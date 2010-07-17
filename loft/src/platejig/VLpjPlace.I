/* $Id $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        src/platejig/VLpjPlace.I
 *
 * Description: Plate Jigs Implementation.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/02/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include <math.h>
#include "bserr.h"
#include "bsparameters.h"
#include "bsxtractpar.h"
#include "bsdistptpt.h"
#include "bsproj1.h"
#include "bstst_plan.h"
#include "bscvmidpt.h"
#include "EMSmsgdef.h"
#include "emssfintdef.h"
#include "VDobj.h"
#include "VDexp.h"
#include "VDgeom.h"
#include "VDmem.h"
#include "VDchn.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "vsedgedef.h"
#include "vsgeommacros.h"
#include "vsedgemacros.h"
#include "vsplatedef.h"
#include "vlplatejig.h"
#include "vlpltjigset.h"
#include "vldbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

#define GAP_TOL		20.0
#define PJ_SLOT_MACRO 	"pljig_slot"

from SMframe		import		SMfind_frm_syst;
from SMfrm_syst		import		SMfind_all_frame;
from ACrg_collect	import		ACget_named_attribute, AClist_attribute;
from ci_macro           import          init;
from EMSproject		import		EMplace_surface_of_projection;
from EMSsurface		import		EMintsurf_saveside, EMgetactiveid;
from EMSdpr		import		EMmake_primitive1;
from EMSsubbs		import		EMreduce_range;

extern GRclassid	OPP_GR3dlineseg_class_id, OPP_nci_macro_class_id,
			OPP_expression_class_id, OPP_ACrg_collect_class_id,
			OPP_EMSproject_class_id;

IGRlong	    VLpjGetNamedAttibute(	IGRlong             *msg,
					struct GRid    	    *mgrID,
					struct ACrg_coll    *attr  )
{
IGRlong			sts;
struct GRobj_env	boxOE;

   sts = *msg = MSSUCC;
   boxOE._objid = NULL_OBJID;

   vdobj$GetTemplate( objID      = mgrID,
                      nth        = 2,
                      templateOE = &boxOE );
   if( boxOE._objid == NULL_OBJID ) { *msg = MSFAIL; goto wrapup; }

   sts = om$send(  msg      = message ACrg_collect.ACget_named_attribute(
						msg, attr ),
		   senderid = NULL_OBJID,
                   targetid = boxOE._objid,
                   targetos = boxOE._osnum  );
wrapup:
   return sts;
}
					

IGRlong     VLpjGetFramesInFreeGrid(        IGRlong             *msg,
                                            struct GRobj_env    *frmOE,
                                            IGRint              num_pl,
                                            struct GRobj_env    *pltOE,
					    IGRdouble		spacing,
					    IGRint		*negative,
					    IGRint		*positive,
					    IGRint		*fr_index,
					    IGRint		*pltCnt,
					    struct GRobj_env    *pltList )
{
BSrc                    rc;
IGRlong                 sts;
IGRint                  i, index, in_range;
IGRdouble               dotp, point[3], normal[3], axis[3];
IGRboolean              not_first;
GRrange                 range, loc_range;
struct GRobj_env        footOE;
struct IGRplane         plane;

   SetProc( VLpjGetFramesInFreeGrid ); Begin

   if( negative )	*negative = -1;
   if( positive )	*positive = -1;
   if( pltCnt   )	*pltCnt   =  0;

   not_first = in_range = FALSE ;
   for( i=0; i<num_pl; ++i )
   {
      vdobj$GetFoot( objOE    = &pltOE[i],
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

   plane.point  = point;
   plane.normal = normal;

   vdobj$GetFoot( objOE    = frmOE,
                  footName = "plane",
                  footOE   = &footOE );

   sts = om$send( msg = message GRvg.GRdetplane( msg, &footOE._matrix_type,
                              footOE._matrix, &plane ),
                  senderid = NULL_OBJID,
                  targetid = footOE._objid,
                  targetos = footOE._osnum );
   __CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;
   __DBGpr_vec("Frame Point ", point );
   __DBGpr_vec("Frame Normal ", normal );

   dotp = 0.0;
   for( i=0; i<3; ++i )
   {
        axis[0] = axis[1] = axis[2] = 0.0 ;
        axis[i] = 1.0;
        if( fabs(BSdotp( &rc, normal, axis )) > dotp )
        {
           dotp = fabs(BSdotp( &rc, normal, axis ));
           index = i;
        }
   }
   __DBGpr_int("Frame Normal Direction ", index );

   if( (point[index] >= range[index]) && (point[index] <= range[3+index]) )
   	in_range = TRUE;
   __DBGpr_int("Input Frame In Range? ", in_range );

   if( !in_range ) goto wrapup;

   __DBGpr_dbl("Spacing Value ", spacing );

   if( negative )
	*negative = (int) (floor((( point[index] - range[index] )/spacing ) ) );

   if( positive ) 
   	*positive = (int) (floor((( range[3+index] - point[index] )/spacing )));

   if( !fr_index || !pltCnt || !pltList )  goto wrapup;

   __DBGpr_int("Checking Frame Index ", *fr_index );

   for( i=0; i<num_pl; ++i )
   {
      vdobj$GetFoot( objOE    = &pltOE[i],
                     footName = VS_K_plGrCmpName,
                     footOE   = &footOE );
      if( footOE.obj_id.objid == NULL_OBJID ) continue;

      vs$getRangeOfComposite( msg       = msg,
                              composite = &footOE,
                              range     = loc_range );

      if( ((point[index]+((*fr_index)*spacing)) >= loc_range[index]) && 
          ((point[index]+((*fr_index)*spacing)) <= loc_range[3+index]) )
      {
	 pltList[(*pltCnt)++] = pltOE[i];
      }
   }
   __DBGpr_int("Number of Plates in Range ", *pltCnt );

wrapup:
   End
   return sts;
}

VLpppProcessCutouts()
{
IGRlong         msg;
IGRint          nbFoundMacs, nbSuccessOps;
IGRchar         **macName=NULL, *badOperatorInMacDef=NULL;

  if( macName = _CALLOC( 2, char * ) )
  {
     macName[0] =  PJ_SLOT_MACRO ;
     VSfindCutOuts( &msg, 0, NULL, 1, macName, &nbFoundMacs,
                    &nbSuccessOps, &badOperatorInMacDef );

     _FREE( badOperatorInMacDef );
     VSfreeList( 1, macName ) ;
  }

  return 1;
}

IGRlong		VLpjGetFramesInPlatesRange( IGRlong		*msg,
					    struct GRobj_env	*frmOE,
					    IGRint		num_pl,
					    struct GRobj_env	*pltOE,
					    IGRboolean		*in_range,
					    IGRint		*frmCnt,
					    struct GRid		**frmList )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, index, nb_frames=0;
IGRdouble		dotp, point[3], normal[3], axis[3];
IGRboolean		not_first;
GRrange			range, loc_range;
struct GRid             Fsyst, *frames=NULL;
struct GRobj_env	footOE;
struct IGRplane		plane;

   SetProc( VLpjGetFramesInPlatesRange ); Begin

   if( !frmOE || !num_pl || !pltOE ) 		return OM_E_INVARG;
   if( !in_range && ( !frmCnt || !frmList ) ) 	return OM_E_INVARG;

   if( in_range)  	*in_range = FALSE;
   if( frmCnt  )	*frmCnt   = 0;
   if( frmList )	*frmList  = NULL;

   not_first = FALSE ;
   for( i=0; i<num_pl; ++i )
   {
      vdobj$GetFoot( objOE    = &pltOE[i],
		     footName = VS_K_plGrCmpName,
		     footOE   = &footOE );
      if( footOE.obj_id.objid == NULL_OBJID ) continue;

      vs$getRangeOfComposite( msg	= msg,
			      composite = &footOE,
			      range	= loc_range );
      if( not_first ) GRaccumulate_range( msg, loc_range, range );
      else
      {
	  not_first = TRUE ;
	  dblcpy( range, loc_range, 6 );
      }
   }
   __DBGpr_vec("Low Range point ", &range[0] );
   __DBGpr_vec("High Range point ", &range[3] );

   plane.point  = point;
   plane.normal = normal;

   vdobj$GetFoot( objOE    = frmOE,
                  footName = "plane",
                  footOE   = &footOE ); 

   sts = om$send( msg = message GRvg.GRdetplane( msg, &footOE._matrix_type,
                              footOE._matrix, &plane ),
                  senderid = NULL_OBJID,
                  targetid = frmOE->_objid,
                  targetos = frmOE->_osnum );
   __CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;
   __DBGpr_vec("Frame Point ", point );
   __DBGpr_vec("Frame Normal ", normal );

   dotp = 0.0;
   for( i=0; i<3; ++i )
   {
	axis[0] = axis[1] = axis[2] = 0.0 ;
        axis[i] = 1.0;
	if( fabs(BSdotp( &rc, normal, axis )) > dotp )
	{
	   dotp = fabs(BSdotp( &rc, normal, axis ));
	   index = i;
	}
   }
   __DBGpr_int("Frame Normal Direction ", index );

   if( (point[index] >= range[index]) && (point[index] <= range[3+index]) )
	if( in_range )		*in_range = TRUE;
   if( in_range ) __DBGpr_int("Input Frame In Range? ", *in_range );
  
   if( !frmCnt || !frmList )	goto wrapup;

   sts = om$send( msg = message SMframe.SMfind_frm_syst( msg, &Fsyst ),
		  senderid = NULL_OBJID,
		  targetid = frmOE->_objid,
		  targetos = frmOE->_osnum );
   __CheckRC( sts, *msg, "SMframe.SMfind_frm_syst", wrapup ) ;
   __DBGpr_obj("Frame System Object ID ", Fsyst );

   sts = om$send( msg = message SMfrm_syst.SMfind_all_frame( msg, &frames,
				NULL, &nb_frames, NULL, NULL ),
                  senderid = NULL_OBJID,
                  targetid = Fsyst.objid,
                  targetos = Fsyst.osnum );
   __CheckRC( sts, *msg, "SMfrm_syst.SMfind_all_frame", wrapup ) ;
   __DBGpr_int("Number of frames ", nb_frames );   

   if( !( *frmList = _MALLOC( nb_frames, struct GRid ) ) ) vd_$mem_fail();

   for( i=0; i<nb_frames; ++i )
   {
      vdobj$GetFoot( objID    = &frames[i],
                     footName = "plane",
                     footOE   = &footOE );
      if( footOE.obj_id.objid == NULL_OBJID ) continue;

      sts = om$send( msg = message GRvg.GRdetplane( msg, &footOE._matrix_type,
				footOE._matrix, &plane ),
                  senderid = NULL_OBJID,
                  targetid = frames[i].objid,
                  targetos = frames[i].osnum );
      if( !(sts&1&(*msg)) ) 	continue;

      if( (point[index] >= range[index]) && (point[index] <= range[3+index]) )
      {
	(*frmList)[(*frmCnt)++] = frames[i];
      }
   }
   __DBGpr_int("Number of Frames in the Plate Range ", *frmCnt );
   __DBGpr_objlist( "Frame ", *frmCnt, *frmList );

wrapup:
   _FREE( frames );
   End
   return sts;
}

static IGRlong VLpjCreateLocalPlane( IGRlong             	*msg,
				     struct GRobj_env    	*mgrOE,
				     IGRint			direction,
				     struct GRobj_env    	*frmOE,
				     struct GRvg_construct   	*cst,
				     IGRboolean			*is_new,
				     struct GRobj_env    	*plnOE )
{
IGRlong                 sts;
IGRint			i, index;
IGRdouble		spacing, point[3], normal[3];
struct GRobj_env        prmfrmOE, footOE;
struct IGRplane         plane;
struct ACrg_coll	attrib;

   SetProc( VLpjCreateLocalPlane ); Begin

   sts = *msg = MSSUCC;

   *is_new = FALSE;
   plnOE->_objid = NULL_OBJID;

   if( !vd_$is_ancestry_valid( 	object  = &frmOE->obj_id,
				classid = OPP_expression_class_id ) )
   {
       *plnOE = *frmOE ;
       goto wrapup;
   }

   *is_new = TRUE;
   __DBGpr_obj("Input Plate Jig Manager ", mgrOE->obj_id );
   prmfrmOE._objid = NULL_OBJID;
   vdobj$GetTemplate( objOE      = mgrOE,
                      nth        = direction,
                      templateOE = &prmfrmOE );
   __DBGpr_obj("Primary Frame ", prmfrmOE.obj_id );
   if( prmfrmOE._objid == NULL_OBJID ) { *msg = MSFAIL; goto wrapup; }

   plane.point  = point;
   plane.normal = normal;

   vdobj$GetFoot( objOE    = &prmfrmOE,
                  footName = "plane",
                  footOE   = &footOE );

   sts = om$send( msg = message GRvg.GRdetplane( msg, &footOE._matrix_type,
                              footOE._matrix, &plane ),
                  senderid = NULL_OBJID,
                  targetid = footOE._objid,
                  targetos = footOE._osnum );
   __CheckRC( sts, *msg, "GRvg.GRdetplane", wrapup ) ;
   __DBGpr_vec("Frame Point ", point );
   __DBGpr_vec("Frame Normal ", normal );

   if( direction == PJS_PRIMARY_DIR )  
		strcpy( attrib.name, NAM_PJS_PRM_SPACING );
   else		strcpy( attrib.name, NAM_PJS_SCD_SPACING );

   sts = VLpjGetNamedAttibute( msg, &mgrOE->obj_id, &attrib );
   __CheckRC( sts, *msg, "VLpjGetNamedAttibute", wrapup ) ;

   spacing = attrib.desc.value.att_exp;
   __DBGpr_dbl("Spacing ", spacing );

   vdexp$Get( objOE = frmOE, jnt = &index );
   __DBGpr_int("Index ", index );	

   for( i=0; i<3; ++i )		point[i] += index*spacing;
   __DBGpr_vec("New Point to create Plane ", point );

   plnOE->mod_env = *(cst->env_info);
   sts = VLcreatePlane( point, normal, cst->env_info, cst, 
			&plnOE->obj_id, msg );
   __CheckRC( sts, *msg, "VLcreatePlane", wrapup ) ;

wrapup:
   End
   return sts;
}

IGRlong		VLpjCreatePlateJig( IGRlong		*msg,
				    struct GRobj_env    *mgrOE,
				    struct GRobj_env    *boxOE,
				    struct GRobj_env	*frmOE,
				    IGRint		num_pl,
				    struct GRobj_env    *pltOE,
				    struct GRid		*lineIDs )
{
BSrc			rc;
IGRlong			sts;
IGRint			i, stat, nint=0, nvtx=0, ncmp=0, direction, nb_pj_attr,
			base_pl, inv_norm;
IGRboolean      	adj, clo, is_new;
IGRdouble               bastol, cht, xpt[6], extension, max_dist,
			Bpln[6], *Vrtx=NULL, grd_dist, Ppln[6], Tpln[6];
IGRchar			footName[40], side[40];
IGRshort		*inv=NULL, line_inv[4];
IGRpoint		spt1, spt2, ept1, ept2;
struct GRid		CrvID, SrfID, pl_encomp, comp_crv, mkSrcId;
struct GRobj_env	footOE, locFrmOE, mgrBoxOE, in_lineOEs[4], 
			out_lineOEs[4], *Icrv=NULL, *Ocrv=NULL;
struct GRvg_construct   cst;
struct GRlc_info        *Entr=NULL, lineLCs[4];
struct IGRpolyline      geom;
struct ACrg_coll        attrib, pj_attr[7];

   SetProc( VLpjCreatePlateJig ); Begin

   sts = *msg = MSSUCC;

   VLinitCnst( &cst );

   is_new          = FALSE;
   CrvID.objid     = NULL_OBJID;
   pl_encomp.objid = NULL_OBJID;
   comp_crv.objid  = NULL_OBJID;

   if( !( Icrv = _MALLOC( 2*num_pl, struct GRobj_env ) ) ) vd_$mem_fail();

   __DBGpr_obj("Input Frame ", frmOE->obj_id );
   __DBGpr_int("Number of Input Plates ", num_pl );

   strcpy( attrib.name, NAM_PJS_DIRECTION );
   sts = om$send(  msg      = message ACrg_collect.ACget_named_attribute(
                                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = boxOE->_objid,
                   targetos = boxOE->_osnum  );
   __CheckRC( sts, *msg, "ACrg_collect.ACget_named_attribute", wrapup ) ;
   direction = (IGRint) attrib.desc.value.att_exp;

   strcpy( attrib.name, NAM_PJS_PLATESIDE );
   sts = om$send(  msg      = message ACrg_collect.ACget_named_attribute(
                                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = boxOE->_objid,
                   targetos = boxOE->_osnum  );
   __CheckRC( sts, *msg, "ACrg_collect.ACget_named_attribute", wrapup ) ;
   strcpy( side, attrib.desc.value.att_txt );
   if( !strcmp( side, VS_K_plBotSfPath ) )	inv_norm = -1;
   else						inv_norm =  1;

   sts = VLpjCreateLocalPlane( 	msg, mgrOE, direction,
			 	frmOE, &cst, &is_new, &locFrmOE );
   __CheckRC( sts, *msg, "VLpjCreateLocalPlane", wrapup ) ;

   if( is_new && locFrmOE._objid == NULL_OBJID ) { sts = MSFAIL; goto wrapup; }

   nint=0;
   for( i=0; i<num_pl; ++i )
   {
      __DBGpr_obj("Plate ", pltOE[i].obj_id );
      Icrv[i].mod_env      = *(cst.env_info) ;
      Icrv[i].obj_id.objid = NULL_OBJID;
      Icrv[i].obj_id.osnum = cst.env_info->md_id.osnum; 

      vdobj$GetFoot( objOE     = &pltOE[i],
                     footName  = side,
                     footOE    = &footOE );

      vd_$grCopy( msg   = msg,
		  frEnv = &footOE.mod_env,
		  frObj	= &footOE.obj_id,
		  toEnv = cst.env_info,
		  toObj = &SrfID );

      sts = VLcreateInter( msg, &SrfID, cst.env_info, 0,
			   &locFrmOE.obj_id, &locFrmOE.mod_env, 0, 
			   &Icrv[nint].obj_id, &Icrv[nint].mod_env );
      vd_$bulk_delete( grids = &SrfID, theEnv = cst.env_info );
      if( !(sts&1&(*msg)) ) continue;
      nint++;
   }

   if( !nint ) { sts = *msg = MSFAIL; goto wrapup; }

   if( !( Ocrv = _MALLOC( 2*nint, struct GRobj_env ) ) ) vd_$mem_fail();
   if( !( inv  = _MALLOC( nint, IGRshort ) ) ) vd_$mem_fail();

   vdgeom$GetTolerance( cht = &cht );
   vdgeom$GetTolerance( basis = &bastol );
   sts = OrderCrv( Icrv, nint, GAP_TOL, bastol, Ocrv, inv, &adj, &clo, msg);
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else			*msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   /* Extract ordered vertices of the future composite curve */
   sts = VLextractVertices( msg, nint, Ocrv, inv, &nvtx, &Vrtx);
   __CheckRC( sts, *msg, "VLextractVertices", wrapup ) ;

   /* Try to close the gap */
   ncmp = nint;
   if( nint > 1 )
   {
       *msg = MSSUCC;
       cst.geometry    = (IGRchar *) &geom;
       geom.num_points = 2;
       for( i=1; i<nint; i++ )
       {
	  VLendpts( msg, &Ocrv[i-1].obj_id, &Ocrv[i-1].mod_env, spt1, ept1 );
	  if( inv[i-1] == 1 )	dblcpy ( &xpt[0], ept1, 3);
	  else			dblcpy ( &xpt[0], spt1, 3);

          VLendpts( msg, &Ocrv[i].obj_id, &Ocrv[i].mod_env, spt2, ept2 );
          if( inv[i] == 1 )  	dblcpy ( &xpt[3], spt2, 3);
          else                  dblcpy ( &xpt[3], ept2, 3);

	  if( BSdistptpt( &rc, &xpt[0], &xpt[3] ) > bastol )
	  {
	     geom.points = (IGRdouble *) xpt;
	     Ocrv[ncmp].obj_id.objid = NULL_OBJID;
	     Ocrv[ncmp].obj_id.osnum = cst.env_info->md_id.osnum;
	     Ocrv[ncmp].mod_env      = *(cst.env_info);

	     sts = om$construct( classid = OPP_GR3dlineseg_class_id,
				 osnum   = Ocrv[ncmp].obj_id.osnum,
				 p_objid = &Ocrv[ncmp].obj_id.objid,
				 msg = message GRgraphics.GRaltconstruct(&cst));
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

   BuildCrv( 1, Icrv, ncmp, inv, adj, clo, Entr, &cst, &CrvID, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "BuildCrv", wrapup ) ;

   strcpy( attrib.name, NAM_PJS_EXTENSION );
   sts = VLpjGetNamedAttibute( msg, &mgrOE->obj_id, &attrib );
   __CheckRC( sts, *msg, "VLpjGetNamedAttibute", wrapup ) ;
   extension = attrib.desc.value.att_exp;

   sts = VLextendCurve( msg, &CrvID, cst.env_info, 5*cht, bastol, 
			extension, extension, NULL, NULL );
   __CheckRC( sts, *msg, "VLextendCurve", wrapup ) ;
   __DBGpr_obj( "Curve ID ", CrvID );

   strcpy( attrib.name, NAM_PJS_BASEPLANE );
   sts = VLpjGetNamedAttibute( msg, &mgrOE->obj_id, &attrib );
   __CheckRC( sts, *msg, "VLpjGetNamedAttibute", wrapup ) ;
   base_pl = (IGRint) attrib.desc.value.att_exp;
   __DBGpr_int("Base Plane Option ", base_pl );

   if( base_pl != IDX_PJS_BASEPL )      inv_norm = 1;

   if( base_pl == IDX_PJS_BASEPL )		base_pl = IDX_J5;
   else if( base_pl == IDX_PJS_CENTERLINE )	base_pl = IDX_J4;
   else						base_pl = IDX_J3;

   for( i=0; i<100; ++i )
   {
      sprintf( footName, "Edge%d", i );
      vdobj$GetFoot( objOE    = mgrOE,
                     footName = footName,
                     footOE   = &mgrBoxOE );
      if( vd_$is_ancestry_valid(  object  = &mgrBoxOE.obj_id,
                                  classid = OPP_ACrg_collect_class_id ) ) break;
   }
   if( i == 100 ) { sts = MSFAIL; goto wrapup; }

   sts = om$send ( msg =  message ACrg_collect.AClist_attribute(
                                msg, 7, pj_attr, &nb_pj_attr ),
                senderid = NULL_OBJID,
                targetid = mgrBoxOE._objid,
                targetos = mgrBoxOE._osnum );
   __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup ) ;
   if( nb_pj_attr != 7 ) { sts = MSFAIL; goto wrapup; }

   Bpln[0] = pj_attr[0].desc.value.att_exp ;
   Bpln[1] = pj_attr[1].desc.value.att_exp ;
   Bpln[2] = pj_attr[2].desc.value.att_exp ;
   Bpln[3] = pj_attr[3].desc.value.att_exp ;
   Bpln[4] = pj_attr[4].desc.value.att_exp ;
   Bpln[5] = pj_attr[5].desc.value.att_exp ;
   max_dist = pj_attr[6].desc.value.att_exp ;
   __DBGpr_vec( "COG ", &Bpln[0] );
   __DBGpr_vec( "Average Normal ", &Bpln[3] );    
   __DBGpr_dbl( "Maximum Distance ", max_dist );

   strcpy( attrib.name, NAM_PJS_MINHEIGHT );
   sts = VLpjGetNamedAttibute( msg, &mgrOE->obj_id, &attrib );
   __CheckRC( sts, *msg, "VLpjGetNamedAttibute", wrapup ) ;
   grd_dist = attrib.desc.value.att_exp;
   __DBGpr_dbl("Minimum Height ", grd_dist );

   sts = VLcomputePlanes( Bpln, &locFrmOE.obj_id, grd_dist+max_dist, 
			  cst.env_info, Ppln, Tpln, msg);
   __CheckRC( sts, *msg, "VLcomputePlanes", wrapup ) ;

   sts = VLendpts( msg, &CrvID, cst.env_info, spt1, ept1 );
   __CheckRC( sts, *msg, "VLendpts", wrapup ) ;
   __DBGpr_vec("Curve Start Point ", spt1 );
   __DBGpr_vec("Curve End Point ", ept1 );
 
   BSproj1( &rc, spt1, &Tpln[3], &Tpln[0], spt2 );
   if( rc == BSSUCC )   *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "BSproj1", wrapup ) ;

   BSproj1( &rc, ept1, &Tpln[3], &Tpln[0], ept2 );
   if( rc == BSSUCC )   *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "BSproj1", wrapup ) ;

   __DBGpr_vec("Projected Curve Start Point ", spt2 );
   __DBGpr_vec("Projected Curve End Point ", ept2 );

   lineIDs[0] = CrvID ;

   geom.num_points = 2;
   geom.points  = (IGRdouble *) xpt;
   cst.geometry = (IGRchar *) &geom;

   dblcpy ( &xpt[0], ept1, 3);	dblcpy ( &xpt[3], ept2, 3);
   lineIDs[1].objid = NULL_OBJID;
   lineIDs[1].osnum = cst.env_info->md_id.osnum;
   sts = om$construct( classid = OPP_GR3dlineseg_class_id,
                       osnum   = lineIDs[1].osnum,
                       p_objid = &lineIDs[1].objid,
                       msg = message GRgraphics.GRaltconstruct(&cst));
   __CheckRC( sts, *msg, "GRaltconstruct: GR3dlineseg:EndSide", wrapup ) ;

   dblcpy ( &xpt[0], ept2, 3);  dblcpy ( &xpt[3], spt2, 3);
   lineIDs[2].objid = NULL_OBJID;
   lineIDs[2].osnum = cst.env_info->md_id.osnum;
   sts = om$construct( classid = OPP_GR3dlineseg_class_id,
                       osnum   = lineIDs[2].osnum,
                       p_objid = &lineIDs[2].objid,
                       msg = message GRgraphics.GRaltconstruct(&cst));
   __CheckRC( sts, *msg, "GRaltconstruct: GR3dlineseg:BottomLine", wrapup ) ;

   dblcpy ( &xpt[0], spt2, 3);  dblcpy ( &xpt[3], spt1, 3);
   lineIDs[3].objid = NULL_OBJID;
   lineIDs[3].osnum = cst.env_info->md_id.osnum;
   sts = om$construct( classid = OPP_GR3dlineseg_class_id,
                       osnum   = lineIDs[3].osnum,
                       p_objid = &lineIDs[3].objid,
                       msg = message GRgraphics.GRaltconstruct(&cst));
   __CheckRC( sts, *msg, "GRaltconstruct: GR3dlineseg:StartSide", wrapup ) ;

   for( i=0; i<4; ++i )
   {
      in_lineOEs[i].obj_id  = lineIDs[i];
      in_lineOEs[i].mod_env = *(cst.env_info);
   }

   sts = OrderCrv( in_lineOEs, 4, 5*cht, bastol, out_lineOEs, 
		   line_inv, &adj, &clo, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   BuildCrv( 2, in_lineOEs, 4, line_inv, adj, clo, lineLCs, 
	     &cst, &comp_crv, msg );
   if( *msg == BSSUCC ) *msg = MSSUCC;
   else                 *msg = MSFAIL;
   __CheckRC( sts, *msg, "OrderCrv", wrapup ) ;

   ASmake_source_from_env( &comp_crv, cst.env_info, &mkSrcId );
   pl_encomp.osnum = cst.env_info->md_id.osnum;
   sts = om$construct( classid = OPP_nci_macro_class_id,
                       osnum   = pl_encomp.osnum,
                       p_objid = &pl_encomp.objid,
                       msg = message ci_macro.init( &stat, 0, "pla_encomp",
				1, &mkSrcId, NULL, cst.env_info ) );
   __CheckRC( sts, stat, "nci_macro.init:pla_encomp", wrapup ) ;
   __DBGpr_obj("Encompassing Plane ", pl_encomp );

   vdobj$GetFoot( objID    = &pl_encomp,
                  footName = "res_surf",
                  footOE   = &footOE );

   lineIDs[4].osnum = cst.env_info->md_id.osnum;
   sts = om$send(msg = message GRgraphics.GRcopy( msg, cst.env_info,
				cst.env_info, &lineIDs[4].objid ),
		senderid = NULL_OBJID,
		targetid = footOE._objid,
		targetos = footOE._osnum );
   __CheckRC( sts, stat, "GRgraphics.GRcopy:pla_encomp", wrapup ) ;

wrapup:

   if( !(sts&1&(*msg)) && CrvID.objid != NULL_OBJID )
   {
      om$send(  msg = message GRgraphics.GRdelete( msg, cst.env_info ),
                senderid = NULL_OBJID,
                targetid = CrvID.objid,
                targetos = CrvID.osnum );
   }

   if( pl_encomp.objid != NULL_OBJID )
   {
      om$send(  msg = message GRgraphics.GRdelete( msg, cst.env_info ),
		senderid = NULL_OBJID,
		targetid = pl_encomp.objid,
		targetos = pl_encomp.osnum );
   }

   if( comp_crv.objid != NULL_OBJID )
   {
      om$send(  msg = message GRgraphics.GRdelete( msg, cst.env_info ),
                senderid = NULL_OBJID,
                targetid = comp_crv.objid,
		targetos = comp_crv.osnum );
   }

   if( is_new && locFrmOE._objid != NULL_OBJID )
   {
      om$send(  msg = message GRgraphics.GRdelete( msg, cst.env_info ),
                senderid = NULL_OBJID,
                targetid = locFrmOE._objid,
                targetos = locFrmOE._osnum );
   }

   _FREE( inv  );
   _FREE( Icrv );
   _FREE( Ocrv );
   _FREE( Entr );
   _FREE( Vrtx );
   End
   return sts;
}

