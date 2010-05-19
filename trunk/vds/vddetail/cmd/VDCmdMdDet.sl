/* $Id: VDCmdMdDet.sl,v 1.1.1.1 2001/01/04 21:08:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddetail/cmd / VDCmdMdDet.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdMdDet.sl,v $
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
# Revision 1.10  1996/05/16  10:15:30  pinnacle
# Replaced: vddetail/cmd/VDCmdMdDet.sl for:  by rgade for vds.240
#
# Revision 1.9  1996/04/29  05:51:42  pinnacle
# Replaced: vddetail/cmd/VDCmdMdDet.sl for:  by rgade for vds.240
#
# Revision 1.8  1996/04/22  09:26:58  pinnacle
# Replaced: vddetail/cmd/VDCmdMdDet.sl for:  by rgade for vds.240
#
# Revision 1.7  1996/04/21  16:30:30  pinnacle
# Replaced: vddetail/cmd/VDCmdMdDet.sl for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/07  22:23:12  pinnacle
# Replaced: vddetail/cmd/VDCmdMdDet.sl for:  by azuurhou for vds.240
#
# Revision 1.2  1995/06/02  13:02:18  pinnacle
# Replace: vddetail/cmd/VDCmdMdDet.sl by azuurhou for OPE
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/11  22:42:50  pinnacle
# updated files
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/* **************************************************************************

	File name :		VDCmdMdDet.sl
	Creation date :		92/03/25
	Revision date :		92/06/11 ( ADZ )
	Author  :		Alain CLAUDE
	Product :		I/VDS - VDSdetail
				"Modify clipping polygon of drawing view"

	Description : 
	-----------
		The command object VDCmdMdDet is a subclass of CEO_LOCATE. 

		This command object allows the user to modify a drawing view 
		(GRdrawview) (or a reference file attachment (GRreffile)) by 
		acting on the clipping polygon associated with the reference
		file owned by the drawing view attachment.  The reference
		file attachment is updated whenever the clipping polygon is
		modified.

		The processing is done in 3 steps :
		   - Enter new scale for drawing view, or for reference file.
		   - Enter new Z-depths for the clipping polygon.
		   - Select vertex of the clipping polygon to be modified 
		(note: the vertex transformation is done in the relative xy 
		directions of the clipping polygon).  

	History :

		92/04/08	alc	Initial release
		92/05/27	alc	Get rid of unnecessary re-display
                92/06/05        adz     Add EX_RJT_MOVEON in start state.
                                        Changed message. prompt and status
                                        strings by key values in VDdetail.mb
		93/01/28	adz	Displaying in user defined units.


   ************************************************************************** */


/*
	Class specification 
 */


command_string	VDC_M_MdCpDrVw, 0, VDMdCpDrVw
/* synonym	VDC_M_MdDrwVw, 0, VDMdCpDrVw */
class		"VDCmdMdDet"
super_class	"VDS_LOCATE"
product_name    "$VDS"
command_table	"vds.cmd"
options         "SITC"


/*
	Specification area
 */

specification

#include <stdio.h>
#include "dpmacros.h"
#include "OMmacros.h"
#include "grmacros.h"
#include "parametric.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "bserr.h"
#include "msdef.h"
#include "emssfintdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "detaildef.h"
#include "madef.h"


instance
{
	struct GRid	drawview ; /* selected drawing view to be modified */
	struct GRid	reffile  ; /* model attachment of drawing view     */
		/* 
		   Note :
			If a reference file has been selected instead of
			a drawing view, me->drawview.objid will be set to
			NULL_OBJID.
		 */

	struct GRid	clippoly ; 	/* associated clipping polygonw    */
	struct GRparms	clip_parms ;	/* geometric parms  of clippoly    */

	struct GRmd_env dv_mod_info ;	/* module information of drawview  */

	IGRchar		old_scale_string[256] ;
	IGRchar		scale_string[256] ;
					/* scale of drawview or reffile    */

	IGRdouble	z1, z2 ;	/* Z depths of clipping polygon    */

	struct GRevent	from_pt_event ; /* event needed for dynamics) */
	IGRpoint	from_point ;    /* from point (vertex to be modified) */
	IGRpoint	to_point   ;    /* to point   (new vertex position)   */
}


/*
	Implementation area
 */

implementation

#include <stdlib.h>

/* include/prototypes */
/**
  #include "VDpr_detail.h"
 **/
#include "bstypes.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "macpexten.h"
#include "mainvscmx.h"
#include "mamulmx.h"
#include "matypemx.h"

#define	RC_NEED_OTHER_Z		2000		/* see action get_new_Zdepths */

from GRdrawview import GRget_drawing_attachment_id, 
				GRget_drawview_scale, GRscale_drawing_view ;
from GRdvattach import GRget_component_id ;
from GRreffile  import GRcopy, GRdelete, 
				GRgetscale, GRgetenvironment, GRaltscale ;
from GRgraphics import GRdisplay, GRptproject ;
from GRvg       import GRchgprops ;
from IGEdisplay import DPupdate   ;
from GRclippoly import GRgenprism, GRmodify_height, GRmodify ;
from GRcontext	import GRupdatectx;

struct dyn_args {				/* Structure for dynamics    */
	struct GRid	clippoly   ;		/* Clipping polygon */
	struct GRid	clone_clip ;		/* Clone of clipping polygon */
	IGRboolean	clone_exists  ;
	struct GRmd_env	LocateContext ;		
	struct GRmd_env	NewContext ;		
	struct GRevent	from_pt_event ;		/* Event to get vertex */
	GRobjid		cob_objid  ;
	} ;

extern			GRdisplay_object() ;
extern			DPerase_hilite(), DPdynflags() , DPdynamics() ;
extern			GRbrlnconstr()  ;
extern			GRmodel_scale() ;
extern			pr_mat() ;
extern			VDctx_SetRecomputeDrawingFlag();


/* ------------------------------------------------------------------
			Utilities functions 
   ------------------------------------------------------------------ */

static IGRlong get_reffile(drawview, reffile)
   struct GRid		*drawview ; /* I : drawing view     */
   struct GRid		*reffile  ; /* O : model attachment */

/*
	Description :	This function gets the GRid of the model attachment
			(reference file) of a drawing view.
			A return code of 1 is for success.
 */

{
IGRlong			msg, sts ;
struct GRid		da_id    ;	  /* GRid of drawing view attachment */
struct GRid		da_ref_ids[1]   ; /* GRid of reference file object   */
IGRint			da_ref_types[1] ;

/* Get drawing view attachment component */
sts = om$send(	msg	 = message GRdrawview.GRget_drawing_attachment_id
						(&msg, &da_id), 
		senderid = NULL_OBJID,
		targetid = drawview->objid, 
		targetos = drawview->osnum	) ;
as$status(sts = sts) ;
if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("get_reffile() : message GRdrawview.GRget_drawing_attachment_id() unsuccessful \n") ;
	#endif
	return 0 ;	/* error */
	}

#if 0
gr$display_object( object_id = &da_id, mode = GRhd); 
#endif

/* Get model attachment (reference file object) component */
sts = om$send(	msg	 = message GRdvattach.GRget_component_id 
	(&msg, GR_DV_REFFILE, 1, &da_ref_ids[0], &da_ref_types[0]),
		senderid = NULL_OBJID,
		targetid = da_id.objid,
		targetos = da_id.osnum	) ;
as$status(sts = sts) ;
if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("get_reffile() : message GRdvattach.GRget_component_id() unsuccessful \n") ;
	#endif
	return 0 ;	/* error */
	}

reffile->objid = da_ref_ids[0].objid ; /* function output */
reffile->osnum = da_ref_ids[0].osnum ;

#if 0 
printf("objid/osnum of reference file is %d/%d \n", reffile->objid,
						    reffile->osnum) ;
gr$display_object( object_id = reffile, mode = GRhhdo) ; 
#endif

return 1 ;	/* success */
} /* get_reffile() */


/* ------------------------------------------------------------------ */

static IGRlong get_clippoly(reffile, clippoly)
   struct GRid		*reffile  ; /* I : reference file (GRreffile)     */
   struct GRid		*clippoly ; /* O : clipping polygon of model att. */

