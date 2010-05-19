
/* $Id: VDTBX_cmdi.I,v 1.3 2001/08/16 21:40:12 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDTBX_cmdi.I
 *
 * Description:
 *
 * Implementation file for VDTBX command object initialization/reset
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDTBX_cmdi.I,v $
 *      Revision 1.3  2001/08/16 21:40:12  ylong
 *      Added export xml functionality
 *
 *      Revision 1.2  2001/02/22 22:23:45  ylong
 *      TR4657 and TR4702
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/24  14:54:02  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.11  1995/11/29  13:57:22  pinnacle
# Replaced: ./vdtbl/cmd/VDTBX_cmdi.I for:  by ksundar for vds.240
#
# Revision 1.10  1995/09/25  23:01:50  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by sundar for vds.240
#
# Revision 1.9  1995/09/05  23:15:32  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/08/16  21:11:52  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/08/14  22:42:14  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/08/11  23:36:24  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/03  21:59:22  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/07/26  20:30:48  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/11  21:54:26  pinnacle
# Replaced: vdtbl/cmd/VDTBX_cmdi.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/07/06  16:23:14  pinnacle
# Created: vdtbl/cmd/VDTBX_cmdi.I by hverstee for vds.240
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

#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"

#include "VDdrwlo_pr.h"
#include "vdpardef.h"
#include "vdandef.h"
#include "VDmem.h"

from   VDdrwlo    import   VDdrwlo_gfld;

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

/*
#define  MY_DEBUG
*/


method save_form_pos ( long * sts )
{

  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);
  *sts = MSSUCC;

  return OM_S_SUCCESS;
}

method set_form_pos ( long * sts )
{
   if(x_pos != -1 && y_pos != -1)
     FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );

  return OM_S_SUCCESS;
}

method init ( int type ; char * str_ptr )
{
  int         status, format;
  long        sts;

  /*A initialize superclass */

  status = om$send (mode     = OM_e_wrt_message,
                    msg      = message CEO.init (type, str_ptr),
                    targetid = my_id);
  as$status (action = RET_STATUS);

  /*A  initialize instance   */

  me->My_Type       = type;
  me->nNumTab       = 0;

  me->TabDis        = NULL;
  me->Table_Tab     = NULL;

  ex$get_cur_mod (osnum = &me->My_OS);

  me->Sepertab      = _MALLOC (VD_TBEX_SEPERSTRING * VD_TBEX_NUMSEPER, IGRchar);

  if (me->Sepertab == NULL)
  {
    UI_status (VD_TBEX_EMSG_MEM);
    _put_response( resp = TERMINATE);
  }
  else
  {
    strcpy (&me->Sepertab[0], ",");
    strcpy (&me->Sepertab[VD_TBEX_SEPERSTRING], "|");
    strcpy (&me->Sepertab[VD_TBEX_SEPERSTRING*2], "<blank>");
    strcpy (&me->Sepertab[VD_TBEX_SEPERSTRING*3], "<tab>");
    strcpy (&me->Sepertab[VD_TBEX_SEPERSTRING*4], ",<tab>");

    strcpy (me->szSeper, ",");
    FIg_get_state( me->forms[0].form_ptr, VD_TBEX_TOG_FMT, &format );
    if( format ) {
      strcpy (me->CUR_filnam, "TBexport.xml");
      FIg_erase( me->forms[0].form_ptr, VD_TBEX_GRP_OPT );
    }
    else {
      strcpy (me->CUR_filnam, "TBexport.txt");
      FIg_display( me->forms[0].form_ptr, VD_TBEX_GRP_OPT );
    }

    /*    reset instance   */

    status = 
    om$send (msg = message VDCmdTBX.VDTBX_Reset (&sts),
        targetid = my_id);
  }

  quit:
  return (OM_S_SUCCESS);
}

method delete (int   f_defer_flag)
{
  IGRint      status;
  long        sts;

  /*    do my cleanup    */

  status = 
  om$send (msg = message VDCmdTBX.VDTBX_Cleanup (&sts),
      targetid = my_id);

  return (OM_S_SUCCESS);
}



method  VDTBX_Cleanup ( long * sts )
{
  int    status;

  *sts = MSSUCC;

  /*    free memory    */

  _FREE (me->Sepertab);
  _FREE (me->Table_Tab);
  _FREE (me->TabDis);

  /*   and do superclass delete   */

  status =
  om$send (msg = message CEO_LOCATE.delete (0),
          mode = OM_e_wrt_message,
      targetid = my_id);

  return (OM_S_SUCCESS);
}


