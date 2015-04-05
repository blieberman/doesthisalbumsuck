#!/usr/local/rvm/rubies/ruby-2.1.0/bin/ruby

require "uri"
require "net/http"
require "json"

uri = URI.parse("http://ws.audioscrobbler.com/2.0/?method=chart.gettopartists&api_key=4813ee0c7592b5a8941e9a9cdd85ee98&format=json")

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)

result = JSON.parse(response.body)

result['artists']['artist'].each do |child|
  puts child['name']
end
