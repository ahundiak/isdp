
/* $Id: VCCmdSAi.I,v 1.3 2002/05/08 15:48:23 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdSAi.I
 *
 * Description:
 *      Implementation file for command objects that display and
 *      edit attributes.
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdSAi.I,v $
 *  Revision 1.3  2002/05/08 15:48:23  anand
 *  Files added/modified for sub-cable functionality.
 *
 *  Revision 1.2  2001/02/20 01:09:47  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.6  2000/03/24  21:10:48  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by lawaddel for route
#
# Revision 1.5  2000/03/13  17:06:20  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by lawaddel for route
#
# Revision 1.4  1999/01/20  17:07:42  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by apazhani for route
#
# Revision 1.3  1998/12/22  17:02:44  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by lawaddel for route
#
# Revision 1.2  1998/11/02  07:30:38  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by sbilla for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.6  1998/04/20  04:09:54  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by kddinov for route
#
# Revision 1.5  1998/02/18  10:13:28  pinnacle
# Replaced: vccmd/VCCmdSAi.I for: TR179702189 by aharihar for route
#
# Revision 1.4  1998/02/06  11:37:14  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by apazhani for route
#
# Revision 1.3  1997/12/10  20:57:34  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by r250_int for route
#
# Revision 1.2  1997/11/30  16:08:06  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by r250_int for route
#
# Revision 1.18  1997/11/27  16:38:58  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by onayragu for cabling
#
# Revision 1.17  1997/11/13  12:06:36  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by apazhani for cabling
#
# Revision 1.16  1997/09/11  20:50:40  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by apazhani for cabling
#
# Revision 1.15  1997/08/11  21:54:20  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.13  1997/08/05  22:52:56  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.12  1997/07/31  20:07:18  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.11  1997/07/29  15:03:36  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.10  1997/07/14  22:53:24  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.9  1997/05/22  14:44:04  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.8  1997/05/07  20:00:28  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.7  1997/01/20  22:12:24  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/09  23:03:14  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/01/09  20:00:46  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.3  1996/11/06  18:30:26  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/11  21:53:24  pinnacle
# Replaced: vccmd/VCCmdSAi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/10/03  18:28:34  pinnacle
# Created: vccmd/VCCmdSAi.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  09/11/97      Alwin   Modified method VCSAget, to implement fence locate
 *  13/11/97      Alwin   Modified method VCSAdisp, to enable the scale gadgets
 *  Nov 19 97	Onay	  Change parent of terminal implementation.
 *  Feb 06 98     Alwin   Reset the Connection of the Old Cable to the New one
 *                        when we change the Comp Code of the Cable. CR17980047
 *  Feb 16 98     Anand   Erased a set of gadgets while displaying another,
 *                        in form VCSetAtt, for TR179702189
 *  Nov 02 98     Reddy   Erased Change Parent element gadget for guides and 
 *		          Connection components . Symbol scale is inactivated 
 *			  in PID mode for cable and guide .TR179800424
 *  Nov 17 98     law     Change Parent moving terminal to origin-TR179801645
 *  Dec 02 98     law     Rotation defined by form field. - CR179802404
 *  Jan 20 99     Alwin   Modified some variables types to get rid of the 
 *			  compilation errors( CLIX machine ).
 *  Mar 13 00     law     CR179900814-backshells on guides-list cables in guides
 *  Mar 24 00     law     TR179901245-hilight cables being analyzed
 *************************************************************************/

class implementation VCCmdSA;

/*
#define	vdsDEBUG
*/

#include "nddef.h"
#include "ndmacros.h"

#include "asbox.h"
#include "VDmem.h"
#include "VCproto.h"
#include "VCCmdSet.h"
#include "VCCmdDef.h"
#include "VCTagDef.h"
#include "coparamac.h"
#include <math.h>

%safe
#include "VX_FIproto.h"
%endsafe

#include "VRMcForm.h"
#include "parametric.h"
#include "VCdefine.h"
#include "vc_define.h"
#include "vrdbgmacros.h"
#include "vc_default.h"


from  VCRoot        import  VCSetCode;
from  VCRoot        import  VCSetTagNo;
from  VCRoot        import  VCSetMtoFlag;

from  VCRoot        import  VCGetCode;
from  VCRoot        import  VCGetTagNo;
from  VCRoot        import  VCGetMtoFlag;
from  VCRoot        import  VCGetMatrix;
from  VCRoot        import  VCGetRep;
from  VCRoot        import  VCGetType;
from  VCRoot        import  VCGetProduct;
from  VCRoot        import  VCGetParams;
from  VCRoot        import  VCChgParam;
from  VCRoot        import  VCPutExpand;

from  VCRoot        import  VCGetInstance;
from  VCRoot        import  VCSetInstance;
from  VCRoot        import  VCDUMP;
from  VCRoot        import  VCParent;
from  VCRoot        import  VCBaseMat;

from  VCCable       import  VCCbInitCon;
from  VCCable       import  VCConnect;
from  VCCable       import  VCConList;
from  VCCable       import  VCGetSignal;
from  VCCable       import  VCPutSignal;
from  VCGuide       import  VCGetCptCoord;

from  VCDB          import  VCGpAnum;
from  GRgraphics import   GRdisplay; /* added for tr179901245 */

from  ACncpx        import  ACgive_structure;
from  NDnode        import  NDget_objects;
from  NDnode        import  NDconnect;
from  NDnode        import  ASreturn_go;
from  NDnode        import  NDs_compute_node;
from  NDnode        import  NDdisplay;
from  NDnode        import  NDdisconnect;

from  GRgencs       import  GRgetmatrix;
from  VRGeneric     import  VRGetMatrix;
from  VCTerm        import  VCGetEquipId;
from  VCTerm        import  VCTRealCon;

from  VCCable	    import  VCAmIParCab, VCAmISubCab;

extern	GRclassid OPP_VREquipment_class_id, OPP_VDequipment_class_id;

extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);
extern double   BSdistptpt();


/*C  Initialize my instance  */

method init ( int type ; char * str_ptr )
{
  int             status;

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VCAT.init( type, str_ptr ),
                    targetid = my_id);

  me->CmdProd       = VC_PROD_NONE;
  me->Product       = VC_PROD_NONE;

  me->MyRet          = me->ret;
  me->bTagByp        = FALSE;

  VC_INITSTR (me->CompCode);
  VC_INITSTR (me->CompTag);
  VC_INITSTR (me->CompDesc);

  me->Product        = VC_PROD_NONE;
  me->nObjType       = VC_TYPE_INIT;
  me->CmdProd        = VC_PROD_NONE;
  me->nObjRep        = 0;
  me->nTagCat        = VCTAG_CAT_GENERAL;

  me->CompId.objid   = NULL_OBJID;

  me->nFOstart       = -1;
  me->nCC            = 0;
  me->CClist         = NULL;
  me->CCdesc         = NULL;

  me->FCmain       = VC_FPOS_SA_MAIN;
  me->FCsub        = VC_FPOS_SA_SUB;
  me->FCcontrol    = -1;

  me->nSAindex      = 0;
  me->nSAmax        = 1;

  me->bSysUp        = FALSE;
  me->bUsrUp        = FALSE;

  me->bSAmoreup     = FALSE;
  me->bSAcconup     = FALSE;
  me->bSAtconup     = FALSE;

  me->pSysAtt  = me->forms[VC_FRM_MAIN].form_ptr;
  me->pUsrAtt  = me->forms[VC_FRM_SUB].form_ptr;

  me->pMORE  = me->forms[VC_FRM_MORE].form_ptr;
  me->pTCON  = me->forms[VC_FRM_TCON].form_ptr;
  me->pCCON  = me->forms[VC_FRM_CCON].form_ptr;

  /* Handle sub-cable related new instance data */
  me->bParCab = FALSE;
  om$vla_set_dimension( varray = me->BegTerm , size = 0 );
  om$vla_set_dimension( varray = me->EndTerm , size = 0 );
  om$vla_set_dimension( varray = me->szBegTag , size = 0 );
  om$vla_set_dimension( varray = me->szEndTag , size = 0 );

  return (OM_S_SUCCESS);
}

