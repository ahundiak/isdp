for tfile in *.t
do
echo slicing $tfile
${EXNUC}/bin/slic -Csi $tfile
done
