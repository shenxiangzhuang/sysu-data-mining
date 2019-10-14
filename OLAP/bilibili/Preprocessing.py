import pandas as pd
from sqlalchemy import create_engine

# read source data
data = pd.read_csv('BilibiliGaomu.csv')

# datetime format
data.ctime = pd.to_datetime(data.ctime, infer_datetime_format=True)
# month col
data['month'] = data.ctime.apply(lambda date: date.month)
# word nums
data['wordnum'] = data.content.apply(lambda text: len(text))

# new dataframe
df = data[['gender', 'username', 'likes', 'wordnum', 'month']]
df.columns = ['sex', 'username', 'likes', 'wordnum', 'month']
df.to_csv('data.csv', index=None)


# to sqlite
e = create_engine('sqlite:///data.sqlite', encoding='utf8')
df.to_sql(name='Gaomu', con=e)
