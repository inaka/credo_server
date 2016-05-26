defmodule CredoServer.Repository do
  @moduledoc false

  use Ecto.Schema
  require Logger
  import Ecto.Changeset
  alias CredoServer.{Repo, Repository, User}

  schema "repositories" do
    belongs_to :user, CredoServer.User
    field :github_id, :integer
    field :name, :string
    field :owner, :string
    field :full_name, :string
    field :html_url, :string
    field :private, :boolean, default: false
    field :status, :string

    timestamps
  end

  @fields [:github_id, :name, :full_name, :html_url, :private, :status, :owner]

  def changeset(repository, params \\ :empty) do
    repository
    |> cast(params, @fields, @fields)
  end

  def webhook_status(repository_response, user) do
    repo_owner = repository_response["owner"]["login"]
    repo_name = repository_response["name"]
    case get_credo_webhook(user, repo_owner, repo_name) do
      nil -> "off"
      _ -> "on"
    end
  end

  def add_webhook(repository, user) do
     client = User.tentacat_client(user)
     case Tentacat.Hooks.create(repository.owner, repository.name, new_hook_body, client) do
       {201, _} ->
         repo_change = Ecto.Changeset.change(repository, status: "on")
         Repo.update(repo_change)
         :ok
       {_, error} ->
         Logger.error("There was an error adding the webhook" <> inspect error)
         :error
     end
  end

  def remove_webhook(repository, user) do
    credo_webhook = get_credo_webhook(user, repository.owner, repository.name)

    if credo_webhook do
      client = User.tentacat_client(user)
      Tentacat.Hooks.remove(repository.owner, repository.name, credo_webhook["id"], client)
      repo_change = Ecto.Changeset.change(repository, status: "off")
      Repo.update(repo_change)
    end
  end

  def action_method(%Repository{status: "on"}) do
    "delete"
  end
  def action_method(%Repository{status: "off"}) do
    "post"
  end

  def get_repository_with_user(repository_name) do
    repository = Repo.get_by(Repository, full_name: repository_name)
    Repo.preload(repository, [:user])
  end

  def public_and_admin_filter(repository_info) do
    not repository_info["private"] and repository_info["permissions"]["admin"]
  end

  def elixir_repo_filter(%{"language" => "Elixir"}) do
    true
  end
  def elixir_repo_filter(%{"language" => nil}) do
    true
  end
  def elixir_repo_filter(repository_info) do
    case HTTPoison.get(repository_info["languages_url"]) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, response} = Poison.decode(body)
        Map.has_key?(response, "Elixir")
      _ ->
        false
    end
  end

  # Private

  defp get_credo_webhook(user, repository_owner, repository_name) do
    hooks = webhooks(user, repository_owner, repository_name)
    Enum.find(hooks, fn(hook) ->
      hook["config"]["url"] == Application.get_env(:credo_server, :webhook_url)
    end)
  end

  defp webhooks(user, repository_owner, repository_name) do
    client = User.tentacat_client(user)
    case Tentacat.Hooks.list(repository_owner, repository_name, client) do
      hooks when is_list(hooks) ->
        hooks
      _ ->
        []
    end
  end

  defp new_hook_body() do
    %{
      "name" => "web",
      "active" => true,
      "events" => ["pull_request"],
      "config" => %{
        "url" => Application.get_env(:credo_server, :webhook_url),
        "content_type" => "json"
      }
    }
  end
end
