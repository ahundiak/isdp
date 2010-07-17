/* $Id: VRsketchact.I,v 1.4 2002/04/10 20:33:30 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrsketch / VRsketchact.I
 *
 * Description:
 *
 *    CLASS  NAME:  VRsketch
 *    Abstract: This file contains method needed for sketching.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRsketchact.I,v $
 *	Revision 1.4  2002/04/10 20:33:30  louis
 *	tr5649-standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:17:27  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 19:54:28  anand
 *	SP merge
 *	
# Revision 1.3  2000/07/10  19:23:56  pinnacle
# Replaced: route/vrsketch/VRsketchact.I for:  by apazhani for Service Pack
#
# Revision 1.2  2000/05/24  01:09:32  pinnacle
# Replaced: route/vrsketch/VRsketchact.I for:  by lawaddel for Service Pack
#
# Revision 1.1  2000/04/28  00:24:30  pinnacle
# Created: route/vrsketch/VRsketchact.I by lawaddel for Service Pack
#
# Revision 1.11  1999/10/22  15:52:28  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by lawaddel for route
#
# Revision 1.9  1999/05/28  14:27:52  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by apazhani for route
#
# Revision 1.8  1999/05/05  22:22:54  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by lawaddel for route
#
# Revision 1.3  1998/11/13  17:42:00  pinnacle
# TR179802345 Nozzle User Params
#
# Revision 1.2  1998/11/06  22:47:06  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.7  1998/04/20  16:37:20  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by apazhani for route
#
# Revision 1.6  1998/04/10  14:59:22  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by lawaddel for route
#
# Revision 1.5  1998/03/20  21:23:00  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by lawaddel for route
#
# Revision 1.3  1998/02/25  17:07:38  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by apazhani for route
#
# Revision 1.2  1998/01/22  06:24:32  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by apazhani for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.5  1997/06/27  14:07:00  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by apazhani for route
#
# Revision 1.4  1997/05/23  13:47:38  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by apazhani for route
#
# Revision 1.3  1997/05/19  21:25:10  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by yzhu for route
#
# Revision 1.2  1997/03/06  06:49:14  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by ashankar for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.13  1996/06/13  15:03:16  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by hverstee for route240
#
# Revision 1.12  1996/05/30  16:28:18  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by ashankar for route240
#
# Revision 1.11  1996/05/21  20:07:28  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by hverstee for route240
#
# Revision 1.10  1996/05/08  19:59:58  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by ashankar for route240
#
# Revision 1.9  1996/05/03  16:44:12  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by ashankar for route240
#
# Revision 1.8  1996/04/04  20:59:14  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by ashankar for route240
#
# Revision 1.7  1996/02/05  07:01:18  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by ashankar for route240
#
# Revision 1.6  1996/02/05  06:39:00  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by ashankar for route240
#
# Revision 1.5  1996/01/19  15:10:34  pinnacle
# Replaced: vrsketch/VRsketchact.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	momo :  31-10-1990  design date
 *	karine: 13-11-1991  new skewed mode
 *	Mallik: 18-4-1994   Fixed TR # 179418577
 *	Mallik: 12-5-1004   Fixed TR # 179311285
 *			    Dangles of Attached reference files lose
 *			    connectivity.
 *      Alwin   May/23/1997 Modified method VRskfstelm for CR179300978.
 *	Alwin   Jan/22/1998 Added an additional check which will prevent the
 *			    user from sketching in the wrong directions.
 *			    for TR179702549
 *	Alwin   Feb/25/1998 Considered the case of the reducers also in the 
 *			    above made additional check. TR179800535 
 *      law     Apr/09/1998 TR179702549-added/modified filters to prevent
 *                          sketchin wrong way.
 *      Alwin   Apr/21/1998 TR179800431-Initialized the Instance Variable 
 *			    MissParamId to NULL, in method VRsknextpt.
 *      law	11/01/98    TR179801939-Tier processing errors.
 *      Alwin   Apr/21/1998 TR179802345 When sketching out of nozzles we need
 *			    to grab both "System" & "User" Collectors. 
 *      Alwin   May/28/1999 CR179900491 Initialize the newly added variables
 *                          to handle Shape Transition components.
 *      law	05/03/99    TR179900616-Sketching off of a cross.
 *      law     08/13/99    TR179900739-Locate on a fiting-to-fiting component
 *      law     09/19/99    TR17900780/781- rway cleanup
 *      law     04/26/00    TR179901408-vendor name dynamic
 *      law     05/23/00    TR179901422-DBG statements added
 *      Alwin   07/10/00    CR179901003 Copied the information from the Raceway
 *                          Nozzle.
 *      law     04/08/02    TR5649-standardize tolerance with VRGetTol
 *
 *************************************************************************/

class implementation VRsketch;

#include <math.h>

#include <stdio.h>
#include <string.h>

#include "exdef.h"
#include "igrdef.h"
#include "dpdef.h"
#include "nddef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "grdpbdef.h"
#include "csdef.h"
#include "VRcsdef.h"
#include "VRcordef.h"
#include "VRattr_def.h"
#include "acrepdef.h"
#include "VRPid.h"
#include "VRMath.h"
#include "OMprimitives.h"
#include "comiscmac.h"
#include "igr.h"
#include "griodef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "bserr.h"
#include "bsvalues.h"
#include "VRpriv_attr.h"
#include "bsparameters.h"
#include "VRact_params.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRprivmacros.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "asmacros.h"
#include "ndmacros.h"
#include "csmacros.h"
#include "values.h"
#include "asbox.h"
#include "AS_status.h"
#include "VRmacros.h"
#include "VRcptmacros.h"
#include "VRSttopo.h"
#include "VRRwDimen.h"            /* CR179900491 */
#include "VRMcplace.h"
#include "VRRDBmac.h"             /* TR179901408 */
#include "vrparameters.h"
#include "parametric.h"
#include "vrtools_pto.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bspt_on_lne.h"
#include "bsxln.h"
#include "bsdotp.h"
#include "bscrossp.h"
#include "VDmem.h"
#include "vrdbgmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exmacros.h"
#include "expression.h"
#include "expmacros.h"


#define VR_CONNECTABLE	-6
#define AS_DEBUG	1
#define _start		2
#define _N_P 		3
#define	STOP		20

/* #define MY_DEBUG */
 
from	GRgraphics	import	GRxform, GRdelete, GRdisplay;
from 	GRvg		import	GRchgprops;
from	GRcoords	import	GRcvt_to_lcl_coords, GRcvt_to_wld_coords;
from	IGEgragad	import	DPinrot;
from	NDnode		import	NDdisplay, NDdelete, NDget_objects, NDgive_structure, NDcopy;
from    VRCnrlSeg	import	VRget_planes, VRChgSegState, VRget_terminators;
from 	VRGeneric	import	VRGetIndex, VRGetSysType, VRGetMatrix, 
                                VRGetSupports, VRGetOrigCoor, VRSetStatus, 
                                VRGetCptOnSup, VRGetCorrections,
				VRDisconnect, VRGetParams, VRSelectCptByGeom,
                                VRGetStatus, VRGetCode, VRGetCorOnCpt,
				VRGetCptGeom, VRGetNumberOfCpts;
from 	VRNozzle	import	VRGetRefId;
from	ACrg_collect	import	ACget_named_attribute,
				ACmod_list_attribute;
from	ACncpx		import	ACgive_structure;

extern GRclassid OPP_VRCptIn_class_id;


/*******************************************************************************
/*
/* Initialize some instance data whose needed to be initialized only at the 
/* begining of the sketch
/*
/******************************************************************************/

method VRskinit( IGRlong *sts )
{
  IGRlong	status;
  SetProc( VRsketch_VRskinit ); Begin

  *sts = MSSUCC;

  /*| update segment construction list */
  me->const_list.msg            = &me->ret;
  me->const_list.env_info       = &me->ModuleInfo;
  me->const_list.newflag        = FALSE;
  me->const_list.properties     = GRIS_NEW | GRIS_DISPLAYABLE;
  me->const_list.name           = 0;
  me->const_list.display        = &me->LineSymbology.display_attr;
  me->const_list.class_attr     = (char *)&me->assoc_list;
  me->const_list.geometry       = NULL;

  /*| update component construction list */
  me->cmp_const_list.msg        = &me->ret;
  me->cmp_const_list.env_info   = &me->ModuleInfo;
  me->cmp_const_list.newflag    = FALSE;
  me->cmp_const_list.properties = GRIS_NEW | GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  me->cmp_const_list.name       = 0;
  me->cmp_const_list.display    = &me->ActiveDisplay;
  me->cmp_const_list.class_attr = NULL;
  me->cmp_const_list.geometry   = NULL;

  me->assoc_list.go_objid.objid = NULL_OBJID;
  me->assoc_list.as_attr   	= ( IGRchar * )&me->Product;
  me->assoc_list.context   	= NULL;

  /* init for the construct point */

  me->cst_display.color     = 4;
  me->cst_display.weight    = 1;
  me->cst_display.style     = 2;

  me->way_cst_display.color     = 4;
  me->way_cst_display.weight    = 1;
  me->way_cst_display.style     = 1;

  me->cst_buffer.dis_att = NULL;
  me->way_cst_buffer.dis_att = NULL;

  me->cst_poly.points = me->cst_pts;

  me->cst_buffer.tag                 = NULL_OBJID;
  me->cst_buffer.type                = IGRPY;
  me->cst_buffer.flags               = 0;
  me->cst_buffer.range               = NULL;
  me->cst_buffer.level               = NULL;
  me->cst_buffer.ele_spec_att.null   = NULL;
  me->cst_buffer.geometry.polyline   = &me->cst_poly;
  me->cst_buffer.u_bound_att         = NULL;
  me->cst_buffer.v_bound_att         = NULL;
  me->cst_buffer.u_num_bound_att     = 0;
  me->cst_buffer.v_num_bound_att     = 0;
  me->cst_buffer.u_bound_att_indices = NULL;
  me->cst_buffer.v_bound_att_indices = NULL;

  me->way_cst_poly.points = me->way_cst_pts;

  me->way_cst_buffer.tag                 = NULL_OBJID;
  me->way_cst_buffer.type                = IGRPY;
  me->way_cst_buffer.flags               = 0;
  me->way_cst_buffer.range               = NULL;
  me->way_cst_buffer.level               = NULL;
  me->way_cst_buffer.ele_spec_att.null   = NULL;
  me->way_cst_buffer.geometry.polyline   = &me->way_cst_poly;
  me->way_cst_buffer.u_bound_att         = NULL;
  me->way_cst_buffer.v_bound_att         = NULL;
  me->way_cst_buffer.u_num_bound_att     = 0;
  me->way_cst_buffer.v_num_bound_att     = 0;
  me->way_cst_buffer.u_bound_att_indices = NULL;
  me->way_cst_buffer.v_bound_att_indices = NULL;

  status = om$send( msg      = message VRsketch.VRSkInitInstance( sts ),
		    targetid = my_id );
  as$status();

  End
  return ( OM_S_SUCCESS );
}

/*******************************************************************************
/*
/* Initialize construct point display attributes buffer
/*
/******************************************************************************/

method VRskinit_buffer( IGRint *sts )
{

  SetProc( VRsketch_VRskinit_buffer ); Begin
  *sts = MSSUCC;

  me->cst_buffer.dis_att = NULL;
  me->way_cst_buffer.dis_att = NULL;

  End
  return(OM_S_SUCCESS);
}

/*******************************************************************************
/*
/* Initialize construct point display attributes buffer
/*
/******************************************************************************/

method VRSkGetLocateState( IGRlong *sts )
{

  SetProc( VRsketch_VRSkGetLocateState ); Begin
  *sts = MSSUCC;

  if( me->my_state == _start ) *sts = NO_PREVIOUS_SEG;

  End
  return(OM_S_SUCCESS);
}

/*******************************************************************************
/*
/* this method is called after a locate to get the right event. The x,y,z 
/* event data depond of the located element.
/*
/******************************************************************************/