IGRlong         VLpjCreateEdgeJig(  IGRlong             *msg,
                                    struct GRobj_env    *mgrOE,
                                    struct GRobj_env    *boxOE,
				    struct GRobj_env    *crvOE,
                                    struct GRid         *lineIDs )
{
IGRlong			sts;
IGRint			i, j, base_pl, inv_norm, nb_pj_attr, edgeCount=0;
IGRdouble               bastol, cht, extension, max_dist, Bpln[6], grd_dist;
IGRpoint                spt1, ept1, spt2, ept2, point;
IGRchar			footName[40], side[40];
IGRboolean		is_scd_filled;
IGRushort               options;
GRobjid			return_id;
struct GRobj_env        mgrBoxOE;
struct GRid		CrvID, edgeList[4], srfID, *nat_edges=NULL,
			new_obj, active_id, top_lm_id;
struct ACrg_coll	attrib, pj_attr[7];
struct GRvg_construct   cst;
struct IGRplane         plane;
struct EMSdataselect    plane_data;

   SetProc( VLpjCreateEdgeJig );  Begin

   CrvID.objid = NULL_OBJID;  
   srfID.objid = NULL_OBJID;

   sts = *msg = MSSUCC;

   VLinitCnst( &cst );

   vdgeom$GetTolerance( cht = &cht );
   vdgeom$GetTolerance( basis = &bastol );

