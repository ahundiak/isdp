echo "linking PDUpdmr.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUpdmr.o \
	${PDU}/pdmr/*.o 

echo "pdmr image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUpdmr.o
echo
