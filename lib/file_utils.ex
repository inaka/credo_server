defmodule CredoServer.FileUtils do
  @moduledoc false

  def repository_path(repository_info) do
    repository = repository_info["full_name"]
    "#{System.tmp_dir}#{repository}"
  end

  def create_repository_dir(repository_info) do
    path = repository_path(repository_info)
    File.mkdir_p(Path.dirname(path))

    path
  end

  def delete_repository_dir(path) do
    File.rm_rf(path)
  end
end
