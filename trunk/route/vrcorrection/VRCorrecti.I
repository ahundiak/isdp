/* $Id: VRCorrecti.I,v 1.10 2002/04/11 19:07:53 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrcorrection / VRCorrecti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCorrecti.I,v $
 *	Revision 1.10  2002/04/11 19:07:53  louis
 *	Move piping exclusive functionality from VRCorrecti.I to the new VREvalComponent method in VRPCorentiti.I
 *	
 *	Revision 1.9  2002/04/10 18:12:39  louis
 *	TR5649-standardize tolerances
 *	
 *	Revision 1.8  2001/08/22 20:04:57  jdsauby
 *	JTS TR 5335 - jds 8/22/01
 *	
 *	Revision 1.7  2001/07/25 21:58:49  anand
 *	JTS TR MP 5418
 *	
 *	Revision 1.6  2001/07/24 17:08:15  anand
 *	JTS TR MP 5439
 *	
 *	Revision 1.5  2001/05/11 16:29:47  anand
 *	JTS TR 4998
 *	
 *	Revision 1.4  2001/05/07 20:37:24  anand
 *	JTS CR 5177
 *	
 *	Revision 1.3  2001/02/20 01:13:15  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 16:05:55  anand
 *	SP merge
 *	
# Revision 1.1  2000/07/19  21:32:14  pinnacle
# Created: route/vrcorrection/VRCorrecti.I by aharihar for Service Pack
#
# Revision 1.6  2000/01/25  18:52:30  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by lawaddel for route
#
# Revision 1.5  1999/06/14  20:58:20  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by lawaddel for route
#
# Revision 1.4  1999/05/24  20:35:50  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by lawaddel for route
#
# Revision 1.3  1999/05/04  13:42:14  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by sbilla for route
#
# Revision 1.2  1999/03/31  23:14:08  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.11  1998/04/25  18:17:18  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by kddinov for route
#
# Revision 1.10  1998/03/29  10:32:40  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by apazhani for route
#
# Revision 1.9  1998/03/17  14:46:12  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by kddinov for route
#
# Revision 1.8  1998/03/08  23:14:42  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by kddinov for route
#
# Revision 1.7  1998/01/19  17:28:56  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by lawaddel for route
#
# Revision 1.6  1998/01/14  18:42:22  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by lawaddel for route
#
# Revision 1.5  1997/12/18  18:57:16  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for: TR 179702478 by aharihar for route
#
# Revision 1.4  1997/12/11  18:03:10  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by r250_int for route
#
# Revision 1.3  1997/12/10  18:05:40  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for: CR 179421375 and CR 179603102 by aharihar for route
#
# Revision 1.2  1997/10/20  15:29:30  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by kddinov for route
#
# Revision 1.9  1997/10/01  22:11:04  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by kddinov for route
#
# Revision 1.8  1997/07/15  19:47:56  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by kddinov for route
#
# Revision 1.7  1997/05/19  06:03:52  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by apazhani for route
#
# Revision 1.6  1997/04/16  19:05:00  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by kddinov for route
#
# Revision 1.4  1997/04/10  13:01:16  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by hverstee for route
#
# Fluff changes in revision 1.5 
# 
# Revision 1.3  1997/03/04  05:10:22  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by apazhani for route
#
# Revision 1.2  1997/02/24  00:09:48  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by kddinov for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.9  1996/05/30  19:21:00  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by hverstee for route240
#
# Revision 1.8  1996/05/02  21:54:32  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by ashankar for route240
#
# Revision 1.7  1996/04/04  22:19:34  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by msmanem for route240
#
# Revision 1.5  1996/03/29  22:16:40  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by hverstee for route240
#
# Revision 1.4  1996/03/13  23:08:44  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by hverstee for route240
#
# Revision 1.3  1996/02/28  06:44:22  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by ashankar for route240
#
# Revision 1.2  1996/01/16  23:26:14  pinnacle
# Replaced: vrcorrection/VRCorrecti.I for:  by r240_int for route240
#
 *
 * History:
 *	11/23/90    momo	creation
 *	5/12/94     Mallik	While modifying the sizes of an elbow
 *				in rectangular shape, the reducer getting
 *				placed was not oriented properly.
 *	08/09/94i   Manyam	Modified the method "VRUpdateFlowArrow()"
 *				to place the arrow at the mid point of
 *				the correction
 *	01/15/96    tlb		Add VX_FIproto.h, prototypes
 *      03/04/97    Alwin       Set the proper option_code for mating FLANGE
 *      19/05/97    Alwin       "option_code" for mating FLANGE, is restricted
 *                              only if Parent Component is FLANGE.
 *      10/10/97    Anand       Revamped method VREvalComponent
 *      01/12/98    law         New shapes for raceway - CR179309874
 *      01/19/98    law         TR179702521/TR179702519 - Crashes on "Verify"
 *	3-98	    KDD		VRGetParams --> VRGetPrivateParams.
 *      03/31/99    law         TR179900487-fix spontaneous CONRED generation.
 *      05/04/99    Reddy       Doble value comparision corrected
 *      06/05/99    Reddy       Doble value comparision corrected - TR179900559
 *      01/25/00    law         tr179900976 - transition failures
 *     Jul 19 2k    Anand       CR 179901668 - Spec of Valve to be used as a
 *				criterion for querying a Mating flange
 *     May 07 01    Anand       JTS CR 5177 - End prep of mating flange should
 *     				be "compatible" (per the compatibility matrix
 *     				implemented in the verify function). Until now,
 *     				the condition imposed was end prep of mating
 *     				flange be EQUAL to end prep of parent.
 *     May 11 01    Anand       JTS TR 4998 - Correction component was
 *				returning wrong cpt index for its neighbor.
 *     Jul 24 01    Anand       JTS TR 5439 - Pipe was returning invalid cpt
 *				index when section 16 comps were placed.
 *     Jul 25 01    Anand       JTS TR 5418 - Mating flange not found for some
 *				workflows. Confusion regarding what "green" and
 *				"red" ends refer to w.r.t a network and a
 *				component's macro.
 *     Aug 22 01    jds		JTS TR 5453 - Mating flange is not being found.  This
 *     				is due to the determination of end_preps based on
 *     				prep_g for cpt00 and prep_r for cpt01.  Instead, it
 *     				will need to ask the cpt for its end_prep.
 *      04/05/02    law         TR5649-standardize tolerance with VRGetTol
 *      04/11/02    law         No TR-Major exclusive processing made it
 *                              desirable to clone this method under
 *                              VRPCorentity class. The piping code was deleted
 *                              from this method.
 *
 *************************************************************************/

class implementation VRCorrection;

/*
#define vdsDEBUG        1
*/

#include <math.h>
#include <stdlib.h>
#include "dp.h"
#include "csdef.h"
#include "nddef.h"
#include "bstypes.h"
#include "bsparameters.h"
#include "VRMath.h"
#include "VRcsdef.h" 
#include "VRattr_def.h"
#include "VRparamdef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "VRmacros.h"
#include "ndmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "VRpriv_attr.h"
#include "asmacros.h"
#include "csmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "parametric.h"
#include "asbox.h"
#include "ndmacros.h"
#include "vrparameters.h"
#include "VRcompdef.h" 
#include "VRcordef.h" 

#include "vrcorrec_pto.h"
#include "vrtools_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bspt_on_lne.h"
#include "mainvmx.h"
#include "matypemx.h"

#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"
#include "VRDbParamDef.h"
#include "vdbmacros.h"
#include "VRDbTbl.h"
#include "VDmem.h"
#include "VRPDBdef.h"	/* These two header files need to be included for  */
#include "VRPDBmac.h"	/* using macros pertaining to DB access thru cache */

/*
#define MY_DEBUG
*/

#define AS_DEBUG

from	ACncpx		import	ACget_NV_rep, ACmplace;
from	ACpretend	import	ACpconnect,
				ACgive_downscan;
from	ACpretendin	import	ACiconnect;
from	ACrg_collect	import	AClist_attribute,
				ACget_named_attribute,
                                ACmod_list_attribute,
				ACset_list_attribute;

from	VRGeneric	import	VRSetStatus,
				VRGetStatus,
				VRGetCptGeom,
                                VRGetPrivateParams,
                                VRChgParams,
				VRGetCptProp,
				VRGetSupports,
				VRGetCptOnSup,
				VRGetConnDesc,
				VRGetCorOnCpt,
				VRGetNextOnCpt,
				VRGetOrigCoor,
				VRGetInstance,
				VRSetInstance,
				VRGetNumberOfCpts,
				VRGetSysType,
                                VRGetCode,
				VRGetModel;

extern	IGRboolean	ASbroadcast_in_progress;
extern	struct GRid	NULL_GRID;
extern	GRclassid	OPP_VRHanger_class_id;
extern	GRclassid	OPP_ACpretend_class_id;
extern	GRclassid	OPP_ACpretendin_class_id;
extern  GRclassid	OPP_VRPNozz_class_id;
extern  GRclassid	OPP_VRCptIn_class_id;

extern	OM_S_CHANSELECT	AS_to_comp;

extern	int		VRCorrection_VRFlArSym();
extern	int		VRCorrection_VRFlArSc();
extern	int		VRprint_user_attr();

#define _VR_NE( a, b )  ( fabs ((a)-(b)) > VRGetTol(VR_DEFAULT_TOL) )

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetCptsInfo( IGRlong			*p_retmsg;
                      IGRint			NbParent;
                      struct	GRid		*p_MyParentId;
                      struct	GRmd_env	*p_MdEnv;
                      IGRshort			*NbVia;
                      IGRshort			*Cmp0CptIndex;
                      IGRshort			*Cmp1CptIndex;
                      IGRdouble			*Cpt0Coord;
                      IGRdouble			*Cpt1Coord;
                      IGRlong			*HaveToCorrectCmp0;
                      IGRlong			*HaveToCorrectCmp1;
		      struct	VRcp_attr	*ConProp0;
		      struct	VRcp_attr	*ConProp1 )

{
  IGRshort		NextParentIndex;
  IGRlong		status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid	NextParentId;

  SetProc( VRCorrection.VRGetCptsInfo );Begin

  
  *p_retmsg = MSSUCC;

  /*"My Parents = %d %d\n", p_MyParentId[0].objid, p_MyParentId[1].objid */

  if( Cmp0CptIndex && Cmp1CptIndex )
  {
	status =
	om$send( msg      = message VRGeneric.VRGetConnDesc
			( p_retmsg, &p_MyParentId[1], Cmp0CptIndex,
			  Cmp1CptIndex, p_MdEnv ),
		targetid = p_MyParentId[0].objid,
		targetos = p_MyParentId[0].osnum );
	as$status( action = RET_STATUS );
	if ( *p_retmsg != MSSUCC ) return OM_S_SUCCESS;

	/*"my parent 0 index is %d\n", *Cmp0CptIndex */
	/*"my parent 1 index is %d\n", *Cmp1CptIndex */

	/* test of consistency : needed when we do a delete by fence */
	status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                                       ( &retcode, *Cmp0CptIndex,
                                         &NextParentId, &NextParentIndex, 0,
                                         NbVia, NULL, NULL, p_MdEnv
                                       ),
			  targetid = p_MyParentId[0].objid,
			  targetos = p_MyParentId[0].osnum );
	as$status( action = RET_STATUS );

	/*"NextId = %d .. NextCpt = %d\n", NextParentId.objid, NextParentIndex */

	if( NextParentId.objid != p_MyParentId[1].objid )
	{
		/*| Not valid connection */

		*p_retmsg = MSFAIL;
		return OM_S_SUCCESS;
	}
  }
  else return OM_E_INVARG;

  status = VR$GetCptInfo( p_retmsg	= (HaveToCorrectCmp0) ? HaveToCorrectCmp0 : &retcode,
			p_CmpId	= &p_MyParentId[0],
			CmpCptNum	= *Cmp0CptIndex,
			p_CptCoord	= Cpt0Coord,
			p_CptProp	= ConProp0,
			p_MdEnv	= p_MdEnv );
  as$status( action = RET_STATUS );

  status = VR$GetCptInfo( p_retmsg	= (HaveToCorrectCmp1) ? HaveToCorrectCmp1 : &retcode, 
			p_CmpId	= &p_MyParentId[1],
			CmpCptNum	= *Cmp1CptIndex,
			p_CptCoord	= Cpt1Coord,
			p_CptProp	= ConProp1,
			p_MdEnv	= p_MdEnv );
  as$status( action = RET_STATUS );

  End
  return(OM_S_SUCCESS);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetCorCmpId( IGRlong			*msg;
		      IGRchar			*CorCmpName;
                      IGRshort			RealPos;
		      IGRint			ChanPos;
                      IGRint			*RetChanPos;
		      struct	GRid		*CorCmpId )
{
  IGRint		i;		/* index loop			*/
  IGRlong		status;		/* return code                 */

  SetProc( VRCorrection.VRGetCorCmpId );Begin

  *msg      = MSSUCC;
  status    = OM_S_SUCCESS;

  if( CorCmpName )
  {
    /*"CorCmpName = %s\n", CorCmpName */
    /*"NbCorCmp   = %d\n", me->my_NbCorCmp */

    for( i=0; i<me->my_NbCorCmp; i++ )
    {
      /*"CorCmpName = %s\n", me->my_StrCmpList[i].CmpName */

      if( ! strcmp( me->my_StrCmpList[i].CmpName, CorCmpName ) )
      {
        status = 
        om$get_objid_at_index ( objid	     = my_id,
                                p_chanselect = &AS_to_comp,
                                index	     = i,
                                objidaddr    = &CorCmpId->objid,
				osnumaddr    = &CorCmpId->osnum  );
        as$status( action = RET_STATUS );

        if( RetChanPos ) *RetChanPos = i;

	End
        return(OM_S_SUCCESS);
      }
    }
  }
  else if( RealPos != -1 )
  {
    /*"RealPos = %d\n", RealPos */

    for( i=0; i<me->my_NbCorCmp; i++ )
    {
      /*"CmpRealPos[%d] = %d\n", i, me->my_StrCmpList[i].CmpRealPos */

      if( me->my_StrCmpList[i].CmpRealPos == RealPos )
      {
        status = 
        om$get_objid_at_index ( objid	     = my_id,
                                p_chanselect = &AS_to_comp,
                                index	     = i,
                                objidaddr    = &CorCmpId->objid,
				osnumaddr    = &CorCmpId->osnum  );
        as$status( action = RET_STATUS );

        if( RetChanPos ) *RetChanPos = i;

        /*"CorCmpId = %d\n", CorCmpId->objid */

	End
        return(OM_S_SUCCESS);
      }
    }
  }
  else if( ChanPos != -1 )
  {
    status = om$get_objid_at_index ( objid	  = my_id,
                                     p_chanselect = &AS_to_comp,
                                     index	  = ChanPos,
                                     objidaddr    = &CorCmpId->objid,
				     osnumaddr    = &CorCmpId->osnum );
    as$status( action = RET_STATUS );

    if( RetChanPos ) *RetChanPos = ChanPos;

    End
    return(OM_S_SUCCESS);
  }

  CorCmpId->objid = NULL_OBJID;

  End
  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetCorCmpLength( IGRlong			*msg;
                          struct	GRid		*CorCmpId;
                          struct	GRmd_env	*md_env;
			  IGRdouble			*CorCmpLength )

{
  BSrc			bsretcode;		       /* BS return code     */
  IGRlong		status, retcode;               /* return code        */
  IGRdouble		Cpt0[3], Cpt1[3], CptVect[3];  /* Cpt coord.         */

  /*| Initialize return codes */
  SetProc( VRCorrection.VRGetCorCmpLength );Begin

  *msg     = MSSUCC;
  retcode  = MSSUCC;
  status   = OM_S_SUCCESS;


  if( !CorCmpId ) return OM_E_INVARG;

  /*"we ask CorCmpId %d for his length\n", CorCmpId->objid */
  
  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                               ( &retcode, 0, Cpt0, NULL, NULL, md_env ),
		    targetid = CorCmpId->objid,
		    targetos = CorCmpId->osnum  );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                               ( &retcode, 1, Cpt1, NULL, NULL, md_env ),
		    targetid = CorCmpId->objid,
		    targetos = CorCmpId->osnum  );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  BSmkvec( &bsretcode, CptVect, Cpt0, Cpt1 );

  /*"CptVect = %f %f %f\n", CptVect[0], CptVect[1], CptVect[2] */

  *CorCmpLength = BSlenvec( &bsretcode, CptVect );

  /*"CorCmpLength = %f\n", CorCmpLength */

  End
  return OM_S_SUCCESS;

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetCorCmpPretendId( IGRlong			*msg;
                             IGRchar			*CorCmpName;
                             struct	GRid		*CorCmpPretendId )

