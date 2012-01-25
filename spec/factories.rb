#FactoryGirl.define do
Factory.define :department do |f|
  f.sequence(:display_name) { |n| "Test Department #{n}" }
  f.sequence(:short_name) { |n| "testdept#{n}" }
end
Factory.define :site do |f|
  f.sequence(:display_name) { |n| "Test Site #{n}" }
  f.sequence(:short_name) { |n| "testsite#{n}" }
  f.sequence(:name_filter) { |n| "TEST-TC-#{n}" }
  f.association :department
end
Factory.define :client do |f|
  f.sequence(:name) { |n| "TEST-TC-#{n}" }
  f.mac_address { Factory.next(:mac_address) }
  f.client_type "tc"
  f.ip_address "100.200.300.400"
  f.association :site
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

Factory.sequence :mac_address do |n|
  "#{(1..6).map{"%0.2X"%rand(256)}.join(":")}".downcase
end
