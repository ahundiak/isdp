
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/


class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>

#include "OMerrordef.h"

#include "igrtypedef.h"
#include "igetypedef.h"

#include "msdef.h"

#include "igr.h"
#include "gr.h"
#include "igrdp.h"

#include "grdpbdef.h"

#include "godef.h"
#include "go.h"
#include "growner.h"

#include "dpstruct.h"

#include "bs.h"
#include "bsparameters.h"

#include "madef.h"

#include "ve.h"
#include "vedef.h"
#include "veerr.h"

/* prototype files */
%safe
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
%endsafe

/* External Global Variables */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEwindow_info      VEwin_info;
extern OMuword                   OPP_GR3dlineseg_class_id;
extern OMuword                   OPP_GR3dpoint_class_id;


%safe
/* static space to hold an order 2, 2 pole curve */
static IGRdouble VEstat_poles[6];
static IGRdouble VEstat_knots[4] = { 0.0, 0.0, 1.0, 1.0 };

static struct IGRbsp_curve VEstat_curve = { 2,               /* order                 */
	                                    FALSE, FALSE,    /* periodic, non-uniform */
	                                    2, VEstat_poles, /* num_poles, poles      */
	                                    4, VEstat_knots, /* num_knots, knots      */
	                                    FALSE, NULL,     /* rational, weights     */
	                                    FALSE, FALSE,    /* planar, phy_closed    */
	                                    0, NULL };       /* num_boundaries, bdrys */

%endsafe


from GRvg import GRconstruct, GRgenabsg, GRgetsymb;

#define GET_SYMBOLOGY( objid )                                                        \
	                                                                              \
	sts = om$send( msg      = message GRvg.GRgetsymb( &msg, &element_symb ),      \
	               senderid = NULL_OBJID,                                         \
	               targetid = (objid),                                            \
	               targetos = osnum );                                            \
	                                                                              \
	   OM_ERRCHK( sts, "VEget_env_info_from_objects:  GRgetsymb send failed" );   \
	   MSG_ERRCHK( msg, "VEget_env_info_from_objects:  GRgetsymb failed" );       \


#define DELETE_OBJECT( objid )                             \
	                                                   \
	sts = om$send( msg      = message Root.delete(0),  \
	               senderid = NULL_OBJID,              \
	               targetid = (objid),                 \
	               targetos = osnum );                 \

	   


/*--- VEconstruct_env_objects -----------------------------------*/

void VEconstruct_env_objects( env, batch_env )

	struct VEenv_info *env;
	struct GRmd_env   *batch_env;

