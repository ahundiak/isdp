/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "OMerrordef.h"
#include "msdef.h"
#include "dpdef.h"
#include "referr.h"
#include "refpriv.h"
#include "dp.h"
#include "dpmacros.h"
#include "dpsavevw.h"
#include "OMmacros.h"

#argsused
GRverifyview(msg,saved_view,osnum,objid,vw_origin,vw_rotation,vw_volume,
		same,new_origin,new_rotation,new_volume)

IGRlong 	*msg;
IGRchar		*saved_view;
GRspacenum      *osnum;
GRobjid         *objid;
IGRdouble	*vw_origin;
IGRmatrix	vw_rotation;
IGRdouble	*vw_volume;
IGRboolean 	*same;
IGRdouble	*new_origin;
IGRmatrix	new_rotation;
IGRdouble	*new_volume;

{				
    IGRshort   mx_size=4;	/* dimension of matrix			*/

    IGRlong 	msg2;
    IGRlong	OMmsg;

    IGRint  num_returned, i;

    IGRmatrix mx;		/* local matrix				*/

    struct DPsavevw vw_struct;	/* saved view structure			*/
    struct var_list vw_list[2];

    OMmsg = OM_S_SUCCESS;

    if ( saved_view)
    {
         vw_list[0].var = SAV_VW_STRUCT;
         vw_list[0].var_ptr = (IGRchar *)&vw_struct;	
         vw_list[0].num_bytes = sizeof(struct DPsavevw);
         vw_list[0].bytes_returned = (IGRlong *)&num_returned;
         vw_list[1].var = END_PARAM;

/*         dp$inq_set_saved_view( 
   	    msg = &msg2,
    	    osnum = *osnum,
    	    mod_objid = *objid,
    	    vw_name = saved_view,
    	    which_error = &which_error,
    	    var_list = vw_list);
*/
    	if  (1 & msg2) /* check to see if view changed	*/
        {
      	    *same = TRUE;

    	    MAtrnmx(&msg2,&mx_size,vw_struct.rotation,mx);
       	    for (i=0; (i<16) && *same;++i)
      	    {
    	        if ( mx[i] != vw_rotation[i])
       	        {
    	    	    *same  = FALSE;
    	        }
       	    }
       	    for (i=0; (i < 3) && *same; ++i)
       	    {
    	        if (vw_struct.origin[i] != vw_origin[i])
       	        {
    	    	    *same  = FALSE;
    	    	}
    	    	else 	
    	    	{
    	    	    if ((vw_struct.vw_volume[i] != vw_volume[i])
  	 	    	   ||
            	       (vw_struct.vw_volume[i+3] != vw_volume[i+3]))
               	    {
            	    	*same  = FALSE;
    	    	    }
    	    	}
       	    }
       	    if (! *same)/* redo the instance data		*/
       	    {
       	        for (i=0; i < 3; ++i)
       	        {
                    /* Changed != to = in the statement below         */
                    /* In the original form the statement was ignored */
                    /* 07/28/92  ansi conversion effort               */
    	            new_origin[i] = vw_struct.origin[i];
    	    	    new_volume[i] = vw_struct.vw_volume[i];
		    new_volume[i+3] = vw_struct.vw_volume[i+3];
		}
		for (i=0; i<16; ++i)
		{
		    new_rotation[i] = mx[i];
		}
#ifdef DEBUG
        printf("The saved view has changed\n");
#endif
            }
	}
	else
	{
    	    *msg = GRVIEWNOTFOUND;
	    OMmsg = OM_E_ABORT;
        }
    }

    return (OMmsg);
}
