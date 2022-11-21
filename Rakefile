# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

# Disable assets precompile for Buildpacks.
# SEE: [ruby on rails 4 - How disable assets compilation on heroku? - Stack Overflow](https://stackoverflow.com/questions/23687972/how-disable-assets-compilation-on-heroku)
Rake::Task["assets:precompile"].clear
namespace :assets do
  task 'precompile' do
    puts "Not pre-compiling assets..."
  end
end
