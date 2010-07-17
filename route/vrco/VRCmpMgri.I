/* $Id: VRCmpMgri.I,v 1.7 2002/05/28 19:21:24 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrco / VRCmpMgri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCmpMgri.I,v $
 *	Revision 1.7  2002/05/28 19:21:24  louis
 *	TR5888-component flipping on replace
 *	
 *	Revision 1.6  2002/04/23 21:54:27  louis
 *	Regression due to tr5982 code fixes
 *	
 *	Revision 1.5  2002/03/19 23:20:02  louis
 *	*** empty log message ***
 *	
 *	Revision 1.4  2001/03/22 16:30:41  anand
 *	JTS CR MP 3970
 *	
 *	Revision 1.3  2001/02/09 17:12:13  anand
 *	Problems with placement/replacement of CCOMPs.
 *	
 *	Revision 1.2  2001/01/11 22:46:25  anand
 *	SP merge
 *	
# Revision 1.1  2000/11/28  21:38:06  pinnacle
# Created: route/vrco/VRCmpMgri.I by lawaddel for Service Pack
#
# Revision 1.2  1998/10/09  18:30:40  pinnacle
# Replaced: vrco/VRCmpMgri.I for: TR179801965 by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/06  20:01:34  pinnacle
# Replaced: vrco/VRCmpMgri.I for:  by lawaddel for route
#
# Revision 1.2  1998/03/25  15:03:22  pinnacle
# Replaced: vrco/VRCmpMgri.I for:  by lawaddel for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/24  22:00:38  pinnacle
# Replaced: vrco/VRCmpMgri.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/05/01  14:32:24  pinnacle
# Replaced: vrco/VRCmpMgri.I for:  by hverstee for route240
#
# Revision 1.5  1996/04/30  23:29:40  pinnacle
# Replaced: vrco/VRCmpMgri.I for:  by hverstee for route240
#
# Revision 1.4  1996/03/19  22:21:02  pinnacle
# Replaced: vrco/VRCmpMgri.I for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  21:27:36  pinnacle
# Replaced: vrco/VRCmpMgri.I for:  by r240_int for route240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/15/96	tlb	Add prototypes
 *      03/23/98        law     TR179702488-associative lists for insert cmp.
 *      04/06/98        law     Crashes on solaris- opt_cnt needed IGRshort
 *      Oct 9 98      Anand     TR179801965 - Crash on Solaris 2.6 when user
 *				attempts to insert component.
 *      11/20/00        law     TR-MP4140 Allow 80 char. option-code
 *      Feb  9 01     Anand     No TR/CR. Disallow 'ref' as a placement
 *				orientation for CCOMPs.
 *      Mar 22 01     Anand     JTS CR MP 3970.
 *      03/19/02        law     TR5982-bendsweep incorrect for EL45 sketching
 *      04/23/02        law     TR5982-regression due to bad arguments
 *      05/28/02        law     TR5888-Pass angle to evaluate
 *************************************************************************/
 class implementation VRCmpMgr;

#include <math.h>
#include <string.h>
#include "igewindow.h"
#include "VRattr_def.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "AS_status.h"
/* Removed as a source of compile errors for TR179702488
#include "VRdef.h" 
*/
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "VRpriv_attr.h"
#include "VRparamdef.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "dpdef.h"
#include "VRco.h"
#include "VRmsg.h"
#include "parametric.h"
#include "ndmacros.h"
#include "nddef.h"
#include "VRsketchdef.h"
#include "VRmacros.h"
#include "VRDbStruct.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "bstypes.h"
#include "bsvalues.h"
#include "bsparameters.h"
#include "bserr.h"
#include "VRcsdef.h"
#include "msdef.h"
#include "msmacros.h"
#include "dpmacros.h"
#include "VRRDBdef.h"
/* include files below were added/reordered for TR179702488 */
#include <stdio.h>
#include <stdlib.h>
#include "VRDbStruct.h"
#include "VDmacdef.h"
#include "vdsmacros.h"
#include "VDSutil.h"
#include "vrco_pto.h"
#include "vrtools_pto.h"
#include "VRPid.h"
#include "bsdotp.h"
#include "bslenvec.h"
#include "bscrossp.h"
#include "VRDbParamDef.h"
#include "VRHDBdef.h"
#include "vdbmacros.h"
#include "VRRDBmac.h"
#include "VRHDBmac.h"

/* 3 lines added for 179702488- buttons in VRco.h and VRsketchdef.h conflict */
#define VR_OPTCODE_LIST_NUM  400
#define OPTION_FLD 27
#define BIG_DIAM   19

/*
#define MY_DEBUG	
*/

from	GRgraphics	import	GRdisplay;
from	IGEgragad	import	DPinrot;
from	VRGeneric	import	VRGetCptGeom;
from	ACrg_collect	import	ACadd_list_attribute,
				AClist_attribute;
