echo "linking PDUparts.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUparts.o \
	${PDU}/parts/*.o 

echo "parts image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUparts.o
echo