method VRSkGetEvent( IGRlong *sts )
{
  IGRshort			cmp_systype;   /* component item_num          */
  IGRshort			CptNum;        /* component cpt num           */
  IGRboolean			Connect;       /* TRUE if located component   */
					       /* is a nozzle or a conccomp   */
  IGRboolean			IS_CONNECTABLE;/* TRUE if located component   */
					       /* is a nozzle or a conccomp   */
  IGRlong			retcode;       /* return code                 */
  IGRlong			status;        /* return code                 */
  IGRdouble			locate_pt[3];  /* tmp located point	      */
  IGRdouble			accept_pt[3];  /* tmp accept point            */
  struct	GRid		loc_id;        /* located cmp id              */

  SetProc( VRsketch_VRSkGetEvent ); Begin
  *sts = MSSUCC;

  /* we use to CALL VRUpdate function */

  /*| object is located */
  loc_id = me->event1.located_object[0].located_obj;

  /*"loc_obj = %d\n", loc_id.objid */
  me->first_pt_free  = FALSE;
  me->next_pt_free   = FALSE;

  me->IS_CONNECTABLE = FALSE;

  /* --  erase highlight -- */
  status = om$send( msg      = message NDnode.NDdisplay
                               ( 0, GRhe, &me->event1.located_object[0].module_info ),
                    targetid = loc_id.objid, 
                    targetos = loc_id.osnum);
  as$status();

  /*| Get component type : Dangling, Nozzle, Pipe, .... */
  status = om$send( msg      = message VRGeneric.VRGetSysType( &retcode, &cmp_systype ),
      		    targetid = loc_id.objid,
                    targetos = loc_id.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"systype = %d\n", cmp_systype */

  /* nozzle and constrain component are a connectable components by defintion */
  Connect = cmp_systype == VR_NOZZLE || cmp_systype == VR_CONC_COMP;

  /* -- if located object is a connectable component -- */
  status = VRGetIfConnectable
           ( &IS_CONNECTABLE, &loc_id, &me->event1.located_object[0].module_info );
	
  /*"IS_CONNECTABLE = %d \n", IS_CONNECTABLE */

  /* -- If it's a connectable component take the nearest connect point -- */
  if( IS_CONNECTABLE )
  {
	struct	GRid	Win;
	double		dDataPoint[3], dMinDist, dCptCoord[3];

  	dDataPoint[0] = me->event1.event.button.x;
 	dDataPoint[1] = me->event1.event.button.y;
  	dDataPoint[2] = me->event1.event.button.z;

	Win.objid = me->event1.event.button.objid; 
	Win.osnum = me->event1.event.button.osnum; 

	dMinDist = VR$SelectClosestCpt( p_Component= &loc_id,
			    		p_Window   = &Win,
			    		p_DataPoint= dDataPoint,
			    		p_Cpt	   = &CptNum,
					p_CptCoord = dCptCoord,
			    		p_Mdenv	   = &me->event1.located_object[0].module_info);

    	/*"cptcoord = %f %f %f\n", me->event1.event.button.x,me->event1.event.button.y,me->event1.event.button.z */
	if( !Connect ) me->IS_CONNECTABLE = 1;

    	/* -- update the event1 button -- */
        if ( CptNum != -1 ) 
    	{
      	  me->event1.event.button.x = dCptCoord[0];
          me->event1.event.button.y = dCptCoord[1];
          me->event1.event.button.z = dCptCoord[2];
    	}

    me->bI_Need_Pick = TRUE;
  }
  else
  {
	/* located component doesn't have a free connect point */
  	if( cmp_systype == VR_DANGLING )
  	{
 		IGRint 			i, size=5;
		IGRuint			count;
 		OM_S_OBJECT_LINKAGE 	src_link[5];
 		GRclassid 		obj_classid;
	
		extern GRclassid	OPP_ACpretendin_class_id;

   		/*| the located object is a DANGLING */

  		if( loc_id.osnum != me->ModuleInfo.md_id.osnum )
		{
			/*| connexion via OS */

			/* see if the dangling is already connected */
   			status = om$get_channel_objects( osnum 		= loc_id.osnum, 
							 objid 		= loc_id.objid,
                                     			 p_chanselect 	= &AS_notification,
                                     			 list 		= src_link,
							 size 		= size,
                                     			 count 		= &count );

   			if( status != OM_S_SUCCESS && status != OM_I_LISTOVFLOW ) count = 0;

			/*"count of connecting object = %d\n", count */

   			for( i=0; i<count; i++ )
       			{
				/*"conn obj[%d] = %d %d\n", i, src_link[i].S_objid, src_link[i].osnum */

        			om$get_classid( objid = src_link[i].S_objid,
						osnum = src_link[i].osnum,
                        			p_classid = &obj_classid );

        			if(om$is_ancestry_valid( subclassid   = obj_classid,
                          				 superclassid = OPP_ACpretendin_class_id) == OM_S_SUCCESS)
		         	{
					IGRint		index, NbChild;
					GRclassid	obj_class;
					struct GRid	*buffer;
				
					extern GRclassid OPP_VRCptIn_class_id;

					/*| connecting object is a pretend in */

					status = om$send( msg      = message NDnode.NDget_objects
									( ND_CHILDREN | ND_IN_BUF, NULL, 0, &buffer, 0, OM_K_MAXINT, &NbChild ),
				  			  targetid = src_link[i].S_objid,
				  			  targetos = src_link[i].osnum );
					as$status( action = RET_STATUS );

					/*"NbChild = %d\n", NbChild */

					for( index=0; index<NbChild; index++ )
					{
						/*"buffer[%d] = %d %d\n", index, buffer[index].objid, buffer[index].osnum */

  						status = om$get_classid( osnum     = buffer[index].osnum,
                           					 	 objid     = buffer[index].objid,
                           					 	 p_classid = &obj_class );
	  					as$status();

  						if( om$is_ancestry_valid
      							( subclassid   = obj_class,
        						  superclassid = OPP_VRCptIn_class_id ) == OM_S_SUCCESS )
						{
    							ex$message( field   = ERROR_FIELD,
	            						    in_buff = "Dangling already connected" );

		        				*sts = MSFAIL;
                                                        End
        						return OM_S_SUCCESS;
      						}
					}
				}
			}
		}

           {
               struct GRid WindowId;
 
               //Modified by Alwin - for CR179601979
               /* In this we need to have the accepted window Id, by assiging
                  event2 to event1, we loose the window in which the object
                  is accepted. So overcome this problem the accepted window ID
                  is stored in the WindowId and then it is reset */
 
               WindowId.objid = me->event1.event.button.objid;
               WindowId.osnum = me->event1.event.button.osnum;
 
               me->event1.event.button = me->event2.event.button; //Already Existing code
 
               me->event1.event.button.objid = WindowId.objid;
               me->event1.event.button.osnum = WindowId.osnum;
           }
      				
		/* set the button.point with center of component */

/*C  Module Info Changed to event's Module info. In case the object is located
     in reference file the transformation should be from located env to current
     env.       Fixed TR # 179418577
 */

      		status = om$send( msg      = message VRGeneric.VRGetOrigCoor
                              			     ( &retcode, locate_pt, &me->event1.located_object[0].module_info ),
                     		  targetid = loc_id.objid,
                       		  targetos = loc_id.osnum );
      		as$status( action = RET_STATUS );
      		as$status( sts = retcode, action = RET_STATUS );

      		/*"locate_pt = %f %f %f\n", locate_pt[0], locate_pt[1], locate_pt[2] */

    		me->event1.event.button.x = locate_pt[0];
      		me->event1.event.button.y = locate_pt[1];
      		me->event1.event.button.z = locate_pt[2];
	}  		
	else
	{
  		/*"component OS = %d Current OS = %d \n",loc_id.osnum,me->ModuleInfo.md_id.osnum*/
  		if ( loc_id.osnum == me->ModuleInfo.md_id.osnum )
  		{
  			switch( cmp_systype )
  			{
    				case VR_PIPE :
	      				/*| Located object is a pipe */

      					accept_pt[0] = me->event1.event.button.x;
      					accept_pt[1] = me->event1.event.button.y;
      					accept_pt[2] = me->event1.event.button.z;
      					/*"accept pt = %f %f %f\n", accept_pt[0], accept_pt[1], accept_pt[2]*/

	      				status = VRSkLocatePipe
        	       				 ( &retcode, &me->event1, accept_pt, &loc_id,
        	       				   &me->ModuleInfo, locate_pt
               					 );
      					as$status( action = RET_STATUS );

      					if( retcode == MSFAIL )
      					{
    						ex$message( field   = ERROR_FIELD,
	            					    in_buff = "Accept point is out of range !" );

	        				*sts = MSFAIL;
                                                End
        					return OM_S_SUCCESS;
      					}

      					/*"locate_pt = %f %f %f\n", locate_pt[0], locate_pt[1], locate_pt[2]*/

      					me->event1.event.button.x = locate_pt[0];
	      				me->event1.event.button.y = locate_pt[1];
      					me->event1.event.button.z = locate_pt[2];

      					break;

   				case VR_ELBOW :
      					/* right point is the component center */      
	      				status = om$send( msg      = message VRGeneric.VRGetOrigCoor
        	                          			     ( &retcode, locate_pt, &me->ModuleInfo ),
                	       				  targetid = loc_id.objid,
                       					  targetos = loc_id.osnum );
      					as$status( action = RET_STATUS );
	      				as$status( sts = retcode, action = RET_STATUS );

      					/*"locate_pt = %f %f %f\n", locate_pt[0], locate_pt[1], locate_pt[2] */

      					me->event1.event.button.x = locate_pt[0];
      					me->event1.event.button.y = locate_pt[1];
      					me->event1.event.button.z = locate_pt[2];
	      				break;

    				default :
					ex$message( field   = ERROR_FIELD,
	                	   		    in_buff = "Bad located Component !" );
	       				*sts = MSFAIL;
                                        End
	               			return OM_S_SUCCESS;
  			}
  		}
	  	else
        	{
			ex$message( field   = ERROR_FIELD,
        	         	    in_buff = "Bad located Component !" );
	       		*sts = MSFAIL;
		}
	}
  }

  End
  return OM_S_SUCCESS;
}

/*******************************************************************************
/*
/* This method is called at starting when the user gives a data point to get 
/* this points' coordinates. 
/*
/******************************************************************************/

method VRskfstpt( IGRlong *sts )
{
  SetProc( VRsketch_VRskfstpt ); Begin 
  *sts = MSSUCC;

  /* the first data is given by the user, the system call this method to update  first_pt
  /* prev_pt, CmpFirstType ( FREE_SPACE ) and FirstType ( FREE_SPACE ) instance data
  /**/

  me->first_pt[0] = me->event1.event.button.x;
  me->first_pt[1] = me->event1.event.button.y;
  me->first_pt[2] = me->event1.event.button.z;

  me->prev_pt[0]  = me->first_pt[0];
  me->prev_pt[1]  = me->first_pt[1];
  me->prev_pt[2]  = me->first_pt[2];

  /*"first pt %f %f %f\n",me->first_pt[0], me->first_pt[1], me->first_pt[2] */
  /*"first pt %f %f %f\n", me->prev_pt[0], me->prev_pt[1] , me->prev_pt[2]  */

  me->CmpFirstType = FREE_SPACE;  /* user start the line route from a free space */
  me->FirstType    = FREE_SPACE;
  End
  return(OM_S_SUCCESS);
}

/******************************************************************************
/*
/* This method is called when the user locate a component to statr a new 
/* network. In this method system updates some instance data needed later to 
/* construct segments and components
/*
/*****************************************************************************/

method VRskfstelm( IGRlong *sts )
{
  IGRshort	mask;          		/* used by chgprops            	*/
  IGRshort	action;        		/* used by chgprops            	*/
  IGRshort	cmp_systype;   		/* component type              	*/
  IGRshort	cmp_index;     		/* component index             	*/
  BSrc		bsretcode;		/* BS function return code	*/
  IGRint	i;             		/* loop index                  	*/
  IGRint	index;         		/* used to update plane that   	*/
                               		/* will move if extend         	*/
  IGRint	nb_of_planes;  		/* nb of CS planes             	*/
  IGRint	nb_of_supports;		/* nb of supports              	*/
  IGRlong	status;        		/* return code                 	*/
  IGRlong	retcode;       		/* return code                 	*/
  IGRdouble	cmp_pt[6];     		/* connect pt of the dang      	*/
  IGRmatrix 	ref_matrix;    		/* needed for nozzle           	*/
  GRclassid	ClassId;       		/* located object class id     	*/
  struct	GRid	planes_id[4];  	/* prev_seg planes id          	*/
  struct	GRid	NewActParamId; 	/* needed in VR_CONNECTABLE case*/
  struct 	GRid	PrevSegId;	/* dangling's support via OS	*/
  union		VRparam_attr ActParam;  /* located object attributes   	*/

  SetProc( VRsketch_VRskfstelm ); Begin 
  *sts = MSSUCC;

  /*| object is located or key point is given */
  __DBGpr_obj("locatedobj ", me->event1.located_object[0].located_obj );

  if( ! me->event1.num_id ) goto free_space; /* it is a key point */

  /*"loc_obj osnum = %d\n", me->event1.located_object[0].located_obj.osnum */
  /*"mdenv objid   = %d\n", me->event1.located_object[0].module_info.md_id.objid */
  /*"msenv osnum   = %d\n", me->event1.located_object[0].module_info.md_id.osnum */

  om$get_classid( osnum     = me->event1.located_object[0].located_obj.osnum,
		  objid     = me->event1.located_object[0].located_obj.objid,
		  p_classid = &ClassId );

  if( om$is_ancestry_valid( subclassid = ClassId,
                            superclassid = OPP_VRGeneric_class_id ) != OM_S_SUCCESS ) goto free_space;

		/* Located Element class is a subclass of VRGeneric */

  /* set FirstLocatedElemId instance data */
  me->FirstLocatedElemId    = me->event1.located_object[0].located_obj;
  me->FirstLocatedElemMdEnv = me->event1.located_object[0].module_info;

// added by alwin for CR179300978
/* If the located component is "Correction" get its 'option_code' and
*  set it in the Sketch Form, if component is a danglling then get the
*  correction connected to it and get the 'option_code */
  if( me->FirstLocatedElemId.objid != NULL_OBJID && me->Product == VR_PIPING )
  {
     IGRshort nStatus;
     IGRlong msg;
     IGRchar szCompCode[10];
     struct GRid   CorId;
     struct ret_struct ExprSt;

     status = om$send( msg      = message VRGeneric.VRGetSysType
                                        ( &msg, &cmp_systype ),
                    senderid = NULL_OBJID,
                    targetid = me->FirstLocatedElemId.objid,
                    targetos = me->FirstLocatedElemId.osnum );
 
     switch( cmp_systype )
     {
 
         case VR_PIPE :
 
           status = VRResetOptionCode(&msg, me->form_ptr,
                                      me->FirstLocatedElemId );
           break;
 
         case VR_DANGLING :
 
           CorId.objid = NULL_OBJID;
           status = om$send ( msg = message VRGeneric.VRGetCorOnCpt( &msg,
                               0, &CorId, &me->FirstLocatedElemMdEnv ),
          /*                 senderid = NULL_OBJID, */
                           targetid = me->FirstLocatedElemId.objid,
                           targetos = me->FirstLocatedElemId.osnum );
           __DBGpr_obj("correction id",CorId);
      /* Flow changed for TR179900739 */
      /*     if(CorId.objid == NULL_OBJID) Could not get to this code  */
           {
      IGRchar pathname[OM_K_MAXOSNAME_LEN];
      struct GRid ExpressionId;

      /* Get the Current Working Directory */
      status = di$pwd( dirname = pathname );

      /* Setting it to the HOME directory i.e ":filename:usr" */
      status = di$cd( dirname = DIR_G_home_name );

      /* Get the ExpressionId if it is already created in the
         Directory Subsystem */
      status = di$translate(
                       objname = "piping_option_code",
                       p_objid = &ExpressionId.objid,
                       p_osnum = &ExpressionId.osnum );

      /* Re-Setting it to the PWD directory  */
      status = di$cd( dirname = pathname );

      if( ExpressionId.objid != NULL_OBJID )
      {
         status =
         om$send ( msg = message NDnode.NDgive_structure(
                              &msg, &ExprSt, &me->FirstLocatedElemMdEnv),
                senderid = NULL_OBJID,
                targetid = ExpressionId.objid,
                targetos = ExpressionId.osnum );
         as$status ();
      }
      else
      {
         strcpy(ExprSt.var.text_st.text_string, "1");
      }
/* Logic changed for tr179900739 */
FIfld_set_text(me->form_ptr, PIPING_OPTION, 0, 0,ExprSt.var.text_st.text_string,FALSE);
           } 
/*           else ----  flow changed for tr179900739  */
{

/*
              status = VRResetOptionCode(&msg, me->form_ptr, CorId );
*/
}
           break;
 
         default :
 
           status = om$send ( msg = message VRGeneric.VRGetCode( &msg,
                                               szCompCode ),
                    senderid = NULL_OBJID,
                    targetid = me->FirstLocatedElemId.objid,
                    targetos = me->FirstLocatedElemId.osnum );
 
           if( !strncmp(szCompCode, "EL", 2) )
           {
             for( i=0; i<2; i++ )
             {
                  status = om$send ( msg = message VRGeneric.VRGetCorOnCpt(
                               &msg, i, &CorId, &me->FirstLocatedElemMdEnv ),
                           senderid = NULL_OBJID,
                           targetid = me->FirstLocatedElemId.objid,
                           targetos = me->FirstLocatedElemId.osnum );

                  if( CorId.objid != NULL_OBJID )
                  {
                      status =
                      om$send ( msg = message VRGeneric.VRGetStatus( &msg,
                                        &nStatus ),
                           senderid = NULL_OBJID,
                           targetid = CorId.objid,
                           targetos = CorId.osnum );
 
                      if( nStatus & VR_CORRECTION )
                      {
                         status = VRResetOptionCode(&msg, me->form_ptr, CorId );
                         break;
                      }
                 }
              }
            }
            else if( !strcmp(szCompCode, "TEE") )
            {
                 for( i=0; i<3; i++)
                 {
         
                     status =
                     om$send ( msg = message VRGeneric.VRGetCorOnCpt( &msg,
                                      i, &CorId, &me->FirstLocatedElemMdEnv ),
                          senderid = NULL_OBJID,
                          targetid = me->FirstLocatedElemId.objid,
                          targetos = me->FirstLocatedElemId.osnum );
 
                     if( CorId.objid != NULL_OBJID )
                     {
                         status =
                         om$send ( msg = message VRGeneric.VRGetStatus( &msg,
                                        &nStatus ),
                                senderid = NULL_OBJID,
                                targetid = CorId.objid,
                                targetos = CorId.osnum );
 
                         if( nStatus & VR_CORRECTION )
                         {
                            status = VRResetOptionCode(&msg, me->form_ptr,
                                                       CorId );
                            break;
                         }
                     }
 
                 }
            }
            break;
     }
  }
// added by alwin for CR179300978

  status = om$send( msg      = message VRGeneric.VRGetSysType
                                                 ( &retcode, &cmp_systype ),
                    targetid = me->FirstLocatedElemId.objid,
                    targetos = me->FirstLocatedElemId.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( me->IS_CONNECTABLE ) cmp_systype = VR_CONNECTABLE;

  /* now, we system propose to start only from nozzle, dangling, pipe, elbow and constraints
  /* components ( split, offset, helix, ... ). If user located an other component the system 
  /* start the line route from free space
  /**/

  if( cmp_systype == VR_NOZZLE || cmp_systype == VR_DANGLING
                               || cmp_systype == VR_PIPE
                               || cmp_systype == VR_ELBOW 
                               || cmp_systype == VR_CONC_COMP
			       || cmp_systype == VR_CONNECTABLE )
  {

	struct GRid UsrId, NewUsrParamId;

	/* the system need to update the parameter design form and the 
	additionnal parameters form from the located component. The route 
	system autorize components to share the same attributes collection 
	except correction component.*/

	if(  cmp_systype == VR_NOZZLE ) //allowing raceway nozzle also. Alwin
	{
	  /*A load the dia in PIPING and width and depth in HVAC */
	  {
	    IGRint			NbAttr=0;
	    union  VRparam_attr		dimension;
	    struct GRid			SysId;
	    struct ACrg_coll		Attr[5];
	    IGRlong			retmsg;
	    struct ret_struct		ParamAttr;
	    IGRint 			FootIndex = -1, retstatus;

	    status = 
	    VR$GetCmpAttributes( 	p_retmsg	= &retcode,
				     	Product		= me->Product,
					p_ComponentId	= &me->FirstLocatedElemId,
					p_SysParamId	= &SysId,
					p_MdEnv		= &me->ModuleInfo );
	    as$status( sts = retcode, action = RET_STATUS );

            /* added by alwin for TR179802345 */
            /* Actually all these days we've have been grabing only the System
            Attributes from the nozzle and forming a new collector for the
            components sketched out of the Nozzle. Whereas we've to do the same
            for User Params also. */

            __DBGpr_obj( " Nozzle Id ", me->FirstLocatedElemId );

            __DBGpr_com( " Get the User Collection from Nozzle ... " );
            status =
            VR$GetCmpAttributes(        p_retmsg        = &retcode,
                                        Product         = me->Product,
                                        p_ComponentId = &me->FirstLocatedElemId,
                                        p_UserParamId   = &UsrId,
                                        p_MdEnv         = &me->ModuleInfo );
            as$status( sts = retcode, action = RET_STATUS );
            __DBGpr_obj( " Nozzle User Coll Id ", UsrId );

            /* added by alwin for TR179802345 */

	    status = 
	    VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
			     		Product		  = me->Product,
					p_SysCollectionId = &SysId,
					p_DimAttributes   = &dimension,
					p_MdEnv		  = &me->ModuleInfo );
	    as$status( sts = retcode, action = RET_STATUS );

	    switch( me->Product )
	    {
		case VR_PIPING:
		NbAttr=2;
		strcpy( Attr[0].name, VR_N_GDIAMETER_DB);
		Attr[0].desc.value.att_exp = dimension.piping_attr.G_diameter;
		strcpy( Attr[1].name, VR_N_RDIAMETER_DB);
		Attr[1].desc.value.att_exp = dimension.piping_attr.R_diameter;
		break;
		
		case VR_RWAY:
		case VR_HVAC:
		NbAttr=5;
		strcpy( Attr[0].name, VR_N_WIDTH1_DB);
		Attr[0].desc.value.att_exp = dimension.hvac_attr.G_width;
		strcpy( Attr[1].name, VR_N_DEPTH1_DB);
		Attr[1].desc.value.att_exp = dimension.hvac_attr.G_depth;
		strcpy( Attr[2].name, VR_N_WIDTH2_DB);
		Attr[2].desc.value.att_exp = dimension.hvac_attr.R_width;
		strcpy( Attr[3].name, VR_N_DEPTH2_DB);
		Attr[3].desc.value.att_exp = dimension.hvac_attr.R_depth;
		strcpy( Attr[4].name, VR_N_SHAPE_IN);
		/*A get the shape from the nozzle it self */
		status = 
		om$send( msg      = message ACncpx.ACgive_structure(
      			   &retstatus, &FootIndex, 
			   VR_N_SHAPE_IN, &ParamAttr, &me->ModuleInfo),
                    targetid = me->FirstLocatedElemId.objid,
                    targetos = me->FirstLocatedElemId.osnum );
		as$status();
		Attr[4].desc.value.att_exp = ParamAttr.var.root_pm_st.value;

                /* In case of Pid, CERT wants the duct shape to be of
                   the Active Shape, even if Nozzle is of different Shape 
                   Code*/
                if( bVR_IS_PID_ACTIVE && ( me->Product != VR_RWAY ) )
                {
                   status =
                   om$send( msg = message ACncpx.ACgive_structure(
                                 &retstatus, &FootIndex,
                                 VR_N_SHAPE_IN, &ParamAttr, &me->ModuleInfo),
                          senderid = NULL_OBJID,
                          targetid = me->ActParamId.objid,
                          targetos = me->ActParamId.osnum );
                   as$status();
                   Attr[4].desc.value.att_exp = ParamAttr.var.root_pm_st.value;
                }
		break;
		
		default:
		printf( "VRskfstelm: InValid Product Type\n" );
		break;

	    }/*end switch */
	
	    for( i=0; i<NbAttr; i++ )
		Attr[i].desc.type = AC_ATTRIB_DOUBLE;

	    /*A modify the attribute in the active collection */
	    /*A Create a new active collection, and modify the new collection */
	    /*A attributes.	*/

	    /*C In case of a nozzle it is safe to create a new collection.  */
	    /*C If you work on the old collections you could be modifying the */
	    /*C sizes of any previous components created. */

	    NewActParamId.objid = NULL_OBJID;
	    NewActParamId.osnum = me->ModuleInfo.md_id.osnum;
	    status =
	    VR$ModifyCollection(    p_msg                   = &retmsg,
				    p_InputCollectionId     = &me->ActParamId,
				    p_OutputCollectionId    = &NewActParamId );
	    as$status();
	    as$status( sts = retmsg );

	    status =
	    VR$ModifyCollection(    p_msg                   = &retmsg,
				    Operation		    = VR_UPDATE_COLL,
				    p_InputCollectionId     = &SysId,
				    p_OutputCollectionId    = &NewActParamId );
	    as$status();
	    as$status( sts = retmsg );

	    status =
	    VR$ModifyCollection(    p_msg                   = &retmsg,
				    Operation               = VR_UPDATE_COLL,
				    p_ParamsListToModify    = Attr,
				    NbParamsToModify        = NbAttr,
				    p_OutputCollectionId    = &NewActParamId );
	    as$status();
	    as$status( sts = retmsg );

            NewUsrParamId.objid = NULL_OBJID;
            NewUsrParamId.osnum = me->ModuleInfo.md_id.osnum;
            status =
            VR$ModifyCollection(    p_msg                   = &retmsg,
                                    p_InputCollectionId     = &UsrId,
                                    p_OutputCollectionId    = &NewUsrParamId );
            as$status();
            as$status( sts = retmsg );

	    me->ActParamId       = NewActParamId;
            me->UsrParamId       = NewUsrParamId; //added by alwin TR179802345
	  }
	} else {
        __DBGpr_com("Get Comp Attributes");
        status = VR$GetCmpAttributes( 	p_retmsg	= &retcode,
				     	Product		= me->Product,
					p_ComponentId = &me->FirstLocatedElemId,
					p_SysParamId	= &me->ActParamId,
					p_UserParamId	= &me->UsrParamId,
					p_MdEnv		= &me->ModuleInfo );
      	as$status( action = RET_STATUS );
      	as$status( sts = retcode, action = RET_STATUS );

        status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
				     		Product		  = me->Product,
						p_SysCollectionId = &me->ActParamId,
						p_DimAttributes   = &ActParam,
						p_MdEnv		  = &me->ModuleInfo );
      	as$status( action = RET_STATUS );
      	as$status( sts = retcode, action = RET_STATUS );
	}
	
      	/*^ VRprint_user_attr( &me->ActParamId );  */
      	/*^ VRprint_user_attr( &me->UsrParamId ); */

        /* for elbow HVAC and constraints component attributes need to be taken
	 from connect point ==> this is going to be done later. */
      	switch( cmp_systype )
      	{
        	case VR_DANGLING :
                   __DBGpr_com("processing dangle ********************");
			/* this case can not be inter OS */
		        /* update current section if HVAC */
		        if( me->Product == VR_HVAC || me->Product == VR_RWAY )
		        {
				status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
								p_ComponentId	= &me->FirstLocatedElemId,
								p_OutPutSection	= me->section_matrix,
								p_MdEnv		= &me->ModuleInfo );
          			as$status( action = RET_STATUS );
          			as$status( sts = retcode, action = RET_STATUS );
        		}

/* get the support of the dangling. the segment is going to be the last segment of
		        the current line route ( prev_seg_id )
		        */

		        status = om$send( msg = message VRGeneric.VRGetSupports
                		                ( &retcode, 1, &PrevSegId, &nb_of_supports ),
		                       	  targetid = me->FirstLocatedElemId.objid, 
	                	          targetos = me->FirstLocatedElemId.osnum );
			as$status( action = RET_STATUS );
			as$status( sts = retcode, action = RET_STATUS );

		        /*"nb_of_support = %d\n", nb_of_supports */
		        /*"prev_seg_id = %d\n", PrevSegId.objid */

       			/* update previous and first points : dangling support end points */
       			status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               	             	     ( &retcode, NULL, &me->FirstLocatedElemMdEnv, cmp_pt, NULL ),
                          		  targetid = PrevSegId.objid,
       	                  		  targetos = PrevSegId.osnum);
       			as$status( action = RET_STATUS );

	        	/* get index of the dangling on its support ( segment ) to know witch is the start 
		        /* point and witch is the end point of thpreve segment
		        /**/

		        status = om$send(msg      = message VRGeneric.VRGetIndex
               		                            ( &retcode, &PrevSegId, &cmp_index ),
	                	         targetid = me->FirstLocatedElemId.objid,
               		        	 targetos = me->FirstLocatedElemId.osnum);
		        as$status( action = RET_STATUS );
		        as$status( sts = retcode, action = RET_STATUS );

			if( me->ModuleInfo.md_id.osnum == me->FirstLocatedElemMdEnv.md_id.osnum )
			{
         			me->CmpFirstType = IS_DANGLING; /* we use this instance in VRskdelseg method */
        			me->FirstType    = IS_DANGLING; /* we use this instance to create the next segment 
                        			                /* and the right components on it. this instance
                                        			/* set to free space each time a create a new segment
                                        			/**/

				me->prev_seg_id = PrevSegId;
				
			        /* Change it temporary to no locatable */
			        mask   = GRIS_LOCATABLE;
			        action = 0;
		        	status = om$send( msg      = message GRvg.GRchgprops( &retcode, &action, &mask ),
                			          targetid = me->prev_seg_id.objid,
		                        	  targetos = me->prev_seg_id.osnum);
			        as$status( action = RET_STATUS );
			        as$status( sts = retcode, action = RET_STATUS );

			        if( cmp_index == 1 )
        			{
					/* dangling is at the end of CS */
       
					me->CmpPosition = END_OF_SEG; /* +1 : this instance data is needed to replace
        	                         			      /* correctly the dangling.
                	                        		      /**/

          				/* update previous and first point instance data */
          				for(i=0;i<3;i++)
          				{
		            			me->prev_pt[i]  = cmp_pt[i];
	            				me->first_pt[i] = cmp_pt[i+3];
        	  			}
        			}
        			else
	        		{
        	  			/* dangling is at the begining of CS */
          				me->CmpPosition = BEGIN_OF_SEG; /* -1 */
          				me->CmpOrientation[0] = -1; /* this instance data is needed to replace
			        	                            /* correctly the dangling. 
			                	                    /**/

	          			me->CmpOrientation[1] =  1; /* not needed here +1 by default ==> 05-07-91 */
	
        	  			for(i=0;i<3;i++)
          				{
            					me->prev_pt[i]  = cmp_pt[i+3];
            					me->first_pt[i] = cmp_pt[i];
	          			}
        			}
/*  
printf("prev_pt = %f %f %f\n",me->prev_pt[0] ,me->prev_pt[1],me->prev_pt[2]);
printf("first_pt= %f %f %f\n",me->first_pt[0],me->first_pt[1],me->first_pt[2]);
*/
			        /* update the plane to move if extend */
			        status = om$send ( msg = message NDnode.NDget_objects
                		                         ( ND_ROOT, planes_id, 4, NULL, 0,
          						   OM_K_MAXINT, &nb_of_planes
                                		         ),
		                        	   targetid = me->prev_seg_id.objid, 
	                		           targetos = me->prev_seg_id.osnum);
			        as$status( action = RET_STATUS );
			        as$status( sts = retcode, action = RET_STATUS );

		        	index = 0;
			        if( me->CmpPosition == END_OF_SEG ) index = 3;

			        me->plane_to_move_id = planes_id[index];
			        /*"plane_to_move = %d\n",me->plane_to_move_id.objid */ 

		        	/* update seg_GRid table and num_of_seg ==> add the dangling support */
			        me->num_of_seg = 1;
			        me->seg_GRid[0] = me->prev_seg_id;
			        /*"num_of_seg      = %d\n", me->num_of_seg */
		        	/*"me->seg_GRid[0] = %d\n", me->seg_GRid[0].objid */
			}
			else
			{
         			me->CmpFirstType = IS_DANGLING_TO_CONNECT; /* we use this instance in VRskdelseg method */
        			me->FirstType    = IS_DANGLING_TO_CONNECT; /* we use this instance to create the next segment 
                        			                	   /* and the right components on it. this instance
                                        				   /* set to free space each time a create a new segment
                                        				   /**/

    				BSmkvec(  &bsretcode, me->ImpDirForDyn, &cmp_pt[0], &cmp_pt[3] );
				
				if( cmp_index == 0 )
				{
					me->ImpDirForDyn[0] *= -1;
					me->ImpDirForDyn[1] *= -1;
					me->ImpDirForDyn[2] *= -1;
				}
	
	      			BSnorvec( &bsretcode, me->ImpDirForDyn );

				me->NbOfImpDirection 	= 1;

  				me->first_pt[0] 	= me->event1.event.button.x;
  				me->first_pt[1] 	= me->event1.event.button.y;
  				me->first_pt[2] 	= me->event1.event.button.z;

  				me->prev_pt[0]  	= me->first_pt[0];
  				me->prev_pt[1]  	= me->first_pt[1];
  				me->prev_pt[2]  	= me->first_pt[2];
/*
printf("first pt %f %f %f\n",me->first_pt[0], me->first_pt[1], me->first_pt[2]);
printf("prev pt %f %f %f\n", me->prev_pt[0], me->prev_pt[1] , me->prev_pt[2]);
*/			}
			
		        break;

        	case VR_NOZZLE :
          		me->FirstType = IS_NOZZLE;
			me->CmpFirstType = IS_NOZZLE;

	          	/*"FirstType    = %d\n", me->FirstType */
	          	/*"CmpFirstType = %d\n", me->CmpFirstType */

		        /* Get nozzle matrix to update first_pt, prev_pt and 
			the sketch imposed direction. ( when we start from a 
			nozzle, directon of starting segment must be the 
			x nozzle axis ). imposed direction instance is used to 
			force the dynamic to be in the /* nozzle x axis. */

          		status = 
			om$send( msg      = message VRGeneric.VRGetMatrix
	             			( &retcode, 0, NULL, ref_matrix,
					&me->FirstLocatedElemMdEnv ),
				  targetid = me->FirstLocatedElemId.objid,
				  targetos = me->FirstLocatedElemId.osnum );
          		as$status( action = RET_STATUS );

			me->NbOfImpDirection   = 1;
          		me->ImpDirForDyn[0] = ref_matrix[0];
          		me->ImpDirForDyn[1] = ref_matrix[4];
          		me->ImpDirForDyn[2] = ref_matrix[8];

          		me->first_pt[0]    = me->event1.event.button.x;
          		me->first_pt[1]    = me->event1.event.button.y;
          		me->first_pt[2]    = me->event1.event.button.z;

          		me->prev_pt[0]     = me->first_pt[0];
          		me->prev_pt[1]     = me->first_pt[1];
          		me->prev_pt[2]     = me->first_pt[2];

          		/* update section matrix from nozzle matrix */
          		if( me->Product != VR_PIPING )
          		{
            			me->section_matrix[0] = ref_matrix[0];
            			me->section_matrix[1] = ref_matrix[4];
            			me->section_matrix[2] = ref_matrix[8];
            			me->section_matrix[3] = ref_matrix[1];
            			me->section_matrix[4] = ref_matrix[5];
            			me->section_matrix[5] = ref_matrix[9];
            			me->section_matrix[6] = ref_matrix[2];
            			me->section_matrix[7] = ref_matrix[6];
            			me->section_matrix[8] = ref_matrix[10];
         		}

          		break;

        	case VR_PIPE :
	  		/* this case can not be inter OS */
          		/*| cmp_systype is a pipe */

          		me->FirstType     = IS_PIPE;
          		me->CmpFirstType  = IS_PIPE;

          		me->first_pt[0] = me->prev_pt[0]  = me->event1.event.button.x;
          		me->first_pt[1] = me->prev_pt[1]  = me->event1.event.button.y;
          		me->first_pt[2] = me->prev_pt[2]  = me->event1.event.button.z;

          		/*"SplitPt = %f %f %f\n", me->first_pt[0], me->first_pt[1], me->first_pt[2] */

          		/* get pipe support ( segment to split later ) befor placing tee */
          		status = VRSkGetPipeVirtualSupportInfo
                   		 ( &me->FirstLocatedElemId, me->first_pt, &me->ModuleInfo,
				   &me->prev_seg_id, me->ImpDirForDyn, NULL
                   		 );
			as$status( action = RET_STATUS );

          		/*"prev_seg = %d\n", me->prev_seg_id.objid */

			me->NbOfImpDirection = 1;
          		
			/* update section if HVAC */
          		if( me->Product == VR_HVAC || me->Product == VR_RWAY )
          		{
			status =
			VR$ModifyHvacSection
			(	p_retmsg	= &retcode,
				p_ComponentId	= &me->FirstLocatedElemId,
				p_OutPutSection	= me->section_matrix,
				p_MdEnv		= &me->ModuleInfo
			);
          		as$status();
          		}
			
			break;

        	case VR_ELBOW :
			/* this case can not be inter OS */
        		/*| First componnet is an elbow */

        		me->FirstType    	= IS_ELBOW;
        		me->CmpFirstType 	= IS_ELBOW;

        		status = VRSkGetElbowTopo
                 		 ( &me->FirstLocatedElemId, &me->ImpDirForDyn[0], &me->ImpDirForDyn[3],
                  		   me->first_pt, &me->ModuleInfo
                 		 );
        		as$status( action = RET_STATUS );

			me->NbOfImpDirection = 2;

			{
				IGRint		dummy;
			  	struct 	GRid 	TmpId[2];

  				/*| -- Get Elbow supports to update prev_seg_id -- */
				status = om$send( msg 	   = message VRGeneric.VRGetSupports
	                        	 	  	             ( &retcode, 2, TmpId, &dummy ),
                   	  		  	  targetid = me->FirstLocatedElemId.objid, 
                    	  		  	  targetos = me->FirstLocatedElemId.osnum );
 				as$status( action = RET_STATUS );
  				as$status( sts = retcode, action = RET_STATUS );

				me->prev_seg_id = TmpId[0];
 			}

        		me->prev_pt[0] = me->first_pt[0];
        		me->prev_pt[1] = me->first_pt[1];
        		me->prev_pt[2] = me->first_pt[2];

        		if( me->Product == VR_HVAC || me->Product == VR_RWAY )
        		{
				status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
								p_ComponentId	= &me->FirstLocatedElemId,
								p_OutPutSection	= me->section_matrix,
								p_MdEnv		= &me->ModuleInfo );
          			as$status( action = RET_STATUS );
          			as$status( sts = retcode, action = RET_STATUS );
		       	}

			break;

        	case VR_CONNECTABLE :
        	case VR_CONC_COMP :

          		if( cmp_systype ==  VR_CONC_COMP)
          		{
            			me->FirstType    = IS_CONC_COMP;
            			me->CmpFirstType = IS_CONC_COMP;
          		}
          		else
          		{
	    			me->FirstType    = IS_COMP_TO_CONNECT;
            			me->CmpFirstType = IS_COMP_TO_CONNECT;
          		} 
          		/*"FirstType = %d\n", me->FirstType */
          		status = VRGetCompInfo
                   		 ( me->Product, &me->FirstLocatedElemId, me->FirstType,
				   &me->event1.event.button.x, &me->FirstLocatedElemMdEnv, &me->FirstCptNum,
                                   me->first_pt, me->ImpDirForDyn, NULL, &me->ActParamId, &NewActParamId
		   		);
          		as$status( action = RET_STATUS );
         /* Tier processing for tr179801939 */
