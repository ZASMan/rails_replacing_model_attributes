# Ruby on Rails: Replacing Model Attributes
Ever have a Rails model and start adding a bunch of attributes and realize after a while that you had a poor design pattern, but now have hundreds or thousands of values in your production database? What the hell do you do then?
I had a similar problem in a project where we were defining different user permissions with booleans in our ```User``` model such as `is_moderator` and `is_admin`, but it was becoming confusing for both the developers and end users who had to create an 'admin' user by checking true both a `is_moderator` and `is_admin` boolean and a 'moderator' user by checking true the `is_moderator` boolean but false for the `is_admin` boolean. We decided to replace it with a 'role' string value. The steps I took to change this were the following:
1. Create a migration to create the `role` attribute. Don't start out with deleting the attributes because you need to update your database!:
```
class AddRoleToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :role, :string, default: 'user'

    # Update All Existing Users in Database
    execute "update users set role = 'admin' where is_moderator is true and is_admin is true"
    execute "update users set role = 'moderator' where is_moderator is true and is_admin is false"
    execute "update users set role = 'user' where is_moderator is false and is_admin is false"
  end
end
```
2. Run ```rake db:migrate``` and check that the values changed appropriately.
3. Update all user model related specs.
4. Update the permitted params in users controller, user form, and any other feature specs. I updated the ```before_action``` methods in my application controller to be used in all the controllers:

```
   # Old Application Controller
  def authenticate_admin!
    return false if current_user && current_user.is_admin
    msg = "You lack the necessary admin permission for the requested action."
    respond_to do |format|
      format.html { redirect_to(root_path, alert: msg) }
      format.json { render json: msg }
    end
  end

  def authenticate_moderator!
    return false if current_user && current_user.is_moderator
    msg = "You lack the necessary edit permission for the requested action."
    respond_to do |format|
      format.html { redirect_to(root_path, alert: msg) }
      format.json { render json: msg }
    end
  end

  # New Application Controller
  def authenticate_admin!
    return false if current_user && current_user.role == 'admin'
    msg = "You lack the necessary admin permission for the requested action."
    respond_to do |format|
      format.html { redirect_to(root_path, alert: msg) }
      format.json { render json: msg }
    end
  end

  def authenticate_moderator!
    return false if current_user && current_user.role == 'moderator' || current_user.role == 'admin'
    msg = "You lack the necessary edit permission for the requested action."
    respond_to do |format|
      format.html { redirect_to(root_path, alert: msg) }
      format.json { render json: msg }
    end
  end
```
5. Update all controller permissions and view logic. Throughout the application, many buttons were wrapped around statements such as `if current_user.is_moderator`. `is_moderator` users would have included both users who had `is_admin` and `is_moderator`. Rather than update all the logic in every view file with something like `if current_user.role == 'moderator' || current_user.role == 'admin'`, I added the original attributes as model method. After that, all my tests passed.:
```
  def is_admin
    return true if role == 'admin'
  end

  def is_moderator
    return true if role == 'moderator' || role == 'admin'
  end
```
6. Updated seed data for development and test environments.
7. Run migrations to remove the depreceated `is_moderator` and `is_admin` attributes.
