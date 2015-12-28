defmodule CredoServer.Repository do
  use CredoServer.Web, :model

  schema "repositories" do
    belongs_to :user_id, CredoServer.User
    field :github_id, :integer
    field :name, :string
    field :full_name, :string
    field :html_url, :string
    field :private, :boolean, default: false
    field :status, :string

    timestamps
  end

  @required_fields ~w(github_id name full_name html_url private status)
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
end
