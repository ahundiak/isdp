/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / VRskcrseg.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRskcrseg.I,v $
 *	Revision 1.3  2001/07/09 22:43:34  anand
 *	No TR/CR.
 *	
 *	Revision 1.2  2001/02/20 01:17:15  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:10  cvs
 *	Initial import to CVS
 *	
# Revision 1.10  2000/01/04  16:15:36  pinnacle
# Replaced: vrsketch/VRskcrseg.I for:  by lawaddel for route
#
# Revision 1.9  1999/05/24  20:37:52  pinnacle
# Replaced: vrsketch/VRskcrseg.I for:  by lawaddel for route
#
# Revision 1.8  1999/05/18  18:20:50  pinnacle
# Replaced: vrsketch/VRskcrseg.I for:  by lawaddel for route
#
# Revision 1.7  1999/05/13  19:32:16  pinnacle
# Replaced: vrsketch/VRskcrseg.I for:  by lawaddel for route
#
# Revision 1.3  1998/11/06  22:46:28  pinnacle
# Replaced: vrsketch/VRskcrseg.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/09/02  15:59:40  pinnacle
# Replaced: vrsketch/VRskcrseg.I for:  by onayragu for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.2  1996/01/19  15:10:16  pinnacle
# Replaced: vrsketch/VRskcrseg.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	09/02/97	Onay	Additional parameters for inline comp. enhanc.
 *      11/01/98       law      TR179801939-tier processing errors.
 *      04/19/99       LAW      cr179900491-variable spacing for each tier
 *	01/03/99	law	tr179801414-conreds not sizing correctly
 *	Jul 9 '01	Anand	Skewed segments in auto-sketch leaves behind
 *				spurious planes and compoint. Corrected these.
 *
 *************************************************************************/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 sketch state language file.

 CHANGE HISTORY:  momo 13-11-1989 : Design date

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

class implementation VRsketch;



#include "godef.h"
#include "nddef.h"
#include "VRcordef.h"
#include "VRclsymbf.h"
#include "VRDbParamDef.h"
#include "OMprimitives.h"
#include "gr.h" 
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "bserr.h"
#include "bsparameters.h"
#include "VRclsymb.h"
#include "VRpriv_attr.h"
#include "OMmacros.h"
#include "csmacros.h"
#include "ndmacros.h"
#include "VRprivmacros.h"
#include "VRutilmacros.h"
#include "VRact_params.h"
#include "VRdef.h"
#include "VRcsdef.h"
#include "AS_status.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bsmkvec.h"
#include "bsnorvec.h"
#include "vrtools_pto.h"
#include "vrdbgmacros.h"
#include "parametric.h"
#include "VDmem.h"

#define AS_DEBUG	1
#define PREVSEG		0
#define NEWSEG		1

from 	GRgraphics      import 	GRconstruct,
				GRdelete;
from	NDnode		import	NDdisplay,
				NDdelete,
				NDget_objects,
				NDs_compute_node;
from	VRGeneric	import	VRGetIndex,
				VRGetPlanes,
				VRSelectCptByGeom,
				VRGetParams,
				VRConnect;
