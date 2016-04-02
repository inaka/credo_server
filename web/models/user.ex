defmodule CredoServer.User do
  use CredoServer.Web, :model

  import Ecto.Query
  alias CredoServer.Repo
  alias CredoServer.User

  schema "users" do
    field :name, :string
    field :username, :string
    field :github_token, :string
    field :email, :string
    field :email_code, :string
    field :auth_token, :string
    field :auth_expires, Ecto.DateTime
    field :synced_at, Ecto.DateTime

    timestamps
  end

  @required_fields ~w(name username github_token email auth_token auth_expires)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  @doc """
  Gets an user that matches with the given `token` and token hasn't expired.
  """
  def find_by_auth_token(token) do
    now = Ecto.DateTime.utc
    users =
      from(u in CredoServer.User)
        |> where([u], u.auth_token == ^token and u.auth_expires > ^now)
        |> Repo.all

    case users do
      [one] -> one
      []    -> nil
      other -> raise Ecto.MultipleResultsError,
                     queryable: CredoServer.User,
                     count: length(other)
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
          emails = Tentacat.Users.Emails.list(client)
          %{"email" => email} = Enum.find(emails, fn(e) -> e["primary"] end)


          changeset = User.changeset(%User{}, %{username: github_user["login"], name: github_user["name"],
                                                github_token: token, email: email,
                                                auth_token: new_auth_token, auth_expires: new_expiration_date})

          {:ok, new_user } = Repo.insert(changeset)
        found_user ->
          changeset = Ecto.Changeset.change found_user, auth_token: new_auth_token, auth_expires: new_expiration_date
          {:ok, updated_user} = Repo.update(changeset)
      end

      user
  end

  # Private

  defp new_auth_token do
    SecureRandom.uuid
  end

  defp new_expiration_date do
    now = Ecto.DateTime.local
    tomorrow = %Ecto.DateTime{day: now.day + 1, hour: now.hour, min: now.min,
                              month: now.month, sec: now.sec, year: now.year}
  end
end
