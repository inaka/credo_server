defmodule CredoServer.User do
  @moduledoc false

  import Ecto.Query
  import Ecto.Changeset
  alias CredoServer.Repo
  alias CredoServer.User
  alias CredoServer.Repository
  use Ecto.Schema

  schema "users" do
    field :name, :string
    field :username, :string
    field :github_token, :string
    field :email, :string
    field :email_code, :string
    field :auth_token, :string
    field :auth_expires, Ecto.DateTime
    field :synced_at, Ecto.DateTime
    has_many :repositories, CredoServer.Repository

    timestamps
  end

  @fields [:name, :username, :github_token,
           :email, :auth_token, :auth_expires]

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  @doc """
  Gets an user that matches with the given `token` and token hasn't expired.
  """
  def find_by_auth_token(token) do
    now = Ecto.DateTime.utc
    query = from(user in __MODULE__,
                 where: user.auth_token == ^token and user.auth_expires > ^now)

    case Repo.all(query) do
      []    -> nil
      [user] -> user
      users -> raise Ecto.MultipleResultsError,
                     queryable: CredoServer.User,
                     count: length(users)
    end
  end

  @doc """
  Save a user with the given token.
  """
  def save(token) do
    client = Tentacat.Client.new(%{access_token: token})
    github_user = Tentacat.Users.me(client)

    {:ok, user} =
      case Repo.get_by(User, username: github_user["login"]) do
        nil ->
          create_user(client, github_user, token)
        found_user ->
          update_token(found_user)
      end

      user
  end

  @doc """
  Sync user repositories
  """
  def sync_repositories(user) do
    Repo.delete_all Ecto.assoc(user, :repositories)
    public_repos = User.public_repos(user)
    create_user_repos(user, public_repos)
    user_change = Ecto.Changeset.change(user, synced_at: Ecto.DateTime.utc)
    Repo.update(user_change)
  end

  # Private

  defp create_user_repos(user, public_repos) do
    Enum.map(public_repos, fn(repo) ->
      status = Repository.webhook_status(repo, user)

      repo_info = [github_id: repo["id"], name: repo["name"],
                   full_name: repo["full_name"], html_url: repo["html_url"],
                   status: status]
      repo = Ecto.build_assoc(user, :repositories, repo_info)

      Repo.insert(repo)
    end)
  end

  defp create_user(client, github_user, token) do
    emails = Tentacat.Users.Emails.list(client)
    %{"email" => email} = Enum.find(emails, fn(e) -> e["primary"] end)

    user_info = %{username: github_user["login"],
                  name: github_user["name"],
                  github_token: token,
                  email: email,
                  auth_token: new_auth_token,
                  auth_expires: new_expiration_date}
    user_changeset = User.changeset(%User{}, user_info)

    Repo.insert(user_changeset)
  end

  def public_repos(user) do
    user
    |> get_repos
    |> Enum.filter(fn(repo) -> not repo["private"] end)
  end

  def tentacat_client(user) do
    Tentacat.Client.new(%{access_token: user.github_token})
  end

  # Private

  defp update_token(user) do
    user_changeset = change(user,
                            auth_token: new_auth_token,
                            auth_expires: new_expiration_date)
    Repo.update(user_changeset)
  end

  defp get_repos(user) do
    client = tentacat_client(user)
    Tentacat.Repositories.list_mine(client)
  end

  defp new_auth_token do
    SecureRandom.uuid
  end

  defp new_expiration_date do
    now = Ecto.DateTime.utc
    %Ecto.DateTime{day: now.day + 1, hour: now.hour, min: now.min,
                   month: now.month, sec: now.sec, year: now.year}
  end
end
