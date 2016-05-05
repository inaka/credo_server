defmodule CredoServerTest do
  use ExUnit.Case
  alias CredoServer.CredoWebhook
  alias CredoServer.GithubUtils

  test "hanlde pull request with default config" do
    cred = GithubUtils.basic_auth()
    pr_data = %{"pull_request" => %{"head" => %{"ref" => "without_config"}},
                "repository" => %{"full_name" => "alemata/credo_test"}}
    github_files = [%{"additions" => 2,
      "blob_url" => "https://github.com/alemata/credo_test/blob/5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695/lib/another_file.ex",
      "changes" => 3,
      "contents_url" => "https://api.github.com/repos/alemata/credo_test/contents/lib/another_file.ex?ref=5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695",
      "deletions" => 1, "filename" => "lib/another_file.ex",
      "patch" => "@@ -45,6 +45,7 @@ defmodule AnotherFile do\n \n \n   def test do\n-    IO.inspect \"this is a test for credo\"\n+    IO.inspect \"this is a test for credo and\"\n+    require IEx; IEx.pry\n   end\n end",
      "raw_url" => "https://github.com/alemata/credo_test/raw/5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695/lib/another_file.ex",
      "sha" => "c1f12c512b6ec76c58e7cdc97b9c5111d3eff8a0", "status" => "modified"}]
    errors = CredoWebhook.handle_pull_request(cred, pr_data, github_files)
    expected = {:ok,
    [
      %{commit_id: '5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695',
        path: "lib/another_file.ex",
        position: 6,
        text: "There should be no calls to IEx.pry/1."},
      %{commit_id: '5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695',
        path: "lib/another_file.ex",
        position: 5,
        text: "There should be no calls to IO.inspect/1."}
    ]}
    assert errors == expected
  end

  test "hanlde pull request with custom config" do
    cred = GithubUtils.basic_auth()
    pr_data = %{"pull_request" => %{"head" => %{"ref" => "with_config"}},
                "repository" => %{"full_name" => "alemata/credo_test"}}
    github_files = [%{"additions" => 2,
   "blob_url" => "https://github.com/alemata/credo_test/blob/5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695/lib/another_file.ex",
   "changes" => 3,
   "contents_url" => "https://api.github.com/repos/alemata/credo_test/contents/lib/another_file.ex?ref=5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695",
   "deletions" => 1, "filename" => "lib/another_file.ex",
   "patch" => "@@ -45,6 +45,7 @@ defmodule AnotherFile do\n \n \n   def test do\n-    IO.inspect \"this is a test for credo\"\n+    IO.inspect \"this is a test for credo and\"\n+    require IEx; IEx.pry\n   end\n end",
   "raw_url" => "https://github.com/alemata/credo_test/raw/5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695/lib/another_file.ex",
   "sha" => "c1f12c512b6ec76c58e7cdc97b9c5111d3eff8a0", "status" => "modified"}]
    errors = CredoWebhook.handle_pull_request(cred, pr_data, github_files)
    expected = {:ok,
    [
      %{commit_id: '5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695',
        path: "lib/another_file.ex",
        position: 6,
        text: "There should be no calls to IEx.pry/1."}
    ]}
    assert errors == expected
  end
end
