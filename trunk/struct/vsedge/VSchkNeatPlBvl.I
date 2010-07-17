/* $Id: VSchkNeatPlBvl.I,v 1.8 2001/05/30 16:31:49 ramarao Exp $  */
/*************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsedge/VSchkNeatPlBvl.I
 *
 * Description: Functionality to update all the bevels nicely. 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSchkNeatPlBvl.I,v $
 *      Revision 1.8  2001/05/30 16:31:49  ramarao
 *      Fixed TR# 5269.
 *
 *      Revision 1.7  2001/05/03 18:58:57  ramarao
 *      Fixed a crash. - TR# 5172
 *
 *      Revision 1.6  2001/05/01 14:52:40  ramarao
 *      Supressed warning messages.
 *
 *      Revision 1.5  2001/04/28 17:06:48  ramarao
 *      Fixed ETL# 7962.
 *
 *      Revision 1.4  2001/03/20 20:54:26  ramarao
 *      Given a good name for bevels and some fixes.
 *
 *      Revision 1.3  2001/03/13 00:47:04  ramarao
 *      Assigned proper font size to bevels.
 *
 *      Revision 1.2  2001/03/09 17:35:27  ramarao
 *      Implemented functions to get proper label positions.
 *
 *      Revision 1.1  2001/03/03 21:23:38  ramarao
 *      Handled Neat Plate Recompute Process.
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      03/03/01   Rama Rao     File Creation.
 *	03/09/01   Rama Rao	Added Function to get proper label positions.
 *************************************************************************/

class implementation VDSroot;

#include "EMSmsgdef.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VDobj.h"
#include "VDmem.h"
#include "VDchn.h"
#include "VDefp.h"
#include "VDsa.h"
#include "vdAPImacros.h"
#include "v_datamacros.h"
#include "v_geommacros.h"
#include "v_miscmacros.h"
#include "VSefp.h"
#include "vsdbgmacros.h"

from ACpretend	import	ACpconnect, ACgive_downscan;
from ci_macro	import	init;
from GR3dtext   import  GRgettxattr;

extern GRclassid	OPP_nci_macro_class_id, OPP_GRcurve_class_id;

/*
 * Set the Font Global Variable.
 */
static void VSbvlSetGlobalFontSize( struct GRid	bevelID )
{
IGRlong			sts, msg;
struct GRid		textID;
struct   IGRestx        text_attr;

    textID.objid = NULL_OBJID;
    vdchn$Get2( objID   = &bevelID,
		chnIDx  = VDCHN_IDX_TO_COMPONENTS,
		nth	= 2,
		outID	= &textID );
    if( textID.objid == NULL_OBJID ) goto wrapup;

    if( !vd_$is_ancestry_valid( object  = &textID,
                                classid = OPP_GR3dtext_class_id ) )
    {
       goto wrapup;
    }

    sts = om$send(  msg     = message GR3dtext.GRgettxattr( &msg,
                        &text_attr, NULL, NULL ),
                        senderid= textID.objid,
                        targetid= textID.objid,
                        targetos= textID.osnum ) ;
    if( !(sts&1&msg) ) goto wrapup;

    VSbvl_set_font_size( (int)text_attr.width );
    return;

wrapup:
    VSbvl_set_font_size( 25 );
    return;
}

/*
 * Get Bevel Label Position.
 */
static void VSbvlGetBevelLabelPoisions( struct GRid	   *parent_list,
					IGRint		   change_index,
					struct GRid        edgeID,
				        IGRboolean	   change_connect,
					struct GRid	   *bevelID,
				        struct GRmd_env	   cur_env        )
{
BSrc			rc;
IGRlong		      	sts, msg; 
IGRint			other_edge_index;
IGRdouble              	offsetVal=0.0;
struct GRid            	pret_parent;
struct GRobj_env       	edge1OE, edge2OE, plate1OE, plate2OE,
                       	pt1OE, pt2OE, bvlCrvOE;
struct IGRbsp_curve	*bvlCrv=NULL;

    if( change_index == 3 )     other_edge_index = 4;
    else                        other_edge_index = 3;

    __DBGpr_int( "Other Edge Index", other_edge_index );
    __DBGpr_obj( "Other Edge Pretend", parent_list[other_edge_index] );

    sts = vd_$return_foot( msg = &msg, name = "",
                           objId = &parent_list[other_edge_index],
                           footId = &edge1OE.obj_id,
                           footEnv = &edge1OE.mod_env );
    __DBGpr_obj( "Edge1", edge1OE.obj_id );
	
    VDahGetObjectEnv( &edgeID, &edge2OE );
    __DBGpr_obj( "Edge2", edge2OE.obj_id );

    bvlCrvOE.obj_id.objid  = NULL_OBJID;
    sts = ConstructBevel( &edge1OE, &edge2OE, &bvlCrvOE, &bvlCrv );
    if( !(sts&1) || bvlCrvOE.obj_id.objid == NULL_OBJID ) goto wrapup;
    vdobj$Delete( objOE = &bvlCrvOE );

    vdobj$GetPretendParent( pretendID = &parent_list[1],
                            parentID  = &pret_parent );
    VDahGetObjectEnv( &pret_parent, &plate1OE );
    vdobj$GetPretendParent( pretendID = &parent_list[2],
                            parentID  = &pret_parent );
    VDahGetObjectEnv( &pret_parent, &plate2OE );
    __DBGpr_obj( "Plate1", plate1OE.obj_id );
    __DBGpr_obj( "Plate2", plate2OE.obj_id );

