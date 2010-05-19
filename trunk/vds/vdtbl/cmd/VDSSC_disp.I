/* $Id: VDSSC_disp.I,v 1.6 2001/07/02 14:44:05 ylong Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDSSC_disp.I
 *
 * Description:
 *
 * Main form display for edit/review sort/summarization object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_disp.I,v $
 *      Revision 1.6  2001/07/02 14:44:05  ylong
 *      *** empty log message ***
 *
 *      Revision 1.5  2001/01/30 21:13:56  ad
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/01/22 18:41:09  paul_noel
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/22 15:22:42  paul_noel
 *      Update from SPX on init
 *
 *      Revision 1.2  2001/01/18 20:24:03  paul_noel
 *      Changes were to match latest service pack before conversion
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/12/06  22:08:56  pinnacle
# ylong
#
# Revision 1.2  2000/09/07  13:26:00  pinnacle
# Replaced: vds/vdtbl/cmd/VDSSC_disp.I for:  by mdong for Service Pack
#
# Revision 1.1  2000/09/07  13:12:46  pinnacle
# Created: vds/vdtbl/cmd/VDSSC_disp.I by mdong for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/11  02:40:18  pinnacle
# Replaced: vdtbl/cmd/VDSSC_disp.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.6  1996/03/07  23:12:12  pinnacle
# Replaced: vdtbl/cmd/VDSSC_disp.I for:  by yzhu for vds.240
#
# Revision 1.5  1995/09/25  23:00:52  pinnacle
# Replaced: vdtbl/cmd/VDSSC_disp.I for:  by sundar for vds.240
#
# Revision 1.4  1995/08/04  14:38:00  pinnacle
# Replaced: vdtbl/cmd/VDSSC_disp.I for:  by hverstee for vds.240
#
# Revision 1.2  1995/07/06  16:21:14  pinnacle
# Replaced: vdtbl/cmd/VDSSC_disp.I for:  by hverstee for vds.240
#
# Revision 1.1  1995/06/07  20:21:22  pinnacle
# Created: vdtbl/cmd/* by tdumbach for vds.240
#
# Revision 1.4  1995/05/24  15:19:00  pinnacle
# Replaced: vdtbl/cmd/VDSSC_disp.I by hverstee r#
#
# Revision 1.3  1995/05/15  16:17:54  pinnacle
# Replaced: vdtbl/cmd/VDSSC_disp.I by hverstee r#
#
# Revision 1.2  1995/05/11  17:00:14  pinnacle
# Replaced: vdtbl/cmd/VDSSC_disp.I by hverstee r#
#
# Revision 1.1  1995/04/29  17:00:50  pinnacle
# Created: vdtbl/cmd/VDSSC_disp.I by hverstee r#
# rno
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      04/20/95          HV            New
 *	09/06/00	  Ming		CR179901855
 *	12/06/00	ylong		TR4267
 *	01/30/01	ylong		TR4453
 *	07/02/01	ylong		TR5400
 * -------------------------------------------------------------------*/

class implementation VDCmdSSC;

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
#include "VDmem.h"
#include "v_dbgmacros.h"
 

method   VDSSC_disp (char    * form_ptr)

