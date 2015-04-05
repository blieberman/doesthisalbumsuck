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

db = Mongo::Client.new([ '127.0.0.1:27017' ], :database => 'music')
documents = db[:tweets]

client.search("springbreak", result_type: "recent").take(50).each do |tweet|
  documents.insert_one({"loc" => "Boston", "timecreated" => tweet.created_at.day.to_s+"/"+tweet.created_at.month.to_s+"/"+tweet.created_at.year.to_s, "message" => tweet.text});
end
