import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# 假设 m910 和 m910b 已经时间对齐并且 'start_time' 列是 datetime 类型

# 获取最近 24 小时的数据
end_time = max(m910['start_time'].max(), m910b['start_time'].max())
start_time = end_time - pd.Timedelta(hours=24)
m910_24h = m910[(m910['start_time'] >= start_time) & (m910['start_time'] <= end_time)]
m910b_24h = m910b[(m910b['start_time'] >= start_time) & (m910b['start_time'] <= end_time)]

# 创建一个大尺寸的图表
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(20, 24))

# 自定义样式
plt.style.use('seaborn')
colors = ['#1f77b4', '#ff7f0e']  # 蓝色和橙色

# 绘制 average_peak_memory 的折线图
ax1.plot(m910_24h['start_time'], m910_24h['average_peak_memory'], label='m910', color=colors[0], marker='o', markersize=8, linewidth=2)
ax1.plot(m910b_24h['start_time'], m910b_24h['average_peak_memory'], label='m910b', color=colors[1], marker='s', markersize=8, linewidth=2)
ax1.set_xlabel('Start Time', fontsize=14)
ax1.set_ylabel('Average Peak Memory', fontsize=14)
ax1.set_title('Average Peak Memory Comparison (Last 24 Hours)', fontsize=18)
ax1.legend(fontsize=12)
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))
ax1.xaxis.set_major_locator(mdates.HourLocator(interval=2))
ax1.tick_params(axis='both', which='major', labelsize=12)
plt.setp(ax1.xaxis.get_majorticklabels(), rotation=45, ha='right')
ax1.grid(True, linestyle='--', alpha=0.7)

# 绘制 total_cpu_time 的折线图
ax2.plot(m910_24h['start_time'], m910_24h['total_cpu_time'], label='m910', color=colors[0], marker='o', markersize=8, linewidth=2)
ax2.plot(m910b_24h['start_time'], m910b_24h['total_cpu_time'], label='m910b', color=colors[1], marker='s', markersize=8, linewidth=2)
ax2.set_xlabel('Start Time', fontsize=14)
ax2.set_ylabel('Total CPU Time', fontsize=14)
ax2.set_title('Total CPU Time Comparison (Last 24 Hours)', fontsize=18)
ax2.legend(fontsize=12)
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))
ax2.xaxis.set_major_locator(mdates.HourLocator(interval=2))
ax2.tick_params(axis='both', which='major', labelsize=12)
plt.setp(ax2.xaxis.get_majorticklabels(), rotation=45, ha='right')
ax2.grid(True, linestyle='--', alpha=0.7)

plt.tight_layout()
plt.show()

# 打印数据点数量
print(f"Number of data points in m910 (last 24h): {len(m910_24h)}")
print(f"Number of data points in m910b (last 24h): {len(m910b_24h)}")
