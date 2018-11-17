'''
This script aggregates data from the logs so that we can better compare the performance of different
players against deepstack 

Right now, it reads through all of the log files and then aggregates the scores for the "weaker" player against DeepStack

'''
import os
import scipy.stats as sp

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
			scores[p1].append(score)
			scores[p2].append(-1*score)
	return scores


weak_player_scores = {}
for (root, dirs, files) in os.walk('logs/', topdown=True):
	for file in files:
		if file.endswith('.log'):
			scores = aggregate_scores(root + file)
			for key in scores.keys():
				if key != 'deepStack':
					weak_player_scores[key] = scores[key]

print(sp.ttest_ind(weak_player_scores['allin'], weak_player_scores['alwayscall']))