    vdsa$GetStruct( objID = &parent_list[0],
                    name  = "offset_value",
                    dbl   = &offsetVal );
    __DBGpr_dbl( "Offset Value", offsetVal );

    sts = GetLabelPoint( &plate1OE, bvlCrv, offsetVal, &pt1OE );
    if( !(sts&1) || pt1OE.obj_id.objid == NULL_OBJID ) goto wrapup;
    ASmake_source_from_env( &pt1OE.obj_id, &cur_env, &pret_parent );

    if( change_connect )
    {
       sts = om$send( msg = message NDnode.NDchange_connect(
                             1, &parent_list[5], &pret_parent ),
                      senderid = bevelID->objid,
                      targetid = bevelID->objid,
                      targetos = bevelID->osnum );
    }
    else 
    {
       sts = om$send ( msg = message NDnode.NDchg_state
                                        ( ND_SUP_ONLY, ND_SUP_ONLY ),
		       senderid = pret_parent.objid,
                       targetid = pret_parent.objid,
                       targetos = pret_parent.osnum   );
       parent_list[5] = pret_parent;
    }

    sts = GetLabelPoint( &plate2OE, bvlCrv, -1*offsetVal, &pt2OE );
    if( !(sts&1) || pt2OE.obj_id.objid == NULL_OBJID ) goto wrapup;
    ASmake_source_from_env( &pt2OE.obj_id, &cur_env, &pret_parent );

    if( change_connect )
    {
       sts = om$send( msg = message NDnode.NDchange_connect(
                             1, &parent_list[6], &pret_parent ),
                      senderid = bevelID->objid,
                      targetid = bevelID->objid,
                      targetos = bevelID->osnum );
    }
    else 
    {
       sts = om$send ( msg = message NDnode.NDchg_state
                                        ( ND_SUP_ONLY, ND_SUP_ONLY ),
		       senderid = pret_parent.objid,
                       targetid = pret_parent.objid,
                       targetos = pret_parent.osnum   );
       parent_list[6] = pret_parent;
    }

    __DBGpr_obj( "Point1", pt1OE.obj_id );
    __DBGpr_obj( "Point2", pt2OE.obj_id );

wrapup:
    _FREE( bvlCrv );
    return;
}

/*
 * Get EJ_Bevel Label Position.
 */
static void VSbvlGetEJBevelLabelPoisions( struct GRid        *parent_list,
                                          struct GRid        edgeID,
                                          IGRboolean         change_connect,
                                          struct GRid        *bevelID,
                                          struct GRmd_env    cur_env        )
{
IGRlong                 sts, msg;
IGRdouble               offsetVal=0.0;
struct GRid             pret_parent;
struct GRobj_env        plateOE, ptOE;
struct IGRbsp_curve     *bvlCrv=NULL;

    sts = vd_$get_geometry( msg = &msg, grobjId = &edgeID,
                            grobjEnv = &cur_env, geometry = &bvlCrv );

    vdobj$GetPretendParent( pretendID = &parent_list[1],
                            parentID  = &pret_parent );
    VDahGetObjectEnv( &pret_parent, &plateOE );
    __DBGpr_obj( "Plate", plateOE.obj_id );

    vdsa$GetStruct( objID = &parent_list[0],
                    name  = "offset_value",
                    dbl   = &offsetVal );
    __DBGpr_dbl( "Offset Value", offsetVal );

    sts = GetLabelPoint( &plateOE, bvlCrv, offsetVal, &ptOE );
    if( !(sts&1) | ptOE.obj_id.objid == NULL_OBJID ) goto wrapup;
    ASmake_source_from_env( &ptOE.obj_id, &cur_env, &pret_parent );

    if( change_connect )
    {
       sts = om$send( msg = message NDnode.NDchange_connect(
                             1, &parent_list[3], &pret_parent ),
                      senderid = bevelID->objid,
                      targetid = bevelID->objid,
                      targetos = bevelID->osnum );
    }
    else 
    {
       sts = om$send ( msg = message NDnode.NDchg_state
                                        ( ND_SUP_ONLY, ND_SUP_ONLY ),
		       senderid = pret_parent.objid,
                       targetid = pret_parent.objid,
                       targetos = pret_parent.osnum );
       parent_list[3] = pret_parent;
    }
    __DBGpr_obj( "Point", ptOE.obj_id );

wrapup:
    _FREE( bvlCrv );
    return;
}

/*
 * Following function will modify an existing bevel and create bevels, if required.
 */
static void VSbvlModifyBevels( IGRint			bvlModifCnt,
		               IGRint			*bvlModifInfo,
			       struct GRid		*bevelList,
			       struct GRid		plateID,
			       struct GRid		neat_plate,
			       struct GRid		*edgeIDs,
			       struct GRmd_env      	cur_env 	)
{
IGRlong			sts, msg;
IGRint			i, j, parent_cnt=0, change_index, prev_bvl_idx=-1, 
			child_cnt, int_msg;
IGRchar			macName[40], down_scan[40], objPath[DI_PATH_MAX], *p,
			objName[DI_PATH_MAX];
struct GRid		bevelID, parentID, parent_list[10], copy_list[10];
struct  GRsymbology     symbology;

    __DBGpr_int( "Number of Bevels to Modify", bvlModifCnt );
    __DBGpr_obj( "Parent Plate for the neat plate", plateID );

