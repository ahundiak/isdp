/* $Id: VRskfunk.I,v 1.7 2002/05/29 15:14:35 louis Exp $  */

/* I/ROUTE
 *
 * File:        vrtools/VRskfunk.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRskfunk.I,v $
 *	Revision 1.7  2002/05/29 15:14:35  louis
 *	TR6312 Option codes increased to 99
 *	
 *	Revision 1.6  2002/05/07 20:27:29  louis
 *	Incorrect application of tolerance value.
 *	
 *	Revision 1.5  2002/04/10 20:44:58  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.4  2001/03/08 23:43:05  louis
 *	tr4725-dbg prints only
 *	
 *	Revision 1.3  2001/02/20 01:18:20  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:38  anand
 *	SP merge
 *	
# Revision 1.3  2000/11/28  21:39:18  pinnacle
# Replaced: route/vrtools/VRskfunk.I for:  by lawaddel for Service Pack
#
# Revision 1.2  2000/05/11  21:52:14  pinnacle
# Replaced: route/vrtools/VRskfunk.I for:  by apazhani for Service Pack
#
# Revision 1.1  2000/05/04  14:26:12  pinnacle
# Created: route/vrtools/VRskfunk.I by lawaddel for Service Pack
#
# Revision 1.17  2000/03/27  00:57:54  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by aharihar for route
#
# Revision 1.16  2000/02/21  20:52:26  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.15  2000/02/10  19:25:32  pinnacle
# (No comment)
#
# Revision 1.14  2000/01/25  18:58:24  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.13  1999/11/05  20:00:54  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.12  1999/10/22  15:53:08  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.11  1999/05/28  16:37:10  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.10  1999/05/28  14:08:20  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by apazhani for route
#
# Revision 1.9  1999/05/13  19:33:40  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.8  1999/05/04  13:59:46  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by sbilla for route
#
# Revision 1.7  1999/04/29  21:24:08  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.3  1998/10/28  23:20:48  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by apazhani for route
#
# Revision 1.2  1998/08/05  16:00:08  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/01/14  19:02:10  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by lawaddel for route
#
# Revision 1.2  1997/10/29  22:43:54  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by onayragu for route
#
# Revision 1.4  1997/07/18  14:47:36  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by apazhani for route
#
# Revision 1.3  1997/05/23  13:54:36  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by apazhani for route
#
# Revision 1.2  1997/02/06  10:05:08  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.9  1996/04/05  14:25:02  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by r240_int for route240
#
# Revision 1.8  1996/04/04  19:01:42  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by ashankar for route240
#
# Revision 1.7  1996/03/08  08:53:58  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by ashankar for route240
#
# Revision 1.6  1996/01/19  19:14:36  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by ashankar for route240
#
# Revision 1.5  1996/01/19  10:37:14  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by ashankar for route240
#
# Revision 1.4  1996/01/18  23:30:04  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by r240_int for route240
#
# Revision 1.3  1996/01/18  23:07:16  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by r240_int for route240
#
# Revision 1.2  1996/01/18  00:33:24  pinnacle
# Replaced: vrtools/VRskfunk.I for:  by r240_int for route240
#
 *
 * History:
 *	08/19/94    MM		Modified VRSkUpdateForm due to addition
 *					of VR_TRAY.
 *	01/15/96    tlb		Add VX_FIproto.h, prototypes
 *				Change to ANSII style:
 *					VRskgetpt_in_active_cs, VRskgetendpt 
 *					VRSkIsConElbowValid, VRSkGetJustif
 *					VRSkSetFormMode
 *	01/17/96    tlb		Change to ANSII style:
 *					VRSkUpdateForm, VRNozUpdateForm
 *					VRMakeConstraints, VRGetTopology
 *					VRis_change_param, VRSkGetAttrToConnect
 *					VRGetCompFunction
 *	01/17/96	tlb	Use VDfld_set_list_text
 *      Feb/06/97   Alwin       Modified VRSkUpdateForm, added for THROAT_RADIUS
 *                              and TRAN_LENGTH. Modified VRSkSetFormMode
 *      May/23/97   Alwin       Modified VRSkUpdateForm. Added function
 *                              VRResetOptionCode.
 *      May/18/97   Alwin       Made slight correction in VRis_next_pt_valid. 
 *      Jan/08/98   law         CR179309874-New Raceway shapes.
 *      Jan/12/98   law         CR179701945-Throat radius and transition length.
 *      June/30/98  Reddy       TR179801150-Greyed the Depth gadget for Cicular
 *				Raceway.
 *      July/03/98  Reddy       TR179801149-Highlighted  the Depth gadget for 
 *				Rectangular Raceway.
 *      Jul/25/98   LAW         Added tiers for raceway - CR179801144
 *      Oct/23/98   Alwin       Modified to add increase NbAttr to 3 when we
 *                              come acroos the Missing Params Collector.
 *      Apr/19/99   law         CR179900491 - Variable tier spacing
 *      05/04/99    Reddy       Doble value comparision corrected
 *      05/28/99    Alwin       Added a function to return the shape_code for
 *				a given comp_code. Modified the VRSkUpdateForm
 *				function to handle the "shape_transition" 
 *				components.
 *      09/19/99    LAW         TR17900780/781- rway cleanup
 *      10/2/99     law         TR17900780 & tr179900932 - more cleanup
 *      01/25/00    law         tr179900976 - transition failures
 *      02/10/00    Alwin       CR179900696 - update the material list
 *                              based on the spec_name.
 *      02/21/00    law         tr179900985 - HVAC transition fixes
 *      03/26/2k    Anand       Put in check for compcode before calling
 *				function VRGetComp_NbCpt.
 *      05/03/00    law         tr179901512 - HVAC transition fixes
 *      05/10/00    Alwin       CR179901312 - Added Acoustic gadgets for Nozzle
 *      11/21/00    law         TR-MP4140  - prevent crash on bad optcode
 *      03/08/01    law         dbg prints
 *      04/08/02    law         TR5649-standardize tolerance with VRGetTol
 *      05/28/02    law         TR6312-increase VR_MAX_OPTCODE_SIZE to 99
 *************************************************************************/

class implementation Root;


#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "GRtypedef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "VRmacros.h"
#include "OMerrordef.h"
#include "nddef.h"
#include "csdef.h"
#include "madef.h"
#include "msdef.h"
#include "codpdef.h"
#include "grdpbdef.h"
#include "VRcordef.h"
#include "VRparamdef.h"
#include "VRMath.h"
#include "dppriv.h"
#include "dp.h"
#include "bstypes.h"
#include "bsvalues.h"
#include "bserr.h"
#include "bsparameters.h"
#include "VRpriv_attr.h"
#include "grdpbmacros.h"
#include "csmacros.h"
#include "ndmacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "VRdef.h" 
#include "VRcsdef.h" 
#include "VRcompdef.h" 
#include "VRdimdef.h" 
#include "VRstructs.h" 
#include "VRattr_def.h"
#include "VRsketchdef.h"
#include "VRRwDimen.h"
#include "VRformdef.h"
#include "FI.h"
#include "VRchgattrdef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "VRutildef.h" /* Added for CR179309874 - New raceway shapes */
#include "VRprivmacros.h"
#include "VRplanedef.h"
#include "VRMcForm.h"
#include "AS_status.h"
#include "VRRDBdef.h"
#include "VRRDBmac.h"
/* Added for tr179900985 */
#include "VRHDBdef.h"
#include "VRHDBmac.h"

#include "MS.h"
#include "VRco.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bsvalues.h"
#include "VRDbParamDef.h"
#include "ACrg_collect.h"
#include "VRNozzleForm.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "ACattrib.h"
#include "wl.h"
#include "vrtools_pto.h"
#include "vrcorrec_pto.h"
#include "vrpdu_pto.h"
#include "bsint2lns.h"
#include "bscrossp.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "VDmem.h"

#include "parametric.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
 
#include "expression.h"
#include "expmacros.h"
%safe
#include <math.h>
#include "VX_FIproto.h"
%endsafe
#include "vrdbgmacros.h"

#define	AS_DEBUG 	1
#define COS179   	cos( 179 * PI / 180 )
#define	NOT_AN_EXTEND	0
#define VR_MAX_OPTCODE_SIZE  99
#define VR_OPTCODE_LIST_NUM  400
/* tr179900976 - VR_CIRC_ELLP failed - dont know why */
#define VR_CIRCULAR_ELLP     66 

from	GRgraphics	import	GRxform;
from	GRgencs		import	GRgetmatrix;
from	GRcoords	import	GRcvt_to_lcl_coords;
from	NDnode		import	NDcopy_to_root, NDplace, NDget_objects,
				NDgive_structure, NDchange_connect, NDs_compute_node,
				NDmake_source, ASreturn_go;
from	ACncpx		import	ACgive_structure;
from	ACrg_collect	import	ACget_named_attribute, ACadd_list_attribute;
from	VRGeneric	import	VRGetMatrix, VRGetNumberOfCpts,
				VRGetSupOnCpt, VRGetStatus,
				VRGetPlanes, VRGetPlanesOnCpt, VRGetInstance;
from	VRNozzle	import	VRGetRefId;
from	VRConcComp	import	VRAddPlanes;
from	VRCnrlSeg	import	VRGetTopo, VRnotify_merge,
    				VRmerge_segments, VRget_terminators;

extern	GRclassid	OPP_VRconsdist_class_id;

/******************************************************************************
VRdbls_are_equal function added as part of tr179900932 cleanup

 CHANGE HISTORY:  Created 10/28/99 to accept 2 double values and return a
 boolean TRUE/FALSE. The value BSBASISVAL is used as a tolerance 
 BSBASISVAL difference returns FALSE;
******************************************************************************/

IGRboolean VRdbls_are_equal(val1,val2)

IGRdouble val1,val2;

{
  if(fabs(val1 - val2) < VRGetTol(VR_DEFAULT_TOL)) return TRUE;
  else return FALSE;
}  /* end VRdbls_are_equal */
/******************************************************************************
VRdbls_not_equal function   added as part of tr179900932 cleanup

 CHANGE HISTORY:  Created 10/28/99 to accept 2 double values and return a
 boolean TRUE/FALSE if not equal. The value BSBASISVAL is used as a tolerance
 BSBASISVAL difference should return true;
******************************************************************************/

IGRboolean VRdbls_not_equal(val1,val2)

IGRdouble val1,val2;

{
  if(fabs(val1 - val2) >= VRGetTol(VR_DEFAULT_TOL)) return TRUE;
  else return FALSE;
}  /* end VRdbls_not_equal */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 comp_rw_tier_depth fucntion
 
 CHANGE HISTORY:  momo 07-25-1998 : Design date for CR179801144

******************************************************************************/
/*                       I        I        I        I          O     */
VRcomp_rw_tier_depth( mod_env, obj_id, num_tier, tier_spc, rw_depth )

