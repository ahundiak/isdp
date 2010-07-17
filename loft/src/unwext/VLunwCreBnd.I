/* $Id: VLunwCreBnd.I,v 1.11 2002/04/25 13:56:50 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/unwext/VLunwCreBnd.I
 *
 * Description: Function to get the developped surface after applying stock.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwCreBnd.I,v $
 *      Revision 1.11  2002/04/25 13:56:50  ramarao
 *      Found a big memory leak.
 *
 *      Revision 1.10  2002/02/14 17:16:00  ramarao
 *      Fixed TR# 5974.
 *
 *      Revision 1.9  2001/09/04 16:35:49  ramarao
 *      Read INNER_CUTOUT_.. properly from the setup file.
 *
 *      Revision 1.8  2001/07/02 23:21:37  ramarao
 *      Fixed a problem reported by Art.
 *
 *      Revision 1.7  2001/06/27 16:18:15  ramarao
 *      Fixed TR# 5369.
 *
 *      Revision 1.6  2001/06/22 18:20:55  ramarao
 *      Removed the previous fix.
 *
 *      Revision 1.5  2001/06/16 17:29:06  ramarao
 *      Fixed TR# 5288.
 *
 *      Revision 1.4  2001/05/15 15:03:34  ramarao
 *      Fixed ETL# 8192.
 *
 *      Revision 1.3  2001/04/12 20:38:05  ramarao
 *      Fixed TR# 5025.
 *
 *      Revision 1.2  2001/02/20 01:07:18  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1  2001/01/16 19:53:58  ramarao
 *      *** empty log message ***
 *
# Revision 1.18  2000/10/23  14:20:56  pinnacle
# Replaced: loft/src/unwext/VLunwCreBnd.I for:  by rchennup for Service Pack
#
# Revision 1.17  2000/10/22  20:53:12  pinnacle
# Replaced: loft/src/unwext/VLunwCreBnd.I for:  by rchennup for Service Pack
#
# Revision 1.16  2000/10/16  17:27:32  pinnacle
# ah
#
# Revision 1.15  2000/07/14  18:20:28  pinnacle
# Replaced: loft/src/unwext/VLunwCreBnd.I for:  by rchennup for Service Pack
#
# Revision 1.14  2000/07/14  16:20:54  pinnacle
# Replaced: loft/src/unwext/VLunwCreBnd.I for:  by rchennup for Service Pack
#
# Revision 1.13  2000/07/08  19:18:32  pinnacle
# Replaced: loft/src/unwext/VLunwCreBnd.I for:  by rchennup for Service Pack
#
# Revision 1.11  2000/05/25  14:20:04  pinnacle
# Replaced: loft/src/unwext/VLunwCreBnd.I for:  by rchennup for Service Pack
#
# Revision 1.10  2000/05/19  16:42:24  pinnacle
# ah
#
# Revision 1.9  2000/05/17  19:47:06  pinnacle
# Replaced: loft/src/unwext/VLunwCreBnd.I for:  by rchennup for Service Pack
#
# Revision 1.2  2000/04/24  20:02:48  pinnacle
# Replaced: loft/src/unwext/VLunwCreBnd.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/21  21:52:24  pinnacle
# Created: loft/src/unwext/VLunwCreBnd.I by rchennup for Service Pack
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      04/21/00        Rama Rao        File Creation.
 *      05/18/00        ah              Convert internal cutouts to parametric
 *      10/16/00        ah              Added env to VDdrawCurve
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "bserr.h"
#include "bsmdstptcv.h"
#include "bscvmidpt.h"
#include "asmacros.h"
#include "EMSmsgdef.h"
#include "EMSopt.h"
#include "EMSssprops.h"
#include "VDtypedef.h"
#include "VDobj.h"
#include "VDefp.h"
#include "VDgeom.h"
#include "VDmem.h"
#include "v_datamacros.h"
#include "vsoptdef.h"
#include "vsattr.h"
#include "vsplatedef.h"
#include "vsplate.h"
#include "vsedgemacros.h"
#include "vsmiscmacros.h"
#include "vlstructure.h"
#include "vlunfold.h"
#include "vlcontmacros.h"
#include "VLunwMisc.h"
#include "vldbgmacros.h"

//#define DEBUG           1 
#define vdsDEBUG        1
#define vdserrDEBUG     1

extern   OM_S_CHANSELECT AS_to_owner;

extern GRclassid OPP_GR3dlinestr_class_id, OPP_GRcurve_class_id;

from ACpretend		import	ACfind_parent ;
from EMSloopset		import	EMget_loops;
from EMSboundary	import  EMcount_edges,EMget_edges;
from EMSsubbs		import	EMget_props;
from EMSedge		import	EMget_bcxyz_geom;

IGRint  VLcheckEdgeProximity(	struct  IGRbsp_curve	*bvl_geom,
				struct  IGRbsp_curve	*edge_geom,
				IGRdouble		thick 		)
{
IGRlong		rc;
IGRdouble       tol, spt1[3], spt2[3], ept1[3], ept2[3], spt[3], ept[3], par,
                pt[3], mdist, mid_pt[3], dotp;

   vdgeom$GetTolerance(cht = &tol);
   tol = 2*tol + thick ;

   MAbcendpts( &rc, bvl_geom, spt1, ept1 );
   if( !(rc&1) ) return FALSE;

   MAbcendpts( &rc, edge_geom, spt2, ept2 );
   if( !(rc&1) ) return FALSE;

   vl$dotProduct( msg   = &rc,
                  sPnt1 = spt1,
                  ePnt1 = ept1,
                  sPnt2 = spt2,
                  ePnt2 = ept2,
                  dot   = &dotp );
   if( !(rc&1) || fabs( dotp ) < 0.9 )  return FALSE;

   MAbcendpts( &rc, bvl_geom, spt, ept );
   if( !(rc&1) ) return FALSE;

   BSmdstptcv( edge_geom, spt, &par, pt, &mdist, &rc );
   if( rc != BSSUCC || mdist > tol )	return FALSE;

   BSmdstptcv( edge_geom, ept, &par, pt, &mdist, &rc );
   if( rc != BSSUCC || mdist > tol )    return FALSE;

   BScvmidpt( bvl_geom, &par, mid_pt, &rc );
   if( rc != BSSUCC ) return FALSE;

   BSmdstptcv( edge_geom, mid_pt, &par, pt, &mdist, &rc );
   if( rc != BSSUCC || mdist > tol )    return FALSE;

   return TRUE;
}

IGRlong VLbuildNeatUnwrapEdge( 	IGRlong			*msg,
				struct unw_obj_plat	*dev,
				struct GRid		*EdgeId,
				struct GRvg_construct   *cst,
				struct GRobj_env	*UnwrapEdgeId )
{
IGRlong			sts;
IGRint			numCrv=0;
struct GRid		*Crvs=NULL;
struct GRobj_env 	curve_env;

   SetProc( VLbuildNeatUnwrapEdge ); Begin

   sts = vs$get_graphic_edge(  msg     = msg,
                               edId    = EdgeId,
                               edEnv   = &dev->surf_id.mod_env,
                               copy    = TRUE,
                               copyEnv = cst->env_info,
                               grEdge  = &(curve_env.obj_id)) ;
   if( !(sts&1) ) curve_env.obj_id = *EdgeId;
   curve_env.mod_env = *(cst->env_info);

   sts = VLprojAndMapCrvOntoSrf( dev, 1, &curve_env, FALSE,
                                 cst, NULL, NULL, &numCrv, &Crvs );
   __CheckRC( sts, 1, "VLprojAndMapCrvOntoSrf", wrapup ) ;
   __DBGpr_int("VLprojAndMapCrvOntoSrf returns ", numCrv );

   if( !numCrv ) goto wrapup;

   __DBGpr_objlist("Curve ", numCrv, Crvs );

   UnwrapEdgeId->obj_id = Crvs[0];
   UnwrapEdgeId->mod_env = *(cst->env_info);

wrapup:
   _FREE( Crvs );
   End
   return sts;
}

static IGRlong  VLunwGetDevSrfId(  IGRlong              *msg,
                                   struct unw_obj_plat  *dev,
                                   struct GRobj_env     *surf_env )
{
IGRlong                 sts;
IGRint                  chan_count=0;
IGRchar                 side[30];
struct GRobj_env        plate;

   SetProc( VLunwGetDevSrfId ); Begin

   if( !msg || !dev || !surf_env )      return OM_E_INVARG;

   VDGetParserModelOE( &plate );

   sts = om$get_channel_count ( osnum        = dev->surf_id._osnum,
                                objid        = dev->surf_id._objid,
                                p_chanselect = &AS_to_owner,
                                count        = (OMuint *)&chan_count );
   __DBGpr_int("AS_to_owner channel count ", chan_count );
   if( (sts&1) && chan_count )  { *surf_env = dev->surf_id ; goto wrapup; }

   // Get the correct surface from the Non-hole plate parent
   if (  dev->side_of_plate == OFFSET_SIDE ||
         dev->side_of_plate == OFFSET_FLIP    ) strcpy(side, VS_K_plTopSfPath);
   else                                         strcpy(side, VS_K_plBotSfPath);
   __DBGpr_str("Side to Unwrap ", side );

   sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                msg, side, &surf_env->obj_id,
                                &surf_env->_matrix_type, surf_env->_matrix ),
                senderid = NULL_OBJID,
                targetid = plate._objid,
                targetos = plate._osnum );
   __CheckRC( sts, *msg, "NDmacro.ACreturn_foot", wrapup );
   surf_env->_md_os = surf_env->_osnum;
   ex$get_modid( mod_osnum = surf_env->_md_os,
                 mod_id    = &surf_env->_md_id );

wrapup:
   End
   return sts;
}

IGRlong VLmatchBevelNeatEdgeWithAtt( IGRlong             *msg,
				     struct unw_obj_plat *dev,
				     IGRint		 numAtt,
				     struct GRid 	 *attIds,
				     IGRint		 numEdge,
				     struct EdgeMatch    *edgeIds  )
{
IGRlong                 sts;
IGRint                  i, j, loc_suc, tmp, is_natedge=0;
IGRdouble               thick=0.0;
IGRchar                 attrName[40];
struct ret_struct       attrVal;
struct GRid             solid_id, plate;
struct GRobj_env        curve_env, dev_surf_id;
struct IGRbsp_curve     **xyzCrvAtt, *cv;

    SetProc( VL_unw_matchBevelEdgeWithAtt ); Begin

    __DBGpr_int("Number of Bevel macros ", numAtt );
    if( !numAtt || !numEdge ) return MSSUCC;

    sts = VLunwGetDevSrfId( msg, dev, &dev_surf_id );
    __CheckRC( sts, *msg, "VLunwGetDevSrfId", wrapup );
    __DBGpr_obj("dev->surf_id ", dev_surf_id.obj_id );

    __DBGpr_objlist("Bevel Macro ", numAtt, attIds );
    __DBGpr_int("Number of Edges ", numEdge );

    xyzCrvAtt = NULL;
    cv = NULL ;
    xyzCrvAtt = (struct IGRbsp_curve **)
                 om$malloc ( size = numAtt * sizeof(IGRchar *) );
    if( xyzCrvAtt == NULL ) {
	#if DEBUG
          printf("Error in VLmatchBevelEdgeWithAtt\n");
          printf("Error in om$malloc of xyzCrvAtt\n");
	#endif
        goto wrapup;
    }

    // try to get the VLunwObj macro on the consuming child
    sts = om$get_objid_at_index(  osnum        = dev_surf_id._osnum,
                                  objid        = dev_surf_id._objid,
                                  p_chanselect = &AS_to_owner,
                                  index        = 0,
                                  objidaddr    = &solid_id.objid,
                                  osnumaddr    = &solid_id.osnum);
    __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
    __DBGpr_obj("EMS Solid ID ", solid_id );

    sts = om$get_objid_at_index( osnum        = solid_id.osnum,
                                 objid        = solid_id.objid,
                                 p_chanselect = &AS_to_owner,
                                 index        = 0,
                                 objidaddr    = &plate.objid,
                                 osnumaddr    = &plate.osnum);
   __CheckRC( sts, 1, "om$get_objid_at_index", wrapup ) ;
   __DBGpr_obj("Plate in the model ", plate );

   strcpy( attrName, VS_K_plThcknsAttr );

   sts = om$send( msg = message NDmacro.ACgive_structure(
                                &loc_suc , &tmp, attrName, &attrVal, NULL ),
                        senderid = NULL_OBJID,
                        targetid = plate.objid,
                        targetos = plate.osnum  );
   __CheckRC( sts, loc_suc, "ACgive_structure:Thickness", wrapup ) ;

   thick = attrVal.var.root_pm_st.value;
   __DBGpr_dbl("Plate Thickness ", thick );

   for(i=0;i<numAtt;i++)
   {
       xyzCrvAtt[i] = NULL;
       sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                msg, "curve", &curve_env.obj_id,
                                &curve_env._matrix_type, curve_env._matrix ),
                  senderid = NULL_OBJID,
                  targetid = attIds[i].objid,
                  targetos = attIds[i].osnum );
       if( !(sts&1&(*msg)) ) continue;
       __DBGpr_obj("Bevel Curve Foot ", curve_env.obj_id );

       if( !vs$is_ancestry_valid( object  = &curve_env.obj_id,
                                  classid = OPP_GRcurve_class_id ) ) continue;

       curve_env._md_os = attIds[i].osnum;
       sts = ex$get_modid( mod_osnum = curve_env._md_os,
                           mod_id    = &curve_env._md_id );

       sts = VLgetGeometry( &curve_env, FALSE, NULL_OBJID,
                            (IGRchar **)&xyzCrvAtt[i], msg );
       if( !(sts&1&(*msg)) ) continue;
   }

   gr$get_module_env( buffer = &curve_env.mod_env );

   for(i=0; i<numEdge; i++)
   {
      is_natedge = 0;
      edgeIds[i].EdgeMac.objid = NULL_OBJID;
      curve_env.obj_id = edgeIds[i].EdgeId ;  
      __DBGpr_obj("Edge ID ", edgeIds[i].EdgeId );

      sts = VLgetGeometry( &curve_env, FALSE, NULL_OBJID,
                            (IGRchar **)&cv, msg );
      if( !(sts&1&(*msg)) ) 
      {
	struct IGRbsp_curve  natedge_cv;

	natedge_cv.poles   = NULL;
	natedge_cv.weights = NULL;
	natedge_cv.knots   = NULL;
	natedge_cv.bdrys   = NULL;

	sts = om$send ( msg = message EMSedge.EMget_bcxyz_geom(
			msg, NULL, NULL, dev->surface, 0, OM_K_MAXINT,
			FALSE, NULL, &natedge_cv ),
		senderid = NULL_OBJID,
		targetid = edgeIds[i].EdgeId.objid,
		targetos = edgeIds[i].EdgeId.osnum  );
	if( !(sts&1&(*msg)) ) continue;
	is_natedge = 1;
	cv = &natedge_cv ;
      }
 
      for( j=0; j<numAtt; j++)
      {
        if( xyzCrvAtt[j] != NULL )
        {
            if( VLcheckEdgeProximity( xyzCrvAtt[j], cv,thick) )
            {
                edgeIds[i].EdgeMac = attIds[j];
                __DBGpr_obj("Bevel Matched ", attIds[j] );
		_FREE( xyzCrvAtt[j] );
                break;
            }
        }
      }
      if( is_natedge )
      {
	if( cv->poles ) 	_FREE( cv->poles );
	if( cv->knots )		_FREE( cv->knots );
	if( cv->bdrys )         _FREE( cv->bdrys );
	if( cv->weights )	_FREE( cv->weights );
      }
      else	_FREE( cv );
   }
   sts = *msg = MSSUCC;

wrapup:
   _FREE( cv );
   for(i=0;i<numAtt;i++) _FREE( xyzCrvAtt[i] );
   _FREE( xyzCrvAtt );

   End
   return sts;
}

IGRlong VLmatchNeatEdgeWithAtt( IGRlong             *suc,
			    struct unw_obj_plat *dev,
			    IGRint 		numAtt,
			    struct GRid		*attIds,
			    IGRint		numEdge,
			    struct EdgeMatch	*edgeIds  )
{
struct  IGRbsp_curve    **xyzCrvAtt, *cv;
        IGRint          i=0, j ,tmp=0;
        IGRlong         OmStat, msg, sts;
        IGRint          loc_suc;
struct  GRid            AS_ELEM,source,srf_prt;
struct  GRobj_env       ELEM, curve_env;
        IGRushort       options;
        char            attrName[40];
struct  ret_struct      attrVal;
        IGRdouble       thick=0.0;



/*c retrieve all the xyz edge curves attached as parents of each edge_att
    nci_macro */

        xyzCrvAtt  = NULL;
  	cv = NULL;

        xyzCrvAtt = (struct IGRbsp_curve **)
                    om$malloc ( size = numAtt * sizeof(IGRchar *) );
        if( xyzCrvAtt == NULL ) {
	  #if DEBUG
             printf("Error in VLmatchEdgeWithAtt\n");
             printf("Error in om$malloc of xyzCrvAtt\n");
	  #endif
	  goto wrapup;
        }

	gr$get_module_env( buffer = &curve_env.mod_env );

        if( numAtt > 0)
        {
                OmStat = om$send( msg = message  ACcpx.ACfind_exp_temp_obj(
                                                                 &loc_suc,
                                                                 0,
                                                                 &srf_prt ),
                                  senderid = NULL_OBJID,
                                  targetid = attIds[0].objid,
                                  targetos = attIds[0].osnum );
                if(!(OmStat&loc_suc&1) ){
		   #if DEBUG
                        printf("Error in VLmatchEdgeWithAtt\n");
                        printf("Error in ACfind_exp_temp_obj = %d\n",i);
		   #endif
                   goto wrapup;
                }

                OmStat = om$send(msg = message ACpretend.ACfind_parent(
                                                &source,NULL,NULL),
                                  senderid = NULL_OBJID,
                                  targetid = srf_prt.objid,
                                  targetos = srf_prt.osnum);

                if(!(OmStat&1) ){
		    #if DEBUG
                        printf("Error in VLmatchEdgeWithAtt\n");
                        printf("Error in ACfind_exp_temp_obj = %d\n",i);
		    #endif
                    goto wrapup;
                }

        strcpy( attrName, VS_K_plThcknsAttr );

          OmStat = om$send( msg = message NDmacro.ACgive_structure (
                                                        &loc_suc ,
                                                        &tmp,
                                                        attrName,
                                                        &attrVal,
                                                        NULL),
                        senderid = NULL_OBJID,
                        targetid = source.objid,
                        targetos = source.osnum  );

          thick = attrVal.var.root_pm_st.value;
        }

        for(i=0;i<numAtt;i++){
                xyzCrvAtt[i] = NULL;

                sts = om$send( msg = message  ACcpx.ACfind_exp_temp_obj(
                                                                 &loc_suc,
                                                                 1,
                                                                 &AS_ELEM ),
                                  senderid = NULL_OBJID,
                                  targetid = attIds[i].objid,
                                  targetos = attIds[i].osnum );
                if(!(sts&loc_suc&1) ){
		  #if DEBUG
                        printf("Error in VLmatchEdgeWithAtt\n");
                        printf("Error in ACfind_exp_temp_obj = %d\n",i);
		  #endif
		  continue;
                }

                sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        &msg ,
                                        "",
                                        &ELEM.obj_id,
                                        &ELEM.mod_env.md_env.matrix_type,
                                        ELEM.mod_env.md_env.matrix ),
                                  senderid = NULL_OBJID,
                                  targetid = AS_ELEM.objid,
                                  targetos = AS_ELEM.osnum );
                if(!(sts&msg&1) ){
		   #if DEBUG
                        printf("Error in VLmatchEdgeWithAtt\n");
                        printf("Error in ACreturn_foot = %d\n",i);
		   #endif
		   continue;
                }

                ELEM.mod_env.md_id.osnum = ELEM.obj_id.osnum;
                xyzCrvAtt[i] = NULL;
                sts = VLgetGeometry( &ELEM, (IGRboolean) FALSE, NULL_OBJID,
                                         (IGRchar **)&xyzCrvAtt[i], &msg );
                if(!(sts&msg&1)) {
		   #if DEBUG
                        printf("Error in VLmatchEdgeWithAtt\n");
                        printf("Error in VLgetGeometry = %d\n",i);
		   #endif
		   continue;
                }
        }
