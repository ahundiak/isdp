echo "linking PDMpdmp.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMpdmp.o \
        ${PDM}/pdmp/*.o

echo "pdmp image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMpdmp.o
echo
