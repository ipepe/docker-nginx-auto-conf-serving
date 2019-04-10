require 'erb'
require 'digest'
require 'fileutils'

puts "==== Starting auto nginx conf runner! ===="

def sites_enabled_md5
  all_configuration_md5s = []
  Dir.glob('/etc/nginx/sites-enabled/*.conf') do |enabled_site_conf|
    all_configuration_md5s.push(Digest::MD5.hexdigest(File.read(enabled_site_conf)))
  end
  Digest::MD5.hexdigest all_configuration_md5s.join(',')
end

process_file_lock = File.open($PROGRAM_NAME, 'r')

if process_file_lock.flock(File::LOCK_EX | File::LOCK_NB)
  md5_before = sites_enabled_md5

  puts 'Cleaning all sites-enabled'
  `rm /etc/nginx/sites-enabled/*`

  Dir.glob('/usr/share/webapps/**/*.conf.erb') do |template_file_path|
    next if template_file_path == '/usr/share/webapps/example.conf.erb'
    puts "Processing: #{template_file_path}"
    begin
      template_file_path
      template_dir_path = File.dirname(template_file_path)
      site_config_name = File.basename(template_file_path, '.erb')

      template = ERB.new(File.read(template_file_path))

      compiled_template = template.result(binding)

      puts "Saving configuration to /etc/nginx/sites-available/#{site_config_name}"
      File.write("/etc/nginx/sites-available/#{site_config_name}", compiled_template)
      puts "Linking /etc/nginx/sites-available/#{site_config_name} to sites-enabled"
      `ln -s /etc/nginx/sites-available/#{site_config_name} /etc/nginx/sites-enabled/#{site_config_name}`
    rescue StandardError => e
      STDERR.puts "#{e.class}: #{e.message}"
      STDERR.puts e.backtrace
    end
  end

  puts 'Nginx test'
  puts `/usr/sbin/nginx -t`

  if sites_enabled_md5 != md5_before
    puts 'Configurations changed. Nginx reload!'
    `/usr/sbin/nginx -s reload`
  else
    puts 'Configurations are same. Skipping reload'
  end
else
  STDERR.puts "Unable to obtain process lock for auto_nginx_conf_runner. My pid = #{$$}"
end

puts "==== Finished auto nginx conf runner! ===="
