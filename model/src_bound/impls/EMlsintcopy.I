/* ###################   APOGEE COMPILED   ################## */
/* ------

     CHANGE HISTORY:
	RC	12/04/86  : Creation date	
	RC      03/04/86  : Modified
	SS	08/24/87  : Changed the connect_edges flag to options
			    to provide for options like - making a
                            model-space copy of the loopset, etc.
        RC      10/28/87  : MOdified for version 1.1
	SS	06/15/89  : When copying into a foreign object space,
			    care is now taken to see that the copy is
			    no longer treated as a shell.
----- */

class implementation EMSloopset;


#include "EMS.h"
#include "EMSopt.h"
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMcp.h"
#include "EMSprop.h"
#include "EMSobjmgrdef.h"

extern GRclassid OPP_EMSloopset_class_id;

method EMintcopy(
   IGRlong 	            *EMmsg; 
   struct GRmd_env	    *mdenv;
   GRspacenum               obj_osnum;
   GRspacenum	            new_osnum;
   IGRushort        options; 
   GRobjid 	            *newobjid;
   struct EMcp_info         *copy_info)
{
  IGRboolean	       shell_ls;
  IGRlong              OM_stat, mthd_stat;
  GRobjid              loop_id;
  IGRuint      count;
  IGRint               i;
  IGRboolean           ls_copy_exists;
  OM_S_CHANSELECT      loopset_chan, loop_chan;	

  *EMmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  /*
   * find out if I have been already copied or not.
   * If so, return my counter part's objid and I am 
   * all done
   */
	
  EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 0, &ls_copy_exists);
  EMerr_hndlr (!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  if (ls_copy_exists) goto wrapup;

  /* construct and copy the loopset object */
	
  if (options & EMS_COPY_XYZ)
  {
      OM_stat = om$construct (msg = message EMSloopset.EMset_props
		     (&mthd_stat, EMLS_XYZ, EMS_O_SET), 
                     classid = OPP_EMSloopset_class_id, osnum = new_osnum,
                     p_objid = newobjid);
  }
  else
  {
     /*
      * During the construct and copy, do not copy the property bit
      * indicating that this is a shell loopset. This is set only after
      * it is determined that the copy should be made a shell also.
      */

     if (shell_ls = ME.EMSloopset->ls_props & EMLS_SHELL)
       ME.EMSloopset->ls_props &= ~EMLS_SHELL;
     OM_stat = om$construct_and_copy(object = me, obj_osnum = obj_osnum,
		      osnum = new_osnum, p_objid = newobjid);
     if (shell_ls)
       ME.EMSloopset->ls_props |= EMLS_SHELL;
  }
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  /*
   * put my_id and my counter part's id in the copy_info
   */

  EMcpsearch (&mthd_stat, my_id, newobjid, copy_info, 3, &ls_copy_exists);
  EMerr_hndlr (!(1&mthd_stat), *EMmsg, EMS_E_Fail, wrapup);

  OM_stat = EMmake_chanselect(EMSloopset_to_loops, &loopset_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);
	
  OM_stat = om$get_channel_count(osnum = obj_osnum, object = me,
                  p_chanselect = &loopset_chan, count = &count);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  OM_stat = EMmake_chanselect (EMSloop_to_outter, &loop_chan);
  EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  for (i = 0; (i < (IGRint) count) ; ++i)
  {
     OM_stat = om$send(msg = message EMSboundary.EMintcopy
	         (&mthd_stat, mdenv, obj_osnum, new_osnum, options,
                  &loop_id, copy_info),
		senderid = my_id, p_chanselect = &loopset_chan,
		from = i, to = i);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);
		
     OM_stat = om$send(msg = message Root.connect (loopset_chan,
                       0, loop_id, new_osnum, loop_chan, i),
		 targetid = *newobjid, targetos = new_osnum);
     EMerr_hndlr (!(1&OM_stat), *EMmsg, EMS_E_OMerror, wrapup);

  } /* for (i = 0; (i < (IGRint) count) ; ++i) */

  /*
   * If this loopset was a shell, and has continued to remain natural, and
   * the it is not a copy into model-space, and the object space into which
   * it is being copied is the same as the current one, then make the copy of
   * this loopset also a shell. Else, leave it alone.
   */

  if (ME.EMSloopset->ls_props & EMLS_SHELL &&
      ME.EMSloopset->ls_props & EMLS_NATURAL &&
      !(options & EMS_COPY_XYZ) &&
      obj_osnum == new_osnum && obj_osnum == OM_Gw_current_OS)
    {
    extern IGRboolean EMlsvalidator();
    extern IGRlong EMputshobj();

    OM_stat = EMputshobj (&mthd_stat, NULL, EMSshobj_sfbdry, OM_Gw_current_OS,
               EMlsvalidator, *newobjid);
    if (!EMSerror (OM_stat & mthd_stat))
      om$send (msg = message EMSloopset.EMset_props (&mthd_stat,
       EMLS_SHELL, EMS_O_ON), targetid = *newobjid);
    }

wrapup:
	EMWRAPUP (*EMmsg, OM_stat, "In EMSloopset.EMintcopy");	
	return(OM_stat);
}
end implementation EMSloopset;
