echo "linking PDUcatalogs.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUcatalogs.o \
	${PDU}/catalogs/*.o 

echo "catalogs image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUcatalogs.o
echo