/*
	Description :	Get the GRid of the clipping polygon given the GRid
			of the reference file (model attachment).
			A return code of 1 is for success.
 */

{
IGRlong			sts ;

OM_S_CHANSELECT 	poly_chan   ;
OM_S_OBJECT_LINKAGE	list_clippoly[1]; /* unique */
OMuint			count_poly  ;

/* Get the clipping polygon */
om$make_chanselect(	channame 	= "GRreffile.to_clip",
                	p_chanselect 	= &poly_chan	) ;

sts = om$get_channel_objects( 	osnum 		= reffile->osnum,
				objid		= reffile->objid,
				p_chanselect 	= &poly_chan,
                        	list		= list_clippoly,
                        	size		= 1,
                        	count		= &count_poly	) ;
as$status(sts = sts) ;
if (sts != OM_S_SUCCESS) {
	#ifdef DEBUG
	printf("get_clippoly() : macro om$get_channel_objects() unsuccessful \n") ;
	#endif
	return 0 ;	/* error */
	}

clippoly->objid = list_clippoly[0].S_objid ; /* function output */
clippoly->osnum = list_clippoly[0].osnum   ;

#if 0
printf("objid/osnum of clipping polygon is %d/%d \n", 	clippoly->objid,
							clippoly->osnum) ;
gr$display_object( object_id = clippoly, mode = GRhhdo) ; 
#endif

return 1 ;	/* success */
} /* get_clippoly() */


/* ------------------------------------------------------------------ */

static IGRlong display_clippoly(clippoly, mod_env, display_flag)
   struct GRid		*clippoly    ; /* I : clipping polygon or reffile */
   struct GRmd_env	*mod_env     ; /* I : module env. of drawing view */
   IGRboolean		display_flag ; /* I : TRUE => on ; FALSE => off   */

/*
	Description :	Make displayable or un-displayable the given clipping 
			polygon, then display (GRbd) or un-display (GRbeheo) it.
			A return code of 1 is for success.
 */

{
IGRlong			msg, sts ;

IGRshort            	set         ; 
IGRshort 		property    ;
struct GRmd_env		display_env ;
IGRint			bytes_in, bytes_out ;
enum  GRdpmode   	mode ;

#ifdef DEBUG
	printf("   ---> Call to display_clippoly() \n")   ;
	printf("   display_flag is %d \n", display_flag) ;
#endif

/* Make given graphic object displayable */

property = GRIS_DISPLAYABLE ;
if (display_flag)	set = 1 ;	/* set property */
else			set = 0 ;	/* reset property with mask */
property 	= GRIS_DISPLAYABLE ;

sts = om$send(	msg 	 = message GRvg.GRchgprops(&msg, &set, &property),
		senderid = NULL_OBJID,
		targetid = clippoly->objid,
		targetos = clippoly->osnum) ;
as$status(sts = sts) ;
if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("display_clippoly() : message GRvg.GRchgprops() unsuccessful \n") ;
	#endif
	return 0 ;	/* error */
	}

/* Get the enviroment in which displays are to take place */

bytes_in = sizeof(display_env);
gr$get_display_env(	msg 	= &msg,
 			sizbuf	= &bytes_in,
   			buffer 	= &display_env,
   			nret 	= &bytes_out	);
if (!(msg & 1)) {
	#ifdef DEBUG
	printf("display_clippoly() : macro gr$get_display_env() unsuccessful \n") ;
	#endif
	return 0 ; 	/* error */
	}
#if 0
printf("display_env.md_id is %d/%d \n", display_env.md_id.objid,
					display_env.md_id.osnum) ;
#endif

/* Display the clipping polygon */

if (display_flag)	mode = GRbd    ; 	  /* background draw  */
else			mode = GRbeheo ; 
			/* background erase, highlight erase override */

sts  = om$send(	msg = message GRgraphics.GRdisplay(
					&msg,
					&mod_env->md_env.matrix_type,
					mod_env->md_env.matrix,
					&mode,
					&display_env.md_id),
		senderid = NULL_OBJID,
		targetid = clippoly->objid,
		targetos = clippoly->osnum) ;
as$status(sts = sts) ;
if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("display_clippoly() : GRgraphics.GRdisplay() failed \n") ;
	#endif
	return 0 ; 	/* error */
	}

return 1 ;		/* success */
} /* display_clippoly() */


/* ------------------------------------------------------------------ */

static IGRlong get_clip_extents(clippoly, mod_env, low_point, high_point, norm)
   struct GRid		*clippoly  ;	/* I */
   struct GRmd_env	*mod_env   ; 	/* I : module env. of drawing view */
   IGRpoint		low_point  ;	/* O : extent of clipping polygon  */
   IGRpoint		high_point ;    /* O :	in world coordinates       */
   IGRvector		norm ;		/* O : drawing view normal         */

/*
	Description :
		This function returns the extents and the relative Z normal
		in world coordinates.
 */
{
IGRlong			sts, msg ;
BSrc			rc ;
struct IGRcv_prism	*prism_ptr ; /* ptr to abstract data cache */

#ifdef DEBUG
	printf("   ---> Call to get_clip_extents() \n")   ;
#endif

sts = om$send(	msg = message GRclippoly.GRgenprism(
				&msg, 
				&mod_env->md_env.matrix_type, 
				mod_env->md_env.matrix,
				(IGRchar **) &prism_ptr),
		senderid = NULL_OBJID,
                targetid = clippoly->objid,
                targetos = clippoly->osnum) ;
as$status(sts = sts) ;
if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("get_clip_extents() : message GRclippoly.GRgenprism() \n") ;
	#endif
	return 0 ; 	/* error */
	}

/* Get local Z direction of prism in world coordinates */
norm[0] = prism_ptr->matrix[2] ;
norm[1] = prism_ptr->matrix[6] ;
norm[2] = prism_ptr->matrix[10] ;
BSnorvec(&rc, norm) ;

/* Determine the extents of the curve prism geometry in world coordinates */
MAcpextents(&msg, prism_ptr, low_point, high_point) ;
if (msg != MSSUCC) {
	#ifdef DEBUG
	printf("get_clip_extents() : function MAcpextents() failed \n") ;
	#endif
	return 0 ; 	/* error */
	}

return 1 ;	/* success */
} /* get_clip_extents() */


/* ------------------------------------------------------------------ */

static IGRlong get_z_depths(clippoly, mod_env, z1, z2)
   struct GRid		*clippoly ;	/* I */
   struct GRmd_env	*mod_env ; 	/* I : module env. of drawing view */
   IGRdouble		*z1, *z2 ;	/* O : z depths (relative to view) */ 

/*
	Description :	get the Z depths of a drawing view from the clipping
			polygon prism of the reference file owned
			by the drawing attachment of the drawing view.
		A return code of 1 is for success.
 */

{
IGRlong		sts;
BSrc		rc ;
IGRdouble	low_point[3], high_point[3], world_norm[3] ;
IGRdouble	max_z ;

#ifdef DEBUG
	printf("   ---> Call to get_z_depths() \n")   ;
#endif

/* Get clippoly extents */
sts = get_clip_extents(	clippoly, mod_env, 
			&low_point[0], &high_point[0], &world_norm[0] ) ;
if (sts != 1) {
	#ifdef DEBUG
	printf("get_z_depths() : function get_clip_extents() failed \n") ;
	#endif
	return 0 ; 	/* error */
	}

/* Get relative Z depths of drawing view in world coordinates */
*z1 = BSdotp(&rc, &low_point[0],  &world_norm[0]) ;
if (rc != BSSUCC) {
	#ifdef DEBUG
	printf("get_z_depths() : function BSdotp() failed \n") ;
	#endif
	return 0 ; 	/* error */
	}

*z2 = BSdotp(&rc, &high_point[0], &world_norm[0]) ;
if (rc != BSSUCC) {
	#ifdef DEBUG
	printf("get_z_depths() : function BSdotp() failed \n") ;
	#endif
	return 0 ; 	/* error */
	}

if (*z1 > *z2) {
	/* depending on orientation (e.g. drawing sheet put on the front view) */
	max_z = *z1 ; *z1 = *z2 ; *z2 = max_z ;
	}

return 1 ; 		/* success */
} /* get_z_depths() */


