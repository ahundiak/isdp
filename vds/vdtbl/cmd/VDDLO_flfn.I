
/* $Id: VDDLO_flfn.I,v 1.1.1.1 2001/01/04 21:09:26 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDDLO_flfn.I
 *
 * Description:
 *
 * Implementation file for sub edit fill form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDDLO_flfn.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/07/14  20:49:44  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/02  08:28:30  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by vgnair for vds
#
# Revision 1.2  1997/11/24  14:52:26  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.13  1996/05/14  19:50:34  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by yzhu for vds.240
#
# Revision 1.12  1995/11/17  22:27:58  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.11  1995/11/13  21:25:54  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.10  1995/09/25  22:57:58  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by sundar for vds.240
#
# Revision 1.9  1995/09/20  22:03:50  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.8  1995/09/12  16:51:40  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.7  1995/08/14  22:43:50  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.6  1995/08/11  23:32:46  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.5  1995/08/03  21:07:58  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.4  1995/07/06  16:03:56  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/06/19  20:01:00  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I for:  by hverstee for vds.240
#
# Revision 1.3  1995/05/11  16:56:52  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I by hverstee r#
#
# Revision 1.2  1995/05/08  20:39:34  pinnacle
# Replaced: vdtbl/cmd/VDDLO_flfn.I by hverstee r#
#
# Revision 1.1  1995/04/13  14:04:44  pinnacle
# Created: vdtbl/cmd/VDDLO_flfn.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      03/20/95          HV            New
 * 	12/02/97	  vini		Added cell
 *	07/13/99	  Ming		TR179900709
 *
 * -------------------------------------------------------------------*/

class implementation VDCmdDLO;

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
#include "v_slc.h"
#include "VDattrexp.h"
#include "vdtblmacros.h"
#include "VDCmdSSC.h"

#include "grmacros.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "griomacros.h"
#include "grmsg.h"

#include "VDCmdDrwlo.h"
#include "vdsmacros.h"

/*
#define MY_DEBUG
*/



