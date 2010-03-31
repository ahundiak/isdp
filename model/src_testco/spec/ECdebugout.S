/* ###################   APOGEE COMPILED   ################## */
class specification ECdebugout (1:0) of CObuild;

#include "ems_m_inc.h"

instance ECdebugout
 {
  struct        GRlc_stack locate_stack;
  IGRint        type;
 };

override init, execute;

end specification ECdebugout;

