defmodule CredoServer.AuthControllerTest do
  use ExUnit.Case
  use Plug.Test
  alias CredoServer.{Router, Repo, User}

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo)
    :ok
  end

  @router_opts Router.init([])

  test "render sign up page" do
    conn =
      conn(:get, "/auth")
      |> Router.call(@router_opts)

    assert conn.status == 200
    assert conn.resp_body =~ "Sign in with Github"
  end

  test "post to login should redirect to github auth" do
    conn =
      conn(:post, "/auth/oauth/login")
      |> Router.call(@router_opts)

    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) =~ "https://github.com/login/oauth/authorize"
    refute conn.assigns[:user]
  end

  test "create user on github callback" do
    use_cassette "github_callback" do
      conn = conn(:get, "/auth/oauth/callback?code=ac91e51c2ec6c6e3b57b")
      assert 0 == Repo.all(User) |> Enum.count
      conn = Router.call(conn, @router_opts)
      created_user = Repo.get_by(User, github_token: "github_token_example")

      assert 1 == Repo.all(User) |> Enum.count
      assert created_user.username == "alemata"
      assert conn.status == 302
      assert hd(get_resp_header(conn, "location")) =~ "/repos"
    end
  end

  test "logout user" do
    conn =
      conn(:get, "/auth/oauth/logout")
      |> Router.call(@router_opts)

    refute get_session(conn, :user)
  end
end