from	NDnode		import	NDchg_state;
/* 2 lines added for TR179702488 */
from    ACncpx          import  ACgive_structure; 
from    ACrg_collect    import  ACget_named_attribute;
from	VRComponent	import  VRGetAngle;

/**************************************************************************

	       	    VRInitInstance	:
		    ---------------------			
		    Initialization of the different instances to
		    their default values.
	
			- every Id   to NULL_OBJID
			- AABBCCcode to ""
			- CmpNumber  to ""
			- CmpNotes   to ""
			- CmpOption  to 1
			- Angle      to 0.0
			- CmpMatrix  to Identity matrix
			- Product    to VR_PIPING 

*********************************************************************/
method VRInitInstance( IGRlong *sts )
{
  IGRint			i;
  struct	GRsymbology	symb;

  me->CmpId.objid    	= NULL_OBJID;
  me->SysParamId.objid  = NULL_OBJID;
  me->UsrParamId.objid  = NULL_OBJID;
  me->MissParamId.objid = NULL_OBJID;
  me->CmpId.osnum  	= me->ModuleInfo.md_id.osnum;
  me->SysParamId.osnum  = me->ModuleInfo.md_id.osnum;
  me->UsrParamId.osnum  = me->ModuleInfo.md_id.osnum;
  me->MissParamId.osnum = me->ModuleInfo.md_id.osnum;
  me->CmpItemNum	= 0;
  me->CmpStatus		= 0;
  me->CmpOption		= 1;
  me->CmpNbCpts		= 0;
  me->Angle 	     	= 0.0;
  me->CptNum 		= VR_CENTER_JUST;
  me->NextCptNum 	= 0;
  me->CmpNumber[0]      = '\0';
  me->CmpNotes[0]       = '\0';
  me->CmpAABBCCcode[0]  = '\0';  
  me->CmpNoMtoFlag	= '0';
  me->ModuleEnv		= me->ModuleInfo;
  me->NbSupports 	= 0;
  me->Flags		= FALSE;
  me->CmpCat		= -1;
  me->CmpBehavior	= -1;
  me->PrevTagNum	= -1;
  me->bTagNumUsed	= FALSE;
  me->bFlipByCenterPoint= FALSE;
  me->bCmpReversed      = FALSE;
  me->bIsRotCmd         = FALSE;

  for( i=0; i<16; i++ )
  	me->CmpMatrix[i] = 0;

  for( i=0; i<VR_MAX_CPTS; i++ )
  {
      me->SupOrientation[3*i]     = 0;
      me->SupOrientation[(3*i)+1] = 0;
      me->SupOrientation[(3*i)+2] = 0;
  }

  /*| -- get the representation -- */
  ACget_def_NVrep(&me->cRep,&symb);

  /*"cRep = %d \n",me->cRep */
#ifdef MY_DEBUG
  printf (" INITinst mgr\n");
#endif

  me->bSKF_up = FALSE;
  me->pSKF    = NULL;

  return OM_S_SUCCESS;
}
/*******************************************************************************

		    VRGetCmpMatrix     :
		    --------------------
		    Get the component matrix from th component.
		    When VRsketch class will be implemented as a
		    subclass of this one, the matrix will be taken
		    from the last created segment.
			
			- VR$GetMatrix 					( I/O )

********************************************************************************/
method VRGetCompMatrix( IGRlong *sts  )
{
  IGRlong	msg,status;

  /* ---- Get Located Component Matrix ----- */
  /*"CmpId  = %d %d \n",me->CmpId.objid,me->CmpId.osnum*/
  /*"CptNum = %d \n",me->CptNum*/
  if( me->CmpId.objid != NULL_OBJID )
  {
  	status = VR$GetMatrix ( p_msg	      = &msg,
                          	p_ComponentId = &me->CmpId,
				CompCpt	      = me->CptNum,
		          	p_Matrix      = me->CmpMatrix,
                          	p_MdEnv	      = &me->ModuleEnv);
  	as$status ();

  	me->CmpMatrix[3]  = me->event1.event.button.x;
  	me->CmpMatrix[7]  = me->event1.event.button.y;
  	me->CmpMatrix[11] = me->event1.event.button.z;
  }

  return OM_S_SUCCESS;
}
/****************************************************************************

		    VREvaluate 		 :	
		    ----------------------
		    Evaluate of the component without any topology.
		    
			- VR$Evaluate		Product			( I )
						CmpAABBCCcode		( I )
						CmpNumber		( I )
						CmpNotes		( I )
						CmpOption		( I )
						Symb			( I )
						cRep			( I )
						CmpId			( I )
						System  Parameters	( I )
						User    Parameters	( I )
						Missing Parameters	( I )
						Nb Missing Parameters	( O )
						Address Missings Params ( O )
						ModuleEnv		( I )

*******************************************************************************/
method VREvaluateComp( IGRlong *sts )
{
  IGRlong 			msg, status,retcode;
  IGRint			NbMissingParams;
  struct	ACrg_coll	*p_MissingParamsList;
  struct ret_struct CmpParam;
  IGRdouble angle,Gdiam,Rdiam,loc_angle;
  IGRint                        retstatus,FootIndex=-1;
  struct  ACrg_coll	Collection;
  IGRint locItemNo,locnocpt,locoption;
  IGRchar spec_name[15];
  IGRchar fam_name[VRRDB_CHAR_FAM],part_number[VRRDB_CHAR_PFX];
  IGRshort comp_topo,comp_type;
  IGRint  comp_numcp,comp_seccp;
  struct ACrg_coll mac_pm[100];
  struct VRHDB_ct_key     hCtK;
  struct VRHDB_ct         hCtR;
  struct VRRDB_ct_key     rCtK;
  struct VRRDB_ct         rCtR;
  IGRshort      NN;
  IGRint pm_no;

  *sts	= MSSUCC;

  NbMissingParams = 0;

#ifdef MY_DEBUG
  printf ("start evaluate\n");
#endif

  /*"SysParamId   = %d %d \n",me->SysParamId.objid,me->SysParamId.osnum*/
  /*"UsrParamId   = %d %d \n",me->UsrParamId.objid,me->UsrParamId.osnum*/
  /*"MissParamId  = %d %d \n",me->MissParamId.objid,me->MissParamId.osnum*/
  /*"AABBCCcode   = %s \n",me->CmpAABBCCcode*/
  /*"CmpItemNum   = %d \n",me->CmpItemNum*/
  /*"CmpStatus    = %d \n",me->CmpStatus*/
  /*"CmpNumber    = %s \n",me->CmpNumber*/
  /*"CmpNotes     = %s \n",me->CmpNotes*/
  /*"CmpNoMtoFlag = %c \n",me->CmpNoMtoFlag*/
  /*"Product      = %d \n",me->Product*/
  /*"CptNum	  = %d \n",me->CptNum*/

/* Get the comp_type */
  strcpy( Collection.name, VR_N_CLASS_AN );
  status =
           om$send ( msg = message ACrg_collect.ACget_named_attribute(
                                           &retcode, &Collection ),
                                 senderid = NULL_OBJID,
             targetid = me->SysParamId.objid,
             targetos = me->SysParamId.osnum );

  strcpy(spec_name, Collection.desc.value.att_txt );
  locItemNo = 0;
  if(me->Product == VR_RWAY)
  {
        strcpy (rCtK.comp_code, me->CmpAABBCCcode);
        strcpy (rCtK.sh_code, "");
        rCtK.comp_type = VRRDB_UNDEF;

        NN = 0;
        VR$RDB_CT (p_msg = &retcode,
             keyin = &rCtK,
             p_num = &NN,
             p_rec = &rCtR);
        if(NN == 0)
        {
            printf(" Comp_code %s not correct in db\n",me->CmpAABBCCcode);
            *sts = VR_NOT_VALID;	
            return OM_S_SUCCESS;
        }
        if(hCtR.data.ct_topo == 3) 
           locItemNo == 1;
        else if(hCtR.data.ct_topo == 4) 
        {
           locItemNo  = 2;
           comp_numcp = 3;
        }

  }
  else if(me->Product == VR_HVAC)
  {
        strcpy (hCtK.comp_code, me->CmpAABBCCcode);
        strcpy (hCtK.sh_code, "");

        NN =0;
        VR$HDB_CT (p_msg = &retcode,
             keyin = &hCtK,
             p_num = &NN,
             p_rec = &hCtR);
        if(NN == 0)
        {
            printf(" Comp_code %s not correct in db\n",me->CmpAABBCCcode);
            *sts = VR_NOT_VALID;	
            return OM_S_SUCCESS;
        }
        if(hCtR.data.ct_topo == 3) 
           locItemNo == 1;
        else if(hCtR.data.ct_topo == 4) 
        {
           locItemNo  = 2;
           comp_numcp = 3;
        }

  }
  else if(me->Product == VR_PIPING)
  {
        strcpy( Collection.name, VR_N_GDIAMETER_DB );
        status =
           om$send ( msg = message ACrg_collect.ACget_named_attribute(
                                           &retcode, &Collection ),
                                 senderid = NULL_OBJID,
             targetid = me->SysParamId.objid,
             targetos = me->SysParamId.osnum );

        Gdiam = Collection.desc.value.att_exp;

        strcpy( Collection.name, VR_N_RDIAMETER_DB );
        status =
           om$send ( msg = message ACrg_collect.ACget_named_attribute(
                                           &retcode, &Collection ),
                                 senderid = NULL_OBJID,
             targetid = me->SysParamId.objid,
             targetos = me->SysParamId.osnum );

        Rdiam = Collection.desc.value.att_exp;

#ifdef MY_DEBUG
printf ("Gdiam is %f\n",Gdiam);
printf ("Rdiam is %f\n",Rdiam);
#endif

#ifdef MY_DEBUG
printf("specname from instance is %s \n",spec_name);
printf ("comp_code from instance is %s\n",me->CmpAABBCCcode);
printf ("option_code from instance %d\n",me->CmpOption);
#endif

        locoption = (int) me->CmpOption;
        fam_name[0] = '\0';
        pm_no = 0;
        status =
        access_piping (  spec_name, me->CmpAABBCCcode, Gdiam, Rdiam, locoption,
                         fam_name, part_number, &comp_topo, &comp_type,
                         &comp_numcp, &comp_seccp, mac_pm, &pm_no, NULL);
#ifdef MY_DEBUG
printf("Back from access_piping\n");
#endif

        if(fam_name[0] == '\0')
        {
            printf(" -----> component : pipingdb:%s-%s-%.3f-%.3f-%d NOT found in database\n",spec_name,me->CmpAABBCCcode,Gdiam,Rdiam,locoption);
            *sts = VR_NOT_VALID;	
            return OM_S_SUCCESS;
        }
        locItemNo = (IGRint) comp_type;
  }
  me->CmpItemNum = 0;
#ifdef MY_DEBUG
printf("ItemNo is %d\n",locItemNo);
printf("numcpt is %d\n",comp_numcp);
#endif
  loc_angle = 0;
  if(locItemNo == 1)
  {
        IGRint                  Index=-1;
        struct ret_struct       AttrSt;
        me->CmpItemNum = VR_ELBOW;
        status =
        om$send (msg = message VRComponent.ACgive_structure
                                ( &retstatus, &Index,
                                 VR_N_BEND_ANG_DB, &AttrSt, &me->ModuleEnv ),
                                targetid = my_id );
        loc_angle = AttrSt.var.root_pm_st.value;
#ifdef MY_DEBUG
printf("comp is an elbow\n");
#endif
  }
  else if(locItemNo == 2 && comp_numcp == 3)
  {
        me->CmpItemNum = VR_TEE;

#ifdef MY_DEBUG
printf("comp is a TEE\n");
#endif
  }
  status = VR$Evaluate(	p_msg		= &msg,
			Product		= me->Product,
			AABBCCcode	= me->CmpAABBCCcode,
			ItemNum		= me->CmpItemNum,
			SStatus		= me->CmpStatus, 
			Number		= me->CmpNumber,
			Notes		= me->CmpNotes,
                        Angle           = loc_angle,
			NoMtoFlg	= me->CmpNoMtoFlag,
			p_Option	= &me->CmpOption,
			Symbology	= &me->Symb,
			Representation	= me->cRep,
			p_Type		= &me->CmpType,
			p_NbCpts	= &me->CmpNbCpts,		
			p_SysParamId	= &me->SysParamId,
			p_UsrParamId	= &me->UsrParamId,
			p_MissParamId	= &me->MissParamId,
			p_ComponentId	= &me->CmpId,
			p_NbMissParams	= &NbMissingParams,
			p_AddrMissings  = &p_MissingParamsList,
			p_MdEnv		= &me->ModuleEnv);

#ifdef MY_DEBUG
  printf ("Evaluated Cmp Id = %d %d \n",me->CmpId.objid,me->CmpId.osnum);
  printf ("Nb Cpts = %d \n",me->CmpNbCpts);
#endif

  if (!(status & 0x01) || !(msg & 0x01) || (me->CmpId.objid == NULL_OBJID) )
  {
    	/*| Error in status of VREvaluate MissingParam */
 	if( msg == MSFAIL )	msg = VR_E_ErrorEvaluation;

    	ex$message( field    = ERROR_FIELD,

	    	     msgnumb = msg );
	
	*sts = VR_NOT_VALID;	

	return OM_S_SUCCESS;
  }

  if( NbMissingParams )
  {
  	/*| -- Modify collection because of missing parameters -- */
	if( me->MissParamId.objid == NULL_OBJID )
	{
		me->MissParamId.osnum = me->ModuleEnv.md_id.osnum;
   		status = 
		om$construct( 	classid = OPP_ACrg_collect_class_id,
      	         		p_objid = &me->MissParamId.objid,
	           		osnum   = me->MissParamId.osnum,
                          	msg     = message NDnode.NDchg_state( ~0, ND_DEL_NO_CH ));
 		as$status();
  	}

	status = 
	om$send( msg      = message ACrg_collect.ACadd_list_attribute
					( &msg, NbMissingParams, p_MissingParamsList ),
		 targetid = me->MissParamId.objid,
		 targetos = me->MissParamId.osnum ) ;
	as$status() ;
        
        /*^ VRprint_user_attr( &me->MissParamId ); */

    	*sts = VR_ADDED_PARAM;
	
  	/*"MissParamId = %d \n",me->MissParamId.objid*/
  }

#ifdef MY_DEBUG
  printf (" end eval method\n");
#endif

  return OM_S_SUCCESS;
}

