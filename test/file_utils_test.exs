defmodule CredoServer.FileUtilsTests do
  use ExUnit.Case
  alias CredoServer.{FileUtils, GithubUtils}
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @repository_info %{"statuses_url" => "https://api.github.com/repos/alemata/credo_test/statuses/{sha}",
  "git_refs_url" => "https://api.github.com/repos/alemata/credo_test/git/refs{/sha}",
  "issue_comment_url" => "https://api.github.com/repos/alemata/credo_test/issues/comments{/number}",
  "has_downloads" => true,
  "compare_url" => "https://api.github.com/repos/alemata/credo_test/compare/{base}...{head}",
  "full_name" => "alemata/credo_test",
  "subscription_url" => "https://api.github.com/repos/alemata/credo_test/subscription",
  "assignees_url" => "https://api.github.com/repos/alemata/credo_test/assignees{/user}",
  "branches_url" => "https://api.github.com/repos/alemata/credo_test/branches{/branch}",
  "teams_url" => "https://api.github.com/repos/alemata/credo_test/teams"}

  @github_file %{"additions" => 2,
  "blob_url" => "https://github.com/alemata/credo_test/blob/5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695/lib/another_file.ex",
  "changes" => 3,
  "contents_url" => "https://api.github.com/repos/alemata/credo_test/contents/lib/another_file.ex?ref=5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695",
  "deletions" => 1, "filename" => "lib/another_file.ex",
  "patch" => "@@ -45,6 +45,7 @@ defmodule AnotherFile do\n \n \n   def test do\n-    IO.inspect \"this is a test for credo\"\n+    IO.inspect \"this is a test for credo and\"\n+    require IEx; IEx.pry\n   end\n end",
  "raw_url" => "https://github.com/alemata/credo_test/raw/5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695/lib/another_file.ex",
  "sha" => "c1f12c512b6ec76c58e7cdc97b9c5111d3eff8a0", "status" => "modified"}

  test "create repository dir" do
    repository_dir = FileUtils.create_repository_dir(@repository_info["full_name"])
    assert File.exists?(repository_dir)
  end

  test "create content file" do
    cred = GithubUtils.basic_auth()
    repository_path = FileUtils.create_repository_dir(@repository_info["full_name"])
    FileUtils.create_content_file(cred, @repository_info["full_name"], repository_path, @github_file)
    path = "#{repository_path}/lib/another_file.ex"
    assert File.exists?(path)
    assert File.read!(path) == File.read!("test/file_example.exs")
  end

  test "add repository config file" do
    pr_data = %{"pull_request" => %{"head" => %{"ref" => "branch"}},
                "repository" => @repository_info}
    cred = GithubUtils.basic_auth()
    repository_path = FileUtils.create_repository_dir(@repository_info["full_name"])
    FileUtils.add_repository_credo_config(cred, pr_data, repository_path)
    path = "#{repository_path}/.credo.exs"
    assert File.exists?(path)
    assert File.read!(path) == File.read!("test/credo_config.exs")
  end

  test "delete repository path" do
    repository_dir = FileUtils.create_repository_dir(@repository_info["full_name"])
    assert File.exists?(repository_dir)
    FileUtils.delete_repository_dir(repository_dir)
    refute File.exists?(repository_dir)
  end
end
