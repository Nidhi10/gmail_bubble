class RemoveAttachmentIdFromEmail < ActiveRecord::Migration
  def change
    remove_column :emails, :attachment_id, :string
    remove_column :emails, :attachment_data, :string
    remove_column :emails, :attachment_size, :string

  end
end
