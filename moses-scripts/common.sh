# Bash code to be sourced directly in the script

#############
# Functions #
#############

# Output date at a certain format
my_date() {
    date --rfc-3339=seconds
}

# Given an error message, display that error on stderr and exit
fatalError() {
    echo "[$(my_date)] [ERROR] $@" 1>&2
    exit 1
}

# Pad $1 symbol with up to $2 0s
pad() {
    local pad_expression="%0${2}d"
    printf "$pad_expression" "$1"
}

# Return the number of rows (header excluded) in a CSV files
nrows() {
    echo $(($(wc -l < "$1") - 1))
}
