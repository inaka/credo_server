defmodule CredoServer.GithubUtils do
  @moduledoc false

  @egithub Application.get_env(:credo_server, :egithub)
  @egithub_webhook Application.get_env(:credo_server, :egithub_webhook)

  def commit_id(github_file) do
    commit_regexp = ~r/.+\/raw\/(?<commit>\w+)\//
    raw_url = github_file["raw_url"]
    commit_id_str = Regex.named_captures(commit_regexp, raw_url)["commit"]
    to_char_list(commit_id_str)
  end

  def get_relative_position(patch, abs_number) do
    lines = String.split(patch, "\n")
    get_relative_position(lines, abs_number, {-1, :undefined})
  end

  def basic_auth() do
    user = String.to_char_list(Application.get_env(:credo_server, :github_user))
    password = String.to_char_list(Application.get_env(:credo_server, :github_password))
    @egithub.basic_auth(user, password)
  end

  def oauth(github_token) do
    @egithub.oauth(github_token)
  end

  def file_content(cred, repository, commit_id, filename) do
    @egithub.file_content(cred, repository, commit_id, filename)
  end

  def event(module, status_cred, tool_name, context, comments_cred, request) do
    @egithub_webhook.event(module, status_cred,
                           tool_name, context,
                           comments_cred, request)
  end

  # Private

  defp get_relative_position([], _, _) do
    :not_found
  end
  defp get_relative_position([line | lines], abs_number, positions) do
    type = patch_line_type(line)
    case new_position(line, positions) do
      {local, global} when global == abs_number and type == :addition ->
        {:ok, local}
      new_postitions ->
        get_relative_position(lines, abs_number, new_postitions)
    end
  end

  defp new_position(line, {local, global}) do
    new_local = local + 1
    case patch_line_type(line) do
      :patch ->
        new_global = path_position(line)
        {new_local, new_global - 1}
      :deletion ->
        {new_local, global}
      _ ->
        {new_local, global + 1}
    end
  end

  defp patch_line_type(line) do
    case String.slice(line, 0..0) do
      "@"  -> :patch;
      "+"  -> :addition;
      "-"  -> :deletion;
      _    -> :same;
    end
  end

  defp path_position(line) do
    position_regexp = ~r/^@@ .*? \+(?<position>\d+),.*$/
    position_string = Regex.named_captures(position_regexp, line)["position"]
    {position, _} = Integer.parse(position_string)

    position
  end

end