struct 		GRmd_env	*mod_env;          /* module environement   */
struct		GRid		obj_id;            /* object id        */
IGRdouble			num_tier;	   /* number of tiers  */
IGRdouble			tier_spc;	   /* tier_spacing */
IGRdouble			*rw_depth;          /* Computed depth */
{
  *rw_depth = num_tier * tier_spc;
  return(OM_S_SUCCESS);
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 get_active_cs fucntion
 
 CHANGE HISTORY:  momo 07-12-1989 : Design date

******************************************************************************/
/*                 I        O             O                 O               */
VRskget_active_cs( mod_env, active_cs_id, active_cs_matrix, cstype )

struct 		GRmd_env	*mod_env;          /* module environement   */
struct		GRid		*active_cs_id;     /* active cs Grid        */
IGRdouble			*active_cs_matrix; /* active cs matrix      */
IGRchar				*cstype;           /* type of active_cs     */
/*.VRskget_active_cs */
{
  IGRlong	msg;             /* return code                          */
  IGRlong	status;          /* return code                          */
  IGRlong	NumberOfBytes;   /* number of bytes : used by DBP macros */
  IGRlong	BytesReceived;   /* number of received bytes             */
  struct GRmd_env module_env;    /* module environnement GRid            */
  IGRint NbCpts;

  if( mod_env == NULL )
  {
    /*| get module_env */
    NumberOfBytes = sizeof( struct GRmd_env );
    status = gr$get_model_env( msg    = &msg,
  			       sizbuf = &NumberOfBytes,
			       buffer = &module_env,
			       nret   = &BytesReceived );
    as$status( action = RET_STATUS );
    as$status( sts = msg, action = RET_STATUS );
  }
  else module_env = *mod_env;

  /*| get active CS */ 
  active_cs_id->osnum = module_env.md_id.osnum;
  status = cs$get_active_info( msg   = &msg,
                               osnum = active_cs_id->osnum,
                               objid = &active_cs_id->objid );
  as$status( action = RET_STATUS );
  as$status( sts = msg, action = RET_STATUS );
  /*"active_cs_objid = %d\n", active_cs_id->objid */

  /*| get CS type */
  NumberOfBytes = MAX_CS_TYPE;
  status = gr$get_cs_type( msg    = &msg,
                           sizbuf = &NumberOfBytes,
                           buffer = cstype,
                           nret   = &BytesReceived );
  as$status( action = RET_STATUS );
  as$status( sts = msg, action = RET_STATUS );

  if ( active_cs_matrix )
  {
	/*| get CS matrix */
	status =
	om$send( msg      = message GRgencs.GRgetmatrix
				( &msg, active_cs_matrix ),
		senderid = NULL_OBJID,
		targetid = active_cs_id->objid, 
		targetos = active_cs_id->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = msg, action = RET_STATUS );

  /*^
     IGRint	i, j;

     printf("VRsketch.VRget_active_cs =================================\n");

     for(i=0;i<16;i+=4)
     {
       for(j=0;j<4;j++)printf("ref[%d]= %f  ",i+j,active_cs_matrix[i+j]);
       printf("\n");
     }

     printf("VRsketch.VRget_active_cs =================================\n");
  */

  }/* end return matrix */

  return(OM_S_SUCCESS);

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 is_next_pt_valid fucntion
 
 CHANGE HISTORY:  momo 25-10-1989 : Design date


 DESCRIPTION  : next_pt is it a valid point

 RET_CODE     : IS_A_VALID_POINT
                IS_NOT_A_VALID_POINT
                IS_AN_EXTEND

 
***********************************************************************************/

VRis_next_pt_valid(	AcceptExtend, IsValidPoint, prev_pt, first_pt, 
			next_pt, NbOfImpDirection, imp_direct )

IGRint	  	AcceptExtend;
IGRint		*IsValidPoint;
IGRdouble 	*prev_pt;
IGRdouble 	*first_pt;
IGRdouble 	*next_pt;
IGRint		NbOfImpDirection;
IGRdouble 	*imp_direct;

/*.VRis_next_pt_valid */
{
  IGRint	i;
  IGRint	NbPrevDir;
  BSrc		bsretcode;      		/* BS return code            */
  IGRdouble 	dot_p[VR_MAX_CPTS];             /* vectors' dot product      */
  IGRdouble	prev_direct[3*VR_MAX_CPTS];	/* previous directions       */
  IGRvector 	next_direct;                    /* next direction vector     */


  *IsValidPoint = IS_NOT_A_VALID_POINT;

  /* calculate normal next direction vector */
  BSmkvec( &bsretcode, next_direct, first_pt, next_pt );
  BSnorvec( &bsretcode, next_direct );

  /*"next_dir = %f %f %f\n",next_direct[0],next_direct[1],next_direct[2] */

  if( NbOfImpDirection )
  {
    	/*| imposed direction */
	NbPrevDir = NbOfImpDirection;
	for( i=0; i<3*NbOfImpDirection; i++ ) prev_direct[i] = imp_direct[i];
  }
  else
  {
    	/*| calculate normal previous direction vector */
	NbPrevDir = 1;
    	BSmkvec( &bsretcode, prev_direct, prev_pt, first_pt );
    	BSnorvec( &bsretcode, prev_direct );
  }

  /*^
	printf("============ VRis_next_pt_valid\n");
  	for( i=0; i<NbPrevDir; i++ )
  	{
          printf("\t\t prev_dir = %f %f %f\n", prev_direct[3*i],prev_direct[3*i+1],prev_direct[3*i+2] );
        }
	printf("============ VRis_next_pt_valid\n");
  */


  /* calculate the dot product between next and previous directions */
  if( NbOfImpDirection )
  {
  	for( i=0; i<NbOfImpDirection; i++ )
  	{
    		dot_p[i] = BSdotp( &bsretcode, &prev_direct[3*i], next_direct );
    		/*"dot_p[%d] = %E\n", i, dot_p[i] */

  		if( !AcceptExtend )
  		{
                        /*** Not too sure so modified tr179900780 **/
    			if( (1 - fabs(dot_p[i])) >= VRGetTol(VR_DOTPROD_TOL) )
    			{
      				*IsValidPoint = IS_A_VALID_POINT;
      				return OM_S_SUCCESS;
    			}
  		}
		else
        	{   
    			//if(fabs(1-dot_p[i])<BSBASISVAL ), commented by alwin
    			if( fabs(1 - fabs(dot_p[i])) < VRGetTol(VR_DOTPROD_TOL))
			{
				*IsValidPoint = IS_A_VALID_POINT;
      				return OM_S_SUCCESS;
			}
		}
  	}
  }
  else
  {
  	dot_p[0] = BSdotp( &bsretcode, prev_direct, next_direct );
        /*"dot_p = %E\n", dot_p[0] */

        /*** Not too sure so modified tr179900780 **/
    	if(( 1 - dot_p[0]) < VRGetTol(VR_DOTPROD_TOL) ) 
        {
		if( AcceptExtend ) *IsValidPoint = IS_AN_EXTEND;
        }
        else if( dot_p[0] >= COS179 ) *IsValidPoint = IS_A_VALID_POINT;
  }

  return(OM_S_SUCCESS);
}

/****************************************************************************

 VRget_project_pt fucntion
 
 CHANGE HISTORY:  momo 25-10-1989 : Design date


 DESCRIPTION  : get projection point

/****************************************************************************/

/*                I         I        O                                      */
VRget_project_pt( first_pt, next_pt, projpt, win_direction, imp_direction )

IGRdouble 		*first_pt;
IGRdouble 		*next_pt;
IGRdouble 		*projpt;
IGRdouble 		*win_direction;
IGRdouble		*imp_direction;

/*.VRget_project_pt */
{
  IGRchar	 		cstype[MAX_CS_TYPE];
                                                 /* type of active_cs         */
  IGRlong	 		rc;              /* math. return code         */
  IGRlong	 		status;          /* return code               */
  IGRdouble	 		min_dist;        /* used bu BSint2lns         */
  IGRdouble	 		min_distance;    /* used bu BSint2lns         */
  IGRdouble	 		line_pt0[3];     /* used to calculate projpt  */
  IGRdouble	 		line_pt1[3];     /* used to calculate projpt  */
  IGRdouble	 		pt_result[6];    /* used by BSint2lns         */
  IGRmatrix	 		ref_matrix;      /* active ref. matrix        */
  struct 	GRid	 	ref_id;          /* active ref. GRid          */
  struct 	IGRline 	line0;           /* used to calculate projpt  */
  struct 	IGRline 	line1;           /* used to calculate projpt  */
  struct 	IGRline 	*line[2];        /* used to calculate projpt  */


  /* initialization */

  line0.point1 = first_pt;
  line0.point2 = line_pt0;
  line1.point1 = next_pt;
  line1.point2 = line_pt1;
  line[0]      = &line0;
  line[1]      = &line1;

  min_dist     = 1.e+30; /* no tolerance mon here */

	  /*| lines defining the win_direction coordinate axis */

  line_pt1[0]  = next_pt[0] + 50 * win_direction[0];
  line_pt1[1]  = next_pt[1] + 50 * win_direction[1];
  line_pt1[2]  = next_pt[2] + 50 * win_direction[2];

  /*"first_pt = %f %f %f\n", first_pt[0], first_pt[1], first_pt[2] */
  /*"next_pt  = %f %f %f\n", next_pt[0] , next_pt[1] , next_pt[2]  */
  /*"pt1 = %f %f %f\n", line1.point1[0], line1.point1[1], line1.point1[2] */
  /*"pt2 = %f %f %f\n", line1.point2[0], line1.point2[1], line1.point2[2] */

  if( ! imp_direction )
  {
    	status = VRskget_active_cs( ( struct GRmd_env * ) NULL, &ref_id, ref_matrix, cstype );
    	as$status( action = RET_STATUS );

  	/*| lines defining the X coordinate axis */

  	line_pt0[0]  = first_pt[0] + 50 * ref_matrix[0];
  	line_pt0[1]  = first_pt[1] + 50 * ref_matrix[4];
  	line_pt0[2]  = first_pt[2] + 50 * ref_matrix[8];

  	/*"pt1 = %f %f %f\n", line0.point1[0], line0.point1[1], line0.point1[2] */
  	/*"pt2 = %f %f %f\n", line0.point2[0], line0.point2[1], line0.point2[2] */

  	BSint2lns( line, (IGRpoint *)pt_result, &min_distance, &rc );

  	if( rc != BSPARALLEL )
  	{
    		min_dist   = min_distance;
    		projpt[0] = pt_result[0];
    		projpt[1] = pt_result[1];
    		projpt[2] = pt_result[2];
  	}
    
  	/*| lines defining the Y coordinate axis */

  	line_pt0[0]  = first_pt[0] + 50 * ref_matrix[1];
  	line_pt0[1]  = first_pt[1] + 50 * ref_matrix[5];
  	line_pt0[2]  = first_pt[2] + 50 * ref_matrix[9];

  	/*"pt1 = %f %f %f\n", line0.point1[0], line0.point1[1], line0.point1[2] */
  	/*"pt2 = %f %f %f\n", line0.point2[0], line0.point2[1], line0.point2[2] */

  	BSint2lns( line, (IGRpoint *)pt_result, &min_distance, &rc );

  	if( rc != BSPARALLEL && min_distance < min_dist )
  	{
    		min_dist   = min_distance;
    		projpt[0] = pt_result[0];
    		projpt[1] = pt_result[1];
    		projpt[2] = pt_result[2];
  	}
    
  	/*| lines defining the Z coordinate axis */

  	line_pt0[0]  = first_pt[0] + 50 * ref_matrix[2];
  	line_pt0[1]  = first_pt[1] + 50 * ref_matrix[6];
  	line_pt0[2]  = first_pt[2] + 50 * ref_matrix[10];

  	/*"pt1 = %f %f %f\n", line0.point1[0], line0.point1[1], line0.point1[2] */
  	/*"pt2 = %f %f %f\n", line0.point2[0], line0.point2[1], line0.point2[2] */

  	BSint2lns( line, (IGRpoint *)pt_result, &min_distance, &rc );

  	if( rc != BSPARALLEL && min_distance < min_dist )
  	{  
    		projpt[0] = pt_result[0];
    		projpt[1] = pt_result[1];
    		projpt[2] = pt_result[2];
  	}

  	/*"projpt   = %f %f %f\n", projpt[0],   projpt[1],   projpt[2]   */
  }
  else
  {
  	/*| lines defining the inposed direction */

  	line_pt0[0]  = first_pt[0] + 50 * imp_direction[0];
  	line_pt0[1]  = first_pt[1] + 50 * imp_direction[1];
  	line_pt0[2]  = first_pt[2] + 50 * imp_direction[2];

  	/*"pt1 = %f %f %f\n", line0.point1[0], line0.point1[1], line0.point1[2] */
  	/*"pt2 = %f %f %f\n", line0.point2[0], line0.point2[1], line0.point2[2] */

  	BSint2lns( line, (IGRpoint *)pt_result, &min_distance, &rc );

    	projpt[0] = pt_result[0];
    	projpt[1] = pt_result[1];
    	projpt[2] = pt_result[2];
  }

  return(OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  			   VRskgetpt_in_active_cs function

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint VRskgetpt_in_active_cs( IGRdouble	*base_pt,
				IGRdouble	*active_pt,
				struct	GRmd_env *mod_env
				)
/*.VRskgetpt_in_active_cs */
{
  IGRchar	cstype[MAX_CS_TYPE]; /* type of active_cs                */
  IGRlong	status;		     /* return code                      */
  IGRlong	msg;		     /* return code                      */
  struct GRid	ref_id;              /* active ref. GRid                 */

  status =
  VRskget_active_cs( mod_env, &ref_id, (IGRdouble *) NULL, cstype );
  as$status( action = RET_STATUS );

  /*| get base_pt in active_CS */
  status = om$send( msg      = message GRcoords.GRcvt_to_lcl_coords
                                                ( &msg,
                                                  cstype,
  		                                  1,
                                                  base_pt,
                                                  active_pt ),
                    senderid = NULL_OBJID,
                    targetid = ref_id.objid,
                    targetos = ref_id.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = msg, action = RET_STATUS );

  /*"active_pt = %f %f %f\n", active_pt[0],active_pt[1],active_pt[2] */

  return( OM_S_SUCCESS );

}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

			VRskgetendpt function


 CHANGE HISTORY:  momo 16-01-1990 : Design date

 ABSTRACT      :  get end point of linestr associated with a CnrlSeg

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRlong VRskgetendpt( IGRlong				*msg,
			IGRboolean			pt_type,
			IGRdouble			*end_pt,
			struct		GRid		*seg_id,
			struct 		GRmd_env	*md_env
			)

/*.VRskgetendpt */
{
  IGRlong 			status;  /* return code                 */
  IGRlong 			retcode; /* return code                 */
  struct 	ret_struct	seg_str; /* segment structure           */


  *msg    = MSSUCC;
  status  = OM_S_SUCCESS;
  retcode = OM_S_SUCCESS;


  /* get control segment structure */

  status = om$send( msg      = message NDnode.NDgive_structure 
                                       ( &retcode, &seg_str, md_env ),
                    senderid = NULL_OBJID,
                    targetid = seg_id->objid, 
                    targetos = seg_id->osnum );
  as$status( action = RET_STATUS );  
  as$status( sts = retcode, action = RET_STATUS );  

  if( pt_type )
  {
    end_pt[0] = seg_str.var.line_st.p1[0];
    end_pt[1] = seg_str.var.line_st.p1[1];
    end_pt[2] = seg_str.var.line_st.p1[2];
    end_pt[3] = seg_str.var.line_st.p0[0];
    end_pt[4] = seg_str.var.line_st.p0[1];
    end_pt[5] = seg_str.var.line_st.p0[2];
  }
  else
  {
    end_pt[0] = seg_str.var.line_st.p0[0];
    end_pt[1] = seg_str.var.line_st.p0[1];
    end_pt[2] = seg_str.var.line_st.p0[2];
    end_pt[3] = seg_str.var.line_st.p1[0];
    end_pt[4] = seg_str.var.line_st.p1[1];
    end_pt[5] = seg_str.var.line_st.p1[2];
  }
  
  /*"end_pt0 = %f %f %f\n", end_pt[0], end_pt[1], end_pt[2] */
  /*"end_pt1 = %f %f %f\n", end_pt[3], end_pt[4], end_pt[5] */
  
  return(OM_S_SUCCESS );

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 VRis_change_param function

 CHANGE HISTORY:  momo 23-10-1989 : Design date


 DESCRIPTION  : test if user has changed active parameters


~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRis_change_param( 	IGRshort			product,
			struct		GRid		*buf_param_id,
			struct		GRid		*act_param_id,
			IGRshort			twist_orient,
			IGRshort			twist_save,
			IGRshort			*is_change,
			IGRshort			*placement_type,
			struct		GRmd_env	*MdEnv)

/*.VRis_change_param */
{
  IGRint			sts, FootIndex=-1;
  IGRlong			status, retcode;
  struct	ret_struct	ActParam, BufParam;
  union		VRparam_attr	ActParamAttr, BufParamAttr;


  *is_change = NO_CHANG;

  status = VR$GetDimensionAttributes(	p_retmsg	  = &retcode,
					Product		  = product,
					p_SysCollectionId = act_param_id,
					p_DimAttributes	  = &ActParamAttr,
					p_MdEnv	  	  = MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = VR$GetDimensionAttributes(	p_retmsg	  = &retcode,
					Product		  = product,
					p_SysCollectionId = buf_param_id,
					p_DimAttributes	  = &BufParamAttr,
             				p_MdEnv	  	  = MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );
  
  if( product == VR_PIPING )
  {
    if( fabs( BufParamAttr.piping_attr.G_diameter -
                           ActParamAttr.piping_attr.G_diameter ) > 
                                                        VRGetTol(VR_DIST_TOL) )
    {
      /*| we detect a diameter changement */
      *is_change      = DIAMETER_CHANG;
      *placement_type = VR_REDUCER;
      __DBGpr_com("************** Setting REDUCER1 *****************");

      return OM_S_SUCCESS;
    }

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_FLUID_CODE_AN,
                                   &ActParam, MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = act_param_id->objid,
		      targetos = act_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"fluid_code = %s\n", ActParam.var.text_st.text_string */

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_FLUID_CODE_AN,
                                   &BufParam, MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = buf_param_id->objid,
		      targetos = buf_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"fluid_code = %s\n", BufParam.var.text_st.text_string */

    if( strcmp( BufParam.var.text_st.text_string,
                                            ActParam.var.text_st.text_string ) )
    {
      /*| we detect fluide_code changement */
      *is_change      = AUTHER_CHANG;
      *placement_type = VR_FLGE_COMP;

      return OM_S_SUCCESS;
    }
    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_CONSTR_STAT_AN,
                                   &ActParam, MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = act_param_id->objid,
		      targetos = act_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"const_sts = %s\n", ActParam.var.text_st.text_string */

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_CONSTR_STAT_AN,
                                   &BufParam, MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = buf_param_id->objid,
		      targetos = buf_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"const_sts = %s\n", BufParam.var.text_st.text_string */

    if( strcmp( BufParam.var.text_st.text_string,
                                            ActParam.var.text_st.text_string ) )
    {
      /*| we detect const_sts changement */
      *is_change      = AUTHER_CHANG;
      *placement_type = VR_FLGE_COMP;

      return OM_S_SUCCESS;
    }

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_APPRV_STAT_AN, 
                                   &ActParam, MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = act_param_id->objid,
		      targetos = act_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"approval_sts = %s\n", ActParam.var.text_st.text_string */

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_APPRV_STAT_AN,
                                   &BufParam, MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = buf_param_id->objid,
		      targetos = buf_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"approval_sts = %s\n", BufParam.var.text_st.text_string */

    if( strcmp( BufParam.var.text_st.text_string,
                                            ActParam.var.text_st.text_string ) )
    {
      /*| we detect approval_sts changement */
      *is_change      = AUTHER_CHANG;
      *placement_type = VR_FLGE_COMP;

      return OM_S_SUCCESS;
    }

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts,&FootIndex, VR_N_CLASS_AN, &ActParam,
                                   MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = act_param_id->objid,
		      targetos = act_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"pds_class = %s\n", ActParam.var.text_st.text_string */

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_CLASS_AN, &BufParam,
                                   MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = buf_param_id->objid,
		      targetos = buf_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"pds_class = %s\n", BufParam.var.text_st.text_string */

    if( strcmp( BufParam.var.text_st.text_string,
                                            ActParam.var.text_st.text_string ) )
    {
      /*| we detect component pds class changement */
      *is_change      = AUTHER_CHANG;
      *placement_type = VR_FLGE_COMP;

      return OM_S_SUCCESS;
    }

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_SEQ_NUMBER_AN,
                                   &ActParam, MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = act_param_id->objid,
		      targetos = act_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"line_seq_number = %s\n", ActParam.var.text_st.text_string */

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_SEQ_NUMBER_AN, 
                                   &BufParam, MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = buf_param_id->objid,
		      targetos = buf_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"line_seq_number = %s\n", BufParam.var.text_st.text_string */

    if( strcmp( BufParam.var.text_st.text_string,
                                            ActParam.var.text_st.text_string ) )
    {
      /*| we detect line_seq_number changement */
      *is_change      = AUTHER_CHANG;
      *placement_type = VR_FLGE_COMP;

      return OM_S_SUCCESS;
    }

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_ZONE_AN, &ActParam,
                                   MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = act_param_id->objid,
		      targetos = act_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"zone = %s\n", ActParam.var.text_st.text_string */

    status = om$send( msg      = message ACncpx.ACgive_structure
                                 ( &sts, &FootIndex, VR_N_ZONE_AN, &BufParam,
                                   MdEnv
                                 ),
     	              senderid = NULL_OBJID,
	    	      targetid = buf_param_id->objid,
		      targetos = buf_param_id->osnum );
    as$status( action = RET_STATUS );
    as$status( sts = sts, action = RET_STATUS );

    /*"zone = %s\n", BufParam.var.text_st.text_string */

    if( strcmp( BufParam.var.text_st.text_string,
                                            ActParam.var.text_st.text_string ) )
    {
      /*| we detect zone changement */
      *is_change      = AUTHER_CHANG;
      *placement_type = VR_FLGE_COMP;

      return OM_S_SUCCESS;
    }
  }
  else
  {
    if( ActParamAttr.hvac_attr.shape != BufParamAttr.hvac_attr.shape )
    {
      /*| we place a shape transition */

      *is_change = AUTHER_CHANG;
      status = VRGetTransCode
		( ActParamAttr.hvac_attr.shape, BufParamAttr.hvac_attr.shape,
                  placement_type );
      as$status();

      return OM_S_SUCCESS;
    }
    if( twist_orient != twist_save                                          &&
        ( BufParamAttr.hvac_attr.shape != VR_CIRC ||
                                  ActParamAttr.hvac_attr.shape != VR_CIRC ) &&
          !( BufParamAttr.hvac_attr.shape == VR_RECT &&
                                        ActParamAttr.hvac_attr.shape == VR_RECT 
/**
          && BufParamAttr.hvac_attr.G_width == BufParamAttr.hvac_attr.G_depth
          && ActParamAttr.hvac_attr.G_width == ActParamAttr.hvac_attr.G_depth
**/
          && (fabs(BufParamAttr.hvac_attr.G_width - BufParamAttr.hvac_attr.G_depth) < VRGetTol(VR_DIST_TOL) )
          && (fabs(ActParamAttr.hvac_attr.G_width - ActParamAttr.hvac_attr.G_depth) < VRGetTol(VR_DIST_TOL) )
        )
      )
    {  
      /*| we place an orientation transition */

      *is_change      = AUTHER_CHANG;
      *placement_type = VR_TWIST_R_TR;

      return OM_S_SUCCESS;
    }
/*
    if( BufParamAttr.hvac_attr.G_width != ActParamAttr.hvac_attr.G_width ||
        ( BufParamAttr.hvac_attr.G_depth != ActParamAttr.hvac_attr.G_depth
                                && ActParamAttr.hvac_attr.shape != VR_CIRC ) )
*/
    /****TR179900491****/
    if((fabs(BufParamAttr.hvac_attr.G_width - ActParamAttr.hvac_attr.G_width)
                                                     > VRGetTol(VR_DIST_TOL)) ||
       (fabs(BufParamAttr.hvac_attr.G_depth - ActParamAttr.hvac_attr.G_depth)
         > VRGetTol(VR_DIST_TOL) && ActParamAttr.hvac_attr.shape != VR_CIRC ) )
    {
      /*| we place an excentric reducer */

      __DBGpr_com("************** Setting REDUCER2 *****************");
      *is_change      = DIAMETER_CHANG;
      *placement_type = VR_REDUCER;
    }
  }

  return OM_S_SUCCESS;
}


/******************************************************************************/

IGRint Cursor_Pos( pt )

IGRdouble pt[];

/*.Cursor_Pos */
{
  GRobjid		win_id;
  IGRint		i, pnt_status, num_windows, num_gra_gad, dyn_x, dyn_y;
  IGRint		dit_point[3], wfl, index, win[MAX_WINDOW];
  IGRlong		msg;
  IGRdouble		point[3];
  struct GRid		mod_id;
  struct EX_button 	uor_point;
  struct DPgra_gad	window[MAX_WINDOW];
  struct DPgad_in_win	win_info[MAX_WINDOW];
  struct DP_information	dp_info[MAX_WINDOW];
  WLuint32		win_no;


  for( i=0; i < MAX_WINDOW; i++ )
  {
    dp_info[i].gragad         = &window[i];
    dp_info[i].is_hidden_line = FALSE;
    dp_info[i].is_update      = FALSE;
    dp_info[i].is_fit         = FALSE;	
    dp_info[i].hline_info     = NULL;
    dp_info[i].hl_tiler       = NULL;
  }

  ex$get_cur_mod(id = &mod_id.objid, osnum = &mod_id.osnum);
  uor_point.osnum   = mod_id.osnum;

  /*  	get all the window objects that are connected to this module's channel
	this routine calls enter_dynamics. Need to exit dyn so as to avoid
	symbology problems	 */

  DPdyn_set_up(dp_info,win_info,win, &num_windows, &num_gra_gad);

  /* start of mouse position */

  /* Modified for conversion to 3.0 EMS */
  WLmouse_win_position(&win_no,&dyn_x,&dyn_y,&wfl);

  /* Is the mouse in a window associated with this module  */

  if (DPdyn_ret_index(dyn_x,dyn_y,win_no,num_windows,dp_info,
	win_info, &index, &win_id ))
  {		
    /* convert point  */

    point[0] = (IGRdouble) dyn_x;
    point[1] = (IGRdouble) dyn_y;

    uor_point.objid = win_id;
    uor_point.window = (IGRlong)win_no;
    pnt_status = DPdyn_conv_pnt( &msg,
				 dp_info[index].gragad,point,
				 dit_point,&uor_point,mod_id.osnum
                               );
    pt[0] = uor_point.x;
    pt[1] = uor_point.y;
    pt[2] = uor_point.z;
  }

  for ( i=0; i<num_windows; i++ )
	WLexit_dynamics( (WLuint32) win[i] );

return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

VRskIsConElbowValid fucntion
 
 CHANGE HISTORY:  momo 10-01-1991 : Design date

 RET_CODE     : IS_A_VALID_POINT
                IS_NOT_A_VALID_POINT

 
*****************************************************************************/

VRSkIsConElbowValid( IGRint	  	*msg,
			IGRdouble 	*first_pt,
			IGRdouble 	*next_pt,
			IGRdouble	*elbow_direct1,
			IGRdouble	*elbow_direct2
			)

/*.VRIsConElbowValid */
{
  BSrc		bsretcode;      /* BS return code                            */
  IGRlong	status;         /* return code                               */
  IGRdouble 	dot_p;          /* vector's dot product                      */
  IGRdouble 	dot_p1;         /* vector's dot product                      */
  IGRdouble 	next_direct[3]; /* next direction vector                     */

  *msg   = IS_A_VALID_POINT;
  status = OM_S_SUCCESS;

  /*"fs_pt = %f %f %f\n", first_pt[0], first_pt[1], first_pt[2] */
  /*"nx_pt = %f %f %f\n", next_pt[0],  next_pt[1],  next_pt[2]  */

  /*"el_d1 = %f %f %f\n", elbow_direct1[0],elbow_direct1[1],elbow_direct1[2] */
  /*"el_d2 = %f %f %f\n", elbow_direct2[0],elbow_direct2[1],elbow_direct2[2] */

  BSmkvec(  &bsretcode, next_direct, first_pt, next_pt );
  BSnorvec( &bsretcode, next_direct );

  /*"next_dir = %f %f %f\n",next_direct[0],next_direct[1],next_direct[2] */

  dot_p  = BSdotp( &bsretcode, elbow_direct1, next_direct );
  dot_p1 = BSdotp( &bsretcode, elbow_direct2, next_direct );

  /*"dot_p         = %E\n", dot_p       */
  /*"dot_p1        = %E\n", dot_p1      */

  if( fabs(1 + dot_p)  >= VRGetTol(VR_DOTPROD_TOL) &&
      fabs(1 + dot_p1) >= VRGetTol(VR_DOTPROD_TOL) )
  {
    /*| Not valid elbow connect */

    *msg = IS_NOT_A_VALID_POINT;
  }

  /*"msg = %d\n", *msg */

  return(OM_S_SUCCESS);
}

/*****************************************************************************/

VRSkGetAttrToConnect( 	IGRshort		product,
			struct	GRid		*act_param_id,
			struct	GRid		*user_param_id,
			struct	GRid		*cmp_id,
			struct	GRid		*seg_id,
			struct	GRid		*buf_param_id,
			struct	GRid		*seg1_id,
			struct	GRmd_env	*md_env)
			
/*.VRSkGetAttrToConnect */
{
  BSrc  			bsretcode;
  IGRint  			NbCmp;
  IGRlong 			status, retcode;
  IGRdouble			dotp, TmpValue, EndPt[6];
  IGRvector			Seg1Vect, Seg2Vect, Y_Vect, TmpVect;
  IGRmatrix			Cmp0Matrix, Cmp1Matrix;
  struct	GRid    	CmpToAskForParam;
  struct	GRid		ListCmp[VR_NB_CMPS];
  union		VRparam_attr	CmpParam;


  status  = OM_S_SUCCESS;
  retcode = MSSUCC;


  /*"SegId = %d\n", seg_id->objid */
  /*"CmpId = %d\n", cmp_id->objid */

  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               ( &retcode, &NbCmp, md_env, EndPt, ListCmp ),
                    senderid = NULL_OBJID,
                    targetid = seg_id->objid,
                    targetos = seg_id->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( NbCmp != VR_NB_CMPS )
  {
    as$status( sts = OM_E_ABORT, msg = "Not valid number of component" );
    return OM_E_ABORT ;
  }

  /*"ListCmp = %d %d\n", ListCmp[0].objid, ListCmp[1].objid */

  if( ListCmp[0].objid == cmp_id->objid ) CmpToAskForParam = ListCmp[1];
  else                                    CmpToAskForParam = ListCmp[0];

  BSmkvec( &bsretcode, Seg1Vect, EndPt, &EndPt[3] );
  BSnorvec( &bsretcode, Seg1Vect );

  /*"Seg1Vect = %f %f %f\n", Seg1Vect[0], Seg1Vect[1], Seg1Vect[2] */

  status = om$send( msg      = message VRGeneric.VRGetMatrix
                               ( &retcode, 0, NULL, Cmp0Matrix, md_env ),
                    senderid = NULL_OBJID,
                    targetid = CmpToAskForParam.objid,
                    targetos = CmpToAskForParam.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = VRSkGetAttrFromCmp( product, act_param_id, NULL, user_param_id,
                               &CmpToAskForParam, seg_id, NULL, md_env );
  as$status( action = RET_STATUS );

  status = om$send( msg      = message VRCnrlSeg.VRget_terminators
                               ( &retcode, &NbCmp, md_env, EndPt, ListCmp ),
                    senderid = NULL_OBJID,
                    targetid = seg1_id->objid,
                    targetos = seg1_id->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"NbCmp = %d\n", NbCmp */

  BSmkvec( &bsretcode, Seg2Vect, EndPt, &EndPt[3] );
  BSnorvec( &bsretcode, Seg2Vect );

  /*"Seg2Vect = %f %f %f\n", Seg2Vect[0], Seg2Vect[1], Seg2Vect[2] */

  status = om$send( msg      = message VRGeneric.VRGetMatrix
                               ( &retcode, 0, NULL, Cmp1Matrix, md_env ),
                    senderid = NULL_OBJID,
                    targetid = ListCmp[0].objid,
                    targetos = ListCmp[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  BScrossp( &bsretcode, Seg1Vect, Seg2Vect, TmpVect );

  /*"TmpVect = %f %f %f\n", TmpVect[0], TmpVect[1], TmpVect[2] */

  status = VRSkGetAttrFromCmp( product, buf_param_id, NULL, NULL, &ListCmp[0],
                               seg1_id, NULL, md_env );
  as$status( action = RET_STATUS );

  Y_Vect[0] = Cmp0Matrix[2];
  Y_Vect[1] = Cmp0Matrix[6];
  Y_Vect[2] = Cmp0Matrix[10];

  /*"Y_Vect = %f %f %f\n", Y_Vect[0], Y_Vect[1], Y_Vect[2] */

  dotp = BSdotp( &bsretcode, Y_Vect, TmpVect );

  /*"dotp = %f\n", dotp */
          
  if( ( 1 - fabs( dotp ) ) < VRGetTol(VR_DOTPROD_TOL) )
  {
    /*| first width is OUT ==> switch */

    status = VR$GetDimensionAttributes(	p_retmsg	  = &retcode,
					Product		  = product,
					p_SysCollectionId = act_param_id,
					p_DimAttributes	  = &CmpParam,
             				p_MdEnv	  	  = md_env );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    TmpValue                   = CmpParam.hvac_attr.G_width;
    CmpParam.hvac_attr.G_width = CmpParam.hvac_attr.G_depth;
    CmpParam.hvac_attr.G_depth = TmpValue;

    status = VRModifyParameterBox
             ( &retcode,product,&CmpParam,act_param_id,act_param_id );
    as$status( action = RET_STATUS );
  } 

  Y_Vect[0] = Cmp1Matrix[2];
  Y_Vect[1] = Cmp1Matrix[6];
  Y_Vect[2] = Cmp1Matrix[10];

  /*"Y_Vect = %f %f %f\n", Y_Vect[0], Y_Vect[1], Y_Vect[2] */

  dotp = BSdotp( &bsretcode, Y_Vect, TmpVect );

  /*"dotp = %f\n", dotp */
          
  if( ( 1 - fabs( dotp ) ) < VRGetTol(VR_DOTPROD_TOL) )
  {
    /*| second width is OUT ==> switch */
    status = VR$GetDimensionAttributes(	p_retmsg	  = &retcode,
					Product		  = product,
					p_SysCollectionId = buf_param_id,
					p_DimAttributes	  = &CmpParam,
             				p_MdEnv	  	  = md_env );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    TmpValue                   = CmpParam.hvac_attr.G_width;
    CmpParam.hvac_attr.G_width = CmpParam.hvac_attr.G_depth;
    CmpParam.hvac_attr.G_depth = TmpValue;

    status = VRModifyParameterBox
             ( &retcode,product,&CmpParam,buf_param_id,buf_param_id );
    as$status( action = RET_STATUS );
  }

  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRskxform( msg, xform_matrix, plane_to_move, md_env )

IGRlong 			*msg;
IGRdouble 			*xform_matrix;
struct 		GRid		*plane_to_move;
struct		GRmd_env	*md_env;

/*. VRxform */
{
  IGRshort			mat_type;  /* type of the xform_matrix       */
  IGRlong			status;    /* return code                    */
  IGRlong			retcode;   /* return code                    */
  GRobjid			new_objid; /* used by the xform message      */

  *msg    = MSSUCC;
  retcode = OM_S_SUCCESS;
  status  = OM_S_SUCCESS;

  MAtypemx( &retcode, xform_matrix, &mat_type );

  /*"mat_type = %d\n", mat_type */

  /*^
      {
        IGRint i, j;

        printf("========================================================\n");
        
        printf("XFORM_MATRIX : \n\n");

        for( i=0; i<16; i+=4 )
        {
          for( j=0; j<4; j++ ) printf("%f.. ", xform_matrix[i+j] );
          printf("\n");
        }

        printf("\n");

        printf("========================================================\n");
      }
  */

  /*"plan_to_move = %d\n", plane_to_move->objid */
  /*"md_env = %d %d\n", md_env->md_id.objid, md_env->md_id.osnum */

  status = om$send( msg = message GRgraphics.GRxform
                          ( &retcode, md_env, &mat_type, xform_matrix,
                            &new_objid
                          ),
                    senderid = NULL_OBJID,
                    targetid = plane_to_move->objid, 
                    targetos = plane_to_move->osnum);
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  return OM_S_SUCCESS;

}

/******************************************************************************/
/*									      */
/*	Karine: 20-11-1991 See if the component has free points	  	      */
/*									      */
/******************************************************************************/

VRGetIfConnectable( connectable, ObjId, md_env )

IGRboolean			*connectable;
struct		GRid		*ObjId;
struct		GRmd_env	*md_env;

/*.VRGetIfConnectable */
{
  IGRint		i, NbCpt;
  IGRshort		nStatus; 
  IGRlong		retcode=MSSUCC, status=OM_S_SUCCESS;          
  struct	GRid	SegId;

  *connectable = FALSE;

  /* -- See if it's a correction component -- */
  status = om$send( msg      = message VRGeneric.VRGetStatus(&retcode,&nStatus),
   		    senderid = NULL_OBJID,
                    targetid = ObjId->objid,
                    targetos = ObjId->osnum );
  as$status ( action = RET_STATUS );

  if ( !(nStatus&VR_CORRECTION) )
  {
	/* -- Get number of component connection point -- */
  	status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
					( &retcode, &NbCpt, md_env ),
		 	  senderid = NULL_OBJID,
                	  targetid = ObjId->objid,
		          targetos = ObjId->osnum );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
  
  	/*" NbCpt = %d \n",NbCpt*/

  	/* -- See if these points are already connected or not -- */
  	for( i=0; i<NbCpt; i++ )
  	{
		/*"point : %d \n",i*/
  		status = om$send( msg      = message VRGeneric.VRGetSupOnCpt
            		                     ( &retcode, i, &SegId, md_env ),
                          	  senderid = NULL_OBJID,
		                  targetid = ObjId->objid,
                		  targetos = ObjId->osnum ) ;
  		as$status( action = RET_STATUS ) ;

		if( SegId.objid == NULL_OBJID ) *connectable = TRUE;
	}
  }

  return OM_S_SUCCESS;
}

/******************************************************************************/

VRMergeSegments( p_retmsg, SegNum, p_SegmentsId, p_MdEnv )

IGRlong			*p_retmsg;
IGRint			SegNum;
struct	GRid		*p_SegmentsId;
struct	GRmd_env	*p_MdEnv ;
{
  IGRint		i;
  IGRlong		retcode=MSSUCC, status=OM_S_SUCCESS;
  struct 	GRid 	TmpPrevId, TmpCmpId;

  SetProc( Fn VRMergeSegments ); Begin
  *p_retmsg = MSSUCC;

  __DBGpr_int("seg index passed is %d\n",SegNum);
  for( i=1; i<SegNum; i++ )
  {
        __DBGpr_int("seg index processed is %d\n",i);
        __DBGpr_obj("segobjid",p_SegmentsId[i]);
  	status = om$send( msg      = message VRCnrlSeg.VRnotify_merge( &retcode, p_MdEnv ),
                    	  senderid = NULL_OBJID,
                    	  targetid = p_SegmentsId[i].objid,
                    	  targetos = p_SegmentsId[i].osnum );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );

  	TmpPrevId.objid = NULL_OBJID;    
        __DBGpr_com("VRmerge_segments being called here");
  	status = om$send( msg      = message VRCnrlSeg.VRmerge_segments
                               		( &retcode, &p_SegmentsId[i], p_MdEnv, &TmpPrevId, &TmpCmpId ),
                    	  senderid = NULL_OBJID,
                    	  targetid = p_SegmentsId[0].objid,
                    	  targetos = p_SegmentsId[0].osnum );
   	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
        __DBGpr_obj("TmpPrevId",TmpPrevId);
        __DBGpr_obj("TmpCmpId",TmpCmpId);
  }
  
  __DBGpr_com("calling NDs_compute_node using p_SegmentsId[0]");
  status = om$send( msg      = message NDnode.NDs_compute_node( &retcode, 0, p_MdEnv ),
                    senderid = NULL_OBJID,
                    targetid = p_SegmentsId[0].objid,
                    targetos = p_SegmentsId[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  __DBGpr_com("ComputeCorrection called here");
  status = VR$ComputeCorrection( 	p_retmsg	= &retcode,
					CorType		= VR_UNKNOWN,
 					p_SegmentId	= &p_SegmentsId[0],
 					p_MdEnv		= p_MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  End
  return(OM_S_SUCCESS);

}

/*****************************************************************************/
/* given two lists of planes, this function takes all dependent objects of each
/* plane in SrcPlanesId list and connects them to the correcponding one in
/* NewPlanesId list
/**/

VRskUpdateConnection( SrcPlanesId, NewPlanesId, NbPlanes )

struct	GRid		*SrcPlanesId;
struct	GRid		*NewPlanesId;
IGRint			NbPlanes;
{
IGRint	                mode_batch;	   /* mode batch                     */
IGRint 			cn_type = ND_COMP;
					   /* used by wait_batch macro       */
IGRint 			i, j, nb_children;
                                           /* used by get_objects message    */
IGRlong 		status;   	   /* return code                    */
struct 	GRid 		*p_CsBuffer;
                                           /* used by get_objects            */

  SetProc( Fn VRSkUpdateConnection ); Begin  
  nd$mod_batch( request    = ND_GET,
                p_ret_mode = &mode_batch );

  __DBGpr_int("NbPlanes",NbPlanes);
  for(i=0; i<NbPlanes; i++)
  {
    if( SrcPlanesId[i].objid != NewPlanesId[i].objid )
    {
      /*"old[%d] = %d\n", i, SrcPlanesId[i].objid */
      /*"new[%d] = %d\n", i, NewPlanesId[i].objid */

      __DBGpr_obj("Get children of old plane",SrcPlanesId[i]);
      /* get the dangling parent segment's id */
      status =
      om$send( msg      = message NDnode.NDget_objects
                                   	( ND_CHILDREN|ND_IN_BUF,NULL,0,
					&p_CsBuffer,0,OM_K_MAXINT,
					&nb_children ),
               senderid = NULL_OBJID,
               targetid = SrcPlanesId[i].objid,
               targetos = SrcPlanesId[i].osnum );
      as$status();
/*
 printf("src_pl= %d .. nb_of_cs = %d\n", SrcPlanesId[i].objid, nb_children);
*/
#ifdef vdsDEBUG
        for( j=0; j<nb_children; j++ )
        {
            printf("cs[%d] = %d\n", j, p_CsBuffer[j].objid );
        }
#endif
      for( j=0; j<nb_children; j++ )
      {
#ifdef vdsDEBUG
        printf("objid %d is child %d of %d is now a child of %d\n",
                p_CsBuffer[j].objid, j,  SrcPlanesId[i].objid,NewPlanesId[i].objid);
#endif
        /*"cs[%d] = %d\n", j, p_CsBuffer[j].objid */

        status = om$send( msg      = message NDnode.NDchange_connect
                                     ( 1, &SrcPlanesId[i], &NewPlanesId[i] ),
                          senderid = NULL_OBJID,
                          targetid = p_CsBuffer[j].objid, 
                          targetos = p_CsBuffer[j].osnum);
        as$status();

        nd$wait_batch( type       = GR_GEOM_POSTED,
                       l_object   = &p_CsBuffer[j],
               	       l_obj_info = &cn_type,
               	       nb_obj     = 1 );
      }
    }
  }

  if( mode_batch != ND_DEFER ) nd$exec_batch();

  End
  return OM_S_SUCCESS;
}

/*************************************************************************/
/*									 */
/*		Karine : 25 - 10 - 1991 				 */
/*									 */	
/*     Function called by VRsketch.sl to put the gadget in Read only or  */
/*     Read Write mode							 */
/*								 	 */
/*************************************************************************/

VRSkSetFormMode( IGRshort		Product,
		IGRint			Mode
		)

/*.VRSkSetFormMode */
{
	IGRlong 	status;
 	Form		FormPtr;


	switch(Product)
        {
		case VR_PIPING :
			status = FI_get_form_by_name( "VRPpDgPar", &FormPtr);
			if( status == FI_SUCCESS )
                        {
				FIfld_set_mode(FormPtr, NOM_PIPE_DIAM, 0, Mode);
				FIfld_set_mode(FormPtr, LINE_SEQ_NO, 0, Mode);	
				FIg_display(FormPtr,NOM_PIPE_DIAM );
				FIg_display(FormPtr,LINE_SEQ_NO );
			}
			break;

		case VR_HVAC :
			status = FI_get_form_by_name("VRHvDgPar", &FormPtr);
			if( status == FI_SUCCESS )
			{
				if ( Mode == FI_REVIEW )
				{
				FIg_disable(FormPtr, RECTANGULAR_SHAPE);	
				FIg_disable(FormPtr, OVAL_SHAPE);	
				FIg_disable(FormPtr, CIRCULAR_SHAPE);	
				FIg_disable(FormPtr, RADIUS_SHAPE);	
				}
				else
				{
                                FIg_enable(FormPtr, RECTANGULAR_SHAPE);
				FIg_enable(FormPtr, OVAL_SHAPE);
                                FIg_enable(FormPtr, CIRCULAR_SHAPE);
                                FIg_enable(FormPtr, RADIUS_SHAPE);
				}
				FIfld_set_mode(FormPtr, W_SIZE, 0, Mode);
				FIfld_set_mode(FormPtr, D_SIZE, 0, Mode);
                                FIfld_set_mode(FormPtr, THROAT_RADIUS, 0, Mode);
                                FIfld_set_mode(FormPtr, TRANS_LENGTH, 0, Mode);
				FIg_display(FormPtr, W_SIZE );
				FIg_display(FormPtr, D_SIZE );
                                FIg_display(FormPtr, THROAT_RADIUS );
                                FIg_display(FormPtr, TRANS_LENGTH );

			}
			break;

		case VR_CABLING :
			status = FI_get_form_by_name("VRRwDgPar", &FormPtr);
			if( status == FI_SUCCESS )
			{
				
                                /* Below modified for CR179309874 -
                                                       New raceway shapes */
				if ( Mode == FI_REVIEW )
				{
				FIg_disable(FormPtr, RECTANGULAR_SHAPE);	
				FIg_disable(FormPtr, CIRCULAR_SHAPE);
				FIg_disable(FormPtr, OVAL_SHAPE);	
				FIg_disable(FormPtr, ELLP_SHAPE);	
				FIg_disable(FormPtr, RADIUS_SHAPE);	
                                FIfld_set_mode(FormPtr, D_SIZE, 0, Mode);
				}
				else
				{
				FIg_enable(FormPtr, RECTANGULAR_SHAPE);
                                FIg_enable(FormPtr, CIRCULAR_SHAPE);
				FIg_enable(FormPtr, OVAL_SHAPE);
                                FIg_enable(FormPtr, ELLP_SHAPE);
                                FIg_enable(FormPtr, RADIUS_SHAPE);
				FIg_display(FormPtr, RECTANGULAR_SHAPE);
                                FIg_erase(FormPtr, CIRCULAR_SHAPE);
				FIg_erase(FormPtr, OVAL_SHAPE);
                                FIg_erase(FormPtr, ELLP_SHAPE);
                                /* Tier added for CR179801144 */
                                FIg_display(FormPtr, N_TIER_DG);
                                FIg_display(FormPtr, SP_TIER_DG);
                                FIfld_set_mode(FormPtr, D_SIZE, 0, FI_REVIEW);
                                FIg_erase(FormPtr, RADIUS_SHAPE);

				}
				FIfld_set_mode(FormPtr, W_SIZE, 0, Mode);
				FIg_display(FormPtr, W_SIZE );
				FIg_display(FormPtr, D_SIZE );
			}
			break;
		
			default : break ;
	}

	return OM_S_SUCCESS;
}

/**********************************************************************/
/*								      */
/*								      */
/*	Karine: 7 - 11 - 1991					     */
/*								     */
/*     Special display for a specified angle in Skewed Mode          */
/*								     */
/*********************************************************************/

VRskdisplay_angle( angle, prev_pt, first_pt, projpt, z_win )

IGRdouble angle, *prev_pt, *first_pt, *projpt, *z_win;

{
   IGRint	i;
   IGRdouble	dForcedDir[3], dDirCursor[3];
   IGRdouble	normal[3];
   IGRdouble	direction[2][3];
   IGRdouble	line_pt1[3];
   IGRdouble	pt_result[6];
   IGRdouble	min_distance;
   IGRlong	rc;
   struct       IGRline		line0, line1;
   struct	IGRline		*line[2];


    /* -- Build segment's direction -- */
    for (i= 0; i<3; i++) 
    {
    	dDirCursor[i] = projpt[i] - first_pt[i];
    }
    BSnorvec( &rc, dDirCursor );
    /*"Direction cursor = %f %f %f\n", dDirCursor[0], dDirCursor[1], dDirCursor[2]*/


    /* -- Compute rotated direction -- */
    for (i=0; i<3; i++)
    {
     	direction[0][i] = prev_pt[i];
    	direction[1][i] = first_pt[i];
    }
    BSproj0( &rc, projpt, direction, dForcedDir);


    /* -- Go back to vectoriel world -- */
    for (i= 0; i<3; i++) 
    	dForcedDir[i] = dForcedDir[i] - first_pt[i];
    BSnorvec( &rc, dForcedDir );
    /*"dForcedDir = %f %f %f\n", dForcedDir[0], dForcedDir[1], dForcedDir[2]*/


    /* -- Compute rotation axis -- */
    BScrossp ( &rc, dForcedDir, dDirCursor, normal);
    BSnorvec( &rc, normal );
    /*"Normal = %f %f %f\n", normal[0], normal[1], normal[2]*/


    /* -- Rotate direction -- */
    {
	/*C Fix for TR#179415653	: Manyam */
	IGRboolean	bBooleanVar=TRUE;
	IGRdouble	dOrig[3], dAngle;

	dAngle = angle;
	dOrig[0]=dOrig[1]=dOrig[2]=0.0;
	BSroto( &rc, dOrig, normal , &bBooleanVar, &dAngle,
		dForcedDir,dForcedDir );  
     }

    for (i= 0; i<3; i++) 
    	dForcedDir[i] = dForcedDir[i] + first_pt[i];

    line0.point1 = first_pt;
    line0.point2 = dForcedDir;
    line1.point1 = projpt;
    line1.point2 = line_pt1;
    line[0]      = &line0;
    line[1]      = &line1;
   
    line_pt1[0]  = projpt[0] + 50 * z_win[0];
    line_pt1[1]  = projpt[1] + 50 * z_win[1];
    line_pt1[2]  = projpt[2] + 50 * z_win[2];

    BSint2lns( line, (IGRpoint *)pt_result, &min_distance, &rc );

    if( rc != BSPARALLEL )
    {
    	projpt[0] = pt_result[0];
    	projpt[1] = pt_result[1];
    	projpt[2] = pt_result[2];
    }

   return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

VRSkGetJustif( IGRshort 			Product,
		struct		GRid		*p_MyParamId,
		struct		GRmd_env	*p_MdEnv
		)

/*.VRSkGetJustif */
{
  struct	GRid		ActParamId;
  union 	VRparam_attr	Param, Param1;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  IGRshort			ByCpt0=0;
  IGRshort			ByCpt1=1;
  IGRshort			Justif;

  Justif = ByCpt0;

  if( Product == VR_PIPING )
  {
  	/*| get dimension Attributes from given system collection */
        status = VR$GetDimensionAttributes(	p_retmsg	  = &retcode,
						Product		  = Product,
						p_SysCollectionId = p_MyParamId,
						p_DimAttributes	  = &Param,
       						p_MdEnv	  	  = p_MdEnv );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );

	/* get system active collection */
  	status = VR$GetAttributes( 	p_retmsg	= &retcode,
				   	Product		= Product,
					p_SysParamId	= &ActParamId,
             				p_MdEnv		= p_MdEnv );
  	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );
    	
  	/*| get dimension Attributes from system active collection */
  	status = VR$GetDimensionAttributes(	p_retmsg	  = &retcode,
						Product		  = Product,
						p_SysCollectionId = &ActParamId,
						p_DimAttributes	  = &Param1,
             					p_MdEnv	  	  = p_MdEnv );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );

  	/*"g_diam = %f\n", Param.piping_attr.G_diameter */
  	/*"r_diam = %f\n", Param.piping_attr.R_diameter */
  	/*"g_diam = %f\n", Param1.piping_attr.G_diameter */
  	/*"r_diam = %f\n", Param1.piping_attr.R_diameter */
/****
  	if( ( Param.piping_attr.G_diameter != Param.piping_attr.R_diameter  ) 
		&& ( Param.piping_attr.R_diameter == Param1.piping_attr.G_diameter ) ) Justif = ByCpt1;
****/
        /*law  Double value comparison problem tr179900932 cleanup */
        if(( VRdbls_not_equal(Param.piping_attr.G_diameter,
                                Param.piping_attr.R_diameter  ))
                && ( VRdbls_are_equal(Param.piping_attr.R_diameter,
		     Param1.piping_attr.G_diameter))) Justif = ByCpt1;
  }
   
  /*"justif = %d\n", Justif */

  return( Justif );
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*** Modified for CR179900491 ***/
VRSkUpdateForm( IGRint			product,
		IGRchar 		*FormPtr,
		IGRint			*ShapeGadget,
		struct		GRid	*ParamId,
		IGRchar 		*AABBCCode,
		IGRint			*active_cpt,
                struct VRRwCptDetails  *RWcptdata,
		struct GRmd_env		*md_env,
		IGRshort		SketchMode)
		
/*.VRSkUpdateForm */
{
  struct	ACrg_coll	Attr;
  IGRlong			status, retmsg;
  IGRint			i, int_conv;
  IGRdouble			size_g, size_r;
  IGRchar			specname[15];
  IGRchar                       pathname[OM_K_MAXOSNAME_LEN];
/* TR-MP4140 - expand optcode to 80 characters */
  IGRchar			optcodes[VR_MAX_OPTCODE_SIZE][81];
  IGRshort    			*opt_codes;
  IGRchar     			*opt_txt;
  IGRshort    			opt_cnt;
  IGRint  NbCpts;
  struct       GRid             ExpressionId;

  SetProc( Fn VRSkUpdateForm ); Begin 

  __DBGpr_com("--------------------------------------------");
  switch( product )
  {
  	case VR_PIPING :
		status=
		VR$DispCollAttr ( pForm 	= FormPtr,
			  	  pCollId	= ParamId,
			  	  Gadget	= LINE_SEQ_NUM,
			  	  pAttrName 	= VR_N_SEQ_NUMBER_AN);

		status=
		VR$DispCollAttr ( pForm 	= FormPtr,
			  	  pCollId	= ParamId,
			  	  Gadget	= PP_DIAM,
			  	  pAttrName 	= VR_N_GDIAMETER_DB);

		status=
                VR$DispCollAttr ( pForm         = FormPtr,
                                  pCollId       = ParamId,
                                  Gadget        = SK_PID_SCALE,
                                  pAttrName     = VR_N_PID_SCALE_DB);
                /* added by alwin for CR179300978 */
                /* Setting the Option Codes in the List */
                strcpy( Attr.name, VR_N_GDIAMETER_DB );
                status =
                om$send ( msg = message ACrg_collect.ACget_named_attribute(
                                           &retmsg, &Attr ),
                                 senderid = NULL_OBJID,
                                 targetid = ParamId->objid,
                                 targetos = ParamId->osnum );
                as$status( );
 
                size_g = Attr.desc.value.att_exp;
                strcpy( Attr.name, VR_N_CLASS_AN );
                status =
                om$send ( msg = message ACrg_collect.ACget_named_attribute(
                                           &retmsg, &Attr ),
                                 senderid = NULL_OBJID,
                                 targetid = ParamId->objid,
                                 targetos = ParamId->osnum );
                as$status( );
 
                strcpy(specname, Attr.desc.value.att_txt );
                status = VRget_opt_code_txt( &retmsg, VR_PIPING, "PIPING",
                               specname, size_g, size_g, &opt_codes,
                               &opt_txt, &opt_cnt, NULL);
 
                if( status&1 )
                {
                   /* Option Code gadget label = 50 add this in VRsketchdef.h */
                   FIfld_set_list_num_rows( FormPtr, PIPING_OPTION, 0, opt_cnt);
                   for( i=0; i< opt_cnt; i++ )
                   {
                     IGRlong   msg;
                     IGRchar   p_error[30];
 
                     /* TR-MP4140 - initialize o_lname for no-match */
                     optcodes[i][0] = '\0';
                     status = vd$get_alias ( p_msg     = &msg,
                                              product  = PIPING,
                                              type     = VR_OPTCODE_LIST_NUM,
                                              i_code   = (IGRint) opt_codes[i],
                                              o_lname  =  optcodes[i],
                                              p_error  = p_error       );
 
                     if ( !strlen( optcodes[i]) )
                       sprintf( optcodes[i], "%d", opt_codes[i] );
                     VDfld_set_list_text( FormPtr, PIPING_OPTION, i, 0,
                                          optcodes[i], FALSE);
                   }
                 }
                 opt_codes     = NULL ;
                 opt_txt       = NULL ;

                 /* Get the Current Working Directory */
                 status = di$pwd( dirname = pathname );
 
                 /* Setting it to the HOME directory i.e ":filename:usr" */
                 // This variable "DIR_G_home_name" is defined in DIglob.h file
                 // gives the HOME DIRECTORY
                 status = di$cd( dirname = DIR_G_home_name );
 
                 /* Get the ExpressionId if it is already created in the
                    Directory Subsystem */
                 status = di$translate(
                                  objname = "piping_option_code",
                                  p_objid = &ExpressionId.objid,
                                  p_osnum = &ExpressionId.osnum );
 
                 if( ExpressionId.objid != NULL_OBJID )
                 {
                    IGRchar opt_code[81];
                    struct ret_struct ExprSt;
 
                    status =
                    om$send ( msg = message NDnode.NDgive_structure(
                                         &retmsg, &ExprSt, NULL ),
                           senderid = NULL_OBJID,
                           targetid = ExpressionId.objid,
                           targetos = ExpressionId.osnum );
                    as$status ();
 
                    strcpy( opt_code, ExprSt.var.text_st.text_string );
                    FIfld_set_text( FormPtr, PIPING_OPTION, 0, 0, opt_code, FALSE );
                 }
 
                 /* Re-Setting it to the PWD directory  */
                 status = di$cd( dirname = pathname );
                 /* End added by alwin for CR179300978 */

		break;

        case VR_CABLING :
                /* Below modified for CR179701945 - Add Throat radius */
                /*** Below Modified for CR179900491 ***/

		__DBGpr_com(" Reached the Raceway case " );
                status=
                VR$DispCollAttr ( pForm         = FormPtr,
                                  pCollId       = ParamId,
                                  Gadget        = HV_THROAT_RADIUS,
                                  pAttrName     = VR_N_THROAT_DB);
  
                status=
                VR$DispCollAttr ( pForm         = FormPtr,
                                  pCollId       = ParamId,
                                  Gadget        = HV_TRAN_LENGTH,
                                  pAttrName     = VR_N_TRANS_L_DB);
		status=
		VR$DispCollAttr ( pForm 	= FormPtr,
			  	  pCollId	= ParamId,
			  	  Gadget	= LINE_SEQ_NUM,
			  	  pAttrName 	= VR_N_SEQ_NUMBER_AN);
/*** added for tr179900932 cleanup ***/
		status=
		VR$DispCollAttr ( pForm 	= FormPtr,
			  	  pCollId	= ParamId,
			  	  Gadget	= CORN_RAD,
			  	  pAttrName 	= VR_N_CORN_RAD_DB);

                /*** Below Modified for CR179900491 ***/
     		strcpy(Attr.name, VR_N_SHAPE_IN);
		status =
		om$send( msg = message ACrg_collect.ACget_named_attribute
							( &retmsg, &Attr ),
			senderid = NULL_OBJID,
			targetid = ParamId->objid,
			targetos = ParamId->osnum );
       		as$status( action = RET_STATUS );
    		int_conv = (IGRint) Attr.desc.value.att_exp;
                if(int_conv == VR_RECT)
                {
                  FIg_display(FormPtr,FRM_NO_TIER_1);
                  FIg_display(FormPtr,FRM_TIER_SP_1);
                  FIg_display( FormPtr, N_TIER_SK1_TEXT );
                  FIg_display( FormPtr, SP_TIER_SK1_TEXT );
                }
                else
                {
                  FIg_erase( FormPtr, N_TIER_SK1_TEXT );
                  FIg_erase( FormPtr, SP_TIER_SK1_TEXT );
                  FIg_erase( FormPtr, N_TIER_SK2_TEXT );
                  FIg_erase( FormPtr, SP_TIER_SK2_TEXT );
                  FIg_erase(FormPtr,FRM_TIER_SP_1);
                  FIg_erase(FormPtr,FRM_TIER_SP_2);
                  FIg_erase(FormPtr,FRM_NO_TIER_1);
                  FIg_erase(FormPtr,FRM_NO_TIER_2);
                }

                /*** Below Modified for CR179900491 ***/
                __DBGpr_com("displaying tier collector here");

                if(SketchMode == VR_MANUAL)
                {
                  IGRchar spec_name[120];
                  IGRlong longmsg,mm;
                  struct ret_struct       ParamAttr;
                  IGRint                  FootIndex = -1, retstatus;

                  if(int_conv == VR_RECT)
                  {
                    FIg_display(FormPtr,N_TIER_SK2_TEXT);
                    FIg_display(FormPtr,SP_TIER_SK2_TEXT);
                    FIg_display(FormPtr,FRM_TIER_SP_2);
                    FIg_display(FormPtr,FRM_NO_TIER_2);


                  }
                  *active_cpt = 2;
                  __DBGpr_com(
                    "Pushing green cpt into all other cpts for the component");
                  status =
                        om$send( msg      = message ACncpx.ACgive_structure
                                 ( &retstatus,
                                   &FootIndex,
                                   VR_N_CLASS_AN,
                                   &ParamAttr,
                                   md_env),
                        senderid = NULL_OBJID,
                        targetid = ParamId->objid,
                        targetos = ParamId->osnum );
                  strcpy (spec_name,ParamAttr.var.text_st.text_string);
                   __DBGpr_str("spec_name",spec_name);
                   __DBGpr_str("AABBCCode",AABBCCode);

                  /* The following condition added by alwin to send the
                  proper shape_code in the case of the Transition Components*/
                  __DBGpr_int( " Shape Gadget ", *ShapeGadget );

                  if( ( *ShapeGadget == VR_RECT_CIRC ) ||
                      ( *ShapeGadget == VR_RECT_OVAL ) ||
                      ( *ShapeGadget == VR_RECT_CORN ) ||
                      ( *ShapeGadget == VR_RECT_ELLP ) ||
                      ( *ShapeGadget == VR_OVAL_CIRC ) ||
                      ( *ShapeGadget == VR_OVAL_CORN ) ||
                      ( *ShapeGadget == VR_OVAL_ELLP ) ||
                      ( *ShapeGadget == VR_CIRC_CORN ) ||
                      ( *ShapeGadget == VR_ELLP_CORN ) ||
                      ( *ShapeGadget == VR_CIRCULAR_ELLP )  ) /* tr179900976 */
                  {
/*                     int_conv = *ShapeGadget; *** Deleted tr179900780 ***/
                     /*** confusion between shape gadget and shape codes ***/
                     /*** Added for TR179900780 ***/
                     if(AABBCCode[0] != '\0')
                     {
                        IGRshort bIsTransition;
                        IGRint locshape_code;
                        /* tr179900985 - added product to arguments */
                        status = VRGetShapeFrmCompCode (  AABBCCode,
                                                          &bIsTransition,
                                                          &locshape_code,
                                                          product );
                        /***** tr179900976 ****/
                        if(bIsTransition)
                        {
                            int_conv = locshape_code;
                        } 
                     }
                  }

                  /*** Get the number of cpts to store */
		  if(AABBCCode[0] != '\0')
		  {
		      status = VRGetComp_NbCpt( &longmsg, (IGRshort) product,
			      			int_conv,spec_name,
						AABBCCode, &NbCpts);
		  }
                  __DBGpr_int("---------------NbCpts----------------",NbCpts);
                  if(NbCpts < 1 || NbCpts > 10)
                  NbCpts = 10;

                  __DBGpr_com("initializing instance by VRRw_dimen_fields");
                  for(mm=1; mm<NbCpts; mm++)
                  {
                    RWcptdata[mm] = RWcptdata[0];
                    __DBGpr_int("cpt copied from 0",mm);
                    __DBGpr_int("no tiers copied",RWcptdata[mm].nb_tier);
                  }

                }
                else
                {
                  *active_cpt = 1;
                  NbCpts = 2;
                  __DBGpr_com( " Calling34 VRRw_dimen_fields ");
                  /* shape management for transitions-tr179900976 */
                  if(AABBCCode[0] != '\0')
                  {
                        IGRshort bIsTransition;
                        IGRint locshape_code;
                        /* tr179900985 - added product to arguments */
                        status = VRGetShapeFrmCompCode (  AABBCCode,
                                                          &bIsTransition,
                                                          &locshape_code,
                                                          product );
                        if(bIsTransition) /* A little overkill */
                        {
                            int_conv = locshape_code;
                        }
                  }

                  status = VRRw_dimen_fields(0, 0, NULL, md_env, NbCpts,
                      0, 0, int_conv, RWcptdata,
                      ParamId);
                }
                __DBGpr_com("display instance by VRRw_dimen_fields");
                __DBGpr_com( " Calling35 VRRw_dimen_fields ");
                status = VRRw_dimen_fields(FormPtr, 0, NULL, md_env, NbCpts,
                      active_cpt, 1, int_conv, RWcptdata,
                      ParamId);
                __DBGpr_com("back from VRRw_dimen_fields display");
    		{
                /* transition tests modified for tr179900976 ***/
                if(int_conv == VR_RECT_CIRC ||
                   int_conv == VR_RECT_OVAL ||
                   int_conv == VR_RECT_CORN ||
                   int_conv == VR_RECT_ELLP ||
                   int_conv == VR_OVAL_CIRC ||
                   int_conv == VR_OVAL_CORN ||
                   int_conv == VR_OVAL_ELLP ||
                   int_conv == VR_CIRC_CORN ||
                   int_conv == VR_CIRCULAR_ELLP ||
                   int_conv == VR_ELLP_CORN )
                        {
                           __DBGpr_com( " Its a SHAPE TRANSITION COMPONENT " );
                           FIg_erase( FormPtr,ACTIVE_CPT_INDEX );
                           FIg_erase( FormPtr,ACTIVE_CPT_INDEX_TEXT );
                           FIg_erase( FormPtr,DECREASE_ACTIVE_CPT_INDEX );
                           FIg_erase( FormPtr,INCREASE_ACTIVE_CPT_INDEX );

                           FIg_erase( FormPtr,FRM_TIER_SP_2 );
                           FIg_erase( FormPtr,FRM_NO_TIER_2 );
                           FIg_erase( FormPtr,N_TIER_SK2_TEXT );
                           FIg_erase( FormPtr,SP_TIER_SK2_TEXT );

                           /* transition tests Added for tr179900976 ***/
                           if(int_conv == VR_RECT_CIRC)
                           {
				FIg_erase( FormPtr, RW_R_SHAPE );
				FIg_display( FormPtr, RW_C_SHAPE );
                                FIg_erase( FormPtr , RW_D_TXT );
                                FIg_erase( FormPtr , RW_DEPTH );
	 			*ShapeGadget = RW_C_SHAPE;
                           }
                           else if(int_conv == VR_RECT_OVAL)
                           {
				FIg_erase( FormPtr, RW_R_SHAPE );
				FIg_display( FormPtr, RW_O_SHAPE );
	 			*ShapeGadget = RW_O_SHAPE;
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
                           }
                           else if(int_conv == VR_RECT_CORN)
                           {
				FIg_erase( FormPtr, RW_R_SHAPE );
				FIg_display( FormPtr, RW_RS_SHAPE );
	 			*ShapeGadget = RW_RS_SHAPE;
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
                                FIg_display(FormPtr,CORN_RAD);
                                FIg_display(FormPtr,CORN_RAD_TXT);
                           }
                           else if(int_conv == VR_RECT_ELLP)
                           {
				FIg_erase( FormPtr, RW_R_SHAPE );
				FIg_display( FormPtr, RW_E_SHAPE );
	 			*ShapeGadget = RW_E_SHAPE;
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
                           }
                           else if(int_conv == VR_OVAL_CIRC)
                           {
				FIg_erase( FormPtr, RW_C_SHAPE );
				FIg_display( FormPtr, RW_O_SHAPE );
				FIg_display( FormPtr, RW_DEPTH );
                                FIg_display( FormPtr , RW_D_TXT );
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
	 			*ShapeGadget = RW_O_SHAPE;
                           }
                           else if(int_conv == VR_OVAL_CORN)
                           {
				FIg_erase( FormPtr, RW_O_SHAPE );
				FIg_display( FormPtr, RW_RS_SHAPE );
	 			*ShapeGadget = RW_RS_SHAPE;
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
                                FIg_display(FormPtr,CORN_RAD);
                                FIg_display(FormPtr,CORN_RAD_TXT);
                           }
                           else if(int_conv == VR_OVAL_ELLP)
                           {
				FIg_erase( FormPtr, RW_O_SHAPE );
				FIg_display( FormPtr, RW_E_SHAPE );
	 			*ShapeGadget = RW_E_SHAPE;
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
                           }
                           else if(int_conv == VR_CIRC_CORN)
                           {
				FIg_erase( FormPtr, RW_C_SHAPE );
				FIg_display( FormPtr, RW_RS_SHAPE );
	 			*ShapeGadget = RW_RS_SHAPE;
                                FIg_display( FormPtr , RW_D_TXT );
                                FIg_display( FormPtr , RW_DEPTH );
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
                                FIg_display(FormPtr,CORN_RAD);
                                FIg_display(FormPtr,CORN_RAD_TXT);
                           }
                           else if(int_conv == VR_ELLP_CORN)
                           {
				FIg_erase( FormPtr, RW_E_SHAPE );
				FIg_display( FormPtr, RW_RS_SHAPE );
	 			*ShapeGadget = RW_RS_SHAPE;
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
                                FIg_display(FormPtr,CORN_RAD);
                                FIg_display(FormPtr,CORN_RAD_TXT);
                           }
                           else if(int_conv == VR_CIRCULAR_ELLP)
                           {
				FIg_erase( FormPtr, RW_C_SHAPE );
				FIg_display( FormPtr, RW_E_SHAPE );
	 			*ShapeGadget = RW_E_SHAPE;
                                FIg_display( FormPtr , RW_DEPTH );
                                FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_INSERT);
                                FIg_display( FormPtr , RW_D_TXT );
                           }

                        }

                        /*Below modified for CR179309874 - New raceway shapes */
      			else if( int_conv == VR_CIRC)
                        {
				__DBGpr_com(" shape is Circular " );
				FIg_erase( FormPtr, RW_R_SHAPE );
				FIg_erase( FormPtr, RW_E_SHAPE );
				FIg_erase( FormPtr, RW_O_SHAPE );
				FIg_erase( FormPtr, RW_RS_SHAPE );
				FIg_display( FormPtr, RW_C_SHAPE );
	 			*ShapeGadget = RW_C_SHAPE;
				// ADDED for TR179801150
				//Set the Race way Depth gadget to  REVIEW mode

				FIfld_set_mode(FormPtr, RW_DEPTH, 0, FI_REVIEW);
                                FIg_erase( FormPtr,RW_DEPTH); /*tr179900780*/
			/* As the above function is taking time to get 
	        	   REVIEW mode,FIg_display function is incorporated 
			   Added for TR179801149                          */     
/*				FIg_display( FormPtr, RW_DEPTH ); */
				FIfld_set_mode(FormPtr, SMALL_RW_DEPTH, 0,
				                                FI_REVIEW);
                                /* tr179900780 **/
                                FIg_erase( FormPtr,SMALL_RW_DEPTH);
				//Above lines are added for the TR179801150
				/* display added with CR179801144 */
/*
                                if( SketchMode == VR_MANUAL )
				{
				   FIg_display( FormPtr, SMALL_RW_DEPTH );
				}
*/
	 			*ShapeGadget = RW_C_SHAPE;
        		}

      			else if (int_conv == VR_CORNER)
                        {
				__DBGpr_com(" shape is Square Corner " );
				FIg_erase( FormPtr, RW_R_SHAPE );
				FIg_erase( FormPtr, RW_E_SHAPE );
				FIg_erase( FormPtr, RW_O_SHAPE );
				FIg_erase( FormPtr, RW_C_SHAPE );
				FIg_display( FormPtr, RW_RS_SHAPE );
	 			*ShapeGadget = RW_RS_SHAPE;
				//added for TR179801150
				 FIfld_set_mode(FormPtr, SMALL_RW_DEPTH,
				                          0, FI_INSERT);
				/* display added with CR179801144 */
                                if( SketchMode == VR_MANUAL )
				{
				   FIg_display( FormPtr, SMALL_RW_DEPTH );
				}

        		}

                        /* Below added for CR179309874 - New raceway shapes */

      			else if(int_conv == VR_OVAL)
                        {
				__DBGpr_com(" shape is Oval " );
				FIg_erase( FormPtr, RW_R_SHAPE );
				FIg_erase( FormPtr, RW_E_SHAPE );
				FIg_erase( FormPtr, RW_C_SHAPE );
				FIg_erase( FormPtr, RW_RS_SHAPE );
				FIg_display( FormPtr, RW_O_SHAPE );
	 			*ShapeGadget = RW_O_SHAPE;

				//added for TR179801150
				 FIfld_set_mode(FormPtr, SMALL_RW_DEPTH,
				                          0, FI_INSERT);
				/* display added with CR179801144 */
                                if( SketchMode == VR_MANUAL )
				{
				   FIg_display( FormPtr, SMALL_RW_DEPTH );
				}
        		}

      			else if(int_conv == VR_ELLIPSE)
                        {
				__DBGpr_com(" shape is Ellipse " );
				FIg_erase( FormPtr, RW_R_SHAPE );
				FIg_erase( FormPtr, RW_O_SHAPE );
				FIg_erase( FormPtr, RW_C_SHAPE );
				FIg_erase( FormPtr, RW_RS_SHAPE );
				FIg_display( FormPtr, RW_E_SHAPE );
	 			*ShapeGadget = RW_E_SHAPE;

				//added for TR179801150
				 FIfld_set_mode(FormPtr, SMALL_RW_DEPTH,
				                          0, FI_INSERT);
				/* display added with CR179801144 */
                                if( SketchMode == VR_MANUAL )
				{
				   FIg_display( FormPtr, SMALL_RW_DEPTH );
				}
        		}
			else /* case VR_RECT: */
                        {
                        /** ASSUMPTION OF RECTANGULAR SHAPE  **/
				__DBGpr_com(" shape is Rectangle " );
				FIg_erase( FormPtr, RW_C_SHAPE );
				FIg_erase( FormPtr, RW_E_SHAPE );
				FIg_erase( FormPtr, RW_O_SHAPE );
				FIg_erase( FormPtr, RW_RS_SHAPE );
				FIg_display( FormPtr, RW_R_SHAPE );
	 			*ShapeGadget = RW_R_SHAPE;

				//added for TR179801150
				 FIfld_set_mode(FormPtr, RW_DEPTH, 0, 
							FI_REVIEW);
			/* As the above function is taking time to get 
			   REVIEW mode,FIg_display function is incorporated*/      
				 FIg_display( FormPtr, RW_DEPTH );
				 FIfld_set_mode(FormPtr, SMALL_RW_DEPTH,
				                          0, FI_REVIEW);
				/* display added with CR179801144 */
				if( SketchMode == VR_MANUAL )
				{
				   FIg_display( FormPtr, SMALL_RW_DEPTH );
				}
                                if(int_conv != VR_RECT)
                                {
	           		strcpy(Attr.name, VR_N_SHAPE_IN);
				Attr.desc.type = AC_ATTRIB_DOUBLE;
				Attr.desc.value.att_exp = 0.;	/* Ask Bruno */
                                __DBGpr_com("modified collection here");
				status = VRModifyCollection( &retmsg,
                                                VR_UPDATE_COLL, VR_RG_COLL,
                                                 NULL, &Attr,1,ParamId);
                                }
         		}

  		} /*** end processing different shape codes ***/
	break;

    	case VR_HVAC :
		status=
		VR$DispCollAttr ( pForm 	= FormPtr,
			  	  pCollId	= ParamId,
			  	  Gadget	= HV_WIDTH,
			  	  pAttrName 	= VR_N_WIDTH1_DB);

		VR$DispCollAttr ( pForm 	= FormPtr,
			  	  pCollId	= ParamId,
			  	  Gadget	= HV_DEPTH,
			  	  pAttrName 	= VR_N_DEPTH1_DB);

		status=
                VR$DispCollAttr ( pForm         = FormPtr,
                                  pCollId       = ParamId,
                                  Gadget        = HV_SYMB_SCALE,
                                  pAttrName     = VR_N_PID_SCALE_DB);
		status=
		VR$DispCollAttr ( pForm 	= FormPtr,
			  	  pCollId	= ParamId,
			  	  Gadget	= LINE_SEQ_NUM,
			  	  pAttrName 	= VR_N_SEQ_NUMBER_AN);
 /*** Added for tr179900780 ***/
                status=
                VR$DispCollAttr ( pForm         = FormPtr,
                                  pCollId       = ParamId,
                                  Gadget        = CORN_RAD,
                                  pAttrName     = VR_N_CORN_RAD_DB);
                status=
                VR$DispCollAttr ( pForm         = FormPtr,
                                  pCollId       = ParamId,
                                  Gadget        = HV_THROAT_RADIUS,
                                  pAttrName     = VR_N_THROAT_DB);
  
                status=
                VR$DispCollAttr ( pForm         = FormPtr,
                                  pCollId       = ParamId,
                                  Gadget        = HV_TRAN_LENGTH,
                                  pAttrName     = VR_N_TRANS_L_DB);


		/*C add if not found : Confirm with bruno : NYC */
		if ( !( status&1 ) )
		{
			strcpy(Attr.name, VR_N_PID_SCALE_DB);
			Attr.desc.type = AC_ATTRIB_DOUBLE;
			Attr.desc.value.att_exp = 1.;	/* Ask Bruno */
		
			status = om$send( msg      = message 
				ACrg_collect.ACadd_list_attribute( 
					&retmsg, 1, &Attr ),
				senderid = NULL_OBJID,
				targetid = ParamId->objid,
				targetos = ParamId->osnum );
			as$status( action = RET_STATUS );

			status=
                	VR$DispCollAttr ( pForm	= FormPtr,
                                  pCollId       = ParamId,
                                  Gadget        = HV_SYMB_SCALE,
                                  pAttrName     = VR_N_PID_SCALE_DB);
		}
                /** Block added for tr179900985 **/
                if(AABBCCode[0] != '\0') /*** dont know if needed****/
                {
                    IGRint locshape_code;
                    IGRshort bIsTransition;
                    struct        ACrg_coll       Attr;
                    struct GRid SysParam;
                    IGRlong      retmsg;

                    status = VRGetShapeFrmCompCode (  AABBCCode,
                                                          &bIsTransition,
                                                          &locshape_code,
                                                          product );
                    if(bIsTransition)
                    {
                       if(locshape_code == VR_RECT_OVAL)
                       {
                          if(*ShapeGadget == HV_R_SHAPE)
                          {
                             FIg_erase( FormPtr, HV_O_SHAPE );
                             FIg_display( FormPtr, HV_R_SHAPE );
                             locshape_code = VR_RECT;
                          }
                          else
                          {
                             FIg_erase( FormPtr, HV_R_SHAPE );
                             FIg_display( FormPtr, HV_O_SHAPE );
                             locshape_code = VR_OVAL;
                          }
                       }
                       else if(locshape_code == VR_RECT_CIRC)
                       {
                          if(*ShapeGadget == HV_R_SHAPE)
                          {
                             FIg_erase( FormPtr, HV_C_SHAPE );
                             FIg_display( FormPtr, HV_R_SHAPE );
                             locshape_code = VR_RECT;
                          }
                          else
                          {
                             FIg_erase( FormPtr, HV_R_SHAPE );
                             FIg_display( FormPtr, HV_C_SHAPE );
                             locshape_code = VR_CIRC;
                          }
                       }
                       else if(locshape_code == VR_RECT_CORN)
                       {
                          if(*ShapeGadget == HV_R_SHAPE)
                          {
                             FIg_erase( FormPtr, HV_RS_SHAPE );
                             FIg_display( FormPtr, HV_R_SHAPE );
                             locshape_code = VR_RECT;
                          }
                          else
                          {
                             FIg_erase( FormPtr, HV_R_SHAPE );
                             FIg_display( FormPtr, HV_RS_SHAPE );
                             locshape_code = VR_CORNER;
                          }
                       }
                       else if(locshape_code == VR_OVAL_CIRC)
                       {
                          if(*ShapeGadget == HV_O_SHAPE)
                          {
                             FIg_erase( FormPtr, HV_C_SHAPE );
                             FIg_display( FormPtr, HV_O_SHAPE );
                             locshape_code = VR_OVAL;
                          }
                          else
                          {
                             FIg_erase( FormPtr, HV_O_SHAPE );
                             FIg_display( FormPtr, HV_C_SHAPE );
                             locshape_code = VR_CIRC;
                          }
                       }
                       else if(locshape_code == VR_OVAL_CORN)
                       {
                          if(*ShapeGadget == HV_O_SHAPE)
                          {
                             FIg_erase( FormPtr, HV_RS_SHAPE );
                             FIg_display( FormPtr, HV_O_SHAPE );
                             locshape_code = VR_OVAL;
                          }
                          else
                          {
                             FIg_erase( FormPtr, HV_O_SHAPE );
                             FIg_display( FormPtr, HV_RS_SHAPE );
                             locshape_code = VR_CORNER;
                          }
                       }
                       else if(locshape_code == VR_CIRC_CORN)
                       {
                          if(*ShapeGadget == HV_C_SHAPE)
                          {
                             FIg_erase( FormPtr, HV_RS_SHAPE );
                             FIg_display( FormPtr, HV_C_SHAPE );
                             locshape_code = VR_CIRC;
                          }
                          else
                          {
                             FIg_erase( FormPtr, HV_C_SHAPE );
                             FIg_display( FormPtr, HV_RS_SHAPE );
                             locshape_code = VR_CORNER;
                          }
                       }
                       int_conv = locshape_code;
                       /* NOT updating ParamId - TR179901512 */
/***** TR179901512
                       Attr.desc.value.att_exp = (double) locshape_code;
                       strcpy(Attr.name, VR_N_SHAPE_IN);
                       Attr.desc.type = AC_ATTRIB_DOUBLE;
                       __DBGpr_com("modified collection here");
                       status = VRModifyCollection( &retmsg,
                                                VR_UPDATE_COLL, VR_RG_COLL,
                                                NULL, &Attr,1,ParamId);
*****/
                   }
                }
                else
                {
                /* End tr179900985 block */
		/* NYC Add to the collection if not found */
		
     		strcpy(Attr.name, VR_N_SHAPE_IN);

		status =
		om$send( msg = message ACrg_collect.ACget_named_attribute
							( &retmsg, &Attr ),
			senderid = NULL_OBJID,
			targetid = ParamId->objid,
			targetos = ParamId->osnum );
       		as$status( action = RET_STATUS );

    		int_conv = Attr.desc.value.att_exp;
                }

		/* erase all shapes */
		FIg_erase( FormPtr, HV_R_SHAPE );
		FIg_erase( FormPtr, HV_O_SHAPE );
		FIg_erase( FormPtr, HV_RS_SHAPE );
		FIg_erase( FormPtr, HV_C_SHAPE );

    		switch ( int_conv )
    		{
			case VR_RECT:
				FIfld_set_mode(FormPtr, HV_DEPTH, 0, FI_INSERT);

/* Added with CR179801144 */    FIg_display ( FormPtr, HV_DEPTH );
         			FIg_display ( FormPtr, HV_R_SHAPE );
	 			*ShapeGadget = HV_R_SHAPE;
         		break;
        
      			case VR_CIRC:
				FIfld_set_mode(FormPtr, HV_DEPTH, 0, FI_REVIEW);
/* Added with CR179801144 */    FIg_display ( FormPtr, HV_DEPTH );
         			FIg_display ( FormPtr, HV_C_SHAPE );
	 			*ShapeGadget = HV_C_SHAPE; 
         		break;
        
      			case VR_OVAL:
				FIfld_set_mode(FormPtr, HV_DEPTH, 0, FI_INSERT);
/* Added with CR179801144 */    FIg_display ( FormPtr, HV_DEPTH );
         			FIg_display  ( FormPtr, HV_O_SHAPE );
	 			*ShapeGadget = HV_O_SHAPE;
			break;

			case VR_CORNER:
				FIfld_set_mode(FormPtr, HV_DEPTH, 0, FI_INSERT);
/* Added with CR179801144 */    FIg_display ( FormPtr, HV_DEPTH );
				FIg_display  ( FormPtr, HV_RS_SHAPE );
                                *ShapeGadget = HV_RS_SHAPE;


         		break;
		}
		break;
  }

  if( SketchMode == VR_MANUAL )
  {
  	switch( product )
  	{
		case VR_PIPING:
			VR$DispCollAttr ( pForm 	= FormPtr,
			  	  	  pCollId	= ParamId,
			  	  	  Gadget	= SMALL_DIAMETER,
			  	  	  pAttrName 	= VR_N_RDIAMETER_DB);

			if( strcmp( AABBCCode,"" ) )
			{
				/* Get G_DIAMETER value */
     				strcpy(Attr.name, VR_N_GDIAMETER_DB);

				status =
				om$send( msg = message ACrg_collect.ACget_named_attribute
							( &retmsg, &Attr ),
					senderid = NULL_OBJID,
					targetid = ParamId->objid,
					targetos = ParamId->osnum );
       				as$status( action = RET_STATUS );

				size_g = Attr.desc.value.att_exp;


				/* Get G_DIAMETER value */
     				strcpy(Attr.name, VR_N_RDIAMETER_DB);

				status =
				om$send( msg = message ACrg_collect.ACget_named_attribute
							( &retmsg, &Attr ),
					senderid = NULL_OBJID,
					targetid = ParamId->objid,
					targetos = ParamId->osnum );
       				as$status( action = RET_STATUS );

				size_r = Attr.desc.value.att_exp;

				/* Get CLASS value */
     				strcpy(Attr.name, VR_N_CLASS_AN);

				status =
				om$send( msg = message ACrg_collect.ACget_named_attribute
							( &retmsg, &Attr ),
					senderid = NULL_OBJID,
					targetid = ParamId->objid,
					targetos = ParamId->osnum );
       				as$status( action = RET_STATUS );

				strcpy( specname , Attr.desc.value.att_txt );

				status = 
				VRget_opt_code_txt ( &retmsg, VR_PIPING, 
						     AABBCCode, specname, 
			     	     	     	     size_g, size_r, &opt_codes, 
						     &opt_txt, &opt_cnt, NULL
						   );

				if ( status & 1 )
				{
				  FIfld_set_list_num_rows( FormPtr, OPTION, 0, opt_cnt);
				  /* -- set a list of texts corresponding to opt_codes -- */
				  for( i=0; i< opt_cnt; i++ )
				  {
				    IGRlong	msg;
      				    IGRchar	p_error[30];

                                    /* TR-MP4140 - initialize o_lname nomatch*/
                                    optcodes[i][0] = '\0';
      				    status = vd$get_alias ( 	p_msg	= &msg,
		    	       					product	= PIPING,
		    	       					type	= VR_OPTCODE_LIST_NUM,
		               					i_code	= (IGRint) opt_codes[i],
		    	       					o_lname	= optcodes[i],
		    	       					p_error	= p_error	);

	  			    /*"optcodes[%d] = %s, length = %d \n", i, 
							optcodes[i], strlen(optcodes[i])*/
				    /* -- display the opt code if no short desc is available -- */
				    if ( strlen( optcodes[i]) == 0 )
				      sprintf( optcodes[i], "%d", opt_codes[i] );
				    VDfld_set_list_text( FormPtr, OPTION, i, 0, 
						     	     optcodes[i], FALSE );
				  }
				}
			}
			break;

		case VR_HVAC:  
			VR$DispCollAttr ( pForm 	= FormPtr,
			  	  	  pCollId	= ParamId,
			  	  	  Gadget	= SMALL_HV_WIDTH,
			  	  	  pAttrName 	= VR_N_WIDTH2_DB);

			VR$DispCollAttr ( pForm 	= FormPtr,
			  	  	  pCollId	= ParamId,
			  	  	  Gadget	= SMALL_HV_DEPTH,
			  	  	  pAttrName 	= VR_N_DEPTH2_DB);

               /* Added for tr179901512 */
               if(AABBCCode[0] != '\0')
               {
                  IGRshort bIsTransition;
                  IGRint locshape_code;
                  status = VRGetShapeFrmCompCode (  AABBCCode,
                                                          &bIsTransition,
                                                          &locshape_code,
                                                          product );
                  if(bIsTransition)
                  {
                     int_conv = locshape_code;
                  }
                }
                else
                {
                   strcpy(Attr.name, VR_N_SHAPE_IN);

                   status =
                     om$send( msg = message ACrg_collect.ACget_named_attribute
                                                        ( &retmsg, &Attr ),
                        senderid = NULL_OBJID,
                        targetid = ParamId->objid,
                        targetos = ParamId->osnum );
                   as$status( action = RET_STATUS );

                   int_conv = Attr.desc.value.att_exp;
                }
                /* Modified for tr179901512 */
                if(int_conv == VR_CIRC || int_conv == VR_RECT_CIRC ||
                                          int_conv == VR_OVAL_CIRC ) 
                {
                   IGRdouble widthval;
                   IGRint row = 0, col = 0, sel_flag = 0, r_pos;
                   FIfld_get_value( FormPtr , SMALL_HV_WIDTH, row, col,
                                         &widthval, &sel_flag, &r_pos );
                   FIg_set_value( FormPtr , SMALL_HV_DEPTH, widthval);
/*                   FIg_erase(FormPtr , SMALL_HV_DEPTH); TR179901512 */

                }
			/* KLUDGE waiting */

			FIg_erase( FormPtr, HV_O_SHAPE2 );
			FIg_erase( FormPtr, HV_R_SHAPE2 );
			FIg_erase( FormPtr, HV_C_SHAPE2 );
			FIg_erase( FormPtr, HV_RS_SHAPE2 );
			FIg_erase( FormPtr, HV_TEXT_SHAPE2 );


			break;


		case VR_CABLING:  
                        /* Modified for CR179900491 */
                        __DBGpr_com("displaying width/depth for rway here");
                        {
                         struct ret_struct       ParamAttr;
                         IGRint                  FootIndex = -1, retstatus;
                         IGRlong longmsg; 
                         IGRchar spec_name[120];

                         strcpy(Attr.name, VR_N_SHAPE_IN);

                         status =
                           om$send( msg = message ACrg_collect.ACget_named_attribute
                                                        ( &retmsg, &Attr ),
                            senderid = NULL_OBJID,
                            targetid = ParamId->objid,
                            targetos = ParamId->osnum );
                         as$status( action = RET_STATUS );


                         int_conv = Attr.desc.value.att_exp;
                         /* Following block for transitions-tr179900976 */
                         if(AABBCCode[0] != '\0')
                         {
                            IGRshort bIsTransition;
                            IGRint locshape_code;
                            /* Added product for tr179900985 */
                            status = VRGetShapeFrmCompCode (  AABBCCode,
                                                          &bIsTransition,
                                                          &locshape_code,
                                                          product );
                            if(bIsTransition)
                            {
                                int_conv = locshape_code;
                            }
                         }
                         /* get the spec name */
                         status =
                             om$send( msg      = message ACncpx.ACgive_structure
                                      ( &retstatus,
                                        &FootIndex,
                                        VR_N_CLASS_AN,
                                        &ParamAttr,
                                        md_env),
                             senderid = NULL_OBJID,
                             targetid = ParamId->objid,
                             targetos = ParamId->osnum );
                         strcpy (spec_name,ParamAttr.var.text_st.text_string);

                         /* The following condition added by alwin to send the
                         proper shape_code in the case of the Transition
                         Components*/
/*** deleted code fro tr179801414 for tr179900976 ***/
                         /**************************************/
                         /*** Get the number of cpts to store */
			 if( AABBCCode[0] != '\0')
			 {
			     status = VRGetComp_NbCpt ( &longmsg,
				     			(IGRshort) product,
							int_conv,spec_name,
							AABBCCode, &NbCpts);
			 }
                         /* NbCpts = some magic number */
                         if(NbCpts < 1 || NbCpts>10 )
                            NbCpts = 10;
                         __DBGpr_int("no. of cpts to store",NbCpts);

                         *active_cpt = 2;
                         /*** Changed 0 to int_conv for shape-tr179900780 ***/
__DBGpr_com( " Calling36 VRRw_dimen_fields ");
                         status = VRRw_dimen_fields(FormPtr, 0, NULL, 
                                   md_env, NbCpts,
                                   active_cpt, 1, int_conv, RWcptdata,
                                   ParamId);
                        }
			break;
    	}


  }

__DBGpr_com("---------------------------------------------------");
  End
  return OM_S_SUCCESS;

} /* end VRSkUpdateForm */


/*********************************************************************************************/

VRNozUpdateForm( IGRint			product,
		IGRchar 		*FormPtr,
		struct		GRid	*ParamId)

/*.VRNozUpdateForm */
{
  IGRlong			status;

  SetProc( Fn VRNozUpdateForm ); Begin

  if( product == VR_PIPING )
  {
  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= SEQ_NUMBER,
		    	  pAttrName 	= VR_N_SEQ_NUMBER_AN);

  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= FLUID_CODE,
		    	  pAttrName 	= VR_N_FLUID_CODE_AN);

  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= ZONE_NB,
		    	  pAttrName 	= VR_N_ZONE_AN);
  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= INSUL_THIK,
		    	  pAttrName 	= VR_N_INSUL_THK_DB);

  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= OPER_TEMP,
		    	  pAttrName 	= VR_N_OPER_TEMP_DB);

  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= OPER_PRESSURE,
		    	  pAttrName 	= VR_N_OPER_PRESS_DB);

  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= DGN_TEMP,
		    	  pAttrName 	= VR_N_DGN_TEMP_DB);

  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= DGN_PRESS,
		    	  pAttrName 	= VR_N_DGN_PRESS_DB);
  }
  else
  {
  	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= HPRESSURE_CLASS,
		    	  pAttrName 	= VR_N_PRESS_CLASS_AN);
	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= SPEC_NAME,
		    	  pAttrName 	= VR_N_CLASS_AN);
        // CR179900696
        /* When we set the spec_name in this gadget we also need to update the
        Material Class informaiton in the Material_class gadget. */
        {
            IGRchar         szSpecName[30];

            FIg_get_text( FormPtr, SPEC_NAME, szSpecName );
            __DBGpr_str( " ### Spec Name ", szSpecName );

            // Call this function to update the Material list...from db
            VRUpdMaterial_InsulationList( FormPtr, TRUE, szSpecName,
                                                         DUCT_MATERIAL );
        }


	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= SIZING_METHOD,
		    	  pAttrName 	= VR_N_SIZE_METHOD_AN);

	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= AIR_FLOW,
		    	  pAttrName 	= VR_N_FLOW_RATE_DB);
	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= NOZZLE_AIRFLOW,
		    	  pAttrName 	= VR_N_FLOW_RATE_DB);

	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= MAX_VELOCITY,
		    	  pAttrName 	= VR_N_MAX_VELOC_DB);

	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= MAX_DEPTH,
		    	  pAttrName 	= VR_N_MAX_DEPTH_DB);
	
	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= DUCT_MATERIAL,
		    	  pAttrName 	= VR_N_DUCT_MATERIAL_AN);

	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= DUCT_THICK,
		    	  pAttrName 	= VR_N_DUCT_THICK_DB);


	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= INSUL_MATERIAL,
		    	  pAttrName 	= VR_N_INSUL_TYPE_AN);


	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= HINSUL_THICK,
		    	  pAttrName 	= VR_N_INSUL_THK_DB);

	// following added for CR179901312. Alwin
	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= ACOUSTICAL_MATERIAL,
		    	  pAttrName 	= VR_N_ACST_INSUL_TYPE_AN);

	status=
  	VR$DispCollAttr ( pForm 	= FormPtr,
		    	  pCollId	= ParamId,
		    	  Gadget	= ACOUSTICAL_THICK,
		    	  pAttrName 	= VR_N_ACST_INSUL_THK_DB);

  }
  End
  return OM_S_SUCCESS;

} 

