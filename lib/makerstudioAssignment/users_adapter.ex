defmodule MakerstudioAssignment.UsersAdapter do

  def lookup(table_name ,id) do
    :ets.lookup(table_name, id)
  end

  def insert(table_name,{key,value})do
    :ets.insert(table_name,{key,value})
  end

end
