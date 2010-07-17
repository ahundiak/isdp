/* $Id: VSchkNeatTemp.I,v 1.2 2001/10/31 16:45:03 ahundiak Exp $ */
/*************************************************************************
 * I/STRUCT
 *
 * File:        isdp/struct/vsedge/VSchkNeatTemp.I
 *
 * Description: Functionality for Connecting neat plates and bevels to
 *		proper plate parents and recompute them.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSchkNeatTemp.I,v $
 *      Revision 1.2  2001/10/31 16:45:03  ahundiak
 *      *** empty log message ***
 *
 *      Revision 1.1  2001/10/22 22:57:38  ramarao
 *      Fixed TR# 5663.
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR               DESCRIPTION
 *      10/22/01   Rama Rao             File Creation
 *************************************************************************/

class implementation VDSroot;

#include <math.h>
#include "EMSmsgdef.h"
#include "ndmacros.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vsplatedef.h"

#include "bsdistptpt.h"

extern struct GRid NULL_GRID;

extern GRclassid	OPP_nci_macro_class_id, OPP_VSplate_class_id,
			OPP_ACpretend_class_id;

from ACpretend import	ACgive_downscan;

static VSconnectPlateBevels( struct GRobj_env	*pltOE,
			     struct GRobj_env   *neatOE,
			     struct GRmd_env    *cur_env  )
{
IGRlong			sts, msg;
IGRint			i, j, k, index, child_cnt=0, parent_count, pretend_cnt;
IGRchar			macName[50], down_scan[50] ;
struct GRid		*child_list=NULL, childID, new_parent, pretendID, tempID,
			parent_list[10];
struct GRobj_env	tempOE;
TVDvlaID                childVla;

   printf( "Connecting neat plate [ %d, %d ] to Plate [ %d, %d ]\n",
			neatOE->_objid, neatOE->_osnum,
			pltOE->_objid, pltOE->_osnum     );

   ASmake_source_from_env( &pltOE->obj_id, cur_env, &new_parent );

   vdobj$GetTemplate( objOE = neatOE, nth = 0, templateOE = &tempOE );

   if( tempOE._objid == NULL_OBJID )
   {
   	om$send( msg = message NDnode.NDconnect(
                                  1, &new_parent, NULL_GRID, ND_ADD ),
		 senderid = NULL_OBJID,
                 targetid = neatOE->_objid,
                 targetos = neatOE->_osnum ) ;
   }
   else
   {
        om$send( msg = message NDnode.NDchange_connect(
				1, &tempOE.obj_id, &new_parent ),
		 senderid = NULL_OBJID,
                 targetid = neatOE->_objid,
                 targetos = neatOE->_osnum ) ;
   }

   vdvla_id$Construct( vla = &childVla );
   vdchn$GetChildrenByClass( objID   = &neatOE->obj_id,
                             classID = OPP_ACpretend_class_id,
                             vla     = &childVla  );
   pretend_cnt = vdvla_id$GetCnt( vla = &childVla );

   VSgetChildrenGoThruPretends( &msg, &neatOE->obj_id, 
				&child_cnt, &child_list ) ;

   if( !child_cnt ) goto wrapup;

   for( i=0; i<child_cnt; i=i+1 )
   {
       vdobj$Get( objID = &child_list[i], macName = macName );
       if( strcmp( macName, "Bevel" ) && strcmp( macName, "EJ_Bevel" ) &&
	   strcmp( macName, "Fab_Stock" ) && strcmp( macName, "VA_Bevel" ) )
        continue;

       sts = om$send( msg = message NDnode.NDget_objects( ND_ROOT,
		    		parent_list, 10, NULL, 0, 
				OM_K_MAXINT, &parent_count ),
                      senderid = NULL_OBJID,
                      targetid = child_list[i].objid,
                      targetos = child_list[i].osnum );

       for( j=0; j<parent_count; ++j )
       {
	   for( k=0; k<pretend_cnt; ++k )
	   {
	      vdvla_id$GetAt( vla = &childVla, nth = k, objID = &pretendID );
	      if( pretendID.objid == parent_list[j].objid &&
		  pretendID.osnum == parent_list[j].osnum     )
	      {
		 if( !strcmp( macName, "Bevel" ) && ( j == 3 ) )
		      index = 2 ;
		 else index = j ;
		 break;
	      }
	   }
	   if( k < pretend_cnt ) break;
       }

       om$send( msg = message NDnode.NDdisconnect( 
				parent_count, parent_list ),
                senderid = NULL_OBJID,
                targetid = child_list[i].objid,
                targetos = child_list[i].osnum   );

       for( j=parent_count; j>index; --j )
	  parent_list[j] = parent_list[j-1] ;

       parent_list[index] = new_parent;
       parent_count++;

       if( parent_count == 7 )
       {
            om$send( msg = message ACpretend.ACgive_downscan( down_scan ),
                     senderid = NULL_OBJID,
                     targetid = parent_list[2].objid,
                     targetos = parent_list[2].osnum );
            if( strstr( down_scan, "edge" ) )
            {
                tempID = parent_list[2];
                parent_list[2] = parent_list[3];
                parent_list[3] = tempID;
            }
       }

       om$send( msg = message NDnode.NDconnect(
                        parent_count, parent_list, NULL_GRID, ND_NEW ),
                senderid = NULL_OBJID,
                targetid = child_list[i].objid,
                targetos = child_list[i].osnum   );
   }
   vdvla_id$Delete( vla = &childVla );

wrapup:
   _FREE( child_list );
   return sts;
}

