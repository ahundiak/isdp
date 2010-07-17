/* $Id: VSint.I,v 1.6 2001/10/24 14:57:08 jayadev Exp $  */

/*************************************************************************
 * I/STRUCT
 *
 * File:	vscoord/VSint.I
 *
 * Description:
 *	The bscv_sf_int routine fails on elements very close to
 *	tolerance distances.  These routines correct this by
 *	first trying the intersection routine and then determining
 *	actual min distance.
 *
 *	Also remove some of the allocating/deallocating stuff required
 *	by calling routine.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSint.I,v $
 *	Revision 1.6  2001/10/24 14:57:08  jayadev
 *	fix for TR# 5262
 *	
 *	Revision 1.5  2001/05/25 17:27:22  ramarao
 *	Fixed TR# 5242.
 *	
 *	Revision 1.4  2001/04/02 22:25:59  ramarao
 *	Fixed TR# 4999
 *	
 *	Revision 1.3  2001/03/18 19:09:24  ad
 *	Fix for MP4855
 *	
 *	Revision 1.2  2001/01/17 00:09:18  ramarao
 *	*** empty log message ***
 *	
# Revision 1.1  2000/11/15  16:49:04  pinnacle
# Created: struct/vscoord/VSint.I by jpulapar for Service Pack
#
# Revision 1.7  2000/03/24  20:10:20  pinnacle
# Replaced: vscoord/VSint.I for:  by impd252 for struct
#
# Revision 1.6  2000/03/03  21:09:04  pinnacle
# Replaced: vscoord/VSint.I for:  by impd252 for struct
#
# Revision 1.5  2000/02/23  22:22:04  pinnacle
# tr179901005
#
# Revision 1.3  1999/10/13  13:56:04  pinnacle
# tr179900763
#
# Revision 1.2  1998/09/27  14:03:24  pinnacle
# TR179801601
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1997/11/19  16:39:02  pinnacle
# TR179702163
#
# Revision 1.4  1997/10/31  15:32:10  pinnacle
# Remove Spec File
#
# Revision 1.3  1997/09/26  17:58:44  pinnacle
# TR179701071
#
# Revision 1.3  1997/05/28  12:29:42  pinnacle
# Replaced: vscoord/VSint.I for:  by mfournie for struct
#
# Revision 1.2  1997/05/22  17:02:56  pinnacle
# Replaced: vscoord/VSint.I for: use <int_2_elem> CImacro. by mfournie for struct
#
 # Revision 1.1  1997/05/20  16:32:08  pinnacle
 # Created: vscoord/VSint.I by mfournie for struct
 #
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	05/19/97   ah		creation.
 *	05/22/97   mf		use <int_2_elem> CImacro.
 *	05/28/97   mf		use <srf_ext> CImacro.
 *      06/16/97   ah           TR179701071 Checkin
 *      08/01/97   ah           Problem with extend surface
 *                              Deleted some unused routines
 *      09/26/97   ah           2.5 Build Checkin
 *	10/31/97   ah		Added VDmaster.h
 *      11/19/97   ah           TR179702163
 *				Failing on twisted beams which use EMSgenbs
 *                              Surfaces, changed extend surface to use
 *                              SMextentObjSrfRg function
 *				Also got rid of unused functions
 *      09/27/98   ah           TR179801601 If extend command used for 2163 fails
 *                              (sometimes it does not extend in all directions)
 *                              then revert to original pla_ext
 *      08/11/99   ah           TR179900763 Need to delete parent expressions when
 *                              placing intermediate ci macros
 *      02/23/00   ah           TR179901005 Failing on some web intersections,
 *                              increase the surface extension when this happens
 *                              Also corrected a problem with a tempID out of bounds
 *      03/24/00   HF           TR179901244 Failing on some web intersections.
 *                              Extend both surfaces, not only Srf1.
 *      11/15/00   Jayadev      etl#4002 - VScsIntSrfSrf - first intersect with
 *				first surface extended; if this fails, then go
 *				for second surface extension and intersection
 *	03/18/01   Adz		Perform intersection with natural boundaries.
 *      10/23/01   Jayadev      TR# MP5262 EMSgenbs surfaces not being deleted
 *                              by their GRdelete implementation; Forcing a 
 *                              Root.delete when GRdelete fails
 *************************************************************************/

