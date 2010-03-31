/* ###################   APOGEE COMPILED   ################## */
class implementation EMScompsurf;

#include "EMS.h"
#include <stdio.h>
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "gocmacros.h"
#include "EMcp.h"
#include "ndmacros.h" /* For nd$get_clone */



method EMintcopy(
	IGRlong 	*EMmsg; 	
	struct GRmd_env *obj_mdenv;
	struct GRmd_env *new_mdenv;
	GRobjid 	*newobjid;
	struct EMcp_info *copy_info;
	IGRushort bdry_options, sf_options)

/*
Description

	This file contains EMintcopy implementation for composite 
        surface.

  *EMmsg	is the method completion code.
  *obj_mdenv 	is the struct describing objects's
		present environment.
  *new_mdenv 	is the struct describing copy's
		environment.
  *newobjid 	is the objid of the copied composite
		surface.
  *copy_info 	is a struct storing the copy information
		temporarily. It is used during the copy process.

Algorithm
		The following sequence of operations are performed
		in copying a composite surface:
		1) construct and the copy the composite surface
		   object.
		2) send a message to its components. The
		   components may be simple surfaces or
		   composites (dpr objects or primitive solids).
		3) connect the copied composite surface 
		   objects to the copies of the components.
		4) change the property bits appropriately
		   via GRvg.GRchgprops.


History
		RC     03/04/87 : Creation date.
		RC     10/14/87 : Added code to copy acoss 
				  EMSsurface.to_associations channel.
		RC     10/29/87 : Modified for version 1.1.0
		SM     06-Jul-89: Added bdry_options and sf_options arguments
*/
		
{
   IGRboolean            is_associative_class;
   IGRboolean            cs_copy_exists;
   IGRshort              props, clear_bits;
   IGRlong               OM_stat;
IGRlong   mthd_stat;
   GRobjid               compid;
   struct GRid           cscp_GRid;
   IGRuint       count;
   IGRlong               i;
   OM_S_CHANSELECT       composite_chan;
   void                  EMcpsearch ();

   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   /*
    * find out if I have been already copied or not.
    * If so, return my counter part's objid and I am all done
    */
	
   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
               &cs_copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   if (cs_copy_exists) goto wrapup;

   if (EFisAncestryValid(&mthd_stat, my_id, OM_Gw_current_OS,
                        OPP_EMAsurface_class_id, FALSE))
    is_associative_class = TRUE;
   else
    is_associative_class = FALSE;

    if (is_associative_class && (sf_options & EMS_COPY_ASSOCIATIVE))
    {
      struct GRid my_grid,my_clone;

      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;
      my_clone.objid = NULL_OBJID;
/*
      nd$get_clone(nb_obj = 1, p_original = &my_grid, p_clone = &my_clone);
*/

      if(!(IF_NULL_OBJID(my_clone.objid)))
      {
       *newobjid = my_clone.objid;

       EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
                   &cs_copy_exists);
       EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
       goto wrapup;
      }
    }

   /* construct and copy the composite surface object */

   OM_stat = om$construct_and_copy(object = me, 
	      osnum = new_mdenv->md_id.osnum, p_objid = newobjid);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * put my_id and my counter part's id in the copy_info
    */

   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
               &cs_copy_exists);
		    	 
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * clear GR_RIGID_RELATIONSHIP bit
    */

   clear_bits = 0;
   props = GR_RIGID_RELATIONSHIP;
   OM_stat = om$send(msg = message GRvg.GRchgprops(&mthd_stat,
                             &clear_bits, &props),
       	  targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   OM_stat = EMmake_chanselect (GRcmpowner_to_components, &composite_chan);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
	
   OM_stat = om$get_channel_count(object = me, 
                 p_chanselect = &composite_chan, count = &count);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   cscp_GRid.objid = *newobjid;
   cscp_GRid.osnum = new_mdenv->md_id.osnum;

   for (i = 0; (i < (IGRint) count) ; ++i)
   {
      OM_stat = om$send(msg = message EMSsurface.EMintcopy
                  (&mthd_stat, obj_mdenv, new_mdenv, &compid, copy_info, 
		   bdry_options, sf_options),
		    senderid = my_id, p_chanselect = &composite_chan,
		    from = i, to = i);
      EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

      OM_stat = om$send(msg = message GRconnector.GRrigidconn (&mthd_stat,
			&cscp_GRid, &i),
	    targetid = compid, targetos = new_mdenv->md_id.osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

   } /* for (i = 0; (i < (IGRint) count) ; ++i) */

/*
 * If the copy has been initiated by my roots then I need to inform the
 * associative graph manager about my clone object so that connections
 * can take place across my father child channel.
 * pp 05/05/91
 */
     if ((sf_options & EMS_COPY_ASSOCIATIVE) && is_associative_class)
     {
       struct GRid original,clone;
       IGRushort nb_object;

       nb_object = 1;
       original.objid = my_id;
       original.osnum = OM_Gw_current_OS;
       clone.objid = *newobjid;
       clone.osnum = new_mdenv->md_id.osnum;
     

       OM_stat = om$send (msg = message EMAsurface.EMcopy_recomp_info (
                               &mthd_stat, obj_mdenv, new_mdenv, *newobjid,
                               copy_info, bdry_options, sf_options),
                         targetid = my_id);
       EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
     }

     if (is_associative_class && !(sf_options & EMS_COPY_ASSOCIATIVE))
     {
       struct GRid ret_GRid;
       ret_GRid.objid = NULL_OBJID;
       OM_stat = om$send (msg = message NDnode.NDmove_to_root(&mthd_stat,
                                &ret_GRid, new_mdenv),
                          targetid = *newobjid,
                          targetos = new_mdenv->md_id.osnum);
       EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

       if (ret_GRid.objid != (*newobjid))
       {
        *newobjid = ret_GRid.objid;
        EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
    	            &cs_copy_exists);
        EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
       }
     } 

 
wrapup:
   GR_NOTIFY_LISTENERS(EMmsg, &OM_stat, GR_COPIED);

     EMWRAPUP (*EMmsg, OM_stat, "EMScompsurf.EMintcopy");

     return(OM_stat);
}

end implementation EMScompsurf;