/*********************************************************************************************/

VRMakeConstraints( IGRint			NbPlanes,
		struct	GRid		*PlanesId,
		struct	GRid		*CopyPlane,
		struct	GRmd_env	*p_PlMdEnv,
		struct	GRmd_env	*p_CurMdEnv)

/*.VRMakeConstraints */
{
	struct	GRas		assoc_list;
	struct	GRid		CpPlanes[6], TempsId[2], constr;
  	IGRlong			status, retcode;	
	IGRint			i;

        assoc_list.num_parents = 2;
    	assoc_list.parents     = TempsId;
      	constr.osnum 	       = p_CurMdEnv->md_id.osnum;

	CpPlanes[0] = PlanesId[0];
	CpPlanes[1] = PlanesId[1];
	CpPlanes[2] = PlanesId[2];

	/*"Dep  Planes = %d %d %d\n", CpPlanes[0].objid,CpPlanes[1].objid,CpPlanes[2].objid */
	/*"Copy Planes = %d %d %d\n", CopyPlane[0].objid,CopyPlane[1].objid,CopyPlane[2].objid */

	for( i=0; i<NbPlanes; i++ )
 	{
		if( CopyPlane[i].objid != NULL_OBJID ) CpPlanes[i+3] = CopyPlane[i];
		else
		{
    		  status = om$send( 	msg      = message NDnode.NDcopy_to_root
			       			   	( &retcode, 0, p_PlMdEnv, p_CurMdEnv,
							  &CpPlanes[i+3]
						        ),
					senderid = NULL_OBJID,
		    			targetid = CpPlanes[i].objid,
		    			targetos = CpPlanes[i].osnum );
    		  as$status();

  		  CopyPlane[i] = CpPlanes[i+3];
                }

		TempsId[0] = CpPlanes[i];
		TempsId[1] = CopyPlane[i];
		
      		status = om$construct( 	classid = OPP_VRconsdist_class_id,
    		               		p_objid = &constr.objid,
		               		osnum   = constr.osnum,
                               		msg     = message NDnode.NDplace
                                                 ( &assoc_list, NULL, NULL ) );
        	as$status( action = RET_STATUS ); 

        	/*"created constraint %d %d\n", constr.objid, constr.osnum */
	}

	/*"copy Planes = %d %d %d\n", CpPlanes[3].objid,CpPlanes[4].objid,CpPlanes[5].objid */
	
	return OM_S_SUCCESS;
}