   strcpy( attrib.name, NAM_PJS_PLATESIDE );
   sts = om$send(  msg      = message ACrg_collect.ACget_named_attribute(
                                                msg, &attrib ),
                   senderid = NULL_OBJID,
                   targetid = boxOE->_objid,
                   targetos = boxOE->_osnum  );
   __CheckRC( sts, *msg, "ACrg_collect.ACget_named_attribute", wrapup ) ;
   strcpy( side, attrib.desc.value.att_txt );
   __DBGpr_str("Jig Side ", side );
   if( !strcmp( side, VS_K_plBotSfPath ) )      inv_norm = -1;
   else                                         inv_norm =  1;

   strcpy( attrib.name, NAM_PJS_EXTENSION );
   sts = VLpjGetNamedAttibute( msg, &mgrOE->obj_id, &attrib );
   __CheckRC( sts, *msg, "VLpjGetNamedAttibute", wrapup ) ;
   extension = attrib.desc.value.att_exp;

   vd_$grCopy( msg   = msg,
               frEnv = &crvOE->mod_env,
               frObj = &crvOE->obj_id,
               toEnv = cst.env_info,
               toObj = &CrvID );

   sts = VLextendCurve( msg, &CrvID, cst.env_info, 5*cht, bastol,
                        extension, extension, NULL, NULL );
   __CheckRC( sts, *msg, "VLextendCurve", wrapup ) ;
   __DBGpr_obj( "Curve ID ", CrvID );