/*
NAME
	VEconstruct_env_objects

DESCRIPTION
	This function constructs the objects required to represent special data
	about an environment that needs to be include in the batch object space.
	The objects that are constructed are:

	   - a line segment that represents the clipping range diagonal of
	     the environment

	   - a point whose color represents the color override of the
	     environment, if one exists

	   - a point whose style represents the style override of the
	     environment, if one exists

	   - a point whose weight represents the weight override of the
	     environment, if one exists

PARAMETERS
	env (IN) - the VE environment that is to have the environment
	           objects constructed
	batch_env (IN) - module environment of the invisible module

GLOBALS USED
	VEexec_parms

HISTORY
	01/10/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong               sts;
	IGRlong               msg;
	struct IGRdisplay     dis_attr;
        struct GRvg_construct cons_args;
	OM_S_OBJID            clip_diag_id, color_id, style_id, weight_id;

	dis_attr.color = 1;
	dis_attr.style  = dis_attr.weight = 0;

	/* fill in part of the construct structure */
	cons_args.msg        = &msg;
	cons_args.env_info   = batch_env;
	cons_args.newflag    = FALSE;
	cons_args.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	cons_args.class_attr = NULL;
	cons_args.name       = NULL;
	cons_args.display    = &dis_attr;
	cons_args.level      = VEexec_parms.non_displayed_layer;
	cons_args.geometry   = (IGRchar *) &VEstat_curve;

	/* get the clip range diagonal from the clipping planes */
	VEstat_poles[0] = env->clip_planes[0].point[0];  /* Min-X */
	VEstat_poles[1] = env->clip_planes[1].point[1];  /* Min-Y */
	VEstat_poles[2] = env->clip_planes[2].point[2];  /* Min-Z */
	VEstat_poles[3] = env->clip_planes[3].point[0];  /* Max-X */
	VEstat_poles[4] = env->clip_planes[4].point[1];  /* Max-Y */
	VEstat_poles[5] = env->clip_planes[5].point[2];  /* Max-Z */
	
	/* construct line segment that represents clip range diagonal */
	sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	                    osnum   = batch_env->md_id.osnum,
	                    classid = OPP_GR3dlineseg_class_id,
	 	            p_objid = &clip_diag_id );

	   OM_ERRCHK( sts, "VEconstruct_env_objects: om$construct (CLIP-DIAG) failed" );
	   MSG_ERRCHK( msg, "VEconstruct_env_objectsg:  GRconstruct (CLIP-DIAG) failed" );


	VEstat_poles[0] = VEstat_poles[1] = VEstat_poles[2] =
	VEstat_poles[3] = VEstat_poles[4] = VEstat_poles[5] = 0.0;

	if ( ! (env->ref_symb.flags & DPB_USE_ORIG_COLOR) )
	   {
	   /* construct point that represents color override */
	   dis_attr.color = env->ref_symb.color;

	   sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	                       osnum   = batch_env->md_id.osnum,
	                       classid = OPP_GR3dpoint_class_id,
	 	               p_objid = &color_id );

	      OM_ERRCHK( sts, "VEconstruct_env_objects: om$construct (COLOR) failed" );
	      MSG_ERRCHK( msg, "VEconstruct_env_objectsg:  GRconstruct (COLOR) failed" );
	   }
	else
	   color_id = NULL_OBJID;

	if ( ! (env->ref_symb.flags & DPB_USE_ORIG_STYLE) )
	   {
	   /* construct point that represents style override */
	   dis_attr.style = env->ref_symb.style;

	   sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	                       osnum   = batch_env->md_id.osnum,
	                       classid = OPP_GR3dpoint_class_id,
	 	               p_objid = &style_id );

	      OM_ERRCHK( sts, "VEconstruct_env_objects: om$construct (STYLE) failed" );
	      MSG_ERRCHK( msg, "VEconstruct_env_objectsg:  GRconstruct (STYLE) failed" );
	   }
	else
	   style_id = NULL_OBJID;

	if ( ! (env->ref_symb.flags & DPB_USE_ORIG_WEIGHT) )
	   {
	   /* construct point that represents weight override */
	   dis_attr.weight = env->ref_symb.weight;

	   sts = om$construct( msg     = message GRvg.GRconstruct( &cons_args ),
	                       osnum   = batch_env->md_id.osnum,
	                       classid = OPP_GR3dpoint_class_id,
	 	               p_objid = &weight_id );

	      OM_ERRCHK( sts, "VEconstruct_env_objects: om$construct (WEIGHT) failed" );
	      MSG_ERRCHK( msg, "VEconstruct_env_objectsg:  GRconstruct (WEIGHT) failed" );
	   }
	else
	   weight_id = NULL_OBJID;

	VEadd_env_objects_to_dir( batch_env->md_id.osnum, env->attach_id,
	                          clip_diag_id, color_id, style_id, weight_id );

	}  /* VEconstruct_env_objects */


/*--- VEget_env_info_from_objects -------------------------------------*/

#if defined(__STDC__)
void VEget_env_info_from_objects( OMuword           osnum,
				  OM_S_OBJID        clip_diag_id,
				  OM_S_OBJID        color_id,
				  OM_S_OBJID        style_id,
				  OM_S_OBJID        weight_id,
				  struct VEenv_info *env )
