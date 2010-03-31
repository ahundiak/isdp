
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hstex_table_include
#define hstex_table_include 1

#define NO_STATUS          0
#define ENTRY_PRESENT      1
#define ANY_ENTRY          2
#define ACTIVE_ONLY        3
#define NO_ENTRY           4
 
struct offset_ref_ct
                 {
                   int     offset;
                   int     ref_ct;
                 };


#endif
