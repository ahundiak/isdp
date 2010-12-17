echo "linking PDMris.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMris.o \
        ${PDM}/ris/*.o

echo "pdmp image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMris.o
echo
