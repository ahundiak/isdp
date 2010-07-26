/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
    GRget_component_id

Description
    This method is used to get the objet id of the drawing view components.

Arguments
    *msg        IGRlong           return code
    selector    IGRint            flag specifing type of component
                                     -  GR_DV_REFFILE
                                     -  GR_DV_TEXTNAME
                                     -  GR_DV_TEXTSCALE
                                     -  GR_DV_CS
    count       IGRint            size of arrays
    ids[]       struct GRid       an array of ids
    types[]     IGRint            an array containing the type of ids
                                     -  GR_DV_REFFILE
                                     -  GR_DV_TEXTNAME
                                     -  GR_DV_TEXTSCALE
                                     -  GR_DV_CS

Return Values
    MSSUCC   -  if success
    MSFAIL   -  if failure
\*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detaildef.h"
#include "gocmacros.h"
#include "ref.h"
#include "refdef.h"
#include "OMmacros.h"
#include "OMminimum.h"

extern IGRint   GRget_to_comp_chansel();

method GRget_component_id ( IGRlong *msg; 
                            IGRint selector; 
                            IGRint count;
                            struct GRid ids[]; 
                            IGRint types[])
{
    IGRlong           om_msg;
    IGRint            num;
    IGRint            i;
    IGRint            tcount;
    IGRint            tsel;
    OM_S_CHANSELECT   chansel;
    struct GRid       go_id;

    *msg = MSSUCC;
    om_msg = OM_S_SUCCESS;

    GRget_to_comp_chansel(&chansel);

    om$send ( msg = message GRowner.GRget_number_components ( msg, &tcount), 
              targetid = my_id);

    for (num = 0, i=tcount -1; (i >= 0) && (num < count); --i) 
    {
        om_msg = om$get_objid_at_index ( osnum = OM_Gw_current_OS, 
                                         objid = my_id,
                                         p_chanselect = &chansel, 
                                         index = i,
                                         objidaddr = &go_id.objid,
                                         osnumaddr = &go_id.osnum);

        if (om_msg & 1) 
        {
            GRdvget_comp_type (msg, &go_id, &tsel);

            if (om_msg & *msg & 1) 
            {
                if (tsel & selector) 
                {
                    /*
                     *  If the object is in the selector mask then add it to
                     *  the array.
                     */         
                    ids[num] = go_id;
                    types[num] = tsel;
                    num++;
                }
            }
        }
    }

    return(om_msg);
}
end implementation GRdvattach;
