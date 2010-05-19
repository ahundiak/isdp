/* $Id: VDsolLocFn.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdpocket/func/VDsolLocFn.I
 *
 * Description:
 *		Functions to determine the relationship between
 *		an objects and a constraint solid.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsolLocFn.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
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
# Revision 1.15  1995/09/18  19:04:26  pinnacle
# Replaced: ./vdpocket/func/VDsolLocFn.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			raju		creation date
 *	09/17/95	raju		add stop checking.
 *
 ***************************************************************************/

class implementation  Root;

/*
Name
   VDsolLocFnc.I

Description
   This file contains functions which are used by Locate with Solid
   function.

Notes

Abstract

History
   09-13-1994  Raju   Creation
*/
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "growner.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "emssfintdef.h"
#include "emsdattyp.h"
#include "EMStypedef.h"
#include "EMSconstruct.h"
#include "EMSmsgdef.h"
#include "emsinter.h"

#include "VDvolelem.h"
/*
#define  VDS_DBG
*/
#include "vderrmacros.h"
#include "vdsollocdef.h"

%safe
static char	    obj_rln;
static char	    obj_processed;
%endsafe

extern   OMuword  OPP_EMSsolid_class_id,
		  OPP_EMSsurface_class_id,
		  OPP_GRcurve_class_id,
		  OPP_GRpoint_class_id,
		  OPP_ACncpx_class_id,
		  OPP_GRowner_class_id,
		  OPP_GRgencs_class_id,
		  OPP_GRreffile_class_id,
		  OPP_GRdvattach_class_id;

extern	IGRboolean		IGEstop();

from    EMSsurface    import   EMcrvsrfint;
from	EMSsolid      import   EMpoint_locate;
from	GRlinear      import   GRgetpolyline;
from	EMSsurface    import   EMputLsIfNotThere;
from	GRgencs	      import   GRgetmatrix;
from	GRowner	      import   GRget_context;
from	GRowner	      import   GRget_components;


/*+fe
Function   VDsolid_surf_rln

Abstract
Given a solid and another solid/surface, this function determines
relation of the other object wrt solid.

Arguments
  long			*msg	      O -  return status
  struct GRid		*solid        I - solid object
  struct GRmd_env	*solid_env    I - env of solid
  struct GRid		*other_obj    I - object whose relation wrt solid is
					  to be found. Can be solid or surface.
  struct GRmd_env	*other_env    I - env of other object
  char			*relation     O - relation of other object wrt solid

Description
First these two objects are intersected ( without creating intersection list)
to see if these two are intersecting.

If not intersecting, it is found whether the second object is inside or
outside.

Notes

Return status
  same as OM return status

Return message
  MSFAIL - failue

History
   09-13-1994  Raju   Creation
-fe*/
long   VDsolid_surf_rln (
  long			*msg,
  struct GRid		*solid,
  struct GRmd_env	*solid_env,
  struct GRid		*other_obj,
  struct GRmd_env	*other_env,
  char			*relation
)
{
long			sts;
IGRushort		inters_opts, world_opts, param_opts, trim_opts;
struct EMSdataselect	obj2;
IGRint			num_inters;
IGRulong		location;


    __DBGpr_com("Entered VDsolid_surf_rln" );
    __DBGpr_obj("solid obj", *solid );
    __DBGpr_obj("other obj", *other_obj );

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    *relation = VD_UNKNOWN;

    /*
     * see if there is an intersection between the two
     */
    obj2.datatype    = EMSdata_object;
    obj2.data.object = other_obj;


    sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(msg, 
	    &solid_env->md_env, NULL, NULL, NULL, NULL), senderid = NULL_OBJID, 
	    targetid = solid->objid, targetos = solid->osnum);
    VDS_ERR_HNDLR("EMSsurface.EMputLsIfNotThere",sts,*msg, VD_VERBOSE, wrapup );

    sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(msg, 
	    &other_env->md_env, NULL, NULL, NULL, NULL), senderid = NULL_OBJID, 
	    targetid = other_obj->objid, targetos = other_obj->osnum);
    VDS_ERR_HNDLR("EMSsurface.EMputLsIfNotThere",sts,*msg, VD_VERBOSE, wrapup );

    inters_opts = EMS_SFINT_MUSTCLOSE | EMS_SFINT_AUTODOUBLECHECK |
		  EMS_SFINT_SKIPFIXING | EMS_SFINT_NOREFINE;

    world_opts  = NULL;
    param_opts  = NULL;

    trim_opts   = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_COPLANAR |
		  EMSINT_TRIM_BDRYISAREA | EMSINT_TRIM_PROCOVERLAP;

    num_inters = 0;
    sts = EMintersect_surfaces (  msg,
				  solid,
				  &(solid_env->md_env),
                                  1,
				  &obj2,
				  &(other_env->md_env),
				  inters_opts,
				  world_opts,
				  param_opts,
				  trim_opts,
				  NULL,
				  &num_inters,
				  NULL, NULL, NULL, NULL,
				  NULL, NULL,
				  NULL);
    __DBGpr_int ( "num_inters", num_inters );

    /*
     * print error statement only if VDS_DBG is defined.
     */
#ifdef VDS_DBG
    VDS_ERR_HNDLR ( "EMintersect_surfaces", sts, *msg, VD_VERBOSE, wrapup );
#else
    if ( !(sts&*msg&1) ) goto wrapup;
#endif

