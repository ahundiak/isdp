/* $Id $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/pin_jig/VLklPlace.I
 *
 * Description: Key Lines Implementation.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/01/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "bserr.h"
#include "bsdotp.h"
#include "EMSmsgdef.h"
#include "VDobj.h"
#include "VDtypedef.h"
#include "VDefp.h"
#include "VDgeom.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vsgeommacros.h"
#include "vsplatedef.h"
#include "vlforkmacros.h"
#include "vlsband.h"
#include "vlkline.h"
#include "vldbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

#define NAM_KBJ_XORY	"Longitudinal"
#define NAM_KBJ_NAME	"SeamName"
#define NAM_KL_DIAGNAM  "Name"

extern GRclassid	OPP_VDdrwSet_class_id, OPP_SMSpltSrf_class_id,
			OPP_SMInfPlane_class_id, OPP_SMSfBnd_class_id,
			OPP_GR3dpoint_class_id;

extern OM_S_CHANSELECT	AS_to_comp;

from VDdrwSet	import	VDinitSet, VDaddObjectsToSet;
from SMInfPlane import	SMgive_rel_position;
from VLjunction import  VLreturn_graphic, ACget_named_attribute;

IGRlong         VSklGetPlateSeams( IGRlong              *msg,
                                   IGRint               num_pl,
                                   struct GRobj_env     *plates,
                                   IGRint               *count,
                                   struct GRobj_env     **list )
{
IGRlong                 sts;
IGRint                  i, nb_srf=0, tmp_count=0;
IGRboolean		not_first;
GRclassid               classids[2];
GRrange                 range, loc_range;
struct GRmd_env         loc_env;
struct GRobj_env        footOE, *children=NULL;

   SetProc( VSklGetPlateSeams ); Begin

   *count = 0;
   *list  = NULL;

   not_first = FALSE ;
   for( i=0; i<num_pl; i++ )
   {
      vdobj$GetFoot( objOE    = &plates[i],
                     footName = VS_K_plGrCmpName,
                     footOE   = &footOE );
      if( footOE.obj_id.objid == NULL_OBJID ) continue;

      vs$getRangeOfComposite( msg       = msg,
                              composite = &footOE,
                              range     = loc_range );
      if( not_first ) GRaccumulate_range( msg, loc_range, range );
      else
      {
          not_first = TRUE ;
          dblcpy( range, loc_range, 6 );
      }
   }
   __DBGpr_vec("Low Range point ", &range[0] );
   __DBGpr_vec("High Range point ", &range[3] );

   gr$get_module_env (buffer = &loc_env );
   classids[0] = OPP_SMSpltSrf_class_id ;
   classids[1] = OPP_SMSfBnd_class_id ;

   /* Function which will NOT LOCATE */
   VD_findall_objects_in_range( range, 2, classids,
                                TRUE, loc_env, &nb_srf, list );
   __DBGpr_int("Number Of Objects Found ", nb_srf );

   for( i=0; i<nb_srf; ++i )
   {
       tmp_count = 0;
	__DBGpr_obj( "Checking SMSpltSrf object", (*list)[i].obj_id );

       sts = VLgetPlatesThroughPretends( msg, &(*list)[i],
                                         &tmp_count, &children );
       __CheckRC( sts, *msg, "VLgetPlatesThroughPretends", wrapup );
	__DBGpr_int("tmp_count", tmp_count );
       if( tmp_count )
       {
	  __DBGpr_obj( "Plate", children[0].obj_id );
          children[0]._md_os = children[0]._osnum;
          sts = ex$get_modid( mod_osnum = children[0]._md_os,
                              mod_id    = &children[0]._md_id );
          (*list)[(*count)++] = (*list)[i];
       }
       _FREE( children );
   }

wrapup:
   _FREE( children );
   End
   return sts;
}

static IGRint  VLsortKLPtJunction( struct GRid   *obj1,
				   struct GRid   *obj2 )
{
IGRlong			sts, msg;
IGRint			row1, row2, col1, col2;
struct ACrg_coll	attrib;

   strcpy( attrib.name, NAM_KPJ_ROW );
   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                &msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = obj1->objid,
                   targetos = obj1->osnum  );
   row1 = attrib.desc.value.att_exp;

   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                &msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = obj2->objid,
                   targetos = obj2->osnum  );
   row2 = attrib.desc.value.att_exp;

   strcpy( attrib.name, NAM_KPJ_COL );
   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                &msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = obj1->objid,
                   targetos = obj1->osnum  );
   col1 = attrib.desc.value.att_exp;

   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                &msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = obj2->objid,
                   targetos = obj2->osnum  );
   col2 = attrib.desc.value.att_exp;

   if( col1 == col2 )
   {
	if( row1 == row2 ) return  0;
	if( row1 <  row2 ) return -1;
	else		   return  1;
   }
   else if( col1 < col2 )	return -1;
   else				return  1;
}

static IGRint  VLsortKLJunction( struct GRid   *obj1,
                                 struct GRid   *obj2 )
{
BSrc			rc;
IGRlong                 sts, msg;
IGRdouble		dir1, dir2;
IGRpoint		spt1, spt2, ept;
IGRvector		axis, vector;
struct ACrg_coll	attrib;
struct GRobj_env	crv1, crv2;

   axis[0] =axis[1] =axis[2] = 0.0;
   strcpy( attrib.name, NAM_KBJ_XORY );
   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                &msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = obj1->objid,
                   targetos = obj1->osnum  );
   dir1 = attrib.desc.value.att_exp;

   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                &msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = obj2->objid,
                   targetos = obj2->osnum  );
   dir2 = attrib.desc.value.att_exp;

   if( dir1 == dir2 )
   {
	if( dir1 == 0.0 )	axis[0] = 1.0;
	else			axis[1] = 1.0;

	sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
					&msg, NULL, &crv1 ),
                   senderid = NULL_OBJID,
                   targetid = obj1->objid,
                   targetos = obj1->osnum  );
	VLendpts( &msg, &crv1.obj_id, &crv1.mod_env, spt1, ept );

        sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                        &msg, NULL, &crv2 ),
                   senderid = NULL_OBJID,
                   targetid = obj2->objid,
                   targetos = obj2->osnum  );
        VLendpts( &msg, &crv2.obj_id, &crv2.mod_env, spt2, ept );
        VLvector( &msg, spt1, spt2, 1.0, 1.0, TRUE, vector );

   	if( BSdotp( &rc, axis, vector )  < 0.0 )      return  1;
   	else                                          return -1;
   }
   else if( dir1 < dir2 )	return -1;
   else				return  1;
}

IGRlong VLcreateKLJunction( IGRlong                *msg,
			    struct GRid		   *line,
		   	    struct GRmd_env	   *env,
			    IGRchar		   *name,
			    struct GRid		   *junction )
{
BSrc			rc;
IGRlong			sts;
IGRint			nb_pb_attr=0;
IGRdouble		dir;
IGRuchar                weight=1;
IGRpoint		spt, ept;
IGRvector		vec, x_vec, y_vec;
struct ACrg_coll	attrib[2];
struct GRobj_env	gr_obj;

   *msg = MSSUCC;

   x_vec[0] = y_vec[1] = 1.0 ;
   x_vec[1] = x_vec[2] = y_vec[0] = y_vec[2] = 0.0;

   gr_obj.obj_id  = *line;
   gr_obj.mod_env = *env;

   sts = om$send(  msg      = message GRvg.GRchgweight( msg,
                                                        &weight ),
                        senderid = NULL_OBJID,
                        targetid = line->objid,
                        targetos = line->osnum );

