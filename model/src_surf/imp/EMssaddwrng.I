/* ###################   APOGEE COMPILED   ################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:  EMSsubbs

     METHOD NAME:  GRaddwrng

     Abstract:   This method adds an object to the R-tree
		 with respect to its range.

-----
%SC%    

     GRaddwrng ( EMmsg, md_env )

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     *md_env	  struct GRmd_env  object's environment information

-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     *EMmsg	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure


-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:  none.

     Methods:  EMput_range_in_rtree

-----
%RL%

-----
%NB%

     NOTES:  none

-----
%CH%

     CHANGE HISTORY:
	
	SAM	  07/05/88 : Creation date.
	SS	  08/31/88 : Modified to the new post-processing scheme
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

This message was overriden because to add the reduced range in the rtree.
 For instances like copy GRaddwrng at GRvg would add the geometric range
 in the rtree.
 EMput_range_in_rtree calculates the reduced range and puts in the rtree.
 The listners are notified because GRvg GRaddwrng message notifies the
 listners.

----*/
/*EH*/

class implementation EMSsubbs;

#include "EMS.h"
#include "emserr.h"
#include "emsmacros.h"
#include "EMSerrordef.h"
#include "EMSopt.h"
#include "godef.h"
#include "gocmacros.h"

method GRaddwrng(IGRlong *EMmsg; struct GRmd_env *md_env)
{
 IGRboolean		notify, addtree;
 IGRlong		OM_stat;		/* OM return status		    */

 *EMmsg = EMS_S_Success;
 OM_stat = OM_S_SUCCESS;

 notify = EMcheck_inhibit_postproc();

 OM_stat = om$send(msg = message EMSsubbs.EMput_range_in_rtree(
				EMmsg, NULL, NULL, NULL, CONSTRUCTIONAL, &md_env->md_id),
				   targetid = my_id);
 EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

 wrapup:
   if (notify)
     {
     if (!EMSerror (*EMmsg))
       OM_stat = om$send (msg = message EMSsurface.EMpostrtree (EMmsg,
                  NULL, addtree = TRUE, md_env, OPPmargs, NULL), 
                  targetid = my_id);
     EMrestore_postproc();
     }

  EMWRAPUP(*EMmsg, OM_stat, "EMSsubbs.GRaddwrng");
  return(OM_stat);

}

end implementation EMSsubbs;