/*
struct GRid		*inters;

    inters = (struct GRid *) malloc(sizeof(struct GRid));
    inters->osnum = 2;
    inters->objid = NULL_OBJID;


    inters_opts = EMS_SFINT_MUSTINTERSECT | EMS_SFINT_MUSTCLOSE |
		  EMS_SFINT_AUTODOUBLECHECK |
		  EMS_SFINT_SKIPFIXING | EMS_SFINT_NOREFINE;

    world_opts  = EMSINT_OUTPUT_WORLD;
    param_opts  = EMSINT_OUTPUT_PARAM | EMSINT_PARAM_OBJECT |
		  EMSINT_ORIENT_OUTPUT;

    trim_opts   = EMSINT_TRIM_OUTPUT | EMSINT_TRIM_COPLANAR |
		  EMSINT_TRIM_BDRYISAREA | EMSINT_TRIM_PROCOVERLAP;

    num_inters = 0;
    sts = EMintersect_surfaces (  msg,
				  solid,
				  &(solid_env->md_env),
                                  1,
				  &obj2,
				  &(other_env->md_env),
				  inters_opts,
				  world_opts,
				  param_opts,
				  trim_opts,
				  NULL,
				  &num_inters,
				  NULL, NULL, NULL, NULL,
				  NULL, NULL,
				  NULL);
    __DBGpr_int ( "num_inters", num_inters );
    VDS_ERR_HNDLR ( "EMintersect_surfaces", sts, *msg, VD_VERBOSE, wrapup );

	    sts = om$send ( msg = message EMSsurface.EMsfsfint (
			&msg,
			&(me->vol.mod_env.md_env.matrix_type),
			me->vol.mod_env.md_env.matrix,
			NULL,
			&obj2,
			&set_elem_env.md_env,
			NULL,
			NULL,
	    EMSINT_TRIM_OUTPUT | EMSINT_TRIM_COPLANAR | EMSINT_TRIM_BDRYISAREA,
			&num_inters, 
			NULL, NULL ),
		   targetid = me->vol.obj_id.objid,
		   targetos = me->vol.obj_id.osnum);
*/

   if ( num_inters )
	*relation = VD_OVERLAP;
   else
   {
	sts = EFsolidRelationship (	(EMSrc *)msg,
					NULL_OBJID,
					solid->objid,
					other_obj->objid,
					solid->osnum,
					other_obj->osnum,
					solid_env,
					other_env,
					0,
					&location );
	if ( *msg == EMS_S_Success )
	{
	    if ( location == EMS_S_INSOLID )
		*relation = VD_INSIDE;
	    else if ( location == EMS_S_OUTSOLID )
		*relation = VD_OUTSIDE;
	}
	else if(*msg == EMS_I_InvalidArg && location == EMS_S_ONSOLID)
	    *relation = VD_OVERLAP;
   }

wrapup:
   __DBGpr_com("Exiting VDsolid_surf_rln" );
   *msg = MSSUCC;
   return sts;

}


/*+fe
Function   VDsolid_crv_rln

Abstract
Given a solid and curve, this function determines relation of the curve
object wrt solid.

Arguments
  long			*msg	      O -  return status
  struct GRid		*solid        I - solid object
  struct GRmd_env	*solid_env    I - env of solid
  struct GRid		*crv_obj      I - curve object
  struct GRmd_env	*crv_env      I - env of curve
  char			*relation     O - relation of curve wrt solid

Description
First these two objects are intersected ( without creating intersection list)
to see if these two are intersecting.

If not intersecting, it is found whether the second object is inside or
outside.

Notes

Return status
  same as OM return status

Return message
  MSFAIL - failue

History
   09-13-1994  Raju   Creation
-fe*/
long  VDsolid_crv_rln (
  long			*msg,
  struct GRid		*solid,
  struct GRmd_env	*solid_env,
  struct GRid		*crv_obj,
  struct GRmd_env	*crv_env,
  char			*relation
)
{
long			sts,
			pnt_slots = 0;
struct EMSdataselect	other_obj;
enum   EMScvinttype	loc;
double			PtOnCrv[3];
IGRushort		solidPtLocOptions = NULL;
IGRulong		location;
IGRlong			num_inters;


   *msg = MSSUCC;
   sts  = OM_S_SUCCESS;
   *relation = VD_UNKNOWN;

   /* 
    * see if solid and curve intersect
    */
   num_inters = 0;

   sts = om$send ( msg = message EMSsurface.EMcrvsrfint (
						msg,
						NULL,
						&solid_env->md_env,
						NULL,
						crv_obj,
						&crv_env->md_env,
						FALSE,
						&pnt_slots,
						&num_inters,
						NULL, NULL,
						NULL, NULL, NULL ),
			    senderid  = solid->objid,
			    targetid  = solid->objid,
			    targetos  = solid->osnum );

   VDS_ERR_HNDLR ( "EMSsurface.EMcrvsrfint", sts, *msg, VD_VERBOSE, wrapup );

   __DBGpr_int("num_inters", num_inters);

   if ( num_inters )
	*relation = VD_OVERLAP;
   else
   {
	other_obj.datatype    = EMSdata_object;
	other_obj.data.object = crv_obj;
	loc = EMScvint_rtend;
	sts  = EMinternalpt (   msg,
				&crv_env->md_env.matrix_type,
				crv_env->md_env.matrix,
				&other_obj,
				loc,
				1,
				PtOnCrv );
	VDS_ERR_HNDLR ( "EMinternalpt", sts, *msg, VD_VERBOSE, wrapup );

	sts  = om$send ( msg = message EMSsolid.EMpoint_locate (
						msg,
						solid_env,
						solidPtLocOptions,
						PtOnCrv,
						NULL,
						&location ), 
				targetid = solid->objid,
				targetos = solid->osnum,
				senderid = NULL_OBJID );
	VDS_ERR_HNDLR("EMSsolid.EMpoint_locate", sts, *msg, VD_VERBOSE,wrapup );

	if ( location == EMS_S_INSOLID )
		*relation = VD_INSIDE;
	else if ( location == EMS_S_OUTSOLID )
		*relation = VD_OUTSIDE;
	else
	{
		printf("**** Curve needs further processing ****\n");
		goto wrapup;
	}
   }

wrapup:
	*msg = MSSUCC;
	return sts;

}

