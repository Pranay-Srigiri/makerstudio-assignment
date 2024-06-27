defmodule MakerstudioAssignmentWeb.UserControllerTest do
  use ExUnit.Case
  use Plug.Test

  # Helper function to extract JSON response
  defp json_response(conn, status) do
    conn
    |> Plug.Conn.read_body()
    |> Jason.decode!()
    |> elem(1)
  end

  setup do
    # Create an ETS table for users and usernames before each test
    :ok = :ets.new(:users, [:set, :named_table])
    :ok = :ets.new(:usernames, [:set, :named_table])
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  # Test for UsersController.users/2
  test "POST /users creates a new user" do
    conn = conn()
           |> post("/users", %{"username" => "user1"})

    assert conn.status == 200

    assert json_response(conn, 200) == %{"message" => "User Id: _"}
  end

  test "POST /users returns error if username is already taken" do
    :ok = :ets.insert(:usernames, {"user1"})

    conn = conn()
           |> post("/users", %{"username" => "user1"})

    assert conn.status == 400

    assert json_response(conn, 400) == %{"message" => "Username already present, choose another username"}
  end

  # Test for UsersController.users_tasks/2
  test "POST /users/:user_id/tasks creates a new task for a specified user" do
    user_id = Ecto.UUID.generate()

    conn = conn()
           |> post("/users/#{user_id}/tasks", %{
             "title" => "Task title",
             "description" => "Task description",
             "duedate" => "2024-06-28",
             "status" => "Todo"
           })

    assert conn.status == 200

    assert json_response(conn, 200) == %{"message" => "Task Id: _"}
  end

  test "POST /users/:user_id/tasks returns error if status is invalid" do
    user_id = Ecto.UUID.generate()

    conn = conn()
           |> post("/users/#{user_id}/tasks", %{
             "title" => "Task title",
             "description" => "Task description",
             "duedate" => "2024-06-28",
             "status" => "InvalidStatus"
           })

    assert conn.status == 400

    assert json_response(conn, 400) == %{"message" => "Invalid status. Must be Todo or In Progress or Done"}
  end

  # Test for UsersController.get_tasks_by_userid/2
  test "GET /users/:user_id/tasks returns all tasks of a specified user" do
    user_id = Ecto.UUID.generate()
    :ok = :ets.insert(:users, {user_id, [%{"task_id" => "task1", "title" => "Task 1"}]})

    conn = conn()
           |> get("/users/#{user_id}/tasks")

    assert conn.status == 200

    assert json_response(conn, 200) == %{tasks: [%{"task_id" => "task1", "title" => "Task 1"}]}
  end

  test "GET /users/:user_id/tasks returns error if user is not found" do
    user_id = Ecto.UUID.generate()

    conn = conn()
           |> get("/users/#{user_id}/tasks")

    assert conn.status == 400

    assert json_response(conn, 400) == %{"message" => "User not found"}
  end

  # Test for UsersController.get_tasks_by_taskid/2
  test "GET /users/:user_id/tasks/:task_id returns a specific task for a specified user" do
    user_id = Ecto.UUID.generate()
    task_id = Ecto.UUID.generate()
    :ok = :ets.insert(:users, {user_id, [%{"task_id" => task_id, "title" => "Task 1"}]})

    conn = conn()
           |> get("/users/#{user_id}/tasks/#{task_id}")

    assert conn.status == 200

    assert json_response(conn, 200) == %{tasks: %{"task_id" => task_id, "title" => "Task 1"}}
  end

  test "GET /users/:user_id/tasks/:task_id returns error if task is not found for specified user" do
    user_id = Ecto.UUID.generate()
    task_id = Ecto.UUID.generate()

    conn = conn()
           |> get("/users/#{user_id}/tasks/#{task_id}")

    assert conn.status == 400

    assert json_response(conn, 400) == %{"message" => "#{task_id} not found!!"}
  end

  # Test for UsersController.delete_task/2
  test "DELETE /users/:user_id/tasks/:task_id deletes a specific task for a specified user" do
    user_id = Ecto.UUID.generate()
    task_id = Ecto.UUID.generate()
    :ok = :ets.insert(:users, {user_id, [%{"task_id" => task_id, "title" => "Task 1"}]})

    conn = conn()
           |> delete("/users/#{user_id}/tasks/#{task_id}")

    assert conn.status == 200

    assert json_response(conn, 200) == %{"message" => "Task deleted successfully"}
  end

  test "DELETE /users/:user_id/tasks/:task_id returns error if task is not found for specified user" do
    user_id = Ecto.UUID.generate()
    task_id = Ecto.UUID.generate()

    conn = conn()
           |> delete("/users/#{user_id}/tasks/#{task_id}")

    assert conn.status == 404

    assert json_response(conn, 404) == %{"message" => "Task not found for user #{user_id} with ID #{task_id}"}
  end

  # Test for UsersController.update_task/2
  test "PUT /users/:user_id/tasks/:task_id updates a specific task for a specified user" do
    user_id = Ecto.UUID.generate()
    task_id = Ecto.UUID.generate()
    :ok = :ets.insert(:users, {user_id, [%{"task_id" => task_id, "title" => "Task 1"}]})

    conn = conn()
           |> put("/users/#{user_id}/tasks/#{task_id}", %{
             "title" => "Updated Task 1",
             "description" => "Updated description",
             "duedate" => "2024-06-30",
             "status" => "In Progress"
           })

    assert conn.status == 200

    assert json_response(conn, 200) == %{message: "Task updated successfully", updated_task: %{
      "task_id" => task_id,
      "title" => "Updated Task 1",
      "description" => "Updated description",
      "duedate" => "2024-06-30",
      "status" => "In Progress"
    }}
  end

  test "PUT /users/:user_id/tasks/:task_id returns error if task is not found for specified user" do
    user_id = Ecto.UUID.generate()
    task_id = Ecto.UUID.generate()

    conn = conn()
           |> put("/users/#{user_id}/tasks/#{task_id}", %{
             "title" => "Updated Task 1",
             "description" => "Updated description",
             "duedate" => "2024-06-30",
             "status" => "In Progress"
           })

    assert conn.status == 404

    assert json_response(conn, 404) == %{"message" => "Task not found"}
  end
end
