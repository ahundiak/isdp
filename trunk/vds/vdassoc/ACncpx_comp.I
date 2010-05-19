/* $Id: ACncpx_comp.I,v 1.7 2002/06/07 14:42:51 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/ACncpx_comp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACncpx_comp.I,v $
 *	Revision 1.7  2002/06/07 14:42:51  ramarao
 *	Implemented To Do List.
 *	
 *	Revision 1.6  2002/06/03 19:18:36  ramarao
 *	Used a seperate flag ( CMPtoggle ) for recompute info.
 *	
 *	Revision 1.5  2002/05/22 21:52:01  ramarao
 *	Added a bit of code to debug out the recompute info.
 *	
 *	Revision 1.4  2001/11/10 17:11:29  ramarao
 *	Fixed TR# 4425.
 *	
 *	Revision 1.3  2001/03/03 21:21:33  ramarao
 *	Do special processing for neat plates ( nci_macros ).
 *	
 *	Revision 1.2  2001/01/18 19:08:47  ramarao
 *	Merged Service Pack Files to 262 pload.
 *	
# Revision 1.1  2000/10/05  15:04:28  pinnacle
# Created: vds/vdassoc/ACncpx_comp.I by jpulapar for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  20:10:38  pinnacle
# Fixed Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/05/17  20:38:02  pinnacle
# Replaced: vdassoc/ACncpx_comp.I for:  by ashankar for vds.240
#
# Revision 1.1  1996/02/26  04:15:52  pinnacle
# Created: vdassoc/ACncpx_comp.I by rchennup for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      02/26/96	Ch.Rama Rao	Fix for Update problem TR#179600513
 *      05/17/96        Shankar         Fix for Cond. Macro update problem
 *                                      TR#179601964
 *	10/30/97	ah		Warning message
 *      10/02/00        Jayadev         abort if the compute of macro fails
 * -------------------------------------------------------------------*/

class implementation ACncpx;

#define AS_DEBUG
#define VDS_CORRECTION 1

extern char *regcmp();
extern char *regex();
extern char *strpbrk();

#include <alloca.h>
#include "ASmacroi.h"
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "godef.h"
#include "grownerdef.h"
#include "grownmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "gocmacros.h"
#include "EMSkey.h"
#include "ASmsg.h"
#include "msmacros.h"
#include "VDobj.h"

from ACcpx_defn import 	ACgive_name, ACgive_temp_desc, ACgive_feet_desc;
from ACcpx_defn import 	ACintpt_foot;
from ACmacro_defn import 	ACgive_upscan;
from ACpretend  import 	ACfind_parent;
from ACpretend  import 	ACrebind;
from ACconst  import 	ACget_foot_in_mac;
from EMSpointerA import EMstore_key_from_id, EMstore_id_from_key;

extern IGRboolean ASbroadcast_in_progress;

method NDupdate(int *msg, cn_type, count;
                struct GRid *parents;
                int *parent_state;
                struct GRid *context,*new_objid;
                struct GRmd_env *md_env)
{
   long status,loc_msg;
// long stat;              // Not used
   struct GRid mac_def;
   IGRlong msg1;
   enum GRdpmode dpmode;
   struct GRid cur_mod;
   IGRchar mac_classname[100];
   IGRchar         macName[40];
   struct GRid     my_GRid;
   struct GRobj_env    myOE;

   my_GRid.objid = my_id;
   my_GRid.osnum = OM_Gw_current_OS;

   myOE.obj_id  = my_GRid;
   myOE.mod_env = *md_env;

   if( VDgetCMPtoggle() )
   {
       printf( "Recomputing --- " );
       vdobj$Print( objID = &my_GRid );
   }

   status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
   as$status(action = RET_STATUS);


   status = om$get_classname(osnum = mac_def.osnum,objid =mac_def.objid ,
               classname = mac_classname);

   if((om$is_ancestry_valid(subclassname = mac_classname,
                      superclassname = "ACcond_def")!=OM_S_SUCCESS))
   {

  		if(context->objid == NULL_OBJID)
 		{
  /* Not in a macro ---> with respect to message to check parent status
     and to perform erase/display. NDcompute_node will then be received*/ 

  		   status = om$send(msg = message ACcpx.NDupdate(msg,cn_type,count,
							   parents, parent_state,context,new_objid,md_env),
		   				targetid = my_id,
		   				mode = OM_e_wrt_message);
		   if( ! ( status & 1 & (*msg) ) )
		   {
		     VDaddToDoList( myOE );
		   }
		   else
		   {
		     VDremoveFromToDoList( myOE );
		   }

  		   GR_NOTIFY_LISTENERS((long *) msg,&status,GR_GEOM_MODIFIED);
                   // abort status returned
                   if(!(status&1)) return OM_W_ABORT;
 		}
		else
 		{
#ifdef VDS_CORRECTION
/*	START VDS CORRECTION	-	Rama Rao	*/
        /* Get cur mod id for display */
                status = ex$get_cur_mod(id = &cur_mod.objid, 
					osnum = &cur_mod.osnum );
        	as$status();

        /*| erase */
                dpmode = GRbehe;
                status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                   &md_env->md_env.matrix_type,
                   md_env->md_env.matrix,
                   &dpmode,
                   &cur_mod),
                                targetid = my_id);
                as$status();
/*	END VDS CORRECTION    -       Rama Rao        */
#endif
  			/*in a macro --> transfer context*/
  			status = om$send(msg = message ACncpx.ACcontext_compute 
				((long *)msg, cn_type, count, 
				parents, context, md_env),
			targetid = my_id);

