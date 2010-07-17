
/* $Id: VCCmdAnali.I,v 1.1.1.1 2001/01/04 21:12:30 cvs Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:        vccmdutil/VCCmdAnali.I
 *
 * Description:
 *      Command implementation of analysis
 *
 *
 * Dependencies:
 *
 * Revision History:
 *        $Log: VCCmdAnali.I,v $
 *        Revision 1.1.1.1  2001/01/04 21:12:30  cvs
 *        Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/04/20  04:14:52  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by kddinov for route
#
# Revision 1.1  1997/10/30  04:17:36  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.12  1997/07/22  15:24:38  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.11  1997/07/14  22:39:46  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.10  1997/05/10  13:29:42  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.9  1997/03/28  21:20:24  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.8  1997/03/20  21:16:30  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.7  1997/03/19  18:35:56  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.6  1997/03/14  18:24:38  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.5  1997/03/12  22:26:24  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.4  1997/01/24  00:01:30  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.3  1996/10/25  19:13:38  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.2  1996/10/07  20:26:44  pinnacle
# Replaced: vccmdutil/VCCmdAnali.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:02:12  pinnacle
# Created: vccmdutil/VCCmdAnali.I by hverstee for cabling
#
 *
 * History:
 *        07/10/96        hv        Initial
 *
 *************************************************************************/

class implementation VCCmdAnal;

#include "cierrordef.h"
#include "ciexecmacros.h"
#include "cierrmacros.h"

#include "VDmem.h"

#include "VCproto.h"
#include "vc_default.h"

extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);

%safe
#include "VX_FIproto.h"
%endsafe

/*
#define MY_DEBUG
*/

from  ACncpx     import   ACgive_structure;
from  VCRoot     import   VCGetProduct;
from  VCDB       import   VCGetLayout;
from  VCCon      import   VCConGetTrace;
from  GRgraphics import   GRdisplay;

extern GRclassid        OPP_VCTerm_class_id; 
extern GRclassid        OPP_VCFoTerm_class_id; 
extern GRclassid        OPP_VCElTerm_class_id; 
extern GRclassid        OPP_VCFoCable_class_id;
extern GRclassid        OPP_VCElCable_class_id;


/*=======================================================================*/

method init ( int type ; char * str_ptr )
{
  int       status;

  /*A call my super class's init */
  status = 
  om$send (mode     = OM_e_wrt_message,
           msg      = message VDS_LOCATE.init( type, str_ptr ),
           targetid = my_id  );
  as$status( action = RET_STATUS );

  /*A initialize my instance data */
  me->MyType         = type;

  _FREE (VCANGLB_trac);

  VCANGLB_ntrace     = 0;
  VCANGLB_trac       = NULL;
  VCANGLB_select     = VC_DEFAN_NONE;

  me->nLay           = 0;
  me->nLtab          = 0;
  me->nLTOT          = 0;
  me->LayTab         = NULL;

  me->LocType        = VC_UNKNOWN;
  me->nCptNum        = 0;
  me->nActPos        = -1;
  me->bSelected      = FALSE;

/* 4-98 KDD use single point default selection function
*  switch (me->MyType)
*  {
*    case VC_CMDTYP_GEN:
*    default:
*      me->Product    = VC_PROD_NONE;
*      break;
*
*    case VC_CMDTYP_EL:
*      me->Product    = VC_PROD_ELEC;
*      break;
*
*    case VC_CMDTYP_FO:
*      me->Product    = VC_PROD_FO;
*      break;
*  }
*/

  status = VCGetDefaultInfo( me->MyType, VC_GET_PRODUCT, (char *) &me->Product);


  /*  initialize to straight connections only   */
  me->TransFlags     = (VCTR_CON_CON | VCTR_TERM_THRU);

  me->bToFile        = FALSE;
  me->bToPPL         = FALSE;

  VCANGLB_signam[0]  = '\0';
  me->szTagNo[0]     = '\0';
  me->szTagN2[0]     = '\0';

  me->ConId1.GRid.objid  = NULL_OBJID;
  me->ConId1.GRid.osnum  = me->ModuleInfo.md_id.osnum;
  me->ConId1.OutId.nType = VC_UNKNOWN;

  me->ConId2.GRid.objid  = NULL_OBJID;
  me->ConId2.GRid.osnum  = me->ModuleInfo.md_id.osnum;
  me->ConId2.OutId.nType = VC_UNKNOWN;

  me->nNumAna        = 0;
  me->ProcList       = NULL;
  me->bSetCheck      = NULL;

#ifdef MY_DEBUG
  printf (" Analyze init done\n");
#endif

  return OM_S_SUCCESS;
}

