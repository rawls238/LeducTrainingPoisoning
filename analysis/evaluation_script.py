'''
This script aggregates data from the logs so that we can better compare the performance of different
players against deepstack 

Right now, it reads through all of the log files and then aggregates the scores for the "weaker" player against DeepStack

'''
import os
import scipy.stats as sp
import csv

def aggregate_scores(log_name):
	scores = {}
	with open(log_name) as f:
		for line in f:
			if 'STATE' not in line or line.index('STATE') > 0:
				continue
			line_split = line.split('|')
			p2 = line_split[3].strip()
			p1 = line_split[2].split(':')[1]
			if p1 not in scores:
				scores[p1] = []
			if p2 not in scores:
				scores[p2] = []
			score = float(line_split[2].split(':')[0])
			scores[p2].append(score)
			scores[p1].append(-1*score)
	return scores

def get_scores(f):
	profile_scores = {}
	for (root, dirs, files) in os.walk(f, topdown=True):
		for file in files:
			if file.endswith('.log'):
				scores = aggregate_scores(root +file)
				for key in scores.keys():
					profile_scores[key] = scores[key]
	return profile_scores

unbiased_player_scores = get_scores('../logs/1k Games/Trial2-ControlDS/')
biased_player_scores = get_scores('../logs/1k Games/Trial2-BiasDS/')

with open('results.csv', 'w') as fp:
	writer_condensed = csv.writer(fp)
	writer_condensed.writerow(['type', 'round', 'player', 'result'])
	for key in biased_player_scores.keys():
		r = 0
		for val in biased_player_scores[key]:
			if key == 'mild_adaptive':
				key = 'mildadaptive_rocks'
			elif key == 'random_bluffer':
				key = 'randomizedbluffer'
			writer_condensed.writerow(['biased', r, key, val])
			r += 1
	for key in unbiased_player_scores.keys():
		r = 0
		for val in unbiased_player_scores[key]:
			writer_condensed.writerow(['unbiased', r, key, val])
			r += 1
