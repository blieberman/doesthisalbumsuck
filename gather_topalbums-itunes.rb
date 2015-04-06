#!/usr/local/rvm/rubies/ruby-2.1.0/bin/ruby

require "uri"
require "json"
require "net/http"
require "mongo"
include Mongo

# open mongo connection
client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'music')
artists = client[:artists]

results = artists.find()
results.each do |artist|
  artistName = artist["name"]
  puts artistName

  #aNPrepped = artistName.gsub! ' ', '+'
  aNPrepped = URI.escape(artistName)

  # prep itunes api http request
  itunes_url = "https://itunes.apple.com/search?term=#{ aNPrepped }&entity=album&limit=1&order=recent"
  itunes_uri = URI.parse(itunes_url)

  itunes_http = Net::HTTP.new(itunes_uri.host, itunes_uri.port)
  itunes_http.use_ssl = true
  itunes_request = Net::HTTP::Get.new(itunes_uri.request_uri)

  itunes_response = itunes_http.request(itunes_request)
  itunes_result = JSON.parse(itunes_response.body)

  #iterate through the albums
  itunes_result['results'].each do |album|
    albumName = ""
    albumName = album['collectionName']
    puts albumName

    doc = artists.find(:name => artistName).
    find_one_and_update({ '$set' => { :albums => albumName }}, :return_document => :after)
    doc
  end

end