method VCGetRefInfo ( int * sts )
{
  int              status;
  IGRlong          retmsg;
  GRclassid        MyClassId;

  struct GRid      LocRef;

 *sts = MSSUCC;

  LocRef = me->event1.located_object[0].located_obj;

  if (me->ConId1.GRid.objid == NULL_OBJID)
  {
    /*A get the first located object */
 
    /*A get located element class id   */
    status = 
    om$get_classid (objid      = LocRef.objid,
                    osnum      = LocRef.osnum,
                    p_classid  = &MyClassId   );

    /*A change to virtual.....  */
    if (om$is_ancestry_valid
               (subclassid = MyClassId,
              superclassid = OPP_VCTerm_class_id) == OM_S_SUCCESS)
    {
      struct GRid   GGG;
      IGRboolean    bCreate;

      bCreate = FALSE;

      status =
      VCT_virtualize (&retmsg, bCreate, &LocRef, &me->ModuleInfo,
                                        &GGG, &me->ModuleInfo);
      as$status();

      VCANGLB_select = VC_DEFAN_TERM;
      me->LocType    = VC_TERM_TYPE;
    }
    else
    {
      VCANGLB_select = VC_DEFAN_CABLE;
      me->LocType    = VC_CABLE_TYPE;
    }

#ifdef MY_DEBUG
    printf (" setup, type = %d\n", me->LocType);
    printf (" Refid = <%d %d>\n", LocRef.objid,LocRef.osnum);
#endif

    status =
    om$send (msg = message VCRoot.VCGetProduct (&me->Product, NULL),
        targetid = LocRef.objid,
        targetos = LocRef.osnum);

    /*   find the buffer sizes (max)  */
    status =
    om$send( msg = message VCDB.VCGetLayout
                         (&retmsg, NULL, &me->nLay, &me->nLtab, NULL),
        targetid = LocRef.objid,
        targetos = LocRef.osnum );
    as$status( action = RET_STATUS );

    if (me->nLay <= 0)
    {
       *sts = MSFAIL;
       goto quit;
    }

    /*C    and retrieve the layout buffer    */

    me->LayTab = _MALLOC (me->nLay , struct VClayout);

    status =
    om$send( msg = message VCDB.VCGetLayout
                         (&retmsg, NULL, &me->nLay, &me->nLtab, me->LayTab),
        targetid = LocRef.objid,
        targetos = LocRef.osnum );
    as$status( action = RET_STATUS );

    /*    begin of trace....   */
    me->ConId1.GRid = LocRef;
    me->ConId1.OutId.nType = me->LocType;

    if (me->LocType == VC_CABLE_TYPE)
    { /*   force bypass of second pick   */
      *sts = VC_RTC_ANCAB;
       _put_response( resp = VC_RTC_ANCAB);
    }
  }
  else
  {     /*   second reference, get ID and check product     */
    IGRint     nPR;

#ifdef MY_DEBUG
    printf (" Ref2 = <%d %d>\n", LocRef.objid,LocRef.osnum);
#endif

    status =
    om$send (msg = message VCRoot.VCGetProduct (&nPR, NULL),
        targetid = LocRef.objid,
        targetos = LocRef.osnum);

#ifdef MY_DEBUG
    printf (" Products %d %d\n", me->Product, nPR);
#endif

    if (nPR != me->Product)
    {
       *sts = MSFAIL;
       goto quit;
    }

    VCANGLB_select = VC_DEFAN_CBTRAC;

    /*    end of trace....   */
    me->ConId2.GRid = LocRef;
/*
    me->ConId2.OutId.nType = VC_TERM_TYPE;
*/
  }

  quit:
  return OM_S_SUCCESS;
}