/*c loop on all the edge_att nci_macros to get the 3D graphic edge att and
    then performes the comparaison test.
    if no edge_att is found the  edgeIds->EdgeMac.objid is set to NULL else
    we store the edge_att GRid */

        options = 0;

            for(i=0; i<numEdge; i++){
		edgeIds[i].EdgeMac.objid = NULL_OBJID;
                /*d retrieve the xyz bspline edge */
		curve_env.obj_id = edgeIds[i].EdgeId ;
                sts = VLgetGeometry( &curve_env, (IGRboolean) FALSE, 
				NULL_OBJID, (IGRchar **)&cv, &msg );
                 if( !(sts&msg&1) ){
		   #if DEBUG
                        printf("Error in VLmatchEdgeWithAtt\n");
                        printf("Error in VLgetGeometry = %d\n",i);
		   #endif
		   continue;
                 }

                /* check which 2D edge is matching with the curve attribut */

                for(j=0; j<numAtt; j++){
                   if( xyzCrvAtt[j] != NULL ){

                        if( VLcheckEdgeProximity( xyzCrvAtt[j], cv,thick) ){
                                edgeIds[i].EdgeMac = attIds[j];
                                om$dealloc( ptr = xyzCrvAtt[j] );
                                xyzCrvAtt[j] = NULL;
                                break;
                        }
                   }
                }
		_FREE( cv );
            }/*end loop i */

        for(i=0;i<numAtt;i++){
                if( xyzCrvAtt[i] != NULL ) {
                        om$dealloc( ptr = xyzCrvAtt[i] );
                        xyzCrvAtt[i] = NULL;
                }
        }

        if( xyzCrvAtt != NULL ){
                om$dealloc( ptr = xyzCrvAtt );
                xyzCrvAtt = NULL;
        }

        *suc = MSSUCC;
        return(MSSUCC);



