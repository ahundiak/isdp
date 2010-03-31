
/* ###################   APOGEE COMPILED   ################## */
class specification GAbspline (2:0) of GAcurve,GRbspline;

#include "EMSasdef.h"
#include "EMSas.h"

/* ************************************************************************
Description

 This class provides for
  a) common functionality with regards to implementation of 
     associativity in EMS for all bspline objects.
  b) common message declarations for supporting associativity.

 This is an abstract class.

 It currently inherits the following channels:
 a) father channel (restricted) declared at NDnodein.
 b) children  channel  (restricted)  declared at NDnodein.
 c) vla to store the syntax that is necessary for recomputation.
 d) GRbspline instance data.

History
 Creation : PP : 03/02/91
 WBC : 06/27/91 : Inherited GRcopy from GAcurve.
 WBC : 04/23/93 : Inherited debug from GAcurve to print out my
                  associative information.
 WBC : 05/17/93 : Inherited GRcpparallel from GAcurve to change the
                  class of the copied object from GAxxx to GRxxx
                  (make the object non-associative).
   ************************************************************************ */

from GAcurve inherit GRcopy, GRdetplane, debug, GRcpparallel;

end specification GAbspline;
