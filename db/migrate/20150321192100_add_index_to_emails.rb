class AddIndexToEmails < ActiveRecord::Migration
  def change
    add_index :emails, :message_id, unique:  true
  end
end