/* ------------------------------------------------------------------ */

static IGRlong proc_z_depths(clippoly, mod_env, z1, z2)
   struct GRid		*clippoly ; /* I */
   struct GRmd_env	*mod_env  ; /* I : module env. of drawing view     */
   IGRdouble		z1, z2    ; /* I : new z depths (relative to view) */ 

/*
	Description :
		This function updates the relative Z-depths of drawing view
		given in local z coordinates of the clipping polygon.
		A return code of 1 indicates a sucessful completion.
 */

{
IGRdouble	low_point[3], high_point[3], world_norm[3], aux_point[3] ;
IGRdouble	from_point[3], to_point[3], borept1[3], borept2[3] ;
IGRdouble	z_aux, check1, check2 ;
IGRdouble	z1old, z2old;
struct GRparms	clippoly_parms ;
struct IGRline	boreline ;
IGRint		i  ;
BSrc		rc ;
IGRlong		msg, sts ;

#ifdef DEBUG
	printf("   ---> Call to proc_z_depths() \n")   ;
	printf("   z1 and z2 are <%f> and <%f> \n", z1, z2) ;
#endif

   sts = get_clip_extents(	clippoly, mod_env,
				&low_point[0], &high_point[0], &world_norm[0]) ;
   if (sts != 1) {
	#ifdef DEBUG
	printf("proc_z_depths() : function get_clip_extents() failed \n") ;
	#endif
	return 0 ; 	/* error */
	}

   clippoly_parms.u 		= 0 ;
   clippoly_parms.v 		= 0 ;
   clippoly_parms.polygon_inx 	= 2 ; 		/* param not on curve */
   clippoly_parms.leaf_id 	= *clippoly ;	/* GRid of clippoly   */

   boreline.point1 = &borept1[0] ;
   boreline.point2 = &borept2[0] ;

/* z1 and z2 should be different */
if (z1 == z2) z1 = 0 ;

/* Force z1 to be the minimum relative Z depth of drawing view (if needed) */
if (z2 < z1) {
	z_aux = z1 ; z1 = z2 ; z2 = z_aux ;
	} 

/* Look at drawing sheet orientation (e.g. when put on the front view) */
check1 = BSdotp(&rc, &low_point[0],  &world_norm[0])  ; 
if (rc != BSSUCC) return 0 ;
check2 = BSdotp(&rc, &high_point[0],  &world_norm[0]) ;
if (rc != BSSUCC) return 0 ;
if (check2 < check1) {
	for (i = 0 ; i < 3 ; i = i+1) {
		aux_point[i]  = low_point[i]  ; 
		low_point[i]  = high_point[i] ;	
		high_point[i] = aux_point[i]  ;
		}
	}

/* get old z-depths of drawing view */

sts = get_z_depths( clippoly, mod_env, &z1old, &z2old );
if (sts != 1) {
	#ifdef DEBUG
	printf("proc_z_depths() : function get_z_depths() failed \n") ;
	#endif
	return 0 ; 	/* error */
}


/* Update new relative z1 depth, applied to low_point */

  from_point[0] = low_point[0] ;
  from_point[1] = low_point[1] ;
  from_point[2] = low_point[2] ;

  to_point[0] = z1 * world_norm[0] ;
  to_point[1] = z1 * world_norm[1] ;
  to_point[2] = z1 * world_norm[2] ;

  if ( z1 == z2old )
  {
	/*
	 * when this case arises, first move high_point and then low_point
	 *		Raju  5/31/1995
	 */
	from_point[0] = high_point[0] ;
	from_point[1] = high_point[1] ;
	from_point[2] = high_point[2] ;

	to_point[0] = z2 * world_norm[0] ;
	to_point[1] = z2 * world_norm[1] ;
	to_point[2] = z2 * world_norm[2] ;
  }     


  
   GRbrlnconstr(&msg, &to_point[0], mod_env->md_env.matrix, &boreline);
   if (!(msg & 1)) {
	#ifdef DEBUG
	printf("proc_z_depths() : function GRbrlnconstr() failed \n") ;
	#endif
	return 0 ; /* error */
	}

   sts = om$send(msg = message GRclippoly.GRmodify_height(&msg,
                     mod_env, 
                     &clippoly_parms,
                     &from_point[0],
                     &boreline),
		     senderid = NULL_OBJID,
                     targetid = clippoly->objid,
                     targetos = clippoly->osnum) ;
   as$status(sts = sts) ;
   if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("proc_z_depths() : message GRclippoly.GRmodify_height() failed \n") ;
	#endif
	return 0 ; /* error */
	}

/* Update new relative z2 depth, applied to high_point */

  from_point[0] = high_point[0] ;
  from_point[1] = high_point[1] ;
  from_point[2] = high_point[2] ;

  to_point[0] = z2 * world_norm[0] ;
  to_point[1] = z2 * world_norm[1] ;
  to_point[2] = z2 * world_norm[2] ;

  if ( z1 == z2old )
  {
	/*
	 * when this case arises, first move high_point and then low_point
	 *		Raju  5/31/1995
	 */
	from_point[0] = low_point[0] ;
	from_point[1] = low_point[1] ;
	from_point[2] = low_point[2] ;

	to_point[0] = z1 * world_norm[0] ;
	to_point[1] = z1 * world_norm[1] ;
	to_point[2] = z1 * world_norm[2] ;
  }     

   GRbrlnconstr(&msg, &to_point[0], mod_env->md_env.matrix, &boreline);
   if (!(msg & 1)) {
	#ifdef DEBUG
	printf("proc_z_depths() : function GRbrlnconstr() failed \n") ;
	#endif
	return 0 ; /* error */
	}

   sts = om$send(msg = message GRclippoly.GRmodify_height(&msg,
                     mod_env, 
                     &clippoly_parms,
                     &from_point[0],
                     &boreline),
		senderid = NULL_OBJID,
                targetid = clippoly->objid,
                targetos = clippoly->osnum) ;
   if (!(sts & msg & 1)) {
        UI_status("Modify zdepths failed");
	#ifdef DEBUG
	printf("proc_z_depths() : message GRclippoly.GRmodify_height() failed \n") ;
	#endif
	return 0 ; /* error */
	}

return 1 ; /* success */
} /* proc_z_depths() */


/* ------------------------------------------------------------------ */

static IGRlong proc_xy_vertex(clippoly, mod_env, fr_vert_loc, fr_point, to_point)
   struct GRid		*clippoly ; 	/* I/O */
   struct GRmd_env	*mod_env  ; 	/* I : module env. of drawing view */
   struct GRparms	*fr_vert_loc ;	/* I */
   IGRdouble		*fr_point, *to_point ; /* I : from and to points   */

/*
	Description :
		This function updates the relative bottom (or top) face
		of a drawing view given the old vertex and new vertex
		positions (fr_point and to_point).
		A return code of 1 indicates a sucessful completion.
 */

{
IGRdouble	borept1[3], borept2[3] ;
struct IGRline	boreline ;
IGRlong		msg, sts ;

#ifdef DEBUG
	printf("   ---> Call to proc_xy_vertex() \n")   ;
#endif

   boreline.point1 = &borept1[0] ;
   boreline.point2 = &borept2[0] ;

   GRbrlnconstr(&msg, &to_point[0], mod_env->md_env.matrix, &boreline);
   if (!(msg & 1)) {
	#ifdef DEBUG
	printf("proc_xy_vertex() : function GRbrlnconstr() failed \n") ;
	#endif
	return 0 ; /* error */
	}

   sts = om$send(msg = message GRclippoly.GRmodify(&msg,
		                     	mod_env, 
                     			fr_vert_loc,
                     			&fr_point[0],
                     			&boreline,
					&clippoly->objid),
		     senderid = NULL_OBJID,
                     targetid = clippoly->objid,
                     targetos = clippoly->osnum) ;
   if (!(sts & msg & 1)) {
        UI_status("Modify vertex failed" );
	#ifdef DEBUG
	printf("proc_xy_vertex() : message GRclippoly.GRmodify() failed \n") ;
	#endif
	return 0 ; /* error */
	}
    UI_status("Modify vertex Successesfull");
#ifdef DEBUG
	printf("Success for proc_xy_vertex() \n") ;
	printf("Clipping polygon is %d / %d \n", clippoly->objid, clippoly->osnum) ;
#endif
return 1 ; /* success */
} /* proc_xy_vertex() */


