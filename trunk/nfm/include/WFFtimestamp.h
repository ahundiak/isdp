/*  All macros first check to see if timestamping is enabled  */

/*  Macro to load NFIglobal.time_value  */

#define _WFFts_command_start() \
	if (WFFglobal.timestamp_enabled == TRUE) \
		WFFglobal.time_value = time ((long *) 0);

/*  Macro to put variable args into timestamp buffer  */

#define _WFFts_data(s) \
	if (WFFglobal.timestamp_enabled == TRUE) __WFFts_data s

/*  Macro to write data to the timestamp file  */

#define _WFFts_commit() \
	if (WFFglobal.timestamp_enabled == TRUE) __WFFts_commit ()
