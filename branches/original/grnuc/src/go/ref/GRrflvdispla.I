/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRlvdisplay - display certain levels in a reference file
Synopsis
	
        GRlvdisplay(msg, type, matrix, mode, display_info,levels)


	IGRlong *msg		Completion code

	IGRshort *type  	type of the matrix
	IGRmatrix *matrix       environment transformation matrix
	GRdpmode  *mode		the display mode
       	struct GRid *dp_info	
				special display information

	IGRint	*levels		level array

Description

	This method gathers the pertinent information to display
	certain levels in a reference file. The levels will be 
	displayed only if they are turned on in the reference file
	attachment.  

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.
History
	MAS     03/27/86 	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "gocmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "OMmacros.h"

method  GRlvdisplay(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix; 
	enum GRdpmode *mode; struct GRid *dp_info; IGRint *levels)
{
    IGRshort	props;
    IGRshort tmp_prop,
	     action = -1;


    IGRlong  	OMmsg;			/* OM return code		*/

    IGRint	dimension,
		i,
    		ref_levels[32]; 	/* saved levels from reffile	*/

    struct GRid gr_oid;

    GRspacenum 	osnum;

    IGRmatrix *mx[1];

    OM_S_CHANSELECT poly_chan;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    /* if a file has not yet been attached, do not do anything
     */

    dimension = om$dimension_of(varray = me->filename);

    OMmsg = om$os_name_to_number(osname = me->osname,
		p_osnum = &osnum);

    if ( dimension && (OMmsg&1))
    {
	/* turn on only the levels which are on in both the
	 * instance data of the reference file object and the
	 * level mask sent in.
	 */

	for (i=0; i<32; ++i)
	{			
	    ref_levels[i] = me->dp_levels[i];
	    me->dp_levels[i] = me->dp_levels[i] & levels[i];
	}

  	/* 
	 * set the clipping polygon display off if it is on
	 * so that it does not erase the clipping polygon.
	 */

	om$make_chanselect(channame = "GRreffile.to_clip",
		p_chanselect = &poly_chan);

	om$send(msg = message GRvg.GRgetprops(msg,&props),
	    p_chanselect = &poly_chan);

	if ( props & GRIS_DISPLAYABLE)
	{
	    tmp_prop = props & (~GRIS_DISPLAYABLE);

	    om$send (msg = message GRvg.GRchgprops(msg,&action,&tmp_prop),
		p_chanselect = &poly_chan);
	}

	gr_oid.objid = my_id;
	gr_oid.osnum = OM_Gw_current_OS;

	mx[0]  = (IGRmatrix *) matrix;

	dp$display(msg = msg,
		   osnum =  dp_info->osnum,
		   objid =  dp_info->objid,
		   mode  =  *mode,
		   oids  =  &gr_oid,
		   mtx_type = mx_type,
		   matrix = mx);

	for (i=0; i<32; ++i)
	{			
	    me->dp_levels[i] = ref_levels[i];
	}

	if ( props & GRIS_DISPLAYABLE)
	{
	    om$send (msg = message GRvg.GRchgprops(msg,&action,&props),
		p_chanselect = &poly_chan);
	}
    }


    return (OMmsg);
}
end implementation GRreffile;