method VCSAget(IGRint     *sts)
{
  IGRint i, NumOfFenceObjs;
  struct GRobj_env  *FenceObjs;

  /*A Initialization */
  NumOfFenceObjs = 0;
  FenceObjs = NULL;
  me->LocatedObjects = 0;

  /*A get the fence contents */

  as$start_fence(set= &me->event1.located_object[0].located_obj,
                set_env = &me->event1.located_object[0].module_info,
                nb_obj = &NumOfFenceObjs,
                p_obj_env = &FenceObjs,
                response = me->response,
                response_data = me->response_data);

  /*A return error if no object is found */
  if ( !NumOfFenceObjs )
  {
//      *sts = MSFAIL; Trying with VC_RTC_ERROR
      *sts = VC_RTC_ERROR;
      return  OM_S_SUCCESS;
  }

  me->nSAindex = 0;
  me->nSAmax = 0;

  /*A transfer all the route Cmp objects to the instance data */
  if( NumOfFenceObjs )
  {
      me->LocatedObjects = _CALLOC( NumOfFenceObjs, struct GRobj_env );
      __CheckPtr( me->LocatedObjects,
		  "Could Not allocate Dynamic Memory for me->LocatedObjects",
		  wrapup );

      // Filter out all sub-cables here.
      for ( i=0; i<NumOfFenceObjs; i++ )
      {
	  IGRint	status, ObjType;

	  status = om$send( msg = message VCRoot.VCGetType( &ObjType ),
			    senderid = NULL_OBJID,
			    targetid = FenceObjs[i].obj_id.objid,
			    targetos = FenceObjs[i].obj_id.osnum );
	  if( ObjType & VC_GEN_CABLE )
	  {
	      IGRlong	msg;

	      status = om$send( msg = message VCCable.VCAmISubCab( &msg,
								   &ObjType,
								   NULL, NULL,
								   NULL ),
				senderid = NULL_OBJID,
				targetid = FenceObjs[i].obj_id.objid,
				targetos = FenceObjs[i].obj_id.osnum );

	      if( ObjType==VCC_SPLIT_BEGIN || ObjType==VCC_SPLIT_END )
	      {
		  __DBGpr_obj("Skipping subcable",FenceObjs[i].obj_id);
		  if( NumOfFenceObjs == 1 )
		      UI_status("This command does not process Sub-Cables!");
		  continue;
	      }
	  }
	  me->LocatedObjects[me->nSAmax] = FenceObjs[i];
	  ++(me->nSAmax);
      }
  }
  me->LocatedObjects = _REALLOC( me->LocatedObjects, me->nSAmax,
							    struct GRobj_env );

  me->CompId		= me->LocatedObjects[me->nSAindex].obj_id;
  me->LocatedMdEnv	= me->LocatedObjects[me->nSAindex].mod_env;

wrapup :

  ASend_fence();

  *sts = VC_RTC_ALLOK;

  if( !me->nSAmax )
     me->ret = VC_RTC_ERROR;

  return OM_S_SUCCESS;
}

method VCSAdisp(IGRint     *sts)
{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       iProd;
  IGRint       i, idsp;
  IGRboolean   bCreate;
  IGRdouble    dMTO;
  IGRchar	szClass [100];
struct GRid	ModId;
/*added for tr179901245 */
  enum   GRdpmode         Mode;
IGRlong                 msg;
IGRint ii;


  SetProc( VCSAdisp ); Begin


  bCreate = FALSE;

  *sts = VC_RTC_ALLOK;

  if (!me->bSysUp)
  {
    status =
    VC_Cmd_form_open (me->pSysAtt, VC_FPOS_SA_MAIN);
    me->bSysUp = TRUE;
  }

  FIf_reset( me->pSysAtt );

  if (me->nSAmax > 1)
  {
    __DBGpr_com( " It's a FENCE locate " );
    FIg_display ( me->pSysAtt, VCSET_GDGGRP_FENCE);
    FIg_set_value( me->pSysAtt, VCSET_GDG_FENCE_FL, me->nSAindex+1 );
/* Added for tr179901245 */
    for(ii=0; ii<me->nSAmax; ii++)
    {
      struct GRid tempid;
      tempid = me->LocatedObjects[ii].obj_id;

      Mode = GRhe;
      status =
      om$send( msg = message GRgraphics.GRdisplay( &msg,
                                        &me->ModuleInfo.md_env.matrix_type,
                                         me->ModuleInfo.md_env.matrix,
                                        &Mode, &me->ModuleInfo.md_id ),
          targetid = tempid.objid,
          targetos = tempid.osnum );
      as$status();
    }

  }
  else
    FIg_erase   ( me->pSysAtt, VCSET_GDGGRP_FENCE);

/* Added for tr179901245 */
  Mode = GRhd;
  status =
      om$send( msg = message GRgraphics.GRdisplay( &msg,
                                        &me->ModuleInfo.md_env.matrix_type,
                                         me->ModuleInfo.md_env.matrix,
                                        &Mode, &me->ModuleInfo.md_id ),
          targetid = me->CompId.objid,
          targetos = me->CompId.osnum );
  as$status();


  status =
  om$send (msg = message VCCmdSA.VCSAGetData (&retmsg, &me->CompId),
      targetid = my_id);

 
  /* added by alwin to display the Scale related gadgets if it's PID rep */

 /*** Following if condition is modified for avoiding symbolscale field
 display in the case of cable and guide . if( bVC_IS_PID( me->nObjRep ))
 condition - Before TR179800424 ----   Reddy ******/

/* Modified for CR179802404 */
  if ( bVC_IS_PID( me->nObjRep ) &&
       ((me->nObjType & VC_GEN_TERM)||(me->nObjType & VC_GEN_BKSHLL))
     )
  {
    /* If it's pid mode then we have display the two gadgets through which
    can change the scale of the object */
 
    __DBGpr_com( " It's PID component " );
    FIg_display (me->pSysAtt, VCSET_GDG_SCALE_TXT);
    FIg_display (me->pSysAtt, VCSET_GDG_SCALE_FLD);
/* CR179802404 */
    FIg_display (me->pSysAtt, VCSET_GDG_AROT_TXT);
    FIg_display (me->pSysAtt, VCSET_GDG_AROT_FLD);
 
    {
      IGRint FootIndex = -1; 
      IGRlong msg=MSSUCC;
      struct ret_struct  ParamAttr;
      /* -- Get scale factor -- */
      status=
      om$send ( msg   = message ACncpx.ACgive_structure
                    ( (IGRint*)&msg, &FootIndex, VC_N_PID_SCALE_DB,
                      &ParamAttr, &me->LocatedObjects[me->nSAindex].mod_env ),
                          targetid = me->CompId.objid,
                          targetos = me->CompId.osnum );
 
      if( !( status & msg & OM_S_SUCCESS ) )
        ParamAttr.var.root_pm_st.value = 1.0;
 
      /*Setting the Scale Factor in the Gadget */
      FIg_set_value( me->pSysAtt, VCSET_GDG_SCALE_FLD,
                     ParamAttr.var.root_pm_st.value );
      __DBGpr_dbl( "Scale Factor ", ParamAttr.var.root_pm_st.value );
      /* rotation angle added for CR179802404 */
      {
         IGRdouble dMyMat[16],dParMat[16];
         IGRint status;
         IGRdouble ang, ang2;
         struct GRid Par_Id;
         FIg_display ( me->pSysAtt, VCSET_GDG_AROT_FLD);
         FIg_display ( me->pSysAtt, VCSET_GDG_AROT_TXT);
         status = om$send ( msg = message VCRoot.VCGetMatrix
                    ( &msg, -1, dMyMat,
                                   &me->LocatedObjects[me->nSAindex].mod_env),
		  senderid = NULL_OBJID,
                  targetid = me->CompId.objid,
                  targetos = me->CompId.osnum);
         __DBGpr_mat("matrix for form angle",dMyMat);

         status = VCgetangfrmmat(dMyMat, &ang);

         Par_Id.objid = NULL_OBJID;
         __DBGpr_com("Getting parent angle");
         if (me->nObjType & VC_GEN_TERM)
         {
            status = om$send ( msg = message VCRoot.VCParent( &msg, 0, 
                           &Par_Id, &me->LocatedObjects[me->nSAindex].mod_env),
			targetid = me->CompId.objid,
			targetos = me->CompId.osnum);

            __DBGpr_com("For terminals parent, got matrix");
            /* Get parent objid-NOTE that this will not work for backshell */
/*
            status=
               om$send ( msg   = message VCTerm.VCGetEquipId (&msg,&Par_Id), 
			targetid = me->CompId.objid,
			targetos = me->CompId.osnum);
*/
         }
         else if (me->nObjType & VC_GEN_BKSHLL)
         {
            /* Get parent of connector objid */
            status=
               om$send ( msg   = message VCTerm.VCTRealCon (&msg,&Par_Id,
                                  &me->LocatedObjects[me->nSAindex].mod_env),
                        targetid = me->CompId.objid,
                        targetos = me->CompId.osnum);

            __DBGpr_com("For backshells parent, got matrix");
            status = om$send ( msg = message VCRoot.VCParent( &msg, 0, 
                           &Par_Id, &me->LocatedObjects[me->nSAindex].mod_env),
			targetid = me->CompId.objid,
			targetos = me->CompId.osnum);

         }
         __DBGpr_obj("Par_Id ",Par_Id);
         if(status == OM_S_SUCCESS &&
           (me->CompId.objid != Par_Id.objid) &&
           (Par_Id.objid != NULL_OBJID))
         {
            IGRint nCP=1;
            __DBGpr_obj("Parent is",Par_Id);
/*  Removed by CR179802404
            status = om$send ( msg = message VCRoot.VCGetMatrix
                    ( &msg, -1, dParMat,
                                   &me->LocatedObjects[me->nSAindex].mod_env),
                  senderid = NULL_OBJID,
                  targetid = Par_Id.objid,
                  targetos = Par_Id.osnum);
*/

        status = om$send( msg      = message VCRoot.VCBaseMat
                                            (&msg, nCP, dParMat, 
                                   &me->LocatedObjects[me->nSAindex].mod_env),
                  senderid = NULL_OBJID,
                  targetid = me->CompId.objid,
                  targetos = me->CompId.osnum);

            __DBGpr_mat("matrix for Parent",dParMat);
           status = VCgetangfrmmat(dParMat, &ang2);
            __DBGpr_dbl("Parent angle is",ang2);

            ang = ang - ang2;
         }

         FIg_set_value( me->pSysAtt, VCSET_GDG_AROT_FLD, ang);
         __DBGpr_dbl( "rotational angle ", ang );

      }
    }
  }
  else
  {
    __DBGpr_com( " Either It's not PID rep or has no scale" );
    FIg_erase (me->pSysAtt, VCSET_GDG_SCALE_TXT);
    FIg_erase (me->pSysAtt, VCSET_GDG_SCALE_FLD);
/* CR179802404 */
    FIg_erase (me->pSysAtt, VCSET_GDG_AROT_TXT);
    FIg_erase (me->pSysAtt, VCSET_GDG_AROT_FLD);
  }
  /* added by alwin to display the Scale related gadgets if it's PID rep */

  me->bTagByp        = FALSE;
  me->nTagCat        = VCTAG_CAT_GENERAL;

  if (me->nObjType & VC_GEN_TERM)
  {  /*  make sure we've got the virtual    */
    status =
    VCT_virtualize (&retmsg, bCreate, &me->CompId, &me->ModuleInfo,
                                      &me->CompId, &me->ModuleInfo);

    FIg_display ( me->pSysAtt, VCSET_GDGGRP_TERM);
    FIg_erase   ( me->pSysAtt, VCSET_GDGGRP_CABLE);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_HDBKSH);

/* 4-98 KDD use single point default selection function
*    if (me->Product == VC_PROD_ELEC)
*      me->nTagCat    = VCTAG_CAT_ELTERM;
*    else
*      me->nTagCat    = VCTAG_CAT_FOTERM;
*/
    status = 
	VCGetDefaultInfo( me->Product, VC_GET_TERM_TAG, (char *)&me->nTagCat);

  }
  else
  if (me->nObjType & VC_GEN_CABLE)
  {
    FIg_display ( me->pSysAtt, VCSET_GDGGRP_CABLE);
    FIg_erase   ( me->pSysAtt, VCSET_GDGGRP_TERM);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_CABA_VCBTN);

