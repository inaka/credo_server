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
  def file_content(cred, repository, commit_id, filename) do
    File.read("test/file_example.exs")
  end

  # :egithub_webhook
  def event(module, status_cred, tool_name, context, comments_cred, request) do
    :ok
  end
end
