class QueuedSitesController < ApplicationController
  
  def create
    
    @queued_site = QueuedSite.new(params[:queued_site])

    if @queued_site.valid?
      @queued_site.state = "waiting"
      @queued_site.save
      flash[:notice] = "#{@queued_site.uri} has been added to the list."
    else
      flash[:error] = "Nope.  Don't think so. #{@queued_site.errors.full_messages.join(". ")}"
      
    end
    
    redirect_to processed_sites_path
    
  end
  
end