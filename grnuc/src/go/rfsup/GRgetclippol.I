/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetclippoly - get the clipping polygon

Synopsis
	GRgetclippoly(msg,objid,ptr)

	IGRlong		*msg;		 completion code		
	IGRshort	*mx_type;	 type of matrix		
	IGRmatrix	matrix;		 the environment matrix 	
	GRobjid		*objid;		 object id			
	IGRchar		**ptr;		 pointer to geometry		

Description
	This function get the clipping polygon of a 
	reference file attachment object.

Diagnostics
	The possible values for msg are:
	MSSUCC - successful completion
	MSFAIL - error occurred

Notes
	This function uses the geometry cache for the 
	object.

History
	MAS	04/03/87 	Design Date

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"

extern    IGRboolean    GRtest_absg();

GRgetclippoly(msg,mx_type,matrix,objid,ptr)

IGRlong		*msg;		/* completion code		*/
IGRshort	*mx_type;	/* type of matrix		*/
IGRmatrix	matrix;		/* the environment matrix 	*/
GRobjid		*objid;		/* object id			*/
IGRchar		**ptr;		/* pointer to geometry		*/

{
    IGRlong	OMmsg;		/* return code			*/
    IGRint	count;		

    OM_S_CHANSELECT poly_chan;
    OM_S_OBJECT_LINKAGE  list;

    
    OMmsg = OM_S_SUCCESS;	/* initialize return values	*/
    *msg = MSSUCC;
			

    poly_chan.type = OM_e_name;
    poly_chan.u_sel.name = "GRreffile.to_clip";		    

   				/* get the clip poly object	*/
    OMmsg = om$get_channel_objects(
			objid = *objid,
			p_chanselect = &poly_chan,
			list = &list,
			size = 1,
			count = (OMuint *)&count);	

    if (1 & OMmsg)
    {				/* get the poly clip geometry	*/
	if (! GRabsg_test(msg,mx_type,matrix,&OM_Gw_current_OS,
			&list.S_objid,ptr))
	{
	    OMmsg = om$send(
		    msg = message GRvg.GRgenabsg(msg,mx_type,matrix,ptr),
		    senderid = *objid,
		    targetid = list.S_objid);
	}	
    }

    if (! (1 & OMmsg ))
    {
	*msg = MSFAIL;
    }

    return (OMmsg);
}

end implementation GRreffile;
