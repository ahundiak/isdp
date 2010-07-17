/* $Id: VLstfMark.I,v 1.2 2001/02/20 01:05:24 build Exp $  */
/* --------------------------------------------------------------------
 * I/LOFT
 *
 * File:        loft/src/pcard/VLstfMark.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLstfMark.I,v $
 *      Revision 1.2  2001/02/20 01:05:24  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1  2001/01/28 18:38:45  ramarao
 *      Implemented CR# MP 4301 on Stiffner Automarking process.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      01/24/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "bserr.h"
#include "bsmdistptsf.h"
#include "bsbxint.h"
#include "emssfintdef.h"
#include "expression.h"
#include "expmacros.h"
#include "VDobj.h"
#include "VDefp.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "vsplatedef.h"
#include "vsbeamdef.h"
#include "vssectiondef.h"
#include "vsgeommacros.h"
#include "vsedgedef.h"
#include "vsedgemacros.h"
#include "vsmiscmacros.h"
#include "vlmiscmacros.h"
#include "vlquerydef.h"
#include "vldbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

from	ci_macro	import		init;
from	VSfeature	import		VSforwardToSource;
from	VSpart		import		VSgetSupports;

extern OM_S_CHANSELECT	AS_to_owner;

extern GRclassid	OPP_EMSsubbs_class_id, OPP_VSdivFeature_class_id,
			OPP_VSplate_class_id,  OPP_nci_macro_class_id;

extern VLgetMacrosAtStep();

VLget_top_owner( struct GRid  	*component,
		 struct GRid	*owner      )
{
IGRlong			sts;
IGRint			count=0;
OM_S_OBJECT_LINKAGE     as_link;
struct GRid		top_owner;

   *owner = *component;

   sts = om$get_channel_objects( osnum 	      = component->osnum,
                                 objid 	      = component->objid,
                                 p_chanselect = &AS_to_owner,
                                 list 	      = &as_link,
                                 size 	      = 1, 
				 count 	      = (OMuint *) &count );
   if( (sts&1) && count )
   {
      top_owner.objid = as_link.S_objid;
      top_owner.osnum = as_link.osnum;

      VLget_top_owner( &top_owner, owner );
   }
}

IGRint	VLpcTildaMarkingDefined( struct GRobj_env *Plate )
{
IGRlong                 sts, msg;
IGRint			i, result, suppCount=0;
IGRchar			attr_name[40], footName[40], macName[40];
VSsuppList      	pltSupport;
struct GRid		srfOwner, footId;

   SetProc( VLpcTildaMarkingDefined ); Begin

   result = FALSE;

   __DBGpr_obj("Input Plate ID ", Plate->obj_id );

   sts = om$send(  msg = message VSfeature.VSforwardToSource( 
						&msg,
						OM_e_wrt_object,
			 message VSpart.VSgetSupports( &msg, &Plate->mod_env,
                                        &suppCount, pltSupport ) ),
	senderid = NULL_OBJID,
	targetid = Plate->_objid,
	targetos = Plate->_osnum );
   __CheckRC( sts, msg, "VSpart.VSgetSupports", wrapup ) ; 
   __DBGpr_obj( "Plate Support Surface", pltSupport[0].obj_id );

   VLget_top_owner( &pltSupport[0].obj_id, &srfOwner );
   __DBGpr_obj( "Plate Surface Owner", srfOwner );

   for( i=0; i<20; ++i )
   {
      if( i<10 ) sprintf( attr_name, "~~marking%d", i );
      else	 sprintf( attr_name, "~~marking0%d", i-10 );
      if( 1 & ( VLgetOperName( "", &srfOwner, attr_name, footName ) ) )
      {
         __DBGpr_str( "Tilda Marking Name", attr_name );
	 __DBGpr_str( "Foot Name", footName );

          sts = vl$return_foot ( msg     = &msg,
                                 name    = attr_name,
                                 objId   = &srfOwner,
                                 footId  = &footId    );
	  if( sts&1&msg )
	  {
	     __DBGpr_obj( "Found the foot", footId );
             result = TRUE;
	     goto wrapup;
	  }
	  else
 	  {
	     vdobj$Get( objID = &srfOwner, macName = macName );
	     __DBGpr_str( "Foot is Missing; Problem with the macro", macName );
	  }
      }
   }

wrapup:
   End
   return result;
}

IGRint  VLpcStfMarkExists( struct GRobj_env	*Stiff,
			   struct GRobj_env	*Plate,
			   struct GRmd_env	*loc_env  )
{
IGRint			i, nbMac, result;
struct GRid		plateID;
struct GRobj_env	*macList=NULL;

   result = FALSE;

   VLbrowseFctInTree( Stiff, VL_Q_TOP_SOURCE, NULL, VL_Q_DOWN_DIRECT,
                      VLgetMacrosAtStep, &nbMac, &macList, loc_env );
   VLfilterDef( nbMac, macList, &nbMac, "stfPcMark" );
   for( i=0; i<nbMac; ++i )
   {
       vdobj$GetParent( objID 	 = &macList[i].obj_id,
			idx	 = 1,
			parentID = &plateID );
       if( plateID.objid == Plate->_objid && 
	   plateID.osnum == Plate->_osnum     )
       {
	  __DBGpr_com( "Stiffener Marking Already Exists for this Plate" );
	  result = TRUE;
	  goto wrapup;
       }
   }
   __DBGpr_com( "Stiffener Marking Does not exist" );

wrapup:
   _FREE( macList );
   return result;
}

IGRint 	VLcurve_fully_on_surface( struct IGRbsp_curve	*crv_geom,
				  struct GRobj_env 	*srf,
				  IGRdouble		tol    )
{
BSrc			rc;
IGRlong			sts, msg;
IGRboolean		result;
IGRdouble		u, v, dist;
IGRpoint		spt, ept, pt, mid_pt;
struct IGRbsp_surface	*srf_geom=NULL;

   result = FALSE;

   if( !vs$is_ancestry_valid( object  = &srf->obj_id,
			      classid = OPP_EMSsubbs_class_id ) )
     return FALSE;

   sts = vs$get_geometry(  msg      = &msg,
                           grobjId  = &srf->obj_id,     
                           grobjEnv = &srf->mod_env,   
                           geometry = &srf_geom );
   __CheckRC( sts, msg, "vd_$get_geometry: Surface", wrapup ) ;

   MAbcendpts( &msg, crv_geom, spt, ept );

   BSmdistptsf( &rc, srf_geom, spt, &u, &v, pt, &dist ) ;
   if( rc != BSSUCC || dist > tol ) goto wrapup;

   BSmdistptsf( &rc, srf_geom, ept, &u, &v, pt, &dist ) ;
   if( rc != BSSUCC || dist > tol ) goto wrapup;

   BScvmidpt( crv_geom, &u, mid_pt, &rc );
   if( rc != BSSUCC )  goto wrapup;

   BSmdistptsf( &rc, srf_geom, mid_pt, &u, &v, pt, &dist ) ;
   if( rc != BSSUCC || dist > tol ) goto wrapup;

   result = TRUE;

wrapup:
   _FREE( srf_geom );
   return result;
}

IGRint	VLcheckPlateForMarking(	struct GRobj_env	*Stiff,
				struct GRobj_env	*Plate,
				IGRint			*left_or_right,
				struct GRmd_env		*loc_env )
{
BSrc			rc;
IGRlong			sts, msg, isConsumed;
IGRint			i, j, edgeCnt;
IGRboolean		result=FALSE;
IGRdouble		tol;
struct GRobj_env	web_surf[2], plt_surf[2];
struct IGRbsp_curve     *edgeGeom[VDEFP_NEAT_EDGES_MAX];

    SetProc( VLcheckPlateForMarking ); Begin

    __DBGpr_obj( "Input Stiffener Object", Stiff->obj_id );
    __DBGpr_obj( "Input Plate Object to be tested", Plate->obj_id );

    vdgeom$GetTolerance( cht = &tol );

    for( j=0; j<VDEFP_NEAT_EDGES_MAX; ++j )  edgeGeom[j] = NULL;

    if( Stiff->_objid == Plate->_objid && Stiff->_osnum == Plate->_osnum )
       goto wrapup;

    if( vs$is_ancestry_valid( object  = &Plate->obj_id,	
			      classid = OPP_VSdivFeature_class_id ) )
    {
	__DBGpr_com( "VSdivFeature class: Not eligible for marking" );
	goto wrapup;
    }

    /* If the Plate is consumed return failure */
    sts = om$send( msg      = message NDmacro.ACtest_consumed( &isConsumed),
                   senderid = NULL_OBJID,
                   targetid = Stiff->obj_id.objid,
                   targetos = Stiff->obj_id.osnum );
    __CheckRC( sts, 1, "NDmacro.ACtest_consumed", wrapup ) ;
    if( isConsumed & 1 ) 
    {
	__DBGpr_com( "Input Plate is Consumed" );
       goto wrapup;
    }

    // Get the Stiffener Web Left.
    sts = VLgetVSbeamFace( Stiff, VS_K_nmWebL, VL_Q_TOP_CURRENT, 
			   &web_surf[0], &msg );
    __CheckRC( sts, msg, "VLgetVSbeamFace: Web Left", wrapup ) ;
    __DBGpr_obj("Beam Web Left", web_surf[0].obj_id );
    if( web_surf[0]._objid == NULL_OBJID ) goto wrapup;

    // Get the Stiffener Web Right.
    sts = VLgetVSbeamFace( Stiff, VS_K_nmWebR, VL_Q_TOP_CURRENT, 
                           &web_surf[1], &msg );
    __CheckRC( sts, msg, "VLgetVSbeamFace: Web Right", wrapup ) ;
    __DBGpr_obj("Beam Web Right", web_surf[1].obj_id );
    if( web_surf[1]._objid == NULL_OBJID ) goto wrapup;

    // Get the Plate Base Surface
    sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plBotSfPath,
                                      &plt_surf[0].obj_id,
                                      &plt_surf[0]._matrix_type,
                                      plt_surf[0]._matrix ),
                   senderid = NULL_OBJID,
                   targetid = Plate->_objid,
                   targetos = Plate->_osnum ) ;
    __CheckRC( sts, msg, "NDmacro.ACreturn_foot: Base", wrapup ) ;
    __DBGpr_obj("Plate Base Surface", plt_surf[0].obj_id );

    plt_surf[0]._md_os = Plate->_md_os;
    sts = ex$get_modid( mod_osnum = plt_surf[0]._md_os,
			mod_id    = &plt_surf[0]._md_id );

    // Get the Plate Offset Surface.
    sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      &msg,
                                      VS_K_plTopSfPath,
                                      &plt_surf[1].obj_id,
                                      &plt_surf[1]._matrix_type,
                                      plt_surf[1]._matrix ),
                   senderid = NULL_OBJID,
                   targetid = Plate->_objid,
                   targetos = Plate->_osnum ) ;
    __CheckRC( sts, msg, "NDmacro.ACreturn_foot: Offset", wrapup ) ;
    __DBGpr_obj("Plate Offset Surface", plt_surf[1].obj_id );

    plt_surf[1]._md_os = Plate->_md_os;
    sts = ex$get_modid( mod_osnum = plt_surf[1]._md_os,
                        mod_id    = &plt_surf[1]._md_id );

    for( i=0; i<2; ++i )
    {
	for( j=0; j<VDEFP_NEAT_EDGES_MAX; ++j )   _FREE( edgeGeom[j] );

        sts = VDefpGetSurfaceEdgeBsps( 	&plt_surf[i], VDEFP_NEAT_EDGES_MAX,
                             		tol, &edgeCnt, edgeGeom );
   	__CheckRC( sts, msg, "VDefpGetSurfaceEdgeBsps", wrapup );

        for( j=0; j<edgeCnt; ++j )
        {
           if( VLcurve_fully_on_surface( edgeGeom[j], &web_surf[0], tol ) )
	   {
	      __DBGpr_com( "Edge is on Web Left Surface" );
	      result = TRUE;
	      *left_or_right = 0;
              goto wrapup;
	   }

           if( VLcurve_fully_on_surface( edgeGeom[j], &web_surf[1], tol ) )
           {
	      __DBGpr_com( "Edge is on Web Right Surface" );
	      result = TRUE;
	      *left_or_right = 1;
	      goto wrapup;
           }
        }
    }

