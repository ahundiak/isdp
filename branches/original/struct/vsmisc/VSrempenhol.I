/* $Id: VSrempenhol.I,v 1.6 2002/02/28 18:17:59 ylong Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsmisc/VSrempenhol.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSrempenhol.I,v $
 *      Revision 1.6  2002/02/28 18:17:59  ylong
 *      VSgetChildrenPlate() args changed to take care of compilation warnings
 *
 *      Revision 1.5  2001/04/11 22:33:38  ramarao
 *      Fixed TR# 5010. Replace overlap function with BScvcv_int().
 *
 *      Revision 1.4  2001/02/20 01:19:07  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.3  2001/02/06 19:19:04  build
 *      Add include file
 *
 *      Revision 1.2  2001/01/31 22:09:58  ramarao
 *      Implemented CR# 4564.
 *
 *      Revision 1.1  2001/01/31 17:25:42  ramarao
 *      Implemented CR# 4564.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      01/31/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "vs.h"
#include "VDmem.h"
#include "VDchn.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "v_edgemacros.h"
#include "v_geommacros.h"
#include "VDobj.h"
#include "vsjoint.h"
#include "vsjointdef.h"
#include "vsplatedef.h"
#include "vsdrw.h"
#include "vsdbgmacros.h"

#define vdsDEBUG	1
#define vdserrDEBUG	1

extern OM_S_CHANSELECT      AS_to_owner;

extern GRclassid OPP_GRcurve_class_id, OPP_VSplate_class_id,
		 OPP_VSmodPlate_class_id, OPP_VSdivFeature_class_id;

from VSfeature	import	VSforwardToOriginal, VSexecuteFunctionAlongGeneration;
from EMSsubbs   import  EMproject_curve_along_surface_normals;

#define MAX_NAMES_TO_DELETE	50

static IGRint		nb_mac_to_del;
static VStktxt		mac_to_del[MAX_NAMES_TO_DELETE];

VSinitNamesToDelete()
{
IGRint		i;

   nb_mac_to_del = 0;
   for( i=0; i<MAX_NAMES_TO_DELETE; ++i ) mac_to_del[i][0] = '\0';
}

VSaddInternalNamesToDelete( VSdrwArgLst		*arglist )
{
VSdrwArgLst	*argv;

   SetProc( VSaddInternalNamesToDelete ); Begin

   for( argv = arglist; argv ; argv = argv->next )
   {
      if( argv->arg.type != VS_string ) continue;
      strcpy( mac_to_del[nb_mac_to_del], argv->arg.v.sval );
      __DBGpr_str( "Macro Name to Delete", mac_to_del[nb_mac_to_del] );
      nb_mac_to_del++;
   }
   __DBGpr_int( "Total number of macros to delete", nb_mac_to_del );

wrapup:
   End;
}
					
static IGRint	VSgetChildrenPlate( const struct GRid *plate,
				    void              *voidList )
{
IGRlong         sts, msg;
IGRint          i, j, count, mac_cnt;
IGRchar         macName[DI_PATH_MAX];
struct GRid     tmp_id, *pChild;
VSlistElmtId    *cuList;

   /* Initialization */
   pChild  = NULL;
   count   = 0;

   sts = VSgetChildrenGoThruPretends( &msg, plate, &count, &pChild );
   if( ! (sts&msg&1) || !count )      goto    wrapup;

   cuList = (VSlistElmtId *)voidList;

   for( i=0, mac_cnt=0; i<count; i++ )
   {
	if( vd_$is_ancestry_valid( object  = &pChild[i],
				   classid = OPP_VSplate_class_id ) &&
	   !vd_$is_ancestry_valid( object  = &pChild[i],
                                   classid = OPP_VSdivFeature_class_id ) )
        {
           tmp_id          = pChild[mac_cnt];
           pChild[mac_cnt] = pChild[i];
           pChild[i]       = tmp_id;
           mac_cnt++;
        }
   }
   if( !mac_cnt ) goto wrapup;
   count = mac_cnt;

   if( *(cuList->pList) )
   {
       *(cuList->pList) = _REALLOC( *(cuList->pList),
                                (*(cuList->pCount) + count), struct GRid );
   }
   else
   {
       *(cuList->pList) = _MALLOC( count, struct GRid );
   }

   if( !(*(cuList->pList)) )
   {
       printf(" Error : Not enought memory to allocate pList\n" );
       _FREE( pChild );
       return  FALSE;
   }

   for( i=*cuList->pCount, j=0; j<count; i++, j++ )
             (*cuList->pList)[i] = pChild[j];

   *cuList->pCount += count;

wrapup :
   _FREE( pChild );
   return  TRUE;
}

