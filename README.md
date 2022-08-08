## Files and process:
| Step                    | **File**               | **Input**                                             | **Output**                                                 | **Process**                                                                                                                                                                                                                            |
|-------------------------|------------------------|-------------------------------------------------------|------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1. Scraping             | `pushshift.ipynb`      |                                                       | ..\data\[focal_subr_name]\ `subr_name_comments.csv`        | All comments and posts within 90 days of bot implementation                                                                                                                                                                            |
|                         | `reddi_api.ipynb`      |                                                       |                                                            | *intended* - Retrieve all deleted comments/posts - Retrieve reactions for current comments/posts                                                                                                                                       |
| 2. Cleaning             | `datacleaning.ipynb`   | ..\data\[focal_subr_name]\ `[subr_name]_comments.csv` | ..data\[focal_subr_name]\ `[subr_name]_clean_comments.csv` | 1. Change epoch time to human time 2. Choose comments/posts within 30 days of implementation 3. Choose only relevant variables from the scrapped data + Comments: + Posts: 4. Report number of cases before, after, cleaned, left out. |
| 3. Harassment Detection | `perspectiveapi.ipynb` |                                                       |                                                            | *problem* - Need to get the right data types                                                                                                                                                                                           |
|                         | `detoxify.ipynb`       | ..\data\[focal_subr_name]\ `[subr_name]_clean.csv`    | ..\data\[focal_subr_name]\ `[subr_name]_res.csv`           | 1. Get scores for each comments with detoxify model 2. Flag if the comment is harassment based on threshhol                                                                                                                            |
| 4. Regression           | `visual_RD.r`          | TBD                                                   | TBD                                                        | Visualizing Regression Discontinuity                                                                                                                                                                                                   |
|                         | `BSTS.r`               |                                                       |                                                            | 1. Group comments and score by date 2. Take average score for each date/ percentage of comments flagged as toxic in one day 3. Construct BSTS                                                                                          |


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

