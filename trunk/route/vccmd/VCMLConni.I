/* $Id: VCMLConni.I,v 1.4 2002/05/24 21:41:49 anand Exp $  */

/*************************************************************************
 * I/CABLE
 *
 * File:  vccmd/VCMLConni.I
 *
 * Description:
 *      Implementation file for place cable command object
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VCMLConni.I,v $
 *  Revision 1.4  2002/05/24 21:41:49  anand
 *  Second set of bug fixes for the cable lead enhancement.
 *  Fixes errors in model arising out of merge-cable workflows.
 *  Ensure placeholders are created for markers for DB driven
 *  cables. Major shuffling of code in Sketch cable state table.
 *
 *  Revision 1.3  2002/05/08 15:48:23  anand
 *  Files added/modified for sub-cable functionality.
 *
 *  Revision 1.2  2001/02/20 01:09:49  build
 *  Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *  Revision 1.1.1.1  2001/01/04 21:12:28  cvs
 *  Initial import to CVS
 *
# Revision 1.5  1999/02/03  05:25:50  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by sbilla for route
#
# Revision 1.4  1998/10/16  06:30:54  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by sbilla for route
#
# Revision 1.3  1998/06/24  19:10:00  pinnacle
# tr179801131
#
# Revision 1.2  1998/06/15  20:09:52  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by lawaddel for route
#
# Revision 1.6  1998/04/20  04:12:24  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by kddinov for route
#
# Revision 1.5  1998/02/20  05:33:58  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by apazhani for route
#
# Revision 1.4  1998/02/19  06:07:54  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by apazhani for route
#
# Revision 1.3  1998/01/21  06:57:26  pinnacle
# Replaced: vccmd/VCMLConni.I for: TR 179800035 by aharihar for route
#
# Revision 1.2  1997/11/30  16:07:52  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by r250_int for route
#
# Revision 1.23  1997/11/10  11:04:32  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by apazhani for cabling
#
# Revision 1.22  1997/10/14  10:04:44  pinnacle
# Replaced: vccmd/VCMLConni.I for: CR#:179701618 by aharihar for cabling
#
# Revision 1.21  1997/07/22  16:05:30  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.20  1997/07/14  22:53:36  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.19  1997/05/22  14:44:30  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.18  1997/05/19  14:07:46  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.17  1997/05/10  15:17:38  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.16  1997/05/07  14:19:42  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.15  1997/04/28  22:33:54  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.14  1997/03/12  21:59:18  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.13  1997/01/20  22:12:40  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.12  1997/01/09  23:06:14  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.11  1997/01/09  19:58:02  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.9  1996/11/15  22:29:56  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.8  1996/11/06  18:28:52  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.7  1996/10/29  22:22:02  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.6  1996/10/25  14:31:10  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.5  1996/10/11  21:53:04  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.4  1996/10/03  18:29:58  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.3  1996/09/26  21:19:58  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.2  1996/09/20  21:39:06  pinnacle
# Replaced: vccmd/VCMLConni.I for:  by hverstee for cabling
#
# Revision 1.1  1996/08/28  22:20:16  pinnacle
# Created: vccmd/VCMLConni.I by hverstee for cabling
#
 *
 * History:
 *  06/18/96      hv      New
 *  10/14/97    Anand   CR 179701618 - Implements search capability
 *			in fields with associative lists.
 *  11/10/97    Alwin   TR 179702063 - Checked the freeing process and  
 *                      corrected and set the freed pointers to NULL.
 *  01/21/98    Anand   TR 179800035 - Software locks up. 
 *  02/20/98	Alwin	Check has been made whether the user keys in search
 *			string or picking it from the associative list. If user
 *			picks the compdoe from list, don't call search the
 *			algorithm. TR179800042
 *  06/02/98    law     TR179800042 - Add call to VDfrm_fld_set_sub_list.
 *  10/12/98    Reddy   TR179801269 - Uncommented  lines default selection
 *  02/02/99    Reddy   TR179900132 - terminal tag constants wrongly allocated 
 *                      cable instance varible .
 *************************************************************************/


class implementation VCCmdPC;

#include "VDfrm.h"

#include <stdlib.h>
#include <string.h>   /* Added for CR 179701618 by Anand */
#include "VCproto.h"

#include "VCTagDef.h"
#include "VDmem.h"
#include "vrdbgmacros.h"
#include "vc_default.h"