/*+fe
Function   VDsolid_pt_rln

Abstract
Given a solid and a point, this function determines relation of the point
object wrt solid.

Arguments
  long			*msg	      O -  return status
  struct GRid		*solid        I - solid object
  struct GRmd_env	*solid_env    I - env of solid
  struct GRid		*pt_obj       I - point object
  struct GRmd_env	*pt_env       I - env of point
  char			*relation     O - relation of curve wrt solid

Description
Relationship is found using point locate wrt solid.

Notes

Return status
  same as OM return status

Return message
  MSFAIL - failue

History
   09-13-1994  Raju   Creation
-fe*/
long  VDsolid_pt_rln (
  long			*msg,
  struct GRid		*solid,
  struct GRmd_env	*solid_env,
  struct GRid		*pt_obj,
  struct GRmd_env	*pt_env,
  char			*relation
)
{
long			sts;
int			action;
struct IGRpolyline	polyline;
double			pt[3];
IGRushort		solidPtLocOptions = NULL;
IGRulong		location;


   *msg = MSSUCC;
   sts  = OM_S_SUCCESS;
   *relation = VD_UNKNOWN;

   polyline.points  = pt;
   action = 1;
   sts = om$send( msg = message GRlinear.GRgetpolyline( 
					msg,
     					&(pt_env->md_env.matrix_type),
     					pt_env->md_env.matrix,
					&action,
					&polyline),
		   targetid = pt_obj->objid,
		   targetos = pt_obj->osnum,
		   senderid = NULL_OBJID );

   VDS_ERR_HNDLR("GRlinear.GRgetpolyline", sts, *msg, VD_VERBOSE, wrapup);

   sts  = om$send ( msg = message EMSsolid.EMpoint_locate (
						msg,
						solid_env,
						solidPtLocOptions,
						pt,
						NULL,
						&location ), 
				targetid = solid->objid,
				targetos = solid->osnum,
				senderid = NULL_OBJID );
   VDS_ERR_HNDLR ("EMSsolid.EMpoint_locate", sts, *msg, VD_VERBOSE, wrapup);

   if ( location == EMS_S_INSOLID )
	*relation = VD_INSIDE;
   else if ( location == EMS_S_OUTSOLID )
	*relation = VD_OUTSIDE;
   else
	*relation = VD_OVERLAP;

wrapup:
   *msg = MSSUCC;
   return sts;
}

/*+fe
Function   VDsolid_cs_rln

Abstract
Given a solid and a coordinate system, this function determines 
relation of the cs wrt solid.

Arguments
  long			*msg	      O -  return status
  struct GRid		*solid        I - solid object
  struct GRmd_env	*solid_env    I - env of solid
  struct GRid		*cs_obj       I - cs object
  struct GRmd_env	*cs_env       I - env of cs
  char			*relation     O - relation of cs wrt solid

Algorithm
Relationship is found using point locate wrt solid.

Notes

Return status
  same as OM return status

Return message
  MSFAIL - failue

History
   09-13-1994  Raju   Creation
-fe*/
long  VDsolid_cs_rln (
  long			*msg,
  struct GRid		*solid,
  struct GRmd_env	*solid_env,
  struct GRid		*cs_obj,
  struct GRmd_env	*cs_env,
  char			*relation
)
{
long			sts;
double			lcl_to_wld_mx[16],
			wld_origin[3],  /* origin of cs in wld cs */
			lcl_origin[3],  /* origin of cs in present locate */
			*env_mx;
IGRushort		solidPtLocOptions = NULL;
IGRulong		location;


   *msg = MSSUCC;
   sts  = OM_S_SUCCESS;
   *relation = VD_UNKNOWN;

   sts = om$send( msg = message GRgencs.GRgetmatrix( 
					msg,
					lcl_to_wld_mx),
		   targetid = cs_obj->objid,
		   targetos = cs_obj->osnum,
		   senderid = NULL_OBJID );
   VDS_ERR_HNDLR("GRliear.GRgetployline", sts, *msg, VD_VERBOSE, wrapup);

   wld_origin[0] = lcl_to_wld_mx[3];
   wld_origin[1] = lcl_to_wld_mx[7];
   wld_origin[2] = lcl_to_wld_mx[11];

#ifdef VDS_DBG
   printf(" cs origin in world cs : [%lf], [%lf], [%lf]\n",
		wld_origin[0], wld_origin[1], wld_origin[2] );
#endif

   env_mx = cs_env->md_env.matrix;

   lcl_origin[0] =	env_mx[0] * wld_origin[0] +
			env_mx[1] * wld_origin[1] +
			env_mx[2] * wld_origin[2] +
			env_mx[3];

   lcl_origin[1] =	env_mx[4] * wld_origin[0] +
			env_mx[5] * wld_origin[1] +
			env_mx[6] * wld_origin[2] +
			env_mx[7];

   lcl_origin[2] =	env_mx[8] * wld_origin[0] +
			env_mx[9] * wld_origin[1] +
			env_mx[10] * wld_origin[2] +
			env_mx[11];

   sts  = om$send ( msg = message EMSsolid.EMpoint_locate (
						msg,
						solid_env,
						solidPtLocOptions,
						lcl_origin,
						NULL,
						&location ), 
				targetid = solid->objid,
				targetos = solid->osnum,
				senderid = NULL_OBJID );
   VDS_ERR_HNDLR ("EMSsolid.EMpoint_locate", sts, *msg, VD_VERBOSE, wrapup);

   if ( location == EMS_S_INSOLID )
	*relation = VD_INSIDE;
   else if ( location == EMS_S_OUTSOLID )
	*relation = VD_OUTSIDE;
   else
	*relation = VD_OVERLAP;

wrapup:
   *msg = MSSUCC;
   return sts;
}

