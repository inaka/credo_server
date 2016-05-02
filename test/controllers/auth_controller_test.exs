defmodule CredoServer.AuthControllerTest do
  use ExUnit.Case
  use Plug.Test
  alias CredoServer.Router
  alias CredoServer.Repo
  alias CredoServer.User

  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup_all do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")
    :ok
  end

  @router_opts Router.init([])

  test "render sign up page" do
    conn = conn(:get, "/auth")
    conn = Router.call(conn, @router_opts)
    assert conn.status == 200
    assert conn.resp_body =~ "Sign in with Github"
  end

  test "post to login should redirect to github auth" do
    conn = conn(:post, "/auth/oauth/login")
    conn = Router.call(conn, @router_opts)
    assert conn.status == 302
    assert hd(get_resp_header(conn, "location")) =~ "https://github.com/login/oauth/authorize"
    refute conn.assigns[:user]
  end

  test "create user on github callback" do
    use_cassette "github_callback" do
      conn = conn(:get, "/auth/oauth/callback?code=ac91e51c2ec6c6e3b57b")
      conn = Router.call(conn, @router_opts)
      created_user = Repo.get_by(User, github_token: "1c4a58ba3f7bccb7e0d3c93b224fca796c2f4cfd")
      assert created_user.username == "alemata"
      assert conn.status == 302
      assert hd(get_resp_header(conn, "location")) =~ "/repos"
    end
  end

  test "logout user" do
    conn = conn(:get, "/auth/oauth/logout")
    conn = Router.call(conn, @router_opts)
    refute get_session(conn, :user)
  end
end
