defmodule CredoServer.UserTest do
  use CredoServer.ModelCase

  alias CredoServer.User

  @valid_attrs %{auth_expires: "2010-04-17 14:00:00", auth_token: "some content", email: "some content", email_code: "some content", github_token: "some content", name: "some content", synced_at: "2010-04-17 14:00:00", username: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
