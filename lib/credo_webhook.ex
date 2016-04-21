defmodule CredoServer.CredoWebhook do
  @moduledoc false

  alias CredoServer.GithubUtils

  def handle_pull_request(cred, data, github_files) do
    errors =
      Enum.map(github_files, fn(github_file) ->
        run_credo(cred, data, github_file)
      end)

      {:ok, List.flatten(errors)}
  end

  def run_credo(cred, data, github_file) do
    path = create_content_file(cred, data, github_file)

    config = Credo.Config.read_or_default(path)
    case Credo.CLI.Command.Suggest.run(path, config) do
      {:error, errors} ->
        create_github_errors_messages(errors, github_file)
      _ ->
        []
    end
  end

  def create_content_file(cred, data, github_file) do
    repository = data["repository"]["full_name"]
    filename = github_file["filename"]
    path = "#{System.tmp_dir}#{repository}/#{filename}"
    File.mkdir_p(Path.dirname(path))

    commit_id = GithubUtils.commit_id(github_file)
    {:ok, content} = :egithub.file_content(cred, repository, commit_id, filename)
    File.write(path, content)

    path
  end

  def create_github_errors_messages(errors, github_file) do
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