long  VDsolid_comp_rln(
 long			*msg,			/* O */
 struct GRid		*solid,			/* I */
 struct GRmd_env	*solid_env,		/* I */
 struct GRid		*comp,			/* I */
 struct GRmd_env	*comp_env,		/* I */
 char			*comp_processed,	/* O */
 char			*comp_rln		/* O */
)
{
long		sts;
OMuword		comp_classid;
char		comp_type;


  if (	!msg || !solid || !solid_env || !comp || !comp_env ||
	!comp_processed  || !comp_rln )
  {
    sts = OM_E_INVARG;
    *msg = MSINARG;
    goto wrapup;
  }

  __DBGpr_com ( "Entered VDsolid_comp_rln" );
  __DBGpr_obj ( "component id", *comp );

  sts = OM_S_SUCCESS;
  *msg = MSSUCC;


  *comp_processed = FALSE;
  *comp_rln = VD_UNKNOWN;

  if ( IGEstop() )  goto wrapup;

  sts = om$get_classid ( osnum     = comp->osnum,
			 objid     = comp->objid,
			 p_classid = &comp_classid   );
  if ( !(sts&1) )
  {
    printf("%s[%d] om$get_classid failed for object[%d,%d]\n",
			__FILE__, __LINE__,
			comp->osnum, comp->objid);
    goto wrapup;
  }

  comp_type = VD_UNKNOWN;
  if ( om$is_ancestry_valid (	subclassid   = comp_classid,
				superclassid = OPP_EMSsolid_class_id ) ==
							OM_S_SUCCESS )
  {
	comp_type = VD_SOLID;
  }
  else if ( om$is_ancestry_valid ( subclassid   = comp_classid,
				   superclassid = OPP_EMSsurface_class_id ) ==
							OM_S_SUCCESS )
  {
	comp_type = VD_SURFACE;
  }
  else if ( om$is_ancestry_valid ( subclassid   = comp_classid,
				   superclassid = OPP_GRcurve_class_id ) ==
							OM_S_SUCCESS )
  {
	comp_type = VD_CURVE;
	if ( om$is_ancestry_valid ( subclassid   = comp_classid,
				    superclassid = OPP_GRpoint_class_id ) ==
							OM_S_SUCCESS )
		comp_type = VD_POINT;
  }
  else if ( om$is_ancestry_valid ( subclassid   = comp_classid,
				   superclassid = OPP_GRgencs_class_id ) ==
							OM_S_SUCCESS )
  {
		comp_type = VD_CS;
  }

  if ( comp_type == VD_UNKNOWN ) goto wrapup;

  *comp_processed = TRUE;

  switch ( comp_type )
  {
    case VD_SOLID:
    case VD_SURFACE:
     sts  = VDsolid_surf_rln ( msg,
			      solid,
			      solid_env,
			      comp,
			      comp_env,
			      comp_rln );
     /*
      * print error message only in DBG mode
      */
#ifdef VDS_DBG
     VDS_ERR_HNDLR ( "VDsolid_surf_rln", sts, *msg, VD_VERBOSE, wrapup);
#else
     if ( !(sts & *msg & 1) ) goto wrapup;
#endif
     break;

    case VD_CURVE:
     sts = VDsolid_crv_rln ( msg,
			     solid,
			     solid_env,
			     comp,
			     comp_env,
			     comp_rln );
     VDS_ERR_HNDLR ( "VDsolid_crv_rln", sts, *msg, VD_VERBOSE, wrapup );
     break;

     case VD_POINT:
      sts = VDsolid_pt_rln ( msg,
			     solid,
			     solid_env,
			     comp,
			     comp_env,
			     comp_rln );
      VDS_ERR_HNDLR ( "VDsolid_pt_rln", sts, *msg, VD_VERBOSE, wrapup );
      break;

     case VD_CS:
      sts = VDsolid_cs_rln ( msg,
			     solid,
			     solid_env,
			     comp,
			     comp_env,
			     comp_rln );
      VDS_ERR_HNDLR ( "VDsolid_cs_rln", sts, *msg, VD_VERBOSE, wrapup );
      break;

      /* default is not necessary */

  } /* switch ( comp_type ) */

  __DBGpr_int("relation of component", *comp_rln );

wrapup:
  return sts;

}