/*****************************************************************************

		    VRReverseComponent	:
		    ---------------------
		    Reverse a component by inversing his X axis.
		
			- CmpMatrix					( I/O )	
			- CptNum					( I/O )

*******************************************************************************/

method VRReverseComponent( IGRlong *sts )
{
  int		  status = OM_S_SUCCESS;

  IGRlong			retmsg;
  IGRint			CompTopo;
  IGRboolean			Flag;
  enum 		GRdpmode 	mode;

  *sts = MSSUCC;
  Flag = TRUE;

  /* -- Erase Highligthed mode -- */
  status = dp$erase_hilite ( msg   = &retmsg,
			     osnum = me->ModuleEnv.md_id.osnum);

  /* -- test whether this is from rotate pip comp command or not -- */
  /* -- do this if the product is piping -- */

  /* -- set automatically, relearn OO programming      */

  /* -- Only one cpt : we cannot reverse component -- */
  if ( me->CmpNbCpts < 2 )
  {
	me->ret = VRNOT_OK;
	return OM_S_SUCCESS;
  }

  VRCheckCompTopo( &CompTopo, &me->CmpId, &me->ModuleEnv );

  if( CompTopo == VR_OLET_TOPO )
  {
	me->ret = VRNOT_OK;
	return OM_S_SUCCESS;
  }

  me->Angle = 0;
 
  /* -- Delete display of component at its previous position -- */
  mode = GRbe;
  status = om$send( msg      = message GRgraphics.GRdisplay
		       ( &retmsg, &me->ModuleEnv.md_env.matrix_type,
			 me->ModuleEnv.md_env.matrix, &mode, 
			 &me->ModuleEnv.md_id ),
	    targetid = me->CmpId.objid, 
	    targetos = me->CmpId.osnum );
  as$status();

  /* Rather than going through all permutations I'll make a quickie
     fix here to block this connectpointshuffling for normal 2 CP
     inline components when accessed by the rotate command

     (TR # 179601405      HV 5/1/96)                                 */

  /* Henk's "quickie-fix" appeared to be causing problems - commented out by
   * Anand for CR 3970 */

/*  if (me->bIsRotCmd && (me->CmpNbCpts == 2) && (CompTopo == VR_INLINE_TOPO))
 *{
 *  me->CptNum++;
 *  if( me->CptNum == me->CmpNbCpts)	me->CptNum = VR_CENTER_JUST;
 *}
 *else
 */
  { /*    leave rest of cases alone         */

    /* ----- Initialize cpt number on which rotation will be made ----- */
    if( me->CptNum == me->CmpNbCpts)	me->CptNum = VR_CENTER_JUST;

    if( me->NextCptNum == me->CmpNbCpts)	me->NextCptNum = VR_CENTER_JUST;


    if ( me->bIsRotCmd )
	if( me->NextCptNum == VR_CENTER_JUST )	me->NextCptNum = 0;


    /* If this is an inline component, then we need to be able to reverse
     the orientation around the center connect point. Therefore, hold
     the connect point to -1 (VR_CENTER_JUST) and call VR$Orient with
     bFlipByCenterPoint as the ReverseFlag. The ReverseFlag overrides the
     normal behavior of not reversing components with VR_CENTER_JUST
     justification.
    */
    if ((CompTopo == VR_INLINE_TOPO))
    {
	if ((!me->bFlipByCenterPoint) && (me->CptNum == VR_CENTER_JUST))
		me->bFlipByCenterPoint = TRUE;
	else if ((me->bFlipByCenterPoint) && (me->CptNum == VR_CENTER_JUST))
		{
		me->bFlipByCenterPoint = FALSE;
		me->CptNum++;
		}
	else  me->CptNum++;
    }	
    else me->CptNum++;

    if (me->CptNum == me->CmpNbCpts)
      /* Below 3 lines added by Anand - no TR/CR; prevent 'ref' being thrown up
       * as an option for Constrained components. */
      if( me->CmpType == VR_CONSTR_COMPONENT_TYPE )
	  me->CptNum = 0;
      else
      /* Above 3 lines added by Anand */
	  me->CptNum = VR_CENTER_JUST;
  }

#ifdef MY_DEBUG
printf (" Before reverse, CmpNbCpts %d, CptNum %d, NextCptNum %d, flip %d\n",
                me->CmpNbCpts,me->CptNum,me->NextCptNum,me->bFlipByCenterPoint);
#endif

  status = VR$OrientComp( p_retmsg = &retmsg,
		       	  p_CmpId  = &me->CmpId,
			  Justif   = me->CptNum,
		       	  Matrix   = me->CmpMatrix,
		       	  p_MdEnv  = &me->ModuleEnv,
			  ReverseFlag = me->bFlipByCenterPoint );

  if( ! ( status & 1 & retmsg ) )
  {
	*sts = MSFAIL;
	me->ret = VRNOT_OK;
	return OM_S_SUCCESS;
  }

  me->bCmpReversed = !(me->bCmpReversed);

  if(!(me->NbSupports < 2))
  {	
	status = VRTestCmpPosition( &me->CmpId,me->CmpNbCpts,me->NbSupports,
				    me->SupOrientation, &Flag, &me->ModuleEnv);
	as$status();


	if( !Flag )
	{
		if( me->CptNum )
   		{
			status = 
			om$send( msg = message VRCmpMgr.VRReverseComponent(
					&retmsg ),
	    		 	 targetid = my_id);
			as$status();
		}
	}
  }	
  
  /* -- Display component with his it's position -- */
  mode = GRbd;
  status = 
  om$send( msg      = message GRgraphics.GRdisplay
	      		( &retmsg, &me->ModuleEnv.md_env.matrix_type,
		 	  me->ModuleEnv.md_env.matrix, &mode, 
		 	  &me->ModuleEnv.md_id ),
	 targetid = me->CmpId.objid, 
	 targetos = me->CmpId.osnum );
  as$status();

  me->NextCptNum = me->CptNum +1;
  return OM_S_SUCCESS;

}

