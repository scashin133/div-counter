class CreateProcessedSites < ActiveRecord::Migration
  def self.up
    create_table(:processed_sites) do |t|
      t.integer :div_count
      t.string :uri
      t.column :body, :longtext
      t.string :title
      
      t.timestamps
    end
  end
  
  def self.down
    drop_table(:processed_sites)
  end
end