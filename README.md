# MakerstudioAssignment

To start your server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` 

To create a user :

  * Endpoint:  /users  (POST)
  * Description: Creates a new user.
  * Request Body:  JSON format
       {
          "username": "user1"
       }


To create a task for user :

  * Endpoint: /users/:user_id/tasks (POST)
  * Description: Creates a new task for the specified user.
  * Path Parameter: :user_id - The ID returned when creating a user.
  * Request Body: JSON format
   {
    "title": "To create a new task",
    "description": "This is the description of the task for a specified user.",
    "duedate": "24/06/2024"
    "status": "Completed"
   }


To retrieve all the tasks for a specified user:

  * Endpoint: /users/:user_id/tasks (GET)
  * Description: Retrieves all tasks for the specified user.
  * Path Parameter: :user_id - The ID returned when creating a user.
  * Request Body: None


To retrieve specific task for a specified user:

  * Endpoint:  /users/:user_id/tasks/:task_id (GET)
  * Description: Retrieves a specific task for the specified user.
  * Path Parameters:
        :user_id - The ID returned when creating a user.
        :task_id - The ID returned when creating a task.
  * Request Body: None


To delete a specific task for a specified user:

  * Endpoint: /users/:user_id/tasks/:task_id (DELETE)
  * Description: Deletes a specific task for the specified user.
  * Path Parameters:
        :user_id - The ID returned when creating a user.
        :task_id - The ID returned when creating a task.
  * Request Body: None


To update a specific task for a specified user:

  * Endpoint: /users/:user_id/tasks/:task_id (PUT)
  * Description: Updates a specific task for the specified user.
  * Path Parameters:
        :user_id - The ID returned when creating a user.
        :task_id - The ID returned when creating a task
  * Request Body:  JSON format
    {
      "title": "Updated title",
      "description": "Updated description",
      "duedate": "25/06/2024",
      "status": "In Progress"
    }
