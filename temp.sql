import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# 假设 m910 和 m910b 已经时间对齐并且 'start_time' 列是 datetime 类型

# 获取最近 24 小时的数据
end_time = max(m910['start_time'].max(), m910b['start_time'].max())
start_time = end_time - pd.Timedelta(hours=24)
m910_24h = m910[(m910['start_time'] >= start_time) & (m910['start_time'] <= end_time)]
m910b_24h = m910b[(m910b['start_time'] >= start_time) & (m910b['start_time'] <= end_time)]

# 创建一个超大尺寸的图表
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(60, 80))

# 自定义样式
plt.style.use('seaborn-whitegrid')
colors = ['#1f77b4', '#ff7f0e']  # 蓝色和橙色

# 绘制 average_peak_memory 的折线图
ax1.plot(m910_24h['start_time'], m910_24h['average_peak_memory'], label='m910', color=colors[0], marker='o', markersize=15, linewidth=4)
ax1.plot(m910b_24h['start_time'], m910b_24h['average_peak_memory'], label='m910b', color=colors[1], marker='s', markersize=15, linewidth=4)
ax1.set_xlabel('Start Time', fontsize=36)
ax1.set_ylabel('Average Peak Memory', fontsize=36)
ax1.set_title('Average Peak Memory Comparison (Last 24 Hours)', fontsize=48)
ax1.legend(fontsize=32)
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))
ax1.xaxis.set_major_locator(mdates.HourLocator(interval=1))
ax1.tick_params(axis='both', which='major', labelsize=28)
plt.setp(ax1.xaxis.get_majorticklabels(), rotation=45, ha='right')
ax1.grid(True, linestyle='--', alpha=0.7)

# 添加数据点标签
for i, txt in enumerate(m910_24h['average_peak_memory']):
    ax1.annotate(f'{txt:.2f}', (m910_24h['start_time'].iloc[i], txt), xytext=(0, 10), 
                 textcoords='offset points', ha='center', va='bottom', fontsize=20, color=colors[0])
for i, txt in enumerate(m910b_24h['average_peak_memory']):
    ax1.annotate(f'{txt:.2f}', (m910b_24h['start_time'].iloc[i], txt), xytext=(0, -10), 
                 textcoords='offset points', ha='center', va='top', fontsize=20, color=colors[1])

# 绘制 total_cpu_time 的折线图
ax2.plot(m910_24h['start_time'], m910_24h['total_cpu_time'], label='m910', color=colors[0], marker='o', markersize=15, linewidth=4)
ax2.plot(m910b_24h['start_time'], m910b_24h['total_cpu_time'], label='m910b', color=colors[1], marker='s', markersize=15, linewidth=4)
ax2.set_xlabel('Start Time', fontsize=36)
ax2.set_ylabel('Total CPU Time', fontsize=36)
ax2.set_title('Total CPU Time Comparison (Last 24 Hours)', fontsize=48)
ax2.legend(fontsize=32)
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))
ax2.xaxis.set_major_locator(mdates.HourLocator(interval=1))
ax2.tick_params(axis='both', which='major', labelsize=28)
plt.setp(ax2.xaxis.get_majorticklabels(), rotation=45, ha='right')
ax2.grid(True, linestyle='--', alpha=0.7)

# 添加数据点标签
for i, txt in enumerate(m910_24h['total_cpu_time']):
    ax2.annotate(f'{txt:.2f}', (m910_24h['start_time'].iloc[i], txt), xytext=(0, 10), 
                 textcoords='offset points', ha='center', va='bottom', fontsize=20, color=colors[0])
for i, txt in enumerate(m910b_24h['total_cpu_time']):
    ax2.annotate(f'{txt:.2f}', (m910b_24h['start_time'].iloc[i], txt), xytext=(0, -10), 
                 textcoords='offset points', ha='center', va='top', fontsize=20, color=colors[1])

plt.tight_layout()
plt.savefig('ultra_large_comparison_plot.png', dpi=300, bbox_inches='tight')
plt.close()

print("Ultra-large comparison plot has been saved as 'ultra_large_comparison_plot.png'")
print(f"Number of data points in m910 (last 24h): {len(m910_24h)}")
print(f"Number of data points in m910b (last 24h): {len(m910b_24h)}")