extern IGRint   VCGetDefaultInfo( IGRint, IGRint, char *);

/*
#define MY_DEBUG
*/

#define MIN_DIST    1.0     /* in MM? ASK BRUNO */


/***********  EXTERN ***********/

from  GRgraphics    import  GRdelete;
from  VCCable	    import  VCGetInfoSubCab;


method init ( int type ; char * str_ptr )
{
  int         status;
  IGRlong     retmsg;
  int         i;
  double      dSelOn   = 1;
  double      dSelOff  = 0;

  extern
  int         GRstatus_display_button();

#ifdef MY_DEBUG
  printf (" init entered, do superclasses\n");
#endif

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VCCmdCAT.init( type, str_ptr ),
                    targetid = my_id);

  me->pSysAtt       = me->status_display_form_ptr;
  me->pUsrAtt       = me->forms[VCC_PC_USR_ATTR_FORM].form_ptr;
  me->pCtlAtt       = me->forms[VCC_PC_CONTROL_FORM].form_ptr;
  me->PkLdForm	    = me->forms[VCC_PC_SPL_CAB_FORM].form_ptr;

  me->CmdType       = VCCAT_TYPE_ADD;

  me->nRWtr         = 0;
  me->RWTrac        = NULL;

/* 4-98 KDD use single point default selection function */

  status = VCGetDefaultInfo( (IGRint) me->iSynType,
                                VC_GET_CAB_TAG, (char *) &me->nTagCat);
 
  status = VCGetDefaultInfo( (IGRint) me->iSynType,
                                VC_GET_PRODUCT, (char *) &me->Product);

  switch (me->iSynType)
  {
    case VC_CMDTYP_GEN:

       me->Product       = VC_PROD_NONE; //Uncommented for the TR179801269

      FIg_display (me->pCtlAtt, VCPCAB_GENHEAD);
      break;

    case VC_CMDTYP_EL:
      me->Product       = VC_PROD_ELEC; //Uncommented for the TR179801269
  //  me->nTagCat       = VCTAG_CAT_ELCABLE;
      FIg_display (me->pCtlAtt, VCPCAB_ELHEAD);
      break;

    case VC_CMDTYP_FO:
      me->Product       = VC_PROD_FO;  //Uncommented for the TR179801269
  //  me->nTagCat       = VCTAG_CAT_FOCABLE;
      FIg_display (me->pCtlAtt, VCPCAB_FIBHEAD);
      break;

    default:
      _put_response( resp = TERMINATE );
      goto quit;
  }

  me->CmdProd   = me->Product;
  me->nObjType  = VC_GEN_CABLE;

  me->FCmain    = VC_FPOS_PC_MAIN;
  me->FCsub     = VC_FPOS_PC_SUB;
  me->FCcontrol = VC_FPOS_PC_CTRL;

  status =
  om$send (msg = message VCCmdCAT.VCATlist (&retmsg),
      targetid = my_id);

#ifdef MY_DEBUG
  printf (" init route cable, product %d\n",me->Product);
#endif

  status = 
  om$send( msg     = message VCCmdPC.VCinit (&retmsg),
          targetid = my_id);


  if (bVC_IS_2D (me->nACTrep))
  {
    me->bDepth        = TRUE;
    me->bOrtho        = TRUE;
    FIg_set_value (me->pCtlAtt, VCPCAB_ZDEPTH,     dSelOn);
    FIg_set_value (me->pCtlAtt, VCPCAB_CONSTRAINT, dSelOn);
  }
  else
  {
    me->bDepth        = FALSE;
    me->bOrtho        = FALSE;
    FIg_set_value (me->pCtlAtt, VCPCAB_ZDEPTH,     dSelOff);
    FIg_set_value (me->pCtlAtt, VCPCAB_CONSTRAINT, dSelOff);
  }


#ifdef MY_DEBUG
  printf (" Get collections\n");
#endif

  status = 
  om$send( msg     = message VCAT.VCAT_act (&retmsg),
          targetid = my_id);

  FIg_display (me->pSysAtt, VCCAT_GROUP_CABLE);

  /*A Initialize form contents */
  status = 
  om$send( msg  = message VCCmdCAT.VCATSysForm 
                                   (&retmsg, me->pSysAtt),
       targetid = my_id);

