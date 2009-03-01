class AddIndexUriQueued < ActiveRecord::Migration
  def self.up
    add_index(:queued_sites, :uri)
    add_index(:processed_sites, :uri)
  end

  def self.down
  end
end
