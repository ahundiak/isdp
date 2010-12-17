echo "linking PDUinit.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUinit.o \
	${PDU}/init/*.o 

echo "catalogs image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUinit.o
echo