   sts = VLendpts( msg, line, env, spt, ept );
   __CheckRC( sts, *msg, "VLendpts", wrapup );

   sts = VLvector( msg, spt, ept, 1.0, 1.0, TRUE, vec );
   __CheckRC( sts, *msg, "VLvector", wrapup );

   if( fabs( BSdotp( &rc, vec, x_vec ) )  < 0.5 )	dir = 0 ;
   else							dir = 1 ;

   strcpy( attrib[nb_pb_attr].name, NAM_KBJ_XORY );
   attrib[nb_pb_attr].desc.type = AC_ATTRIB_DOUBLE;
   attrib[nb_pb_attr].desc.value.att_exp = dir;
   nb_pb_attr++;

   strcpy( attrib[nb_pb_attr].name, NAM_KBJ_NAME );
   attrib[nb_pb_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy( attrib[nb_pb_attr].desc.value.att_txt, name );
   nb_pb_attr++;

   sts = vl$createLoftFork (    msg     = msg,
                                graphic = &gr_obj,
                                attr    = attrib,
                                number  = nb_pb_attr,
                                Env     = &gr_obj.mod_env,
                                forkId  = junction );

wrapup:
   return sts;
}

static IGRlong VLcreateKLDiagJunction( 	IGRlong                 *msg,
                                   	struct GRid             *line,
                                   	struct GRmd_env         *env,
                                   	IGRchar                 *name,
                                   	struct GRid             *junction )
{
IGRlong			sts;
IGRint			nb_pb_attr=0;
struct ACrg_coll        attrib[1];
struct GRobj_env        gr_obj;

   *msg = MSSUCC;

   gr_obj.obj_id  = *line;
   gr_obj.mod_env = *env;

   strcpy( attrib[nb_pb_attr].name, NAM_KL_DIAGNAM );
   attrib[nb_pb_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy( attrib[nb_pb_attr].desc.value.att_txt, name );
   nb_pb_attr++;

   sts = vl$createLoftFork (    msg     = msg,
                                graphic = &gr_obj,
                                attr    = attrib,
                                number  = nb_pb_attr,
                                Env     = &gr_obj.mod_env,
                                forkId  = junction );

wrapup:
   return sts;
}

static IGRlong	VLcreateKLPtJunction( IGRlong                 *msg,
				      struct GRid	      line1,
				      struct GRid             line2,
				      IGRpoint		      key_pt1,
				      IGRpoint		      key_pt2,
				      struct IGRbsp_curve     *crv1_geom,
				      struct IGRbsp_curve     *crv2_geom,
				      IGRdouble		      long_dist,
				      IGRdouble               trans_dist,
				      IGRpoint                pt,
				      IGRint		      col,
				      IGRint		      row,
				      struct GRvg_construct   *cst,
				      struct GRid	      *pt_junction )
{
BSrc			rc;
IGRlong			sts;
IGRint			nb_pt_attr=0;
IGRuchar                weight=8;
IGRboolean		status;
IGRdouble		dir, arc_len=0.0, tol=0.00001, par[2], mid_par;
IGRpoint                long_pt, trans_pt, proj_pt;
struct ACrg_coll	attrib, pt_attrib[6];
struct GRid		long_line, trans_line;
struct GRobj_env	gr_obj;
struct IGRbsp_curve	*long_geom, *trans_geom;
struct IGRpolyline	pt_poly;

   strcpy( attrib.name, NAM_KBJ_XORY );
   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = line1.objid,
                   targetos = line1.osnum  );
   dir = attrib.desc.value.att_exp;

   if( dir == 1.0 ) 
   { 
     long_line  = line1; 
     trans_line = line2; 
     long_geom  = crv1_geom;
     trans_geom = crv2_geom;
     dblcpy( long_pt,  key_pt1, 3 ); 
     dblcpy( trans_pt, key_pt2, 3 );
   }
   else
   {
     long_line  = line2;
     trans_line = line1;
     long_geom  = crv2_geom;
     trans_geom = crv1_geom;
     dblcpy( long_pt,  key_pt2, 3 );
     dblcpy( trans_pt, key_pt1, 3 );
   }

   nb_pt_attr = 0;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_COL );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_DOUBLE;
   pt_attrib[nb_pt_attr].desc.value.att_exp = col;
   nb_pt_attr++;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_ROW );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_DOUBLE;
   pt_attrib[nb_pt_attr].desc.value.att_exp = row;
   nb_pt_attr++;

   strcpy( attrib.name, NAM_KBJ_NAME );
   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = long_line.objid,
                   targetos = long_line.osnum  );

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_LNAM );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy( pt_attrib[nb_pt_attr].desc.value.att_txt, 
			 attrib.desc.value.att_txt );
   nb_pt_attr++;

   if( MAptbcproj( msg, long_pt, long_geom, &tol, proj_pt, &par[0] ) )
   {
	if( MAptbcproj( msg, pt, long_geom, &tol, proj_pt, &par[1] ) )
	{
	    mid_par = ( par[0] + par[1] ) / 2.0 ;
	    BSarclen( &rc, &status, long_geom, &par[0], &par[1], 
		      &mid_par, &arc_len  );
	}
	else arc_len = 0.0;
   }
   else arc_len = 0.0;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_LDIST );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_DOUBLE;
   pt_attrib[nb_pt_attr].desc.value.att_exp = arc_len + long_dist;
   nb_pt_attr++;

   strcpy( attrib.name, NAM_KBJ_NAME );
   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = trans_line.objid,
                   targetos = trans_line.osnum  );

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_TNAM );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_TEXT;
   strcpy( pt_attrib[nb_pt_attr].desc.value.att_txt,
                         attrib.desc.value.att_txt );
   nb_pt_attr++;

   if( MAptbcproj( msg, trans_pt, trans_geom, &tol, proj_pt, &par[0] ) )
   {
        if( MAptbcproj( msg, pt, trans_geom, &tol, proj_pt, &par[1] ) )
        {
            mid_par = ( par[0] + par[1] ) / 2.0 ;
            BSarclen( &rc, &status, trans_geom, &par[0], &par[1],
                      &mid_par, &arc_len  );
        }
        else arc_len = 0.0;
   }
   else arc_len = 0.0;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_TDIST );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_DOUBLE;
   pt_attrib[nb_pt_attr].desc.value.att_exp = arc_len + trans_dist ;
   nb_pt_attr++;

   gr_obj._objid  = NULL_OBJID;
   gr_obj._osnum  = cst->env_info->md_id.osnum;
   gr_obj.mod_env = *(cst->env_info );

   pt_poly.num_points  = 1;
   pt_poly.points      = pt;
   cst->geometry        = (IGRchar *) &pt_poly;
   sts = om$construct(	classid = OPP_GR3dpoint_class_id,
			osnum	= gr_obj._osnum,
			p_objid = &gr_obj._objid,
			msg	= message GRgraphics.GRaltconstruct( cst ) );	
   cst->geometry = NULL;

   sts = om$send(  msg      = message GRvg.GRchgweight( msg,
                                                        &weight ),
                        senderid = NULL_OBJID,
                        targetid = gr_obj._objid,
                        targetos = gr_obj._osnum );

   sts = vl$createLoftFork (    msg     = msg,
                                graphic = &gr_obj,
                                attr    = pt_attrib,
                                number  = nb_pt_attr,
                                Env     = &gr_obj.mod_env,
                                forkId  = pt_junction );

wrapup:
   return sts;
} 

