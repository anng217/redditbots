import pandas as pd
import numpy as np
import scipy.stats as sts

def detox_loop(df,model):
    detox = Detoxify(model, device='cuda')
    i = 0
    n = len(df)
    df_res = pd.DataFrame()
    while i < n:
        res = detox.predict(df[i:i+100])
        f = pd.DataFrame(res,df[i:i+100]).round(5)
        df_res = pd.concat([df_res,f])
        i = i + 100
    return df_res

def flag_base(df_res,thresh):
    [float(i) for i in thresh]
    df_res['toxicity_flag'] = np.where(df_res['toxicity']>thresh[0],1,0)
    df_res['severe_toxicity_flag'] = np.where(df_res['severe_toxicity']>thresh[1],1,0)
    df_res['obscene_flag'] = np.where(df_res['obscene']>thresh[2],1,0)
    df_res['threat_flag'] = np.where(df_res['threat']>thresh[3],1,0)
    df_res['insult_flag'] = np.where(df_res['insult']>thresh[4],1,0)
    df_res['identity_attack_flag'] = np.where(df_res['identity_attack']>thresh[5],1,0)
    return df_res

def flag_unbiased(df_res,thresh):
    [float(i) for i in thresh]
    df_res['toxicity_flag'] = np.where(df_res['toxicity']>thresh[0],1,0)
    df_res['severe_toxicity_flag'] = np.where(df_res['severe_toxicity']>thresh[1],1,0)
    df_res['obscene_flag'] = np.where(df_res['obscene']>thresh[2],1,0)
    df_res['threat_flag'] = np.where(df_res['threat']>thresh[3],1,0)
    df_res['insult_flag'] = np.where(df_res['insult']>thresh[4],1,0)
    df_res['identity_attack_flag'] = np.where(df_res['identity_attack']>thresh[5],1,0)
    df_res['sexual_explicit_flag'] = np.where(df_res['sexual_explicit']>thresh[6],1,0)
    return df_res

def clean(df,model,thresh, print_res):
    df=list(df['body'].values.flatten())
    res = detox_loop(df=df,model=model)
    
    if model == 'original':
        res = flag_base(df_res=res, thresh = thresh)
    else:
        res = flag_unbiased(df_res=res, thresh = thresh)
    
    if print_res == True:
        df_mean = res.mean()
        return res,df_mean
    else:
        return res

def detox(source_dir,model, thresh, print_res, save_dir):
    #keeping separate pre-post list
    df = pd.read_csv(source_dir)
    df_pre = df[df['post']==0]
    df_post = df[df['post']==1]
 
    #pre
    if print_res == True:
        pre_res,pre_mean = clean(df=df_pre,model=model, thresh=thresh, print_res = True)
        print(f'Pre: {pre_mean}')
    else:
        pre_res = clean(df=df_pre,model=model, thresh=thresh, print_res = False)
    pre_res = pd.concat([df_pre.reset_index(drop=True),pre_res.reset_index(drop=True)], axis = 1)
    #post
    if print_res == True:
        post_res,post_mean = clean(df=df_post,model=model, thresh=thresh, print_res = True)
        print(f'Pre: {post_mean}')
    else:
        post_res = clean(df=df_post,model=model, thresh=thresh, print_res = False)
    post_res = pd.concat([df_post.reset_index(drop=True),post_res.reset_index(drop=True)], axis = 1)

    if save_dir != False:
        pre_res['post'] = 0
        post_res['post'] = 1
        res = pd.concat([pre_res,post_res], ignore_index= True)
        res.to_csv(save_dir,encoding = 'utf-8-sig')

    return pre_res,post_res