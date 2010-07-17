/* $Id: VSgmmiscfunk.I,v 1.2 2001/02/20 01:18:54 build Exp $  */
/*************************************************************************
 * I/STRUCT
 *
 * File:        vsgeom/VSgmmiscfunk.I
 *
 * Description: Geometry Misc. Functions.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSgmmiscfunk.I,v $
 *      Revision 1.2  2001/02/20 01:18:54  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1  2001/02/01 00:28:47  ramarao
 *      Implemented CR# 4203.
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR                       DESCRIPTION
 *      01/31/01   Rama Rao            		File Creation
 *************************************************************************/

class implementation VDSroot;

#include "bserr.h"
#include "bsdistptpt.h"
#include "AS_status.h"
#include "asmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "emsmapdef.h"
#include "EMSmsgdef.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDgeom.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "vsplatedef.h"
#include "vsdbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

from 	GRcurve		import		GRendpts;
from	ci_macro	import		init;
from	VSfeature	import		VSforwardToOriginal;

extern struct GRid	NULL_GRID;
extern GRclassid	OPP_nci_macro_class_id, OPP_GR3dlineseg_class_id;

IGRlong VSendpts ( msg, Obj, Env, spt, ept)

/*d This debug function extracts the endpoints of an object. */

                IGRlong         *msg;           /*O Completion code     */
        struct  GRid            *Obj;           /*I Target object       */
        struct  GRmd_env        *Env;           /*I Target module info  */
                IGRdouble       spt[];          /*O Start point         */
                IGRdouble       ept[];          /*O End point           */

{
/* Beginning of function */

                IGRint          sts=OM_S_SUCCESS;

        /* Call GRendpts message */
        sts = om$send ( msg      = message GRcurve.GRendpts (
                                                msg,
                                                &Env->md_env.matrix_type,
                                                Env->md_env.matrix,
                                                spt,
                                                ept ),
                        senderid = NULL_OBJID,
                        targetid = Obj->objid,
                        targetos = Obj->osnum );
        return (sts);

/* End of function */
}

IGRlong VSextractVertices ( msg, ncrv, Curve, Inv, nvtx, Vertex)

/*d This function extracts the vertices of a bunch of ordered curves that are
    the components of composite curve. The vertices's array must be freed by
    the calling program. */

