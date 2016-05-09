defmodule CredoServer.EgithubAdapter do
  @moduledoc false

  def basic_auth(user, password) do
    :egithub.basic_auth(user, password)
  end

  def oauth(github_token) do
    :egithub.oauth(github_token)
  end

  def file_content(cred, repository, commit_id, filename) do
    {:ok, "file content"}
  end
end
