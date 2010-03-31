/* ###################   APOGEE COMPILED   ################## */
/* #################   APOGEE  COMPILED   ######################### */
class specification GAcompcurve(2:0) of GAcurve,GRcompcurve;

#include "EMSasdef.h"
#include "EMSas.h"

/* ************************************************************************
Description

 This class provides for
  a) functionality with regards to implementation of 
     associativity in EMS for composite curve objects

 This is not an abstract class.

 It currently inherits the following channels:
 a) father channel (restricted) declared at NDnodein.
 b) children  channel  (restricted)  declared at NDnodein.
 c) vla to store the syntax that is necessary for recomputation.

History
    WBC : 03/22/91 : Creation
    WBC : 03/27/91 : Overrode EMconstruct_associative.
    WBC : 06/27/91 : Overrode GRcopy.
    WBC : 04/23/93 : Inherited debug from GAcurve to print out my
                     associative information.
    WBC : 05/14/93 : Overrode GRcpparallel to change the class of the copied
                     object from GAxxx to GRxxx (make it non-associative).
   ************************************************************************ */

from GAcurve inherit GRdetplane, debug;

override EMconstruct_associative,
         ACcopy_to_Groot,
         NDmake_source,
         GRcopy,
         GRcpparallel;

end specification GAcompcurve;
