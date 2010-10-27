/* $Id: ASnodei.I,v 1.1 2001/01/18 19:08:55 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/ASnodei.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: ASnodei.I,v $
 * Revision 1.1  2001/01/18 19:08:55  ramarao
 * Merged Service Pack Files to 262 pload.
 *
# Revision 1.2  2000/10/30  19:54:18  pinnacle
# Replaced: vds/vdassoc/ASnodei.I for:  by jpulapar for Service Pack
#
# Revision 1.1  2000/10/05  15:04:14  pinnacle
# Created: vds/vdassoc/ASnodei.I by jpulapar for Service Pack
#
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 10/02/00  Jayadev   abort if the NDcompute_node fails inside NDupdate 
 *
 ***************************************************************************/
class implementation ASnode;
/*
   Ch    dec 87 :  update for the 1.1 release

   This is the implementation file of the class ASnode and gather only the
   overrided method of GRgraphics and GRvg.
*/

#include "AS_status.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "asdef.h"
#include "nddef.h"
#include "asmacros.h"
#include "asbox.h"
#include "dpmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grownmacros.h"
#include "exmacros.h"

#define AS_DEBUG 1

from ACpretgo  import ACgive_info;

method NDupdate(int *msg, cn_type, count;
                struct GRid *parents;
                int *parent_state;
                struct GRid *context,*new_objid;
                struct GRmd_env *md_env)
{
 long status,loc_msg;
 enum GRdpmode dpmode;
 OM_S_OBJID sv_md;
 struct GRid cur_mod;
 extern IGRboolean ASbroadcast_in_progress;
 IGRboolean save_br,computeFail = FALSE;

 new_objid->objid = my_id;
 new_objid->osnum = OM_Gw_current_OS;

 /*"cn_type %x\n",cn_type */

 /* Depending on parent state, recompute or not */

 NDcontrol_parent_state(count,parent_state,msg);

 if(!(1&*msg)) return OM_S_SUCCESS;


/* In case of stop, don't update */

 if( (cn_type&ND_COMP_TYPE) == ND_COMP_STOPPED)
   {
    *msg = ND_COMP_OUT_OF_DATE;
    return OM_S_SUCCESS;
   }

/* Get cur mod id for display */

 if(   !(cn_type&ND_COMP_NO_DISPLAY)
    || !(cn_type&ND_COMP_NO_ERASE))
   {
    status = ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
    as$status();
   }


 save_br = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;

/* if Rtree defined removed the element from R-tree */

 if(!(cn_type&ND_COMP_NO_REM_RT))
  {
   /*| remove from R-tree */
   status = om$send(msg = message GRgraphics.GRremwrng(&loc_msg,md_env),
		    targetid = my_id);
  }
 if(!(cn_type&ND_COMP_NO_ERASE))
  {
   /*| erase */
   dpmode = GRbehe;
   status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
				   &md_env->md_env.matrix_type,
				   md_env->md_env.matrix,
				   &dpmode,
				   &cur_mod),
		    targetid = my_id);
   as$status();
  }

/*| recompute the element */

 loc_msg = 0;
 sv_md = md_env->md_id.objid;
 md_env->md_id.objid = NULL_OBJID;
 status = om$send(msg = message NDnode.NDcompute_node(&loc_msg,cn_type,
						count,parents,md_env),
		  targetid = my_id);
 md_env->md_id.objid = sv_md;

 // abort on recompute failure
 if(!(status&1)) computeFail = TRUE; 

/* If context compute, transfer symbology */

 if(context && context->objid != NULL_OBJID)
		 ACtrans_symb(*context,*new_objid);

/* make sure that a completion code is returned */
 if(! loc_msg) *msg = ND_COMP_SUCC;
 else *msg = loc_msg;


/* if Rtree defined add the element to R-tree */

 if(!(cn_type&ND_COMP_NO_ADD_RT))
  {
   /*| add to R-tree */
   status = om$send(msg =  message GRgraphics.GRaddwrng(&loc_msg,md_env),
                    targetid = my_id);
  }
/* display the element */

 if(!(cn_type&ND_COMP_NO_DISPLAY))
  {
   /*| display */
   dpmode = GRbd;
   status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
				   &md_env->md_env.matrix_type,
				   md_env->md_env.matrix,
				   &dpmode,
				   &cur_mod),
		    targetid = my_id);
   as$status();
  }

ASbroadcast_in_progress = save_br;

/*" completion code %d\n",*msg */
 if(computeFail) return OM_W_ABORT;
 else return OM_S_SUCCESS;
}

end implementation ASnode;
