/* $Id: VDconstCS.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddetail/func/VDconstCS.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDconstCS.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1995/11/27  14:50:22  pinnacle
# Created: ./vddetail/func/VDconstCS.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 ***************************************************************************/

class implementation Root;

/*+fe
Function   VDconstruct_CS()

Abstract
  This function constructs a rectngular coordinate system given 3 points.

Arguments
  IGRlong		 *msg	      O    return status
  IGRpoint		 pt1	      I    input point 1
  IGRpoint		 pt2	      I    input point 2
  IGRpoint		 pt3	      I    input point 3
  struct GRvg_construct  *cst	      I    construction list
  struct GRid		 *csId	      O    grid of constructed CS

Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/

#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "wl.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "parametric.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "v_miscmacros.h"
#include "vderrmacros.h"

#include "ma.h"
#include "ma3protmx.h"
#include "matrnmx.h"


extern OMuword		OPP_GRgencs_class_id;

from   GRgraphics  import   GRconstruct;
from   GRgraphics  import   GRdisplay;

long  VDconstruct_cs(
  long			*msg,
  IGRpoint		pt1,
  IGRpoint		pt2,
  IGRpoint		pt3,
  struct GRvg_construct *cst,
  struct GRid		*csId
)
{
  long			sts;
  double		rotmax[16];
  IGRshort		ii;
  struct GRcs_construct cs_args;  /* cs-specific construction args */
  struct IGRlbsys       lbs_geom;   /* local bounded system geometry */

  SetProc( VDconstruct_cs ); Begin

  if ( !msg || !pt1 || !pt2 || !pt3 || !cst || !csId )
  {
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
  }

  __DBGpr_vec(" Point#1 ", pt1 );
  __DBGpr_vec(" Point#2 ", pt2 );
  __DBGpr_vec(" Point#3 ", pt3 );

  *msg = MSSUCC;
  sts  = OM_S_SUCCESS;

  /* evaluate rotation matrix from 3 points */
  MA3protmx( msg, pt1, pt2, pt3, rotmax );
  if ( *msg != MSSUCC)
  {
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
  }

  __DBGpr_mat(" RowMtx  ", rotmax );

  ii = 4;
  MAtrnmx ( msg, &ii, rotmax, lbs_geom.matrix);
  if ( *msg != MSSUCC)  goto wrapup;

  __DBGpr_mat(" LbsGm#1  ", rotmax );

  for (ii = 0; ii < 3; ++ii)
  {
	lbs_geom.matrix[3 + (4 * ii)] = pt1[ii];
	lbs_geom.diag_pt1[ii] = 0;
	lbs_geom.diag_pt2[ii] = 0;
  }

  __DBGpr_mat(" LbsGm#2 ", lbs_geom.matrix );

/*
    cs_args.flag = CS_MAKE_ACTIVE | CS_CONNECT_TO_MGR;
*/
  cs_args.desc = NULL;
  cs_args.type = RECTANGULAR;

  cst->class_attr = (IGRchar *) &cs_args;
  cst->geometry = (IGRchar *)&lbs_geom;

  csId->osnum = cst->env_info->md_id.osnum;
  sts = om$construct (  osnum = csId->osnum,
			classid = OPP_GRgencs_class_id,
			p_objid = &csId->objid,
			msg = message GRgraphics.GRconstruct ( cst ) );
  VDS_ERR_HNDLR ( "om$construct", sts, 1, VD_VERBOSE, wrapup);
  __DBGpr_obj ( "cs object =", *csId );

  /*
   * Display CS
   */
  sts = gr$display_object(  object_id = csId,
			    md_env    = cst->env_info,
			    mode      = GRbd  );


wrapup:
   return sts;
}


long  VDconst_tmp_cs(
  long			*msg,
  IGRpoint		pt1,
  IGRpoint		pt2,
  IGRpoint		pt3,
  struct GRid		*csId
)
{
  long			  sts;
  struct GRvg_construct	  cst;
  int			  numberOfBytes,
			  BytesReceived;
  struct GRmd_env	  mod_env;
  struct IGRdisplay	  disp;
  short			  level;

  SetProc( VDconst_tmp_cs ); Begin

  if ( !msg || !pt1 || !pt2 || !pt3 || !csId )
  {
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
  }

  numberOfBytes = sizeof ( IGRshort );
  gr$get_active_layer(  msg     = msg,
                        sizbuf  = &numberOfBytes,
                        buffer  = &level,
                        nret    = &BytesReceived );

  numberOfBytes = sizeof ( struct GRmd_env );
  gr$get_module_env  (	 msg     = msg,
                         sizbuf  = &numberOfBytes,
                         buffer  = &mod_env,
                         nret    = &BytesReceived );

  numberOfBytes = sizeof ( struct IGRdisplay );
  gr$get_active_display(msg     = msg,
                        sizbuf  = &numberOfBytes,
                        buffer  = &disp,
                        nret    = &BytesReceived );

  /*
   * Change to specific layout.
   */
  sts =
  ige$get_color_from_name( color = (short *)&disp.color, name = "Highlight" );
  disp.weight += 1 ;
  disp.style   = 2 ;

  cst.msg      = msg;
  cst.env_info = &mod_env;
  cst.display  = &disp;
  cst.newflag  = FALSE;
  cst.level    = level;
  cst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE ;
  cst.name       = NULL;

  sts = VDconstruct_cs (  msg,  pt1, pt2, pt3, &cst, csId );
  VDS_ERR_HNDLR ( "VDconstruct_cs", sts, *msg, VD_VERBOSE, wrapup );

wrapup:
  End ;
  return sts;

}

void tmp_construct_cs_call ( IGRpoint  pt1,  IGRpoint pt2, IGRpoint pt3 )
{
long		sts, msg;
struct GRid     csId;


    sts = VDconst_tmp_cs ( &msg, pt1, pt2, pt3, &csId );

}

end implementation Root;
