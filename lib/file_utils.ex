defmodule CredoServer.FileUtils do
  @moduledoc false
  alias CredoServer.GithubUtils

  def repository_path(repository_info) do
    repository = repository_info["full_name"]
    "#{System.tmp_dir}#{repository}"
  end

  def create_repository_dir(repository_info) do
    path = repository_path(repository_info)
    File.mkdir_p(Path.dirname(path))

    path
  end

  def create_content_file(cred, repository_info, github_file) do
    commit_id = GithubUtils.commit_id(github_file)
    repository = repository_info["full_name"]
    filename = github_file["filename"]
    {:ok, content} = :egithub.file_content(cred, repository, commit_id, filename)

    repository_path = create_repository_dir(repository_info)
    file_path = "#{repository_path}/#{filename}"
    File.mkdir_p(Path.dirname(file_path))
    File.write(file_path, content)

    file_path
  end

  def add_repository_credo_config(cred, pr_data, repository_path) do
    branch = pr_data["pull_request"]["head"]["ref"]
    repository_name = pr_data["repository"]["full_name"]
    case :egithub.file_content(cred, repository_name, branch, ".credo.exs") do
      {:ok, content} ->
        config_path = "#{repository_path}/.credo.exs"
        File.write(config_path, content)
    end
  end

  def delete_repository_dir(path) do
    File.rm_rf(path)
  end
end
