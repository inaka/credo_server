ExUnit.start()
Code.load_file("test/test_utils.exs")
Ecto.Adapters.SQL.begin_test_transaction(CredoServer.Repo)
