/* ###################   APOGEE COMPILED   ################## */
class specification EMAdatpln (2:0) of EMSassoc, EMSdatpln;

#include "REdatpln.h"

/* ************************************************************
Specification
 This class provides for functionality to create/manage
 associative datums.

History
 Creation : PP : 07/04/91
   ************************************************************ */

instance EMAdatpln
{
};

from EMSassoc inherit NDupdate, NDget_state, NDchg_state, NDdisplay,
     NDmove_to_root, NDmake_source, NDdelete, ACcopy_to_Groot;

override EMconstruct_associative,
/*
 * To perform graph copy.
 */
         NDcopy_graph,
/*
 * This override exists to return the point geometry for a reference
 * plane parallel to a plane and passing thru a point.
 */
         EMassoc_autodimparam,

         EMautodim,
/*
 * Delete the parameter parents, and any auto-dimensioning
 * support objects.
 */
         GRdelete,
/*
 * Broadcast SKmgrprops message so that profiles who are my children can
 * update themselves more intelligently.
 */
         EMcompute_postprocess,
         EMget_parent_type;

end specification EMAdatpln;
