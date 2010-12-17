echo "linking PDMtools.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMtools.o \
        ${PDM}/tools/*.o

echo "tools image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMtools.o
echo