from	ACncpx		import	ACgive_structure;
from	VRCnrlSeg	import	VRget_terminators;
from    ACrg_collect    import  AClist_attribute;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRskcrseg( IGRlong *sts )
{
  IGRshort 			Factor;    /* nedded for the fit_to_fit      */
  IGRshort			cmp_index[VR_NB_CMP_SUPPORTS];
                                           /* component index                */
  IGRshort			placement_type;
                                           /* used to place correction cmp   */
  IGRshort			act_param_change;
                                           /* to know if user has changed    */
                                           /* the active parameters          */
  IGRshort			GivenAction=0;
					   /* needed to call place segment   */
  IGRshort 			PlaceType; /* component to place is it NEW   */
  IGRint 			i;         /* loop index                     */
  IGRint 			mode_batch;/* batch mode                     */
  IGRint 			num_parents;
                                           /* nb planes return by get_planes */
  IGRlong 			status;    /* return code                    */
  IGRlong 			retcode;   /* return code                     */
  IGRdouble	  		pts[6];    /* VRlinestr's end points         */ 
  IGRdouble	  		CmpAngle=0.0;
					   /* non linear component placement */ 
                                           /* angle                          */
  IGRdouble	  		orient_section[6];
                                           /* used by HVAC to orient section */ 
  IGRdouble	  		*p_orient_section=NULL;
                                           /* used by HVAC to orient section */ 
  IGRdouble         		section_matrix[9];
                                           /* current section orientation    */
  IGRboolean			CorType=FALSE;
					   /* used to place correction entity*/
  IGRshort			FittingType=FALSE;
  IGRboolean			UpdateEvent=FALSE;
  IGRboolean			UpdateSegLen;
  IGRdouble  depth_val;
  struct 	GRid 		CnrlSegId; /* CnrlCmp's GRid                 */
  struct 	GRid 		NewSegmentId;
                                           /* used to place TEE              */
  struct 	GRid 		CmpToConnectId;
					   /* needed to connect component    */
  struct 	GRid		parents[VR_NB_SEG_PLANES];
                                           /* planes' GRid                   */
  struct 	GRid 		list_parents[VR_NB_CMP_SUPPORTS];
                                           /* CnrlCmp's GRid                 */
  struct GRid CmpId;
  union		VRparam_attr	ActParam;
  IGRint			ParamsReturnCode;

  SetProc( Md VRskcrseg ); Begin 

  *sts   = MSSUCC;
  retcode    = MSSUCC;
  status = OM_S_SUCCESS;
  ParamsReturnCode	= MSSUCC;
  CmpId.objid = NULL_OBJID; /*** Added for tr179801414 ***/

  __DBGpr_int("num_seg   ", me->num_of_seg );
  __DBGpr_int("fit_to_fit", me->next_pt_free );
  __DBGpr_vec("prev  pt  ",me->prev_pt );
  __DBGpr_vec("first pt  ",me->first_pt);
  __DBGpr_vec("next  pt  ",me->next_pt ); 
  __DBGpr_obj("prev_seg_id ", me->prev_seg_id);
  __DBGpr_int(" extend?", me->extend);
  __DBGpr_int(" first type",me->FirstType);

  CnrlSegId.objid    = NULL_OBJID;
  NewSegmentId.objid = NULL_OBJID;
  /* needed to exec_batch later */
  nd$mod_batch( request    = ND_GET, p_ret_mode = &mode_batch );

  if( me->FirstType == IS_ELBOW )
  {
	/* Get elbow information : segments parents and collection parameters on
    	/* the connect points
    	/**/

    	status = om$send( msg      = message VRsketch.VRSkGetElbowInfo( &retcode ),
                      	  targetid = my_id );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );

    	/* update active param and the design parameters form. For the other case
    	/* is done in VRskfstelm method bacause we had all informaton about
    	/* located component. when is an elbow, we need the direction two get
    	/* parameters on connect point.
    	/**/
    	
        VR$active_params( 	operation    = VR_REPLACE,
                      		VRproduct    = me->Product,
                      		update_flag  = VR_UPDATE,
                      		act_param_id = &me->BufParamId,
  	      	      		status       = retcode );

        /* modified for CR179900491 */
    	status = VRSkUpdateForm( me->Product, me->form_ptr, &me->shape_gadget, 
				 &me->BufParamId, me->CmpAABBCCcode,
				 &me->active_cpt, me->RWcptdata,
                                 &me->ModuleInfo, VR_AUTOMATIQUE );
    	as$status();

    	/*"ActParam = %d\n", me->ActParamId.objid */ 

    	/* get active user collection */
    	status = VR$GetAttributes( 	p_retmsg	= &retcode,
				     	Product		= me->Product,
					p_UserParamId	= &me->UsrParamId,
					p_MdEnv		= &me->ModuleInfo );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );

    	/* update ActParam union ( active dimension parameters ) */
    	status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
					     	Product		  = me->Product,
						p_SysCollectionId = &me->BufParamId,
						p_DimAttributes	  = &ActParam,
						p_MdEnv	  	  = &me->ModuleInfo );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );
  }
  else
  {		
    	/*"ActParam = %d\n", me->ActParamId.objid */ 
    	status = VR$GetAttributes( 	p_retmsg	= &retcode,
				     	Product		= me->Product,
					p_SysParamId	= &me->ActParamId,
					p_UserParamId	= &me->UsrParamId,
					p_MdEnv		= &me->ModuleInfo );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );

    	/* update ActParam union ( active dimension parameters ) */
    	status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
					     	Product		  = me->Product,
						p_SysCollectionId = &me->ActParamId,
						p_DimAttributes	  = &ActParam,
						p_MdEnv	  	  = &me->ModuleInfo );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );
  }

  /*^ VRprint_user_attr( &me->ActParamId ); */

  /* VR_OLD_COMP : means we will replace located component by an other
  /* VR_NEW_COMP : means a new component will be placed
  /**/

  if( me->FirstType == IS_DANGLING ) PlaceType = VR_OLD_COMP;
  else                               PlaceType = VR_NEW_COMP;

  /* update sketch's type for the next input */
  /*me->orthogonal_sketch = TRUE;*/
  me->NbOfImpDirection  = 0;  

  /* set orientation section */
  if( me->Product != VR_PIPING )
  {
	/* get new section depending on old one, first_pt and next_pt */
	status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_InPutSection	= me->section_matrix,
					p_StartPt	= me->first_pt,
					p_EndPt		= me->next_pt,
					p_OutPutSection	= section_matrix );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );

      	if( me->twist_orient )
      	{
        	orient_section[3] = section_matrix[6];
        	orient_section[4] = section_matrix[7];
        	orient_section[5] = section_matrix[8];
      	}
      	else
      	{
        	orient_section[3] = section_matrix[3];
        	orient_section[4] = section_matrix[4];
        	orient_section[5] = section_matrix[5];
      	}	

    	if( ActParam.hvac_attr.shape != VR_CIRC )
    	{
      		if( me->twist_save )
      		{
        		orient_section[0] = me->section_matrix[6];
        		orient_section[1] = me->section_matrix[7];
        		orient_section[2] = me->section_matrix[8];
      		}
      		else
      		{
        		orient_section[0] = me->section_matrix[3];
        		orient_section[1] = me->section_matrix[4];
       		 	orient_section[2] = me->section_matrix[5];
      		}
    	}
    	else
    	{
      		if( me->twist_orient )
      		{
        		orient_section[0] = section_matrix[6];
        		orient_section[1] = section_matrix[7];
        		orient_section[2] = section_matrix[8];
     		 }
      		 else
      		 { 
        		orient_section[0] = section_matrix[3];
        		orient_section[1] = section_matrix[4];
        		orient_section[2] = section_matrix[5];
      		}
    	}

    	p_orient_section = orient_section;
  }

  if( me->prev_seg_id.objid != NULL_OBJID && me->extend )
  {
    	/*| extend : previous segment  */

   	/* see if user has changed active design parameters */

	__DBGpr_com( " Calling VRis_change_param " );
    	VRis_change_param( 	me->Product, &me->BufParamId, &me->ActParamId,
               		me->twist_orient, me->twist_save, &act_param_change,
               		&placement_type, &me->ModuleInfo
			 );
    	__DBGpr_int( " act_param_change ", act_param_change );
    	__DBGpr_int( " placement_type   ", placement_type   );
	/* added by alwin for TR179801414 - Modified for TR179801939 */
	if( ( placement_type == VR_REDUCER ) && ( me->Product == VR_RWAY) &&
    	    ( me->shape_gadget == RW_R_SHAPE ) )
	{
struct VRRwCptDetails LocRWcptdata[10];
	  IGRint FootIndex=-1, intmsg, NbAttr;
	  IGRint no_tier1, no_tier2;
	  IGRdouble spacing_tier1, spacing_tier2;
	  struct ret_struct TmpParam;
	  struct ACrg_coll  NewListAttr[20];
	  struct ACrg_coll  ListAttr[20];
	  IGRdouble width1,depth1,depth2,width2;
          IGRint w_d_swap;
	  IGRshort mycpt;
	  IGRvector my_vect;
	  IGRint Idum, j;
	  IGRint no_comps = 1;
          struct GRid ParamId[3];
	  IGRchar no_tier_str[20],sp_tier_str[20],depth_str[20],width_str[20];
	  IGRint not_found , width_not_found, depth_not_found;
	  IGRint coll;
          IGRchar tier_spstore1[200],tier_spstore2[200],tempvalstr[200];

           __DBGpr_obj("prev_seg_id ", me->prev_seg_id);
           __DBGpr_vec("prevpt ",me->prev_pt);
           __DBGpr_vec("firstpt ",me->first_pt);
           __DBGpr_vec("nextpt ",me->next_pt);

          /**** SPECIAL CODE FOR REDUCERS IN RWAY CRSEG processing *****/
	  BSmkvec( &retcode,my_vect,me->prev_pt,me->first_pt );
	  BSnorvec( &retcode,my_vect);
           __DBGpr_vec("myvect ",my_vect);

          status = om$send( msg     = message VRCnrlSeg.VRget_terminators
                      ( &retcode, &no_comps, &me->ModuleInfo, NULL, &CmpId ),
               targetid = me->prev_seg_id.objid,
               targetos = me->prev_seg_id.osnum);
           __DBGpr_obj("Prev comp ",CmpId);
           /*** Large block of code deleted here for TR179801414 by LAW ***/
        }
	/* added by alwin for TR179801414 */

  	GivenAction = IS_AN_EXTEND;

    	if( ! act_param_change )
    	{
		GivenAction &= ~VR_SHARE_PLANES;
		status = VR$PlaceSegment(	p_retmsg	= &retcode,
						Product		= me->Product,
						GivenAction	= GivenAction,
         					p_SegmentPt0	= me->first_pt,
         					p_SegmentPt1	= me->next_pt,
	 					p_PrevSegId   	= &me->prev_seg_id,
	 					p_CurMdEnv	= &me->ModuleInfo );
    	}

  } /* END OF EXTEND */

  if( me->prev_seg_id.objid == NULL_OBJID || !me->extend || act_param_change )
  {
    	/*| creation of a segment ==> call def_planes function */
    	if( me->prev_seg_id.objid == NULL_OBJID )
    	{
      		/* first segment : def_plane need in this case :
      		/* - referentiel if we start from a nozzle or free space
      		/* - three planes if we start from constraints component
      		/**/

      		/*" me->FirstType = %d \n",me->FirstType*/
      		switch( me->FirstType )
      		{
      			case FREE_SPACE:
				status = VR$PlaceSegment(	p_retmsg	= &retcode,
								Product		= me->Product,
         							p_SegmentPt0	= me->first_pt,
         							p_SegmentPt1	= me->next_pt,
	 							p_CurMdEnv	= &me->ModuleInfo,
	 							p_NewSegmentId 	= &CnrlSegId );
				as$status( action = RET_STATUS );
				break;
				
			default:
				/*"FirstCptNum = %d\n", me->FirstCptNum */
				status = VR$PlaceSegment(	p_retmsg	= &retcode,
								Product		= me->Product,
         							p_SegmentPt0	= me->first_pt,
         							p_SegmentPt1	= me->next_pt,
	 							p_CmpToConnectId= &me->FirstLocatedElemId,
								CmpCptNum 	= me->FirstCptNum,
	 							p_CmpMdEnv	= &me->FirstLocatedElemMdEnv,
		 						p_CurMdEnv	= &me->ModuleInfo,
		 						p_NewSegmentId  = &CnrlSegId );
				as$status( action = RET_STATUS );
				break;
		}
    	}
    	else
    	{
      		/*| we have a previous segment */

      		if( me->FirstType == IS_PIPE )
      		{	
        		/*| start from pipe ==> Call macro to split previous segment */
      			status = VR$SplitSegment( p_retmsg		= &retcode,
						  p_SegmentToSplitId	= &me->prev_seg_id,
						  p_SplitPoint		= me->first_pt,
						  p_MdEnv		= &me->ModuleInfo,
						  p_NewSegmentId	= &NewSegmentId );
          		as$status( action = GOTO_VALUE, value = wrapup );
          		as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

        		/*| AFTER  SPLIT */

        		/*"prev_seg = %d\n", me->prev_seg_id.objid */
        		/*"new_seg  = %d\n", NewSegmentId.objid    */
      		}

		GivenAction |= VR_SHARE_PLANES;

		status = VR$PlaceSegment(	p_retmsg	= &retcode,
						Product		= me->Product,
						GivenAction	= GivenAction,
         					p_SegmentPt0	= me->first_pt,
         					p_SegmentPt1	= me->next_pt,
	 					p_PrevSegId   	= &me->prev_seg_id,
	 					p_CurMdEnv	= &me->ModuleInfo,
	 					p_NewSegmentId  = &CnrlSegId );
          	as$status( action = GOTO_VALUE, value = wrapup );
          	as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

	}

    	if( me->prev_seg_id.objid == NULL_OBJID )
    	{
      		/*| first segment */

      		switch( me->FirstType )
      		{
        		case FREE_SPACE :
          			/* we are starting from free space ==> place dangling */
          			/* get dangling orientation */
          			if( me->Product != VR_PIPING )
	  			{
          				if( me->twist_orient )
          				{
            					orient_section[0] = section_matrix[6];
            					orient_section[1] = section_matrix[7];
            					orient_section[2] = section_matrix[8];
          				}
          				else
          				{ 
            					orient_section[0] = section_matrix[3];
            					orient_section[1] = section_matrix[4];
            					orient_section[2] = section_matrix[5];
          				}
          
          				p_orient_section = orient_section;
	  			}

          			cmp_index[0] = 0; /* component index in CnrlSegId segment */
                                /***** Added for TR179801414 ********/
                                {
                                   struct GRid *tmpbufptr;
                                   tmpbufptr = (struct GRid *) NULL;
                                   if(CmpId.objid != NULL_OBJID)
                                   {
                                   struct GRid chkcoll[3];
                                   status = om$send ( msg =
                                      message VRGeneric.VRGetParams(&retcode,
                                       &chkcoll[0], &chkcoll[1], &chkcoll[2] ),
                                      senderid = NULL_OBJID,
                                      targetid = CmpId.objid,
                                      targetos = CmpId.osnum);
                                   tmpbufptr = &chkcoll[0];
                                   }
          			status = VR$PlaceCmpByItemName
					 ( 
						p_retmsg             	= &retcode,
                           			PlacementTime     	= PlaceType,
                                 		Product	   		= me->Product,
                                 		TopoParentsNum    	= 1,
                                 		p_TopoParentsList 	= &CnrlSegId,
                                 		p_CmpIndexOnTopo  	= cmp_index,
                                 		p_CmpAngle        	= &me->Angle,
                                 		p_CmpOrientSection	= p_orient_section,
                                 		p_MdEnv       		= &me->ModuleInfo,
                                 		p_ActParamId      	= &me->ActParamId,
                                 		p_BufParamId      	= tmpbufptr,
                                 		p_UserParamId     	= &me->UsrParamId,
                                 		p_CmpCstList      	= &me->cmp_const_list
					 );
          			as$status( action = GOTO_VALUE, value = wrapup );
          			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );
                                }
          			
				break;

        		case IS_NOZZLE :   
        		case IS_CONC_COMP :
			case IS_COMP_TO_CONNECT :
			case IS_DANGLING_TO_CONNECT :
			{
				struct GRid TempId[4];

	  			/*| VRGeneric.VRConnect*/
	  			status = VR$MakeSource
					 ( 	p_msg		= &retcode,
				  		p_ComponentId	= &me->FirstLocatedElemId,
				  		nCpNum		= me->FirstCptNum,
				  		p_CompMdEnv	= &me->FirstLocatedElemMdEnv,
				  		p_MdEnv		= &me->ModuleInfo,
				  		p_ConnectorId 	= &CmpToConnectId
					 );
	  			as$status( action = GOTO_VALUE, value = wrapup );
	  			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

				if( me->FirstLocatedElemId.objid != CmpToConnectId.objid )
				{
					/* connect the dependent plane upon
					/* the VRcptin : VR$placeSegment can 
					/* return these planes ( to do later )
					/**/

					IGRint		i, index, NbTemps;
					struct GRid	*buffer;
					GRclassid	obj_classid;

                           		extern GRclassid OPP_VRDepPlane_class_id;

					status = om$send( msg      = message NDnode.NDget_objects
						        	     ( ND_ROOT | ND_IN_BUF, NULL, 0,
								       &buffer, 0, OM_K_MAXINT, &NbTemps ),
			  				  targetid = CnrlSegId.objid,
			  				  targetos = CnrlSegId.osnum );
					as$status();

					for(i=0, index=0; i<NbTemps; i++)
					{
						/*"buffer[%d] = %d\n", i, buffer[i].objid */

				 		om$get_classid( objid     = buffer[i].objid,
		  						osnum     = buffer[i].osnum,
		                    				p_classid = &obj_classid );

				 		if(om$is_ancestry_valid( subclassid   = obj_classid,
                           						 superclassid = OPP_VRDepPlane_class_id) == OM_S_SUCCESS)
						{
							/*| it's a VRDetPlane */
							TempId[index++] = buffer[i];
						}
					}

					TempId[index] = CnrlSegId;

				}
				else TempId[0] = CnrlSegId;
	
          			status = om$send( msg      = message VRGeneric.VRConnect
                                       			( &retcode, TempId, 0,
							me->FirstCptNum, &me->ModuleInfo),
                            			  targetid = CmpToConnectId.objid, 
                            			  targetos = CmpToConnectId.osnum);
          			as$status( action = GOTO_VALUE, value = wrapup );
          			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

				break;
			}

        		default : break;
      		}  
    	}
    	else
    	{
      		/*| not first segment */

      		switch( me->FirstType )
      		{
        		case IS_PIPE :
          			placement_type 	= VR_TEE;
          			num_parents     = 3;
          			list_parents[0] = me->prev_seg_id; cmp_index[0] = 1;
          			list_parents[1] = CnrlSegId;      cmp_index[1] = 0;
          			list_parents[2] = NewSegmentId;    cmp_index[2] = 0;
          			break;          
          
        		case IS_ELBOW : 
          			num_parents    = 3;
          			PlaceType      = VR_OLD_COMP;
          			placement_type = VR_TEE;
          			list_parents[0] = me->prev_seg_id;
          			list_parents[1] = me->ElbowSecSegId;
          			list_parents[2] = CnrlSegId;

          			/* elbow could be on the start or end of the previous segment */
          			status = om$send( msg      = message VRGeneric.VRGetIndex
                                       				( &retcode, &me->prev_seg_id, &cmp_index[0]),
                            			  targetid = me->FirstLocatedElemId.objid,
                            			  targetos = me->FirstLocatedElemId.osnum);
          			as$status( action = GOTO_VALUE, value = wrapup );
          			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

          			cmp_index[2] = 0;

          			/* elbow could be on the start or end of the Second segment */
          			status = om$send( msg      = message VRGeneric.VRGetIndex
                                       				( &retcode,&me->ElbowSecSegId,&cmp_index[1]),
                            			  targetid = me->FirstLocatedElemId.objid,
                            			  targetos = me->FirstLocatedElemId.osnum);
          			as$status( action = GOTO_VALUE, value = wrapup );
          			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

          			/* set elbow orientation on its supports */
          			if( cmp_index[0] ) me->CmpOrientation[0] = -1;
          			if( cmp_index[1] ) me->CmpOrientation[1] = -1;

          			break;

        		default : 
          			/* IN_LINE component ( if extend ) or ELBOW ==> place an elbow */

         			if( me->extend ) CmpAngle = me->CmpAngle;
          			else placement_type = VR_ELBOW;

          			num_parents = 2;
          			list_parents[0] = me->prev_seg_id;
          			list_parents[1] = CnrlSegId;

          			/* set index and orientation of the elbow on its supports */
          			if( me->CmpPosition == BEGIN_OF_SEG )
          			{ 
            				cmp_index[0] = 0;
            				me->CmpOrientation[0] = -1;
          			}
          			else
          			{
            				cmp_index[0] = 1;
            				me->CmpOrientation[0] = 1;
          			}
  
          			cmp_index[1] = 0;
          			break;
      		}
                __DBGpr_com("Calling PlaceCmpByItemName HERE ---------");
                __DBGpr_obj("ActParamId",me->ActParamId);
                __DBGpr_obj("BufParamId",me->BufParamId);

                /**** sending actparamid and bufparamid - TR179801414 */

      		status = VR$PlaceCmpByItemName
				 ( 	p_retmsg             	= &retcode,
                         		PlacementTime     	= PlaceType,
                                 	Product	   		= me->Product,
                                 	TopoParentsNum    	= num_parents,
                                 	p_TopoParentsList 	= list_parents,
					CmpItemName		= placement_type,
                                 	p_CmpIndexOnTopo  	= cmp_index,
                             		p_RelCmpOrient    	= me->CmpOrientation,
                                 	p_CmpAngle        	= &CmpAngle,
                                 	p_CmpOrientSection	= p_orient_section,
					p_OldCmpId		= &me->FirstLocatedElemId,
                                 	p_MdEnv       		= &me->ModuleInfo,
                                 	p_ActParamId      	= &me->ActParamId,
					p_BufParamId		= &me->BufParamId,
                                 	p_UserParamId     	= &me->UsrParamId,
                                 	p_MissParamId     	= &me->MissParamId,
                                 	p_CmpCstList      	= &me->cmp_const_list
				 );
if (retcode == ADDITIONAL_PARAMS)
  {
  ParamsReturnCode	= ADDITIONAL_PARAMS;
  goto wrapup;
  }
		if( !( status & 1 & retcode ) ) goto wrapup;
/*****************/
      		/* Update CmpAngle instance */
      		me->Angle = CmpAngle;

      		/* adapte consdtruction : segment length and correction ( graphic and 
      		/* type )
      		/**/

      		switch( me->FirstType )
      		{
        		case IS_PIPE :
		          	/*| compute correction */
         			status = VRUpdateGraph
                   			 ( &retcode, me->Product, &UpdateSegLen, &me->prev_seg_id,
                     			   &me->FirstLocatedElemId, -1, -1, &me->ModuleInfo
                   			 );
          			as$status( action = GOTO_VALUE, value  = wrapup );
          			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

          			if( UpdateSegLen )
          			{
            				/*| IS A TEE */
          				VRUpdateSegLength
            				( &retcode, &me->prev_seg_id, &NewSegmentId, &me->ModuleInfo );
          			}
          			else
          			{
            				/*| IS AN OLET */
            				status = om$send( msg      = message NDnode.NDdisplay
                                               			     ( 0, GRbd, &me->ModuleInfo ),
                              				  targetid = me->FirstLocatedElemId.objid,
                              				  targetos = me->FirstLocatedElemId.osnum );
          				as$status( action = GOTO_VALUE, value = wrapup );
          				as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );
          			}

          			status = VRChangeSegLength
                   			 ( 1, FALSE, &me->prev_seg_id, &me->ModuleInfo );
          			as$status( action = GOTO_VALUE, value  = wrapup );

          			break;

        		case IS_ELBOW    :
          			status = VRGetCorrectionType
                   			 ( &retcode, &me->FirstLocatedElemId, &me->ElbowSecSegId,
                     			   &FittingType, &me->ModuleInfo
                   			 );
          			as$status( action = GOTO_VALUE, value  = wrapup );
          			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

          			if( FittingType )
          			{          
            				if( cmp_index[1] ) Factor = -1;
            				else               Factor = 1;

            				status = VRChangeSegLength
                     				 ( Factor, VR_UNKNOWN, &me->ElbowSecSegId, &me->ModuleInfo );
            				as$status( action = GOTO_VALUE, value  = wrapup );
          			}

          			status = VRGetCorrectionType
                   			 ( &retcode, &me->FirstLocatedElemId, &me->prev_seg_id,
                     			   &FittingType, &me->ModuleInfo
                   			 );
          			as$status( action = GOTO_VALUE, value  = wrapup );
          			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

          			if( FittingType )
          			{
            				/* To update previous segment */
            				if( cmp_index[0] ) Factor  = 1;
            				else               Factor = -1;

           				status = VRChangeSegLength
                     				 ( Factor, VR_UNKNOWN, &me->prev_seg_id, &me->ModuleInfo );
            				as$status( action = GOTO_VALUE, value  = wrapup );
          			}

          			break;

        		case IS_DANGLING :
         			/*| First located element is a dangling or elbow */
        			if( me->next_pt_free ) FittingType = TRUE;

        			if( me->CmpPosition == BEGIN_OF_SEG ) Factor = -1;
         			else                                  Factor =  1;

         			status = VRChangeSegLength
                  			 ( Factor, FittingType, &me->prev_seg_id, &me->ModuleInfo );
         			as$status( action = GOTO_VALUE, value  = wrapup );

         			break;

        		default : 
          			if( me->next_pt_free || ( me->extend && me->first_pt_free ) ) CorType=TRUE;
  	  			status = VR$ComputeCorrection
						( 	p_retmsg	= &retcode,
							ComputeType	= VR_PLACE,
							CorType		= CorType,
 							p_SegmentId	= &me->prev_seg_id,
 							p_MdEnv		= &me->ModuleInfo
						 );
         			as$status( action = GOTO_VALUE, value = wrapup );
          			as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

          			if( me->next_pt_free || ( me->extend && me->first_pt_free ) ) FittingType=TRUE;

          			if( me->CmpPosition == BEGIN_OF_SEG ) Factor = -1;
          			else                                  Factor =  1;

          			status = VRChangeSegLength
                   			 ( Factor, FittingType, &me->prev_seg_id, &me->ModuleInfo );
          			as$status( action = GOTO_VALUE, value  = wrapup );

          			break;
      		}

      		/* ChangeSegLength puts plane in the batch for compute */

      		if( mode_batch != ND_DEFER ) nd$exec_batch();

      		if( me->FirstType == IS_PIPE && !UpdateSegLen )
      		{
        		VRDisplayCorrection
        		( &NewSegmentId, &me->FirstLocatedElemId, &me->ModuleInfo );

        		VRDisplayCorrection
        		( &me->prev_seg_id, &me->FirstLocatedElemId, &me->ModuleInfo );
      		}

      		UpdateEvent = TRUE;
    	}


      	/* get end points of creating segment to update first and next points */
      	status = VRskgetendpt
              		 ( &retcode, FALSE, pts, &CnrlSegId, &me->ModuleInfo );
      	as$status( action = GOTO_VALUE, value  = wrapup );
      	as$status( sts = retcode, action = GOTO_VALUE, value = wrapup );

    	/*| update instance data */

    	if( me->num_of_seg >= MAX_SEG )
    	{
      		om$vla_set_dimension(	varray = me->seg_GRid,
                          		size  = me->num_of_seg+1 );
   	}

    	me->seg_GRid[me->num_of_seg] = CnrlSegId;
    	me->prev_seg_id = CnrlSegId;
    	me->num_of_seg += 1;
  
    	/*"num_seg = %d\n", me->num_of_seg */

    	if( me->next_pt_free || UpdateEvent )
    	{
      		me->prev_pt[0] = pts[0];
      		me->prev_pt[1] = pts[1];
      		me->prev_pt[2] = pts[2];
    	}
    	else
    	{
      		me->prev_pt[0] = me->first_pt[0];
      		me->prev_pt[1] = me->first_pt[1];
      		me->prev_pt[2] = me->first_pt[2];
    	}

    	me->plane_to_move_id = parents[3]; /* last parent */
    	/*"plan_to_move = %d\n", me->plane_to_move_id.objid */

    	if( ( me->Product == VR_HVAC || me->Product == VR_RWAY ) && 
                                                   		me->FirstType != IS_ELBOW )
    	{
      		/*| update twist and section orientation */
      		for( i=0; i<9; i++ ) me->section_matrix[i] = section_matrix[i];
      		me->twist_save = me->twist_orient;
    	}

    	if( ( me->Product == VR_HVAC || me->Product == VR_RWAY ) && 
                                                    		me->FirstType == IS_ELBOW )
    	{
      		/* primary axis correcpond to buffer design parameters */
      		me->ActParamId = me->BufParamId;
   	}
    	else me->BufParamId = me->ActParamId;

    	me->FirstType                = FREE_SPACE;
    	me->CmpPosition              = 0;
    	me->CmpOrientation[0]        = 1;
    	me->CmpOrientation[1]        = 1;
    	me->CmpAABBCCcode[0]           = '\0';
    	me->CmpNumber[0]             = '\0';
    	me->FirstLocatedElemId.objid = NULL_OBJID;

  } /* END NO EXTEND */

  if( ( me->next_pt_free || UpdateEvent ) && !me->extend ) 
  {
   	me->first_pt[0] = pts[3];
    	me->first_pt[1] = pts[4];
    	me->first_pt[2] = pts[5];
  }
  else
  {
   	me->first_pt[0] = me->next_pt[0];
    	me->first_pt[1] = me->next_pt[1];
    	me->first_pt[2] = me->next_pt[2];
  }

  /*"prev  pt %f %f %f\n",me->prev_pt[0] ,me->prev_pt[1] ,me->prev_pt[2]  */
  /*"first pt %f %f %f\n",me->first_pt[0],me->first_pt[1],me->first_pt[2] */
  /*"next  pt %f %f %f\n",me->next_pt[0] ,me->next_pt[1] ,me->next_pt[2]  */ 

  /* set the second point state for the next point given by the user */
  /*"fst fit_to_fit = %d\n", me->first_pt_free */
  me->next_pt_free = me->first_pt_free;
  /*"next fit_to_fit = %d\n", me->next_pt_free */

  if( !me->extend || ( me->extend && act_param_change ) )
{
 me->PlaceDangling = TRUE;
}

  me->extend = 0;

  End
  return(OM_S_SUCCESS);