/* 4-98 KDD use single point default selection function
*    if (me->Product == VC_PROD_ELEC)
*      me->nTagCat    = VCTAG_CAT_ELCABLE;
*    else
*      me->nTagCat    = VCTAG_CAT_FOCABLE;
*/
    status =
        VCGetDefaultInfo( me->Product, VC_GET_CAB_TAG, (char *)&me->nTagCat);

  }
  else
  if (me->nObjType & VC_GEN_GUIDE) /** Modified for cr179900814 **/
  {
    GRclassid          parentClassId;
    IGRchar         c200ClassName[200];
    IGRshort CpNum;
    struct GRid *p_Children;
    IGRint NbChildren,NbUnitAconn,NbUnitBconn,NbCables, tmprow;
    IGRlong     retmsg;
    IGRint GDCBHor, GDUAHor, GDUBHor, Ndx;
    IGRint GDCBVer, GDUAVer, GDUBVer;
    IGRdouble dCptCoor0[3],dCptCoor1[3], dP0, dP1, tcoord[3];

    FIg_display ( me->pSysAtt, VCSET_GDGGRP_TERM);
    FIg_erase   ( me->pSysAtt, VCSET_GDGGRP_CABLE);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_HDTERM);
    FIg_display ( me->pSysAtt, VCSET_GDG_HDGUIDE);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_VCBTN);

    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_EQTYP);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_EQTAG);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_CMPAR);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_BKSH);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_EQTYP);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_EQTAG);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_CMPAR);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_BKSH);
    
    /** ADDED for TR179800424  ****/
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_CPBTN);
    /*Added for CR179900814 */
    status =
        om$send( msg      = message NDnode.NDget_objects
                ( ND_CHILDREN | ND_IN_BUF, NULL, 0, &p_Children, 0,
                  OM_K_MAXINT, &NbChildren ),

                  senderid = NULL_OBJID,
                  targetid = me->CompId.objid,
                  targetos = me->CompId.osnum);
    /* Count the number of cable and connector children */
    CpNum = 0;
    status =   om$send ( msg = message VCGuide.VCGetCptCoord( &retmsg,
                        CpNum,dCptCoor0,&me->ModuleInfo  ),
                                senderid = NULL_OBJID,
                                targetid = me->CompId.objid,
                                targetos = me->CompId.osnum );
    CpNum = 1;
    status =   om$send ( msg = message VCGuide.VCGetCptCoord( &retmsg,
                        CpNum,dCptCoor1,&me->ModuleInfo  ),
                                senderid = NULL_OBJID,
                                targetid = me->CompId.objid,
                                targetos = me->CompId.osnum );

    NbUnitAconn = 0;
    NbUnitBconn = 0;
    NbCables    = 0;
    GDCBHor = FALSE;
    GDUAHor = FALSE;
    GDUBHor = FALSE;
    FIg_erase   ( me->pSysAtt, VCSET_GDG_GDUA_TXT);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_GDUA_FLD);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_GDUB_TXT);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_GDUB_FLD);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_GDCB_TXT);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_GDCB_FLD);

    for(Ndx = 0; Ndx < NbChildren; Ndx++)
    {
      om$get_classname (objid = p_Children[Ndx].objid,
                        osnum = p_Children[Ndx].osnum,
                    classname = c200ClassName);
      if(!strcmp(c200ClassName,"VCElCable") || !strcmp(c200ClassName,"VCFoCable"))
      {
           IGRchar loctagid[VC_MAX_TAGNO];
           tmprow = NbCables;
           NbCables++ ;
           status = om$send ( msg = message VCRoot.VCGetTagNo( loctagid ),
                            targetid = p_Children[Ndx].objid,
                            targetos = p_Children[Ndx].osnum );
           if(tmprow == 0)
           {
             FIg_display  (me->pSysAtt, VCSET_GDG_GDCB_TXT);
             FIg_display  (me->pSysAtt, VCSET_GDG_GDCB_FLD);
             FIg_set_text (me->pSysAtt,VCSET_GDG_GDCB_FLD, loctagid);
           }
           FIfld_set_list_num_rows( me->pSysAtt, VCSET_GDG_GDCB_FLD,
                             0, NbCables);
           FIfld_set_list_text ( me->pSysAtt, VCSET_GDG_GDCB_FLD, tmprow,0,
                             (unsigned char *)loctagid, FALSE);
           if(strlen(loctagid) > 20) GDCBHor = TRUE;
      }

      else if (!strcmp(c200ClassName,"VCBksh"))
      {
        IGRchar loccompcd[VC_MAX_CCODE];
        IGRdouble dRefMatrix[16];
        BSrc  rc;
        IGRint lMsg;
        IGRint FootIndex = -1;
        struct ret_struct  ParamAttr;
        ParamAttr.var.root_pm_st.value = 0.0;
        status=
          om$send ( msg   = message ACncpx.ACgive_structure
                    ( &lMsg, &FootIndex, VC_N_REF_CS,
                      &ParamAttr, &me->ModuleInfo ),
                          targetid = p_Children[Ndx].objid,
                          targetos = p_Children[Ndx].osnum );

        tcoord[0] = ParamAttr.var.ref_st.t[3];
        tcoord[1] = ParamAttr.var.ref_st.t[7];
        tcoord[2] = ParamAttr.var.ref_st.t[11];

        dP0 = BSdistptpt (&rc, tcoord, dCptCoor0);
        dP1 = BSdistptpt (&rc, tcoord, dCptCoor1);
        status = om$send ( msg = message VCRoot.VCGetCode( loccompcd ),
                            targetid = p_Children[Ndx].objid,
                            targetos = p_Children[Ndx].osnum );
        if(dP0 < dP1)
        {
            tmprow =  NbUnitAconn;
            NbUnitAconn++;
            if(tmprow == 0)
             {
              FIg_display  (me->pSysAtt, VCSET_GDG_GDUA_TXT);
              FIg_display  (me->pSysAtt, VCSET_GDG_GDUA_FLD);
              FIg_set_text (me->pSysAtt,VCSET_GDG_GDUA_FLD, loccompcd);
             }
            FIfld_set_list_num_rows( me->pSysAtt, VCSET_GDG_GDUA_FLD,
                             0, (IGRint) NbUnitAconn);
            FIfld_set_list_text ( me->pSysAtt, VCSET_GDG_GDUA_FLD, tmprow,0,
                             (unsigned char *)loccompcd, FALSE);
            if(strlen(loccompcd) > 20) GDUAHor = TRUE;
        }
        else
        {
            tmprow =  NbUnitBconn;
            NbUnitBconn++;
            if(tmprow == 0)
            {
              FIg_display  (me->pSysAtt, VCSET_GDG_GDUB_TXT);
              FIg_display  (me->pSysAtt, VCSET_GDG_GDUB_FLD);
              FIg_set_text (me->pSysAtt,VCSET_GDG_GDUB_FLD, loccompcd);
            }
            FIfld_set_list_num_rows( me->pSysAtt, VCSET_GDG_GDUB_FLD,
                             0, (IGRint) NbUnitBconn);
            FIfld_set_list_text ( me->pSysAtt, VCSET_GDG_GDUB_FLD, tmprow,0,
                             (unsigned char *)loccompcd, FALSE);
            if(strlen(loccompcd) > 20) GDUBHor = TRUE;
        }
      }
   }
   GDCBVer = FALSE;
   GDUAVer = FALSE;
   GDUBVer = FALSE;
   if(NbUnitAconn > 3) GDUAVer = TRUE;
   if(NbUnitBconn > 3) GDUBVer = TRUE;
   if(NbCables > 7) GDCBVer = TRUE;
   if(NbUnitAconn == 0)FIg_set_text (me->pSysAtt,VCSET_GDG_GDUA_FLD," ");
   if(NbUnitBconn == 0)FIg_set_text (me->pSysAtt,VCSET_GDG_GDUB_FLD," ");
   if(NbCables == 0)FIg_set_text (me->pSysAtt,VCSET_GDG_GDCB_FLD," ");
   FIfld_set_list_scroll(me->pSysAtt,VCSET_GDG_GDUA_FLD,GDUAVer,GDUAHor);
   FIfld_set_list_scroll(me->pSysAtt,VCSET_GDG_GDUB_FLD,GDUBVer,GDUBHor);
   FIfld_set_list_scroll(me->pSysAtt,VCSET_GDG_GDCB_FLD,GDCBVer,GDCBHor);
  } /* End add cr179900814 */
  else
  if (me->nObjType & VC_GEN_BKSHLL)
  {
    /* Modified for CR179900814 - bkshell on guides */
    struct GRid ParentList[10];
    IGRint NbParent, MaxParent, ii, ifound;
    IGRchar szClass[100];
    me->bTagByp        = TRUE;

    FIg_display ( me->pSysAtt, VCSET_GDGGRP_TERM);

    FIg_erase   ( me->pSysAtt, VCSET_GDGGRP_CABLE);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_HDTERM);
    FIg_display ( me->pSysAtt, VCSET_GDG_HDBKSH);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_VCBTN);

    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_BKSH);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_BKSH);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TAG_TXT);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TAGNO);