{
  IGRint		nb_child, i;
  IGRchar		downscan[80];  /*C Increased to 80. It was causing a */
				       /*C problem in down scan.	     */
  IGRlong		retcode, status;
  struct GRid		*list_child;
  GRclassid		obj_class;

  SetProc( VRCorrection.VRGetCorCmpPretendId );Begin

  *msg     = MSSUCC;
  retcode  = MSSUCC;
  status   = OM_S_SUCCESS;

  if( CorCmpName )
  {
    status = om$send( msg     = message NDnode.NDget_objects
                                ( ND_CHILDREN | ND_IN_BUF, NULL, 0, &list_child,
				  0, OM_K_MAXINT, &nb_child
                                ),
		      targetid = my_id );
    as$status( action = RET_STATUS );
        
    for( i=0 ; i < nb_child ; i++ )
    {
      status = om$get_classid( osnum     = list_child[i].osnum, 
			       objid     = list_child[i].objid, 
			       p_classid = &obj_class );
      as$status( action = RET_STATUS );

      /*"child[%d] ID = %d\n", i, list_child[i].objid */

      if( om$is_ancestry_valid( subclassid   = obj_class,
			      superclassid = OPP_ACpretend_class_id )
                                                               == OM_S_SUCCESS )
      {
        /*| it is a pretend */

        status = om$send(msg      = message ACpretend.ACgive_downscan(downscan),
			 targetid = list_child[i].objid, 
			 targetos = list_child[i].osnum );
        
        if( !strcmp( downscan, CorCmpName ) )
        {
          /*| the pretend allready exist */

          *CorCmpPretendId = list_child[i];
      
          return OM_S_SUCCESS;
        }
      }
    }

    /*| Not Pretend */

    CorCmpPretendId->objid = NULL_OBJID;

  End
    return OM_S_SUCCESS;
  }

  as$status(sts = OM_E_ABORT, msg = "Argument not valid");
   
  End
  return(OM_E_ABORT);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetPipeTempId( IGRlong			*msg;
			IGRint			ChanPos;
                        struct	GRmd_env	*md_env;
			struct	GRid		*PipeTempId;
			IGRshort		*TempCpt )

{
  IGRshort			TempRealPos;
  IGRint			Index1, Index, NbChild;
  IGRuint			NbCmp;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid		PipeId;
  struct	VRGenInfo	Instance;

  SetProc( VRCorrection.VRGetPipeTempId );Begin

  *msg    = MSSUCC;

  /*"Pipe ChanPos = %d\n", ChanPos */
  NbCmp = me->my_NbCorCmp;

/*
  status = om$get_channel_count( objid		= my_id,
				 p_chanselect	= &AS_to_comp,
				 count		= &NbCmp );
  as$status( action = RET_STATUS );
*/

  if( ChanPos == -1 )
  {
	/* the pipe is connected */

	/*| get pipe */
	status = om$send( msg    = message VRCorrection.VRGetCorCmpId
				   ( &retcode,
				     "PIPE", 
				     -1,
				     -1,
				     &ChanPos,
				     &PipeId ),
			  targetid = my_id );
	as$status( action = RET_STATUS );
	
	/* return with an error if ChanPos < 0 */
	if( ChanPos < 0 )
	{
	  as$status( sts = OM_E_ABORT, msg = "Can Not Proceed further, Process Aborted" );
	  return(OM_E_ABORT);
	}

	Index1 = ( NbCmp) ? NbCmp-1 : 0;
	TempRealPos = me->my_StrCmpList[ChanPos].CmpRealPos+1;
  }
  else
  {
	/* the pipe is not connected */
	Index1 = ( NbCmp ) ? NbCmp : 0;
	TempRealPos = me->my_StrCmpList[ChanPos].CmpRealPos;
  }

  /*"Pipe RealPos = %d\n", me->my_StrCmpList[ChanPos].CmpRealPos */
  /*"Index1 = %d NbCmp = %d\n", Index1, NbCmp */

  if( me->my_StrCmpList[ChanPos].CmpRealPos == 0 ||
			me->my_StrCmpList[ChanPos].CmpRealPos == Index1 )
  {
	/*| get my parents */
	status = om$send( msg    = message NDnode.NDget_objects
				   ( ND_ROOT, PipeTempId, 2, NULL, 0, OM_K_MAXINT,
				     &NbChild
				   ),
			  targetid = my_id );
	as$status( action = RET_STATUS );
  }

  if( me->my_StrCmpList[ChanPos].CmpRealPos == 0 ) TempCpt[0] = me->my_CmpCptIndex[0];
  else
  {
	status = om$send( msg    = message VRCorrection.VRGetCorCmpId
				   ( &retcode,
				     NULL, 
				     me->my_StrCmpList[ChanPos].CmpRealPos-1,
				     -1,
				     &Index,
				     &PipeTempId[0] ),
			  targetid = my_id );
	as$status( action = RET_STATUS );

	status = om$send( msg      = message VRGeneric. VRGetInstance 
						   ( &retcode, &Instance ),
			  targetid = PipeTempId[0].objid,
			  targetos = PipeTempId[0].osnum );
	as$status( action = RET_STATUS );

	TempCpt[0] = 1 - Instance.nJustif;
  }

  if( me->my_StrCmpList[ChanPos].CmpRealPos == Index1 ) TempCpt[1] = me->my_CmpCptIndex[1];
  else
  {
	status = om$send( msg    = message VRCorrection.VRGetCorCmpId
				   ( &retcode,
				     NULL, 
				     TempRealPos,
				     -1,
				     &Index,
				     &PipeTempId[1] ),
			  targetid = my_id );
	as$status( action = RET_STATUS );

	status = om$send( msg      = message VRGeneric. VRGetInstance 
						   ( &retcode, &Instance ),
			  targetid = PipeTempId[1].objid,
			  targetos = PipeTempId[1].osnum );
	as$status( action = RET_STATUS );

	TempCpt[1] = 1 - Instance.nJustif;
  }

  /*"Cmp0 = %d %d\n",  PipeTempId[0].objid, TempCpt[0] */
  /*"Cmp1 = %d %d\n",  PipeTempId[1].objid, TempCpt[1] */

  return(OM_S_SUCCESS);

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetPipeCpts( IGRlong			*msg;
                      struct	GRmd_env	*md_env;
		      IGRdouble			*PipeCptsCoord )

{
  IGRshort		CompCpt[2];
  struct	GRid	ComponentId[2];
  IGRlong		status=OM_S_SUCCESS, retcode=MSSUCC;

  SetProc( VRCorrection.VRGetPipeCpts );Begin

  *msg    = MSSUCC;

  status = om$send( msg      = message VRCorrection.VRGetPipeTempId
			       ( &retcode, -1, md_env, ComponentId,
				 CompCpt ),
		    targetid = my_id );

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                               ( &retcode, CompCpt[0], &PipeCptsCoord[0], NULL,
				 NULL, md_env ),
                    targetid = ComponentId[0].objid,
                    targetos = ComponentId[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"PipeCpts = %f %f %f\n", PipeCptsCoord[0],PipeCptsCoord[1],PipeCptsCoord[2] */

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                               ( &retcode, CompCpt[1], &PipeCptsCoord[3], NULL,
				 NULL, md_env ),
                    targetid = ComponentId[1].objid,
                    targetos = ComponentId[1].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"PipeCpts = %f %f %f\n", PipeCptsCoord[3],PipeCptsCoord[4],PipeCptsCoord[5] */

  return(OM_S_SUCCESS);

}

/*********************************************************/

method	VRNotifyDelete( 
	IGRlong			*msg;		/* I/O : return status*/
	IGRint			NbParents;	/* I :	Nb of deleted parents*/
	struct GRid		*ParentIds	/* I : Array containing the
						       deleted parents list*/
)
{
	IGRint		WaitIndex, i;
	IGRlong		status = OM_S_SUCCESS;
	struct	GRid	MyId;

	SetProc( VRCorrection.VRNotifyDelete );Begin

	/*A initialization */
	*msg = MSSUCC;

	if ( NbParents <0 || NbParents > my_nbParent )
			goto wrapup;

	MyId.objid = my_id;
	MyId.osnum = OM_Gw_current_OS;

	/*"MyId = %d %d\n", MyId.objid, MyId.osnum */

	/*A check whether i am in the batch list */
	status =
	NDis_waiting( GR_DELETED, 0, &MyId, &WaitIndex, NULL, NULL, 1 );

	/* "WaitIndex = %d \n", WaitIndex */

	/*A if i am in set both cpt indexs to -1 */
	if ( WaitIndex != -1 || NbParents == my_nbParent )
	{
		for ( i=0; i< my_nbParent; i++ )
			me->my_CmpCptIndex[i] = -1;
		goto	wrapup;
	}


	if ( !ParentIds || !NbParents )
		goto	wrapup;

	/*A if i come here it means that only one of my parents is
	    going to be deleted */

	{
		IGRint		NbRoots;
		struct	GRid	*pBuffer;

		/*A get my parents	*/
		status = 
		om$send( msg	 = message NDnode.NDget_objects(
					ND_ROOT | ND_IN_BUF,
					NULL,
					0,
					&pBuffer,
					0,
					OM_K_MAXINT,
					&NbRoots ),
			targetid = my_id);
		as$status( action = RET_STATUS );

		/*A we support only two parents for a correction.
		    My first parent is going to be deleted( which
		    means that previous second parent will be now
		    first parent ). I need to update my instance
		    data so that it will be compatible with this
		    new ordering.
		*/
		if ( ParentIds->objid == pBuffer[0].objid &&
		   ParentIds->osnum == pBuffer[0].osnum )
			me->my_CmpCptIndex[0] = me->my_CmpCptIndex[1];

		/*C Currently only the cpt index of the Cmps is 
		    dependent on the order in which the parents
		    are connected. If there is any other data
		    that also can be updated here ( in future )
		*/
	}

wrapup :

	End
	return(OM_S_SUCCESS);
  
}

/*****************************************************************************/

method VRGetDynCpts( IGRlong			*msg;
                     struct	GRid		*CmpId;
                     IGRshort			*NbCpts;
                     struct	GRmd_env	*md_env )

{
  IGRint		NbParent;
  IGRlong		status=OM_S_SUCCESS, retcode=MSSUCC;
  OMuint		ChanPos;
  struct	GRid	FatherId[2];

  /*| Initialize return codes */
  SetProc( VRCorrection.VRGetDynCpts );Begin


  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;
  *NbCpts = 0;


  status = om$send( msg      = message NDnode.NDget_objects
                                       ( ND_ROOT, FatherId, my_nbParent,
                                         NULL, 0, OM_K_MAXINT, &NbParent
                                       ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  if( NbParent != my_nbParent )
  {
    as$status( sts = OM_E_ABORT, msg = "number of my parents is not valid" );
    return(OM_E_ABORT);
  }

  status = om$get_index( objid_c      = my_id,
                         p_chanselect = &AS_to_comp,
                         objid        = CmpId->objid,
                         osnum2       = CmpId->osnum,
                         indexaddr    = &ChanPos );
  as$status( action = RET_STATUS );

  /*" Pos On Chan = %d\n", ChanPos */
  /*" Com name = <%s>\n", me->my_StrCmpList[ChanPos].CmpName */

  if( !strcmp( me->my_StrCmpList[ChanPos].CmpName, "PIPE" ) )
  {
    status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                                 ( &retcode, me->my_CmpCptIndex[0], NULL,
                                   NULL, 0, NbCpts, NULL, NULL, md_env ),
                      targetid = FatherId[0].objid,
                      targetos = FatherId[0].osnum );

    /*"NbCpts = %d\n", *NbCpts */
  }

  End
  return(OM_S_SUCCESS);

}

/*****************************************************************************/

method VRGetNeighbor( IGRlong			*msg;
                      struct	GRid		*FatherId;
                      IGRint			CorCmpChanPos;
                      IGRshort			CmpCptIndex;
                      struct	GRmd_env	*md_env;
                      struct	GRid		*CmpNeighborId;
                      IGRshort			*CmpNeighborCptIndex )
{
  IGRshort		FatherIndex, NeighPos;
  IGRlong		status, retcode;
  IGRint		NeighborChanPos; 
  struct	GRid	LocalNeighId, *p_CmpNeighborId;

  SetProc( VRCorrection.VRGetNeighbor );Begin

  /*| Initialize return codes */

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  __DBGpr_int("Seeking neighbor of component @ Channel Position",CorCmpChanPos);
  __DBGpr_int("Seeking neighbor at cpt Index", CmpCptIndex );

  if( CmpNeighborId ) p_CmpNeighborId = CmpNeighborId;
  else                p_CmpNeighborId = &LocalNeighId;

  if( !strcmp( me->my_StrCmpList[CorCmpChanPos].CmpName, "PIPE" ) )
  {
    if( CmpCptIndex == 0 )
                   NeighPos = me->my_StrCmpList[CorCmpChanPos].CmpRealPos - 1;
    else           NeighPos = me->my_StrCmpList[CorCmpChanPos].CmpRealPos + 1;
  }
  else
  {
    if( CmpCptIndex == me->my_StrCmpList[CorCmpChanPos].CmpJustification )
    {
      if( me->my_StrCmpList[CorCmpChanPos].CmpFatherIndex == 0 ) 
                     NeighPos = me->my_StrCmpList[CorCmpChanPos].CmpRealPos - 1;
      else           NeighPos = me->my_StrCmpList[CorCmpChanPos].CmpRealPos + 1;
    }
    else
    {
      if( me->my_StrCmpList[CorCmpChanPos].CmpFatherIndex == 0 )
                     NeighPos = me->my_StrCmpList[CorCmpChanPos].CmpRealPos + 1;
      else           NeighPos = me->my_StrCmpList[CorCmpChanPos].CmpRealPos - 1;
    }
  }

  if( NeighPos == -1 || NeighPos == me->my_NbCorCmp )
  {
    if( NeighPos == -1 ) FatherIndex = 0;
    else                 FatherIndex = 1;

    if( CmpNeighborId ) *p_CmpNeighborId = FatherId[FatherIndex];

    if( CmpNeighborCptIndex )
    {
      *CmpNeighborCptIndex = me->my_CmpCptIndex[FatherIndex];
    }
  }
  else
  {
    status = om$send( msg      = message VRCorrection.VRGetCorCmpId
                                ( &retcode, NULL, NeighPos, -1,
                                  &NeighborChanPos, p_CmpNeighborId
                                ),
                     targetid = my_id );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );

    if( CmpNeighborCptIndex )
    {
      __DBGpr_int("CmpF.Index",
			   me->my_StrCmpList[CorCmpChanPos].CmpFatherIndex   );
      __DBGpr_int("NeiF.Index",
			   me->my_StrCmpList[NeighborChanPos].CmpFatherIndex );
      __DBGpr_int("CmpRealPos",
			   me->my_StrCmpList[CorCmpChanPos].CmpRealPos       );
      __DBGpr_int("NeiRealPos",
			   me->my_StrCmpList[NeighborChanPos].CmpRealPos     );

      if( me->my_StrCmpList[CorCmpChanPos].CmpFatherIndex == 
                            me->my_StrCmpList[NeighborChanPos].CmpFatherIndex )
      {
        if( me->my_StrCmpList[CorCmpChanPos].CmpFatherIndex == 0 )
        {
          if( !strcmp( me->my_StrCmpList[NeighborChanPos].CmpName, "PIPE" ) )
                                                     *CmpNeighborCptIndex = 0;
          else
          {
            if( me->my_StrCmpList[CorCmpChanPos].CmpRealPos < 
                                me->my_StrCmpList[NeighborChanPos].CmpRealPos )
            *CmpNeighborCptIndex =
                           me->my_StrCmpList[NeighborChanPos].CmpJustification;
            else
                *CmpNeighborCptIndex = 
                       1 - me->my_StrCmpList[NeighborChanPos].CmpJustification;
          }
        }
        else
        {
          if( me->my_StrCmpList[CorCmpChanPos].CmpRealPos < 
                                me->my_StrCmpList[NeighborChanPos].CmpRealPos )
            *CmpNeighborCptIndex =
                       1 - me->my_StrCmpList[NeighborChanPos].CmpJustification;
          else *CmpNeighborCptIndex =
                           me->my_StrCmpList[NeighborChanPos].CmpJustification;
        }
      }
      else
      {
        if( !strcmp( me->my_StrCmpList[NeighborChanPos].CmpName, "PIPE" ) )
	{
	    /* Begin fix for TR 5439 */
	    IGRshort	NbDynCpts;

	    status =
	    om$send( msg = message VRCorrection.VRGetDynCpts( &retcode,
							      p_CmpNeighborId,
							      &NbDynCpts,
							      md_env ),
		     targetid = my_id );

	    // Add the number of Dyn cpts to the cpt index.
	    *CmpNeighborCptIndex = 1+NbDynCpts;
	    /* End fix for TR 5439 */
	}
        else
	    *CmpNeighborCptIndex =
                       1 - me->my_StrCmpList[NeighborChanPos].CmpJustification;
      }      
    }
  }

  End
  return(OM_S_SUCCESS);

}

/*****************************************************************************/

method VRGetCmpNeighbor( IGRlong			*msg;
                         struct		GRid		*CmpToGetNeighborId;
                         IGRint				IndexFrom;
                         IGRint				IndexTo;
                         IGRshort			*NbNeighbor;
                         struct		GRid		*CmpNeighborId;
                         IGRshort			*CmpNeighborCptIndex;
                         struct		GRmd_env	*md_env )
{
  IGRint		NbCpts, CptIndex, i;		
  IGRint		NbParent;
  IGRshort		FatherIndex;
  IGRshort		NeighPos;
  IGRuint		CorCmpChanPos;
  IGRint		NeighborChanPos;
  IGRlong		status, retcode;       
  struct	GRid	FatherId[my_nbParent]; 

  /*| Initialize return codes */

  SetProc( VRCorrection.VRGetCmpNeighbor );Begin

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;


  if( ( ! CmpNeighborId && ! CmpNeighborCptIndex && ! NbNeighbor ) ||
        ! CmpToGetNeighborId || ( IndexFrom > IndexTo ) || ( IndexFrom < 0 ) 
    )
  {
      End
      return OM_E_INVARG;
  }

  *NbNeighbor = 0;

  /*^
      status = om$send( msg      = message VRCorrection.VRShowInstance(),
                        targetid = my_id );
  */

  status = om$send( msg      = message NDnode.NDget_objects
                                       ( ND_ROOT, FatherId, my_nbParent,
                                         NULL, 0, OM_K_MAXINT, &NbParent
                                       ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  if( NbParent != my_nbParent )
  {
    as$status( sts = OM_E_ABORT, msg = "number of my parents is not valid" );
    End
    return(OM_E_ABORT);
  }

  __DBGpr_me();
  __DBGpr_obj(" CmpToGetNeighborId", *CmpToGetNeighborId);
  __DBGpr_obj(" Parent 0",FatherId[0]);
  __DBGpr_obj(" Parent 1",FatherId[1]);

       if( CmpToGetNeighborId->objid == FatherId[0].objid ) FatherIndex =  0;
  else if( CmpToGetNeighborId->objid == FatherId[1].objid ) FatherIndex =  1;
       else                                                 FatherIndex = -1; 

  if( FatherIndex != -1 )
  {
    __DBGpr_obj("My parent asks for his neighbor", *CmpToGetNeighborId );

    if( IndexFrom != me->my_CmpCptIndex[FatherIndex] )
    {
	End
	return OM_E_INVARG;
    }

    *NbNeighbor = 1;

    if( ! me->my_NbCorCmp ) // FTF or components butted up against each other.
    {
      if( CmpNeighborId )
      {
        CmpNeighborId[0] = FatherId[1-FatherIndex];
        __DBGpr_obj(" CmpNeighborId is the other parent",CmpNeighborId[0]);
      }

      if( CmpNeighborCptIndex )
      {
        /*| get CmpNeighborCptIndex */

        CmpNeighborCptIndex[0] = me->my_CmpCptIndex[1-FatherIndex];

        /*"Neighbor index is %d\n", *CmpNeighborCptIndex */
      }
    }
    else
    {
	/* Correction components exist and Parent desires to know
	 * neighboring correction component => one of the extreme
	 * components in the correction is being sought. */

      if( FatherIndex ) NeighPos = me->my_NbCorCmp - 1;
      else              NeighPos = 0;

      /*"NeighPos = %d\n", NeighPos */

      if( CmpNeighborId )
      {
	  __DBGpr_int(" Calling VRGetCorCmpId with NeighPos",NeighPos);
        status = om$send( msg      = message VRCorrection.VRGetCorCmpId
                                     ( &retcode, NULL, NeighPos, -1, 
                                       &NeighborChanPos, &CmpNeighborId[0]
                                     ),
                          targetid = my_id );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );
      
        /*"NeighChanPos = %d\n", NeighborChanPos */
	__DBGpr_obj(" Cor cmp id from VRGetCorCmpId",CmpNeighborId[0]);
      }

      if( CmpNeighborCptIndex )
      {
        /*| Get CmpNeighborCptIndex */

        if( !strcmp( me->my_StrCmpList[NeighborChanPos].CmpName, "PIPE" ) )
        {
          CmpNeighborCptIndex[0] = FatherIndex;
        }
        else
        {
          CmpNeighborCptIndex[0] =
                          me->my_StrCmpList[NeighborChanPos].CmpJustification;

          if(me->my_StrCmpList[NeighborChanPos].CmpFatherIndex != FatherIndex)
          {
            CmpNeighborCptIndex[0] = 1 - CmpNeighborCptIndex[0];
          }
        }

        /* we do this to have a generic behaviour. this will work if we connect 
        /* tap or olet on the component
        /**/

        if( CmpNeighborCptIndex && CmpNeighborCptIndex[0] )
        {
          status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
                                               ( &retcode, &NbCpts, md_env ),
                           targetid = CmpNeighborId[0].objid,
                           targetos = CmpNeighborId[0].osnum );
          as$status( action = RET_STATUS );
          as$status( sts = retcode, action = RET_STATUS );

          CmpNeighborCptIndex[0] = NbCpts - 1;
        }
      }
    }
  }
  else
  {
    status = om$get_index( objid_c      = my_id,
                           p_chanselect = &AS_to_comp,
                           objid        = CmpToGetNeighborId->objid,
                           osnum2       = CmpToGetNeighborId->osnum,
                           indexaddr    = &CorCmpChanPos );
    as$status( action = RET_STATUS );

    /* component asking for his neighbors is a pipe */

    if( !strcmp( me->my_StrCmpList[CorCmpChanPos].CmpName, "PIPE" ) )
    {
      IGRshort		NbVia=0;
      IGRshort		*ViaCpNum=NULL;
      struct	GRid	*ListVia=NULL;

      /* get all pipe olets */

      status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                                   ( &retcode, me->my_CmpCptIndex[0], NULL,
                                     NULL, 0, &NbVia, NULL, NULL, md_env ),
                        targetid = FatherId[0].objid,
                        targetos = FatherId[0].osnum );

      /*"NbVia = %d\n", NbVia */

      if( NbVia )
      {
	ListVia = _MALLOC ( NbVia, struct GRid );
	ViaCpNum = _MALLOC ( NbVia, IGRshort );

        /*  ListVia  = ( struct GRid * ) malloc( SizeMalloc * NbVia );
         *  ViaCpNum = ( IGRshort * )    malloc( sizeof( IGRshort ) * NbVia );
	 */

        if( ListVia && ViaCpNum )
        {
          NbVia = 0;

          status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                                       ( &retcode, me->my_CmpCptIndex[0], NULL,
                                         NULL, NbVia, &NbVia, ListVia, ViaCpNum,
                                         md_env ),
                            targetid = FatherId[0].objid,
                            targetos = FatherId[0].osnum );
          as$status();

          /*^
              for( i=0; i<NbVia; i++ )
              { 
                printf("VRCorrect.VRGetCmpNeighbor\t ViaId[i]= %d,ViaCpt= %d\n",
                                               ListVia[i].objid, ViaCpNum[i] );
              }
          */              
        }
      }

      /* get neigh and cpt */

      for( CptIndex=IndexFrom, i=0; CptIndex<NbVia+2 && CptIndex<=IndexTo;
                                                               CptIndex++, i++ )
      {                                
        *NbNeighbor += 1;

        if( CptIndex == 0 || CptIndex == NbVia+1 )
        {
          /* neighbors other than olets */

          status = om$send
          ( msg      = message VRCorrection.VRGetNeighbor
                       ( &retcode, FatherId, CorCmpChanPos, CptIndex,md_env,
                         (CmpNeighborId) ? &CmpNeighborId[i] : NULL,
                         (CmpNeighborCptIndex) ? &CmpNeighborCptIndex[i] : NULL ),
            targetid = my_id );
          as$status();

          /*^
             if( CmpNeighborId )       printf("CmpNeigh = %d\n", CmpNeighborId[i].objid );
             if( CmpNeighborCptIndex ) printf("CmpNeighborCptIndex = %d\n", CmpNeighborCptIndex[i] );
          */
        }
        else
        {
          if( CmpNeighborId && ListVia )
          {
            CmpNeighborId[i] = ListVia[CptIndex-1]; 
            /*"CmpNeighborId = %d\n", CmpNeighborId[i].objid */
          }

          if( CmpNeighborCptIndex && ViaCpNum )
          {
            CmpNeighborCptIndex[i] = ViaCpNum[CptIndex-1];
            /*"CmpNeighborCptIndex = %d\n", CmpNeighborCptIndex[i] */
          }
        }
      }

     /* if( ListVia  ) free( ListVia );
      * if( ViaCpNum ) free( ViaCpNum );
      */
	_FREE ( ListVia );
	_FREE ( ViaCpNum );
    }
    else
    {
      for( CptIndex=IndexFrom, i=0; CptIndex<2 && CptIndex<=IndexTo; 
                                                               CptIndex++, i++ )
      {
        *NbNeighbor += 1;

        status = om$send ( msg      = message VRCorrection.VRGetNeighbor
                     ( &retcode, FatherId, CorCmpChanPos, CptIndex, md_env,
                       (CmpNeighborId) ? &CmpNeighborId[i] : NULL,
                       (CmpNeighborCptIndex) ? &CmpNeighborCptIndex[i] : NULL ),
          targetid = my_id );

        /*^ 
            if( CmpNeighborId ) printf("CmpNeigh = %d\n", CmpNeighborId[i].objid );
	    printf(" CmpNeighborCptIndex %d\n",CmpNeighborCptIndex[i]);
        */

	/* The below code commented by Anand for JTS TR 4998. Why was
	 * CmpNeighborCptIndex[i] (that was correctly returned by
	 * VRCorrection.VRGetNeighbor) being overwritten, and being
	 * overwritten by a value as absurd as NbCpts-1 was not
	 * understood. The fact that commenting it out fixed the
	 * TR was explanation enough that the below code was absurd.
	 * 					Anand (May 11, 2001) */

#if 0
        if( CmpNeighborCptIndex && CmpNeighborCptIndex[i] )
        {
          status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
                                               ( &retcode, &NbCpts, md_env ),
                           targetid = CmpNeighborId[i].objid,
                           targetos = CmpNeighborId[i].osnum );
          as$status();
          as$status( sts = retcode );

          CmpNeighborCptIndex[i] = NbCpts - 1;
        }
#endif

        /*^
            if( CmpNeighborCptIndex ) printf("CmpNeighindex = %d\n", CmpNeighborCptIndex[i] );
        */
      }
    }
  }

