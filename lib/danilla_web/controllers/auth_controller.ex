defmodule DanillaWeb.AuthController do
  use DanillaWeb, :controller

  def login_view(conn, _params) do
    conn = put_layout(conn, false)
    render(conn, "login.html", token: get_csrf_token())
  end

  def login(conn, params) do
    if username = params["username"] do
      if password = params["password"] do
        users = :mnesia.dirty_read(Users, username)

        case length(users) do
          1 ->
            [user] = users

            {table, saved_username, saved_password, tfa_key, tfa_used} = user

            if Bcrypt.verify_pass(password, saved_password) do
              guid = conn.req_cookies["guid"]

              # fix this
              is_logged =
                if tfa_used == true do
                  # is tfa activated
                  if token = params["token"] do
                    # is used put token while login
                    if Elixir2fa.generate_totp(tfa_key) == token do
                      # is tfa token same
                      true
                    else
                      false
                    end
                  else
                    false
                  end
                else
                  true
                end

              if is_logged do
                :ets.insert(:danilla_session, {username, guid})
                :ets.insert(:danilla_session, {guid, username})

                conn
                |> put_session(:username, saved_username)
                |> redirect(to: "/")
              end
            else
              redirect(conn, to: "/login")
            end

          0 ->
            redirect(conn, to: "/login")
        end
      end
    end

    redirect(conn, to: "/login")
  end

  def logout(conn, _params) do
    guid = conn.req_cookies["guid"]

    :ets.delete(:danilla_session, guid)

    conn
    |> clear_session
    |> redirect(to: "/login")
  end
end
