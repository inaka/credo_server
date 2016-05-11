ExUnit.start()
Code.load_file("test/test_utils.exs")
Code.load_file("test/egithub_adapter.ex")

Mix.Task.run "ecto.create", ["--quiet"]
Mix.Task.run "ecto.migrate", ["--quiet"]
Ecto.Adapters.SQL.begin_test_transaction(CredoServer.Repo)