class implementation ACncpx;

#include	"VDmaster.h"
#include        "VDobj.h"

#include        "gotextdef.h"
#include        "cotxmacros.h"

#include        "ACdyn_col.h"
#include        "bsparameters.h"
#include        "EMSssprops.h"
#include 	"grcoordsys.h"

#include 	"vspart.h"
#include 	"vsdpb.h"

#include 	"vscsby2el.h"

#include 	"vsbeamdef.h"
#include 	"vsbeam.h"
#include 	"vssectiondef.h"
#include 	"vsbeam.h"
#include 	"vsbeammacros.h"
#include 	"vsplatedef.h"

#include 	"vsstfnrdef.h"

#include 	"vsmiscmacros.h"
#include 	"vsgeommacros.h"

#include 	"vdAPImacros.h"
#include 	"vdmeamacros.h"

/* Include of prototypes */
#include        "bsmdistptsf.h"
#include        "bscv_sf_int.h"

#include        "vscoordproto.h"

extern	GRclassid	OPP_GR3dpoint_class_id, OPP_GRcurve_class_id,
			OPP_nci_macro_class_id;

from	ci_macro	import	init;

/*
#define TRACE
#define	vsDEBUG
*/

#include        "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*-----------------------------------------------
 * Function to do a Root.delete for TR# MP5262
 *-----------------------------------------------
 */
void VSdelete_leftOver( struct GRid *leftOver)
{
  __DBGpr_obj("Doing a Root.delete for object ", *leftOver);
  
  om$send( msg    = message Root.delete(1),
	   mode   = OM_e_wrt_object,
	   senderid = NULL_OBJID,
	   targetid = leftOver->objid,
	   targetos = leftOver->osnum ) ;
}
/* -----------------------------------------------------------------
 * Utility routine for getting rid of sources no longer required
 */

/* -----------------------------------------------------------------
 * ah I did a little bit of testing using the api for int 2 elements
 * but decided to leave this code alone for now.
 */
