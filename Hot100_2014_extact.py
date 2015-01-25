import pandas as pd
import os
import urllib2
from urllib2 import urlopen
import re

path = '/Users/hparsa/data_projects/python/Music_python/Ranks/'
df=[]
Row=1
#Stop words to excract the first singer if there are multiple
stopWords = ["featuring", ",", " and ", "&", "/", "with", "feat." , "featuing", "+", "featruing", " X ", "ft."]
def get_ranks():
    df = pd.DataFrame(columns = ["row",
                                 "rowId",
                                 "weekDate",
                                 "pos",
                                 "singer",
                                 "song",
                                 "lastPos",
                                 "weekNo",
                                 "jump"])
    files = os.listdir(path)
    Row = 1
    weekOf = 0
    try:
        for each_file in files:
            source = open(path+each_file, 'r').read()
            thisWeek = 0
            print "Week of", each_file[7:-4]
            source_check = source
            count0 = source_check.count('<article id="row-')
            weekOf += 1
            for i in range(1,count0):
                try:
                    rowId = source.split('<article id="row-')[1].split('" class="chart-row')[0].strip()
                    thisWeek = int(source.split('<span class="this-week">')[1].split('</span>')[0].strip())
                    lastWeek = source.split('<span class="last-week">Last Week:')[1].split('</span>')[0].strip()                    
                    song = re.split('<div class="row-title">', source)[1].split('<h2>')[1].split('</h2>')[0].strip()
                    tmp = source.split('trackaction="Artist Name">',1)[1].split('</a>',1)

                    #Exctacting The first singer if there are multipe
                    singer = tmp[0].strip()
                    instrl=[]
                    for word in stopWords:
                        instr = singer.lower().find(word.lower())
                        if instr > 0:
                            instrl.append(instr)
                    if len(instrl)>0 :
                        singer = singer[0:min(instrl)].strip()
                    
                    #Assigning the rest of the source for the next position(s) in the current week
                    source = tmp[1]

                    df = df.append({"row" : int(Row), #generated sequence
                                    "rowId": int(rowId),#weekly row extracted from source page
                                    "weekDate" : each_file[7:-4],#date of the week
                                    "pos" : int(thisWeek),
                                    "singer" : singer,
                                    "song" : song,
                                    "lastPos" : int(lastWeek.replace('--', '110')),
                                    "weekNo": int(weekOf), #week of the year
                                    "jump": int(int(lastWeek.replace('--', '110')) - int(thisWeek)) },#change in position compared to previous week
                                   ignore_index = True)
                    Row += 1
                except Exception as e:
                    print rowId, each_file, str(e)
    except Exception as e:
        print str(e)

    fileName  = '/Users/hparsa/data_projects/python/Music_python/Hot100_2014.csv'
    df.to_csv(fileName)

get_ranks()