#ifdef MY_DEBUG
  printf (" set notif/cclist %d \n", me->nCC);
#endif

  FIfld_set_list_num_rows( me->pSysAtt, VCCAT_COMP_CODE,
                             0, (IGRint) me->nCC);
  FIfld_set_list_num_rows( me->pCtlAtt, VCPCAB_COMPCODE, 0, (IGRint) me->nCC);

  if(me->nCC < 5) 
  {
    FIfld_set_list_scroll( me->pSysAtt, VCCAT_COMP_CODE, 0, 0 );
    FIfld_set_list_scroll( me->pCtlAtt, VCPCAB_COMPCODE, 0, 0 );
  }
  else
  {
    FIfld_set_list_scroll( me->pSysAtt, VCCAT_COMP_CODE, 1, 0 );
    FIfld_set_list_scroll( me->pCtlAtt, VCPCAB_COMPCODE, 1, 0 );
  }

  for(i=0;i<me->nCC; i++)
  {
    FIfld_set_list_text( me->pSysAtt, VCCAT_COMP_CODE, i, 0,
			    (IGRuchar *)&me->CClist[i*VC_MAX_CCODE], FALSE);
    FIfld_set_list_text( me->pCtlAtt, VCPCAB_COMPCODE, i, 0,
			    (IGRuchar *)&me->CClist[i*VC_MAX_CCODE], FALSE);
  }

  FIg_erase( me->PkLdForm, VCSUBCAB_USED_GROUP );

  status = GRstatus_display_button(1);

#ifdef MY_DEBUG
  printf (" init done \n");
#endif

  quit:
  return OM_S_SUCCESS;
}

method VCinit ( long * sts )
{
  int             i;
  IGRlong         retmsg;

  me->bTagByp       = FALSE;

  /*A initialize instance data with input or default null values */

  me->nPtObjs       = 0;
  me->nMyPnts       = 0;
  me->nSecPts       = 0;
  me->nMySect       = 0;

  me->dLAST[0]      = 0.0;
  me->dLAST[1]      = 0.0;
  me->dLAST[2]      = 0.0;

  me->bBrk          = FALSE;
  me->bGoing        = FALSE;
  me->bBegCP        = TRUE;

  me->nPrev         = -1;
  me->nLdig         = -1;
  me->nDdig         = -1;

  for (i=0; i<100; i++)
  {
    me->mySect[i].cbstat  = VC_STATUS_INIT;
    me->mySect[i].type    = -1;
    me->mySect[i].iFrom   = 0;
    me->mySect[i].iTo     = 0;
    me->mySect[i].numvert = -1;
    me->mySect[i].strno   = -1;
    me->mySect[i].parno   = -1;

    me->mySect[i].dY0     = 0.0;
    me->mySect[i].dZ0     = 0.0;
    me->mySect[i].dY1     = 0.0;
    me->mySect[i].dZ1     = 0.0;

    me->ptObjs[i].objid   = NULL_OBJID;
    me->ptObjs[i].osnum   = me->ModuleInfo.md_id.osnum;

    me->DYline[i].points     = NULL;
    me->DYline[i].num_points = 0;
  }

  me->nRWtr = 0;
  _FREE (me->RWTrac);

  me->FirstTerm.objid     = NULL_OBJID;
  me->FirstTerm.osnum     = me->ModuleInfo.md_id.osnum;
  me->ConnId.objid        = NULL_OBJID;
  me->ConnId.osnum        = me->ModuleInfo.md_id.osnum;
  me->ASConnId.objid      = NULL_OBJID;
  me->ASConnId.osnum      = me->ModuleInfo.md_id.osnum;
  me->otherLnId[0].objid  = NULL_OBJID;
  me->otherLnId[0].osnum  = me->ModuleInfo.md_id.osnum;
  me->otherLnId[1].objid  = NULL_OBJID;
  me->otherLnId[1].osnum  = me->ModuleInfo.md_id.osnum;
  me->otherLnCpt[0]       = -1;
  me->otherLnCpt[1]       = -1;
  me->myMergeCpt[0]       = -1;
  me->myMergeCpt[1]       = -1;

  me->otherLnMdEnv[0].md_id.objid         = NULL_OBJID;
  me->otherLnMdEnv[0].md_id.osnum         = me->ModuleInfo.md_id.osnum;
  me->otherLnMdEnv[0].md_env.matrix_type  = 0;
  me->otherLnMdEnv[1].md_id.objid         = NULL_OBJID;
  me->otherLnMdEnv[1].md_id.osnum         = me->ModuleInfo.md_id.osnum;
  me->otherLnMdEnv[1].md_env.matrix_type  = 0;

  MAidmx (&retmsg, me->otherLnMdEnv[0].md_env.matrix);
  MAidmx (&retmsg, me->otherLnMdEnv[1].md_env.matrix);

  /* Added for split */
  me->bToBeSplit = FALSE;
  me->bSkSplCab  = FALSE;
  me->ParSpltEnd = -1;
  om$vla_set_dimension( varray=me->Leads, size=0 ); 

  FIg_enable( me->pCtlAtt, VCPCAB_COMPCODE );
  FIg_enable( me->pCtlAtt, VCPCAB_TAGNO );
  FIg_set_value( me->pCtlAtt, VCPCAB_SPLIT, 0 );

  return OM_S_SUCCESS;
}