long VDsolid_obj_rln (
 long			*msg,
 struct GRid		*solid,		/* I - reference solid	*/
 struct GRmd_env	*solid_env,	/* I - solid env	*/
 struct GRobj_env	*obj		/* I - input object */
)
{
long			sts;
OMuword			obj_classid;
int			ii, compcnt = 50;
struct GRid		complist[50];


 if ( !msg || !solid || !solid_env || !obj )
 {
    sts = OM_E_INVARG;
    *msg = MSINARG;
    goto wrapup;
 }

 sts = OM_S_SUCCESS;
 *msg = MSSUCC;

 if ( IGEstop() )  goto wrapup;

 if ( obj_rln == VD_OVERLAP ) goto wrapup;

 sts = om$get_classid ( objid     = obj->obj_id.objid,
			osnum     = obj->obj_id.osnum,
			p_classid = &obj_classid );
 if ( !(sts&1) )
 {
    printf("%s[%d] om$get_classid failed for object[%d,%d]\n",
		__FILE__, __LINE__, obj->obj_id.osnum, obj->obj_id.objid);
    goto wrapup;
 }

 if ( om$is_ancestry_valid ( subclassid   = obj_classid,
			     superclassid = OPP_GRowner_class_id ) ==
							OM_S_SUCCESS )
 {
    OMuword		comp_classid;
    struct GRobj_env	comp;
    char		comp_processed,
			comp_rln;

    sts = om$send ( msg = message GRowner.GRget_components (
						msg,
						&obj->mod_env,
						complist,
						compcnt,
						&compcnt,
						0,
						OM_K_MAXINT ),
		    targetid = obj->obj_id.objid,
		    targetos = obj->obj_id.osnum,
		    senderid = NULL_OBJID );
/*
    om$report_error ( sts = sts );
    VDS_ERR_HNDLR( "GRowner.GRget_components", sts, *msg, VD_VERBOSE, wrapup );
*/
    if ( !(sts&1) )
    {
      printf( "%s[%d] : GRowner.GRget_components failure\n", __FILE__,
							     __LINE__  );
      goto wrapup;
    }

    if ( sts&1  && compcnt == 0 ) *msg = MSSUCC;

    if ( compcnt > 0 )
    {
	sts = om$send ( msg = message GRowner.GRget_context(
						msg,
						&obj->mod_env,
						&comp.mod_env ),
			targetid = obj->obj_id.objid,
			targetos = obj->obj_id.osnum,
			senderid = NULL_OBJID );
	VDS_ERR_HNDLR( "GRowner.GRget_context", sts, *msg, VD_VERBOSE, wrapup);
    }

    for ( ii=0; ii<compcnt; ii++)
    {

	if ( IGEstop() ) break;

	sts = om$get_classid ( objid     = complist[ii].objid,
			       osnum     = complist[ii].osnum,
			       p_classid = &comp_classid );
	if ( !(sts&1) )
	{
		printf("%s[%d] om$get_classid failed for object[%d,%d]\n",
			__FILE__, __LINE__,
			complist[ii].osnum, complist[ii].objid );
		continue;
	}

	if ( (om$is_ancestry_valid ( subclassid   = comp_classid,
				    superclassid = OPP_EMSsolid_class_id) ==
							OM_S_SUCCESS ) ||
	     (om$is_ancestry_valid ( subclassid   = comp_classid,
				    superclassid = OPP_EMSsurface_class_id) ==
							OM_S_SUCCESS ) ||
	     (om$is_ancestry_valid ( subclassid   = comp_classid,
				    superclassid = OPP_GRcurve_class_id) ==
							OM_S_SUCCESS ) ||
	     (om$is_ancestry_valid ( subclassid   = comp_classid,
				    superclassid = OPP_GRgencs_class_id) ==
							OM_S_SUCCESS )
        )
	{
	     comp.obj_id.objid = complist[ii].objid;
	     comp.obj_id.osnum = complist[ii].osnum;

	     sts = VDsolid_comp_rln (	msg,
					solid,
					solid_env,
					&comp.obj_id,
					&comp.mod_env,
					&comp_processed,
					&comp_rln );
	     if ( !(sts & *msg & 1) )
	     {
		/*
		 * solid-component relation failed.
		 * Found to happen when size of surface of revolution is smaller
		 * than bastol.
		 * Ignoring this component and proceeding with
		 * remaining components.
		 * Idea is relation of rest of objects will be relation
		 * of the total object.
		 */
		VD_InfoWarning( 3, &comp.obj_id, NULL );

#ifdef	VDS_DBG
		printf("%s[%d] : VDsolid_comp_rln failed;",__FILE__,__LINE__);
#endif
		sts = OM_S_SUCCESS;
		*msg = MSSUCC;
		continue;
	     }

	     if ( comp_processed ) obj_processed = TRUE;
	     if ( comp_processed )
	     {
		if  ( obj_rln == VD_UNKNOWN )
			obj_rln = comp_rln;
		else if ( obj_rln == VD_OUTSIDE && comp_rln != VD_UNKNOWN  )
			obj_rln = comp_rln;
		else if ( obj_rln == VD_INSIDE && comp_rln == VD_OVERLAP )
			obj_rln = VD_OVERLAP;

		if ( obj_rln == VD_OVERLAP ) goto wrapup;
	     }
	}
	else if ( (om$is_ancestry_valid ( subclassid   = comp_classid,
				    superclassid = OPP_GRowner_class_id ) ==
							OM_S_SUCCESS ) 
	)
	{
	   struct GRobj_env tmpobj;

	   tmpobj.obj_id.objid	= complist[ii].objid;
	   tmpobj.obj_id.osnum	= complist[ii].osnum;
	   tmpobj.mod_env	= comp.mod_env;

	   sts = VDsolid_obj_rln ( msg,
				   solid,
				   solid_env,
				   &tmpobj     );
	   VDS_ERR_CONTINUE ( "VDsolid_obj_rln", sts, *msg, VD_VERBOSE );
	}
	else
	{
/*
	   comp_list[*nb_comps].objid = compLinkage[ii].S_objid;
	   comp_list[*nb_comps].osnum = compLinkage[ii].osnum;
	   (*nb_comps)++;
*/
	   continue;
	}

    } /*  for ( ii=0; ii<cnt; ii++) */
 } /* if ( subclass of GRowner ) */
 else
 {
    char  obj_processed_loc,
	  obj_rln_loc;


    sts = VDsolid_comp_rln (	msg,
				solid,
				solid_env,
				&(obj->obj_id),
				&(obj->mod_env),
				&obj_processed_loc,
				&obj_rln_loc );
    if ( !(sts & *msg & 1) )
    {
	/*
	 * solid-component relation failed.
	 * Found to happen when size of surface of revolution is smaller
	 * than bastol.
	 * Ignoring this component and proceeding with
	 * remaining components.
	 * Idea is relation of rest of objects will be relation
	 * of the total object.
	 */

#ifdef	VDS_DBG
	printf("%s[%d] : VDsolid_comp_rln failed;", __FILE__, __LINE__);
#endif

	VD_InfoWarning( 3, &obj->obj_id, NULL );
	sts = OM_S_SUCCESS;
	*msg = MSSUCC;
	goto wrapup;
    }

    if ( obj_processed_loc ) obj_processed = TRUE;
    if ( obj_processed_loc )
    {
	if  ( obj_rln == VD_UNKNOWN )
	      obj_rln = obj_rln_loc;
	else if ( obj_rln == VD_OUTSIDE && obj_rln_loc != VD_UNKNOWN  )
	      obj_rln = obj_rln_loc;
	else if ( obj_rln == VD_INSIDE && obj_rln_loc == VD_OVERLAP )
	      obj_rln = VD_OVERLAP;
    }
 }

wrapup:
    return sts;
}

