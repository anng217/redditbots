# Data Cleaning Process
With respect to detoxify.ipynb

## Comments
Cleaning comments by removing all the `author` = 'AutoModerator', all the `body` = '[removed]' or `body` = '[deleted]'

| Community   | Before (Origin) | Before (Clean) | After (Origin) | After (Clean) | Before-After Period|
|-------------|-----------------|----------------|----------------|---------------|--------------------|
| r/femaledatingstrategy| 15,823 | 13,354        | 32,373         | 24,038        |  Oct-Nov           |

## Submission
Cleaning submissions by removing all contents that has no content (`selftext` is null), and content is 

| Community   | Before (Origin) | Before (Clean) | After (Origin) | After (Clean) | Before-After Period|
|-------------|-----------------|----------------|----------------|---------------|--------------------|
| r/femaledatingstrategy| 3,397 | 2,128          | XXXXXX        | XXXXXX       |  Oct-Nov           |

# Female Dating Strategy Toxicity

## Baseline model for average

|                           |     Oct   (Mean)    |     Nov   (Mean)    |     Difference    |     P-value            |
|---------------------------|---------------------|---------------------|-------------------|------------------------|
|     toxicity              |     0.247975        |     0.234422        |     -0.013553     |     0.00016            |
|     severe_toxicity       |     0.011171        |     0.010200        |     -0.000971     |     0.02618            |
|     obscene               |     0.144904        |     0.141388        |     -0.003516     |     0.24838            |
|     threat                |     0.003408        |     0.003919        |     0.000511      |     0.14367            |
|     insult                |     0.003408        |     0.080094        |     0.076686      |     7.95982 x 10^-6    |
|     identity_attack       |     0.012623        |     0.009663        |     -0.00296      |     8.65267 x 10^-9    |

## Baseline Model - Percentage of comments flagged


## Unbiased Model for average
|                           |     Oct   (Mean)    |     Nov   (Mean)    |     Difference    |     P-value     |
|---------------------------|---------------------|---------------------|-------------------|-----------------|
|     toxicity              | 0.239328            | 0.233624            | -0.005704         | 0.13658         |
|     severe_toxicity       | 0.005412            | 0.004703            | -0.000709         | 0.00350         |
|     obscene               | 0.133117            | 0.131320            | -0.001797         | 0.056481        |
|     threat                | 0.003724            | 0.004406            | 0.000682          | 0.108916        |
|     insult                | 0.118515            | 0.110362            | -0.00812          | 7.95982 x 10^-6 |
|     identity_attack       | 0.016930            | 0.013421            | -0.00351          | 8.65267 x 10^-9 |
| sexual explicit           | 0.078196            | 0.078861            | 0.000665          | 0.76770         |


## Unbiased Model - Percentage of comments flagged

|                        |     Oct   (Mean)    |     Nov   (Mean)    |     Difference    |     P-value      |
|------------------------|---------------------|---------------------|-------------------|------------------|
| toxicity_flag          | 23.49%              | 23.03%              | -0.00460          | 0.3126           |
| severe_toxicity_flag   | 8.92%               | 0.47%               | -0.08448          | 0.1985           |
| obscene_flag           | 1.42%               | 13.75%              | -0.00418          | 0.0269           |
| threat_flag            | 0.20%               | 7.40%               | 0.072027          | 2.2939 x 10^-215 |
| insult_flag            | 0.101393            | 0.094226            | -0.00716          | 0.02471          |
| identity_attack_flag   | 0.005017            | 0.003203            | -0.00181          | 0.0067           |
| sexual_explicit_flag   | 0.070990            | 0.072635            | 0.001645          | 0.5556           |