/***********************************************************************/

IGRdouble VRGetAngle( p_msg, p_AxisList, PrimaryOrient, SecondaryOrient, p_MdEnv )

IGRlong			*p_msg;
struct	GRid		*p_AxisList;
IGRdouble		PrimaryOrient;
IGRdouble		SecondaryOrient;
struct GRmd_env	*p_MdEnv;
{
	IGRint			status;
	IGRlong			retcode;
	IGRdouble		dPrimary [3], dSecondary [3], dTransformed [3];
	IGRdouble		dTmpAngle, dAngle, VRcompute_angle ();
	BSrc			rc;

	/*" Orientation Primary   : %f\n", PrimaryOrient   */
	/*" Orientation Secondary : %f\n", SecondaryOrient */

	*p_msg = MSSUCC;

	status = om$send( msg      = message VRCnrlSeg.VRGetTopo
   			             ( &retcode, dPrimary, NULL,NULL, NULL, NULL, p_MdEnv ),
			  senderid = NULL_OBJID,
			  targetid = p_AxisList[0].objid,
			  targetos = p_AxisList[0].osnum );
	as$status ( action = RET_STATUS );

	/*  -- Primary axis = (Vsegment * relative orientation) -- */
	dPrimary[0] *= PrimaryOrient;
	dPrimary[1] *= PrimaryOrient;
	dPrimary[2] *= PrimaryOrient;