method VCFillForm ()
{
  int            status;
  IGRint         retmsg;
  IGRint         FootIndex=-1;
  IGRint         i;
  IGRint         index;
  IGRchar       *fptr;

  struct ret_struct    ParamAttr;

#ifdef MY_DEBUG
    printf (" Fillform \n");
#endif

  me->bToFile        = FALSE;
  me->bToPPL         = FALSE;

  VC_INITSTR (VCANGLB_filenam);
  VC_INITSTR (me->szPPLNam);
  VC_INITSTR (me->szFNCNam);

  fptr = me->forms[VC_ANA_FORM].form_ptr;

  VC_Cmd_form_open (fptr, VC_FPOS_ANA);

  /*A fill the tag num info */
  status = 
  om$send( msg = message ACncpx.ACgive_structure
                            (&retmsg, &FootIndex, VC_N_TAG_NUMBER_AN,
                            &ParamAttr, &me->ModuleInfo),
      targetid = me->ConId1.GRid.objid,
      targetos = me->ConId1.GRid.osnum );
  as$status( action = RET_STATUS );

  strcpy (me->szTagNo, ParamAttr.var.text_st.text_string);

#ifdef MY_DEBUG
    printf (" Tag number origin %s \n", me->szTagNo);
#endif

  if (me->ConId2.GRid.objid != NULL_OBJID)
  {
    status =
    om$send( msg = message ACncpx.ACgive_structure
                            (&retmsg, &FootIndex, VC_N_TAG_NUMBER_AN,
                            &ParamAttr, &me->ModuleInfo),
        targetid = me->ConId2.GRid.objid,
        targetos = me->ConId2.GRid.osnum );

    strcpy (me->szTagN2, ParamAttr.var.text_st.text_string);
#ifdef MY_DEBUG
    printf (" Tag number dest %s \n", me->szTagN2);
#endif
  }

  FIg_set_text (fptr, VC_ANGD_ORG, me->szTagNo);
  FIg_set_text (fptr, VC_ANGD_DST, me->szTagN2);

  FIg_set_text (fptr, VC_ANGD_SIG, VCANGLB_signam);

  /*A fill the conn positions field */
  FIfld_set_max_num_rows (fptr, VC_ANGD_PIN, me->nLay);

  index = 0;

  me->nLAct = -1;

  for (i=0; i<me->nLay; i++)
  {
    switch (me->LayTab[i].pDef.nType)
    {
      case VC_TERM_TYPE:
#ifdef MY_DEBUG
        printf (" Layout tab defterm %d - %s %s \n", index,
                  me->LayTab[i].pDef.Conn.Term.szModId,
                  me->LayTab[i].pDef.Conn.Term.szPosId);
#endif
        FIfld_set_text (fptr, VC_ANGD_PIN, index, 0, 
                        me->LayTab[i].pDef.Conn.Term.szModId, FALSE);
        FIfld_set_text (fptr, VC_ANGD_PIN, index, 1, 
                        me->LayTab[i].pDef.Conn.Term.szPosId, FALSE);
        index++;
        break;

      case VC_CABLE_TYPE:
#ifdef MY_DEBUG
        printf (" Layout tab defcable %d - %d %s \n", index,
                  me->LayTab[i].pDef.Conn.Cable.nCpt,
                  me->LayTab[i].pDef.Conn.Cable.szLeadId);
#endif
        FIfld_set_text (fptr, VC_ANGD_PIN, index, 0, 
                        me->LayTab[i].pDef.Conn.Cable.szLeadId, FALSE);
        FIfld_set_text (fptr, VC_ANGD_PIN, index, 1," ", FALSE);
        index++;
        break;

      default:
        break;
    }

    switch (me->LayTab[i].pAlt.nType)
    {
      case VC_TERM_TYPE:
#ifdef MY_DEBUG
        printf (" Layout tab altterm %d - %s %s \n", index,
                  me->LayTab[i].pAlt.Conn.Term.szModId,
                  me->LayTab[i].pAlt.Conn.Term.szPosId);
#endif
        FIfld_set_text (fptr, VC_ANGD_PIN, index, 0, 
                        me->LayTab[i].pAlt.Conn.Term.szModId, FALSE);
        FIfld_set_text (fptr, VC_ANGD_PIN, index, 1,
                        me->LayTab[i].pAlt.Conn.Term.szPosId, FALSE);
        index++;
        break;

      case VC_CABLE_TYPE:
        FIfld_set_text (fptr, VC_ANGD_PIN, index, 0,  
                        me->LayTab[i].pAlt.Conn.Cable.szLeadId, FALSE);
        FIfld_set_text (fptr, VC_ANGD_PIN, index, 1," ", FALSE);
        index++;
        break;

      default:
        break;
    }
  }

  me->nLTOT = index;

  status =
  om$send (msg = message VCCmdAnal.VCANfunc (&(me->MyRet)),
      targetid = my_id);

  return OM_S_SUCCESS;
}