IGRlong	VScheckNeatPlateTemplates()
{
BSrc			rc;
IGRlong			sts, msg, isConsumed;
IGRint			i, j, loc_cnt, mac_count, plt_cnt, nb_class, 
			cn_type=ND_COMP, state;
IGRdouble		plt_center[3], neat_center[3];
IGRchar			macName[50];
IGRboolean		need_recomp=FALSE;
GRobjid			*loc_list=NULL;
GRspacenum		osnum;
GRclassid		classid[1];
GRrange			range;
struct GRid		parentID, obj_chk, *mac_list=NULL;
struct GRobj_env	srfOE, ptOE, objOE, *plt_list=NULL;
struct GRmd_env		cur_env;

   gr$get_module_env( buffer = &cur_env );

   osnum = cur_env.md_id.osnum;

   nb_class = 1;
   classid[0] = OPP_nci_macro_class_id;

   loc_cnt = 0;
   VDpms_findall_ancestryobjects( osnum, nb_class, classid, &loc_cnt, NULL );
   if( !loc_cnt ) goto wrapup;

   if( !( loc_list  = _MALLOC( loc_cnt, GRobjid ) ) ) 
	vd_$mem_fail( msg = &msg );

   if( !( mac_list  = _MALLOC( loc_cnt, struct GRid ) ) ) 
	vd_$mem_fail( msg = &msg );

   VDpms_findall_ancestryobjects( osnum, nb_class, classid,
                                  &loc_cnt, loc_list );
   mac_count = 0;

   for( i=0; i<loc_cnt; ++i )
   {
       obj_chk.objid = loc_list[i];
       obj_chk.osnum = osnum;

       vdobj$Get( objID = &obj_chk, macName = macName );
       if( strcmp( macName, "neat_plate" ) )  continue;

       sts = om$send( msg = message ACncpx.ACget_STATE( &state ),
		      senderid = NULL_OBJID,
                      targetid = obj_chk.objid,
                      targetos = obj_chk.osnum );
       if( state & ncpx_root ) continue;

       parentID.objid = NULL_OBJID;
       vdobj$GetParent( objID = &obj_chk, idx = 0, parentID = &parentID );
       if( parentID.objid != NULL_OBJID ) continue;

       mac_list[mac_count] = obj_chk;
       mac_count++;	
   }
   _FREE( loc_list );

   if( !mac_count ) goto wrapup;

   nb_class = 1;
   classid[0] = OPP_VSplate_class_id;

   plt_cnt = 0;
   range[0] = -1e+10; range[1] = -1e+10; range[2] = -1e+10;
   range[3] =  1e+10; range[4] =  1e+10; range[5] =  1e+10;

   VD_findall_objects_in_range( range, nb_class, classid,
                       TRUE, cur_env, &plt_cnt, &plt_list );
   if( !plt_cnt ) goto wrapup;

   for( i=0; i<plt_cnt; ++i )
   {
     	isConsumed = 0;
        sts = om$send( msg = message NDmacro.ACtest_consumed( &isConsumed ),
		       senderid = NULL_OBJID,
                       targetid = plt_list[i]._objid,
                       targetos = plt_list[i]._osnum );
        if( !(sts&1) || isConsumed ) continue;

	srfOE._objid = NULL_OBJID ;
        vdobj$GetFoot( objOE    = &plt_list[i],
                       footName = VS_K_plBotSfPath,
                       footOE   = &srfOE 	     );
        if( srfOE._objid == NULL_OBJID ) goto wrapup;
        srfOE.mod_env = plt_list[i].mod_env;

        VDefpGetSurfaceCenter( &srfOE, plt_center );

	for( j=0; j<mac_count; ++j )
	{
	   objOE.obj_id  = mac_list[j] ;
	   objOE.mod_env = cur_env;

	   sts = GetNeatCenter( &objOE, &ptOE, neat_center );
	   if( !(sts&1) )  continue;

	   if( fabs( BSdistptpt( &rc, plt_center, neat_center ) ) < 0.1 )
	   {
	       VSconnectPlateBevels( &plt_list[i], &objOE, &cur_env );
               nd$wait_batch( type       = GR_GEOM_POSTED,
                              nb_obj     = 1,
                              l_object   = &mac_list[j],
                              l_obj_info = &cn_type );
	       need_recomp = TRUE;
           }
	}
   }

   if( need_recomp )  nd$exec_batch();

wrapup:
   _FREE( mac_list );
   _FREE( loc_list );
   _FREE( plt_list );
   return sts;
}

end implementation VDSroot;
