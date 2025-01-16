defmodule Fooer.Repo do
  use Ecto.Repo,
    otp_app: :fooer,
    adapter: Ecto.Adapters.Postgres
end
