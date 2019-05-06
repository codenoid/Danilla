defmodule Mix.Tasks.Database do
  use Mix.Task

  @shortdoc "Init Database"
  def run(_) do
    :net_kernel.start([:danilla@master, :shortnames])

    if File.exists?("#{File.cwd!}/Mnesia.danilla@master") do
      :mnesia.start()
    end

    :mnesia.create_schema([node()])

    IO.puts("Creating tables ...")

    case :mnesia.create_table(Users,
           attributes: [:username, :password, :tfa_key, :tfa_used],
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

    :mnesia.wait_for_tables([Users], 5000)

    check_record = fn ->
      :mnesia.read({Users, "admin"})
    end

    case {type, result} = :mnesia.transaction(check_record) do
      {:atomic, []} ->
        tfa_secret = random_string(12)

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
        IO.puts("Unknown Error !")
    end

    # :mnesia.stop()
  end

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end
end
