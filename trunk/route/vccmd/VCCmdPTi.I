
/* $Id: VCCmdPTi.I,v 1.2 2001/02/20 01:09:38 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdPTi.I
 *
 * Description:
 *      Implementation file for place terminal command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdPTi.I,v $
 *  Revision 1.2  2001/02/20 01:09:38  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.3  1998/12/22  17:01:26  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by lawaddel for route
#
# Revision 1.2  1998/07/22  06:50:14  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by apazhani for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.3  1998/04/20  04:32:24  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by kddinov for route
#
# Revision 1.2  1998/04/20  04:08:40  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.19  1997/09/10  23:10:36  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by apazhani for cabling
#
# Revision 1.18  1997/09/10  17:40:58  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by apazhani for cabling
#
# Revision 1.17  1997/07/14  22:52:44  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.16  1997/05/22  14:45:56  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.15  1997/05/19  14:07:20  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.14  1997/05/10  15:16:56  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.13  1997/05/07  16:12:12  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.12  1997/04/29  19:49:20  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.11  1997/04/29  19:36:50  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.10  1997/03/12  21:57:50  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.9  1997/01/24  16:27:04  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.8  1997/01/24  14:55:56  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.7  1997/01/23  23:50:08  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.6  1997/01/20  22:11:12  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.5  1997/01/03  18:13:58  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/30  15:27:56  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  14:33:42  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/26  21:18:30  pinnacle
# Replaced: vccmd/VCCmdPTi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:16:26  pinnacle
# Created: vccmd/VCCmdPTi.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  09/10/97      Alwin   Modified to add the VCTEvaluate and dynamics method,
 *                        and VCFollowCursor, VCfollowdyn functions-for
 *                        CR179701611
 *  07/22/98      Alwin   Adjusted to be line with the state table modification.
 *			  i.e. Addition of the "state Evaluate".
 *  12/20/98      law     CR179802404-Allow rotation of terminals/connectors
 *************************************************************************/

class implementation VCCmdPT;

#include "VCcreate.h"
#include "asbox.h"
#include "VCmacros.h"
#include "VCproto.h"
#include "VCTagDef.h"
#include "VCCmdForm.h"

#include "VDmem.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "dpstruct.h"

#include "vc_default.h"
#include "VCstructs.h"
#include "matypemx.h"
#include "mamulmx.h"
#include "bstypes.h"
#include "bsinv_mat.h"
#include "vrdbgmacros.h"
#define DYNCOMP 100

/*
#define  MY_DEBUG
*/

from     VCRoot    import    VCGetType;
from     VCRoot    import    VCSelectCpt;
from     GRowner   import    GRget_matrix;
from     GRgraphics    import    GRdisplay, GRdelete;
from     GRgraphics    import    GRxform, GRcopy;
from     GRgencs    import    GRgetmatrix;
from     VRGeneric    import    VRGetMatrix;

extern GRclassid   OPP_VCTerm_class_id;
extern GRclassid   OPP_VCCable_class_id;
extern GRclassid   OPP_GRgencs_class_id;
extern GRclassid   OPP_ASsource_class_id;
extern GRclassid   OPP_VREquipment_class_id;
extern GRclassid   OPP_VRGeneric_class_id;
extern GRclassid   OPP_VDequipment_class_id;
extern GRclassid   OPP_VCElTerm_class_id;
extern GRclassid   OPP_VCFoTerm_class_id;

extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);

%safe
#include "VX_FIproto.h"
static IGRdouble dPrevCursorPt[]={0.0, 0.0, 0.0};
%endsafe


/**********************************************************/

