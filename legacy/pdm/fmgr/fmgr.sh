echo "linking PDMfmgr.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMfmgr.o \
        ${PDM}/fmgr/*.o

echo "fmgr image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMfmgr.o
echo