wrapup:
    for( j=0; j<VDEFP_NEAT_EDGES_MAX; ++j )   _FREE( edgeGeom[j] );
    if( result )	
    {
       __DBGpr_com( "Returning Success" );
       End
       return MSSUCC;
    }
    else
    {
       __DBGpr_com( "Returning Failure" );
       End
       return MSFAIL;
    }
}

IGRlong	VLstfMarkPlate(	IGRlong			*msg,
			struct GRobj_env	*Stiff,
			struct GRobj_env	*Plate,
			IGRint			left_or_right,
			struct GRid		*stfMark )
{
IGRlong                 sts;
IGRint                  i, nb_marks;
IGRshort		trimming_options;
struct GRid		*markIds=NULL;
struct GRobj_env	web_surf, base_surf;
struct GRlc_info      	surfInfo, webInfo ;
struct GRvg_construct	cnst;

    SetProc( VLstfMarkPlate ); Begin

    sts = *msg = OM_S_SUCCESS;

    __DBGpr_int( "left_or_right", left_or_right );

    web_surf._objid = NULL_OBJID;
    surfInfo.located_obj.objid = NULL_OBJID;
    webInfo.located_obj.objid  = NULL_OBJID;

    VLinitCnst( &cnst );

    if( left_or_right == 0 )
    {
       // Get the Stiffener Web Left.
       sts = VLgetVSbeamFace( Stiff, VS_K_nmWebL, VL_Q_TOP_CURRENT,
                              &web_surf, msg );
       __CheckRC( sts, *msg, "VLgetVSbeamFace: Web Left", wrapup ) ;
       __DBGpr_obj("Beam Web Left", web_surf.obj_id );
    }
    else if( left_or_right == 1 )
    {
       // Get the Stiffener Web Right.
       sts = VLgetVSbeamFace( Stiff, VS_K_nmWebR, VL_Q_TOP_CURRENT,
                              &web_surf, msg );
       __CheckRC( sts, *msg, "VLgetVSbeamFace: Web Right", wrapup ) ;
       __DBGpr_obj("Beam Web Right", web_surf.obj_id );
    }
    if( web_surf._objid == NULL_OBJID ) goto wrapup;

