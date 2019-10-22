import json
import datetime
import os
from collections import OrderedDict 

def update_meta(version, source, script, genes=None, prot=None, chebi=None, pathways=None, goterms=None,interactions=None):
  meta_data = OrderedDict()  
  dataset_name = version.split(':')[0]
  meta_data.update({"Version": version.split(':')[1]})
  meta_data.update({"Source": source})
  if genes:
      meta_data.update({"Number of Genes ": genes})
  if prot:
      meta_data.update({"Number of Proteins ": prot})
  if chebi:
      meta_data.update({"Number of Small Molecules ": chebi})
  if interactions:
      meta_data.update({"Number of interactions ": interactions})
  if pathways:
      for p in pathways.keys():
          meta_data.update({"Number of "+ p: pathways[p]})
  if goterms:
      for namespace in goterms.keys():
          meta_data.update({"Number of "+ namespace: goterms[namespace]})  
  meta_data.update({"Import script": script })
  meta_data.update({"Import Date ": str(datetime.datetime.now().date())})    
  dataset_meta = {dataset_name: [meta_data]}

  fname = "dataset/meta.json" 
  if not os.path.exists(os.path.join(os.getcwd(), 'dataset')):
    os.makedirs('dataset')
  
  if not os.path.isfile(fname):
    a = []
    a.append(dataset_meta)
    with open(fname, mode='w') as f:
        json.dump(a,f, indent=2)
  else:
    with open(fname) as feedsjson:
        feeds = json.load(feedsjson)

    feeds[0][dataset_name] = [meta_data] 
    with open(fname, mode='w') as f:
        json.dump(feeds, f, indent=2)  
