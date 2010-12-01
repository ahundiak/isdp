objects = \
        $(RIS)/lib/com_arch.o       \
        $(RIS)/lib/com_common.o     \
        $(RIS)/lib/com_network.o    \
        $(RIS)/lib/app_app.o        \
        $(RIS)/lib/app_interface.o

target: $(RIS)/lib/ris.o

$(RIS)/lib/ris.o : $(objects)
	@ld -r -o  $(RIS)/lib/ris.o $(objects)
	@ls    -l  $(RIS)/lib/ris.o

clean:
	@rm -f ris.o
