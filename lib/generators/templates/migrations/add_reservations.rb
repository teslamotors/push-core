class AddReservations < ActiveRecord::Migration
  def self.up
    add_column :push_messages, :reserved_by, :string, :default => nil
    add_column :push_messages, :reserved_until, :datetime
    add_index :push_messages, :app
    add_index :push_messages, :reserved_by
    add_index :push_messages, :reserved_until
  end

  def self.down
    remove_index :push_messages, :reserved_until
    remove_index :push_messages, :reserved_by
    remove_index :push_messages, :app
    remove_column :push_messages, :reserved_until
    remove_column :push_messages, :reserved_by
  end
end