    /*
     * For each bevel to modify or create a new bevel.
     */ 
    for( i=0; i<bvlModifCnt; ++i )
    {
      /*
       * This following check ( prev_bvl_idx != bvlModifInfo[2*i] ) will make 
       * sure that for any new bevel, for the first time it goes to IF block
       * and ELSE for all the others. Remeber that this function is called to 
       * split a bevel into multiple bevels. The first bevel is same except the
       * edge index. Also in the IF block parents are retained. For all the other
       * newly created bevels, this parent list is used, except the edge index.
       */
      if( prev_bvl_idx != bvlModifInfo[2*i] )
      {
	/*
	 * Get the Proper bevel from the bevel index and bevel list.
	 * Bevel index is stored first. So 2*i. Edge is stored at 2*i+1.
	 */
	prev_bvl_idx = bvlModifInfo[2*i];
        bevelID = bevelList[bvlModifInfo[2*i]];

	/*
	 * Get the parent list.
	 */
	__DBGpr_obj( "Checking Bevel", bevelID );
   	sts = vdchn$GetList( objID   = &bevelID,
                             chnIDx  = VDCHN_IDX_PARENT,
                             maxCnt  = 10,
			     cnt     = &parent_cnt,
			     outIDs  = parent_list   );
	for( j=0; j<parent_cnt; ++j )	// For each parent in the parent list
	{
	   /*
	    * Get the pretend Parent.
	    */
	   __DBGpr_obj( "Parent for this Bevel", parent_list[j] );
	   vdobj$GetPretendParent( pretendID = &parent_list[j],
				   parentID  = &parentID        );
	   if( parentID.objid == NULL_OBJID ) parentID = parent_list[j];
	   __DBGpr_obj( "Parent ID", parentID );

	   /*
	    * Check if this plate parent is matching with the current plate in 
	    * computation. If not matching, just continue in the loop.
 	    */
	   if( parentID.objid != plateID.objid  ||
	       parentID.osnum != plateID.osnum      ) continue;

	   /*
	    * Idea here isto get the proper edge parent index associated with the
	    * current plate. For 'Bevel' macro add the plate parent index with 
	    * '2' and for all the other bevel macros, add '1'.
	    * 'Bevel' macro could have two plate parents and the other bevel
	    * macros, viz. 'EJ_Bevel' and 'Fab_Stock' have only one plate parent.
	    */
	   vdobj$Get( objID = &bevelID, macName = macName );
	   if( !strcmp( macName, "Bevel" ) ) change_index = j+2;
	   else				     change_index = j+1;
	   __DBGpr_int( "Parent to Change Index", change_index );

	   /*
	    * Get the Proper Edge object index from the Input Edge List.
	    * Create an ACpretend object with downscan.
	    * This 'edge%2d' is taken from the bevl macro definitions.
	    */
	   __DBGpr_obj( "Edge object", edgeIDs[bvlModifInfo[2*i+1]] );
	   sprintf( down_scan, "edge%02d", bvlModifInfo[2*i+1] );

	   parentID.objid = NULL_OBJID;
	   parentID.osnum = cur_env.md_id.osnum;
	   sts = om$construct(
			   classid = OPP_ACpretend_class_id,
                           osnum   = parentID.osnum,
                           p_objid = &parentID.objid,
                           msg = message 
			     ACpretend.ACpconnect( 0, neat_plate, down_scan ) );
	   __DBGpr_obj( "Old Parent", parent_list[change_index] );
	   __DBGpr_obj( "New Parent", parentID );

	   /*
	    * Do Change Connect from the previous edge index to new edge index.
	    */
	   sts = om$send(msg = message NDnode.NDchange_connect(
				 1, &parent_list[change_index], &parentID ),
                        senderid = bevelID.objid,
                        targetid = bevelID.objid,
                        targetos = bevelID.osnum );

           VSbvlSetGlobalFontSize( bevelID );

           if( !strcmp( macName, "Bevel" ) )
           {
              VSbvlGetBevelLabelPoisions( parent_list, change_index, 
                                        edgeIDs[bvlModifInfo[2*i+1]], 
					TRUE, &bevelID, cur_env );
           }
	   else 
           {
	      VSbvlGetEJBevelLabelPoisions( parent_list, 
					    edgeIDs[bvlModifInfo[2*i+1]],
					    TRUE, 
					    &bevelID, cur_env );
	   }

	   /*
	    * Force the immediate recompute of this bevel object.
	    * nd$wait_batch() is not called intentionally here.
	    */
	   sts = om$send(msg = message NDnode.NDs_compute_node( 
					&msg, ND_COMP, &cur_env ),
                        senderid = bevelID.objid,
                        targetid = bevelID.objid,
                        targetos = bevelID.osnum );

	   /*
	    * Get the symbology and store it to assign to the the newly
	    * created bevels.
	    */
           sts = om$send( msg   = message GRvg.GRgetsymb( &msg, &symbology ),
                        senderid = bevelID.objid,
                        targetid = bevelID.objid,
                        targetos = bevelID.osnum );

	   /*
	    * Store the Object Name for later use in new bevels.
            */
	   vdobj$Get( objID = &bevelID, objPath = objPath );
	   p = strrchr( objPath,':' );
	   if(p)  *(p+1) = '\0'; 
	   else   objPath[0] = '\0';

	   /*
	    * Delete the ACpretend objects hanging in the object space without
	    * any children.  Good to delete them.
	    */
           child_cnt = 0;
           vdchn$GetList( objID = &parent_list[change_index],
                          chnIDx = VDCHN_IDX_CHILD, maxCnt = 1, 
			  cnt = &child_cnt );
           __DBGpr_int("Pretend Child Count", child_cnt );

           if( child_cnt == 0  )
              vd_$bulk_delete( grids  = &parent_list[change_index],
                               theEnv = &cur_env );
	   break;
	}
       }
       else
       {
	 /*
	  * Here, in this ELSE block, we have to create a new bevel object.
	  * Parent list and symbology are collected in the IF block.
	  * Just we need to assign the proper edge parent index.
	  */

	 /*
	  * Copy the parent list to a local buffer. 
	  * Better don't change the original parent list.
	  */
	 for( j=0; j<parent_cnt; ++j )  copy_list[j] = parent_list[j] ;

         /*
          * Get the Proper Edge object index from the Input Edge List.
          * Create an ACpretend object with downscan.
          * This 'edge%2d' is taken from the bevl macro definitions.
          */
	 parentID.objid = NULL_OBJID;
	 parentID.osnum = cur_env.md_id.osnum;
	 sprintf( down_scan, "edge%02d", bvlModifInfo[2*i+1] );
	 __DBGpr_int( "Edge Index", bvlModifInfo[2*i+1] );
	 sts = om$construct(
                       classid = OPP_ACpretend_class_id,
                       osnum   = parentID.osnum,
                       p_objid = &parentID.objid,
                       msg = message
                             ACpretend.ACpconnect( 0, neat_plate, down_scan ) );

	 /*
	  * This newly created ACpretend object will be used as a new parent
	  * at proper parent index.
	  */
	 copy_list[change_index] = parentID;

	 __DBGpr_str( "Placing Macro", macName );
	 __DBGpr_int( "Parent Count", parent_cnt );

	 /*
	  * Assign proper label positions.
	  */
	
	 if( !strcmp( macName, "Bevel" ) ) 
	 {
	    VSbvlGetBevelLabelPoisions( copy_list, change_index, 
				        edgeIDs[bvlModifInfo[2*i+1]], 
					FALSE, NULL, cur_env );
	 }
         else 
         {
            VSbvlGetEJBevelLabelPoisions( copy_list, 
                                          edgeIDs[bvlModifInfo[2*i+1]],
                                          FALSE, NULL, cur_env );
         }

	 /*
	  * Construct a New Bevel Object.
	  */
	 bevelID.objid = NULL_OBJID;
	 bevelID.osnum = cur_env.md_id.osnum;
	 sts = om$construct( 
			classid = OPP_nci_macro_class_id,
			osnum   = bevelID.osnum,
			p_objid = &bevelID.objid,
			msg = message  ci_macro.init( &int_msg, 0, 
			 macName, parent_cnt, copy_list, NULL, &cur_env ) );
	 if( sts&1&int_msg )
	 {
	    /*
	     * Assign Original Bevel Symbology.
	     */
	    __DBGpr_obj( "Created a New Bevel", bevelID );
            sts = om$send( msg   = message GRvg.GRputsymb( &msg,&symbology ),
                        senderid = bevelID.objid,
                        targetid = bevelID.objid,
                        targetos = bevelID.osnum );

	    /*
	     * Assign Good Name to this new bevel.
	     */
	    sprintf( objName, "%sM%d%d", objPath, 
			bevelID.objid, bevelID.osnum );

            sts = om$send( msg = message GRvg.GRputname( &msg, objName ),
                        senderid = bevelID.objid,
                        targetid = bevelID.objid,
                        targetos = bevelID.osnum );
	 }
	 else
	 {
	    /*
	     * If bevel creation is failed, delete the object.
	     */
	    vd_$bulk_delete( grids   = &bevelID, theEnv = &cur_env );
	 }
       }
    }

