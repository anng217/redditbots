from xml.dom.pulldom import START_ELEMENT
import pandas as pd
import numpy as np
import scipy.stats as sts
from detoxify import Detoxify
import datetime as dt
import time
import requests
from pmaw import PushshiftAPI
import praw

# Detox Comments
def detox_loop(df,model):
    detox = Detoxify(model, device='cuda')
    i = 0
    n = len(df)
    df_res = pd.DataFrame()
    tic = time.time()
    while i < n:
        res = detox.predict(df[i:i+100])
        f = pd.DataFrame(res,df[i:i+100]).round(5)
        df_res = df_res.append(f)
        if i%300 == 0:
            print('Time elapsed: ', round(time.time()-tic), 'secs, i =', i)
        i = i + 100
    return df_res

def detox_body(df,model):
    df=list(df['body'].values.flatten())
    res = detox_loop(df=df,model=model)
    return res

def detox(source_dir,model, save_dir= None):
    #keeping separate pre-post list
    df = pd.read_csv(source_dir)
    body_res = detox_body(df, model)
    res = pd.concat([df.reset_index(drop=True),body_res.reset_index(drop=True)], axis = 1)
    if save_dir != None:
        res.to_csv(save_dir, encoding = 'utf-8-sig')
    return res

# praw enhancement
reddit = praw.Reddit(
 client_id='9wXh5oa4cfW07_eUn5Hu3A',
 client_secret='m3GnhaEvbM5LGCWX3BMghLCatOLN3g',
 user_agent=f'python: PMAW request enrichment (by u/softyarn)'
)

api_praw = PushshiftAPI(praw=reddit)

# pmaw set up
api = PushshiftAPI()


# Reddit API (no wrapper)
def clean_id(source_dir, comment_bool):
    df = pd.read_csv(source_dir)
    df = df[["id","body"]]
    if comment_bool == True:
        df['id'] ='t1_' + df['id'].astype(str)
    else:
        df['id'] ='t3_' + df['id'].astype(str)
    df["note"] = np.where(df["body"] == "[removed]", "removed", np.where(df["body"] == "[deleted]", "deleted", "text"))
    return df

def get_comments(df, headers) :
    tic = time.time()
    global res_df
    res_df = []
    i = 0
    while i < len(df["id"]):
        j = min(len(df["id"]), i + 40)
        x = ",".join(df["id"][i:j])
        comments = requests.get('https://oauth.reddit.com/api/info',headers=headers,params={'id': x}).json()
        for k in range(j-i):
            comment_df = pd.DataFrame.from_dict(comments.get("data").get("children")[k].get("data"), orient = "index").transpose()
            res_df.append(comment_df)
        i += 40
        if i%300 == 0:
            time.sleep(2)
            #now = time.localtime(time.time())
            print('Time elapsed: ', round(time.time() - tic),' secs, i = ',i)
            #print(time.strftime("Time now: %HH:%M:%S",now),f', i = {i}')
    return pd.concat(res_df)

def get_submissions(df, headers):
    tic = time.time()
    global res_df
    res_df = pd.DataFrame()
    i = 0
    while i < len(df["id"]):
        j = min(len(df["id"]), i + 40)
        x = ",".join(df["id"][i:j])
        submissions = requests.get('https://oauth.reddit.com/by_id/names',headers=headers,params={'names': x}).json()
        for k in range(20):
            submission_df = pd.DataFrame.from_dict(submissions.get("data").get("children")[k].get("data"), orient = "index").transpose()
            res_df.append(submission_df)
        i += 40
        if i%300 == 0:
            time.sleep(2)
            print('Time elapsed: ', round(time.time() - tic),' secs, i = ',i)
    return pd.concat(res_df)  

# Pushift PMAW
def fetch_comments (subreddit, bot_epoch, before, after, duration, limit = 1000000000):
    before = int((dt.datetime(bot_epoch)-dt.timedelta(days = duration)).timestamp())
    after = int((dt.datetime(bot_epoch)+dt.timedelta(days = duration)).timestamp())
    comments = api.search_comments(subreddit = subreddit, limit = limit, before = before, after = after)
    df = pd.DataFrame(comments)
    df['post']=1
    df.loc[df['created_utc'] < bot_epoch, 'post'] = 0
    return df

def flatten_author(df):
    authors = df.loc[:,'author']
    authors_unique = np.unique(authors)
    authors_str = ','.join(authors_unique)
    return authors_str

def author_list(df):
    authors = df.loc[:,'author']
    authors_unique = np.unique(authors)
    return authors_unique

def get_epoch(bot_epoch, duration):
    before = int((dt.datetime.fromtimestamp(bot_epoch)+dt.timedelta(days = duration)).timestamp())
    after = int((dt.datetime.fromtimestamp(bot_epoch)-dt.timedelta(days = duration)).timestamp())
    return before, after

def author_comments(df, bot_epoch, duration, limit = 10000000000, enhance = True):
    before, after = get_epoch(bot_epoch, duration) 
    #creating loop so that only 100 authors per praw
    tic = time.time()
    global res_df
    res_df = []
    authors = author_list(df)
    i = 0
    while i < len(authors):
        j = min(i+100, len(authors))
        x = ','.join(authors[i:j])
        comments = api.search_comments(author = x, limit = limit, before = before, after = after)
        comments_list = [c for c in comments]
        res_df.append(comments_list)
        i +=100
    if i%500 == 0:
        time.sleep(1)
        print('Time elapsed: ', round(time.time() - tic),' secs, i = ',i)
    return pd.concat(res_df)