wrapup:
	_FREE( cv );

        for(i=0;i<numAtt;i++){
                if( xyzCrvAtt[i] != NULL ) {
                        om$dealloc( ptr = xyzCrvAtt[i] );
                        xyzCrvAtt[i] = NULL;
                }
        }

        if( xyzCrvAtt != NULL ){
                om$dealloc( ptr = xyzCrvAtt );
                xyzCrvAtt = NULL;
        }

        *suc = MSFAIL;
        return(MSFAIL);

}

IGRlong	VLunwProdEdgeMatch( IGRlong		*msg,
			    struct unw_obj_plat *dev,
			    IGRint		*numLoops,
			    IGRint		**loopIndex,
			    IGRint		*numEdges,
			    struct EdgeMatch	**edgeList )
{
IGRlong			sts, option;
IGRdouble		tol=0.0;
IGRint			i, j, is_bevel=0, numMacros=0, edgeCnt=0, nb_loopset=0,
			buf_size=0, NumLoops=0, *locLoopIndex=NULL, depth,
			total_num_edges=0, loop1_num_edges=0, CurnumEdges=0,
			loc_edge_cnt=0;
IGRushort		*props=NULL;
GRobjid			*LoopIds=NULL;
OM_S_CHANSELECT       	chanloopset;
OM_S_OBJECT_LINKAGE	listLOOPSET;
struct EdgeMatch        *locEdgeList=NULL;
struct GRobj_env	TravId, gr_obj, dev_surf_id, neatOE;
struct GRid		*macrosId=NULL, *EdgesId=NULL;
struct IGRbsp_curve	*edgeGeom[VDEFP_NEAT_EDGES_MAX];

