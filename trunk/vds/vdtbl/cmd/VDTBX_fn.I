
/* $Id: VDTBX_fn.I,v 1.5 2001/09/13 22:05:14 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDTBX_fn.I
 *
 * Description:
 *
 * Implementation file for TBX form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDTBX_fn.I,v $
 *      Revision 1.5  2001/09/13 22:05:14  ylong
 *      Unhighlight table header when reselect another one
 *
 *      Revision 1.4  2001/08/16 21:40:18  ylong
 *      Added export xml functionality
 *
 *      Revision 1.3  2001/05/31 19:48:27  ylong
 *      highlight exported table
 *
 *      Revision 1.2  2001/02/22 22:24:02  ylong
 *      TR4657 and TR4702
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/09/25  23:02:38  pinnacle
# Replaced: vdtbl/cmd/VDTBX_fn.I for:  by sundar for vds.240
#
# Revision 1.3  1995/09/05  23:18:30  pinnacle
# Replaced: vdtbl/cmd/VDTBX_fn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/11  21:54:46  pinnacle
# Replaced: vdtbl/cmd/VDTBX_fn.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  16:26:36  pinnacle
# Created: vdtbl/cmd/VDTBX_fn.I by hverstee for vds.240
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      06/30/95          HV            New
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdTBX;

#include "OMmacros.h"
#include "OMprimitives.h"
#include "igetypedef.h"
#include "gr.h"
#include "FI.h"
%safe
#include "VX_FIproto.h"
%endsafe
#include "ASmatrix.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "vdpardef.h"
#include "grmacros.h"

#include "VDdrwlo_pr.h"

from   VDdrwTbl   import   VDgetTableLayoutName;

%safe
#include <math.h>
%endsafe

/*
#define   MY_DEBUG
*/



method form_notification ( int         form_label ;
                           int         gadget_label ;
                           double      value ;
                           char      * form_ptr )