    return; 
}

/*
 * Following function will Check if there are any bevels overlapping 
 * and if there are any, deletes them.
 */

void VSremoveOverlappingBevels( struct GRid	neat_plate,
				struct GRmd_env cur_env       )
{
BSrc                    rc;
IGRlong                 sts, msg;
IGRint                  i, j, k, nbMac=0, bevelCnt=0, numDistCvs1=0,
                        numDistCvs2=0, numOvCvs=0, ovLapCode;
IGRchar			mac1Name[100], mac2Name[100];
struct GRid		*macList=NULL, crvId,bevelIDs[50], firstPlt[2], 
			secondPlt[2];
struct GRmd_env         crvEnv;
struct IGRbsp_curve     *crv1Geom=NULL, *crv2Geom=NULL, **DCvs1=NULL,
                        **DCvs2=NULL, **OCvs=NULL;

   /*
    * Collect all the child bevels on this plate. Note that we are not handling
    * variable bevels ( "VA_bevel" macros ) in this function.
    */

   sts = VSgetChildrenGoThruPretends(  &msg, &neat_plate, &nbMac, &macList );
   __CheckRC( sts, msg, "VSgetChildrenGoThruPretends", wrapup ) ;

   for( i=0; i<nbMac; ++i )
   {
      vdobj$Get( objID = &macList[i], macName = mac1Name );
      if( !strcmp( mac1Name, "Bevel"     ) ||
          !strcmp( mac1Name, "EJ_Bevel"  ) ||
          !strcmp( mac1Name, "Fab_Stock" )    )
      {
         bevelIDs[bevelCnt++] = macList[i];
      }
   }

