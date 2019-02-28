import sys
import re

def find_name(str):
	name = re.findall('"([^"]*)"', str)
	if len(name) > 0:
		return re.findall('"([^"]*)"', str)[0]
	return ""

def to_sif(file):
	member = []
	evalun = []

	f = open(file, "r")

	for num, line in enumerate(f , 0):
		if "InheritanceLink" in line or "MemberLink" in line:
			member.append(num)
		elif "EvaluationLink" in line:
			evalun.append(num)

	# # write to file as csv
	lines=open(file, "r").readlines()

	with open(file.split(".")[0]+".sif", "a") as output:
		try:
			for i in member:
				output.write(find_name(lines[i+1]) + "\t" + "Member_of" + "\t" + find_name(lines[i+2]) + "\n")
	
			for i in evalun:
				output.write(str(find_name(lines[i+3])) + "\t" + str(find_name(lines[i+1])) + "\t" + str(find_name(lines[i+4])) + "\n")
		except "IndexError":
			print("error") 

if __name__ == "__main__":
	to_sif(sys.argv[1])

