class AddCompressionProcessedSite < ActiveRecord::Migration
  def self.up
    add_column(:processed_sites, :compressed_body, :mediumblob)
    ProcessedSite.update_all("compressed_body = COMPRESS(body)")
    remove_column(:processed_sites, :body)
  end

  def self.down
  end
end
