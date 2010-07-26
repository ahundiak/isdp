/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRgraphics

     METHOD NAME:	GRrcopy

     Abstract: 	This method copies a graphics object to the object
		space described in the structure new_dsenv.

-----
%SC%    

     GRrcopy(msg,obj_dsenv,new_dsenv,newobjid)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *obj_dsenv	   GRmd_env	 struct describing object's present
				  environment
     *new_dsenv	   GRmd_env	 struct describing copy's environment

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
     *newobjid	  GRobjid	 objid of the copied object

-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:

-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
-----
%CH%

     CHANGE HISTORY:
	
	SDG     05/18/86 : Design date.
	MAS	08/12/86 : Revision date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
	This method calls the OM function that constructs an
	exact copy of the given object and places that copy in the
	object space described by the md_env structure "new_dsenv".
	The copied object is then transformed to the environment of 
	the new object space.
 
----*/
/*EH*/

class implementation GRgraphics;

#include "grimport.h"
#include "msdef.h"
#include "godef.h"
#include "madef.h"
#include "OMmacros.h"
#include "gocmacros.h"  
#include "grownmacros.h"

from GRmodule import GRmdaddwrng;

extern    IGRboolean    MAinvmx();
extern    IGRboolean    MAmulmx();
extern    IGRboolean    MAtypemx();
extern    IGRboolean    MAidmx();

method GRrcopy(IGRlong *msg; struct GRmd_env *obj_dsenv;
	       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{

	IGRboolean   set_bits;		/* properties flag	*/
	IGRboolean   not_in_rtree = 0;
	IGRboolean   world;

	IGRshort  mask;			/* mask for properties	*/
	IGRshort  mxsize = 4;		/* matrix size		*/
	IGRshort mx_type;		/* type of tmatrix	*/

	IGRlong  status;		/* method return status	*/
	IGRlong  msg2;			/* math return code	*/

	IGRmatrix tmatrix;		/* transformation matrix*/

	IGRdouble *mx;	
	GRobjid  tempid;		/* temporary id of copy */
	struct GRmd_env  md_env;	/* environment structure*/

	GRrange  range;			/* my range		*/

	IGRmatrix invmx;		/* inverse matrix	*/

	*msg = MSSUCC;

	status = om$construct_and_copy(object = me,
           obj_osnum = OM_Gw_current_OS,
           osnum = new_dsenv->md_id.osnum,	
           p_objid = &tempid);

	if (status & 1)
	{				/* clear component bit and
					   the rtree bit		*/
	    mask = me->properties & (~GR_RIGID_RELATIONSHIP) 
		   | GRIS_NEW;


	    set_bits = -1;		/* replace properties		*/
	    om$send(mode = OM_e_wrt_object,
                msg = message GRgraphics.GRchgprops
		    (&msg2,&set_bits,&mask),
                senderid = my_id,
                targetid = tempid,
                targetos = new_dsenv->md_id.osnum);

	    if ( IF_NULL_OBJID(new_dsenv->md_id.objid) ||
		(mask & GRNOT_IN_RTREE))
	    {
		not_in_rtree = 1;
 	    }
	
	    if ( (obj_dsenv->md_env.matrix_type == MAIDMX) &&
	         (new_dsenv->md_env.matrix_type == MAIDMX))
	    {
	    	*newobjid = tempid;

	   	if (! not_in_rtree) 
		{ 	
		    world = FALSE;		
					/* get range to add to R-tree	*/
	       	    status = om$send(mode = OM_e_wrt_object,
                        msg = message GRgraphics.GRgetrang
			    (&msg2,&obj_dsenv->md_env.matrix_type,
			     obj_dsenv->md_env.matrix,&world,range),
                        senderid = my_id,
                        targetid = my_id);

	       	    if (status & 1)
	            {			/* add to the R-tree		*/
	       		status = om$send(mode = OM_e_wrt_object,
	         	    msg = message GRmodule.GRmdaddwrng
				(&msg2,range,&tempid),
                            senderid = my_id,
                            targetid = new_dsenv->md_id.objid,
                            targetos = new_dsenv->md_id.osnum);
		    }
		    if (! (1 & status & msg2))
		    {
			om$send(msg = message Root.delete(0),
			    senderid = *newobjid,
			    targetid = *newobjid,
			    targetos = new_dsenv->md_id.osnum);

		    }
		}
	    }
	    else
	    {
	   	if (new_dsenv->md_env.matrix_type != MAIDMX)
	   	{			
	    				/* matrix for new object space */
	    	    if (! MAinvmx(&msg2,&mxsize,new_dsenv->md_env.matrix,
				invmx))
		    {
			status = OM_E_ABORT;
			goto wrapup;
		    }
		    else
		    {
	    		MAmulmx(&msg2,&mxsize,&mxsize,&mxsize,invmx,
		    		obj_dsenv->md_env.matrix,tmatrix);
	    		MAtypemx(&msg2,tmatrix,&mx_type);
			mx = &tmatrix[0];
		    }
		}
		else
		{
		    mx = &obj_dsenv->md_env.matrix[0];
		    mx_type = obj_dsenv->md_env.matrix_type;
		}
		if (! not_in_rtree)
		{
		    world = FALSE;
 	   				/* get the range of the object */
	     	    status = om$send(mode = OM_e_wrt_object,
                       msg = message GRgraphics.GRgetrang
			  (&msg2,&obj_dsenv->md_env.matrix_type,
			   obj_dsenv->md_env.matrix,&world,range),
                       senderid = my_id,
                       targetid = my_id);

		    if (1 & status)
		    {
					/* add to the R-tree 		*/
	   	        status = om$send(mode = OM_e_wrt_object,
                           msg = message GRmodule.GRmdaddwrng
				(&msg2,range,&tempid),
                           senderid = my_id,
                           targetid = new_dsenv->md_id.objid,
                           targetos = new_dsenv->md_id.osnum);
		    }

		    if (! (1 & status & msg2))
		    {
			om$send(msg = message Root.delete(0),
			    senderid = *newobjid,
			    targetid = *newobjid,
			    targetos = new_dsenv->md_id.osnum);

		    }
		}		
		if (status & 1)
 		{
					/* load new module information	*/
		    MAidmx(&msg2,md_env.md_env.matrix);
		    md_env.md_env.matrix_type = MAIDMX;
		    md_env.md_id = new_dsenv->md_id;
	
	   				/* transform the copied object */
	   	    status = om$send(mode = OM_e_wrt_object,
                       msg = message GRgraphics.GRxform(
			  &msg2,&md_env,&mx_type,mx,newobjid),
                       senderid = my_id,
                       targetid = tempid,
                       targetos = new_dsenv->md_id.osnum);

		    if ( !(1 & status & msg2))
		    {
			om$send(
			    msg = message GRgraphics.GRdelete
				(&msg2,&md_env),
			    senderid = *newobjid,
			    targetid = *newobjid,
			    targetos = new_dsenv->md_id.osnum);
		    }
		}
	    }
	}


    wrapup:

	if ( ! ( status & 1))
	{
	    *msg = MSFAIL;
	}
	else
	{
	    gr$add_to_active_owner(
		msg = msg,
		mod_env = new_dsenv,
		objid = *newobjid);
	}

	GR_NOTIFY_LISTENERS(msg,&status,GR_COPIED);

	return(status);
}

end implementation GRgraphics;
