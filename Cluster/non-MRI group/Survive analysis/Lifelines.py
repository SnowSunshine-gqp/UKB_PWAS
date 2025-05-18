import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from lifelines import KaplanMeierFitter, CoxPHFitter
from lifelines.statistics import logrank_test, multivariate_logrank_test

Preject_path= 'Work_path/'

dir_path = Preject_path + 'Cluster/non-MRI group/Survive analysis/Diseases_KM_collect/'
save_fig_path = Preject_path + 'Cluster/non-MRI group/Survive analysis/KM_Figure/'
save_stats_path = Preject_path + 'Cluster/non-MRI group/Survive analysis/stats/'

Disease_name = ["ACD", "ACS", "AXT", "BP", "MDD", "MS", "PD", "SCZ"]
Complete_Disease_name = ["All cause dementia", "All cause stroke", "Anxiety disorder", "Bipolar disorder",
                         "Major depressive disorder", "Multiple sclerosis", "Parkinson's disease", "Schizophrenia"]
for n in range(0, len(Disease_name)):
    item = Disease_name[n]
    # 指定CSV文件的路径
    file_path = dir_path + item + '_KM.csv'
    # 使用read_csv()函数读取CSV文件
    df = pd.read_csv(file_path)

    temp_stats_path = save_stats_path + item + '.xlsx'
    Cox_data = df[['Duration', 'Event_label', 'sex', 'age', 'Asian', 'Black', 'Other', 'Group_label']]
    #
    cph = CoxPHFitter()
    cph.fit(Cox_data, 'Duration', 'Event_label')
    A = cph.summary
    A.to_excel(temp_stats_path, index=True)
    test_statistic = A['exp(coef)']['Group_label']
    upper = A["exp(coef) upper 95%"]['Group_label']
    lower = A['exp(coef) lower 95%']['Group_label']
    p_value = A['p']['Group_label']

    #
    T = df['Duration']
    E = df['Event_label']
    indx = df['Group_label'] == 1

    # 设置图形窗口的大小
    plt.figure(figsize=(10, 8))  # 你可以根据需要调整这里的数值
    start_time = 0
    end_time = max(T)

    kmf = KaplanMeierFitter()
    kmf.fit(T[indx], E[indx], timeline=np.linspace(start_time, end_time, num=501), label='Subgroup 1')
    ax = kmf.plot_survival_function(color='red', legend=False)  # 设置legend=False以隐藏图例

    kmf.fit(T[~indx], E[~indx], timeline=np.linspace(start_time, end_time, num=501), label='Subgroup 2')
    ax = kmf.plot_survival_function(ax=ax, color='green', legend=False)
    # 添加标题和保存图像
    plt.title(f'{Complete_Disease_name[n]}',  # 添加标题
              fontsize=30)
    #plt.xlabel('Time (year)', fontsize=14, color='black')  # 添加x轴标签
    #plt.ylabel('Survival Probability', fontsize=14, color='black')  # 添加y轴标签
    plt.legend(fontsize=24)  # 显示图例
    #plt.grid(True)  # 显示网格
    # 设置x轴和y轴的标签文字
    ax.tick_params(axis='x', labelsize=20, labelcolor='black')
    ax.tick_params(axis='y', labelsize=20, labelcolor='black')
    ax.set_xlabel('', fontsize=24, color='black')  # 设置x轴标签并指定颜色
    #ax.set_ylabel('Survival Probability', fontsize=14, color='black')  # 设置y轴标签并指定颜色

    # 在左下角添加显著性信息
    plt.text(0.05, 0.05, f'HR = {test_statistic:.2f} (95% CI={lower:.2f}-{upper:.2f});\np = {p_value:.1g}', fontsize=24, transform=ax.transAxes)
    # 保存图像
    temp_fig_path = save_fig_path + item + '_survival_curve.png'  # 指定保存图像的路径
    plt.savefig(temp_fig_path)  # 保存图像

    # 显示图像
    plt.show()

# 注意：在循环结束后，确保关闭图形界面，以避免资源占用
plt.close('all')
