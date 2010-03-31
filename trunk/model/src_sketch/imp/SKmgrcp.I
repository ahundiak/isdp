/* ###################   APOGEE COMPILED   ################## */
class implementation SKmgr;

#include "EMS.h"
#include <stdio.h>
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "gocmacros.h"
#include "EMcp.h"

from SKvariable import SKintcopy;
from SKgeometry import SKintcopy;
from SKconstraint import SKintcopy,SKconnect_to_skmgr;

method SKintcopy(
	IGRlong 	*EMmsg; 	
        IGRushort options;
	struct GRmd_env *obj_mdenv;
	struct GRmd_env *new_mdenv;
	GRobjid 	*newobjid;
	struct EMcp_info *copy_info)
{
   IGRboolean            copy_exists;
   IGRshort              props, clear_bits;
   IGRlong               i, OM_stat, mthd_stat;
   GRobjid               compid,ptid,const_id;
   struct GRid           mycp_GRid;
   IGRuint               count;
   OM_S_CHANSELECT       composite_chan,to_vars,to_constrs;
   void                  EMcpsearch ();

   /*  ******************************************************************** */

   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;

   /*
    * find out if I have been already copied or not.
    * If so, return my counter part's objid and I am all done
    */
	
   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, 
               &copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   if (copy_exists) goto wrapup;

   /* construct and copy myself */

   OM_stat = om$construct_and_copy(object = me, 
	      osnum = new_mdenv->md_id.osnum, p_objid = newobjid);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * Initialise the save state information to NULL to be safe.
    */

   OM_stat = om$send (msg = message SKmgr.SKinit(&mthd_stat,
                            SK_OPT_NO_STORE_PROPS |
                            SK_OPT_NO_STORE_ORIENTATION,
                            NULL,NULL,NULL,NULL),
                      targetid = *newobjid,
                      targetos = new_mdenv->md_id.osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   /*
    * put my_id and my counter part's id in the copy_info
    */

   EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, 
               &copy_exists);
   EMerr_hndlr(!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   mycp_GRid.objid = *newobjid;
   mycp_GRid.osnum = new_mdenv->md_id.osnum;

   /*
    * clear GR_RIGID_RELATIONSHIP bit
    */

   clear_bits = 0;
   props = GR_RIGID_RELATIONSHIP;
   OM_stat = om$send(msg = message GRvg.GRchgprops(&mthd_stat,
                             &clear_bits, &props),
       	  targetid = mycp_GRid.objid, targetos = new_mdenv->md_id.osnum);
   EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

   /* 
    * copy my component curves
    */

   OM_stat = EMmake_chanselect (GRcmpowner_to_components, &composite_chan);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
	
   OM_stat = om$get_channel_count(object = me, 
                 p_chanselect = &composite_chan, count = &count);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   for (i = 0; (i < (IGRint) count) ; ++i)
   {
      OM_stat = om$send(msg = message SKgeometry.SKintcopy
                  (&mthd_stat, options, obj_mdenv, new_mdenv, 
                   &compid, copy_info), 
		    senderid = my_id, p_chanselect = &composite_chan,
		    from = i, to = i);
      EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

      OM_stat = om$send(msg = message GRconnector.GRrigidconn (&mthd_stat,
			&mycp_GRid, &i),
	    targetid = compid, targetos = new_mdenv->md_id.osnum);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

   } /* for (i = 0; (i < (IGRint) count) ; ++i) */

/*
 * Copying all the points.
 */
 
   OM_stat = om$make_chanselect(channame = "SKmgr.to_vars",
                                p_chanselect = &to_vars);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

   OM_stat = om$get_channel_count(object = me, 
                 p_chanselect = &to_vars, count = &count);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   for (i=0;i<count;i++)
   {
    OM_stat = om$send(msg = message SKvariable.SKintcopy
                  (&mthd_stat, options, obj_mdenv, new_mdenv, 
                   &ptid, copy_info), 
		    senderid = my_id, p_chanselect = &to_vars,
		    from = i, to = i);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

    OM_stat = om$send (msg = message SKmgr.SKconnect_to_ptvar(&mthd_stat,
                          ptid,NULL,
                          0,i),
                    targetid = mycp_GRid.objid,
                    targetos = mycp_GRid.osnum);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
   }

/*
 * Copying all the constraints.
 */

   OM_stat = om$make_chanselect(channame = "SKmgr.to_constrs",
                                p_chanselect = &to_constrs);
   EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail, wrapup);

   OM_stat = om$get_channel_count(object = me, 
                 p_chanselect = &to_constrs, count = &count);
   EMerr_hndlr(!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

   for (i=0;i<count;i++)
   {
    OM_stat = om$send(msg = message SKconstraint.SKintcopy
                  (&mthd_stat, options, obj_mdenv, new_mdenv, 
                   &const_id, copy_info), 
		    senderid = my_id, p_chanselect = &to_constrs,
		    from = i, to = i);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

    OM_stat = om$send (msg = message SKconstraint.SKconnect_to_skmgr(&mthd_stat,
                             mycp_GRid.objid,NULL,i,OM_K_MAXINT),
                       targetid = const_id,
                       targetos = mycp_GRid.osnum);
    EMerr_hndlr(!(1&OM_stat&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);
   }

wrapup:

     EMWRAPUP (*EMmsg, OM_stat, "SKmgr.EMintcopy");
     return(OM_stat);
}

end implementation SKmgr;
