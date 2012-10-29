FactoryGirl.define do
  factory :department do
    sequence(:display_name) { |n| "Test Department #{n}" }
    sequence(:short_name) { |n| "testdept#{n}" }
  end
  factory :site do
    sequence(:display_name) { |n| "Test Site #{n}" }
    sequence(:short_name) { |n| "testsite#{n}" }
    sequence(:name_filter) { |n| "TEST-TC-#{n}" }
    site_type "general_access"
    association :department
  end
  factory :client do
    sequence(:name) { |n| "TEST-TC-#{n}" }
    mac_address { FactoryGirl.generate(:mac_address) }
    client_type "tc"
    ip_address "100.200.300.400"
    association :site
    
    trait :orphan do
      site nil
    end
  end
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@missouri.edu" }
    role "authenticated_user"
    association :department
    
    trait :administrator do
      role "administrator"
    end
    
    trait :department_manager do
      role "department_manager"
    end
    
    trait :site_manager do 
      role "site_manager"
    end
  end
#  Factory.define :site do |f|
#    f.sequence(:display_name) { |n| "Test Site #{n}" }
#    f.sequence(:short_name) { |n| "testsite#{n}" }
#    f.sequence(:name_filter) { |n| "TEST-TC-#{n}" }
#  end
#  Factory.define :thin_client do |f|
#    f.sequence(:name) { |n| "TEST-TC-#{n}" }
#    f.mac_address { Factory.next(:mac_address) }
#    f.department "sites"
#    f.sequence(:ip_address) { |n| "100.200.300.1#{n}" }
#    f.association :site
#  end
#end
  sequence :mac_address do
    "#{(1..6).map{"%0.2X"%rand(256)}.join(":")}".downcase
  end
end