wrapup:

  __DBGpr_com(" in wrapup!");

  if( CnrlSegId.objid != NULL_OBJID )
  {
    /* Below code put in by Anand */
    {
      struct GRid	*OldSegPlaneIds=NULL, *NewSegPlaneIds=NULL, *PlnChldId;
      IGRint		j, NbOldSegPln=0, NbNewSegPln=0, NbPlnChld=0;
      IGRboolean	bSharedPlane;

      /********************************************************************
       * The Control Segment was created but we needed to wrapup => so	  *
       * we delete it. That is okay, but what about the planes created	  *
       * for this Control Segment? We need to get rid of them as well,	  *
       * don't we? No! The newly created C.S might share planes with the  *
       * Prev Seg. Check for this, and if there are newly created planes, *
       * get rid of them. Also check for VRcompoint objects.		  *
       ********************************************************************/

      __DBGpr_obj(" Old c s", me->prev_seg_id);

      status = om$send( msg      = message NDnode.NDget_objects(
							ND_ROOT,
							NULL, 0, NULL, 0,
							OM_K_MAXINT,
							&NbOldSegPln ),
			targetid = me->prev_seg_id.objid,
			targetos = me->prev_seg_id.osnum );
      as$status();
      __DBGpr_int("Nb Parent of old Cnrl Seg", NbOldSegPln );

      OldSegPlaneIds = _CALLOC( NbOldSegPln, struct GRid );

      status = om$send( msg      = message NDnode.NDget_objects(
							ND_ROOT,
							OldSegPlaneIds,
							NbOldSegPln,
							NULL, 0,
							OM_K_MAXINT,
							&NbOldSegPln ),
			targetid = me->prev_seg_id.objid,
			targetos = me->prev_seg_id.osnum );
      as$status();
      __DBGpr_objlist(" Parent of old Cnrl Seg", NbOldSegPln, OldSegPlaneIds );

      status = om$send( msg      = message NDnode.NDget_objects(
							ND_ROOT,
							NULL, 0, NULL, 0,
							OM_K_MAXINT,
							&NbNewSegPln ),
			targetid = CnrlSegId.objid,
			targetos = CnrlSegId.osnum );
      as$status();
      __DBGpr_int("Nb Parent of New Cnrl Seg", NbNewSegPln );

      NewSegPlaneIds = _CALLOC( NbNewSegPln, struct GRid );

      status = om$send( msg      = message NDnode.NDget_objects(
							ND_ROOT,
							NewSegPlaneIds, 4,
							NULL, 0,
							OM_K_MAXINT,
							&NbNewSegPln ),
			targetid = CnrlSegId.objid,
			targetos = CnrlSegId.osnum );
      as$status();

      __DBGpr_obj("New Cnrl Seg", CnrlSegId);
      __DBGpr_objlist("Parent of New Cnrl Seg", NbNewSegPln, NewSegPlaneIds);

      for( i=0 ; i<NbNewSegPln ; i++ )
      {
	  bSharedPlane=FALSE;
	  for( j=0 ; j<NbOldSegPln ; j++ )
	  {
	      if( OldSegPlaneIds[j].objid == NewSegPlaneIds[i].objid &&
		  OldSegPlaneIds[j].osnum == NewSegPlaneIds[i].osnum )
	      {
		  bSharedPlane = TRUE;
		  break;
	      }
	  }

	  if( bSharedPlane )
	      continue;

	  __DBGpr_obj(" Plane unique to New C.S",NewSegPlaneIds[i]);

	  status = om$send( msg      = message NDnode.NDget_objects(
								 ND_CHILDREN,
								 NULL, 0,
								 NULL, 0,
								 OM_K_MAXINT,
								 &NbPlnChld ),
			    targetid = NewSegPlaneIds[i].objid,
			    targetos = NewSegPlaneIds[i].osnum );
	  as$status();
	  __DBGpr_int("Nb Children of plane",NbPlnChld);

	  PlnChldId = _CALLOC( NbPlnChld, struct GRid );

	  status = om$send( msg      = message NDnode.NDget_objects(
								 ND_CHILDREN,
								 PlnChldId, 
								 NbPlnChld,
								 NULL, 0,
								 OM_K_MAXINT,
								 &NbPlnChld ),
			    targetid = NewSegPlaneIds[i].objid,
			    targetos = NewSegPlaneIds[i].osnum );
	  as$status();
	  __DBGpr_objlist("Child of plane",NbPlnChld,PlnChldId);

	  for( j=0 ; j<NbPlnChld ; j++ )
	  {
	      if( PlnChldId[j].objid == CnrlSegId.objid &&
		  PlnChldId[j].osnum == CnrlSegId.osnum )
		  continue;

	      __DBGpr_obj(" Attempting to delete",PlnChldId[j]);
	      status = om$send( msg      = message NDnode.NDdelete(
							    &me->ModuleInfo ),
				targetid = PlnChldId[j].objid,
				targetos = PlnChldId[j].osnum );
	      as$status();
	  }

	  __DBGpr_obj(" Attempting to delete",NewSegPlaneIds[i]);
	  status = om$send( msg      = message NDnode.NDdelete(
							    &me->ModuleInfo ),
			    targetid = NewSegPlaneIds[i].objid,
			    targetos = NewSegPlaneIds[i].osnum );
	  as$status();

	  _FREE( PlnChldId );
      }
      _FREE( OldSegPlaneIds );
      _FREE( NewSegPlaneIds );
    }
    /* Above code put in by Anand */

    status = om$send( msg      = message NDnode.NDdisplay( 0,
                                                           GRbehe,
                                                           &me->ModuleInfo ),
                      targetid = CnrlSegId.objid, 
                      targetos = CnrlSegId.osnum);
    as$status();

    status = om$send( msg      = message GRgraphics.GRdelete( &retcode,
                                                              &me->ModuleInfo),
      	              targetid = CnrlSegId.objid, 
	              targetos = CnrlSegId.osnum);
    as$status()
    as$status( sts = retcode );

    nd$exec_batch();
  }

  if( NewSegmentId.objid != NULL_OBJID )
  {
  	struct GRid	SegList[2];
  	
  	SegList[0] = me->prev_seg_id;
  	SegList[1] = NewSegmentId; 
  	
	status = VR$MergeSegments(	p_retmsg	= &retcode,
					p_SegmentsId	= SegList,
					p_MdEnv		= &me->ModuleInfo );
	as$status();  	
	as$status( sts = retcode, action = RET_STATUS );  	
  }

if (ParamsReturnCode == ADDITIONAL_PARAMS)
  {
  *sts	= ADDITIONAL_PARAMS;
  }

  End
  return(OM_S_SUCCESS);

}

end implementation VRsketch;