IGRlong	VScsInt2Elements
(
IGRlong		        *msg,		/*O	Completion code		*/
struct	GRobj_env	*Obj1,		/*I	First object		*/
struct	GRobj_env	*Obj2,		/*I	Second object		*/
struct	GRmd_env	*Env,		/*I	Current environment	*/
struct	GRid		*Inter		/*O	Resulting object	*/
)
{
  IGRlong		sts=OM_S_SUCCESS;
  IGRlong               ret;
  
  struct  GRid		template[5], OccId;
  IGRint		i, suc=0;
  struct  GRobj_env	Foot;
  
  IGRint                trim1;
  IGRint                trim2;
  IGRint                approx = 0;
  
  /* Initialize */
  OccId.objid = Inter->objid = NULL_OBJID;
  OccId.osnum = Inter->osnum = Env->md_id.osnum;
  for ( i=0; i<5; i++ )
  {
    template[i].objid = NULL_OBJID;
    template[i].osnum = Env->md_id.osnum;
  }
  *msg = MSSUCC;
  
  /* 
   * If the input object is curve, set the trim option to 0 and
   * if it is a surface set it to 2.
   */
  if( vd_$is_ancestry_valid( object  = &Obj1->obj_id,
			     classid = OPP_GRcurve_class_id ) )
  {
    trim1  = 0;
  }
  else trim1  = 2;
  
  if( vd_$is_ancestry_valid( object  = &Obj2->obj_id,
                             classid = OPP_GRcurve_class_id ) )
  {     
    trim2  = 0;
  }
  else trim2  = 2;
  
  /* Make source on 1st object */
  sts = as$make_source ( go_grid	= Obj1->obj_id,
                         mod_env	= &Obj1->mod_env,
                         as_grid	= &template[0] );
  __CheckRC ( sts, *msg, "as$make_source()", wrapup ) ;
  
  /* Make source on 2nd object */
  sts = as$make_source ( go_grid	= Obj2->obj_id,
                         mod_env	= &Obj2->mod_env,
                         as_grid	= &template[1] );
  __CheckRC ( sts, *msg, "as$make_source()", wrapup ) ;
  
  /* Create expression for trimming 1st object */
  sts = exp$create ( exp_name  = NULL,
                     exp_value = (IGRdouble) trim1,
                     osnum     = Env->md_id.osnum,
                     p_exp_id  = &template[2].objid,
                     p_osnum   = &template[2].osnum );
  __CheckRC ( sts, *msg, "exp$create()", wrapup ) ;
  
  /* Create expression for trimming 2nd object */
  sts = exp$create ( exp_name  = NULL,
                     exp_value = (IGRdouble) trim2,
                     osnum     = Env->md_id.osnum,
                     p_exp_id  = &template[3].objid,
                     p_osnum   = &template[3].osnum );
  __CheckRC ( sts, *msg, "exp$create()", wrapup ) ;
  
  /* Create expression for approximation */
  sts = exp$create ( exp_name  = NULL,
                     exp_value = (IGRdouble) approx,
                     osnum     = Env->md_id.osnum,
                     p_exp_id  = &template[4].objid,
                     p_osnum   = &template[4].osnum );
  __CheckRC ( sts, *msg, "exp$create()", wrapup ) ;
  
  /* Force them to delete themselves */
  for(i = 0; i < 5; i++)
  {
    om$send(msg = message NDnode.
            NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
            senderid = NULL_OBJID,
            targetid = template[i].objid,
            targetos = template[i].osnum);
  }
  
  /* Construct nci_macro */
  sts = om$construct ( classid = OPP_nci_macro_class_id,
                       osnum   = OccId.osnum,
                       p_objid = &OccId.objid );
  __CheckRC ( sts, *msg, "om$construct()", wrapup ) ;
  
  /* Create macro occurence */
  sts = om$send ( msg = message ci_macro.init ( &suc,
                                                AChdr_nodisplay | AChdr_norange,
                                                "int_2_elem",
                                                5,
                                                template,
                                                NULL,
                                                Env ),
                  senderid = NULL_OBJID,
                  mode     = OM_e_wrt_message,
                  targetid = OccId.objid,
                  targetos = OccId.osnum );
  *msg = (IGRlong) suc;
  __CheckRC ( sts, *msg, "ci_macro.init <int_2_elem>", wrapup ) ;
  
  /* Get resulting foot */
  sts = vd_$return_foot ( msg     = msg,
                          name    = "resi0",
                          objId   = &OccId,
                          objEnv  = Env,
                          footId  = &Foot.obj_id,
                          footEnv = &Foot.mod_env );
  __CheckRC ( sts, *msg, "vd_$return_foot()", wrapup ) ;
  
  /* Copy in output object */
  sts = gr$copy_object ( msg          = msg,
                         object_id    = &Foot.obj_id,
                         md_env       = &Foot.mod_env,
                         new_env      = Env,
                         new_id       = Inter,
                         display_flag = 0 );
  __CheckRC ( sts, *msg, "gr$copy_object()", wrapup ) ;

 wrapup:
  if (OccId.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &ret,
                       object_id    = &OccId,
                       md_env       = Env,
                       display_flag = 0 );
  }
  
  // TR179900763 need to delete the 3 parent expressions as well
#if 1
  for(i = 2; i < 5; i++)
  {
    if (template[i].objid != NULL_OBJID)
    {
      gr$delete_object ( msg          = &ret,
                         object_id    = &template[i],
                         md_env       = Env,
                         display_flag = 0 );
    }
  }
#endif
  return (sts);
  
}

/* ---------------------------------------------------------------
 * TR179702163 12 Nov 97 Art Hundiak
 *
 * twisted beams were failing, problem was with extending EMSgenbs
 * pla_offext did not work
 * tried srf_offext and it worked sometime on clix but core dumped on
 * Solaris
 *
 * Found a sm function which extends surface to a range
 * This seemd to work ok so use it
 *
 * This function doubles the range of the web surface.
 * A general surface could end up doubling back on itself causing
 * down stream problems.  It is hoped that even twisted beams running
 * along shells will behave themselves.
 *
 * 01 Aug 1997, Art Hundiak
 * For some non-planar beams, int2elem fails to intersect the web and
 * top/bottom surface even when trim is set.
 * Still not sure why but it fails.
 *
 * Marc originally worked around this by extending the web using the
 * srf_ext macro.  However, I found that this failed for non-planar
 * Beams.
 *
 * I rewrote the function using the pla_offext macro.  This macro extends
 * the surface in all directions eliminating the need to find points
 * required by srf_ext.
 *
 * It seems to work ok.
 *
 */

