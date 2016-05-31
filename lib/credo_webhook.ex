defmodule CredoServer.CredoWebhook do
  @moduledoc false

  alias CredoServer.GithubUtils
  alias CredoServer.FileUtils

  def handle_pull_request(cred, pr_data, github_files) do
    repository_info = pr_data["repository"]
    repository_path = FileUtils.create_repository_dir(repository_info)
    FileUtils.add_repository_credo_config(cred, pr_data, repository_path)

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
    file_path = FileUtils.create_content_file(cred, repository_info, github_file)

    config = Credo.Config.read_or_default(file_path, ".credo.exs", true)
    case Credo.CLI.Command.Suggest.run(file_path, config) do
      {:error, errors} ->
        create_github_errors_messages(errors, github_file)
      _ ->
        []
    end
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
