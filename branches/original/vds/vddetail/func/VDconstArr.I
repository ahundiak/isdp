/* $Id: VDconstArr.I,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vddetail/func/VDconstArr.I
 *
 * Description:
 *		Dynamic Display function.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDconstArr.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:36  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/27  18:00:16  pinnacle
# TR179601991
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/06/07  12:47:10  pinnacle
# Replaced: vddetail/func/VDconstArr.I for:  by ksundar for vds.240
#
# Revision 1.2  1996/04/06  08:19:32  pinnacle
# Replaced: vddetail/func/VDconstArr.I for:  by ksundar for vds.240
#
# Revision 1.1  1995/11/27  14:50:08  pinnacle
# Created: ./vddetail/func/VDconstArr.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      08/27/96        ah              TR179601991 Comments in .sl file
 * 
 *
 ***************************************************************************/

class implementation Root;

/*+fe
  There are three functions in this file.

  VDconstruct_arrow()  -  constructs an arrow given the following data.
  VDconst_view_arrow() -  sets cst and calls VDconstruct_arrow().
  VDdisp_view_arrow()  -  Deletes exisiting arrow and calls VDconst_view_arrow()

Function   VDconstruct_arrow()

Abstract
  This function constructs a arrow given starting point, vector, and
length. This is called by VDconst_view_arrow.


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

#include <math.h>
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
#include "dpmacros.h"
#include "grmacros.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "v_miscmacros.h"
#include "vderrmacros.h"
#include "VDdetail.h"

#include "ma.h"
#include "ma3protmx.h"
#include "matrnmx.h"

#define  VD_ARR_LEN_FCT   0.5

extern OMuword		OPP_GR3dlinestr_class_id;

from   GRgraphics  import   GRaltconstruct;

long  VDconstruct_arrow(
  long			*msg,
  IGRpoint		origin,
  IGRvector		arrvec,
  double		arrlen,
  struct GRvg_construct *cst,
  struct GRid		*arrId
)
{
  long			sts;
  struct IGRpolyline	arrow;
  double		points[30], veclen, headlen, offset, tmppnt[3];


  if ( !msg || !origin || !arrvec || arrlen == 0.0 || !cst || !arrId )
  {
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
  }

  *msg = MSSUCC;
  sts  = OM_S_SUCCESS;

  __DBGpr_vec(" arrvec ", arrvec );
  __DBGpr_vec(" origin ", origin );
  __DBGpr_dbl(" arrlen ", arrlen );

  veclen = sqrt ( arrvec[0]*arrvec[0] + arrvec[1]*arrvec[1] +
		  arrvec[2]*arrvec[2] );
  if ( veclen < 1e-06 )
  {
    *msg = MSINARG;
    sts = OM_E_INVARG;
    goto wrapup;
  }


  points[0] = origin[0];
  points[1] = origin[1];
  points[2] = origin[2];

  points[3] = points[0] + arrlen * arrvec[0]/veclen;
  points[4] = points[1] + arrlen * arrvec[1]/veclen;
  points[5] = points[2] + arrlen * arrvec[2]/veclen;


  headlen = arrlen * 0.2;
  offset = headlen * sqrt ( 1.0/3.0 );  /* headlen * tan 30 */;

  tmppnt[0] = points[3] - headlen * arrvec[0]/veclen;
  tmppnt[1] = points[4] - headlen * arrvec[1]/veclen;
  tmppnt[2] = points[5] - headlen * arrvec[2]/veclen;

  points[9] = points[3];
  points[10] = points[4];
  points[11] = points[5];

  points[15] = points[3];
  points[16] = points[4];
  points[17] = points[5];

  points[21] = points[3];
  points[22] = points[4];
  points[23] = points[5];

  points[6] = tmppnt[0];
  points[7] = tmppnt[1];
  points[8] = tmppnt[2];

  points[12] = tmppnt[0];
  points[13] = tmppnt[1];
  points[14] = tmppnt[2];

  points[18] = tmppnt[0];
  points[19] = tmppnt[1];
  points[20] = tmppnt[2];

  points[24] = tmppnt[0];
  points[25] = tmppnt[1];
  points[26] = tmppnt[2];

  if ( arrvec[0] != 0.0 )
  {
    points[7] += offset;
    points[14] += offset;
    points[19] -= offset;
    points[26] -= offset;
  }
  else if ( arrvec[0] != 0.0 )
  {
    points[6] += offset;
    points[14] += offset;
    points[18] -= offset;
    points[26] -= offset;
  }
  else
  {
    points[6] += offset;
    points[13] += offset;
    points[18] -= offset;
    points[25] -= offset;
  }

  arrow.num_points = 9;
  arrow.points = points;

  cst->class_attr = NULL;
  cst->geometry = (IGRchar *)&arrow;

  arrId->osnum = cst->env_info->md_id.osnum;
  sts = om$construct (  osnum = arrId->osnum,
			classid = OPP_GR3dlinestr_class_id,
			p_objid = &arrId->objid,
			msg = message GRgraphics.GRaltconstruct ( cst ) );
  VDS_ERR_HNDLR ( "om$construct", sts, 1, VD_VERBOSE, wrapup);

  __DBGpr_obj(" Arr obj ", *arrId );
  __DBGpr_mat(" Cst MTX ", cst->env_info->md_env.matrix );

  /*
   * Display arrow
   */
/*
 * TR179601991 Change from highlight to backgound as it was before
 */

  sts = gr$display_object(  object_id = arrId,
			    md_env    = cst->env_info,
			    mode      = GRbd  );

wrapup:
   return sts;
}

/* VDconst_view_arrow
 * This function is called by VDdisp_view_arrow. This sets construction list.
 */
