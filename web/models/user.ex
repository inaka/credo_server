defmodule CredoServer.User do
  @moduledoc false

  import Ecto.Changeset
  import Ecto.Query
  use Ecto.Schema
  alias CredoServer.{Repo, User, Repository}

  schema "users" do
    field :name, :string
    field :username, :string
    field :github_token, :string
    field :email, :string
    field :email_code, :string
    field :auth_token, :string
    field :auth_expires, Ecto.DateTime
    field :synced_at, Ecto.DateTime
    has_many :repositories, Repository

    timestamps
  end

  @fields [:name, :username, :github_token,
           :email, :auth_token, :auth_expires]

  def changeset(user, params \\ :empty) do
    user
    |> cast(params, @fields, @fields)
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
                     queryable: User,
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
    public_repositories = get_public_repositories(user)
    create_user_repos(user, public_repositories)
    user_change = Ecto.Changeset.change(user, synced_at: Ecto.DateTime.utc)
    Repo.update(user_change)
  end

  def repositories_query(user) do
    query = Ecto.assoc(user, :repositories)
    Ecto.Query.order_by(query, [r], r.full_name)
  end

  @doc """
  Get amount of users who have at least one repository being checked
  """
  def active_users() do
    query = from(c in CredoServer.User,
                 join: p in assoc(c, :repositories),
                 where: p.status == "on", group_by: c.id)

    CredoServer.Repo.all(query)
  end

  # Private

  defp create_user_repos(user, public_repositories) do
    Enum.map(public_repositories, fn(repo) ->
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


  def tentacat_client(user) do
    Tentacat.Client.new(%{access_token: user.github_token})
  end

  # Private

  defp get_public_repositories(user) do
    user
    |> get_repositories
    |> Enum.filter(&public_and_admin_filter/1)
  end

  defp public_and_admin_filter(repository_info) do
    not repository_info["private"] and repository_info["permissions"]["admin"]
  end

  defp update_token(user) do
    user_changeset = change(user,
                            auth_token: new_auth_token,
                            auth_expires: new_expiration_date)
    Repo.update(user_changeset)
  end

  defp get_repositories(user) do
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