  __DBGpr_int(" NbNeigh", *NbNeighbor );
  for( i=0 ; i<*NbNeighbor ; i++ )
  {
      if( CmpNeighborId )
	  __DBGpr_obj("CmpNeigh", CmpNeighborId[i] );
      if( CmpNeighborCptIndex )
	  __DBGpr_int("CmpNeighindex", CmpNeighborCptIndex[i] );
  }

  End
  return(OM_S_SUCCESS);

}

/*****************************************************************************/

method VRGetCptIndex( IGRlong		*msg;
                      struct	GRid	*MyParentId;
                      IGRshort		*MyParentCptIndex )
{
  IGRshort		FatherIndex;
  IGRint		NbFather;
  IGRlong		status;
  struct	GRid	FatherId[my_nbParent];

  SetProc( VRCorrection.VRGetCptIndex );Begin

  *msg   = MSSUCC;
  status = OM_S_SUCCESS;

  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, FatherId, my_nbParent, NULL, 0, 
                                 OM_K_MAXINT, &NbFather ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  /*"my parent %d ask for his cpt index\n", MyParentId->objid */
  /*"Father 0 id = %d\n", FatherId[0].objid */

  if( FatherId[0].objid == MyParentId->objid ) FatherIndex = 0;
  else                                         FatherIndex = 1;

  *MyParentCptIndex = me->my_CmpCptIndex[FatherIndex];

  /*"MyParentCptIndex = %d\n", *MyParentCptIndex */

  return(OM_S_SUCCESS);

}

/*****************************************************************************/

method VRChgCorInstance( IGRlong	*msg;
                         IGRshort	*FittingToFitting;
			 IGRshort	*MyFirstParentCptIndex;
			 IGRshort	*MySecondParentCptIndex  )
{
  SetProc( VRCorrection.VRChgCorInstance );Begin

  *msg = MSSUCC;

  if( FittingToFitting )
  {
    if(   *FittingToFitting  &&  !(me->my_state&VR_FIT_TO_FIT) )
    {
		/* -- Switch to FtoF -- */
		me->my_state |=  VR_FIT_TO_FIT ;
		/* -- Force full recompute -- */
		me->my_state |=  VR_UPDATE_CON ;
    }
    if( !(*FittingToFitting) &&   (me->my_state&VR_FIT_TO_FIT) )
    {
		/* -- Switch to Not FtoF -- */
		me->my_state &= ~VR_FIT_TO_FIT;
		/* -- Force full recompute -- */
		me->my_state |=  VR_UPDATE_CON ;
    }

    /*"my new state = %d\n", me->my_state */
  }

  if( MyFirstParentCptIndex )
  {
    me->my_CmpCptIndex[0] = *MyFirstParentCptIndex;

    /*"my new Parent0 Cpt Index = %d\n", me->my_CmpCptIndex[0] */
  }

  if( MySecondParentCptIndex )
  {
    me->my_CmpCptIndex[1] = *MySecondParentCptIndex;

    /*"my new Parent1 Cpt Index = %d\n", me->my_CmpCptIndex[1] */
  }

  return(OM_S_SUCCESS);

}


/*****************************************************************************/

method VRUpdateConnection( IGRlong		 *msg;
                           struct	GRid	 *CmpToAskForNextParentId;
                           IGRshort		 CmpToAskForNextParentIndex;
                           struct	GRmd_env *md_env )
{
  IGRshort		NextParentIndex;
  IGRshort		MyOldParentIndex;
  IGRint                NbFather;
  IGRlong		status;
  IGRlong		retcode;
  struct	GRid	NextParentId;
  struct	GRid	FatherId[my_nbParent];

  SetProc( VRCorrection.VRUpdateConnection );Begin

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;


  /* Get my actual parent */

  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, FatherId, my_nbParent, NULL, 0,
                                 OM_K_MAXINT, &NbFather
                               ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  /*^
      IGRint i;
      for( i=0; i<NbFather; i++ )
      {
        printf("VRCorrection.VRUpdateConnection : Parent %d objid is %d\n", 
                                                       i, FatherId[i].objid );
      }
  */

  /*"CmpToAskForTheNextParent = %d\n", CmpToAskForNextParentId->objid */

  status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                                       ( &retcode, CmpToAskForNextParentIndex,
                                         &NextParentId, &NextParentIndex, 0,
                                         NULL, NULL, NULL, md_env 
                                       ),
                    targetid = CmpToAskForNextParentId->objid,
                    targetos = CmpToAskForNextParentId->osnum );
  as$status( action = RET_STATUS );

  if( NextParentId.objid == NULL_OBJID ) return(OM_S_SUCCESS);

  if(CmpToAskForNextParentId->objid == FatherId[0].objid) MyOldParentIndex=1;
  else                                                    MyOldParentIndex=0;

  if( NbFather > 1 && NextParentId.objid == FatherId[MyOldParentIndex].objid )
  {
    me->my_state |= VR_UPDATE_CON;

    /*"my_state = %x\n", me->my_state */

    return OM_S_SUCCESS;
  }

  if( NbFather > 1 )
  {
    /*"I change parent = %d by %d\n", FatherId[MyOldParentIndex].objid, NextParentId.objid */

    status = om$send( mode     = OM_e_wrt_message,
                      msg      = message NDnodein.NDchange_connect
                                         ( 1, &FatherId[MyOldParentIndex], 
                                           &NextParentId
                                         ),
                      targetid = my_id );
    as$status( action = RET_STATUS );
  }
  else
  {
    status = om$send( msg      = message NDnode.NDconnect
                                 ( 1, &NextParentId, NULL_GRID, ND_NEW ),
                      targetid = my_id );
    as$status( action = RET_STATUS );
  }
    
  me->my_state |= VR_UPDATE_CON;

  /*"my_state = %x\n", me->my_state */

  return(OM_S_SUCCESS);

}

