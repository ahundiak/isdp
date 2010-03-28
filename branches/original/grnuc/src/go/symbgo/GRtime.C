/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRtime

Description
   This function will produce an integer which represents the time
   in seconds since 00:00:00 GMT, January 1, 1970.  This function is 
   used so to provide an operating system independent interface.

   *tloc       IGRint            if tloc (taken as an integer) is non-zero,
                                 the return value is also stored in the
                                 location to which tloc points.

History
   HGW   10/01/86    Creation Date
   HGW   11/16/87    Changes for version 1.1
   SCW   07/07/92    Changed argument for time from int to time_t (ansi)
 */

#include "grimport.h"
#include "igrtypedef.h"

IGRint   GRtime(tloc)
time_t   *tloc;
{
   return (time(tloc));
}