method  VCANfunc (int *sts)
{
  IGRint      status;
  IGRint      i;
  IGRchar    *fptr;

  /*   wipe out old table first    */

  fptr = me->forms[VC_ANA_FORM].form_ptr;

  for (i=0; i<me->nNumAna; i++)
  {
    FIfld_set_text (fptr, VC_ANGD_SEL, i, 0, " ", FALSE);
    FIfld_set_text (fptr, VC_ANGD_SEL, i, 1, " ", FALSE);
  }

  _FREE (me->ProcList);
  _FREE (me->bSetCheck);

  /*    CUSTOM, fill the calculator table    */

#ifdef MY_DEBUG
  printf (" To getfunc.....\n");
#endif

  status =
  VC_AN_getfunc (VCANGLB_select, &me->nNumAna, NULL);

  me->ProcList  = _MALLOC (me->nNumAna, struct VC_anproc);
  me->bSetCheck = _MALLOC (me->nNumAna, IGRboolean);

  status =
  VC_AN_getfunc (VCANGLB_select, &me->nNumAna, me->ProcList);

  for (i=0; i<me->nNumAna; i++)
  {
    FIfld_set_text (fptr, VC_ANGD_SEL, i, 0, me->ProcList[i].Desc, FALSE);
    me->bSetCheck[i] = FALSE;
  }

  return OM_S_SUCCESS;
}