/* -------------------------------------------------------------------- */

long  VDgetcontextid( msg, refid, ctxid )
IGRlong         *msg;     /* O-OUTPUT */
struct GRid     *refid;   /* I-INPUT  */
struct GRid     *ctxid;   /* O-OUTPUT */
{

int                     sts = OM_S_SUCCESS ;
OM_S_OBJECT_LINKAGE     list[2];
OM_S_CHANSELECT         to_context;
int                     count;

 ctxid->objid = NULL_OBJID ;

 sts = om$make_chanselect (   channame = "GRreffile.to_context",
                                        p_chanselect = &to_context );

 sts = om$get_channel_objects(  osnum           = refid->osnum,
                                objid           = refid->objid,
                                p_chanselect    = &to_context,
                                list            = list,
                                size            = 1,
                                count           = (OMuint * )&count   ) ;

 if( ! (sts&&1) ) { return FALSE; }

 ctxid->objid = list[0].S_objid;
 ctxid->osnum = list[0].osnum;
 *msg = MSSUCC;

 return TRUE;
}

/*---------------------------------------------------------------------------*/

static IGRint DYclipxymod(dptr, point, matrix, 
		objects, num_objects, buffers, num_buffers,
		in_dummy1,  in_dummy2,  in_dummy3,
		out_dummy1, out_dummy2, out_dummy3)
   struct dyn_args	*dptr  ;
   struct EX_button	*point ;
   IGRdouble		*matrix ;
   struct GRid		**objects    ;
   IGRint		*num_objects ;
   struct DPele_header  **buffers ;
   IGRint		*num_buffers ;
   IGRchar		*in_dummy1 ;
   IGRchar		*in_dummy2 ;
   IGRchar		*in_dummy3 ;
   IGRchar		**out_dummy1 ;
   IGRchar		**out_dummy2 ;
   IGRchar		**out_dummy3 ;
{
struct IGRline	dyn_boreline ;
IGRpoint	pts1, pts2   ;
IGRpoint	event_from_point, clone_from_point, to_point ;
struct GRparms	clone_clip_parms ;
IGRlong		msg, sts ;

#ifdef DEBUG
	printf("   ---> Call to DYclipxymod() \n") ;
#endif

event_from_point[0] = dptr->from_pt_event.event.button.x ;
event_from_point[1] = dptr->from_pt_event.event.button.y ;
event_from_point[2] = dptr->from_pt_event.event.button.z ;

to_point[0] = point->x ; to_point[1] = point->y ; to_point[2] = point->z ;

/*
	If the clone already exists, delete it
 */

if (dptr->clone_exists) {
	sts = om$send(msg = message GRgraphics.GRdelete(&msg,
				&dptr->NewContext),
		senderid = dptr->cob_objid,
		targetid = dptr->clone_clip.objid,
		targetos = dptr->clone_clip.osnum) ; as$status(sts = sts) ;
	if (!(sts & msg & 1)) {
		#ifdef DEBUG
		printf("warning in DYclipxymod() : GRgraphics.GRdelete() failed \n") ;
		#endif
		; /* nop */
		}
	else dptr->clone_exists = FALSE ;
	}

/* 
	Make a clone of the clipping polygon
 */

sts = om$send(msg	= message GRgraphics.GRcopy(&msg,
				&dptr->LocateContext,
				&dptr->NewContext,
				&dptr->clone_clip.objid),
		senderid = dptr->cob_objid,
		targetid = dptr->clippoly.objid,
		targetos = dptr->clippoly.osnum) ; as$status(sts = sts) ;
if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("DYclipxymod() : GRgraphics.GRcopy() failed \n") ;
	#endif
	return MSFAIL ;
	}
dptr->clone_clip.osnum = dptr->NewContext.md_id.osnum ;
dptr->clone_exists     = TRUE ;

/*
	Project event the clipping polygon clone
 */

sts = om$send(	msg	= message GRgraphics.GRptproject(
					&msg,
					&dptr->NewContext.md_env.matrix_type,
					dptr->NewContext.md_env.matrix,
					event_from_point,	/* I */
					clone_from_point,	/* O */
					&clone_clip_parms),	/* O */
			senderid = dptr->cob_objid,
			targetid = dptr->clone_clip.objid,
			targetos = dptr->clone_clip.osnum) ; as$status(sts = sts) ;
if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("DYclipxymod() : GRgraphics.GRptproject() failed \n") ;
	#endif
	return MSFAIL ;
	}

/*
	Construct the boreline
 */

dyn_boreline.point1 = pts1 ; dyn_boreline.point2 = pts2 ;
GRbrlnconstr(&msg, to_point, matrix, &dyn_boreline) ;
if (!(msg & 1)) {
	#ifdef DEBUG
	printf("DYclipxymod() : error in GRbrlnconstr() \n") ;
	#endif
	return MSFAIL ;
	}

/*
	Modify the clipping polygon face (relative xy directions)
 */

#ifdef DEBUG
printf("dptr->clone_clip is %d / %d \n", 	dptr->clone_clip.objid, 
						dptr->clone_clip.osnum) ;
#endif

sts = om$send(msg = message GRclippoly.GRmodify(&msg,
					&dptr->NewContext,
					&clone_clip_parms,
					clone_from_point,
					&dyn_boreline,
					&dptr->clone_clip.objid),
		     senderid = dptr->cob_objid,
                     targetid = dptr->clone_clip.objid,
                     targetos = dptr->clone_clip.osnum) ; as$status(sts = sts) ;
if (!(sts & msg & 1)) {
	#ifdef DEBUG
	printf("DYclipxymod() : message GRclippoly.GRmodify() failed \n") ;
	#endif
	return MSFAIL ; /* error */
	}

*num_buffers = 0 ; *buffers = NULL ;
*num_objects = 1 ; *objects = &dptr->clone_clip ;

return MSSUCC ; /* success */
} /* DYclipxymod() */


/* ------------------------------------------------------------------
			State table
   ------------------------------------------------------------------ */


state_table

#include "VDmsg.h"

#define	RC_NEED_OTHER_Z		2000		/* see action get_new_Zdepths */

state start

	message_key		VD_M_MdCpDrVw	
	prompt_key  		VD_P_IdDrVwRfFl
	accept_key  		VD_P_AccRej
 	relocate_key		VD_P_ObjNtFnd
	locate_eligible		"GRdrawview, GRreffile"
	locate_properties	"LC_DP_ONLY | LC_LC_ONLY | LC_RW"
  	locate_owner		"LC_RIGID_OWNER | LC_FLEX_OWNER | LC_FLEX_COMP"
  	locate_display		"ELEM_HILIGHT"
	dynamics		0
  	mask			"GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP"
	filter			locate	

	on EX_RJT_MOVEON	state terminate

	on EX_DATA
		do erase_highlight
		do get_drawview	   /* Get drawview, reffile and clippoly */
 		   on ERROR
			do status_key VD_E_UnableCP 		state terminate
		state St_Scale


state St_Scale

	execute	display_Scale      /* Display current scale of drawing view */

	message_key	VD_M_MdCpDrVw	
	prompt_key  	VD_P_KeyScale
	dynamics	0
  	mask		"GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP"
	filter		get_event	

	on EX_BACK_UP
		state start 	/* Backtrack */

	on EX_RJT_MOVEON
		state St_Z1	/* Keep the previous scale */

	on NULL_STRING
		state .

	on EX_STRING
		do get_new_Scale	/* Read keyboard */
		   on ERROR
			do status_key VD_E_CntRdScale			state .
		do undisplay_for_scaling
		do apply_new_Scale	/* Scale drawview or reffile */
		   on ERROR
			do status_key VD_E_CntStScale
			do display_for_scaling
			state St_Scale
		do display_for_scaling	/* Then, re-display update */
		state St_Z1

		
