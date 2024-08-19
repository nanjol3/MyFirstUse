import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates

# 确保 start_time 列是 datetime 类型
m910['start_time'] = pd.to_datetime(m910['start_time'])
m910b['start_time'] = pd.to_datetime(m910b['start_time'])

# 获取最近 24 小时的数据
end_time = max(m910['start_time'].max(), m910b['start_time'].max())
start_time = end_time - pd.Timedelta(hours=24)
m910_24h = m910[(m910['start_time'] >= start_time) & (m910['start_time'] <= end_time)]
m910b_24h = m910b[(m910b['start_time'] >= start_time) & (m910b['start_time'] <= end_time)]

# 创建两个子图
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 16))

# 绘制 average_peak_memory 的折线图
ax1.plot(m910_24h['start_time'], m910_24h['average_peak_memory'], label='m910')
ax1.plot(m910b_24h['start_time'], m910b_24h['average_peak_memory'], label='m910b')
ax1.set_xlabel('Start Time')
ax1.set_ylabel('Average Peak Memory')
ax1.set_title('Average Peak Memory Comparison')
ax1.legend()
ax1.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))
ax1.xaxis.set_major_locator(mdates.HourLocator(interval=4))
plt.setp(ax1.xaxis.get_majorticklabels(), rotation=45, ha='right')

# 绘制 total_cpu_time 的折线图
ax2.plot(m910_24h['start_time'], m910_24h['total_cpu_time'], label='m910')
ax2.plot(m910b_24h['start_time'], m910b_24h['total_cpu_time'], label='m910b')
ax2.set_xlabel('Start Time')
ax2.set_ylabel('Total CPU Time')
ax2.set_title('Total CPU Time Comparison')
ax2.legend()
ax2.xaxis.set_major_formatter(mdates.DateFormatter('%Y-%m-%d %H:%M'))
ax2.xaxis.set_major_locator(mdates.HourLocator(interval=4))
plt.setp(ax2.xaxis.get_majorticklabels(), rotation=45, ha='right')

plt.tight_layout()
plt.show()