   strcpy( attrib.name, NAM_PJS_BASEPLANE );
   sts = VLpjGetNamedAttibute( msg, &mgrOE->obj_id, &attrib );
   __CheckRC( sts, *msg, "VLpjGetNamedAttibute", wrapup ) ;
   base_pl = (IGRint) attrib.desc.value.att_exp;
   __DBGpr_int("Base Plane Option ", base_pl );

   if( base_pl != IDX_PJS_BASEPL )      inv_norm = 1;

   if( base_pl == IDX_PJS_BASEPL )              base_pl = IDX_J5;
   else if( base_pl == IDX_PJS_CENTERLINE )     base_pl = IDX_J4;
   else                                         base_pl = IDX_J3;

   strcpy( attrib.name, NAM_PJS_MINHEIGHT );
   sts = VLpjGetNamedAttibute( msg, &mgrOE->obj_id, &attrib );
   __CheckRC( sts, *msg, "VLpjGetNamedAttibute", wrapup ) ;
   grd_dist = attrib.desc.value.att_exp;
   __DBGpr_dbl("Minimum Height ", grd_dist );

   for( i=0; i<100; ++i )
   {
      sprintf( footName, "Edge%d", i );
      vdobj$GetFoot( objOE    = mgrOE,
                     footName = footName,
                     footOE   = &mgrBoxOE );
      if( vd_$is_ancestry_valid(  object  = &mgrBoxOE.obj_id,
                                  classid = OPP_ACrg_collect_class_id ) ) break;
   }
   if( i == 100 ) { sts = MSFAIL; goto wrapup; }

