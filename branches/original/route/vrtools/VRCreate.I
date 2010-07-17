/* $Id: VRCreate.I,v 1.5 2002/05/03 13:52:16 louis Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrtools / VRCreate.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRCreate.I,v $
 *	Revision 1.5  2002/05/03 13:52:16  louis
 *	TR5959 pload cleanup for symbolization
 *	
 *	Revision 1.4  2002/04/10 20:44:42  louis
 *	TR5649-Standardize tolerance
 *	
 *	Revision 1.3  2001/02/20 01:17:37  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 20:09:12  anand
 *	SP merge
 *	
# Revision 1.2  2000/11/30  23:19:30  pinnacle
# Replaced: route/vrtools/VRCreate.I for:  by aharihar for Service Pack
#
# Revision 1.1  2000/05/24  01:31:18  pinnacle
# Created: route/vrtools/VRCreate.I by lawaddel for Service Pack
#
# Revision 1.5  2000/01/25  18:57:04  pinnacle
# Replaced: vrtools/VRCreate.I for:  by lawaddel for route
#
# Revision 1.4  2000/01/04  14:54:44  pinnacle
# Replaced: vrtools/VRCreate.I for:  by lawaddel for route
#
# Revision 1.3  1999/05/24  20:38:58  pinnacle
# Replaced: vrtools/VRCreate.I for:  by lawaddel for route
#
# Revision 1.2  1998/10/28  23:21:54  pinnacle
# Replaced: vrtools/VRCreate.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.4  1997/10/30  17:48:00  pinnacle
# Replaced: vrtools/VRCreate.I for:  by impd for route
#
# Revision 1.3  1997/09/02  19:26:54  pinnacle
# Replaced: vrtools/VRCreate.I for:  by onayragu for route
#
# Revision 1.2  1997/07/17  19:54:02  pinnacle
# Replaced: vrtools/VRCreate.I for:  by r250_int for route
#
# Revision 1.5  1997/07/07  22:08:08  pinnacle
# Replaced: vrtools/VRCreate.I for:  by yzhu for route
#
# Revision 1.4  1997/03/05  18:06:46  pinnacle
# Replaced: vrtools/VRCreate.I for:  by hverstee for route
#
# Revision 1.3  1997/03/03  18:31:58  pinnacle
# Replaced: vrtools/VRCreate.I for:  by r241_int for route
#
# Revision 1.2  1997/02/28  11:05:36  pinnacle
# Replaced: vrtools/VRCreate.I for:  by apazhani for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/01/18  00:30:08  pinnacle
# Replaced: vrtools/VRCreate.I for:  by r240_int for route240
#
 *
 * History:
	01/17/96   tlb	Add prototypes
	07/07/97   yzhu	use VDsetAttDrSymb
	09/02/97   Onay	Additional params enhancement.
        10/23/98   Alwin Modified the design of the inline components having
                         Additional Parameters. TR179800720/179800830
        01/04/00   Law   TR179801414 - CONRED sizing incorrect
 *      01/25/00    law         tr179900976 - transition failures
 *      11/30/2k   Anand	Added check for null pointer to prevent crash.
 *      04/08/02    law         TR5649-standardize tolerance with VRGetTol
 *      05/02/02    law         tr5959 pload cleanup-remove redundant display
 *
 *************************************************************************/
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*
/*  function called by sketch command to create and place a component.
/*
/*  CHANGE HISTORY:  momo 6-11-1989 : Design date
/*
/*  Implementation of : VR$GetCompGenInfo and VR$PlaceCmpByItemName macros.
/* 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


class implementation Root;


#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "VRattr_def.h"
#include "msdef.h"
#include "msmacros.h"
#include "VRmacros.h"
#include "VRdef.h"
#include "VRdimdef.h"
#include "VRcompdef.h"
#include "VRclsymb.h"
#include "VRsketchdef.h"
#include "nddef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRstructs.h"
#include "ndmacros.h"
#include "ACrg_collect.h"
#include "VRparamdef.h"		/* I/ROUTE feet names definition */
#include "VDDbtbldef.h"		/* Generic feet names definition */
#include "ACattrib.h"
#include "acrepmacros.h"
#include "VRpriv_attr.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VRclsymb.h"
#include "AS_status.h"
#include "VRPid.h"
#include "VRMath.h"
#include "VDSutil.h"
/*#include "VDSudp_mac.h" */
#include "v_drw.h"
#include "vrdbgmacros.h"
#include "vddgndef.h"
#include "VRRwDimen.h"
#include "vdattmacros.h"                /* vd$get_attr_symbology        */
#include "vrtools_pto.h"                /* vd$get_attr_symbology        */
/* bs includes added for tr179801414 */
#include "bserr.h"
#include "bsparameters.h"
#include "bsvalues.h"