static IGRlong	VLklCreateKeyJunction( struct IGRbsp_curve      *key_geom,
				       IGRdouble	   	*pt,
				       IGRdouble		*inter_key,
				       IGRint			is_long,
				       struct GRid		mold_line,
				       IGRint			col,
				       IGRint			row,
				       struct GRvg_construct	*cst,
				       struct GRid	   	*pt_junction )
{
BSrc			rc;
IGRlong			sts, msg;
IGRint			nb_pt_attr;
IGRboolean		status;
IGRdouble		arc_len=0.0, tol=0.0, mid_par, par[2];
IGRuchar                weight=8;
IGRpoint		proj_pt;
struct GRobj_env	gr_obj;
struct IGRpolyline	pt_poly;
struct ACrg_coll	attrib, pt_attrib[6];

   strcpy( attrib.name, NAM_KBJ_NAME );
   sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                &msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = mold_line.objid,
                   targetos = mold_line.osnum  );

   if( MAptbcproj( &msg, inter_key, key_geom, &tol, proj_pt, &par[0] ) )
   {
        if( MAptbcproj( &msg, pt, key_geom, &tol, proj_pt, &par[1] ) )
        {
            mid_par = ( par[0] + par[1] ) / 2.0 ;
            BSarclen( &rc, &status, key_geom, &par[0], &par[1],
                      &mid_par, &arc_len  );
        }
        else arc_len = 0.0;
   }
   else arc_len = 0.0;

   nb_pt_attr=0;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_COL );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_DOUBLE;
   pt_attrib[nb_pt_attr].desc.value.att_exp = col;
   nb_pt_attr++;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_ROW );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_DOUBLE;
   pt_attrib[nb_pt_attr].desc.value.att_exp = row;
   nb_pt_attr++;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_LNAM );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_TEXT;
   if( is_long ) 
	strcpy( pt_attrib[nb_pt_attr].desc.value.att_txt, NAM_KL_KLIN );
   else
        strcpy( pt_attrib[nb_pt_attr].desc.value.att_txt, 
					attrib.desc.value.att_txt );
   nb_pt_attr++;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_LDIST );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_DOUBLE;
   if( is_long ) pt_attrib[nb_pt_attr].desc.value.att_exp = arc_len ;
   else		 pt_attrib[nb_pt_attr].desc.value.att_exp = 0.0;
   nb_pt_attr++;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_TNAM );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_TEXT;
   if( is_long )
        strcpy( pt_attrib[nb_pt_attr].desc.value.att_txt, 
					attrib.desc.value.att_txt );
   else
        strcpy( pt_attrib[nb_pt_attr].desc.value.att_txt, NAM_KL_FRLN );
   nb_pt_attr++;

   strcpy( pt_attrib[nb_pt_attr].name, NAM_KPJ_TDIST );
   pt_attrib[nb_pt_attr].desc.type = AC_ATTRIB_DOUBLE;
   if( is_long ) pt_attrib[nb_pt_attr].desc.value.att_exp = 0.0 ;
   else          pt_attrib[nb_pt_attr].desc.value.att_exp = arc_len ;
   nb_pt_attr++;

   gr_obj._objid  = NULL_OBJID;
   gr_obj._osnum  = cst->env_info->md_id.osnum;
   gr_obj.mod_env = *(cst->env_info );

   pt_poly.num_points  = 1;
   pt_poly.points      = pt;
   cst->geometry        = (IGRchar *) &pt_poly;
   sts = om$construct(  classid = OPP_GR3dpoint_class_id,
                        osnum   = gr_obj._osnum,
                        p_objid = &gr_obj._objid,
                        msg     = message GRgraphics.GRaltconstruct( cst ) );
   cst->geometry = NULL;

   sts = om$send(  msg      = message GRvg.GRchgweight( &msg,
                                                        &weight ),
                        senderid = NULL_OBJID,
                        targetid = gr_obj._objid,
                        targetos = gr_obj._osnum );

   sts = vl$createLoftFork (    msg     = &msg,
                                graphic = &gr_obj,
                                attr    = pt_attrib,
                                number  = nb_pt_attr,
                                Env     = &gr_obj.mod_env,
                                forkId  = pt_junction );
}

static IGRlong	VLklGetDeltaDist(  IGRint		   count,
				   struct GRid             *list,
				   struct GRobj_env        *crv,
				   struct IGRbsp_curve	   *key_geom,
				   IGRdouble		   inp_dist,
				   IGRdouble		   *dist )
{
BSrc			rc;
IGRlong			sts, msg;
IGRint			i, nmdi=0;
IGRboolean		status;
IGRdouble               min_dist=0.0, mid_par, par[2], tol=0.0001,
			*line_pa=NULL, *test_pa=NULL;
IGRpoint                spt1, ept1, spt2, ept2, pt, proj_pt,
			*line_pt=NULL, *test_pt=NULL;
struct GRobj_env	jn_crv;
struct IGRbsp_curve	*crv_geom=NULL;

   *dist = inp_dist;

   sts = VLendpts( &msg, &crv->obj_id, &crv->mod_env, spt1, ept1 );
   __CheckRC( sts, msg, "VLendpts: Edge ", wrapup );

   for( i=0; i<count; ++i )
   {
       sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                        &msg, NULL, &jn_crv ),
                   senderid = NULL_OBJID,
                   targetid = list[i].objid,
                   targetos = list[i].osnum  );
       if( crv->_objid == jn_crv._objid ) continue;

       sts = VLendpts( &msg, &jn_crv.obj_id, &jn_crv.mod_env, spt2, ept2 );
       if( !(sts&1&msg) ) continue;

       if( VLsame_point( spt1, spt2, 0.1 ) ) 	      dblcpy( pt, spt1, 3 );
       else if( VLsame_point( spt1, ept2, 0.1 ) )   dblcpy( pt, spt1, 3 );
       else if( VLsame_point( ept1, spt2, 0.1 ) )   dblcpy( pt, spt2, 3 );
       else if( VLsame_point( ept1, ept2, 0.1 ) )   dblcpy( pt, spt2, 3 );
       else continue;
      
       sts = vs$get_geometry(  msg      = &msg,
			       grobjId  = &jn_crv.obj_id,
			       grobjEnv = &jn_crv.mod_env,
			       geometry = &crv_geom );
       __CheckRC( sts, msg, "vs$get_geometry", wrapup ) ;
       BSmdistcvcv( key_geom, crv_geom, &nmdi, &line_pa, &test_pa,
                    &line_pt, &test_pt, &min_dist, &rc );
       if( min_dist < 0.1 )
       {
	  if( MAptbcproj( &msg, pt, crv_geom, &tol, proj_pt, &par[0] ) )
	  {
	      if( MAptbcproj( &msg, test_pt[0], crv_geom, 
			     &tol, proj_pt, &par[1] ) )
	      {
		mid_par = ( par[0] + par[1] ) /  2.0 ;
                BSarclen( &rc, &status, crv_geom, &par[0], &par[1],
                      &mid_par, dist  );
	      }
	  }
       }
       break;
   }

wrapup:
   _FREE( line_pa   );
   _FREE( test_pa   );
   _FREE( line_pt   );
   _FREE( test_pt   );
   _FREE( crv_geom  );
   return sts;
}
				   

