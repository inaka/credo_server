defmodule CredoServer.Render do
  @moduledoc false

  import Plug.Conn
  require EEx
  EEx.function_from_file(:def, :repositories_index,
                         "web/templates/repositories/index.html.eex",
                         [:assigns])

  EEx.function_from_file(:def, :sing_up,
                         "web/templates/sign_up.html.eex",
                         [:assigns])

  EEx.function_from_file(:def, :layout,
                         "web/templates/layout/layout.html.eex",
                         [:assigns])


  def render(conn, template_method) do
    conn = assign(conn, :view_template, template_method)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(conn.status || 200, layout(conn.assigns))
  end

  def render_template(template_method, assigns) do
    template_method.(assigns)
  end
end