method form_notification ( int       form_label ;
                           int       gadget_label ;
                           double    value ;
                           char    * form_ptr )
{
  int               status;
  int               sts;
  IGRlong           retmsg;
  IGRint            i, j;
  IGRint            nActRow;
  IGRdouble         dtmp;
  enum GRdpmode     dpmode;
  struct GRid       disp_info;

  dtmp = 0.0;
  if ( form_ptr == NULL )  return OM_E_INVARG;

  FIg_set_text (form_ptr, VC_ANGD_MS1, "" );
  FIg_set_text (form_ptr, VC_ANGD_MS2, "" );

  me->MyRet = gadget_label;

  switch( gadget_label )
  {
    case FI_ACCEPT:    /*    IMPOSSIBLE......  */
    case FI_CANCEL:
      VC_Cmd_form_close (form_ptr, VC_FPOS_ANA);
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_EXECUTE:
      if (VCANGLB_trac == NULL)
      {
        status =
        om$send (msg = message VCCmdAnal.VCTrace (&sts),
            targetid = my_id);
      }
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_RESET:
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case VC_ANGD_OUT:
      FIg_get_value( form_ptr, gadget_label, &dtmp);
      me->bToFile = (dtmp) ? FALSE : TRUE;

      if (me->bToFile)
      {
        FIg_display (form_ptr, VC_ANGD_FIL);
        FIg_display (form_ptr, VC_ANGD_TXT);
        if (VCANGLB_filenam[0] == '\0')
        {
          strcpy (VCANGLB_filenam, getenv("PWD"));
          strcat (VCANGLB_filenam, "/");
          strcat (VCANGLB_filenam, VC_AN_DEFFILE);
        }

        FIg_set_text (form_ptr, VC_ANGD_FIL, VCANGLB_filenam);
      }
      else
      {
        FIg_erase (form_ptr, VC_ANGD_FIL);
        FIg_erase (form_ptr, VC_ANGD_TXT);
      }
      break;

    case VC_ANGD_PPL:
      FIg_get_value( form_ptr, gadget_label, &dtmp);
      me->bToPPL = (dtmp) ? FALSE : TRUE;

      if (me->bToPPL)
      {
        FIg_erase   (form_ptr, VC_ANGD_DYNGRP);
        FIg_display (form_ptr, VC_ANGD_PPLGRP);

        if (me->szPPLNam[0] == '\0')
        {
          IGRchar     *pp;

          pp = getenv("CABLE");

          if (pp != NULL)
          {
            strcpy (me->szPPLNam, getenv("CABLE"));
            strcat (me->szPPLNam, "/");
            strcat (me->szPPLNam, VC_AN_DEFPATH);
          }
          else
            strcpy (me->szPPLNam, VC_AN_DEFPATH);
        }

        if (me->szFNCNam[0] == '\0')
          strcpy (me->szFNCNam, VC_AN_DEFFUNC);

        FIg_set_text (form_ptr, VC_ANGD_PATH, me->szPPLNam);
        FIg_set_text (form_ptr, VC_ANGD_FUNC, me->szFNCNam);
      }
      else
      {
        FIg_erase   (form_ptr, VC_ANGD_PPLGRP);
        FIg_display (form_ptr, VC_ANGD_DYNGRP);
      }
      break;

    case VC_ANGD_FIL:
      FIg_get_text (form_ptr, gadget_label, VCANGLB_filenam);
      break;

    case VC_ANGD_PATH:
      FIg_get_text (form_ptr, gadget_label, me->szPPLNam);
      break;

    case VC_ANGD_FUNC:
      FIg_get_text (form_ptr, gadget_label, me->szFNCNam);
      break;

    case VC_ANGD_PIN:
      FIfld_get_active_row (form_ptr, VC_ANGD_PIN, &nActRow, &i);

      FIfld_set_select (form_ptr, VC_ANGD_PIN, nActRow, 0, FALSE);
      FIfld_set_select (form_ptr, VC_ANGD_PIN, nActRow, 1, FALSE);

      if (me->nLAct >= 0)
      { /*  unselect original    */
        me->bSelected      = FALSE;
        VCANGLB_signam[0]  = '\0';

        FIfld_set_line_color (form_ptr, VC_ANGD_PIN, me->nLAct, 0 , -1);
        if (me->LocType == VC_CABLE_TYPE)
        {
          VCANGLB_select = VC_DEFAN_CABLE;
          me->ConId1.OutId.Conn.Cable.szLeadId[0] = '\0';
          me->ConId1.OutId.Conn.Cable.nCpt = me->nCptNum;
        }
        else
        {
          me->ConId1.OutId.Conn.Term.szModId[0] = '\0';
          me->ConId1.OutId.Conn.Term.szPosId[0] = '\0';
          me->ConId2.OutId.Conn.Term.szModId[0] = '\0';
          me->ConId2.OutId.Conn.Term.szPosId[0] = '\0';

          if (me->ConId2.GRid.objid != NULL_OBJID)
            VCANGLB_select = VC_DEFAN_CBTRAC;
          else
            VCANGLB_select = VC_DEFAN_TERM;
        }
      }

      dp$erase_hilite (msg = &retmsg);

      if (nActRow >= me->nLTOT) break;

      if (me->nLAct != nActRow)
      { /* select the new one   */
        me->nLAct = nActRow;

        FIfld_set_line_color (form_ptr, VC_ANGD_PIN, nActRow, 0 , FI_RED);

        /*    find the trace and signal name.....  */

        me->nActPos = nActRow;

        if (me->LocType == VC_CABLE_TYPE)
        {
          unsigned char   szdumm[VC_MAX_LEAD_ID];

          FIfld_get_text (form_ptr, VC_ANGD_PIN, nActRow, 0, VC_MAX_LEAD_ID,
                           szdumm, &i, &j);

          strcpy (me->ConId1.OutId.Conn.Cable.szLeadId, (IGRchar *)szdumm);

          me->ConId1.OutId.Conn.Cable.nCpt = me->nCptNum;
          VCANGLB_select = VC_DEFAN_SIGNAL;
        }
        else
        {
          FIfld_get_text (form_ptr, VC_ANGD_PIN, nActRow, 0, VC_MAX_MOD_ID,
          (unsigned char *)   me->ConId1.OutId.Conn.Term.szModId, &i, &j);
          FIfld_get_text (form_ptr, VC_ANGD_PIN, nActRow, 1, VC_MAX_POS_ID,
          (unsigned char *)   me->ConId1.OutId.Conn.Term.szPosId, &i, &j);

          if (me->ConId2.GRid.objid != NULL_OBJID)
            VCANGLB_select = VC_DEFAN_PATH;
          else
            VCANGLB_select = VC_DEFAN_SIGNAL;
        }
      }
      else
        me->nLAct = -1;

      status =
      om$send (msg = message VCCmdAnal.VCTrace (&sts),
          targetid = my_id);

      GRfindmod (&disp_info);
      dpmode = GRhd;

      for (i=0; i<VCANGLB_ntrace; i++)
      {
        status =
        om$send (msg = message GRgraphics.GRdisplay
                                 (&retmsg, &me->ModuleInfo.md_env.matrix_type,
                                  me->ModuleInfo.md_env.matrix,
                                  &dpmode, &disp_info),
            targetid = VCANGLB_trac[i].GRid.objid,
            targetos = VCANGLB_trac[i].GRid.osnum,
            senderid = NULL_OBJID);
        as$status( action = RET_STATUS );
      }
      break;

    case VC_ANGD_SEL:
      FIfld_get_active_row (form_ptr, VC_ANGD_SEL, &nActRow, &i);

      FIfld_set_select (form_ptr, VC_ANGD_SEL, nActRow, 0, FALSE);

      if (nActRow >= me->nNumAna) break;

      if (me->bSetCheck[nActRow])
      {
        me->bSetCheck[nActRow] = FALSE;
        FIfld_set_line_color (form_ptr, VC_ANGD_SEL, nActRow, 0 , -1);
      }
      else
      {
        me->bSetCheck[nActRow] = TRUE;
        FIfld_set_line_color (form_ptr, VC_ANGD_SEL, nActRow, 0 , FI_RED);
      }
      break;

  } /* end switch on gadgets */

  quit:
  return OM_S_SUCCESS;
}

