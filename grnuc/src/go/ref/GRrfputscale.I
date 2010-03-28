/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRputscale - put a new scale factor in a reference file window

	GRputscale(msg,scale)

	IGRlong *msg		Completion code
	IGRchar *scale 		the scale string to be added to the
				object.
Description

	This method changes the scale factor stored in a reference
	file object. 

	If a file is attached, the new scale is applied to the 
	attachment of the file.

Diagnostics
	The possible return codes values in the msg field are:

	MSSUCC - successful completion
	MSFAIL - error occured

Notes
	None.
History
	MAS 	05/04/87	Design date.
        dhm     07/07/92        ANSI conversion.
\*/

class implementation GRreffile;

#include "grimport.h"
#include "msdef.h"
#include "OMmacros.h"
#include "refpriv.h"

method GRputscale(IGRlong *msg; IGRchar *scale)
{
    IGRshort	mx_size,		/* matrix size			*/
		mx_type;

    IGRlong	OMmsg,			/* return codes			*/
		msg1;
   
    IGRint	dimension;		/* array dimension		*/
				
    IGRmatrix	current_smatrix,	/* working matrices		*/
		new_smatrix1,
		new_smatrix,
		matrix,
		inv_matrix;

    IGRdouble   *mx=NULL;

    GRspacenum 	r_osnum,		/* reference object space	*/
		m_osnum;		/* master object space		*/
    GRobjid	mod_id;			/* module id			*/

    *msg = MSSUCC;			/* initialize return code	*/
    OMmsg = OM_S_SUCCESS;

    dimension = om$dimension_of(varray = me->filename);
    if (dimension)
    {
        mx_size = 4;
     	m_osnum = OM_Gw_current_OS;

        Get_module_info(&msg1,me->osname,&r_osnum,&mod_id);
					/* get new scale matrix		*/
    	GRmodel_scale(&msg1,&m_osnum,&r_osnum,scale,new_smatrix);

    	dimension = om$dimension_of(varray = me->scale_factor);
  
       	if (dimension)			/* scale already present	*/
	{
	    /* 
	     * if the attachment already was attached with a scale
	     * factor, the inverse of this matrix must be applied
	     * before the attachment's new scale is correct.
	     */

    	    GRmodel_scale(&msg1,&m_osnum,&r_osnum,me->scale_factor,
			  current_smatrix);
	    if (1 & msg1)
	    {
					/* invert scale matrix		*/
		MAinvscmx(&msg1,current_smatrix,inv_matrix);

		if (1 & msg1)
		{			/* combine new and old scale	*/
		    MAmulmx(&msg1,&mx_size,&mx_size,&mx_size,
			new_smatrix,inv_matrix,new_smatrix1);
		    
		    if (1 & msg1)
		    {
			mx = (IGRdouble *) new_smatrix1;
		    }
		}
	    }
	}
	else
	{
	    mx = (IGRdouble *) new_smatrix;
	}
	if (1 & OMmsg & *msg)
	{
	    mx_type = MAIDMX;
	    MAidmx(&msg1,matrix);

	    OMmsg = om$send(
		msg = message GRreffile.GRxformref
		    (msg,&mx_type,matrix,mx),
		targetid = my_id);
	}
    }
    if ( 1 & OMmsg & *msg)
    {
	OMmsg = om$vla_set_dimension(
		varray = me->scale_factor,
		size = (strlen(scale)+1));

	if ( 1 & OMmsg)
	{				/* copy in new scale		*/
	    strcpy(me->scale_factor,scale);
   	}
	else
	{
	    *msg = MSFAIL;
	}
    }

    return(OMmsg);
}

end  implementation GRreffile;
