CC = cc

FBsensor: $(MODEL)/ems/FBsensor.c
	@echo
	@echo "    FBsensor.c -> $@"
	@if test "${DEBUG}" != "yes"; \
	then ${CC} -o FBsensor $(MODEL)/ems/FBsensor.c; \
	else ${CC} -o -g -DDEBUG=1 FBsensor $(MODEL)/ems/FBsensor.c; fi
	@if test "${DEBUG}" = "yes"; \
	then echo "    debug version of $*.c compiled"; fi

