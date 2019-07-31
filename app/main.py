import time 
from collections import Counter  
 
# current time digits instances counter 
def current_time_digits_instances(): 
    now_time_str = time.strftime("%Y/%m/%d %H:%M") 
    print "Current time: {}".format(now_time_str) 
    now_time_digit_count = Counter(now_time_str) 
    print "Digit\tInstances" 
    for i in range(0, 10):  
        print "{}\t{}".format(i, now_time_digit_count.get(str(i), 0)) 

def handler(event, context): 
        bug testing
        current_time_digits_instances() 
        return None 