/******************************************************************************

		    VRRotateComponent	:
		    ---------------------
		    Rotate a component around an axis with a specified angle.

		    	- VR$OrientCmp		CmpMatrix		( I/O )
						Angle 	 		( I )

********************************************************************************/
method VRRotateComponent( IGRlong *sts )
{
  IGRlong			status, retcode;
  enum 		GRdpmode 	mode;

  *sts    = MSSUCC;

  /*"Angle = %f \n",me->Angle*/


  /* -- Delete old display of the component's graphic -- */
  mode = GRbe;
  status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &retcode, &me->ModuleEnv.md_env.matrix_type,
				 me->ModuleEnv.md_env.matrix, &mode, 
				 &me->ModuleEnv.md_id ),
		    targetid = me->CmpId.objid, 
		    targetos = me->CmpId.osnum );
  as$status();

  /*"CptNum = %d\n",me->CptNum*/

  /* -- Orient with specified amgle -- */

  VR$OrientComp( p_retmsg = &retcode,
		 p_CmpId  = &me->CmpId,
		 Justif   = me->CptNum,
		 Matrix   = me->CmpMatrix,
		 Angle    = me->Angle,
		 p_MdEnv  = &me->ModuleEnv,
		 ReverseFlag = me->bFlipByCenterPoint
	        );
  if( ! ( status & 1 &  retcode) )
  {
	*sts = MSFAIL;
	return OM_S_SUCCESS;
  }

  /* -- Display of the component oriented -- */
  mode = GRbd;
  status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &retcode, &me->ModuleEnv.md_env.matrix_type,
				 me->ModuleEnv.md_env.matrix, &mode, 
				 &me->ModuleEnv.md_id ),
		    targetid = me->CmpId.objid, 
		    targetos = me->CmpId.osnum );
  as$status();

  return OM_S_SUCCESS;
}