#else
void VEget_env_info_from_objects( osnum, clip_diag_id, color_id, style_id, weight_id, env )

	OMuword           osnum;
	OM_S_OBJID        clip_diag_id;
	OM_S_OBJID        color_id;
	OM_S_OBJID        style_id;
	OM_S_OBJID        weight_id;
	struct VEenv_info *env;
#endif

/*
NAME
	VEget_env_info_from_objects

DESCRIPTION
	This function sets the special data about an enviroment that is
	reprsented by objects placed in the batch object space.  The data
	that is set is:

	   - the clipping planes of the environment which are defined by a
	     line segment that represents the clipping range diagonal

	   - the color override of the environment which is defined by a point
	     whose color represents the override, if one exists

	   - the style override of the environment which is defined by a point
	     whose style represents the override, if one exists

	   - the weight override of the environment which is defined by a point
	     whose weight represents the override, if one exists

PARAMETERS
	osnum (IN) - the object space that contains environment objects
	clip_diag_id (IN) - the object id of the clipping diagonal object
	color_id (IN) - the object id of the color object
	style_id (IN) - the object id of the style object
	weight_id (IN) - the object id of the weight object
	env (IN/OUT) - the VE environment that is to be filled in
		
GLOBALS USED
	VEwin_info
	
HISTORY
	06/15/89    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             sts;
	IGRlong             msg;
	struct GRsymbology  element_symb;
	struct IGRbsp_curve *curve;

	/* get the geometry of the line segment => it will be the */
	/* clipping range for the objects in this attachment      */
	sts = om$send( msg      = message GRvg.GRgenabsg( &msg,
	                                                  &env->matrix_type,
	                                                  env->matrix,
	                                                  (IGRchar **)&curve ),
	               targetid = clip_diag_id,
	               targetos = osnum,
	               senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "VEget_env_info_from_objects: GRgenabsg send failed" );
	   MSG_ERRCHK( msg, "VEget_env_info_from_objects:  GRgenabsg failed" );

	/* get the clipping planes for this environment */
	if ( 1 & sts & msg )
	  VEassign_clipping_planes_from_range( env->clip_planes, curve->poles );
	else
	  {
	  /* couldn't get geometry from clipping line segment => assign */
	  /* clipping planes to the range of the window                 */
	  VEassign_clipping_planes_from_range( env->clip_planes, VEwin_info.clip_range );
	  }

	DELETE_OBJECT( clip_diag_id );

	env->ref_symb.flags |= DPB_USE_ORIG_COLOR;
	if ( color_id != NULL_OBJID )
	   {
	   /* get the color override */
	   GET_SYMBOLOGY( color_id );

	   if ( 1 & sts & msg )
	      {
	      env->ref_symb.color = element_symb.display_attr.color;
	      env->ref_symb.flags &= ~DPB_USE_ORIG_COLOR;
	      }

	   DELETE_OBJECT( color_id );
 	   }

	env->ref_symb.flags |= DPB_USE_ORIG_STYLE;
	if ( style_id != NULL_OBJID )
	   {
	   /* get the style override */
	   GET_SYMBOLOGY( style_id );
	   
	   if ( 1 & sts & msg )
	      {
	      env->ref_symb.style = element_symb.display_attr.style;
	      env->ref_symb.flags &= ~DPB_USE_ORIG_STYLE;
	      }

	   DELETE_OBJECT( style_id );
 	   }

	env->ref_symb.flags |= DPB_USE_ORIG_WEIGHT;
	if ( weight_id != NULL_OBJID )
	   {
	   /* get the weight override */
	   GET_SYMBOLOGY( weight_id );

	   if ( 1 & sts & msg )
	      {
	      env->ref_symb.weight = element_symb.display_attr.weight;
	      env->ref_symb.flags &= ~DPB_USE_ORIG_WEIGHT;
	      }

	   DELETE_OBJECT( weight_id );
 	   }

	}  /* VEget_env_info_from_objects */

end implementation Root;
