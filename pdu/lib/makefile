objects = \
	$(PDU)/lib/pdu_pdmr.o    \
	$(PDU)/lib/pdu_filemgr.o \
	$(PDU)/lib/pdm_tools.o

target: $(PDU)/lib/pdu.o

$(PDU)/lib/pdu.o : $(objects)
	@ld -r -o $(PDU)/lib/pdu.o $(objects)
	@ls    -l $(PDU)/lib/pdu.o

clean:
	@rm -f pdu.o

