import csv
import datetime

with open('rafinacja/all-mastodon.csv','r',encoding="utf8") as f:
	data=csv.reader(f, delimiter=',')
	data=list(data)[1:]

print(len(data), len(data[1]), data[0])

# zbiór dat
start = datetime.datetime.strptime("2022-11-11", "%Y-%m-%d")
end = datetime.datetime.strptime("2023-05-12", "%Y-%m-%d")
date_generated = [start + datetime.timedelta(days=x) for x in range(0, (end-start).days)]
date_generated=[date.strftime("%Y-%m-%d") for date in date_generated]
print(date_generated, len(date_generated))


# poprawka tabeli
data=list(zip(*data))
data=data[1:]
instances=list(set(data[0]))
print(len(instances))
data=list(zip(*data))

data2={}


# sprawdzam dla każdej instancji i każdego dnia badania, czy istniała, jeśli tak, przypisuję grupę wielkości wg liczby użytkowników
# 0 - brak danych
# 1 - 0-1
# 2 - 2-10
# 3 - 11-100
# 4 - 101-1000
# 5 - 1001-10000
# 6 - 10000+

total=len(instances)
for n,i in enumerate(instances):
	print(f'{n}\t{total}\nchecking {i}')
	records=[d for d in data if d[0]==i]
	data2[i]=[]
	for date in date_generated:
		found=0
		for r in records:
			if r[1]==date:
				found=1
				data2[i].append(int(r[2]))
				break
		if not found:
			data2[i].append(0)
	print(set(data2[i]))


## dla bezpieczeństwa zapis do CSV zakomentowany, żeby nie nadpisać istniejących danych
# with open('rafinacja/dane-dzien-instancja.csv', 'w', encoding='UTF8', newline='') as f:
# 	writer = csv.writer(f)
# 	header=['instance']+date_generated
# 	writer.writerow(header)
# 	for d in data2:
# 		row=[d]+data2[d]
# 		writer.writerow(row)