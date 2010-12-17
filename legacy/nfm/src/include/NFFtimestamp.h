/*  All macros first check to see if timestamping is enabled  */

/*  Macro to load NFFglobal.time_value  */

#define _NFFts_command_start() \
    if (NFFglobal.timestamp_enabled == TRUE) \
        NFFglobal.time_value = time ((long *) 0);

/*  Macro to put variable args into timestamp buffer  */

#define _NFFts_data(s) \
    if (NFFglobal.timestamp_enabled == TRUE) __NFFts_data s

/*  Macro to write data to the timestamp file  */

#define _NFFts_commit() \
    if (NFFglobal.timestamp_enabled == TRUE) __NFFts_commit ()