method   VDDLO_fl_formnot  (int        gadget_label;
                            double     value;
                            char     * form_ptr)
{
  IGRint       status;
  IGRlong      retmsg, status1;
  IGRint       nVal;
  IGRint       i, iSet;
  IGRint       iType;
  IGRchar      szFld[VD_DRWLO_CHR_BUFFER];
  IGRchar      tmpFld[VD_DRWLO_CHR_BUFFER];
  IGRchar      szMsg[80], fillTypeFld[30];
  VD_execRes   expVal;
  struct GRid  lGRID;

  IGRlong                               sts,
                                        ret_msg;
  struct        GRactive_symbol_def     active_symbol;
  struct        GRsymbol_lib_file       file;
  struct        GRid                    symbol_id;
  struct        GRmd_env                sl_env;
  int                                   Selflag,
                                        rows,
                                        cell_count ;
  char                                  null[1],
                                        *cell,
                                        active_cell[MAX_SYMBOL_DEF_NAME];


  status   = OM_S_SUCCESS;
  iSet     = -1;
  szMsg[0] = '\0';
  szFld[0] = '\0';
  tmpFld[0] = '\0';
  fillTypeFld[0] = '\0';
  rows     = 0;
  null[0]  = '\0';
  Selflag  = FALSE;


  nVal     = (value > 0) ? (value + 0.001) : (value - 0.001);

  FIfld_get_type (form_ptr, gadget_label, 0, &iType);
  if (iType == FI_ALPHA)
    FIg_get_text (form_ptr, gadget_label, szFld);

#ifdef MY_DEBUG
  printf ("FN fill\n");
#endif

  switch (gadget_label)
  {
    case VD_DLOF_FLD_DEC:
      if (me->nCur_fldrec >= 0)
      {
        if ((nVal < 0) || (nVal > 10))
        {
          strcpy (szMsg, VD_DLO_EMSG_PAR);
          break;
        }
        me->Lfldrec[me->nCur_fldrec].f_decimal = nVal;
        FIg_set_value (form_ptr, gadget_label, value);
      }
      break;

    case VD_DLOF_FLD_FONT:
      if (szFld[0] == '\0') break;
      if (me->nCur_fldrec >= 0)
      {
        szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

        strcpy (me->Lfldrec[me->nCur_fldrec].id_Font, szFld);
        FIg_set_text (form_ptr, gadget_label,
                      me->Lfldrec[me->nCur_fldrec].id_Font);
        me->Pv_need_update = TRUE;
      }
      break;

    case VD_DLOF_FLD_WEIGHT:
      if (me->nCur_fldrec >= 0)
      {
        if ((nVal < 0) || (nVal > 31))
        {
          strcpy (szMsg, VD_DLO_EMSG_PAR);
          break;
        }
        me->Lfldrec[me->nCur_fldrec].id_weight = nVal;
        FIg_set_value (form_ptr, gadget_label, value);
      }
      break;


case VD_DLOF_FLD_LIBRY:
      FIg_get_text (form_ptr, gadget_label, szFld);
      if (szFld[0] == '\0') break;

      /* Commented by Ming for TR179900709
      if(!strcmp(szFld, me->Lfldrec[me->nCur_fldrec].id_Font))  break;
      */

      /* Added by Ming for TR179900709 */
      {
        char *new_file_name = NULL;
        char firstDir[1024];
        char absPathName[1024];

        tmpFld[0] = '\0';
        strcpy( tmpFld, szFld );
        new_file_name = strrchr( szFld, '/' );

        if( !new_file_name )
        {
          firstDir[0] = absPathName[0] = '\0';
          strcpy( firstDir, "." );

          status =
          vd$file_path( msg = &retmsg,
                        fileToFind = szFld,
                        dirToSearchFirst = firstDir,
                        dirInProdPathToSearchThen = VD_DLO_CELL_CONFIG_RELPATH,
                        absPathName = absPathName );

          if( status&retmsg&1 )
            strcpy( szFld, absPathName );
	  else
          {
            strcpy( szMsg, "Can't find cell library!" );
            break;
          }
        }
      }

        sts = gr$symretrieve_cell_library (
                filename = szFld,
                file_no = &file.file_no,
                flag = EX_read_write | EX_read_only,
                fstat = EX_old_module);

        if (sts == GR_E_NO_FILE) {
                strcpy(szMsg,"File Does Not Exist");
                break;
                }
        else if (sts == GR_E_NOT_CELL_LIB) {
                strcpy(szMsg,"File Not A Cell Library");
                break;
                }
                else if (sts == GR_E_NO_PREMISSION) {

                strcpy(szMsg,"No Permission for Operation");
                break;
                }
            else if( !(sts & 1)) break;

        strcpy(file.file_name,szFld);

        sts = gr$symput_asl ( msg = &ret_msg,
                     file = &file);

	/* Added by Ming for TR179900709 */
	strcpy( szFld, tmpFld );

        gr$symget_active_symbol (msg = &ret_msg,
                   act_symbol_def = &active_symbol);
        if(ret_msg == MSSUCC)
                strcpy( active_cell,active_symbol.name);
        else  active_cell[0] = '\0';

        /* for the cells in the library */
        cell = NULL;
        gr$get_cell_def_info( p_count = &cell_count,
                        pp_names = &cell);

      if (me->nCur_fldrec >= 0)
      {
        if (me->Lfldrec[me->nCur_fldrec].fieldtype == VD_DRWLO_EN_CELL)
        {
        szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

        strcpy (me->Lfldrec[me->nCur_fldrec].id_Font, szFld);
        FIg_set_text (form_ptr, gadget_label,
                      me->Lfldrec[me->nCur_fldrec].id_Font);
        me->Pv_need_update = TRUE;
        }
      }


       if(cell_count == 0 )
            strcpy (szMsg, " Cells not defined in the library \n");

        null[0] = '\0';
        FIfld_get_list_num_rows( form_ptr, VD_DLOF_FLD_CELLS,0, &rows );
     for (i=0; i<rows; i++) {
          VDfld_set_list_text (form_ptr, VD_DLOF_FLD_CELLS, i, 0,
                        null, Selflag);
        }

  if (cell_count > 5)
    FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_CELLS, 1, 0);
  else
    FIfld_set_list_scroll (form_ptr, VD_DLOF_FLD_CELLS, 0, 0);

  for (i=0; i<cell_count; i++)
  {

    VDfld_set_list_text (form_ptr, VD_DLOF_FLD_CELLS, i, 0,
               &cell[MAX_SYMBOL_DEF_NAME * i], Selflag);
  }
  if (cell != NULL) free(cell);
        break;


case VD_DLOF_FLD_CELLS:
        FIg_get_text (form_ptr, gadget_label, szFld);
        if (szFld[0] == '\0') break;

        sts = gr$symsd_locate_in_all_sl ( msg = &ret_msg,
                     sd_name = szFld,
                     sl_env = &sl_env,
                     sd_id = &symbol_id);
        if( ret_msg == MSFAIL) {
                 strcpy(szMsg,"Symbol Not Defined");
                 break;
         }
        else if (ret_msg == MSSUCC) {
      if (me->nCur_fldrec >= 0)
      {
        if ( me->Lfldrec[me->nCur_fldrec].fieldtype == VD_DRWLO_EN_CELL )
        {
        szFld[VD_DRWLO_CHR_TEXT-1] = '\0';

        strcpy (me->Lfldrec[me->nCur_fldrec].Ftext, szFld);

        FIg_set_text (form_ptr, gadget_label,
                      me->Lfldrec[me->nCur_fldrec].Ftext);
        me->Pv_need_update = TRUE;
        }
      }

                sts = gr$symput_active_symbol ( msg = &ret_msg,
                     symbol_name = szFld,
                         symbol_id = &symbol_id,
                     asl_env = &sl_env);
                if(!( ret_msg & 1))break;
             }
      break;


    case VD_DLOF_FLD_EXPATT:
/*    if (szFld[0] == '\0') break; */

      if (me->nCur_fldrec >= 0)
      {
        szFld[VD_DRWLO_CHR_DESC-1] = '\0';

        strcpy (me->Lfldrec[me->nCur_fldrec].id_name, szFld);

        FIg_set_text (form_ptr, gadget_label,
                      me->Lfldrec[me->nCur_fldrec].id_name);
        me->Pv_need_update = TRUE;
      }

      break;

    case VD_DLOF_FLD_TEXT:
/*    if (szFld[0] == '\0') break; */

      /* tr 179528568 */
      FIg_get_text (form_ptr, VD_DLOF_FLD_FILL, fillTypeFld);
      if( !strcmp( fillTypeFld, "Expression")){
         status1 = 0;
         status1 = VD_expParse(      szFld,
                                  FALSE,
                                  VD_EXP_WARNING,
                                  0, NULL,
                                  &expVal );

         if( !(status1&1) ) {
          strcpy (szMsg, "Expression syntax error!");
         }
      }
      if (me->nCur_fldrec >= 0)
      {
        szFld[VD_DRWLO_CHR_TEXT-1] = '\0';

        strcpy (me->Lfldrec[me->nCur_fldrec].Ftext, szFld);

        FIg_set_text (form_ptr, gadget_label,
                      me->Lfldrec[me->nCur_fldrec].Ftext);
        me->Pv_need_update = TRUE;
      }
      break;

    case VD_DLOF_FLD_FILL:
/*    if (szFld[0] == '\0') break; */

      FIg_set_text( form_ptr, VD_DLOF_FLD_EXPRESS, "" );

      if( me->nCur_fldrec >= 0 )
      {
        strcpy( me->Lfldrec[me->nCur_fldrec].Ftext  , "" );
        strcpy( me->Lfldrec[me->nCur_fldrec].id_name, "" );
      }

      if (me->nCur_fldrec >= 0)
      {
        szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

/* for the cell */
//        for (i=0; i<9; i++)
        for (i=0; i<10; i++)
        {
          if (strcmp (szFld, &me->pr_filltyp[i*VD_DRWLO_CHR_IDFLD]) == 0)
          {
            iSet = i;
            break;
          }
        }

        if (iSet < 0)
          strcpy (szMsg, VD_DLO_EMSG_INV);
        else
        {
          me->Pv_need_update = TRUE;
          me->Lfldrec[me->nCur_fldrec].fieldtype = iSet;
        }
      }

      if( me->nCur_fldrec >= 0 )
      {
        if( me->Lfldrec[me->nCur_fldrec].fieldtype == VD_DRWLO_EN_EXPR_TABLE )
        {
          FIg_display ( form_ptr, VD_DLOF_FLD_EXTYP );
          FIg_display ( form_ptr, VD_DLOF_TXT_EXTYP );
          FIg_set_text( form_ptr, VD_DLOF_FLD_EXTYP, "" );
          FIg_set_text( form_ptr, VD_DLOF_FLD_EXNAM, "" );
        }
      }
      break;

    case VD_DLOF_FLD_EXTYP:

      FIg_display( form_ptr, VD_DLOF_FLD_EXNAM );
      FIg_display( form_ptr, VD_DLOF_TXT_EXNAM );
      FIg_set_text( form_ptr, VD_DLOF_FLD_EXNAM, "" );
      FIg_set_text( form_ptr, VD_DLOF_FLD_EXPRESS, "" );

      status =
      om$send( msg      = message VDCmdDLO.VDDLO_expnam(&retmsg,
                                                        form_ptr,
                                                        szFld),
               targetid = my_id );

      if( retmsg != MSSUCC )
      {
        UI_status( VD_CREXP_EMSG_NNAM );
        strcpy( szMsg, VD_CREXP_EMSG_NNAM );
        break;
      }

      if( me->nCur_fldrec >= 0 )
      {
        strcpy( me->Lfldrec[me->nCur_fldrec].Ftext, "" );
        strcpy( me->Lfldrec[me->nCur_fldrec].Ftext, szFld );
        me->Pv_need_update = TRUE;
      }

      break;

    case VD_DLOF_FLD_EXNAM:

      FIg_get_text( form_ptr, VD_DLOF_FLD_EXTYP, tmpFld );
      if( tmpFld[0] == '\0' )
      {
        strcpy( szMsg, VD_CREXP_EMSG_TKIN );
        UI_status( szMsg );
        break;
      }

      if( me->nCur_fldrec >= 0 )
      {
        strcpy( me->Lfldrec[me->nCur_fldrec].Ftext, "" );
        strcpy( me->Lfldrec[me->nCur_fldrec].Ftext, tmpFld );
      }
      else
        break;

      vd$tblexp_old( msg     = &retmsg,
                     osnum   = me->My_OS,
                     tabnam  = szFld,
                     GRid    = &lGRID );

      if( lGRID.objid == NULL_OBJID )
      {
        sprintf( szMsg, VD_CREXP_EMSG_NSYM, szFld );
        UI_status( szMsg );
        break;
      }
      else
      {
        if( me->nCur_fldrec >= 0 )
        {
          szFld[VD_DRWLO_CHR_TEXT-1] = '\0';
          strcat( me->Lfldrec[me->nCur_fldrec].Ftext, "," );
          strcat( me->Lfldrec[me->nCur_fldrec].Ftext, szFld );
          me->Pv_need_update = TRUE;
        }

      }

      break;

    case VD_DLOF_FLD_DTYPE:
      if (szFld[0] == '\0') break;

      if (me->nCur_fldrec >= 0)
      {
        szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

        for (i=0; i<2; i++)
        {
          if (strcmp (szFld, &me->pr_dattyp[i*VD_DRWLO_CHR_IDFLD]) == 0)
          {
            iSet = i;
            break;
          }
        }

        if (iSet < 0)
          strcpy (szMsg, VD_DLO_EMSG_INV);
        else
          me->Lfldrec[me->nCur_fldrec].datatype = iSet;
      }
      break;

    case VD_DLOF_FLD_JUST:
      if (szFld[0] == '\0') break;

      if (me->nCur_fldrec >= 0)
      {
        szFld[VD_DRWLO_CHR_IDFLD-1] = '\0';

        for (i=0; i<3; i++)
        {
          if (strcmp (szFld, &me->pr_justif[i*VD_DRWLO_CHR_IDFLD]) == 0)
          {
            iSet = i;
            break;
          }
        }

        if (iSet < 0)
          strcpy (szMsg, VD_DLO_EMSG_INV);
        else
        {
          me->Pv_need_update = TRUE;
          me->Lfldrec[me->nCur_fldrec].justification = iSet;
        }
      }
      break;

    case VD_DLOF_BTN_DEFAULT:
      if (me->nCur_fldrec >= 0)
      {
        VD_drwlo_mfld (&me->FldCUR, &(me->Lfldrec[me->nCur_fldrec]));
        me->FldCUR.lin_seqno       = 0;
        me->FldCUR.col_seqno       = 0;
        me->FldCUR.fieldid[0]      = '\0';
        me->FldCUR.id_name[0]      = '\0';
        me->FldCUR.Ftext[0]        = '\0';
        me->FldCUR.hdtr_type       = VD_DRWLO_EN_ALL;
      }
      break;

    case VD_RLOF_FLD_LINENUM:
      if ((nVal < 1) || (nVal > me->nMax_linenum))
      {
        strcpy (szMsg, VD_DLO_EMSG_PAR);
        break;
      }

      me->nCur_linenum = nVal;
      break;

    case VD_DLOF_BTN_DN:
      if (me->nCur_linenum > 1) me->nCur_linenum--;
      goto F_PROCESS;

    case VD_DLOF_BTN_UP:
      if (me->nCur_linenum < me->nMax_linenum) me->nCur_linenum++;

      F_PROCESS:
      status =
      om$send (msg = message VDdrwlo.VDdrwlo_xfld
                            (&retmsg, me->nCur_group, me->nCur_colnum,
                              me->sCur_fieldid, me->nCur_linenum,
                             &me->nCur_fldrec),
          targetid = my_id);
#ifdef MY_DEBUG
      printf (" cur fldrec %d\n",me->nCur_fldrec);
#endif
      break;

    case FI_CANCEL:
    case FI_ACCEPT:
      /* tr 179528568 */
      FIg_get_text (form_ptr, VD_DLOF_FLD_FILL, fillTypeFld);
      if( !strcmp( fillTypeFld, "Expression")){
         FIg_get_text (form_ptr, VD_DLOF_FLD_TEXT, szFld);
         status1 = 0;
         status1 = VD_expParse(   szFld,
                                  FALSE,
                                  VD_EXP_WARNING,
                                  0, NULL,
                                  &expVal );

         if( !(status1&1) ) {
          strcpy (szMsg, "Expression syntax error!");
          break;
         }
      }

      status =
      om$send (msg = message VDCmdDLO.save_form_pos
                            (&retmsg, me->My_actv_form, form_ptr),
          targetid = my_id);

      me->nCur_fldrec    = -1;
      me->nCur_linenum   = 0;

      if (me->Pv_need_update)
      {
        status =
        om$send (msg = message VDCmdDLO.VDDLO_disp
                               (me->forms[VD_DLO_MAINFORM].form_ptr),
            targetid = my_id);
      }

      _put_response( resp = EX_FORM_FINISHED );
      goto quit;
  }

  status =
  om$send (msg = message VDCmdDLO.VDDLO_disp (form_ptr),
      targetid = my_id);

  FIg_set_text (form_ptr, VD_DLOF_FLD_MSG, szMsg);

  quit:
#ifdef MY_DEBUG
  printf ("FN fill exit\n");
#endif
  return (status);
}

end implementation VDCmdDLO;

