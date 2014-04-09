class AddExtIdToPush < ActiveRecord::Migration
  def self.up
    add_column :push_messages, :ext_id, :string, :default => nil
    add_index :push_messages, :ext_id
    add_index :push_messages, :device

    add_index :push_feedback, :device
  end

  def self.down
    remove_index :push_feedback, :device

    remove_index :push_messages, :device
    remove_index :push_messages, :ext_id
    remove_column :push_messages, :ext_id
  end
end
