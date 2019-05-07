defmodule Danilla.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # set node name to danilla@master
    :net_kernel.start([:danilla@master, :shortnames])

    :mnesia.create_schema([node()])

    :mnesia.start()

    IO.puts("Creating tables ...")

    case :mnesia.create_table(Users,
           attributes: [:username, :password, :tfa_key, :tfa_used],
           disc_only_copies: [node()]
         ) do
      {:atomic, :ok} ->
        IO.puts("Users table created successfully !")

      {:aborted, {:already_exists, Users}} ->
        IO.puts("Users table already exist !")

      {:aborted, {:bad_type, Users, :disc_only_copies, :danilla@master}} ->
        IO.puts("Error, disc_only_copies failed")

      _ ->
        IO.puts("Unknown Error !")
    end

    case :mnesia.create_table(Secrets,
           attributes: [:id, :type, :value],
           disc_only_copies: [node()]
         ) do
      {:atomic, :ok} ->
        IO.puts("Secrets table created successfully !")

      {:aborted, {:already_exists, Secrets}} ->
        IO.puts("Secrets table already exist !")

      {:aborted, {:bad_type, Secrets, :disc_only_copies, :danilla@master}} ->
        IO.puts("Error, disc_only_copies failed")

      _ ->
        IO.puts("Unknown Error !")
    end

    :mnesia.wait_for_tables([Users], 5000)

    check_record = fn ->
      :mnesia.read({Users, "admin"})
    end

    case {type, result} = :mnesia.transaction(check_record) do
      {:atomic, []} ->
        tfa_secret = Elixir2fa.random_secret(16)

        case :mnesia.dirty_write(
               {Users, "admin", "$2b$06$YChCKP6dY3R1zysxIRC8peB2rxqTT0b15r.K1PxLyCGVjdu6AuGku",
                tfa_secret, false}
             ) do
          :ok ->
            IO.puts("Default user has been created !")

          _ ->
            IO.puts("Unknown Error !")
        end

      _ ->
        IO.puts("Already exist !")
    end

    :timer.sleep(510)

    # :mnesia.stop()

    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      DanillaWeb.Endpoint
      # Starts a worker by calling: Danilla.Worker.start_link(arg)
      # {Danilla.Worker, arg},
    ]

    # create table for web session
    :ets.new(:danilla_session, [:set, :public, :named_table])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Danilla.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    DanillaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
