/* #######################    APOGEE COMPILED   ######################## */
class implementation GRcmpowner;

#include "grimport.h"
#include "igrtypedef.h"
#include "OMerrordef.h"
#include "msdef.h"

%safe
static IGRint	        to_comp_chan_defined = FALSE;
static OM_S_CHANSELECT  to_comp_chansel;
%endsafe

IGRint GRget_to_comp_chansel( p_chansel )
    OM_S_CHANSELECT *   p_chansel;
{
    IGRint  status;

    if ( !to_comp_chan_defined ) 
    {
        status = om$make_chanselect ( channame = "GRcmpowner.to_components",
                                      p_chanselect = &to_comp_chansel );
        if (!(status & 1)) return (0);
        to_comp_chan_defined = TRUE;
    }
    
    if ( p_chansel ) *p_chansel = to_comp_chansel;

    return (1);
}

IGRint GRget_to_comp_info( p_chansel, osnum, objid, p_count )
    OM_S_CHANSELECT *   p_chansel;
    OMuword             osnum;
    OM_S_OBJID          objid;
    IGRint *            p_count;
{
    IGRint  status;

    if ( !to_comp_chan_defined ) 
        GRget_to_comp_chansel ( p_chansel );
    else 
        *p_chansel = to_comp_chansel;

    status = om$get_channel_count ( osnum = osnum,
                                    objid = objid,
                                    p_chanselect = p_chansel,
                                    count = (OMuint *)p_count );
                                    
    return (status & 1);
}
        
end implementation GRcmpowner;