    // Get the Plate Base Surface
    sts = om$send( msg    = message NDmacro.ACreturn_foot(
                                      msg,
                                      VS_K_plBotSfPath,
                                      &base_surf.obj_id,
                                      &base_surf._matrix_type,
                                      base_surf._matrix ),
                   senderid = NULL_OBJID,
                   targetid = Plate->_objid,
                   targetos = Plate->_osnum ) ;
    __CheckRC( sts, *msg, "NDmacro.ACreturn_foot: Base", wrapup ) ;
    __DBGpr_obj("Plate Base Surface", base_surf.obj_id );

    base_surf._md_os = Plate->_md_os;
    sts = ex$get_modid( mod_osnum = base_surf._md_os,
                        mod_id    = &base_surf._md_id );

    if( Plate->_objid == 115021 && Plate->_osnum == 36 )
    {
	VDdumpSurface( &web_surf, NULL, "web" );
	VDdumpSurface( &base_surf, NULL, "base" );
    }

    webInfo.module_info  = *(cnst.env_info);
    vd_$grCopy( msg   = msg,
	        frEnv = &web_surf.mod_env, 
		frObj = &web_surf.obj_id,
		toEnv = &webInfo.module_info, 
		toObj = &webInfo.located_obj );
    __DBGpr_obj("Copied Beam Surface", webInfo.located_obj );