/********************************************************************************

		    VRComputeCmpAngle	:
		    ---------------------
		    Compute of an angle given by a Data Point. The angle is
		    the one from the X axis of the component.	

			- DataPoint					( I )
			  XAxis						( I )
			  Angle						( O )

********************************************************************************/
method VRComputeCmpAngle( IGRlong *sts )
{
  IGRlong			status, retcode;
  IGRdouble			dPoint[3], OrthoNormal[3];
  IGRdouble			dDotP, dCrossP, TmpV[3];
  IGRdouble			XAxis[3], YAxis[3], Origin[3];
  IGRmatrix			WinMatrix;
  IGRint			i;
  IGRlong			bsretcode;
  struct	GRid		WindowId;

  *sts    = MSSUCC;

  dPoint [0]	= me->event1.event.button.x;
  dPoint [1]	= me->event1.event.button.y;
  dPoint [2]	= me->event1.event.button.z;

  WindowId.objid = me->event1.event.button.objid;
  WindowId.osnum = me->event1.event.button.osnum;

  status = om$send( msg      = message IGEgragad.DPinrot( &retcode, WinMatrix),
		    targetid = WindowId.objid,
		    targetos = WindowId.osnum);
  as$status ();

  /* ------ Get X Axis and Origin from matrix  ----- */
  for( i=0; i<3; i++ )  
  {
	Origin[i] = me->CmpMatrix[(i*4)+3];
	XAxis[i]  = me->CmpMatrix[i*4];
  }

  PointViewDependant( dPoint, WinMatrix, XAxis, Origin );
  VRget_axis ( dPoint, Origin, XAxis, YAxis );

  OrthoNormal[0] = me->CmpMatrix[1];
  OrthoNormal[1] = me->CmpMatrix[5];
  OrthoNormal[2] = me->CmpMatrix[9];

  dDotP = BSdotp( &bsretcode, OrthoNormal, YAxis );

  BScrossp ( &bsretcode, OrthoNormal, YAxis, TmpV );
  dCrossP = BSlenvec( &bsretcode, TmpV );
  /*"dCrossP = %lf\n", dCrossP*/

  if( BSdotp( &bsretcode, XAxis, TmpV ) < BSBASISVAL ) dCrossP *= -1;

  /*"dDotP   = %lf\n", dDotP*/
  /*"dCrossP = %lf\n", dCrossP*/

  me->Angle = atan2( dCrossP, dDotP );
  /*"me->Angle = %f\n", me->Angle*/

  return OM_S_SUCCESS;
 
}

