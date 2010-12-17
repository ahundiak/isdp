echo "linking PDMreports.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMreports.o \
        ${PDM}/reports/*.o

echo "reports image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMreports.o
echo