    surfInfo.module_info = *(cnst.env_info);
    vd_$grCopy( msg   = msg,
		frEnv = &base_surf.mod_env, 
		frObj = &base_surf.obj_id,
	        toEnv = &surfInfo.module_info, 
		toObj = &surfInfo.located_obj );
    __DBGpr_obj("Copied Plate Base Surface", surfInfo.located_obj );

    trimming_options = EMSINT_TRIM_HANDLESTOP | EMSINT_TRIM_OUTPUT |
		       EMSINT_TRIM_BDRYISAREA | EMSINT_TRIM_COPLANAR |
		       EMSINT_TRIM_PROCOVERLAP;

    sts = EMintersect_two_element( &webInfo, &surfInfo, trimming_options, 
				   &cnst, &nb_marks, &markIds, msg );
    __CheckRC( sts, *msg, "EMintersect_two_element", wrapup ) ;
    __DBGpr_int("Number of Intersections", nb_marks );

    if( !nb_marks ) { sts = MSFAIL; goto wrapup; }

    *stfMark = markIds[0];

    vs$bulk_delete( count   = nb_marks-1,
                    grids   = &markIds[1],
                    theEnv  = cnst.env_info ) ;

wrapup:
    vs$bulk_delete( grids  = &webInfo.located_obj, 
		    theEnv = &webInfo.module_info );

    vs$bulk_delete( grids  = &surfInfo.located_obj, 
                    theEnv = &surfInfo.module_info );