long  VDsolidFilter (
 long			*msg,		/* O - return message	*/
 struct GRid		*solid,		/* I - reference solid	*/
 struct GRmd_env	*solid_env,	/* I - solid env	*/
 char			rln_needed,	/* I - desired relation */ 
 int			num_obj_in,	/* I - no. of input objects */
 struct GRobj_env	*obj_list_in,   /* I - list of input objects */
 int			*num_obj_out,   /* O - no. of objects which have
					       the desired relation  */
 struct GRobj_env	**obj_list_out  /* O - list of desired objects.
						= NULL, if not needed */
)
{
long			sts;
struct GRobj_env	obj;
int			ii;
OMuword			obj_classid;


   sts = OM_S_SUCCESS;
   *msg = MSSUCC;

   __DBGpr_com("Entered VDsolidFilter");
   __DBGpr_obj("Solid", *solid );
   __DBGpr_int("No. of objects to be processed", num_obj_in ); 

   *num_obj_out = 0;
   if ( obj_list_out )
     *obj_list_out = (struct GRobj_env *) malloc(sizeof(struct GRobj_env) *
                                                        num_obj_in);

   for(ii=0; ii<num_obj_in; ii++)
   {
	if ( IGEstop() ) break;

	obj.obj_id = obj_list_in[ii].obj_id;
	obj.mod_env = obj_list_in[ii].mod_env;

	__DBGpr_obj( "Processing object", obj.obj_id );

	obj_rln = VD_UNKNOWN;
	obj_processed = FALSE;

	sts = om$get_classid (  osnum     = obj.obj_id.osnum,
				objid     = obj.obj_id.objid,
				p_classid = &obj_classid   );

	if ( om$is_ancestry_valid ( subclassid   = obj_classid,
				    superclassid = OPP_GRreffile_class_id ) !=
							OM_S_SUCCESS &&
	     om$is_ancestry_valid ( subclassid = obj_classid,
				    superclassname = "VRplane" ) != 
							OM_S_SUCCESS &&
	     om$is_ancestry_valid ( subclassid = obj_classid,
				    superclassid = OPP_GRdvattach_class_id ) !=
							OM_S_SUCCESS
	)
	{
	  sts = VDsolid_obj_rln ( msg,
				  solid,
				  solid_env,
				  &obj );
	  /*
	   * Now return status of VSsolid_obj_rln is always success
	   */
	  VDS_ERR_CONTINUE ( "VDsolid_obj_rln", sts, *msg, VD_VERBOSE );
	}
	else
	{
	   obj_processed = TRUE;
	   obj_rln = VD_OUTSIDE;
	}

	if ( !obj_processed || obj_rln == VD_UNKNOWN ){
		VD_InfoWarning( 1, &obj.obj_id, NULL );
		continue;
	}

#ifdef  VDS_DBG
	if ( obj_rln == VD_INSIDE )
	   printf("\tObject is INSIDE\n");
	else if ( obj_rln == VD_OVERLAP )
	   printf("\tObject is OVERLAPPING\n");
	else if ( obj_rln == VD_OUTSIDE )
	   printf("\tObject is OUTSIDE\n");
	else if ( obj_rln == VD_UNKNOWN )
	   printf("\tRelation of object UNKNOWN\n");
#endif

	switch ( obj_rln )
	{
	   case VD_UNKNOWN :
	   case VD_OUTSIDE :
		break;

	   case VD_INSIDE  :
	     if ( rln_needed == VD_EL_INSIDE ||
		  rln_needed == VD_EL_INSIDE_OVERLAP )
	     {
		if ( obj_list_out)  (*obj_list_out)[*num_obj_out] =
							obj_list_in[ii];
		(*num_obj_out)++;
	     }
	     break;

	   case VD_OVERLAP  :
	     if ( rln_needed == VD_EL_OVERLAP ||
		  rln_needed == VD_EL_INSIDE_OVERLAP )
	     {
		if ( obj_list_out)  (*obj_list_out)[*num_obj_out] =
							obj_list_in[ii];
		(*num_obj_out)++;
	     }
	     break;

	} /*      switch ( obj_rln ) */

   } /* for(ii=0; ii<num_obj_in; ii++) */

   /* supress compilation warning for warpup not referenced */
   goto wrapup;

wrapup:
   if ( obj_list_out )
	*obj_list_out = (struct GRobj_env *)realloc( *obj_list_out,
				  sizeof(struct GRobj_env) * (*num_obj_out));

   __DBGpr_com("Exiting VDsolidFilter");
   return sts;

}

#if 0

Following two functions are obsolete. They are no longer used.

static struct GRid  comp_list[10];