	/*" Primary : %f ,%f ,%f\n",dPrimary[0],dPrimary[1],dPrimary[2]*/

	/* -- get secondary segment's vector -- */

	status = om$send( msg      = message VRCnrlSeg.VRGetTopo
				     ( &retcode,dSecondary,NULL,NULL,NULL,NULL,p_MdEnv ),
		          senderid = NULL_OBJID,
			  targetid = p_AxisList[1].objid,
			  targetos = p_AxisList[1].osnum );
	as$status ( action = RET_STATUS );

	dSecondary[0] *= SecondaryOrient;
    	dSecondary[1] *= SecondaryOrient;
    	dSecondary[2] *= SecondaryOrient;

	/*" Secondary : %f ,%f ,%f\n",dSecondary[0],dSecondary[1],dSecondary[2]*/

	/* -- Compute Angle between Primary and Secondary axis -- */
	/* -- Z axis = Primary ^ Secondary -- */
	BScrossp (&rc, dPrimary, dSecondary, dTransformed );

	dTmpAngle = VRcompute_angle( dPrimary, dSecondary, dTransformed );

	/* -- Convert angle in degrees -- */
	dTmpAngle = dTmpAngle / M_PI * 180.0;

	dAngle = dTmpAngle;

	return ( dAngle );
}

