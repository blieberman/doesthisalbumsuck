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

# prep top aritsts http request
TOP_ARTISTS_URL = "http://developer.echonest.com/api/v4/artist/top_hottt?api_key=#{ API_KEY }&format=json&results=300&start=0&bucket=hotttnesss"
topArtist_uri = URI.parse(TOP_ARTISTS_URL)

topArtist_http = Net::HTTP.new(topArtist_uri.host, topArtist_uri.port)
topArtist_request = Net::HTTP::Get.new(topArtist_uri.request_uri)

topArtist_response = topArtist_http.request(topArtist_request)
topArtist_result = JSON.parse(topArtist_response.body)

callCount = 0

topArtist_result['response']['artists'].each do |artist|
  artistName = artist['name']
  puts artistName
  aNPrepped = artistName.gsub! '&', 'and'
  aNPrepped = URI.escape(artistName)
  puts aNPrepped

  # prep twitter handle http request
  twitter_handle_url = "http://developer.echonest.com/api/v4/artist/twitter?api_key=#{ API_KEY }&name=#{ aNPrepped }&format=json"
  twitterHandle_uri = URI.parse(twitter_handle_url)

  twitterHandle_http = Net::HTTP.new(twitterHandle_uri.host, twitterHandle_uri.port)
  twitterHandle_request = Net::HTTP::Get.new(twitterHandle_uri.request_uri)

  twitterHandle_response = twitterHandle_http.request(twitterHandle_request)
  twitterHandle_result = JSON.parse(twitterHandle_response.body)

  twitterHandle = ""
  twitterHandle = twitterHandle_result['response']['artist']['twitter']
  puts twitterHandle

  documents.insert_one({"name" => artistName, "twitterHandle" => twitterHandle, "popularity" => artist['hotttnesss']});
  puts callCount
  callCount += 1
  if callCount >= 115
    puts "SLEEPING TO AVOID RATE LIMIT..."
    sleep 20
    callCount = 0
  end
end
