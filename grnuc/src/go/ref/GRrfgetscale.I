/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRgetscale - get scale factor from reference file to	
			master file

	GRgetscale(msg,scale)

	IGRlong *msg		Completion code
	IGRdouble *scale 	the scale factor

Description

	This method returns the scale defining the reference
	file attachment. This is the master file unit to 
	reference file unit ratio.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	GRINVMSG - no file is attached.
	MSFAIL - error occured

Notes
	None.
History
	MAS 	05/04/87	Design date.

\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "grerr.h"
#include "OMmacros.h"
#include "refpriv.h"

method GRgetscale(IGRlong *msg; IGRdouble *scale)
{
    IGRlong	OMmsg;
    IGRlong 	msg1;
   
    IGRint	dimension;

    IGRmatrix	smatrix;

    GRspacenum 	r_osnum,m_osnum;
    GRobjid	mod_id;

    *msg = MSSUCC;		/* initialize return code	*/
    OMmsg = OM_S_SUCCESS;
    
    dimension = om$dimension_of(varray = me->filename);
    if (dimension)
    {
    	dimension = om$dimension_of(varray = me->scale_factor);
  
       	if (dimension)
	{
	    m_osnum = OM_Gw_current_OS;

	    Get_module_info(&msg1,me->osname,&r_osnum,&mod_id);

    	    GRmodel_scale(&msg1,&m_osnum,&r_osnum,
			me->scale_factor,smatrix);
	    if (1 & msg1)
	    {
	        *scale = smatrix[0];
	    }
	    else
	    {
		*msg = MSFAIL;
		OMmsg = OM_E_ABORT;
	    }
	}
	else
	{
	    *scale = 1.0;
	}
    }
    else
    {
	*msg = GRINVMSG;
	OMmsg = OM_E_ABORT;
    }

    return(OMmsg);
}

end  implementation GRreffile;
