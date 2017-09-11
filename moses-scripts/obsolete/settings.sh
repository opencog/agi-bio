####################
# General settings #
####################

# Initial random seed
init_seed=1

# Data path. If the path is relative, then it is considered
# relative the root directory of this repository.
data_path="gse16717/offvscontrol_no_col1.csv"

###########################
# OpenCog server settings #
###########################

# Path of the OpenCog repository
opencog_repo_path=~/OpenCog/opencog
build_dir_name=build

#################################
# Background knowledge settings #
#################################

# File path of the scheme file containing background knowledge (if the
# path is relative, it is relative to the directory where that
# settings file is)
scheme_file_path="scripts/background_knowledge.scm"

#############################
# Cross-validation settings #
#############################

# Number of folds
kfold=1

# Train / (Test + Train) ratio (in case kfold is 0 or 1)
train_ratio=0.66

##################
# MOSES settings #
##################

# Log level
log_level=debug

# Number of threads MOSES can use
jobs=4

# Number of evaluations per run
evals=1K

# Maximum number of candidates output by MOSES
max_candidates=1

# Algorithm of feature selection within MOSES
fsm_algo=random

# Number of features to select during feature selection within MOSES
fsm_nfeats=50