    _FREE( markIds );
    End
    return (sts);
}

IGRlong		VLautoMarkStiffener( IGRlong		*msg,
				     struct GRobj_env	Stiff,
				     struct GRmd_env	loc_env )
{
IGRlong			sts;
IGRint          	i, max=0, rangeFlag=0, nb_class, left_or_right, suc,
			count=0;
IGRdouble		exp_factor;
IGRchar         	status_msg[128];
GRclassid		classids[1];
GRrange         	range,new_range;
struct GRid		expId, mrk_macro, Temp[3];
struct GRobj_env       	gensolOE, *list=NULL;

    SetProc( VLautoMarkStiffener ); Begin

    sts = *msg = OM_S_SUCCESS;

    __DBGpr_obj( "Input Stiffener Object", Stiff.obj_id );
    vdobj$GetFoot( objOE    = &Stiff,
                   footName = VS_K_bmGrCmpName,
                   footOE   = &gensolOE);
    if( gensolOE._objid == NULL_OBJID ) goto wrapup;
    __DBGpr_obj( "Graphic Foot", gensolOE.obj_id );

    vs$getRangeOfComposite( msg       = msg,
                            composite = &gensolOE,
                            range     = range       );
    __CheckRC( 1, *msg, "vs$getRangeOfComposite", wrapup );

    // Extend the range by so that all the legal marking objects are grabbed
    rangeFlag = VLgiveRangeExp(&exp_factor);
    if(!rangeFlag) exp_factor = 0.05; // 5% default expansion

    for(i=0;i<3;i++)
       new_range[i] = ((1.0+exp_factor)*range[i]) - (exp_factor*range[i+3]);
    __DBGpr_vec( "Extended Range Low Point", &new_range[0] );

    for(i=0;i<3;i++)
       new_range[i+3] = -(exp_factor*range[i]) +
                         ((1.0+exp_factor)*range[i+3]);
    __DBGpr_vec( "Extended Range High Point", &new_range[3] );

    nb_class    = 1;
    classids[0] = OPP_VSplate_class_id;

    /* Function which will NOT LOCATE */
    VD_findall_objects_in_range( new_range, nb_class, classids,
                                 TRUE, loc_env, &count, &list );
    __DBGpr_int( "Range Check Finds", count );

    /* Geometric filter on result */
    max = count;
    count = 0;
    for ( i=0; i<max; i++)
    {
       sprintf( status_msg,
                "Validating Objects for AutoMarking ... %d / %d", i+1, max );
       UI_status( status_msg );

       if( VLpcTildaMarkingDefined(  &list[i] ) )  continue;

       if( VLpcStfMarkExists( &Stiff, &list[i], &loc_env ) ) continue;

       if ( VLcheckPlateForMarking( &Stiff, &list[i],
                   		    &left_or_right, &loc_env ) & 1)
       {
          ASmake_source_from_env( &Stiff.obj_id, &loc_env, &Temp[0] ) ;
          ASmake_source_from_env( &list[i].obj_id, &loc_env, &Temp[1] ) ;

          exp$create( exp_syntax = "dummy",
                      osnum      = loc_env.md_id.osnum,
                      p_exp_id   = &Temp[2].objid,
                      p_osnum    = &Temp[2].osnum,
                      type_rq    = EXP_TEXT );

          mrk_macro.objid = NULL_OBJID ;
          mrk_macro.osnum = loc_env.md_id.osnum;
          sts = om$construct( classid = OPP_nci_macro_class_id,
                              osnum   = mrk_macro.osnum,
                              p_objid = &mrk_macro.objid,
                              msg     = message ci_macro.init( 
					&suc, 0, "stfPcMark",
                                        3, Temp, NULL, &loc_env ) );
	  if( !(sts&1) || !(suc&1) )
          {
	      __DBGpr_com("stfPcMark Macro Placement Failed!!\n" );
	      om$send(  msg      = message Root.delete( 0 ),
			senderid = NULL_OBJID,
                        targetid = mrk_macro.objid,
                        targetos = mrk_macro.osnum ) ;
          }
          __DBGpr_obj( "stfPcMark Macro", mrk_macro );
          list[count++] = list[i];
       }
    }
    __DBGpr_int("Eligible Plate Count for Auto Marking", count );


wrapup:
    UI_status( "" );
    _FREE( list );
    End
    return (sts);
}

end implementation VDSroot;