/************** CR179900491, load the default active params and instance[?]
The following block was uncommented for tr179900780**********************/
         if(me->Product == VR_RWAY)
         {
           /* Modified for CR179900491 */
           IGRint shape_code;
           if( me->shape_gadget == RW_O_SHAPE )
              shape_code = VR_OVAL;
           else if( me->shape_gadget == HV_C_SHAPE )
              shape_code = VR_CIRC;
           else if( me->shape_gadget == RW_RS_SHAPE )
              shape_code = VR_CORNER;
           else if( me->shape_gadget == RW_E_SHAPE )
              shape_code = VR_ELLIPSE;
           else  /***** Modified for tr179900780 *****/
           {
              me->shape_gadget = RW_R_SHAPE;
              shape_code = VR_RECT;
           }
           me->active_cpt = 1;
           status = VRRw_loc_dimen_fields(&me->ModuleInfo,
                                   me->FirstLocatedElemId,
                                   NULL, 
                                   me->FirstCptNum,
                                   NULL,
                                   shape_code, me->RWcptdata,
                                   &NewActParamId );

         }
			me->NbOfImpDirection = 1;
			me->ActParamId       = NewActParamId;

          		if( me->Product != VR_PIPING )
          		{
  				status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
								p_ComponentId	= &me->FirstLocatedElemId,
								CmpCptNum	= me->FirstCptNum,
								p_OutPutSection	= me->section_matrix,
								p_MdEnv		= &me->FirstLocatedElemMdEnv );
            			as$status( action = RET_STATUS );
            			as$status( sts = retcode, action = RET_STATUS );
          		}

          		/*"imp_dir  = %f %f %f\n", me->ImpDirForDyn[0],me->ImpDirForDyn[1],me->ImpDirForDyn[2]*/
			/*"first pt = %f %f %f\n", me->first_pt[0],me->first_pt[1],me->first_pt[2]*/

  	  		me->prev_pt[0]  = me->first_pt[0];
	  		me->prev_pt[1]  = me->first_pt[1];
	 		me->prev_pt[2]  = me->first_pt[2];

			break;

	        default : break;

	} /* end of switch( cmp_systype ) */

         /* Tier processing for tr179801939 */
         /**** CR179900491, load the default active params and instance[?] */
         if(me->Product == VR_RWAY)
         {
           /* Modified for CR179900491 */
           IGRint shape_code;
           if( me->shape_gadget == RW_O_SHAPE )
              shape_code = VR_OVAL;
           else if( me->shape_gadget == HV_C_SHAPE )
              shape_code = VR_CIRC;
           else if( me->shape_gadget == RW_RS_SHAPE )
              shape_code = VR_CORNER;
           else if( me->shape_gadget == RW_E_SHAPE )
              shape_code = VR_ELLIPSE;
           else
              shape_code = VR_RECT;
__DBGpr_com("***** VRskfstelm cpt processing *****");
           me->active_cpt = 1;
           __DBGpr_com("VRskfstelm-call VRRw_loc_dimen_fields");
           me->active_cpt = 1;
           __DBGpr_com("VRskfstelm-call VRRw_loc_dimen_fields");
           status = VRRw_loc_dimen_fields(&me->ModuleInfo,
                                   me->FirstLocatedElemId,
                                   NULL,
                                   me->FirstCptNum,
                                   NULL,
                                   shape_code, me->RWcptdata,
                                   &me->ActParamId );

         }


      	/* component additionnal attributes collection become system's active collection */
      	VR$active_params( operation    = VR_REPLACE,
                          VRproduct    = me->Product,
                          mode         = VR_USER_MODE,
                          update_flag  = VR_UPDATE,
                 	  act_param_id = &me->UsrParamId,
  	      	          status       = retcode );

	VR$active_params( operation    = VR_REPLACE,
                          VRproduct    = me->Product,
                          update_flag  = VR_UPDATE,
  	                  act_param_id = &me->ActParamId,
  	      	          status       = retcode );
        __DBGpr_com("Call01 to VRSkUpdateForm");
        status = VRSkUpdateForm( me->Product, me->form_ptr, &me->shape_gadget,
				 &me->ActParamId, me->CmpAABBCCcode,
                                 &me->active_cpt, me->RWcptdata,
                                 &me->ModuleInfo, VR_AUTOMATIQUE );
        __DBGpr_com("back from VRSkUpdateForm");

  	as$status();
  }
  else
  {
free_space :

  	me->FirstType = FREE_SPACE;

  	me->first_pt[0] = me->event1.event.button.x;
  	me->first_pt[1] = me->event1.event.button.y;
  	me->first_pt[2] = me->event1.event.button.z;

	  me->prev_pt[0]  = me->first_pt[0];
  	me->prev_pt[1]  = me->first_pt[1];
  	me->prev_pt[2]  = me->first_pt[2];
  
  	/*"first pt %f %f %f\n", me->first_pt[0],me->first_pt[1],me->first_pt[2] */
  }

  me->BufParamId = me->ActParamId;

	End
  return(OM_S_SUCCESS);

}


