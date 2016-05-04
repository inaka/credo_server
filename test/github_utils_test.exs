defmodule CredoServer.GithubUtilsTests do
  use ExUnit.Case
  alias CredoServer.GithubUtils

  @github_file  %{"additions" => 91,
    "blob_url" => "https://github.com/alemata/credo_test/blob/5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695/.credo.exs",
    "changes" => 91,
    "contents_url" => "https://api.github.com/repos/alemata/credo_test/contents/.credo.exs?ref=5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695",
    "deletions" => 0, "filename" => ".credo.exs",
    "patch" => "@@ -109,7 +109,7 @@ option_spec_list() ->\n     [\n      {help,$h, \"help\", undefined, \"Show this help information.\"},\n{config, $c, \"config\", string, Commands},\n-{commands, undefined, \"commands\", undefined, \"Show availablecommands.\"}\n+     {commands, undefined, \"commands\",undefined, \"Show available commands.\"} %% Long Line\n].\n \n -spec process_options([atom()], [string()]) -> ok.\n@@ -175,3 +175,5 @@ git-hook         Pre-commit Git Hook:Gets all staged files and runs the rules\nfiles.\n \">>,\n    io:put_chars(Commands).\n+\n+%% Another dummy change to check how patches are builtwith changes wide apart.",
    "raw_url" => "https://github.com/alemata/credo_test/raw/5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695/.credo.exs",
    "sha" => "98049e08ec29b479179982c817bd111379c199b6", "status" => "added"}

  test "get commit id from github_file" do
    commit_id = GithubUtils.commit_id(@github_file)
    assert commit_id == '5f58c47bd71c97cdfe46d4ef456b9d0a0fd10695'
  end

  test "get relative position" do
    {:ok, position} = GithubUtils.get_relative_position(@github_file["patch"], 112)
    assert position == 5
    {:ok, position} = GithubUtils.get_relative_position(@github_file["patch"], 178)
    assert position == 13
    {:ok, position} = GithubUtils.get_relative_position(@github_file["patch"], 179)
    assert position == 14
    assert :not_found = GithubUtils.get_relative_position(@github_file["patch"], 109)
    assert :not_found = GithubUtils.get_relative_position(@github_file["patch"], 111)
    assert :not_found = GithubUtils.get_relative_position(@github_file["patch"], 174)
    assert :not_found = GithubUtils.get_relative_position(@github_file["patch"], 180)
  end

  test "get git basic auth" do
    cred = GithubUtils.basic_auth()
    user = Application.get_env(:credo_server, :github_user)
    pass = Application.get_env(:credo_server, :github_password)
    assert cred == {:basic, to_char_list(user), to_char_list(pass)}
  end

  test "get git oauth" do
    cred = GithubUtils.oauth("git_token")
    assert cred == {:oauth, "git_token"}
  end
end
