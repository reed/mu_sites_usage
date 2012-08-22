source 'http://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'select2-rails'
  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails', '2.0.0'
gem 'therubyracer', require: "v8"
gem 'whenever', :require => false
gem 'draper' 
gem 'net-ldap'
gem 'friendly_id'
gem 'cancan'
gem 'best_in_place'
gem 'will_paginate'
gem 'exception_notification'
gem 'coffeebeans'
gem 'jbuilder'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
gem 'debugger', group: [:development, :test, :staging]

group :development do
	gem 'rspec-rails', '~> 2.8.1'
	gem 'annotate', '~> 2.4.0'
end

#group :staging do
  gem 'tiny_tds'
  gem 'activerecord-sqlserver-adapter'
#end

group :test do
  gem 'rspec', '~> 2.8.0'
  gem "factory_girl_rails"
  gem "capybara"
  gem "guard-rspec", '~> 0.6.0'
  gem 'guard-spork', '~> 0.5.2'
  gem 'spork', '~> 1.0.0rc0'
  gem 'rb-fsevent'
  gem 'growl'
  # Pretty printed test output
  gem 'turn', :require => false
end
