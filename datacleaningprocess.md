# Data Cleaning Process
With respect to detoxify.ipynb

- For Comments: Cleaning comments by removing all the `author` = 'AutoModerator', all the `body` = '[removed]' or `body` = '[deleted]'
- For Submissions: Cleaning submissions by removing all contents that has no content (`selftext` is null), all the `selftext` is  = '[removed]' or `selftext` = '[deleted]'


| No. | Community              | Type        | Before (Orig.) | Before (Clean)              | After (Orig.) | After (Clean)              | Bot Date      |
|-----|------------------------|-------------|----------------|-----------------------------|---------------|----------------------------|---------------|
| 1   | r/femaledatingstrategy | Comments    | 16,028         | 13,485                      | 31,357        | 23,149                     | Oct 28, 2019  |
|     |                        | Submissions | 894            | 432 (Text)<br>159(Images)   | 1901          | 596 (Text)<br>432 (Images) |               |
| 2   | r/women                | Comments    | 271            | 214                         | 201           | 154                        | June 27, 2016 |
|     |                        | Submissions | 550            | 15 (Text)<br>11 (Images)    | 682           | 11 (Text)<br>7 (Images)    |               |
| 3   | r/feminisms            | Comments    | 1,288          | 906                         | 1,152         | 899                        | Mar 17, 2012  |
|     |                        | Submissions | 328            | 19 (Text)<br>4 (Images)     | 244           | 16 (Text)<br>5 (Images)    |               |
| 4   | r/wgtow                | Comments    | 842            | 763                         | 1,285         | 1164                       | Apr 29, 2021  |
|     |                        | Submissions | 87             | 34 (Text)<br>7 (Images)     | 135           | 61 (Text)<br>22 (Images)   |               |
| 5   | r/WitchesVSPatriarchy  | Comments    | 23,015         | 15,610                      | 20,879        | 20,879                     | Dec 22, 2020  |
|     |                        | Submissions | 1,664          | 238(Text)<br>1,004 (Images) | 1,411         | 175 (Text)<br>894 (Images) |               |
| 6   | r/exfds                | Comments    | 468            | 452                         | 132           | 127                        | Nov 23, 2020  |
|     |                        | Submissions | 32             | 15 (Text)<br>10 (Images)    | 12            | 20 (Text)<br>3 (Images)    |               |


# Female Dating Strategy Toxicity

## Baseline model for average

|                           |     Oct   (Mean)    |     Nov   (Mean)    |     Difference    |     P-value            |
|---------------------------|---------------------|---------------------|-------------------|------------------------|
|     **toxicity**              |     **0.247975**        |    **0.234422**        |     **-0.013553**     |     **0.00016**            |
|     **severe_toxicity**       |     **0.011171**        |     **0.010200**        |     **-0.000971**     |     **0.02618**            |
|     obscene               |     0.144904        |     0.141388        |     -0.003516     |     0.24838            |
|     threat                |     0.003408        |     0.003919        |     0.000511      |     0.14367            |
|     **insult**                |     **0.003408**        |     **0.080094**        |     **0.076686**      |     **7.95982 x 10^-6**    |
|     **identity_attack**       |     **0.012623**        |     **0.009663**        |     **-0.00296**      |     **8.65267 x 10^-9**    |

## Baseline Model - Percentage of comments flagged


## Unbiased Model for average
|                           |     Oct   (Mean)    |     Nov   (Mean)    |     Difference    |     P-value     |
|---------------------------|---------------------|---------------------|-------------------|-----------------|
|     toxicity              | 0.239328            | 0.233624            | -0.005704         | 0.13658         |
|     **severe_toxicity**       | **0.005412**            | **0.004703**            | **-0.000709**         | **0.00350**         |
|     obscene               | 0.133117            | 0.131320            | -0.001797         | 0.056481        |
|     threat                | 0.003724            | 0.004406            | 0.000682          | 0.108916        |
|     **insult**                | **0.118515**            | **0.110362**            | **-0.00812**          | **7.95982 x 10^-6** |
|     **identity_attack**       | **0.016930**            | **0.013421**            | **-0.00351**          | **8.65267 x 10^-9** |
| sexual explicit           | 0.078196            | 0.078861            | 0.000665          | 0.76770         |


## Unbiased Model - Percentage of comments flagged

|                        |     Oct   (Mean)    |     Nov   (Mean)    |     Difference    |     P-value      |
|------------------------|---------------------|---------------------|-------------------|------------------|
| toxicity_flag          | 23.49%              | 23.03%              | -0.46%            | 0.3126           |
| severe_toxicity_flag   | 8.92%               | 8.53%               | -0.39%            | 0.1985           |
| **obscene_flag           | 14.18%              | 13.75%              | -0.42%            | 0.0269**           |
| **threat_flag            | 0.20%               | 7.40%               | 7.2%              | 2.2939 x 10^-215** |
| **insult_flag            | 10.14%              | 9.42%               | -0.72%            | 0.02471**          |
| **identity_attack_flag   | 0.5%                | 0.32%               | -0.18%            | 0.0067**           |
| sexual_explicit_flag   | 7.10%               | 7.26%               | 0.16%             | 0.5556           |

# Control Group
The problem with control group is that it could also be neighbor. So I explore these group first:

**Control/Neighbor suspects**
r/