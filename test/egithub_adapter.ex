defmodule CredoServer.EgithubAdapter do
  @moduledoc false

  def basic_auth(user, password) do
    :egithub.basic_auth(user, password)
  end

  def oauth(github_token) do
    :egithub.oauth(github_token)
  end

  def file_content(_, _, "without_config", ".credo.exs") do
    :no_content
  end
  def file_content(_, _, _, ".credo.exs") do
    File.read("test/credo_config.exs")
  end
  def file_content(_cred, _repository, _commit_id, _filename) do
    File.read("test/file_example.exs")
  end

  # :egithub_webhook
  def event(_module, _status_cred, _tool_name, _context, _comments_cred, _request) do
    :ok
  end
end
