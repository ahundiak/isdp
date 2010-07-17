
/* $Id: VCCmdCATi.I,v 1.2 2001/02/20 01:09:26 build Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCCmdCATi.I
 *
 * Description:
 *      Implementation file for command objects that display and
 *      edit attributes.
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCCmdCATi.I,v $
 *  Revision 1.2  2001/02/20 01:09:26  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *  Initial import to CVS
 *
# Revision 1.2  1999/01/19  07:37:22  pinnacle
# Replaced: vccmd/VCCmdCATi.I by aharihar for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/10/30  04:15:40  pinnacle
# Integration of Cable into 02.04.03.04
#
# Revision 1.16  1997/07/22  16:04:22  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.15  1997/07/14  22:51:00  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.14  1997/05/22  14:45:04  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.13  1997/05/19  14:08:04  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.12  1997/04/28  22:35:10  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.11  1997/01/20  22:11:50  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.10  1997/01/09  23:03:58  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.9  1997/01/09  19:56:46  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.7  1996/11/06  18:29:44  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.6  1996/10/25  14:32:04  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.5  1996/10/11  21:53:38  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/03  18:30:16  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:20:20  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:38:18  pinnacle
# Replaced: vccmd/VCCmdCATi.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:11:50  pinnacle
# Created: vccmd/VCCmdCATi.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  18 Jan 1999   Anand   Extended VCATlist for jumpers.
 *
 *************************************************************************/

class implementation VCCmdCAT;

#include "VCmacros.h"
#include "VCCmdPJ.h"
#include "VCCmdForm.h"

#include "VDmem.h"

%safe
#include "VX_FIproto.h"
%endsafe

#include "VRMcForm.h"
#include "vrdbgmacros.h"

/*
#define  MY_DEBUG
*/

from  VCRoot        import  VCGetRep;
from  VCRoot        import  VCGetType;
from  VCRoot        import  VCGetCode;
from  VCRoot        import  VCGetTagNo;
from  VCRoot        import  VCGetProduct;
from  VCRoot        import  VCGetParams;
from  VCRoot        import  VCGetTopology;
from  VCRoot        import  VCGetInstance;
from  VCRoot        import  VCChgParam;

from  VCMac         import  VCGetEquipTag;



/*C  Initialize my instance  */
method init (int  type; char * strptr)
{
  IGRint   status;

  status =
  om$send (msg = message VCAT.init (type, strptr),
          mode = OM_e_wrt_message,
      targetid = my_id);

  me->MyRet          = me->ret;
  me->bTagByp        = FALSE;

  VC_INITSTR (me->CompCode);
  VC_INITSTR (me->CompTag);
  VC_INITSTR (me->CompDesc);

  me->CompNoMtoFlag  = '0';

  me->Product        = VC_PROD_NONE;
  me->nObjType       = VC_TYPE_INIT;
  me->CmdType        = VCCAT_TYPE_NONE;
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

  me->pSysAtt      = me->forms[VC_FRM_MAIN].form_ptr;
  me->pUsrAtt      = me->forms[VC_FRM_SUB].form_ptr;
  me->pCtlAtt      = NULL;

  return OM_S_SUCCESS;
}

method VCATExit( IGRlong     *msg ) /* I/O - return status  */
{
  IGRint     status;

  SetProc( VCATExit ); Begin 

  *msg = MSSUCC;

  __DBGpr_com(" closing sys att form");
  if (me->pSysAtt)
    status = VC_Cmd_form_close (me->pSysAtt, me->FCmain);

  __DBGpr_com(" closing user att form");
  if (me->pUsrAtt)
    status = VC_Cmd_form_close (me->pUsrAtt, me->FCsub);

  me->bSysUp = me->bUsrUp = FALSE;

  __DBGpr_com(" closing ctl att form");
  if (me->pCtlAtt)
    status = VC_Cmd_form_close (me->pCtlAtt, me->FCcontrol);

  __DBGpr_com(" freeing cclist and ccdesc pointers!");
  _FREE (me->CClist);
  _FREE (me->CCdesc);

  End
  return OM_S_SUCCESS;
}

