class AddRoleToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :role, :string, default: 'User'

    # Update All Users in Database
    execute "update users set role = 'admin' where is_admin is true"
    execute "update users set role = 'moderator' where is_moderator is true and is_admin is false"
    execute "update users set role = 'user' where is_admin is false and is_moderator is false"
  end
end