IGRlong	VSextendOffsetSurface(
  TGRobj_env *srf,
  IGRdouble   extend,
  IGRdouble   offset,
  TGRmd_env  *env,
  TGRid      *resultId
)
{
  IGRstat l_ret = 0;
  IGRstat sts,msg;
  IGRint  suc;
  IGRint  i;
  
  TGRid      occId;
  TGRid      tempId[3];
  TGRobj_env foot;
  
  /* Initialize */
  occId.objid = resultId->objid = NULL_OBJID;
  occId.osnum = resultId->osnum = env->md_id.osnum;
  
  for ( i=0; i < 3; i++ )
  {
    tempId[i].objid = NULL_OBJID;
    tempId[i].osnum = env->md_id.osnum;
  }
  
  /* Make source on Surface */
  sts = as$make_source ( go_grid =  srf->obj_id,
                         mod_env = &srf->mod_env,
                         as_grid = &tempId[2] );
  __CheckRC ( sts, 1, "as$make_source()", wrapup );
  
  /* Create expression for extension */
  sts = exp$create ( exp_name  = NULL,
                     exp_value = extend,
                     osnum     = env->md_id.osnum,
                     p_exp_id  = &tempId[0].objid,
                     p_osnum   = &tempId[0].osnum );
  __CheckRC ( sts, 1, "exp$create()", wrapup ) ;

  /* Create expression for offset */
  sts = exp$create ( exp_name  = NULL,
                     exp_value = offset,
                     osnum     = env->md_id.osnum,
                     p_exp_id  = &tempId[1].objid,
                     p_osnum   = &tempId[1].osnum );
  __CheckRC ( sts, 1, "exp$create()", wrapup ) ;
  
  /* Force them to delete themselves */
  /* TR179901005, this was counting to 5 */
  for(i = 0; i < 3; i++)
  {
    om$send(msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
	    senderid = NULL_OBJID,
	    targetid = tempId[i].objid,
	    targetos = tempId[i].osnum);
  }
  
  /* Construct nci_macro */
  sts = om$construct ( classid = OPP_nci_macro_class_id,
                       osnum   =  occId.osnum,
                       p_objid = &occId.objid );
  __CheckRC ( sts, 1, "om$construct()", wrapup ) ;
  
  /* Create macro occurence */
  sts = om$send ( msg = message ci_macro.init ( &suc,
                                                AChdr_nodisplay | AChdr_norange,
                                                "pla_offext",
                                                3,tempId,
                                                NULL,
                                                env ),
                  senderid  = NULL_OBJID,
                  mode      = OM_e_wrt_message,
                  targetid  = occId.objid,
                  targetos  = occId.osnum
  );
  __CheckRC ( sts, suc, "ci_macro.init <pla_offext>", wrapup ) ;
  
  /* Get resulting foot */
  sts = vd_$return_foot ( msg     = &msg,
                          name    = "ressur",
                          objId   = &occId,
                          objEnv  = env,
                          footId  = &foot.obj_id,
                          footEnv = &foot.mod_env );
  __CheckRC ( sts, msg, "vd_$return_foot()", wrapup ) ;
  
  /* Copy in output object */
  sts = gr$copy_object ( msg       = &msg,
                         object_id = &foot.obj_id,
                         md_env    = &foot.mod_env,
                         new_env   = env,
                         new_id    = resultId,
                         display_flag = 0 );
  __CheckRC ( sts, msg, "gr$copy_object()", wrapup ) ;
  
  l_ret = 1;
  
wrapup:
  
  if (occId.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &msg,
                       object_id    = &occId,
                       md_env       =  env,
                       display_flag = 0 );
  }
#if 1
  // TR179900763 Delete expressions as well
  for(i = 0; i < 2; i++)
  {
    if (tempId[i].objid != NULL_OBJID)
    {
      gr$delete_object ( msg          = &msg,
                         object_id    = &tempId[i],
                         md_env       =  env,
                         display_flag = 0 );
    }
  }
