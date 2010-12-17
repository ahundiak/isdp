echo "linking PDUmacros.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUmacros.o \
	${PDU}/macros/*.o 

echo "catalogs image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUmacros.o
echo
