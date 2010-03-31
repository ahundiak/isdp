class implementation SKgeometry;

#include "ma.h"
#include "OMmacros.h"
#include "emsmacros.h"
#include "gocmacros.h"
#include "EMcp.h"

from SKvariable import SKintcopy;

method SKintcopy(
	IGRlong 	*EMmsg; 	
        IGRushort options;
	struct GRmd_env *obj_mdenv;
	struct GRmd_env *new_mdenv;
	GRobjid 	*newobjid;
	struct EMcp_info *copy_info)

		
{
   IGRboolean            gm_copy_exists;
   IGRlong               OM_stat;
   IGRlong   mthd_stat;
   GRobjid               ptid;
   IGRshort              props, clear_bits;
   struct GRid           gm_GRid;
   IGRuint       count;
   IGRint                i;
   OM_S_CHANSELECT       to_defpts;
   void                  EMcpsearch ();

   /* ******************************************************************* */

   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   /*
    * find out if I have been already copied or not.
    * If so, return my counter part's objid and I am all done
    */
	
   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
               &gm_copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   if (gm_copy_exists) goto wrapup;

   OM_stat = om$construct_and_copy(object = me, 
	      osnum = new_mdenv->md_id.osnum, p_objid = newobjid);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

/*
 * If the option was specified to copy associatively then update
 * the copy list maintained by the graph manager if an entry exists
 * for the same.
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

/* end pp 07/29/91 */
   /*
    * put my_id and my counter part's id in the copy_info
    */

   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
               &gm_copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   clear_bits = 0;
   props = GR_RIGID_RELATIONSHIP;
   OM_stat = om$send(msg = message GRvg.GRchgprops(&mthd_stat,
                             &clear_bits, &props),
       	  targetid = *newobjid, targetos = new_mdenv->md_id.osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
	

   OM_stat = om$make_chanselect(channame = "SKgeometry.to_defpts",
                                p_chanselect = &to_defpts);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

   OM_stat = om$get_channel_count(object = me, 
                p_chanselect = &to_defpts, count = &count);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   gm_GRid.objid = *newobjid;
   gm_GRid.osnum = new_mdenv->md_id.osnum;

/*
 * Copy the points.
 */

   for (i=0;i<count;i++)
   {
    OM_stat = om$send(msg = message SKvariable.SKintcopy
                  (&mthd_stat, options, obj_mdenv, new_mdenv, 
                   &ptid, copy_info), 
		    senderid = my_id, p_chanselect = &to_defpts,
		    from = i, to = i);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

    OM_stat = om$send (msg = message SKgeometry.SKconnect_to_pt(&mthd_stat,
                             NULL,ptid,OM_K_MAXINT,i),
                       targetid = gm_GRid.objid,
                       targetos = gm_GRid.osnum);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
   }

wrapup:

     EMWRAPUP (*EMmsg, OM_stat, "SKgeometry.EMintcopy");
     return(OM_stat);
}

end implementation SKgeometry;
