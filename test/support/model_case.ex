defmodule CredoServer.ModelCase do
  @moduledoc """
  This module defines the test case to be used by
  model tests.

  You may define functions here to be used as helpers in
  your model tests. See `errors_on/2`'s definition as reference.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias CredoServer.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]
      import CredoServer.ModelCase
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(CredoServer.Repo, [])
    end

    :ok
  end

  @doc """
  Helper for returning list of errors in model when passed certain data.
  """
  def errors_on(model, data) do
    model.__struct__.changeset(model, data).errors
  end
end
