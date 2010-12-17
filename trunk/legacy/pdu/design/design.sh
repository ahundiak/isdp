echo "linking PDUdesign.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUdesign.o \
	${PDU}/design/*.o 

echo "design image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUdesign.o
echo
