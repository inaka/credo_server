defmodule CredoServer.CredoWebhook do
  @moduledoc false

  alias CredoServer.GithubUtils
  alias CredoServer.FileUtils

  def handle_pull_request(cred, pr_data, github_files) do
    repository_info = pr_data["repository"]
    repository_path = FileUtils.create_repository_dir(repository_info)

    errors =
      Enum.map(github_files, fn(github_file) ->
        run_credo(cred, repository_info, github_file)
      end)

    FileUtils.delete_repository_dir(repository_path)

    {:ok, List.flatten(errors)}
  end

  # Private

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