method VCCmdStart ( int * sts )
{
  IGRshort   nCount;
  IGRlong    retmsg;
  IGRint     status;
  IGRshort   nC1, nC2;
  IGRchar   *p1;
  IGRchar   *p2;

  status = OM_S_SUCCESS;

  *sts = VC_RTC_ALLOK;

#ifdef MY_DEBUG
  printf ("cmdstart\n");
#endif

  me->nVCConn_type = VC_GEN_TERM | VC_GEN_BITERM;
  me->CommGadget   = VC_GDG_CMD_GENTERM;

#include "vc_default.h"


/* 4-98 KDD use single point default selection function
*  switch (me->iSynType)
*  {
*    case VC_CMDTYP_GEN:
*    default:
*      me->Product    = VC_PROD_NONE;
*      me->nTagCat    = VCTAG_CAT_GENERAL;
*      break;
*
*    case VC_CMDTYP_EL:
//     me->CommGadget = VC_GDG_CMD_ELTERM;
*      me->Product    = VC_PROD_ELEC;
*      me->nTagCat    = VCTAG_CAT_ELTERM;
*      break;
*
*    case VC_CMDTYP_FO:
*      me->Product    = VC_PROD_FO;
//     me->CommGadget = VC_GDG_CMD_FOTERM;
*      me->nTagCat    = VCTAG_CAT_FOTERM;
*      break;
*
*    case VC_CMDTYP_MISC1:
*      me->Product    = VC_PROD_NONE;
*      goto quit;
*  }
*/

  status = VCGetDefaultInfo( (IGRint) me->iSynType, 
				VC_GET_TERM_TAG, (char *) &me->nTagCat);

  status = VCGetDefaultInfo( (IGRint) me->iSynType, 
				VC_GET_PRODUCT, (char *) &me->Product);


  me->FCmain       = VC_FPOS_PT_MAIN;
  me->FCsub        = VC_FPOS_PT_SUB;
  me->FCcontrol    = -1;

  me->pSysAtt      = me->forms[VC_FRM_MAIN].form_ptr;
  me->pUsrAtt      = me->forms[VC_FRM_SUB].form_ptr;
  me->pCtlAtt      = NULL;

  nC1 = nC2 = 0;

  if (me->iSynType != VC_CMDTYP_FO)
    vc$elterm_idx (p_count = &nC1,
                   osnum   = me->My_OS);

  if (me->iSynType != VC_CMDTYP_EL)
    vc$foterm_idx (p_count = &nC2,
                   osnum   = me->My_OS);

  nCount = me->nCC = nC1 + nC2;

  if (nCount > 0)
  {
    me->CClist = _MALLOC (nCount * VC_MAX_CCODE, IGRchar);
    me->CCdesc = _MALLOC (nCount * VC_MAX_SDESC, IGRchar);
    if (me->CClist == NULL) return (OM_E_NODYNMEM);

    p1 = me->CClist;
    p2 = me->CCdesc;

    if (nC1 > 0)
    {
       vc$elterm_idx (p_count = &nC1,
                      osnum   = me->My_OS,
                      p_desc  = p2,
                      p_codes = p1);

       p1 += nC1 * VC_MAX_CCODE;
       p2 += nC1 * VC_MAX_SDESC;

       me->nFOstart = nC1;
#ifdef MY_DEBUG
       printf (" FO start %d\n",nC1);
#endif
    }

    if (nC2 > 0)
    {
       vc$foterm_idx (p_count = &nC2,
                      osnum   = me->My_OS,
                      p_desc  = p2,
                      p_codes = p1);
    }
  }

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdInit ( int * sts )
{
  IGRint   i;

  *sts = VC_RTC_ALLOK;

#ifdef MY_DEBUG
  printf ("cmdinit\n");
#endif

  me->nCpt         = -1;
  me->nVal         = 0;
  me->bMTO         = TRUE;

  me->ConstrId.objid = NULL_OBJID;
  me->ConstrId.osnum = me->ModuleInfo.md_id.osnum;
  me->RefId.objid    = NULL_OBJID;
  me->RefId.osnum    = me->ModuleInfo.md_id.osnum;

  for (i=0; i<16; i++)
    me->dValues[i] = 0;

  return (OM_S_SUCCESS);
}

/**********************************************************/

method VCCmdGetRef ( int * sts )
{
  int          status = OM_S_SUCCESS;
  IGRlong      msg;
  GRclassid    parentClassId;

  struct GRid  OwnId;

  extern int   ASget_as_owner();

  me->My_localret = VC_RTC_ALLOK;

  /*A ----- Get located object ----- */
  me->RefId = me->event1.located_object[0].located_obj;
  OwnId     = me->RefId;
  OwnId.objid = NULL_OBJID;

  ASget_as_owner (&me->RefId, &OwnId);

  if (OwnId.objid != NULL_OBJID)
  {
    UI_status ("Reference cannot be embedded");

    /*A ----- Dehilite. ----- */
    status =
    dp$erase_hilite (msg   = &msg,
                     osnum = me->RefId.osnum);

    _put_response( resp = VC_RTC_ERROR);
    *sts = VC_RTC_ERROR;
    me->My_localret = VC_RTC_ERROR;
    me->RefId.objid = NULL_OBJID;
    goto quit;
  }

  /*A ----- Check type ------------- */
  om$get_classid (objid = me->RefId.objid,
                  osnum = me->RefId.osnum,
              p_classid = &parentClassId);

  /*A Check reference type and decide nVCConn_type */

  if ((om$is_ancestry_valid (
             subclassid   = parentClassId,
             superclassid = OPP_GRgencs_class_id) == OM_S_SUCCESS)
         ||  (om$is_ancestry_valid (
               subclassid   = parentClassId,
               superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS))
  {
       me->nVCConn_type |= VC_TERM_CS;
  }
  else
  if (om$is_ancestry_valid (
             subclassid   = parentClassId,
             superclassid = OPP_VDequipment_class_id) == OM_S_SUCCESS)
  {
      me->nVCConn_type |= VC_TERM_EQ;
  }
  else
  if (om$is_ancestry_valid (
               subclassid   = parentClassId,
               superclassid = OPP_VREquipment_class_id) == OM_S_SUCCESS)
  {
      me->nVCConn_type |= VC_TERM_RE;
  }
  else
  {
    /*A ----- Dehilite. ----- */
    status =
    dp$erase_hilite (msg   = &msg,
                     osnum = me->RefId.osnum);

    _put_response( resp = VC_RTC_ERROR);
    *sts = VC_RTC_ERROR;
    me->My_localret = VC_RTC_ERROR;
    me->RefId.objid = NULL_OBJID;
    goto quit;
  }

  /*  In any case make sure it's an associative root   */

#ifdef MY_DEBUG
       printf (" Refid... %d %d\n",me->RefId.objid,me->RefId.osnum);
#endif

  status =
  as$make_source (go_grid  = me->RefId,
                  mod_env  = &me->event1.located_object[0].module_info,
                  as_os    = me->ModuleInfo.md_id.osnum,
                  as_grid  = &me->RefId);

  *sts = VC_RTC_ALLOK;
#ifdef MY_DEBUG
       printf (" Refid.source.. %d %d\n",me->RefId.objid,me->RefId.osnum);
#endif

  quit:
  return (OM_S_SUCCESS);
}

method VCCmdNulPar (int  * sts)
{

  /*    set up for no parent     */

  *sts = VC_RTC_ALLOK;

  me->nVCConn_type |= VC_TERM_NO;

  return (OM_S_SUCCESS);
}

method VCTEvaluate ( int *sts )
{
  int                     status;
  IGRlong                 msg;
  struct GRid             ParId[4];
  IGRint                  NumPar;
  IGRint                  i;

  SetProc( Md VCTEvaluate ); Begin 

  *sts = MSSUCC;

  for(i=0;i<4;i++)
  {
    ParId[i].objid      = NULL_OBJID;
    ParId[i].osnum      = me->ModuleInfo.md_id.osnum;
  }

  /* No attribute coll. for virtual terms  */
  if (!(me->nVCConn_type & VC_GEN_VIRTUAL))
  {
    status =
    om$send (msg = message VCAT.VCAT_coll (&msg, &ParId[0], &ParId[1]),
        targetid = my_id);

    me->GenInfo.nNbAttr       = 2;
  }
  else
    me->GenInfo.nNbAttr       = 0;

  NumPar = me->GenInfo.nNbAttr;

  if (me->RefId.objid != NULL_OBJID)
  {
    ParId[me->GenInfo.nNbAttr] = me->RefId;
    NumPar++;
  }

  /*C Verify against database ... ?? */

  me->GenInfo.nStat        = VC_STATUS_INIT;
  me->GenInfo.nType        = me->nVCConn_type;
  me->GenInfo.cRep         = me->nACTrep;
  me->GenInfo.nProduct     = me->Product;
  me->GenInfo.nNbTopo      = 1;
  me->GenInfo.bNoMtoFlg    = me->bMTO;
  me->GenInfo.cRep         = me->nACTrep;
  me->GenInfo.nProduct     = me->Product;
  me->GenInfo.nNbTopo      = 1;
  me->GenInfo.bNoMtoFlg    = me->bMTO;

  strcpy (me->GenInfo.szCode,  me->CompCode);
  strcpy (me->GenInfo.szTagno, me->TagNum);

  me->GenInfo.Attr.Term.nCpt           = me->nCpt;
  me->GenInfo.Attr.Term.nOff           = me->nVal;
  me->GenInfo.Attr.Term.dOffVal        = me->dValues;

  /*A ----- Create and place the Component  ----- */
  status =
  VC_CreateTerm (&msg, NumPar, ParId, &me->GenInfo, me->ActiveLevel,
                 &me->ActiveDisplay, &me->ModuleInfo, &me->ConstrId);

  /* added by alwin */

  if( ! ( status & msg & 1 ) )
      me->ret = VC_RTC_ERROR;
  __DBGpr_obj( " Constructed Terminal Id ", me->ConstrId );
  /* added by alwin */

  End
  return OM_S_SUCCESS;
}

IGRint VCfollowdyn( strComp, point, matrix, objects, num_objects, 
                    buffers, num_buffers, dummy_in1, dummy_in2, dummy_in3,
                    dummy_out1, dummy_out2, dummy_out3 )
struct          VCParams        *strComp;
struct          EX_button       *point;
IGRdouble                       *matrix;
struct          GRid            **objects;
IGRint                          *num_objects;
struct          DPele_header    **buffers;
IGRint                          *num_buffers;
IGRchar                         *dummy_in1;
IGRchar                         *dummy_in2;
IGRchar                         *dummy_in3;
IGRchar                         **dummy_out1;
IGRchar                         **dummy_out2;
IGRchar                         **dummy_out3;
/*.VCfollowdyn */
{
  IGRshort      nTranType;
  IGRlong       status, retcode;
  IGRdouble     Matrix[16], dOffset[3], OutMatrix[16];
  
  SetProc( Fn VCfollowdyn ); Begin 

  status  = OM_S_SUCCESS;

  MAidmx( &retcode,  Matrix );
  MAidmx( &retcode,  OutMatrix );

  if( strComp->Parent.objid == NULL_OBJID )
  {
       __DBGpr_com( " Reached No Parent case " );
       dOffset[0] = ( point->x - dPrevCursorPt[0] );
       dOffset[1] = ( point->y - dPrevCursorPt[1] );
       dOffset[2] = ( point->z - dPrevCursorPt[2] );

       OutMatrix[3] = dOffset[0];
       OutMatrix[7] = dOffset[1];
       OutMatrix[11] = dOffset[2];

       dPrevCursorPt[0] = point->x;
       dPrevCursorPt[1] = point->y;
       dPrevCursorPt[2] = point->z;
  }
  else
  {
       GRclassid Classid;
       IGRshort nFour = 4, nOne=1;
       IGRdouble Matrix[16], TempMatrix[16], dCoord[4], dLocCoord[4];
       BSrc bsretcode;

       MAidmx( &retcode, Matrix );
       MAidmx( &retcode, OutMatrix );

       dCoord[0] = point->x;
       dCoord[1] = point->y;
       dCoord[2] = point->z;
       dCoord[3] = 1;

       status = om$get_classid( objid = strComp->Parent.objid,
                                osnum = strComp->Parent.osnum,
                                p_classid = &Classid );

       if (( Classid == OPP_ASsource_class_id )
              ||  ( Classid == OPP_GRgencs_class_id ) )
       {
        /* So the Parent is Co-ordinate System */

          status = om$send ( msg = message GRgencs.GRgetmatrix( &retcode,
                                                Matrix ),
                                   senderid = NULL_OBJID,
                                   targetid = strComp->Parent.objid,
                                   targetos = strComp->Parent.osnum );
       }
       else
       {
          /* Parent is Equipment */
          IGRshort nTmpType;

          if (om$is_ancestry_valid (
                       subclassid   = Classid,
                       superclassid = OPP_VRGeneric_class_id) == OM_S_SUCCESS)
          {
              status = om$send ( msg = message VRGeneric.VRGetMatrix( &retcode,
                                         NULL, NULL, Matrix,
                                         &strComp->md_env ),
                                   senderid = NULL_OBJID,
                                   targetid = strComp->Parent.objid,
                                   targetos = strComp->Parent.osnum );
          }
          else 
          {
               status = om$send ( msg = message GRowner.GRget_matrix( &retcode,
                                         &strComp->md_env.md_env.matrix_type,
                                         strComp->md_env.md_env.matrix,
                                         &nTmpType, Matrix ),
                                   senderid = NULL_OBJID,
                                   targetid = strComp->Parent.objid,
                                   targetos = strComp->Parent.osnum );
          }
       }
       /**** Inserted for CR179802404 (rotation of parent) */
       MAidmx( &retcode, TempMatrix);
       TempMatrix[3] = Matrix[3];
       TempMatrix[7] = Matrix[7];
       TempMatrix[11] = Matrix[11];
       BSinv_mat( nFour, TempMatrix, OutMatrix, &bsretcode );
       MAmulmx( &retcode, &nFour, &nFour, &nOne, OutMatrix, dCoord, dLocCoord );

    //   MAidmx( &retcode, OutMatrix );
       OutMatrix[3] = dLocCoord[0] - dPrevCursorPt[0];
       OutMatrix[7] = dLocCoord[1] - dPrevCursorPt[1];
       OutMatrix[11] = dLocCoord[2] - dPrevCursorPt[2];

       dPrevCursorPt[0] = dLocCoord[0];
       dPrevCursorPt[1] = dLocCoord[1];
       dPrevCursorPt[2] = dLocCoord[2];
  }

  MAtypemx( &retcode, OutMatrix, &nTranType);

  /* -- Apply transformation matrix to graphics -- */
  __DBGpr_obj( " Transforming the object ", strComp->CompId );
  status =
  om$send ( msg      = message GRgraphics.GRxform ( &retcode,
                                                &strComp->md_env,
                                                &nTranType,
                                                OutMatrix,
                                                &strComp->CompId.objid ),
                     senderid = NULL_OBJID,
                     targetid =  strComp->CompId.objid,
                     targetos =  strComp->CompId.osnum );

  *objects = &strComp->CompId;
  *num_objects = 1;

  {
        /* This has been added to get rid of compiler messages  */
        IGRdouble         *Lmatrix;
        IGRchar           *Ldummy;

        *num_buffers = 0;
        *buffers = NULL;
        Lmatrix  = matrix;
        Ldummy   = dummy_in1;
        Ldummy   = dummy_in2;
        Ldummy   = dummy_in3;
        Ldummy   = *dummy_out1;
        Ldummy   = *dummy_out2;
        Ldummy   = *dummy_out3;
  }

End
return OM_S_SUCCESS;
} /* end function VCfollowdyn */

%safe
static struct VCParams Terminal; /* Global Structure */
%endsafe

IGRlong VCFollowCursor( struct GRid *CompId, struct GRmd_env *md_env )
{
   IGRlong status = OM_S_SUCCESS, msg;
   struct GRid Duplicate;

   SetProc( Fn VCFollowCursor ); Begin 

   Terminal.CompId = *CompId;
   Terminal.md_env = *md_env;

   __DBGpr_obj( " Terminal Id ", Terminal.CompId );

   Duplicate.osnum = Terminal.CompId.osnum;
   status = om$send ( msg = message GRgraphics.GRcopy( &msg, &Terminal.md_env,
                                          &Terminal.md_env, &Duplicate.objid ),
                                   senderid = NULL_OBJID,
                                   targetid = Terminal.CompId.objid, 
                                   targetos = Terminal.CompId.osnum );
                                        
   Terminal.CompId = Duplicate;
   __DBGpr_obj( " Duplicate Terminal Id ", Terminal.CompId );

   /* This "dPrevCursorPt" needs to be intialized before calling the 
      "dp$dynamics" macro, or else it gets retained and it will cause problem 
      if stay in the command and keep executing the forms for successive 
      placement of Terminals */
   dPrevCursorPt[0] = dPrevCursorPt[1] = dPrevCursorPt[2] = 0.0;

   __DBGpr_com( " Calling dp$dynamics " );
   status = dp$dynamics ( dyn_fun     = VCfollowdyn,
                          information = &Terminal );

   if( Duplicate.objid != NULL_OBJID )
   {
      enum GRdpmode Mode;

      Mode = GRbe;
      status = om$send ( msg = message GRgraphics.GRdisplay( &msg,
                                   &md_env->md_env.matrix_type,
                                   md_env->md_env.matrix, &Mode,
                                   &md_env->md_id ),
                         senderid = NULL_OBJID,
			   targetid = CompId->objid, 
			   targetos = CompId->osnum );

      status = om$send ( msg = message GRgraphics.GRdelete( &msg, md_env ),
                                   senderid = NULL_OBJID,
                                   targetid = CompId->objid, 
                                   targetos = CompId->osnum ); 

      /* added by alwin */
      status = om$send ( msg = message GRgraphics.GRdisplay( &msg,
                                   &md_env->md_env.matrix_type,
                                   md_env->md_env.matrix, &Mode,
                                   &md_env->md_id ),
                         senderid = NULL_OBJID,
			   targetid = Duplicate.objid,
			   targetos = Duplicate.objid );
      /* added by alwin */

      status = om$send ( msg = message GRgraphics.GRdelete( &msg, md_env ),
                                   senderid = NULL_OBJID,
                                   targetid = Duplicate.objid, 
                                   targetos = Duplicate.osnum ); 
     Duplicate.objid = NULL_OBJID;
   }

   End
   return status;
}

method dynamics ( int dynamics; int *sts)
{
  IGRlong status;
  *sts = MSSUCC;

  if ( dynamics == DYNCOMP )
  {
        Terminal.Parent = me->RefId;

        status =
        VCFollowCursor( &me->ConstrId, &me->ModuleInfo);
  }

return OM_S_SUCCESS;
}

end implementation VCCmdPT;