state St_Z1

	execute	display_Zdepths	   /* Display current Z depths of clippoly */

	message_key	VD_M_MdCpDrVw
	prompt_key	VD_P_KeyZDMv  
	dynamics	0
  	mask		"GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP"
	filter		get_event	

	on EX_BACK_UP
		state St_Scale 		/* Backtrack */

	on EX_RJT_MOVEON
		state St_FromVertex	/* Keep the previous Z-depths */

	on NULL_STRING
		state .

	on EX_STRING
		do get_new_Zdepths	/* Read keyboard */
		   on RETURN_CODE = RC_NEED_OTHER_Z		state St_Z2
		   on ERROR do status_key VD_E_CntGtZD		state .
		state St_Zdepths	/* Ready to set Z depths */


state St_Z2

	message_key	VD_M_MdCpDrVw
	prompt_key  	VD_P_KeyOtherZD
	dynamics	0
  	mask		"GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP"
	filter		get_event	

	on EX_BACK_UP or EX_RJT_MOVEON	/* Previous state */
		state St_Z1 	        /* Backtrack */

	on NULL_STRING
		state .

	on EX_STRING
		do get_other_Z	/* Read keyboard */
		   on ERROR
			do status_key	VD_E_CntGtOtZD			state .
		state St_Zdepths	/* Ready to set Z depths */


state St_Zdepths

		/* 
			Set new Z depths, and update reference file 
		 */

	execute undisplay_reference_file
	execute apply_new_Zdepths         /* Modify Z depths of clippoly  */
		   on ERROR
			do status_key VD_E_CntStNwZD		 state St_Z1
	execute display_Zdepths	      	  /* Display Z depths of clippoly */
	on SUCCESS
		state St_FromVertex
	

state St_FromVertex

	execute display_clipping_polygon  /* Display clipping polygon prism */

	message_key	VD_M_MdCpDrVw
	prompt_key  	VD_P_SlVrtMdMv
	dynamics	0
  	mask		"GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP"
	filter		get_event	

	on EX_BACK_UP
		do undisplay_clipping_polygon /* Make prism undisplayable */
		state St_Z1		      /* Backtrack */

	on EX_RJT_MOVEON		      /* Re-start command */
		do undisplay_clipping_polygon /* Make prism undisplayable */
		state start

	on EX_DATA
		do get_from_Vertex	/* Project on clipping polygon */
		   on ERROR
			do status_key VD_E_CntGtVrtCp		state .
		state St_ToVertex


state St_ToVertex

	message_key	VD_M_MdCpDrVw
	prompt_key	VD_P_EntDstPtMv
	dynamics	2
  	mask		"GRm_DATA | GRm_RJT_MOVEON | GRm_BACK_UP"
	filter		get_event	

	on EX_BACK_UP			      /* Previous state */
		state St_FromVertex

	on EX_RJT_MOVEON		      /* Re-start command */
		do undisplay_clipping_polygon /* Make prism undisplayable */
		state start

	on EX_DATA
		do get_new_Vertex		/* Get destination point */
		   on ERROR
			do status_key VD_E_CntGtDstPt		state .
		do undisplay_clipping_polygon 	/* Make prism undisplayable */
		do undisplay_reference_file
		do apply_new_Vertex
		   on ERROR
			do status_key VD_E_CntMdVrCp
			do display_clipping_polygon
			state .
		do display_clipping_polygon	/* Re-display clipping prism */
		do replace_from_Vertex		/* Update from vertex */
		   on ERROR
			do status_key VD_E_CntPrPtCp		state -
		state .				/* For ever */


/*
	------------------------------------------------------------------
			Actions definition
	------------------------------------------------------------------
 */


action init
/*.action init */
{
  status = om$send(msg	  = message CEO_LOCATE.init(type, str_ptr),
		 targetid = my_id,
		 mode	  = OM_e_wrt_message) ;
  if (!(status & 1)) {
	om$report_error(sts = status) ; /* warning */
	}
  me->drawview.objid = NULL_OBJID ;
  me->reffile.objid  = NULL_OBJID ;
  me->clippoly.objid = NULL_OBJID ;
		 /* flag to know if un-displaying is needed at delete() */

  goto quit;

} /*|end of action init() */


/* ------------------------------------------------------------------ */


action delete
/*.action delete */
{
  /* 
   * If needed, make the clipping polygon undisplayable and
   * undisplayed (GRbeheo)
   */
  if( me->clippoly.objid != NULL_OBJID) {
    status = display_clippoly(&me->clippoly, &me->dv_mod_info, FALSE); 
  }

  status =
  om$send(msg	  = message CEO_LOCATE.delete(f_defer_flag),
	 targetid = my_id,
	 mode	  = OM_e_wrt_message);
  as$status( action = RET_STATUS );

  goto quit;

}


/* ------------------------------------------------------------------ */

action erase_highlight
/*.action erase_highlight */
{
IGRlong      msg;
OM_S_OBJID   mod_objid;
OMuword      mod_osnum;

  status = 
  ex$get_cur_mod ( id = &mod_objid,
                   osnum = &mod_osnum ) ;

  status = 
  dp$erase_hilite( msg = &msg,
                   objid = mod_objid,
                   osnum = mod_osnum ) ;
  *sts = SUCC ;

  goto quit;
}


/* ------------------------------------------------------------------ */

action get_drawview
/*.action get_drawview */
/*
	Description :
		Initialize GRid and md_env of a drawing view.
		Get also the reference file and clipping polygon GRids which
		are associated with it.
	Note :
		The located object can be also a reference file instead of
		being a drawing view.
 */
{
struct GRid	lc_obj    ;
OMuword		obj_class ;
extern OMuword	OPP_GRdrawview_class_id,
		OPP_GRreffile_class_id ;

  lc_obj = me->event1.located_object[0].located_obj ; /* drawview or reffile */
  me->dv_mod_info = me->event1.located_object[0].module_info ;

  status = om$get_classid(	osnum = lc_obj.osnum,
				objid = lc_obj.objid,
				p_classid = &obj_class) ; as$status() ; 
  if(status != OM_S_SUCCESS) { *sts = ERRO ; goto quit ; }

  if (obj_class == OPP_GRdrawview_class_id) {
	me->drawview = lc_obj ;
	status = get_reffile(&me->drawview,  &me->reffile)  ;
	if (!(status & 1)) {
	  *sts = ERRO ; goto quit ;
	}
  }
  else if (obj_class == OPP_GRreffile_class_id) {
	me->drawview.objid = NULL_OBJID ; 
	/* flag to indicate that a reference file has been located */
	me->reffile = lc_obj ;
  }
  else {	
	#ifdef DEBUG
	  printf("Located object is neither GRdrawview nor GRreffile\n");
	#endif
	*sts = ERRO ; goto quit ;
  }

  /*
   * In both cases (GRdrawview or GRreffile), get the clipping polygon
   */
  status = get_clippoly(&me->reffile, &me->clippoly) ;
  if(!(status & 1)){
    *sts = ERRO; goto quit;
  }

  *sts = SUCC;
  goto quit ;
} /* get_drawview() */


/*
	------------------------------------------------------------------
 */


action display_Scale
/*.action display_Scale */
/*
	Description :
		Display in the status field the current scale of the
		given drawing view or reference file.
 */
{
IGRchar		local_scale_string[256], buffer[256] ;
IGRdouble	scale_xyz[3], local_scale ;
IGRlong		msg ;

if (me->drawview.objid != NULL_OBJID) {
	/*
		A drawing view has been located 
	 */

	status = om$send(msg = message GRdrawview.GRget_drawview_scale(
					&msg,
					&me->dv_mod_info,
					local_scale_string,
					scale_xyz
					),
			targetid = me->drawview.objid,
			targetos = me->drawview.osnum) ; as$status() ;
	if (!(status & msg & 1)) {
		#ifdef DEBUG
		printf("GRdrawview.GRget_drawview_scale() failed \n") ;
		#endif
		*sts = ERRO ; goto quit ;
		}
	strcpy(me->old_scale_string, local_scale_string) ;
	}
else {
	/*
		A reference file has been located
	 */

	status = om$send(msg = message GRreffile.GRgetscale(&msg, &local_scale),
			targetid = me->reffile.objid,
			targetos = me->reffile.osnum) ; as$status() ;
	if (!(status & msg & 1)) {
		#ifdef DEBUG
		printf("GRreffile.GRgetscale() failed \n") ;
		#endif
		*sts = ERRO ; goto quit ;
		}
	sprintf(me->old_scale_string, "%f", local_scale) ;
	}

sprintf(buffer, "Current scale is %s", me->old_scale_string) ;
ex$message(field = 2, in_buff = buffer) ;
*sts = SUCC ;
}/* display_Scale() */


