/* ###################   APOGEE COMPILED   ################## */
class specification ECshowSSI (1:0) of CObuild;

/*

HISTORY

13 Apr 1989 jBk Renamed to be a show boolean SSI command.

*/

#include "ems_m_inc.h"

instance ECshowSSI
 {
  struct        GRlc_stack locate_stack;
 };

override execute;

end specification ECshowSSI;