method  VCATGetData (IGRlong    *msg;
             struct  GRid       *CompId)
{
  IGRint       status;

  *msg  = MSSUCC;

  status =
  om$send( msg = message VCRoot.VCGetCode (me->CompCode),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  status =
  om$send( msg  = message VCRoot.VCGetTagNo (me->CompTag),
       targetid = CompId->objid,
       targetos = CompId->osnum );

  status =
  om$send( msg = message VCRoot.VCGetRep (&me->nObjRep, NULL ),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  status =
  om$send( msg = message VCRoot.VCGetType (&me->nObjType),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  status =
  om$send( msg = message VCRoot.VCGetProduct (&me->Product, NULL),
      targetid = CompId->objid,
      targetos = CompId->osnum );

  return OM_S_SUCCESS;
}

/*C  update the sys form */
method VCATSysForm (IGRlong   *msg;    /* I/O - return status */
                    IGRchar   *FormPtr)  /* I - Form to fill up */

{
  IGRboolean  bIsPidRep=FALSE;
  IGRint          status;
  IGRshort        i;
  IGRshort        nNei;
  IGRlong         retmsg;
  struct GRid     Conn[2];

  void            VCCLn_odest ();

  /*A validate  */
  if ( !FormPtr )
    return OM_S_SUCCESS;

  if (me->nObjType & VC_GEN_CABLE)
  {
    FIg_display (FormPtr, VCCAT_GROUP_CABLE);

    for (i=0; i<2; i++)
    {
      Conn[i].objid   = NULL_OBJID;
      Conn[i].osnum   = me->ModuleInfo.md_id.osnum;

#ifdef MY_DEBUG
      printf ("getconlist %d\n", i);
#endif

      status =
      om$send(msg    = message VCRoot.VCGetTopology
                                  (&retmsg, i, &nNei, &Conn[i],
                                    NULL, NULL, NULL),
            targetid = me->CompId.objid,
            targetos = me->CompId.osnum);
  
      /*      set origin/destination id's ...........   */

#ifdef MY_DEBUG
      printf ("getconlist ret %d\n", nNei);
      printf ("getconlist to odest <%d %d>\n", Conn[i].objid, Conn[i].osnum);
#endif

        VCCLn_odest (FormPtr, (IGRint) i, &Conn[i], &me->ModuleInfo);
    }
  }
  else
  if (me->nObjType & VC_GEN_TERM)
  {
    IGRchar     szEQP[VC_MAX_EQ_ID];

    VC_INITSTR (szEQP);

    FIg_display (FormPtr, VCCAT_GROUP_TERM);

    status =
    om$send(msg  = message VCMac.VCGetEquipTag
                                  (&retmsg, szEQP,  &me->ModuleInfo),
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum);

    FIg_set_text ( FormPtr, VCCAT_TRM_EQUIP_NAME, szEQP);
  }

#ifdef MY_DEBUG
  printf (" cable o-d done\n");
#endif

  FIg_set_text ( FormPtr, VCCAT_COMP_CODE, me->CompCode );

  FIg_set_text ( FormPtr, VCCAT_DESC_FIELD, me->CompDesc );

  FIg_set_text ( FormPtr, VCCAT_LINK_NAME, me->CompTag );

  status = 
  om$send (msg = message VCAT.VCAT_sdsp (&retmsg, FormPtr),
      targetid = my_id);

  if ( me->CompId.objid != NULL_OBJID )
  {
    status =
    om$send( msg      = message VCRoot.VCGetRep (&me->nObjRep, NULL),
      targetid = me->CompId.objid,
      targetos = me->CompId.osnum );
    as$status( action = RET_STATUS );

    if ( bVC_IS_PID( me->nObjRep ) )
      bIsPidRep = TRUE;
  }
  else
  {
    /*A look for the active representation */
    if ( bVC_IS_PID_ACTIVE )
      bIsPidRep = TRUE;
  }

/*      no PID scale for now.....
  if( bIsPidRep )
  {
    FIg_display( FormPtr, VCCAT_LBL_SYMB_SCALE );
    FIg_display( FormPtr, VCCAT_SYMBOL_SCALE );
  }
  else
*/

  {
    FIg_erase( FormPtr, VCCAT_LBL_SYMB_SCALE );
    FIg_erase( FormPtr, VCCAT_SYMBOL_SCALE );
  }

#ifdef MY_DEBUG
  printf ("sysform done\n");
#endif

  return  OM_S_SUCCESS;
}

/*C  */
method  VCATChgLnAttr (IGRlong   *msg;    /* I/O - return status  */
               struct  GRid      *CompId;    /* I -  Link Id    */
               struct  GRid      *SysId;    /* I - System  Id  */
               struct  GRid      *UsrId)    /* I - User Id    */

{
  IGRint      status;
  IGRlong      retmsg;

  /*A initialization */
  *msg = MSSUCC;
  
  /*A validity check */
  if ( !CompId )  return  OM_E_INVARG;
  
  /*A change the system, user and missing parameters of
      the link */

  if (SysId)
  {
    status =
    om$send( msg = message VCRoot.VCChgParam
                            (&retmsg, (IGRshort) VC_SYSTEM, SysId),
    targetid = CompId->objid,
    targetos = CompId->osnum );
    as$status( action = RET_STATUS );
  }

  if (UsrId)
  {
    status =
    om$send( msg = message VCRoot.VCChgParam
                             (&retmsg, (IGRshort) VC_USER, UsrId),
    targetid = CompId->objid,
    targetos = CompId->osnum );
    as$status( action = RET_STATUS );
  }

  return  OM_S_SUCCESS;
}

method  VCATSysFormNot (int      gadget_label;  /* I : gadget label*/
                        double   value;    /* I :          */
                        char    *form_ptr;  /* I : sys form ptr  */
                        char    *UsrFormPtr)  /* I : user form Ptr */

{
  IGRint       status;
  IGRlong      retmsg;
  IGRint       i, idsp, jdsp;
  IGRint       iType;
  IGRchar      szFld[VC_CMD_BUFSIZE];
  IGRboolean   bIsPidRep=FALSE;
  IGRdouble    dValue;

  VC_INITSTR (szFld);

  dValue = 0.0;

  me->MyRet = gadget_label;

  FIg_set_text( form_ptr, FI_MSG_FIELD, "" );

  FIfld_get_type (form_ptr, gadget_label, 0, &iType);
  if (iType == FI_ALPHA)
  {
    FIg_get_text (form_ptr, gadget_label, szFld);
    szFld[VC_CMD_BUFSIZE-1] = '\0';
  }

  switch( gadget_label )
  {
    case VCCAT_LOAD_CABLE:
    me->MyRet = VCCAT_LOAD_CABLE;
    _put_response( resp = VCCAT_LOAD_CABLE );
    break;

    case VCCAT_COMP_CODE:
    if (VC_EMPTYSTR(szFld)) break;

/*TBD : move type of representation to instance data */

    if ( me->CompId.objid != NULL_OBJID )
    {
      IGRshort    Rep;

      status =
      om$send( msg      = message VCRoot.VCGetRep (&Rep, NULL),
        targetid = me->CompId.objid,
        targetos = me->CompId.osnum );
      as$status( action = RET_STATUS );
      if ( bVC_IS_PID( Rep ) )
        bIsPidRep = TRUE;
    } else {
      /*A look for the active representation */
      if ( bVC_IS_PID_ACTIVE )
        bIsPidRep = TRUE;
    }
  

    if ( strlen( szFld ) > 0 )
    {
      IGRboolean  bFound=FALSE;
      
      jdsp = 0;

      /* check for the cable code in DB */

      for (i=0;i<me->nCC; i++)
      {
        idsp = i * VC_MAX_CCODE;
        jdsp = i * VC_MAX_SDESC;

        if (strcmp (szFld, &me->CClist[idsp]) == 0)
        {
          bFound = TRUE;
          break;
        }
      }

      if ( !bFound )
      {
        FIg_set_text( form_ptr, FI_MSG_FIELD,
                                 "Cable Code Not Found in Database" );
      }
      else
      {
        strcpy (me->CompDesc, &me->CCdesc[jdsp]);
        FIg_set_text ( form_ptr, VCCAT_DESC_FIELD, me->CompDesc );

        FIg_set_text( form_ptr, FI_MSG_FIELD,"" );
        strcpy( me->CompCode, szFld );
        me->bCCch = TRUE;
      }
    }
    break;

    case VCCAT_LINK_NAME:    /* tag number */

    /*A if diff from the previous one */
    if( strcmp(szFld, me->CompTag) )
    {
      IGRshort    nST;

      status = VC_TAGchk (&nST, me->nTagCat, szFld);
      if (nST < 0)
      {
        me->bTGch = TRUE;
        strcpy( me->CompTag, szFld );
      }
      else
      {
        FIg_set_text (form_ptr, FI_MSG_FIELD, "Duplicate Tag Number");

        FIg_set_text (form_ptr, gadget_label, me->CompTag);
      }
    } 
    break;

    case VCCAT_NO_MTO:
    {
      IGRint    State=0;
    
      FIg_get_state( form_ptr, gadget_label, &State );

      if ( !State )
      {
        me->CompNoMtoFlag = '0';
        strcpy (szFld, "");
      }
      else
      {
        me->CompNoMtoFlag = '1';
        strcpy (szFld,"y");
      }

      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_NO_MTO_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
    }
    break;

    case VCCAT_NOTES:
      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_COMP_NOTE_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCCAT_ZONE:
      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_ZONE_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCCAT_UNIT:
      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_UNIT_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCCAT_PARTNUM:
      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_PART_NUM_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCCAT_SYSTEM_NAME :
      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_SYST_NAME_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCCAT_CONST_STATUS :
      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_CONSTR_STAT_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

/*     pid scle ......
    case VCCAT_SYMBOL_SCALE:
    FIg_get_value( form_ptr, gadget_label, &dValue );
    strcpy( ListAttr[0].name, VC_N_PID_SCALE_DB );
    bCollMod = TRUE;
    break;
*/

    case VCCAT_CHGREC:
      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_CHG_REQ_NUM_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCCAT_APPROV_STATUS:
      status =
      om$send (msg = message VCAT.VCAT_set
                              (&retmsg, VC_SYSTEM, VC_N_APPRV_STAT_AN, 
                                 AC_ATTRIB_TEXT, szFld, 0.0),
          targetid = my_id);
      break;

    case VCCAT_USR_ATTR_BUTTON :
      /*A display the form */
      VC_Cmd_form_open (UsrFormPtr, me->FCsub);

      me->bUsrUp = TRUE;

      status =
      om$send (msg = message VCAT.VCAT_udsp (&retmsg, UsrFormPtr),
          targetid = my_id);

      me->MyRet = VC_RTC_BTN_USRPAR;
      _put_response( resp = VC_RTC_BTN_USRPAR );
      break;

    case FI_RESET:
    /*A reset the system attributes */
      status =
      om$send( msg = message VCAT.VCAT_act (&retmsg),
          targetid = my_id );

/*TBD : Do I need to reset all the sub forms also */

      if ( me->CompId.objid != NULL_OBJID )
      {
        /*A get the Link's data ( Modify Cmd ) */
        status =
        om$send( msg = message VCCmdCAT.VCATGetData (&retmsg, &me->CompId ),
            targetid = my_id );
      }

/*TBD : do we need to do any processing for place command */

      /*A fill up the sys form */
      status =
      om$send( msg = message VCCmdCAT.VCATSysForm
                                      (&retmsg, form_ptr),
          targetid = my_id );
      me->MyRet = VC_RTC_RESET;
      break;
  
    case FI_ACCEPT :
      if (VC_EMPTYSTR(me->CompCode))
      {
        FIg_set_text( form_ptr, FI_MSG_FIELD,
                                        "cable code not specified" );
        break;
      }

      if (VC_EMPTYSTR(me->CompTag))
      {
        FIg_set_text( form_ptr, FI_MSG_FIELD,
                                        "Tag Number not specified" );
        break;
      }

      /*  store values     set up attrboxes   */
      status =
      om$send (msg = message VCAT.VCAT_sav (&retmsg),
          targetid = my_id);

      VC_Cmd_form_close (form_ptr, me->FCmain);

      me->bSysUp = FALSE;

      me->MyRet = VC_RTC_ACCEPT;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    case FI_EXECUTE :
      if (VC_EMPTYSTR(me->CompCode))
      {
        FIg_set_text( form_ptr, FI_MSG_FIELD,
                                        "cable code not specified" );
        break;
      }

      if (VC_EMPTYSTR(me->CompTag))
      {
        FIg_set_text( form_ptr, FI_MSG_FIELD,
                                        "Tag Number not specified" );
        break;
      }

      /*  store values     set up attrboxes   */
      status =
      om$send (msg = message VCAT.VCAT_sav (&retmsg),
          targetid = my_id);

      me->MyRet = VC_RTC_DONE;
      _put_response( resp = EX_FORM_FINISHED );
      break;
        
    case FI_CANCEL :
      VC_Cmd_form_close (form_ptr, me->FCmain);

      me->bSysUp = FALSE;

      me->MyRet = VC_RTC_CANCEL;
      _put_response( resp = EX_FORM_FINISHED );
      break;
      
    default :
      return  OM_S_SUCCESS;
  }
    
  quit:
  return  OM_S_SUCCESS;
}
 
/*C user form notification */ 

method  VCATUsrFormNot (int      gadget_label;
                        double   value;
                        char    *form_ptr)

{
  IGRint    status;
  IGRint    sel_flag=0;
  IGRint    r_pos;
  IGRint    row = 0;
  IGRint    num_rows;
  IGRint    nAtt;
  IGRint    length, algt;
  IGRchar   szValue[VC_CMD_BUFSIZE];
  IGRchar   szText[VC_CMD_BUFSIZE];
  IGRlong   retmsg;

  FIg_set_text( form_ptr, FI_MSG_FIELD, "" );

  /*A need to write form_notif here */
  switch ( gadget_label )
  {
    case VCCAT_MFL_USRPAR:
      /*A nothing required */
      break;

    case FI_RESET:
      FIfld_set_num_rows( form_ptr, VC_GDG_MFL_USERPAR, 0);
      break;

    case FI_EXECUTE:
    case FI_ACCEPT: 
      nAtt = 0;
      status =
      om$send (msg = message VCAT.VCAT_set
                                  (&retmsg, VC_USER, NULL, 
                                        AC_ATTRIB_TEXT, NULL, 0.0),
          targetid = my_id);

      FIfld_get_num_rows( form_ptr, VCCAT_MFL_USRPAR, &num_rows );

      for ( row=0; row<num_rows; row++ )
      {
        /* Get name's length */
        length = 0;
        FIfld_get_text_length (form_ptr, VC_GDG_MFL_USERPAR, row, 0, &length);
        FIfld_get_text_length (form_ptr, VC_GDG_MFL_USERPAR, row, 1, &algt);

        if (length > 1)
        {
          FIfld_get_text( form_ptr, VC_GDG_MFL_USERPAR, row, 0, length,
                          (unsigned char *) szText, &sel_flag, &r_pos );

          if ((algt >0) && (algt < VC_CMD_BUFSIZE))
            FIfld_get_text( form_ptr, VC_GDG_MFL_USERPAR, row, 1, algt,
                          (unsigned char *) szValue, &sel_flag, &r_pos );
          else
            VC_INITSTR (szValue);

          status =
          om$send (msg = message VCAT.VCAT_set
                                  (&retmsg, VC_USER, szText,
                                       AC_ATTRIB_TEXT, szValue, 0.0),
              targetid = my_id);
#ifdef MY_DEBUG
          printf ("create usratt %d len %d %s value %s\n",
                               nAtt,length,szText, szValue);
#endif
          nAtt++;
        }
      }

      FIg_set_state_off (form_ptr, gadget_label);

      FIg_set_state_off (form_ptr, VC_GDG_BTN_USRPAR);
      FIg_set_state_off (form_ptr, VC_GDG_BTN_LOADATT);

    case FI_CANCEL:     /* Member of group   */
      VC_Cmd_form_close (form_ptr, me->FCsub);

      me->bUsrUp = FALSE;

      _put_response( resp = EX_FORM_FINISHED );
      break;
    
    default :
      break;

  }/* end of switch on gadgets */

  quit:
#ifdef MY_DEBUG
  printf ("end usrformnot\n");
#endif
  return  OM_S_SUCCESS;
}

/*C  loads the identified cable's info in to sys form  */
/*TBD  Add return status as an argument to this method    */

method  VCATLoadLnAttr (char  *SysFormPtr;  /* I : System form to fill up */
                 struct GRid  *CompId)      /* I : link to copy from */
{
  IGRint       status;
  IGRlong      retmsg;

  /*A return error if no object is found */
  if ( !CompId || CompId->objid == NULL_OBJID )
    return  OM_E_INVARG;

#ifdef MY_DEBUG
  printf (" Loadlnatt for <%d %d>\n", CompId->objid, CompId->osnum);
#endif

  /*A get the system, user and missing parameters from comp */
  status =
  om$send( msg = message VCAT.VCAT_load (&retmsg, CompId),
    targetid = my_id );

  /*A update the sys form */  
  status =
  om$send( msg = message VCCmdCAT.VCATSysForm
                                  (&retmsg, SysFormPtr ),
      targetid = my_id );

#ifdef MY_DEBUG
  printf ("Leave LoadLnAttr\n");
#endif

  return  OM_S_SUCCESS;
}

method VCATlist (IGRlong      *msg)
{
  IGRlong     retmsg;
  IGRint      status;
  IGRshort    nC1, nC2;
  IGRchar    *p1;
  IGRchar    *p2;

  SetProc( Md VCATlist ); Begin 

  *msg = MSSUCC;

  _FREE (me->CClist);
  _FREE (me->CCdesc);
  nC1 = nC2 = 0;

  if (me->CmdProd == VC_PROD_NONE)
  {
    me->Product  = VC_PROD_NONE;
    me->nFOstart = -1;
  }

  if (me->nObjType & VC_GEN_TERM)
  {
    if (me->Product != VC_PROD_FO)
    {
      vc$elterm_idx (p_count = &nC1,
                     osnum   = me->My_OS);

      me->nFOstart = nC1;
    }

    if (me->Product != VC_PROD_ELEC)
      vc$foterm_idx (p_count = &nC2,
                     osnum   = me->My_OS);
  }
  else
  if (me->nObjType & VC_GEN_CABLE)
  {
    if (me->Product != VC_PROD_FO)
    {
      vc$elcab_idx (p_count = &nC1,
                    osnum   = me->My_OS);

      me->nFOstart = nC1;
    }

    if (me->Product != VC_PROD_ELEC)
      vc$focab_idx (p_count = &nC2,
                    osnum   = me->My_OS);
  }
  else
  if (me->nObjType & VC_GEN_GUIDE)
  {
    vc$guide_idx (p_count = &nC1,
                  osnum   = me->My_OS);
  }
  /* added by alwin for CR179701619 */
  else
  if (me->nObjType & VC_GEN_JUMPER)
  {
    __DBGpr_com( " Fetching the Info from DB..." );
    vc$jumper_idx ( p_count = &nC1,
		   /***
		   p_desc   = &me->CCdesc,
		   p_codes  = &me->CClist,
		   ***/
                   osnum    = me->My_OS );
  }
  /* added by alwin for CR179701619 */

  me->nCC = nC1 + nC2;

  if (me->CmdProd == VC_PROD_NONE)
    me->nFOstart = nC1;
  else
    me->nFOstart = -1;

  if (me->nCC > 0)
  {
    me->CClist = _MALLOC (me->nCC * VC_MAX_CCODE, IGRchar);
    me->CCdesc = _MALLOC (me->nCC * VC_MAX_SDESC, IGRchar);
    if (me->CClist == NULL) 
    {
       __DBGpr_com( " Memory Allocation Error !!! " );
       End
       return (OM_E_NODYNMEM);
    }

    p1 = me->CClist;
    p2 = me->CCdesc;

    if (me->nObjType & VC_GEN_TERM)
    {
      if (me->Product != VC_PROD_FO)
      {
        vc$elterm_idx (p_count = &nC1,
                       p_desc  = p2,
                       p_codes = p1,
                       osnum   = me->My_OS);
        p1 += (nC1 * VC_MAX_CCODE);
        p2 += (nC1 * VC_MAX_SDESC);
      }

      if (me->Product != VC_PROD_ELEC)
      {
        vc$foterm_idx (p_count = &nC2,
                       p_desc  = p2,
                       p_codes = p1,
                       osnum   = me->My_OS);
      }
    }
    else
    if (me->nObjType & VC_GEN_CABLE)
    {
      if (me->Product != VC_PROD_FO)
      {
        vc$elcab_idx (p_count = &nC1,
                      p_desc  = p2,
                      p_codes = p1,
                      osnum   = me->My_OS);

        p1 += (nC1 * VC_MAX_CCODE);
        p2 += (nC1 * VC_MAX_SDESC);
      }

      if (me->Product != VC_PROD_ELEC)
      {
        vc$focab_idx (p_count = &nC2,
                      p_desc  = p2,
                      p_codes = p1,
                      osnum   = me->My_OS);
      }
    }
    else
    if (me->nObjType & VC_GEN_GUIDE)
    {
      vc$guide_idx (p_count = &me->nCC,
                    p_desc  = me->CCdesc,
                    p_codes = me->CClist,
                    osnum   = me->My_OS);
    }
    /*added by alwin for CR179701619 */
    else 
    if( me->nObjType & VC_GEN_JUMPER )
    {
      vc$jumper_idx (p_count = &me->nCC,
                    p_desc  = me->CCdesc,
                    p_codes = me->CClist,
                    osnum   = me->My_OS);
    }
    /*added by alwin for CR179701619 */
  }

#ifdef MY_DEBUG
  printf (" set compcode list %d entries, split\n",me->nCC,me->nFOstart);
#endif

  End
  return (OM_S_SUCCESS);
}

method VCATcheck (IGRlong      *msg)
{
  IGRint      status;
  IGRint      i;
  IGRshort    nST;

  *msg = VC_RTC_ALLOK;
  me->ret = VC_RTC_ALLOK;

  if (me->nCC <= 0)
  {
    status =
    om$send( msg = message VCCmdCAT.VCATlist (msg),
        targetid = my_id );
  }

  for (i=0; i<me->nCC; i++)
  {
#ifdef MY_DEBUG
    printf ("compcode check %s %s\n",me->CompCode, (&me->CClist[i*VC_MAX_CCODE]));
#endif
    if (strcmp (&me->CClist[i*VC_MAX_CCODE], me->CompCode) == 0) goto CCOK;
  }

  UI_status ("Invalid comp_code");
  *msg = VC_RTC_ERROR;
  me->ret = VC_RTC_ERROR;
  return (OM_S_SUCCESS);

  CCOK:

  if (me->bTagByp) return (OM_S_SUCCESS);

  if (VC_EMPTYSTR(me->CompTag))
  {
    UI_status ("Missing Tag Number");
    *msg = VC_RTC_ERROR;
    me->ret = VC_RTC_ERROR;
    return (OM_S_SUCCESS);
  }

  VC_TAGchk (&nST, me->nTagCat, me->CompTag);

  if (nST >= 0)
  {
    UI_status ("Duplicate Tag Number");
    *msg = VC_RTC_ERROR;
    me->ret = VC_RTC_ERROR;
  }

  return (OM_S_SUCCESS);
}

/*   split out function to fill tag numbers   */

void  VCCLn_odest (char      *form_ptr,
                   int        odest,
            struct GRid      *connId,
            struct GRmd_env  *md_env)

{
  IGRint      status;
  IGRlong     retmsg;
  IGRchar     szTag[VC_MAX_TAGNO];
  IGRchar     szEQP[VC_MAX_EQ_ID];

  VC_INITSTR (szTag);
  VC_INITSTR (szEQP);

  if (connId->objid != NULL_OBJID)
  {
#ifdef MY_DEBUG
    printf("cable end %d:- get tags\n",odest);
#endif

    status =
    om$send(msg  = message VCRoot.VCGetTagNo (szTag),
        senderid = NULL_OBJID,
        targetid = connId->objid,
        targetos = connId->osnum);

    status =
    om$send(msg  = message VCMac.VCGetEquipTag (&retmsg, szEQP, md_env),
        senderid = NULL_OBJID,
        targetid = connId->objid,
        targetos = connId->osnum);
  }

#ifdef MY_DEBUG
    printf("cable end %d: found tags %s %s \n",odest, szTag, szEQP);
#endif

  switch (odest)
  {
    case 0:
    FIg_set_text(form_ptr,VCCAT_FROM_CONN_NAME, szTag );
    FIg_set_text(form_ptr,VCCAT_FROM_EQUIP_NAME, szEQP );
    break;

    case 1:
    FIg_set_text(form_ptr,VCCAT_TO_CONN_NAME, szTag);
    FIg_set_text(form_ptr,VCCAT_TO_EQUIP_NAME, szEQP );
    break;
  }

  return;
}

method  VCAT_sdsp (IGRlong     *sts;
                   IGRchar     *fptr)
{
  IGRshort        iloop;
  IGRshort        iAttr;
  IGRint          inum;

  *sts = MSSUCC;
  inum = om$dimension_of (varray = me->Syscoll);

  for (iloop = 0; iloop < inum; iloop++)
  {
    iAttr = VCDB_AttrNamToNum (me->Syscoll[iloop].name);

#ifdef MY_DEBUG
    printf (" sysatt %d %d, %s %s\n", iloop, iAttr,
                          me->Syscoll[iloop].name,
                          me->Syscoll[iloop].desc.value.att_txt);
#endif

    switch (iAttr)
    {
      case VC_X_PART_NUM_AN:
        FIg_set_text (fptr, VCCAT_PARTNUM,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_UNIT_AN:
        FIg_set_text (fptr, VCCAT_UNIT,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_SYST_NAME_AN:
        FIg_set_text (fptr, VCCAT_SYSTEM_NAME,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_APPRV_STAT_AN:
        FIg_set_text (fptr, VCCAT_APPROV_STATUS,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_CONSTR_STAT_AN:
        FIg_set_text (fptr, VCCAT_CONST_STATUS,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_CHG_REQ_NUM_AN:
        FIg_set_text (fptr, VCCAT_CHGREC,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_COMP_NOTE_AN:
        FIg_set_text (fptr, VCCAT_NOTES,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_ZONE_AN:
        FIg_set_text (fptr, VCCAT_ZONE,
                                me->Syscoll[iloop].desc.value.att_txt);
        break;

      case VC_X_NO_MTO_AN:
        if (me->Syscoll[iloop].desc.value.att_txt[0] != 'y')
          FIg_set_state_off (fptr, VCCAT_NO_MTO);
        else
          FIg_set_state_on  (fptr, VCCAT_NO_MTO);
        break;
    }
  }

  return (OM_S_SUCCESS);
}

end implementation VCCmdCAT;

