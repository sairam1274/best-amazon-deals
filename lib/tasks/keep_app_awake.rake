require 'rake'

desc "Pings app to keep it awake"
task :keep_app_awake => :environment do
  require "net/http"
  
  if ENV['PING_URL']
    uri = URI(ENV['PING_URL'])
    Net::HTTP.get_response(uri)
  end
end