   SetProc( VLunwProdEdgeMatch ); Begin

   vdgeom$GetTolerance(cht = &tol);
   __DBGpr_dbl("Tolerance ", tol );

   sts = VLunwGetDevSrfId( msg, dev, &dev_surf_id );
   __CheckRC( sts, *msg, "VLunwGetDevSrfId", wrapup );

   for( i=0; i<VDEFP_NEAT_EDGES_MAX; ++i ) edgeGeom[i] = NULL;

   neatOE.obj_id.objid = NULL_OBJID;
   __DBGpr_obj( "Surface ID", dev_surf_id.obj_id );
   GetNeatPlate( &dev_surf_id, &neatOE );
   __DBGpr_obj( "Neat OE", neatOE.obj_id );

   if( neatOE.obj_id.objid != NULL_OBJID )
   {
      struct GRobj_env  *edgeOEs=NULL;

      __DBGpr_com( "Getting edges from existing neat plate" );
      GetNeatEdges( &neatOE, &edgeOEs, &edgeCnt );
      __DBGpr_int("Number Of Neat Edges ", edgeCnt );
      for( i=0; i<edgeCnt; ++i )
      {
         sts = VLgetGeometry( &edgeOEs[i], FALSE, NULL_OBJID,
                              (IGRchar **)&edgeGeom[i], msg );
      }
      _FREE( edgeOEs );
   }
   else
   {
      sts = VDefpGetSurfaceEdgeBsps( &dev_surf_id, VDEFP_NEAT_EDGES_MAX,
                                     tol, &edgeCnt, edgeGeom );
      __CheckRC( sts, *msg, "VDefpGetSurfaceEdgeBsps", wrapup );
      __DBGpr_int("Number Of Neat Edges ", edgeCnt );

      if( edgeCnt == 100 )
      {
         for( i=0; i<edgeCnt; ++i )   _FREE( edgeGeom[i] );
         VDgeomGetSurfaceNaturalOuterContourGeometry( &dev_surf_id,
                                                      VDEFP_NEAT_EDGES_MAX,
                                                      &edgeCnt,
                                                      edgeGeom );
      }
   }

   chanloopset.type = OM_e_num;
   sts = om$get_channel_number( channame  = "EMSsubbs.to_loopset",
				p_channum = &chanloopset.u_sel.number );
   __CheckRC( sts, 1, "om$get_channel_number", wrapup );

   gr_obj._objid = NULL_OBJID;
   sts = om$send( msg      = message NDnode.ASreturn_go(
					&gr_obj.obj_id,
                                        &gr_obj._matrix_type,
                                        gr_obj._matrix ),
                senderid = NULL_OBJID,
                targetid = dev_surf_id._objid,
                targetos = dev_surf_id._osnum );
   if( !(sts&1) ) gr_obj = dev_surf_id ;

   /* Retrieve the loopset id */
   listLOOPSET.S_objid = NULL_OBJID;
   sts = om$get_channel_objects( osnum           = gr_obj._osnum,
				 objid           = gr_obj._objid,
				 p_chanselect    = &chanloopset,
				 size            = 1,
				 count           = (OMuint *)&nb_loopset,
				 list            = &listLOOPSET );
   __CheckRC( sts, 1, "om$get_channel_objects", wrapup );

   option  = EMS_OPT_ALL;
   LoopIds = NULL;
   props   = NULL;
   depth   = OM_K_MAXINT;
   buf_size = 0;

   sts = om$send ( msg = message EMSloopset.EMget_loops( msg,
							 option,
							 &depth,
							 &LoopIds,
							 &props,
							 &buf_size,
							 &NumLoops ),
                    senderid = NULL_OBJID,
                    targetid = listLOOPSET.S_objid,
                    targetos = listLOOPSET.osnum );
   __CheckRC( sts, *msg, "EMSloopset.EMget_loops", wrapup );
   __DBGpr_int("Total Number Of Loops ", NumLoops );
   *numLoops = NumLoops ;

   if( !( locLoopIndex = _MALLOC( NumLoops, IGRint )) ) vd_$mem_fail();
   locLoopIndex[0] = edgeCnt;

   total_num_edges = 0;
   for( i=0; i<NumLoops; ++i )
   {
      loc_edge_cnt = 0;
      sts = om$send ( msg = message EMSboundary.EMcount_edges(
					msg, option, &loc_edge_cnt ),
                    senderid = NULL_OBJID,
                    targetid = LoopIds[i],
                    targetos = listLOOPSET.osnum );
      __CheckRC( sts, *msg, "EMSboundary.EMcount_edges", wrapup );
      total_num_edges += loc_edge_cnt ;
   }
   __DBGpr_int("Number Of Natural Edges ", total_num_edges );

