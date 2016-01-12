defmodule CredoServer.StatusController do
  use CredoServer.Web, :controller

  import CredoServer.Router.Helpers

  def show(conn, _opts) do
    render(conn, "show.json", response: "OK")
  end

end

defmodule CredoServer.StatusView do
  use CredoServer.Web, :view

  def render("show.json", %{response: response}) do
    %{status: response}
  end
end
