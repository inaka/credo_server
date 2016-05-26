defmodule CredoServer.RepositoryTest do
  use ExUnit.Case, async: false
  alias CredoServer.Repository

  @fields %{github_id: 56711785, name: "credo_test",
            full_name: "alemata/credo_test",
            html_url: "https://github.com/alemata/credo_test",
            owner: "alemata", status: "off"}

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "changeset with valid attributes" do
    changeset = Repository.changeset(%Repository{}, @fields)
    assert changeset.valid?
  end

  # Filters

  test "admin persmissions filter when private" do
    repo_info = %{"private" => true}
    refute Repository.public_and_admin_filter(repo_info)
  end
  test "admin persmissions filter when public but not admin" do
    repo_info = %{"private" => false, "permissions" => %{"not_admin" => true}}
    refute Repository.public_and_admin_filter(repo_info)
  end
  test "admin persmissions filter when public and admin" do
    repo_info = %{"private" => false, "permissions" => %{"admin" => true}}
    assert Repository.public_and_admin_filter(repo_info)
  end

  test "admin language filter when language is Elixir" do
    repo_info = %{"language" => "Elixir"}
    assert Repository.elixir_repo_filter(repo_info)
  end
  test "admin language filter when language not present" do
    repo_info = %{"language" => nil}
    assert Repository.elixir_repo_filter(repo_info)
  end
  test "admin language filter when Elixir is in languages" do
    use_cassette "languages_with_elixir" do
      repo_info = %{"language" => "Ruby", "languages_url" => "https://api.github.com/repos/inaka/dayron/languages"}
      assert Repository.elixir_repo_filter(repo_info)
    end
  end
  test "admin language filter when Elixir is not in languages" do
    use_cassette "languages_without_elixir" do
      repo_info = %{"language" => "Ruby", "languages_url" => "https://api.github.com/repos/inaka/elvis/languages"}
      refute Repository.elixir_repo_filter(repo_info)
    end
  end
end