/* ------------------------------------------------------------------ */

action get_new_Scale
/*.action get_new_Scale */
/*
	Description :
		Get the new scale from the keyboard.
 */
{
char	buffer[GR_MAX_CHAR + 1] ; 	/* user input */
char	*numerics, *aux ;

  status = OM_S_SUCCESS ;

  numerics = "0123456789.: " ;	/* dot, colon and space signs included also */
  strcpy(buffer, me->event1.event.keyin) ;

  /* Check if the user input is composed of numerics */
  for( aux = &buffer[0]; *aux != '\0'; aux++){
	if( strchr(numerics, *aux) == NULL ){
		/* not a numeric character */
		*sts = ERRO; goto quit;
	}
  }

  strcpy( me->scale_string, buffer );
  *sts = SUCC;
}/* get_new_Scale() */


/* ------------------------------------------------------------------ */

action display_for_scaling
/*.action display_for_scaling */
/*
	Description :
		This method re-displays a drawing view or a reference file.
		It should be used after a re-scaling operation (e.g.
		apply_new_Scale method).
 */
{
enum GRdpmode	mode ;
struct GRid	disp_obj ;
IGRlong		msg  ;

  mode   = GRbd ; 			/* Background draw */ 
  if (me->drawview.objid != NULL_OBJID) {
	disp_obj = me->drawview ;
  }
  else {
	disp_obj = me->reffile ;
  }

  status = om$send(	msg	= message GRgraphics.GRdisplay(&msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&mode,
					&me->ModuleInfo.md_id),
			targetid = disp_obj.objid,
			targetos = disp_obj.osnum	) ; as$status() ;
  if (!(status & msg & 1)) {
	#ifdef DEBUG
	printf("display_for_scaling() : GRgraphics.GRdisplay() failed \n") ;
	#endif
	*sts = ERRO ; goto quit ;
  }

  *sts = SUCC ;
}/* display_for_scaling() */


/*
	------------------------------------------------------------------
 */


action undisplay_for_scaling
/*.action undisplay_for_scaling */
/*
	Description :
		This method un-displays a drawing view or a reference file
		(at this step, the clipping polygon prism is not displayed).
		It should be used just before a re-scaling operation (e.g.
		apply_new_Scale method).
 */
{
enum GRdpmode	mode ;
struct GRid	disp_obj ;
IGRlong		msg  ;

  mode   = GRbeheo ;
  if (me->drawview.objid != NULL_OBJID) {
	disp_obj = me->drawview ;
  }
  else {
	disp_obj = me->reffile ;
  }

  status = om$send(	msg	= message GRgraphics.GRdisplay(&msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&mode,
					&me->ModuleInfo.md_id),
			targetid = disp_obj.objid,
			targetos = disp_obj.osnum	) ; as$status() ;
  if (!(status & msg & 1)) {
	#ifdef DEBUG
	printf("undisplay_for_scaling() : GRgraphics.GRdisplay() failed \n") ;
	#endif
	*sts = ERRO ; goto quit ;
  }

  *sts = SUCC ;
}/* undisplay_for_scaling() */


/*
	------------------------------------------------------------------
 */


action apply_new_Scale
/*.action apply_new_Scale */
/*
	Description :
		Apply new scale for the located object (drawing view, or
		reference file).  This action should be called after the
		display_Scale and get_new_Scale actions which set the
		instance variables old_scale_string and scale_string.
 */

{
struct GRmd_env	ref_env ;
IGRmatrix	old_scale_matrix, scale_matrix, inv_matrix, result_matrix ;
IGRpoint	dummy_point ;
IGRshort	matrix_type,mx_type ;
GRobjid		new_objid   ;
IGRshort	four ;
IGRint		flag ;
IGRlong		msg  ;
struct	GRid	ctxid;
IGRmatrix	matrix;


  if (me->drawview.objid != NULL_OBJID) {

	dummy_point[0] = 0 ; dummy_point[1] = 0 ; dummy_point[2] = 0 ;

	flag = 0 ;	/* if 0, scale about origin */
	status = om$send(msg = message GRdrawview.GRscale_drawing_view(
					&msg,
					&me->dv_mod_info,
					&flag,	
					me->scale_string,
					dummy_point /* better than NULL */
					),
			targetid = me->drawview.objid,
			targetos = me->drawview.osnum) ; as$status() ;
	if (!(status & msg & 1)) {
		#ifdef DEBUG
		printf("GRdrawview.GRscale_drawing_view() failed \n") ;
		#endif
		*sts = ERRO ; goto quit ;
		}
        MAidmx( &msg, matrix );
        mx_type = MAIDMX;
        status = VDgetcontextid ( &msg, &me->reffile, &ctxid );
        VDctx_SetRecomputeDrawingFlag(1);
	status = om$send ( msg = message GRcontext.GRupdatectx( &msg, &mx_type,
							 matrix ),
					targetid = ctxid.objid,
					targetos = ctxid.osnum );
        VDctx_SetRecomputeDrawingFlag(0);


	}
  else {
	/*
		Located object is a reference file
		Note : GRreffile.GRaltscale() scales the reference file
		   attachment, and updates also the associated
		   clipping polygon prism.
	 */

	/* 1) Compute transformation matrix */

	status = om$send(msg = message GRreffile.GRgetenvironment(&msg,
					&me->dv_mod_info,
					&ref_env),
			targetid = me->reffile.objid, 
			targetos = me->reffile.osnum) ; as$status() ;
	if (!(status & msg & 1)) {
		#ifdef DEBUG
		printf("GRreffile.GRgetenvironment() failed \n") ;
		#endif
		*sts = ERRO ; goto quit ;
		}

	status = GRmodel_scale(&msg, &me->dv_mod_info.md_id.osnum, 
			&ref_env.md_id.osnum,
			me->old_scale_string, old_scale_matrix) ;
	if (!(status & msg & 1)) {
		#ifdef DEBUG
		printf("Error in GRmodel_scale() \n") ;
		#endif
		*sts = ERRO ; goto quit ;
		}

	MAinvscmx(&msg, old_scale_matrix, inv_matrix) ; 
					/* inverse old scale matrix */
	if (!(msg & 1)) {
		#ifdef DEBUG
		printf("Error in MAinvscmx() \n") ;
		#endif
		*sts = ERRO ; goto quit ;
	}

	status = GRmodel_scale(&msg, &me->dv_mod_info.md_id.osnum, 
			&ref_env.md_id.osnum,
			me->scale_string, scale_matrix) ;
	if (!(status & msg & 1)) {
		#ifdef DEBUG
		printf("Error GRmodel_scale() \n") ;
		#endif
		*sts = ERRO ; goto quit ;
		}
 
	four = 4 ;
	MAmulmx(&msg, &four, &four, &four, scale_matrix, inv_matrix, result_matrix);
        MAtypemx (&msg, result_matrix, &matrix_type);

	/* 2) Apply transformation matrix, and change scale */

	status = om$send(msg = message GRreffile.GRaltscale (&msg,
                                                &me->dv_mod_info,
                                                &matrix_type,
                                                result_matrix,
                                                &new_objid,
                                                me->scale_string),
			targetid = me->reffile.objid,
			targetos = me->reffile.osnum) ; as$status() ;
	if (!(status & msg & 1)) {
		#ifdef DEBUG
		printf("GRreffile.GRaltscale() failed \n") ;
		#endif
		*sts = ERRO ; goto quit ;
		}
	me->reffile.objid = new_objid ; /* just in case... */
	} /* reffile */

  *sts = SUCC ;
} /* apply_new_Scale() */


