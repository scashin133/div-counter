class QueuedSite < ActiveRecord::Base

  validates_uniqueness_of :uri
  validates_format_of :uri, :with => /^http.+$/

  def self.has_more_sites?()
    return !find(:first).nil?
  end

  def self.dequeue()
    qs = QueuedSite.find(:first, :order => "user_flag DESC, created_at ASC", :conditions => "state = 'waiting'")
    qs.state = "processing"
    qs.save
    return qs
  end

  def processed!()
    self.destroy()
  end
end