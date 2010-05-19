/* $Id: VDsrc_obj.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/func/VDsrc_obj.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsrc_obj.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.6  1995/09/06  21:04:06  pinnacle
# Replaced: vdannot/func/VD[AIsg]*.I for:  by jwfrosch for vds.240
#
# Revision 1.5  1995/08/30  13:39:54  pinnacle
# Replaced: vdannot/func/VD[AlpsI]*.I for:  by jwfrosch for vds.240
#
# Revision 1.4  1995/08/29  21:25:42  pinnacle
# Replaced: vdannot/func/VD[ApTgsI]*.I for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/08/18  23:04:08  pinnacle
# Replaced: vdannot/func/*.I for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/07/27  19:09:48  pinnacle
# Replaced: vdannot/func/VDsrc_obj.I for:  by jwfrosch for vds.240
#
# Revision 1.1  1995/07/25  22:43:10  pinnacle
# Created: vdannot/func/VDsrc_obj.I by jwfrosch for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation Root;

#include <stdio.h>
#include <string.h>

#include "igrtypedef.h"
#include "igetypedef.h"
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "ex.h"
#include "gr.h"
#include "growner.h"
#include "vdandef.h"
#include "vdanmacros.h"

#include "bserr.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "go.h"
#include "nddef.h"
#include "parametric.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "AS_status.h"

#define VD_DEBUG

#include "VDdebug.h"

#define			MAX_TEMP	2
#define			MAX_FEET	1

from	ACcpx		import	ACfind_exp_temp_obj;
from	ACcpx		import	ACfind_exp_temp_struct;
from	NDmacro		import	ACreturn_foot;
from	NDnode		import	NDget_objects, NDchg_state;
from	GRvg		import	GRgetrang;
from	GR3dpoint	import	GRaltconstruct;
from	ci_macro	import	set_all_extern_feet;

extern GRclassid	OPP_GR3dpoint_class_id,
			OPP_VDitem_class_id;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int	VDannot_construct_pnt ( CI_MACRO_ID )

  struct GRid		CI_MACRO_ID;

{
  int			i, pos, BytesReceived = 0, NumberOfBytes;
  IGRint		num_ent;
  IGRlong		status, msg;
  IGRdouble		vec[3];
  IGRboolean		world = 1;

  IGRpoint		local_point;
  struct  GRid		go_sup, OBJ, PNT, BubbleId;
  struct  GRmd_env	mod_env, sup_env;
  GRrange		range;

  struct GRvg_construct	cst;
  struct IGRdisplay	dis;
  struct ret_struct	expr;
  struct IGRpolyline	geom;
  OM_S_CHANSELECT	To_Comp;

  __enterFunction ( name = "VDannot_construct_pnt" );

  status =
  om$make_chanselect(	channame	= "GRcmpowner.to_components",
			p_chanselect	= &To_Comp );

  NumberOfBytes = sizeof(mod_env);
  gr$get_module_env (	msg	= &msg,
			sizbuf	= &NumberOfBytes,
			buffer	= &mod_env,
			nret	= &BytesReceived );

  PNT.objid = NULL_OBJID;
  PNT.osnum = mod_env.md_id.osnum;

  /*
   * Find the number or templates for input.
   */

  status =
  om$send (	msg	 = message NDnode.NDget_objects (
						ND_ROOT, NULL, 0, NULL,
						0, OM_K_MAXINT, &num_ent),
		senderid = NULL_OBJID,
		targetid = CI_MACRO_ID.objid,
		targetos = CI_MACRO_ID.osnum);
  if ( ! ( status & 1 ) || num_ent > MAX_TEMP )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  __printf ( "num_ent    : %d", num_ent );

  status =
  om$send (	msg	 = message  ACcpx.ACfind_exp_temp_obj ( (int *)&msg, 0, &OBJ ),
		senderid = NULL_OBJID,
		targetid = CI_MACRO_ID.objid,
		targetos = CI_MACRO_ID.osnum );
  if( ! ( status & msg & 1 ) )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  __printf ( "CI_MACRO_ID: [%d,%d]", `CI_MACRO_ID.osnum, CI_MACRO_ID.objid` );
  __printf ( "OBJ        : [%d,%d]", `OBJ.osnum, OBJ.objid` );

  status =
  om$send (	msg	 = message NDmacro.ACreturn_foot(
					&msg, "",
					&go_sup,
					&sup_env.md_env.matrix_type,
					 sup_env.md_env.matrix ),
		senderid = NULL_OBJID,
		targetid = OBJ.objid,
		targetos = OBJ.osnum );
  as$status();

  __printf ( "go_sup     : [%d,%d]", `go_sup.osnum, go_sup.objid` );

