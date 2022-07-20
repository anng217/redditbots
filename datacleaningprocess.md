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
|                          |     Oct   (Perc)    |     Nov   (Perc)    |     Difference    |     P-value         |
|--------------------------|---------------------|---------------------|-------------------|---------------------|
| **toxicity_flag**        | **23.40%**          | **22.01%**          | **-1.39%**        | **0.00140**         |
| **severe_toxicity_flag** | 0.0762%             | 0.0625%             | -0.01%            | 0.61401             |
| **obscene_flag**         | 14.72%              | 14.35%              | -0.37%            | 0.31422             |
| **threat_flag**          | 0.15%               | 0.16%               | 0.01%             | 0.64951             |
| **insult_flag**          | **7.16%**           | **6.15%**           | **-1.01%**        | **8.75518 x 10^-5** |
| **identity_attack_flag** | **0.3809%**         | **0.2384%**         | **-0.14%**        | **0.01091**         |


**About Unbiased Model:** A model that recognizes toxicity and minimizes this type of unintended bias with respect to mentions of identitied.

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

|                          | **Oct (Mean)** | **Nov (Mean)** | **Difference** | **P-value**          |
|--------------------------|----------------|----------------|----------------|----------------------|
| **toxicity_flag**        | 23.49%         | 23.03%         | -0.46%         | 0.3126               |
| **severe_toxicity_flag** | 8.92%          | 8.53%          | -0.39%         | 0.1985               |
| **obscene_flag**         | **14.18%**     | **13.75%**     | **-0.42%**     | **0.0269**           |
| **threat_flag**          | **0.20%**      | **7.40%**      | **7.2%**       | **2.2939 x 10^-215** |
| **insult_flag**          | **10.14%**     | **9.42%**      | **-0.72%**     | **0.02471**          |
| **identity_attack_flag** | **0.5%**       | **0.32%**      | **-0.18%**     | **0.0067**           |
| **sexual_explicit_flag** | 7.10%          | 7.26%          | 0.16%          | 0.5556               |

# Control Group
The problem with control group is that it could also be neighbor. So I explore these group first:

**Control/Neighbor**

| **Community**             | **Created Date**<br>*(Bot Date)* | **Before (Clean)** | **After (Clean)** |
|---------------------------|----------------------------------|--------------------|-------------------|
| **_Uses Bot Eventually_** |                                  |                    |                   |
| r/wgotw                   | May 21, 2014<br>*(Apr 29, 2021)* | NA                 |                   |
| r/WitchesVSPatriarchy     | Sep 27, 2018<br>*(Dec 22, 2020)* |                    |                   |
| r/exfds                   | Mar 14, 2020<br>*(Nov 23, 2020)* | NA                 |                   |
| **_Does not use bots_**   |                                  |                    |                   |
| r/TwoXChromosomes         | Jul 16, 2009                     | 67,713             | 69,252            |
| r/feminism                | Jan 10, 2009                     | 4,529              | 5,241             |
| **_Users overlap_**       |                                  |                    |                   |
| r/purplepilldebate        | Aug 22, 2013                     |                    |                   |
| r/datingoverthirty        | Nov 3, 2014                      |                    |                   |
| r/askwomenoverthirty      |                                  |                    |                   |
| **_Opposite Topic_**      |                                  |                    |                   |
| r/mgtow                   |                                  | 93,202             | 92,201            |
| r/TheRedPill              | Oct 25, 2012                     | 9,737              |  9,327            |

## r/feminism as Control for FDS
### Base line for average
|                     | **Oct (Mean)** | **Nov (Mean)** | **Difference** | **P-value** |
|---------------------|----------------|----------------|----------------|-------------|
| **toxicity**        | 0.1794         | 0.1680         | -0.0114        | 0.063       |
| **severe_toxicity** | 0.0088         | 0.0085         | -0.0003        | 0.733       |
| **obscene**         | 0.0891         | 0.0849         | -0.0042        | 0.379       |
| **threat**          | 0.0042         | 0.0038         | -0.0004        | 0.594       |
| **insult**          | 0.0516         | 0.0511         | -0.0005        | 0.879       |
| **identity_attack** | **0.0184**        | **0.1529**         | **0.1345**         | **0.029**       |