IGRlong	VLklGetIntersectionLines(  IGRlong                 *msg,
				   IGRint		   num_pl,
				   struct GRobj_env	   *plates,
				   struct GRid             *key_lines,
				   IGRint		   *count,
				   struct GRid		   *pt_list )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, j, srf_count=0, num_parents=0, loc_cnt=0,
			nb_prj=0, nmdi=0, *key_ind=NULL, is_long, loc_pt_cnt=0,
			row_cnt, col_cnt, *row=NULL, *col=NULL, 
			key1_ind=-1, key2_ind=-1, same_dir=0, neatCnt=0,
			edgeCnt=0, num_bnd_edges=0, *edge_dir=NULL;
IGRdouble		dir1=0.0, dir2=0.0, dist, *line_pa=NULL, *test_pa=NULL,
			long_dist=0.0, trans_dist=0.0, tol=0.0, tmp_dir;
IGRchar			sf_name[128], status_msg[128], jn_name[128], *p=NULL;
IGRvector		vector;
IGRpoint        	spt1, spt2, ept1, ept2, inter_key, 
			*line_pt=NULL, *test_pt=NULL, *key_pt=NULL;
OM_S_OBJID		*prj_list=NULL;
struct ACrg_coll	attrib;
struct GRid		templateID, ptId, inter, pt_jn, loc_pt[100], *list=NULL;
struct GRobj_env	*srf_list=NULL, *bnd_edges=NULL, crv1, crv2, crv3;
struct GRvg_construct   cst;
struct IGRbsp_curve	*crv1_geom=NULL, *crv2_geom=NULL, *crv3_geom=NULL,
			**realEdgeGeom=NULL, *neatGeom[VDEFP_NEAT_EDGES_MAX],
			**edgeGeom=NULL;

   SetProc( VLklGetIntersectionLines ); Begin

   if( !msg || !num_pl || !plates || !count || !pt_list )  return OM_E_INVARG;

   *count = 0;
   VLinitCnst( &cst );

   sts = VSklGetPlateSeams( msg, num_pl, plates, &srf_count, &srf_list );
   __DBGpr_int("Number of Surfaces Returned ", srf_count );

   if( !( list = _MALLOC( srf_count+20, struct GRid ) ) ) vd_$mem_fail() ;

   for( i=0; i<srf_count; ++i )
   {
       sprintf(status_msg, "Generating Seams ... %d / %d", i+1, srf_count );
       UI_status( status_msg );

       __DBGpr_int("Checking ", i );
       nb_prj=0;
       _FREE( prj_list );
       p = NULL;
/*
       vdobj$Get  (objOE = &srf_list[i], objName = sf_name );
       VDstrupr( sf_name );
       p = strrchr( sf_name, ':' );
       if( p )  strcpy( sf_name, p+1 );
       __DBGpr_str("Key Line Name ", sf_name );
	
       for( j=0; j<strlen(sf_name); ++j ) if( isdigit(sf_name[j]) ) break;
       if( j == strlen(sf_name) ) continue;
*/

       sts = VLcreateMultipleInter( msg, num_pl, plates, VS_K_plBotSfPath, 
				&srf_list[i], &cst, 1, &inter );
       if( !(sts&(*msg)&1) || (inter.objid == NULL_OBJID) ) continue;
       __DBGpr_obj("Intersection Object ", inter );

       sts = VLcreateKLJunction( msg, &inter, cst.env_info,
                                 sf_name, &list[loc_cnt] );
       __DBGpr_obj("Junction Object ", list[loc_cnt] );
       if( (*msg)&1 )     loc_cnt++;
       else               goto del_inter;

       continue;

del_inter:
       sts = om$send(  msg = message GRgraphics.GRdelete( msg,
                                          cst.env_info ),
                        senderid = NULL_OBJID,
                        targetid = inter.objid,
                        targetos = inter.osnum  );
   }

   sts = VSgetExternalContour( msg, num_pl, plates, cst.env_info,
            VS_K_plBotSfPath, &num_bnd_edges, &bnd_edges, NULL, &edge_dir );
   __CheckRC( sts, *msg, "VSgetExternalContour", wrapup );

   for( i=0; i<num_bnd_edges; ++i )
   {
       if( edge_dir[i] == AFT )		strcpy( jn_name, "AFT EJ" );
       else if( edge_dir[i] == FWD )	strcpy( jn_name, "FWD EJ" );
       else if( edge_dir[i] == IB  )	strcpy( jn_name, "IB EJ" );
       else if( edge_dir[i] == OB  )    strcpy( jn_name, "OB EJ" );
       else if( edge_dir[i] == UPP )	strcpy( jn_name, "UP EJ" );
       else if( edge_dir[i] == DWN )    strcpy( jn_name, "DOWN EJ" ); 
       sts = VLcreateKLJunction( msg, &bnd_edges[i].obj_id, 
			&bnd_edges[i].mod_env, jn_name, &list[loc_cnt] );
       __DBGpr_obj("Junction Object ", list[loc_cnt] );
       loc_cnt++;
   }

   if( !loc_cnt )	{ *count = 0; 	goto wrapup; }

   for( i=0; i<num_pl; ++i )
      VLklGetStructuralLines( msg, &plates[i], &loc_cnt, &list );

   qsort(list, loc_cnt, sizeof(struct GRid), (int (*)())VLsortKLJunction);

   if( !( key_pt  = _MALLOC( loc_cnt, IGRpoint ) ) ) vd_$mem_fail() ;
   if( !( key_ind = _MALLOC( loc_cnt, IGRint   ) ) ) vd_$mem_fail() ;
   if( !( row     = _CALLOC( loc_cnt, IGRint   ) ) ) vd_$mem_fail() ;
   if( !( col     = _CALLOC( loc_cnt, IGRint   ) ) ) vd_$mem_fail() ;

   row_cnt = 0;
   col_cnt = 0;
   tmp_dir = 1.0;
   for( i=0; i<loc_cnt; ++i )
   {
       same_dir = 0;
       strcpy( attrib.name, NAM_KBJ_XORY );
       sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = list[i].objid,
                   targetos = list[i].osnum  );
       dir1 = attrib.desc.value.att_exp;

       sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                        msg, NULL, &crv1 ),
                   senderid = NULL_OBJID,
                   targetid = list[i].objid,
                   targetos = list[i].osnum  );
       if( !(sts&1&(*msg)) ) continue;

       sts = VLendpts( msg, &crv1.obj_id, &crv1.mod_env, spt1, ept1 );
       if( !(sts&1&(*msg)) ) continue;

       if( tmp_dir == dir1 )
       {
           sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = list[i].objid,
                   targetos = list[i].osnum  );
           dir2 = attrib.desc.value.att_exp;
	   if( dir1 == dir2 )
	   {
              sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                        msg, NULL, &crv2 ),
                   senderid = NULL_OBJID,
                   targetid = list[i-1].objid,
                   targetos = list[i-1].osnum  );
              if( !(sts&1&(*msg)) ) continue;

              sts = VLendpts( msg, &crv2.obj_id, &crv2.mod_env, spt2, ept2 );
              if( !(sts&1&(*msg)) ) continue;

              if( VLsame_point( spt1, spt2, 0.1 ) ||
	          VLsame_point( spt1, ept2, 0.1 ) ||
	          VLsame_point( ept1, spt2, 0.1 ) ||
	          VLsame_point( ept1, ept2, 0.1 ) )    same_dir = 1;
	   }
       }
       else	tmp_dir =  dir1;

       if( dir1 == 0.0 ) 
       {
	  sts = VLendpts( msg, &key_lines[0], cst.env_info, spt2, ept2 );
	  if( ( key1_ind == -1 ) && ( spt1[0] > spt2[0] ) )	
	  {
	      key1_ind = col_cnt;
	      col_cnt++;
          }
	  if( !same_dir ) { col[i] = col_cnt;   col_cnt++;	}
	  else		  { col[i] = col[i-1] ; 		}
       }
       else
       {
	  sts = VLendpts( msg, &key_lines[1], cst.env_info, spt2, ept2 );
	  if( ( key2_ind == -1 ) && ( spt1[1] > spt2[1] ) )
	  {
	       key2_ind = row_cnt;
	       row_cnt++;
	  }
	  if( !same_dir ) { row[i] = row_cnt; 	row_cnt++; }
	  else		  { row[i] = row[i-1] ;            }
       }
   }

   for( i=0; i<loc_cnt; ++i )
   {
       key_ind[i] = 0;
       for( j=0; j<3; ++j )	key_pt[i][j] = 0.0 ;
   }

   sts = vs$get_geometry(  msg      = msg,
                           grobjId  = &key_lines[0],
                           grobjEnv = cst.env_info,
                           geometry = &crv1_geom );
   __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

   sts = vs$get_geometry(  msg      = msg,
                           grobjId  = &key_lines[1],
                           grobjEnv = cst.env_info,
                           geometry = &crv2_geom );
   __CheckRC( sts, *msg, "vs$get_geometry", wrapup ) ;

   BSmdistcvcv( crv1_geom, crv2_geom, &nmdi, &line_pa, &test_pa,
                &line_pt, &test_pt, &dist, &rc );

   dblcpy( inter_key, line_pt[0], 3 );
   __DBGpr_vec("Intersection point of two key lines ", inter_key );

   UI_status("Generating Intersection Points..." );
   for( i=0; i<loc_cnt; ++i )
   {
       nmdi = 0;
       dist = 0.0;
       _FREE( line_pa   );
       _FREE( test_pa   );
       _FREE( line_pt   );
       _FREE( test_pt   );
       _FREE( crv1_geom );
       _FREE( crv2_geom );
       _FREE( crv3_geom );

       strcpy( attrib.name, NAM_KBJ_XORY );
       sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = list[i].objid,
                   targetos = list[i].osnum  );
       if( !(sts&1&(*msg)) ) continue;
       dir1 = attrib.desc.value.att_exp;
       if( dir1 == 1.0 ) continue;

       trans_dist = 0.0;
       sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                        msg, NULL, &crv1 ),
                   senderid = NULL_OBJID,
                   targetid = list[i].objid,
                   targetos = list[i].osnum  );
       if( !(sts&1&(*msg)) ) continue;

       sts = VLgetGeometry( &crv1, FALSE, NULL_OBJID,
                        (IGRchar **)&crv1_geom, msg );
       if( !(sts&1&(*msg)) ) continue;

       if( key_ind[i] == 0 )
       {
           if( dir1 == 0.0 )
           {
	       crv2.obj_id  = key_lines[1];
	       crv2.mod_env = *(cst.env_info);
	       is_long = 1;
           }
           else
           {
               crv2.obj_id  = key_lines[0];
               crv2.mod_env = *(cst.env_info);
	       is_long = 0;
           }

           sts = VLgetGeometry(  &crv2, FALSE, NULL_OBJID,
                             (IGRchar **)&crv2_geom, msg );
           if( !(sts&1&(*msg)) ) continue;

           BSmdistcvcv( crv1_geom, crv2_geom, &nmdi, &line_pa, &test_pa,
                    &line_pt, &test_pt, &dist, &rc );
           if( ( rc != BSSUCC ) || !nmdi ) continue;
	   if( dist > 0.1 ) 
           {
	      VLklGetDeltaDist( loc_cnt, list, &crv1, crv2_geom,
				dist, &trans_dist );
           }

	   dblcpy( key_pt[i], test_pt[0], 3 );

	   VLklCreateKeyJunction( crv2_geom, key_pt[i], inter_key, is_long,
		   list[i], col[i]+1, key2_ind+1, &cst, &loc_pt[loc_pt_cnt] );
	   loc_pt_cnt++;
	   key_ind[i] = 1;
       }

       for( j=i+1; j<loc_cnt; ++j )
       {
	  nmdi = 0;
	  dist = 0.0;
	  _FREE( line_pa   );
	  _FREE( test_pa   );
	  _FREE( line_pt   );
	  _FREE( test_pt   );
 	  _FREE( crv2_geom );
	  _FREE( crv3_geom );

	  if( i == j ) continue;
	  long_dist = 0.0;
	  sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = list[j].objid,
                   targetos = list[j].osnum  );
	  if( !(sts&1&(*msg)) ) continue;
          dir2 = attrib.desc.value.att_exp;
	  if( dir1 == dir2 ) continue;

          sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                        msg, NULL, &crv2 ),
                   senderid = NULL_OBJID,
                   targetid = list[j].objid,
                   targetos = list[j].osnum  );
          if( !(sts&1&(*msg)) ) continue;

          sts = VLgetGeometry( &crv2, FALSE, NULL_OBJID,
                        (IGRchar **)&crv2_geom, msg );
          if( !(sts&1&(*msg)) ) continue;

          if( key_ind[j] == 0 )
          {
             if( dir2 == 0.0 )
             {
                 crv3.obj_id  = key_lines[1];
                 crv3.mod_env = *(cst.env_info);
		 is_long = 1;
             }
             else
             {
                 crv3.obj_id  = key_lines[0];
                 crv3.mod_env = *(cst.env_info);
		 is_long = 0;
	     }
             sts = VLgetGeometry(  &crv3, FALSE, NULL_OBJID,
                                   (IGRchar **)&crv3_geom, msg );
             if( !(sts&1&(*msg)) ) continue;

             BSmdistcvcv( crv2_geom, crv3_geom, &nmdi, &line_pa, &test_pa,
                    &line_pt, &test_pt, &dist, &rc );
             if( ( rc != BSSUCC ) || !nmdi ) continue;
             if( dist > 0.1 )
             {
                 VLklGetDeltaDist( loc_cnt, list, &crv2, 
				   crv3_geom, dist, &long_dist );
             }

             dblcpy( key_pt[j], test_pt[0], 3 );
             VLklCreateKeyJunction( crv3_geom, key_pt[j], inter_key, is_long,
                   list[j], key1_ind+1, row[j]+1, &cst, &loc_pt[loc_pt_cnt] );
	     loc_pt_cnt++;
	     key_ind[j] = 1;
          }
          nmdi = 0;
          dist = 0.0;
          _FREE( line_pa   );
          _FREE( test_pa   );
          _FREE( line_pt   );
          _FREE( test_pt   );
	  _FREE( crv3_geom );

	  BSmdistcvcv( crv1_geom, crv2_geom, &nmdi, &line_pa, &test_pa,
                              &line_pt, &test_pt, &dist, &rc );
	  if( ( rc != BSSUCC ) || !nmdi ||  ( dist > 0.1 ) ) continue;

	  VLcreateKLPtJunction( msg, list[i], list[j], key_pt[i],
	   	key_pt[j], crv1_geom, crv2_geom, long_dist, trans_dist,
		(IGRdouble *)line_pt, col[i]+1, row[j]+1, 
		&cst, &loc_pt[loc_pt_cnt] );
	  loc_pt_cnt++;
       }
   }

   qsort( &loc_pt[0], loc_pt_cnt, sizeof(struct GRid), 
	  (int (*)())VLsortKLPtJunction );

   for( i=0; i<loc_pt_cnt; ++i )   pt_list[i] = loc_pt[i] ;
   *count = loc_pt_cnt;

