/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        GRgenabsg

Description
        This routine generates the abstract data representation for a 3-D
        double precision cell header object and places the data in the 
        abstract geometry cache.

        IGRlong *msg                completion message 
        IGRshort *matrix_type       type of transformation matrix
        IGRmatrix matrix            transformation matrix
        IGRchar **absgptr           pointer to abstract geometry buffer

Note
        The GR_RECALCULATE_GEOM bit should be checked in this routine.
        If set recalculate the extents.  This bit should only be set by the
        archiver of version 1.0 to version 1.1.
   
History
        DEM/HGW     07/02/86    Design date and  07/03/86 : Creation date.
        HGW         08/07/86    Changed terminolgy.
        HGW         09/29/86    Convert to 4.0
        HGW         11/07/87    Change for version 1.1
        mrm         01/31/89    send valid matrix_type and matrix to GRgetrang
        scw         07/22/92    ansi conversion
*/

class implementation GRclhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "madef.h"
#include "gocmacros.h"
#include "grsymdef.h"

method GRgenabsg (IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix;
                  IGRchar **absgptr)
{
    OMuint            count = 0;
    IGRint            i;
    IGRboolean        world;
    IGRdouble        *pr;
    GRrange           range;
    GRrange           go_range;
    OM_S_CHANSELECT   to_comp;

    *msg = MSSUCC;

    if (me->owner_properties & GR_RECALCULATE_GEOM)
    {
        world = TRUE;
        om$make_chanselect (channame = "GRcmpowner.to_components",
                            p_chanselect = &to_comp);
        om$get_channel_count (object = me,
                              p_chanselect = &to_comp,
                              count = &count);
        if (count)
        {
            /*
             *  get the range of the object in the world coordinate system
             */
         
            pr = range;
            for (i = 0; i < count; ++i)
            {
                om$send (msg = message GRvg.GRgetrang
                              (msg, matrix_type, matrix, &world, pr),
                         p_chanselect = &to_comp,
                         to = i,
                         from = i);

                if (i == 0)
                {
                    pr = go_range;
                }
                else
                {
                    GRaccumulate_range (msg, go_range, range);
                }
            }

            /*
             *  matrix is an identity matrix the origin is the lower
             *  left front and range is the range in world
             *  coordinates adjusted to the new origin
             */

            me->matrix[0] = 1;
            me->matrix[1] = 0;
            me->matrix[2] = 0;
            me->matrix[3] = 0;
            me->matrix[4] = 1;
            me->matrix[5] = 0;
            me->matrix[6] = 0;
            me->matrix[7] = 0;
            me->matrix[8] = 1;
            for (i = 0; i < 3; ++i)
            {
                me->origin[i] = range[i];
                me->diag_pt1[i] = 0;
                me->diag_pt2[i] = range[i + 3] - range[i];
            }
            me->owner_properties &= (0xffffffff ^ GR_RECALCULATE_GEOM);
        } 
    }

    return (GR3dlbgenabsg (msg, matrix_type, matrix, me->matrix,
                           me->origin, me->diag_pt1, me->diag_pt2, my_id, 
                           OM_Gw_current_OS, absgptr));
}

end implementation GRclhdr;