method VCFstart ()
{
  int   status;

  status = VC_Cmd_form_open (me->pCtlAtt, me->FCcontrol);

  status = VC_Cmd_form_pos  (me->pSysAtt, me->FCmain);

  status = VC_Cmd_form_pos  (me->PkLdForm, VC_FPOS_PC_LEAD);

  return OM_S_SUCCESS;
}

method delete ( int f_defer_flag )
{
  int       status = OM_S_SUCCESS;
  IGRlong   msg;
  IGRlong   sts;

  if( me->CompId.objid != NULL_OBJID )
  {
  /*A Delete Component */
    status =
    om$send ( msg  = message GRgraphics.GRdelete ( &msg, &me->ModuleInfo),
          senderid = my_id,
          targetid = me->CompId.objid,
          targetos = me->CompId.osnum ) ;
    as$status ();
    me->CompId.objid = NULL_OBJID;
  }

  sts = om$send ( mode     = OM_e_wrt_message,
                  msg      = message CEO_LOCATE.delete( f_defer_flag),
                  targetid = my_id);

  return sts;
}



method form_notification ( int       form_label ;
                           int       gadget_label ;
                           double    value ;
                           char    * form_ptr )
{
  int		  status = OM_S_SUCCESS;

  IGRlong   retmsg;
  double    dSelFlag = 0;
  double    dSelOn   = 1;
  double    dSelOff  = 0;
  IGRchar  *fptr;
  IGRchar   c30buff[VC_MAX_TAGNO];

  c30buff[0] = '\0';

#ifdef MY_DEBUG
  printf("in form_notification %d form, %d gadget\n", form_label, gadget_label);
#endif

  if ( form_label == VCC_PC_CONTROL_FORM )
  {
    fptr = me->pCtlAtt;

    FIg_get_value (fptr, gadget_label, &dSelFlag);
#ifdef MY_DEBUG
    printf("gadget %d button value %f\n", gadget_label, dSelFlag);
#endif

    switch( gadget_label )
    {
      case VCPCAB_COMPCODE:
      {
         /* Compcode rewritten by law for TR179800042 */
         int new_list_cnt,sel_index;
         IGRchar      szText[VC_CMD_BUFSIZE];
         int i, idsp, jdsp;
         int sel_flag=0,r_pos,length;
         int unique_flg;

         status = VDfrm_fld_set_sub_list(  form_ptr,
                                VCPCAB_COMPCODE,
                                FI_MSG_FIELD,
                                me->CClist,
                                VC_MAX_CCODE,
                                me->nCC,
                                &new_list_cnt,
                                0,
                                &sel_index,
                                &unique_flg   );

         /* The form preprocessor uses  me->CompCode to reset the field */
         FIfld_get_text_length (form_ptr, VCPCAB_COMPCODE, 0, 0, &length);
         FIfld_get_text( form_ptr, VCPCAB_COMPCODE, 0, 0, length,
                          (unsigned char *) szText, &sel_flag, &r_pos );
         strcpy(me->CompCode,szText);
         if(unique_flg)
         {
            FIg_enable(form_ptr,FI_EXECUTE);
            FIg_enable(form_ptr,FI_ACCEPT);
            jdsp = sel_index * VC_MAX_SDESC;

            strcpy (me->CompDesc, &me->CCdesc[jdsp]);
            me->bCCch = TRUE;

            if (me->Product == VC_PROD_NONE)
            {
                    if (sel_index >= me->nFOstart)
                    {
                       me->Product = VC_PROD_FO;
                       me->nTagCat = VCTAG_CAT_FOCABLE; // TR179900132   
                    }
                    else
                    {
                       me->Product = VC_PROD_ELEC;
                       me->nTagCat = VCTAG_CAT_ELCABLE; //TR179900132
                    }
            }
         }
      }
      break;

      case VCPCAB_TAGNO:
        FIg_get_text( form_ptr, gadget_label, c30buff );

        /*A if diff from the previous one */
        if( strcmp(c30buff, me->CompTag) )
        {
          IGRshort     nST = -1;

          status = VC_TAGchk (&nST, me->nTagCat, c30buff);

          if (nST < 0)
	  {
	    /* If the Tag Number specified is not a duplicate one then reset
	    the message field to null message. Alwin */

            strcpy (me->CompTag, c30buff);
	    FIg_set_text( form_ptr, FI_MSG_FIELD, "  ");
	  }
          else
          {
            FIg_set_text( form_ptr, FI_MSG_FIELD,
                              "Duplicate Tag Number");
            FIg_set_text( form_ptr, gadget_label, me->CompTag);
          }
        }

        FIg_set_text (me->pSysAtt, VCCAT_LINK_NAME,
                       me->CompTag);
        break;

      case VCPCAB_CONNECT: /* manual pop-off */
        if (me->bBrk)
        {
          FIg_set_value (fptr, VCPCAB_DIG   , dSelOff );
          break;
        }

        if( dSelFlag == dSelOn ) 
        {
          FIg_set_value (fptr, VCPCAB_ATTACH, dSelOff );
          FIg_set_value (fptr, VCPCAB_DIG   , dSelOff );

          _put_response( resp = VCL_LINK_CONNECT ); 
        }
        else
        {
          FIg_set_value (fptr, VCPCAB_DIG, dSelOn );
          _put_response( resp = VCL_LINK_FREE_POINT );
        }
        break;
          
      case VCPCAB_SPLIT:
	me->MyRetCode = VCL_LINK_SPLIT;
	_put_response( resp = EX_FORM_FINISHED );
	break;

      case VCPCAB_ATTACH: /* manual pop-off */
        if (me->bBrk)
        {
          FIg_set_value (fptr, VCPCAB_DIG   , dSelOff );
          break;
        }

        if( dSelFlag == dSelOn ) 
        {
          FIg_set_value (fptr, VCPCAB_CONNECT, dSelOff );
          FIg_set_value (fptr, VCPCAB_DIG    , dSelOff );

          _put_response( resp = VCL_LINK_ATTACH );
        }
        else
        {
          FIg_set_value (fptr, VCPCAB_DIG, dSelOn );
          _put_response( resp = VCL_LINK_FREE_POINT );
        }
        break;
          
      case VCPCAB_DIG: /* default always on, and force others off  */
        if (me->bBrk)
        {
          FIg_set_value (fptr, VCPCAB_DIG   , dSelOff );
          break;
        }

        FIg_set_value (fptr, VCPCAB_ATTACH, dSelOff );
        FIg_set_value (fptr, VCPCAB_CONNECT, dSelOff );
        FIg_set_value (fptr, VCPCAB_DIG, dSelOn );

        _put_response( resp = VCL_LINK_FREE_POINT );
        break;

      case VCPCAB_BREAK:

        if ((!me->bBrk) && (me->bGoing))
        {   /*    add BREAK ON section     */
          IGRshort    i,j;

          FIg_set_value (fptr, VCPCAB_ATTACH, dSelOff );
          FIg_set_value (fptr, VCPCAB_CONNECT, dSelOff );
          FIg_set_value (fptr, VCPCAB_DIG, dSelOff );
          FIg_set_value (fptr, VCPCAB_BREAK, dSelOn );

          i = j = 0;
          status =
          om$send (msg = message VCCmdPC.VCMLAddNode
                         (VCC_BREAK_ON, me->dLAST, me->dLAST, i, j, NULL),
              targetid = my_id);

          me->bBrk = TRUE;

          FIg_set_value (fptr, VCPCAB_DIG, dSelOff );
          FIg_set_value (fptr, VCPCAB_BREAK, dSelOn );

          _put_response( resp = VCL_LINK_BREAK );
        }
        else
        {  /*   no break, continue at free point   */

          FIg_set_value (fptr, VCPCAB_DIG, dSelOn );
          FIg_set_value (fptr, VCPCAB_BREAK, dSelOff );
          _put_response( resp = VCL_LINK_FREE_POINT );
        }

        break;

      case VCPCAB_ZDEPTH:  /* flip depth toggle  */
        me->bDepth = !(me->bDepth);
        break;

      case VCPCAB_CONSTRAINT:  /* flip ortho toggle  */
        me->bOrtho = !(me->bOrtho);
        if (me->bOrtho)
        {  /*   force depth for ortho   */
          me->bDepth = TRUE;
          FIg_set_value (fptr, VCPCAB_ZDEPTH, dSelOn );
        }
        break;

      case FI_CANCEL:
        _put_response( resp = VC_RTC_CANCEL);
        break;

      default:
        _put_response( resp = VC_RTC_AS_IS );
        break;
    }

    status =
    om$send (msg = message VCCmdPC.VCDynRefresh (&retmsg),
        targetid = my_id);
  }
  else
  if ( form_label == STATUS_FORM )
  {
    fptr = me->pSysAtt;

    status =
    om$send( msg  = message VCCmdCAT.VCATSysFormNot
                              (gadget_label, value, fptr, me->pUsrAtt),
         targetid = my_id);
        /* [2] User form, [3] Search form */
    as$status( action = RET_STATUS );
  
    if( gadget_label == VCCAT_COMP_CODE)
        FIg_set_text (me->pCtlAtt, VCPCAB_COMPCODE, me->CompCode);
    else
    if( gadget_label == VCCAT_LINK_NAME)
        FIg_set_text (me->pCtlAtt, VCPCAB_TAGNO,  me->CompTag);
  }
  else
  if ( form_label == VCC_PC_USR_ATTR_FORM )
  {
    status =
    om$send( msg = message VCCmdCAT.VCATUsrFormNot
                                  (gadget_label, value, form_ptr),
        targetid = my_id );
    as$status( action = RET_STATUS );
  }
  else
  if ( form_label == VCC_PC_SPL_CAB_FORM ) // Handle pick/drop lead events.
  {
      switch( gadget_label )
      {
	  IGRint		i, NumRows, SelFlag, rp;
	  IGRuchar		LeadName[VC_MAX_LEAD_ID];

	  case VCSUBCAB_GRAB_LEAD:
	      FIfld_get_num_rows( form_ptr, VCSUBCAB_AVLBL_LEAD, &NumRows );

	      for( i=0 ; i<NumRows ; i++ )
	      {
		  FIfld_get_select( form_ptr, VCSUBCAB_AVLBL_LEAD,
				    i, 0, &SelFlag );

		  if( SelFlag )
		  {
		      FIfld_get_text( form_ptr, VCSUBCAB_AVLBL_LEAD, i, 0,
				      VC_MAX_LEAD_ID, LeadName, &SelFlag, &rp );

		      FIfld_get_num_rows( form_ptr, VCSUBCAB_UNUSD_LEAD, &rp );
		      FIfld_set_num_rows( form_ptr, VCSUBCAB_UNUSD_LEAD, rp+1 );

		      FIfld_set_text( form_ptr, VCSUBCAB_UNUSD_LEAD, rp, 0,
				      (char *) LeadName, SelFlag );

		      FIfld_delete_rows( form_ptr, VCSUBCAB_AVLBL_LEAD, i, 1 );
		      i--;
		      NumRows--;
		      FIg_enable( form_ptr, FI_ACCEPT );
		  }
	      }
	      break;

	  case VCSUBCAB_DROP_LEAD:
	      FIfld_get_num_rows( form_ptr, VCSUBCAB_UNUSD_LEAD, &NumRows );

	      for( i=0 ; i<NumRows ; i++ )
	      {
		  FIfld_get_select( form_ptr, VCSUBCAB_UNUSD_LEAD,
				    i, 0, &SelFlag );

		  if( SelFlag )
		  {
		      FIfld_get_text( form_ptr, VCSUBCAB_UNUSD_LEAD, i, 0,
				      VC_MAX_LEAD_ID, LeadName, &SelFlag, &rp );

		      FIfld_get_num_rows( form_ptr, VCSUBCAB_AVLBL_LEAD, &rp );
		      FIfld_set_num_rows( form_ptr, VCSUBCAB_AVLBL_LEAD, rp+1 );

		      FIfld_set_text( form_ptr, VCSUBCAB_AVLBL_LEAD, rp, 0,
				      (char *) LeadName, SelFlag );

		      FIfld_delete_rows( form_ptr, VCSUBCAB_UNUSD_LEAD, i, 1 );
		      i--;
		      NumRows--;
		  }
	      }

	      FIfld_get_num_rows( form_ptr, VCSUBCAB_UNUSD_LEAD, &rp );
	      if( rp==0 )
	      {
		  FIfld_set_text( form_ptr, VCSUBCAB_MESSAGE, 0, 0,
				  "Subcable must have a lead", FALSE );
		  FIg_disable( form_ptr, FI_ACCEPT );
	      }
	      break;

	  case FI_RESET:
	      NumRows = om$dimension_of(varray=me->Leads);
	      FIfld_set_num_rows( form_ptr, VCSUBCAB_AVLBL_LEAD, NumRows );

	      for( i=0 ; i<NumRows ; i++ )
		  FIfld_set_text( form_ptr, VCSUBCAB_AVLBL_LEAD, i, 0,
				  me->Leads[i].LeadNam, 0 );

	      FIfld_set_num_rows( form_ptr, VCSUBCAB_UNUSD_LEAD, 0 );
	      FIg_disable( form_ptr, FI_ACCEPT );
	      break;

	  case FI_CANCEL:
	  {
	      IGRint	nSubCab=0,HoldCpt=-1;
	      struct GRid	HoldId;
	      IGRdouble		EndPt[6]={0,0,0,0,0,0};

	      HoldCpt = me->ParSpltEnd;
	      HoldId  = me->CompId;

	      status = om$send( msg = message VCCmdPC.VCinit( &retmsg ),
				targetid = my_id );

	      /* Check if me->CompId is a parent cable split at the nCpt end */
	      if( HoldCpt == 0 )
		  status = VC$SubCabLeadInfo( p_msg	     = &retmsg,
					      gridInputCab   = HoldId,
					      arr6_dEndCoord = EndPt,
					      md_env	     = &me->ModuleInfo,
					      p_nBegCab      = &nSubCab );
	      else
		  status = VC$SubCabLeadInfo( p_msg	     = &retmsg,
					      gridInputCab   = HoldId,
					      arr6_dEndCoord = EndPt,
					      md_env	     = &me->ModuleInfo,
					      p_nEndCab      = &nSubCab );
	      __DBGpr_int("Num Subcables off located cable at located end",
								      nSubCab);

	      VC_Cmd_form_open( me->pCtlAtt, me->FCcontrol );
	      VC_Cmd_form_close( me->PkLdForm, VC_FPOS_PC_LEAD );

	      /* If so, DON'T redirect to merge. */
	      if( nSubCab )
	      {
		  me->CompId.objid = NULL_OBJID;
		  me->MyRetCode = VC_RTC_ERROR;
		  _put_response( resp = EX_FORM_FINISHED );
	      }
	      else
	      {
		  me->CompId = HoldId;
		  for( i=0 ; i<3 ; i++ )
		      me->dIncrd[i] = EndPt[HoldCpt*3+i];
		  __DBGpr_vec("Last point sketched",me->dIncrd);
		  me->MyRetCode = VCL_LINK_JOIN;
		  _put_response( resp = EX_FORM_FINISHED );
	      }
	      break;
	  }

	  case FI_ACCEPT:
	      FIfld_get_num_rows( form_ptr, VCSUBCAB_UNUSD_LEAD, &NumRows );
	      __DBGpr_int("Number of rows in field",NumRows);
	      if( NumRows==0 )
	      {
		  FIfld_set_text( form_ptr, VCSUBCAB_MESSAGE, 0, 0,
				  "Subcable must have a lead", FALSE );
		  FIg_disable( form_ptr, FI_ACCEPT );
		  FIf_reset( form_ptr );
	      }
	      else
	      {
		  om$vla_set_dimension( varray = me->Leads, size = NumRows );
		  for( i=0 ; i<NumRows ; i++ )
		  {
		      __DBGpr_int("Reading lead name no",i+1);
		      /* Check leadname read from field against valid lead name
		       * (can do by calling VC_ConNum_LeadName) */
		      FIfld_get_text( form_ptr, VCSUBCAB_UNUSD_LEAD, i, 0,
				      VC_MAX_LEAD_ID,
				      (unsigned char *)me->Leads[i].LeadNam,
				      &SelFlag, &rp );
		      __DBGpr_str("Lead name read",me->Leads[i].LeadNam);
		  }
		  /* TODO: Check if all selected leads correspond to all the
		   * leads in the parent cable. If so, don't split, rather
		   * merge! */

		  VC_Cmd_form_open( me->pCtlAtt, me->FCcontrol );
		  VC_Cmd_form_close( me->PkLdForm, VC_FPOS_PC_LEAD );

		  me->MyRetCode = VC_RTC_ALLOK;
		  _put_response( resp = EX_FORM_FINISHED );
	      }
	      break;

      }
  }

quit:
  __DBGpr_int("me return code",me->MyRetCode);
  return OM_S_SUCCESS;
}