/*+fe
Function   VDflatten_object

Abstract
  This function flattens an object into solids, surfaces, curves,
coordinate system and other objects.

Arguments
  long			*msg	      O - return status
  struct GRid		owner_obj     I - owner object
  int			*nb_comps   I/O - At input no. of existing components.
					  At output includes no. of components
					  on the owner object.
Description

Notes
  Components are added to static var comp_list.


Return status
  same as OM return status

Return message
  MSFAIL - failue

History
   09-19-1994  Raju   Creation
-fe*/
long VDflatten_object (
 long		*msg,
 struct GRid	input_obj,
 int		*nb_comps
)
{
long		sts;
OMuword		elem_classid;
OM_S_CHANSELECT to_components;
int		cnt,
		ii;
OM_S_OBJECT_LINKAGE  *compLinkage = NULL;


 sts = OM_S_SUCCESS;
 *msg = MSSUCC;

 sts = om$get_classid ( objid     = input_obj.objid,
			osnum     = input_obj.osnum,
			p_classid = &elem_classid );
 if ( !(sts&1) )
 {
    printf("%s[%d] om$get_classid failed for object[%d,%d]\n",
		__FILE__, __LINE__, input_obj.osnum, input_obj.objid);
    goto wrapup;
 }

 if ( om$is_ancestry_valid ( subclassid   = elem_classid,
			     superclassid = OPP_GRowner_class_id ) ==
							OM_S_SUCCESS )
 {
    sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
			     p_chanselect = &to_components);

    sts = om$get_channel_count( osnum        = input_obj.osnum,
				objid        = input_obj.objid,
				p_chanselect = &to_components,
				count        = (OMuint *) &cnt );
    if ( cnt == 0 )  goto wrapup;

    compLinkage = _MALLOC( cnt, OM_S_OBJECT_LINKAGE );

    if ( (comp_list == NULL) || !compLinkage )
    {
	*msg = EMS_E_NoDynamicMemory;
	sts  = OM_E_NODYNMEM;
	goto wrapup;
    }

    sts = om$get_channel_objects ( osnum	 = input_obj.osnum,
				   objid	 = input_obj.objid,
				   p_chanselect  = &to_components,
				   list          = compLinkage,
				   size          = cnt,
				   count         = (OMuint *)&cnt );
    VDS_ERR_HNDLR( "om$get_channel_objects", sts, MSSUCC, VD_VERBOSE, wrapup );

    for ( ii=0; ii<cnt; ii++)
    {
	if ( *nb_comps == 200 ) goto wrapup;

	sts = om$get_classid ( objid     = compLinkage[ii].S_objid,
			       osnum     = compLinkage[ii].osnum,
			       p_classid = &elem_classid );
	if ( !(sts&1) )
	{
		printf("%s[%d] om$get_classid failed for object[%d,%d]\n",
			__FILE__, __LINE__,
			compLinkage[ii].osnum, compLinkage[ii].S_objid );
		continue;
	}

	if ( (om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_EMSsolid_class_id) ==
							OM_S_SUCCESS ) ||
	     (om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_EMSsurface_class_id) ==
							OM_S_SUCCESS ) ||
	     (om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_GRcurve_class_id) ==
							OM_S_SUCCESS ) ||
	     (om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_GRgencs_class_id) ==
							OM_S_SUCCESS )
        )
	{
	  comp_list[*nb_comps].objid = compLinkage[ii].S_objid;
	  comp_list[*nb_comps].osnum = compLinkage[ii].osnum;
	  (*nb_comps)++;
	  continue;
	}
	else if ( (om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_GRowner_class_id ) ==
							OM_S_SUCCESS ) 
        )
	{
	   struct GRid tmpobj;

	   tmpobj.objid = compLinkage[ii].S_objid;
	   tmpobj.osnum = compLinkage[ii].osnum;
	   sts = VDflatten_object (	msg,
					tmpobj,
					nb_comps );
	   VDS_ERR_CONTINUE ( "VDflatten_object", sts, *msg, VD_VERBOSE );
	}
	else
	{
	   comp_list[*nb_comps].objid = compLinkage[ii].S_objid;
	   comp_list[*nb_comps].osnum = compLinkage[ii].osnum;
	   (*nb_comps)++;
	   continue;
	}

    } /*  for ( ii=0; ii<cnt; ii++) */
 } /* if ( subclass of GRowner ) */
 else
 {
    comp_list[*nb_comps] = input_obj;
    (*nb_comps)++;

 }

wrapup:
    _FREE ( compLinkage ) ;
    return sts;
}

