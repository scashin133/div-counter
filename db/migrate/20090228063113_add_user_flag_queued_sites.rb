class AddUserFlagQueuedSites < ActiveRecord::Migration
  def self.up
    add_column(:queued_sites, :user_flag, :boolean, :default => false)
  end

  def self.down
    remove_column(:queued_sites, :user_flag)
  end
end
