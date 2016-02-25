#!/usr/local/rvm/rubies/ruby-2.1.0/bin/ruby

require "mongo"
include Mongo

# open mongo connection
client = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'music')
artists = client[:artists]

results = artists.find()
results.each do |artist|
  albumName = artist["albums"]
  puts albumName

  if albumName.to_s != '' and albumName.is_a? String and !albumName.nil?
    albumStripped = albumName.split(" - ")[0]
    albumStripped = albumStripped.sub /\s*\(.+\)$/, ''
    puts albumStripped
  end

  doc = artists.find(:name => artist["name"]).
  find_one_and_update({ '$set' => { :albums => albumStripped }}, :return_document => :after)
  doc
end