/******************************************************************************

		    VRRotateQuadrant	:
		    ---------------------
		    Rotate a component around his X axis of 90 degres.

		    	- Angle 	 			( I/O )

********************************************************************************/
method VRRotateQuadrant( IGRlong *sts )
{
  IGRlong			status, retcode;
  enum 		GRdpmode	mode;

  *sts    = MSSUCC;

  me->Angle = me->Angle + M_PI/2;
  modulo (&me->Angle, 2*M_PI);
  
  /*"Angle = %f \n",me->Angle*/

  /* -- Delete old display of the component's graphic -- */
  mode = GRbe;
  status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &retcode, &me->ModuleEnv.md_env.matrix_type,
				 me->ModuleEnv.md_env.matrix, &mode, 
				 &me->ModuleEnv.md_id ),
		    targetid = me->CmpId.objid, 
		    targetos = me->CmpId.osnum );
  as$status();
  
  /*"CptNum = %d \n",me->CptNum*/

  /* -- Orient with specified amgle -- */
  VR$OrientComp( p_retmsg = &retcode,
		 p_CmpId  = &me->CmpId,
		 Justif   = me->CptNum,
		 Matrix   = me->CmpMatrix,
		 Angle    = me->Angle,
		 p_MdEnv  = &me->ModuleEnv,
		 ReverseFlag = me->bFlipByCenterPoint
	        );
  if( ! ( status & 1 & retcode ) )
  {
	*sts = MSFAIL;
	return OM_S_SUCCESS;
  }

  /* -- Delete old display of the component's graphic -- */
  mode = GRbd;
  status = om$send( msg      = message GRgraphics.GRdisplay
			       ( &retcode, &me->ModuleEnv.md_env.matrix_type,
				 me->ModuleEnv.md_env.matrix, &mode, 
				 &me->ModuleEnv.md_id ),
		    targetid = me->CmpId.objid, 
		    targetos = me->CmpId.osnum );
  as$status();

  return OM_S_SUCCESS;
}
/**************************************************************************/