/********************************************************************************************/

VRGetCompPlanes( p_retmsg, p_CompId, CompCpt, p_GivenPt, p_CompMdEnv, p_CurMdEnv, 
		 p_CompPlanesId, p_DepPlanesId )

IGRlong				*p_retmsg;
struct		GRid		*p_CompId;
IGRint				CompCpt;
IGRdouble			*p_GivenPt;
struct 		GRid 		*p_CompPlanesId;
struct		GRmd_env	*p_CompMdEnv;
struct		GRmd_env	*p_CurMdEnv;
struct		GRid		*p_DepPlanesId;

/*.VRGetCompPlanes */
{
  IGRshort		CptNum;
  IGRlong		retcode = MSSUCC;
  IGRlong		msg;
  IGRlong		status=OM_S_SUCCESS;
  GRclassid		CompClassId;
  struct 	GRid 	PlaneIds[3*VR_MAX_CPTS], RefId;


  extern GRclassid 	OPP_VRConcComp_class_id,
			OPP_VRNozzle_class_id ;

  *p_retmsg = MSSUCC;

  /* get the cpt number if the cpt coord is given */
  if( p_GivenPt )
  {
	status =
	VRGetCptNum_GivenCptCoord
		( &retcode, p_CompId, p_GivenPt, &CptNum, p_CompMdEnv );
  	as$status( action = RET_STATUS );
  }
  else CptNum = CompCpt;

  /*"CptNum = %d\n", CptNum */

  if( p_CompMdEnv->md_id.osnum != p_CurMdEnv->md_id.osnum )
  {
	struct	GRid	cmp_context;

	status =
	GRfindcontext ( &msg, &p_CompMdEnv->md_env.matrix_type,
			p_CompMdEnv->md_env.matrix, &p_CompId->osnum,
			&cmp_context );
	if(status != OM_S_SUCCESS || msg != MSSUCC ) 
			cmp_context.objid = NULL_OBJID;
	

	/*"cmp_context = %d\n", cmp_context.objid */

	/*| get component ref */
	status =
	om$send( msg      = message NDnode.NDmake_source
		     ( 	&msg, p_CompId, &cmp_context,
			VR_N_REF_CS, p_CurMdEnv->md_id.osnum,
			&RefId ),
		  senderid = NULL_OBJID,
		  targetid = p_CompId->objid,
		  targetos = p_CompId->osnum );
	as$status();

	/*| create three dependent planes from a referential */
	status = VRCreateDepPlanes
		 ( VR_DEP_REF | VR_ALL_PLANES, 1, &RefId, p_CompMdEnv,p_CurMdEnv,3, PlaneIds );
	as$status();

	p_DepPlanesId[1] = PlaneIds[0];
	p_DepPlanesId[0] = PlaneIds[2];
	p_DepPlanesId[2] = PlaneIds[1];
 
	/*"Dep Pl = %d %d %d\n",  p_DepPlanesId[0].objid, p_DepPlanesId[1].objid, p_DepPlanesId[2].objid */ 

	/* Copy dependent planes and make constraint between dependent planes and the clones */
	status =
	VRMakeConstraints( 3, p_DepPlanesId, p_CompPlanesId, p_CurMdEnv, p_CurMdEnv );
	as$status();
  }
  else 
  {
	/* we need to distinguish the nozzle case */
	status = om$get_classid(
			objid = p_CompId->objid,
			osnum = p_CompId->osnum,
			p_classid = &CompClassId );
	as$status();

	if ( om$is_ancestry_valid( subclassid 	= CompClassId,
		  		 superclassid 	= OPP_VRNozzle_class_id )
	    == OM_S_SUCCESS )
	{
		status =
		om$send( msg      = message VRNozzle.VRGetRefId( &msg, &RefId ),
			senderid = NULL_OBJID,
			targetid = p_CompId->objid,
			targetos = p_CompId->osnum );
		as$status( action = RET_STATUS );

		/*| create three dependent planes from a referential */
		status =
		VRCreateDepPlanes ( VR_DEP_REF | VR_ALL_PLANES, 1, &RefId,
				    p_CompMdEnv,p_CurMdEnv,3, PlaneIds );
		as$status();

		p_DepPlanesId[1] = PlaneIds[0];
		p_DepPlanesId[0] = PlaneIds[2];
		p_DepPlanesId[2] = PlaneIds[1];
 
		/*"Dep Pl = %d %d %d\n",  p_DepPlanesId[0].objid, p_DepPlanesId[1].objid, p_DepPlanesId[2].objid */ 

		/* Copy dependent planes and make constraint between
		   them and the clones */
		status =
		VRMakeConstraints( 3, p_DepPlanesId, p_CompPlanesId, p_CurMdEnv, p_CurMdEnv );
		as$status();

		return OM_S_SUCCESS;
	}
	else if( om$is_ancestry_valid( 	subclassid 	= CompClassId,
			  		superclassid 	= OPP_VRConcComp_class_id )
	    == OM_S_SUCCESS )
	{
	    /*| add conc planes */
	    status = VRAddConcPlanes( &retcode, p_CompId, p_CompMdEnv );
	    as$status( action = RET_STATUS );
	}	

	/*| Get planes on cpt */
	status =
	om$send( msg      = message VRGeneric.VRGetPlanesOnCpt
			( &msg, CptNum, PlaneIds, p_CompMdEnv ),
		senderid = NULL_OBJID,
		targetid = p_CompId->objid,
		targetos = p_CompId->osnum );
	as$status( action = RET_STATUS );

	if( ! ( msg & 1 ) )
	{
		/*| component without topology */

		/* the component is without topology and is in the current object
		/* space. we create three planes needed to maintain network connexion
		/* on the given component connect point
		/**/

		status = VRBuildCompPlanes
			 ( &retcode, p_CompId, CptNum, p_CompMdEnv, PlaneIds,
			   p_CompMdEnv);
		as$status( action = RET_STATUS );
	}

	/* GetPlanesOnCpt or VRBuildCompPlanes return planes in this order :
	/* 
	/* 0 ==> common plane
	/* 1 ==> ortho  plane
	/* 2 ==> end    plane
	/**/

	p_CompPlanesId[0] = PlaneIds[2];
	p_CompPlanesId[1] = PlaneIds[0];
	p_CompPlanesId[2] = PlaneIds[1];

	/*"Comp Planes 0 = <%d, %d>\n", p_CompPlanesId[0].objid, p_CompPlanesId[0].osnum */
	/*"Comp Planes 1 = <%d, %d>\n", p_CompPlanesId[1].objid, p_CompPlanesId[1].osnum */
	/*"Comp Planes 0 = <%d, %d>\n", p_CompPlanesId[2].objid, p_CompPlanesId[2].osnum */
  }

  return OM_S_SUCCESS;
}

