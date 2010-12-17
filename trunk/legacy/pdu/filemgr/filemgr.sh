echo "linking PDUfilemgr.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUfilemgr.o \
	${PDU}/filemgr/*.o 

echo "catalogs image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUfilemgr.o
echo
