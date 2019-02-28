import sys
import re
import pandas as pd

def find_name(str):
	name = re.findall('"([^"]*)"', str)
	if len(name) > 0:
		return re.findall('"([^"]*)"', str)[0]
	return ""

def to_csv(file):
	member = []
	evalun = []
	nodes = []

	f = open(file, "r")
	lines=open(file, "r").readlines()

	for num, line in enumerate(f , 0):
		if "InheritanceLink" in line or "MemberLink" in line:
			member.append(num)
			if not find_name(lines[num+1]) in nodes:
				nodes.append(find_name(lines[num+1]))

		elif "EvaluationLink" in line:
			evalun.append(num)
			if not find_name(lines[num+1]) in nodes:
				nodes.append(find_name(lines[num+3]))

		# elif "PredicateNode" in line:
		# 	if not find_name(line) in column: 
		# 		column.append(find_name(line))

	# write to file as csv
	df_member = pd.concat([pd.DataFrame([[find_name(lines[i+1]), find_name(lines[i+2])]], columns=["node","member"]) 
		       for i in member], ignore_index=True)

	# df_member.to_csv("member.csv")

	df_eva = pd.concat([pd.DataFrame([[str(find_name(lines[i+3])), str(find_name(lines[i+4]))]], columns=["node",str(find_name(lines[i+1]))])  
		     for i in evalun], ignore_index=True)

	column = ['Atom', 'isMemberOf', 'interacts_with']

	# df_eva.to_csv("eva.csv")

	# # df = pd.merge(df_member, df_eva, on='node',  how='outer')
	# nodes = list(set(df_member["node"].append(df_eva['node'])))

	print(len(set(nodes)))
	nodes = list(set(nodes))
	
	df_new = pd.concat([pd.DataFrame([[n, str(df_member[df_member['node']==n]['member'].get_values()), 
		str(df_eva[df_eva['node']==n]['interacts_with'].get_values())]], columns=column) for n in nodes], ignore_index=True)

	df_new.to_csv(file.split(".")[0]+".csv")


if __name__ == "__main__":
	to_csv(sys.argv[1])