/*****************************************************************************/

method VRNotifyModif( IGRlong	*msg )
{
  SetProc( VRCorrection.VRNotifyModif );Begin

  *msg = MSSUCC;

  me->my_state |= VR_UPDATE_CON;
  
  End
  return(OM_S_SUCCESS);
}

/*****************************************************************************/

method VRGetCorLength( IGRshort			Type; 
                       struct	GRmd_env	*md_env;
		       IGRdouble		*MyLength )
{
  IGRint		i;
  IGRlong		retcode=MSSUCC, status=OM_S_SUCCESS;
  IGRdouble		CmpLength[MAX_CorCmp];
  struct	GRid	CmpId;

  SetProc( VRCorrection.VRGetCorLength );Begin

  *MyLength = 0.;

  for( i=0; i<me->my_NbCorCmp; i++ )
  {
	status = om$send( msg      = message VRCorrection.VRGetCorCmpId
				     ( &retcode, NULL, -1, i, NULL, &CmpId ),
                          targetid = my_id );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	status = om$send( msg       = message VRCorrection.VRGetCorCmpLength
				    ( &retcode, &CmpId, md_env, &CmpLength[i] ),
			targetid = my_id );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
  }
	

  switch( Type )
  {
    case 0 :
	for( i=0; i<me->my_NbCorCmp; i++ ) *MyLength += CmpLength[i];
    break;

    case 1 :
	for( i=0; i<me->my_NbCorCmp; i++ )
	{
		if( !strcmp( me->my_StrCmpList[i].CmpName, "PIPE" ) ) continue;

		*MyLength += CmpLength[i];	
	}
    break;

    case 2 :
	for( i=0; i<me->my_NbCorCmp; i++ )
	{
		if( !strcmp( me->my_StrCmpList[i].CmpName, "PIPE" ) )
		{
			*MyLength = CmpLength[i];	
			break;
		}
	}
    break;

    case 3 : 
	for( i=0; i<me->my_NbCorCmp; i++ )
	  if( me->my_StrCmpList[i].CmpFatherIndex == 0 &&
		 strcmp( me->my_StrCmpList[i].CmpName, "PIPE" ) ) *MyLength += CmpLength[i];
    break;

    case 4 : 
	for( i=0; i<me->my_NbCorCmp; i++ )
	  if( me->my_StrCmpList[i].CmpFatherIndex == 1 ) *MyLength += CmpLength[i];
    break;

    default : return OM_E_INVARG;
  }

  /*"MyLength = %f\n", *MyLength */

  End
  return OM_S_SUCCESS;
}

/*****************************************************************************/

method VRMergeCorrection( IGRlong			*msg;
			  struct	GRid		*OldCmpId;
			  struct	GRmd_env	*md_env )
{
  IGRshort		FatherIndex, NextParentIndex;
  IGRint		i, Count, NbFather, CorToDeleteType;
  IGRlong		status, retcode;
  struct	GRid	my_grid;
  struct	GRid	CorId;			 /* correction to notify      */
  struct	GRid	NextParentId;            /* my new parent             */
  struct	GRid	FatherId[my_nbParent];   /* my parent grid list       */
  struct	GRid	*p_Buffer;

  SetProc( VRCorrection.VRMergeCorrection );Begin

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /* whose father is old component */
  status = om$send( msg      = message NDnode.NDget_objects
                                       ( ND_ROOT, FatherId, my_nbParent, NULL,
                                         0, OM_K_MAXINT, &NbFather
                                       ),
                    targetid = my_id );

  if(FatherId[0].objid == OldCmpId->objid) FatherIndex = 1;
  else                                     FatherIndex = 0;

  status = om$send( msg      = message VRGeneric.VRGetNextOnCpt
                               ( &retcode, me->my_CmpCptIndex[FatherIndex],
                                 &NextParentId, &NextParentIndex, 0, NULL, 
                                 NULL, NULL, md_env 
                               ),
                    targetid = FatherId[FatherIndex].objid,
                    targetos = FatherId[FatherIndex].osnum );
  as$status( action = RET_STATUS );

  /*"new parent is %d\n", NextParentId.objid */

  if( NextParentId.objid != NULL_OBJID )
  {
    status = om$send( msg      = message VRGeneric.VRGetCorOnCpt
                                 ( &retcode, NextParentIndex, &CorId, md_env ),
                      targetid = NextParentId.objid,
                      targetos = NextParentId.osnum );
    as$status( action = RET_STATUS );

    if (CorId.objid != NULL_OBJID)
    { 
    /* Update my type */
    status = om$send( msg      = message VRCorrection.VRget_state( & CorToDeleteType ),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );
    as$status( action = RET_STATUS );

    /*"me->my_state = %x\n", me->my_state */
    /*"CorToDelete state = %x\n", CorToDeleteType */

    if( ( me->my_state & VR_FIT_TO_FIT ) != ( CorToDeleteType & VR_FIT_TO_FIT ) ) me->my_state &= ~VR_FIT_TO_FIT;
    /*"me->my_state = %x\n", me->my_state */

    /* we disconnect CorId befor puting it in the notify because she is in the
    /* compute batch list. she is going to receive a compute. In the compute 
    /* method a correction with less than two parents is not computed
    /**/

    /*"disconnect correction %d \n", CorId.objid */

    status = om$send( msg      = message NDnode.NDdisconnect( 1,&NextParentId ),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );

    /* get dependency of deleted correction */
    status = om$send( msg      = message NDnode.NDget_objects
                                         ( ND_CHILDREN | ND_IN_BUF, NULL, 0, &p_Buffer,
                                           0, OM_K_MAXINT, &Count
                                         ),
                      targetid = CorId.objid,
                      targetos = CorId.osnum );
    /*"Count = %d\n", Count */

    /* Move all dependency to new correction */
    for( i=0; i<Count; i++ )
    {
      /*"p_Buffer[%d] = %d\n", i, p_Buffer[i].objid */

      status = om$send( msg      = message NDnodein.NDchange_connect
                                                  ( 1, &CorId, &my_grid ),
                        targetid = p_Buffer[i].objid,
                        targetos = p_Buffer[i].osnum );
      as$status( action = RET_STATUS );
    }

    /*A delete the object */
    status = VRDeleteObjects( 1, &CorId, md_env );
    as$status();

    /*A update my instance data */    
    status = 
    om$send( msg      = message VRCorrection.VRNotifyDelete(
			&retcode, 0, NULL ),
		targetid = CorId.objid,
                targetos = CorId.osnum );
    as$status();
    }

    /* we update the connection of my_id */

    me->my_state |= VR_UPDATE_CON;

    status = om$send( mode     = OM_e_wrt_message,
                      msg      = message NDnodein.NDchange_connect
                                         ( 1, OldCmpId, &NextParentId ),
                      targetid = my_id );
    as$status( action = RET_STATUS );


  }

  End
  return OM_S_SUCCESS;

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method VRSplit( IGRlong			*msg;
                struct	GRid		*CmpId;
                IGRshort			MyType;
                IGRshort			CopyType;
                struct	GRmd_env	*md_env )
{
  IGRint		i, j, NbHanger, Count, NbPretend;
  IGRint		Index, NbFather;
  IGRboolean		BroadCast_Save;
  BSrc			bsretcode;
  IGRlong		status, retcode;
  IGRdouble		Uparams, *p_CptCoord=NULL, CmpOrig[6];
  IGRboolean		Found, GoodPoint;
  struct	GRid	PretendId, CorCmpList[MAX_CorCmp], *p_HangerList=NULL;
  struct	GRid	my_grid, NewCorId, FatherId[my_nbParent], NewPretendId;

  SetProc( VRCorrection.VRSplit );Begin

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

  /*"ASbroadcast_in_progress = %d\n", ASbroadcast_in_progress */
  BroadCast_Save = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;
  
  /* copy my self ==> out the batch to not copy dependency */
  status = om$send( msg      = message NDnode.NDcopy
                               ( &retcode, 0, md_env, md_env, &NewCorId ),
                    targetid = my_id );

  ASbroadcast_in_progress = BroadCast_Save;
  /*"ASbroadcast_in_progress = %d\n", ASbroadcast_in_progress */

  /* test copy return code */
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"NewCorId = %d\n", NewCorId.objid */

  /* Get my parents */
  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, FatherId, my_nbParent, NULL, 0, 
                                 OM_K_MAXINT, &NbFather
                               ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
 
  if( NbFather != my_nbParent )
  {
    as$status( sts = OM_E_ABORT, msg = "Bad parents' number" );
    return OM_E_ABORT;
  }

  /* Connect new correction to my parents */
  status = om$send( msg      = message NDnode.NDconnect
                                       ( 2, FatherId, NULL_GRID, ND_NEW ),
		    targetid = NewCorId.objid,
                    targetos = NewCorId.osnum );
  as$status( action = RET_STATUS );

  if( FatherId[0].objid == CmpId->objid ) Index = 0;
  else					  Index = 1;

