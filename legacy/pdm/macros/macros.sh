echo "linking PDMmacros.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMmacros.o \
        ${PDM}/macros/*.o

echo "bom image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMmacros.o
echo