wrapup:
   UI_status( "" );
   for( i=0; i<loc_cnt; ++i )
   {
       sts = om$send(  msg = message GRgraphics.GRdelete( msg,
                                          cst.env_info ),
                        senderid = NULL_OBJID,
                        targetid = list[i].objid,
                        targetos = list[i].osnum  );
   }

   for( i=0; i<neatCnt; ++i )   _FREE( neatGeom[i] );

   if( realEdgeGeom )
   {
       for(i=0; i<edgeCnt; i++ )
       {
           if( realEdgeGeom[i] )
           {
               BSfreecv( msg, realEdgeGeom[i] );
               realEdgeGeom[i] = NULL ;
           }
       }
   }

   _FREE( key_pt    );
   _FREE( key_ind   );
   _FREE( row       );
   _FREE( col       );
   _FREE( list      );
   _FREE( line_pa   );
   _FREE( test_pa   );
   _FREE( line_pt   );
   _FREE( test_pt   );
   _FREE( crv1_geom );
   _FREE( crv2_geom );
   _FREE( crv3_geom );
   _FREE( srf_list  );
   _FREE( bnd_edges );
   _FREE( edge_dir  );
   End
   return sts;
}


static IGRlong	VLklFillDirPts(    IGRlong                 *msg,
                                   IGRint                  num_bnd_edges,
                                   struct GRobj_env        *bnd_edges,
				   IGRint                  *edge_dir,
				   struct GRid		   *key_line,
				   struct GRvg_construct   *cst,
				   IGRint		   dir1,
				   IGRint		   dir2,
				   IGRdouble		   *points )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, dir, index, prev_ind, next_ind, valid_ind, nmdi=0;