#define AS_DEBUG
#define	VR_MANAGE_TAG	2

from 	NDnode		import 	NDdisplay, NDchg_state, NDcopy, NDdelete;
from	ACrg_collect	import	ACadd_list_attribute, AClist_attribute;
from	VRComponent	import	VRReplace;
from	ACncpx		import	ACgive_structure;
from	VRGeneric	import	VRGetInstance, VRSetInstance;
from 	GRvg       	import  GRputsymb;
from 	VDSroot       	import  VDgetAttrDrivenSymb;

extern	GRclassid	OPP_ACrg_collect_class_id; 

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint VRPlaceCmpByItemName
( p_msg, PlacementTime, Product, TopoParentsNum, p_TopoParentsList, 
  CmpItemName, CmpJust, p_CmpIndexOnTopo, p_RelCmpOrient, p_CmpAngle, 
  p_CmpOrientSection, DisplayFlag, p_OldCmpId, p_ModuleEnv, p_ActParamId, 
  p_BufParamId, p_UserParamId, p_MissParamId, p_CmpCstList
)
IGRlong		*p_msg;			/* O   : Return code 		     */
IGRshort	PlacementTime;		/* I   : VR_PLACE or VR_REPLACE	     */
IGRshort	Product;      	      	/* I   : Product name		     */
IGRint		TopoParentsNum;	   	/* I   : number of Component supports*/
struct	GRid	*p_TopoParentsList;    	/* I   : GRid list of the commponent */
					/*       supports                    */
IGRshort	CmpItemName;   		/* I   : Component Item Name	     */
IGRshort	CmpJust; 		/* I   : Component placement justif  */
IGRshort	*p_CmpIndexOnTopo;	/* I   : Component index on supports */
IGRshort        *p_RelCmpOrient; 	/* I   : Component orientation       */
					/*       relatively of supports axis */
IGRdouble	*p_CmpAngle;            /* I   : Component angle if placement*/
					/*       matrix not defined completly*/
					/*       only by supports topo       */
IGRdouble	*p_CmpOrientSection;    /**/
IGRboolean	DisplayFlag;            /* I   : if TRUE component will be   */
					/*	 displayed after placement   */
struct	GRid	*p_OldCmpId;		/* I/O : In input to replace an      */
					/*       existing component.         */
struct GRmd_env *p_ModuleEnv;		/* I   : Module info                 */
struct	GRid	*p_ActParamId;          /* I   : Active System attributes    */
					/*       collection                  */
struct	GRid	*p_BufParamId;          /* I   : Last active system attribute*/
					/*       collection befor changement */
					/*       needed for reducing comp    */
struct	GRid	*p_UserParamId;         /* I   : User attributes collection  */
struct	GRid	*p_MissParamId;         /* O   : Missing attributes coll     */
struct	GRvg_construct  *p_CmpCstList;  /* I   : Component construction list */

