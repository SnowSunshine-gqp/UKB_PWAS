import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from lifelines import KaplanMeierFitter, CoxPHFitter
from lifelines.statistics import logrank_test, multivariate_logrank_test

Preject_path = 'Work_path'
dir_path = Preject_path + 'Cluster/non-MRI group/Survive analysis/Diseases_KM_collect/'
save_stats_path = Preject_path + 'Domain analysis/Weight_score/stats/'

Region_name = ["Total volume", "Cortical volume", "Subcortical volume"]
Disease_name = ["ACD", "ACS", "AXT", "BP", "MDD", "MS", "PD", "SCZ"]

for k in range(0, len(Region_name)):
    file_path = Preject_path + 'Joint association/Weight_score/' + Region_name[k] + ' Weight Score.csv'
    Weight_score = pd.read_csv(file_path)
    for n in range(0, len(Disease_name)):
        item = Disease_name[n]
        file_path = dir_path + item + '_KM.csv'
        df = pd.read_csv(file_path)
        matched_df = pd.merge(Weight_score, df, on='eid', how='inner')
        count_total = sum((matched_df['Event_label'] == 1))
        count_up = sum((matched_df['Event_label'] == 1) & (matched_df['Favourable'] == 1))
        count_mid = sum((matched_df['Event_label'] == 1) & (matched_df['Intermediate'] == 1))
        count_low = sum((matched_df['Event_label'] == 1) & (matched_df['Favourable'] == 0) & (matched_df['Intermediate'] == 0))
        print("{5}-{0}: total = {1}, n_up = {2}, n_mid = {3}, n_low = {4}, ".format(item, count_total, count_up, count_mid, count_low, Region_name[k]))
        temp_stats_path = save_stats_path + Region_name[k] + '/' + item + '.xlsx'
        Cox_data = matched_df[['Duration', 'Event_label', 'sex', 'age', 'Asian', 'Black', 'Other', 'Favourable', 'Intermediate']]
        #
        cph = CoxPHFitter()
        cph.fit(Cox_data, 'Duration', 'Event_label')
        A = cph.summary
        A.to_excel(temp_stats_path, index=True)