#endif
  return l_ret;
  
}

IGRlong SMextentObjSrfRg(
  IGRlong         *msg,         /* O */
  TGRobj_env      *surfOE,      /* I Surface to extend */
  GRrange          ext_range,   /* I Range to extend it */
  TGRvg_construct *cst,         /* I */
  IGRboolean       reduce_data, /* I TRUE Not Implemented */
  TGRid           *extSurfID    /* O Resulting Object */
);

/* -----------------------------------------------
 * Add a range factor to allow controlling the
 * amount of extension
 */
IGRlong	VScsExtendSurface(
  TGRobj_env      *srfOE,
  IGRdouble        ER,
  TGRid           *resultID
)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;

  GRrange    ext_range;
  IGRdouble  delta;
  
  IGRboolean world  = TRUE;
  IGRboolean reduce = TRUE;

  TGRvg_construct cst;

  /* Init */
  resultID->objid = NULL_OBJID;
  VDsupInitCnst(&cst);

  /* Get current range */
  sts = om$send( msg = message GRgraphics.GRgetrang( &msg,
                                                     &srfOE->mod_env.md_env.matrix_type,
                                                      srfOE->mod_env.md_env.matrix,
                                                     &world,
                                                      ext_range ),
                 senderid = NULL_OBJID,
                 targetid = srfOE->obj_id.objid,
                 targetos = srfOE->obj_id.osnum );
  if (!(sts & msg & 1))
  {
    printf("Could not get range of surface to extend\n");
    goto wrapup;
  }
  //printf("Range b1 %8.2f,%8.2f,%8.2f\n",ext_range[0],ext_range[1],ext_range[2]);
  //printf("Range b2 %8.2f,%8.2f,%8.2f\n",ext_range[3],ext_range[4],ext_range[5]);

  /* Basically want to double the range */
  if (ext_range[0] < ext_range[3])
  {
    delta = (ext_range[3] - ext_range[0]) * ER;
//  if (delta < 1.0) delta = 1.0;
    ext_range[0] -= delta;
    ext_range[3] += delta;
  }
  else
  {
    delta = (ext_range[0] - ext_range[3]) * ER;
    ext_range[0] += delta;
    ext_range[3] -= delta;

  }
  if (ext_range[1] < ext_range[4])
  {
    delta = (ext_range[4] - ext_range[1]) * ER;
    ext_range[1] -= delta;
    ext_range[4] += delta;
  }
  else
  {
    delta = (ext_range[1] - ext_range[4]) * ER;
    ext_range[1] += delta;
    ext_range[4] -= delta;

  }
  if (ext_range[2] < ext_range[5])
  {
    delta = (ext_range[5] - ext_range[2]) * ER;
    ext_range[2] -= delta;
    ext_range[5] += delta;
  }
  else
  {
    delta = (ext_range[2] - ext_range[5]) * ER;
    ext_range[2] += delta;
    ext_range[5] -= delta;
  }
  //printf("Range e1 %8.2f,%8.2f,%8.2f\n",ext_range[0],ext_range[1],ext_range[2]);
  //printf("Range e2 %8.2f,%8.2f,%8.2f\n",ext_range[3],ext_range[4],ext_range[5]);
  //printf("\n");

  /* Do It */
  sts = SMextentObjSrfRg(&msg,srfOE,ext_range,&cst,reduce,resultID);

  if (!(sts & msg & 1))
  {
    printf("SMextentObjSrfRg failed\n");
    goto wrapup;
  }

  //gr$display_object(object_id = resultID, mode = GRbd);

  retFlag = 1;

wrapup:

  return retFlag;

}

/* ------------------------------------------
 * TR179702163 Use new extend surface function
 * TR179801601 Use the old extend/offset surface if that fails
 */
