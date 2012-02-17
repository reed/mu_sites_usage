class LogsController < ApplicationController
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction
  
  def index
    @title = "Device Logs"
    search_filters = build_search_filters(params)
    @logs = LogDecorator.decorate(Log.search(search_filters).order(sort_column + " " + sort_direction).page(params[:page]))
  end

  private
  
  def build_search_filters(data)
    filters = Hash.new
    if data[:search_name] && !data[:search_name].empty?
      filters[:name] = data[:search_name]
    end
    if data[:search_start_date] && !data[:search_start_date].empty?
      filters[:start_date] = data[:search_start_date]
    end
    if data[:search_end_date] && !data[:search_end_date].empty?
      filters[:end_date] = data[:search_end_date]
    end
    if data[:search_site] && data[:search_site].to_i > 0
      filters[:site] = data[:search_site]
    end
    filters
  end
  
  def sort_column
    (Log.column_names + ["clients.name", "sites.display_name"]).include?(params[:sort]) ? params[:sort] : "logs.updated_at"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
