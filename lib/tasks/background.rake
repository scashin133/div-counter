namespace :background do

  task :crawler => :environment do
    
    DivCrawler.run()
    
  end
  
  task :seeder => :environment do
    
    service = ENV["SERVICE"]
    
    if service.empty?
      service = nil
    end
    
    DivSeeder.run(service)
    
  end
  
end