class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :message_id
      t.string :subject
      t.string :from
      t.string :thread_id
      t.string :history_id
      t.string :snippet
      t.string :message
      t.string :filename
      t.string :attachment_id
      t.string :attachment_size
      t.string :attachment_data
      t.string :recieved_date

      t.timestamps
    end
  end
end