/*
	------------------------------------------------------------------
 */


action display_Zdepths
/*.action display_Zdepths */
/*
	Description :
		Display in the status field the current Z depths of the
		clipping polygon (drawing view).
 */
{
   IGRdouble	tmp_z1, tmp_z2 ;
   IGRchar	buffer[200] ;
   IGRchar	units[200];

  status = get_z_depths(&me->clippoly, &me->dv_mod_info, &tmp_z1, &tmp_z2) ;
  if (!(status & 1)) {
	*sts = ERRO ; goto quit ;
  }
  me->z1 = tmp_z1 ;
  me->z2 = tmp_z2 ;

  /* convert the intern values to extern user defined values. */
  status = VDdet_conv_int_ext( tmp_z1, &tmp_z1, me->dv_mod_info.md_id.osnum );
  status = VDdet_conv_int_ext( tmp_z2, &tmp_z2, me->dv_mod_info.md_id.osnum );
  status = VDdet_get_def_units( me->dv_mod_info.md_id.osnum, NULL, units );

#ifdef	DEBUG
  printf("me:z1 and z2 are <%f> and <%f> \n", me->z1, me->z2) ;
  printf("   z1 and z2 are <%f> and <%f> \n", tmp_z1, tmp_z2) ;
#endif

  sprintf(buffer, "Current Z depths are %g, %g %s ", tmp_z1, tmp_z2, units ) ; 
  ex$message(field = 2, in_buff = buffer) ; 

  *sts = SUCC ;
} /* display_Zdepths() */


/* ------------------------------------------------------------------ */

action get_new_Zdepths
/*.action get_new_Zdepths */
/*
	Description :
		Parse the user input string to get new Z depths (state St_Z1).
		The pattern to be search is <z1 separator z2>, where the
		separator is the comma.  If so, me->z1 and me->z2 are set.

		If only one Z depth is given, me->z1 is set and the argument
		*sts is set to RC_NEED_OTHER_Z.
 */
{
char	separator    ;
char	numerics[80] ;			/* checking   */
char	buffer[GR_MAX_CHAR + 1] ; 	/* user input */
IGRdouble	tmp_z1, tmp_z2 ;
int		len ;
char		*aux ;

  status = OM_S_SUCCESS ;

  strcpy(numerics, "0123456789.+- ") ; 
			/* dot, plus, minus and space characters included */
  separator = ',' ; 	/* comma */
  strcpy(buffer, me->event1.event.keyin) ;

  /* Check if the user input is composed of numerics */
  len = strlen(numerics) ;
  numerics[len] = separator ; numerics[len+1] = '\0' ;

  for( aux = &buffer[0]; *aux != '\0'; aux++ ){
	if (strchr(numerics, *aux) == NULL) {
		/* not a numeric character */
		*sts = ERRO ; goto quit ;
	}
  }

  /* Search for pattern <z1 separator z2> */
  aux = (char *)strchr(buffer, separator) ;
  if (aux != NULL) {
	buffer[(int) (aux - &buffer[0])] = '\0' ;
	tmp_z1 = atof(buffer)  ;
	tmp_z2 = atof(aux + 1) ;

	if ((tmp_z1 == 0) && (tmp_z2 == 0)) {
		*sts = ERRO ; goto quit ;
	}

	me->z1 = tmp_z1 ; 
	me->z2 = tmp_z2 ;
	*sts = SUCC ; goto quit ;
  }
  else {
	me->z1 = atof(buffer)    ;
	*sts   = RC_NEED_OTHER_Z ; goto quit ;
  }
} /* get_new_Zdepths() */


/* ------------------------------------------------------------------ */

action get_other_Z
/*.action get_other_Z */
/*
	Description :
		If only one Z depth is given by the user, get the second new
		Z depth (me->z2) for the clipping polygon (state St_Z2).
 */
{
char	buffer[GR_MAX_CHAR + 1] ; 	/* user input */
char	*numerics, *aux ;


  status = OM_S_SUCCESS ;
  numerics = "0123456789.+-" ;	/* dot, plus and minus signs included also */
  strcpy(buffer, me->event1.event.keyin) ;

  /* Check if the user input is composed of numerics */

  for( aux = &buffer[0]; *aux != '\0'; aux++ ){
	if (strchr(numerics, *aux) == NULL) {
		/* not a numeric character */
		*sts = ERRO ; goto quit ;
	}
  }

  me->z2 = atof(buffer) ;
  *sts   = SUCC ;
} /* get_other_Z() */


/* ------------------------------------------------------------------ */

action apply_new_Zdepths
/*.action apply_new_Zdepths */
/*
	Description :
		Modify the new Z depths of the clipping polygon (St_Zdepths).
 */
{
   IGRdouble	tmp_z1, tmp_z2 ;
   IGRmatrix	matrix;
   IGRshort	mx_type;
   struct GRid  ctx_id;
   IGRlong	msg,stat;
 
  tmp_z1 = me->z1 ;
  tmp_z2 = me->z2 ;

  status = VDdet_conv_ext_int( me->z1, &tmp_z1, me->dv_mod_info.md_id.osnum );
  status = VDdet_conv_ext_int( me->z2, &tmp_z2, me->dv_mod_info.md_id.osnum );

#ifdef DEBUG
  printf("   z1 and z2 are <%f> and <%f> \n", me->z1, me->z2) ;
  printf("   z1 and z2 are <%f> and <%f> \n", tmp_z1, tmp_z2) ;
#endif

  status = proc_z_depths(&me->clippoly, &me->dv_mod_info, tmp_z1, tmp_z2) ;
  if (!(status & 1)) {
	*sts = ERRO ; goto quit ;
  }
  MAidmx ( &msg,matrix );
  mx_type = MAIDMX;

  stat = VDgetcontextid ( &msg, &me->reffile, &ctx_id );
  VDctx_SetRecomputeDrawingFlag(1);
  stat = om$send(msg = message GRcontext.GRupdatectx( &msg ,&mx_type,
                                                        matrix ),
                 targetid = ctx_id.objid,
                 targetos = ctx_id.osnum );
  VDctx_SetRecomputeDrawingFlag(0);


  *sts = SUCC ;
} /* apply_new_Zdepths() */


/* ------------------------------------------------------------------ */

action display_clipping_polygon
/*.action display_clipping_polygon */
/*
	Description :
		Make the clipping polygon displayable (GRIS_DISPLAYABLE),
		then display it (GRbd).

	Programmer's digest :
		The sequence to update both the reference file attachment and
		the clipping polygon is the following :
			- do undisplay_cliping_polygon
			- do undisplay_reference_file
			- do display_clipping_polygon 
				(=> it updates both clippoly, and reffile)
 */
{
  status = display_clippoly(&me->clippoly, &me->dv_mod_info, TRUE) ; 
  if (!(status & 1)) {
	*sts = ERRO ; goto quit ;
  }

  *sts = SUCC ;
} /* display_clipping_polygon() */

/* ------------------------------------------------------------------ */

action undisplay_clipping_polygon
/*.action undisplay_clipping_polygon */
/*
	Description :
		First, make the clipping polygon undisplayable, 
		then, un-display it.
 */
{
  status = display_clippoly(&me->clippoly, &me->dv_mod_info, FALSE) ; 
  if(!(status & 1)) {
	*sts = ERRO ; goto quit ;
  }

  *sts = SUCC ;
} /* undisplay_clipping_polygon() */


/* ------------------------------------------------------------------ */

action display_reference_file		/* NOT NEEDED */
/*.action display_reference_file */
/*
	Display reference file (model attachment of drawing view).
	Warning : doesn't take into account clipping polygon volume.
 */
{
enum GRdpmode	mode ;
IGRlong		msg  ;

  if (! me->reffile.objid) {
	*sts = ERRO ; goto quit ;
  }

  mode   = GRbd ;
  status =
  om$send(msg	= message GRgraphics.GRdisplay(&msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&mode,
					&me->ModuleInfo.md_id),
	  targetid = me->reffile.objid,
	  targetos = me->reffile.osnum	);
  if(!(status & msg & 1)) {
	as$status() ;
	#ifdef DEBUG
	  printf("display_reference_file() : GRgraphics.GRdisplay() failed\n");
	#endif
	*sts = ERRO ; goto quit ;
  }

  *sts = SUCC ;
} /* display_reference_file() */


