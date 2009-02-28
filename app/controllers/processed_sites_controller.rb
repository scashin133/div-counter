class ProcessedSitesController < ApplicationController
  # GET /processed_sites
  # GET /processed_sites.xml
  def index
    @processed_sites = ProcessedSite.paginate(:all, :page => params[:page] || 1, :per_page => 20, :order => "div_count DESC")

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @processed_sites }
    end
  end

end
