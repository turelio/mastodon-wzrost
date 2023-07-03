import csv
from itertools import groupby

with open('rafinacja/dane-dzien-instancje.csv','r',encoding="utf8") as f:
	data=csv.reader(f, delimiter=',')
	data=list(data)[1:]

#print(len(data), len(data[1]), data[0])

data2={}
for i in data:
	entry={}
	instance=i[0]
	x=i[1:]
	x=[int(x1) for x1 in x]
	entry['host']=instance
	entry['raw']=x

# existed at start
	if x[0]==0:
		entry['at_start']=0
	else:
		entry['at_start']=1

# existed at end
	if x[-1]==0:
		entry['at_end']=0
	else:
		entry['at_end']=1

# existed throughout
	if entry['at_start'] == 1 and entry['at_end'] == 1:
		entry['duration']='start2end'
	elif entry['at_start'] == 0 and entry['at_end'] == 1:
		entry['duration']='mid2end'
	elif entry['at_start'] == 1 and entry['at_end'] == 0:
		entry['duration']='start2mid'
	elif entry['at_start'] == 0 and entry['at_end'] == 0:
		entry['duration']='mid2mid'
	else:
		entry['duration']='error'

# duplikaty, usuwanie zer
	x_nonull=[x1 for x1 in x if x1>0]
	x_set=list(set(x_nonull))
	x_nodup=[k for k, g in groupby(x_nonull)]
	# print(x_set, x_nodup)
	entry['group_change']=x_nodup
	data2[i[0]]=entry


growth=[]
for k in data2:
	growth.append(data2[k]['group_change'])

growth=[f'{g[0]}->{g[-1]}' for g in growth]
# growth=[str(g) for g in growth]
g_unique=list(set(growth))

g_count=[]
for g in g_unique:
	n=growth.count(g)
	# print(g,'=>',n)
	g_count.append([g,n])

g_count=list(sorted(g_count,key=lambda l:l[1], reverse=True))
print(len(growth), len(set(growth)))
	

duration=[]
for k in data2:
	duration.append(data2[k]['duration'])

d_count=[]
for d in set(duration):
	n=duration.count(d)
	# print(g,'=>',n)
	d_count.append([d,n])

d_count=list(sorted(d_count,key=lambda l:l[1], reverse=True))
print("\ngroup\tcount")
for g in g_count:
	print(g[0],'\t',g[1])

print("\nduration\tcount")
for d in d_count:
	print(d[0],'\t',d[1])