method VRGetAABBCCCode ( IGRlong *sts )
{
  IGRlong		msg, status;
  IGRint		Shape;
  struct  ACrg_coll	Collection;

  me->CmpAABBCCcode[0] = 0;

#ifdef MY_DEBUG
  printf ("AABBCC_CODEkeyin is <%s>\n", me->event1.event.keyin);
#endif

  if( me->event1.event.keyin[0] == '\0' )
  {
	*sts = MSFAIL;
	return OM_S_SUCCESS;
  }

  status = VRGetAABBCC ( &msg, &me->event1, me->CmpAABBCCcode, (IGRshort *)&me->Flags);

  if (me->Flags & SHAPEFLAG)
  {
    	Shape  = me->Flags & 0x00ff;
    	/*"Shape is %d\n", Shape */

    	/*| Updating collection VR_N_SHAPE_IN */
    	strcpy ( Collection.name , VR_N_SHAPE_IN ); 
    	Collection.desc.type          = AC_ATTRIB_DOUBLE;
    	Collection.desc.value.att_exp =  Shape;
    	status = VRUpdateParameterBox( &msg, &Collection, &me->SysParamId);
    	as$status ();
  } 

#ifdef MY_DEBUG
  printf ("Code is <%s>\n",  me->CmpAABBCCcode);
#endif

return	OM_S_SUCCESS;

}
/*******************************************************************************************/
method VROrientByAngle( IGRlong *sts )
{
  *sts    = MSSUCC;

  if ( me->event1.event.value == 0 )
  {
	*sts = VRNOT_OK; 
	return OM_S_SUCCESS;
  }
  else
  {
  	me->Angle = me->Angle + ((me->event1.event.value*M_PI) / 180 );
  	modulo (&me->Angle, 2*M_PI);
  } 

  /*"Angle = %f\n", me->Angle */

  return OM_S_SUCCESS;
}
/* -------------------------------------------------------------------------- */

method VRDisplayAngle (IGRlong *ret)
{
  IGRdouble	Tmp;

  Tmp = ( me->Angle*180 ) / M_PI;

  ex$message( field 	= ERROR_FIELD, 
	      msgnumb 	= VR_S_DisplayAngle,
	      type	= "%3.2f",
	      var 	= Tmp
	    );

  return OM_S_SUCCESS; 
}

/**********************************************************************/

method VRValidateXtion( IGRlong *sts )
{
	IGRlong			retmsg;

	*sts    = MSSUCC;

	/*A Validate the Xtion component	*/
	if ( !VRIsShXtionValid( &retmsg, &me->CmpId, &me->ModuleEnv ) )
		*sts = VRNOT_OK; 

	return OM_S_SUCCESS;

}

