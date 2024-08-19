import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

def process_dataframe(df, name, start_time, end_time):
    # 确保 'start_time' 列是 datetime 类型
    df['start_time'] = pd.to_datetime(df['start_time'])
    
    # 筛选共同时间范围内的数据
    df = df[(df['start_time'] >= start_time) & (df['start_time'] <= end_time)]
    
    # 创建 30 分钟的时间组
    df['time_group'] = df['start_time'].dt.floor('30T')
    
    # 按时间组分组并计算平均值
    df_30min = df.groupby('time_group').agg({
        'average_peak_memory': 'mean',
        'total_cpu_time': 'mean'
    }).reset_index()
    
    print(f"Number of 30-minute windows in {name}: {len(df_30min)}")
    
    return df_30min

# 确定共同的时间范围
start_time = max(m910['start_time'].min(), m910b['start_time'].min())
end_time = min(m910['start_time'].max(), m910b['start_time'].max())

print(f"Common time range: from {start_time} to {end_time}")

# 处理 m910 和 m910b 数据
m910_30min = process_dataframe(m910, 'm910', start_time, end_time)
m910b_30min = process_dataframe(m910b, 'm910b', start_time, end_time)

# 创建比较图
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(15, 12))

# 设置 x 轴格式
date_form = mdates.DateFormatter("%Y-%m-%d %H:%M")

# 绘制 Average Peak Memory 对比图
ax1.plot(m910_30min['time_group'], m910_30min['average_peak_memory'], label='m910', marker='o', markersize=4)
ax1.plot(m910b_30min['time_group'], m910b_30min['average_peak_memory'], label='m910b', marker='s', markersize=4)
ax1.set_title('Average Peak Memory Comparison')
ax1.set_xlabel('Time')
ax1.set_ylabel('Average Peak Memory')
ax1.legend()
ax1.xaxis.set_major_formatter(date_form)
ax1.grid(True)

# 绘制 Total CPU Time 对比图
ax2.plot(m910_30min['time_group'], m910_30min['total_cpu_time'], label='m910', marker='o', markersize=4)
ax2.plot(m910b_30min['time_group'], m910b_30min['total_cpu_time'], label='m910b', marker='s', markersize=4)
ax2.set_title('Total CPU Time Comparison')
ax2.set_xlabel('Time')
ax2.set_ylabel('Total CPU Time')
ax2.legend()
ax2.xaxis.set_major_formatter(date_form)
ax2.grid(True)

plt.tight_layout()
plt.show()

# 打印一些统计信息
print("\nAverage Peak Memory Statistics:")
print(f"m910 mean: {m910_30min['average_peak_memory'].mean():.2f}")
print(f"m910b mean: {m910b_30min['average_peak_memory'].mean():.2f}")
print(f"Difference: {m910_30min['average_peak_memory'].mean() - m910b_30min['average_peak_memory'].mean():.2f}")

print("\nTotal CPU Time Statistics:")
print(f"m910 mean: {m910_30min['total_cpu_time'].mean():.2f}")
print(f"m910b mean: {m910b_30min['total_cpu_time'].mean():.2f}")
print(f"Difference: {m910_30min['total_cpu_time'].mean() - m910b_30min['total_cpu_time'].mean():.2f}")