method  VDTBX_Reset ( long * sts )
{
  IGRint       status;
  IGRchar     *form_ptr;

  *sts = MSSUCC;

  /*   reset all used instance vars   */

  form_ptr  = me->forms[0].form_ptr;
  me->My_localret   = 0;

  me->Table_Id.objid  = NULL_OBJID;
  me->Layout_Id.objid = NULL_OBJID;

  me->bNumquote     = FALSE;
  me->bTxtquote     = FALSE;
  me->iNumTab       = -1;

  me->CUR_tabnam[0] = '\0';

  me->nNumEnt   = 0;

  status = om$vla_set_dimension (varray = me->Data,
                                 size   = 0);
  status = om$vla_set_dimension (varray = me->nSelect,
                                 size   = 0);

  FIfld_set_max_num_rows (form_ptr, VD_TBEX_FLD_DATA,
                                                 (int)me->nNumEnt);
  FIfld_set_list_num_rows (form_ptr, VD_TBEX_FLD_DATA, 0,
                                                 (int)me->nNumEnt);
  FIg_reset (form_ptr, VD_TBEX_FLD_DATA);
   
  /*   display form   */

  status =
  om$send (msg = message VDCmdTBX.VDTBX_disp (form_ptr),
      targetid = my_id);

  return (OM_S_SUCCESS);
}


method VDTBX_Start (long     *msg)

{
  IGRint      status;
  IGRlong     retmsg;
  IGRchar     dirname[VD_TBEX_NUM_CHSTR];
  IGRchar     superClassName[VD_TBEX_NUM_CHSTR];
  IGRint      i, idsp;
  IGRint      ref_file;
  IGRchar    *formptr;

  /*    set tables list    */

  *msg = MSSUCC;

  _FREE (me->Table_Tab);
  _FREE (me->TabDis);

  me->nNumTab = 0;

  strcpy (dirname, "drw_tables");
  strcpy (superClassName, "VDdrwTbl");
  ref_file = 1;
  me->Table_Tab   = NULL;
  formptr  = me->forms[0].form_ptr;

  status =
  VD_get_tableName (&retmsg, dirname, superClassName, &me->nNumTab,
                                         ref_file, &me->Table_Tab);

  if (me->nNumTab > 0)
  {
    me->TabDis = _MALLOC (me->nNumTab * VD_TBEX_NUM_CHSTR, IGRchar);

    if (me->TabDis == NULL)
    {
      UI_status (VD_TBEX_EMSG_MEM);
      _put_response( resp = TERMINATE);
      goto quit;
    }
  }

  if (me->nNumTab > 5)
    FIfld_set_list_scroll (formptr, VD_TBEX_FLD_TABNAM, 1, 0);
  else
    FIfld_set_list_scroll (formptr, VD_TBEX_FLD_TABNAM, 0, 0);
 
  FIfld_set_list_num_rows (formptr, VD_TBEX_FLD_TABNAM, 0, me->nNumTab);

  /*   create display tables list   */

  for( i=0 ; i<me->nNumTab ; i++ )
  {
    IGRchar     szTemp[VD_TBEX_NUM_CHSTR];

    strcpy( szTemp, me->Table_Tab[i].tbl_name);
    strcat( szTemp, "[");
    strcat( szTemp, me->Table_Tab[i].deg_file.fname);
    strcat( szTemp, "]");

    idsp = i * VD_TBEX_NUM_CHSTR;

    strcpy( &me->TabDis[idsp], szTemp);

    VDfld_set_list_text (formptr, VD_TBEX_FLD_TABNAM, i, 0,
                                        &me->TabDis[idsp], FALSE);
  }

  /*    separators list   */

  FIfld_set_list_scroll   (formptr, VD_TBEX_FLD_SEPER, 0, 0);
  FIfld_set_list_num_rows (formptr, VD_TBEX_FLD_SEPER, 0, VD_TBEX_NUMSEPER);

  for (i=0; i<VD_TBEX_NUMSEPER; i++)
  {
    idsp = i * VD_TBEX_SEPERSTRING;

    VDfld_set_list_text (formptr, VD_TBEX_FLD_SEPER, i, 0,
                          &me->Sepertab[idsp], FALSE);
  }

  /*    limit scrollability of input fields    */

  FIfld_set_max_num_chars (formptr, VD_TBEX_FLD_TABNAM, 0,
                              VD_TBEX_NUM_CHSTR);
  FIfld_set_max_num_chars (formptr, VD_TBEX_FLD_FILNAM, 0,
                              VD_TBEX_NUM_CHSTR);

  quit:
  return OM_S_SUCCESS;
}


