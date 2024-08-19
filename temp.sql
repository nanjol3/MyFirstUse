import pandas as pd
import matplotlib.pyplot as plt

def process_dataframe(df, name):
    # 确保 'start_time' 列是 datetime 类型
    df['start_time'] = pd.to_datetime(df['start_time'])
    
    # 创建 30 分钟的时间组
    df['time_group'] = df['start_time'].dt.floor('30T')
    
    # 按时间组分组并计算平均值
    df_30min = df.groupby('time_group').agg({
        'average_peak_memory': 'mean',
        'total_cpu_time': 'mean'
    }).reset_index()
    
    # 创建包含两个指标的列表
    result_list = df_30min[['average_peak_memory', 'total_cpu_time']].values.tolist()
    
    print(f"Number of 30-minute windows in {name}: {len(result_list)}")
    
    return result_list, df_30min

# 处理 m910 数据
m910_30min, m910_30min_df = process_dataframe(m910, 'm910')

# 处理 m910b 数据
m910b_30min, m910b_30min_df = process_dataframe(m910b, 'm910b')

# 打印前几个结果作为示例
print("\nFirst few entries of m910_30min:")
for i, entry in enumerate(m910_30min[:5]):
    print(f"Window {i+1}: Avg Peak Memory = {entry[0]:.2f}, Total CPU Time = {entry[1]:.2f}")

print("\nFirst few entries of m910b_30min:")
for i, entry in enumerate(m910b_30min[:5]):
    print(f"Window {i+1}: Avg Peak Memory = {entry[0]:.2f}, Total CPU Time = {entry[1]:.2f}")

# 可视化结果
def plot_30min_data(df_30min, title):
    plt.figure(figsize=(12, 6))
    plt.plot(df_30min['time_group'], df_30min['average_peak_memory'], label='Avg Peak Memory')
    plt.plot(df_30min['time_group'], df_30min['total_cpu_time'], label='Total CPU Time')
    plt.title(f'{title} - Non-overlapping 30 Minute Window Analysis')
    plt.xlabel('Time')
    plt.ylabel('Values')
    plt.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

plot_30min_data(m910_30min_df, 'm910')
plot_30min_data(m910b_30min_df, 'm910b')
