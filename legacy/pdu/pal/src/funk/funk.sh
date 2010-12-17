echo "linking PDUfpal.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUfpal.o \
	${FPAL}/src/funk/*.o \
	${FPAL}/src/pdmr/*.o \
	${FPAL}/src/pdmr/svs/*.o \
	${FPAL}/src/ris/*.o 

if [ $? = 0 ]
then
echo "FUTURE PAL image created successfully."
if [ -f ${PDU}/config/dload/init/PDUpal.o ]
then
	echo "Removing old PAL..."
	rm ${PDU}/config/dload/init/PDUpal.o 
fi
echo
ls -lsat ${PDU}/config/dload/init/PDU*pal.o
echo
fi
