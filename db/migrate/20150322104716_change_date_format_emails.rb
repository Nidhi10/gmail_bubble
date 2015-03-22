class ChangeDateFormatEmails < ActiveRecord::Migration
  def change
    change_column :emails, :recieved_date, :datetime
  end
end