/*.VRPlaceCmpByItemName */
{
  IGRint	sts;
  IGRint 	CmpType;    		/* component type	             */
  IGRint 	CmpNbCpts;    		/* number of cpts                    */
  IGRint 	NbMissingParams=0;	/* number of missing params return by*/
					/* the evaluate macro                */
  IGRlong	status;        		/* return code       		     */
  IGRlong	retcode;       		/* return code                 	     */
  IGRlong	NumberOfBytes; 		/* to get current md_env       	     */
  IGRlong	BytesReceived; 		/* to get current md_env       	     */
  IGRdouble	Angle=0;
  IGRdouble	VRGetAngle();
  struct	GRsymbology	Symb;
  struct GRid	NewCmpId; 		/* created CnrlCmp             	     */
  struct GRid	*p_CmpToEvaluateId;	/* needed to evaluate created  	     */
  struct GRid	ParentsList[VR_NB_ATTR];/* new attributes list	             */
  struct GRid	SymbId;
  struct GRmd_env	MdEnv; 		/* current md_env              	     */
  struct GRmd_env	*p_MdEnv;	/* pointer to md_env structure 	     */
  struct VRGenInfo	CmpGenInfoStr;	/* component info              	     */
  struct IGRdisplay	ActiveDisplay;  /* Active Display              	     */
  struct GRvg_construct CnstList; 	/* construction list           	     */
  struct GRvg_construct *p_CnstList; 	/* pointer to construction list	     */
  struct ACrg_coll	*p_MissingParamsList;/* missing parameters collection*/
					/* returned by the evaluate macro    */

  /*  following are used by vd$get_att_symbology */
  IGRchar                 path[DI_PATH_MAX];
  IGRchar                 filename[DI_PATH_MAX];
  struct		  GRsymbology	ActSymb  /*, AttrSymb  */  ;
  long 			  msg;
  struct GRid             collId; /* for symbology collector */
  VD_drwOutputData        *output = NULL;

/* For additional params prompting	*/
IGRint			NbAttr;
struct	ACrg_coll	Attributes [VR_MAX_ATTR];
struct GRid		NewCollectionId;

struct VRGenInfo        Instance; // added for TR179800720

  SetProc( VRPlaceCmpByItemName ); Begin 
  *p_msg  = MSSUCC;
  retcode = MSSUCC;
  status  = OM_S_SUCCESS;

  /* check argument coherence */
  if( PlacementTime != VR_NEW_COMP && ! p_OldCmpId )
  {
	/*| invalid argument */
	ex$message( field   = ERROR_FIELD,
	            in_buff = "Bad argument to replace component !" );
        End 
 	return OM_E_INVARG;
  }

  /* get the module info */ 
  if( ! p_ModuleEnv )
  {
    	if( p_CmpCstList && p_CmpCstList->env_info ) p_MdEnv = p_CmpCstList->env_info;
    	else
    	{
      		/*| Get the current module info */

      		p_MdEnv = &MdEnv;

      		NumberOfBytes = sizeof( struct GRmd_env );
      		status = gr$get_model_env( 	msg    = &retcode,
    			         		sizbuf = &NumberOfBytes,
			         		buffer = p_MdEnv,
			         		nret   = &BytesReceived );
      		as$status( action = RET_STATUS );
    	}
  }
  else p_MdEnv = p_ModuleEnv; 
  
  /*"module_info = %d %d\n", p_MdEnv->md_id.objid, p_MdEnv->md_id.osnum */

  p_CmpToEvaluateId 	= (p_OldCmpId) ? p_OldCmpId : &NewCmpId;
  if( PlacementTime == VR_NEW_COMP )
  {
	p_CmpToEvaluateId->objid= NULL_OBJID;
  }
  else
  {
	status =
	om$send( msg      = message NDnode.NDdisplay( 0, GRbehe, p_MdEnv ),
		senderid = NULL_OBJID,
		targetid = p_OldCmpId->objid,
		targetos = p_OldCmpId->osnum );
    	as$status( action = RET_STATUS );

        //Store the Old Component's Instance, so that we can reset when
        //replacement fails. Alwin
        status =
        om$send( msg      = message VRGeneric.VRGetInstance( &retcode,
                                &Instance ),
                senderid = NULL_OBJID,
                targetid = p_OldCmpId->objid,
                targetos = p_OldCmpId->osnum );
        as$status( action = RET_STATUS );
  }

  /* If there exists the Missing Parameter, instead of adding the Missing
  Parameters to the "User Paramerters", we'll add it into the Missing Parameter
  Collector and increase the "me->NbAttr" to 3. This should be sufficient for
  the Evalualation process. In a way we alliging our design to that of the
  Manually placed component, any component which has missing parameters is
  forced to have three parent collectors. Alwin for TR179800720/830 */
  if ( p_MissParamId && ( p_MissParamId->objid != NULL_OBJID ) )
  {
    ParentsList[2] = *p_MissParamId;
  }

  /* - set component istance info in the generic structure
  /* - update topology information ( index on support, orientation, angle, .. )
  /* - system attribute collection given Active and Buffer attribute collections
  /**/
  status =
  VRGetCompGenInfo(	&retcode, Product, TopoParentsNum, p_TopoParentsList,
			CmpItemName, CmpJust, p_CmpIndexOnTopo,
         		p_RelCmpOrient, p_CmpAngle,p_CmpOrientSection,
         		p_MdEnv, p_ActParamId, p_BufParamId,
/*			&CmpGenInfoStr,  &ParentsList[0] ); commenting this
b'cas the missing parameters has been added */
                        &CmpGenInfoStr,  &ParentsList[0], p_MissParamId );
  as$status();
  as$status( sts = retcode );
  __DBGpr_com("back from VRGetCompGenInfo");
  /*"component Sys Param = %d\n", ParentsList[0].objid */


 if( CmpItemName == VR_ELBOW || CmpItemName == VR_TEE )
 {
  	Angle = VRGetAngle( &retcode, p_TopoParentsList,
			CmpGenInfoStr.Attr.Comp.Orientation.dPrimary,
			CmpGenInfoStr.Attr.Comp.Orientation.dSecondary, p_MdEnv );
 }

  /*| temporary to test */

  /*"nproIndex = %d\n", CmpGenInfoStr.Attr.Comp.Orientation.nPriIndex */
  /*"nSecIndex = %d\n", CmpGenInfoStr.Attr.Comp.Orientation.nSecIndex */
  /*"dprimary  = %f\n", CmpGenInfoStr.Attr.Comp.Orientation.dPrimary  */
  /*"dsecondary= %f\n", CmpGenInfoStr.Attr.Comp.Orientation.dSecondary*/

  /*| call the evaluate macro. This macro is going to create the component and evaluate it */

  ParentsList[1] = *p_UserParamId;

#ifdef UN_COMMENT
if (p_MissParamId)
  {
  if (p_MissParamId->objid != NULL_OBJID)
    {
    /* Need to create a collection gathering standard user collection	*/
    /* and missing attributes got from previous evaluation.		*/
    NewCollectionId.osnum	= p_MdEnv->md_id.osnum;
    NewCollectionId.objid	= NULL_OBJID;
    status = om$send (msg = message NDnode.NDcopy (
			&retcode, 0, p_MdEnv, p_MdEnv, &NewCollectionId),
				senderid = NULL_OBJID,
				targetos = ParentsList [1].osnum,
				targetid = ParentsList [1].objid );
    status = om$send (msg = message ACrg_collect.AClist_attribute
			(&retcode, VR_MAX_ATTR, Attributes, &NbAttr),
				senderid = NULL_OBJID,
				targetos = p_MissParamId->osnum,
				targetid = p_MissParamId->objid );
    status =
    VR$ModifyCollection (	p_msg			= &retcode,
				Operation		= VR_MERGE_COLL,
				p_ParamsListToModify	= Attributes,
				NbParamsToModify	= NbAttr,
				p_OutputCollectionId	= &NewCollectionId );
    ParentsList [1]	= NewCollectionId;
    /*"new collection id is %ld\n",NewCollectionId.objid */
    }
  }
#endif

  /*"component User Param = %d\n", ParentsList[1].objid */

  SymbId.osnum = p_MdEnv->md_id.osnum;
  VR$symbology( return_code = &retcode,
                symb_id     = &SymbId,
                symb        = &Symb );
  __DBGpr_com("Doing evaluate");
/*** This block added for tr179801414 for conred resizing ***/
if ( Product == VR_RWAY )
{
  struct VRRwCptDetails LocRWcptdata[10];
  struct VRRwCptDetails TmpRWcptdata[2];
  IGRint active_cpt,tmpactshape,tmpbufshape,tmpcmpshape;
  IGRdouble width1,width2,depth1,depth2;
  struct ret_struct ParamAttr;
  IGRint            FootIndex = -1, retstatus;

  active_cpt = 0;
  if(p_BufParamId)
  {
     /* "bufparam is %ld\n",p_BufParamId->objid **/

      /**** Major additions for transitions --- tr179900976 ****/
      FootIndex = -1;
      status =
                om$send( msg      = message ACncpx.ACgive_structure(
                           &retstatus, &FootIndex,
                           VR_N_SHAPE_IN, &ParamAttr, p_MdEnv),
                    senderid = NULL_OBJID,
		    targetid = p_BufParamId->objid,
		    targetos = p_BufParamId->osnum );
      tmpbufshape = (IGRint) ParamAttr.var.root_pm_st.value;
      __DBGpr_int("BufParam shape ",tmpbufshape);

      __DBGpr_com( " Calling40 VRRw_dimen_fields ");
      status = VRRw_dimen_fields(NULL,NULL,NULL,
                           p_MdEnv, 2, NULL, 0,
                              tmpbufshape, LocRWcptdata, p_BufParamId);
      TmpRWcptdata[0] = LocRWcptdata[0];
      FootIndex = -1;
      status =
                om$send( msg      = message ACncpx.ACgive_structure(
                           &retstatus, &FootIndex,
                           VR_N_SHAPE_IN, &ParamAttr, p_MdEnv),
                    senderid = NULL_OBJID,
		    targetid = p_ActParamId->objid,
		    targetos = p_ActParamId->osnum );

      tmpactshape = (IGRint) ParamAttr.var.root_pm_st.value;
      __DBGpr_int("ActParam shape ",tmpactshape);
      __DBGpr_com( " Calling41 VRRw_dimen_fields ");
                     status = VRRw_dimen_fields(NULL,NULL,NULL,
                              p_MdEnv, 2, NULL, 0,
                              tmpactshape, LocRWcptdata, p_ActParamId);
      TmpRWcptdata[1] = LocRWcptdata[1];
      if(tmpbufshape == tmpactshape) tmpcmpshape == tmpactshape;
      else if(tmpbufshape == VR_RECT)
      {
         if(tmpactshape == VR_CIRC) tmpcmpshape = VR_RECT_CIRC;
         else if(tmpactshape == VR_OVAL) tmpcmpshape = VR_RECT_OVAL;
         else if(tmpactshape == VR_CORNER) tmpcmpshape = VR_RECT_CORN;
         else tmpcmpshape = VR_RECT_ELLP;
      }
      else if(tmpbufshape == VR_CIRC)
      {
         if(tmpactshape == VR_RECT) tmpcmpshape = VR_RECT_CIRC;
         else if(tmpactshape == VR_OVAL) tmpcmpshape = VR_OVAL_CIRC;
         else if(tmpactshape == VR_CORNER) tmpcmpshape = VR_CIRC_CORN;
         else tmpcmpshape = VR_CIRC_ELLP;
      }
      else if(tmpbufshape == VR_OVAL)
      {
         if(tmpactshape == VR_RECT) tmpcmpshape = VR_RECT_OVAL;
         else if(tmpactshape == VR_CIRC) tmpcmpshape = VR_OVAL_CIRC;
         else if(tmpactshape == VR_CORNER) tmpcmpshape = VR_OVAL_CORN;
         else tmpcmpshape = VR_OVAL_ELLP;
      }
      else if(tmpbufshape == VR_CORNER)
      {
         if(tmpactshape == VR_RECT) tmpcmpshape = VR_RECT_CORN;
         else if(tmpactshape == VR_CIRC) tmpcmpshape = VR_CIRC_CORN;
         else if(tmpactshape == VR_OVAL) tmpcmpshape = VR_OVAL_CORN;
         else tmpcmpshape = VR_ELLP_CORN;
      }
      else
      {
         if(tmpactshape == VR_RECT) tmpcmpshape = VR_RECT_ELLP;
         else if(tmpactshape == VR_CIRC) tmpcmpshape = VR_CIRC_ELLP;
         else if(tmpactshape == VR_OVAL) tmpcmpshape = VR_OVAL_ELLP;
         else tmpcmpshape = VR_ELLP_CORN;
      }

     __DBGpr_com( " Calling42 VRRw_dimen_fields ");
                     status = VRRw_dimen_fields(NULL,NULL,NULL,
                              p_MdEnv, 2, NULL, 0,
                              tmpcmpshape, LocRWcptdata, &ParentsList[0]);

     /*** TR179900976 transition processing ***/
     if(tmpcmpshape != VR_RECT_OVAL &&
        tmpcmpshape != VR_RECT_CIRC &&
        tmpcmpshape != VR_RECT_CORN &&
        tmpcmpshape != VR_RECT_ELLP &&
        tmpcmpshape != VR_OVAL_CORN &&
        tmpcmpshape != VR_OVAL_ELLP &&
        tmpcmpshape != VR_ELLP_CORN &&
        tmpcmpshape != VR_CIRC_ELLP)
     {
        IGRint w_d_swap;
        width1 = TmpRWcptdata[0].width;
        depth1 = TmpRWcptdata[0].depth;
        width2 = TmpRWcptdata[1].width;
        depth2 = TmpRWcptdata[1].depth;

        w_d_swap = 0; /* if true is expander */
        /*** Modifications for tr179900976 ***/
        if (tmpcmpshape == VR_OVAL_CIRC)
        {
           /* A simple kludge to correct the reversing of cpt0/1 */
           w_d_swap = 1;
        }
        else if (tmpcmpshape == VR_RECT_CIRC)
        {
           TmpRWcptdata[1].depth = TmpRWcptdata[1].width;
        }
        else if (tmpcmpshape == VR_CIRC_CORN )
        {
           TmpRWcptdata[0].depth = TmpRWcptdata[0].width;
        }
        else if((width2 - width1) > VRGetTol(VR_DIST_TOL))
            w_d_swap = 1;
        else if (((width1 - width2) < VRGetTol(VR_DIST_TOL)) &&
                   ((depth2 - depth1) > VRGetTol(VR_DIST_TOL)) )
            w_d_swap = 1;
        else
            __DBGpr_com( " No width depth swap detected ");

        if(w_d_swap)
        {
            LocRWcptdata[1] = TmpRWcptdata[0];
            LocRWcptdata[0] = TmpRWcptdata[1];
        }
        else
        {
            LocRWcptdata[0] = TmpRWcptdata[0];
            LocRWcptdata[1] = TmpRWcptdata[1];
        }
     }
     else
     {
        __DBGpr_com("transition found-skipping swap check");
     }
     /*** tr179900976 send correct shape ***/
     __DBGpr_com( " Calling43 VRRw_dimen_fields ");
     status = VRRw_dimen_fields(NULL,NULL,NULL,
                              p_MdEnv, 2, NULL, 2,
                              tmpcmpshape, LocRWcptdata, &ParentsList[0]);
  }

}
  sts = VR$Evaluate(	p_msg		= &retcode,
			Product		= ( IGRint )Product,
			ItemNum		= CmpItemName,
			SStatus		= CmpGenInfoStr.nStatus,
			Angle		= Angle,
			Number		= CmpGenInfoStr.szNumber,
			Notes 		= CmpGenInfoStr.szNotes,
			NoMtoFlg	= CmpGenInfoStr.cNoMtoFlg,
			p_Option	= &CmpGenInfoStr.nOption,
			Symbology	= &Symb,
			Representation	= CmpGenInfoStr.cRep,
			p_Type		= &CmpType,
			p_NbCpts	= &CmpNbCpts,
			p_SysParamId	= &ParentsList[0],
			p_UsrParamId	= &ParentsList[1],
                        /*added by alwin for TR179800720 */
                        p_MissParamId   = (p_MissParamId) ? p_MissParamId:NULL,
			p_ComponentId	= p_CmpToEvaluateId,
			p_NbMissParams	= &NbMissingParams,
			p_AddrMissings	= &p_MissingParamsList,
			p_MdEnv		= p_MdEnv );

  __DBGpr_com("Back from evaluate");
  if( !( sts & 1 & retcode) )
  {
    	ex$message( 	field   = ERROR_FIELD,
	        	in_buff = "Component not found in data base !");
        __DBGpr_com("Component not found in data base");
	End
	return OM_E_ABORT;
  }

  __DBGpr_int( " Nb. of Missing Params ", NbMissingParams );
  if( NbMissingParams )
  {
      /* Below if condition added by Anand to prevent a CRASH!! The
       * p_MissParamId need not be always a valid pointed passed to this
       * function.  VRPlaceCmpByItemName is infact called by a macro
       * VR$PlaceCmpByItemName and if p_MissParamId is not passed, it defaults
       * to null.  */
      if( p_MissParamId == NULL )
      {
	  /* ADDITIONAL_PARAMS value is 12 - the last bit does not end with a
	   * one and therefore signifies error status. Plus, at places, this
	   * information is expected - therefore consistent and okay. */
	  *p_msg = ADDITIONAL_PARAMS;
	  End
	  return OM_E_INVARG;
      }


     /*|add missing parameters in the user attribute list with default values */	
     ex$message( field	= ERROR_FIELD,
	      in_buff	= "Additional params added");

     *p_msg = ADDITIONAL_PARAMS;
     /* Creation of Missing attributes collection */
     p_MissParamId->osnum	= p_ModuleEnv->md_id.osnum;
     p_MissParamId->objid	= NULL_OBJID;
     status = om$construct (	classid	= OPP_ACrg_collect_class_id,
			   p_objid	= &p_MissParamId->objid,
			   osnum	= p_MissParamId->osnum,
			   msg	= 
				 message NDnode.NDchg_state (~0, ND_DEL_NO_CH));
     as$status ();

     status = om$send( msg      = message ACrg_collect.ACadd_list_attribute
			     ( &retcode, NbMissingParams, p_MissingParamsList ),
			     senderid = NULL_OBJID,
			     targetid = p_MissParamId->objid,
			     targetos = p_MissParamId->osnum ) ;
     as$status() ;
     as$status( sts = retcode );

     /* Evaluated component is deleted because of missing parameters	*/

     /* Don't delete this object in the case of the "Replacement of Component",
     we have reuse to proceed further ...  Alwin */

     if( PlacementTime == VR_NEW_COMP )
     {
         status = om$send (msg = message NDnode.NDdelete (p_MdEnv),
                       targetos = p_CmpToEvaluateId->osnum,
                       targetid = p_CmpToEvaluateId->objid,
                       senderid = NULL_OBJID );
         p_CmpToEvaluateId->objid       = NULL_OBJID;
     }
     else
     {
        /* In the case of old component case...we should not delete the
        component instead ..reset the instance data which had backed up
        before evaluation. Alwin for TR179800720/830 */
        status =
        om$send( msg      = message VRGeneric.VRSetInstance( &retcode,
                                &Instance ),
                senderid = NULL_OBJID,
                targetid = p_OldCmpId->objid,
                targetos = p_OldCmpId->osnum );
        as$status( action = RET_STATUS );
     }
     goto wrapup;
  }

  /*| place the evaluated component */

  /* get graphic construction list */
  if( ! p_CmpCstList )
  {
  	/*| Get the construction list */

  	p_CnstList = &CnstList;

  	status = VRGetConstructionList
             	         ( &retcode, p_MdEnv, NULL, NULL, &ActiveDisplay, NULL, p_CnstList );
    	as$status( action = RET_STATUS );
    	as$status( sts = retcode, action = RET_STATUS );
  }
  else p_CnstList = p_CmpCstList;

  if( PlacementTime == VR_NEW_COMP )
  {
#ifdef	MANAGE_IDS
      struct ret_struct	ParamAttr;
      IGRint 		FootIndex = -1, retstatus;
      IGRint		IdList[VDS_LIST_OF_IDS];
      IGRint		CmpCat=-1, CmpBehavior=-1;
#endif	MANAGE_IDS
      __DBGpr_com("Placing Macro");
      /*| call place macro */
      VR$Place(		p_msg			= &retcode,
			p_ComponentId		= p_CmpToEvaluateId,
			Type			= CmpType,
			NbCpts			= CmpNbCpts,
			p_Instance		= &CmpGenInfoStr,
			NbSegments		= TopoParentsNum,
			p_SegmentIds		= p_TopoParentsList,
			p_CnstList		= p_CnstList,
			p_MdEnv			= p_MdEnv );
      as$status( action = RET_STATUS );
      as$status( sts = retcode, action = RET_STATUS );
      __DBGpr_com("back from Placing Macro");

#ifdef	MANAGE_IDS
      /*A added for Id management in piping ( PID only ) */
      if ( p_CmpToEvaluateId->objid != NULL_OBJID ) 
      { 	
      /*A get the Cmp Category and Cmp Behavior */
      FootIndex = -1;
      status = 
      om$send( msg      = message ACncpx.ACgive_structure
		( &retstatus, &FootIndex, VD_N_ID_CATEGORY_IN,
				&ParamAttr, p_ModuleEnv ),
		senderid = NULL_OBJID,
		targetid = p_CmpToEvaluateId->objid,
		targetos = p_CmpToEvaluateId->osnum);
      as$status( action = RET_STATUS );

      CmpCat = (int)ParamAttr.var.root_pm_st.value;
      /*printf( " Cmp Category = %d \n", CmpCat );*/

      FootIndex = -1;
      status = 
      om$send( msg      = message ACncpx.ACgive_structure
		( &retstatus, &FootIndex, VD_N_BEHAVIOUR_IN,
				&ParamAttr, p_ModuleEnv ),
		senderid = NULL_OBJID,
		targetid = p_CmpToEvaluateId->objid,
		targetos = p_CmpToEvaluateId->osnum);
      as$status( action = RET_STATUS );

      CmpBehavior = (int)ParamAttr.var.root_pm_st.value;
      /*printf( " Cmp Behavior = %d \n", CmpBehavior );*/

      if ( Product != VR_RWAY &&
 		bVR_IS_PID_ACTIVE && CmpBehavior == (int)VR_MANAGE_TAG )
      {
	struct	VRGenInfo	Instance;

	/*A Get system name */
	status = 
	om$send( msg      = message ACncpx.ACgive_structure
		( &retstatus, &FootIndex, VD_N_SYSTEM_NAME_AN,
				&ParamAttr, p_ModuleEnv ),
		senderid = NULL_OBJID,
		targetid = p_CmpToEvaluateId->objid,
		targetos = p_CmpToEvaluateId->osnum);
	as$status( action = RET_STATUS );

	/*A get the instance data of the created comp */
	status = 
	om$send( msg	= message VRGeneric.VRGetInstance( 
			&retcode, &Instance ),
		senderid = NULL_OBJID,
		targetid = p_CmpToEvaluateId->objid,
		targetos = p_CmpToEvaluateId->osnum);
	as$status( action = RET_STATUS ) ;

	/*C get the list of available line Ids */
	status = 
	VDGetListOfIDs( ParamAttr.var.text_st.text_string,
			CmpCat, IdList );

	for ( i=0; i<VDS_LIST_OF_IDS; i++)
	{
		/*C lock this Id*/
		status =
		VDLockSelectedID ( ParamAttr.var.text_st.text_string,
			CmpCat, IdList[i] );

		if ( status&1 ) {
		sprintf(Instance.szNumber, "%05d", IdList[i] );
		break;
		}
	}
	
	/*A set the instance with the tag number being set */
	status = 
	om$send( msg	= message VRGeneric.VRSetInstance( 
		&retcode, &Instance ),
		senderid = NULL_OBJID,
		targetid = p_CmpToEvaluateId->objid,
		targetos = p_CmpToEvaluateId->osnum);
	as$status( action = RET_STATUS ) ;	

      } /*end id management */
      } /* end NULL_OBJID check */
#endif

  }
  else
  {
      	IGRint i;
	struct GRid ParentsList1[VR_NB_ATTR+VR_MAX_CPTS];
	struct GRas assoc_list;

        //added by Alwin for TR179800720
        if( p_MissParamId && ( p_MissParamId->objid != NULL_OBJID ) )
        {
            struct VRGenInfo CompInstance;

            status =
            om$send ( msg = message VRGeneric.VRGetInstance( &retcode,
                                            &CompInstance ),
                          senderid = NULL_OBJID,
                          targetid = p_OldCmpId->objid,
                          targetos = p_OldCmpId->osnum );
            as$status( action = RET_STATUS );

            //B'cas before evaluation...CmpGenInfo has NULL, its only after
            //evaluation it gets the CompCode value, which needs to obtained
            //from the Instance of the evaluated component. Alwin

            strcpy( CmpGenInfoStr.szAABBCC, CompInstance.szAABBCC );
        }

	/*| KLUDGE WAITING THE REPLACE MACRO */
	for(i=0;i<CmpGenInfoStr.nNbAttr;i++) ParentsList1[i]   = ParentsList[i];
	for(i=0;i<CmpGenInfoStr.nNbTopo;i++) 
		ParentsList1[i+CmpGenInfoStr.nNbAttr] = p_TopoParentsList[i];

  	assoc_list.as_attr        = ( IGRchar * ) &CmpGenInfoStr;
  	assoc_list.num_parents    = CmpGenInfoStr.nNbTopo + CmpGenInfoStr.nNbAttr;
  	assoc_list.go_objid.objid = NULL_OBJID;
  	assoc_list.parents        = ParentsList1;

    	status = om$send( msg      = message VRComponent.VRReplace
			    ( &assoc_list, p_MdEnv, ( IGRchar * ) p_CnstList ),
                      senderid = NULL_OBJID,
                      targetid = p_OldCmpId->objid,
                      targetos = p_OldCmpId->osnum );
    	as$status( action = RET_STATUS );

      	nd$exec_batch();
  }

  /*vds$get_active_symb( &ActSymb ) */

/*** removed for tr5959 pload cleanup *****/
#if 0
  VRget_active_symb ( &(ActSymb.level), &(ActSymb.display_attr));
  __DBGpr_com("attribute symbology");
  /* yzhu attr.symb or user defined file for symbology driven */
  collId.objid = NULL_OBJID ;
  status =
  VDgetVdCollId( &msg, VD_DGNST_DIR_NAME, FALSE, FALSE, &collId );
  if( (status&msg&1) ) {
      status = VDsetAttDrSymb(&msg, *p_CmpToEvaluateId, p_MdEnv, output );
      if( !(status&msg&1) ) {
        status =
        om$send(msg      = message GRvg.GRputsymb( &retcode, &ActSymb),
                senderid = NULL_OBJID,
                targetid = p_CmpToEvaluateId->objid,
                targetos = p_CmpToEvaluateId->osnum ) ;
      }
      VD_drwFreeOutputData( &output ) ;
  }
  else {
	/*
	*  read symbology from input file. 9/1/94
	*  For the moment it is hardcoded later we need to change it using
	*  setup file. msm. 9/5/94
	*/

        /* simply OVERRIDE the active values with the VDS method
           HV 3/4/97                                             */
	strcpy( filename, "routeattr.symb");
	status =
        om$send( msg = message VDSroot.VDgetAttrDrivenSymb(
                                        &retcode,
					filename,
                                        p_MdEnv,
                                        &ActSymb),
/*
                                        &AttrSymb),
*/
		senderid = NULL_OBJID,
                targetid = p_CmpToEvaluateId->objid,
                targetos = p_CmpToEvaluateId->osnum );

/*
	if( status & retcode & 1 ){ ActSymb = AttrSymb ; }
*/

	status =
	om$send(msg      = message GRvg.GRputsymb( &retcode, &ActSymb),
		senderid = NULL_OBJID,
		targetid = p_CmpToEvaluateId->objid,
		targetos = p_CmpToEvaluateId->osnum ) ;
        __DBGpr_com("Back from putsymb");
  }
#endif
  if( DisplayFlag )
  {
  	status = om$send( msg      = message NDnode.NDdisplay( 0, GRbd, p_MdEnv ),
                          senderid = NULL_OBJID,
                      	  targetid = p_CmpToEvaluateId->objid, 
                      	  targetos = p_CmpToEvaluateId->osnum);
 	as$status();
  }

__DBGpr_com("leaving VRPlaceCmpByItemName (before wrapup)");

wrapup :
  End
  return OM_S_SUCCESS;

}
end implementation Root;