IGRlong		VSremovePenetrationHoles( IGRlong		*msg,
					  struct GRid		*plate_id,
					  struct GRmd_env       *plate_env,
					  IGRint		*hole_cnt,
					  struct GRid		*hole_list  )
{
BSrc			rc;
IGRlong			sts, nb_inter=0, nover=0;
IGRint			i, j, k, plt_cnt=0, parent_cnt, nint=0;
IGRchar			macName[50];
IGRdouble		*xintpts=NULL, *xpar0=NULL, *xpar1=NULL, 
			*xendpts=NULL, *xover0=NULL, *xover1=NULL;
struct GRid		pretendId, macId, ownerId, grEdge, *plt_list=NULL;
struct GRobj_env	crvOE, plt_surf;
struct GRvg_construct	cnst;
struct GRlc_info	baseInfo, crvInfo;
struct IGRbsp_curve	*edgeGeom=NULL, *crvGeom=NULL;
OM_S_OBJID              *projCrvs=NULL;
VSlistElmtId     	fctArgs;

   SetProc( VSremovePenetrationHoles ); Begin

   sts = *msg = MSSUCC;

   if( nb_mac_to_del == 0 )
   {
	__DBGpr_com( "Nothing to check against. Returning" );
	return sts;
   }
   __DBGpr_obj( "Input Plate ID ", *plate_id );
   __DBGpr_int( "Hole Count", *hole_cnt );

   VDsupInitCnst( &cnst );
   baseInfo.located_obj.objid = crvInfo.located_obj.objid = NULL_OBJID;

   fctArgs.pList  = &plt_list;
   fctArgs.pCount = &plt_cnt;

   sts = om$send( msg = message VSfeature.VSforwardToOriginal(
                        msg,
                        OM_e_wrt_object,
                        message NDmacro.ACreturn_foot( msg, VS_K_plBotSfPath,
			   &plt_surf.obj_id, &plt_surf._matrix_type,
                            plt_surf._matrix ) ),
                   senderid = NULL_OBJID,
                   targetid = plate_id->objid,
                   targetos = plate_id->osnum ) ;
    __CheckRC( sts, *msg, "NDmacro.ACreturn_foot: Base", wrapup ) ;
    __DBGpr_obj("Plate Base Surface", plt_surf.obj_id );
    plt_surf._md_os = plate_id->osnum;
    sts = ex$get_modid( mod_osnum = plt_surf._md_os,
                        mod_id    = &plt_surf._md_id );

    baseInfo.module_info  = *(cnst.env_info);
    vd_$grCopy( msg   = msg,
                frEnv = &plt_surf.mod_env,
                frObj = &plt_surf.obj_id,
                toEnv = &baseInfo.module_info,
                toObj = &baseInfo.located_obj );
    __DBGpr_obj("Copied Plate Surface", baseInfo.located_obj );

   *msg = -2;
   sts = om$send( msg = message VSfeature.VSforwardToOriginal( 
			msg, 
			OM_e_wrt_object,
			message VSfeature.VSexecuteFunctionAlongGeneration(
			  		plate_id, VSgetChildrenPlate, 
					(void*)&fctArgs, FALSE ) ),
	  senderid = NULL_OBJID,
	  targetid = plate_id->objid,
	  targetos = plate_id->osnum );
   if( *msg == -2 )
   {
       sts = VSgetChildrenPlate( plate_id, &fctArgs );
       if( sts & 1 )   	*msg = MSSUCC;
       else		*msg = MSFAIL;
   }
   if( ! (sts&(*msg)&1)){ sts = MSFAIL; goto wrapup; }
   __DBGpr_int("Number of Child Plates returned ", plt_cnt ); 

