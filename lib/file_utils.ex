defmodule CredoServer.FileUtils do
  @moduledoc false
  alias CredoServer.GithubUtils

  def create_repository_dir(repository_info) do
    path = get_repository_path(repository_info)
    File.mkdir_p(path)

    path
  end

  def create_content_file(cred, repository_name, repository_path,  github_file) do
    commit_id = GithubUtils.commit_id(github_file)
    filename = github_file["filename"]
    {:ok, content} = GithubUtils.file_content(cred, repository_name,
                                              commit_id, filename)

    file_path = "#{repository_path}/#{filename}"
    File.mkdir_p(Path.dirname(file_path))
    File.write(file_path, content)

    file_path
  end

  def add_repository_credo_config(cred, pr_data, repository_path) do
    branch = pr_data["pull_request"]["head"]["ref"]
    repository_name = pr_data["repository"]["full_name"]
    config_content = GithubUtils.file_content(cred, repository_name,
                                              branch, ".credo.exs")
    case config_content do
      {:ok, content} ->
        config_path = "#{repository_path}/.credo.exs"
        File.write(config_path, content)
      _ ->
        :ok
    end
  end

  def delete_repository_dir(path) do
    File.rm_rf(path)
  end

  defp get_repository_path(repository_name) do
    random = SecureRandom.urlsafe_base64(6)
    "#{System.tmp_dir}#{random}/#{repository_name}"
  end
end