/* Added the following lines for TR179702189 - Anand */
/* Modified for CR179900814 */
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_EQTYP);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_EQTAG);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_CMPAR);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TTXT_BKSH);

    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_EQTYP);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_EQTAG);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_CMPAR);
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_BKSH );


    /* The following gagdet labels were added ( Ref VCCmdSet.h ) - Anand */
    /* Modified for cr179900814 */
    FIg_display ( me->pSysAtt, VCSET_GDG_TTXT_CABA_TRTYP);
    FIg_display ( me->pSysAtt, VCSET_GDG_TTXT_CABA_TRTAG);

    /************  ADDED for TR179800424 ****/
    FIg_erase   ( me->pSysAtt, VCSET_GDG_TERM_CPBTN);
    /* Added for CR179900814 - bkshell on guides */
    /*** Get the parent list ***/
    MaxParent = 10;
    status = om$send (msg = message NDnode.NDget_objects (
                                ND_ROOT, ParentList, MaxParent, NULL,
                                0, OM_K_MAXINT, &NbParent ),
                  senderid = NULL_OBJID,
                  targetos = me->CompId.osnum,
                  targetid = me->CompId.objid );
    /*** If any of the parents are a guide ***/
    ifound = FALSE;
    for (ii=0; ii<NbParent; ii++)
    {
       status = om$get_classname ( osnum           = ParentList [ii].osnum,
                                objid           = ParentList [ii].objid,
                                classname       = szClass );

       if(!strcmp(szClass,"VCGuide"))
       {
          ifound = TRUE;
       }
    }
    if(ifound)
    {
       FIg_erase ( me->pSysAtt, VCSET_GDG_TTXT_CABA_EQTYP);
       FIg_erase ( me->pSysAtt, VCSET_GDG_TTXT_CABA_EQTAG);
       FIg_erase ( me->pSysAtt, VCSET_GDG_CABA_EQTYP);
       FIg_erase ( me->pSysAtt, VCSET_GDG_CABA_EQTAG);
       FIg_erase ( me->pSysAtt, VCSET_GDG_TTXT_CABA_TRTYP);
       FIg_erase ( me->pSysAtt, VCSET_GDG_TTXT_CABA_TRTAG);
       FIg_display ( me->pSysAtt, VCSET_GDG_CABA_TRTYP);
       FIg_display ( me->pSysAtt, VCSET_GDG_CABA_TRTAG);
       FIg_display ( me->pSysAtt, VCSET_GDG_TTXT_GTYP);
       FIg_display ( me->pSysAtt, VCSET_GDG_TTXT_GTAG);
    }
    else
    {
       FIg_erase ( me->pSysAtt, VCSET_GDG_TTXT_GTYP);
       FIg_erase ( me->pSysAtt, VCSET_GDG_TTXT_GTAG);
       FIg_display ( me->pSysAtt, VCSET_GDG_TTXT_CABA_EQTYP);
       FIg_display ( me->pSysAtt, VCSET_GDG_TTXT_CABA_EQTAG);
       FIg_display ( me->pSysAtt, VCSET_GDG_CABA_TRTYP);
       FIg_display ( me->pSysAtt, VCSET_GDG_CABA_TRTAG);
    }
  } /* End add for cr179900814 */

  iProd = me->CmdProd;
  
  me->CmdProd = me->Product;

  status =
  om$send (msg = message VCCmdSA.VCSAlist (&retmsg),
      targetid = my_id );

  me->CmdProd = iProd;

  /* Check if located obj is parent-cable. If so handle below form calls
   * to VCSET_GDG_CCODE field appropriately. */

  if( me->bParCab == FALSE )
  {
      FIfld_set_list_num_rows( me->pSysAtt, VCSET_GDG_CCODE,
			       0, (IGRint) me->nCC);

      if(me->nCC < 5)
	  FIfld_set_list_scroll( me->pSysAtt, VCSET_GDG_CCODE, 0, 0 );
      else
	  FIfld_set_list_scroll( me->pSysAtt, VCSET_GDG_CCODE, 1, 0 );

      for (i=0;i<me->nCC; i++)
	  FIfld_set_list_text( me->pSysAtt, VCSET_GDG_CCODE, i, 0, 
			       (unsigned char *)&me->CClist[i*VC_MAX_CCODE],
			       FALSE );

      FIg_enable( me->pSysAtt, VCSET_GDG_CCODE );
  }
  else
      FIg_disable( me->pSysAtt, VCSET_GDG_CCODE );

  for (i=0;i<me->nCC; i++)
  {
    idsp = i * VC_MAX_SDESC;

    if (strcmp (me->CompCode, &me->CClist[i*VC_MAX_CCODE]) == 0)
    {
      strcpy (me->CompDesc, &me->CCdesc[idsp]);
      break;
    }
  }

  me->bCCch = me->bTGch = FALSE;

  FIg_set_text ( me->pSysAtt, VCSET_GDG_CCODE, me->CompCode );

  FIg_set_text ( me->pSysAtt, VCSET_GDG_DESC , me->CompDesc );

  FIg_set_text ( me->pSysAtt, VCSET_GDG_TAGNO, me->CompTag );

  dMTO = me->bMTO;

  FIg_set_value (me->pSysAtt, VCSET_GDG_MTO, dMTO);
  
