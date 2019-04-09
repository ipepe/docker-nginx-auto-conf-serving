puts "Starting auto nginx conf runner!"
Dir.glob('/usr/share/webapps/**/webapp.conf.erb') do |conf_filepath|
  puts conf_filepath
end