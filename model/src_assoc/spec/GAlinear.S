/* ###################   APOGEE COMPILED   ################## */
/* #################   APOGEE  COMPILED   ######################### */
class specification GAlinear(2:0) of GAbspline,GRlinear;

#include "EMSasdef.h"
#include "EMSas.h"

/* ************************************************************************
Description

 This class provides for
  a) functionality with regards to implementation of 
     associativity in EMS for linear objects

 This is not an abstract class.

 It currently inherits the following channels:
 a) father channel (restricted) declared at NDnodein.
 b) children  channel  (restricted)  declared at NDnodein.
 c) vla to store the syntax that is necessary for recomputation.

History
    WBC : 03/22/91 : Creation
    WBC : 06/27/91 : Inherited GRcopy from GAcurve.
    WBC : 04/23/93 : Inherited debug from GAcurve to print out my
                     associative information.
    WBC : 05/17/93 : Inherited GRcpparallel from GAcurve to change the
                     class of the copied object from GAxxx to GRxxx
                     (make the object non-associative).
   ************************************************************************ */

from GAcurve inherit GRcopy, GRdetplane, debug, GRcpparallel;

end specification GAlinear;