/************************************************************************/
/* Added by Onay to avoid change parent if from reference file		*/
/************************************************************************/
ex$get_cur_mod ( id = &ModId.objid, osnum = &ModId.osnum );
*szClass	= 0;
status = om$get_classname (	osnum		= me->CompId.osnum,
				objid		= me->CompId.objid,
				classname	= szClass );
if (om$is_ancestry_valid (	subclassname	= szClass,
				superclassname	= "ASsourcein" ) ==
						OM_S_SUCCESS ||
			  me->CompId.osnum != ModId.osnum )
  {
  FIg_disable (me->pSysAtt, VCSET_GDG_TERM_CPBTN);
  }
else
  {
  FIg_enable (me->pSysAtt, VCSET_GDG_TERM_CPBTN);
  }

status =
  om$send (msg = message VCCmdSA.VCSALoadLnAttr
                        (me->pSysAtt, &me->CompId),
      targetid = my_id );

  End
  return (OM_S_SUCCESS);
}

method VCSAref(int *sts)
{
  int               status;
  struct GRid       locId;

  me->ret = VC_RTC_ALLOK;
  status  = OM_S_SUCCESS;

  /*A ----- Get located object ----- */
  locId = me->event1.located_object[0].located_obj;

  status =
  om$send(msg = message VCCmdSA.VCSALoadLnAttr (me->pSysAtt, &locId),
     targetid = my_id );
  as$status();

  FIg_set_state_off (me->pSysAtt, VCSET_GDG_COPYBTN);

  return (OM_S_SUCCESS);
}

method VCSARetCode(int *sts)
{

  *sts = me->MyRet;

  me->ret = me->MyRet;

  return (OM_S_SUCCESS);
}

