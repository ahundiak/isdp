echo "linking PDUreports.o"
echo
ld -r -o ${PDU}/config/dload/init/PDUreports.o \
        ${PDU}/reports/*.o

echo "reports image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDUreports.o
echo
