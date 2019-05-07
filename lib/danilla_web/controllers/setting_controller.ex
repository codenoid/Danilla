defmodule DanillaWeb.SettingController do
  use DanillaWeb, :controller

  def setting_view(conn, _params) do
    users = :mnesia.dirty_read(Users, get_session(conn, :username))

    tfa_status =
      case length(users) do
        1 ->
          [user] = users

          {table, saved_username, saved_password, tfa_key, tfa_used} = user

          tfa_used

        _ ->
          redirect(conn, to: "/logout")
      end

    qr_code =
      if tfa_status == true do
        case length(users) do
          1 ->
            [user] = users

            {table, saved_username, saved_password, tfa_key, tfa_used} = user

            Elixir2fa.generate_qr("Danilla_#{get_session(conn, :username)}", tfa_key)

          _ ->
            redirect(conn, to: "/logout")
        end
      end

    render(conn, "setting.html", token: get_csrf_token(), tfa_status: tfa_status, qr_code: qr_code)
  end

  def setting_save(conn, %{"current_pw" => password, "new_pw" => new_password} = params) do
    users = :mnesia.dirty_read(Users, get_session(conn, :username))

    case length(users) do
      1 ->
        [user] = users

        {table, saved_username, saved_password, tfa_key, tfa_used} = user

        if Bcrypt.verify_pass(password, saved_password) do
          new_hash = Bcrypt.hash_pwd_salt(new_password)

          :mnesia.transaction(
            :mnesia.dirty_write({Users, saved_username, new_hash, tfa_key, tfa_used})
          )

          redirect(conn, to: "/setting?status=success")
        else
          redirect(conn, to: "/setting?status=failed")
        end

      _ ->
        redirect(conn, to: "/setting?status=failed")
    end
  end

  def enable(conn, %{"type" => type}) do
    users = :mnesia.dirty_read(Users, get_session(conn, :username))

    case length(users) do
      1 ->
        [user] = users

        {table, saved_username, saved_password, tfa_key, tfa_used} = user

        if type == "2fa" do
          :mnesia.transaction(
            :mnesia.dirty_write({Users, saved_username, saved_password, tfa_key, true})
          )
        end

        redirect(conn, to: "/setting")

      _ ->
        redirect(conn, to: "/logout")
    end
  end

  def disable(conn, %{"type" => type}) do
    users = :mnesia.dirty_read(Users, get_session(conn, :username))

    case length(users) do
      1 ->
        [user] = users

        {table, saved_username, saved_password, tfa_key, tfa_used} = user

        if type == "2fa" do
          :mnesia.transaction(
            :mnesia.dirty_write({Users, saved_username, saved_password, tfa_key, false})
          )
        end

        redirect(conn, to: "/setting")

      _ ->
        redirect(conn, to: "/logout")
    end
  end
end
