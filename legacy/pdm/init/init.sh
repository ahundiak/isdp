echo "linking PDMinit.o"
echo
ld -r -o ${PDU}/config/dload/init/PDMinit.o \
        ${PDM}/init1/*.o

echo "init image created successfully."
echo
ls -lsat ${PDU}/config/dload/init/PDMinit.o
echo
