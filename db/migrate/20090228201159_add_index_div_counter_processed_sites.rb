class AddIndexDivCounterProcessedSites < ActiveRecord::Migration
  def self.up
    add_index(:processed_sites, :div_count)
  end

  def self.down
    remove_index(:processed_sites, :div_count)
  end
end
