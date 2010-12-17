echo "linking PDMmulfile.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMmulfile.o \
        ${PDM}/mulfile/*.o

echo "mulfile image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMmulfile.o
echo
