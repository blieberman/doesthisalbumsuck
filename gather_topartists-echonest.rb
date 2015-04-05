#!/usr/local/rvm/rubies/ruby-2.1.0/bin/ruby

require "uri"
require "json"
require "net/http"
require "mongo"
include Mongo

## ECHONEST API KEYS ##
API_KEY = 'L7IXI5E2ZRRIRQDRD'
CONSUMER_KEY = '14b2e4475de5e5be91631c47f20839c9'
SHARED_SECRET = '4Es+qT0HS6GOce7t1F2JCA'
####


# open mongo connection
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'music')
documents = db[:artists]

# prep http request
URL = "http://developer.echonest.com/api/v4/artist/top_hottt?api_key=#{ API_KEY }&format=json&results=500&start=0&bucket=hotttnesss"
uri = URI.parse(URL)

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Get.new(uri.request_uri)

response = http.request(request)

result = JSON.parse(response.body)

result['response']['artists'].each do |artist|
  documents.insert_one({"name" => artist['name'], "twitterHandle" => "", "popularity" => artist['hotttnesss']});
end
