class AddUserToEmail < ActiveRecord::Migration
  def change
    add_column :emails, :user, :string
  end
end
