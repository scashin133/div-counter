namespace :background do

  task :crawler => :environment do
    Process.fork do
      DivCrawler.new().run()
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