  			new_objid->objid = my_id;
  			new_objid->osnum = OM_Gw_current_OS;
		   if( ! ( status & 1 & (*msg) ) )
		   {
		     VDaddToDoList( myOE );
		   }
                   else
                   {
                     VDremoveFromToDoList( myOE );
                   }
                   // abort status returned
                   if(!(status&*msg&1)) return OM_W_ABORT; 
#ifdef VDS_CORRECTION
/*	START VDS CORRECTION	-	Rama Rao	*/
        /*| display */
                dpmode = GRbd;
                status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                   &md_env->md_env.matrix_type,
                   md_env->md_env.matrix,
                   &dpmode,
                   &cur_mod),
                                targetid = my_id);
                as$status();
/*      END VDS CORRECTION    -       Rama Rao        */  
#endif
 		}
	}
	else
	{	
#ifdef VDS_CORRECTION
/**     START VDS_CORRECTION **/
	   if( context->objid != NULL_OBJID )
	   {
/**     END VDS_CORRECTION  - Shankar  **/
#endif
		/* Get cur mod id for display */
	 	status = ex$get_cur_mod(id = &cur_mod.objid, 
					osnum = &cur_mod.osnum);
    		as$status();

		/*| erase */
   		dpmode = GRbehe;
   		status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                   &md_env->md_env.matrix_type,
                   md_env->md_env.matrix,
                   &dpmode,
                   &cur_mod),
            			targetid = my_id);
   		as$status();

		   /** get context object from occurence object **/
	        /* Following Line is commented for TR# 4425 */
  	 	//COm_get_condit_def_hdr(&msg1,&mac_def,context,count,parents,md_env);

		/** compute context **/
  		status = om$send(msg = message ACncpx.ACcontext_compute 
				((long *)msg, cn_type, count, parents, context, md_env),
						targetid = my_id);
  		new_objid->objid = my_id;
  		new_objid->osnum = OM_Gw_current_OS; 
		   if( ! ( status & 1 & (*msg) ) )
		   {
		     VDaddToDoList( myOE );
		   }
                   else
                   {
                     VDremoveFromToDoList( myOE );
                   }
                // abort status returned
                if(!(status&1)) return OM_W_ABORT;

		/*| display */
   		dpmode = GRbd;
   		status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
                   &md_env->md_env.matrix_type,
                   md_env->md_env.matrix,
                   &dpmode,
                   &cur_mod),
            			targetid = my_id);
   		as$status();
#ifdef VDS_CORRECTION
/**       START VDS_CORRECTION  **/
	   }
	   else
	   {
  		status = om$send(msg = message ACcpx.NDupdate(msg,cn_type,count,
						   parents, parent_state,context,new_objid,md_env),
		   				targetid = my_id,
		   				mode = OM_e_wrt_message);
		   if( ! ( status & 1 & (*msg) ) )
		   {
		     VDaddToDoList( myOE );
		   }
                   else
                   {
                     VDremoveFromToDoList( myOE );
                   }
  		GR_NOTIFY_LISTENERS((long *) msg,&status,GR_GEOM_MODIFIED);
	    }
/**       END VDS_CORRECTION    - Shankar  **/
#endif

	}
	if((*msg)&1) *msg = ND_COMP_SUCC;


        /*
	 * Do special Processing for neat Plates ( nci_macro class ).
	 */
        status = om$get_classname( osnum = my_GRid.osnum,
				   objid = my_GRid.objid ,
               		           classname = mac_classname );

        if( om$is_ancestry_valid(
		      subclassname   = mac_classname,
                      superclassname = "nci_macro") == OM_S_SUCCESS )
	{
	    vdobj$Get( objID = &my_GRid, macName = macName );
	    if( !strcmp( macName, "neat_plate" ) )
	    {
	        VDcheckNeatPlateForBevels( my_GRid, *md_env );
	    }
	}

	return status;
}

end implementation ACncpx;
