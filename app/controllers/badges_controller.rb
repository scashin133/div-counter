class BadgesController < ApplicationController
  
  def index
    
    @processed_sites = ProcessedSite.paginate(:all, :page => params[:page] || 1, :per_page => 20, :order => "div_count DESC")

    respond_to do |format|
      format.html # index.html.haml
      format.xml  { render :xml => @processed_sites }
    end
    
  end
  
  def create
    @processed_site = ProcessedSite.find_by_uri(params[:uri], :order => "created_at DESC")
    
    render :partial => ""
  end
  
  def show
    @processed_site = ProcessedSite.find(params[:id])
    
    
    respond_to do |format|
      format.js  { render :xml => @processed_sites }
    end
    
  end
  
end
