
target: makeimp
	grmake -r -k -f makeimp
	@cd $(NFM10)/lib; make; cd

makeimp: imp.m
	grmakemake imp.m makeimp

clean:
	@rm -f makeimp *.o
