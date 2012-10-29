require 'spec_helper'

describe Permissions::DepartmentManagerPermission do
  let(:department){ create(:department) }
  let(:other_department){ create(:department) }
  let(:user){ create(:user, :department_manager, department: department) }
  let(:authenticated_user){ create(:user, department: department) }
  let(:department_manager){ create(:user, :department_manager, department: department) }
  let(:department_site){ create(:site, department: department )}
  let(:other_department_site){ create(:site, department: other_department)}
  let(:client_with_site){ create(:client, site: department_site) }
  let(:client_without_site){ create(:client, :orphan) }
  subject { Permissions.permission_for(user) }
    
  it 'allows departments' do
    should allow(:departments, :index) 
    should allow(:departments, :show) 
    should_not allow(:departments, :new) 
    should_not allow(:departments, :create) 
    should_not allow(:departments, :edit) 
    should_not allow(:departments, :update) 
    should_not allow(:departments, :destroy)
    should_not allow_param(:department, :display_name)
    should_not allow_param(:department, :short_name)
  end
    
  it 'allows sites' do
    should allow(:sites, :index) 
    should allow(:sites, :show) 
    should allow(:sites, :popup) 
    should allow(:sites, :refresh) 
    should allow(:sites, :new) 
    should allow(:sites, :create) 
    should allow(:sites, :edit, department_site) 
    should_not allow(:sites, :edit, other_department_site) 
    should allow(:sites, :update, department_site) 
    should_not allow(:sites, :update, other_department_site) 
    should allow(:sites, :destroy, department_site)
    should_not allow(:sites, :destroy, other_department_site)
    should allow(:sites, :view_client_status_details, department_site) 
    should_not allow(:sites, :view_client_status_details, other_department_site)
    should allow_param(:site, :display_name)
    should allow_param(:site, :short_name)
    should allow_param(:site, :name_filter)
    should allow_param(:site, :enabled)
    should allow_param(:site, :site_type)
    should_not allow_param(:site, :department_id)
  end
    
  it 'allows clients' do
    should allow(:clients, :index) 
    should allow(:clients, :upload) 
    should allow(:clients, :update) 
    should allow(:clients, :destroy, client_with_site) 
    should_not allow(:client, :destroy, client_without_site)
    should allow_param(:client, :name)
    should allow_param(:client, :mac_address)
    should allow_param(:client, :client_type)
    should allow_param(:client, :ip_address)
    should allow_param(:client, :last_checkin)
    should allow_param(:client, :last_login)
    should allow_param(:client, :current_status)
    should allow_param(:client, :current_user)
    should allow_param(:client, :current_vm)
    should allow_param(:client, :enabled)
    should allow_param(:client, :site_id)
  end
    
  it 'allows api' do 
    should allow(:api, :index) 
    should allow(:api, :sites) 
    should allow(:api, :counts)
    should allow(:api, :info) 
  end
    
  it 'allows logs' do 
    should allow(:logs, :index) 
    should_not allow_param(:log, :client_id)
    should_not allow_param(:log, :operation)
    should_not allow_param(:log, :login_time)
    should_not allow_param(:log, :logout_time)
    should_not allow_param(:log, :user_id)
    should_not allow_param(:log, :vm)
  end
    
  it 'allows sessions' do  
    should allow(:sessions, :new) 
    should allow(:sessions, :create) 
    should allow(:sessions, :destroy) 
  end
      
  it 'allows stats' do  
    should allow(:stats, :index) 
    should allow(:stats, :show) 
  end
      
  it 'allows users' do  
    should allow(:users, :index) 
    should allow(:users, :new) 
    should allow(:users, :create, authenticated_user)
    should_not allow(:users, :create, department_manager) 
    should allow(:users, :edit, authenticated_user)
    should_not allow(:users, :edit, department_manager) 
    should allow(:users, :update, authenticated_user)
    should_not allow(:users, :update, department_manager) 
    should allow(:users, :destroy, authenticated_user)
    should_not allow(:users, :destroy, department_manager)
    should allow_param(:user, :username)
    should allow_param(:user, :name)
    should allow_param(:user, :email)
    should allow_param(:user, :role)
    should_not allow_param(:user, :department_id)
  end
end