long  VDconst_view_arrow(
  long			*msg,
  IGRpoint		origin,
  IGRvector		arrvec,
  double		arrlen,
  struct GRid		*arrId
)
{
  long			  sts;
  struct GRvg_construct	  cst;
  int			  numberOfBytes,
			  BytesReceived;
  struct GRmd_env	  mod_env;
  struct IGRdisplay	  disp;
  short			  level;

  if ( !msg || !origin || !arrvec || arrlen == 0.0 || !arrId )
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
  gr$get_active_display(msg 	= msg,
			sizbuf	= &numberOfBytes,
			buffer	= &disp,
			nret	= &BytesReceived );

  /*
   * Change to specific layout.
   */
  sts =
  ige$get_color_from_name( color = (short *)&disp.color, name = "Highlight" );
  disp.weight += 3 ;
  disp.style   = 0 ;

  cst.msg      = msg;
  cst.env_info = &mod_env;
  cst.display  = &disp;
  cst.newflag  = FALSE;
  cst.level    = level;
  cst.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  cst.name       = NULL;

  sts = VDconstruct_arrow (  msg, origin, arrvec, arrlen, &cst, arrId );
  VDS_ERR_HNDLR ( "VDconstruct_arrow", sts, *msg, VD_VERBOSE, wrapup );

wrapup:
  return sts;

}

/* VDdisp_view_arrow
 * This is the function that needs to be called for creating and displaying
 * view arrow.
 */
long  VDdisp_view_arrow(
 long			*msg,		/* O - return status */
 struct GRid		*arrId,		/* I/O - if !NULL_OBJID, it is deleted
						 first and then created */
 struct GRmd_env	*mod_env,	/* mod env in which to create */
 IGRpoint		pt1,		/* Min point of Box */
 IGRpoint		pt2,		/* MAx point of Box */
 char			view		/* view char, see VDdetail.h */
)
{
long			sts;
double			center[3], arrvec[3], arrlen, arrStPt[3];

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    if ( !msg  || !arrId || !mod_env || !pt1 || !pt2 )
    {
	*msg = MSINARG;
	sts = OM_E_INVARG;
	goto wrapup;
    }

    if ( arrId->objid != NULL_OBJID )
    {
	IGRlong msg ;

	/* commented for Fix 179600223 */
/*
 * TR179601991 Undo 179600223, go back to backgound
 * This code should never get executed.
 */
	sts =
	gr$display_object(  object_id = arrId,
			    md_env    = mod_env,
			    mode      = GRbe  );
/*
		dp$erase_hilite( msg = &msg );
*/

	sts =
	vd_$bulk_delete(	count	= 1,
				grids	= arrId,
				theEnv	= mod_env );
	arrId->objid = NULL_OBJID;
    }

    __DBGpr_vec(" Point#1 ", pt1 );
    __DBGpr_vec(" Point#2 ", pt2 );
    __DBGpr_mat(" ObjEnv  ", mod_env->md_env.matrix );

    arrlen = pt2[0] - pt1[0];
    if ( (pt2[1]-pt1[1]) > arrlen )  arrlen = pt2[1]-pt1[1];
    if ( (pt2[2]-pt1[2]) > arrlen )  arrlen = pt2[2]-pt1[2];
    arrlen *= VD_ARR_LEN_FCT;

    center[0] = (pt1[0] + pt2[0]) / 2.0;
    center[1] = (pt1[1] + pt2[1]) / 2.0;
    center[2] = (pt1[2] + pt2[2]) / 2.0;

    __DBGpr_vec(" Center ", center );

    /*
     * construct arrow
     */
    arrvec[0] = arrvec[1] = arrvec[2] = 0.0;

    switch ( view )
    {
	case  VD_XPOS :

	  arrStPt[0] = center[0] - (pt2[0]-pt1[0])*0.55 - arrlen;
	  arrStPt[1] = center[1] ;
	  arrStPt[2] = center[2] ;
	  arrvec[0] = 1.0;
	  break;

	case  VD_XNEG :

	  arrStPt[0] = center[0] + (pt2[0]-pt1[0])*0.55 + arrlen;
	  arrStPt[1] = center[1] ;
	  arrStPt[2] = center[2] ;
	  arrvec[0] = -1.0;
	  break;

	case  VD_YPOS :

	  arrStPt[0] = center[0] ;
	  arrStPt[1] = center[1] - (pt2[1]-pt1[1])*0.55 - arrlen;
	  arrStPt[2] = center[2] ;
	  arrvec[1] = 1.0;
	  break;

	case  VD_YNEG :

	  arrStPt[0] = center[0] ;
	  arrStPt[1] = center[1] + (pt2[1]-pt1[1])*0.55 + arrlen;
	  arrStPt[2] = center[2] ;
	  arrvec[1] = -1.0;
	  break;

	case  VD_ZPOS :

	  arrStPt[0] = center[0] ;
	  arrStPt[1] = center[1] ;
	  arrStPt[2] = center[2] - (pt2[2]-pt1[2])*0.55 - arrlen;
	  arrvec[2] = 1.0;
	  break;

	case  VD_ZNEG :

	  arrStPt[0] = center[0] ;
	  arrStPt[1] = center[1] ;
	  arrStPt[2] = center[2] + (pt2[2]-pt1[2])*0.55 + arrlen;
	  arrvec[2] = -1.0;
	  break;
    }

    sts = VDconst_view_arrow ( msg, arrStPt, arrvec, arrlen, arrId );
    VDS_ERR_HNDLR( "VDconstruct_arrow", sts, *msg, VD_VERBOSE, wrapup );

wrapup:
    return sts;

}

end implementation Root;