   for( i=0; i<bevelCnt; ++i )		// For each bevel in the list.
   {
      vdobj$Get( objID = &bevelIDs[i], macName = mac1Name );
      for( j=i+1; j<bevelCnt; ++j )	// Note 'i+1'
      {
	if( bevelIDs[j].objid == NULL_OBJID ) continue;

	vdobj$Get( objID = &bevelIDs[j], macName = mac2Name );

	/*
	 * If macro names aren't macthing, no point in continuing.
	 */
	if( strcmp( mac1Name, mac2Name ) )  continue;

	/*
	 * Do the geometrical matching.
	 */
        sts = vd_$return_foot( msg = &msg, name = "curve", objId = &bevelIDs[i],
                               footId = &crvId, footEnv = &crvEnv );
        if( !(sts&1&msg) ) continue;

        if( !vd_$is_ancestry_valid( object  = &crvId,
                                classid = OPP_GRcurve_class_id ) ) continue;

        _FREE( crv1Geom );
        sts = vd_$get_geometry( msg = &msg, grobjId = &crvId,
                                grobjEnv = &crvEnv, geometry = &crv1Geom );

        sts = vd_$return_foot( msg = &msg, name = "curve", objId = &bevelIDs[j],
                               footId = &crvId, footEnv = &crvEnv );
        if( !(sts&1&msg) ) continue;

        if( !vd_$is_ancestry_valid( object  = &crvId,
                                classid = OPP_GRcurve_class_id ) ) continue;

        _FREE( crv2Geom );
        sts = vd_$get_geometry( msg = &msg, grobjId = &crvId,
                                grobjEnv = &crvEnv, geometry = &crv2Geom );

        if( numDistCvs1 )
        {
           for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
           _FREE( DCvs1 );
           numDistCvs1 = 0;
        }
        if( numDistCvs2 )
        {
           for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
           _FREE( DCvs2 );
           numDistCvs2 = 0;
        }
        if( numOvCvs )
        {
           for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
           _FREE( OCvs );
           numOvCvs = 0;
        }

        BSchk2cvsov( crv1Geom, crv2Geom, 1.0, 1, &ovLapCode,
                     &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2,
                     &numOvCvs, &OCvs, &rc );
	/*
	 * If there is no exact ( complete ) overlap, just continue;
	 */
        if( rc != BSSUCC || ovLapCode != 6 ) continue;

	/*
	 * Check if they have same plate parents.
	 */
        vdobj$GetParent( objID = &bevelIDs[i], idx = 1, parentID = &firstPlt[0] );
	vdobj$GetParent( objID = &bevelIDs[j], idx = 1, parentID = &secondPlt[0] );
	if( strcmp( mac1Name, "Bevel" ) )
	{
	   if( firstPlt[0].objid == secondPlt[0].objid &&
	       firstPlt[0].osnum == secondPlt[0].osnum    )
	   {
	      /*
	       * These two bevels are completely overlapped and parents are
	       * matching, So delete them.
	       */
	      __DBGpr_obj( "Deleting Bevel", bevelIDs[j] );
	      vd_$bulk_delete( grids  = &bevelIDs[j], theEnv = &cur_env );
	      bevelIDs[j].objid = NULL_OBJID;
	   }
	}
	else
	{
	    vdobj$GetParent( objID = &bevelIDs[i], idx = 2,
			     parentID = &firstPlt[1] );
            vdobj$GetParent( objID = &bevelIDs[j], idx = 2,
                             parentID = &secondPlt[1] );

	    if((( firstPlt[0].objid == secondPlt[0].objid &&
		  firstPlt[0].osnum == secondPlt[0].osnum    ) &&
	        ( firstPlt[1].objid == secondPlt[1].objid &&
                  firstPlt[1].osnum == secondPlt[1].osnum    ) ) ||
	       (( firstPlt[0].objid == secondPlt[1].objid &&
                  firstPlt[0].osnum == secondPlt[1].osnum    ) &&
                ( firstPlt[1].objid == secondPlt[0].objid &&
                  firstPlt[1].osnum == secondPlt[0].osnum    ) ) )
           {
              /*
               * These two bevels are completely overlapped and parents are
               * matching, So delete them.
               */
	      __DBGpr_obj( "Deleting Bevel", bevelIDs[j] );
              vd_$bulk_delete( grids  = &bevelIDs[j], theEnv = &cur_env );
              bevelIDs[j].objid = NULL_OBJID;
           }
	}
      }
   }
wrapup:
   _FREE( macList );
   _FREE( crv1Geom );
   _FREE( crv2Geom );
   if( numDistCvs1 )
   {
      for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
      _FREE( DCvs1 );
      numDistCvs1 = 0;
   }
   if( numDistCvs2 )
   {
      for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
      _FREE( DCvs2 );
      numDistCvs2 = 0;
   }
   if( numOvCvs )
   {
      for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
      _FREE( OCvs );
      numOvCvs = 0;
   }
   return;
}

/*
 * Following function will delete all the unwanted bevels.
 */
static void VSbvlDeleteUnwantedBevels( IGRint                   bvlModifCnt,
                                       IGRint                   *bvlModifInfo,
                               	       struct GRid              *bevelList,
                                       struct GRid              plateID,
                                       struct GRid              neat_plate,
                                       struct GRid              *edgeIDs,
                                       struct GRmd_env          cur_env       )
{
IGRlong                 sts, msg;
IGRint                  i, j, parent_cnt=0, change_index, prev_bvl_idx=-1, 
			child_cnt, int_msg;
IGRchar                 macName[40], down_scan[40];
struct GRid             bevelID, parentID, parent_list[10];

    __DBGpr_int( "bvlModifCnt", bvlModifCnt );
    __DBGpr_int( "Number of Bevels to Modify", bvlModifCnt );
    __DBGpr_obj( "Parent Plate for the neat plate", plateID );