IGRdouble		min_dist=0.0, *line_pa=NULL, *test_pa=NULL;
IGRpoint		spt1, ept1, spt2, ept2, *line_pt=NULL, *test_pt=NULL;
struct IGRbsp_curve	*key_geom=NULL, *crv_geom=NULL;

   sts = *msg = MSSUCC;

   sts = vs$get_geometry(  msg      = msg,
			   grobjId  = key_line,
			   grobjEnv = cst->env_info,
			   geometry = &key_geom );
   __CheckRC( sts, *msg, "vs$get_geometry: KeyLine", wrapup ) ;

   for( i=0; i<num_bnd_edges; ++i )
   {
      if( edge_dir[i] == dir1 ) 
      {
          sts = vs$get_geometry(  msg      = msg,
                                  grobjId  = &bnd_edges[i].obj_id,
                                  grobjEnv = &bnd_edges[i].mod_env,
                                  geometry = &crv_geom );
          __CheckRC( sts, *msg, "vs$get_geometry: Edges", wrapup ) ;

          BSmdistcvcv( key_geom, crv_geom, &nmdi, &line_pa, &test_pa,
                       &line_pt, &test_pt, &min_dist, &rc );
	  __DBGpr_dbl("Minimum Distance ", min_dist );

          if( min_dist < 0.1 )
          {
	     dblcpy( &points[3], line_pt[0], 3 );
	     index = i ;
	     break;
	  }
          _FREE( line_pa   );
          _FREE( test_pa   );
          _FREE( line_pt   );
          _FREE( test_pt   );
          _FREE( crv_geom  );
      }
   }

   if( i == num_bnd_edges )
   {
       if( dir1 == IB )         dir = DWN;
       else if( dir1 == OB )    dir = UPP;
       else if( dir1 == DWN )   dir = IB;
       else if( dir1 == UPP )   dir = OB;
       else { sts = MSFAIL; goto wrapup; }

       for( i=0; i<num_bnd_edges; ++i )
       {
      	   if( edge_dir[i] == dir )
           {
               sts = vs$get_geometry(  msg      = msg,
                                       grobjId  = &bnd_edges[i].obj_id,
                                       grobjEnv = &bnd_edges[i].mod_env,
                                       geometry = &crv_geom );
               __CheckRC( sts, *msg, "vs$get_geometry: Edges", wrapup ) ;

               BSmdistcvcv( key_geom, crv_geom, &nmdi, &line_pa, &test_pa,
                            &line_pt, &test_pt, &min_dist, &rc );
               __DBGpr_dbl("Minimum Distance ", min_dist );

               if( min_dist < 0.1 )
               {
                 dblcpy( &points[3], line_pt[0], 3 );
          	 index = i ;
          	 break;
               }
               _FREE( line_pa   );
               _FREE( test_pa   );
               _FREE( line_pt   );
               _FREE( test_pt   );
               _FREE( crv_geom  );
	   }
       }
       if( i == num_bnd_edges ) { sts = MSFAIL; goto wrapup; }
   }

   prev_ind = index - 1;
   if( prev_ind < 0 )                   prev_ind = num_bnd_edges-1;

   next_ind = index + 1;
   if( next_ind == num_bnd_edges )      next_ind = 0 ;

   if( edge_dir[prev_ind] == dir2 )		valid_ind = prev_ind ;
   else if( edge_dir[next_ind] == dir2)		valid_ind = next_ind ;
   else 
   { 
       if( dir2 == IB )		dir = DWN;
       else if( dir2 == OB )	dir = UPP;
       else if( dir2 == DWN ) 	dir = IB;
       else if( dir2 == UPP )	dir = OB;
       else { sts = MSFAIL; goto wrapup; }
       if( edge_dir[prev_ind] == dir )		valid_ind = prev_ind ;
       else if( edge_dir[next_ind] == dir )     valid_ind = next_ind ;
       else { sts = MSFAIL; goto wrapup; }
   }

   VLendpts( msg, &bnd_edges[index], &bnd_edges[index].mod_env, spt1, ept1 );
   VLendpts( msg, &bnd_edges[valid_ind], &bnd_edges[valid_ind].mod_env,
	     spt2, ept2 );

   if( VLsame_point( spt1, spt2, 0.1 ) )        dblcpy( &points[0], spt1, 3 );
   else if( VLsame_point( spt1, ept2, 0.1 ) )   dblcpy( &points[0], spt1, 3 );
   else if( VLsame_point( ept1, spt2, 0.1 ) )   dblcpy( &points[0], ept1, 3 );
   else if( VLsame_point( ept1, ept2, 0.1 ) )   dblcpy( &points[0], ept1, 3 );
   else { sts = MSFAIL; goto wrapup; }

wrapup:
   _FREE( line_pa   );
   _FREE( test_pa   );
   _FREE( line_pt   );
   _FREE( test_pt   );
   _FREE( crv_geom  );
   _FREE( key_geom  );
   return sts;
}

