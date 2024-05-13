# An-Improved-DRM-with-SSR-for-Continuous-BP-Estimation

## Dataset

* Public dataset: In this project, data from the MIMIC-II dataset is applied. The data can be downloaded from the link (https://archive.ics.uci.edu/dataset/340/cuff+less+blood+pressure+estimation).
* Multi-day BP dataset: The dataset used in this study is a personal dataset consisting of recordings obtained from 12 healthy subjects, comprising 11 males and 1 female. (Data not publicly available at this time)

## Feature Extraction

The feature extraction part is done based on MatLab. 

* BP_annotate.m is used to calculate features from BP signals.
* PPG_annotate.m is used to calculate features from PPG signals.
* Extract_feature.m and Extract_feature_withnoise.m are used to extract features without and with random noise.
* loop_features.m is used to extract features for all signals.
* finaldouble_check.m, finaldouble_check2.m, double_check.m and ECG_check.m are used to check whether extracted features are suitable.

## Feature Voting System

In this project, 8 feature selection methods will be used, which are named ReliefF feature selection (ReliefF), correlation-based feature selection (CFS), mutual information method (MI), neighborhood component analysis (NCA), features for classification using minimum redundancy maximum relevance(FSCMRMR), recursive feature elimination (RFE), variance thresholding (VT), and relativity analysis (RA).

## Deep RNN Model

* Run if you want to change the number of training times to k. The default is 10,000 times
  ```sh
  python main_all.py --num_train_steps k
  ```
* If data is changed, first run
 ```sh
  python main_all.py --stage preprocess
  ```
* Then run
 ```sh
  python main_all.py
  python main_all.py --stage test
  ```
