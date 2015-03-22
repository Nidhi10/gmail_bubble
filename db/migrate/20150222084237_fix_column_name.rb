class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :emails, :from, :email_from
  end
end
