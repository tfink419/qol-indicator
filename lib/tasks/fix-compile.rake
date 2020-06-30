task "assets:fix-precompile" => :environment do
  file_name = "#{Rails.root}/public/packs/manifest.json"
  text = File.read(file_name)
  new_contents = text.gsub(/\/packs-dev\//, "/packs/")
  File.open(file_name, "w") {|file| file.puts new_contents }
end