   sts = om$send ( msg =  message ACrg_collect.AClist_attribute(
                                msg, 7, pj_attr, &nb_pj_attr ),
                senderid = NULL_OBJID,
                targetid = mgrBoxOE._objid,
                targetos = mgrBoxOE._osnum );
   __CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup ) ;
   if( nb_pj_attr != 7 ) { sts = MSFAIL; goto wrapup; }

   Bpln[0] = pj_attr[0].desc.value.att_exp ;
   Bpln[1] = pj_attr[1].desc.value.att_exp ;
   Bpln[2] = pj_attr[2].desc.value.att_exp ;
   Bpln[3] = pj_attr[3].desc.value.att_exp ;
   Bpln[4] = pj_attr[4].desc.value.att_exp ;
   Bpln[5] = pj_attr[5].desc.value.att_exp ;
   max_dist = pj_attr[6].desc.value.att_exp ;
   __DBGpr_vec( "COG ", &Bpln[0] );
   __DBGpr_vec( "Average Normal ", &Bpln[3] );
   __DBGpr_dbl( "Maximum Distance ", max_dist );

   plane.point  = point; 
   plane.normal = Bpln+3 ;
   for( i=0; i<3; ++i ) point[i] = Bpln[i] + (max_dist+grd_dist)*Bpln[3+i] ;

   strcpy( attrib.name, NAM_PJS_MINHEIGHT );
   sts = VLpjGetNamedAttibute( msg, &mgrOE->obj_id, &attrib );
   __CheckRC( sts, *msg, "VLpjGetNamedAttibute", wrapup ) ;
   grd_dist = attrib.desc.value.att_exp;
   __DBGpr_dbl("Minimum Height ", grd_dist );

   VLendpts( msg, &CrvID, cst.env_info, spt1, ept1 );
   __DBGpr_vec("Start Point For Projection ", spt1 );

   for( i=0; i<3; ++i ) ept1[i] = spt1[i] + 2*(max_dist+grd_dist)*Bpln[3+i] ;
   __DBGpr_vec("End Point For Projection ", ept1 );

   srfID.osnum = cst.env_info->md_id.osnum;
   sts = om$construct( classid = OPP_EMSproject_class_id,
                       osnum   = srfID.osnum,
                       p_objid = &srfID.objid,
                       msg = message EMSproject.EMplace_surface_of_projection(
				&cst, &CrvID, cst.env_info, NULL, 0, 
				spt1, ept1, 0, &srfID.objid ) );
   __CheckRC( sts, *msg, "EMSproject.EMplace_surface_of_projection", wrapup ) ;

   plane_data.datatype = EMSdata_plane; 
   plane_data.data.plane = (struct IGRplane *) &plane;

   __DBGpr_vec("Plane Point ", plane.point );
   __DBGpr_vec("Plane Normal ", plane.normal );

   options = EMSsfbool_opt_OpenIntPossible |
             EMSsfbool_opt_doublecheck     |   /* Only if it fails */
             EMSsfbool_opt_noredraw |
             EMSsfbool_opt_HandleStop;

   sts = om$send ( msg = message EMSsurface.EMintsurf_saveside(
                                                msg,
                                                &cst,
                                                &plane_data,
                                                cst.env_info,
                                                spt1,
                                                -1,
                                                options,
                                                NULL,
                                                NULL,
                                                FALSE,
                                                NULL ),
                   targetid = srfID.objid,
                   targetos = srfID.osnum,
                   senderid = NULL_OBJID );
   __CheckRC( sts, *msg, "EMSsurface.EMintsurf_saveside", wrapup ) ;

   sts = om$send(msg = message EMSsurface.EMgetactiveid( msg,
                                        &active_id, &top_lm_id),
                        targetid = srfID.objid,
                        targetos = srfID.osnum,
                        senderid = NULL_OBJID);
   __CheckRC( sts, *msg, "EMSsurface.EMgetactiveid", wrapup ) ;

   sts = om$send ( msg = message EMSdpr.EMmake_primitive1(
                                                msg,
                                                cst.env_info,
                                                &new_obj ),
                        targetid = active_id.objid,
                        targetos = active_id.osnum,
                        senderid = NULL_OBJID );
   __CheckRC( sts, *msg, "EMSdpr.EMmake_primitive1", wrapup ) ;