method VCSAsave()
{
  IGRint     status;
  IGRlong    retmsg;
  IGRint     cn_type;
  struct GRid   Sys,Usr;

  /* added for CR179800047 */
  IGRshort nPos0=0, nPos1=0, i;
  struct VCpos *cab=NULL, *trm=NULL;
  struct VCpos *cab1=NULL, *trm1=NULL;
  IGRchar  **szSignal0=NULL, **szSignal1=NULL;
 
  SetProc( Md VCSAsave ); Begin

  cn_type      = ND_COMP;
  if (me->bTGch)
  { /*  includes tagnumber reference   */
    status =
    om$send (msg = message VCRoot.VCSetTagNo (me->CompTag),
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);
  }

  if (me->bCCch)
  { /*   need disconnect and re-calc ??   */
    status =
    om$send (msg = message VCRoot.VCSetCode (me->CompCode),
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);

    if (me->nObjType & VC_GEN_CABLE)
    {  /*   disconnect and regenerate connectivity   */
      IGRboolean    bDisc;

      bDisc = TRUE;

      /* Before intializing the Cable Leads obtain the Connectivity information.
      When you change the Cable Code, we ensure that the connection existing
      between Cable and Terminal be intact. For this first we'll obtain the
      Connection details and later this will be set to the New Cable.
      added by alwin for CR179800047 */
 
      /*******************Get Details of Cable End 0 *************************/
      /* First get the No. of Cable Leads connected to the Terminal Pins */
      status =
      om$send ( msg = message VCCable.VCConList
                        ( &retmsg, 0, VC_CBE_CONNECTED,
                        &nPos0, NULL, NULL, NULL, NULL ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum );
 
      /* From the Nb. of Cables Leads connected to the Terminal Pins allocate
      memory so that we can Obtain that information and set it back to the
      new cable. Alwin */
 
      __DBGpr_int( " Nb. of Leads Connected to Terminal0 ", nPos0 );
      if ( nPos0 )
      {
        cab       = _MALLOC( nPos0, struct   VCpos);
        trm       = _MALLOC( nPos0, struct   VCpos);
        szSignal0 = _MALLOC( nPos0, IGRchar * );
 
        if( !cab || !trm || !szSignal0 )
        {
           __DBGpr_com( " Memory Allocation Error :(- " );
           End
           return( OM_E_NODYNMEM );
        }
        status =
        om$send ( msg = message VCCable.VCConList
                        ( &retmsg, 0, VC_CBE_CONNECTED,
                        &nPos0, cab, trm, NULL, NULL ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum );
 
        for( i=0; i<nPos0;  i++ )
        {
            __DBGpr_int( " Cable Cpt ",         cab[i].Conn.Cable.nCpt );
            __DBGpr_str( " Cable Lead ",        cab[i].Conn.Cable.szLeadId );
            __DBGpr_str( " Term. Position ",    trm[i].Conn.Term.szPosId );
            __DBGpr_str( " Term. Module ",      trm[i].Conn.Term.szModId );
 
            szSignal0[i]  = _MALLOC( VC_MAX_SIG_ID, IGRchar );
            if( !szSignal0[i] )
            {
               __DBGpr_com( " Memory Allocation Error !!! " );
               End
               return( OM_E_NODYNMEM );
            }
 
            __DBGpr_com( " Get the Signal Name " );
            szSignal0[i][0] = '\0';
            status =
            om$send ( msg = message VCCable.VCGetSignal
                                ( &retmsg, &cab[i], szSignal0[i] ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum );
            __DBGpr_str( " Signal Name ", szSignal0[i] );
        }
      }
 
      /*******************Get Details of Cable End 0 *************************/
 
      /* First get the No. of Cable Leads connected to the Terminal Pins */
      status =
      om$send ( msg = message VCCable.VCConList
                        ( &retmsg, 1, VC_CBE_CONNECTED,
                        &nPos1, NULL, NULL, NULL, NULL ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum );
 
      /* From the Nb. of Cables Leads connected to the Terminal Pins allocate
      memory so that we can Obtain that information and set it back to the
      new cable. Alwin */
 
      __DBGpr_int( " Nb. of Leads Connected to Terminal1 ", nPos1 );
      if ( nPos1 )
      {
        cab1       = _MALLOC( nPos1, struct   VCpos);
        trm1       = _MALLOC( nPos1, struct   VCpos);
        szSignal1  = _MALLOC( nPos1, IGRchar * );
 
        if( !cab1 || !trm1 || !szSignal1 )
        {
           __DBGpr_com( " Memory Allocation Error !!! " );
           End
           return( OM_E_NODYNMEM );
        }
 
        status =
        om$send ( msg = message VCCable.VCConList
                        ( &retmsg, 1, VC_CBE_CONNECTED,
                        &nPos1, cab1, trm1,  NULL, NULL ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum );
 
        __DBGpr_int( " Nb of Leads connected to Terminal Pins ", nPos1 );
        for( i=0; i<nPos1;  i++ )
        {
            __DBGpr_int( " Cable Cpt ",         cab1[i].Conn.Cable.nCpt );
            __DBGpr_str( " Cable Lead ",        cab1[i].Conn.Cable.szLeadId );
            __DBGpr_str( " Term. Position ",    trm1[i].Conn.Term.szPosId );
            __DBGpr_str( " Term. Module ",      trm1[i].Conn.Term.szModId );
 
            szSignal1[i]  = _MALLOC( VC_MAX_SIG_ID, IGRchar );
            if( !szSignal1[i] )
            {
               __DBGpr_com( " Memory Allocation Error !!! " );
               End
               return( OM_E_NODYNMEM );
            }
 
            __DBGpr_com( " Get the Signale Name " );
            szSignal1[i][0] = '\0';
            status =
            om$send ( msg = message VCCable.VCGetSignal
                                ( &retmsg, &cab1[i], szSignal1[i] ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum );
            __DBGpr_str( " Signal Name ", szSignal1[i] );
        }
      }
      /* added by alwin */

      status =
      om$send (msg = message VCCable.VCCbInitCon (&retmsg, bDisc),
          targetid = me->CompId.objid,
          targetos = me->CompId.osnum);
    }

  }

  status =
  om$send (msg = message VCRoot.VCSetMtoFlag (me->bMTO),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);

  status =
  om$send (msg = message VCAT.VCAT_sav (&retmsg),
      targetid = my_id);

  status =
  om$send (msg = message VCAT.VCAT_coll (&retmsg, &Sys, &Usr),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" set collections <%d %d> <%d %d>\n",Sys.objid,Sys.osnum,
                         Usr.objid, Usr.osnum);
#endif

  if (me->nObjType & VC_GEN_CABLE)
  {
    IGRshort     noret;

    struct VCEXpan   ExRec;

    ExRec.type = VCEX_DBL;
    ExRec.AT.EXd = me->dTail;
    status =
    om$send (msg = message VCRoot.VCPutExpand
                              (&retmsg, (IGRshort) VC_EXIN_TAIL,
                                &noret, &ExRec),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);

    ExRec.AT.EXd = me->dEstim;

    status =
    om$send (msg = message VCRoot.VCPutExpand
                              (&retmsg, (IGRshort) VC_EXIN_ESTIM,
                                &noret, &ExRec),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);
  }

  status =
  om$send (msg = message VCRoot.VCChgParam
                         (&retmsg, (IGRshort) VC_SYSTEM, &Sys),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);

#ifdef MY_DEBUG
  printf (" sys set <%d %d>\n",Sys.objid,Sys.osnum);
#endif

  status =
  om$send (msg = message VCRoot.VCChgParam
                         (&retmsg, (IGRshort) VC_USER, &Usr),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum);

  nd$wait_batch (type   = GR_GEOM_POSTED,
             l_object   = &me->CompId,
             l_obj_info = &cn_type,
             nb_obj     = 1);

  /* Resetting the Connection details obtained from Old Cable to the New Cable,
  added by alwin for CR179800047 */
 
  if( ( me->bCCch ) && ( me->nObjType & VC_GEN_CABLE ) )
  {
    struct GRid temp;
 
    if( nPos0 )
    {
        status =
        om$send ( msg = message VCCable.VCConnect
                        ( &retmsg, nPos0, cab, trm, &temp ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum);
 
        for( i=0;  i<nPos0; i++ )
        {
            status =
            om$send ( msg = message VCCable.VCPutSignal
                        ( &retmsg, &cab[i], szSignal0[i] ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum);
 
            _FREE( szSignal0[i] );
        }
 
        _FREE( cab );
        _FREE( trm );
        _FREE( szSignal0 );
    }

    if( nPos1 )
    {
        status =
        om$send ( msg = message VCCable.VCConnect
                        ( &retmsg, nPos1, cab1, trm1, &temp ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum);
 
        for( i=0;  i<nPos1; i++ )
        {
            status =
            om$send ( msg = message VCCable.VCPutSignal
                        ( &retmsg, &cab1[i], szSignal1[i] ),
                targetid = me->CompId.objid,
                targetos = me->CompId.osnum);
 
            _FREE( szSignal1[i] );
        }
 
        _FREE( cab1 );
        _FREE( trm1 );
        _FREE( szSignal1 );
    }
  }
  /* added by alwin */

#ifdef MY_DEBUG
  printf (" usr set <%d %d>\n",Usr.objid,Usr.osnum);
#endif
  End
  return (OM_S_SUCCESS);
}

method VCSACleanup()
{
  int          status;
  IGRlong      retmsg;

  dp$erase_hilite (msg = &retmsg);

  if (me->bSysUp)
    status = VC_Cmd_form_close (me->pSysAtt, me->FCmain);

  if (me->bUsrUp)
    status = VC_Cmd_form_close (me->pUsrAtt, me->FCsub);

  if (me->bSAmoreup)
    status = VC_Cmd_form_close (me->pMORE, VC_FPOS_SA_MORE);

  if (me->bSAcconup)
    status = VC_Cmd_form_close (me->pCCON, VC_FPOS_SA_CCON);

  if (me->bSAtconup)
    status = VC_Cmd_form_close (me->pTCON, VC_FPOS_SA_TCON);

  _FREE (me->CClist);
  _FREE (me->CCdesc);
  _FREE (me->LocatedObjects); /*Free the memory allocated for fence operation */

  om$vla_set_dimension( varray = me->BegTerm , size = 0 );
  om$vla_set_dimension( varray = me->EndTerm , size = 0 );
  om$vla_set_dimension( varray = me->szBegTag , size = 0 );
  om$vla_set_dimension( varray = me->szEndTag , size = 0 );

  status =
  om$send (msg = message VCAT.delete (0) ,
          mode = OM_e_wrt_message,
      targetid = my_id);

  return (OM_S_SUCCESS);
}

/************************************************************************/
/* Method to get new parent of terminal and switch.			*/
/* Try to retrieve potential parent of located terminal. If one found	*/
/* it will be disconnected. If none found, it's a terminal without	*/
/* parent. Then check new parent and create a source object before	*/
/* connecting it.							*/
/* Parent can be GRgencs (thru ASsource), VDequipment, VREquipment or	*/
/* or nothing.								*/
/* New parent has to be either GRgencs, VDequipment or VREquipment.	*/
/* If it is a GRgencs, an ASsource is retrieve or constructed.		*/
/************************************************************************/

method VCSAProcessParent (IGRint     *sts)
{
IGRint			One, NbParent, MaxParent, ii, bFound;
IGRint			MyStatus;
IGRint			NbNewParent, Type, NotType, Info, NewType;
IGRlong			lMsg;
struct GRid		OldSourceId, OldGoId, NewSourceId, NewGoId;
struct GRid		ParentList [10], TermId, TmpId, ModId;
IGRchar			szClass [100], szParentClass [100];
struct VCGenInfo	Instance;
/* Matrix - 16 - Modified for TR179801645 */
IGRdouble		dOffset [16], dEltOrg [16], dNewOrg [3], dOldOrg [3];
IGRdouble		dOldMat [16], dNewMat [16];
struct GRmd_env		MdEnv;
GRclassid		ClassId;

/*** Added for CR179802404 ***/
IGRdouble		oldparang,newparang,newtermang,oldtermang;
IGRdouble		oldparscl,newparscl;

*sts			= VC_RTC_ALLOK;
me->ret			= VC_RTC_ALLOK;
NewType			= 0;
One			= 1;
MaxParent		= 10;
NbParent		= 0;
*szClass		= 0;
bFound			= FALSE;
OldGoId.objid		= NULL_OBJID;
OldSourceId.objid	= NULL_OBJID;
/* dEltOrg [0]		= dEltOrg [1] = dEltOrg [2] = 0.0; */
dOldOrg [0]		= dOldOrg [1] = dOldOrg [2] = 0.0;
dNewOrg [0]		= dNewOrg [1] = dNewOrg [2] = 0.0;
oldparscl = 1.0;
newparscl = 1.0;
oldparang = 0.0;
newparang = 0.0;
oldtermang = 0.0;
newtermang = 0.0;
/* dOffset 4x4 - tr179801645 */
/*
dOffset [3]		=
dOffset [7]		=
dOffset [11]		= -100000000000000.0;
*/

__DBGpr_com ("Entering VCSAProcessParent");

TermId	= me->CompId;
NewGoId = me->event1.located_object[0].located_obj;
MdEnv	= me->event1.located_object[0].module_info;

ex$get_cur_mod ( id = &ModId.objid, osnum = &ModId.osnum );

/************************************************************************/
/* First check new parent is not an equipment in a reference file	*/
/************************************************************************/
MyStatus = om$get_classid (	osnum		= NewGoId.osnum,
				objid		= NewGoId.objid,
				p_classid	= &ClassId );
if (om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VREquipment_class_id)
						== OM_S_SUCCESS ||
    om$is_ancestry_valid (	subclassid	= ClassId,
				superclassid	= OPP_VDequipment_class_id)
						== OM_S_SUCCESS )
  {
  if (NewGoId.osnum != ModId.osnum)
    {
    me->ret	= VC_RTC_ERROR;
    goto wrapup;
    }
  }

Instance.Attr.Term.dOffVal	= dEltOrg; /* TR179801645 */

/*
MyStatus = om$send (msg = message VCRoot.VCDUMP ( &lMsg ),
		  senderid = NULL_OBJID,
		  targetos = TermId.osnum,
		  targetid = TermId.objid );
*/

MyStatus = om$send (msg = message VCRoot.VCGetInstance ( &lMsg, &Instance ),
		  senderid = NULL_OBJID,
		  targetos = TermId.osnum,
		  targetid = TermId.objid );

__DBGpr_obj ("Need to connect Terminal ", TermId);
__DBGpr_obj ("To graphic object ", NewGoId);

NotType	= 0;
Type	= Instance.nType;
if (Type & VC_TERM_CS)
  NotType	= ~VC_TERM_CS;
if (Type & VC_TERM_NO)
  NotType	= ~VC_TERM_NO;
if (Type & VC_TERM_EQ)
  NotType	= ~VC_TERM_EQ;
if (Type & VC_TERM_RE)
  NotType	= ~VC_TERM_RE;

/************************************************************************/
/* Let's try to guess previous parent if any				*/
/************************************************************************/
MyStatus = om$send (msg = message NDnode.NDget_objects (
				ND_ROOT, ParentList, MaxParent, NULL,
				0, OM_K_MAXINT, &NbParent ),
		  senderid = NULL_OBJID,
		  targetos = TermId.osnum,
		  targetid = TermId.objid );

for (ii=0;ii<NbParent;ii++)
  {
  *szClass	= 0;
  MyStatus = om$get_classname (	osnum		= ParentList [ii].osnum,
				objid		= ParentList [ii].objid,
				classname	= szClass );

  if (om$is_ancestry_valid (	subclassname	= szClass,
				superclassname	= "ASsource" ) ==
						OM_S_SUCCESS )
    {
    /********************************************************************/
    /* Check for any potential parent such as coord. sys. or Equipment	*/
    /********************************************************************/
    NbNewParent	= 0;
    MyStatus = om$send (msg = message NDnode.ASreturn_go (
				&OldGoId, NULL, NULL ),
		  senderid = NULL_OBJID,
		  targetos = ParentList [ii].osnum,
		  targetid = ParentList [ii].objid );
    *szParentClass	= 0;
    MyStatus = om$get_classname (	osnum		= OldGoId.osnum,
				objid		= OldGoId.objid,
				classname	= szParentClass );
    if (om$is_ancestry_valid (	subclassname	= szParentClass,
				superclassname	= "GRgencs" ) ==
						OM_S_SUCCESS )
      {
      bFound	= TRUE;
      OldSourceId.osnum	= ParentList [ii].osnum;
      OldSourceId.objid	= ParentList [ii].objid;
      MyStatus = om$send (msg = message GRgencs.GRgetmatrix ( &lMsg, dOldMat ),
				senderid = NULL_OBJID,
				targetos = OldGoId.osnum,
				targetid = OldGoId.objid );
	dOldOrg [0]	= dOldMat [3];
	dOldOrg [1]	= dOldMat [7];
	dOldOrg [2]	= dOldMat [11];
        __DBGpr_obj("Oldparent is",OldGoId);
        MyStatus= VCgetangfrmmat(dOldMat,&oldparang); /* CR179802404 */

	}
      break;
    } /* end if Source with GRgencs */
  else
  if (om$is_ancestry_valid (	subclassname	= szClass,
				superclassname	= "VDequipment" ) ==
						OM_S_SUCCESS )
    {
    /********************************************************************/
    bFound	= TRUE;
    OldSourceId.osnum	= ParentList [ii].osnum;
    OldSourceId.objid	= ParentList [ii].objid;
    VDGetCsFromEq (&OldSourceId, &OldGoId, &Info);
    MyStatus = om$send (msg = message GRgencs.GRgetmatrix (
				&lMsg,
				dOldMat ),
		      senderid = NULL_OBJID,
		      targetos = OldGoId.osnum,
		      targetid = OldGoId.objid );
    dOldOrg [0]	= dOldMat [3];
    dOldOrg [1]	= dOldMat [7];
    dOldOrg [2]	= dOldMat [11];
    __DBGpr_obj("Oldparent is",OldGoId);
    MyStatus= VCgetangfrmmat(dOldMat,&oldparang); /* CR179802404 */
    break;
    } /* end if Parent is a VDequipment */
  else
  if (om$is_ancestry_valid (	subclassname	= szClass,
				superclassname	= "VREquipment" ) ==
						OM_S_SUCCESS )
    {
    /********************************************************************/
    bFound	= TRUE;
    OldSourceId.osnum	= ParentList [ii].osnum;
    OldSourceId.objid	= ParentList [ii].objid;
    OldGoId.osnum	= ParentList [ii].osnum;
    OldGoId.objid	= ParentList [ii].objid;
    //VDGetCsFromEq (&OldSourceId, &OldGoId, &Info);
    MyStatus = om$send (msg = message VRGeneric.VRGetMatrix (
				&lMsg,
				0, NULL, dOldMat, &me->LocatedMdEnv ),
		      targetos = OldGoId.osnum,
		      targetid = OldGoId.objid );
    dOldOrg [0]	= dOldMat [3];
    dOldOrg [1]	= dOldMat [7];
    dOldOrg [2]	= dOldMat [11];
    __DBGpr_obj("Oldparent is",OldGoId);
    MyStatus= VCgetangfrmmat(dOldMat,&oldparang); /* CR179802404 */
    break;
    } /* end if Parent is a VREquipment */
  } /* end for */
  /***** Added for CR179802404 *******/
  oldparscl = 1.0;
  if(OldGoId.objid != NULL_OBJID)
  {
      IGRint FootIndex = -1, msg=MSSUCC;
      struct ret_struct  ParamAttr;
      ParamAttr.var.root_pm_st.value = 0.0;
      MyStatus=
      om$send ( msg   = message ACncpx.ACgive_structure
                    ( &msg, &FootIndex, VC_N_PID_SCALE_DB,
                      &ParamAttr, &me->LocatedObjects[me->nSAindex].mod_env ),
                          targetid = OldGoId.objid,
                          targetos = OldGoId.osnum );
      if(ParamAttr.var.root_pm_st.value > 0.0)
         oldparscl = ParamAttr.var.root_pm_st.value;

  }

/*
printf ("bFound is %d, OldGoId (%d,%d) OldSourceId (%d,%d) TermId (%d,%d)\n",
		bFound,
		OldGoId.osnum, OldGoId.objid,
		OldSourceId.osnum, OldSourceId.objid,
		TermId.osnum, TermId.objid );
*/
/************************************************************************/
/* We need to get new origin of located object				*/
/************************************************************************/
*szClass	= 0;
MyStatus = om$get_classname (	osnum		= NewGoId.osnum,
				objid		= NewGoId.objid,
				classname	= szParentClass );
if (om$is_ancestry_valid (	subclassname	= szParentClass,
				superclassname	= "GRgencs" ) ==
						OM_S_SUCCESS )
  {
  NewType	= VC_TERM_CS;
  MyStatus = om$send (msg = message GRgencs.GRgetmatrix ( &lMsg, dNewMat ),
				senderid = NULL_OBJID,
				targetos = NewGoId.osnum,
				targetid = NewGoId.objid );
  dNewOrg [0]	= dNewMat [3];
  dNewOrg [1]	= dNewMat [7];
  dNewOrg [2]	= dNewMat [11];
    __DBGpr_obj("Newparent is",NewGoId);
  MyStatus= VCgetangfrmmat(dNewMat,&newparang); /* CR179802404 */

  /**********************************************************************/
  /* We need to create or retrieve a new source				*/
  /**********************************************************************/
  MyStatus = 
  as$make_source (go_grid  = NewGoId,
		  mod_env  = &me->event1.located_object[0].module_info,
		  as_os    = me->ModuleInfo.md_id.osnum,
		  as_grid  = &NewSourceId);
  }
else
if (om$is_ancestry_valid (	subclassname	= szParentClass,
				superclassname	= "VDequipment" ) ==
						OM_S_SUCCESS )
  {
  NewType	= VC_TERM_EQ;
  VDGetCsFromEq (&NewGoId, &TmpId, &Info);
  MyStatus = om$send (msg = message GRgencs.GRgetmatrix ( &lMsg, dNewMat ),
				senderid = NULL_OBJID,
				targetos = TmpId.osnum,
				targetid = TmpId.objid );
  dNewOrg [0]	= dNewMat [3];
  dNewOrg [1]	= dNewMat [7];
  dNewOrg [2]	= dNewMat [11];
  NewSourceId	= NewGoId;
  }
else
if (om$is_ancestry_valid (	subclassname	= szParentClass,
				superclassname	= "VREquipment" ) ==
						OM_S_SUCCESS )
  {
  NewType	= VC_TERM_RE;
  MyStatus = om$send (msg = message VRGeneric.VRGetMatrix ( 
			&lMsg, 0, NULL, dNewMat, &MdEnv ),
				targetos = NewGoId.osnum,
				targetid = NewGoId.objid );
  dNewOrg [0]	= dNewMat [3];
  dNewOrg [1]	= dNewMat [7];
  dNewOrg [2]	= dNewMat [11];
  NewSourceId	= NewGoId;
    __DBGpr_obj("Newparent is",NewGoId);
    MyStatus= VCgetangfrmmat(dNewMat,&newparang); /* CR179802404 */
  }
  /*** Added for TR179801645 ******/
  {
    IGRint status;
/* Removed by cr179802404
    status =
    om$send ( msg = message VCRoot.VCGetMatrix
                    ( &lMsg, -1, dEltOrg, &MdEnv),
        targetid = TermId.objid,
        targetos = TermId.osnum);
  __DBGpr_mat("Terminal matrix before",dEltOrg);
*/
  }
  newparscl = 1.0;
  if(NewGoId.objid != NULL_OBJID)
  {
      IGRint status = 1, FootIndex = -1, msg=MSSUCC;
      struct ret_struct  ParamAttr;
      ParamAttr.var.root_pm_st.value = 0.0;
      status=
      om$send ( msg   = message ACncpx.ACgive_structure
                    ( &msg, &FootIndex, VC_N_PID_SCALE_DB,
                      &ParamAttr, &me->LocatedObjects[me->nSAindex].mod_env ),
                          targetid = NewGoId.objid,
                          targetos = NewGoId.osnum );
      if(ParamAttr.var.root_pm_st.value > 0.0)
         newparscl = ParamAttr.var.root_pm_st.value;

  }


  /* Modified for tr179801645 */
  __DBGpr_dbl("newparscl ",newparscl);
  __DBGpr_dbl("oldparscl ",oldparscl);
Instance.Attr.Term.dOffVal = dEltOrg;
MyStatus = om$send (msg = message VCRoot.VCGetInstance ( &lMsg, &Instance ),
		  senderid = NULL_OBJID,
		  targetos = TermId.osnum,
		  targetid = TermId.objid );
  __DBGpr_mat("Terminal matrix from Instance ", dEltOrg);
  dEltOrg [3]	= dEltOrg [3]/oldparscl*newparscl ;
  dEltOrg [7]	= dEltOrg [7]/oldparscl*newparscl ;
  dEltOrg [11]	= dEltOrg [11]/oldparscl*newparscl ;

  *szParentClass	= 0;
  MyStatus = om$get_classname (	osnum		= NewSourceId.osnum,
				objid		= NewSourceId.objid,
				classname	= szParentClass );
  /************************************************************************/
  /* Resetting old type of connection					*/
/************************************************************************/
Instance.nType			&= NotType;
Instance.nType			|= NewType;
Instance.Attr.Term.nOff = 16; /* TR179801645 */
Instance.Attr.Term.dOffVal = &dEltOrg[0];
MyStatus = om$send (msg = message VCRoot.VCSetInstance ( &lMsg, &Instance ),
		  senderid = NULL_OBJID,
		  targetos = TermId.osnum,
		  targetid = TermId.objid );
if (bFound)
  {
  /*
  printf ("Trying to disconnect (%d,%d) and reconnect to (%d,%d)\n", 
		      OldSourceId.osnum, OldSourceId.objid, 
		      NewSourceId.osnum, NewSourceId.objid );
  */
  MyStatus = om$send ( msg = message NDnode.NDdisconnect (
							One,
							&OldSourceId ),
			senderid = NULL_OBJID,
			targetos = TermId.osnum,
			targetid = TermId.objid );
  } /* end if old parent found */
*szParentClass	= 0;
MyStatus = om$get_classname (	osnum		= NewSourceId.osnum,
				objid		= NewSourceId.objid,
				classname	= szParentClass );
MyStatus = om$send ( msg = message NDnode.NDconnect (
							One,
							&NewSourceId,
							NULL_GRID,
							ND_ADD),
			senderid = NULL_OBJID,
			targetos = TermId.osnum,
			targetid = TermId.objid );
/************************************************************************/
/* Erase all graphic objects from screen.				*/
/* Recompute the associative node to get graphic updated		*/
/************************************************************************/
MyStatus = om$send ( msg = message NDnode.NDdisplay (
			0, GRbe, &me->event1.located_object[0].module_info ),
		senderid = NULL_OBJID,
		targetos = TermId.osnum,
		targetid = TermId.objid );
MyStatus = om$send ( msg = message NDnode.NDs_compute_node (
			&lMsg, 0, &me->event1.located_object[0].module_info ),
		senderid = NULL_OBJID,
		targetos = NewSourceId.osnum,
		targetid = NewSourceId.objid );
as$status (sts = MyStatus);
as$status (sts = lMsg);
MyStatus = om$send ( msg = message NDnode.NDdisplay (
			0, GRbd, &me->event1.located_object[0].module_info ),
		senderid = NULL_OBJID,
		targetos = TermId.osnum,
		targetid = TermId.objid );

/*
MyStatus = om$send (msg = message VCRoot.VCDUMP ( &lMsg ),
		  senderid = NULL_OBJID,
		  targetos = TermId.osnum,
		  targetid = TermId.objid );
*/
wrapup :

__DBGpr_com ("Exiting VCSAProcessParent");

return OM_S_SUCCESS;

} /* end method VCSAProcessParent */
IGRint VCgetangfrmmat(Mat,oang)
IGRdouble *Mat, *oang;
{
   IGRint status;
   IGRdouble sinang, ang;

   sinang = fabs(Mat[4]);
   ang = asin(sinang) * 180. / M_PI;
   if(Mat[0] < 0.0)
     if(Mat[4] < 0.0)
        ang = ang + 180.0; /* 3rd quadrant */
     else
        ang = 180. - ang;  /* 2nd quadrant */
   else if(Mat[4] < 0.0)
     ang = 360.0 - ang;    /* 4th quadrant */
   __DBGpr_dbl("angle from matrix is",ang);
   *oang = ang;
return (status);
}
end implementation VCCmdSA;

