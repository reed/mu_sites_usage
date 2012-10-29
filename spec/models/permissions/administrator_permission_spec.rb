require 'spec_helper'

describe Permissions::AdministratorPermission do
  let(:user){ create(:user, :administrator) }
  subject { Permissions.permission_for(user) }
    
  it 'allows everything' do
    should allow(:anything, :here) 
    should allow_param(:anything, :here)
    should allow_param(:department, :display_name)
    should allow_param(:department, :short_name)
  end
end