method VCATcheck ( IGRlong    *sts)
{
  int		  status = OM_S_SUCCESS;

  IGRdouble    d3pt1[3],d3pt2[3];
  int          i;
 
  extern void  VR_enforceMinDist();

  status =
  om$send (msg = message VCCmdCAT.VCATcheck (sts),
          mode = OM_e_wrt_message,
      targetid = my_id);

  if (*sts != VC_RTC_ALLOK) goto quit;

  me->ret = VC_RTC_ALLOK;
  *sts    = VC_RTC_ALLOK;

  if( me->nMyPnts < 2 ) goto quit;
 
  /*    only for 2pt line ?????   */

  if( me->nMyPnts == 2 )  /* atleast MIN_DIST apart */
  {
    for( i = 0; i < 3; i++ )
    {
      d3pt1[i] = me->myPnts[0].xyz[i];
      d3pt2[i] = me->myPnts[1].xyz[i];
    }

/* KDD */
#ifdef MY_DEBUG
printf("\tbefore VR_enforceMinDist (VCMLConni) me->myPnts[0] (%f, %f, %f)" 
	" me->myPnts[1] (%f, %f, %f)\n", 
	me->myPnts[0].xyz[0], me->myPnts[0].xyz[1], me->myPnts[0].xyz[2]);
#endif


    VR_enforceMinDist( d3pt1, d3pt2, MIN_DIST );  

#ifdef MY_DEBUG
    printf("After enforcing \n");
    printf("Data point 0th %f %f %f \n",d3pt1[0],d3pt1[1],d3pt1[2]);
    printf("Data point 1st %f %f %f \n",d3pt2[0],d3pt2[1],d3pt2[2]);
#endif

    for( i = 0; i < 3; i++ )
    {
      me->myPnts[0].xyz[i] = d3pt1[i];
      me->myPnts[1].xyz[i] = d3pt2[i];
    }

/* print put in debug by law for TR179800042 */
#ifdef MY_DEBUG
printf("\tafter  VR_enforceMinDist (VCMLConni) me->myPnts[0] (%f, %f, %f)" 
	" me->myPnts[1] (%f, %f, %f)\n", 
	me->myPnts[0].xyz[0], me->myPnts[0].xyz[1], me->myPnts[0].xyz[2]);
#endif

  }

  /*  close off link if necessary    */

  if (me->nSecPts > 0)
  {  /*  close of string if necessary   */
    me->mySect[me->nMySect].iTo    = me->nMyPnts - 1;
    me->mySect[me->nMySect].strno  = 0;
    me->nSecPts = 0;
    me->nMySect++;
  }

#ifdef MY_DEBUG
  printf("\n\n\n Id %s \n", me->CompTag);
#endif

  quit:
  return OM_S_SUCCESS;
}

method wakeup ( int pos )
{
  int     status;

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VCCmdCAT.wakeup( pos ),
                    targetid = my_id);

  if( pos & EX_suspend )
      FIf_display( me->pCtlAtt );

  return (OM_S_SUCCESS);
}

method sleep ( int pos )
{
  int             status;

  if( pos & EX_suspend )
      FIf_erase ( me->pCtlAtt );

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message VCCmdCAT.sleep( pos ),
                    targetid = my_id);

  return (OM_S_SUCCESS);
}

end implementation VCCmdPC;

