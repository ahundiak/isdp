class implementation SKcompcurve;

#include "EMS.h"
#include <stdio.h>
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "gocmacros.h"
#include "EMcp.h"

method SKintcopy(
	IGRlong 	*EMmsg; 	
        IGRushort options;
	struct GRmd_env *obj_mdenv;
	struct GRmd_env *new_mdenv;
	GRobjid 	*newobjid;
	struct EMcp_info *copy_info)

		
{
   IGRboolean           cc_copy_exists;
   IGRshort             props, clear_bits;
   IGRlong              OM_stat;
   IGRlong   		mthd_stat;
   GRobjid              compid;
   struct GRid          cc_GRid;
   IGRuint       	count;
   IGRlong              i;
   OM_S_CHANSELECT      composite_chan;
   void                 EMcpsearch ();

   /* ********************************************************************* */

   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   mthd_stat = 1;

   /*
    * find out if I have been already copied or not.
    * If so, return my counter part's objid and I am all done
    */
	
   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
               &cc_copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   if (cc_copy_exists) goto wrapup;

   /* construct and copy the composite surface object */

   OM_stat = om$construct_and_copy(object = me, 
	      osnum = new_mdenv->md_id.osnum, p_objid = newobjid);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

/*
 * If the option was specified to copy associatively then update
 * the copy list maintained by the graph manager.
 * pp 07/29/91
 */

   if (options & SK_OPT_COPY_ASSOCIATIVE)
   {
     int cpinx = 0;
     struct GRid my_grid;

     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;

     EMget_clone_pos(&mthd_stat,NULL,&my_grid, copy_info, &cpinx, 
                     NULL);
     if (mthd_stat == MSFAIL)
     {
      cpinx = -1;
      mthd_stat = MSSUCC;
     }
     else
      copy_info->graph_info.graph_array[cpinx].clone = (*newobjid);
   }

   /*
    * put my_id and my counter part's id in the copy_info
    */

   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
               &cc_copy_exists);
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

   props = 0;
   OM_stat = om$send (msg = message GRvg.GRgetprops(&mthd_stat,&props),
       	  targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   OM_stat = EMmake_chanselect (GRcmpowner_to_components, &composite_chan);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
	
   OM_stat = om$get_channel_count(object = me, 
                 p_chanselect = &composite_chan, count = &count);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   cc_GRid.objid = *newobjid;
   cc_GRid.osnum = new_mdenv->md_id.osnum;

   /*
    * Copying all the components.
    */

   for (i = 0; (i < (IGRint) count) ; ++i)
   {
      OM_stat = om$send(msg = message SKgeometry.SKintcopy
                              (&mthd_stat, options, obj_mdenv, new_mdenv, 
                               &compid, copy_info), 
	         	senderid = my_id, p_chanselect = &composite_chan,
		        from = i, to = i);
      EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

      OM_stat = om$send(msg = message GRconnector.GRrigidconn (&mthd_stat,
			      &cc_GRid, &i),
      	                targetid = compid,
                        targetos = new_mdenv->md_id.osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

   } /* for (i = 0; (i < (IGRint) count) ; ++i) */

wrapup:
     EMWRAPUP (*EMmsg, OM_stat, "SKcompcurve.EMintcopy");
     return(OM_stat);
}
end implementation SKcompcurve;