    for( i=0; i<bvlModifCnt; ++i )
    {
        /*
         * Remeber that this function is called to merge multiple bevls into a 
         * single bevel. Get the Proper bevel from the bevel index and bevel list.
         * Get the Proper bevel from the bevel index and bevel list.
         * Bevel index is stored first. So 2*i. Edge is stored at 2*i+1.
         */
        prev_bvl_idx = bvlModifInfo[2*i];
        bevelID = bevelList[bvlModifInfo[2*i+1]];

        /*
         * Get the parent list.
         */
        __DBGpr_obj( "Updating Bevel to Full Bevel", bevelID );
        sts = vdchn$GetList( objID   = &bevelID,
                             chnIDx  = VDCHN_IDX_PARENT,
                             maxCnt  = 10,
                             cnt     = &parent_cnt,
                             outIDs  = parent_list   );
        for( j=0; j<parent_cnt; ++j )  // For each parent in the parent list
        {
           /*
            * Get the pretend Parent.
            */
           __DBGpr_obj( "Parent for this Bevel", parent_list[j] );
           vdobj$GetPretendParent( pretendID = &parent_list[j],
                                   parentID  = &parentID        );
           if( parentID.objid == NULL_OBJID ) parentID = parent_list[j];
           __DBGpr_obj( "Parent ID", parentID );

           /*
            * Check if this plate parent is matching with the current plate in
            * computation. If not matching, just continue in the loop.
            */
           if( parentID.objid != plateID.objid  ||
               parentID.osnum != plateID.osnum      ) continue;

           /*
            * Idea here is to get the proper edge parent index associated with the
            * current plate. For 'Bevel' macro add the plate parent index with
            * '2' and for all the other bevel macros, add '1'.
            * 'Bevel' macro could have two plate parents and the other bevel
            * macros, viz. 'EJ_Bevel' and 'Fab_Stock' have only one plate parent.
            */
           vdobj$Get( objID = &bevelID, macName = macName );
           if( !strcmp( macName, "Bevel" ) ) change_index = j+2;
           else                              change_index = j+1;
           __DBGpr_int( "Parent to Change Index", change_index );

           /*
            * Get the Proper Edge object index from the Input Edge List.
            * Create an ACpretend object with downscan.
            * This 'edge%2d' is taken from the bevl macro definitions.
            */
           __DBGpr_obj( "Edge object", edgeIDs[bvlModifInfo[2*i]] );
           sprintf( down_scan, "edge%02d", bvlModifInfo[2*i] );

           parentID.objid = NULL_OBJID;
           parentID.osnum = cur_env.md_id.osnum;
           sts = om$construct(
                           classid = OPP_ACpretend_class_id,
                           osnum   = parentID.osnum,
                           p_objid = &parentID.objid,
                           msg = message
                             ACpretend.ACpconnect( 0, neat_plate, down_scan ) );
           __DBGpr_obj( "Old Parent", parent_list[change_index] );
           __DBGpr_obj( "New Parent", parentID );

           /*
            * This newly created ACpretend object will be used as a new parent
            * at proper parent index.
	    * Do Change Connect from the previous edge index to new edge index.
            */
           sts = om$send(msg = message NDnode.NDchange_connect(
                                 1, &parent_list[change_index], &parentID ),
                        senderid = bevelID.objid,
                        targetid = bevelID.objid,
                        targetos = bevelID.osnum );

           VSbvlSetGlobalFontSize( bevelID );

           if( !strcmp( macName, "Bevel" ) )
           {
              VSbvlGetBevelLabelPoisions( parent_list, change_index,
                                        edgeIDs[bvlModifInfo[2*i]],
                                        TRUE, &bevelID, cur_env );
           }
           else
           {
              VSbvlGetEJBevelLabelPoisions( parent_list,
                                            edgeIDs[bvlModifInfo[2*i]],
                                            TRUE,
                                            &bevelID, cur_env );
           }

           /*
            * Force the immediate recompute of this bevel object.
            * nd$wait_batch() is not called intentionally here.
            */
           sts = om$send(msg = message NDnode.NDs_compute_node(
                                        &msg, ND_COMP, &cur_env ),
                        senderid = bevelID.objid,
                        targetid = bevelID.objid,
                        targetos = bevelID.osnum );

           /*
            * Delete the ACpretend objects hanging in the object space without
            * any children.  Good to delete them.
            */
	   child_cnt = 0;
	   vdchn$GetList( objID = &parent_list[change_index],
			  chnIDx = VDCHN_IDX_CHILD, maxCnt = 1, cnt = &child_cnt );
	   __DBGpr_int("Pretend Child Count", child_cnt );

	   if( child_cnt == 0  ) 
	      vd_$bulk_delete( grids  = &parent_list[change_index], 
			       theEnv = &cur_env );
           break;
        }
   }

   /*
    * Check if there are any bevels overlapping and delete them.
    */
   VSremoveOverlappingBevels( neat_plate, cur_env );

   return;
}

/*
 * Following function is called from NDupdate of neat plate macro. NDupdate of
 * ACncpx class was overwritten to call this function. Neat Plate has the latest 
 * foot when this function is called. This function's job is to update all the
 * attached bevels to proper parents by changing the edge indices.
 */
IGRlong VDcheckNeatPlateForBevels( struct GRid		neat_plate,
				   struct GRmd_env	cur_env		)
{
BSrc			rc;
IGRlong			sts, msg;
IGRint			i, j, k, nbMac=0, bevelCnt=0, numDistCvs1=0, numDistCvs2=0,
			numOvCvs=0, ovLapCode, bvlModifCnt=0, *bvlModifInfo=NULL,
			edgeCnt, cmpCnt;
IGRchar			macName[40];
struct GRid		crvId, plateID, *macList=NULL, bevelIDs[50], cmpIDs[101],
			*edgeIDs;
struct GRmd_env		crvEnv;
struct IGRbsp_curve	*crv1Geom=NULL, *crv2Geom=NULL, **DCvs1=NULL, 
			**DCvs2=NULL, **OCvs=NULL;

