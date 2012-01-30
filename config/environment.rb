# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SitesUsage::Application.initialize!

SitesUsage::Application.config.ldap = YAML.load_file("#{Rails.root}/config/ldap.yml")
