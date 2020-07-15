Rake::Task["assets:precompile"].enhance do
  Rake::Task["assets:fix-precompile"].invoke
end

task "assets:fix-precompile" => :environment do
  puts "Modifying manifest.json"
  file_name = "#{Rails.root}/public/packs/manifest.json"
  text = File.read(file_name)
  new_contents = text.gsub(/\/packs-dev\//, "/packs/")
  File.open(file_name, "w") {|file| file.puts new_contents }
end