static IGRlong VLklFillDiagPoints( IGRlong                 *msg,
                                   IGRint                  num_bnd_edges,
				   struct GRobj_env	   *bnd_edges,
				   IGRint	           *edge_dir,
                                   struct GRid             *key_lines,
				   struct GRvg_construct   *cst,
				   IGRdouble		   *points )
{
IGRlong			sts;
IGRint			i;

   //Get the two FWD-IB points.
   sts = VLklFillDirPts( msg, num_bnd_edges, bnd_edges, edge_dir, 
			 &key_lines[1], cst, FWD, IB, &points[0] );
   __CheckRC( sts, *msg, "VLklFillDirPts: FWD-IB", wrapup ) ;
   __DBGpr_vec( "Point 1 ", &points[0] );
   __DBGpr_vec( "Point 2 ", &points[3] );

   //Get the two OB-FWD points.
   sts = VLklFillDirPts( msg, num_bnd_edges, bnd_edges, edge_dir, 
			 &key_lines[0], cst, OB, FWD, &points[6] );
   __CheckRC( sts, *msg, "VLklFillDirPts: OB-FWD", wrapup ) ;
   __DBGpr_vec( "Point 3 ", &points[6] );
   __DBGpr_vec( "Point 4 ", &points[9] );

   //Get the two AFT-OB points.
   sts = VLklFillDirPts( msg, num_bnd_edges, bnd_edges, edge_dir,
			 &key_lines[1], cst, AFT, OB, &points[12] );
   __CheckRC( sts, *msg, "VLklFillDirPts: AFT-OB", wrapup ) ;
   __DBGpr_vec( "Point 5 ", &points[12] );
   __DBGpr_vec( "Point 6 ", &points[15] );

   //Get the two IB-AFT points.
   sts = VLklFillDirPts( msg, num_bnd_edges, bnd_edges, edge_dir,
			 &key_lines[0], cst, IB, AFT, &points[18] );
   __CheckRC( sts, *msg, "VLklFillDirPts: IB-AFT", wrapup ) ;
   __DBGpr_vec( "Point 7 ", &points[18] );
   __DBGpr_vec( "Point 8 ", &points[21] );

wrapup:
   return sts;
}

IGRlong	VLklGetDiagonalChordDim(   IGRlong              *msg,
				   IGRint		num_pl,
				   struct GRobj_env     *plates,
                                   struct GRid		*key_lines,
				   struct GRid		*list  )
{
IGRlong                 sts;
IGRint			i, num_bnd_edges=0, loc_cnt=0, *edge_dir=NULL;
IGRdouble		points[24];
IGRpoint		spt, ept;
struct GRid		line;
struct GRobj_env	*bnd_edges=NULL;
struct GRvg_construct   cst;

   SetProc( VLklGetDiagonalChordDim ); Begin
   if( !msg || !num_pl || !plates || !list || !key_lines ) return OM_E_INVARG;

   UI_status("Generating Diagonal Chord Dimensions" );
   VLinitCnst(&cst);

   sts = VLendpts( msg, &key_lines[0], cst.env_info, spt, ept );
   __CheckRC( sts, *msg, "VLendpts: First Key Line", wrapup );

   sts = VLcreateLineSeg( spt, ept, cst.env_info, &cst, &line, msg );
   __CheckRC( sts, *msg, "VLcreateLineSeg: First Line", wrapup );
   sts = VLcreateKLDiagJunction( msg, &line, cst.env_info, 
		 	"KeyFrameChordDimension", &list[loc_cnt++] );
   __CheckRC( sts, *msg, "VLcreateKLDiagJunction", wrapup );

   sts = VLendpts( msg, &key_lines[1], cst.env_info, spt, ept );
   __CheckRC( sts, *msg, "VLendpts: Second Key Line", wrapup );

   sts = VLcreateLineSeg( spt, ept, cst.env_info, &cst, &line, msg );
   __CheckRC( sts, *msg, "VLcreateLineSeg: Second Line", wrapup );
   sts = VLcreateKLDiagJunction( msg, &line, cst.env_info, 
                 "KeyLineChordDimension", &list[loc_cnt++] );
   __CheckRC( sts, *msg, "VLcreateKLDiagJunction", wrapup );

   sts = VSgetExternalContour( msg, num_pl, plates, cst.env_info, 
	    VS_K_plBotSfPath, &num_bnd_edges, &bnd_edges, NULL, &edge_dir );
   __CheckRC( sts, *msg, "VSgetExternalContour", wrapup );

   sts = VLklFillDiagPoints( msg, num_bnd_edges, bnd_edges, edge_dir, 
			     key_lines, &cst, points );
   __CheckRC( sts, *msg, "VLklFillDiagPoints", wrapup );

   sts = VLcreateLineSeg( &points[18], &points[6], cst.env_info, 
			  &cst, &line, msg );
   __CheckRC( sts, *msg, "VLcreateLineSeg: Third Line", wrapup );
   sts = VLcreateKLDiagJunction( msg, &line, cst.env_info,
                 "CrossUnitDiagonalDimension1", &list[loc_cnt++] );
   __CheckRC( sts, *msg, "VLcreateKLDiagJunction", wrapup );

   sts = VLcreateLineSeg( &points[12], &points[0], cst.env_info,
                          &cst, &line, msg );
   __CheckRC( sts, *msg, "VLcreateLineSeg: Fourth Line", wrapup );
   sts = VLcreateKLDiagJunction( msg, &line, cst.env_info,
                 "CrossUnitDiagonalDimension2", &list[loc_cnt++] );
   __CheckRC( sts, *msg, "VLcreateKLDiagJunction", wrapup );

   sts = VLcreateLineSeg( &points[15], &points[9], cst.env_info,
                          &cst, &line, msg );
   __CheckRC( sts, *msg, "VLcreateLineSeg: Fifth Line", wrapup );
   sts = VLcreateKLDiagJunction( msg, &line, cst.env_info,
                 "OB-AFTChordDimension", &list[loc_cnt++] );
   __CheckRC( sts, *msg, "VLcreateKLDiagJunction", wrapup );

   sts = VLcreateLineSeg( &points[9], &points[3], cst.env_info,
                          &cst, &line, msg );
   __CheckRC( sts, *msg, "VLcreateLineSeg: Sixth Line", wrapup );
   sts = VLcreateKLDiagJunction( msg, &line, cst.env_info,
                 "OB-FWDChordDimension", &list[loc_cnt++] );
   __CheckRC( sts, *msg, "VLcreateKLDiagJunction", wrapup );

   sts = VLcreateLineSeg( &points[21], &points[15], cst.env_info,
                          &cst, &line, msg );
   __CheckRC( sts, *msg, "VLcreateLineSeg: Seventh Line", wrapup );
   sts = VLcreateKLDiagJunction( msg, &line, cst.env_info,
                 "IB-AFTChordDimension", &list[loc_cnt++] );
   __CheckRC( sts, *msg, "VLcreateKLDiagJunction", wrapup );

   sts = VLcreateLineSeg( &points[3], &points[21], cst.env_info,
                          &cst, &line, msg );
   __CheckRC( sts, *msg, "VLcreateLineSeg: Eighth Line", wrapup );
   sts = VLcreateKLDiagJunction( msg, &line, cst.env_info,
                 "IB-FWDChordDimension", &list[loc_cnt++] );
   __CheckRC( sts, *msg, "VLcreateKLDiagJunction", wrapup );

wrapup:
   for( i=0; i<num_bnd_edges; ++i )
   {
      sts = om$send(  msg = message GRgraphics.GRdelete( msg,
                                        cst.env_info ),
                        senderid = NULL_OBJID,
                        targetid = bnd_edges[i]._objid,
                        targetos = bnd_edges[i]._osnum  );
   }
   _FREE( edge_dir );
   _FREE( bnd_edges );
   End
   return sts;
}

IGRlong		VLklGetKeyLines(   IGRlong		*msg,
				   IGRint		num_pl,
				   struct GRobj_env     *plates,
				   struct GRobj_env     *frame,
				   struct GRid		*key_lines )
{
IGRlong                 sts, loc_sts, loc_msg;
IGRint			i;
IGRuchar                weight=3;
IGRpoint		spt, ept, midpt;
IGRvector		normal;
struct GRobj_env	ems_plane;
struct GRvg_construct	cst;

