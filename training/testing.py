#!/usr/bin/python

import csv
import nltk
import string
import pickle

## load the classifier ##
f = open('tweet_classifier.pickle')
classifier = pickle.load(f)
f.close()
#########
# create a whitelsit of just letters and spaces
whitelist = string.letters + ' '
allWords = []

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
f2 = open('test.csv')

csv_f_tr = csv.reader(f)
csv_f_te = csv.reader(f2)

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

## LOAD TESTING TWEETS ##
for row in csv_f_te:
  score = row[0]
  message = row[5]

  te_rawTweets.append((message, score))

for (m, score) in te_rawTweets:
  s = ''
  for c in m:
    if c in whitelist:
      s += c
    else:
      s += ''
  s = s.lower()
  s = removeShortWords(s)

  tokens = nltk.word_tokenize(s)
  te_tweets.append((tokens, score))

testSet = nltk.classify.apply_features(extractFeatures, te_tweets)

#tweet = "i can't stop listening to the new album"
#print classifier.classify(extractFeatures(tweet.split()))

#print classifier.show_most_informative_features(32)
print 'accuracy:', nltk.classify.util.accuracy(classifier, testSet)
