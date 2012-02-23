namespace :deploy do
  task :clear_tmp do
    puts "Clearing temp files"
    Rake::Task['tmp:clear'].invoke
    puts "Cleared temp files"
  end
  
  task :clean_assets do
    puts "Removing precompiled assets"
    Rake::Task['assets:clean'].invoke
    puts "Removed precompiled assets"
  end
  
  task :compile_assets do
    puts "Precompiling assets"
    Rake::Task['assets:precompile'].invoke
    puts "Precompiled assets"
  end
  
  desc "Refresh server for updated code"
  task :update => [:clear_tmp, :clean_assets, :compile_assets] do
    puts "Restarting webserver"
    touch 'tmp/restart.txt'
  end
end