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

  def users_tasks(
        %{
          body_params: %{
            "title" => title,
            "description" => description,
            "duedate" => duedate,
            "status" => status
          }
        } = conn,
        %{"user_id" => user_id} = _params
      ) do
    case :ets.lookup(:users, user_id) do
      [{_, task_list}] ->
        # no_task=0
        # _success_message=%{message: "user found"}
        task_id = Ecto.UUID.generate()
        task = create_new_task(title, description, duedate, status, task_id)
        new_task_list = task_list ++ [task]

        case :ets.insert(:users, {user_id, new_task_list}) do
          true ->
            success_message = %{message: "Task Id: #{task_id}"}

            conn
            |> put_status(200)
            |> json(success_message)

          _ ->
            fail_message = %{message: "User Creation Failed"}

            conn
            |> put_status(400)
            |> json(fail_message)
        end

      _ ->
        fail_message = %{message: "user not found"}

        conn
        |> put_status(400)
        |> json(fail_message)
    end
  end

  def create_new_task(title, description, duedate, status, task_id) do
    %{
      task_id => %{
        "title" => title,
        "description" => description,
        "duedate" => duedate,
        "status" => status
      }
    }
  end
end
