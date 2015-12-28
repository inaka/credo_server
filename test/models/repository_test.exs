defmodule CredoServer.RepoTest do
  use CredoServer.ModelCase

  alias CredoServer.Repository

  @valid_attrs %{full_name: "some content", github_id: 42, html_url: "some content", name: "some content", private: true, status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Repository.changeset(%Repository{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Repository.changeset(%Repository{}, @invalid_attrs)
    refute changeset.valid?
  end
end
