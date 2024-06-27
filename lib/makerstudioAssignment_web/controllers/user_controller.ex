defmodule MakerstudioAssignmentWeb.UserController do
  use MakerstudioAssignmentWeb, :controller
  import MakerstudioAssignment.UsersAdapter
  def users(%{body_params: %{"username" => username}} = conn, _params) do
    if username_in_list(username) do
      failure_message = %{message: "Username already present, choose another username"}
      conn
      |> put_status(400)
      |> json(failure_message)
    else
      add_username(username)
    id = Ecto.UUID.generate()
    case insert(:users, {id, []}) do
      true ->
        success_message = %{message: "User Id: #{id}"}
        conn
        |> put_status(200)
        |> json(success_message)

      false ->
        fail_message = %{message: "User creation failed"}
        conn
        |> put_status(400)
        |> json(fail_message)

        _ ->
          fail_message = %{message: "Unexpected error"}
        conn
        |> put_status(400)
        |> json(fail_message)
    end
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
        status_list =["Todo","In Progress","Done"]
        unless status in status_list do
          error_message = %{message: "Invalid status. Must be TodO or In Progress or Done"}
           conn |> put_status(400) |> json(error_message)
        end

        unless Regex.match?(~r/^\d{4}-\d{2}-\d{2}$/, duedate) do
          error_message = %{message: "Invalid date format. Must be YYYY-MM-DD."}
           conn |> put_status(400) |> json(error_message)
        end
      case lookup(:users, user_id) do
      [{_, task_list}] ->
        task_id = Ecto.UUID.generate()
        task = create_new_task(title, description, duedate, status, task_id)
        new_task_list = task_list ++ [task]

        case insert(:users, {user_id, new_task_list}) do
          true ->
            success_message = %{message: "Task Id: #{task_id}"}
            conn
            |> put_status(200)
            |> json(success_message)

          _ ->
            fail_message = %{message: "Task Creation Failed"}
            conn
            |> put_status(400)
            |> json(fail_message)
        end

      _ ->
        fail_message = %{message: "User not found"}

        conn
        |> put_status(400)
        |> json(fail_message)
    end
  end

  def get_tasks_by_userid(conn, %{"user_id" => user_id}) do
    case lookup(:users, user_id) do
      [{_user_id, task_list}] ->
        data = %{tasks: task_list}
        conn
        |> put_status(200)
        |> json(data)

        [] ->
          message = %{message: "No tasks found for user_id #{user_id}"}
          conn
          |> put_status(400)
          |> json(message)

      _ ->
        message = %{message: "Error retrieving tasks"}
        conn
        |> put_status(400)
        |> json(message)
    end
  end

  def get_tasks_by_taskid(conn, %{"user_id" => user_id, "task_id" => task_id} = _params) do
    case lookup(:users, user_id) do
      [{^user_id, task_list}] ->
        task = Enum.find(task_list, fn task -> Map.has_key?(task, task_id) end)
        if task do
          message = %{tasks: task}
          conn
          |> put_status(200)
          |> json(message)
        else
          message = %{message: "#{task_id} not found!!"}
          conn
          |> put_status(400)
          |> json(message)
        end

        [] ->
          message = %{message: "User not found with ID #{user_id}"}
          conn
          |> put_status(404)
          |> json(message)

        _ ->
          message = %{message: "Error retrieving tasks"}
          conn
          |> put_status(500)
          |> json(message)
    end
  end

  def delete_task(conn, %{"user_id" => user_id, "task_id" => task_id} = _params) do
    case lookup(:users, user_id) do
      [{_user_id, task_list}] ->
        updated_task_list = Enum.reject(task_list, fn t -> Map.has_key?(t, task_id) end)
       case insert(:users, {user_id, updated_task_list}) do
        true ->
        message = %{message: "Task deleted successfully"}
        conn
        |> put_status(200)
        |> json(message)

        _ ->
          message = %{message: "Task not found for user #{user_id} with ID #{task_id}"}
          conn
          |> put_status(404)
          |> json(message)
      end
      [] ->
        message = %{message: "User not found with ID #{user_id}"}
        conn
        |> put_status(404)
        |> json(message)

      _ ->
        message = %{message: "Error deleting task"}
        conn
        |> put_status(500)
        |> json(message)
    end
  end



  def update_task(%{body_params: params} = conn, %{"user_id" => user_id, "task_id" => task_id}=_params)do
    case lookup(:users, user_id) do
            [{_user_id,task_list}] ->
        task_entry = Enum.find(task_list, fn task ->
            is_map(task) && Map.has_key?(task, task_id)
          end)
        if task_entry do
          to_update_task = Map.get(task_entry, task_id)
          {_empty_values, non_empty_values} =
            Enum.reduce(params, {[], []}, fn {key, value}, {empty, non_empty} ->
              case value do
                "" -> {[key | empty], non_empty}
                _ -> {empty, [{key, value} | non_empty]}
              end
            end)
          new_values_map = Enum.into(non_empty_values, %{})
          updated_values = Map.merge(to_update_task, new_values_map)
          updated_task_list = Enum.map(task_list, fn task ->
              if Map.has_key?(task, task_id) do
                Map.put(task, task_id, updated_values)
              else
                task
              end
            end)
          insert(:users, {user_id, updated_task_list})
          conn
          |> put_status(200)
          |> json(%{message: "Task updated successfully", updated_task: updated_values})
        else
          conn
          |> put_status(404)
          |> json(%{message: "Task not found"})
        end

      _ ->
        conn
        |> put_status(404)
        |> json(%{message: "User not found"})
    end
  end

  defp create_new_task(title, description, duedate, status, task_id) do
    %{
      task_id => %{
        "title" => title,
        "description" => description,
        "duedate" => duedate,
        "status" => status
      }
    }
  end

  defp username_in_list(username) do
    :ets.match_object(:usernames, {username})
    |> Enum.any?()
  end

  defp add_username(username) do
    :ets.insert(:usernames, {username})
  end
end