/****************************************************************************/
VRGetCompFunction( 	IGRshort			product,
			struct		GRid		*p_CompId,
			IGRint				*p_CmpFunction,
			union		VRparam_attr	*p_CmpParam,
			struct		GRmd_env	*p_MdEnv)
/*.VRGetCompFunction */
{
  IGRint			CmpNumCpts, CompTopo;
  IGRlong 			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	VRcp_attr	CmpCptAttr[VR_MAX_CPTS];
  struct	GRid		GraphicId;

  status = VRCheckCompTopo( &CompTopo, p_CompId, p_MdEnv );
  as$status();

  switch( CompTopo )
  {
	case VR_UNDEFINED_TOPO 	:
	case VR_CLOSURE_TOPO	:
	case VR_2_WAYS_TOPO	:
	case VR_OLET_TOPO	:
	case VR_4_WAYS_TOPO	:
	case VR_RETURN_TOPO	:
	case VR_OFFSET_TOPO	:
	case VR_HELIX_TOPO	:
	case VR_SPLIT_TOPO	:
	case VR_BEND_SPLIT_TOPO	:
	case VR_Y_BRANCH_TOPO	:
		*p_CmpFunction = IS_UNDEFINED;
		break;

	case VR_ECCENTRIC_TOPO	:
	case VR_INLINE_TOPO	: 
	case VR_3_WAYS_TOPO	:
		status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
							( &retcode, &CmpNumCpts, p_MdEnv ),
				  senderid = NULL_OBJID,
				  targetid = p_CompId->objid,
				  targetos = p_CompId->osnum );
		as$status();

		status = 
  		om$send( msg      = message NDnode.ASreturn_go( &GraphicId, NULL, NULL),
			senderid = NULL_OBJID,
	   		targetid = p_CompId->objid,
			targetos = p_CompId->osnum);
		as$status( action = RET_STATUS );

 		status =
		VRget_cache_attr( &GraphicId, CmpNumCpts, CmpCptAttr );
  		as$status( action = RET_STATUS );

		if( p_CmpParam )
		{
			if( product == VR_PIPING )
			{
				p_CmpParam->piping_attr.G_diameter = CmpCptAttr[0].width;
				p_CmpParam->piping_attr.R_diameter = CmpCptAttr[1].width;
				/*"GD = %f\n", p_CmpParam->piping_attr.G_diameter */
				/*"RD = %f\n", p_CmpParam->piping_attr.R_diameter */
			}
			else
			{
				p_CmpParam->hvac_attr.shape   = CmpCptAttr[0].section_mask & VR_SHAPE;
				p_CmpParam->hvac_attr.G_width = CmpCptAttr[0].width;
				p_CmpParam->hvac_attr.G_depth = CmpCptAttr[0].depth;
				p_CmpParam->hvac_attr.R_width = CmpCptAttr[1].width;
				p_CmpParam->hvac_attr.R_depth = CmpCptAttr[1].depth;

				/*"shape = %d\n", p_CmpParam->hvac_attr.shape   */
				/*"GW    = %f\n", p_CmpParam->hvac_attr.G_width */
				/*"GD    = %f\n", p_CmpParam->hvac_attr.G_depth */
				/*"RW    = %f\n", p_CmpParam->hvac_attr.R_width */
				/*"RD    = %f\n", p_CmpParam->hvac_attr.R_depth */
			}
		}

		if( product == VR_PIPING )
		{
                        /* TR179900780 law */
			if( VRdbls_not_equal(CmpCptAttr[0].width,
                                                         CmpCptAttr[1].width ))
			{
				*p_CmpFunction = IS_REDUCER;
			}
			else *p_CmpFunction = IS_UNDEFINED;
		}
		else
		{
			if( ( CmpCptAttr[0].section_mask & VR_SHAPE ) != ( CmpCptAttr[1].section_mask & VR_SHAPE ) )
			{
				*p_CmpFunction = IS_TRANSITION;
			}
                        /*** law-tr179900932 cleanup ***/
			else if(VRdbls_not_equal( CmpCptAttr[0].width,
                                                  CmpCptAttr[1].width) ||
			        VRdbls_not_equal( CmpCptAttr[0].depth,
                                                 CmpCptAttr[1].depth ) )

			{
				*p_CmpFunction = IS_REDUCER;
			}
			else *p_CmpFunction = IS_UNDEFINED;
		}
		break;

	default : *p_CmpFunction = IS_UNDEFINED;
  }

  return OM_S_SUCCESS;
}

/****************************************************************************/

VRAddConcPlanes( retmsg, CompId, md_env )

IGRlong			*retmsg;
struct	GRid		*CompId;
struct	GRmd_env	*md_env;