   SetProc( VDcheckNeatPlateForBevels ); Begin

   __DBGpr_obj( "Input Neat Plate", neat_plate );

   /*
    * Get the plate parent, which will be later on.
    */
   vdobj$GetParent( objID    = &neat_plate,
		    idx      = 0,
		    parentID = &plateID );
   if( plateID.objid == NULL_OBJID ) goto wrapup;

   /*
    * Get the latest edges of the neat plate macro.
    */
   sts = vdchn$GetList( objID   = &neat_plate,
                        chnIDx  = VDCHN_IDX_TO_COMPONENTS,
                        maxCnt  = 101,
                        cnt     = &cmpCnt,
                        outIDs  = cmpIDs   );

   /*
    * We don't need to handle the "point"  foot. Exclude this feet from the list.
    */
   edgeCnt = cmpCnt - 1; edgeIDs = cmpIDs + 1;

   /*
    * Collect all the child bevels on this plate. Note that we are not handling
    * variable bevels ( "VA_bevel" macros ) in this function.
    */
   sts = VSgetChildrenGoThruPretends(  &msg, &neat_plate, &nbMac, &macList );
   __CheckRC( sts, msg, "VSgetChildrenGoThruPretends", wrapup ) ;

   for( i=0; i<nbMac; ++i )
   {
      vdobj$Get( objID = &macList[i], macName = macName );
      if( !strcmp( macName, "Bevel"     ) ||
	  !strcmp( macName, "EJ_Bevel"  ) ||
	  !strcmp( macName, "Fab_Stock" )    )
      {
	 bevelIDs[bevelCnt++] = macList[i];
      }
   }
   __DBGpr_int( "Bevel Count", bevelCnt );
   __DBGpr_int( "Edge Count", edgeCnt );

   /*
    * If there are no bevels or edges, nothing to do.
    */
   if( !bevelCnt || !edgeCnt || !edgeIDs ) goto wrapup;

   /*
    * This "for" block will handle the case, when a bevel has to split into 
    * multiple bevels. ( Imagine a new cutout on a source plate )
    * Checking has to be done with respect to each bevel. See there are any 
    * edges overlapping with the bevel geometry.  If there is any overlapping
    * store the bevel index and edge index in 'bvlModifInfo' array.
    * Allocate memory for an integer array. This array will store the bevel index
    * and edge index successively in this first case.
    */
   if( !( bvlModifInfo = _MALLOC( 2*edgeCnt*bevelCnt, IGRint ) )) 
	vd_$mem_fail( msg = &msg );

   for( i=0; i<bevelCnt; ++i )	// For each bevel object in the bevel list
   {
      __DBGpr_obj( "Checking Bevel", bevelIDs[i] );
      /* 
       * Get the bevel geometry.
       */
      sts = vd_$return_foot( msg = &msg, name = "curve", objId = &bevelIDs[i],
		             footId = &crvId, footEnv = &crvEnv );
      if( !(sts&1&msg) ) continue;

      if( !vd_$is_ancestry_valid( object  = &crvId,
                                classid = OPP_GRcurve_class_id ) ) continue;

      _FREE( crv1Geom );	
      sts = vd_$get_geometry( msg = &msg, grobjId = &crvId, 
			      grobjEnv = &crvEnv, geometry = &crv1Geom );
      if( !(sts&1&msg) ) continue;

      for( j=0; j<edgeCnt; ++j )   // For each neat edge object in the edge list
      {
	 _FREE( crv2Geom );

	 /*
 	  * Get the neat edge geometry.
          */
	 sts = vd_$get_geometry( msg = &msg, grobjId = &edgeIDs[j],
                                 grobjEnv = &cur_env, geometry = &crv2Geom );
         if( !(sts&1&msg) ) continue;

	 /*
	  * Free all the previously allocated memory to call BS overlapping 
          * function.
          */
         if( numDistCvs1 )
         {
            for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
            _FREE( DCvs1 );
            numDistCvs1 = 0;
         }
         if( numDistCvs2 )
         {
            for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
            _FREE( DCvs2 );
            numDistCvs2 = 0;
         }
         if( numOvCvs )
         {
            for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
            _FREE( OCvs );
            numOvCvs = 0;
         }

	 /*
	  * call the BS function to check is there is any overlap.
	  * 1.0 is the search tolerance I used. We can change it later.
          * Also I used option 1.
          *
          * option  -1 - return only the OvLapCode
          *          0 - return only the distinct parts of the curves
          *          1 - return only the overlap portions of the curves
          *          2 - return both distinct and overlap portions
	  */ 
	 BSchk2cvsov( crv1Geom, crv2Geom, 1.0, 1, &ovLapCode,
		      &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2, 
		      &numOvCvs, &OCvs, &rc );
	 if( rc != BSSUCC ) continue;

	 /*
	  * Overlap Codes.
	  * -1:  cv1 is NOT within search_tol of cv2
	  *  0:  curve endpoints are touching within search_tol and thus we can
	  *      connect
	  *  1:  cv2 endpoint is within search_tol to somewhere on cv1. 
	  *	 cv2 will be extended and cv1 possibly split.
	  *  2:  cv1 endpoint is within search_tol to somewhere on cv2.
	  *      cv1 will be extended and cv2 possibly split.
	  *  3:  cv1 is entirely overlapping with cv2. No distinct curves will be
	  *	 be reurned for cv1, but cv2 will have some.
	  *  4:  cv2 is entirely overlapping with cv1.  No distinct curves will
	  *      be returned for cv2, but cv1 will have some.
	  *  5:  portion of cv1 and cv2 are overlapping and a portion of each is
	  *      distinct. 
	  *  6:  entire portion of cv1 and cv2 are overlapping each other.
	  *  7:  similar to 6: where the endpoints are touching,
	  *      but curves aren't overlapping
	  */

	 /*
	  * Check the overlap code. Continue, if they are not overlapping.
	  */
	 if( ovLapCode != 4 && ovLapCode != 5 && ovLapCode != 6 ) continue;

	 /*
	  * If there are no overlapping curves, just continue;
	  */
	 if( numOvCvs != 1 ) continue;

	 /*
	  * Store the bevel index and edge index in order. This is very important
          * in the later stage.
	  */
         bvlModifInfo[2*bvlModifCnt] = i;	// Bevel Index
	 bvlModifInfo[2*bvlModifCnt+1] = j;     // Edge  Index
	 bvlModifCnt++;				// Increment the count
      }
   }

