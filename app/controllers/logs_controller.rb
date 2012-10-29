class LogsController < ApplicationController
  helper_method :sort_column, :sort_direction
  before_filter :client_map, :only => :index
  before_filter :scope_site_options, :only => :index
  
  def index
    respond_to do |format|
      format.json { render json: Log.tokens(params[:q]) }
      format.any(:html, :js) {
        @title = "Device Logs"
        search_filters = build_search_filters(params)
        @logs = Log.search(search_filters).order(sort_column + " " + sort_direction)
        @log_count = @logs.count
        @logs = LogDecorator.decorate(@logs.page(params[:page])) 
      }
    end
  end

  private
  
  def build_search_filters(data)
    filters = Hash.new
    if data[:search_client] && !data[:search_client].empty?
      filters[:client] = data[:search_client]
    end
    if data[:search_vm_or_user] && data[:search_vm_or_user].include?("$$")
      category, val = data[:search_vm_or_user].split('$$')
      filters[category.to_sym] = val
    end
    if data[:search_start_date] && !data[:search_start_date].empty?
      filters[:start_date] = data[:search_start_date]
    end
    if data[:search_end_date] && !data[:search_end_date].empty?
      filters[:end_date] = data[:search_end_date]
    end
    if data[:search_site] && !data[:search_site].empty?
      filters[:site] = data[:search_site]
    elsif !current_user.administrator?
      filters[:site] = current_user.department.sites.map { |c| c.id } << nil
    end
    if data[:search_type] && !data[:search_type].empty?
      filters[:client_type] = data[:search_type]
    end
    filters
  end
  
  def sort_column
    (Log.column_names + ["clients.name", "sites.display_name"]).include?(params[:sort]) ? params[:sort] : "logs.updated_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
  
  def client_map
    if params[:search_client] && !params[:search_client].empty?
      @client = Client.find(params[:search_client])
      @client = [@client.id, @client.name].join(',') if @client
    else
      @client = nil
    end
  end
  
  def scope_site_options
    if current_user.try(:administrator?)
      @sites = Site.all
    else
      c_ids = current_user.department.sites.map { |c| c.id } << nil
      @sites = Site.where(:id => c_ids)
    end
  end
end
