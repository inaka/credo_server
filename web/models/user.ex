defmodule CredoServer.User do
  use CredoServer.Web, :model
  
  import Ecto.Query
  alias CredoServer.Repo

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

  @required_fields ~w(name username github_token email email_code auth_token auth_expires synced_at)
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
end
