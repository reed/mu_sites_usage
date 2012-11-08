require 'spec_helper'

describe Permissions::AuthenticatedUserPermission do
  let(:department){ create(:department) }
  let(:other_department){ create(:department) }
  let(:user){ create(:user, department: department) }
  let(:department_site){ create(:site, department: department )}
  let(:other_department_site){ create(:site, department: other_department)}
  let(:external_site){ create(:site, site_type: 'general_access' )}
  let(:internal_site){ create(:site, site_type: 'internal' )}
  subject { Permissions.permission_for(user) }
    
  it 'allows departments' do
    should allow(:departments, :index) 
    should allow(:departments, :show) 
    should_not allow(:departments, :new) 
    should_not allow(:departments, :create) 
    should_not allow(:departments, :edit) 
    should_not allow(:departments, :update) 
    should_not allow(:departments, :destroy)
    should_not allow_param(:departments, :display_name)
    should_not allow_param(:departments, :short_name)
  end
    
  it 'allows sites' do
    should_not allow(:sites, :index) 
    should allow(:sites, :show, external_site) 
    should allow(:sites, :popup, external_site) 
    should allow(:sites, :refresh, external_site) 
    should_not allow(:sites, :show, internal_site) 
    should_not allow(:sites, :popup, internal_site) 
    should_not allow(:sites, :refresh, internal_site) 
    should_not allow(:sites, :new) 
    should_not allow(:sites, :create) 
    should_not allow(:sites, :edit) 
    should_not allow(:sites, :update) 
    should_not allow(:sites, :destroy)
    should allow(:sites, :view_client_status_details, department_site) 
    should_not allow(:sites, :view_client_status_details, other_department_site)
    should_not allow_param(:sites, :display_name)
    should_not allow_param(:sites, :short_name)
    should_not allow_param(:sites, :name_filter)
    should_not allow_param(:sites, :enabled)
    should_not allow_param(:sites, :site_type)
    should_not allow_param(:sites, :department_id)
  end
    
  it 'allows clients' do
    should_not allow(:clients, :index) 
    should allow(:clients, :upload) 
    should_not allow(:clients, :update) 
    should_not allow(:clients, :destroy)
    should_not allow_param(:clients, :name)
    should_not allow_param(:clients, :mac_address)
    should_not allow_param(:clients, :client_type)
    should_not allow_param(:clients, :ip_address)
    should_not allow_param(:clients, :last_checkin)
    should_not allow_param(:clients, :last_login)
    should_not allow_param(:clients, :current_status)
    should_not allow_param(:clients, :current_user)
    should_not allow_param(:clients, :current_vm)
    should_not allow_param(:clients, :enabled)
    should_not allow_param(:clients, :site_id)
  end
    
  it 'allows api' do 
    should allow(:api, :index) 
    should allow(:api, :sites) 
    should allow(:api, :counts)
    should allow(:api, :info) 
  end
    
  it 'allows logs' do 
    should_not allow(:logs, :index) 
    should_not allow_param(:logs, :client_id)
    should_not allow_param(:logs, :operation)
    should_not allow_param(:logs, :login_time)
    should_not allow_param(:logs, :logout_time)
    should_not allow_param(:logs, :user_id)
    should_not allow_param(:logs, :vm)
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
    should_not allow(:users, :index) 
    should_not allow(:users, :new) 
    should_not allow(:users, :create) 
    should_not allow(:users, :edit) 
    should_not allow(:users, :update) 
    should_not allow(:users, :destroy)
    should_not allow_param(:users, :username)
    should_not allow_param(:users, :name)
    should_not allow_param(:users, :email)
    should_not allow_param(:users, :role)
    should_not allow_param(:users, :department_id)
  end
end