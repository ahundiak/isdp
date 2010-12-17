echo "linking PDMpdms.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMpdms.o \
        ${PDM}/pdms/*.o

echo "pdms image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMpdms.o
echo
