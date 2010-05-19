
/* $Id: VDSSC_fexp.I,v 1.5 2001/03/09 23:21:11 ylong Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDSSC_fexp.I
 *
 * Description:
 *
 * Implementation file for expression form notification
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_fexp.I,v $
 *      Revision 1.5  2001/03/09 23:21:11  ylong
 *      *** empty log message ***
 *
 *      Revision 1.4  2001/02/23 18:15:17  ylong
 *      *** empty log message ***
 *
 *      Revision 1.3  2001/01/30 21:14:00  ad
 *      *** empty log message ***
 *
 *      Revision 1.2  2001/01/18 20:30:57  paul_noel
 *      Changes were to match latest service pack before conversion
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.4  1999/05/13  21:27:26  pinnacle
# (No comment)
#
# Revision 1.3  1999/05/05  13:36:34  pinnacle
# (No comment)
#
# Revision 1.2  1998/11/04  19:58:42  pinnacle
# tr179802265
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/01/23  16:30:24  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fexp.I for:  by mdong for vds
#
# Revision 1.3  1998/01/09  21:29:10  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fexp.I for:  by mdong for vds
#
# Revision 1.2  1997/12/11  19:41:04  pinnacle
# Replaced: vdtbl/cmd/VDSSC_fexp.I for:  by mdong for vds
#
# Revision 1.1  1997/11/11  02:45:18  pinnacle
# Created: vdtbl/cmd/VDSSC_fexp.I by mdong for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      09/23/97	Ming Dong	creation
 *      11/04/98	ylong		tr179802265
 *	01/30/01	ylong		TR4453
 *	02/23/01	ylong		TR4730
 *	03/09/01	ylong		CR4796
 *
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

#include "VDdrwlo_pr.h"
#include "VDmem.h"
#include "VDdrwlo.h"
#include "vdtblmacros.h"
#include "PDUerror.h"
#include "VDmsg.h"
#include "v_dbgmacros.h"
#include "VDDbDef.h"

%safe
#include <math.h>
%endsafe

/*
#define   MY_DEBUG
*/

extern int 		VDSverify_login();
extern IGRboolean	VD_TBL_idquote();
extern IGRint		VD_EXP_SetIndx();

from VDcrexp               import VDcrexp_init;