   sts = om$send ( msg = message EMSboundary.EMcount_edges(
                                        msg, option, &loop1_num_edges ),
                    senderid = NULL_OBJID,
                    targetid = LoopIds[0],
                    targetos = listLOOPSET.osnum );
   __CheckRC( sts, *msg, "EMSboundary.EMcount_edges", wrapup );
   __DBGpr_int("Number Of Edges on External Boundary ", loop1_num_edges );
						
   *numEdges = total_num_edges - loop1_num_edges + edgeCnt ;
   __DBGpr_int("Total number Of Edges:Calculated ", (total_num_edges - loop1_num_edges + edgeCnt) );

   if( *numEdges < 1 )
   {
        sts = *msg = MSFAIL;
        goto wrapup;
   }
   if( !( locEdgeList = _MALLOC( (total_num_edges - loop1_num_edges + edgeCnt), 			 struct EdgeMatch )) )  vd_$mem_fail();

   for( i=0; i<edgeCnt; ++i )
   {
     /* 16 Oct 2000 - added NULL env arg, edges always created in active os */
	VDdrawCurve( edgeGeom[i], NULL, &locEdgeList[i].EdgeId );
	locEdgeList[i].EdgeMac.objid = NULL_OBJID;
   }

   *numEdges = edgeCnt ;
   *edgeList = locEdgeList ;

   for( i=1; i<NumLoops; ++i )
   {
      	CurnumEdges = 0;
	buf_size    = 0;
	sts = om$send ( msg = message EMSboundary.EMget_edges(
				msg, depth, option, &EdgesId, &buf_size,
				&CurnumEdges ),
                            senderid = NULL_OBJID,
                            targetid = LoopIds[i],
                            targetos = listLOOPSET.osnum  );
	__CheckRC( sts, *msg, "EMSboundary.EMget_edges", wrapup );	

	locLoopIndex[i] = CurnumEdges;
	for( j=0; j<CurnumEdges; ++j )
	{
	   locEdgeList[(*numEdges)].EdgeId = EdgesId[j] ;
	   locEdgeList[(*numEdges)].EdgeMac.objid = NULL_OBJID;
	   (*numEdges)++;
	}

	_FREE( EdgesId );
   }
   __DBGpr_int("Total number Of Edges:Got ", *numEdges );
   *loopIndex = locLoopIndex;
   _FREE( props   );
   _FREE( EdgesId );
   _FREE( LoopIds );

   /* We retieve now all the nci_macros edge_attr attach to the surface */
   as$make_source( go_grid = dev_surf_id.obj_id,
                   mod_env = &dev_surf_id.mod_env,
                   as_grid = &TravId.obj_id);

   sts = VLgetChildrenMacro( TravId, "VSedge3Datt",
                              &numMacros, &macrosId, &dev->res_id );
   __CheckRC( sts, 1, "VLgetChildrenMacro", wrapup );

   if( numMacros == 0 )
   {
       IGRint        loc_nb_mac=0;
       struct GRid   *loc_mac=NULL;

       numMacros = 0;
       _FREE( macrosId ) ;
       sts = VLgetChildrenMacro( TravId, "Bevel",
                                  &loc_nb_mac, &loc_mac, &dev->res_id );
       if( sts != MSSUCC ){
	 #if DEBUG
            printf("Error in VLedgeMatch \n");
            printf("VLgetChildrenMacro Failed\n");
	 #endif
       }
       __DBGpr_int("Number of Bevel macros ", loc_nb_mac );
       if( loc_nb_mac )
       {
          is_bevel = TRUE;
          if( macrosId ) macrosId = _REALLOC( macrosId,
                          (numMacros+loc_nb_mac), struct GRid );
          else  macrosId = _MALLOC( loc_nb_mac, struct GRid ) ;

          for( i=0; i<loc_nb_mac; ++i ) macrosId[numMacros+i] = loc_mac[i] ;
          numMacros += loc_nb_mac;
	  loc_nb_mac = 0;
	  _FREE( loc_mac );
       }
       sts = VLgetChildrenMacro( TravId, "EJ_Bevel",
                                  &loc_nb_mac, &loc_mac, &dev->res_id );
       if( sts != MSSUCC ){
            printf("Error in VLedgeMatch \n");
            printf("VLgetChildrenMacro Failed\n");
       }
       __DBGpr_int("Number of EJ_Bevel macros ", loc_nb_mac );
       if( loc_nb_mac )
       {
          is_bevel = TRUE;
          if( macrosId ) macrosId = _REALLOC( macrosId,
                          (numMacros+loc_nb_mac), struct GRid );
          else  macrosId = _MALLOC( loc_nb_mac, struct GRid ) ;

          for( i=0; i<loc_nb_mac; ++i ) macrosId[numMacros+i] = loc_mac[i] ;
          numMacros += loc_nb_mac;
          loc_nb_mac = 0;
          _FREE( loc_mac );
       }

       sts = VLgetChildrenMacro( TravId, "VA_Bevel",
                                  &loc_nb_mac, &loc_mac, &dev->res_id );
       if( sts != MSSUCC ){
            printf("Error in VLedgeMatch \n");
            printf("VLgetChildrenMacro Failed\n");
       }
       __DBGpr_int("Number of VA_Bevel macros ", loc_nb_mac );
       if( loc_nb_mac )
       {
          is_bevel = TRUE;
          if( macrosId ) macrosId = _REALLOC( macrosId,
                          (numMacros+loc_nb_mac), struct GRid );
          else  macrosId = _MALLOC( loc_nb_mac, struct GRid ) ;

          for( i=0; i<loc_nb_mac; ++i ) macrosId[numMacros+i] = loc_mac[i] ;
          numMacros += loc_nb_mac;
          loc_nb_mac = 0;
          _FREE( loc_mac );
       }

       sts = VLgetChildrenMacro( TravId, "Fab_Stock",
                                  &loc_nb_mac, &loc_mac, &dev->res_id );
       if( sts != MSSUCC ){
            printf("Error in VLedgeMatch \n");
            printf("VLgetChildrenMacro Failed\n");
       }
       __DBGpr_int("Number of Fab_Stock macros ", loc_nb_mac );
       if( loc_nb_mac )
       {
          is_bevel = TRUE;
          if( macrosId ) macrosId = _REALLOC( macrosId,
                          (numMacros+loc_nb_mac), struct GRid );
          else  macrosId = _MALLOC( loc_nb_mac, struct GRid ) ;

          for( i=0; i<loc_nb_mac; ++i ) macrosId[numMacros+i] = loc_mac[i] ;
          numMacros += loc_nb_mac;
          loc_nb_mac = 0;
          _FREE( loc_mac );
       }
       __DBGpr_int("Total Number of Bevel macros ", numMacros );
       __DBGpr_objlist("Bevel Macros ", numMacros, macrosId );
    }

