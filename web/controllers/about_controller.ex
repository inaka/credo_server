defmodule CredoServer.AboutController do
  @moduledoc false

  alias CredoServer.Render

  def about(conn) do
    Render.render(conn, &Render.about/1)
  end
end