method   VDSSC_exp_fn ( int        gadget_label;
                        double     value;
                        char       *form_ptr )
{
  IGRint       		status;
  IGRlong      		retmsg;
  IGRchar      		szFld[VD_CREXP_CHR_DESC];
  IGRchar      		szmsg[80], buffer[VD_DRWEXP_CHR_NAME];
  IGRchar      		funcsym[VD_DRWEXP_CHR_NAME];
  int          		i, num_rows, j, idsp;
  struct GRid		lGRID;
  IGRint		row, pos, sel;
  IGRchar		*txtprog;
  unsigned char		txtrow[VD_DRWLO_CHR_BUFFER];
  IGRchar		Tabnam[VD_DRWEXP_CHR_NAME];
  IGRchar		Tabcol[VD_DRWEXP_CHR_NAME];
  IGRchar               output[VD_CREXP_CHR_INFO];
  int			active_char0, active_char1;
  int			active_row0, active_row1;
  IGRint		length, txtLen;


  SetProc( VDCmdSSC.VDSSC_exp_fn ); Begin

  status     = OM_S_SUCCESS;
  szmsg[0]   = '\0';
  szFld[0]   = '\0';
  buffer[0]  = '\0';
  funcsym[0] = '\0';
  Tabnam[0]  = '\0';
  txtrow[0]  = '\0';
  Tabcol[0]  = '\0';
  txtprog    = NULL;
  length     = 0;
  txtLen     = 0;

  UI_status( "" );

  switch( gadget_label )
  {
    case VD_CREXP_FLD_EXPTYPE:

      me->insert_pos = -1;

      FIg_get_text( form_ptr, gadget_label, szFld );
      if( szFld[0] == '\0' ) break;

      for( i = 0 ; szFld[i] != '\0' ; ++i )
      {
        if( szFld[i] != ' ' && szFld[i] != '\t' ) break;
      }
      if( szFld[i] == '\0' )
      {
        strcpy( szmsg, "Keyin correct expression type" );
        UI_status( szmsg );
        break;
      }

      if( VD_TBL_idquote(szFld) )
      {
        strcpy( szmsg, VD_SSC_EMSG_QTE );
        UI_status( szmsg );
        break;
      }

      if( me->CUR_exptyp[0] != '\0' )
      {
	status =
	om$send( msg      = message VDCmdSSC.VDSSC_StExp(&retmsg),
                 targetid = my_id );
      }

      /* Use above block to replace this one for CR4796 to reset fields
      if( me->CUR_exptyp[0] != '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NACT );
        UI_status( szmsg );
        break;
      }
      */

      strcpy( me->CUR_exptyp, szFld );
      strcpy( me->SSid_exp.Tabtyp, szFld );

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_ExpNam(&retmsg,
						        form_ptr,
						        szFld),
               targetid = my_id );

      if( retmsg != MSSUCC )
      {
        UI_status( VD_CREXP_EMSG_NNAM );
	strcpy( szmsg, VD_CREXP_EMSG_NNAM );
        break;
      }

      break;

    case VD_CREXP_FLD_EXPNAM:

      me->insert_pos = -1;

      if( me->CUR_exptyp[0] == '\0' )
      {
	strcpy( szmsg, VD_CREXP_EMSG_TKIN );
        UI_status( szmsg );
	break;
      }

      FIg_get_text( form_ptr, gadget_label, szFld );
      if( szFld[0] == '\0' ) break;

      if( VD_TBL_idquote(szFld) )
      {
        strcpy( szmsg, VD_SSC_EMSG_QTE );
        UI_status( szmsg );
        break;
      }

      /* Commented out for CR4796
      if( me->CUR_expnam[0] != '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NACT );
        UI_status( szmsg );
        break;
      }
      */

      vd$tblexp_old( msg     = &retmsg,
                     osnum   = me->My_OS,
                     tabnam  = szFld,
                     GRid    = &lGRID );

      strcpy( me->CUR_expnam, szFld );
      strcpy( me->SSid_exp.Tabnam, me->CUR_expnam );


      if( lGRID.objid == NULL_OBJID )
      {
      /*
      **    does not exist, create new
      */
        if( me->My_Type == VD_CMD_EXP_REV )
        {
          sprintf( szmsg, VD_CREXP_EMSG_NSYM, szFld );
          UI_status( szmsg );
          break;
        }

        vd$tblexp_new( msg    = &retmsg,
		       osnum  = me->My_OS,
		       tabnam = me->CUR_expnam,
		       GRid   = &lGRID );

	me->newflag = TRUE;
        strcpy( me->SSid_exp.Shdesc, "" );
        me->SSid_exp.Local  = TRUE;
        me->SSid_exp.data_type = VD_DRWEXP_EN_ASCII;

        sprintf( szmsg, VD_CREXP_EMSG_NSYM, szFld );
        strcat( szmsg, VD_SSC_EMSG_CRE );
      }
      else
      {
        status =
        om$send( msg      = message VDCmdSSC.VDSSC_load(&retmsg, &lGRID),
                 targetid = my_id );

        if( retmsg != MSSUCC )
        {
          UI_status( VD_SSC_EMSG_MEM );
          _put_response( resp = TERMINATE );
          goto quit;
        }

        me->outmode = me->SSid_exp.data_type;

        if( me->My_Type == VD_CMD_EXP_REV ) break;
      }

      VD_EXP_SetIndx( me->SSid_exp.Userid,
                      me->SSid_exp.Timest,
                      &me->SSid_exp.Local,
                      &me->SSid_exp.LcUnit );

      me->My_stored_lo.objid = lGRID.objid;
      me->My_stored_lo.osnum = lGRID.osnum;

      break;

    case VD_CREXP_FLD_DESCR:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_get_text( form_ptr, gadget_label, szFld );
      if (szFld[0] == '\0') break;

      strcpy( me->SSid_exp.Shdesc, szFld );

      break;

    case VD_CREXP_FLD_COPY:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      /*
      **    Check if an expression name has already keyed in
      */
      if( me->CUR_expnam[0] == '\0' )
      {
	strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_get_text( form_ptr, gadget_label, szFld );
      if( szFld[0] == '\0' ) break;

      if( VD_TBL_idquote(szFld) )
      {
        strcpy( szmsg, VD_SSC_EMSG_QTE );
        UI_status( szmsg );
        break;
      }

      vd$tblexp_old( msg     = &retmsg,
                     osnum   = me->My_OS,
                     tabnam  = szFld,
                     GRid    = &lGRID );

      if( lGRID.objid == NULL_OBJID )
      {
        sprintf( szmsg, VD_CREXP_EMSG_NSYM, szFld );
        UI_status( szmsg );
        break;
      }

      strcpy( me->CUR_cpynam, szFld );

      if( me->cpymode == VD_DRWEXP_EN_OVERWRITE )
      {

        status =
        om$send( msg      = message VDCmdSSC.VDSSC_load(&retmsg, &lGRID),
                 targetid = my_id );
        if( retmsg != MSSUCC )
        {
          UI_status( VD_SSC_EMSG_MEM );
          _put_response( resp = TERMINATE );
          goto quit;
        }

	strcpy( me->SSid_exp.Tabtyp, me->CUR_exptyp );
	strcpy( me->SSid_exp.Tabnam, me->CUR_expnam );
        for( i = 0 ; i < me->nExprData ; ++i )
        {
          strcpy( me->Lexpdata[i].Datnam, me->CUR_expnam );
        }

	VD_DLO_SetIndx( me->SSid_exp.Userid,
                        me->SSid_exp.Timest,
                        &me->SSid_exp.Local,
                        &me->SSid_exp.LcUnit );

        me->outmode = me->SSid_exp.data_type;

        sprintf( szmsg, VD_CREXP_EMSG_NCPY, szFld, me->CUR_expnam );
      }
      else
      {
        status =
        om$send( msg      = message VDCmdSSC.VDSSC_append(&retmsg, &lGRID),
                 targetid = my_id );
        if( retmsg != MSSUCC )
        {
          UI_status( VD_SSC_EMSG_MEM );
          _put_response( resp = TERMINATE );
          break;
        }

        sprintf( szmsg, VD_CREXP_EMSG_NAPP, szFld, me->CUR_expnam );
      }

      break;

    case VD_CREXP_FLD_CAT:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIfld_get_active_row( form_ptr, VD_CREXP_FLD_CAT, &row, &pos );
      FIfld_get_text( form_ptr,
		      VD_CREXP_FLD_CAT,
		      row,
		      0,
                      VD_DRWEXP_CHR_NAME,
                      (unsigned char *)buffer,
                      &sel,
		      &pos );

      status = 
      om$send( msg      = message VDCmdSSC.VDSSC_getfunc(&retmsg, buffer),
               targetid = my_id );

      break;

    case VD_CREXP_FLD_FUNC:

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIfld_get_active_row( form_ptr, VD_CREXP_FLD_FUNC, &row, &pos );
      FIfld_get_text( form_ptr,
                      VD_CREXP_FLD_FUNC,
                      row,
                      0,
                      VD_DRWEXP_CHR_NAME,
                      (unsigned char *)buffer,
                      &sel,
                      &pos );

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_findsym(&retmsg,
							 buffer ,
							 funcsym),
               targetid = my_id );

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_txtapp(&retmsg,
							szmsg,
							funcsym),
               targetid = my_id );

      me->insert_pos = -1;

      if( !strcmp(buffer, "database_query") ||
          !strcmp(buffer, "dynamic_query" ) )
      {
	if( VDSverify_login() != PDM_S_SUCCESS )
	{
	  ex$message(msgnumb = VD_E_PrUsNotLog );
          strcpy( szmsg, VD_CREXP_EMSG_NLDB );
          UI_status( szmsg );
          break;
	}

        FIg_display( form_ptr, VD_CREXP_BTN_TABNAM );
        FIg_display( form_ptr, VD_CREXP_FLD_TABSEL );
        FIg_display( form_ptr, VD_CREXP_FLD_TABNAM );

	FIg_set_text( form_ptr, VD_CREXP_FLD_TABSEL, "*" );
	FIg_set_text( form_ptr, VD_CREXP_FLD_COLSEL, "*" );
      }

      break;

    case VD_CREXP_BTN_TABNAM:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_set_text( form_ptr, VD_CREXP_FLD_TABNAM, "" );

      FIg_get_text( form_ptr, VD_CREXP_FLD_TABSEL, szFld ); 

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_tabnam(&retmsg,
                                                        form_ptr,
							szmsg,
							szFld),
               targetid = my_id );

      break;

    case VD_CREXP_BTN_TABCOL:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_set_text( form_ptr, VD_CREXP_FLD_TABCOL, "" );

      FIg_get_text( form_ptr, VD_CREXP_FLD_COLSEL, szFld  );
      FIg_get_text( form_ptr, VD_CREXP_FLD_TABNAM, Tabnam );

      if( Tabnam == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_STAB );
        UI_status( szmsg );
        break;
      }

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_tabpart(&retmsg,
                                                         form_ptr,
                                                         szFld,
							 Tabnam),
               targetid = my_id );

      break;

    case VD_CREXP_BTN_RESET:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      me->nExprData = 0;         // tr179802265

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_svla(&retmsg, ""),
               targetid = my_id );

      break;

    case VD_CREXP_FLD_PROG:

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIfld_get_active_char( form_ptr,
                             gadget_label,
                             0,
                             &active_char0,
                             &active_char1 );

      FIfld_get_active_row( form_ptr,
                            gadget_label,
                            &active_row0,
                            &active_row1 );

      FIfld_get_num_rows ( form_ptr, gadget_label, &num_rows );

      txtprog = _MALLOC( num_rows*(VD_DRWLO_CHR_BUFFER + 1), IGRchar );
      txtprog[0] = '\0';

      for( i = 0 ; i < num_rows ; ++i )
      {
	txtrow[0] = '\0';
 	txtLen = 0;
        FIfld_get_text( form_ptr,
		        gadget_label,
			i,
			0,
			VD_DRWLO_CHR_BUFFER,
			txtrow,
			&sel,
			&pos );

	txtLen = strlen( (IGRchar *)txtrow );
	if( txtrow[txtLen-1] == '\n' ) txtrow[txtLen-1] = ' '; //'\0'; TR4453

        if( i < active_row0 && active_row0 < num_rows )
        {
          length += strlen( (IGRchar *)txtrow );
        }

        strcat( txtprog, (IGRchar *)txtrow );
	strcat( txtprog, " ");   // cat a space for TR4453
	length++;
      }

      me->insert_pos = length + active_char0;

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_svla(&retmsg, txtprog),
               targetid = my_id );

      break;

    case VD_CREXP_TGG_CPYTYP:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      me->cpymode = (!me->cpymode); // 1 - me->cpymode;

      break;

    case VD_CREXP_TGG_OUTTYP:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      /* TR4730, by ylong. 
       * me->outmode = 1 - me->outmode replaced by me->outmode = (!me->outmode)
       */
      me->outmode = (!me->outmode); 
      me->SSid_exp.data_type = me->outmode;

      break;

    case VD_CREXP_TGG_INSTYP:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      me->insmode = (!me->insmode); // 1 - me->insmode;

      break;

    case VD_CREXP_BTN_OBJECT:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;
   
      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_display( form_ptr, VD_CREXP_FLD_PARA );

      FIg_set_text( form_ptr, VD_CREXP_FLD_PARA, "");

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_objattr(&retmsg,
							 szmsg,
                                                         form_ptr),
               targetid = my_id );

      break;

    case VD_CREXP_FLD_PARA:

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_get_text( form_ptr, gadget_label, szFld );
      if( szFld[0] == '\0' ) break;

      for( i = 0 ; i < me->nObjParams ; i++ )
      {
        idsp = i * VD_DRWEXP_PARA_NAME;
        if( !strcmp(&me->pObjParams[idsp], szFld) ) break;
      }
  
      if( i == me->nObjParams )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NPAR );
        UI_status( szmsg );
        break;
      }

      strcpy( buffer, "%" );
      strcat( buffer, szFld );

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_txtapp(&retmsg,
							szmsg,
                                                        buffer),
               targetid = my_id );

      me->insert_pos = -1;

      if( retmsg != MSSUCC )
      {
        _put_response( resp = TERMINATE );
        break;
      }

      break;

    case VD_CREXP_FLD_TABNAM:

      me->insert_pos = -1;
      
      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_get_text( form_ptr, gadget_label, Tabnam );
      if( Tabnam[0] == '\0' ) break;      

      if( VdsVerifyRisTable(Tabnam) != VDS_DBTABLE_FOUND )
      {
        UI_status( VD_CREXP_EMSG_NTAB );
        strcpy( szmsg, VD_CREXP_EMSG_NTAB );
        break;
      }

      FIg_display( form_ptr, VD_CREXP_BTN_TABCOL );
      FIg_display( form_ptr, VD_CREXP_FLD_COLSEL );
      FIg_display( form_ptr, VD_CREXP_FLD_TABCOL );

      break;

    case VD_CREXP_FLD_TABCOL:

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_get_text( form_ptr, gadget_label, Tabcol );

      for( i = 0 ; i < me->colnum ; i++ )
      {
        if( !strcmp(me->colname[i], Tabcol) ) break;
      }
 
      if( i == me->colnum )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NCOL );
        UI_status( szmsg );
        break;
      }

      strcpy( szFld, Tabcol );
      sprintf( Tabcol, "\"%s\"", szFld );

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_txtapp(&retmsg,
 							szmsg,
                                                        Tabcol),
               targetid = my_id );

      me->insert_pos = -1;

      break;

    case VD_CREXP_BTN_WRITE:

      me->insert_pos = -1;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_display( form_ptr, VD_CREXP_FLD_FILNAM );

      break;

    case VD_CREXP_FLD_FILNAM:

      me->insert_pos = -1;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      FIg_get_text( form_ptr, gadget_label, szFld );
      if( szFld[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_KFIL );
        UI_status( szmsg );
        break;
      }

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_write(&retmsg,
                                                       szFld),
               targetid = my_id );

      break;

    case VD_CREXP_BTN_TEST:

      me->insert_pos = -1;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_test(&retmsg,
                                                      form_ptr,
						      gadget_label,
						      output),
               targetid = my_id );

      strcpy( szmsg, output );

      break;

    case VD_CREXP_BTN_PARSE:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      status =
      om$send( msg      = message VDCmdSSC.VDSSC_test(&retmsg,
                                                      form_ptr,
						      gadget_label,
                                                      output),
               targetid = my_id );

      strcpy( szmsg, output );

      break;

    case FI_ACCEPT:

      me->insert_pos = -1;

      if (me->My_Type == VD_CMD_SRT_REV) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        UI_status( VD_CREXP_EMSG_NKIN );
        me->My_localret = gadget_label;
        _put_response( resp = EX_FORM_FINISHED );
        break;
      }

      status =
      om$send( msg      = message VDCmdSSC.VDSSCexp_Save(&retmsg),
               targetid = my_id);

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );

      break;

    case FI_EXECUTE:

      me->insert_pos = -1;

      if( me->My_Type == VD_CMD_EXP_REV ) break;

      if( me->CUR_expnam[0] == '\0' )
      {
        strcpy( szmsg, VD_CREXP_EMSG_NKIN );
        UI_status( szmsg );
        break;
      }

      status = 
      om$send( msg      = message VDCmdSSC.VDSSCexp_Save(&retmsg),
               targetid = my_id);

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );

      break;

    case FI_CANCEL:

      me->insert_pos = -1;

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );

      break;

    case FI_RESET:

      me->insert_pos = -1;
      status =
      om$send( msg      = message VDCmdSSC.VDSSCexp_Reset(&retmsg, form_ptr),
               targetid = my_id );

      me->My_localret = gadget_label;
      _put_response( resp = EX_FORM_FINISHED );

      break;

  }

  FIg_set_text( form_ptr, VD_CREXP_FLD_MSG, szmsg );

  status =
  om$send( msg      = message VDCmdSSC.VDSSC_disp(form_ptr),
           targetid = my_id);

  quit:
  _FREE( txtprog );
  End
  return (status);
}
end implementation VDCmdSSC;