/* ------------------------------------------------------------------ */

action undisplay_reference_file
/*.action undisplay_reference_file */
{
enum GRdpmode	mode ;
IGRlong		msg  ;

  if (! me->reffile.objid) {
	*sts = ERRO ; goto quit ;
  }

  mode   = GRbeheo ;
  status =
  om$send(msg	= message GRgraphics.GRdisplay(&msg,
					&me->ModuleInfo.md_env.matrix_type,
					me->ModuleInfo.md_env.matrix,
					&mode,
					&me->ModuleInfo.md_id),
	targetid = me->reffile.objid,
	targetos = me->reffile.osnum);
  if(!(status & msg & 1)) {
	as$status();
	#ifdef DEBUG
	printf("undisplay_reference_file() : GRgraphics.GRdisplay() failed\n");
	#endif
	*sts = ERRO ; goto quit ;
  }

  *sts = SUCC ;
} /* undisplay_reference_file() */


/* ------------------------------------------------------------------ */

action get_from_Vertex
/*.action get_from_Vertex */
/*
	Description :
		Guess the vertex of the clipping polygon to be modified.  
		The transformation is done in the relative XY directions 
		of the drawing view.
	Note :
		On successful completion, me->from_pt_event, me->from_point
		and me->clip_parms are set.
 */
{
IGRlong		msg ;
IGRpoint 	event_fr_point ; 
		/* data point close to the vertex to be modified */

  event_fr_point[0] = me->event1.event.button.x ;
  event_fr_point[1] = me->event1.event.button.y ;
  event_fr_point[2] = me->event1.event.button.z ;

  me->from_pt_event = me->event1 ; /* used later in dynamics */

  /* Project event_fr_point on prism */
  status =
  om$send(msg	= message GRgraphics.GRptproject(
					&msg,
					&me->dv_mod_info.md_env.matrix_type,
					me->dv_mod_info.md_env.matrix,
					event_fr_point,
					me->from_point,		/* O */
					&me->clip_parms),	/* O */
	targetid = me->clippoly.objid,
	targetos = me->clippoly.osnum);
  if (!(status & msg & 1)) {
	as$status() ;
	*sts = ERRO ; goto quit ;
  }

  #ifdef DEBUG
  printf("action get_from_Vertex() : \n") ;
  printf("event_fr_point is %f / %f / %f \n", 	event_fr_point[0],
						event_fr_point[1],
						event_fr_point[2]) ;
  printf("action get_from_Vertex(), after projection on clippoly : \n") ;
  printf("from_point is %f / %f / %f \n", 	me->from_point[0],
						me->from_point[1],
						me->from_point[2]) ;
  #endif

  *sts = SUCC ;
} /*|end of action get_from_Vertex() */


/* ------------------------------------------------------------------ */

action replace_from_Vertex
/*.action replace_from_Vertex */
/*
	Description :
		Project me->to_point on the clipping polygon to update 
		me->from_point, for the state St_ToVertex.  
 */
{
IGRlong msg ;
/* Project old destination point on prism */
  status =
  om$send(msg	= message GRgraphics.GRptproject(
					&msg,
					&me->dv_mod_info.md_env.matrix_type,
					me->dv_mod_info.md_env.matrix,
					me->to_point,		/* I */
					me->from_point,		/* O */
					&me->clip_parms),	/* O */
	targetid = me->clippoly.objid,
	targetos = me->clippoly.osnum);
  if (!(status & msg & 1)) {
	as$status() ;
	*sts = ERRO ; goto quit ;
  }
  *sts = SUCC ;
} /* replace_from_Vertex() */


/* ------------------------------------------------------------------ */

action get_new_Vertex
/*.action get_new_Vertex */
/*
	Description :
		Get destination point for new position of vertex.
		This action is triggered when the user enters a data point
		in the state St_ToVertex.
 */
{

  status = OM_S_SUCCESS ;
  me->to_point[0] = me->event1.event.button.x ;
  me->to_point[1] = me->event1.event.button.y ;
  me->to_point[2] = me->event1.event.button.z ;

  #ifdef DEBUG
  printf("action get_new_Vertex() \n") ;
  printf("me->to_point is %f / %f / %f \n", 	me->to_point[0],
						me->to_point[1],
						me->to_point[2]) ;
  #endif

  me->from_pt_event = me->event1 ; /* update from vertex for dynamics() */
  *sts = SUCC ;
} /*|end of action get_new_Vertex() */


/* ------------------------------------------------------------------ */

action apply_new_Vertex
/*.action apply_new_Vertex */
/*
	Description :
		Modify the XY face of the clipping polygon of the drawing
		view attachment.
 */

{

 IGRmatrix	matrix;
 IGRshort	mx_type;
 IGRlong	stat,msg;
 struct GRid	ctx_id;

/* Modify the clipping polygon face */
  status = proc_xy_vertex(&me->clippoly, &me->dv_mod_info, 
			  &me->clip_parms, me->from_point, me->to_point) ;
  if (!(status & 1)) {
	*sts = ERRO ; goto quit ;
  }

  #ifdef DEBUG
  printf("action apply_new_Vertex() successful\n") ;
  #endif

  MAidmx ( &msg,matrix );
  mx_type = MAIDMX;

  stat = VDgetcontextid ( &msg, &me->reffile, &ctx_id );
  VDctx_SetRecomputeDrawingFlag(1);
  stat = om$send(msg = message GRcontext.GRupdatectx( &msg ,&mx_type,
							matrix ),
		targetid = ctx_id.objid,
 		targetos = ctx_id.osnum );
  VDctx_SetRecomputeDrawingFlag(0);

  *sts = SUCC ;

} /*|end of action apply_new_Vertex() */




/*---------------------------------------------------------------------------*/

action dynamics
/*
	method dynamics ( int dynamics ; int * sts )
	Description :
		If the dynamics argument is equal to 2 (state St_ToVertex),
		this method displays dynamically the modifications of the 
		relative bottom or top face of the clipping polygon
		of a drawing view given the vertex to be modified
		in the relative xy directions.
 */
{
struct dyn_args	data ;
IGRboolean	inquire, dyn_on ;
IGRlong		msg ;

  #ifdef DEBUG
	printf("   ---> dynamics() triggered \n") ;
  #endif

  /* If dynamics are off then exit */

  inquire = 1 ;
  DPdynflags(&msg, &inquire, &dyn_on, NULL) ;
  if (!dyn_on) {
	#ifdef DEBUG
	printf("Dynamics are off \n") ;
	#endif
	*sts = SUCC ; goto quit ;
  }

  /* Depending on the value of dynamics argument */

  if (! dynamics) { *sts = SUCC ; goto quit ; }

  /* Initialize data structure for dynamics */

  data.clippoly         = me->clippoly    ;
  data.clone_clip.objid = NULL_OBJID      ;
  data.clone_clip.osnum = me->ModuleInfo.md_id.osnum ;
  data.clone_exists     = FALSE ;

  data.LocateContext    = me->dv_mod_info  ;
  data.NewContext       = me->ModuleInfo   ;
  data.NewContext.md_id.objid = NULL_OBJID ;

  data.from_pt_event = me->from_pt_event ; /* Vertex to be modified */
  data.cob_objid	      = my_id ;

  dp$dynamics(dyn_fun = DYclipxymod, information = &data) ;

  /* If needed, remove the clone of the clipping polygon */

  if (data.clone_exists) {
	status = om$send(	msg = message GRgraphics.GRdelete
						(&msg, &data.NewContext),
		senderid = my_id,
		targetid = data.clone_clip.objid,
		targetos = data.clone_clip.osnum	) ; as$status() ;
	if (!(status & msg & 1)) {
		#ifdef DEBUG
		printf("warning in dynamics() method : clone of clippoly not deleted \n") ;
		#endif
		; /* nop */
	}
	else data.clone_exists     = FALSE ;
  }

  *sts = SUCC ;
} /*|end of action dynamics */


/* ------------------------------------------------------------------ */

