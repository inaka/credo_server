defmodule CredoServer.CredoWebhook do
  @moduledoc false

  alias CredoServer.GithubUtils
  alias CredoServer.FileUtils

  def handle_pull_request(cred, pr_data, github_files) do
    repository_name = pr_data["repository"]["full_name"]
    repository_path = FileUtils.create_repository_dir(repository_name)
    FileUtils.add_repository_credo_config(cred, pr_data, repository_path)

    #Add all pr's files to the repository
    add_pr_files(cred, repository_name, repository_path, github_files)
    #Run credo on the repository
    errors = run_credo(cred, repository_path, github_files)

    FileUtils.delete_repository_dir(repository_path)

    {:ok, errors}
  end

  # Private

  defp add_pr_files(cred, repository_name, repository_path, github_files) do
    github_files
    |> Enum.map(&add_pr_file(cred, repository_name, repository_path,  &1))
  end

  defp add_pr_file(cred, repository_name, repository_path, github_file) do
    FileUtils.create_content_file(cred, repository_name, repository_path, github_file)
  end

  # Run credo on the repository, which only has pr's files.
  defp run_credo(cred, repository_path, github_files) do
    config = Credo.Config.read_or_default(repository_path, "default", true)
    case Credo.CLI.Command.Suggest.run(repository_path, config) do
      {:error, issues} ->
        create_github_issues_messages(issues, github_files)
      _ ->
        []
    end
  end

  defp create_github_issues_messages(issues, github_files) do
    issues
    |> Enum.uniq
    |> Enum.flat_map(&create_github_issue(&1, github_files))
  end

  defp create_github_issue(issue, github_files) do
    github_file = find_pr_file_from_issue(issue, github_files)
    patch = github_file["patch"]
    case GithubUtils.get_relative_position(patch, issue.line_no) do
      {:ok, relative_position} ->
        [%{commit_id: GithubUtils.commit_id(github_file),
           path: github_file["filename"], position: relative_position,
           text: issue.message}]
      :not_found ->
        []
    end
  end

  defp find_pr_file_from_issue(issue, github_files) do
    Enum.find(github_files, fn(file) ->
      String.ends_with?(issue.filename, file["filename"]) 
    end)
  end
end
