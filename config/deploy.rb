require 'socialcast/recipes/mongrel_cluster'

set :application, "personal"
set :user, "shawnis"
set :domain, '74.63.8.222'
set :mongrel_port, '4118'
set :server_hostname, 'scashin.com'

set :git_account, 'scashin133'

set :scm_passphrase,  Proc.new { Capistrano::CLI.password_prompt('Git Password: ') }

role :web, server_hostname
role :app, server_hostname
role :db, server_hostname, :primary => true

default_run_options[:pty] = true
set :repository,  "git@github.com:#{git_account}/div-counter.git"
set :scm, "git"
set :user, user

ssh_options[:forward_agent] = true
set :branch, "master"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :use_sudo, false
set :deploy_to, "/home/#{user}/#{application}"

after 'deploy:symlink', 'deploy:finishing_touches'

namespace :deploy do
   task :finishing_touches, :roles => :app do
    run "cp -pf #{deploy_to}/to_copy/environment.rb #{current_path}/config/environment.rb"
    run "cp -pf #{deploy_to}/to_copy/database.yml #{current_path}/config/database.yml"
  end
end