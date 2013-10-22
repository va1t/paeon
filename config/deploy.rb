set :stages, %w(uat usertest training monaprod)
set :default_stage, "uat"
require 'capistrano/ext/multistage'


# ==============================
# Uploads
# ==============================

namespace :uploads do

  desc <<-EOD
    Creates the upload folders unless they exist and sets the proper upload permissions.
  EOD
  task :setup, :except => { :no_release => true } do
    dirs = uploads_dirs.map { |d| File.join(shared_path, d) }
    run "#{try_sudo} mkdir -p #{dirs.join(' ')} && #{try_sudo} chmod g+w #{dirs.join(' ')}"
  end

  desc <<-EOD
    [internal] Creates the symlink to uploads shared folder for the most recently deployed version.
  EOD
  task :symlink, :except => { :no_release => true } do
    run "rm -rf #{release_path}/edi"
    run "ln -nfs #{shared_path}/edi #{release_path}/edi"
  end

  desc <<-EOD
    [internal] Computes uploads directory paths and registers them in Capistrano environment.
  EOD
  task :register_dirs do
    set :uploads_dirs,    %w(edi)
    set :shared_children, fetch(:shared_children) + fetch(:uploads_dirs)
  end

  after       "deploy:finalize_update", "uploads:symlink"
  on :start,  "uploads:register_dirs"

end