defmodule MakerstudioAssignmentWeb.UserController do
  use MakerstudioAssignmentWeb, :controller

  def users(%{body_params: %{"username" => _username}} = conn, _params) do
    id = Ecto.UUID.generate()
    case :ets.insert(:users, {id, []}) do
      true ->
        success_message = %{message: "User Id: #{id}"}

        conn
        |> put_status(200)
        |> json(success_message)

      _ ->
        fail_message = %{message: "user creation failed"}
        conn
        |> put_status(400)
        |> json(fail_message)
    end
  end
end
