import csv
with open('rafinacja/all.csv','r',encoding="utf8") as f:
	data=csv.reader(f, delimiter=',')
	data=list(data)[1:]
# rozmiar pełnego zbioru danych przed rafinacją
print(len(data), len(data[1]), data[1])