{
  IGRint       status;
  IGRlong      retmsg;
  IGRchar      szFld[VD_TBEX_NUM_CHSTR];
  IGRchar      szmsg[VD_TBEX_NUM_CHSTR];
  IGRchar      *strpt = NULL, postfix[10];
  int          i, idsp;
  int          row, NbRows;
  int          format;
  IGRchar      LayNam[VD_TBEX_NUM_CHSTR];

  status   = OM_S_SUCCESS;
  szmsg[0] = '\0';

  me->My_localret = 0;

#ifdef MY_DEBUG
  printf (" TBX formnot, gadget %d\n",gadget_label);
#endif

  switch (gadget_label)
  {
    case VD_TBEX_FLD_TABNAM:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      /*    find table id etc., set up and load   */

      for (i=0; i<me->nNumTab; i++)
      {
        idsp = i * VD_TBEX_NUM_CHSTR;

        if (strcmp (szFld, &me->TabDis[idsp]) == 0) goto TSET;
      }
      sprintf (szmsg, "Table name %s not found",szFld);
      break;

      TSET:
      if( me->Table_Id.objid != NULL_OBJID )
      {
         gr$display_object (	object_id	= &me->Table_Id, 
				mode		= GRhe);
      }

      strcpy (me->CUR_tabnam, szFld);

      me->iNumTab = i;

      me->Table_Id.objid = me->Table_Tab[me->iNumTab].tbl_id.objid;
      me->Table_Id.osnum = me->Table_Tab[me->iNumTab].tbl_id.osnum;

      gr$display_object (	object_id	= &me->Table_Id, 
				mode		= GRhd);
      status =
      om$send (msg = message VDdrwTbl.VDgetTableLayoutName (&retmsg, LayNam),
          targetid = me->Table_Id.objid,
          targetos = me->Table_Id.osnum);

      status = VD_drwlo_getid (&retmsg, LayNam, NULL, &me->Layout_Id);

#ifdef MY_DEBUG
      printf ("layout %s, <%d %d>\n",LayNam, me->Layout_Id.objid,
                                             me->Layout_Id.osnum);
#endif

      if (me->Layout_Id.objid == NULL_OBJID)
      {
        sprintf (szmsg, "Layout name %s not found",LayNam);
        break;
      }

      status =
      om$send (msg = message VDCmdTBX.VDTBX_load (&retmsg),
          targetid = my_id);

      if (retmsg != MSSUCC)
      {   /*   abort   */
        UI_status (VD_TBEX_EMSG_MEM);
        _put_response( resp = TERMINATE);
        goto quit;
      }
      break;

    case VD_TBEX_FLD_FILNAM:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      FIg_get_state( form_ptr, VD_TBEX_TOG_FMT, &format);

      if( format )	strcpy( postfix, "xml" );
      else		strcpy( postfix, "txt" );

      strpt = strrchr( szFld, '.' );
      if( strpt == NULL ) 
      {
	strcat ( szFld, "." );
	strcat ( szFld, postfix );
      }
      else 
      {
	strpt++;
        if( strpt != NULL && strcasecmp( strpt, postfix ) )
	{
	  strcpy ( strpt, postfix);
	}
      }


      strcpy (me->CUR_filnam, szFld);

#ifdef MY_DEBUG
      printf ("Filename %s\n",me->CUR_filnam);
#endif
      break;

    case VD_TBEX_FLD_SEPER:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      strcpy (me->szSeper, szFld);

#ifdef MY_DEBUG
      printf ("Separator %s\n",me->szSeper);
#endif
      break;

    case VD_TBEX_FLD_DATA:
      FIfld_get_active_row (form_ptr, gadget_label, &row, &NbRows);

#ifdef MY_DEBUG
      printf ("Rowpick %d %d\n",row, NbRows);
#endif

      if ((row >= me->nNumEnt) || (row < 0)) break;

      /*    activate/deactivate row   */

      me->nSelect[row] = (!me->nSelect[row]); //1 - me->nSelect[row];
      break;

    case VD_TBEX_BTN_SELECT:
      for (i=0; i<me->nNumEnt; i++)
      {
        me->nSelect[i] = 1;
      }
      break;

    case VD_TBEX_BTN_DESELECT:
      for (i=0; i<me->nNumEnt; i++)
      {
        me->nSelect[i] = 0;
      }
      break;

    case VD_TBEX_CHK_NUM:
      me->bNumquote = 1 - me->bNumquote;
      break;

    case VD_TBEX_CHK_STR:
      me->bTxtquote = 1 - me->bTxtquote;
      break;

    case VD_TBEX_TOG_FMT:
      FIg_get_state( form_ptr, VD_TBEX_TOG_FMT, &format);
      if( format )	// = XML 
      {
	 FIg_erase( form_ptr, VD_TBEX_GRP_OPT );
	 strcpy( postfix, "xml" );
      }
      else		// = ASCII
      {
	 FIg_display( form_ptr, VD_TBEX_GRP_OPT );
	 strcpy( postfix, "txt" );
      }

      strcpy( szFld, me->CUR_filnam );
      if( szFld[0] == '\0' ) break;

      strpt = strchr( szFld, '.' );
      if( !strpt ) 
      {
	strcat( szFld, "." );
	strcat( szFld, postfix );
      }
      else 
      {
	strpt++;
        if( strpt != NULL && strcasecmp( strpt, postfix ) )
	{
	  strcpy ( strpt, postfix);
	}
      }
      strcpy( me->CUR_filnam, szFld );
      FIg_set_text( form_ptr, VD_TBEX_FLD_FILNAM, szFld );

      break;

/* ------------------------  CONTROL BAR GADGETS --------------------------- */

    case FI_CANCEL:
    case FI_ACCEPT:
      FIf_erase( form_ptr );

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
      goto quit;

    case FI_EXECUTE:
    case FI_RESET:
      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );
      break;

    default:
#ifdef MY_DEBUG
      printf (" ERROR edit unknown gadget %d\n", gadget_label);
#endif
      goto quit;
  }

  FIg_set_text (form_ptr, VD_TBEX_FLD_MSG, szmsg);

  status =
  om$send (msg = message VDCmdTBX.VDTBX_disp (form_ptr),
      targetid = my_id);

  quit:
  return (status);
}

end implementation VDCmdTBX;