//  VD_ShowObj( &go_sup );
//  pr_mat("MTX", 4, 4, sup_env.md_env.matrix );

  /*
   * find range of the go_sup and find the mid point
   */
 {
    struct	GRobj_env	tmp ;

    tmp.obj_id  = go_sup ;
    tmp.mod_env = sup_env ;

    VD_getRangeOfComposite( &msg, &tmp, range );

    __printf ( "RTREE[LO]  : %lg %lg %lg", `range[0], range[1], range[2]` );
    __printf ( "RTREE[HI]  : %lg %lg %lg", `range[3], range[4], range[5]` );
  }

  status =
  om$send (	msg	 = message GRvg.GRgetrang(
					&msg,
					&sup_env.md_env.matrix_type,
					 sup_env.md_env.matrix,
					&world,
					 range ),
		senderid = NULL_OBJID,
		targetid = go_sup.objid,
		targetos = go_sup.osnum );
  as$status();


  /*
   * calculate default location.
   */

  __printf ( "Range[LO]  : %14.6lf %14.6lf %14.6lf", `range[0], range[1], range[2]` );
  __printf ( "Range[HI]  : %14.6lf %14.6lf %14.6lf", `range[3], range[4], range[5]` );

  for( i=0 ; i<3 ; i++ )
  {
    local_point[i] = ( range[3+i] + range[i] ) / 2.0 ;
  }

  __printf ( "local      : %14.6lf %14.6lf %14.6lf", `local_point[0], local_point[1], local_point[2]` );

  /*
   * If VDitem is TEMPLATE then use range of Bubble Object in stead of VDitem range
   */

  if( DMancestry_valid ( go_sup, OPP_VDitem_class_id ) == OM_S_SUCCESS )
  {
    status =
    om$get_objid_at_index (	objid		= go_sup.objid,
				osnum		= go_sup.osnum,
				index		= 3,		// Bubble Object
				p_chanselect	= &To_Comp,
				objidaddr	= &BubbleId.objid,
				osnumaddr	= &BubbleId.osnum);
    as$status();
    __printf ( ">>>>>>>>>> BubbleId = [%d,%d]", `BubbleId.osnum, BubbleId.objid` );

    status =
    om$send (	msg	 = message GRvg.GRgetrang
						( &msg,
						  &sup_env.md_env.matrix_type,
						   sup_env.md_env.matrix,
						  &world,
						   range ),
		senderid = NULL_OBJID,
		targetid = BubbleId.objid,
		targetos = BubbleId.osnum );
    as$status();
    __printf ( "Bubble Range[LO] = %14.6lf %14.6lf %14.6lf", `range[0], range[1], range[2]` );
    __printf ( "Bubble Range[HI] = %14.6lf %14.6lf %14.6lf", `range[3], range[4], range[5]` );

    for( i=0 ; i<3 ; i++ )
    {
      local_point[i] = ( range[3+i] + range[i] ) / 2.0 ;
    }

  }

  /*
   * set default presetting option.
   */

  status =
  om$send (	msg	 = message  ACcpx.ACfind_exp_temp_struct (
						 (int *)&msg, 1, &expr, &mod_env  ),
		senderid = NULL_OBJID,
		targetid = CI_MACRO_ID.objid,
		targetos = CI_MACRO_ID.osnum );
  if ( ! ( status & msg & 1 ) )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  __printf ( "expr.type  = %#x, text_string = <%s>", `expr.type, expr.var.text_st.text_string` );

  sscanf ( expr.var.text_st.text_string, "%d %lf %lf %lf", &pos, &vec[0], &vec[1], &vec[2] );

  __printf ( "pos= %d vec = %14.6lf %14.6lf %14.6lf", `pos, vec[0], vec[1], vec[2]` );

  if ( pos >= 0 && pos <= 8 )
  {
    switch( pos )
      {
	case 0:
	  {
	    for( i=0 ; i<3 ; i++ )
	    {
	      local_point[i] = range[i];
	    }
	    break;
	  }
	case 1:
	  {
	    local_point[0] = range[0];
	    local_point[1] = range[1] + 0.5 * (range[4] - range[1]);
	    local_point[2] = range[2] + 0.5 * (range[5] - range[2]);
	    break;
	  }
	case 2:
	  {
	    local_point[0] = range[0];
	    local_point[1] = range[4];
	    local_point[2] = range[5];
	    break;
	  }
	case 5:
	  {
	    local_point[0] = range[0] + 0.5 * (range[3] - range[0]);
	    local_point[1] = range[4];
	    local_point[2] = range[5];
	    break;
	  }
	case 4:
	  {
	    local_point[0] = range[0] + 0.5 * (range[3] - range[0]);
	    local_point[1] = range[1] + 0.5 * (range[4] - range[1]);
	    local_point[2] = range[2] + 0.5 * (range[5] - range[2]);
	    break;
	  }
	case 3:
	  {
	    local_point[0] = range[0] + 0.5 * (range[3] - range[0]);
	    local_point[1] = range[1];
	    local_point[2] = range[2];
	    break;
	  }
	case 6:
	  {
	    local_point[0] = range[3];
	    local_point[1] = range[1];
	    local_point[2] = range[2];
	    break;
	  }
	case 7:
	  {
	    local_point[0] = range[3];
	    local_point[1] = range[1] + 0.5 * (range[4] - range[1]);
	    local_point[2] = range[2] + 0.5 * (range[5] - range[2]);
	    break;
	  }
	case 8:
	  {
	    local_point[0] = range[3];
	    local_point[1] = range[4];
	    local_point[2] = range[5];
	    break;
	  }
	default:
	    break;
      }
  }

  /*
   * add offset to the predefined location.
   */

  local_point[0] += vec[0];
  local_point[1] += vec[1];
  local_point[2]  = vec[2];	// RESETTING of local_point[2] to be equal to vec[2]

  dis.color		= 2;	//cnst_list.color;
  dis.weight		= 1;	//3;
  dis.style		= 0;	//cnst_list.style;

  cst.msg		= &msg;
  cst.properties	= GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cst.display		= &dis;
  cst.env_info		= &mod_env;
  cst.newflag		= 0;
  cst.level		= 0;	//cnst_list.level;
  cst.geometry		= NULL;
  cst.class_attr	= 0;
  cst.name		= 0;

  /*
   * Construct the point
   */

  geom.num_points	= 1 ;
  geom.points		= local_point ;
  cst.geometry		= (char *)&geom ;

  __printf ( "CONpoint   : %14.6lf %14.6lf %14.6lf", `local_point[0], local_point[1], local_point[2]` );

  status =
  om$construct (msg	 = message GR3dpoint.GRaltconstruct (&cst),
		classid	 = OPP_GR3dpoint_class_id,
		p_objid	 = &PNT.objid,
		osnum	 =  PNT.osnum );

  if ( ! ( status & 1 ) )
  {
    PNT.objid = NULL_OBJID;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  om$send (	msg	 = message  ci_macro.set_all_extern_feet
						( (IGRint *)&msg, 1, &PNT, &mod_env ),
		senderid = NULL_OBJID,
		targetid = CI_MACRO_ID.objid,
		targetos = CI_MACRO_ID.osnum );

  __exitFunction ( name = "VDannot_construct_pnt" );
/*
  status =
  om$send (	msg	 = message NDnode.NDchg_state( ND_SUP_ONLY, ND_SUP_ONLY ),
		senderid = NULL_OBJID,
		targetid = CI_MACRO_ID.objid,
		targetos = CI_MACRO_ID.osnum );
*/
  return(1);

wrapup:

  PNT.objid = NULL_OBJID;

  __exit_error_Function ( name = "VDannot_construct_pnt" );

  return (0);
}

end implementation Root;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