/*.VRAddConcPlanes */
{
  IGRshort		IndexTable[3*(VR_MAX_CPTS-1)];
  IGRint		i, NbPlanes, NbSupp, status;
  IGRlong		retcode;
  struct	GRid	TopoIds[3*VR_MAX_CPTS];

  *retmsg = MSSUCC;

  status = om$send( msg	 = message VRGeneric.VRGetPlanes
				( &retcode, 0, NULL, &NbSupp, NULL ),
		    senderid = NULL_OBJID,
		    targetid = CompId->objid,
		    targetos = CompId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( NbSupp ) 
  {
	/*| planes already connected */
	return OM_S_SUCCESS;
  }

  /*| build planes */

  for( i=0; i<3*VR_MAX_CPTS; i++ ) TopoIds[i].objid = NULL_OBJID;
  for( i=0; i<3*(VR_MAX_CPTS-1); i++ ) IndexTable[i]= -1;
  
  status = VRBuildTemp( &retcode, CompId, 3*VR_MAX_CPTS, TopoIds, 3*(VR_MAX_CPTS-1),
			IndexTable, md_env, &NbPlanes );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"nb planes = %d\n", NbPlanes */
  /*^
	for(i=0; i<NbPlanes;   i++ ) printf("pl[%d] = %d\n", i, TopoIds[i].objid );
	printf("it[0] = %d\n", IndexTable[0] );
	printf("it[1] = %d\n", IndexTable[1] );
	printf("it[2] = %d\n", IndexTable[2] );
	for(i=0; i<NbPlanes-3; i++ ) printf("it[%d] = %d\n", i, IndexTable[i] );
  */

  /*| connect planes */
  status = om$send( msg      = message VRConcComp.VRAddPlanes
                               ( &retcode, NbPlanes, TopoIds, IndexTable, md_env ),
		    senderid = NULL_OBJID,
		    targetid = CompId->objid,
		    targetos = CompId->osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  return OM_S_SUCCESS;
}
/****************************************************************************/

IGRlong VRGetCompGenInfo
  ( p_msg, Product, TopoParentsNum, p_TopoParentsList, CmpItemName, CmpJust, 
    p_CmpIndexOnTopo, p_RelCmpOrient, p_CmpAngle, p_CmpOrientSection, p_MdEnv, p_ActParamId,
/*    p_BufParamId, p_CmpGenInfoStr, p_CmpSysParamId *** commenting this */
    p_BufParamId, p_CmpGenInfoStr, p_CmpSysParamId, p_CmpMissParamId
  )
             

IGRlong				*p_msg;        
IGRshort			Product; 
IGRint				TopoParentsNum;
struct		GRid		*p_TopoParentsList;
IGRshort			CmpItemName;   
IGRshort			CmpJust; 
IGRshort			*p_CmpIndexOnTopo;
IGRshort                        *p_RelCmpOrient; 
IGRdouble			*p_CmpAngle;
IGRdouble			*p_CmpOrientSection;
struct		GRmd_env	*p_MdEnv;
struct		GRid		*p_ActParamId;
struct		GRid		*p_BufParamId;
struct		VRGenInfo	*p_CmpGenInfoStr;
struct		GRid		*p_CmpSysParamId;
struct		GRid		*p_CmpMissParamId; //added this for TR179800720

/*.VRGetCompGenInfo */
{
  union		VRparam_attr	ActParam, BufParam, CmpParam;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  IGRint 			i;             		/* loop index                  */
  IGRboolean			SystemCmp;		
  IGRint			nNbAttr=2;		

  SetProc( Fn VRGetCompGenInfo ); Begin 

  /* added by alwin for TR179800720 */
  if( p_CmpMissParamId && ( p_CmpMissParamId->objid != NULL_OBJID ) )
     nNbAttr=3;
  /* added by alwin for TR179800720 */

  *p_msg = MSSUCC;
 
  SystemCmp = CmpItemName==VR_DANGLING || CmpItemName==VR_ELBOW || CmpItemName==VR_TEE;
  VR$SetCompInstanceInfo(	p_msg		= &retcode,
				CmpStatus	= SystemCmp ? (IGRshort)VR_SYSTEM : (IGRshort) !VR_SYSTEM,
				NbTopoParents	= TopoParentsNum,
				NbAttrParents	= nNbAttr, /* added by alwin */
				CmpJust		= CmpJust,
				MdEnvOsnum	= p_MdEnv->md_id.osnum,
				p_CmpGenInfo	= p_CmpGenInfoStr );
  as$status();

  p_CmpGenInfoStr->Attr.Comp.Desc.nItemNum 	    = CmpItemName;
  p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary = *p_CmpAngle;

  /*"ItemName = %d\n", p_CmpGenInfoStr->Attr.Comp.Desc.nItemNum */
  /*"Angle    = %f\n", p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary */
  
  for( i=0; i<TopoParentsNum; i++ )
  {
      	p_CmpGenInfoStr->Attr.Comp.nIndex[i] = p_CmpIndexOnTopo[i];
      	/*"CmpIndexOnTopo[%d] = %d\n", i, p_CmpGenInfoStr->Attr.Comp.nIndex[i] */
  }
  __DBGpr_com("GetDimensionAttributes");
  status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
				 	Product		  = Product,
				 	p_SysCollectionId = p_ActParamId,
				 	p_DimAttributes   = &ActParam,
        	       		 	p_MdEnv		  = p_MdEnv );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( p_BufParamId )
  {
  	status = VR$GetDimensionAttributes( 	p_retmsg	  = &retcode,
				 		Product		  = Product,
				 		p_SysCollectionId = p_BufParamId,
				 		p_DimAttributes   = &BufParam,
               			 		p_MdEnv		  = p_MdEnv );
  	as$status( action = RET_STATUS );
  	as$status( sts = retcode, action = RET_STATUS );
  }

  CmpParam = ActParam;

  if( Product == VR_PIPING )
  {
	CmpParam.piping_attr.R_diameter = ActParam.piping_attr.G_diameter;
	/*"AGD = %f\n", ActParam.piping_attr.G_diameter */
	/*"ARD = %f\n", ActParam.piping_attr.R_diameter */
	/*"CGD = %f\n", CmpParam.piping_attr.G_diameter */
	/*"CRD = %f\n", CmpParam.piping_attr.R_diameter */
  }
  else
  {
        __DBGpr_com("load CmpParam.hvac_attr.R_width/depth");
	CmpParam.hvac_attr.R_width = ActParam.hvac_attr.G_width;
      	CmpParam.hvac_attr.R_depth = ActParam.hvac_attr.G_depth;
  }
  switch( CmpItemName )
  {
      case VR_DANGLING : 
        	/*| is a DANGLING */

        	if( p_CmpOrientSection )
        	{
          		status = VRskComputeCmpAngle
                   			( p_CmpOrientSection, &p_TopoParentsList[0],
                     			  &p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary, p_MdEnv );
          		/*"CmpAngle = %f\n", p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary */
        	}

        	p_CmpGenInfoStr->Attr.Comp.Orientation.nPriIndex = p_CmpGenInfoStr->nNbAttr;
        	p_CmpGenInfoStr->Attr.Comp.Orientation.nSecIndex = -1;
      break;
     
      case VR_REDUCER  :
        	/*| is a REDUCER */

        	if( p_CmpOrientSection && Product != VR_PIPING )
        	{
          		status = VRskComputeCmpAngle
                   			( p_CmpOrientSection, &p_TopoParentsList[0],
                     			  &p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary, p_MdEnv );
          		/*"CmpAngle = %f\n", p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary */
        	}

        	p_CmpGenInfoStr->Attr.Comp.Orientation.nPriIndex = p_CmpGenInfoStr->nNbAttr;
        	p_CmpGenInfoStr->Attr.Comp.Orientation.nSecIndex = -1;

        	if( Product == VR_PIPING )
        	{
          		/*"bGd = %f\n", BufParam.piping_attr.G_diameter */
          		/*"aGd = %f\n", ActParam.piping_attr.G_diameter */

          		if( BufParam.piping_attr.G_diameter > ActParam.piping_attr.G_diameter )
          		{
            			CmpParam.piping_attr.G_diameter = BufParam.piping_attr.G_diameter;
            			p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary = (IGRdouble)p_RelCmpOrient[0];
          		}
          		else
          		{
            			CmpParam.piping_attr.R_diameter = BufParam.piping_attr.G_diameter;
            			p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary = -(IGRdouble)p_RelCmpOrient[0];
          		}

          		/*"Gd = %f\n", CmpParam.piping_attr.G_diameter */
          		/*"Rd = %f\n", CmpParam.piping_attr.R_diameter */
        	}
        	else  /* tr179900932 cleanup */
        	{
          		if( BufParam.hvac_attr.G_width > ActParam.hvac_attr.G_width ||
              		    (VRdbls_are_equal(BufParam.hvac_attr.G_width,
                                              ActParam.hvac_attr.G_width) ) &&
                   		       BufParam.hvac_attr.G_depth > ActParam.hvac_attr.G_depth
                 	    )
          		{
            			CmpParam.hvac_attr.G_width = BufParam.hvac_attr.G_width;
            			CmpParam.hvac_attr.G_depth = BufParam.hvac_attr.G_depth;
            			p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary = 1;
          		}
          		else
          		{
            			p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary = -1;
            			CmpParam.hvac_attr.R_width = BufParam.hvac_attr.G_width;
            			CmpParam.hvac_attr.R_depth = BufParam.hvac_attr.G_depth;
          		}
        	} 
      break;

      case VR_FLGE_COMP :
	        /*| is a FLANGE */
         	p_CmpGenInfoStr->Attr.Comp.Orientation.nPriIndex = p_CmpGenInfoStr->nNbAttr;
         	p_CmpGenInfoStr->Attr.Comp.Orientation.nSecIndex = -1;
         	p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary  = (IGRdouble)1;
      break;
      /* Below modified for CR179309874 - New raceway shapes */
      case VR_TRANS_R_O  :
      case VR_TRANS_R_C  :
      case VR_TRANS_R_E  :
      case VR_TRANS_O_C  :
      case VR_TRANS_O_E  :
      case VR_TRANS_E_C  :
      case VR_TRANS_R_Co :
      case VR_TRANS_E_Co :
      case VR_TRANS_O_Co :
      case VR_TRANS_C_Co :
		/*| is a transition */
        	if( p_CmpOrientSection )
        	{
          		status = VRskComputeCmpAngle
                   			( p_CmpOrientSection, &p_TopoParentsList[0],
                     			  &p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary, p_MdEnv );

          		/*"CmpAngle = %f\n", p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary */
        	}

        	p_CmpGenInfoStr->Attr.Comp.Orientation.nPriIndex =  p_CmpGenInfoStr->nNbAttr;
        	p_CmpGenInfoStr->Attr.Comp.Orientation.nSecIndex = -1;

		status = VRMkTransShape
    			 ( BufParam.hvac_attr.shape, ActParam.hvac_attr.shape, 
		  	   (IGRint *)&CmpParam.hvac_attr.shape
			 );
		as$status();

		if(  BufParam.hvac_attr.shape > ActParam.hvac_attr.shape )
		{
              		CmpParam.hvac_attr.R_width = BufParam.hvac_attr.G_width;
            		CmpParam.hvac_attr.R_depth = BufParam.hvac_attr.G_depth;
           		p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary = -(IGRdouble)p_RelCmpOrient[0];
/*
printf("BufParam.hvac_attr.shape %d\n",BufParam.hvac_attr.shape);
printf("SET CmpParam.R_width-depth %lf %lf\n",CmpParam.hvac_attr.R_width,CmpParam.hvac_attr.R_depth);
printf("flip flag %d\n",p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary);
*/
		}
		else
		{
        	      	CmpParam.hvac_attr.G_width = BufParam.hvac_attr.G_width;
              		CmpParam.hvac_attr.G_depth = BufParam.hvac_attr.G_depth;
	        	p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary  =  (IGRdouble) p_RelCmpOrient[0];
/*
printf("SET CmpParam.G_width-depth %lf %lf\n",CmpParam.hvac_attr.G_width,CmpParam.hvac_attr.G_depth);
printf("flip flag %d\n",p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary);
*/
		}
      break;

      case VR_TWIST_R_TR :
	        /*| is a TWIST */

        	if( p_CmpOrientSection && Product != VR_PIPING )
        	{	
          		status = VRskComputeCmpAngle
                   			( p_CmpOrientSection, &p_TopoParentsList[0],
                     			  &p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary, p_MdEnv );
          		/*"CmpAngle = %f\n", p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary */
        	}
                __DBGpr_com("************** Setting REDUCER3 **************");
		/****Billa Double value comparision **/
       	 	p_CmpGenInfoStr->Attr.Comp.Orientation.nPriIndex = p_CmpGenInfoStr->nNbAttr;
        	p_CmpGenInfoStr->Attr.Comp.Orientation.nSecIndex = -1;
       		p_CmpGenInfoStr->Attr.Comp.Desc.nItemNum = VR_REDUCER;

                /* the fabs had no logical test here. It is assumed the test
                intended to check >= otherwise it makes no sense-law 04/04/02 */
        	if( BufParam.hvac_attr.G_width > ActParam.hvac_attr.G_depth || 
            	 (fabs( BufParam.hvac_attr.G_width-ActParam.hvac_attr.G_depth) < VRGetTol(VR_DIST_TOL)) &&
                      BufParam.hvac_attr.G_depth > ActParam.hvac_attr.G_width
                    )
        	{
          		CmpParam.hvac_attr.G_width = BufParam.hvac_attr.G_width;
         		CmpParam.hvac_attr.G_depth = BufParam.hvac_attr.G_depth;
          		CmpParam.hvac_attr.R_width = ActParam.hvac_attr.G_depth;
          		CmpParam.hvac_attr.R_depth = ActParam.hvac_attr.G_width;
          		p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary  =  1;
        	}
        	else
        	{ 
          		CmpParam.hvac_attr.G_width = ActParam.hvac_attr.G_depth;
          		CmpParam.hvac_attr.G_depth = ActParam.hvac_attr.G_width;
          		CmpParam.hvac_attr.R_width = BufParam.hvac_attr.G_width;
          		CmpParam.hvac_attr.R_depth = BufParam.hvac_attr.G_depth;
          		p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary = -1;
        	}
      break;

      case VR_ELBOW   :
	        /*| is an ELBOW */
        	p_CmpGenInfoStr->Attr.Comp.Orientation.nPriIndex  = p_CmpGenInfoStr->nNbAttr;
        	p_CmpGenInfoStr->Attr.Comp.Orientation.nSecIndex  = 1+p_CmpGenInfoStr->nNbAttr;
        	p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary   = (IGRdouble) p_RelCmpOrient[0];
        	p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary = (IGRdouble) p_RelCmpOrient[1];

        	if( p_BufParamId != NULL && (Product == VR_HVAC || Product == VR_CABLING)
                               			    && ActParam.hvac_attr.shape != VR_CIRC )
        	{
          		CmpParam.hvac_attr.G_width = BufParam.hvac_attr.G_width;
          		CmpParam.hvac_attr.G_depth = BufParam.hvac_attr.G_depth;
      
          		if( p_CmpOrientSection )
          		{
            			status = VRSkGetHvacCmpParams
                     				( &CmpParam, p_TopoParentsList, p_CmpOrientSection,
						  p_MdEnv, p_CmpAngle
                     				);
            			as$status( action = RET_STATUS );
          		}
        	}

        	if( Product == VR_PIPING )
        	{
          		/*"GW = %f\n", CmpParam.piping_attr.G_diameter */
          		/*"GD = %f\n", CmpParam.piping_attr.R_diameter */
        	}
        	else
        	{
          		/*"GW = %f\n", CmpParam.hvac_attr.G_width */
          		/*"GD = %f\n", CmpParam.hvac_attr.G_depth */
          		/*"RW = %f\n", CmpParam.hvac_attr.R_width */
          		/*"RD = %f\n", CmpParam.hvac_attr.R_depth */
        	}
      break;

      case VR_TEE :
	        /*| is a TEE  */

        	CmpParam = BufParam;
        	p_CmpGenInfoStr->Attr.Comp.Orientation.dPrimary   = (IGRdouble) p_RelCmpOrient[0];
        	p_CmpGenInfoStr->Attr.Comp.Orientation.nPriIndex  = p_CmpGenInfoStr->nNbAttr;
        	p_CmpGenInfoStr->Attr.Comp.Orientation.dSecondary = (IGRdouble) p_RelCmpOrient[1];
        	p_CmpGenInfoStr->Attr.Comp.Orientation.nSecIndex  = 1+p_CmpGenInfoStr->nNbAttr;

        	if( Product == VR_PIPING )
        	{
          		if( BufParam.piping_attr.G_diameter > ActParam.piping_attr.G_diameter )
            			CmpParam.piping_attr.R_diameter = ActParam.piping_attr.G_diameter;
          		else CmpParam.piping_attr.R_diameter = BufParam.piping_attr.G_diameter;

          		/*"aGD = %f\n", CmpParam.piping_attr.G_diameter */
          		/*"aRD = %f\n", CmpParam.piping_attr.R_diameter */
        	}
        	else
        	{
          		CmpParam.hvac_attr.R_width = ActParam.hvac_attr.G_width;
          		CmpParam.hvac_attr.R_depth = ActParam.hvac_attr.G_depth;

          		if( p_CmpOrientSection )
          		{
            			status = VRSkGetHvacCmpParams
                     				( &CmpParam, p_TopoParentsList, p_CmpOrientSection,
                       				  p_MdEnv, p_CmpAngle
                     				);
            			as$status( action = RET_STATUS );
          		}

          		if( CmpParam.hvac_attr.R_width > CmpParam.hvac_attr.G_width || 
              			      CmpParam.hvac_attr.R_depth > CmpParam.hvac_attr.G_depth )
          		{
             			CmpParam.hvac_attr.R_width = CmpParam.hvac_attr.G_width;
             			CmpParam.hvac_attr.R_depth = CmpParam.hvac_attr.G_depth;
          		} 

          		/*"aGW = %f\n", CmpParam.hvac_attr.G_width */
          		/*"aGD = %f\n", CmpParam.hvac_attr.G_depth */
          		/*"aRW = %f\n", CmpParam.hvac_attr.R_width */
          		/*"aRD = %f\n", CmpParam.hvac_attr.R_depth */
        	}
      break;

      default : 
        	as$status( sts = OM_W_ABORT, msg = "Component Item name not find" );
		End
        	return(OM_W_ABORT);
  } 

  if( ( ( Product == VR_HVAC || Product == VR_CABLING ) && 
      ( CmpParam.hvac_attr.shape   != ActParam.hvac_attr.shape   ||
        CmpParam.hvac_attr.G_width != ActParam.hvac_attr.G_width ||
        CmpParam.hvac_attr.G_depth != ActParam.hvac_attr.G_depth ||
        CmpParam.hvac_attr.R_width != ActParam.hvac_attr.R_width ||
        CmpParam.hvac_attr.R_depth != ActParam.hvac_attr.R_depth ) ) ||
      ( Product == VR_PIPING && 
      ( CmpParam.piping_attr.G_diameter != ActParam.piping_attr.G_diameter ||
        CmpParam.piping_attr.R_diameter != ActParam.piping_attr.R_diameter ) )
    )
  {
        p_CmpSysParamId->objid = NULL_OBJID;
        p_CmpSysParamId->osnum = p_MdEnv->md_id.osnum;
      	status = VRModifyParameterBox
        	 ( &retcode, Product, &CmpParam, p_ActParamId, p_CmpSysParamId);
      	as$status( action = RET_STATUS );
      	/*"created ACrg_collect %d\n", p_CmpSysParamId->objid */
  }
  else *p_CmpSysParamId = *p_ActParamId;

  /*"CmpSysParamId = %d %d\n", p_CmpSysParamId->objid, p_CmpSysParamId->osnum */

  End
  return OM_S_SUCCESS;
}

#include "VRSttopo.h"

IGRint VRGetTopology( 	IGRlong		*msg,
			struct VRTopo	*pTopo1, 
			struct VRTopo	*pTopo2,
			IGRdouble	*pdAngle, 
			IGRdouble	*pd16Matrix,
			struct GRmd_env	*p_MdEnv)
{
	IGRint		status;
	IGRlong		retcode;
	IGRdouble	d6Seg1Pts[6],
			d6Seg2Pts[6],
			d6IntPt[6],
			d3Seg1Vec[3],
			d3Seg2Vec[3],
			dDist;
	struct IGRline	*Lines[2],
			Line1,
			Line2;
	BSrc		rc;

	*msg = MSSUCC;
	Line1.point1 = d6Seg1Pts; Line1.point2 = &d6Seg1Pts[3] ;
	Line2.point1 = d6Seg2Pts; Line2.point2 = &d6Seg2Pts[3] ;
	Lines[0] = &Line1 ; Lines[1] = &Line2;

/*A	I/ Find intersection point */


	/*C	Get segments' end points */
	status =
	om$send( msg      = message VRCnrlSeg.VRget_terminators
			     ( &retcode, NULL, p_MdEnv, d6Seg1Pts, NULL ),
			  senderid = NULL_OBJID,
			  targetid = pTopo1->SegId.objid,
			  targetos = pTopo1->SegId.osnum );
	as$status ( action = RET_STATUS );

	status =
	om$send( msg      = message VRCnrlSeg.VRget_terminators
			     ( &retcode, NULL, p_MdEnv, d6Seg2Pts, NULL ),
		          senderid = NULL_OBJID,
			  targetid = pTopo2->SegId.objid,
			  targetos = pTopo2->SegId.osnum );
	as$status ( action = RET_STATUS );

	/*C	Compute intersection (BSint2lns) */

	dDist=0.0;
	BSint2lns ( Lines, (IGRpoint *)d6IntPt, &dDist, &rc );
	/*  " Intersect Lines rc = %d\n", rc */
	/*  " Distance           = %f\n", dDist */
	/* Constrained comp if no intersection or parallel but not equal */

	if ( rc != BSSUCC ) {*msg = MSFAIL; return OM_E_ABORT;}

	/*C	Compute segments vectors */

	BSmkvec ( &rc, d3Seg1Vec, d6Seg1Pts, d6IntPt );
	if ( BSlenvec ( &rc, d3Seg1Vec) < VRGetTol(VR_LENGTH_TOL))
	{
		/*C	use the other point to compute the vector */
		BSmkvec ( &rc, d3Seg1Vec, &d6Seg1Pts[3], d6IntPt );
	}

	BSnorvec ( &rc, d3Seg1Vec );

	BSmkvec ( &rc, d3Seg2Vec, d6IntPt, d6Seg2Pts );
	if ( BSlenvec ( &rc, d3Seg2Vec) < VRGetTol(VR_LENGTH_TOL))
	{
		/*C	use the other point to compute the vector */
		BSmkvec ( &rc, d3Seg2Vec, d6IntPt, &d6Seg2Pts[3] );
	}

	BSnorvec ( &rc, d3Seg2Vec );

	/*C	Return results */

	if (pdAngle)
	{
		*pdAngle = VRcompute_angle( d3Seg1Vec, d3Seg2Vec, (IGRdouble *) NULL )
					/ M_PI * 180.0;
	}

	if (pd16Matrix)
	{
		register IGRint	i;

		/*C	Generate Z axis */
		BScrossp( &rc, d3Seg1Vec, d3Seg2Vec, d6Seg1Pts);
		BSnorvec ( &rc, d6Seg1Pts );

		/*C	Orthogonalize the Y vector */
		BScrossp( &rc, d6Seg1Pts, d3Seg1Vec, d3Seg2Vec);

		for (i=0; i<3; i++)
		{
			/* point */
			pd16Matrix[i*4+3] = d6IntPt[i];
			/* X axis */
			pd16Matrix[i*4]   = d3Seg1Vec[i];
			/* Y axis */
			pd16Matrix[i*4+1] = d3Seg2Vec[i];
			/* Z axis */
			pd16Matrix[i*4+2] = d6Seg1Pts[i];
		}

		pd16Matrix[15]=1.0;
		pd16Matrix[12]=pd16Matrix[13]=pd16Matrix[14]=0.0;
	}

return OM_S_SUCCESS;

}/* end VRGetTopology */

/* added by alwin - for CR179300978 */
/* This function is being called from method VRskfstelm, in
   file VRsketchact.I */
IGRint VRResetOptionCode(IGRlong *msg, Form form_ptr, struct GRid CorId )
{
     /* TR-MP4140 - expand o_lname to 80 characters */
     IGRlong status= OM_S_SUCCESS;
     IGRchar o_lname[81], pathname[OM_K_MAXOSNAME_LEN];
     struct GRid ExpressionId;
     struct VRGenInfo  CmpInstance;
 
 
           status = om$send ( msg = message VRGeneric.VRGetInstance( msg,
                                     &CmpInstance ),
                       senderid = NULL_OBJID,
                       targetid = CorId.objid,
                       targetos = CorId.osnum );
           /* TR-MP4140-initialize o_lname for no-match */ 
           o_lname[0] = '\0';
           status = vd$get_alias(    p_msg = msg,
                            product        = PIPING,
                            type           = 400,
                            i_code         = CmpInstance.nOption,
                            o_lname        = o_lname,
                            p_error        = NULL       );
 
           if ( !strlen(o_lname) )
                sprintf(o_lname, "%d", CmpInstance.nOption );
 
           FIfld_set_text( form_ptr, PIPING_OPTION, 0, 0, o_lname, FALSE );
 
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
 
           if( status == DIR_S_SUCCESS )
           {
                status = exp$modify ( exp_id = ExpressionId.objid,
                                      osnum  = ExpressionId.osnum,
                                  exp_syntax = o_lname );
           }
 
           /* Re-Setting it to the PWD directory  */
           status = di$cd( dirname = pathname );
 
  return OM_S_SUCCESS;
}

/* Function added by alwin to retreive the shape_code from the dB */
/******************************************************************************
*       Given  : Component's Code
*
*       Output : Find out whether it's a Shape Transition component. If so
*               return TRUE for bIsTransition and value in shape_code.
*
*       Solution : From the table "rway_codelist", look for "list_num = 330"
*                and the "short_txt = comp_code", find out the correcponding
*                "code_num" which is nothing but your shape_code.
*
******************************************************************************/

/* Added product for TR179900985 */
IGRint VRGetShapeFrmCompCode (  IGRchar *comp_code, IGRboolean *bIsTransition,
                                IGRint  *shape_code, IGRint Product )
{
  IGRshort      nShapeCode;
  IGRlong       status, retmsg;

  SetProc( Fn VRGetShapeFrmCompCode ); Begin

  *bIsTransition = FALSE;
  nShapeCode = -1;

  if(Product == VR_RWAY)       /* tr179900985 addition */
  {
  /* Call the macro to convert the "comp_code" to "shape_code". CL 330 */
  status = VR$RDB_CDLNUM (p_msg = &retmsg,
                      nlist = (IGRshort) 330,
                      p_txt = comp_code,
                      p_num = &nShapeCode );
  }
  else if (Product == VR_HVAC) /* block is tr179900985 addition */
  {
  status = VR$HDB_CDLNUM (p_msg = &retmsg,
                      nlist = (IGRshort) 330,
                      p_txt = comp_code,
                      p_num = &nShapeCode );
  } 

  *shape_code = (IGRshort) nShapeCode;

  if( retmsg == MSSUCC )
  {
    *bIsTransition = TRUE;
  }

  __DBGpr_int( " Shape Code Value ", *shape_code );

  End
  return OM_S_SUCCESS;
}

end implementation Root;
