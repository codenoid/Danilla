# Danilla

Secret Management written in Elixir based on Mnesia & ETS

> **Not Public-Production Ready (yet) !**

## Usage

1. Install Elixir ([Official Tutorial](https://elixir-lang.org/install.html))
2. run `git clone https://github.com/codenoid/Danilla`
3. run `cd Danilla && mix deps.get` (install phoenix, etc)
4. mix phx.server
5. Go to http://localhost:4000

Default Auth is :

```
Username : admin
Password : admin123
```

### API Usage

`http://localhost:4000/api/single?key=secret-key`

## Screenshot

![alt text](https://raw.githubusercontent.com/codenoid/Danilla/master/screenshot/ss1.png)

![alt text](https://raw.githubusercontent.com/codenoid/Danilla/master/screenshot/ss2.png)

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more about phoenix

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
