class CreateProcessedSites < ActiveRecord::Migration
  def self.up
    create_table(:processed_sites) do |t|
      t.integer :div_count
      t.string :uri
      t.column :compressed_body, :mediumblob
      t.string :title

      t.timestamps
    end
    add_index(:processed_sites, :div_count)
  end
  
  def self.down
    drop_table(:processed_sites)
  end
end