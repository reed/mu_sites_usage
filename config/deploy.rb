set :application, "sitesusage"
set :domain, "sitesusage.doit.missouri.edu"
set :repository,  "git:///home/reednj/apps/sites_usage.git"
set :use_sudo, false
set :deploy_to, "/var/www/sitesapp"

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start, :roles => :app do 
    run "touch #{current_release}/tmp/restart.txt"
  end
  task :stop, :roles => :app do 
    # Do nothing
  end
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt'"
  end
end