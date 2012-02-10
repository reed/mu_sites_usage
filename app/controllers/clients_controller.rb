class ClientsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :upload
  before_filter :validate_data, :only => :upload
  
  def upload
    if params[:client_type] == "vm"
      @client = Client.find_by_name_and_current_status(params[:name], "unavailable")
      if @client
        @client.update_attributes!({:current_user => params[:user_id], :current_vm => params[:vm]})
        @target_log_entry = @client.logs.find_by_operation_and_login_time("login", @client.last_login)
        if @target_log_entry
          @target_log_entry.update_attributes!({:user_id => params[:user_id], :vm => params[:vm]})
        end
      end
    else
      operation = params[:operation]
      user_id = params[:user_id]
      vm = params[:vm]
      @client = Client.find_or_create(params)
      if operation == "login" && params[:client_type] != "tc"
        @client.record_action(operation, user_id, vm)
      else
        @client.record_action(operation)
      end
    end
    success
  end
  
  private
  
  def validate_data
    return fail if params[:client_type].nil?
    return fail unless ["tc", "pc", "mac", "vm"].include? params[:client_type].downcase
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
    #render :nothing => true, :status => 400 and return false
    head :bad_request, :connection => "close" and return false
  end
  
  def success
    #render :nothing => true, :status => 200 and return true
    head :ok, :connection => "close" and return true
  end
end