/*
 Function : VDsolidFilter

 This function filters given objects with respect to given solid and
relation and outputs the selected objects

 Memory for 'obj_list_out' is allocated by this function. It should
be freed by caller using
	if ( obj_list_out ) free ( obj_list_out );

This is old routine. Can be deleted after a while.

*/
long  VDsolidFilter_old (
 long			*msg,		/* O - return message	*/
 struct GRid		*solid,		/* I - reference solid	*/
 struct GRmd_env	*solid_env,	/* I - solid env	*/
 char			rln_needed,	/* I - desired relation */ 
 int			num_obj_in,	/* I - no. of input objects */
 struct GRobj_env	*obj_list_in,   /* I - list of input objects */
 int			*num_obj_out,   /* O - no. of objects which have
					       the desired relation  */
 struct GRobj_env	**obj_list_out  /* O - list of desired objects.
						= NULL, if not needed */
)
{
long			sts;
struct GRid		elem_id;
struct GRmd_env		mod_env,
			elem_env;
int			sizbuf,
			NoBytesRet,
			ii;
OMuword			elem_classid;
char			object_type,
			elem_rln;
char			comps_processed,
			comp_rln;
int			nb_comps, jj;


   sts = OM_S_SUCCESS;
   *msg = MSSUCC;

   __DBGpr_com("Entered VDsolidFilter");
   __DBGpr_obj("Solid", *solid );
   __DBGpr_int("No. of objects to be processed", num_obj_in ); 

   sizbuf = sizeof ( struct GRmd_env );
   gr$get_module_env(msg    = msg,
		     sizbuf = &sizbuf,
		     buffer = &mod_env,
		     nret   = &NoBytesRet );	

   *num_obj_out = 0;

   if ( obj_list_out )
     *obj_list_out = (struct GRobj_env *) malloc(sizeof(struct GRobj_env) *
                                                        num_obj_in);

   for(ii=0; ii<num_obj_in; ii++)
   {
	elem_id = obj_list_in[ii].obj_id;
	elem_env = obj_list_in[ii].mod_env;

	__DBGpr_obj( "Processing object", elem_id );


	/* get all components of the object */
	nb_comps = 0;
	sts = VDflatten_object(	msg,
				elem_id,
				&nb_comps );
	VDS_ERR_HNDLR ( "VDflatten_object", sts, *msg, VD_VERBOSE, wrapup );

	__DBGpr_int ( "No. of components", nb_comps );
	__DBGpr_objlist ( "Component list", nb_comps, comp_list );
	
	comps_processed = FALSE;
	elem_rln       = VD_UNKNOWN;
	for ( jj=0; jj< nb_comps; jj++)
	{
		if ( elem_rln == VD_OVERLAP ) break;

		__DBGpr_int ( "Processing component no", jj);
		__DBGpr_obj ( "component id", comp_list[jj] );

		sts = om$get_classid (  osnum     = comp_list[jj].osnum,
					objid     = comp_list[jj].objid,
					p_classid = &elem_classid   );
		if ( !(sts&1) )
		{
		   printf("%s[%d] om$get_classid failed for object[%d,%d]\n",
				__FILE__, __LINE__,
				comp_list[jj].osnum, comp_list[jj].objid);
		   continue;
		}

		object_type = VD_UNKNOWN;
		if ( om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_EMSsolid_class_id ) ==
							OM_S_SUCCESS )
		{
			object_type = VD_SOLID;
		}
		else if ( om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_EMSsurface_class_id ) ==
							OM_S_SUCCESS )
		{
			object_type = VD_SURFACE;
		}
		else if ( om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_GRcurve_class_id ) ==
							OM_S_SUCCESS )
		{
			object_type = VD_CURVE;
			if ( om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_GRpoint_class_id ) ==
							OM_S_SUCCESS )
			object_type = VD_POINT;
		}
		else if ( om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_GRgencs_class_id ) ==
							OM_S_SUCCESS )
		{
			object_type = VD_CS;
		}

		if ( object_type == VD_UNKNOWN ) continue;


		comps_processed = TRUE;

		switch ( object_type )
		{
		  case VD_SOLID:
	  	  case VD_SURFACE:

		   sts  = VDsolid_surf_rln ( msg,
				      solid,
				      solid_env,
				      &comp_list[jj],
				      &elem_env,
				      &comp_rln );
		   VDS_ERR_CONTINUE ( "VDsolid_surf_rln", sts, *msg,VD_VERBOSE);
		   break;

		  case VD_CURVE:
		   sts = VDsolid_crv_rln (  msg,
				      solid,
				      solid_env,
				      &comp_list[jj],
				      &elem_env,
				      &comp_rln );
		   VDS_ERR_CONTINUE ( "VDsolid_crv_rln", sts, *msg,VD_VERBOSE );
		   break;

		 case VD_POINT:
		   sts = VDsolid_pt_rln ( msg,
				      solid,
				      solid_env,
				      &comp_list[jj],
				      &elem_env,
				      &comp_rln );
		   VDS_ERR_CONTINUE ( "VDsolid_pt_rln", sts, *msg, VD_VERBOSE );
		   break;

		 case VD_CS:
		   sts = VDsolid_cs_rln ( msg,
				      solid,
				      solid_env,
				      &comp_list[jj],
				      &elem_env,
				      &comp_rln );
		   VDS_ERR_CONTINUE ( "VDsolid_cs_rln", sts, *msg, VD_VERBOSE );
		   break;

		 default:
		   break;
		} /* switch ( object_type ) */

		__DBGpr_int("relation of component", comp_rln );

		if ( elem_rln == VD_OUTSIDE || elem_rln == VD_UNKNOWN )
		{
		   elem_rln = comp_rln;
		   continue;
		}

		if ( elem_rln == VD_INSIDE && comp_rln == VD_OVERLAP )
			elem_rln = VD_OVERLAP;
	} /*  for ( jj=0; jj< nb_comps; jj++) */

	if ( !comps_processed || elem_rln == VD_UNKNOWN )
	{
	   OMuword  vrplane_classid = (OMuword)(-1);

		sts = om$get_classid (  osnum     = elem_id.osnum,
					objid     = elem_id.objid,
					p_classid = &elem_classid   );
		if ( !(sts&1) )
		{
		   printf("%s[%d] om$get_classid failed for object[%d,%d]\n",
				__FILE__, __LINE__,
				elem_id.osnum, elem_id.objid);
		   continue;
		}

		sts = om$get_classid (	classname = "VRplane",
					p_classid = &vrplane_classid );

		if ( om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = OPP_GRreffile_class_id ) !=
							OM_S_SUCCESS &&
		     ( vrplane_classid == (OMuword)(-1) ||
		       om$is_ancestry_valid ( subclassid   = elem_classid,
				    superclassid = vrplane_classid ) !=
							OM_S_SUCCESS
		     )
		   )
		{
		   VD_InfoWarning( 1, &elem_id, NULL );
		}
		continue;
	}

#ifdef  VDS_DBG
	if ( elem_rln == VD_INSIDE )
	   printf("\tObject is INSIDE\n");
	else if ( elem_rln == VD_OVERLAP )
	   printf("\tObject is OVERLAPPING\n");
	else if ( elem_rln == VD_OUTSIDE )
	   printf("\tObject is OUTSIDE\n");
	else if ( elem_rln == VD_UNKNOWN )
	   printf("\tRelation of object UNKNOWN\n");
#endif

	switch ( elem_rln )
	{
	   case VD_UNKNOWN :
	   case VD_OUTSIDE :
		break;

	   case VD_INSIDE  :
	     if ( rln_needed == VD_EL_INSIDE ||
		  rln_needed == VD_EL_INSIDE_OVERLAP )
	     {
		if ( obj_list_out)  (*obj_list_out)[*num_obj_out] =
							obj_list_in[ii];
		(*num_obj_out)++;
	     }
	     break;

	   case VD_OVERLAP  :
	     if ( rln_needed == VD_EL_OVERLAP ||
		  rln_needed == VD_EL_INSIDE_OVERLAP )
	     {
		if ( obj_list_out)  (*obj_list_out)[*num_obj_out] =
							obj_list_in[ii];
		(*num_obj_out)++;
	     }
	     break;

	} /*      switch ( elem_rln ) */

   } /* for(ii=0; ii<num_obj_in; ii++) */

wrapup:
   if ( obj_list_out )
	*obj_list_out = (struct GRobj_env *)realloc( *obj_list_out,
				  sizeof(struct GRobj_env) * (*num_obj_out));

   __DBGpr_com("Exiting VDsolidFilter");
   return sts;

}

#endif

end implementation  Root;

