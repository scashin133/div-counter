class CreateQueuedSites < ActiveRecord::Migration
	def self.up
	  create_table(:queued_sites) do |t|
	    t.string :state
	    t.string :uri
	    t.boolean :user_flag, :default => false
	    t.timestamps
    end
    
    add_index(:queued_sites, :state)
	end

	def self.down
	  drop_table(:queued_sites)
	end
end
