class ClientsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :upload
  before_filter :validate_data, :only => :upload
  before_filter :scope_clients, :only => :index
  before_filter :validate_filter, :only => :match
  
  def index
    @title = "Device Management"
    respond_to do |format|
      format.json { 
        @clients = @client_scope.search_tokens(params[:q]).order(:name)
        render json: { :total => @clients.count, :clients => @clients.paginate(page: params[:page], per_page: 10) }
      }
      format.any(:html, :js) {
        search_filters = build_search_filters(params)
        @clients = @client_scope.search(search_filters).order(sort_column + " " + sort_direction).page(params[:page])
      }
    end
  end
  
  def update
    @client = current_resource
    respond_to do |format|
      @client.update_attributes(params[:client])
      format.json { respond_with_bip(@client) }
    end
  end

  def destroy
    @client = current_resource
    @client.destroy
    flash[:success] = "Client removed."
    redirect_to clients_path
  end
  
  def upload
    if params[:client_type] == "vm"
      @client = Client.find_by_name_and_current_status(params[:name], "unavailable")
      if @client
        @client.update_attributes!({:current_user => params[:user_id], :current_vm => params[:vm]})
        @target_log_entry = @client.logs.find_by_operation_and_login_time("login", @client.last_login)
        if @target_log_entry
          @target_log_entry.update_attributes!({:user_id => params[:user_id], :vm => params[:vm], :vm_ip_address => params[:vm_ip_address]})
        end
      end
    else
      operation = params[:operation]
      user_id = params[:user_id]
      vm = params[:vm]
      vm_ip_address = params[:vm_ip_address]
      @client = Client.find_or_create(params.permit!)
      if operation == "login" && params[:client_type] != "tc"
        @client.record_action(operation, user_id, vm, vm_ip_address)
      else
        @client.record_action(operation)
      end
    end
    success
  end
  
  def match
    if @filter
      site = Site.find(params[:site_id]) if params[:site_id]
      @matches = SiteClientMatcher.new(site).effect_of_new_name_filter(params[:filter])
    end
    respond_to do |format|
      format.js
    end
  end
  
  private
  
  def current_resource
    @current_resource ||= Client.find(params[:id]) if params[:id]
  end
  
  def validate_data
    return fail if params[:client_type].nil?
    return fail unless ["tc", "pc", "mac", "vm", "zc"].include? params[:client_type].downcase
    return fail if params[:name].nil? || params[:name].empty?
    if params[:client_type] == "vm"
      return fail if params[:vm].nil?
    else
      return fail if params[:mac_address].nil? || params[:ip_address].nil? || params[:operation].nil?
      return fail if params[:mac_address].empty? || params[:ip_address].empty? || params[:operation].empty?
      return fail unless ["check-in", "startup", "login", "logout"].include? params[:operation].downcase
    end
    if params[:client_type] != "tc" && params[:operation] == "login"
      return fail if params[:user_id].nil?
    end
    return true
  end
  
  def fail
    head :bad_request, :connection => "close" and return false
  end
  
  def success
    head :ok, :connection => "close" and return true
  end
  
  def build_search_filters(data)
    filters = Hash.new
    if data[:search_text] && !data[:search_text].empty?
      filters[:text] = data[:search_text]
    end
    if data[:search_type] && !data[:search_type].empty?
      filters[:type] = data[:search_type]
    end
    if data[:search_site] && data[:search_site].to_i > 0
      filters[:site] = data[:search_site]
    end
    filters
  end
  
  def scope_clients
    if current_user.administrator?
      @client_scope = Client.scoped
      @sites = Site.all
    else
      c_ids = current_user.department.sites.map { |c| c.id } << nil
      @client_scope = Client.where(:site_id => c_ids)
      @sites = Site.where(:id => c_ids)
    end
  end
  
  def validate_filter
    Regexp.new("^#{params[:filter]}$", true)
    @filter = params[:filter]
  rescue
    false
  end
  
  def sort_column
    super(Client.column_names + ['clients.enabled', 'sites.display_name'], 'name')
  end
  
end
