/* $Id: dim.I,v 1.1 2001/10/17 20:39:53 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/dim / dim.I
 *
 * Description: This file ONLY contains method toggle_ter_loca()
 *              The original file, defining this method, is:
 *
 *              $GRNUC/src/dim/dim_root/dim.I
 *
 *              (Removed ALL other methods/functions from file.)
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: dim.I,v $
 *	Revision 1.1  2001/10/17 20:39:53  hans
 *	Modifications for CR# MP5368
 *	
 *
 * History:
 *	MM/DD/YYYY	AUTHOR	DESCRIPTION
 *	10/16/2001	HF	Creation Date
 *                              Modifications for CR# MP5368
 *                              Modified method toggle_ter_loca()
 *                              Added functions toggle_4_or_2_term() and get_cycle_4_term()
 *                              to manipulate/retrieve static int cycle_4_term;
 * -------------------------------------------------------------------*/

class implementation DMdim;

#define AS_DEBUG 1

#include "cotxmacros.h"
#include "grownerdef.h"
#include "diminst.h"
#include "dimcomplex.h"
#include "dimtxt.h"

#include "dimlinear.h"
#include "dimradial.h"
#include "dimangular.h"
#include "dimtxtdef.h"
#include "sunlimits.h"
#include "DItypedef.h"

#include "DIdef.h"
#include "DIprims.h"
#include "refdef.h"
#include "matypemx.h"
#include "mascalvc.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "maaddvc.h"
#include "bsrpower.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bsdetmat.h"
#include "bscrossp.h"

extern GRclassid OPP_DMlinear_class_id;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~	HF:10/16/2001 - Start Additions/Modifications for CR# MP5368 ~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#define VD_DEBUG

#include "VDdebug.h"

// From $GRNUC/include/dimdef.h
/* - Terminator Location - */

#define TER_LOCA_INTERNAL	0
#define TER_LOCA_EXTERNAL	1

// Added for new functionality: Unidirectional terminators
#define TER_LOCA_LEFT		2
#define TER_LOCA_RIGHT		3

static int cycle_4_term;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

// Function to enable toggling the value of cycle_4_term
// from within a PPL.
// Execute PPL: ci=toggle_term

int toggle_4_or_2_term()
{
  if (cycle_4_term)
  {
    cycle_4_term = 0;
  }
  else
  {
    cycle_4_term = 1;
  }
  return cycle_4_term;
}

int get_cycle_4_term()
{
  return cycle_4_term;
}

method toggle_ter_loca(IGRint *msg; struct GRmd_env *md_env)
{
  IGRint             status, rc, is_linear = 0;
  GRclassid          clid;

  status = om$get_classid( osnum = OM_Gw_current_OS, objid = my_id, p_classid = &clid);
  dm$status(action = RET_STATUS);

  if (om$is_ancestry_valid( subclassid   = clid,
                            superclassid = OPP_DMlinear_class_id) == OM_S_SUCCESS)
  {
    is_linear = 1;
  }

  __enterMethod ( name = "toggle_ter_loca", argfmt = "me->ter_loca = %d, is_linear = %d",
                  args = `me->ter_loca, is_linear` );

  *msg = DIM_S_SUCCESS;

  if ( ! is_linear )
  {
    me->ter_loca = (me->ter_loca == TER_LOCA_INTERNAL) ? TER_LOCA_EXTERNAL : TER_LOCA_INTERNAL;
  }
  else
  {
    if ( cycle_4_term )
    {
      me->ter_loca += 1;
      if(me->ter_loca > TER_LOCA_RIGHT)
         me->ter_loca = TER_LOCA_INTERNAL;
    }
    else
    {
      if (me->ter_loca <= TER_LOCA_EXTERNAL)
      {
        me->ter_loca = (me->ter_loca == TER_LOCA_INTERNAL) ? TER_LOCA_EXTERNAL : TER_LOCA_INTERNAL;
      }
      else
      {
        me->ter_loca = (me->ter_loca == TER_LOCA_LEFT) ? TER_LOCA_RIGHT : TER_LOCA_LEFT;
      }
    }
  }
  if (md_env)
  {
    struct GRid my_grid;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    status = dm$change_node(
      as_grid   = my_grid,
      md_env    = md_env,
      broadcast = FALSE);
    dm$status(action = RET_STATUS);
  }

  __exitMethod  ( name = "toggle_ter_loca", argfmt = "me->ter_loca = %d",
                  args = `me->ter_loca`);

  return(OM_S_SUCCESS);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~	HF:10/16/2001 - End Additions/Modifications for CR# MP5368 ~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation DMdim;
