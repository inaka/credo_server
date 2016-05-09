defmodule CredoServer.FileUtilsTests do
  use ExUnit.Case
  alias CredoServer.FileUtils
  alias CredoServer.GithubUtils
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  @repository_info %{"statuses_url" => "https://api.github.com/repos/alemata/credo_test/statuses/{sha}",
  "git_refs_url" => "https://api.github.com/repos/alemata/credo_test/git/refs{/sha}",
  "issue_comment_url" => "https://api.github.com/repos/alemata/credo_test/issues/comments{/number}",
  "watchers" => 0, "mirror_url" => :null,
  "languages_url" => "https://api.github.com/repos/alemata/credo_test/languages",
  "stargazers_count" => 0, "forks" => 0, "default_branch" => "master",
  "comments_url" => "https://api.github.com/repos/alemata/credo_test/comments{/number}",
  "commits_url" => "https://api.github.com/repos/alemata/credo_test/commits{/sha}",
  "id" => 56711785, "clone_url" => "https://github.com/alemata/credo_test.git",
  "homepage" => :null,
  "stargazers_url" => "https://api.github.com/repos/alemata/credo_test/stargazers",
  "events_url" => "https://api.github.com/repos/alemata/credo_test/events",
  "blobs_url" => "https://api.github.com/repos/alemata/credo_test/git/blobs{/sha}",
  "forks_count" => 0, "pushed_at" => "2016-04-21T19:16:13Z",
  "git_url" => "git://github.com/alemata/credo_test.git",
  "hooks_url" => "https://api.github.com/repos/alemata/credo_test/hooks",
  "owner" => %{"avatar_url" => "https://avatars.githubusercontent.com/u/210338?v=3",
    "events_url" => "https://api.github.com/users/alemata/events{/privacy}",
    "followers_url" => "https://api.github.com/users/alemata/followers",
    "following_url" => "https://api.github.com/users/alemata/following{/other_user}",
    "gists_url" => "https://api.github.com/users/alemata/gists{/gist_id}",
    "gravatar_id" => "", "html_url" => "https://github.com/alemata",
    "id" => 210338, "login" => "alemata",
    "organizations_url" => "https://api.github.com/users/alemata/orgs",
    "received_events_url" => "https://api.github.com/users/alemata/received_events",
    "repos_url" => "https://api.github.com/users/alemata/repos",
    "site_admin" => false,
    "starred_url" => "https://api.github.com/users/alemata/starred{/owner}{/repo}",
    "subscriptions_url" => "https://api.github.com/users/alemata/subscriptions",
    "type" => "User", "url" => "https://api.github.com/users/alemata"},
  "trees_url" => "https://api.github.com/repos/alemata/credo_test/git/trees{/sha}",
  "git_commits_url" => "https://api.github.com/repos/alemata/credo_test/git/commits{/sha}",
  "collaborators_url" => "https://api.github.com/repos/alemata/credo_test/collaborators{/collaborator}",
  "watchers_count" => 0,
  "tags_url" => "https://api.github.com/repos/alemata/credo_test/tags",
  "merges_url" => "https://api.github.com/repos/alemata/credo_test/merges",
  "releases_url" => "https://api.github.com/repos/alemata/credo_test/releases{/id}",
  "subscribers_url" => "https://api.github.com/repos/alemata/credo_test/subscribers",
  "ssh_url" => "git@github.com:alemata/credo_test.git",
  "created_at" => "2016-04-20T18:40:48Z", "name" => "credo_test",
  "has_issues" => true, "private" => false,
  "git_tags_url" => "https://api.github.com/repos/alemata/credo_test/git/tags{/sha}",
  "archive_url" => "https://api.github.com/repos/alemata/credo_test/{archive_format}{/ref}",
  "has_wiki" => true, "open_issues_count" => 1,
  "milestones_url" => "https://api.github.com/repos/alemata/credo_test/milestones{/number}",
  "forks_url" => "https://api.github.com/repos/alemata/credo_test/forks",
  "url" => "https://api.github.com/repos/alemata/credo_test",
  "downloads_url" => "https://api.github.com/repos/alemata/credo_test/downloads",
  "open_issues" => 1,
  "keys_url" => "https://api.github.com/repos/alemata/credo_test/keys{/key_id}",
  "description" => "",
  "contents_url" => "https://api.github.com/repos/alemata/credo_test/contents/{+path}",
  "language" => "Elixir",
  "contributors_url" => "https://api.github.com/repos/alemata/credo_test/contributors",
  "deployments_url" => "https://api.github.com/repos/alemata/credo_test/deployments",
  "pulls_url" => "https://api.github.com/repos/alemata/credo_test/pulls{/number}",
  "labels_url" => "https://api.github.com/repos/alemata/credo_test/labels{/name}",
  "html_url" => "https://github.com/alemata/credo_test",
  "svn_url" => "https://github.com/alemata/credo_test",
  "issue_events_url" => "https://api.github.com/repos/alemata/credo_test/issues/events{/number}",
  "notifications_url" => "https://api.github.com/repos/alemata/credo_test/notifications{?since,all,participating}",
  "has_downloads" => true,
  "compare_url" => "https://api.github.com/repos/alemata/credo_test/compare/{base}...{head}",
  "full_name" => "alemata/credo_test",
  "subscription_url" => "https://api.github.com/repos/alemata/credo_test/subscription",
  "assignees_url" => "https://api.github.com/repos/alemata/credo_test/assignees{/user}",
  "issues_url" => "https://api.github.com/repos/alemata/credo_test/issues{/number}",
  "size" => 7, "has_pages" => false, "fork" => false,
  "updated_at" => "2016-04-20T18:43:58Z",
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

  test "get repository path" do
    repository_path = FileUtils.repository_path(@repository_info)
    assert String.ends_with?(repository_path, "/alemata/credo_test")
  end

  test "create repository dir" do
    repository_dir = FileUtils.create_repository_dir(@repository_info)
    assert File.exists?(repository_dir)
  end

  test "create content file" do
    cred = GithubUtils.basic_auth()
    repository_path = FileUtils.repository_path(@repository_info)
    FileUtils.create_content_file(cred, @repository_info, @github_file)
    path = "#{repository_path}/lib/another_file.ex"
    assert File.exists?(path)
    assert File.read!(path) == "file content"
  end

  test "add repository config file" do
    pr_data = %{"pull_request" => %{"head" => %{"ref" => "branch"}},
                "repository" => %{"full_name" => "name"}}
    cred = GithubUtils.basic_auth()
    repository_path = FileUtils.create_repository_dir(@repository_info)
    FileUtils.add_repository_credo_config(cred, pr_data, repository_path)
    path = "#{repository_path}/.credo.exs"
    assert File.exists?(path)
    assert File.read!(path) == "file content"
  end

  test "delete repository path" do
    repository_dir = FileUtils.create_repository_dir(@repository_info)
    assert File.exists?(repository_dir)
    FileUtils.delete_repository_dir(repository_dir)
    refute File.exists?(repository_dir)
  end
end
