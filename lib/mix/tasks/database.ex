defmodule Mix.Tasks.Database do
  use Mix.Task

  @shortdoc "Init Database"
  def run(_) do
    :net_kernel.start([:danilla@master, :shortnames])

    :mnesia.start()

    :mnesia.create_schema([node()])

    IO.puts("Creating tables ...")

    case :mnesia.create_table(Users,
           attributes: [:username, :password, :tfa_key],
           disc_copies: [node()]
         ) do
      {:atomic, :ok} ->
        IO.puts("Users table created successfully !")

      {:aborted, {:already_exists, Users}} ->
        IO.puts("Users table already exist !")

      {:aborted, {:bad_type, Users, :disc_copies, :danilla@master}} ->
        IO.puts("Error, disc_copies failed")

      _ ->
        IO.puts("Unknown Error !")
    end

    case :mnesia.create_table(Secrets,
           attributes: [:id, :type, :value],
           disc_copies: [node()]
         ) do
      {:atomic, :ok} ->
        IO.puts("Secrets table created successfully !")

      {:aborted, {:already_exists, Secrets}} ->
        IO.puts("Secrets table already exist !")

      {:aborted, {:bad_type, Secrets, :disc_copies, :danilla@master}} ->
        IO.puts("Error, disc_copies failed")

      _ ->
        IO.puts("Unknown Error !")
    end

    :mnesia.stop()
  end
end