method VCGetRetCode ()
{
  me->ret = me->MyRet;

  return OM_S_SUCCESS;
}

method VCReset ( int * sts )
{
  int         status;
  IGRlong     retmsg;

  status = OM_S_SUCCESS;

  /*   Dehighlight trace    */

  dp$erase_hilite (msg = &retmsg);

  VCANGLB_signam[0] = '\0';

  if (me->nLAct >= 0)
  { /*  unselect original    */

    FIfld_set_line_color (me->forms[0].form_ptr, VC_ANGD_PIN,
                              me->nLAct, 0 , -1);
    if (me->LocType == VC_CABLE_TYPE)
    {
      VCANGLB_select = VC_DEFAN_CABLE;
      me->ConId1.OutId.Conn.Cable.szLeadId[0] = '\0';
      me->ConId1.OutId.Conn.Cable.nCpt = me->nCptNum;
    }
    else
    {
      me->ConId1.OutId.Conn.Term.szModId[0] = '\0';
      me->ConId1.OutId.Conn.Term.szPosId[0] = '\0';
      me->ConId2.OutId.Conn.Term.szModId[0] = '\0';
      me->ConId2.OutId.Conn.Term.szPosId[0] = '\0';

      if (me->ConId2.GRid.objid != NULL_OBJID)
        VCANGLB_select = VC_DEFAN_CBTRAC;
      else
        VCANGLB_select = VC_DEFAN_TERM;
    }
  }

  status =
  om$send (msg = message VCCmdAnal.VCTrace (sts),
      targetid = my_id);

  FIg_set_text( me->forms[0].form_ptr, VC_ANGD_SIG, VCANGLB_signam);

  return OM_S_SUCCESS;
}

