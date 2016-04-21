defmodule CredoServer.Repository do
  use Ecto.Schema
  import Ecto.Changeset
  alias CredoServer.Repo
  alias CredoServer.Repository
  alias CredoServer.User

  schema "repositories" do
    belongs_to :user, CredoServer.User
    field :github_id, :integer
    field :name, :string
    field :full_name, :string
    field :html_url, :string
    field :private, :boolean, default: false
    field :status, :string

    timestamps
  end

  @fields [:github_id, :name, :full_name, :html_url, :private, :status]

  def changeset(repository, params \\ :empty) do
    repository
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  def webhook_status(repository_response, user) do
    case credo_webhook(user, repository_response["name"]) do
      nil -> "off"
      _ -> "on"
    end
  end

  def add_webhook(repository, user) do
     client = User.tentacat_client(user)
     case Tentacat.Hooks.create(user.username, repository.name, new_hook_body, client) do
       {201, _} ->
         repo_change = Ecto.Changeset.change(repository, status: "on")
         Repo.update(repo_change)
         :ok
       _ ->
         :error
     end
  end

  def remove_webhook(repository, user) do
    credo_webhook = credo_webhook(user, repository.name)

    if credo_webhook do
      client = User.tentacat_client(user)
      Tentacat.Hooks.remove(user.username, repository.name, credo_webhook["id"], client)
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

  # Private

  defp credo_webhook(user, repository_name) do
    hooks = webhooks(user, repository_name)
    Enum.find(hooks, fn(hook) ->
      hook["config"]["url"] == Application.get_env(:credo_server, :webhook_url)
    end)
  end

  defp webhooks(user, repository_name) do
    client = User.tentacat_client(user)
    case Tentacat.Hooks.list(user.username, repository_name, client) do
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