/*******************************************************************************
/*
/* This method is called when the user gives the next data point to get this 
/* points' x,y,z coordinates and to verify if this point is valid
/*
/******************************************************************************/

method VRsknextpt( IGRlong *sts )
{
  IGRint	index;       /* loop index                   		 */
  IGRint	action, IsValidPoint;
			     /* needed to call is_next_pt_valid function */
  IGRlong	retcode;      /* return code                  		 */
  IGRlong	status;      /* return code                  		 */
  IGRdouble     projpt[3];   /* projection of the next point 		 */
  IGRmatrix	win_matrix;  /* window matrix                		 */
  IGRmatrix	ref_matrix;  /* active ref. matrix              */
  IGRdouble	vector1[3],vector2[3], normal[3];
    IGRdouble dVectDotProd=0.0;
    IGRdouble vector0[3];
  IGRdouble	unite;
  IGRdouble	free_angle;
  IGRlong	rc;

  SetProc( VRsketch_VRsknextpt ); Begin 

  *sts         = MSSUCC;
  retcode       = MSSUCC;
  unite	       = M_PI / 180;

  /* This Initialization is a must, otherwise the Missing Parameters of a
  certain Component is being carried on to other Components which really don't
  need this. It may be dangerous to allow so. This intialization itself will
  fix the TR179800431. B'cas of this extra parameter pipe "bend_sweep" being
  carried to the pipe, and which doesn't display at the end. Alwin */
  me->MissParamId.objid = NULL_OBJID;
  /* upgrade next_pt */
  me->next_pt[0] = me->event1.event.button.x;
  me->next_pt[1] = me->event1.event.button.y;
  me->next_pt[2] = me->event1.event.button.z;
  /*"next pt %f %f %f\n",me->next_pt[0],me->next_pt[1],me->next_pt[2] */

  /*"orth_sketch = %d\n", me->orthogonal_sketch */
  /* the mode is orthogonal : get the window matrix */
  status = om$send( msg        = message IGEgragad.DPinrot
                                                   ( &retcode, win_matrix ),
                    targetid   = me->event1.event.button.objid,
                    targetos   = me->event1.event.button.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( me->orthogonal_sketch )
  {
    /*| calculate the projpt and test if is a valid point */
    VRget_project_pt( me->first_pt, me->next_pt, projpt, &win_matrix[8],
                      (me->FirstType==IS_COMP_TO_CONNECT || me->FirstType==IS_NOZZLE
						         || me->FirstType==IS_CONC_COMP) ? me->ImpDirForDyn : NULL );

    if(me->FirstType == IS_NOZZLE)
    {
      /*
      to call VRis_next_pt_valid we need to get information from located element
      */
      /* Additional filter for TR17980988 */
      /* For nozzles, prevent acceptance of any point on +x axis */

      status = om$send( msg      = message VRGeneric.VRGetMatrix
          ( &retcode,0,NULL,ref_matrix,&me->FirstLocatedElemMdEnv ),
		  targetid = me->FirstLocatedElemId.objid,
		  targetos = me->FirstLocatedElemId.osnum );
      as$status( action = RET_STATUS );

      BSmkvec( &retcode, vector1, me->first_pt, projpt );

      vector0[0] = ref_matrix[0];
      vector0[1] = ref_matrix[4];
      vector0[2] = ref_matrix[8];
 
      dVectDotProd = BSdotp(&retcode, vector0,vector1 );
      /* If the dot product of the two vectors is positive then they're heading
      the same direction. */

      if( dVectDotProd < VRGetTol(VR_DOTPROD_TOL) )
      {
        ex$message( field   = ERROR_FIELD,
                in_buff = "Can't sketch in this direction !" );

        *sts = MSFAIL;
	End
        return OM_S_SUCCESS;
      }
    }

  }
  else
  { 
	/* the mode is skewed */
    	projpt[0] = me->next_pt[0];
    	projpt[1] = me->next_pt[1];
    	projpt[2] = me->next_pt[2];

    	/* an angle has been defined in the skewed mode*/
    	if(me->AngleFlag == TRUE)
   		VRskdisplay_angle( me->Angle, me->prev_pt, me->first_pt, projpt, &win_matrix[8] );
   	else
   	{
		/* no angle is defined for the skewed mode and we are in free mode */
		/* we only display differently the extend and the perendicular directions */
   				
   		vector1[0] = me->first_pt[0] - me->prev_pt[0];
   		vector1[1] = me->first_pt[1] - me->prev_pt[1];
   		vector1[2] = me->first_pt[2] - me->prev_pt[2];

   		vector2[0] = projpt[0] - me->first_pt[0];
   		vector2[1] = projpt[1] - me->first_pt[1];
   		vector2[2] = projpt[2] - me->first_pt[2];

   		BScrossp ( &rc, vector1, vector2, normal);
   
   		if(( vector1[0] != 0) || ( vector1[1] != 0) || ( vector1[2] != 	0))
   		{
   			free_angle = VRcompute_angle(vector1,vector2,normal);

			/* if we are close to the extend direction we hilite it   */
   			if (free_angle <= unite)
     			{
     				free_angle = 0;
     				VRskdisplay_angle
				( free_angle, me->prev_pt, me->first_pt, projpt, &win_matrix[8]);
     			}

 			/* if we are close to the perpendicular direction we hilite it   */
   			if((free_angle <= ((M_PI/2) + unite)) && (free_angle >= ((M_PI/2) - unite)))
     			{
     				free_angle = M_PI/2;
     				VRskdisplay_angle
				( free_angle, me->prev_pt, me->first_pt, projpt, &win_matrix[8]);
     			}
    		}
   	}

  }

  
  if( me->FirstType == IS_PIPE ) action = 0;
  else
  {
       action = 1;
 
       __DBGpr_obj( " First Located Element Id ", me->FirstLocatedElemId );
 
       /* added by alwin for TR179702549. This additional check prevents the 
       users from sketching in the wrong direction having located a component.
       For example SOLET, TEE, ... say after locating these components the
       dynamics allows extends on both sides of the components whereas only one
       direction is correct. This additional check restricts user from sketching
       in the wrong direction. The same thing couldn't be done for nozzles as
       the inputs we have is few with which we can't restrict, in the case of
       nozzle*/

       if( me->FirstLocatedElemId.objid != NULL_OBJID )
       {
         IGRint NbCpts=0;
         IGRlong retmsg;
         IGRdouble dVectDotProd=0.0, CenterPoint[3];
         IGRdouble Cpts0[3], Cpts1[3], Cptxyz[3], Vector1[3], Vector0[3];
         IGRint Acpt, Thiscpt;
/*
printf("FirstLocatedElemId.objid %ld\n",me->FirstLocatedElemId.objid);
printf("FirstLocatedElemId.osnum %d\n",me->FirstLocatedElemId.osnum); 
*/
         status = 
         om$send ( msg = message VRGeneric.VRGetNumberOfCpts( &retmsg, &NbCpts,
                                               &me->ModuleInfo ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
         as$status ( action = RET_STATUS );
 
         status=
         om$send ( msg = message VRGeneric.VRGetCptGeom
                                       (&retmsg, (IGRshort) 0, Cpts0,
                                              NULL, NULL, &me->ModuleInfo ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
         as$status ( action = RET_STATUS );
           /*** Rewritten for TR179900616 **********/
         if( NbCpts > 2 )
         {
           struct GRid CorId0;
           status=
                om$send ( msg = message VRGeneric.VRGetCptGeom
                                       (&retmsg, (IGRshort) 1, Cpts1,
                                              NULL, NULL, &me->ModuleInfo ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
           as$status ( action = RET_STATUS );
 
           __DBGpr_int( " Nb of Connect Points ", NbCpts );
 
           CenterPoint[0] = ( Cpts0[0] + Cpts1[0] ) / 2.0;
           CenterPoint[1] = ( Cpts0[1] + Cpts1[1] ) / 2.0;
           CenterPoint[2] = ( Cpts0[2] + Cpts1[2] ) / 2.0;

           BSmkvec( &retmsg, Vector1, CenterPoint, projpt );
           BSnorvec( &retmsg, Vector1 );
           Thiscpt = -1;
           for (Acpt = 0; Acpt < NbCpts && Thiscpt < 0; Acpt++)
           {
               struct GRid CorIdoncpt;
               /*Get the Correction Component at Cpt 0 */
               status =
                 om$send ( msg = message VRGeneric.VRGetCorOnCpt( &retmsg,
                               (IGRshort) Acpt, &CorIdoncpt, &me->ModuleInfo ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
               as$status ( action = RET_STATUS );

               /* if no correction at cpt */
               if(CorIdoncpt.objid == NULL_OBJID)
               {
                  __DBGpr_int("CPT has no correction", Acpt);
                  /* Get the Connect point details at Acpt  */
                  om$send ( msg = message VRGeneric.VRGetCptGeom
                                       (&retmsg, (IGRshort) Acpt, Cptxyz,
                                              NULL, NULL, &me->ModuleInfo ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
                  as$status ( action = RET_STATUS );
 

                 /* Get vector to cpt */
                 BSmkvec( &retmsg, Vector0, CenterPoint, Cptxyz);
                 BSnorvec( &retmsg, Vector0 );
                 /* Check if same direction as sketch vector */
                 dVectDotProd = BSdotp(&retmsg, Vector0, Vector1 );
                 if( dVectDotProd > VRGetTol(VR_DOTPROD_TOL) )
                 {
                    Thiscpt = Acpt;
                    __DBGpr_int("CPT is OK",Acpt);
                 }
               }

           }
           if(Thiscpt < 0)
           {
                 ex$message( field   = ERROR_FIELD,
                             in_buff = "Can't sketch in this direction !" );
  
                 *sts = MSFAIL;
	         End
                 return OM_S_SUCCESS;
           }

           else goto Skip_addtional_check;

       }
       else if( NbCpts == 2 ) 
       {
	   IGRint  NbOfTopoPar=0;
           IGRshort nSysType;
	   struct GRid CorId0;
 
           status = om$send ( msg = message VRGeneric.VRGetSysType( 
                                       &retmsg, &nSysType ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
           as$status ( action = RET_STATUS );

	   __DBGpr_int( " Component Type ", nSysType );
 
           if( nSysType == VR_ELBOW ) goto Skip_addtional_check;
           status=
           om$send ( msg = message VRGeneric.VRGetCptGeom
                                       (&retmsg, (IGRshort) 1, Cpts1,
                                              NULL, NULL, &me->ModuleInfo ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
           as$status ( action = RET_STATUS );
  
           /*Get the Correction Component at Cpt 0 */
           status =
           om$send ( msg = message VRGeneric.VRGetCorOnCpt( &retmsg,
                               (IGRshort) 0, &CorId0, &me->ModuleInfo ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
           as$status ( action = RET_STATUS );
	   /********* Had the VRGetSysType method returned the Component's
	   Item Number correctly for all the Components, the following junk
	   of code is not needed...............Alwin */

	   /* Get Topological Nb of Parents, as it is going to help us to find
	   what sought of Component it's. Whether is SOLET( Olet variety ) or 
	   REDUCER. The first condition mentioned below may hold good for both
	   REDUCER's as well as SOLET's. Where as the second condition will
	   ensure that only reducer can enter the if loop*/

	   status = 
	   om$send ( msg = message VRGeneric.VRGetSupports( &retmsg, 
					0, NULL, &NbOfTopoPar ),
                         targetid = me->FirstLocatedElemId.objid,
                         targetos = me->FirstLocatedElemId.osnum );
           as$status ( action = RET_STATUS );
 
           if( ( CorId0.objid != NULL_OBJID ) && ( NbOfTopoPar == 1 ) )
           {
               /*As far I know, this can happen only for the EXPANDER's
               ( i.e CONRED/ECCRED placed as 4 x 6, ). This the only component
               by virtue of the way it's constructed, can have correction at
               the Connect point 1 and can exist without correction at the
               connect point 0. Still there is cache for this, say if user
               places the REDUCER first using the Place Piping Component
               command; and then sketched out from the Bid Dia end it may fail
               again it depends on the orientation with which it is placed. 
	       Alwin for TR179800535 */
__DBGpr_com("should not be here");
               BSmkvec( &retmsg, Vector0, Cpts0, Cpts1 );
               BSnorvec( &retmsg, Vector0 );
           }
           else if( ( CorId0.objid == NULL_OBJID ) && ( NbOfTopoPar == 1 ) )
           {
               BSmkvec( &retmsg, Vector0, Cpts1, Cpts0 );
               BSnorvec( &retmsg, Vector0 );
           }
	   else if( ( CorId0.objid == NULL_OBJID ) && ( NbOfTopoPar == 2 ) )
	   {
	       /* This case is meant only for Olet's */
               BSmkvec( &retmsg, Vector0, Cpts0, Cpts1 );
               BSnorvec( &retmsg, Vector0 );
	   }
	   else goto Skip_addtional_check;

               /* getting vec1 from projpt here */
           BSmkvec( &retmsg, Vector1, Cpts0, projpt );
           BSnorvec( &retmsg, Vector1 );
 
           dVectDotProd = BSdotp(&retmsg, Vector0, Vector1 );
           __DBGpr_dbl( " Vector Product ", dVectDotProd );
       }
       else goto Skip_addtional_check;
  
       /* If the dot product of the two vectors is positive then they're heading
       the same direction. */
       if( dVectDotProd > VRGetTol(VR_DOTPROD_TOL) )
       {

           __DBGpr_com( " Vectors are heading in the same Direction " );
       }
       else 
       {
           __DBGpr_com( " Vectors are heading in the Opposite Directions " );
           ex$message( field   = ERROR_FIELD,
                       in_buff = "Can't sketch in this direction !" );
  
           *sts = MSFAIL;
	   End
           return OM_S_SUCCESS;
       }

     }
  }
Skip_addtional_check:
  status = VRis_next_pt_valid( action, &IsValidPoint, me->prev_pt, me->first_pt, projpt,
			       me->NbOfImpDirection, me->ImpDirForDyn );
  if( status & IS_A_VALID_POINT & IsValidPoint )
  { 
    	/*| is valid */
    	for( index=0; index<3; index++ ) me->next_pt[index] = projpt[index];
    	if( IsValidPoint == IS_AN_EXTEND )
    	{
    		if( me->FirstType == VR_DANGLING )
    		{
    			if( me->ModuleInfo.md_id.osnum == me->FirstLocatedElemMdEnv.md_id.osnum ) me->extend = TRUE;
    			else 
			{
				/*| connection inter OS */
				me->extend = FALSE;
			}
    		}
    		else me->extend = TRUE;
    	}
    	else me->extend = FALSE;

    me->bI_Need_Pick = FALSE;
  }
  else
  {
    ex$message( field   = ERROR_FIELD,
	        in_buff = "Can't sketch in this direction !" );

    *sts = MSFAIL;
  }

  End
  return(OM_S_SUCCESS);
}

/*******************************************************************************
/* 
/* this method is called after each given point to update the DPB last point 
/* and the sketch used event ( event1 ).
/*
/******************************************************************************/

method VRskupdate_event( IGRlong *sts )
{
  IGRlong		retcode, status;
  IGRlong  		Size = sizeof( struct EX_button ),
                	ReturnSize; /* both of these are used for DPB last   */
                                    /* point retrieval                       */
  struct EX_button	LastPoint;  /* from DPB                              */

  SetProc( VRsketch_VRskupdate_event ); Begin
  *sts   = MSSUCC;
  status = OM_S_SUCCESS;

  /* 
   * We need reliable window information from the last point
   */
  gr$get_last_point(  msg    = &retcode,
                      sizbuf = &Size,
                      buffer = &LastPoint,
                      nret   = &ReturnSize );

  /* update the last point in the DPB */
  LastPoint.x = me->first_pt[0];
  LastPoint.y = me->first_pt[1];
  LastPoint.z = me->first_pt[2];

  status =  gr$put_last_point( 	msg = &me->ret,
				sizbuf	= &Size,
				buffer	= ( IGRchar * ) &LastPoint );
  as$status( action = RET_STATUS );
  as$status( sts = me->ret, action = RET_STATUS );

  /* 
   *  Override the subtype and stuff the last end point coordinates
   *  into event1
  */

  Size = ( sizeof( struct GRevent ) - ( 2 * sizeof( IGRint ) ) );
  status = co$build_event( msg          = &retcode,
                           event_nbytes = Size,
                           event        = &me->event1,
                           button       = &LastPoint  );
  as$status( action = RET_STATUS );
  
  /*^
      printf("event1 = %d\n", me->event1.num_id );
      printf("event1 = %f %f %f\n", me->event1.event.button.x,
				    me->event1.event.button.y,
				    me->event1.event.button.z );
  */

  /*| update the flag angle */
  me->AngleFlag = FALSE;

  /*| update the  angle */
  me->Angle = 0;

  End
  return(OM_S_SUCCESS);
}

/*******************************************************************************
/*

  Karine : 7 - 11 - 1991    Angle to have a direction in Skewed mode   

*/
/******************************************************************************/

method VRskgetangle( IGRlong *sts )
{
  IGRint	i;
  IGRlong	rc;
  IGRdouble	vector1[3],vector2[3],normal[3];
  IGRdouble	pt[3];

  SetProc( VRsketch_VRskgetangle ); Begin
  *sts = MSSUCC;


  for (i = 0; i< 3; i++)
  vector1[i] = me->first_pt[i] - me->prev_pt[i];

  if (!me->orthogonal_sketch && !me->AngleFlag  && ((vector1[0] != 0) ||
						    (vector1[1] != 0) ||
						    (vector1[2] != 0)))
  {
  	me->AngleFlag = TRUE;
	FIg_set_state( me->form_ptr, MAINTAIN_SKEW, 0 );
	FIg_erase( me->form_ptr, MAINTAIN_SKEW );

  	if(me->event1.subtype == GRst_DEFAULT)
  	{
  		Cursor_Pos(pt);

  		for(i = 0; i< 3; i++) vector2[i] = pt[i] - me->first_pt[i];
  
  		BScrossp ( &rc, vector1, vector2, normal);

  		me->Angle =  VRcompute_angle(vector1,vector2,normal);
 	}
  	else 
	{
		me->Angle = me->event1.event.value;
	}

	if ( me->Angle > M_PI/2 ) me->Angle = M_PI - me->Angle;
  }

  End 
  return OM_S_SUCCESS;

}

/*******************************************************************************
/*
/* The system calls this method when user gives a distance value to specify 
/* the next point. In this method system determine the next point x,y,z 
/* coordinates.
/* 
/******************************************************************************/

method VRskdelta( IGRlong *sts )
{
  extern Cursor_Pos();

  IGRchar	cstype[MAX_CS_TYPE];       /* type of active_cs               */
  IGRlong        rc;                        /* BS return code                 */
  IGRint	IsValidPoint, action;      /* needed to call is_next_pt_valid */
  IGRlong	status;		           /* return code                     */
  IGRlong	retcode;		           /* return code                     */
  IGRdouble 	lcl_pt[3];                 /* cvt pt to local ref.            */
  IGRdouble 	lcl_first_pt[3];           /* cvt first_pt  to local ref.     */
  IGRdouble 	lcl_next_pt[3];            /* cvt next_pt  to local ref.      */
  IGRdouble  	xabs, yabs, zabs ,pt[3];   /* used to calculate next point    */
  IGRdouble  	absx, absy, absz;          /* used to calculate next point    */
  IGRdouble     projpt[3];                 /* projection of the next point    */
  IGRdouble     tmp_dir[3];                /* projection of the next point    */
  IGRmatrix	ref_matrix;                /* active ref. matrix              */
  IGRmatrix	win_matrix;                /* window matrix                   */
  struct GRid	ref_id;                    /* active ref. GRid                */

  *sts          = MSSUCC;

  if( me->event1.subtype == GRst_DEFAULT )
  {
	*sts = MSFAIL;
	return OM_S_SUCCESS;
  }

  /* get cursor position */
  Cursor_Pos(pt);

  status = om$send( msg        = message IGEgragad.DPinrot( &retcode, win_matrix ),
                    targetid   = me->event1.event.button.objid,
                    targetos   = me->event1.event.button.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( me->AngleFlag ) VRskdisplay_angle( me->Angle, me->prev_pt, me->first_pt, pt, &win_matrix[8] );

  if(!  (me->FirstType==IS_COMP_TO_CONNECT || me->FirstType==IS_NOZZLE
						         || me->FirstType==IS_CONC_COMP) )
  {
    /* we don't start from a nozzle */
    if( !me->orthogonal_sketch )
    {
      /* skewed mode ==> get distance */
      absx = fabs(me->event1.event.value);
      /*" pt      = %f %f %f\n", pt[0], pt[1], pt[2] */
      /*" fst_pt  = %f %f %f\n", me->first_pt[0],me->first_pt[1],me->first_pt[2] */

      /* compute the direction of the next segment */
      BSmkvec(  &rc, tmp_dir, me->first_pt, pt );
      BSnorvec( &rc, tmp_dir );
      /*" tmp_dir = %f %f %f\n", tmp_dir[0], tmp_dir[1], tmp_dir[2] */

      /* upgrade next_pt instance data */
      me->next_pt[0] = absx * tmp_dir[0] + me->first_pt[0];   
      me->next_pt[1] = absx * tmp_dir[1] + me->first_pt[1];   
      me->next_pt[2] = absx * tmp_dir[2] + me->first_pt[2];   
    }
    else
    {
      /* orthogonal mode ==> get the window matrix if me->Zwindow equals NULL */
      if( ! me->ZwindowFlag )
      {
        status = om$send( msg        = message IGEgragad.DPinrot
                                                       ( &retcode, win_matrix ),
                          targetid   = me->event1.event.button.objid,
                          targetos   = me->event1.event.button.osnum );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );

        /*"X_win : %f %f %f\n", win_matrix[0], win_matrix[1], win_matrix[2]  */
        /*"Y_win : %f %f %f\n", win_matrix[4], win_matrix[5], win_matrix[6]  */
        /*"Z_win : %f %f %f\n", win_matrix[8], win_matrix[9], win_matrix[10] */
      }
      else
      {
        /* <Zwindow instance data is set in the dynamic function */
        win_matrix[8]  = me->Z_Window[0];
        win_matrix[9]  = me->Z_Window[1];
        win_matrix[10] = me->Z_Window[2];
      }

      /* project given point */
      VRget_project_pt( me->first_pt, pt, projpt, &win_matrix[8], NULL );
      pt[0] = projpt[0]; pt[1] = projpt[1]; pt[2] = projpt[2];

      /* get first and next point in the active cs */
      status = VRskget_active_cs( NULL, &ref_id, ref_matrix, cstype );
      as$status( action = RET_STATUS );

      /*| get first_pt in active_CS */
      status = om$send( msg      = message GRcoords.GRcvt_to_lcl_coords
                                   ( &retcode, cstype, 1, me->first_pt, lcl_first_pt ),
                        targetid = ref_id.objid,
                        targetos = ref_id.osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
      /*"lcl_first = %f %f %f\n",lcl_first_pt[0],lcl_first_pt[1],lcl_first_pt[2] */

      /*| get pt in active_CS */
      status = om$send( msg      = message GRcoords.GRcvt_to_lcl_coords
                                   ( &retcode, cstype, 1, pt, lcl_pt ),
                        targetid = ref_id.objid,
                        targetos = ref_id.osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
      /*"lcl_pt = %f %f %f\n",lcl_pt[0],lcl_pt[1],lcl_pt[2] */

      /* initialize  lcl_next_pt to lcl_first_pt point */
      lcl_next_pt[0] = lcl_first_pt[0];
      lcl_next_pt[1] = lcl_first_pt[1];
      lcl_next_pt[2] = lcl_first_pt[2];

      /* calculate the direction vector */
      xabs = lcl_pt[0] - lcl_first_pt[0];
      yabs = lcl_pt[1] - lcl_first_pt[1];
      zabs = lcl_pt[2] - lcl_first_pt[2];

      /* get absolute values of direction vector coords. */
      absx = fabs(xabs); absy = fabs(yabs); absz = fabs(zabs);
      /*" absx = %E, absy = %E, absz = %E\n", absx, absy, absz */

      if( absx >= absy && absx >= absz )
      {
        if( absx < VRGetTol(VR_DIST_TOL) ) goto warup;
        /* given distance is along X axis */
        lcl_next_pt[0] = lcl_first_pt[0] + xabs * me->event1.event.value/absx;
      }
      else if( absy >= absx && absy >= absz )
      {
        if( absy < VRGetTol(VR_DIST_TOL) ) goto warup;
        /* given distance is along Y axis */
        lcl_next_pt[1] = lcl_first_pt[1] + yabs * me->event1.event.value/absy;
      }
      else
      {
        if( absz < VRGetTol(VR_DIST_TOL) ) goto warup;
        /* given distance is along Z axis */
        lcl_next_pt[2] = lcl_first_pt[2] +  zabs * me->event1.event.value/absz;   
      }

      /*"next pt = %f %f %f\n", lcl_next_pt[0],lcl_next_pt[1],lcl_next_pt[2] */

      /*| get next_pt in Word_CS */
      status = om$send( msg      = message GRcoords.GRcvt_to_wld_coords
                                   ( &retcode, cstype, 1, lcl_next_pt, me->next_pt ),
                        targetid = ref_id.objid,
                        targetos = ref_id.osnum );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
    }
  }
  else
  {
    absx = fabs(me->event1.event.value);

    me->next_pt[0] = absx * me->ImpDirForDyn[0] + me->first_pt[0];
    me->next_pt[1] = absx * me->ImpDirForDyn[1] + me->first_pt[1];
    me->next_pt[2] = absx * me->ImpDirForDyn[2] + me->first_pt[2];
  }

  /*"next pt = %f %f %f\n", me->next_pt[0],me->next_pt[1],me->next_pt[2] */

  /* call VRis_next_pt_valid */
  if( me->FirstType == IS_PIPE ) action = 0;
  else				 action = 1;
  status = VRis_next_pt_valid
           ( action, &IsValidPoint, me->prev_pt, me->first_pt, me->next_pt,
             me->NbOfImpDirection, me->ImpDirForDyn);

  if( status & IS_A_VALID_POINT & IsValidPoint )
  { 
    /*| is valid */
    if( IsValidPoint == IS_AN_EXTEND ) me->extend = TRUE;
    else                               me->extend = FALSE;

    me->bI_Need_Pick = FALSE;

    return OM_S_SUCCESS;
  }

warup:  ex$message( field   = ERROR_FIELD,
	            in_buff = "Can't sketch in this direction !" );
        *sts = MSFAIL;

  return OM_S_SUCCESS;
}


/*******************************************************************************
/*
/* System calls this method to finishs correctly current network by placing a 
/* dangling at the end if neccessary, reset used instance data, and change all 
/* creating segments proprieties. 
/* NB: during the sketch creating segment are not locatable.
/* 
/******************************************************************************/

method VRskendline( IGRlong *sts )
{
  IGRlong			status;            /* return code             */

  SetProc( Md VRskendline ); Begin 
  *sts = MSSUCC;

  /* nothing to do */
  if( !me->num_of_seg ) return OM_S_SUCCESS;

  status = om$send( msg      = message VRsketch.VRSkPlaceEndDangling( sts ),
                    targetid = my_id );
  as$status();
  as$status( sts = *sts );

  status = om$send( msg      = message VRsketch.VRSkEndLineRoute( sts ),
                    targetid = my_id );
  as$status();
  as$status( sts = *sts );
  End
  return(OM_S_SUCCESS);
}

/*******************************************************************************
/*
/* System calls this method to finishs correctly current network by placing a 
/* dangling at the end if neccessary
/*
/******************************************************************************/

method VRSkPlaceEndDangling( IGRlong *sts )
{
  IGRint			status=OM_S_SUCCESS;/* return code             */
  IGRlong			retcode;           /* return code             */
  struct VRTopo			Topo;
  SetProc( Md VRVRSkPlaceEndDangling ); Begin 

  *sts = MSSUCC;

  if( me->prev_seg_id.objid != NULL_OBJID && me->PlaceDangling )
  {
  	/* get active parameters to create a dangling if necessary and to update   */
  	/* buffer_param                                                            */

        status = VR$GetAttributes( 	p_retmsg	= &retcode,
				     	Product		= me->Product,
					p_SysParamId	= &me->ActParamId,
					p_UserParamId	= &me->UsrParamId,
 					p_MdEnv		= &me->ModuleInfo );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );

       	/* create dangling at the end of me->prev_seg_id ( last creating segment ),
       	/* create correction entity and update the constrain length ( segment )
       	/**/

	Topo.SegId	= me->prev_seg_id;
	Topo.nEndPoint 	= ( me->CmpPosition == BEGIN_OF_SEG ) ? 0 : 1;

    	if( me->Product == VR_PIPING ) Topo.pd3Width = NULL;
    	else
    	{
      		if( me->twist_orient ) Topo.pd3Width = &me->section_matrix[6];
      		else                   Topo.pd3Width = &me->section_matrix[3]; 
    	}

	ACget_def_NVrep(&me->cRep,&me->Symb);
	me->Symb.display_attr 	= me->ActiveDisplay;
	me->Symb.level		= me->ActiveLevel;
        /* TR179801939 carry the tier data from a previous component */
        if( ( me->Product == VR_RWAY) && ( me->shape_gadget == RW_R_SHAPE ) )
        {
          IGRint FootIndex=-1, intmsg, NbAttr;
          IGRdouble no_tier1, spacing_tier1;
          struct ret_struct TmpParam;
          struct ACrg_coll  NewListAttr[300]; /* modified for CR179900491 */
          IGRshort mycpt;
          IGRvector my_vect;
          IGRint Idum;
          IGRint no_comps = 1;
          struct GRid CmpId;
          struct GRid ParamId[3];
          IGRchar no_tier_str[20],sp_tier_str[20];
          IGRint not_found;
          IGRint coll;
          __DBGpr_obj("prev_seg_id ", me->prev_seg_id);
           __DBGpr_vec("prevpt ",me->prev_pt);
           __DBGpr_vec("firstpt ",me->first_pt);
           __DBGpr_vec("nextpt ",me->next_pt);

          BSmkvec( &retcode,my_vect,me->prev_pt,me->first_pt );
          BSnorvec( &retcode,my_vect);
           __DBGpr_vec("myvect ",my_vect);

          status = om$send( msg     = message VRCnrlSeg.VRget_terminators
                      ( &retcode, &no_comps, &me->ModuleInfo, NULL, &CmpId ),
               targetid = me->prev_seg_id.objid,
               targetos = me->prev_seg_id.osnum);
           __DBGpr_obj("Prev comp ",CmpId);
          status = om$send( msg      = message VRGeneric.VRSelectCptByGeom
                   (&retcode, me->prev_pt,my_vect,&mycpt, &me->ModuleInfo),
               senderid = NULL_OBJID,
               targetid = CmpId.objid,
               targetos = CmpId.osnum);
          Idum = (IGRint) mycpt;
           __DBGpr_int("prev cpt ", Idum);

          Idum++;

         status = om$send ( msg = message VRGeneric.VRGetParams(&retcode,
                                &ParamId[0], &ParamId[1], &ParamId[2] ),
               senderid = NULL_OBJID,
               targetid = CmpId.objid,
               targetos = CmpId.osnum);
          /* CR179900491 */
          /*** dynamic depth - this section needs rewritting *********/
          /*** The problem with the old approach is that it assumes that all
data relating to a cpt is defined in the same params block and that the new
data is to be stored in the same param block */
          /*** May need to use local cptdata here */
                 __DBGpr_com("VRSkPlaceEndDangling call VRRw_loc_dimen_fields");
                 me->active_cpt = 1;
                 status = VRRw_loc_dimen_fields(&me->ModuleInfo,
                                   CmpId, 2,
                                   mycpt, NULL,
                                   VR_RECT, me->RWcptdata,
                                   &me->ActParamId );
__DBGpr_obj("CmpId ",CmpId);
__DBGpr_int("cptndx ",mycpt);
__DBGpr_dbl("instance.width ",me->RWcptdata[0].width);
__DBGpr_dbl("instance.depth ",me->RWcptdata[0].depth);
__DBGpr_int("instance.no_tier ",me->RWcptdata[0].nb_tier);
        }
__DBGpr_com("PlaceAutoComponent");
	status =
	VR$PlaceAutoComponent (
			p_lMsg 	= &retcode,
			Product	= me->Product,
			p_CmpId	= &me->CmpId,
			bDisplay= TRUE,
			p_SysId	= &me->ActParamId,
			p_UsrId	= &me->UsrParamId,
			NbTopo	= 1,
			p_Topo	= &Topo,
			p_Symb	= &me->Symb,
			cRep	= me->cRep,
			p_MdEnv	= &me->ModuleInfo );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
  }
  End
  return OM_S_SUCCESS;
}
/*******************************************************************************
/*
/* System calls this method to reset used instance data, and change all 
/* creating segments proprieties.
/* NB: during the sketch creating segment are not locatable.
/*
/******************************************************************************/

method VRSkEndLineRoute( IGRlong *sts )
{
  IGRlong			status;            /* return code             */
  IGRlong			retcode;           /* return code             */
  IGRint			i;                 /* loop index              */
  IGRshort			mask;              /* used by chgprops        */
  IGRshort			action;            /* used by chgprops        */
  IGRboolean			EvalConst;         /* used to chg seg. state  */

  SetProc( VRsketch_VRSkEndLineRoute ); Begin
  if( me->prev_seg_id.objid != NULL_OBJID && me->PlaceDangling
						  && me->FirstType != IS_PIPE )
  {
	/*| Compute correction */
  	status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
 					p_SegmentId	= &me->prev_seg_id,
 					p_MdEnv		= &me->ModuleInfo );
    	as$status();
    	as$status( sts = retcode );

    	status = VRChangeSegLength( 1, FALSE, &me->prev_seg_id, &me->ModuleInfo );
    	as$status();
  }

  /* update all the CnrlSegs state */

  mask   = GRIS_LOCATABLE;
  action = 1;
  for( i=0; i<me->num_of_seg; i++ )
  {
    /* change them to locatable */

    status = om$send(msg      = message GRvg.GRchgprops(&retcode,&action,&mask),
                     targetid = me->seg_GRid[i].objid,
                     targetos = me->seg_GRid[i].osnum);
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    /* change their constrain value state */

    EvalConst = TRUE;

    status = om$send( msg      = message VRCnrlSeg.VRChgSegState( VR_UNKNOWN, VR_EVALUATE_CONST ),
                      targetid = me->seg_GRid[i].objid,
                      targetos = me->seg_GRid[i].osnum);
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }

  End
  return(OM_S_SUCCESS);
}

/*******************************************************************************
/*
/* This method is called when user locates an elbow, to get the primary and
/* secondary Tee segments, deponding of the direction given by the user
/*
/******************************************************************************/

method VRSkGetElbowPrevSeg( IGRlong 		*sts;
  			    struct	GRid	*LocatedElbowId;
                            struct 	GRid 	*ElbowPriSegId;
                            struct	GRid	*ElbowSecSegId )
{
  BSrc				bsretcode;     /* math. func. return code    */
  IGRint			NbSupports;	/* nb of supports            */
  IGRlong			status;        	/* return code               */
  IGRlong			retcode;	/* return code               */
  IGRdouble			scalar;
  IGRdouble			TmpVect[3];
  struct	GRid		ElbowSupportId[2];
  struct	ret_struct	SegRetStruct;

  *sts = MSSUCC;

  /* Get Elbow supports */
  status = om$send( msg = message VRGeneric.VRGetSupports
                          ( &retcode, 2, ElbowSupportId, &NbSupports ),
                    targetid = LocatedElbowId->objid, 
                    targetos = LocatedElbowId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
  /*"nb_of_support = %d\n", NbSupports */

  /* get support 1 direction vector */
  status = om$send( msg = message NDnode.NDgive_structure
                                  ( &retcode, &SegRetStruct, &me->ModuleInfo ),
                    targetid = ElbowSupportId[0].objid, 
                    targetos = ElbowSupportId[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
   
  /*^
      printf("SegVect = \t\t%f %f %f\n", SegRetStruct.var.line_st.v0[0],
                                     SegRetStruct.var.line_st.v0[1],
                                     SegRetStruct.var.line_st.v0[2]  );
  */

  /* calculate the user given direction */
  BSmkvec( &bsretcode, TmpVect, me->first_pt, me->next_pt );
  BSnorvec( &bsretcode, TmpVect );
  /*"TmpVect = %f %f %f\n", TmpVect[0], TmpVect[1], TmpVect[2] */

  /* get primary and secondary Tee supports */
  scalar = BSdotp( &bsretcode, SegRetStruct.var.line_st.v0, TmpVect );
  /*"scalar = %f\n", scalar */

  if( 1 - fabs( scalar ) < VRGetTol(VR_DOTPROD_TOL) )
  {
    /* support 1 direction and user given direction are parallel ==> primary
    /* axis is support 1
    /**/
    *ElbowPriSegId = ElbowSupportId[0];
    *ElbowSecSegId = ElbowSupportId[1];
  }
  else
  {
    /* support 2 direction and user given direction are parallel ==> primary
    /* axis is support 2
    /**/    
    *ElbowPriSegId = ElbowSupportId[1];
    *ElbowSecSegId = ElbowSupportId[0];
  }

  /*"ElbowPriSegId = %d\n", ElbowPriSegId->objid */
  /*"ElbowSecSegId = %d\n", ElbowSecSegId->objid */

  return OM_S_SUCCESS;
}


/*******************************************************************************
/*
/* This method is called to get located elbow information
/* 
/******************************************************************************/

method VRSkGetElbowInfo( IGRlong *sts )
{
  IGRshort		mask;      /* used by chgprops               */
  IGRshort		action;    /* used by chgprops               */
  IGRshort		CmpIndex;  /* cmp index                      */
  IGRlong		status, retcode;

  SetProc( Md VRSkGetElbowInfo ); Begin 
  *sts    = MSSUCC;
  status  = OM_S_SUCCESS;
  retcode = OM_S_SUCCESS;

  /* when user locates an elbow to start from or to connect to, the system 
  /* replace this elbow by a tee. to get primary and secondary of the Tee
  /* we call VRSkGetElbowPrevSeg method
  /**/
  status = om$send( msg      = message VRsketch.VRSkGetElbowPrevSeg
                               ( &retcode, &me->FirstLocatedElemId,
                                 &me->prev_seg_id, &me->ElbowSecSegId
                               ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
  /*"ElbowPriSegId = %d\n", me->prev_seg_id.objid */
  /*"ElbowSecSegId = %d\n", me->ElbowSecSegId.objid */

  /* Tee attributes are getting fron elbow connect points */
  status = VRSkGetAttrFromCmp
           ( me->Product, &me->ActParamId, &me->BufParamId, &me->UsrParamId,
             &me->FirstLocatedElemId, &me->ElbowSecSegId, &me->prev_seg_id,
             &me->ModuleInfo
           );
  as$status( action = RET_STATUS );

  /*^ VRprint_user_attr( &me->ActParamId ); */
  /*^ VRprint_user_attr( &me->BufParamId ); */

  /* Change temporary the primary segment ( me->prev_seg_id ) to no locatable */
  mask   = GRIS_LOCATABLE;
  action = 0;
  status = om$send(msg      = message GRvg.GRchgprops
                                           ( &retcode, &action, &mask ),
                   targetid = me->prev_seg_id.objid,
                   targetos = me->prev_seg_id.osnum);
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /* update seg_GRid table and num_of_seg by adding primary axis */
  me->seg_GRid[0] = me->prev_seg_id;
  me->num_of_seg = 1;
  /*"me->seg_GRid[0] = %d\n", me->seg_GRid[0].objid */
  /*"num_of_seg      = %d\n", me->num_of_seg */

  /* Get elbow index on its primary segment */
  status = om$send(msg      = message VRGeneric.VRGetIndex
                              ( &retcode, &me->prev_seg_id, &CmpIndex ),
                   targetid = me->FirstLocatedElemId.objid,
                   targetos = me->FirstLocatedElemId.osnum);
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /* upgrade me->CmpPosition */
  if( ! CmpIndex ) me->CmpPosition = BEGIN_OF_SEG;

  if( me->Product != VR_PIPING )
  {
    	/* upgrade section matrix if product is not piping */
	status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_InPutSection	= me->section_matrix,
					p_StartPt	= me->first_pt,
					p_EndPt		= me->next_pt,
					p_OutPutSection	= me->section_matrix );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );
  }
  End
  return OM_S_SUCCESS;

}

/*******************************************************************************
/*
/*  This method resets the instances for no specified direction */
/*
/******************************************************************************/

method VRskdelangle( IGRlong *sts )
{
  *sts = MSSUCC;

  me->AngleFlag = FALSE;
  FIg_set_state( me->form_ptr, MAINTAIN_SKEW, 0 );
  me->Angle = 0;

  return(OM_S_SUCCESS);
}

/*******************************************************************************
/*
/* This method is called to delete the last segment and update topology and the
/* internal construction graph.
/*
/******************************************************************************/

method VRskdelseg( IGRlong *sts )
{
  IGRshort 			CmpCptNum;     /* */
  IGRint 			nb_cmp;        /* used by get_terminators     */
  IGRlong 			retcode;       /* return error                */
  IGRlong 			status;        /* return error                */
  IGRdouble 			cmp_pt[6];     /* used by get_terminators     */
  struct 	GRid 		cmp_id[2];     /* used by get_terminators     */
  struct 	GRid 		segment_to_delete;
                                               /* segment to delete GRid      */
  struct	GRid		MyCorId;       /* deleted segment correction  */



  *sts = MSSUCC;

  /*"FirstType  = %d\n", me->FirstType  */
  /*"num_of_seg = %d\n", me->num_of_seg */

  if( me->FirstType == IS_COMP_TO_CONNECT || me->FirstType == IS_CONC_COMP )
  {
    /*" me->CmpFirstType = %d\n", me->CmpFirstType */

    if( !me->num_of_seg )
    {
	/*| connect component has been located */
	return OM_S_SUCCESS;
    }

    /*| delete last component placed by aabbcc code */

    status = om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, &me->ModuleInfo ),
                      targetid = me->FirstLocatedElemId.objid, 
                      targetos = me->FirstLocatedElemId.osnum  );
    as$status();

    if( me->CmpFirstType == IS_PIPE && !me->num_of_seg )
    {
    	/* let next state to be start state */
    	*sts = NO_PREVIOUS_SEG;
  	
	/* delete current segment */
  	status = om$send( msg      = message GRgraphics.GRdelete
						( &retcode, &me->ModuleInfo ),
    	            	  targetid = me->FirstLocatedElemId.objid, 
	            	  targetos = me->FirstLocatedElemId.osnum );
  	as$status();
  	as$status( sts = retcode );

	return OM_S_SUCCESS;
    }

    /* get correction to undisplay and delete it */
    status = om$send( msg      = message VRGeneric.VRGetCorrections
                                                ( &retcode, 1, &MyCorId, &nb_cmp ),
  	              targetid = me->FirstLocatedElemId.objid, 
	              targetos = me->FirstLocatedElemId.osnum);
    as$status( action = RET_STATUS );

    status = om$send( msg      = message NDnode.NDdisplay
                                         ( 0, GRbehe, &me->ModuleInfo ),
                      targetid = MyCorId.objid, 
                      targetos = MyCorId.osnum  );
    as$status();
    status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
                      targetid = MyCorId.objid, 
                      targetos = MyCorId.osnum  );
    as$status();

    status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
     	              targetid = me->FirstLocatedElemId.objid, 
                      targetos = me->FirstLocatedElemId.osnum);
    as$status();

    me->prev_seg_id = me->seg_GRid[me->num_of_seg-1];
    /*"new prev_seg id = %d\n", me->prev_seg_id.objid */

    if( me->CmpFirstType == IS_DANGLING && me->num_of_seg == 1 )
    {
    	/* let next state to be start state */
    	_put_response(resp = EX_RJT_MOVEON);

	me->PlaceDangling = TRUE;

	return OM_S_SUCCESS;
    }

    status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, &me->ModuleInfo ),
                      targetid = me->prev_seg_id.objid, 
                      targetos = me->prev_seg_id.osnum  );
    as$status();

    status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                                 ( &retcode, &nb_cmp, &me->ModuleInfo, cmp_pt, cmp_id ),
                       targetid = me->prev_seg_id.objid,
                       targetos = me->prev_seg_id.osnum);
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    me->first_pt[0] = cmp_pt[3];
    me->first_pt[1] = cmp_pt[4];
    me->first_pt[2] = cmp_pt[5];

    me->prev_pt[0] = cmp_pt[0];
    me->prev_pt[1] = cmp_pt[1];
    me->prev_pt[2] = cmp_pt[2];
/*
printf("firstpt %f %f %f\n",me->first_pt[0],me->first_pt[1],me->first_pt[2]);
printf("prevpt %f %f %f\n",me->prev_pt[0],me->prev_pt[1],me->prev_pt[2]);
*/    
    me->NbOfImpDirection = 0;

    /*| Retrieve user attributes from last component */
    if( me->Product == VR_PIPING )
    {
      status = VR$GetCmpAttributes( 	p_retmsg	= &retcode,
				     	Product		= me->Product,
					p_ComponentId	= &cmp_id[0],
					p_SysParamId	= &me->ActParamId,
					p_UserParamId	= &me->UsrParamId,
					p_MdEnv		= &me->ModuleInfo );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
    }
    else
    {
      IGRdouble			TmpValue;
      union	VRparam_attr	ActParam;

      /*| HVAC or CABLING */

      /* remove twist */
      if( me->twist_orient ) me->twist_orient = FALSE;
      me->twist_save = me->twist_orient;

      status = VRSkGetAttrFromCmp
               ( me->Product, &me->ActParamId, NULL, &me->UsrParamId,
                 &cmp_id[0], &me->prev_seg_id, NULL, &me->ModuleInfo
               );
      as$status( action = RET_STATUS );

      /*| get dimension attributes */
      status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
				     		Product		  = me->Product,
						p_SysCollectionId = &me->ActParamId,
						p_DimAttributes   = &ActParam,
						p_MdEnv		  = &me->ModuleInfo );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      /*| get cpt on sup */
      status = om$send( msg      = message VRGeneric.VRGetCptOnSup
			           ( &retcode, &me->prev_seg_id, &CmpCptNum, &me->ModuleInfo ),
		        targetid = cmp_id[0].objid,
		 	targetos = cmp_id[0].osnum );
      as$status();

      /*| Modify section */
      status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_ComponentId	= &cmp_id[0],
					CmpCptNum	= CmpCptNum,
					p_OutPutSection	= me->section_matrix,
					p_MdEnv		= &me->ModuleInfo );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      /*"G_width = %f\n", ActParam.hvac_attr.G_width */
      /*"G_depth = %f\n", ActParam.hvac_attr.G_depth */

      if( ActParam.hvac_attr.G_width < ActParam.hvac_attr.G_depth )
      {
		TmpValue = me->section_matrix[3];
		me->section_matrix[3] = me->section_matrix[6];
		me->section_matrix[6] = TmpValue;

		TmpValue = me->section_matrix[4];
		me->section_matrix[4] = me->section_matrix[7];
		me->section_matrix[7] = TmpValue;

		TmpValue = me->section_matrix[5];
		me->section_matrix[5] = me->section_matrix[8];
		me->section_matrix[8] = TmpValue;
      }

      /* The G_width must be >= then G_depth */
      status = VRSkUpdateParams( me->Product, &me->ActParamId, &me->ActParamId,
                                 NULL, &me->ModuleInfo );
      as$status();
    }              

    /*| update attributes and the form */
    me->BufParamId = me->ActParamId;
    VR$active_params( operation    = VR_REPLACE,
                      VRproduct    = me->Product,
                      update_flag  = VR_UPDATE,
                      act_param_id = &me->ActParamId,
    	              status       = retcode             );
    /* CR179900491 */
    __DBGpr_com("Call2 for VRSkUpdateForm");
    status = VRSkUpdateForm( me->Product, me->form_ptr, &me->shape_gadget,
			     &me->ActParamId, me->CmpAABBCCcode,
                             &me->active_cpt, me->RWcptdata,
                             &me->ModuleInfo, VR_AUTOMATIQUE );
    __DBGpr_com("back from VRSkUpdateForm");
    as$status();

    VR$active_params( operation    = VR_REPLACE,
                      VRproduct    = me->Product,
                      mode         = VR_USER_MODE,
                      update_flag  = VR_UPDATE,
                      act_param_id = &me->UsrParamId,
    	              status       = retcode             );

    status = om$send( msg      = message VRsketch.VRSkPartialInitInst( &retcode ),
                      targetid = my_id );
    as$status( action = RET_STATUS );

    me->FirstType = FREE_SPACE;
    me->FirstLocatedElemId.objid = NULL_OBJID;

    return OM_S_SUCCESS;
  }

  /* we just start, nothing to delete */
  if( me->FirstType != FREE_SPACE || !me->num_of_seg )
  {
	*sts = NO_PREVIOUS_SEG;
	return(OM_S_SUCCESS);
  }

  /* set segment_to_delete variable */
  segment_to_delete = me->prev_seg_id;
  /*"delete cs id = %d\n", segment_to_delete.objid */

  status = om$send( msg      = message NDnode.NDdisplay( 0,
                                                         GRbehe,
                                                         &me->ModuleInfo ),
                    targetid = segment_to_delete.objid, 
                    targetos = segment_to_delete.osnum);
  as$status();

  /* we started from a dangling or ..., and we reach the last segment */
  if( ! ( --me->num_of_seg ) || ( ( me->CmpFirstType == IS_DANGLING ||
                                    me->CmpFirstType == IS_ELBOW ) && me->num_of_seg == 1 )
                             || ( ( me->CmpFirstType == IS_CONC_COMP ||
                                    me->CmpFirstType == IS_COMP_TO_CONNECT ) && me->num_of_seg == 0 )
    )
  {
__DBGpr_com("started from a dangling and reached the last segment");
    /*| last segment of the current line */
    me->prev_seg_id.objid = NULL_OBJID;

    /*| let next state to be start state */
    *sts = NO_PREVIOUS_SEG;

    status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                                 ( &retcode, &nb_cmp, &me->ModuleInfo, NULL, cmp_id ),
                      targetid = segment_to_delete.objid,
                      targetos = segment_to_delete.osnum  );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
    /*"nb_cmp = %d .... cmp_id = %d\n", nb_cmp, cmp_id[0].objid */

    if( me->CmpFirstType == IS_CONC_COMP || me->CmpFirstType == IS_COMP_TO_CONNECT
				         || me->CmpFirstType == IS_DANGLING_TO_CONNECT )
    {
      GRclassid			p_classid;
      extern    GRclassid       OPP_VRCptIn_class_id;
      if( me->CmpFirstType != IS_DANGLING_TO_CONNECT )
      {
      		/*| disconnect component from segment */
      		status = om$send( msg      = message VRGeneric.VRDisconnect
						   ( &retcode, &segment_to_delete, &me->ModuleInfo ),
				  targetid = cmp_id[0].objid,
				  targetos = cmp_id[0].osnum );
      		as$status();
      }

      /*| delete last segment */
      status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
       	                targetid = segment_to_delete.objid, 
                        targetos = segment_to_delete.osnum);
      as$status();

      /*C       Deleting VRCptIn if there is a connection across OS     */
      /*C       TR# 179311285.                                          */

      status =
	om$get_classid( osnum = cmp_id[0].osnum,
			objid = cmp_id[0].objid,
			p_classid = &p_classid );

        if (((om$is_ancestry_valid( subclassid = p_classid,
				superclassid = OPP_VRCptIn_class_id))
				== OM_S_SUCCESS ))
	{
		status = om$send( msg = message NDnode.NDdelete( &me->ModuleInfo),
					targetid = cmp_id[0].objid,
					targetos = cmp_id[0].osnum);
		as$status();
	}
      return OM_S_SUCCESS;
    }

    if( me->CmpFirstType != IS_NOZZLE )
    {
    	status = om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, &me->ModuleInfo ),
                          targetid = cmp_id[0].objid, 
                          targetos = cmp_id[0].osnum  );
    	as$status();
    }

    if( me->CmpFirstType == IS_ELBOW ) 
    {
      /* if user started from an elbow ==> replace the Tee by an elbow */
      status = VRSkReplaceTeeByElbow
               ( me->Product, &cmp_id[0], &me->ModuleInfo, &me->cmp_const_list );
      as$status( action = RET_STATUS );
 
      /* delete last segment */
      status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
       	                targetid = segment_to_delete.objid, 
                        targetos = segment_to_delete.osnum);
      as$status();

      return OM_S_SUCCESS;
    }
  }
  else
  {
    /* update the previous segment */
    me->prev_seg_id = me->seg_GRid[me->num_of_seg-1];
    /*"new prev_seg id = %d\n", me->prev_seg_id.objid */

    /* get terminators to delete the last elbow and to update instance.   */
    /* We are sending NDdelete to the elbow beford deleting the segment   */
    /* to miss the placement of a dangling when the elbow notify previous */
    /* segment about disconnexion                                         */
     status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                                  ( &retcode, &nb_cmp, &me->ModuleInfo, cmp_pt,
                                    cmp_id
                                  ),
                       targetid = me->prev_seg_id.objid,
                       targetos = me->prev_seg_id.osnum);
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    /*"nb_cmp = %d\n", nb_cmp */
    /*"cmp_pt0 = %f %f %f\n", cmp_pt[0],cmp_pt[1],cmp_pt[2] */
    /*"cmp_pt1 = %f %f %f\n", cmp_pt[3],cmp_pt[4],cmp_pt[5] */
    /*"cmp_id  = %d %d\n", cmp_id[0].objid, cmp_id[1].objid */

    /* undisplay previous segment end component and its correction */
    status = om$send( msg      = message NDnode.NDdisplay
                                 ( 0, GRbehe, &me->ModuleInfo ),
                      targetid = cmp_id[1].objid, 
                      targetos = cmp_id[1].osnum  );
    as$status();

    /* get correction to undisplay and delete it */
    status = om$send( msg      = message VRGeneric.VRGetCorrections
                                                ( &retcode, 1, &MyCorId, &nb_cmp ),
  	              targetid = cmp_id[1].objid, 
	              targetos = cmp_id[1].osnum);
    as$status( action = RET_STATUS );

    status = om$send( msg      = message NDnode.NDdisplay
                                         ( 0, GRbehe, &me->ModuleInfo ),
                      targetid = MyCorId.objid, 
                      targetos = MyCorId.osnum  );
    as$status();

    status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
                      targetid = MyCorId.objid, 
                      targetos = MyCorId.osnum  );
    as$status();

    status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
  	              targetid = cmp_id[1].objid, 
	              targetos = cmp_id[1].osnum);
    as$status();

    /* display the new previous segment */
    status = om$send( msg      = message NDnode.NDdisplay
                                                ( 0, GRbd, &me->ModuleInfo ),
                      targetid = me->prev_seg_id.objid, 
                      targetos = me->prev_seg_id.osnum  );
    as$status();

    /*| update the plane to move if extend */
    status = om$send( msg = message VRCnrlSeg.VRget_planes
                            ( &retcode, NULL, NULL, NULL, &me->plane_to_move_id ),
                      targetid = me->prev_seg_id.objid, 
                      targetos = me->prev_seg_id.osnum);
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    /*"plane_to_move = %d\n",me->plane_to_move_id.objid */ 

    /*| See if constrain between deleted segment and new previous one */
 
    {
      IGRint		i, NbChild;
      GRclassid		ClassId;
      struct	GRid	*p_Child=NULL;

      extern GRclassid OPP_VRcompoint_class_id;

      status = om$send( msg      = message NDnode.NDget_objects
                                   ( ND_CHILDREN, NULL, 0, NULL, 0, OM_K_MAXINT, &NbChild ),
  		        targetid = me->plane_to_move_id.objid,
		        targetos = me->plane_to_move_id.osnum ) ;
      as$status( action = GOTO_VALUE, value  = wrapup ) ;

      /*"Number of child : %d\n", NbChild */

      p_Child = _CALLOC( NbChild, struct GRid );

      if( ! p_Child ) as$status( sts = OM_E_NODYNMEM, action = RET_STATUS );

      status = om$send( msg      = message NDnode.NDget_objects
                                   ( ND_CHILDREN, p_Child, NbChild, NULL, 0,OM_K_MAXINT,
 	  			     &NbChild ),
		        targetid = me->plane_to_move_id.objid,
		        targetos = me->plane_to_move_id.osnum );
      as$status( action = GOTO_VALUE, value = wrapup ) ;

      /* get just constrain child */

      /*"Number of child : %d\n", NbChild */

      for( i=0; i<NbChild; i++ )
      {
        /*"children %d : %d %d\n", i, p_Child[i].objid, p_Child[i].osnum */

        status = om$get_classid( objid     = p_Child[i].objid,
  			         osnum     = p_Child[i].osnum,
			         p_classid = &ClassId ) ;
        as$status( action = GOTO_VALUE, value  = wrapup ) ;

	/*"ClassId = %d\n", ClassId */

        if( om$is_ancestry_valid
            ( subclassid   = ClassId,
              superclassid = OPP_VRcompoint_class_id ) == OM_S_SUCCESS )
        {
          /*| delete constrain */

          status = om$send( msg      = message NDnode.NDdelete( &me->ModuleInfo ),
     	                    targetid = p_Child[i].objid, 
	                    targetos = p_Child[i].osnum );
          as$status();
        }
      }

      /*| Free memory */
      wrapup : if( p_Child ) _FREE( p_Child );

    }

    /*| Retrieve user attributs from last component */
    if( me->Product == VR_PIPING )
    {
      status = VR$GetCmpAttributes( 	p_retmsg	= &retcode,
				     	Product		= me->Product,
					p_ComponentId	= &cmp_id[0],
					p_SysParamId	= &me->ActParamId,
					p_UserParamId	= &me->UsrParamId,
					p_MdEnv		= &me->ModuleInfo );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
    }
    else
    {
      IGRdouble			TmpValue;
      union	VRparam_attr	ActParam;

      /*| HVAC or CABLING */

      /* remove twist */
      if( me->twist_orient ) me->twist_orient = FALSE;
      me->twist_save = me->twist_orient;

      status = VRSkGetAttrFromCmp
               ( me->Product, &me->ActParamId, NULL, &me->UsrParamId,
                 &cmp_id[0], &me->prev_seg_id, NULL, &me->ModuleInfo
               );
      as$status();

      /*| get dimension attributes */
      status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
				     		Product		  = me->Product,
						p_SysCollectionId = &me->ActParamId,
						p_DimAttributes   = &ActParam,
						p_MdEnv		  = &me->ModuleInfo );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      /*"G_width = %f\n", ActParam.hvac_attr.G_width */
      /*"G_depth = %f\n", ActParam.hvac_attr.G_depth */

      status = om$send( msg      = message VRGeneric.VRGetCptOnSup
			           ( &retcode, &me->prev_seg_id, &CmpCptNum, &me->ModuleInfo ),
		        targetid = cmp_id[0].objid,
		 	targetos = cmp_id[0].osnum );
      as$status();

      /* get component section */
      status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					p_ComponentId	= &cmp_id[0],
					CmpCptNum	= CmpCptNum,
					p_OutPutSection	= me->section_matrix,
					p_MdEnv		= &me->ModuleInfo );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );

      if( ActParam.hvac_attr.G_width < ActParam.hvac_attr.G_depth )
      {
		TmpValue = me->section_matrix[3];
		me->section_matrix[3] = me->section_matrix[6];
		me->section_matrix[6] = TmpValue;

		TmpValue = me->section_matrix[4];
		me->section_matrix[4] = me->section_matrix[7];
		me->section_matrix[7] = TmpValue;

		TmpValue = me->section_matrix[5];
		me->section_matrix[5] = me->section_matrix[8];
		me->section_matrix[8] = TmpValue;
      }

      /* The G_width must be >= then G_depth */
      status = VRSkUpdateParams( me->Product, &me->ActParamId, &me->ActParamId,
                                 NULL, &me->ModuleInfo );
      as$status();
    }              

    /*| update attributes and the form */
    me->BufParamId = me->ActParamId;
    VR$active_params( operation    = VR_REPLACE,
                      VRproduct    = me->Product,
                      update_flag  = VR_UPDATE,
                      act_param_id = &me->ActParamId,
    	              status       = retcode             );

    /* CR179900491 */
    __DBGpr_com("Call3 for VRSkUpdateForm");
    status = VRSkUpdateForm( me->Product, me->form_ptr, &me->shape_gadget,
			     &me->ActParamId, me->CmpAABBCCcode,
                             &me->active_cpt, me->RWcptdata,
                             &me->ModuleInfo, VR_AUTOMATIQUE );
    __DBGpr_com("Backfrom VRSkUpdateForm");

    as$status();

    VR$active_params( operation    = VR_REPLACE,
                      VRproduct    = me->Product,
                      mode         = VR_USER_MODE,
                      update_flag  = VR_UPDATE,
                      act_param_id = &me->UsrParamId,
    	              status       = retcode             );

    /* update first and previous points for the next input */
    me->first_pt[0] = cmp_pt[3];
    me->first_pt[1] = cmp_pt[4];
    me->first_pt[2] = cmp_pt[5];

    me->prev_pt[0] = cmp_pt[0];
    me->prev_pt[1] = cmp_pt[1];
    me->prev_pt[2] = cmp_pt[2];
/*
printf("firstpt2 %f %f %f\n",me->first_pt[0],me->first_pt[1],me->first_pt[2]);
printf("prevpt2 %f %f %f\n",me->prev_pt[0],me->prev_pt[1],me->prev_pt[2]);
*/
  }

  /* delete current segment */
  {	
	enum GRdpmode mode;

  	mode = GRbehe;
  	status = om$send( msg      = message GRgraphics.GRdisplay
                               		( &retcode, &me->ModuleInfo.md_env.matrix_type,
				 	  me->ModuleInfo.md_env.matrix, &mode, &me->ModuleInfo.md_id ),
    	            	  targetid = segment_to_delete.objid, 
	            	  targetos = segment_to_delete.osnum);
  	as$status();

  	status = om$send( msg      = message GRgraphics.GRdelete( &retcode, &me->ModuleInfo ),
    	            	  targetid = segment_to_delete.objid, 
	            	  targetos = segment_to_delete.osnum);
  	as$status();
  	as$status( sts = retcode );
  }

  if( me->CmpFirstType == IS_NOZZLE )
  {
    /*"display nozzle %d\n", cmp_id[0].objid */

    status = om$send( msg      = message NDnode.NDdisplay
                                         ( 0, GRbd, &me->ModuleInfo ),
                      targetid = cmp_id[0].objid, 
                      targetos = cmp_id[0].osnum  );
    as$status();
  }
quit :

  return(OM_S_SUCCESS);
 
}

