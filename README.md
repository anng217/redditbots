# Files and process:
## 1. Scraping
- File: `pushshift.ipynb`
- Input: No
- Output: ..\github-data\[focal_subr_name]\ `subr_name_comments.csv`
- Process: Scrap all comments and posts within 90 days of bot implementation
---
- File: `reddi_api.ipynb`
- Input: No
- Output: No
- Process *intended*:
    - Retrieve all deleted comments/posts 
    - Retrieve reactions for current comments/posts
----
## 2. Cleaning
- File: `datacleaning.ipynb`
- Input: ..\data[focal_subr_name]\ `[subr_name]_comments.csv`
- Output: ..data[focal_subr_name]\ `[subr_name]_clean_comments.csv`
- Process:
    1. Change epoch time to human time 
    2. Choose comments/posts within 30 days of implementation 
    3. Choose only relevant variables from the scrapped data 
        + Comments: 
        + Posts: 
    4. Report number of cases before, after, cleaned, left out.
----
## 3. Harassment Detection
- File: `perspectiveapi.ipynb`
- Input: NA
- Output: NA
- Process: *problem* Need to get the right data types
----
- File: `detoxify.ipynb`
- Input: ..\data[focal_subr_name]\ `[subr_name]_clean.csv`
- Output: ..\data[focal_subr_name]\ `[subr_name]_res.csv`
- Process:
    1. Get scores for each comments with detoxify model 
    2. Flag if the comment is harassment based on threshhold
----
## 4. Regression
- File: `visual_RD.r`
- Input: TBD
- Output: TBD
- Process: Visualizing Regression Discontinuity
----
- File: `BSTS.r`
- Input: BSTS.r
- Output: TBD
- Process: 
    1. Group comments and score by date 
    2. Take average score for each date/ percentage of comments flagged as toxic in one day 
    3. Construct BSTS


## Concerns:
- Recover deleted comments
- Upvote for comments
- Upvote for submissions
- Non-text submissions
- Clean internet characters

## Reddit REST API



## Perspective API : [Sample Request](https://developers.perspectiveapi.com/s/docs-sample-requests) | [Installation Guide](https://github.com/googleapis/google-api-python-client) |
### Code
- Open Anaconda Prompt
- Script
`\pip.exe install google-api-python-client`

### Note
Perspective API only allows running single instances. Rate limit is 1 second/instance.

## Detoxify: [Git Repo](https://github.com/unitaryai/detoxify)