    if( numMacros )
    {
        for( i=0; i<(*numEdges); ++i )
        	locEdgeList[i].EdgeMac.objid = NULL_OBJID;

	if( is_bevel )
	{
	   sts = VLmatchBevelNeatEdgeWithAtt( msg, dev, numMacros, macrosId,
					      *numEdges, locEdgeList );
	   __CheckRC( sts, *msg, "VL_unw_matchBevelEdgeWithAtt", wrapup );
	}
	else
	{	
	   sts = VLmatchNeatEdgeWithAtt( msg, dev, numMacros, macrosId,
				         *numEdges, locEdgeList );
	   __CheckRC( sts, *msg, "VL_unw_matchEdgeWithAtt", wrapup );
	}
    }
    else
    {
	for( i=0; i<edgeCnt; ++i ) locEdgeList[i].EdgeMac.objid = NULL_OBJID;
    }

wrapup:
   _FREE( props    );
   _FREE( EdgesId  );
   _FREE( LoopIds  );
   _FREE( macrosId );
   for( i=0; i<edgeCnt; ++i ) 	_FREE( edgeGeom[i] );

   End
   return sts;	
}	

IGRlong   VLunwCreateProdBoundWithOff(
IGRlong			*msg,	    /*O Return Code */
struct  unw_obj_plat    *dev,       /*I structure containing the informations */
struct  GRvg_construct  *cst,       /*I construction list */
IGRchar			*file_name, /*I Setup File Name */
IGRboolean      	add_stock,  /*I Add Stock? */
IGRint          	*numBnd,    /*O number of loop objects return */
struct  GRobj_env       **bndObj,   /*O loop objects return */
IGRint  		*numEdges,  /*O total number of edges */
struct  EdgeMatch       **edgeList, /*O the edge list  containing the unwraped
                                        edge ID and the edge_attribut macro
                                        matching with */
IGRint             	*nb_old_crvs,
struct  GRid    	**old_crvs 	)
{
IGRshort		TypeOfCurve;
IGRuchar		props;
IGRint			i, j, k, ie, ii, OuiNon, NumCmp=0, *LoopIndex=NULL;
IGRlong 		sts;
IGRdouble		exp_diameter, info[4], bid[6], xaxis[3], *OfVal=NULL,
			inner_crv_len;
IGRboolean		isRevNorm=FALSE, isInsideOut1 = TRUE, isReverse,
			isInsideOut2 = FALSE, bool,bool0;
IGRchar			test_str[80], str_diameter[80], str_buf[100];
struct GRid		plt_surf, *CmpLst=NULL;
struct GRobj_env	par_plate, StrID, dev_surf_id, *LcCv=NULL;
struct IGRbsp_curve     **edgeCv=NULL, **CmpCv=NULL, *inner_crv=NULL;
VSpartAttr              pltAttr ;
VSplateAttr             pltInfo ;
struct IGRplane         plane;
FILE			*setup_file=NULL;

   SetProc( VLunwCreateProdBoundWithOff ); Begin

   exp_diameter = 0.0;
   bool0        = FALSE;

   setup_file = VLunwOpenSetupFilex( file_name, NULL );
   if( setup_file == NULL )
   {
	printf("Setup file not found: %s\n", file_name );
	goto get_edges;
   }

   __DBGpr_str("Opened Setup File ", file_name );

   sts = VLunwGetDevSrfId( msg, dev, &dev_surf_id );
   __CheckRC( sts, *msg, "VLunwGetDevSrfId", wrapup );

   while( fgets( str_buf, sizeof(str_buf), setup_file ) ) 
   {
	sscanf( str_buf, "%s %s", test_str, str_diameter );
	if( !strcmp( test_str, "#INNER_CUTOUT_EXPANSION_DIAMETER" ) )
	{
	   exp_diameter = atof( str_diameter );
	   break;
	}
   }

   fclose( setup_file );

get_edges:

   __DBGpr_dbl("Inner Cutout Expansion Diameter ", exp_diameter );

   sts = VLunwProdEdgeMatch( msg, dev, numBnd, &LoopIndex, 
			     numEdges, edgeList );
   __CheckRC( sts, *msg, "VLunwProdEdgeMatch", wrapup );
   if( *numEdges < 1 )
   {
        sts = *msg = MSFAIL;
        goto wrapup;
   }

#if DEBUG
   for( i=0; i<(*numEdges); ++i )
   {
      printf("\n Edge ID = %d, %d, Macro = %d, %d",
             (*edgeList)[i].EdgeId.objid, (*edgeList)[i].EdgeId.osnum,
             (*edgeList)[i].EdgeMac.objid, (*edgeList)[i].EdgeMac.osnum );
   }
#endif

   if( !( *bndObj = _MALLOC( *numBnd, struct GRobj_env )) ) vd_$mem_fail();
   for(i=0;i<(*numBnd);i++) (*bndObj)[i].obj_id.objid = NULL_OBJID;

   if( !( LcCv = _MALLOC( *numEdges, struct GRobj_env )) ) vd_$mem_fail();
   for(i=0;i<(*numEdges);i++) LcCv[i].obj_id.objid = NULL_OBJID;

   k = 0;

   for(i=0; i<(*numBnd); i++ )
   {
      for( j=0; j<LoopIndex[i]; ++j )
      {
	if (dev->developpable == 1)
	{
	    /* 	Surface is planar then we just copy the edges and
		set the active level */
	    sts = vs$get_graphic_edge( 	msg     = msg,
					edId    = &((*edgeList)[k].EdgeId),
					edEnv   = &(dev_surf_id.mod_env),
					copy    = TRUE,
					copyEnv = cst->env_info,
					grEdge  = &(StrID.obj_id)) ;
	    if( !(sts&1) ) StrID.obj_id = (*edgeList)[k].EdgeId;
	    StrID.mod_env = *(cst->env_info);
	
	    sts =  om$send( msg = message GRvg.GRchglevel( msg,
					(IGRshort *) &(cst->level) ),
                                senderid = NULL_OBJID,
                                targetid = StrID.obj_id.objid,
                                targetos = StrID.obj_id.osnum ) ;
	    __CheckRC( sts, *msg, "GRvg.GRchglevel", wrapup );	    
	}
	else
	{
	    /*  Surface is not planar. For each 3D edge build the 
		corresponding unwraped edge */

	    sts = VLbuildNeatUnwrapEdge( msg, dev, &(*edgeList)[k].EdgeId, 
			                 cst, &StrID );
	    __CheckRC( sts, *msg, "VL_unw_buildUnwrapEdge", deldel );

            sts = om$send( msg = message GRgraphics.GRdelete(msg,cst->env_info),
                     senderid = NULL_OBJID,
                     targetid = (*edgeList)[k].EdgeId.objid,
                     targetos = (*edgeList)[k].EdgeId.osnum );
	}
	LcCv[j].obj_id = StrID.obj_id;
	(*edgeList)[k].EdgeId = StrID.obj_id;
	memcpy ( (IGRchar *)&LcCv[j].mod_env, (IGRchar *)cst->env_info,
		 (IGRint)sizeof( struct GRmd_env) );
	++k;
      }
      /* Construct a composite curve if the loop contains more than one edge */
      if( LoopIndex[i] > 1 )
      {
	IGRshort                Orient[VDEFP_NEAT_EDGES_MAX];
	struct GRid             newCrv ;
	struct GRlc_info        outCrvs[VDEFP_NEAT_EDGES_MAX];
	IGRint                  o ;
	IGRboolean              adjNeeded = TRUE, phyClosed = FALSE ;

	cst->geometry = NULL;
	(*bndObj)[i].obj_id.objid = NULL_OBJID;
	(*bndObj)[i].obj_id.osnum = cst->env_info->md_id.osnum;
	TypeOfCurve = 3;
	for( o=0 ; o<LoopIndex[i]; o++ ) Orient[o]=1;
	newCrv.objid = NULL ;
	BuildCrv( TypeOfCurve, LcCv, LoopIndex[i], Orient, adjNeeded, 
		  phyClosed, outCrvs, cst, &newCrv, msg );
	if( *msg == BSSUCC )
	{
	   (*bndObj)[i].obj_id  = newCrv ;
	   (*bndObj)[i].mod_env = *(cst->env_info);
	}
	else
	{
	   *msg=MSFAIL;
	   goto deldel;
	}
	continue ;
      }
      else
      {
	(*bndObj)[i].obj_id  = LcCv[0].obj_id;
	(*bndObj)[i].mod_env = *(cst->env_info);
      }
   }

