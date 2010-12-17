echo "linking PDUtools.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUtools.o \
	${PDU}/tools/*.o 
		
echo "tools image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUtools.o 
echo
