import urllib
import os
import time
from datetime import datetime
from datetime import timedelta
from time import mktime
import sys
import wget
import string
from collections import defaultdict

# config
start = "2009-07-20-00:00"
stop = "2010-12-26-23:30"
myfile = "temperature.csv"


# number of 30-minute slots
date_start = datetime.strptime(start, "%Y-%m-%d-%H:%M")
date_stop = datetime.strptime(stop, "%Y-%m-%d-%H:%M")
delta = date_stop - date_start
num_slots = int(48 * delta.days + delta.seconds / (60*30))

# For each slot: read file, extract temperature, save to CSV file
tmpdict = defaultdict(int)
previous_temperature = (10.0 + 11.0 + 13.0) / 3
fid = open(myfile, 'w')
fid.write('Time, Temperature\n')
# for x in range(0, 100):
for x in range(0, num_slots):

	time_to_query = date_start + timedelta(seconds=x*30*60)
	filename = "html/" + time_to_query.strftime("%Y-%m-%d-%H:%M")
	f = open(filename)
	text = f.read()

	date_and_time = time_to_query.strftime("%Y-%m-%d-%H:%M")
	print("\n" + date_and_time)
	
	# check if the three main stations (cork, dublin airport, shannon) appear.
	# if so: use their average
	# if not: use last known value.
	start_idx = 0
	cities_found = 0
	average_temperature = 0
	
	while (1):

		# find city in string
		item = "&amp;LANG=en&amp;LEVEL=140&SI=kph&CEL=C\">"
		temp = text.find(item, start_idx)
		if (temp == -1):
			break;
		city_start = temp + len(item)
		item = "</a>"
		city_stop = text.find(item, city_start)
		city = text[city_start:city_stop]	

		# find temperature in string
		item = "<td>"
		temperature_start = text.find(item, city_stop) + len(item)
		item = "&deg;C"
		temperature_stop = text.find(item, temperature_start)
		temperature = text[temperature_start:temperature_stop]

		# check if one of the three main weather stations was found
		if (city.find("Cork-Corcaigh (162 m)") != -1 or
			city.find("Dublin Airport (85 m)") != -1 or
			city.find("Shannon (20 m)") != -1):
			cities_found = cities_found + 1
			average_temperature = average_temperature + float(temperature)
	
		print city + " -" + temperature

		start_idx = temperature_stop
		
		tmpdict[city] = tmpdict[city]+1

 	print "Cities_found: " + str(cities_found)
	if (cities_found == 3):
		average_temperature = average_temperature / 3
		previous_temperature = average_temperature
		print "Average temperature: " + str(average_temperature)
	else:
		average_temperature = previous_temperature
		print "Using previous temperature: " + str(average_temperature)
	
	# write average temperature to CSV file
	string_to_write = date_and_time + "," + str(average_temperature) + "\n"
	fid.write(string_to_write)	
	
print(" ")
print tmpdict
fid.close()
print("\nStored results in " + myfile + "\n")
sys.exit()
