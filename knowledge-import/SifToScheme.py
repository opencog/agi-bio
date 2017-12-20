# TODO:
# add in-complex-with link
# CATALYSIS-PRECEDES needs to be instantiated:  run through pattern matcher?

import os
import sys
import fileinput
import re
import collections

# Two files one sif that has the two atoms connected by the rules
# Anonther file containing the translation of the rules into scm format
# separate out the rule from each line in the sif file and find it in the translationfile
# copy the contents of that rule (until you hit a name of another/next rule)
# replace the "$P1" and "$P2" with the two atoms in the first file

sifFile = "./PathwayCommons9.Detailed.hgnc.sif"
ruleFile = "./RulesOfTranslation.txt"
resultFile = "./PathwayCommons9.scm"

tempFile = open(sifFile, 'r+')
translationFile = open (ruleFile, 'r+')
finalFile = open (resultFile, 'a')

def findInstruction(text, atom1, atom2):
   copy = False
   instruction = ""
   translationFile.seek(0)
   for line in translationFile:
      x = line.strip()
      if(x==text):
          #check isUpper() if true then we've hit the next rule!
          copy = True
#          print "found, copy = true " + line +"\t"+ text
          continue

      if (copy):
         if (not line.isupper()):
             if('"$P1"'in line):
                replace1 = '"'+ atom1 +'"'
                instruction += line.replace('"$P1"', replace1)
             elif ('"$P2"'in line):
                replace2 = '"'+ atom2 +'"'
                instruction += line.replace('"$P2"', replace2)
             else:
                instruction += line;
         else:
            # print "stop print for copy at line = "+line
             break
   return instruction



for lne in tempFile:
   words = lne.split()
   print ("rule is "+ words[1].strip().upper())
   write = findInstruction(words[1].strip().upper(),words[0], words[2])
   finalFile.write(write+"\n")