IGRlong	VScsIntCrvSrf
(
	IGRlong		*msg,		/*O	Completion code		*/
struct	GRobj_env	*Curv,		/*I	Curve object		*/
struct	GRobj_env	*Surf,		/*I	Surface object		*/
struct	GRmd_env	*Env,		/*I	Current environment	*/
	IGRpoint	 Pnt,		/*O	Intersection point	*/
	IGRdouble	*parT,		/*O	Curve U parameter	*/
	IGRdouble	*parU,		/*O	Surface U parameter	*/
	IGRdouble	*parV		/*O	Surface V parameter	*/
)
{
  IGRlong sts=OM_S_SUCCESS;
  IGRstat l_msg;

  TGRobj_env	pointOE;
  Tret_struct	str;
  IGRpoint	prj;
  TGRparms	par;
  TGRmd_env	md_env;

  TGRobj_env  extSurfOE;

  /* Initialize */
  if (Env)  md_env = *Env;
  else      gr$get_module_env (buffer = &md_env);

  extSurfOE.obj_id.objid = NULL_OBJID;
  extSurfOE.mod_env      = md_env;
  pointOE.obj_id.objid   = NULL_OBJID;

  /* Intersect curve with surface */
  pointOE.mod_env = md_env;
  sts = VScsInt2Elements( msg, Curv, Surf, &md_env, &pointOE.obj_id );
  if (sts & *msg & 1) goto have_point;
  
  /* Extend and try again */
  sts = VScsExtendSurface(Surf, 0.5, &extSurfOE.obj_id);
  if (!(sts & 1))
  {
    printf("Problem Extending Second Object's Surface\n");
    goto wrapup;
  }
  sts = VScsInt2Elements( msg, Curv, &extSurfOE, &md_env, &pointOE.obj_id );
  if (sts & *msg & 1) goto have_point;
  
  /* Extend using a different method */
  if (extSurfOE.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &extSurfOE.obj_id,
                       md_env       = &extSurfOE.mod_env,
                       display_flag = 0 );
    if(!(l_msg&1))
    {
      __DBGpr_obj(" Failed to deleted Surface** ",extSurfOE.obj_id);
      VSdelete_leftOver(&extSurfOE.obj_id);
    }
  }
  extSurfOE.obj_id.objid = NULL_OBJID;
  
  /* Extend and try again */
  sts = VScsExtendSurface(Surf, 1.0, &extSurfOE.obj_id);
  if (!(sts & 1))
  {
    printf("Problem Extending Second Object's Surface\n");
    goto wrapup;
  }
  sts = VScsInt2Elements( msg, Curv, &extSurfOE, &md_env, &pointOE.obj_id );
  if (sts & *msg & 1) goto have_point;
  
  /* Extend using a different method */
  if (extSurfOE.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &extSurfOE.obj_id,
                       md_env       = &extSurfOE.mod_env,
                       display_flag = 0 );
    if(!(l_msg&1))
    {
      __DBGpr_obj(" Failed to deleted Surface** ",extSurfOE.obj_id);
      VSdelete_leftOver(&extSurfOE.obj_id);
    }
  }
  extSurfOE.obj_id.objid = NULL_OBJID;
  
  sts = VSextendOffsetSurface( Surf, 200.0, 0.0, &md_env, &extSurfOE.obj_id);
  if (!(sts & 1))
  {
    printf("Problem Extending Web Surface\n");
    goto wrapup;
  }
  
  sts = VScsInt2Elements ( msg, Curv, &extSurfOE, &md_env, &pointOE.obj_id );
  
  if (sts & *msg & 1) goto have_point;
  
  // printf("Problem intersecting with second object's surface\n");
  goto wrapup;
  
 have_point:
  __CheckRC ( sts, *msg, "VSint_2_elements()", wrapup ) ;

  /* Get structure */
  sts = as$make_source ( go_grid =  pointOE.obj_id,
                         mod_env = &pointOE.mod_env,
                         as_grid = &pointOE.obj_id );
  __CheckRC ( sts, *msg, "as$make_source()", wrapup ) ;
  sts = om$send ( msg = message NDnode.NDgive_structure( msg, &str, &pointOE.mod_env ),
                  senderid = NULL_OBJID,
                  targetid = pointOE.obj_id.objid,
                  targetos = pointOE.obj_id.osnum
  );
  __CheckRC ( sts, *msg, "NDnode.NDgive_structure", wrapup ) ;
  
  Pnt[0] = str.var.point_st.pt[0];
  Pnt[1] = str.var.point_st.pt[1];
  Pnt[2] = str.var.point_st.pt[2];

  /* Get T parameter */
  sts = om$send ( msg = message GRgraphics.GRptproject(  msg,
							 &Curv->mod_env.md_env.matrix_type,
                                                         Curv->mod_env.md_env.matrix,
                                                         str.var.point_st.pt,
                                                         prj,
							 &par ),
                  senderid = NULL_OBJID,
                  targetid = Curv->obj_id.objid,
                  targetos = Curv->obj_id.osnum );
  if (sts & 1 & *msg)
  {
    *parT = par.u;
  }
  
  /* Get U & V parameters */
  sts = om$send ( msg = message GRgraphics.GRptproject (  msg,
							  &Surf->mod_env.md_env.matrix_type,
                                                          Surf->mod_env.md_env.matrix,
                                                          str.var.point_st.pt,
                                                          prj,
							  &par ),
                  senderid = NULL_OBJID,
                  targetid = Surf->obj_id.objid,
                  targetos = Surf->obj_id.osnum );
  if (sts & 1 & *msg)
  {
    *parU = par.u;
    *parV = par.v;
    
  }
  
