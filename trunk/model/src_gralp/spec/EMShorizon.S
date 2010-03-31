/* ###################   APOGEE COMPILED   ################## */
class specification EMShorizon (2:0) of EMSgraloop;

/*
   History
     
       Jack  05-06-91   Created from Allen's 2.0.0 version.
       Jack  13-June-91 Added override of EMget_the_edges 
                        message. 
       Jack  04-July-91 Changed EMcheck_orientation from being
                        defined here to being overridden here.
       DLB   07/10/91   Disable tagging.
       AIC   08/06/91   Added override for EMmatch_graphics_loops.
       Jack  09/15/91   Removed z vector from instance data.  Horizon
                        loops will now be placed with respect to a
                        reference plane from which we can get the z.
       Jack  09/29/91   Added override of NDupdate message.
       Jack  11/18/91   Added override of EMtranslate_id_key.
       Jack  09/25/92   Added override EMchangeSurface.
*/


#include "EMShorizon.h"

taggable;

instance EMShorizon
{
/*    double  z[3]; */
    variable struct EMShorizon_info  horizon_info[];
};




message EMset_orientation(int *z_index; double vector[3]);
/*
    Sets the orientation.

    If z_index is not NULL, *z_index is stored. Otherwise, vector is
    used.
*/

message EMstore_horizon_info(int count; struct EMShorizon_info *horizon_info;
                             int append);
/*
    Store horizon edge classification information.

    count - input           number of horizon edge classifications

    horizon_info - input    horizon edge classifications

    append - input          if TRUE, append; otherwise replace
*/

from GRgraphics inherit GRdisplay;

override
        debug,
        EMmatch_graphics_loops,
        EMlocate,
        EMSloop.EMexecuteCurveFunction,
        EMbdrylocate,        
        EMkeypoint, 
        EMdisplay,
        EMget_the_edges,
        EMcheck_orientation,
        EMconstruct_associative,
        NDupdate,
        NDmove_to_root,
        EMhelperCopy,
        EMglpinit,
        EMtranslate_id_key, 
        GRchgprops,
        GRgetprops,
        GRdelete,
        GRdisyourself,
        EMchangeSurface;


end specification EMShorizon;