   SetProc( VLklGetKeyLines ); Begin
   if( !msg || !num_pl || !plates || !frame || !key_lines ) return OM_E_INVARG;

   sts = *msg = MSSUCC;

   UI_status("Generating Key Lines.." );

   VLinitCnst(&cst);

   key_lines[0].objid = NULL_OBJID;
   key_lines[1].objid = NULL_OBJID;
   ems_plane._objid    = NULL_OBJID;

   __DBGpr_obj( "Input Key Frame ", frame->obj_id );

   /* Intersect section plane with support surfaces  */
   sts = VLcreateMultipleInter( msg, num_pl, plates, VS_K_plBotSfPath, frame,
			        &cst, 0, &key_lines[0] );
   __CheckRC( sts, *msg, "VLcreateInter: First", wrapup );
   __DBGpr_obj("First Intersection Curve ", key_lines[0] ); 

   sts = om$send(  msg      = message GRvg.GRchgweight( msg,
                                                        &weight ),
                        senderid = NULL_OBJID,
                        targetid = key_lines[0].objid,
                        targetos = key_lines[0].osnum );

   sts = VLendpts( msg, &key_lines[0], cst.env_info, spt, ept );
   __CheckRC( sts, *msg, "VLendpts", wrapup );
   __DBGpr_vec( "Start Point ", spt );
   __DBGpr_vec( "End Point ", ept );

   sts = VLvector( msg, spt, ept, 1.0, 1.0, TRUE, normal );
   __CheckRC( sts, *msg, "VLvector", wrapup );

   for( i=0; i<3; ++i ) midpt[i] = ( ( spt[i] + ept[i] ) / 2.0 ) ;
   __DBGpr_vec( "Mid Point ", midpt );

   sts = VLcreatePlane( midpt, normal, cst.env_info, &cst, 
			&ems_plane.obj_id, msg );
   __CheckRC( sts, *msg, "VLcreatePlane", wrapup );
   __DBGpr_obj("EMS plane created ", ems_plane.obj_id );
   ems_plane.mod_env = *(cst.env_info) ;

  sts = VLcreateMultipleInter( msg, num_pl, plates, VS_K_plBotSfPath, 
			       &ems_plane, &cst, 0, &key_lines[1] );
  __CheckRC( sts, *msg, "VLcreateInter: Second", wrapup ); 

   __DBGpr_obj("Second Intersection Curve ", key_lines[1] );
   sts = om$send(  msg      = message GRvg.GRchgweight( msg,
                                                        &weight ),
                        senderid = NULL_OBJID,
                        targetid = key_lines[1].objid,
                        targetos = key_lines[1].osnum );

   sts = *msg = MSSUCC;

wrapup:
   if( ems_plane._objid != NULL_OBJID )
   {
      loc_sts = om$send(  msg = message GRgraphics.GRdelete( &loc_msg,
					cst.env_info ),
			senderid = NULL_OBJID,
			targetid = ems_plane._objid,
			targetos = ems_plane._osnum  );
   }

   if( !(sts&(*msg)&1) )
   {
      loc_sts = om$send(  msg = message GRgraphics.GRdelete( &loc_msg,
                                        cst.env_info ),
                        senderid = NULL_OBJID,
                        targetid = key_lines[0].objid,
                        targetos = key_lines[0].osnum  );

      loc_sts = om$send(  msg = message GRgraphics.GRdelete( &loc_msg,
                                        cst.env_info ),
                        senderid = NULL_OBJID,
                        targetid = key_lines[1].objid,
                        targetos = key_lines[1].osnum  );
   }

   End
   return sts;
}

IGRlong	VLklGetGirthDims( IGRlong		*msg,
			  struct GRobj_env	*plate_key )
{
IGRlong			sts;
IGRint			i, feet_count=0;
IGRdouble		dir;
IGRpoint		key_point, cur_point;
OM_S_OBJECT_LINKAGE	*Llist=NULL;
struct ACrg_coll	attrib;
struct GRid		*feet_list=NULL;
struct GRobj_env	gr_obj1, gr_obj2;
struct IGRbsp_curve	*crv_geom=NULL;


   SetProc( VLklGetGirthDims ); Begin

   __DBGpr_obj("Plate Key ", plate_key->obj_id );
   sts = om$get_channel_count(	objid        = plate_key->_objid,
				osnum        = plate_key->_osnum,
				p_chanselect = &AS_to_comp,
				count        = (OMuint *)&feet_count );
   __CheckRC( sts, 1, "om$get_channel_count", wrapup );
   __DBGpr_int("Number of Plate Key macro feets ", feet_count );

   if( !( Llist = _CALLOC( feet_count, OM_S_OBJECT_LINKAGE ) ) ) vd_$mem_fail();
   if( !( feet_list = _MALLOC( feet_count, struct GRid ) ) ) vd_$mem_fail() ;

   sts = om$get_channel_objects( objid        = plate_key->_objid,
				 osnum        = plate_key->_osnum,
				 p_chanselect = &AS_to_comp,
			         size	      = feet_count,
				 count        = (OMuint *)&feet_count,
				 list         = Llist );
   __CheckRC( sts, 1, "om$get_channel_objects", wrapup );
   for( i=0; i<feet_count; ++i )
   {
	feet_list[i].objid = Llist[i].S_objid;
 	feet_list[i].osnum = Llist[i].osnum;
   }
   __DBGpr_obj("Key Line ", feet_list[1] );
   __DBGpr_obj("First Key Line ", feet_list[12] );

   sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                        msg, NULL, &gr_obj1 ),
                   senderid = NULL_OBJID,
                   targetid = feet_list[12].objid,
                   targetos = feet_list[12].osnum  );
   __CheckRC( sts, *msg, "VLjunction.VLreturn_graphic", wrapup );

   sts = vs$get_geometry( msg 	   = msg,
			  grobjId  = &gr_obj1.obj_id,
			  grobjEnv = &gr_obj1.mod_env,
			  geometry = &crv_geom );
   __CheckRC( sts, *msg, "vs$get_geometry", wrapup );

   sts = VLcreateDblInter( msg, &gr_obj1.obj_id, &gr_obj1.mod_env, 
        &feet_list[1], &plate_key->mod_env, key_point, &plate_key->mod_env );
   __CheckRC( sts, *msg, "VLcreateDblInter", wrapup );
   __DBGpr_vec("Key Point ", key_point );

   for( i=11; i<feet_count; ++i )
   {
      sts = om$send(  msg      = message VLjunction.ACget_named_attribute(
                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = feet_list[i].objid,
                   targetos = feet_list[i].osnum  );
      if( !(sts&(*msg)&1) ) continue;
      dir = attrib.desc.value.att_exp;
      if( dir == 0.0 ) continue;

      sts = om$send(  msg      = message VLjunction.VLreturn_graphic(
                                        msg, NULL, &gr_obj2 ),
                   senderid = NULL_OBJID,
                   targetid = feet_list[i].objid,
                   targetos = feet_list[i].osnum  );
      __CheckRC( sts, *msg, "VLjunction.VLreturn_graphic", wrapup );

      sts = VLcreateDblInter( msg, &gr_obj1.obj_id, &gr_obj1.mod_env,
	&gr_obj2.obj_id, &gr_obj2.mod_env, cur_point, &plate_key->mod_env );
      if( !(sts&(*msg)&1) ) continue;
      __DBGpr_vec("Intersection Point ", cur_point );
   }

wrapup:
   _FREE( Llist );
   _FREE( feet_list );
   _FREE( crv_geom );
   End
   return sts;
}

end implementation VDSroot;