   /*
    * If there any bevels to modify, call the following function to adjust the
    * bevels nicely.
    */
   if( bvlModifCnt )
   {
       VSbvlModifyBevels( bvlModifCnt, bvlModifInfo, bevelIDs, 
  		          plateID, neat_plate, edgeIDs, cur_env );
   }

   /*
    * This "for" block will handle the case, when multiple bevels has to merge
    * into a single bevel. ( Imagine a remove operator on a boo plate ).
    * Checking has to be done with respect to each neat edge. See there are any
    * bevels overlapping with the neat edge geometry.  If there is any overlapping
    * store the edge index and bevel index in 'bvlModifInfo' array.
    * Allocate memory for an integer array. This array will store the edge index
    * and bevel index successively in this second case.
    */

   bvlModifCnt = 0;
   for( i=0; i<edgeCnt; ++i )   // For each neat edge object.
   {
       /*
        * Get the neat edge geometry.
        */
       __DBGpr_obj( "Checking Edge", edgeIDs[i] );
       _FREE( crv1Geom );
       sts = vd_$get_geometry( msg = &msg, grobjId = &edgeIDs[i],
                               grobjEnv = &cur_env, geometry = &crv1Geom );
       if( !(sts&1&msg) ) continue;

       for( j=0; j<bevelCnt; ++j )	// For each bevel
       {
         /*
          * Get the bevel geometry.
          */
         __DBGpr_obj( "\tChecking Bevel", bevelIDs[j] );
         sts = vd_$return_foot( msg = &msg, name = "curve", objId = &bevelIDs[j],
                                footId = &crvId, footEnv = &crvEnv );
         if( !(sts&1&msg) ) continue;

         if( !vd_$is_ancestry_valid( object  = &crvId,
                                classid = OPP_GRcurve_class_id ) ) continue;

         _FREE( crv2Geom );
         sts = vd_$get_geometry( msg = &msg, grobjId = &crvId,
                                 grobjEnv = &crvEnv, geometry = &crv2Geom );
         if( !(sts&1&msg) ) continue;

         if( numDistCvs1 )
         {
            for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
            _FREE( DCvs1 );
            numDistCvs1 = 0;
         }
         if( numDistCvs2 )
         {
            for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
            _FREE( DCvs2 );
            numDistCvs2 = 0;
         }
         if( numOvCvs )
         {
            for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
            _FREE( OCvs );
            numOvCvs = 0;
         }

         /*
          * call the BS function to check is there is any overlap.
          * 1.0 is the search tolerance I used. We can change it later.
          * Also I used option 0.
	  * For more explanation on option and overlap codes, see the
	  * previous 'for' block.
	  */
         BSchk2cvsov( crv1Geom, crv2Geom, 1.0, 0, &ovLapCode,
                      &numDistCvs1, &DCvs1, &numDistCvs2, &DCvs2,
                      &numOvCvs, &OCvs, &rc );
         /*
          * Check the overlap code. Continue, if they are not overlapping.
	  * Note that we are checking for number of distinct curves on cv1.
          */
         if( rc != BSSUCC  || ovLapCode != 4 || numDistCvs1 == 0  ) continue;
	 __DBGpr_com( "OverLap Found" );

         /*
          * Store the Edge index and Bevel index in order. This is very important
          * in the later stage.
          */
         bvlModifInfo[2*bvlModifCnt] = i;	// Edge Index
         bvlModifInfo[2*bvlModifCnt+1] = j;	// bevel Index
	 bvlModifCnt++;				// Increment Counter.
       }
   }

   /*
    * If there any bevels to delete, call the following function to adjust the
    * bevels nicely.
    */
   if( bvlModifCnt )
   {
       VSbvlDeleteUnwantedBevels( bvlModifCnt, bvlModifInfo, bevelIDs,
                                  plateID, neat_plate, edgeIDs, cur_env );
   }

wrapup:
   _FREE( macList );
   _FREE( crv1Geom );
   _FREE( crv2Geom );
   _FREE( bvlModifInfo );
   if( numDistCvs1 )
   {
      for( k=0; k<numDistCvs1; ++k )      BSfreecv( &rc, DCvs1[k] );
      _FREE( DCvs1 );
      numDistCvs1 = 0;
   }
   if( numDistCvs2 )
   {
      for( k=0; k<numDistCvs2; ++k )      BSfreecv( &rc, DCvs2[k] );
      _FREE( DCvs2 );
      numDistCvs2 = 0;
   }
   if( numOvCvs )
   {
      for( k=0; k<numOvCvs; ++k )      BSfreecv( &rc, OCvs[k] );
      _FREE( OCvs );
      numOvCvs = 0;
   }
   End
   return sts;
}

end implementation VDSroot;