wrapup:
  
  if (pointOE.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &pointOE.obj_id,
                       md_env       = &pointOE.mod_env,
                       display_flag = 0 );
  }
  
  if (extSurfOE.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &extSurfOE.obj_id,
                       md_env       = &extSurfOE.mod_env,
                       display_flag = 0 );
    if(!(l_msg&1))
    {
      __DBGpr_obj(" Failed to deleted Surface** ",extSurfOE.obj_id);
      VSdelete_leftOver(&extSurfOE.obj_id);
    }
  }
  
  return (sts);
}

/* ------------------------------------------
 * TR179702163 Use new extend surface function
 * TR179801601 Use the old extend/offset surface if that fails
 */
IGRlong	VScsIntSrfSrf
(
IGRlong		        *a_msg,		/*O	Completion code		*/
struct	GRobj_env	*Srf1,		/*I	1st surface object	*/
struct	GRobj_env	*Srf2,		/*I	2nd surface object	*/
struct	GRmd_env	*Env,		/*I	Current environment	*/
struct	GRid		*Crv		/*O	Intersection curve	*/
)
{
  IGRstat l_ret = 0;
  IGRstat l_msg = 0;
  
  IGRstat sts;
  
  TGRobj_env extendedSrf1, extendedSrf2;
  
  __enterFunction ( name = "VScsIntSrfSrf", argfmt = "Srf1 = [%d,%d], Srf2 = [%d,%d]",
                    args = `Srf1->obj_id.osnum,Srf1->obj_id.objid, Srf2->obj_id.osnum,Srf2->obj_id.objid` );
  
  extendedSrf1.obj_id.objid = NULL_OBJID;
  extendedSrf1.mod_env      = *Env;
  extendedSrf2.obj_id.objid = NULL_OBJID;
  extendedSrf2.mod_env      = *Env;
  
#ifdef TRACE
  printf("Intersect Surf 1 %d,%d %d\n",Srf1->obj_id.osnum,Srf1->obj_id.objid);
  printf("          Surf 2 %d,%d %d\n",Srf2->obj_id.osnum,Srf2->obj_id.objid);
#endif
  
  /* Try to intersect two surfaces */
  sts = VScsInt2Elements( &l_msg, Srf1, Srf2, Env, Crv );

  __printf ("VScsInt2Elements(Srf1, Srf2) sts = %d, l_msg = %d",`sts, l_msg`);
  
  /* Successful intersection */
  if (sts & l_msg & 1)
  {
    l_ret = 1;
    goto wrapup;
  }
  
  /* Extend web in all directions */
  sts = VScsExtendSurface(Srf1, 0.5, &extendedSrf1.obj_id);
  if (!(sts & 1))
  {
    printf("Problem Extending Web Surface 1\n");
    goto wrapup;
  }
  /* Try to intersect with the first surface extended */
  sts = VScsInt2Elements( &l_msg, &extendedSrf1, Srf2, Env, Crv );
  
  /* Successful intersection */
  if (sts & l_msg & 1)
  {
    l_ret = 1;
    goto wrapup;
  }
  
  //HF: 03/24/00 TR 179901244
  /* Extend Srf2 in all directions */
  sts = VScsExtendSurface(Srf2, 0.5, &extendedSrf2.obj_id);
  if (!(sts & 1))
  {
    printf("Problem Extending Web Surface 2\n");
    goto wrapup;
  }
  
  sts = VScsInt2Elements ( &l_msg, &extendedSrf1, &extendedSrf2, Env, Crv );

  __printf ("VScsInt2Elements(extendedSrf1, extendedSrf2) sts = %d, l_msg = %d",`sts, l_msg`);
  
  if (sts & l_msg & 1)
  {
    l_ret = 1;
    goto wrapup;
  }
  
  if (extendedSrf1.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &extendedSrf1.obj_id,
                       md_env       = &extendedSrf1.mod_env,
                       display_flag = 0 );
    if(!(l_msg&1))
    {
      __DBGpr_obj(" Failed to deleted Surface** ",extendedSrf1.obj_id);
      VSdelete_leftOver(&extendedSrf1.obj_id);
    }
  }
  extendedSrf1.obj_id.objid = NULL_OBJID;
  
  if (extendedSrf2.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &extendedSrf2.obj_id,
                       md_env       = &extendedSrf2.mod_env,
                       display_flag = 0 );
    if(!(l_msg&1))
    {
      __DBGpr_obj(" Failed to deleted Surface** ",extendedSrf2.obj_id);
      VSdelete_leftOver(&extendedSrf2.obj_id);
    }
  }
  extendedSrf2.obj_id.objid = NULL_OBJID;
  
  /* try using pla_off to extend surface */
  sts = VSextendOffsetSurface( Srf1, 200.0, 0.0, Env, &extendedSrf1.obj_id);
  if (!(sts & 1))
  {
    printf("Problem Extending Web Surface\n");
    goto wrapup;
  }
  
  sts = VScsInt2Elements ( &l_msg, &extendedSrf1, Srf2, Env, Crv );
  
  if (sts & l_msg & 1)
  {
    l_ret = 1;
    goto wrapup;
  }
  
  if (extendedSrf1.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &extendedSrf1.obj_id,
                       md_env       = &extendedSrf1.mod_env,
                       display_flag = 0 );
    if(!(l_msg&1))
    {
      __DBGpr_obj(" Failed to deleted Surface** ",extendedSrf1.obj_id);
      VSdelete_leftOver(&extendedSrf1.obj_id);
    }
  }
  extendedSrf1.obj_id.objid = NULL_OBJID;
  
  // TR179901005 Try first extend again with a bigger range
  sts = VScsExtendSurface(Srf1, 1.0, &extendedSrf1.obj_id);
  if (!(sts & 1))
  {
    printf("Problem Extending Web Surface\n");
    goto wrapup;
  }
  
  sts = VScsInt2Elements ( &l_msg, &extendedSrf1, Srf2, Env, Crv );
  
  if (sts & l_msg & 1)
  {
    l_ret = 1;
    goto wrapup;
  }
  
  // Give Up
  printf("Intersection of web with top/bottom surface failed\n");
  
 wrapup:

  if (extendedSrf1.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &extendedSrf1.obj_id,
                       md_env       = &extendedSrf1.mod_env,
                       display_flag = 0 );
    if(!(l_msg&1))
    {
      __DBGpr_obj(" Failed to deleted Surface** ",extendedSrf1.obj_id);
      VSdelete_leftOver(&extendedSrf1.obj_id);
    }
  }
  if (extendedSrf2.obj_id.objid != NULL_OBJID)
  {
    gr$delete_object ( msg          = &l_msg,
                       object_id    = &extendedSrf2.obj_id,
                       md_env       = &extendedSrf2.mod_env,
                       display_flag = 0 );
    if(!(l_msg&1))
    {
      __DBGpr_obj(" Failed to deleted Surface** ",extendedSrf2.obj_id);
      VSdelete_leftOver(&extendedSrf2.obj_id);
    }
  }
  
  __exitFunction ( name = "VScsIntSrfSrf", argfmt = "Crv = [%d,%d]", args = `Crv->osnum, Crv->objid` );

  *a_msg = 1;
  return l_ret;
}

end implementation ACncpx;



