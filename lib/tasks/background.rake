namespace :background do

  task :crawler => :environment do
    logger = Logger.new(File.join(RAILS_ROOT, "log", "crawler_rake.log"))
    
    running = false
    
    if(File.exists?(File.join(RAILS_ROOT, "log", "crawler.pid")))
      crawler_pid = 0
      File.open(File.join(RAILS_ROOT, "log", "crawler.pid"), "r") do |file|
        crawler_pid = file.read
      end
      
      begin
        Process.getpgid(crawler_pid.to_i)
        running = true
      rescue Errno::ESRCH => e
        logger.info "#{Time.now.to_s} Crawler died...restarting"
      end
      
    end
    
    if !running
      
      crawler_pid = Process.fork do
        DivCrawler.new().run()
      end
      
      logger.info "#{Time.now.to_s} Crawler started with pid #{crawler_pid.to_s}"
      
      File.open(File.join(RAILS_ROOT, "log", "crawler.pid"), "w+") do |file|
        file.write(crawler_pid.to_s)
      end
      
    end
    
  end
  
  task :seeder => :environment do
    
    service = ENV["SERVICE"]
    
    if service.empty?
      service = nil
    end
    Process.fork do
      DivSeeder.run(service)
    end
    
  end
  
end