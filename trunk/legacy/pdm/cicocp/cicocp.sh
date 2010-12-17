echo "linking PDMcicocp.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMcicocp.o \
        ${PDM}/cicocp/*.o

echo "cicocp image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMcicocp.o
echo
