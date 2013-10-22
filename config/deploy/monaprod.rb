set :application, "monalisa"
set :repository,  "git@github.com:mjpete3/monalisa.git"

set :scm, :git
set :scm_username, "mjpete3"

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "10.10.1.128"                          # Your HTTP server, Apache/etc
role :app, "10.10.1.128"                          # This may be the same as your `Web` server
role :db,  "10.10.1.128", :primary => true # This is where Rails migrations will run

set :user, "marty"
set :deploy_to, "/var/www/html/monaprod/#{application}"
set :use_sudo, false
set :deploy_via, :remote_cache

#this pain in the ass option allowed the remote sever to authenticate to github
default_run_options[:pty] = true
#set :ssh_options, {:forward_agent => true}
ssh_options[:forward_agent] = true

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
after "deploy", "deploy:bundle_gems"
after "deploy:bundle_gems", "deploy:migrate"
after "deploy:migrate", "deploy:seed" 
after "deploy:seed", "deploy:precompile"
after "deploy:precompile", "deploy:restart"

namespace :deploy do
   task :bundle_gems do
     run "cp -f #{deploy_to}/current/ProdGemfile #{deploy_to}/current/Gemfile"
     run "cd #{deploy_to}/current && bundle install --path vendor/gems"
   end
   
   task :migrate do
     # set the correct database connections for monatest
     run "cp -f #{deploy_to}/current/config/database/monaprod.yml #{deploy_to}/current/config/database.yml"
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake db:migrate"
   end
   
   task :seed do
     # normal do not want to seed the production databases, except for the very first run
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake db:seed" 
     # procedure and modifier codes    
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake csv:cpt"
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake csv:mods"
     # diagnostic codes
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake csv:dsm"
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake csv:icd9"
     # point of service codes
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake csv:pos"     
     # carc and rarc codes supporting eobs    
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake csv:carc"
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake csv:rarc"
     
     # database transformation tasks
     #run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake db:selector"     
   end
   
   task :precompile do
     # for each of the clearing houses, create the directory structure for handling files
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake office_ally:mkdir"
     run "cd #{deploy_to}/current && RAILS_ENV=production bundle exec rake assets:precompile"
   end
   
   task :start do ; end
   task :stop do ; end
   
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end
