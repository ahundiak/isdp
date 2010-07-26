/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
	GRconstruct - construct method for the GRclippoly class.

Synopsis
    	GRconstruct(arglist)
	
	struct GRvg_construct *arglist;	generic input for all
			classes under GRvg.
Description
	This method loads the instance data of the GRclippoly
	object.  

	Additional input information, other than what is 
	specified in the generic GRvg_construct structure, is
	needed by this method.  The additional information is 
	the classname of the underlying geometry which 
	defines the curve of the curve prism.

	This information is passed in the GRvg_construct structure as
	class_attr.  This is done as follows:

	struct GRvg_construct arglist;

	arglist.class_attr = classname;
	
Diagnostics
	The possible return codes values in the arglist->msg 
	field are:

	MSSUCC - successful completion
	MSFAIL - error
Notes
	None.

History
	MAS  	05/27/87 	Design date.

\*/

class implementation GRclippoly;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "grerr.h"
#include "refdef.h"
#include "OMmacros.h"

from GRmodule import GRmdaddwrng;

method GRconstruct(struct GRvg_construct *arglist)
{
    IGRlong i;				/* loop index			*/
    IGRlong OMmsg;			/* local return codes		*/
    IGRlong msg;    

    GRrange range;			/* range for R-tree		*/

    struct GRvg_construct local_arglist;
    struct IGRcv_prism *prism;
    struct GRmd_env local_env;
    struct GRsymbology symb;
					
    OMmsg = OM_S_SUCCESS;		/* initialize return values	*/
    *(arglist->msg) = MSSUCC;

    local_arglist = *arglist;
					/* set the properties		*/
    me->properties = arglist->properties | GRIS_NEW;

			    		/* display attributes		*/
    if (arglist->display)
    {
	symb.display_attr = *(arglist->display);
    }
    symb.level =  arglist->level;
					/* load symbology into element	*/
    om$send(msg = message GRvg.GRputsymb(&msg,&symb),
            senderid = my_id,
	    targetid = my_id);
					/* pointer to geometry		*/
    prism = (struct IGRcv_prism *)arglist->geometry;

    if (arglist->env_info->md_env.matrix_type != MAIDMX)
    {
	MAidmx(&msg,local_env.md_env.matrix);
	local_env.md_env.matrix_type = MAIDMX;
	local_env.md_id.osnum = arglist->env_info->md_id.osnum;
    }
    else
    {
        local_env = *(arglist->env_info);
    }
    local_arglist.env_info = &local_env;
    local_arglist.env_info->md_id.objid = NULL_OBJID;

    local_arglist.geometry = (IGRchar *)&prism->curve;

				/* construct object			*/
    OMmsg = om$construct(
	   classname = arglist->class_attr,
	   p_objid = &me->cv_objid,
	   msg = message GRgraphics.GRconstruct(&local_arglist));

    if (OMmsg & 1)
    {
	for (i=0; i<16; ++i)
	{
	    me->matrix[i] = prism->matrix[i];
	}

	me->height = prism->height;

        /* 
	 * compute the range of the reference file attachment
	 * in the coordinate system of the master file for
	 * insertion in the master file R-tree.
	 *
	 */
	
	MAcpextents(&msg,prism,range,&range[3]);

	for (i=0; i<3 && (1 & *arglist->msg); ++i)
	{
	    if ((range[i] < GRDGNLIMITS_MIN_D) || 
		(range[i+3] > GRDGNLIMITS_MAX_D))
	    {
		*arglist->msg = GRSDGNEXCEED;		
	    }
	}
	if ( ! ( 1 & *arglist->msg))
	{
				/* delete the polygon		*/
	    om$send(
		msg = message GRgraphics.GRdelete
				(&msg,&local_env),
		targetid = me->cv_objid);
	}
	else
	{
	    if (! (IF_NULL_OBJID(arglist->env_info->md_id.objid)))
	    {
				/* add to R-tree			*/
    	        OMmsg = om$send(mode = OM_e_wrt_object,
               	   msg = message GRmodule.GRmdaddwrng
		  	(&msg,range,&my_id),
               	   senderid = my_id,
               	   targetid = arglist->env_info->md_id.objid,
                   targetos = arglist->env_info->md_id.osnum);

    	    	if (! (1 & OMmsg & msg))
    	    	{
		    *(arglist->msg) = MSFAIL;
		    OMmsg = OM_E_ABORT;

				/* delete the polygon		*/
		    om$send(
	    	        msg = message GRgraphics.GRdelete
			    (&msg,&local_env),
	    	        targetid = me->cv_objid);
	   	}
	    }
	}
    }
  

    return( OMmsg );
}
end implementation GRclippoly;
