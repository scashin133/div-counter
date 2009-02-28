require "httparty"
require "hpricot"

class DivSeeder
  
  def self.run(service = "Delicious")
    running = true

    while(running)

      service.classify.constantize.get_next_page().each do |anchor|
        QueuedSite.create(:uri => anchor.attributes["href"], :state => "waiting")
      end

      puts service.classify.constantize.get_status()

      sleep(1)

    end
  end
end

class Delicious
  include HTTParty
  base_uri "delicious.com"
  format :html
  
  @@current_page = 0
  
  def self.get_next_page()
    @@current_page += 1
    ((Hpricot(get("/recent", :query => {:page => @@current_page})))/"a.taggedlink")
  end
  
  def self.get_status()
    return @@current_page
  end
end

class StumbleUpon
  include HTTParty
  base_uri "www.stumbleupon.com"
  default_params :dispmode => "list"
  format :html
  
  @@current_tag_index = 0
  @@tags = []
  @@next_tag_page = ""
  
  def self.get_next_page()
    initialize_tags()
    
    current_tag = (@@next_tag_page.blank? ? @@tags[@@current_tag_index] : @@next_tag_page)
    
    tag_page = (Hpricot(get(current_tag)))
    
    if((tag_page/"ul.listpagination").empty?)
      
      @@next_tag_page = ""
      @@current_tag_index += 1
      
    else
      
      next_pagination = (tag_page.at("a#paginationNext"))
      
      if(next_pagination.nil?)
        
        @@next_tag_page = ""
        @@current_tag_index += 1
        
      else
        
        @@next_tag_page = next_pagination.attributes["href"]
        
      end
      
            
    end
    
    return (tag_page/"dl.dlList dt a")
    
  end
  
  private
  
  def initialize_tags()
    if @@tags.blank?
      ((Hpricot(get("/tag")))/"div.tagcloud ul li a").each do |tag|
        @@tags << tag.attributes["href"]
      end
    end
  end
  
  
end