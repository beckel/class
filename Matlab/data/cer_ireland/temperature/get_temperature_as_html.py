import urllib
import os
import time
from datetime import datetime
from datetime import timedelta
from time import mktime
import sys
import wget

start = "2010-09-28-14:00"
stop = "2010-12-26-23:30"

os.environ['TZ'] = 'Europe/London'
time.tzset()

date_start = datetime.strptime(start, "%Y-%m-%d-%H:%M")
date_stop = datetime.strptime(stop, "%Y-%m-%d-%H:%M")

# number of 30-minute slots
delta = date_stop - date_start
num_slots = int(48 * delta.days + delta.seconds / (60*30))


a = open('commands_new_2.txt', 'w')
a.write('#!/bin/bash\n\n')
for x in range(0,num_slots):
	a.write('sleep 1\n')

	time_to_query = date_start + timedelta(seconds=x*30*60)
	timestamp = int(mktime(time_to_query.timetuple()))
	
	filename = "out/" + time_to_query.strftime('%Y-%m-%d-%H:%M')
	url = "http://www.weatheronline.co.uk/weather/maps/current?LANG=en&DATE=" + str(timestamp) + "&CONT=euro&LAND=IE&KEY=IE&SORT=2&UD=0&INT=06&TYP=wetter&ART=tabelle&RUBRIK=akt&R=310&CEL=C&SI=kph"

	command = "wget -O " + filename + " '" + url + "'"
	a.write(command + '\n')
	
a.close()
