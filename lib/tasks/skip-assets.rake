if ENV['RAILS_ENV'] == 'production' || ENV['NODE_ENV'] == 'staging' 
  Rake::Task["assets:precompile"].clear
  namespace :assets do
    task 'precompile' do
      puts "Not pre-compiling assets..."
    end
  end
end