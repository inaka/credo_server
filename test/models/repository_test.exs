defmodule CredoServer.RepositoryTest do
  use ExUnit.Case, async: true
  alias CredoServer.Repository

  @fields %{github_id: 56711785, name: "credo_test",
            full_name: "alemata/credo_test",
            html_url: "https://github.com/alemata/credo_test",
            status: "off"}

  test "changeset with valid attributes" do
    changeset = Repository.changeset(%Repository{}, @fields)
    assert changeset.valid?
  end
end
