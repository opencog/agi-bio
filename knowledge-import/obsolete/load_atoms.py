#!/usr/bin/env python2.7
# --- This python script uses to start the cogserver and load Bio datasets scheme files. One has to connect with the running docker container on the Hetzner server and make sure cogserver is not running in the container.  
# docker exec -i -t bio_cogserver  bash 
# cd /home/doc
# python load_atoms.py 
# --- once all batasets are loadded one can use the following command to access the running cogserver 
# rlwrap nc localhost 17001
# ctrl c .. to exit from cogserver
# exit   .. to exit from container

import time 
import os 

os.system('export GUILE_AUTO_COMPILE=0')
time.sleep(5)
#os.chdir('/home/opencog/build')
os.chdir('~/opencog/opencog/build')
os.system('./opencog/server/cogserver &')
time.sleep(30)

#load files 
path = '/home/doc/'
scm_files = [f for f in os.listdir(path) if f.endswith('.scm')]

os.system(' echo  \'scm\' | nc localhost 17001')
os.system(' echo \'(clear)\'  | nc localhost 17001 ')

for scm in scm_files:
 os.system(' echo  \'(load-from-path \"'+ path + scm +'\")\' | nc localhost 17001 ')

#count 
os.system(' echo \'(count-all)\'  | nc localhost 17001 ')
