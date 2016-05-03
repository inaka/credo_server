defmodule CredoServer.CredoWebhook do
  @moduledoc false

  alias CredoServer.GithubUtils
  alias CredoServer.FileUtils

  def handle_pull_request(cred, pr_data, github_files) do
    repository_info = pr_data["repository"]
    repository_path = FileUtils.create_repository_dir(repository_info)
    add_repository_credo_config(cred, pr_data, repository_path)

    errors = run_credo(cred, repository_info, github_files)

    FileUtils.delete_repository_dir(repository_path)

    {:ok, errors}
  end

  # Private

  defp run_credo(cred, repository_info, github_files) when is_list(github_files) do
    github_files
    |> Enum.map(&run_credo(cred, repository_info, &1))
    |> List.flatten()
  end

  defp run_credo(cred, repository_info, github_file) do
    file_path = create_content_file(cred, repository_info, github_file)

    config = Credo.Config.read_or_default(file_path)
    case Credo.CLI.Command.Suggest.run(file_path, config) do
      {:error, errors} ->
        create_github_errors_messages(errors, github_file)
      _ ->
        []
    end
  end

  defp add_repository_credo_config(cred, pr_data, repository_path) do
    branch = pr_data["pull_request"]["head"]["ref"]
    repository_name = pr_data["repository"]["full_name"]
    case :egithub.file_content(cred, repository_name, branch, ".credo.exs") do
      {ok, content} ->
        config_path = "#{repository_path}/.credo.exs"
        File.write(config_path, content)
    end
  end

  defp create_content_file(cred, repository_info, github_file) do
    filename = github_file["filename"]
    repository_path = FileUtils.create_repository_dir(repository_info)
    file_path = "#{repository_path}/#{filename}"
    File.mkdir_p(Path.dirname(file_path))

    commit_id = GithubUtils.commit_id(github_file)
    repository = repository_info["full_name"]
    {:ok, content} = :egithub.file_content(cred, repository, commit_id, filename)
    File.write(file_path, content)

    file_path
  end

  defp create_github_errors_messages(errors, github_file) do
    Enum.flat_map(errors, fn(error) ->
      patch = github_file["patch"]
      case GithubUtils.get_relative_position(patch, error.line_no) do
        {:ok, relative_position} ->
          [%{commit_id: GithubUtils.commit_id(github_file),
             path: github_file["filename"], position: relative_position,
             text: error.message}]
        :not_found ->
          []
      end
    end)
  end
end