method VCCleanup ( int * sts )
{
  int         status;
  IGRlong     retmsg;

  /*   Dehighlight trace    */

  dp$erase_hilite (msg = &retmsg);

  _FREE (VCANGLB_trac);
  _FREE (me->LayTab);
  _FREE (me->ProcList);
  _FREE (me->bSetCheck);

  VCANGLB_ntrace   = 0;
  VCANGLB_trac     = NULL;

  VCANGLB_signam[0]     = '\0';
  me->szTagNo[0]     = '\0';
  me->szTagN2[0]     = '\0';

  status =
  om$send(  msg = message VDS_LOCATE.delete ( 0 ) ,
           mode = OM_e_wrt_message,
       targetid = my_id);

  return OM_S_SUCCESS;
}

method VCTrace ( int * sts )
{
  int         status;
  IGRlong     retmsg;
  IGRboolean  bBranched;
  IGRchar    *fptr;

  fptr = me->forms[VC_ANA_FORM].form_ptr;

  _FREE (VCANGLB_trac);
  VCANGLB_ntrace   = 0;

  switch (VCANGLB_select)
  {

    case VC_DEFAN_TERM:
    case VC_DEFAN_CABLE:
      VCANGLB_trac = _MALLOC (1, struct VC_contrace);

      *VCANGLB_trac = me->ConId1;
      break;

    case VC_DEFAN_CBTRAC:
    case VC_DEFAN_PATH:
      status =
      VC_con_trace (&retmsg, me->TransFlags, &me->ConId1, &me->ConId2,
                    &VCANGLB_ntrace, &VCANGLB_trac, VCANGLB_signam);
      as$status();
      break;

    case VC_DEFAN_SIGNAL:
      status =
      om$send (msg = message VCCon.VCConGetTrace
                                  (&retmsg, me->TransFlags, &me->ConId1,
                                   &bBranched, &VCANGLB_ntrace, &VCANGLB_trac,
                                   VCANGLB_signam),
          targetid = me->ConId1.GRid.objid,
          targetos = me->ConId1.GRid.osnum);
      as$status();

      if (!(bBranched)) VCANGLB_select = VC_DEFAN_PATH;
      break;

    default:
      break;
  }

#ifdef MY_DEBUG
  {
    int   i;

    printf (" TRACE TABLE GEN\n");

    for (i=0; i<VCANGLB_ntrace; i++)
    {
      printf (" index, transition %d %d Element <%d %d>\n",
                     VCANGLB_trac[i].nIndex, VCANGLB_trac[i].nTrans,
                     VCANGLB_trac[i].GRid.objid, VCANGLB_trac[i].GRid.osnum);
    }
  }
#endif

  FIg_set_text (fptr, VC_ANGD_SIG, VCANGLB_signam);

  status =
  om$send (msg = message VCCmdAnal.VCANfunc (&(me->MyRet)),
      targetid = my_id);

  return OM_S_SUCCESS;
}