  /*c retrieve the offset values strored in the edge_att */
  if( !( OfVal = _MALLOC( *numEdges, IGRdouble )) ) vd_$mem_fail();

  for(i=0;i<(*numEdges);i++){
        if( (*edgeList)[i].EdgeMac.objid != NULL_OBJID && add_stock ){
                VLretOfVal( &((*edgeList)[i].EdgeMac),
                             &(OfVal[i]), msg );
                if( (*msg) != MSSUCC ){
		   #if DEBUG
                        printf("Error in VL_unw_creBoundWithOff\n");
                        printf( "VLretOfVal Failed for loop=%d: \n",i );
		   #endif
                        goto deldel;
                }
        }
        else OfVal[i] = 0.0;
  }
  #ifdef DEBUG
  __DBGpr_double("OfVal",OfVal,1,(*numEdges));
  #endif


  as$make_source(go_grid = dev_surf_id.obj_id,
                 mod_env = &dev_surf_id.mod_env,
                 as_grid = &plt_surf            );

  if( vs$is_ancestry_valid( object  = &plt_surf,
                                   classid = OPP_ACpretend_class_id )){

      sts   = om$send(  msg     = message ACpretend.ACfind_parent(
                                        &par_plate.obj_id,
                                        &par_plate.mod_env.md_env.matrix_type,
                                        par_plate.mod_env.md_env.matrix ),
                 senderid = NULL_OBJID,
                 targetid = plt_surf.objid,
                 targetos = plt_surf.osnum ) ;
  }
  pltAttr.Iwant    = VS_m_Orientation ;
  pltAttr.specific = (void *) &pltInfo ;
  sts = om$send(  msg     = message GRvg.GRgetattr( msg,
                                                       (char *) &pltAttr ),
                        senderid = NULL_OBJID,
                        targetid= par_plate._objid,
                        targetos= par_plate._osnum ) ;

  if( pltInfo.orientation == VS_K_USE_REV_NORM ) isRevNorm = TRUE;

  plane.point  = (IGRdouble *)&bid[0];
  plane.normal = (IGRdouble *)&bid[3];

  bid[3] = bid[4] = bid[5] = 0. ;

  sts = om$send( msg = message GRvg.GRdetplane(
                                        msg,
                                        &(*bndObj)[0]._matrix_type,
                                        (*bndObj)[0]._matrix,
                                        &plane ),
                         senderid = NULL_OBJID,
                         targetid = (*bndObj)[0]._objid,
                         targetos = (*bndObj)[0]._osnum );

  sts = om$send ( msg = message EMSsubbs.EMget_props
                                         ( msg, &props ),
                      senderid = NULL_OBJID,
                      targetid = dev_surf_id.obj_id.objid,
                      targetos = dev_surf_id.obj_id.osnum );

  if( !(props & EMSIS_NRML_REVERSED) || isRevNorm )
  {
      if( (fabs(bid[3])-1) < 0.001 &&
           fabs(bid[4])    < 0.001 &&
           fabs(bid[5])    < 0.001    )
      {
          if (BSdotp ( msg, &bid[3], xaxis) < 0.0) {
             isReverse = TRUE;
             // isInsideOut1 = FALSE;
             // isInsideOut2 = TRUE;
          }
      }
      else
      {
          isReverse = TRUE;
      }
  }

  /*c apply the offset values on each loop if needed */

  j  = 0;
  ie = 0;
  __DBGpr_int("Number of Boundaries ", (*numBnd) );
  for(i=0; i<(*numBnd); i++ ){

        ie += LoopIndex[i];

        VLisOffNeeded( OfVal, j, ie, &OuiNon );

/*
        if( i>0 )
        {
            GRobjid 	tmp_id;
  	    IGRpoint 	center;

	    __DBGpr_int("Offsetting Inner Contour", i );
	    _FREE( inner_crv );
	    vdgeom$Get2( objOE = &(*bndObj)[i], crv = &inner_crv );

  	    // Force it to be precisly closed
  	    VDgeomCloseCurve(inner_crv);

  	    // Need center
  	    VDgeomGetSymCrvCenter(inner_crv,center);
	    __DBGpr_vec("Inner Contour Center ", center );
 
  	    // Expand it
  	    VDgeomExpandSymCrv(inner_crv,center, exp_diameter/2.0 );

	    // Create a Bspline Curve
	    VDdrawCurve( inner_crv, cst->env_info, &(*bndObj)[i].obj_id );
	    (*bndObj)[i].mod_env = *cst->env_info;
            sts = om$send(msg = message GRgraphics.GRcopy(
                                                msg,
                                                &(*bndObj)[i].mod_env,
                                                cst->env_info,
                                                &tmp_id ),
                                senderid = NULL_OBJID,
                                targetid = (*bndObj)[i].obj_id.objid,
                                targetos = (*bndObj)[i].obj_id.osnum );
            if (!(sts&(*msg)&1)) {
                goto wrapup;
            }
            (*bndObj)[i].obj_id.objid = tmp_id;
            (*bndObj)[i].obj_id.osnum = cst->env_info->md_id.osnum;
            (*bndObj)[i].mod_env = *cst->env_info;
            // OuiNon = FALSE;
        }
*/

	__DBGpr_int("Offset Needed? ", OuiNon );

        if( OuiNon == TRUE ){
          bool = TRUE;

          if (i==0) {
                VLoffset_Cv( &(*bndObj)[i], cst, (IGRboolean)isInsideOut1,
                   (IGRdouble *)NULL, LoopIndex[i], &(OfVal[j]),
                   info, (IGRboolean)FALSE, &StrID, nb_old_crvs, old_crvs, msg);
                bool0 = TRUE;
          }
          else
	  {
            __DBGpr_dbl("Offset Value ", OfVal[j] );
            VLoffset_Cv( &(*bndObj)[i], cst, (IGRboolean)isInsideOut2,
               (IGRdouble *)NULL, LoopIndex[i], &(OfVal[j]),
               NULL, (IGRboolean)FALSE, &StrID, nb_old_crvs, old_crvs, msg);
            __DBGpr_int("Number Of Old Curves ", *nb_old_crvs );
	  }

          if( (*msg) != MSSUCC ){
	     #if DEBUG
                printf("Error in VL_unw_creBoundWithOff\n");
                printf( "VLoffset_Cv Failed for loop=%d: \n",i );
	     #endif
             goto deldel;
          }
          (*bndObj)[i] = StrID;
        }
	else StrID = (*bndObj)[i];
	

	/* ----------------------------------------------
	 * ah - For now, always run this even if the expansion is zero
	 * This ensures the parametric processing is done
	 * Even the non-spades unwraps will want the curves to be
	 * as light as possible
	 */
        //if( (i>0) && (exp_diameter > 0.0001) )

        if (i > 0)
        {
           IGRpoint    center;
	   TVDgeomSym  sym;
	   
           __DBGpr_int("Offsetting Inner Contour", i );
           _FREE( inner_crv );

           __DBGpr_int("Applying Inner Cutout Expansion Diameter ", i );
           vdgeom$Get2( objOE = &StrID, crv = &inner_crv );

           // Force it to be precisly closed
           VDgeomCloseCurve(inner_crv);

           // Need center
           VDgeomGetSymCrvCenter(inner_crv,center);
           __DBGpr_vec("Inner Contour Center ", center );

           // Expand it	   
           VDgeomExpandSymCrv(inner_crv,center, exp_diameter/2.0 );

	   // Make it parametric
	   // Note: no need to free the sym buffer, it's fixed length
	   // in the sym structure.
	   // Commented this part of the code temporarily, since it is
 	   // changing the order of poles.
	   //VDgeomIsCrvSym(inner_crv,0.0,&sym);

	   // Delete the old curve
           om$send( msg = message GRgraphics.GRdelete(msg,cst->env_info),
		     senderid = NULL_OBJID,
                     targetid = StrID.obj_id.objid,
                     targetos = StrID.obj_id.osnum  );

	   /* 16 Oct 2000 - Added env */
  	   VDdrawCurve( inner_crv, cst->env_info, &StrID.obj_id ); 
	   (*bndObj)[i] = StrID;
        }
        j = ie;

  }

