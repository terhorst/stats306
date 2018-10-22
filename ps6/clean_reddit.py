import csv
import json
import functools
import operator
import itertools
import tqdm
import re
import sh
import concurrent.futures


def obscenities():
    from urllib.request import urlopen

    resp = urlopen("http://cs.cmu.edu/~biglou/resources/bad-words.txt")
    badwords = str(resp.read()).split("\\n")
    return badwords[1:-1] + ["nsfw"]


bad_re = re.compile("\\b(" + "|".join(obscenities()) + ")\\b", re.IGNORECASE)


def is_clean(line):
    res = bad_re.search(line)
    return res is None


n = int(sh.wc("reddit_xmas_2017.json", l=True).split(" ")[0])

with concurrent.futures.ProcessPoolExecutor() as p:
    clean = p.map(is_clean, open("reddit_xmas_2017.json", "rt"), chunksize=10000)
    cleaned = [
        json.loads(line)
        for line, clean in zip(
            tqdm.tqdm(open("reddit_xmas_2017.json", "rt"), total=n), clean
        )
        if clean
    ]
json.dump(cleaned, open("reddit_xmas_2017_clean.json", "wt"))