/*=======================================================================*/


method VCAnalyze ( int * sts )
{
  IGRint          status;
  IGRint          i;
  IGRlong         retmsg;
  IGRchar         szDate[80];
  IGRchar        *fptr;
  FILE           *ftosend;

  fptr = me->forms[VC_ANA_FORM].form_ptr;

#ifdef MY_DEBUG
  printf   (" Signal    %s\n",VCANGLB_signam);
  for (i=0; i<VCANGLB_ntrace; i++)
  {
    printf (" Trace tab <%d %d> ", VCANGLB_trac[i].GRid.objid,
                                   VCANGLB_trac[i].GRid.osnum);

    if (VCANGLB_trac[i].OutId.nType == VC_CABLE_TYPE)
      printf (" cable  %d %s\n", VCANGLB_trac[i].OutId.Conn.Cable.nCpt,
                                 VCANGLB_trac[i].OutId.Conn.Cable.szLeadId);
    else
    if (VCANGLB_trac[i].OutId.nType == VC_TERM_TYPE)
      printf (" term   %s %s\n", VCANGLB_trac[i].OutId.Conn.Term.szModId,
                                 VCANGLB_trac[i].OutId.Conn.Term.szPosId);
    else
      printf (" type %d\n", VCANGLB_trac[i].OutId.nType);
  }
#endif

  VD_DLO_SetIndx (NULL, szDate, NULL, NULL);

  ftosend = NULL;

  if (me->bToFile)
  {
    ftosend = fopen (VCANGLB_filenam, "a");
    if (ftosend == NULL)
    {
      UI_status (" FILE CANNOT BE OPENED, revert to display\n");
      me->bToFile = FALSE;
      VCANGLB_filenam[0] = '\0';
      FIg_set_text (fptr, VC_ANGD_FIL, VCANGLB_filenam);
    }
  }

  if (ftosend)
  {
    fprintf (ftosend,
     "=================================================================\n");
    fprintf (ftosend,
     "            CABLE NETWORK Analysis/Report   %s\n",szDate);
    fprintf (ftosend,
     "=================================================================\n");
    fclose (ftosend);
    ftosend = NULL;
  }

  if (me->bToPPL)
  {  /*    execute single PPL function    */
    int      stat;
    char     buffer[MS_MAX_MSG_LENGTH] ;

    VCANGLB_result[0] = '\0';

#ifdef MY_DEBUG
    printf (" execute ppl %s\n",me->szPPLNam);
    printf (" function entry %s\n",me->szFNCNam);
#endif

    ci$exec (stat      = &stat,
             file_name = me->szPPLNam,
             entry     = me->szFNCNam);

    if (stat != CI_S_SUCCESS)
    {
      ci$report_error( status = stat,
                       buffer = buffer);

      UI_status (buffer);
    }

    FIg_set_text (fptr, VC_ANGD_RESL, VCANGLB_result);
  }
  else
  {   /*   execute all marked dynamic functions    */

    for (i=0; i< me->nNumAna; i++)
    {
      VCANGLB_result[0] = '\0';

      if (me->bSetCheck[i])
      {
#ifdef MY_DEBUG
        printf ("Execute analysis %d %s\n", i, me->ProcList[i].Desc);
#endif

        status =
        (me->ProcList[i].fcn) (&retmsg);
      }

      FIfld_set_text (fptr, VC_ANGD_SEL, i, 1, VCANGLB_result, FALSE);
    }
  }

  return OM_S_SUCCESS;
}

end implementation VCCmdAnal;

