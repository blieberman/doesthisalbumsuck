#!/usr/bin/python

import csv
import nltk
import string
import pickle

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
csv_f = csv.reader(f)

rawTweets = []
tweets = []

for row in csv_f:
  score = row[0]
  message = row[5]

  rawTweets.append((message, score))

for (m, score) in rawTweets:
  s = ''
  for c in m:
    if c in whitelist:
      s += c
    else:
      s += ''
  s = s.lower()
  s = removeShortWords(s)

  tokens = nltk.word_tokenize(s)
  tweets.append((tokens, score))

#### let's make the classifier ####
allWords = tweetToAllWords(tweets)

# returns a tuple of each tweet broken down with word boolean and pre-defined sentimate score
tSet = nltk.classify.apply_features(extractFeatures, tweets)
# use the tSet to build a classifier
classifier = nltk.NaiveBayesClassifier.train(tSet)

## lets save the classifier to disk ##
f = open('tweet_classifier.pickle', 'wb')
pickle.dump(classifier, f)
f.close
