in=$1
out=$2
nm -Be $in | awk '{if ($2 == "T") printf("%s\n", $3)}' >> $out
