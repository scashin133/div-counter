require 'hawler'
require 'hawleroptions'
require 'mysql'

class DivCrawler
  
  def initialize()
    @logger = Logger.new(File.join(RAILS_ROOT, "log", "crawler.log"))
  end
  
  def run()
    while(QueuedSite.has_more_sites?)

      qs = QueuedSite.dequeue()

      begin
        options = HawlerOptions.parse(["-f", "-r", "1"], "Usage: #{File.basename $0} [uri] [options]")

        crawler = Hawler.new(qs.uri, method(:count_divs))

        options.each_pair do |o,v|
          crawler.send("#{o}=",v)
        end

        crawler.start

      rescue Exception => e

        logger.error "#{qs.uri} failed"
        logger.error e
        logger.error e.backtrace.join("\n")

      end

      qs.processed!()

    end

  end

  def count_divs (uri, referer, response)

    if (!response.nil? && (response["Content-Type"].nil? || response["Content-Type"].include?("text/html")) && (response.code == "200" || response.code == "302"))
      hpricot_body = Hpricot(response.body)
      divs = (hpricot_body/"div")
      title = (hpricot_body/"title").inner_html
      
      ProcessedSite.connection.insert("INSERT INTO processed_sites (div_count,uri,compressed_body,title,created_at,updated_at) VALUES (#{Mysql.quote(divs.size.to_s)},'#{Mysql.quote(uri.to_s)}',COMPRESS('#{Mysql.quote(response.body.to_s)}'),'#{Mysql.quote(title.to_s)}',UTC_TIMESTAMP(),UTC_TIMESTAMP())")
    end
    
  end

end   