  status = om$send( msg      = message VRCorrection.VRUpdateConnection
                                       ( &retcode, &FatherId[Index],
                                         me->my_CmpCptIndex[Index], md_env 
                                       ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( MyType != -1 )
  {
    status = om$send( msg      = message VRCorrection.VRChgCorInstance
                                         ( &retcode, &MyType, NULL, NULL ),
                      targetid = my_id );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }

  status = om$send( msg      = message VRCorrection.VRUpdateConnection
                                       ( &retcode, &FatherId[1-Index],
                                         me->my_CmpCptIndex[1-Index], md_env 
                                       ),
                    targetid = NewCorId.objid,
                    targetos = NewCorId.osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  if( CopyType != -1 )
  {
    status = om$send( msg      = message VRCorrection.VRChgCorInstance
                                         ( &retcode, &CopyType, NULL, NULL ),
                      targetid = NewCorId.objid,
                      targetos = NewCorId.osnum );
    as$status( action = RET_STATUS );
    as$status( sts = retcode, action = RET_STATUS );
  }

  status = om$send( msg      = message NDnode.NDs_compute_node
                                                        ( &retcode, 0, md_env ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  status = om$send( msg      = message NDnode.NDs_compute_node
                                                        ( &retcode, 0, md_env ),
                    targetid = NewCorId.objid,
                    targetos = NewCorId.osnum  );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /* SPECIAL FOR HANGER .. waiting for generic treatement */
  /* Get my parents */
  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, FatherId, my_nbParent, NULL, 0, 
                                 OM_K_MAXINT, &NbFather
                               ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
				 ( &retcode, me->my_CmpCptIndex[0], &CmpOrig[0],
				   NULL, NULL, md_env
				 ),
                    targetid = FatherId[0].objid,
                    targetos = FatherId[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  /*"Orig0 = %f %f %f\n", CmpOrig[0], CmpOrig[1], CmpOrig[2] */

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
				 ( &retcode, me->my_CmpCptIndex[1], &CmpOrig[3],
				   NULL, NULL, md_env
				 ),
                    targetid = FatherId[1].objid,
                    targetos = FatherId[1].osnum );

  /*"Orig0 = %f %f %f\n", CmpOrig[3], CmpOrig[4], CmpOrig[5] */

  status = om$send( msg      = message GRowner.GRget_components
                               ( &retcode, md_env, CorCmpList, MAX_CorCmp, &Count, 0,
                                 OM_K_MAXINT
                               ), 
                    targetid = my_id );

  for( i=0; i<Count; i++ )
  {
    /*"CorCmpList[%d] = %d\n", i, CorCmpList[i].objid */

    status = om$send( msg      = message VRCorrection.VRGetHangers
                                 ( &retcode, &CorCmpList[i], -1, NULL, &NbHanger,
                                   NULL, md_env 
                                 ), 
                      targetid = my_id );

    /*"NbHanger = %d\n", NbHanger */

    if( NbHanger )
    { 
      /* 
       * p_HangerList = ( struct GRid * ) malloc( NbHanger * sizeof( struct GRid ) );
       * p_CptCoord   = ( IGRdouble * ) malloc( NbHanger * 3 * sizeof( IGRdouble ) );
       */
      p_HangerList = _MALLOC ( NbHanger, struct GRid );
      p_CptCoord = _MALLOC ( NbHanger*3, IGRdouble );

      status = om$send( msg      = message VRCorrection.VRGetHangers
                                   ( &retcode, &CorCmpList[i], NbHanger, p_HangerList,
                                     &NbHanger, p_CptCoord, md_env
                                   ), 
                        targetid = my_id );

      for( j=0, Found=FALSE; j<NbHanger; j++ )
      {
        status = om$send( msg      = message NDnode.NDdisplay( 0, GRbe, md_env ),
                          targetid = p_HangerList[j].objid,
                          targetos = p_HangerList[j].osnum );
        as$status( action = RET_STATUS );

        /*"CptCoord = %f %f %f\n", p_CptCoord[3*j], p_CptCoord[3*j+1], p_CptCoord[3*j+2] */

        BSpt_on_lne( &bsretcode, &CmpOrig[0], &CmpOrig[3], &p_CptCoord[3*j], &Uparams, &GoodPoint );

        if( ! GoodPoint )
        {
          status = om$send( msg      = message NDnode.NDget_objects
                                       ( ND_ROOT, &PretendId, 1, NULL, 0, OM_K_MAXINT, &NbPretend ),
                            targetid = p_HangerList[j].objid,
                            targetos = p_HangerList[j].osnum );
          as$status( action = RET_STATUS );

          /*"NbPret = %d\n", NbPretend */

          if( ! Found )
          {
            status = om$send( msg      = message NDnode.NDcopy
                                         ( &retcode, 0, md_env, md_env, &NewPretendId ),
                              targetid = PretendId.objid,
                              targetos = PretendId.osnum );
            as$status( action = RET_STATUS );

            status = om$send( msg      = message NDnode.NDconnect
                                                      ( 1, &NewCorId, NULL_GRID, ND_NEW ),
                              targetid = NewPretendId.objid,
                              targetos = NewPretendId.osnum );
            as$status( action = RET_STATUS );

            Found = TRUE;
          }
          
          status = om$send( msg      = message NDnodein.NDchange_connect
                                                      ( 1, &PretendId, &NewPretendId ),
                            targetid = p_HangerList[j].objid,
                            targetos = p_HangerList[j].osnum );
          as$status( action = RET_STATUS );
        }

        status = om$send( msg      = message NDnode.NDs_compute_node
                                                    ( &retcode, 0, md_env ),
                          targetid = p_HangerList[j].objid,
                          targetos = p_HangerList[j].osnum );
        as$status( action = RET_STATUS );
      }      
    }
  }

  _FREE( p_HangerList );
  _FREE( p_CptCoord );
      
  End
  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetPipeId( IGRlong		*msg;
                    struct	GRid	*PipeId )
{
  IGRlong		retcode, status;

  SetProc( VRCorrection.VRGetPipeId );Begin

  status = om$send( msg      = message VRCorrection.VRGetCorCmpId
                               ( &retcode, "PIPE", -1, -1, NULL, PipeId ),
                    targetid = my_id );

  End
  return OM_S_SUCCESS;

}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetMyCmp( IGRlong			*msg;
                   struct	GRid		*CorCmpId;
                   struct	GRid		*CmpId;
                   struct	GRmd_env	*md_env )
{
  IGRint		NbFather;
  IGRlong		status, retcode;
  IGRuint		CorCmpIndex;
  struct	GRid	FatherId[my_nbParent];

  SetProc( VRCorrection.VRGetMyCmp );Begin

  *msg    = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;


  status = om$get_index( objid_c      = my_id,
                         p_chanselect = &AS_to_comp,
                         objid        = CorCmpId->objid,
                         osnum2       = CorCmpId->osnum,
                         indexaddr    = &CorCmpIndex     );
  as$status( action = RET_STATUS );

  /*"CorCmpIndex = %d\n", CorCmpIndex */

  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, FatherId, my_nbParent, NULL, 0, 
                                 OM_K_MAXINT, &NbFather
                               ),
                    targetid = my_id );
  as$status( action = RET_STATUS );
 
  if( NbFather != my_nbParent )
  {
    as$status( sts = OM_E_ABORT, msg = "Bad parents' number" );
    return OM_E_ABORT;
  }

  *CmpId = FatherId[me->my_StrCmpList[CorCmpIndex].CmpFatherIndex];

  /*"CmpId = <%d %d>\n", CmpId->objid, CmpId->osnum */

  End
  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRget_state( IGRint *state )

{
  SetProc( VRCorrection.VRget_state );Begin

  *state = me->my_state;

  /*"My state = %x\n", *state */

  End
  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRchg_state( IGRint mask, n_state )
{
  SetProc( VRCorrection.VRchg_state );Begin

  /*"obj %d mask %x n_state %x\n",my_id,mask,n_state */

  me->my_state = ( me->my_state & ~mask) | ( n_state & mask );

  End
  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetMyDirection( IGRlong *msg; IGRdouble *MyDirection; 
                         struct GRmd_env *md_env )

{
  IGRint		NbFather;
  IGRlong		status, retcode;
  struct	GRid	CorFather[my_nbParent];

  SetProc( VRCorrection.VRGetMyDirection );Begin

  *msg = MSSUCC;

  status = om$send( msg      = message NDnode.NDget_objects
                               ( ND_ROOT, CorFather, 2, NULL, 0, OM_K_MAXINT,
				 &NbFather
			       ),
                    targetid = my_id );
  as$status( action = RET_STATUS );

  status = om$send( msg      = message VRGeneric.VRGetCptGeom
                               ( &retcode, me->my_CmpCptIndex[0], NULL, 
				 MyDirection, NULL, md_env
                               ),
                    targetid = CorFather[0].objid,
                    targetos = CorFather[0].osnum );
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

  End
  return OM_S_SUCCESS;
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetFlow( IGRlong *msg; IGRdouble *FlowDir; IGRdouble *FlowValue;
                  struct GRmd_env *md_env )

{
BSrc		rc;
IGRlong	status, retcode;
IGRdouble	MyDirection[3], Cpt0[3], Cpt1[3];

SetProc( VRCorrection.VRGetFlow );Begin

  *msg = OM_S_SUCCESS ;

  if( !FlowDir && !FlowValue ) {*msg = OM_E_INVARG; goto wrapup; } 

__DBGpr_int("Correction         ", my_id); 

/*----------------------
#  Flow Direction Algorithm:
*
*  Flow Direction in a correction is defined ALWAYS from con point 0 to cpt 1.
*  Construct vector V = (Cpt1 - Cpt0) pointing along the flow direction.
*  Test the sign of me->FlowDirection:
*       If negative then FlowDir = - V.
*	otherwise        FlowDir = V.
----------------------*/
  if( FlowDir ) {
	status= om$send( msg       =  message VRGeneric.VRGetCptGeom (&retcode,
				       (IGRshort) 0, Cpt0, NULL, NULL, md_env),
			 targetid  = my_id);


	status= om$send( msg       =  message VRGeneric.VRGetCptGeom (&retcode,
				       (IGRshort) 1, Cpt1, NULL, NULL, md_env),
			 targetid  = my_id);


	BSmkvec ( &rc, MyDirection, Cpt0, Cpt1);
	as$status( sts = rc , msg = "Failed to construct VRCorrection vector");

	if (me->FlowDirection < 0) {
	   FlowDir[0] = - MyDirection[0]; 
	   FlowDir[1] = - MyDirection[1];
	   FlowDir[2] = - MyDirection[2];
	}
	else {
	   FlowDir[0] = MyDirection[0]; 
	   FlowDir[1] = MyDirection[1];
	   FlowDir[2] = MyDirection[2];
	}

__DBGpr_int("me->FlowDirection  ", (int) me->FlowDirection); 
  }

  if( FlowValue ) { 
	IGRint         FootIndex;
	struct ret_struct   AttrRst;

        *FlowValue = me->FlowValue; 
__DBGpr_dbl("me->FlowValue      ", me->FlowValue);

/* 3-98 KDD flow value and direction are kept and propagated from corrections*/
/*
*	FootIndex = -1;
*
*	status = om$send ( msg = message ACncpx.ACgive_structure
*				   ( (IGRint *)&retcode, &FootIndex,
*				   VR_N_FLOW_RATE_DB, &AttrRst, md_env ),
*		  p_chanselect = &AS_to_comp,
*			  from = 0,
*			    to = 0);
*        /* TR179702521/TR179702519 - Crashes fix for new-entry 
*	if ( status & retcode & 1 ) { 
*	   *FlowValue = AttrRst.var.root_pm_st.value;
*
*	   me->FlowValue = AttrRst.var.root_pm_st.value;
*
*__DBGpr_dbl("Attribute FlowValue", AttrRst.var.root_pm_st.value); 
*	} 
*/
  }

wrapup:
End
return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/*----------------------------------------
# 2-98 KDD
*
* KLUDGY: Call this method with FlowDir = NULL, FlowValue = NULL to update the 
*         dependents. 
*
* Also Update the system collections of VRComponent owned by me, and
* VRComponent my parents (not owned by a correction).
*
* Do not propagate! Propagation is done by VRPropagateFlow method. 
*---------------------------------------*/

method VRSetFlow(	IGRlong		*msg; 
			IGRdouble	*FlowDir; 
			IGRdouble	*FlowValue;
			struct GRmd_env *md_env )
{
  BSrc		rc;

  IGRlong	status, retcode;

  IGRshort	ConnectPoint, CmpRealPos, stat;

  IGRint        NbRoots = 0,
		NbCpts;

  int		i, NumAttrib = 0;

  IGRdouble	MyDirection[3]={0.0, 0.0, 0.0}, Cpt0[3], Cpt1[3];

  struct GRid   SysParId, CompId, 
		*buffer = NULL;

  struct VRCorrection_common   attr; 

  struct ACrg_coll      Attrib[2];


SetProc( VRCorrection.VRSetFlow );Begin

  *msg = MSSUCC;

__DBGpr_int("Set Flow in Correction  ", (int) my_id); 

/*----------------------
# Dirty update of dependents.  Confessed by KDD on March-10-98. 
----------------------*/
  if ( (FlowDir == NULL) && (FlowValue == NULL) ) { 
            strcpy (Attrib[ NumAttrib ].name, VR_N_FLOW_RATE_DB),
            Attrib[ NumAttrib ].desc.type = AC_ATTRIB_DOUBLE;
            Attrib[ NumAttrib ].desc.value.att_exp = (double) me->FlowValue;
            NumAttrib++;

            strcpy (Attrib[ NumAttrib ].name, VR_N_FLOW_DIR_IN),
            Attrib[ NumAttrib ].desc.type = AC_ATTRIB_DOUBLE;
            Attrib[ NumAttrib ].desc.value.att_exp = (double) me->FlowDirection;
	    NumAttrib++;
  }

/*----------------------
#  Flow Direction Algorithm:
*
*  Flow Direction in a correction is defined ALWAYS from con point 0 to cpt 1.
*  Construct vector V = (Cpt1 - Cpt0) pointing along the flow direction. 
*  Test the sign of the angle between FlowDir & V1 (BSdotp). 
*	If negative reverse the flow direction in that correction.
*	Then propagate the new flow along the network. 
----------------------*/
  if( FlowDir ) {
      status= om$send( msg       =  message VRGeneric.VRGetCptGeom (&retcode, 
				    (IGRshort) 0, Cpt0, NULL, NULL, md_env),
                       targetid  = my_id);


      status= om$send( msg       =  message VRGeneric.VRGetCptGeom (&retcode, 
                                    (IGRshort) 1, Cpt1, NULL, NULL, md_env),
                       targetid  = my_id);


      BSmkvec ( &rc, MyDirection, Cpt0, Cpt1);
      as$status( sts = rc, msg = "Failed to construct VRCorrection vector");

      if ( BSdotp( &rc, MyDirection, FlowDir ) < 0 ) { 
            attr.Iwant = VRCorrection_FlowDirection;
            attr.FlowDirection = - (me->FlowDirection);
 
            status = om$send( msg     = message VRCorrection.GRputattr
                                            (msg, (IGRchar *) &attr),
                             targetid = my_id);


            /* 3-98. KDD Update the paramters of my components and parents */

            strcpy (Attrib[ NumAttrib ].name, VR_N_FLOW_DIR_IN),
            Attrib[ NumAttrib ].desc.type = AC_ATTRIB_DOUBLE;
            Attrib[ NumAttrib ].desc.value.att_exp = (double) me->FlowDirection;
	    NumAttrib++;
      }
__DBGpr_dbl("Flow Direction Set to", me->FlowDirection); 
  }

/*-----------------------------------
# Set flow rate 
*----------------------------------*/
  if ( FlowValue && (me->FlowValue != *FlowValue) ) {
            attr.Iwant     = VRCorrection_FlowValue;
            attr.FlowValue = *FlowValue;
 
            status = om$send( msg     = message VRCorrection.GRputattr
                                               (&retcode, (IGRchar *) &attr),
                             targetid = my_id);

            /* 3-98. KDD Update the paramters of my components and parents */

            strcpy (Attrib[ NumAttrib ].name, VR_N_FLOW_RATE_DB),
            Attrib[ NumAttrib ].desc.type = AC_ATTRIB_DOUBLE;
            Attrib[ NumAttrib ].desc.value.att_exp = (double) me->FlowValue;
            NumAttrib++;
__DBGpr_dbl("Flow Rate      Set to", me->FlowValue); 
  }

  if ( NumAttrib == 0 ) goto wrapup; 

/*-----------------------------------
# Update VRComponents owned by me. Only those with <= 2 cpts. 
*----------------------------------*/
  for ( i = 0; i < me->my_NbCorCmp; i++ ) {
     CmpRealPos = (me->my_StrCmpList[i]).CmpRealPos;
 
     status = om$send( msg      = message VRCorrection.VRGetCorCmpId( msg,
                                        NULL, CmpRealPos, -1, NULL, &CompId),
                       targetid = my_id);
 
     NbCpts = 0;
     status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
                                         (msg, &NbCpts, md_env),
                       targetid = CompId.objid,
                       targetos = CompId.osnum );
     if ( NbCpts > 2 ) continue;

#ifdef vdsDEBUG
printf("Update my component [%d, %d]\n", CompId.objid, CompId.osnum); 
#endif

     status = om$send( msg      = message VRGeneric.VRGetPrivateParams( msg,
                                          &SysParId, NULL, NULL ),
                       targetid = CompId.objid,
                       targetos = CompId.osnum );
 
     status = om$send( msg      = message ACrg_collect.ACmod_list_attribute
                                           ( msg, 2, Attrib ),
                       targetid = SysParId.objid,
                       targetos = SysParId.osnum);
  }


/*-----------------------------------
# Update my parents of class VRComponent, not owned by other corrections 
* Only those with <= 2 cpts.
*----------------------------------*/
  status = om$send( msg     = message NDnode.NDget_objects(
                                       ND_ROOT | ND_IN_BUF, NULL, 0, &buffer, 0,
                                       OM_K_MAXINT, &NbRoots ),
                  targetid  = my_id);
  if ( !buffer ) NbRoots = 0;
 
  for ( i = 0; i < NbRoots; i++ ) {
     stat = (IGRshort) 1;
     status = om$send( msg      = message VRGeneric.VRGetStatus( msg, &stat),
                       targetid = buffer[i].objid,
                       targetos = buffer[i].osnum );
     if ( stat & VR_CORRECTION ) continue;
 
     NbCpts = 0;
     status = om$send( msg      = message VRGeneric.VRGetNumberOfCpts
                                         (msg, &NbCpts, md_env),
                       targetid = buffer[i].objid,
                       targetos = buffer[i].osnum );
     if ( !(status&1) || (NbCpts > 2) || (NbCpts < 1) ) continue;

#ifdef vdsDEBUG
printf("Update my parent    [%d, %d]\n", buffer[i].objid, buffer[i].osnum); 
#endif

     status = om$send( msg      = message VRGeneric.VRGetPrivateParams( msg,
                                          &SysParId, NULL, NULL ),
                       targetid = buffer[i].objid,
                       targetos = buffer[i].osnum );
 
     status = om$send( msg     = message ACrg_collect.ACmod_list_attribute
                                           ( msg, 2, Attrib ),
                      targetid = SysParId.objid,
                      targetos = SysParId.osnum);
  }

  nd$exec_batch (mode = 0);


wrapup:

  End
  return OM_S_SUCCESS;
}

/****************************************************************************/

method VRGetHangers( IGRlong *msg; struct GRid *CmpId; IGRint ArraySize;
                     struct GRid HangerIds[]; IGRint *NbHangers; IGRdouble *dCpCoors;
                     struct GRmd_env *md_env )

{
  IGRchar			CorCmpName[CorCmp_MAX_CHAR];
  IGRint			j, NbChild, Index=-1;
  IGRlong			retcode, status;
  GRclassid			obj_class;
  struct	GRid		PretendId, *PretChild;
  struct	ret_struct	ParamStr;

  SetProc( VRCorrection.VRGetHangers );Begin


  *msg = MSSUCC;

  *NbHangers = 0;

  status = om$send( msg      = message ASnode.ACgive_path
			       ( (IGRint *)&retcode, CmpId, CorCmpName ),
		    targetid = my_id );
  as$status();

  /*"CorCmpName = %s\n", CorCmpName */

  status = om$send( msg      = message VRCorrection.VRGetCorCmpPretendId
                                       ( &retcode, CorCmpName, &PretendId ),
		    targetid = my_id );
  as$status();

  /*"PretendId = %d\n", PretendId.objid */

  if( PretendId.objid != NULL_OBJID )
  {
    /*| there is a pretend */

    status = om$send( msg      = message NDnode.NDget_objects
                                 ( ND_CHILDREN | ND_IN_BUF, NULL, 0, &PretChild, 0,
				   OM_K_MAXINT, &NbChild
                                 ),
		      targetid = PretendId.objid,
                      targetos = PretendId.osnum  );
    as$status( action = RET_STATUS );
        
    for( j=0 ; j<NbChild ; j++ )
    {
      /*"pretchild[%d] Id = %d\n", j, PretChild[j].objid */

      status = om$get_classid( osnum     = PretChild[j].osnum, 
			       objid     = PretChild[j].objid, 
			       p_classid = &obj_class );
      as$status( action = RET_STATUS );

      if( om$is_ancestry_valid( subclassid   = obj_class,
				superclassid = OPP_VRHanger_class_id ) == OM_S_SUCCESS )
      {
        if( (*NbHangers) < ArraySize )
        {
          if( HangerIds ) HangerIds[(*NbHangers)] = PretChild[j];

          /*"Found Hanger %d\n", PretChild[j].objid */

          if( dCpCoors )
          {
            status = om$send( msg      = message NDmacro.ACgive_structure
                                         ( (IGRint *)&retcode, &Index, VR_N_LOC_PT,
                                           &ParamStr, md_env
                                         ),
			      targetid = PretChild[j].objid,
			      targetos = PretChild[j].osnum );
	    as$status ( action = RET_STATUS );
	    as$status ( sts = retcode, action = RET_STATUS );

	    dCpCoors[(*NbHangers)*3]   = ParamStr.var.point_st.pt[0];
	    dCpCoors[(*NbHangers)*3+1] = ParamStr.var.point_st.pt[1];
	    dCpCoors[(*NbHangers)*3+2] = ParamStr.var.point_st.pt[2];
	  }
        }

        (*NbHangers)++;
      }
    }
  }

  End
return OM_S_SUCCESS;

}/* end VRGetHangers */

/*****************************************************************************/

method VRGetProductName( IGRshort *ProductName )
{
  GRclassid ClassId;

  extern GRclassid OPP_VRPCorentity_class_id, 
		   OPP_VRHCorentity_class_id,
		   OPP_VRRCorentity_class_id;

  SetProc( VRCorrection.VRGetProductName );Begin

  om$get_classid( objid     = my_id,
		  osnum     = OM_Gw_current_OS,
                  p_classid = &ClassId );
             
       if( ClassId == OPP_VRPCorentity_class_id ) *ProductName = VR_PIPING;
  else if( ClassId == OPP_VRHCorentity_class_id ) *ProductName = VR_HVAC;
  else if( ClassId == OPP_VRRCorentity_class_id ) *ProductName = VR_CABLING;
  else return OM_E_ABORT;

  End
  return OM_S_SUCCESS;
}

/*****************************************************************************/

method VREvaluate( IGRlong			*msg;
                   IGRint			count;
                   struct	GRid		*list;
		   struct	GRmd_env	*md_env;
                   union	VRparam_attr	*PipeParams;
                   union	VRparam_attr	*Father0Params;
                   union	VRparam_attr	*Father1Params;
		   struct	VRPlaceStr	*PlaceStr )
{
#define ByCpt0	0
#define ByCpt1	1

	IGRchar				Father0Rep, Father1Rep;
	IGRshort			NbVia=0;
	IGRshort			RedIndex=0, NbCmp = 0;
	IGRlong				status=OM_S_SUCCESS, retcode=MSSUCC,
					HaveToCorrectCmp0, HaveToCorrectCmp1, 
					ChanPos = 0;

	/* Connection attributes */
	IGRshort			Shape0, Shape1;
	IGRint				EndPrep0=0, EndPrep1=0;
	IGRdouble			Width0,Depth0,
					Width1,Depth1;

	struct	VRcp_attr		ConProp0, ConProp1;

	SetProc( VRCorrection.VREvaluate );Begin


	*msg             = MSSUCC;

	me->my_state    &= VR_COR_INIT;
	me->my_NbCorCmp = 0;

	if(	( me->my_state & VR_FIT_TO_FIT ) && 
		( me->my_state & VR_COR_PID_REP ) ) return OM_S_SUCCESS;

	/* initialize Shape, Width and depth of my 2 parents */
        /*** Kludge for COTRAN for tr179900976 ***/
        /*** The transition code is getting sent and eval cant take it ***/ 
	Shape0 = Father0Params->hvac_attr.shape;
	Shape1 = Father1Params->hvac_attr.shape;
        if(Shape1 == VR_OVAL_CIRC) Shape1 = VR_OVAL;
        if(Shape0 == VR_OVAL_CIRC) Shape0 = VR_CIRC;

	Width0 = Father0Params->hvac_attr.G_width;
	Depth0 = Father0Params->hvac_attr.G_depth;

	Width1 = Father1Params->hvac_attr.G_width;
	Depth1 = Father1Params->hvac_attr.G_depth;

	status =
	om$send( msg      = message VRCorrection.VRGetCptsInfo
                               ( &retcode, count, list, md_env, &NbVia,
                                 &me->my_CmpCptIndex[0], &me->my_CmpCptIndex[1],
				 NULL, NULL, &HaveToCorrectCmp0, &HaveToCorrectCmp1,
                                 &ConProp0, &ConProp1
                               ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	if( retcode == MSFAIL )
	{
		*msg = MSFAIL;
		return OM_S_SUCCESS;
	}

	/*"CmpCptIndex = %d %d\n", me->my_CmpCptIndex[0], me->my_CmpCptIndex[1] */
	/*"NbVia       = %d\n", NbVia */

	if( NbVia ) me->my_state &= ~VR_FIT_TO_FIT;

	/* Set the two sections orientation */

	Father0Params->hvac_attr.bTwist = FALSE; /* reference */
	Father1Params->hvac_attr.bTwist = FALSE;
	PipeParams->hvac_attr.bTwist    = FALSE;

	if (	( HaveToCorrectCmp0 == MSSUCC &&
		 (ConProp0.section_mask & VR_SHAPE) != VR_CIRC )
		||
		( HaveToCorrectCmp1 == MSSUCC &&
		 (ConProp1.section_mask & VR_SHAPE) != VR_CIRC ))
	{
	BSrc		bsretcode;
	IGRvector	Cmp0Orie, Cmp1Orie;

	Cmp0Orie[0]=Cmp0Orie[1]=Cmp0Orie[2] = 0.0;
	Cmp1Orie[0]=Cmp1Orie[1]=Cmp1Orie[2] = 0.0;

	/* -- look if a twist -- */
	/* Get connection orientation of component 0 */
	status =
	om$send ( msg = message VRGeneric.VRGetCptGeom (
				&retcode, me->my_CmpCptIndex[0],
				NULL, NULL, Cmp0Orie, md_env ),
		targetid = list[0].objid,
		targetos = list[0].osnum );

	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	/*printf( "Z0 = %f %f %f\n", Cmp0Orie[0], Cmp0Orie[1], Cmp0Orie[2] );
	 */

	status =
	om$send ( msg = message VRGeneric.VRGetCptGeom (
				&retcode, me->my_CmpCptIndex[1],
				NULL, NULL, Cmp1Orie, md_env ),
		targetid = list[1].objid,
		targetos = list[1].osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	/*printf( "Z1 = %f %f %f\n", Cmp1Orie[0], Cmp1Orie[1], Cmp1Orie[2] );
	 */

	Father1Params->hvac_attr.bTwist =
	  (fabs (BSdotp( &bsretcode, Cmp0Orie, Cmp1Orie)) < VRGetTol(VR_ORTHO_TOL) );

	/*printf("Components are %sTwisted\n", Father1Params->hvac_attr.bTwist ? "" : "not " );
	 */

	}
	if( HaveToCorrectCmp0 == MSSUCC )
	{
		Shape0 = ConProp0.section_mask & VR_SHAPE;
		Width0 = ConProp0.width;
		EndPrep0  = ConProp0.end_prep;
		if( Shape0 == VR_CIRC ) Depth0 = Width0;
		else                       Depth0 = ConProp0.depth;

		__DBGpr_dbl("Width0 ", Width0 );
		__DBGpr_dbl("Depth0 ", Depth0 );
		__DBGpr_int("Shape0 ", Shape0 );
		__DBGpr_int("EndPrep0 ", EndPrep0 ); 

		Father0Params->hvac_attr.shape   = Shape0;
		Father0Params->hvac_attr.G_width = Width0;
		Father0Params->hvac_attr.G_depth = Depth0;
	}

	if( HaveToCorrectCmp1 == MSSUCC )  
	{

		Father1Params->hvac_attr.shape   = Shape1
		=	ConProp1.section_mask & VR_SHAPE;

		Father1Params->hvac_attr.G_width = ConProp1.width;
		Father1Params->hvac_attr.G_depth = ConProp1.depth;
		EndPrep1 = ConProp1.end_prep;

		/* invert w/d if section are twisted for test only */
		if ( Father1Params->hvac_attr.bTwist)
		{
			Width1 = Father1Params->hvac_attr.G_depth;
			Depth1 = Father1Params->hvac_attr.G_width;

		/*C  Set father 1 parameters to Width1 and Depth1 */

                        Father1Params->hvac_attr.G_width = Width1;
                        Father1Params->hvac_attr.G_depth = Depth1;

                        Father1Params->hvac_attr.R_width = Width1;
                        Father1Params->hvac_attr.R_depth = Depth1;

		/*C  If the shape is circular need to set Width == Depth */

                        if ( Shape1 == VR_CIRC ) { Width1 = Depth1;
                                Father1Params->hvac_attr.G_width =
                                        Father1Params->hvac_attr.G_depth;
                        }

		}
		else
		{
			Width1 = Father1Params->hvac_attr.G_width;
			Depth1 = Father1Params->hvac_attr.G_depth;
                        if( Shape1 == VR_CIRC ) {
                                Depth1 = Width1;
                                Father1Params->hvac_attr.G_depth =
                                        Father1Params->hvac_attr.G_width;
                        }
		}
		
		__DBGpr_dbl( "Width1 ", Width1 );
		__DBGpr_dbl( "Depth1 ", Depth1 );
		__DBGpr_int( "Shape1 ", Shape1 );
		__DBGpr_int( "EndPrep1 ", EndPrep1 ); 

	}

	/*| Start evaluation */

	if( me->my_state & VR_FIT_TO_FIT )
	{
		/*| -- Fitting to Fitting -- */

		if(	HaveToCorrectCmp0 == MSSUCC &&
			HaveToCorrectCmp1 == MSSUCC )
		{
			if( EndPrep0 != EndPrep1 )
			{
				if( EndPrep0 )	me->my_state |= VR_ADAPTER0;
				else
				if( EndPrep1 )	me->my_state |= VR_ADAPTER1;

				me->my_NbCorCmp += 1;
			}

			if( Shape0 != Shape1 )
			{
				/* transition also used as reducer if needed */
				me->my_state = me->my_state | VR_TRANS0;
				me->my_NbCorCmp += 1;
			}

			/* Double value comparision for Depth is 
			   corrected - TR179900559            */

			else if( _VR_NE( Width0, Width1) || 
				( Shape0 != VR_CIRC && _VR_NE(Depth0,Depth1) ) )
			{
				me->my_state = me->my_state | VR_REDUCER0;
				me->my_NbCorCmp += 1;
			}

			PipeParams->hvac_attr.shape   = Shape1;
			PipeParams->hvac_attr.G_width = Width1;
			PipeParams->hvac_attr.G_depth = Depth1;
		}
	}		/* ------------- */
	else		/* -- NOT FTF -- */
	{		/* ------------- */

	IGRboolean	bTakeCmp0;

	if( ( HaveToCorrectCmp0 == MSSUCC ) && ( HaveToCorrectCmp1 == MSSUCC ) )
	{
		/*
			Set Pipe's attributes from component with :
			- Minimum shape
			or
			- Minimum width
			or
			- Minimum depth
		*/

		/*BILLA  Double value comparison problem */
		bTakeCmp0 = Shape0 < Shape1                                ||
			( Shape0 == Shape1 && Width0 < Width1  ) ||
			( Shape0 == Shape1 && (fabs(Width0 - Width1)<
                                     VRGetTol(VR_DIST_TOL)) && 
			Depth0 < Depth1  ) ||
			( Shape0 == Shape1 && (fabs(Width0 - Width1)<
                                     VRGetTol(VR_DIST_TOL)) && 
			(fabs(Depth0 - Depth1)<VRGetTol(VR_DIST_TOL)) );
	}
	else bTakeCmp0 = (HaveToCorrectCmp0 == MSSUCC );

	if ( bTakeCmp0 )
	{
		PipeParams->hvac_attr.shape   = Shape0;
		PipeParams->hvac_attr.G_width = Width0;
		PipeParams->hvac_attr.G_depth = Depth0;
	}
	else if ( HaveToCorrectCmp1 == MSSUCC ) 
	{
		PipeParams->hvac_attr.shape   = Shape1;
		PipeParams->hvac_attr.G_width = Width1;
		PipeParams->hvac_attr.G_depth = Depth1;
	}

    __DBGpr_dbl( "PipeWidth ", PipeParams->hvac_attr.G_width );
    __DBGpr_dbl( "PipeDepth ", PipeParams->hvac_attr.G_depth );
    __DBGpr_int( "PipeShape ", PipeParams->hvac_attr.shape );

    if( ! ( me->my_state & VR_COR_PID_REP ) )
    {
	if( HaveToCorrectCmp0 == MSSUCC )
	{    
		if( EndPrep0 )
		{
		  me->my_state = me->my_state | VR_ADAPTER0;
		  me->my_NbCorCmp += 1;
		}

		if( Shape0 != PipeParams->hvac_attr.shape )
		{
			me->my_state = me->my_state | VR_TRANS0;
			me->my_NbCorCmp += 1;
		}
		if( !me->my_NbCorCmp )
		{
                  /* Modified for TR179800487 */
		  if(fabs(Width0 - PipeParams->hvac_attr.G_width) >
                                                      VRGetTol(VR_DIST_TOL) 
		 || (fabs(Depth0 - PipeParams->hvac_attr.G_depth) >
                                                      VRGetTol(VR_DIST_TOL)
                 && Shape0 != VR_CIRC ) )
		  {
                        __DBGpr_com("Setting state to VR_REDUCER0");
			me->my_state = me->my_state | VR_REDUCER0;
			me->my_NbCorCmp += 1;
		  }
                }
	}

	if( HaveToCorrectCmp1 == MSSUCC )
	{    
		if( EndPrep1 )
		{
		  me->my_state = me->my_state | VR_ADAPTER1;
		  me->my_NbCorCmp += 1;
		}
		if( Shape1 != PipeParams->hvac_attr.shape )
		{
			me->my_state = me->my_state | VR_TRANS1;
			me->my_NbCorCmp += 1;
		}

		if( !( me->my_state & VR_ADAPTER1 || me->my_state & VR_TRANS1 ) )
		{
                  /* Modified for TR179800487 */
		  if(( fabs(Width1 - PipeParams->hvac_attr.G_width) > 
                                              VRGetTol(VR_DIST_TOL))
                 || (( fabs(Depth1 - PipeParams->hvac_attr.G_depth) > 
                                              VRGetTol(VR_DIST_TOL))
                 && Shape1 != VR_CIRC ) )
		  {
			me->my_state = me->my_state | VR_REDUCER1;
			me->my_NbCorCmp += 1;
		  }
		}
	}
    }
  }

  __DBGpr_int( "NbCorCmp ", me->my_NbCorCmp );

  if( me->my_NbCorCmp >= 1 )
  {  
    om$vla_set_dimension( varray = me->my_StrCmpList,
                          size   = me->my_NbCorCmp );

    /*^
        IGRlong size1;
        size1 = om$dimension_of( varray = me->my_StrCmpList );
        printf("size of NewStrCmpList = %ld\n", size1 );
    */
  }
  
  if( me->my_state & ( VR_ADAPTER0 | VR_REDUCER0 | VR_TRANS0 ) )
  {
    /*| Get representation and user param from Cmp0 */

    Father0Rep = ( IGRchar ) 1; /* extern representation */

    status = om$send( msg      = message ACncpx.ACget_NV_rep
                                 ( ( IGRuchar * ) &Father0Rep ),
                      targetid = list[0].objid, 
                      targetos = list[0].osnum );
    as$status();
  }

  if( me->my_state & ( VR_ADAPTER1 | VR_TRANS1 | VR_REDUCER1 ) )
  {
    /*| Get representation and user param from Cmp1 */

    Father1Rep = ( IGRchar ) 1; /* extern representation */

    status = om$send( msg      = message ACncpx.ACget_NV_rep
                                 ( ( IGRuchar * ) &Father1Rep ),
                      targetid = list[1].objid, 
                      targetos = list[1].osnum );
    as$status();
  }
  
  if( me->my_state & VR_ADAPTER0 )
  {
    /*"ChanPos = %ld\n", ChanPos */
    strcpy( me->my_StrCmpList[ChanPos].CmpName, "ADP0" );
    me->my_StrCmpList[ChanPos].CmpRealPos        = NbCmp;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 0;
    me->my_StrCmpList[ChanPos].CmpJustification  = ByCpt0;

    PlaceStr[ChanPos].CmpItemNum        = VR_FLGE_COMP;
    PlaceStr[ChanPos].CmpJustification  = ByCpt0;
    PlaceStr[ChanPos].CmpRepresentation = Father0Rep;
    PlaceStr[ChanPos].CmpOrientation    = 1;

    NbCmp++; ChanPos++;
  }

  if( me->my_state & VR_TRANS0 )
  {
    /*"ChanPos = %ld\n", ChanPos */

    /*| place transition0 */

    if( Father0Params->hvac_attr.shape > PipeParams->hvac_attr.shape )
    {
        me->my_StrCmpList[ChanPos].CmpJustification = ByCpt1;
        PlaceStr[ChanPos].CmpOrientation   = -1;
        PlaceStr[ChanPos].CmpJustification = ByCpt1;
    }
    else
    {
          me->my_StrCmpList[ChanPos].CmpJustification  = ByCpt0;
          PlaceStr[ChanPos].CmpOrientation    = 1;
          PlaceStr[ChanPos].CmpJustification  = ByCpt0;
    }

    status = VRGetTransCode
	     ( PipeParams->hvac_attr.shape, Father0Params->hvac_attr.shape,
	       &PlaceStr[ChanPos].CmpItemNum );
    as$status();

    strcpy( me->my_StrCmpList[ChanPos].CmpName, "TRS0" );

    me->my_StrCmpList[ChanPos].CmpRealPos        = NbCmp;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 0;
    PlaceStr[ChanPos].CmpRepresentation = Father0Rep;

    NbCmp++; ChanPos++;
  }

  if( me->my_state & VR_REDUCER0 )
  {
    /*"ChanPos = %ld\n", ChanPos */

    /*| place reducer0 */

    strcpy( me->my_StrCmpList[ChanPos].CmpName, "RED0" );
    me->my_StrCmpList[ChanPos].CmpRealPos        = NbCmp;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 0;

    PlaceStr[ChanPos].CmpItemNum        = VR_REDUCER;
    PlaceStr[ChanPos].CmpRepresentation = Father0Rep;

    /*BILLA  Double value comparison problem */
    if( ( Father0Params->hvac_attr.G_width > PipeParams->hvac_attr.G_width ) || 
        ( fabs(Father0Params->hvac_attr.G_width-PipeParams->hvac_attr.G_width)
					< VRGetTol(VR_DIST_TOL) ) && 
        ( Father0Params->hvac_attr.G_depth > PipeParams->hvac_attr.G_depth ) )
    {
      me->my_StrCmpList[ChanPos].CmpJustification = ByCpt0;
      PlaceStr[ChanPos].CmpOrientation   = 1;
      PlaceStr[ChanPos].CmpJustification = ByCpt0;
    }
    else
    {
      me->my_StrCmpList[ChanPos].CmpJustification = ByCpt1;
      PlaceStr[ChanPos].CmpOrientation   = -1;
      PlaceStr[ChanPos].CmpJustification = ByCpt1;
    } 

    NbCmp++; ChanPos++;
  }

  if( me->my_state & VR_REDUCER1 )
  {
    RedIndex = NbCmp;
    NbCmp++;
  }

  if( me->my_state & VR_ADAPTER1 )
  {
    /*"ChanPos = %ld\n", ChanPos */
    strcpy( me->my_StrCmpList[ChanPos].CmpName, "ADP1" );
    me->my_StrCmpList[ChanPos].CmpRealPos        = NbCmp;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 1;
    me->my_StrCmpList[ChanPos].CmpJustification  = ByCpt0;

    PlaceStr[ChanPos].CmpItemNum        = VR_FLGE_COMP;
    PlaceStr[ChanPos].CmpJustification  = ByCpt0;
    PlaceStr[ChanPos].CmpRepresentation = Father1Rep;
    PlaceStr[ChanPos].CmpOrientation    = -1;

    ChanPos++;
  }

  if( me->my_state & VR_TRANS1 )
  {
    /*"ChanPos = %ld\n", ChanPos */

    /*| place transition1 */

    if( PipeParams->hvac_attr.shape > Father1Params->hvac_attr.shape )
    {
        me->my_StrCmpList[ChanPos].CmpJustification = ByCpt0;
        PlaceStr[ChanPos].CmpOrientation   = 1;
        PlaceStr[ChanPos].CmpJustification = ByCpt0;
    }
    else
    {
          me->my_StrCmpList[ChanPos].CmpJustification  = ByCpt1;
          PlaceStr[ChanPos].CmpOrientation    = -1;
          PlaceStr[ChanPos].CmpJustification  = ByCpt1;
    }

    status = VRGetTransCode
	     ( PipeParams->hvac_attr.shape, Father1Params->hvac_attr.shape,
	       &PlaceStr[ChanPos].CmpItemNum );
    as$status();

    strcpy( me->my_StrCmpList[ChanPos].CmpName, "TRS1" );

    me->my_StrCmpList[ChanPos].CmpRealPos        = NbCmp;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 1;
    PlaceStr[ChanPos].CmpRepresentation = Father1Rep;

    ChanPos++;
  }

  if( me->my_state & VR_REDUCER1 )
  {
    /*"ChanPos = %ld\n", ChanPos */
 
    /*| place reducer1 */

    strcpy( me->my_StrCmpList[ChanPos].CmpName, "RED1" );
    me->my_StrCmpList[ChanPos].CmpRealPos        = RedIndex;
    me->my_StrCmpList[ChanPos].CmpFatherIndex    = 1;

    PlaceStr[ChanPos].CmpItemNum        = VR_REDUCER;
    PlaceStr[ChanPos].CmpRepresentation = Father1Rep;

    /*BILLA  Double value comparison problem */
    if( ( PipeParams->hvac_attr.G_width > Father1Params->hvac_attr.G_width ) || 
        ( fabs(PipeParams->hvac_attr.G_width-Father1Params->hvac_attr.G_width)
				< VRGetTol(VR_DIST_TOL)  )  && 
	( PipeParams->hvac_attr.G_depth > Father1Params->hvac_attr.G_depth ) )
    {
      me->my_StrCmpList[ChanPos].CmpJustification = ByCpt1;
      PlaceStr[ChanPos].CmpOrientation   = 1;
      PlaceStr[ChanPos].CmpJustification = ByCpt1;
    }
    else
    {
      me->my_StrCmpList[ChanPos].CmpJustification = ByCpt0;
      PlaceStr[ChanPos].CmpOrientation   = -1;
      PlaceStr[ChanPos].CmpJustification = ByCpt0;
    } 

    ChanPos++;
  }

  End
  return OM_S_SUCCESS;

#undef ByCpt0
#undef ByCpt1

}

/*****************************************************************************/

method VRUpdate( IGRint count; struct GRid *list; struct VRPlaceStr *PlaceStr;
		 struct GRmd_env *md_env )
{
  IGRint		i;
  IGRlong		status=OM_S_SUCCESS, retcode=MSSUCC;
  IGRmatrix		CmpMatrix;
  struct	GRid	CmpId;

  SetProc( VRCorrection.VRUpdate );Begin

  if( me->my_state & VR_STRAIGHT )
  {
	me->my_state &= ~VR_STRAIGHT;
	me->my_NbCorCmp--;

	/*| update RealPos list */
	for( i=0; i<me->my_NbCorCmp; i++ )
			  if( me->my_StrCmpList[i].CmpFatherIndex )
					me->my_StrCmpList[i].CmpRealPos -= 1;
  }

  for( i=0; i<me->my_NbCorCmp; i++ )
  {
	status = om$send( msg      = message VRCorrection.VRGetCorCmpId
				     ( &retcode, NULL, -1, i, NULL, &CmpId ),
			  targetid = my_id );
		
	om$send( msg      = message VRCorrection.VRGetMatrix
				( &retcode, &CmpId, CmpMatrix, md_env ),
		 targetid = my_id );

	VR$OrientComp(	p_retmsg	= &retcode,
			p_CmpId		= &CmpId,
			Justif		= me->my_StrCmpList[i].CmpJustification,
			Matrix		= CmpMatrix,
			p_MdEnv		= md_env );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
  }

  End
  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRGetMatrix( IGRlong			*msg;
                    struct	GRid		*CorCmpId;
		    IGRdouble			*CorCmpMatrix;
                    struct	GRmd_env	*md_env )
{
  IGRshort			RealPos=-1, CompCpt;
  IGRboolean			GetParents=FALSE;
  IGRint			Index, NbChild;
  IGRlong			status=OM_S_SUCCESS, retcode=MSFAIL;
  struct	GRid		FatherId[2];
  struct	GRid		ComponentId;
  IGRuint			CorCmpIndex;

  /*| Initialize return codes */

  SetProc( VRCorrection.VRGetMatrix );Begin

  *msg    = MSSUCC;

  /*"CorCmpId %d asks for his matrix\n", CorCmpId->objid */

  Index = me->my_NbCorCmp ? me->my_NbCorCmp-1 : 0;

  /*"Index = %d\n", Index */

  /* get my given component index on my component channel */
  status = om$get_index( objid_c      = my_id,
                         p_chanselect = &AS_to_comp,
                         objid        = CorCmpId->objid,
                         osnum2       = CorCmpId->osnum,
                         indexaddr    = &CorCmpIndex );
  as$status( action = RET_STATUS );

  /*"CmpChanPos     = %d\n", CorCmpIndex                                   */
  /*"CmpRealPos     = %d\n", me->my_StrCmpList[CorCmpIndex].CmpRealPos     */
  /*"CmpFatherIndex = %d\n", me->my_StrCmpList[CorCmpIndex].CmpFatherIndex */

  if( !me->my_StrCmpList[CorCmpIndex].CmpFatherIndex )
  {
	if( !me->my_StrCmpList[CorCmpIndex].CmpRealPos ) GetParents = TRUE;
	else RealPos = me->my_StrCmpList[CorCmpIndex].CmpRealPos-1;
  }
  else
  {
	if( me->my_StrCmpList[CorCmpIndex].CmpRealPos == Index ||
					! CorCmpIndex ) GetParents = TRUE;
	else RealPos = me->my_StrCmpList[CorCmpIndex].CmpRealPos+1;
  }
	
  if( GetParents )
  {
	/*| get my parents */
	status = om$send( msg    = message NDnode.NDget_objects
				   ( ND_ROOT, FatherId, 2, NULL, 0, OM_K_MAXINT,
				     &NbChild
				   ),
			  targetid = my_id );
	as$status( action = RET_STATUS );

	/*"FatherId = %d %d\n", FatherId[0].objid, FatherId[1].objid */
	/*"CmpFattherIndex = %d\n", me->my_StrCmpList[CorCmpIndex].CmpFatherIndex */

	ComponentId = FatherId[me->my_StrCmpList[CorCmpIndex].CmpFatherIndex];
	CompCpt     = me->my_CmpCptIndex[me->my_StrCmpList[CorCmpIndex].CmpFatherIndex];
  }
  else
  {
	status = om$send( msg    = message VRCorrection.VRGetCorCmpId
				   ( &retcode,
				     NULL, 
				     RealPos,
				     -1,
				     &Index,
				     &ComponentId ),
			  targetid = my_id );
	as$status( action = RET_STATUS );

	/*"componentId = %d\n", ComponentId.objid */

	CompCpt = 1 - me->my_StrCmpList[Index].CmpJustification;
  }

  /* get my right component matrix */
  VR$GetMatrix(	p_msg		= &retcode,
		p_ComponentId = &ComponentId,
		CompCpt		= CompCpt,
		p_Matrix	= CorCmpMatrix,
		p_MdEnv	= md_env);
  as$status( action = RET_STATUS );
  as$status( sts = retcode, action = RET_STATUS );

/*C  Try to verify if there is twist, if there is then matrix needs to be 
     modified, change Y and Z axis in case of a reducer. This twist needs to
     happen only for a reducer near the father 1.
*/
  if(GetParents)
  {
	BSrc		bsretcode;
	IGRvector	Cmp0Orie, Cmp1Orie;
	IGRboolean	bTwist;
	IGRshort	nSysType;
	IGRdouble	dTmp[3];

        bTwist = FALSE;

	/* -- look if a twist -- */
	/* Get connection orientation of component 0 */
	status =
	om$send ( msg = message VRGeneric.VRGetCptGeom (
				&retcode, me->my_CmpCptIndex[0],
				NULL, NULL, Cmp0Orie, md_env ),
		targetid = FatherId[0].objid,
		targetos = FatherId[0].osnum );

/*     spurious error messages .. TR 179602049
	as$status( );
	as$status( sts = retcode);                        */

	/*"Z0 = %f %f %f\n", Cmp0Orie[0], Cmp0Orie[1], Cmp0Orie[2] */

        if (status & retcode & OM_S_SUCCESS) 
	status =
	om$send ( msg = message VRGeneric.VRGetCptGeom (
				&retcode, me->my_CmpCptIndex[1],
				NULL, NULL, Cmp1Orie, md_env ),
		targetid = FatherId[1].objid,
		targetos = FatherId[1].osnum );

/*     spurious error messages .. TR 179602049
	as$status( );
	as$status( sts = retcode );                         */

	/*"Z1 = %f %f %f\n", Cmp1Orie[0], Cmp1Orie[1], Cmp1Orie[2] */

        if (status & retcode & OM_S_SUCCESS) 
	bTwist =
		(fabs (BSdotp( &bsretcode, Cmp0Orie, Cmp1Orie)) < VRGetTol(VR_ORTHO_TOL) );

	/*"Components are %sTwisted\n", bTwist ? "" : "not " */

	status = om$send ( msg =  message VRGeneric.VRGetSysType ( 
				&retcode, &nSysType ),
			targetid = CorCmpId->objid,
			targetos = CorCmpId->osnum );
	as$status();

	/*"SysType = %d \n",nSysType */

/* Add VR_TRANS_E_C - CR179309874 */
	if( bTwist && 
		( nSysType == VR_REDUCER || nSysType == VR_TRANS_R_C || 
		nSysType == VR_TRANS_O_C || nSysType ==  VR_TRANS_C_Co ||
                nSysType == VR_TRANS_E_C )
			&& me->my_StrCmpList[CorCmpIndex].CmpFatherIndex )
	{
	/* Switch the Reducer's Y and Z axis. */

		dTmp[0] = CorCmpMatrix[1]; dTmp[1] = CorCmpMatrix[5]; dTmp[2] =
		CorCmpMatrix[9];
		CorCmpMatrix[1] = CorCmpMatrix[2]; CorCmpMatrix[5]=CorCmpMatrix[6]; CorCmpMatrix[9] = CorCmpMatrix[10];
		CorCmpMatrix[2] = dTmp[0]; CorCmpMatrix[6] = dTmp[1]; CorCmpMatrix[10] = dTmp[2];
	}
   }

  /*"Xcpt = %f %f %f\n", CorCmpMatrix[0], CorCmpMatrix[4], CorCmpMatrix[8] */
  /*"orig = %f %f %f\n", CorCmpMatrix[3], CorCmpMatrix[7], CorCmpMatrix[11] */

  return(OM_S_SUCCESS);

}

/*****************************************************************************/

method VRCreate( IGRlong			*msg;
		 IGRint				OldState;
		 IGRint				*ComputeTable;
		 struct		GRid		*ParamsTable;
		 union		VRparam_attr	*PipeParams;
		 union		VRparam_attr	*DimParamsTable;
		 IGRchar			*go_cnst_lis;
		 struct		GRas		*assoc_list;
		 struct		VRPlaceStr	*PlaceStr;
		 struct		GRmd_env	*md_env )
{
  IGRint			i,j;
  IGRlong			ChanPos=0, status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid		CorCmpId;
  struct	VRGenInfo	*CmpStr;

  SetProc( VRCorrection.VRCreate );Begin

  /* get VRGenInfo component structure */
  CmpStr = ( struct VRGenInfo * ) assoc_list->as_attr;

  /* set the component index */
  assoc_list->go_attr = ( IGRchar * ) &ChanPos;

  for( i=0,j=0; ComputeTable[i] != -1; i++,j+=2 )
  {
    CorCmpId.objid = NULL_OBJID;

    if( OldState & ComputeTable[i] )
    {
      status = om$send( msg      = message VRCorrection.VRGetCorCmpId
                                   ( &retcode, NULL, -1, ChanPos, 
                                     NULL, &CorCmpId
                                   ),
                      targetid = my_id );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
    }

    if( me->my_state &  ComputeTable[i] )
    {
      /*"CompType %x ChanPos = %d\n", ComputeTable[i], ChanPos */

      assoc_list->parents[0] = ParamsTable[j];
      assoc_list->parents[1] = ParamsTable[j+1];

      CmpStr->nJustif			     = PlaceStr[ChanPos].CmpJustification;
      CmpStr->cRep			     = PlaceStr[ChanPos].CmpRepresentation;
      CmpStr->Attr.Comp.Desc.nItemNum        = PlaceStr[ChanPos].CmpItemNum;
      CmpStr->Attr.Comp.Orientation.dPrimary = PlaceStr[ChanPos].CmpOrientation;

      /* set the index of the component connection */

      status = om$send( msg      = message VRCorrection.VREvalComponent
                                   ( &retcode, ComputeTable[i], PipeParams,
				     &DimParamsTable[i],go_cnst_lis, assoc_list,
				     md_env, &CorCmpId
				   ),
                        targetid = my_id );
      as$status( action = RET_STATUS );

      ChanPos++;
    }
    else
    {
      if( OldState & ComputeTable[i] )
      {
        /*" delete old component %d\n", CorCmpId.objid */

        status = om$send( msg      = message NDnode.NDdelete( md_env ),
                          targetid = CorCmpId.objid,
			  targetos = CorCmpId.osnum );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );
      }
    }
  }

  End
  return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* VREvalComponent for piping moved to VRPCorentity                       ***/
/****************************************************************************/
/* The method VREvalComponent has been revamped, with the database access   */
/* now being done through the cache. Header files VRPDBmac.h and VRPDBdef.h */ 
/* have been included for this purpose. A lot of restructuring of the old   */
/* code has also been done. - Anand ( Nov '97 )                             */
/****************************************************************************/

method VREvalComponent( IGRlong			*msg;
			IGRint			CompType;
			union VRparam_attr	*PipeParams, *FatherParams;
			IGRchar			*go_cnst_lis;
			struct	GRas		*assoc_list;
			struct	GRmd_env	*md_env;
			struct	GRid		*CorCmpId )
{
  IGRint			nOption_code=0;
  IGRshort			Product;
  IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
  struct	GRid		ActParamId, ParentId;
  struct	VRGenInfo	*CmpStr, CmpInstance;
  union		VRparam_attr	CmpParams;

  SetProc( VRCorrection.VREvalComponent );Begin

  *msg = MSSUCC;

  CmpStr = ( struct VRGenInfo * ) assoc_list->as_attr;

  __DBGpr_obj("CorCmpId ",*CorCmpId );
  __DBGpr_int("CompType ", CompType );
#ifdef vdsDEBUG
  printf("	##############\n");
  printf("	VR_TRANS0  =%d\n",VR_TRANS0);  
  printf("	VR_TRANS1  =%d\n",VR_TRANS1);  
  printf("	VR_ADAPTER0=%d\n",VR_ADAPTER0);  
  printf("	VR_ADAPTER1=%d\n",VR_ADAPTER1);  
  printf("	##############\n");
#endif

  status = om$send( msg      = message VRCorrection.VRGetCmpParams(CompType,
					 PipeParams, FatherParams, &CmpParams),
		    targetid = my_id );
  as$status();

/* Get the Product Name */
  status = om$send ( msg = message VRCorrection.VRGetProductName( &Product ),
                             targetid = my_id );

  __DBGpr_int( "Product =" , Product);

  if( CorCmpId->objid == NULL_OBJID ) 
  {
/* add collection in the assoc parent list */
	ActParamId = assoc_list->parents[0];
	assoc_list->parents[0].objid = NULL_OBJID;
	status = om$send( msg      = message VRCorrection.VRGetCorCmpAttrs
				     ( &retcode, &CmpParams, &ActParamId,
				       &assoc_list->parents[0], md_env ),
			  targetid = my_id );
        as$status( action = RET_STATUS );
        as$status( sts = retcode, action = RET_STATUS );

        status = om$send( msg      = message ASnode.ASconstruct_go
				      ( assoc_list, md_env, go_cnst_lis,
					0, FALSE ),
                          targetid = my_id );
        as$status( action = RET_STATUS );

        *CorCmpId = assoc_list->go_objid;
	__DBGpr_com("collection added in the assoc parent list");
  }


  if( CompType & VR_TRANS0 || CompType & VR_TRANS1 )
  {
	__DBGpr_int("CompType (=VR_TRANS here)",CompType);

	status = om$send( msg      = message VRGeneric.VRGetInstance
						   ( &retcode, &CmpInstance ),
			  targetid = CorCmpId->objid,
			  targetos = CorCmpId->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	CmpInstance.Attr.Comp.Desc.nItemNum = CmpStr->Attr.Comp.Desc.nItemNum;

	status = om$send( msg      = message VRGeneric.VRSetInstance
						   ( &retcode, &CmpInstance ),
			  targetid = CorCmpId->objid,
			  targetos = CorCmpId->osnum );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );

	status = om$send( msg      = message VRCorrection.VRChgCorCmpAttrs
				   ( &retcode, CorCmpId, &CmpParams,
				     CmpStr->cRep, md_env ),
			  targetid = my_id );
	as$status( action = RET_STATUS );
	as$status( sts = retcode, action = RET_STATUS );
	 
	End
	return OM_S_SUCCESS;
  }

   status = om$send( msg      = message VRCorrection.VRChgCorCmpAttrs
			    ( &retcode, CorCmpId, &CmpParams,
			      CmpStr->cRep, md_env ),
			 targetid = my_id );
   as$status( action = RET_STATUS );
   as$status( sts = retcode, action = RET_STATUS );


  End
  return OM_S_SUCCESS;
}
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRUpdateFlowArrow( IGRlong			*msg;
			  IGRint			count;
			  struct	GRid		*list;
			  struct	GRsymbology	*symb;
                          struct	GRmd_env	*md_env )

{
	IGRchar			path_name[DI_PATH_MAX], cs_name[DI_PATH_MAX];
	IGRshort		Type, Quatre=4;
	GRobjid			newobjid;
	IGRint			i, retmsg;
	IGRuint			NbCmp, bsretcode;
	IGRlong			status=OM_S_SUCCESS, retcode=MSSUCC;
	IGRmatrix		ArrMatrix, TranMatrix, Matrix;
	struct	GRid		my_grid, ArrowId, CsId, ParentId[my_nbParent];
	extern	GRclassid	OPP_ACheader_class_id;
        char                    macro_name[DI_PATH_MAX];
        double                  arrow_scale[3];
	int			UpdateFlag , GetUpdateFlag = - 2 ;

	SetProc( VRCorrection.VRUpdateFlowArrow );Begin

/* KDD get current flow arrow symbol. */
	retmsg = (IGRint) VRCorrection_VRFlArSym(GetUpdateFlag, &UpdateFlag );

	if ( UpdateFlag ) {
	   status = om$send (msg = message VRCorrection.VRDeleteFlowArrow
					(&retcode,  md_env), 
			targetid = my_id );
	}

	/*A initialization	*/
	*msg = MSSUCC;

	my_grid.objid = my_id;
	my_grid.osnum = OM_Gw_current_OS;

	/*A get my number of components	*/
	status = 
	om$get_channel_count(	objid		= my_id,
				p_chanselect	= &AS_to_comp,
				count		= &NbCmp );
	as$status( action = RET_STATUS );

	/*A get my parents	*/
	if (list && count == my_nbParent )
		for ( i=0; i<my_nbParent; i++ )
			ParentId[i] = list[i];
	else
	{
		IGRint		NbParent;

		status = 
		om$send( msg      = message NDnode.NDget_objects(
				ND_ROOT, ParentId, my_nbParent,
				NULL, 0, OM_K_MAXINT, &NbParent ),
			targetid = my_id );
		as$status( action = RET_STATUS );

	}/* end get parents */

	if( NbCmp > me->my_NbCorCmp )
	{
		/*A the arrow exists, get its Id */
		status = 
		om$get_objid_at_index ( objid	      = my_id,
				 p_chanselect = &AS_to_comp,
				 index	      = me->my_NbCorCmp,
				 objidaddr    = &ArrowId.objid,
				 osnumaddr    = &ArrowId.osnum  );
		as$status( action = RET_STATUS );
	}	
	else
	{
		/*A no arrow exists , create a new one	*/

		/*C get the BASE coord system */ 
		CsId.osnum = md_env->md_id.osnum;

		status = 
		di$give_pathname( osnum    = CsId.osnum,
				   pathname = path_name ) ;
        
		/*"path name = %s\n", path_name */

		status = 
		DIstmcpy( cs_name, path_name, "usr:BASEcoordsys", NULL ) ;

		/*"cs name = %s\n", cs_name */

		status = 
		di$translate ( objname = cs_name,
				osnum	= CsId.osnum,
				p_objid = &CsId.objid,
				p_osnum = &CsId.osnum ) ;

		if( status != DIR_S_SUCCESS ) return OM_S_SUCCESS;

		/*"CsId = %d\n", CsId.objid */

		/*A Place the arrow as a symbol */
		ArrowId.osnum = md_env->md_id.osnum;
		status = 
		om$construct(	classid = OPP_ACheader_class_id,
				p_objid = &ArrowId.objid, 
				osnum	 = ArrowId.osnum );
		if( !( 1 & status ) ) return OM_S_SUCCESS;
			
		/*"ArrowId = %d\n", ArrowId.objid */

/* KDD macro name depends on abs(me->FlowDirection) */
                if ( abs(me->FlowDirection) == VR_FLOW_BIDIRECTION) {
                        strcpy( macro_name, "pidbiflow");
                }
                else {
                        strcpy( macro_name, "pidflow");
                }
/*
printf("VRCorrection.VRUpdateFlowArrow macro =%d %s:\n", (int) me->FlowDirection, macro_name);
*/

		status= 
		om$send( msg      = message ACncpx.ACmplace(
				&retmsg, AChdr_nodisplay, 0, macro_name, 
				1, &CsId, md_env ),
			 targetid = ArrowId.objid,
			 targetos = ArrowId.osnum);

		if( !( retmsg & 1 & status ) ) goto wrupup;
  
		status = 
		om$send( msg      = message GRvg.GRputsymb( &retcode, symb ),
			  targetid = ArrowId.objid,
			  targetos = ArrowId.osnum );
		as$status();

		status = 
		om$send( msg      = message NDnode.NDmove_to_root
					( &retcode, &CsId, md_env ),
			  targetid = ArrowId.objid,
			  targetos = ArrowId.osnum);
		as$status ( action = GOTO_VALUE, value = wrupup );

		/*"conn. my arrow %d to myself %d at the index %d\n",
			ArrowId.objid, my_id, me->my_NbCorCmp */
		status = 
		om$send( msg      = message GRconnector.GRrigidconn(
				&retcode, &my_grid,	
				(IGRlong *)&me->my_NbCorCmp ),
			targetid = ArrowId.objid,
			targetos = ArrowId.osnum );
		as$status ( action = GOTO_VALUE, value = wrupup );

		/* -- update status to let the compute update its position */
		me->my_state |= VR_DISP_FLOW;

	}/* end create a new arrow */

	/* ------------------------ */
	/* -- Set ARROW Position -- */
	/* ------------------------ */

	/*A Build the new arrow location	*/

	/*A Get orientation from first component's connection point */
	VR$GetMatrix( p_msg		= &retcode,
		p_ComponentId	= &ParentId[0],
		CompCpt		= me->my_CmpCptIndex[0],
		p_Matrix	= Matrix,
		p_MdEnv		= md_env );
	as$status ( action = GOTO_VALUE, value = wrupup );

/* KDD Reorient X,  Z axis based on the flow direction sign */
	if (me->FlowDirection < 0 ) {
           for (i=0; i<3; i++) {
                Matrix[i*4]     *= -1;
                Matrix[i*4 + 2] *= -1;
           }
	}

/* KDD commented out. New command "Set Flow Arrow Scale"
*	/*A Scale orientation axes with first component's scale	
*	if (me->my_state & VR_COR_PID_REP )
*	{
*		status =
*		om$send( msg	= message ACncpx.ACgive_structure 
*				( &retmsg, &TmpIndex, VR_N_PID_SCALE_DB,
*				&AttrSt, md_env),
*		targetid = ParentId[0].objid,
*		targetos = ParentId[0].osnum );
*
*		if ( ! ( status&(*msg)&1 ) )
*			AttrSt.var.root_pm_st.value=1;
*	}
*	else	AttrSt.var.root_pm_st.value=10;
*
*	/*"Rescale to %f\n", AttrSt.var.root_pm_st.value  *
****************/

/* KDD  Get the flow arrow scale factor. Common to all VRcorrection objects */
        status = (IGRlong) VRCorrection_VRFlArSc( 0, arrow_scale);

	/*A Scale matrix (x,y,z)	*/
	  for (i=0; i<3; i++)
	{
                Matrix[i]   *= arrow_scale[0];
                Matrix[i+4] *= arrow_scale[1];
                Matrix[i+8] *= arrow_scale[2];
	}


	/*A get the origin ( Mid point of the correction ) 
	assumption is that correction will have only two parents	*/
	{
		IGRdouble	Parent1Cpt[3], Parent2Cpt[3];

		status =
		om$send( msg      = message VRGeneric.VRGetCptGeom(
				&retcode, me->my_CmpCptIndex[0], Parent1Cpt,
				NULL, NULL, md_env ),
			targetid = ParentId[0].objid,
			targetos = ParentId[0].osnum );
		as$status( action = RET_STATUS );
		as$status( sts = retcode, action = RET_STATUS );

		/*"Parent1Cpt = %f %f %f\n", 
			Parent1Cpt[0], Parent1Cpt[1], Parent1Cpt[2] */

		status =
		om$send( msg      = message VRGeneric.VRGetCptGeom(
				&retcode, me->my_CmpCptIndex[1], Parent2Cpt,
				NULL, NULL, md_env ),
			targetid = ParentId[1].objid,
			targetos = ParentId[1].osnum );
		as$status( action = RET_STATUS );
		as$status( sts = retcode, action = RET_STATUS );

		/*"Parent2Cpt = %f %f %f\n", 
			Parent2Cpt[0], Parent2Cpt[1], Parent2Cpt[2] */

		Matrix[3]  = .5 * ( Parent1Cpt[0] + Parent2Cpt[0] );  
		Matrix[7]  = .5 * ( Parent1Cpt[1] + Parent2Cpt[1] );  
		Matrix[11] = .5 * ( Parent1Cpt[2] + Parent2Cpt[2] );  

	}/* end origin calculation for the arrow	*/

	/*"X  = %f %f %f\n", Matrix[0], Matrix[4], Matrix[8]  */
	/*"pt = %f %f %f\n", Matrix[3], Matrix[7], Matrix[11] */

	/*A Get arrow's old location	*/
	status = 
	om$send( msg      = message GRowner.GRget_matrix(
				&retcode, &md_env->md_env.matrix_type,
				md_env->md_env.matrix, &Type, ArrMatrix ),
		    targetid =  ArrowId.objid,
		    targetos =  ArrowId.osnum);
	as$status ( action = GOTO_VALUE, value = wrupup );

	/*A Compute the transformation matrix */

	/*A get the transformation matrix : this tranformation is 
	calculated on the basic coordinate system	*/

	/*A Invert Graphics' matrix to get transformation one	*/
	MAinvmx( &retcode, &Quatre, ArrMatrix, ArrMatrix );

	/*A Compute transformation matrix	*/
	BSmult_mats( 4, 4, Matrix, FALSE, 4, 4, ArrMatrix, 
		FALSE, TranMatrix, &bsretcode );

	MAtypemx( &retcode, TranMatrix, &Type );

	/*A Apply the transformation to the arrow	*/

	/*A apply the transformation on the arrow	*/
	status = 
	om$send ( msg      = message GRgraphics.GRxform(
			&retcode, md_env, &Type, 
			TranMatrix, &newobjid ),
		targetid =  ArrowId.objid,
		targetos =  ArrowId.osnum);
	as$status ( action = GOTO_VALUE, value = wrupup );

	End
	return OM_S_SUCCESS;

wrupup :
	/*A delete the createted arrow */
	status = 
	om$send( msg          = message NDnode.NDdelete( md_env ),
		targetid = ArrowId.objid,
		targetos = ArrowId.osnum );
	as$status();

	End
	return OM_S_SUCCESS;

}/* end VRUpdateFlowArrow */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRDeleteFlowArrow( IGRlong			*msg ;
                          struct	GRmd_env	*md_env )
{

  IGRint	status;
  IGRuint	NbCmp;

  /* I have to delete the arrow */
  SetProc( VRCorrection.VRDeleteFlowArrow );Begin

  status =
  om$get_channel_count(	objid		= my_id,
			p_chanselect	= &AS_to_comp,
			count		= &NbCmp );
  as$status( action = RET_STATUS );

  if( NbCmp > 0 && NbCmp > me->my_NbCorCmp )
  {
	status =
	om$send(msg = message NDnode.NDdelete (md_env),
		p_chanselect = &AS_to_comp,
		from = NbCmp-1,
		to   = NbCmp-1 );
	as$status( action = RET_STATUS );
  }
  /* -- Reset my Disp Flow state -- */
  me->my_state &= ~VR_DISP_FLOW;

  End
  return OM_S_SUCCESS;

}/* end VRDeleteFlowArrow */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method VRShowInstance()
{
  IGRint i;

  printf("\n***********************************************************\n");

  printf("my_state			= %x\n", me->my_state );
  printf("number of my components	= %d\n", me->my_NbCorCmp  );

  for( i=0; i<my_nbParent; i++ )
  {
    printf("CptIndex of my %dth parent	= %d\n", i, me->my_CmpCptIndex[i] );
  }

  for( i=0; i<me->my_NbCorCmp; i++ )
  {
    printf("\nCMP %d : \n", i );
    printf("Correction component name	(CmpName)		= %s\n",
					me->my_StrCmpList[i].CmpName         );
    printf("cor cmp position in my list	(CmpRealPos)		= %d\n",
					me->my_StrCmpList[i].CmpRealPos      );
    printf("index of my owner's father	(CmpFatherIndex)	= %d\n",
					me->my_StrCmpList[i].CmpFatherIndex  );
    printf("Cmp placment justification	(CmpJustification)	= %d\n",
					me->my_StrCmpList[i].CmpJustification);
  }

  printf("\n***********************************************************\n");

  return OM_S_SUCCESS;
}

end implementation VRCorrection;