  if (bool == TRUE) {
  j=0;
  for(i=0; i<(*numBnd); i++ ){
     if (LoopIndex[i] > 1) {
        sts = om$send( msg      = message GRowner.GRget_number_components(
                                                                msg,
                                                                &NumCmp ),
                          senderid = NULL_OBJID,
                          targetid = (*bndObj)[i].obj_id.objid,
                          targetos = (*bndObj)[i].obj_id.osnum );
        if (!(sts&(*msg)&1)) {
	  #if DEBUG
                printf("Error in VL_unw_creBoundWithOff\n");
                printf( "GRget_number_components\n");
	  #endif
	  if( i == 0 ) 		goto deldel;
	  else			NumCmp = 1;
        }
     }
     else NumCmp = 1;

        if (j < NumCmp) j = NumCmp;
   }
   if( !( CmpLst = _MALLOC( j, struct GRid )) ) vd_$mem_fail();
   CmpCv = (struct  IGRbsp_curve **)
                  om$malloc( size =  j * sizeof( struct IGRbsp_curve *) );
   if( CmpCv == NULL ){
      #if DEBUG
           printf("Error in VL_unw_creBoundWithOff\n");
           printf("malloc CmpCv : Failed\n");
      #endif
      goto deldel;
   }
   edgeCv = (struct  IGRbsp_curve **)
                  om$malloc( size =  j * sizeof( struct IGRbsp_curve *) );
   if( edgeCv == NULL ){
	#if DEBUG
           printf("Error in VL_unw_creBoundWithOff\n");
           printf("malloc edgeCv : Failed\n");
	#endif
        goto deldel;
   }
   for (k=0;k<j;k++) edgeCv[k] = CmpCv[k] = NULL;

  k = 0;
  for(i=0; i<(*numBnd); i++ ){
    if (i==0) {
      sts = VLreparameter_off_curve(&(*bndObj)[i],LoopIndex[i],
                                       &((*edgeList)[k]), &OfVal[k],info,
                                       CmpLst,CmpCv,edgeCv,cst,TRUE);
      if (bool0) {
           for (ii=0; ii<LoopIndex[0];ii++)
           om$send( msg = message GRgraphics.GRdelete(msg,cst->env_info),
                     targetid = LcCv[ii].obj_id.objid,
                     targetos = LcCv[ii].obj_id.osnum,
                     senderid = NULL_OBJID ) ;
      }
    }
    else {
      sts = VLreparameter_off_curve(&(*bndObj)[i],LoopIndex[i],
                                       &((*edgeList)[k]), &OfVal[k],NULL,
                                       CmpLst,CmpCv,edgeCv,cst,FALSE);
      }
    // if (!(sts&1)) goto deldel;
    k += LoopIndex[i];
  }
 }

 for(i=1; i<(*numBnd); i++ )
 {
    _FREE( inner_crv );

    vdgeom$Get2( objOE = &(*bndObj)[i], crv = &inner_crv );

    vdgeom$GetCrvArcLen( crv = inner_crv, len = &inner_crv_len );

    if( inner_crv_len < 0.01 )
    {
        om$send( msg = message GRgraphics.GRdelete(msg,cst->env_info),
                 senderid = NULL_OBJID,
                 targetid = (*bndObj)[i].obj_id.objid,
                 targetos = (*bndObj)[i].obj_id.osnum  );
        (*bndObj)[i].obj_id.objid = NULL_OBJID;
    }
 }

 k = *numBnd ;
 *numBnd = 1;
 for(i=1; i<k; i++ )
 {
    if( (*bndObj)[i].obj_id.objid != NULL_OBJID )
    {
        (*bndObj)[(*numBnd)] = (*bndObj)[i];
        (*numBnd)++;
    }
 }

 cst->geometry = NULL;
 _FREE( LoopIndex );
 _FREE( OfVal  ) ;
 _FREE( CmpLst ) ;
 _FREE( CmpCv  ) ;
 _FREE( edgeCv ) ;
 _FREE( LcCv   ) ;
 _FREE( inner_crv );

 	#if DEBUG
           printf("Returning Success\n");
 	#endif

        *msg = MSSUCC;
	End
        return(MSSUCC);

deldel:

        /*c delete the composite curve which could have been already evaluated*/
        for( k=0; k<(*numBnd); k++ ){
        if( (*bndObj)[k].obj_id.objid != NULL_OBJID )
        sts = om$send( msg = message GRgraphics.GRdelete(msg,cst->env_info),
                     targetid = (*bndObj)[k].obj_id.objid,
                     targetos = (*bndObj)[k].obj_id.osnum,
                     senderid = NULL_OBJID ) ;
        }

        for( k=0; k<LoopIndex[0]; k++ )
        {
           sts = om$send( msg = message GRgraphics.GRdelete(msg,cst->env_info),
		     senderid = NULL_OBJID,
                     targetid = (*edgeList)[k].EdgeId.objid,
                     targetos = (*edgeList)[k].EdgeId.osnum );
        }

wrapup:
 _FREE( LoopIndex );
 _FREE( OfVal );
 _FREE( CmpLst );
 _FREE( CmpCv );
 _FREE( edgeCv );
 _FREE( LcCv );
 _FREE( *bndObj );
 _FREE( *edgeList );
 _FREE( inner_crv );

 *numEdges = 0;
 *numBnd   = 0;
 #if DEBUG
	printf("Returning Failure\n");
 #endif
 *msg = MSFAIL;
 End
 return(MSFAIL);
}

end implementation VDSroot;