method VRSKF_start ( IGRlong *sts )
{
  IGRlong     status;

  *sts    = MSSUCC;

#ifdef MY_DEBUG
  printf (" SKF_start\n");
#endif

  if (me->bSKF_up)
  {
    me->pSKF = me->forms[0].form_ptr;

    status = FIf_display (me->pSKF);
  /******ADDED FOR TR179702488 ***************************************/
  /** Build associative lists for diameter and option-code          **/
  /*******************************************************************/
  /*| -- Get Nominal Size List and initialize form -- */
  if( me->Product == VR_PIPING ){

        struct ret_struct ParamAttr;
        IGRint            FootIndex = -1, retstatus;
        IGRlong 	  msg,retcode;
        IGRchar           specname[15];
        IGRshort          opt_cnt=0; /* law 04/06/98 int causing solaris crash*/
        IGRint		  i,listsize=0;
        IGRdouble         *npdlist;

  /*
   * Fix for TR179801965 - Cnpdlist was needlessly declared as a 150 x 9 double 
   * char array. Crash occurs only on Solaris 2.6. Now declared as a 1-d array.
   *							- Anand
   */
   /**** TR-MP4140 allow 80 char option-codes *************************/
        IGRchar           Cnpdlist[9];

        IGRdouble         size_g=0.0;
        IGRshort          *opt_codes;
        IGRchar           *opt_txt;
        IGRchar		  *err_ptr;
        struct  ACrg_coll Collection;
        IGRchar		  optcodes[81];

        err_ptr = NULL;
        opt_txt = NULL;
        npdlist = NULL;
        opt_codes       = NULL ;

        status =
        om$send( msg      = message ACncpx.ACgive_structure( &retstatus,
                                                             &FootIndex,
                                                             VR_N_CLASS_AN,
                                                             &ParamAttr,
                                                             &me->ModuleInfo),
	     targetid = me->SysParamId.objid,
	     targetos = me->SysParamId.osnum );
        as$status( action = RET_STATUS );

        strcpy(specname, ParamAttr.var.text_st.text_string);

        status =
        VRget_npd_list( &msg, me->Product,
                        ParamAttr.var.text_st.text_string,
                        &listsize , &npdlist, err_ptr);
        if( status & 1 )
        {
                FIfld_set_list_num_rows( me->pSKF, BIG_DIAM, 0,listsize );
                FIfld_set_list_num_rows( me->pSKF, 
                                         SMALL_DIAMETER, 0,listsize );
                for(i=0; i<listsize; i++)
                {
                        sprintf(Cnpdlist, "%f", npdlist[i]);
                        FIfld_set_list_text( me->pSKF, BIG_DIAM, i, 0,
                                    (unsigned char *) Cnpdlist, FALSE);
                        FIfld_set_list_text( me->pSKF, SMALL_DIAMETER, i,
                                 0, (unsigned char *) Cnpdlist, FALSE);
                }
        }
        strcpy( Collection.name, VR_N_GDIAMETER_DB );
        status =
           om$send ( msg = message ACrg_collect.ACget_named_attribute(
                                           &retcode, &Collection ),
                                 senderid = NULL_OBJID,
	     targetid = me->SysParamId.objid,
	     targetos = me->SysParamId.osnum );

        as$status( );

        size_g = Collection.desc.value.att_exp;

        status = VRget_opt_code_txt( &retcode, VR_PIPING, me->CmpAABBCCcode,
                               specname, size_g, size_g, &opt_codes,
                               &opt_txt, &opt_cnt, NULL);

        if( status&1 )
       {
           FIfld_set_list_num_rows( me->pSKF, OPTION_FLD, 0, opt_cnt);
           for( i=0; i< opt_cnt; i++ )
           {
              IGRchar   p_error[30];
              /*** TR-MP4140 initialize o_lname for no-match ***/
              optcodes[0] = '\0';
              status = vd$get_alias ( p_msg     = &msg,
                                      product  = PIPING,
                                      type     = VR_OPTCODE_LIST_NUM,
                                      i_code   = opt_codes[i],
                                      o_lname  =  optcodes,
                                      p_error  = p_error       );

              if ( !strlen( optcodes) )
              {
                  sprintf( optcodes, "%d", opt_codes[i] );
              }
              FIfld_set_list_text( me->pSKF, OPTION_FLD, i,
                                 0, (unsigned char *) optcodes, FALSE);
           }
        }
  }
/***** end add for TR179702488 ****************************************/

    status =
    om$send (msg = message VRCmpMgr.VRSKF_fill (sts),
        targetid = my_id);

    *sts = VRSKF_DOIT;
  }

  return OM_S_SUCCESS;
}

method VRSKF_fill  ( IGRlong *sts )
{
  *sts    = MSSUCC;

  return OM_S_SUCCESS;
}

end implementation VRCmpMgr;
