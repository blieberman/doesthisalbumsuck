#!/usr/local/rvm/rubies/ruby-2.1.0/bin/ruby

require "twitter"
require "mongo"
include Mongo

#### CONSTANTS FOR MY TWITTER.COM/API INFO ####
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "fMvLjQR4hgdMfLyXeOaxq72ql"
  config.consumer_secret     = "sDPzl9FxfOONbGwM6WOBD7Vn39EasMtS6nMkm6lETpIrJvE9ya"
  config.access_token        = "815947880-YuGX47IfkZh7oB6Gq2hdTjWS3eGmEvwMjnMORNFa"
  config.access_token_secret = "v2WsK9cB94ngCgqOByAR1pOOzlLwwXDpH6Z7kzKsmYGk6"
end
###############################################

# open a mongo connection to the music database
db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'music')
documents = db[:tweets]
artists = db[:artists]

minr = 0.902

results = artists.find({ popularity: {"$lt" => minr} })
results.each do |artist|
  name = artist["name"]
  albumName = artist["albums"]
  twitterHandle = artist["twitterHandle"]
  puts name
  puts albumName
  puts twitterHandle
  puts

  if albumName.to_s == ''
    next
  end

   if twitterHandle.to_s == ''
     twitterHandle = name
   end

  searchText = "#{ twitterHandle } " + albumName + " -filter:retweets -filter:links -http"
#  searchText = "#{ name } " + albumName + " -filter:links -filter:retweets -bit"

  client.search(searchText, lang: "en").take(400).each do |tweet|
    documents.insert_one({"album" => artist["albums"],
                          "artist" => artist["name"],
                          "timecreated" => tweet.created_at.day.to_s+"/"+tweet.created_at.month.to_s+"/"+tweet.created_at.year.to_s, 
                          "message" => tweet.text});
  end

end
