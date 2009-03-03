class ProcessedSitesController < ApplicationController
  # GET /processed_sites
  # GET /processed_sites.xml
  def index
    @processed_sites = ProcessedSite.find(:all, :limit => 20, :order => "div_count DESC")
    @total_processed_sites = ProcessedSite.count(:all)
    
    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @processed_sites }
    end
  end
  
  def show_site
    @processed_sites = ProcessedSite.find(:all, :conditions => {:uri => params[:uri]})
    @uri = params[:uri]
    if @processed_sites.blank?
      queued_site = QueuedSite.find_or_initialize_by_uri(params[:uri])
      
      if queued_site.new_record?
        queued_site.state = "waiting"
        queued_site.user_flag = true
        queued_site.save
      end
      
      flash[:notice] = "#{params[:uri]} has not been processed yet.  It has been added to the crawl."
      redirect_to "/"
    else
      
    end
    
  end

end
