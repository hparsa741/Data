import datetime
import time
import urllib2
from urllib2 import urlopen

website = 'http://www.billboard.com/charts/hot-100/'


def get_source():
    try:
        d = datetime.datetime.strptime('2014-12-27', '%Y-%m-%d')
        while True:
            str_d = d.strftime('%Y-%m-%d')
            if d.timetuple().tm_year < 2014:
                break
            sourceCode = urllib2.urlopen(website+str_d).read().replace('\r', ' ').replace('\n', '').replace('\t', '')
            print website+str_d
            time.sleep(2)
            text_file = open("Hot100_"+str_d+".txt", "w")
            text_file.write(sourceCode)
            text_file.close()

            d = d - datetime.timedelta(weeks = 1)

    except Exception as e:
        print str(e)


get_source()
