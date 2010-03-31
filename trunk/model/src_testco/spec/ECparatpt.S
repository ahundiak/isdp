/* ###################   APOGEE COMPILED   ################## */
class specification ECparatpt (1:0) of CObuild;

#include "ems_m_inc.h"

instance ECparatpt
 {
  IGRboolean	have_element;
  struct        GRlc_info element;
  struct        GRlc_stack locate_stack;
  struct        GRevent event;
  IGRdouble	uv[2];
 };
 
override wakeup, execute, super_cmd.sleep;

end specification ECparatpt;

