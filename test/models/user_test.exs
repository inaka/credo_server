defmodule CredoServer.UserTest do
  use ExUnit.Case, async: true
  alias CredoServer.{TestUtils, User, Repo, Repository}

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  test "find by auth token" do
    user = TestUtils.create_user()
    user_fetched = User.find_by_auth_token(user.auth_token)
    assert user == user_fetched
  end

  test "do not find by auth token if expired" do
    now = Ecto.DateTime.utc
    expired = %Ecto.DateTime{day: now.day, hour: now.hour, min: now.min,
                             month: now.month, sec: now.sec, year: now.year - 1}
    user = TestUtils.create_user(expired)
    user_fetched = User.find_by_auth_token(user.auth_token)
    refute user_fetched
  end

  test "raise exception is multiple users with same token" do
    user = TestUtils.create_user()
    TestUtils.create_user()
    assert_raise(Ecto.MultipleResultsError, fn ->
      User.find_by_auth_token(user.auth_token)
    end)
  end

  test "active returns 0 when no repositories are on" do
    user = TestUtils.create_user()
    repo_fields = %{github_id: 56711785, name: "credo_test",
                    full_name: "alemata/credo_test",
                    html_url: "https://github.com/alemata/credo_test",
                    status: "off"}
    repo_info = Ecto.build_assoc(user, :repositories, repo_fields)
    Repo.insert(repo_info)
    active_users = User.active_users()

    assert active_users == []
  end

  test "active returns 1 when 1 user is active" do
    user = TestUtils.create_user()
    repo_fields = %{github_id: 56711785, name: "credo_test",
                    full_name: "alemata/credo_test",
                    html_url: "https://github.com/alemata/credo_test",
                    status: "on"}
    repo_info = Ecto.build_assoc(user, :repositories, repo_fields)
    Repo.insert(repo_info)

    assert [_] = User.active_users()
  end

  test "active returs 1 when 1 user is active (with another not active user)" do
    user = TestUtils.create_user()
    user2 = TestUtils.create_user()
    repo_fields = %{github_id: 56711785, name: "credo_test",
                    full_name: "alemata/credo_test",
                    html_url: "https://github.com/alemata/credo_test",
                    status: "on"}
    repo_info = Ecto.build_assoc(user, :repositories, repo_fields)
    Repo.insert(repo_info)

    repo_fields = %{github_id: 56711785, name: "credo_test",
                    full_name: "alemata/credo_test",
                    html_url: "https://github.com/alemata/credo_test",
                    status: "off"}
    repo_info = Ecto.build_assoc(user2, :repositories, repo_fields)
    Repo.insert(repo_info)

    assert [_] = User.active_users()
  end

  test "active returns 2 when 2 users active" do
    user = TestUtils.create_user()
    user2 = TestUtils.create_user()
    repo_fields = %{github_id: 56711785, name: "credo_test",
                    full_name: "alemata/credo_test",
                    html_url: "https://github.com/alemata/credo_test",
                    status: "on"}
    repo_info = Ecto.build_assoc(user, :repositories, repo_fields)
    Repo.insert(repo_info)

    repo_fields = %{github_id: 56711785, name: "credo_test",
                    full_name: "alemata/credo_test",
                    html_url: "https://github.com/alemata/credo_test",
                    status: "on"}
    repo_info = Ecto.build_assoc(user2, :repositories, repo_fields)
    Repo.insert(repo_info)

    assert [_, _] = User.active_users()
  end

  test "new user is created" do
    use_cassette "github_callback" do
      created_user = User.save("token")
      assert 1 == Repo.all(User) |> Enum.count
      assert created_user.username == "alemata"
    end
  end

  test "user is updated with new token" do
    use_cassette "github_callback" do
      created_user = User.save("token")
      assert 1 == Repo.all(User) |> Enum.count
      assert created_user.username == "alemata"

      updated_user = User.save("token")
      assert 1 == Repo.all(User) |> Enum.count
      assert updated_user.username == "alemata"
      assert updated_user.auth_token != created_user.auth_token
    end
  end
end