/*
   sts = om$send ( msg = message EMSsubbs.EMreduce_range(
                                                msg,
                                                cst.env_info,
                                                &return_id,
                                                0 ),
                        targetid = new_obj.objid,
                        targetos = new_obj.osnum,
                        senderid = NULL_OBJID );
   __CheckRC( sts, *msg, "EMSsubbs.EMreduce_range", wrapup ) ;
*/
  __DBGpr_obj("Trimmed Surface ", srfID );
   lineIDs[4] = srfID ;

   vs$get_surface_edges( msg         = msg,
			 sfId	     = &lineIDs[4],
			 sfEnv	     = cst.env_info,
			 edgeType    = VS_K_CONTOUR_EDGES,
			 edCount     = &edgeCount, 
			 edList	     = &nat_edges );
   __DBGpr_int("Plane Edge Count ", edgeCount );
   if( edgeCount < 4 ) goto wrapup;

   for( i=0; i<4; ++i )
   {
       	vs$get_graphic_edge( msg     = msg,
                             edId    = &nat_edges[i],
                             edEnv   = cst.env_info,
                             copy    = TRUE,
                             copyEnv = cst.env_info,
                             grEdge  = &edgeList[i] ) ;
   }

   VLendpts( msg, &CrvID, cst.env_info, spt1, ept1 );
   __DBGpr_vec("Start Point of Edge ", spt1 );
   __DBGpr_vec("End Point of Edge ", ept1 );

   is_scd_filled = FALSE;
   for( i=0; i<4; ++i )
   {
        VLendpts( msg, &edgeList[i], cst.env_info, spt2, ept2 );
	__DBGpr_vec("Start Point of Plane Edge ", spt2 );
	__DBGpr_vec("End Point of Plane Edge ", ept2 );
        if( VLsame_point( spt1, spt2, 0.001 ) ) 
	{
	   if( VLsame_point( ept1, ept2, 0.001 ) )  lineIDs[0] = edgeList[i];
	   else if( is_scd_filled == FALSE )
	   {
		lineIDs[1]    = edgeList[i];
		is_scd_filled = TRUE;
	   }
	   else lineIDs[3] = edgeList[i];
	}
        else if( VLsame_point( spt1, ept2, 0.001 ) ) 
        {
           if( VLsame_point( ept1, spt2, 0.001 ) )  lineIDs[0] = edgeList[i];
           else if( is_scd_filled == FALSE )
           {
                lineIDs[1]    = edgeList[i];
                is_scd_filled = TRUE;
           }
           else lineIDs[3] = edgeList[i];
        }
        else if( VLsame_point( ept1, ept2, 0.001 ) )
        {
           if( VLsame_point( spt1, spt2, 0.001 ) )  lineIDs[0] = edgeList[i];
           else if( is_scd_filled == FALSE )
           {
                lineIDs[1]    = edgeList[i];
                is_scd_filled = TRUE;
           }
           else lineIDs[3] = edgeList[i];
        }
        else if( VLsame_point( ept1, spt2, 0.001 ) )
        {
           if( VLsame_point( spt1, ept2, 0.001 ) )  lineIDs[0] = edgeList[i];
           else if( is_scd_filled == FALSE )
           {
                lineIDs[1]    = edgeList[i];
                is_scd_filled = TRUE;
           }
           else lineIDs[3] = edgeList[i];
        }
	else lineIDs[2] = edgeList[i];
   }

wrapup:
   _FREE( nat_edges );

   if( CrvID.objid != NULL_OBJID )
   {
       om$send(  msg = message GRgraphics.GRdelete( msg, cst.env_info ),
                senderid = NULL_OBJID,
                targetid = CrvID.objid,
                targetos = CrvID.osnum );
   }

   if( !(sts&1&(*msg)) && srfID.objid != NULL_OBJID )
   {
	om$send(  msg = message GRgraphics.GRdelete( msg, cst.env_info ),
                senderid = NULL_OBJID,
                targetid = srfID.objid,
                targetos = srfID.osnum );
   }

   End
   return sts;
}

end implementation VDSroot;
