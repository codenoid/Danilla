defmodule DanillaWeb.ApiController do
  use DanillaWeb, :controller

  def one_secret(conn, %{"key" => key}) do
    record = :mnesia.dirty_read(Secrets, key)

    result =
      if length(record) > 0 do
        [value] = record

        Enum.reject(Tuple.to_list(value), fn x -> x == Secrets end)
      else
        []
      end

    conn |> json(result)
  end
end