IGRint VDTBX_sortData(struct VDTBX_data *Data1, struct VDTBX_data *Data2) 
{
  return (Data1->colno - Data2->colno); 
}


method   VDTBX_load   (IGRlong    *msg)
{
  IGRint       status;
  IGRlong      retmsg;
  int          i;

  struct   VDdrwlo_db_fld     *Local;

  /*    load table layout    */

  *msg  = MSFAIL;
  Local = NULL;

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_gfld
                 (&retmsg, VD_DRWLO_EN_DATA, VD_DRWLO_EN_ALL, NULL,
                  VD_DRWLO_EN_ALL, &me->nNumEnt, NULL),
      targetid = me->Layout_Id.objid,
      targetos = me->Layout_Id.osnum);

  if (me->nNumEnt <= 0) me->nNumEnt = 1;

  Local = _MALLOC (me->nNumEnt, struct VDdrwlo_db_fld);
  if (Local == NULL) goto quit;

  status =
  om$vla_set_dimension (varray = me->Data,
                        size   = me->nNumEnt);

  status =
  om$vla_set_dimension (varray = me->nSelect,
                        size   = me->nNumEnt);

  status =
  om$send (msg = message VDdrwlo.VDdrwlo_gfld
                 (&retmsg, VD_DRWLO_EN_DATA, VD_DRWLO_EN_ALL, NULL,
                      VD_DRWLO_EN_ALL, &me->nNumEnt, Local),
      targetid = me->Layout_Id.objid,
      targetos = me->Layout_Id.osnum);

  /*  create display layout list   */

  for (i=0; i<me->nNumEnt; i++)
  {
    me->nSelect[i] = 0;

    me->Data[i].colno  = Local[i].col_seqno;
    me->Data[i].linno  = Local[i].lin_seqno;
    me->Data[i].dttyp  = Local[i].datatype;

    switch (Local[i].fieldtype)
    {
      case VD_DRWLO_EN_TEXT:
        strcpy (me->Data[i].desc, "Text[");
        strcat (me->Data[i].desc, Local[i].Ftext);
        strcat (me->Data[i].desc, "]");
        me->Data[i].dttyp  = VD_DRWLO_EN_ASCII;
        break;

      case VD_DRWLO_EN_ATTRIBUTE:
        strcpy (me->Data[i].desc, "Attribute[");
        strcat (me->Data[i].desc, Local[i].id_name);
        strcat (me->Data[i].desc, "]");
        break;

      case VD_DRWLO_EN_EXPRESSION:
        strcpy (me->Data[i].desc, "Expression[");
        strcat (me->Data[i].desc, Local[i].id_name);
        strcat (me->Data[i].desc, "]");
        break;

      case VD_DRWLO_EN_EXPR_TABLE:
        strcpy (me->Data[i].desc, "Expression Table[");
        strcat (me->Data[i].desc, Local[i].id_name);
        strcat (me->Data[i].desc, "]");
        break;

      case VD_DRWLO_EN_USERDEFINED:
        strcpy (me->Data[i].desc, "Userdefined[]");
        me->Data[i].dttyp  = VD_DRWLO_EN_ASCII;
        break;

      case VD_DRWLO_EN_OVERFLOW:
        strcpy (me->Data[i].desc, "Overflow[]");
        break;

      case VD_DRWLO_EN_FORMTEXT:
        strcpy (me->Data[i].desc, "Formattext[");
        strcat (me->Data[i].desc, Local[i].id_name);
        strcat (me->Data[i].desc, "]");
        me->Data[i].dttyp  = VD_DRWLO_EN_ASCII;
        break;

      case VD_DRWLO_EN_ITEMNO:
        strcpy (me->Data[i].desc, "Itemnumber[]");
        me->Data[i].dttyp  = VD_DRWLO_EN_ASCII;
        break;

      case VD_DRWLO_EN_QUANTITY:
        strcpy (me->Data[i].desc, "Quantity[]");
        me->Data[i].dttyp  = VD_DRWLO_EN_NUMERIC;
        break;

      default:
        strcpy (me->Data[i].desc, "Unknown[]");
        break;
    }
  }

  qsort (	(char*)me->Data, 
		me->nNumEnt, 
		sizeof(struct VDTBX_data), 
		(int(*)())VDTBX_sortData);

  *msg = MSSUCC;
  _FREE (Local);

  quit:
  return (OM_S_SUCCESS);
}

method VDTBX_Rtc (long    *retcode)
{

  *retcode = me->My_localret;

  return OM_S_SUCCESS;
}

end implementation VDCmdTBX;