IGRlong         	*msg;           /*O Completion code           */
IGRint          	ncrv;           /*I Number of curves          */
struct  GRobj_env       Curve[];        /*I Array of curves           */
IGRshort        	Inv[];          /*I Curve inversion flag      */
IGRint          	*nvtx;          /*O Number of vertices        */
IGRdouble       	**Vertex;       /*O Array of vertices         */
{
/* Beginning of function */

                IGRlong         sts=OM_S_SUCCESS;
                IGRint          i, j;
                IGRpoint        spt, ept;

        /* Initialize */
        *nvtx   = ncrv + 1;
        *Vertex = NULL;
        if (ncrv < 1) {
                printf( "VSextractVertices() : no curves given !\n");
                *msg = MSFAIL;
                goto wrapup;
        }

        /* Allocate memory */
        *Vertex = om$calloc ( num = *nvtx * 3, structure = IGRdouble);
        if (*Vertex == NULL) { printf( "Unable to allocate <%d> bytes\n",
                                       *nvtx * 3 * sizeof(IGRdouble));
                               goto wrapup; }

        /* First step */
        sts = VSendpts ( msg, &Curve[0].obj_id, &Curve[0].mod_env, spt, ept);
        as$status ( sts    = sts,
                    msg    = "VSendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        if (Inv[0] == 1) {      dblcpy ( &(*Vertex)[0], spt, 3);
                                dblcpy ( &(*Vertex)[3], ept, 3);        }
        else {                  dblcpy ( &(*Vertex)[0], ept, 3);
                                dblcpy ( &(*Vertex)[3], spt, 3);        }

        for ( i=1; i<ncrv; i++) {
                sts = VSendpts ( msg, &Curve[i].obj_id, &Curve[i].mod_env,
                                  spt, ept);
                as$status ( sts    = sts,
                            msg    = "VSendpts()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

                /* Compute vertices */
                if (Inv[i] == 1) {
                     for ( j=0; j<3; j++)    (*Vertex)[3*i+j] =
                                             ((*Vertex)[3*i+j]+spt[j]) / 2.0;
                     dblcpy ( &(*Vertex)[3*i+3], ept, 3);
                }
                else {
                     for ( j=0; j<3; j++)    (*Vertex)[3*i+j] =
                                             ((*Vertex)[3*i+j]+ept[j]) / 2.0;
                     dblcpy ( &(*Vertex)[3*i+3], spt, 3);
                }
        }

wrapup:
        return (sts);

/* End of function */
}

IGRlong VScreateMultiInter2Elem (

IGRlong                 *msg,           /*O  return message             */
struct  GRid            *input1,        /*I  input elemt 1              */
struct  GRmd_env        *env1,          /*I  env of elemt 1             */
IGRshort                trim1,          /*I  trim option for elemt 1    */
struct  GRid            *input2,        /*I  input elemt 2              */
struct  GRmd_env        *env2,          /*I  env of elemt 2             */
IGRshort                trim2,          /*I  trim option for elemt 2    */
IGRint                  *num_inter,     /*I  Number of Intersections    */
struct  GRid            *inter,         /*O  id of intersection         */
struct  GRmd_env        *loc_env )      /*I  env of intersection        */

{
IGRlong                 sts, loc_msg, no_msg;
struct  GRid            temp_list[5];   // use static to initialize 2 3 4
IGRint                  i;
IGRint                  suc;
IGRchar                 name[40];
struct  GRid            mc_int, resi;
struct  GRid            wk_input1, wk_input2;

        /*c initialization */

        *num_inter      = 0;
        *msg            = MSSUCC;
        loc_msg         = MSFAIL;
        wk_input1.objid         = NULL_OBJID;
        wk_input2.objid         = NULL_OBJID;

        if( input1->osnum != loc_env->md_id.osnum ){

                sts = om$send(  msg = message GRgraphics.GRcopy(
                                        &loc_msg,
                                        env1,
                                        loc_env,
                                        &wk_input1.objid ),
                                senderid = NULL_OBJID,
                                targetid = input1->objid,
                                targetos = input1->osnum );
                as$status( sts = sts );
                wk_input1.osnum = loc_env->md_id.osnum;

                sts = as$make_source(   go_grid = wk_input1,
                                        as_os   = loc_env->md_id.osnum,
                                        as_grid = &temp_list[0] );
                as$status( sts = sts );

        } else {

                sts = as$make_source(   go_grid = *input1,
                                        as_os   = loc_env->md_id.osnum,
                                        as_grid = &temp_list[0] );
                as$status( sts = sts );
          }

        if( input2->osnum != loc_env->md_id.osnum ){

                sts = om$send(  msg = message GRgraphics.GRcopy(
                                        &loc_msg,
                                        env2,
                                        loc_env,
                                        &wk_input2.objid ),
                                senderid = NULL_OBJID,
                                targetid = input2->objid,
                                targetos = input2->osnum );
                as$status( sts = sts );
                wk_input2.osnum = loc_env->md_id.osnum;

                sts = as$make_source(   go_grid = wk_input2,
                                        as_os   = loc_env->md_id.osnum,
                                        as_grid = &temp_list[1] );
                as$status( sts = sts );

        } else {

                sts = as$make_source(   go_grid = *input2,
                                        as_os   = loc_env->md_id.osnum,
                                        as_grid = &temp_list[1] );
                as$status( sts = sts );
          }

        // create default expressions
        temp_list[2].objid = NULL_OBJID;
        sts = exp$create(       exp_name   = NULL,
                                exp_value  = (IGRdouble) trim1,
                                osnum      = loc_env->md_id.osnum,
                                p_exp_id = &temp_list[2].objid,
                                p_osnum  = &temp_list[2].osnum );
        as$status( sts = sts );

        temp_list[3].objid = NULL_OBJID;
        sts = exp$create(       exp_name   = NULL,
                                exp_value  = (IGRdouble) trim2,
                                osnum      = loc_env->md_id.osnum,
                                p_exp_id = &temp_list[3].objid,
                                p_osnum  = &temp_list[3].osnum );
        as$status( sts = sts );

        temp_list[4].objid = NULL_OBJID;
        sts = exp$create(       exp_name   = NULL,
                                exp_value  = (IGRdouble) 0.,
                                osnum      = loc_env->md_id.osnum,
                                p_exp_id = &temp_list[4].objid,
                                p_osnum  = &temp_list[4].osnum );
        as$status( sts = sts );

        mc_int.objid    = NULL_OBJID;
        mc_int.osnum    = loc_env->md_id.osnum;
        sts = om$construct(     classid = OPP_nci_macro_class_id,
                                osnum   = mc_int.osnum,
                                p_objid = &mc_int.objid );
        as$status( sts = sts );
        sts = om$send(  msg      = message ci_macro.init(
                                        &suc, AChdr_nodisplay ,
                                        "int_2_elem",
                                        5, temp_list,
                                        NULL, loc_env ),
                        senderid = NULL_OBJID,
                        mode     = OM_e_wrt_message,
                        targetid = mc_int.objid,
                        targetos = mc_int.osnum );
        if( ! (sts&suc&1)){ loc_msg = MSFAIL; goto wrapup; }
        else {
             *num_inter = 0;
             for( i=0; i<100; ++i )
             {
                sprintf( name, "resi%d", i );
                // get base cv
                sts = om$send(  msg      = message NDmacro.ACreturn_foot(
                                                &loc_msg,
                                                name,
                                                &resi,
                                                NULL,
                                                NULL ),
                                senderid = NULL_OBJID,
                                targetid = mc_int.objid,
                                targetos = mc_int.osnum );
                if( !(sts&1&loc_msg) )  break;

                inter[(*num_inter)].osnum    = loc_env->md_id.osnum;
                sts = om$send(  msg      = message GRgraphics.GRcopy(
                                                &loc_msg,
                                                loc_env,
                                                loc_env,
                                                &inter[(*num_inter)].objid ),
                                senderid = NULL_OBJID,
                                targetid = resi.objid,
                                targetos = resi.osnum );
                as$status( sts = sts );
                (*num_inter)++ ;
             }
             sts = loc_msg = MSSUCC;
        }

wrapup :

        if( ! (loc_msg & 1))    *msg = MSFAIL;

        sts = om$send(  msg      = message GRgraphics.GRdelete
                                        ( &no_msg, loc_env ),
                        senderid = NULL_OBJID,
                        targetid = mc_int.objid,
                        targetos = mc_int.osnum );

        if( wk_input1.objid != NULL_OBJID )
                sts = om$send(  msg      = message GRgraphics.GRdelete
                                        ( &no_msg, loc_env ),
                                senderid = NULL_OBJID,
                                targetid = wk_input1.objid,
                                targetos = wk_input1.osnum );

        if( wk_input2.objid != NULL_OBJID )
                sts = om$send(  msg      = message GRgraphics.GRdelete
                                        ( &no_msg, loc_env ),
                                senderid = NULL_OBJID,
                                targetid = wk_input2.objid,
                                targetos = wk_input2.osnum );

        for( i=2; i<5; i++ )
                sts = om$send(  msg      = message GRgraphics.GRdelete
                                                ( &no_msg, loc_env ),
                                senderid = NULL_OBJID,
                                targetid = temp_list[i].objid,
                                targetos = temp_list[i].osnum );

return  *msg;
}

IGRlong         VScreateMultipleInter(  IGRlong                 *msg,
                                        IGRint                  num_pl,
                                        struct GRobj_env        *pltOE,
                                        IGRchar                 *side,
                                        struct GRobj_env        *surface,
                                        struct GRvg_construct   *cst,
                                        IGRboolean              trim,
                                        struct GRid             *crvID )
{
BSrc                    rc;
IGRlong                 sts;
IGRint                  i, j, nint=0, nvtx=0, ncmp, num_inter=0;
IGRdouble               cht, bastol, xpt[6], *Vrtx=NULL;
IGRboolean              adj, clo;
IGRpoint                spt1, spt2, ept1, ept2;
IGRshort                *inv=NULL;
struct GRid             SrfID, inters[100];
struct GRobj_env        footOE, *Icrv=NULL, *Ocrv=NULL;
struct GRlc_info        *Entr=NULL;
struct IGRpolyline      geom;

   SetProc( VScreateMultipleInter ); Begin

   if( !num_pl || !pltOE || !side || !surface || !cst || !crvID )
        return OM_E_INVARG;

   __DBGpr_int("Number of Input Plates ", num_pl );
   __DBGpr_str("Plate Side ", side );
   __DBGpr_obj("Intersecting Surface/Plane ", surface->obj_id );

   if( !( Icrv = _MALLOC( 2*num_pl, struct GRobj_env ) ) ) vd_$mem_fail();
   nint=0;
   for( i=0; i<num_pl; ++i )
   {
      __DBGpr_obj("Plate ", pltOE[i].obj_id );
      Icrv[nint].mod_env      = *(cst->env_info) ;

      footOE._objid = NULL_OBJID;
      vdobj$GetFoot( objOE     = &pltOE[i],
                     footName  = side,
                     footOE    = &footOE );
      if( footOE._objid == NULL_OBJID ) continue;

      vd_$grCopy( msg   = msg,
                  frEnv = &footOE.mod_env,
                  frObj = &footOE.obj_id,
                  toEnv = cst->env_info,
                  toObj = &SrfID );

      num_inter = 0;
      sts = VScreateMultiInter2Elem( msg, &SrfID, cst->env_info, trim,
                           &surface->obj_id, &surface->mod_env, trim,
                           &num_inter, inters, &Icrv[nint].mod_env );
      vd_$bulk_delete( grids = &SrfID, theEnv = cst->env_info );
      if( !(sts&1&(*msg)) ) continue;
      for( j=0; j<num_inter; ++j )
      {
         Icrv[nint+j].obj_id  = inters[j];
         Icrv[nint+j].mod_env = *(cst->env_info) ;
      }
      nint += num_inter;
   }

   if( !nint ) { sts = *msg = MSFAIL; goto wrapup; }

   if( !( Ocrv = _MALLOC( 2*nint, struct GRobj_env ) ) ) vd_$mem_fail();
   if( !( inv  = _MALLOC( nint, IGRshort ) ) ) vd_$mem_fail();

   vdgeom$GetTolerance( cht = &cht );
   vdgeom$GetTolerance( basis = &bastol );
   sts = OrderCrv( Icrv, nint, 20.0, bastol, Ocrv, inv, &adj, &clo, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   /* Extract ordered vertices of the future composite curve */
   sts = VSextractVertices( msg, nint, Ocrv, inv, &nvtx, &Vrtx);
   __CheckRC( sts, *msg, "VSextractVertices", wrapup ) ;

   /* Try to close the gap */
   ncmp = nint;
   if( nint > 1 )
   {
       *msg = MSSUCC;
       cst->geometry    = (IGRchar *) &geom;
       geom.num_points = 2;
       for( i=1; i<nint; i++ )
       {
          VSendpts( msg, &Ocrv[i-1].obj_id, &Ocrv[i-1].mod_env, spt1, ept1 );
          if( inv[i-1] == 1 )   dblcpy ( &xpt[0], ept1, 3);
          else                  dblcpy ( &xpt[0], spt1, 3);

          VSendpts( msg, &Ocrv[i].obj_id, &Ocrv[i].mod_env, spt2, ept2 );
          if( inv[i] == 1 )     dblcpy ( &xpt[3], spt2, 3);
          else                  dblcpy ( &xpt[3], ept2, 3);

          if( BSdistptpt( &rc, &xpt[0], &xpt[3] ) > bastol )
          {
             geom.points = (IGRdouble *) xpt;
             Ocrv[ncmp].obj_id.objid = NULL_OBJID;
             Ocrv[ncmp].obj_id.osnum = cst->env_info->md_id.osnum;
             Ocrv[ncmp].mod_env      = *(cst->env_info);

             sts = om$construct( classid = OPP_GR3dlineseg_class_id,
                                 osnum   = Ocrv[ncmp].obj_id.osnum,
                                 p_objid = &Ocrv[ncmp].obj_id.objid,
                                 msg = message GRgraphics.GRaltconstruct(cst));
             __CheckRC( sts, *msg, "GRaltconstruct: GR3dlineseg", wrapup ) ;
             ncmp++;
          }
       }
   }

   sts = OrderCrv( Ocrv, ncmp, 5*cht, bastol, Icrv, inv, &adj, &clo, msg);
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   if( !( Entr = _MALLOC( ncmp, struct GRlc_info ) ) ) vd_$mem_fail();
   for( i=0; i<ncmp; i++ )
   {
        Entr[i].module_info = Icrv[i].mod_env;
        Entr[i].located_obj = Icrv[i].obj_id;
   }

   BuildCrv( 1, Icrv, ncmp, inv, adj, clo, Entr, cst, crvID, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "BuildCrv", wrapup ) ;

wrapup:
   _FREE( Vrtx );
   _FREE( Icrv );
   _FREE( Ocrv );
   _FREE( Entr );
   _FREE( inv  );
   End
   return sts;
}


IGRlong         VScreateMultipleProj(   IGRlong                 *msg,
                                        IGRint                  num_pl,
                                        struct GRobj_env        *pltOE,
                                        IGRchar                 *side,
                                        struct GRobj_env        *inp_curve,
                                        struct GRvg_construct   *cst,
                                        struct GRid             *crvID )
{
BSrc                    rc;
IGRlong                 sts;
IGRint                  i, j, nint=0, nvtx=0, ncmp, num_inter=0;
IGRdouble               cht, bastol, xpt[6], *Vrtx=NULL;
IGRboolean              adj, clo;
IGRpoint                spt1, spt2, ept1, ept2;
IGRshort                *inv=NULL, extra_opt;
GRobjid			*inters=NULL;
struct GRobj_env        footOE, *Icrv=NULL, *Ocrv=NULL;
struct GRlc_info        *Entr=NULL, surfInfo, curvInfo;
struct IGRpolyline      geom;

   SetProc( VScreateMultipleProj ); Begin

   if( !num_pl || !pltOE || !side || !inp_curve || !cst || !crvID )
        return OM_E_INVARG;

   __DBGpr_int("Number of Input Plates ", num_pl );
   __DBGpr_str("Plate Side ", side );
   __DBGpr_obj("Input Curve to Project ", inp_curve->obj_id );

   curvInfo.located_obj = inp_curve->obj_id;
   curvInfo.module_info = inp_curve->mod_env;

   if( !( Icrv = _MALLOC( 2*num_pl, struct GRobj_env ) ) ) vd_$mem_fail();
   nint=0;
   for( i=0; i<num_pl; ++i )
   {
      __DBGpr_obj("Plate ", pltOE[i].obj_id );
      Icrv[nint].mod_env      = *(cst->env_info) ;

      sts = om$send( msg = message VSfeature.VSforwardToOriginal(
                        msg,
                        OM_e_wrt_object,
                        message NDmacro.ACreturn_foot( msg, VS_K_plBotSfPath,
                           &footOE.obj_id, &footOE._matrix_type,
                            footOE._matrix ) ),
                   senderid = NULL_OBJID,
                   targetid = pltOE[i]._objid,
                   targetos = pltOE[i]._osnum ) ;
      if( !(sts&1&(*msg)) )   continue;
      footOE._md_os = footOE._osnum;
      sts = ex$get_modid( mod_osnum = footOE._md_os,
                          mod_id    = &footOE._md_id );
      __DBGpr_obj("Plate Base Surface", footOE.obj_id );

      surfInfo.module_info = *(cst->env_info);

      vd_$grCopy( msg   = msg,
                  frEnv = &footOE.mod_env,
                  frObj = &footOE.obj_id,
                  toEnv = &surfInfo.module_info,
                  toObj = &surfInfo.located_obj  );

      num_inter = 0;
      _FREE( inters );

      extra_opt = EMMapBnd_NoClip | EMMapBnd_NoFixing | EMMapBnd_NoRmvColEds;

      sts = VDproject_curve_along_surface_normals( extra_opt, &curvInfo, 
			&surfInfo, cst, FALSE, FALSE, (IGRlong *)&num_inter,
			&inters, msg );
      vd_$bulk_delete( 	grids  = &surfInfo.located_obj, 
			theEnv = &surfInfo.module_info );
      if( !(sts&1&(*msg)) ) continue;
      __DBGpr_int("Number of Projections", num_inter );
      for( j=0; j<num_inter; ++j )
      {
         Icrv[nint+j]._objid  = inters[j];
	 Icrv[nint+j]._osnum  = cst->env_info->md_id.osnum;
         Icrv[nint+j].mod_env = *(cst->env_info) ;
      }
      nint += num_inter;
   }

   if( !nint ) { sts = *msg = MSFAIL; goto wrapup; }

   if( !( Ocrv = _MALLOC( 2*nint, struct GRobj_env ) ) ) vd_$mem_fail();
   if( !( inv  = _MALLOC( nint, IGRshort ) ) ) vd_$mem_fail();

   vdgeom$GetTolerance( cht = &cht );
   vdgeom$GetTolerance( basis = &bastol );
   sts = OrderCrv( Icrv, nint, 20.0, bastol, Ocrv, inv, &adj, &clo, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   /* Extract ordered vertices of the future composite curve */
   sts = VSextractVertices( msg, nint, Ocrv, inv, &nvtx, &Vrtx);
   __CheckRC( sts, *msg, "VSextractVertices", wrapup ) ;

   /* Try to close the gap */
   ncmp = nint;
   if( nint > 1 )
   {
       *msg = MSSUCC;
       cst->geometry    = (IGRchar *) &geom;
       geom.num_points = 2;
       for( i=1; i<nint; i++ )
       {
          VSendpts( msg, &Ocrv[i-1].obj_id, &Ocrv[i-1].mod_env, spt1, ept1 );
          if( inv[i-1] == 1 )   dblcpy ( &xpt[0], ept1, 3);
          else                  dblcpy ( &xpt[0], spt1, 3);

          VSendpts( msg, &Ocrv[i].obj_id, &Ocrv[i].mod_env, spt2, ept2 );
          if( inv[i] == 1 )     dblcpy ( &xpt[3], spt2, 3);
          else                  dblcpy ( &xpt[3], ept2, 3);

          if( BSdistptpt( &rc, &xpt[0], &xpt[3] ) > bastol )
          {
             geom.points = (IGRdouble *) xpt;
             Ocrv[ncmp].obj_id.objid = NULL_OBJID;
             Ocrv[ncmp].obj_id.osnum = cst->env_info->md_id.osnum;
             Ocrv[ncmp].mod_env      = *(cst->env_info);

             sts = om$construct( classid = OPP_GR3dlineseg_class_id,
                                 osnum   = Ocrv[ncmp].obj_id.osnum,
                                 p_objid = &Ocrv[ncmp].obj_id.objid,
                                 msg = message GRgraphics.GRaltconstruct(cst));
             __CheckRC( sts, *msg, "GRaltconstruct: GR3dlineseg", wrapup ) ;
             ncmp++;
          }
       }
   }

   sts = OrderCrv( Ocrv, ncmp, 5*cht, bastol, Icrv, inv, &adj, &clo, msg);
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   if( !( Entr = _MALLOC( ncmp, struct GRlc_info ) ) ) vd_$mem_fail();
   for( i=0; i<ncmp; i++ )
   {
        Entr[i].module_info = Icrv[i].mod_env;
        Entr[i].located_obj = Icrv[i].obj_id;
   }

   BuildCrv( 1, Icrv, ncmp, inv, adj, clo, Entr, cst, crvID, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "BuildCrv", wrapup ) ;

wrapup:
   _FREE( Vrtx );
   _FREE( Icrv );
   _FREE( Ocrv );
   _FREE( Entr );
   _FREE( inv  );
   _FREE( inters );
   End
   return sts;
}

end implementation VDSroot;
