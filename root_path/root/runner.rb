# TODO pid lock runner to prevent long running double process spawn
# TODO

require 'erb'
require 'ostruct'
require 'open3'
require 'digest'

puts "Starting auto nginx conf runner!"

Dir.glob('/usr/share/webapps/**/webapp.conf.erb') do |template_file_path|
  puts "Processing: #{template_file_path}"
  begin
    template_file_path
    template_dir_path = File.dirname(template_file_path)
    site_config_name = Digest::MD5.hexdigest template_file_path

    template = ERB.new(File.read(template_file_path))

    compiled_template = template.result(binding)

    puts "Saving configuration to /etc/nginx/sites-available/#{site_config_name}.conf"
    File.write("/etc/nginx/sites-available/#{site_config_name}.conf", compiled_template)

    `ln -s /etc/nginx/sites-available/#{site_config_name}.conf /etc/nginx/sites-enabled/#{site_config_name}.conf`

  rescue => e
    STDERR.puts "#{e.class}: #{e.message}"
    STDERR.puts e.backtrace
  end
end



nginx_test_output, nginx_test_status = Open3.capture2e('/usr/sbin/nginx -c /etc/nginx/nginx.conf -t')

puts "Nginx test"
puts nginx_test_output


