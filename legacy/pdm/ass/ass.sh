echo "linking PDMass.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMass.o \
        ${PDM}/ass/*.o

echo "ass image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMass.o
echo
