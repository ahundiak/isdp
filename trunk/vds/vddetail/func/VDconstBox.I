/* $Id: VDconstBox.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddetail/func/VDconstBox.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDconstBox.I,v $
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
# Revision 1.1  1995/11/27  14:50:14  pinnacle
# Created: ./vddetail/func/VDconstBox.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			raju
 *
 ***************************************************************************/

class implementation Root;

/*+fe
Function   VDconstruct_box()

Abstract
  This function constructs a rectangular box given 2 points.

Arguments
  IGRlong		 *msg	      O    return status
  IGRpoint		 pt1	      I    input point 1
  IGRpoint		 pt2	      I    input point 2
  struct GRvg_construct  *cst	      I    construction list
  struct GRid		 *boxId	      O    grid of constructed box
  
Notes

Return status
  same as OM return status

Return message
  MSSUCC - success
  MSFAIL - failure

History
   11-03-1994  Raju   Creation
-fe*/

#include "math.h"
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

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grmacros.h"
#include "v_miscmacros.h"
#include "vderrmacros.h"

extern OMuword		OPP_EMSblock_class_id;

from   EMSblock    import   EMboxby2pt;
from   GRgraphics  import   GRdisplay;
from   GRgraphics  import   GRdelete;

long  VDconstruct_box(
  long			*msg,
  IGRpoint		pt0,
  IGRpoint		pt1,
  struct GRvg_construct *cst,
  struct GRid		*boxId
)  
{
  long			sts;

  if ( !msg || !pt0 || !pt1 || !cst || !boxId )
  {
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
  }

  *msg = MSSUCC;
  sts  = OM_S_SUCCESS;

  if ( pt0[0] == pt1[0] ||
       pt0[1] == pt1[1] ||
       pt0[2] == pt1[2]    )  /* does not form a box */
  {
    boxId->objid  = NULL_OBJID;
    goto wrapup;
  }


  boxId->osnum = cst->env_info->md_id.osnum;
  sts = om$construct (  osnum = boxId->osnum,
			classid = OPP_EMSblock_class_id,
			p_objid = &boxId->objid );
  VDS_ERR_HNDLR ( "om$construct", sts, 1, VD_VERBOSE, wrapup);
  __DBGpr_obj ( "box object =", *boxId );

  sts = om$send ( msg = message EMSblock.EMboxby2pt (	msg,
							cst,
							pt0,
							pt1  ),
		  targetid = boxId->objid,
		  targetos = boxId->osnum,
		  senderid = NULL_OBJID );

  if ( !(sts & *msg & 1) )
  {
     printf("%s[%d] : EMSblock.EMboxby2pt failed\n", __FILE__, __LINE__);
     sts = om$send ( msg = message Root.delete ( 1 ),
		     targetid = boxId->objid,
		     targetos = boxId->osnum,
		     senderid = NULL_OBJID  );
     boxId->objid = NULL_OBJID;
     goto wrapup;
  }

  /*
   * Display box
   */
  sts = gr$display_object(  object_id = boxId,
			    md_env    = cst->env_info,
			    mode      = GRbd  );

wrapup:
   return sts;
}


long  VDconst_clip_box(
  long			*msg,
  IGRpoint		pt0,
  IGRpoint		pt1,
  struct GRid		*boxId
)
{
  long			  sts;
  struct GRvg_construct	  cst;
  int			  numberOfBytes,
			  BytesReceived;
  struct GRmd_env	  mod_env;
  struct IGRdisplay	  disp;
  short			  level;


  if ( !msg || !pt0 || !pt1 || !boxId )
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
  gr$get_module_env  (	msg     = msg,
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
  disp.weight += 2 ;
  disp.style   = 0 ;

  cst.msg      = msg;
  cst.env_info = &mod_env;
  cst.display  = &disp;
  cst.geometry = NULL;
  cst.newflag  = FALSE;
  cst.level    = level;
  cst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE ;
  cst.class_attr = NULL;
  cst.name       = NULL;

  sts = VDconstruct_box (  msg,  pt0, pt1, &cst, boxId );
  VDS_ERR_HNDLR ( "VDconstruct_box", sts, *msg, VD_VERBOSE, wrapup );

wrapup:
  return sts;

}

long  VDdisp_clip_box(
 long			*msg,
 struct GRid		*boxId,
 struct GRid		*csId,
 struct GRid		*arrId,
 char			constArrFlg,
 struct GRmd_env	*mod_env,
 IGRpoint		pt1,
 IGRpoint		pt2,
 char			view
)
{
long			sts;
double			csOrigin[3], csXaxis[3], csYaxis[3];

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    if ( !msg  || !boxId || !csId || !arrId || !mod_env || !pt1 || !pt2 )
    {
	*msg = MSINARG;
	sts = OM_E_INVARG;
	goto wrapup;
    }

    if ( boxId->objid != NULL_OBJID )
    {
	sts =
	gr$display_object(  object_id = boxId,
			    md_env    = mod_env,
			    mode      = GRbe  );
	sts =
	vd_$bulk_delete(	count	= 1,
				grids	= boxId,
				theEnv	= mod_env );
	boxId->objid = NULL_OBJID;
    }

    if ( csId->objid != NULL_OBJID )
    {
	sts =
	gr$display_object(  object_id = csId,
			    md_env    = mod_env,
			    mode      = GRbe  );
	sts =
	vd_$bulk_delete(	count	= 1,
				grids	= csId,
				theEnv	= mod_env );
	csId->objid = NULL_OBJID;
    }

    if ( constArrFlg && arrId->objid != NULL_OBJID )
    {
	sts =
	gr$display_object(  object_id = arrId,
			    md_env    = mod_env,
			    mode      = GRbe  );
	sts =
	vd_$bulk_delete(	count	= 1,
				grids	= arrId,
				theEnv	= mod_env );
	arrId->objid = NULL_OBJID;
    }

    sts = VDconst_clip_box ( msg, pt1, pt2, boxId );
    VDS_ERR_HNDLR ( "VDconst_clip_box", sts, *msg, VD_VERBOSE, wrapup );

    if ( boxId->objid == NULL_OBJID ) goto wrapup;

    /*
     * construct cs
     */
    csOrigin[0] = (pt1[0] + pt2[0]) / 2.0;
    csOrigin[1] = (pt1[1] + pt2[1]) / 2.0;
    csOrigin[2] = (pt1[2] + pt2[2]) / 2.0;

    csXaxis[0] = csOrigin[0] + 1.0;
    csXaxis[1] = csOrigin[1];
    csXaxis[2] = csOrigin[2];

    csYaxis[0] = csOrigin[0];
    csYaxis[1] = csOrigin[1] + 1.0;
    csYaxis[2] = csOrigin[2];

    __DBGpr_vec(" CS origin ", csOrigin );
    __DBGpr_vec(" CS Xaxis  ", csXaxis  );
    __DBGpr_vec(" CS Yaxis  ", csYaxis  );

    sts = VDconst_tmp_cs ( msg, csOrigin, csXaxis, csYaxis, csId );
    VDS_ERR_HNDLR ( "VDconst_tmp_cs", sts, *msg, VD_VERBOSE, wrapup );

    /*
     * construct arrow
     */
    if ( !constArrFlg ) goto wrapup;

    sts = VDdisp_view_arrow ( msg, arrId, mod_env, pt1, pt2, view );
    VDS_ERR_HNDLR( "VDdisp_veiw_arrow", sts, *msg, VD_VERBOSE, wrapup );

wrapup:
    return sts;

}

end implementation Root;
