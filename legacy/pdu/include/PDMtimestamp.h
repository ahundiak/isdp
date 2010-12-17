/*  All macros first check to see if timestamping is enabled  */

/*  Macro to load PDMtime_value  */

#define PDMtime_command_start() \
    if (PDMtime_enabled == TRUE) \
        PDMtime_value = time ((long *) 0);

/*  Macro to put variable args into timestamp buffer  */

#define PDMtime_data(s) \
    if (PDMtime_enabled == TRUE) _PDMtime_data s

/*  Macro to write data to the timestamp file  */

#define PDMtime_commit() \
    if (PDMtime_enabled == TRUE) _PDMtime_commit ()
