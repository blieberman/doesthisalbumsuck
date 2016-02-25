#!/usr/bin/python
from __future__ import division

import csv
import nltk
import string
import pickle
import pymongo

from pymongo import MongoClient

## load the classifier ##
f = open('tweet_classifier.pickle')
classifier = pickle.load(f)
f.close()
#########
# create a whitelsit of just letters and spaces
whitelist = string.letters + ' '
allWords = []

# returns string without words in given string
def removeWords(text, removeString):
  wl = text.split()
  rl = removeString.split()

  return ' '.join([i for i in wl if i not in rl])

# returns string with all words under 3 characters
def removeShortWords(text): 
  return ' '.join(word for word in text.split() if len(word)>3)

# returns a list of all words in the given tweets
def tweetToAllWords(tweets):
  words = []
  for (tweet, score) in tweets:
    words.extend(tweet)

  tweets = nltk.FreqDist(words)
  # hacky way of getting one standarized list
  freqs = tweets.keys() 
  return freqs
# returns a dictionary of boolean of whether list of words appears in given frequencyMap keys
def extractFeatures(lOW):
  words = set(lOW)
  features = {}
  for word in allWords:
    features['contains(%s)' % word] = (word in words)
  return features

f = open('training.csv')

csv_f_tr = csv.reader(f)

tr_rawTweets = []
tr_tweets = []
te_rawTweets = []
te_tweets = []

## LOAD ALLWORDS ##
for row in csv_f_tr:
  score = row[0]
  message = row[5]

  tr_rawTweets.append((message, score))

for (m, score) in tr_rawTweets:
  s = ''
  for c in m:
    if c in whitelist:
      s += c
    else:
      s += ''
  s = s.lower()
  s = removeShortWords(s)

  tokens = nltk.word_tokenize(s)
  tr_tweets.append((tokens, score))

allWords = tweetToAllWords(tr_tweets)
#########

## LOAD MONGO TWEETS ##
client = MongoClient('localhost', 27017)
db = client.music
collection = db.tweets


for a in db.artists.find():
  artist = a.get("name")
  albumName = a.get("albums")
  count = 0
  
  for message in collection.find( { "artist": artist } ).distinct("message"):
    print artist
    print albumName
    print message

    s = ''
    for c in message:
      if c in whitelist:
        s += c
      else:
        s += ''
    s = removeShortWords(s)
    s = s.lower()
    s = removeWords(s, albumName.lower())
    s = s.replace(artist.lower(), "")
    
    print s

    sNum = classifier.classify(extractFeatures(message.split()))
    sNum = sNum.replace("'", "")

    collection.find_and_modify( query={"message" : message}, update={"$set": {"sentiment": sNum}}, upsert=False, full_response=True)
    print sNum
    count +=1
    print count
