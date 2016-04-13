defmodule CredoServer.Repository do
  use Ecto.Schema
  import Ecto.Changeset

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
    hooks = webhooks(user, repository_response)
    credo_webhook =
      Enum.find(hooks, fn(hook) ->
        hook["config"]["url"] == Application.get_env(:credo_server, :webhook_url)
      end)

    case credo_webhook do
      nil -> "off"
      _ -> "on"
    end
  end

  # Private

  defp webhooks(user, repository_response) do
    client = Tentacat.Client.new(%{access_token: user.github_token})
    case Tentacat.Hooks.list(user.username, repository_response["name"], client) do
      hooks when is_list(hooks) ->
        hooks
      _ ->
        []
    end
  end
end