### Base line for percentage
|                     | **Oct (Mean)** | **Nov (Mean)** | **Difference** | **P-value** |
|---------------------|----------------|----------------|----------------|-------------|
| **toxicity**        | 0.162950       | 0.153433       | -0.95%         | 0.1988      |
| **severe_toxicity** | 0.001546       | 0.001343       | -0.02%         | 0.7918      |
| **obscene**         | 0.087437       | 0.079402       | -0.80%         | 0.1519      |
| **threat**          | 0.002208       | 0.001918       | -0.03%         | 0.7524      |
| **insult**          | 0.036653       | 0.036824       | 0.02%          | 0.1527      |
| **identity_attack** | **0.006403**   | **0.005754**   | **-0.06%**     | **0.0293**  |

## Unbiased Model for average
|                     | **Oct (Mean)** | **Nov (Mean)** | **Difference** | **P-value** |
|---------------------|----------------|----------------|----------------|-------------|
| **toxicity**        | 0.178182       | 0.171350       | -0.00683       | 0.2739      |
| **severe_toxicity** | 0.003853       | 0.003512       | -0.00683       | 0.4735      |
| **obscene**         | 0.076309       | 0.075908       | -0.00034       | 0.9316      |
| **threat**          | 0.032643       | 0.026996       | -0.0004        | 0.9361      |
| **insult**          | 0.073435       | 0.080117       | -0.0056        | 0.1061      |
| **identity_attack** | **0.004031**   | **0.003967**   | **0.006682**   | **0.0040**  |
| **sexual explicit** | 0.059691       | 0.049408       | -6.4E-05       | 0.9075      |

## Unbiased Model for percentage
|                     | **Oct (Mean)** | **Nov (Mean)** | **Difference** | **P-value** |
|---------------------|----------------|----------------|----------------|-------------|
| **toxicity**        | 15.99%         | 15.90%         | -0.09%         | 0.9075      |
| **severe_toxicity** | 0.044%         | 0.00%          | -0.04%         | 0.1291      |
| **obscene**         | 7.83%          | 7.90%          | 0.07%          | 0.9077      |
| **threat**          | 0.22%          | 0.21%          | -0.01%         | 0.9169      |
| **insult**          | 5.98%          | 6.66%          | 0.68%          | 0.1061      |
| **identity_attack** | **1.43%**      | **1.30%**      | **-0.13%**     | **0.0040**  |
| **sexual_implicit** | **5.23%**      | **4.09%**      | **-1.14%**     | **0.0071**  |

## r/TwoXChromosomes as Control for FDS

## Unbiased Model for average

|                     | **Oct (Mean)** | **Nov (Mean)** | **Difference** | **P-value**        |
|---------------------|----------------|----------------|----------------|--------------------|
| **toxicity**        | **0.18884**    |                |                | **9.052 x 10^-6**  |
| **severe_toxicity** | 0.00324        |                |                | 0.4934             |
| **obscene**         | 0.09652        |                |                | 0.7353             |
| **threat**          | **0.00482**    |                |                | **0.0002**         |
| **insult**          | 0.08227        |                |                | 0.8449             |
| **identity_attack** | **0.00840**    |                |                | **2.7 x 10^-5**    |
| **sexual_implicit** | **0.06349**    |                |                | **1.215 x 10^-30** |

## Unbiased Model for Percentage (Flag)


|                     | **Oct (Mean)** | **Nov (Mean)** | **Difference** | **P-value**        |
|---------------------|----------------|----------------|----------------|--------------------|
| **toxicity**        | **17.98%**     |                |                | **0.0007**         |
| **severe_toxicity** | 0.003%         |                |                | 0.4300             |
| **obscene**         | 10.02%         |                |                | 0.3381             |
| **threat**          | **0.26%**      |                |                | **0.0069**         |
| **insult**          | 6.98%          |                |                | 0.8449             |
| **identity_attack** | **0.25%**      |                |                | **2.707 x 10^-5**  |
| **sexual_implicit** | **5.67%**      |                |                | **8.586 x 10^-19** |

# Synthetic Control 

- Outcome: identity_attack of FDS before and after bot impplementation
- Covars: subscribers of FDS, identity_attack of r/feminism, r/WitchesVSPatriarchy, and r/TwoXChromosomes

**Average of Identity Attack**
![Average of Identity Attack](https://github.com/anng217/redditbots/blob/main/unb_identityattack_m_fds.png?raw=true)

**Precentage of Identity Attack Comments**
![Precentage of Identity Attack Comments](https://github.com/anng217/redditbots/blob/main/unb_identityattack_p_fds.png?raw=true)

# Next steps:
- Regression discontinuity for these control groups to see if the difference in toxicity/identity attack is robust.
- Explore different control communities: opposite communities, unrelated popular communities.
- Run with baseline model with current control groups and other posible control groups.
- Find examples to see how toxicity varies.
- Standardize outcome variables


