DIR=$(realpath "$1")
LR="$2"

find "$DIR" -name "*000000050000*" -exec echo {} "$LR" \;
find "$DIR" -name "*000000100000*" -exec echo {} "$LR" \;
find "$DIR" -name "*000000150000*" -exec echo {} "$LR" \;
find "$DIR" -name "*000000200000*" -exec echo {} "$LR" \;
find "$DIR" -name "*000000250000*" -exec echo {} "$LR" \;
find "$DIR" -name "*000000300000*" -exec echo {} "$LR" \;
find "$DIR" -name "*000000350000*" -exec echo {} "$LR" \;
find "$DIR" -name "*000000400000*" -exec echo {} "$LR" \;