   for( i=0; i<plt_cnt; ++i )
   {
       __DBGpr_obj( "Child Plate", plt_list[i] );
       if( !vd_$is_ancestry_valid( object  = &plt_list[i],
                             classid = OPP_VSmodPlate_class_id ) ) continue;

       vdchn$Get2( objID  = &plt_list[i], 
		   chnIDx = VDCHN_IDX_PARENT, 
		   cnt    = &parent_cnt );

       for( j=0; j<(parent_cnt-1); ++j )
       {
	  vdobj$GetParent( objID    = &plt_list[i],
                           idx      = j+1,
                           parentID = &macId );

	  // __DBGpr_obj( "Cutting Curve", macId );

	  vdobj$Get( objID = &macId, macName = macName );

	  for( k=0; k<nb_mac_to_del; ++k )
	     if( !strcmp( macName, mac_to_del[k] ) ) break;

	  if( k == nb_mac_to_del )	continue;

	  __DBGpr_com( "Trying to delete the edge for this macro" );

	  vdchn$Get2( objID = &plt_list[i], chnIDx = VDCHN_IDX_PARENT,
		      nth = j+1, outID = &pretendId );
	  __DBGpr_obj( "Pretend ID", pretendId );

	  sts = om$send( msg = message NDnode.ASreturn_go( &crvOE.obj_id,
				&crvOE._matrix_type, crvOE._matrix ),
		senderid = NULL_OBJID,
		targetid = pretendId.objid,
        	targetos = pretendId.osnum  );
	  if( !(sts&1) ) continue;
	  crvOE._md_os = crvOE._osnum ;
	  ex$get_modid( mod_osnum = crvOE._md_os,
                        mod_id    = &crvOE._md_id );
	  __DBGpr_obj( "Actual Curve Graphic", crvOE.obj_id );

	  if( !vd_$is_ancestry_valid( object  = &crvOE.obj_id,
		classid = OPP_GRcurve_class_id ) ) continue;

	  __DBGpr_obj( "Valid Cutting Curve", macId );

          crvInfo.module_info  = *(cnst.env_info);
          vd_$grCopy( msg   = msg,
                      frEnv = &crvOE.mod_env,
                      frObj = &crvOE.obj_id,
                      toEnv = &crvInfo.module_info,
                      toObj = &crvInfo.located_obj );
          __DBGpr_obj("Copied Curve", crvInfo.located_obj );

	  nb_inter = 0;
	  _FREE( projCrvs );
	  sts = om$send( msg = message 
			 EMSsubbs.EMproject_curve_along_surface_normals(
				&crvInfo, &baseInfo, &cnst, FALSE, TRUE,
				&nb_inter, &projCrvs, msg ),
		senderid = baseInfo.located_obj.objid,
                targetid = baseInfo.located_obj.objid,
                targetos = baseInfo.located_obj.osnum);
	  if( !(sts&1&(*msg)) || !nb_inter ) continue;
	  __DBGpr_int("Number of Projections", nb_inter );

	  crvOE._objid = projCrvs[0];
	  crvOE._osnum = cnst.env_info->md_id.osnum;

	  __DBGpr_obj( "Projected Curve", crvOE.obj_id );

	  _FREE( crvGeom );
          sts = vd_$get_geometry( msg      = msg,
                                  grobjId  = &crvOE.obj_id,     
                                  grobjEnv = plate_env,
                                  geometry = &crvGeom );

start_again:
	  for( k=0; k<(*hole_cnt); ++k )
	  {
	     sts = vd_$get_graphic_edge( msg     = msg,
                                         edId    = &hole_list[k],
                                         edEnv   = plate_env,
                                         copy    = FALSE,
                                         copyEnv = NULL,
                                         grEdge  = &grEdge ) ;
	     if( !(sts&1&(*msg)) ) continue;

	     _FREE( edgeGeom );
	     sts = vd_$get_geometry( msg      = msg,
				     grobjId  = &grEdge,
				     grobjEnv = plate_env,
				     geometry = &edgeGeom ); 
	     if( !(sts&1&(*msg)) ) continue;

	     nint = 0; nover = 0;
	     _FREE( xintpts ); _FREE( xpar0 ); _FREE( xpar1 );
	     _FREE( xendpts ); _FREE( xover0 ); _FREE( xover1 );
	     BScvcv_int( &rc, crvGeom, edgeGeom, &nint, &xintpts, &xpar0,
			 &xpar1, &nover, &xendpts, &xover0, &xover1 );
	     if( rc != BSSUCC ) continue;
	     if( nint == 0 && nover == 0 ) continue;
	   
	     __DBGpr_com( "Ready for Delete" );

	     grEdge = hole_list[k];
	     hole_list[k] = hole_list[(*hole_cnt)-1] ;
	     hole_list[(*hole_cnt)-1] = grEdge;
	
	     (*hole_cnt)--;

	     goto start_again;
	  }

          for( k=0; k<nb_inter; ++k )
	  {
	     crvOE._objid = projCrvs[k];
	     crvOE._osnum = cnst.env_info->md_id.osnum;
 
	     vd_$bulk_delete( grids  = &crvOE.obj_id,
                              theEnv = cnst.env_info );
 	  }
	  nb_inter = 0;
	  _FREE( projCrvs );
       }
   }
						
wrapup:

   if( baseInfo.located_obj.objid != NULL_OBJID )
   {
       vd_$bulk_delete(	grids  = &baseInfo.located_obj,
			theEnv = cnst.env_info );
   }

   if( crvInfo.located_obj.objid != NULL_OBJID )
   {
       vd_$bulk_delete( grids  = &crvInfo.located_obj,
                        theEnv = cnst.env_info );
   }

   for( k=0; k<nb_inter; ++k )
   {
      crvOE._objid = projCrvs[k];
      crvOE._osnum = cnst.env_info->md_id.osnum;

      vd_$bulk_delete( grids  = &crvOE.obj_id,
                       theEnv = cnst.env_info );
   }

   _FREE( plt_list );
   _FREE( projCrvs );
   _FREE( edgeGeom );
   _FREE( crvGeom  );
   _FREE( xintpts ); _FREE( xpar0 ); _FREE( xpar1 ); 
   _FREE( xendpts ); _FREE( xover0 ); _FREE( xover1 );
   sts = *msg = MSSUCC;
   End
   return sts;
}

end implementation VDSroot;
