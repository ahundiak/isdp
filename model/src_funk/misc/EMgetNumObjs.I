/* ###################   APOGEE COMPILED   ################## */
/*
ABSTRACT

    This function returns the number of object linkages on of
    a specified channel of an object to which is on my_id's
    channel selected by myChansel.

HISTORY

jbk 1-OCT-86 : Creation
*/

class implementation Root;

#include "EMS.h"
/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */
# include "OMminimum.h"     /* has various OM structures */
# include "codef.h"         /* has COERROR macro */
# include "EMSjbklogic.h"   /* has fun logic things */
# include "EMSerrordef.h"   /* has EMS error definitions */
# include "OMerrordef.h"    /* has OM error definitions */

IGRlong EMgetNumberObjects
(myChannel, my_id, itsChannelName, count)
OM_S_CHANSELECT myChannel;
OM_S_OBJID my_id;
IGRchar itsChannelName[];
IGRint *count;
{
    IGRlong om_msg;
    OM_S_OBJECT_LINKAGE itsObjectLinkage;
    OM_S_CHANSELECT itsChansel;
    IGRint local_count;

#   if DEBUG
        fprintf (stderr,
"EMgetNumberObjects, A\n\t *count IS %d count IS 0x%x\n", *count, count);
#   endif

    om_msg = om$get_channel_objects(osnum = OM_Gw_current_OS,
                                    objid = my_id,
                                    p_chanselect = &myChannel,
                                    list = &itsObjectLinkage,
                                    size = 1,
                                    count = (OMuint *)&local_count);
    if (COERROR (om_msg)) return om_msg;
    if (local_count != 1) return EMS_E_ChanCountNot1;

    om_msg = EMmake_chanselect (itsChannelName, &itsChansel);

    if (COERROR (om_msg)) return om_msg;

    om_msg = om$get_channel_count(osnum = itsObjectLinkage.osnum,
                                  objid = itsObjectLinkage.S_objid,
                                  p_chanselect = &itsChansel,
                                  count = (OMuint *)count);
    if (COERROR (om_msg)) return om_msg;

#   if DEBUG
        fprintf (stderr,
"EMgetNumberObjects, B\n\t *count IS %d count IS 0x%x\n", *count, count);
#   endif

    return OM_S_SUCCESS;
}

end implementation Root;
