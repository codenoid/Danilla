defmodule DanillaWeb.SecretController do
  use DanillaWeb, :controller

  def secret_view(conn, _params) do
    render(conn, "secret_list.html", token: get_csrf_token())
  end

  def secret_ajax(conn, _params) do
    records = :mnesia.dirty_all_keys(Secrets)

    result =
      Enum.map(records, fn e ->
        record = :mnesia.dirty_read(Secrets, e)

        if length(record) > 0 do
          [value] = record

          Enum.reject(Tuple.to_list(value), fn x -> x == Secrets end)
        end
      end)

    conn |> json(result)
  end

  def secret_new(conn, %{"key" => key, "type" => type, "secret" => secret} = params) do
    case :mnesia.dirty_write({Secrets, key, type, secret}) do
      :ok ->
        redirect(conn, to: "/secret?status=success")

      _ ->
        redirect(conn, to: "/secret?status=failed")
    end
  end

  def secret_delete(conn, %{"key" => key}) do
    case :mnesia.dirty_delete({Secrets, key}) do
      :ok ->
        redirect(conn, to: "/secret?status=success")

      _ ->
        redirect(conn, to: "/secret?status=failed")
    end
  end
end