{
  IGRchar	*ExpInfo, 
		rowText[VD_DRWLO_CHR_BUFFER], 
		text[2000],
		*syntax, 
		*ptr = NULL;
  int           i, idsp;
  IGRint        Selflag;
  IGRint	num_row, txtLen, row, fldLen, len;
  IGRint        traceFlag = 0 ;
  


  SetProc( VDCmdSSC.VDSSC_disp ); Begin

  ExpInfo     = NULL;
  syntax      = NULL;
  Selflag     = FALSE;
  fldLen      = VD_DRWEXP_PROG_RWFLD;

  if(traceFlag) printf(">>> vds/vdtbl/cmd/VDSSC_disp.I: method VDSSC_disp\n");
  
  switch (me->My_actv_form)
  {
    case VD_SSC_SORTFORM:
      __DBGpr_com (" Edit sort display\n");

      /*    display header   */

      FIg_set_text (form_ptr, VD_CRSRT_FLD_TABNAM, me->CUR_tabnam);

      FIg_set_text (form_ptr, VD_CRSRT_FLD_USERID, me->SSid_tab.Userid);
      FIg_set_text (form_ptr, VD_CRSRT_FLD_DESCR , me->SSid_tab.Shdesc);
      FIg_set_text (form_ptr, VD_CRSRT_FLD_TIMEST, me->SSid_tab.Timest);

      if (me->SSid_tab.Local)
        FIg_set_text (form_ptr, VD_CRSRT_FLD_LOCAL, "X");
      else
        FIg_set_text (form_ptr, VD_CRSRT_FLD_LOCAL, " ");

      if (me->My_Type == VD_CMD_SRT_EDIT)
        FIg_set_text (form_ptr, VD_CRSRT_FLD_COPY,   "");

      /*    display data   */

      if (me->nCurSrt < 0)
      {   /*    display blank     */

        FIg_set_value (form_ptr, VD_CRSRT_FLD_SEQNO, (double) 0);

        if (me->My_Type == VD_CMD_SRT_EDIT)
        {
          FIg_set_state_off (form_ptr, VD_CRSRT_TGG_SEQ);
          FIg_set_state_off (form_ptr, VD_CRSRT_TGG_TYP);
        }

        FIg_set_text  (form_ptr, VD_CRSRT_FLD_ATTR, "");
      }
      else
      {
        FIg_set_value (form_ptr, VD_CRSRT_FLD_SEQNO,
                        (double) me->Lsortrec[me->nCurSrt].nsIndex);
        if (me->My_Type == VD_CMD_SRT_EDIT)
        {
          if (me->Lsortrec[me->nCurSrt].nsSeq == VD_DRWLO_EN_DESCEND)
            FIg_set_state_off (form_ptr, VD_CRSRT_TGG_SEQ);
          else
            FIg_set_state_on  (form_ptr, VD_CRSRT_TGG_SEQ);

          if (me->Lsortrec[me->nCurSrt].nsTyp == VD_DRWLO_EN_ASCII)
            FIg_set_state_off (form_ptr, VD_CRSRT_TGG_TYP);
          else
            FIg_set_state_on  (form_ptr, VD_CRSRT_TGG_TYP);
        }
        else
        {
          if (me->Lsortrec[me->nCurSrt].nsSeq == VD_DRWLO_EN_DESCEND)
            FIg_set_text (form_ptr, VD_CRSRT_FLD_REVSEQ, "DESCENDING");
          else
            FIg_set_text (form_ptr, VD_CRSRT_FLD_REVSEQ, "ASCENDING");

          if (me->Lsortrec[me->nCurSrt].nsTyp == VD_DRWLO_EN_ASCII)
            FIg_set_text (form_ptr, VD_CRSRT_FLD_REVTYP, "ASCII");
          else
            FIg_set_text (form_ptr, VD_CRSRT_FLD_REVTYP, "NUMERIC");
        }

        FIg_set_text  (form_ptr, VD_CRSRT_FLD_ATTR,
                                 me->Lsortrec[me->nCurSrt].szAtt);
      }
      break;

    case VD_SSC_SUMMFORM:
      __DBGpr_com (" Edit summarization display\n");

      /*    display header   */

      FIg_set_text (form_ptr, VD_CRSUM_FLD_TABNAM, me->CUR_tabnam);

      FIg_set_text (form_ptr, VD_CRSUM_FLD_USERID, me->SSid_tab.Userid);
      FIg_set_text (form_ptr, VD_CRSUM_FLD_DESCR , me->SSid_tab.Shdesc);
      FIg_set_text (form_ptr, VD_CRSUM_FLD_TIMEST, me->SSid_tab.Timest);

      if (me->SSid_tab.Local)
        FIg_set_text (form_ptr, VD_CRSUM_FLD_LOCAL, "X");
      else
        FIg_set_text (form_ptr, VD_CRSUM_FLD_LOCAL, " ");

      if (me->My_Type == VD_CMD_SUM_EDIT)
        FIg_set_text (form_ptr, VD_CRSUM_FLD_COPY,   "");

      /*    display data   */

      FIg_set_text (form_ptr, VD_CRSUM_FLD_CAT   , me->CUR_catnam);
      FIg_set_text (form_ptr, VD_CRSUM_FLD_SUBCAT, me->CUR_subcat);

      if ((me->CUR_catnam[0] == '\0') ||
          (me->CUR_subcat[0] == '\0'))
      {
        FIg_erase (form_ptr, VD_CRSUM_GDG_GROUP);
        FIg_erase (form_ptr, VD_CRSUM_TGG_QTYP);
        FIg_erase (form_ptr, VD_CRSUM_TGG_ATYP);
        FIg_erase (form_ptr, VD_CRSUM_FLD_QTYP);
        FIg_erase (form_ptr, VD_CRSUM_FLD_ATYP);
        break;
      }

      FIg_display (form_ptr, VD_CRSUM_GDG_GROUP);

      if (me->My_Type == VD_CMD_SUM_EDIT)
      {
        FIg_display (form_ptr, VD_CRSUM_TGG_QTYP);
        FIg_display (form_ptr, VD_CRSUM_TGG_ATYP);
      }
      else
      {
        FIg_display (form_ptr, VD_CRSUM_FLD_QTYP);
        FIg_display (form_ptr, VD_CRSUM_FLD_ATYP);

        FIg_erase   (form_ptr, VD_CRSUM_BTN_INSERT);
        FIg_erase   (form_ptr, VD_CRSUM_BTN_DELETE);
        FIg_erase   (form_ptr, VD_CRSUM_BTN_DELCAT);
      }


      if (me->nCurQty < 0)
      {
        if (me->My_Type == VD_CMD_SUM_EDIT)
          FIg_set_state_off (form_ptr, VD_CRSUM_TGG_QTYP);
        else
          FIg_set_text      (form_ptr, VD_CRSUM_FLD_QTYP, "Count");

        FIg_erase     (form_ptr, VD_CRSUM_FLD_QEXP);
        FIg_erase     (form_ptr, VD_CRSUM_TXT_QEXP);
      }
      else
      {
        __DBGpr_int ("set toggle qty %d \n",me->Lsqtyrec[me->nCurQty].nSflag);

        if (me->My_Type == VD_CMD_SUM_EDIT)
        {
          if (me->Lsqtyrec[me->nCurQty].nSflag == 0)
            FIg_set_state_off (form_ptr, VD_CRSUM_TGG_QTYP);
          else
            FIg_set_state_on  (form_ptr, VD_CRSUM_TGG_QTYP);
        }
        else
        {
          if (me->Lsqtyrec[me->nCurQty].nSflag == 0)
            FIg_set_text (form_ptr, VD_CRSUM_FLD_QTYP, "Count");
          else
            FIg_set_text (form_ptr, VD_CRSUM_FLD_QTYP, "Expression");
        }

        if (me->Lsqtyrec[me->nCurQty].nSflag == 0)
        {
          FIg_erase     (form_ptr, VD_CRSUM_FLD_QEXP);
          FIg_erase     (form_ptr, VD_CRSUM_TXT_QEXP);
        }
        else
        {
          FIg_display   (form_ptr, VD_CRSUM_FLD_QEXP);
          FIg_display   (form_ptr, VD_CRSUM_TXT_QEXP);

          FIg_set_text  (form_ptr, VD_CRSUM_FLD_QEXP  ,
                                 me->Lsqtyrec[me->nCurQty].szExp);
        }
      }

  __DBGpr_int ("current matchrecord %d \n",me->nCurMtc);
      if (me->nCurMtc < 0)
      {
        FIg_set_value (form_ptr, VD_CRSUM_FLD_MSEQ, (double) 0);
        if (me->My_Type == VD_CMD_SUM_EDIT)
          FIg_set_value (form_ptr, VD_CRSUM_TGG_ATYP, (double) 0);
        else
          FIg_set_text  (form_ptr, VD_CRSUM_FLD_ATYP, "ASCII");

        FIg_set_text  (form_ptr, VD_CRSUM_FLD_MATT, "");
        /* TR179600521 */
        if (me->My_Type == VD_CMD_SUM_EDIT)
              FIg_set_text  (form_ptr, VD_CRSUM_FLD_MREL, "");
        else
              FIg_set_text  (form_ptr, VD_CRSUM_FLD_MREL_REW, "");

        FIg_set_text  (form_ptr, VD_CRSUM_FLD_MEXP, "");
      }
      else
      {
        int       jIndex;

        jIndex = me->Lsmtcrec[me->nCurMtc].nnREL * VD_CRSUM_STL_COMPAR;

        FIg_set_value (form_ptr, VD_CRSUM_FLD_MSEQ,
                        (double) me->Lsmtcrec[me->nCurMtc].nsIndex);

        if (me->My_Type == VD_CMD_SUM_EDIT)
          FIg_set_value (form_ptr, VD_CRSUM_TGG_ATYP,
                        (double) me->Lsmtcrec[me->nCurMtc].nDattyp);
        else
        {
          if (me->Lsmtcrec[me->nCurMtc].nDattyp == 0)
            FIg_set_text  (form_ptr, VD_CRSUM_FLD_ATYP, "ASCII");
          else
            FIg_set_text  (form_ptr, VD_CRSUM_FLD_ATYP, "Numeric");
        }

        __DBGpr_int ("set toggle atp %d \n",me->Lsmtcrec[me->nCurMtc].nDattyp);

        FIg_set_text  (form_ptr, VD_CRSUM_FLD_MATT, 
                                 me->Lsmtcrec[me->nCurMtc].szAtt);
        /* TR179600521 */
        if (me->My_Type == VD_CMD_SUM_EDIT)
        	FIg_set_text  (form_ptr, VD_CRSUM_FLD_MREL, 
                                 &me->pCompar[jIndex]);
        else 
        	FIg_set_text  (form_ptr, VD_CRSUM_FLD_MREL_REW, 
                                 &me->pCompar[jIndex]);
        FIg_set_text  (form_ptr, VD_CRSUM_FLD_MEXP, 
                                 me->Lsmtcrec[me->nCurMtc].szExp);
      }
      break;

    case VD_SSC_EXPRFORM:

      __DBGpr_com( "Edit/Review expression display\n" );

      /*
      **    display header
      */

      if( me->CUR_exptyp != NULL )
        FIg_set_text( form_ptr, VD_CREXP_FLD_EXPTYPE, me->CUR_exptyp );
      if( me->CUR_expnam != NULL )
        FIg_set_text( form_ptr, VD_CREXP_FLD_EXPNAM , me->CUR_expnam );
      if( me->CUR_cpynam != NULL )
        FIg_set_text( form_ptr, VD_CREXP_FLD_COPY   , me->CUR_cpynam );
      FIg_set_text( form_ptr, VD_CREXP_FLD_USERID , me->SSid_exp.Userid );
      FIg_set_text( form_ptr, VD_CREXP_FLD_DESCR  , me->SSid_exp.Shdesc );
      FIg_set_text( form_ptr, VD_CREXP_FLD_TIMEST , me->SSid_exp.Timest );

      if( me->SSid_exp.Local )
        FIg_set_text( form_ptr, VD_CREXP_FLD_LOCAL, "X");
      else
        FIg_set_text( form_ptr, VD_CREXP_FLD_LOCAL, " ");

      /*
      **    display data
      */

      if( me->cpymode == VD_DRWEXP_EN_APPEND )
	FIg_set_state_on ( form_ptr, VD_CREXP_TGG_CPYTYP );
      else
     	FIg_set_state_off( form_ptr, VD_CREXP_TGG_CPYTYP );

      if( me->outmode == VD_DRWEXP_EN_ASCII )
	FIg_set_state_on ( form_ptr, VD_CREXP_TGG_OUTTYP );
      else
     	FIg_set_state_off( form_ptr, VD_CREXP_TGG_OUTTYP );

      FIg_reset( form_ptr, VD_CREXP_FLD_PROG );
      if( me->nExprData > 0 )
      {
	IGRchar	*sp = NULL;
	ExpInfo    = _MALLOC( me->nExprData * VD_CREXP_CHR_INFO, IGRchar );
        ExpInfo[0] = '\0';

	for( i = 0 ; i < me->nExprData ; i++ )
        {
	  strcat( ExpInfo, me->Lexpdata[i].Datinfo );
	}

	/* Clean up new line control character for TR4267 */
	while( (sp = strchr(ExpInfo, '\n')) != NULL ) {
		*sp = ' ';
	}

	/* Modified by Ming for TR179901855 */
	/* Modified again by ylong for TR4453 */
	/*
        FIg_set_text( form_ptr, VD_CREXP_FLD_PROG, ExpInfo );
	*/
	row = 0;
	strcpy(text, ExpInfo);
        syntax = ExpInfo;
        txtLen = strlen( syntax );
        while( txtLen > fldLen )
        {
          rowText[0] = '\0';
	  // clean space at beginning
	  for( i = 0; i < fldLen && isspace(syntax[i]); i++);
	  syntax = &syntax[i];

	  // if first word exceeds VD_DRWEXP_PROG_RWFLD, just keep it
	  // else wrapup the row
	  strcpy(text, syntax);
	  ptr = strpbrk(text, " \t\n\0");
	  if(ptr) *ptr = '\0';			// check null
	  len = strlen( text );
	  if( len > VD_DRWEXP_PROG_RWFLD ) {
		strcpy( rowText, text ); 
		syntax += len;
	  }
	  else {
		for( i = fldLen-1; i > 0 && !isspace(syntax[i]); i--);
		strncpy( rowText, syntax, i );
		rowText[i] = '\0';
		syntax += strlen( rowText );
	  }
	  txtLen = strlen( syntax );
          FIfld_set_text( form_ptr,
                          VD_CREXP_FLD_PROG,
                          row,
                          0,
                          rowText,
                          FALSE );
          row++;
        }

	// clean space at beginning for last line and fill it to form
	for( i = 0; i < fldLen && isspace(syntax[i]); i++);
        FIfld_set_text( form_ptr,
                        VD_CREXP_FLD_PROG,
                        row,
                        0,
                        &syntax[i],
                        FALSE );

        FIfld_get_num_rows( form_ptr, VD_CREXP_FLD_PROG, &num_row ); 
        FIfld_set_active_row( form_ptr, VD_CREXP_FLD_PROG, num_row-1, 0 );

        _FREE( ExpInfo );

      }

      if( me->nExprTyps > 0 )
      {
        FIfld_set_list_num_rows( form_ptr,
                                 VD_CREXP_FLD_EXPTYPE,
                                 0,
                                 (int)me->nExprTyps );
        if( me->nExprTyps > 10 )
        {
          FIfld_set_list_scroll( form_ptr,
                                 VD_CREXP_FLD_EXPTYPE,
                                 1,
                                 0 );
        }
        else
        {
          FIfld_set_list_scroll( form_ptr,
                                 VD_CREXP_FLD_EXPTYPE,
                                 0,
                                 0 );
        }
        for( i = 0 ; i < me->nExprTyps ; i++ )
        {
          idsp = i * VD_CREXP_CHR_TYPE;
          VDfld_set_list_text( form_ptr,
                               VD_CREXP_FLD_EXPTYPE,
                               i,
                               0,
                               &me->pExprTyps[idsp],
                               Selflag );
        }
      }

      break;

    default:
      break;
  }

  __DBGpr_com ("display done.....\n");
  if(traceFlag) printf("<<< vds/vdtbl/cmd/VDSSC_disp.I: method VDSSC_disp[%d]\n");
  
  End
  return (OM_S_SUCCESS);
}

end implementation VDCmdSSC;