/*******************************************************************************
/*
/**/

method VRSkPartialInitInst( IGRlong *sts )
{
  IGRint	i, IndexLoop=VR_NB_ATTR+VR_MAX_CPTS;

  *sts = MSSUCC;

  /*| update segment planes templates number */
  me->assoc_list.num_parents    = VR_NB_SEG_PLANES;

  /*| update sketch mode */
  me->SketchMode = VR_AUTOMATIQUE;

  /*| initialize ListIds instance data */
  for(i=0; i<IndexLoop;i++) me->ListIds[i].objid=NULL_OBJID;

  /* initialize CmpOrientation */
  me->CmpOrientation[0] = 1;
  me->CmpOrientation[1] = 1;

  /* needed to place component by AABBCC code */
  me->ChangePocket   = FALSE;
  me->CmpAABBCCcode[0] = '\0';
  me->CmpNumber[0]   = '\0';
  me->CmpFunction    = 0;
  me->CmpOption         = 1;

  return OM_S_SUCCESS;
}

/*******************************************************************************
/*
/* This method is called each time when the user restart sketch command to 
/* initialize some instance data.
/*
/******************************************************************************/

method VRSkInitInstance( IGRlong *sts )
{
  IGRlong status, retcode;

  *sts = MSSUCC;
  status = om$send( msg      =  message VRsketch.VRSkPartialInitInst( &retcode ),
                    targetid =  my_id );

  /*| update CmpPosition */
  me->CmpPosition = 0;

  /*| First located elem info */
  me->FirstLocatedElemId.objid  = NULL_OBJID;
  me->FirstLocatedElemMdEnv	= me->ModuleInfo;

  /*| update of CmpFirstType and FirstType*/
  me->FirstType    = FREE_SPACE;
  me->CmpFirstType = FREE_SPACE;

  /*| update second elem info */
  me->SecondLocatedElemId.objid = NULL_OBJID;
  me->SecondLocatedElemMdEnv	= me->ModuleInfo;

  /*| update located component connect point */
  me->FirstCptNum    = 0;
  me->SecondCptNum   = 0;

  /*| init number of imposed direction */
  me->NbOfImpDirection = 0;

  /*| update the flag angle */
  me->AngleFlag = FALSE;

  /*| update extend flag */
  me->extend = FALSE;

  /*| update the  angle */
  me->Angle = 0;
  
  /*| update number of segment */
  me->num_of_seg = 0;
  /*"num_of_seg = %d\n", me->num_of_seg */

  /*| update previous segment */
  me->prev_seg_id.objid = NULL_OBJID;

  me->plane_to_move_id.objid = NULL_OBJID;
  me->plane_to_move_id.osnum = me->ModuleInfo.md_id.osnum;
  
  /* update CmpPosition */
  me->CmpPosition = 0;

  /* update orthogonal_sketch */
  me->orthogonal_sketch = TRUE;

  /* init the default mode to draw component : not fitting to fitting */
  me->first_pt_free  = FALSE;
  me->next_pt_free   = FALSE;

  /* init Dynamic widow flag */
  me->ZwindowFlag = FALSE;

  /* update place dangling flag */
  me->PlaceDangling = FALSE;

  /* update active parameters */
  me->ActParamId.osnum = me->ModuleInfo.md_id.osnum;
  VR$active_params( VRproduct    = me->Product,
	    	    act_param_id = &me->ActParamId,
                    status       = retcode );

/********** CR179900491 **********/
  __DBGpr_com("initialize dimen instance here");

  /*** Modified for tr179900780 ***/
  /*** Modified for ETL2174 - tr179901408 ***/
  if(me->Product == VR_RWAY)
  {
    struct ret_struct		ParamAttr;
    IGRint 			FootIndex = -1, retstatus;
     me->active_cpt = 1;
     status =  VRRw_dimen_fields(NULL, 0, NULL, &me->ModuleInfo, 10, 
                              &me->active_cpt, 0,
                              VR_OVAL, me->RWcptdata, &me->ActParamId);
     status =
                 om$send( msg     = message ACncpx.ACgive_structure
                                                          ( &retstatus,
                                                            &FootIndex,
                                                            VR_N_CLASS_AN,
                                                            &ParamAttr,
                                                            &me->ModuleInfo),
                         targetid = me->ActParamId.objid,
                         targetos = me->ActParamId.osnum );

     VR$RDB_SNUM (p_nam = ParamAttr.var.text_st.text_string,
                  p_num = &me->OB.rway.VendorNo );


  }
  /*^ VRprint_user_attr( &me->ActParamId ); */

  me->UsrParamId.osnum = me->ModuleInfo.md_id.osnum;
  VR$active_params( VRproduct    = me->Product,
                    mode         = VR_USER_MODE,
	    	    act_param_id = &me->UsrParamId,
                    status       = retcode );

  me->BufParamId = me->ActParamId;

  if( me->Product == VR_HVAC || me->Product == VR_RWAY )
  {
    /*| initialize section matrix at active referential */
	status = VR$ModifyHvacSection(	p_retmsg	= &retcode,
					Operation	= VR_INIT_SECTION,
					p_OutPutSection	= me->section_matrix,
					p_MdEnv		= &me->ModuleInfo );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );

    	/*| update the twist orientation and twist orientation copy */
    	me->twist_orient  = FALSE;
    	me->twist_save    = FALSE;
  }

  me->PrevLineNum = -1;
  me->bLineNumUsed = FALSE;

  me->bI_Need_Pick = FALSE;

  /* Initialize the two variables.  This is being used only Raceways and also
  only for Shape Transition components. Added by Alwin */
  me->bIsShapeTransition = FALSE;
  me->nShapeCode = -1;

  return ( OM_S_SUCCESS );
}

end implementation VRsketch;

