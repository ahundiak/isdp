echo "linking PDMbom.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMbom.o \
        ${PDM}/bom/*.o

echo "bom image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMbom.o
echo
