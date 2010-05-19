
/* $Id: VDSSC_expr.I,v 1.2 2001/01/30 21:13:58 ad Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vdtbl/cmd/VDSSC_expr.I
 *
 * Description:
 *
 * This file contains all new methods created for EDIT EXPRESSION 
 * command.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDSSC_expr.I,v $
 *      Revision 1.2  2001/01/30 21:13:58  ad
 *      *** empty log message ***
 *
 *      Revision 1.1.1.1  2001/01/04 21:09:26  cvs
 *      Initial import to CVS
 *
# Revision 1.3  1999/04/16  14:53:52  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.2  1998/11/03  15:01:52  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.14  1998/04/16  18:07:16  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.13  1998/03/31  02:45:16  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.12  1998/03/05  19:55:30  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.11  1998/02/27  14:21:44  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.10  1998/02/25  14:43:58  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.9  1998/01/23  16:30:02  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.8  1998/01/09  21:28:08  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.7  1998/01/02  18:59:06  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.6  1997/12/31  19:30:24  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.5  1997/12/11  15:15:14  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.4  1997/12/09  21:29:00  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.3  1997/12/09  16:43:30  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.2  1997/11/18  14:42:50  pinnacle
# Replaced: vdtbl/cmd/VDSSC_expr.I for:  by mdong for vds
#
# Revision 1.1  1997/11/11  02:44:56  pinnacle
# Created: vdtbl/cmd/VDSSC_expr.I by mdong for vds
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *
 *      09/25/97       Ming Dong        Creation
 *	01/30/01	ylong		TR4453
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

#include "asbox.h"
#include "AS_status.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "nddef.h"
#include "acrepdef.h"
#include "codef.h"

#include "VDdrwlo_pr.h"
#include "VDcompmacros.h"

#include "VDmem.h"
#include "vdtblmacros.h"
#include "v_dbgmacros.h"
#include "vddrwattr.h"
#include "v_slc.h"
#include "DMmsg.h"
#include "VDmsg.h"
#include "dpmacros.h"
#include "VDattrexp.h"
#include "vdparmacros.h"
#include "vdbmacros.h"
#include "PDUerror.h"
#include "VDDbDef.h"
#include "lcmacros.h"
#include "dimlocate.h"
#include "ACrg_collect.h"


extern IGRint 		VD_drwVerbValType();
extern IGRint 		VdsVerifyRisTable();
extern IGRint 		VdsRisFreeBuffer();
extern long 		VDmalloc_str_list();

extern GRclassid        OPP_ACcpx_class_id,
		 	OPP_VDdrw2d_class_id,
			OPP_GRsmhdr_class_id,
			OPP_GRclhdr_class_id,
                        OPP_VDrelat_hdr_class_id;

from GRvg	  	import GRgetattr;
from VDcrexp	  	import VDcrexp_gdata;
from VDcrexp	  	import VDcrexp_gtab;
from VDcrexp	  	import VDcrexp_init;
from ACcpx	  	import find_macro;
from NDmacro 		import ACreturn_foot;


/* ---------------------------------------------------------------------------
  Functions: ExpCmp

  Abstract
     those functions are used to compare expression types and names.

     ExpCmp : types comparison on ascending

  Arguments
     struct VDdrwexp_temp       *elm1          I/O     element list
     struct VDdrwexp_temp       *elm2          I/O     element list
----------------------------------------------------------------------------*/
int ExpCmp( struct VDdrwexp_temp *elm1,
            struct VDdrwexp_temp *elm2 )
{
   if( !strcmp(elm1->Datstr, elm2->Datstr) )
     return( -1 );
   else
     return( strcmp(elm1->Datstr, elm2->Datstr) );
}
/* ---------------------------------------------------------------------------*/
void Exp_qsort( IGRint nStr, IGRint Str_size, IGRchar* ExprStr )
{
  IGRint i , idsp;
  struct VDdrwexp_temp *pexpstr;

  
  if( ExprStr == NULL || Str_size == 0 || nStr == 0 )  goto wrapup;

  pexpstr = _MALLOC( nStr, struct VDdrwexp_temp );

  for( i = 0 ; i < nStr ; ++i )
  {
    idsp = i * Str_size;
    strcpy( pexpstr[i].Datstr, &ExprStr[idsp] );
  }

  qsort( pexpstr,
         nStr,
         sizeof(struct VDdrwexp_temp),
         (int (*)())ExpCmp );

  for( i = 0 ; i < nStr ; ++i )
  {
    idsp = i * Str_size;
    strcpy( &ExprStr[idsp], pexpstr[i].Datstr );
  }

  _FREE( pexpstr );

  wrapup:
  return;
}
/* ---------------------------------------------------------------------------*/
method VDSSC_StExp( long     *msg )
/*
**      Form initialization for expression type and catogory fields
*/
{
  IGRint      status;
  int         Selflag;
  int         i, idsp, j, k, idsp_cur, idsp_pre;
  char        *form_ptr;
  IGRchar     temp[VD_DRWEXP_CHR_NAME];


  SetProc( VDCmdSSC.VDSSC_StExp ); Begin

  Selflag          = FALSE;
  *msg             = MSSUCC;
  me->nExprTyps    = 0;
  me->My_actv_form = VD_SSC_EXPRFORM;
  form_ptr         = me->forms[me->My_actv_form].form_ptr;
  temp[0]	   = '\0';

  status =
  om$send( msg      = message VDCmdSSC.set_form_pos(msg, form_ptr),
           targetid = my_id );
  FIf_display( form_ptr );

  if( me->My_Type == VD_CMD_EXP_REV )
  {
  /*
  **    review function, adapt form
  */
    FIg_erase(   form_ptr, VD_CREXP_TXT_EDTITLE  );
    FIg_display( form_ptr, VD_CREXP_TXT_REVTITLE );

    FIg_erase(   form_ptr, VD_CREXP_TXT_COPY     );
    FIg_erase(   form_ptr, VD_CREXP_FLD_COPY     );
    FIg_erase(   form_ptr, VD_CREXP_TGG_CPYTYP   );

    FIg_erase(   form_ptr, VD_CREXP_TXT_FUNC     );
    FIg_erase(   form_ptr, VD_CREXP_FLD_CAT      );
    FIg_erase(   form_ptr, VD_CREXP_FLD_FUNC     );

    FIg_erase(   form_ptr, VD_CREXP_BTN_RESET    );
    FIg_erase(   form_ptr, VD_CREXP_BTN_OBJECT   );
    FIg_erase(   form_ptr, VD_CREXP_BTN_PARSE    );

    FIg_erase(   form_ptr, VD_CREXP_TGG_INSTYP   );

    FIg_disable( form_ptr, FI_ACCEPT             );
    FIg_disable( form_ptr, FI_EXECUTE            );

    FIfld_set_mode( form_ptr, VD_CREXP_FLD_DESCR, 0, FI_REVIEW );
    FIfld_set_mode( form_ptr, VD_CREXP_FLD_PROG , 0, FI_REVIEW );
  }
  else
  {
  /*
  **    limit scrollability of input fields
  */
    FIfld_set_max_num_chars( form_ptr,
                             VD_CREXP_FLD_DESCR,
                             0,
                             VD_CREXP_CHR_DESC );
/* Commented out for TR4453
    FIfld_set_max_num_rows ( form_ptr,
                             VD_CREXP_FLD_PROG,
                             50 );
    FIfld_set_max_num_chars( form_ptr,
                             VD_CREXP_FLD_PROG,
                             0,
                             VD_DRWEXP_PROG_RWFLD );
*/
  }

  status =
  om$send( msg      = message VDCmdSSC.VDSSCexp_Reset(msg, form_ptr),
           targetid = my_id );

  status = om$send( msg      = message VDCmdSSC.VDSSC_sfunc(msg),
                    targetid = my_id );

/*
**      Form initialization for expression type
*/
  vd$tblexp_idt( msg     = msg,
                 osnum   = me->My_OS,
                 p_count = &me->nExprTyps );

  if( me->nExprTyps != 0 )
  {
    me->pExprTyps = _MALLOC( (me->nExprTyps + 1) * VD_CREXP_CHR_TYPE, IGRchar );
    if( me->pExprTyps == NULL )
    {
      UI_status( VD_SSC_EMSG_MEM );
      _put_response( resp = TERMINATE );
      goto quit;
    }

    vd$tblexp_idt( msg     = msg,
                   osnum   = me->My_OS,
                   p_count = &me->nExprTyps,
                   p_typs  = me->pExprTyps );

    for( i = 0 ; i < me->nExprTyps ; i++ )
    {
      idsp = i * VD_CREXP_CHR_TYPE;

      if( me->pExprTyps[idsp] == '\0' )
      {
        if( i+1 < me->nExprTyps )
        {
          for( j = i+1 ; j < me->nExprTyps ; j++ )
	  {
            idsp_cur = j * VD_CREXP_CHR_TYPE;
            idsp_pre = (j-1) * VD_CREXP_CHR_TYPE;
 	    strcpy( &me->pExprTyps[idsp_pre], &me->pExprTyps[idsp_cur] );
	  }
        }
        --me->nExprTyps;
	--i;
 	continue;
      }

      for( j = 0 ; me->pExprTyps[idsp+j] != '\0' ; ++j )
      {
        if( me->pExprTyps[idsp+j] != ' '
          && me->pExprTyps[idsp+j] != '\t' ) break;
      }

      if( me->pExprTyps[idsp+j] == '\0' )
      {
        if( i+1 < me->nExprTyps )
        {
          for( k = i+1 ; k < me->nExprTyps ; k++ )
          {
            idsp_cur = k * VD_CREXP_CHR_TYPE;
            idsp_pre = (k-1) * VD_CREXP_CHR_TYPE;
            strcpy( &me->pExprTyps[idsp_pre], &me->pExprTyps[idsp_cur] );
          }
        }
        --me->nExprTyps;
  	--i;
        continue;
      }
    }


    __DBGpr_int( "Object space No.", me->My_OS );
    __DBGpr_int( "Number of expression types", me->nExprTyps );
#ifdef vdsDEBUG
    for( i = 0 ; i < me->nExprTyps ; i++ )
    {
      idsp = i * VD_CREXP_CHR_TYPE;
      __DBGpr_str( "Expression type", &me->pExprTyps[idsp] );
    }
#endif

    Exp_qsort( me->nExprTyps, VD_CREXP_CHR_TYPE, me->pExprTyps );

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

/*
**      Form initialization for expression catalog
*/

  FIfld_set_num_rows( form_ptr,
                      VD_CREXP_FLD_CAT,
                      (int)me->nExprCats );

  for( i=0 ; i < me->nExprCats ; i++ )
  {
    idsp = i * VD_DRWEXP_CHR_NAME;
    strcpy( temp, &me->pExprCats[idsp]);
    FIfld_set_text( form_ptr,
                    VD_CREXP_FLD_CAT,
                    i,
                    0,
		    temp,
                    Selflag );
  }

  quit:
  End
  return OM_S_SUCCESS;
}

method VDSSC_ExpNam( IGRlong    *msg;
                     char       *form_ptr;
                     IGRchar    *exptyp )
/*
** This method is to retrieve all the expression names from the input
** expression type (*exptyp)
*/
{

  IGRint        status;
  int           Selflag;
  int           i, idsp;


  SetProc( VDCmdSSC.VDSSC_ExpNam ); Begin

  _FREE( me->pExprNams );

  Selflag       = FALSE;
  *msg          = MSSUCC;
  me->pExprNams = NULL;
  me->nExprNams = 0;

/*
**      Search for all expression names for a special type
*/
  vd$tblexp_idnd( msg     = msg,
                  osnum   = me->My_OS,
                  p_type  = exptyp,
                  p_count = &me->nExprNams );

  __DBGpr_int( "Number of expression names", me->nExprNams );

  if( me->nExprNams == 0 )
  {
    *msg = MSFAIL;
    goto quit;
  }

  me->pExprNams = _MALLOC( (me->nExprNams + 1) * VD_CREXP_CHR_NAME, IGRchar );
  if( me->pExprNams == NULL )
  {
    UI_status( VD_SSC_EMSG_MEM );
    _put_response( resp = TERMINATE );
    goto quit;
  }

  vd$tblexp_idnd( msg     = msg,
                  osnum   = me->My_OS,
                  p_type  = exptyp,
                  p_count = &me->nExprNams,
                  p_nams  = me->pExprNams );

  __DBGpr_str( "Expression name", me->pExprNams );

  Exp_qsort( me->nExprNams, VD_CREXP_CHR_NAME, me->pExprNams );

  FIfld_set_list_num_rows( form_ptr,
                           VD_CREXP_FLD_EXPNAM,
                           0,
                           (int)me->nExprNams );

  if( me->nExprNams > 10 )
  {
    FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_EXPNAM, 1, 0 );
  }
  else
  {
    FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_EXPNAM, 0, 0 );
  }

  for( i=0 ; i < me->nExprNams ; i++ )
  {
    idsp = i * VD_CREXP_CHR_NAME;
    VDfld_set_list_text( form_ptr,
                         VD_CREXP_FLD_EXPNAM,
                         i,
                         0,
                         &me->pExprNams[idsp],
                         Selflag );
  }

/*
**      Display the expression names in expression copy field
*/
  FIfld_set_list_num_rows( form_ptr,
                           VD_CREXP_FLD_COPY,
                           0,
                           (int)me->nExprNams );

  if( me->nExprNams > 10 )
  {
    FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_COPY  , 1, 0 );
  }
  else
  {
    FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_COPY  , 0, 0 );
  }

  for( i=0 ; i < me->nExprNams ; i++ )
  {
    idsp = i * VD_CREXP_CHR_NAME;
    VDfld_set_list_text( form_ptr,
                         VD_CREXP_FLD_COPY,
                         i,
                         0,
                         &me->pExprNams[idsp],
                         Selflag );
  }

  quit:
  End
  return OM_S_SUCCESS;
}

method VDSSC_sfunc( IGRlong     *msg )
/*
**      This method is to retrieve all expression categories and
**      functions from file /vds/config/drawing/expr_func and
**      store them in variable pExprCats and variable array Lexpfunc.
*/
{

  FILE          *file_ptr = NULL;
  IGRint        status, i, j;
  IGRchar       total_path[DI_PATH_MAX], path[DI_PATH_MAX];
  IGRchar       line[100], word[30], funcnam[30], cc;
  IGRshort      num_cat, num_func;
  IGRchar	*temp_ptr;


  SetProc( VDCmdSSC.VDSSC_sfunc ); Begin  

  *msg     = MSSUCC;
  status   = TRUE;
  num_cat  = 0;
  num_func = 0;
  temp_ptr = NULL;
  strcpy( total_path, "expr_func" );

  /*
  **    Open the file /vds/config/drawing/expr_func
  */

  file_ptr = fopen( total_path, "r" );

  if( file_ptr == NULL )
  {
    for( i = 0 ; status == TRUE ; i++ )
    {
      if( status = ex$get_path(index = i,
                               path  = path,
                               len   = DI_PATH_MAX) )
      {
        sprintf( total_path, "%sconfig/drawing/expr_func", path );
        file_ptr = fopen( total_path, "r" );
        if( file_ptr ) break;
      }
    }
  }
  
  if( !file_ptr )
  {
    *msg = MSFAIL;
    goto quit;
  }

  /*
  **    Count the numbers of expression categories and functions
  */

  while( fgets(line, 84, file_ptr) != NULL )
  {
    i = 0;
    for( ;; )
    {
      cc = line[i];
      if( cc != ' ' && cc != '\t' ) break;
      ++i;
    }

    if( cc == '%' ) ++num_cat;
    if( cc == '#' ) ++num_func;

  }

  rewind( file_ptr );

  /*
  **    Retrieve and store expression categories in variable pExprCats.
  **    Retrieve and store expression categories, functions and symbols
  **    in variable array Lexpfunc.
  */

  me->nExprCats = num_cat;
  me->nExprfunc = num_func;
  num_cat = num_func = 0;

  me->pExprCats = _MALLOC( (me->nExprCats + 1) * VD_DRWEXP_CHR_NAME, IGRchar );

  status =
  om$vla_set_dimension( varray = me->Lexpfunc,
                        size   = me->nExprfunc );

  while( fgets(line, 84, file_ptr) != NULL )
  {
    i = 0;
    for( ;; )
    {
      cc = line[i];
      if( cc != ' ' && cc != '\t' ) break;
      ++i;
    }
    ++i;

    j = 0;
    if( cc == '%' )
    {
      while( line[i] != '\n' && line[i] != '\0' )
      {
        if( line[i] != ' ' && line[i] != '\t' )
        {
          word[j] = line[i];
          ++j;
        }
        ++i;
      }
      word[j] = '\0';

      temp_ptr = &me->pExprCats[num_cat*VD_DRWEXP_CHR_NAME];
      strcpy( temp_ptr, word );
      ++num_cat;
    }

    if( cc == '#' )
    {
      while( line[i] == ' ' || line[i] == '\t' )
      {
        ++i;
      }

      j = 0;
      while( line[i] != ' '  && 
    	     line[i] != '\t' &&
             line[i] != '\n' &&
  	     line[i] != '\0' )
      {
        funcnam[j] = line[i];
        ++j;
        ++i;
      }
      funcnam[j] = '\0';

      strcpy( me->Lexpfunc[num_func].expfnam, funcnam );
      strcpy( me->Lexpfunc[num_func].expcat, word );

      for( ;; )
      {
        cc = line[i];
        if( cc != ' ' && cc != '\t' ) break;
        ++i;
      }

      j = 0;
      while( line[i] != '\n' && line[i] != '\0' )
      {
        funcnam[j] = line[i];
        ++j;
        ++i;
      }
      funcnam[j] = '\0';

      strcpy( me->Lexpfunc[num_func].expfsym, funcnam );
      ++num_func;
    }

  }


  quit:
  fclose( file_ptr );

  End
  return (OM_S_SUCCESS);
}

method   VDSSC_append( IGRlong    	*msg;
                       struct GRid      *lGrid )
{
  IGRint               status;
  IGRint	       i, j;
  IGRint               nData;
  struct VDdrwexp_data *expdata;
  IGRchar	       *expinfo;


  SetProc( VDCmdSSC.VDSSC_append ); Begin

  *msg        = MSSUCC;
  expdata     = NULL;
  expinfo     = NULL;
  nData       = 0;

  status =
  om$send( msg = message VDcrexp.VDcrexp_gdata(msg,
					       &nData,
					       &expdata),
           targetid = lGrid->objid,
           targetos = lGrid->osnum);
  __DBGpr_int( "in load, found %d data records\n",nData );

  expinfo = _MALLOC( (nData+me->nExprData)*VD_CREXP_CHR_INFO + 1, IGRchar );
  expinfo[0] = '\0';

  for( i = 0 ; i < me->nExprData ; i++ )
  {
    strcat( expinfo, me->Lexpdata[i].Datinfo );
  }
  for( i = 0 ; i < nData ; i++ )
  {
    for( j = 0 ; j < nData ; j++ )
    {
      if( expdata[j].Datsegn == i )
      {
        strcat( expinfo, expdata[j].Datinfo );
        break;
      }
    }
  }

  status =
  om$send( msg      = message VDCmdSSC.VDSSC_svla(msg, expinfo),
           targetid = my_id );

  _FREE( expdata );
  _FREE( expinfo );

  End
  return( OM_S_SUCCESS );
}

method   VDSSC_svla( IGRlong *msg;
		     char    *expinfo )
/*
**	This method is to store expression infomation into variable 
**	array of command object class
*/
{
  IGRlong	length, nData;
  IGRint	i, rowlen, status;
  IGRint        j = 0, num_schar = 0, cp_len;
  IGRint        end_string = 0;


  SetProc( VDCmdSSC.VDSSC_svla ); Begin

  *msg        = MSSUCC;
  rowlen      = VD_CREXP_CHR_INFO - 1;
  length      = strlen( expinfo );

  status = 
  om$vla_set_dimension( varray = me->Lexpdata, size = 0 );

  if( length == 0 ) goto wrapup;
  nData       = 1;

  while(1)
  {
    for( i = j ; expinfo[i] != '\0'; ++i )
    {
      if( expinfo[i] == '\'' )
      {
        ++num_schar;
      }
      if( ((i-j+1) + num_schar) > rowlen )
      {
        cp_len = i - j - 1;
        status =
        om$vla_set_dimension( varray = me->Lexpdata, size = nData );
        strcpy( me->Lexpdata[nData-1].Datnam , me->CUR_expnam );
        strcpy( me->Lexpdata[nData-1].Datgrp , "expr" );
        strncpy( me->Lexpdata[nData-1].Datinfo, &expinfo[j], cp_len );
        me->Lexpdata[nData-1].Datinfo[cp_len] = '\0';
        me->Lexpdata[nData-1].Datsegn = nData-1;
        ++nData;
        j = i - 1;
        break;
      }
  
      if( expinfo[i+1] == '\0' )
      {
        cp_len = i - j + 1;
        status =
        om$vla_set_dimension( varray = me->Lexpdata, size = nData );
        strcpy( me->Lexpdata[nData-1].Datnam , me->CUR_expnam );
        strcpy( me->Lexpdata[nData-1].Datgrp , "expr" );
        strncpy( me->Lexpdata[nData-1].Datinfo, &expinfo[j], cp_len );
        me->Lexpdata[nData-1].Datinfo[cp_len] = '\0';
        me->Lexpdata[nData-1].Datsegn = nData-1;
        end_string = 1;
      }
    }
    num_schar = 0;
   
    if( end_string ) break;
  }

  me->nExprData = nData;

  __DBGpr_int( "No. of data records", me->nExprData );


wrapup:
  End
  return( OM_S_SUCCESS );

}

method   VDSSC_txtapp( IGRlong    	*msg;
		       IGRchar		*szmsg;
                       IGRchar          *buffer )
/*
**	This method is to append text buffer to expression program
*/
{
  IGRint               status;
  IGRint 	       i;
  IGRshort             length;
  IGRchar	       *expinfo, *temp_ptr;
  char		       *form_ptr;


  SetProc( VDCmdSSC.VDSSC_txtapp ); Begin

  *msg        = MSSUCC;
  expinfo     = NULL;
  temp_ptr    = NULL;

  form_ptr = me->forms[me->My_actv_form].form_ptr;

  length  = strlen( buffer );
  expinfo = _MALLOC( me->nExprData*VD_CREXP_CHR_INFO + length, IGRchar );
  expinfo[0] = '\0';
  temp_ptr = _MALLOC( me->nExprData*VD_CREXP_CHR_INFO + length, IGRchar );
  temp_ptr[0] = '\0';

  for( i = 0 ; i < me->nExprData ; i++ )
  {
    strcat( temp_ptr, me->Lexpdata[i].Datinfo );
  }
  strcpy( expinfo, temp_ptr );

  length = strlen( expinfo );

  if( me->insmode == VD_DRWEXP_EN_APPEND )
  {
    strcat( expinfo, buffer );
  }
  else
  {
    if( me->insert_pos == -1 )
    {
      strcpy( szmsg, "Position cursor in the program field first." );
      goto quit;
    }
    else if( me->insert_pos >= length )
    {
      strcat( expinfo, buffer );
    }
    else
    {
      expinfo[me->insert_pos] ='\0';
      strcat( expinfo, buffer );
      strcat( expinfo, &temp_ptr[me->insert_pos] );
    }
  }

  status =
  om$send( msg      = message VDCmdSSC.VDSSC_svla(msg, expinfo),
           targetid = my_id );

  quit:
  _FREE( expinfo );
  _FREE( temp_ptr );

  return( OM_S_SUCCESS );
}

method   VDSSC_getfunc( IGRlong          *msg;
                        IGRchar          *expcat )
/*
**	This method is to retrieve all expression functions 
**	corresponding to the input expression category expcat
**	and store them in current expression function array.
*/
{
  IGRint	i, start, start_flag;
  IGRint	j, k, Selflag;
  IGRchar	*temp_ptr;
  char		*form_ptr;
  IGRint	idsp;


  SetProc( VDCmdSSC.VDSSC_getfunc ); Begin

  me->CUR_nExpFuncs = 0;
  temp_ptr          = NULL;
  *msg        	    = MSSUCC;
  start_flag 	    = 0;
  start 	    = -1;
  Selflag           = FALSE;

  form_ptr = me->forms[me->My_actv_form].form_ptr;

  _FREE( me->CUR_pExpFuncs );
  _FREE( me->CUR_pExpSymbs );

  for( i = 0 ; i < me->nExprfunc ; ++i )
  {
    if( !strcmp(me->Lexpfunc[i].expcat, expcat) )
    {
      if( !start_flag ) start = i;
      start_flag = 1;
      ++me->CUR_nExpFuncs;
    }
  }
  
  if( start == -1 )
  {
    *msg = MSFAIL;
    goto quit;
  }

  me->CUR_pExpFuncs
  = _MALLOC( (me->CUR_nExpFuncs + 1) * VD_DRWEXP_CHR_NAME, IGRchar );
  me->CUR_pExpSymbs
  = _MALLOC( (me->CUR_nExpFuncs + 1) * VD_DRWEXP_CHR_NAME, IGRchar );

  j = 0;
  for( i = start ; i < start + me->CUR_nExpFuncs ; ++i )
  {
    k = j * VD_DRWEXP_CHR_NAME;
    temp_ptr = &me->CUR_pExpFuncs[k];
    strcpy( temp_ptr, me->Lexpfunc[i].expfnam ); 
    temp_ptr = &me->CUR_pExpSymbs[k];
    strcpy( temp_ptr, me->Lexpfunc[i].expfsym ); 
    ++j;
  }

  FIg_reset( form_ptr, VD_CREXP_FLD_FUNC );
  if( me->CUR_nExpFuncs > 0 )
  {
    FIfld_set_num_rows( form_ptr,
			VD_CREXP_FLD_FUNC,
			(int)me->CUR_nExpFuncs);

    for( i = 0 ; i < me->CUR_nExpFuncs ; i++ )
    {
      idsp = i * VD_DRWEXP_CHR_NAME;
      FIfld_set_text( form_ptr,
                      VD_CREXP_FLD_FUNC,
                      i,
                      0,
                      &me->CUR_pExpFuncs[idsp],
                      Selflag );
    }
  }

  quit:
  End
  return OM_S_SUCCESS;

}

method VDSSC_findsym( IGRlong		*msg;
		      IGRchar   	*funcnam;
		      IGRchar		*funcsym)
/*
**	This method is to retrieve the expression function symbol (funcsym)
**	from function name (funcnam).
*/
{
  IGRint	i;


  SetProc( VDCmdSSC.VDSSC_findsym ); Begin

  *msg = MSSUCC;

  for( i = 0 ; i < me->nExprfunc ; ++i )
  {
    if( !strcmp(me->Lexpfunc[i].expfnam, funcnam) )
    {
      strcpy( funcsym, me->Lexpfunc[i].expfsym );
      break;
    }
  }

  if( i == me->nExprfunc ) *msg = MSFAIL;

  End
  return( OM_S_SUCCESS );
}

method VDSSC_tabnam( IGRlong    *msg;
                     char       *form_ptr;
		     IGRchar    *szmsg;
		     IGRchar    *tabsel )
/*
** This method is to retrieve the table names from database and
** display them in the command form.
*/
{

  IGRint        status;
  int           Selflag;
  int           i;
  char          **tablist;
  IGRint        tabnum;
  IGRchar       szFld[VD_CREXP_CHR_DESC];


  SetProc( VDCmdSSC.VDSSC_tabnam ); Begin

  *msg           = MSSUCC;
  Selflag	 = FALSE;

  strcpy( szFld, "Searching database for tables ...");
  FIg_set_text( form_ptr, VD_CREXP_FLD_MSG, szFld );

  status = 
  vdb$RisSelectTable( tabnam	= tabsel,
                      p_numrows = &tabnum,
		      p_buffer  = &tablist );
  as$status();
  if( !(status & OM_S_SUCCESS) )
  {
    UI_status( "Table searching failed"  );
    goto quit;
  }

  FIfld_set_list_num_rows( form_ptr,
                           VD_CREXP_FLD_TABNAM,
                           0,
                           (int)tabnum );

  if( tabnum > 10 )
  {
    FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_TABNAM, 1, 1 );
  }
  else
  {
    FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_TABNAM, 0, 1 );
  }

  for( i=0 ; i < tabnum ; i++ )
  {
    VDfld_set_list_text( form_ptr,
                         VD_CREXP_FLD_TABNAM,
                         i,
                         0,
                         (IGRchar *)tablist[i],
                         Selflag );
  }

  strcpy( szmsg, "Searching finished");

  quit:
  VdsRisFreeBuffer( tablist, tabnum );

  End
  return OM_S_SUCCESS;
}

method VDSSC_objattr( IGRlong    *msg;
		      IGRchar    *szmsg;
                      char       *form_ptr )
/*
** This method is to retrieve all the object attributes and
** display them in the command form.
*/
{
  IGRint		status = OM_S_SUCCESS;
  IGRlong		mask1, mask2, status1;
  IGRlong		display_flag, event_size;
  IGRint   		resp;
  IGRchar  		resp_data[1000];
  IGRchar		locate_prompt[MAX_PROMPT_SIZE];
  IGRchar		relocate_prompt[MAX_PROMPT_SIZE];
  struct GRlc_locate	attribute;
  OM_S_CLASSLIST        classlist;
  OMuword               class[1];
  struct GRevent        loc_event, acc_event;
  struct GRobj_env      loc_object;
  struct GRid           macro_id;
  struct GRlc_stack  	stack;


  SetProc( VDCmdSSC.VDSSC_objattr ); Begin

  *msg               = MSSUCC;
  locate_prompt[0]   = '\0';
  relocate_prompt[0] = '\0';
  me->acc_prompt[0]  = '\0';
  resp_data[0]       = '\0';
  event_size	     = sizeof( struct GRevent );
  stack.num_entries  = 0;

  /*
  **	Locate the object to get attributes of the object
  */
  mask1 = GRm_DATA | GRm_RJT_MOVEON | GRm_STRING;
  mask2 = GRm_DATA | GRm_RJT_MOVEON | GRm_STRING;
  strcpy( locate_prompt, "Identify element to retrieve parameters" );
  ex$message(msgnumb = DM_E_EltNotFound, buff = relocate_prompt);
  ex$message(msgnumb = VD_P_AccRej,      buff = me->acc_prompt);

  display_flag 		 = ELEM_HILIGHT | ALL_WINDOWS;
  attribute.owner_action = LC_FLEX_COMP | LC_REF_OBJECTS | LC_RIGID_COMP 
			   | LC_RIGID_OWNER | LC_FLEX_OWNER;
  attribute.properties   = LC_DP_ONLY | LC_LC_ONLY;
  strcpy( attribute.classes, "ACcpx" );

  classlist.w_count   = 1 ;
  classlist.w_flags   = OM_CLST_subclass;
  classlist.p_classes = class;
  class[0] 	      = OPP_ACcpx_class_id;

  __DBGpr_com( "lc$locate Begin");
  status1 =
  lc$locate( rc               =  msg,
             event1           =  &loc_event,
             event2           =  &acc_event,
             mask1            =  mask1,
             mask2            =  mask2,
   	     eventsize	      =  &event_size,
             display_flag     =  display_flag,
             hilight_mode     =  GRhd,
             unhilight_mode   =  GRhe,
             response         =  &resp,
             response_data    =  resp_data,
             locate_prompt    =  locate_prompt,
             acc_prompt       =  me->acc_prompt,
             relocate_prompt  =  relocate_prompt,
             attributes       =  &attribute,
             stack            =  &stack,
             eligible_classes =  &classlist );
  __DBGpr_com( "lc$locate End");

  UI_prompt( "" );

  loc_object.obj_id  = acc_event.located_object[0].located_obj;
  loc_object.mod_env = acc_event.located_object[0].module_info;

  __DBGpr_obj( "Located object", loc_object.obj_id );

  /*
  ** Check if located object is in a Drawing View
  ** If this is true, then replace it with the originating Model object
  */
  if( DMancestry_valid(loc_object.obj_id, OPP_VDdrw2d_class_id)
      == OM_S_SUCCESS )
  {
    VDpartAttr           attr;

    attr.Iwant  = VD_I_drwParentObj;

    status =
    om$send( msg      = message GRvg.GRgetattr(msg, (char *)&attr),
             targetid = loc_object.obj_id.objid,
             targetos = loc_object.obj_id.osnum );
    if( status & *msg & 1 )
    {
      loc_event.located_object[0].located_obj = attr.obj.obj_id;
      loc_event.located_object[0].module_info = attr.obj.mod_env;

      if( !DMancestry_valid(attr.obj.obj_id, OPP_VDrelat_hdr_class_id)
          == OM_S_SUCCESS )
      {
        if( DMancestry_valid(attr.obj.obj_id, OPP_GRclhdr_class_id)
            == OM_S_SUCCESS ||
            DMancestry_valid(attr.obj.obj_id, OPP_GRsmhdr_class_id)
	    == OM_S_SUCCESS )
        {
          status  = 0;
          *msg = MSFAIL;
          goto quit;
        }
      }

      loc_object  = attr.obj;
    }
  }

  /*
  **	Find the macro GRid of the located object
  */
  status =
  om$send( msg      = message ACcpx.find_macro(&macro_id),
           targetid = loc_object.obj_id.objid,
           targetos = loc_object.obj_id.osnum );
  as$status(action = RET_STATUS);

  __DBGpr_obj( "Macro GRid of the located object", macro_id );

  status = dp$erase_hilite( msg = msg );
  as$status(action = RET_STATUS);

  /*
  ** 	Retrieve the parameter names and fill the command form
  */
  status = 
  om$send( msg      = message VDCmdSSC.VDSSCfill_params(msg,
 						        &loc_object.obj_id,
		    				        "",
		    				        form_ptr,
							szmsg,
                    				        &loc_object.mod_env),
           targetid = my_id );
  as$status(action = RET_STATUS);

  quit:
  End
  return OM_S_SUCCESS;
}

method VDSSC_test( IGRlong    *msg;
                   char       *form_ptr;
		   int	      gadget_label;
		   IGRchar    *output )
/*
** This method is to identify an object which is used to test 
** the expressions created and display the result on message field
** of the command form.
*/
{
  IGRint		status = OM_S_SUCCESS;
  IGRlong		mask1, mask2, status1;
  IGRlong		display_flag, event_size;
  IGRint   		resp, i;
  IGRchar  		*resp_data[1000];
  IGRchar		locate_prompt[MAX_PROMPT_SIZE];
  IGRchar		relocate_prompt[MAX_PROMPT_SIZE];
  struct GRlc_locate	attribute;
  OM_S_CLASSLIST        classlist;
  OMuword               class[1];
  struct GRevent        loc_event, acc_event;
  struct GRobj_env      loc_object[1];
  struct GRlc_stack     stack;
  struct ACrg_coll      coll;
  IGRchar		*expinfo;
  VD_execRes            expVal;
  IGRchar		temp_output[80];


  SetProc( VDCmdSSC.VDSSC_test ); Begin

  *msg               = MSSUCC;
  locate_prompt[0]   = '\0';
  relocate_prompt[0] = '\0';
  me->acc_prompt[0]  = '\0';
  resp_data[0]       = '\0';
  temp_output[0]     = '\0';
  expinfo	     = NULL;
  event_size         = sizeof( struct GRevent );
  stack.num_entries  = 0;
  status1	     = 0;

  /*
  ** Get expression info.
  */
  expinfo = _MALLOC( me->nExprData*VD_CREXP_CHR_INFO + 1, IGRchar );
  expinfo[0] = '\0';

  for( i = 0 ; i < me->nExprData ; i++ )
  {
    strcat( expinfo, me->Lexpdata[i].Datinfo );
  }

  /*
  ** Test the syntax of the expression.
  */
  if( gadget_label == VD_CREXP_BTN_TEST )
  {
    status1 = VD_expParse( expinfo,
                           FALSE,
                           VD_EXP_WARNING,
                           0,
 			   NULL,
                           &expVal );

    if( !(status1&1) )
    {
      strcpy( output, "Syntax errors found!" );
    }
    else
    {
      strcpy( output, "No syntax errors found!" );
    }

    goto quit;
  }

  /*
  **	Locate the object to get attributes of the object
  */
  mask1 = GRm_DATA | GRm_RJT_MOVEON | GRm_STRING;
  mask2 = GRm_DATA | GRm_RJT_MOVEON | GRm_STRING;
  strcpy( locate_prompt, "Identify element to test" );
  ex$message(msgnumb = DM_E_EltNotFound, buff = relocate_prompt);
  ex$message(msgnumb = VD_P_AccRej,      buff = me->acc_prompt);

  display_flag 		 = ELEM_HILIGHT | ALL_WINDOWS;
  attribute.owner_action = LC_FLEX_COMP | LC_REF_OBJECTS | LC_RIGID_COMP
			   | LC_RIGID_OWNER | LC_FLEX_OWNER;
  attribute.properties   = LC_DP_ONLY | LC_LC_ONLY;
  strcpy( attribute.classes, "ACcpx" );

  classlist.w_count   = 1 ;
  classlist.w_flags   = OM_CLST_subclass;
  classlist.p_classes = class;
  class[0] 	      = OPP_ACcpx_class_id;

  __DBGpr_com( "lc$locate Begin");
  status1 =
  lc$locate( rc               =  msg,
             event1           =  &loc_event,
             event2           =  &acc_event,
             mask1            =  mask1,
             mask2            =  mask2,
             eventsize        =  &event_size,
             display_flag     =  display_flag,
             hilight_mode     =  GRhd,
             unhilight_mode   =  GRhe,
             response         =  &resp,
             response_data    =  resp_data,
             locate_prompt    =  locate_prompt,
             acc_prompt       =  me->acc_prompt,
             relocate_prompt  =  relocate_prompt,
             attributes       =  &attribute,
             stack            =  &stack,
             eligible_classes =  &classlist );
  __DBGpr_com( "lc$locate End");

  UI_prompt( "" );

  loc_object[0].obj_id  = acc_event.located_object[0].located_obj;
  loc_object[0].mod_env = acc_event.located_object[0].module_info;

  /*
  **	Evaluate the expression
  */

  status = vd$tblexp_exec ( msg      = msg,
                            osnum    = me->My_OS,
                            buffer   = expinfo ,
                            flag     = TRUE,
                            mode     = VD_EXP_VERBOSE,
                            num_objs = 1,
         	            objList  = loc_object,
                            attr     = &coll );

  if( status & *msg & 1 )
  {
    if( coll.desc.type == AC_ATTRIB_DOUBLE )
    {
      __DBGpr_dbl( "Found Value", coll.desc.value.att_exp );
      sprintf( output, "Output: %f\n", coll.desc.value.att_exp );
    }
    else if( coll.desc.type == AC_ATTRIB_TEXT )
    {
      __DBGpr_str( "Found String", coll.desc.value.att_txt );
      strncpy( temp_output, coll.desc.value.att_txt, 55 );
      temp_output[55] = '\0';
      sprintf( output, "Output: %s\n", temp_output );
    }
    else
    {
      strcpy( output, " ? " );
    }
  }
  else
  {
    strcpy( output, "Expression evaluation failed!" );
  }

  quit:
  End
  _FREE( expinfo );
  return OM_S_SUCCESS;
}

method VDSSC_tabpart( IGRlong    *msg;
                      char       *form_ptr;
		      IGRchar    *colsel;
		      IGRchar	 *Tabnam ) 
/*
** This method is to retrieve all the collum names for an input table
** and display them in the command form.
*/
{
  IGRint        status;
  int           Selflag;
  int           i, j;
  char		table_name[VD_DRWEXP_CHR_NAME];
  IGRchar       **coldata;
  IGRint        num_let, num_match;
  IGRchar	szFld[VD_DRWEXP_CHR_NAME], tmp_str[VD_DRWEXP_CHR_NAME];
  IGRchar	*tmp_ptr;


  SetProc( VDCmdSSC.VDSSC_tabpart ); Begin

  *msg           = MSSUCC;
  Selflag        = FALSE;
  table_name[0]	 = '\0';
  num_let	 = 0;

  if( VdsVerifyRisTable(Tabnam) != VDS_DBTABLE_FOUND )
  {
    UI_status( "Table is not found" );
    goto quit;
  }

  sprintf( table_name, "%s", Tabnam );

  status=
  vdb$RetrieveAttributes( table_name = table_name,
                          p_num      = &me->colnum,
                          p_attr     = &me->colname,
			  p_type     = &coldata );
  as$status();
  if( !(status & OM_S_SUCCESS) )
  {
    printf( " Error, Select column names from <%s>\n", table_name );
    goto quit;
  }

  j = 0;
  for( i = 0 ; colsel[i] != '\0' ; ++i )
  {
    if( colsel[i] == ' ' || colsel[i] == '\t' )
    {
      ++i;
      continue;
    }

   szFld[j] = colsel[i];
   ++j;
  }
  szFld[j] = '\0';

  if( szFld[0] != '*' && szFld[0] != '\0' )
  {
    for( i = 0 ; szFld[i] != '*' && szFld[i] != '\0' ; ++i )
    {
      continue;
    }
    szFld[i] = '\0';
    num_let  = i;
  }

  if( szFld[0] == '*' && szFld[1] != '\0' )
  {
    for( i = 1 ; szFld[i] != '*' && szFld[i] != '\0' ; ++i )
    {
      continue;
    }
    szFld[i] = '\0';
    strcpy( tmp_str, &szFld[1] );
  }

  if( szFld[0] == '\0' ||
      (szFld[0] == '*' && szFld[1] == '\0') )
  {
    FIfld_set_list_num_rows( form_ptr,
                             VD_CREXP_FLD_TABCOL, 
                             0,
                             (int)me->colnum );

    if( me->colnum > 10 )
    {
      FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_TABCOL, 1, 1 );
    }
    else
    {
      FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_TABCOL, 0, 1 );
    }

    for( i=0 ; i < me->colnum ; i++ )
    {
      VDfld_set_list_text( form_ptr,
                           VD_CREXP_FLD_TABCOL,
                           i,
                           0,
                           me->colname[i],
                           Selflag );
    }
  }
  else if( szFld[0] == '*' )
  {
    num_match = 0;
    for( i = 0 ; i < me->colnum ; ++i )
    {
      tmp_ptr = strstr( me->colname[i], tmp_str );
      if( tmp_ptr != NULL )
        ++num_match;
    }
   
    FIfld_set_list_num_rows( form_ptr,
                             VD_CREXP_FLD_TABCOL,
                             0,
                             (int)num_match );

    if( num_match > 10 )
    {
      FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_TABCOL, 1, 1 );
    }
    else
    {
      FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_TABCOL, 0, 1 );
    }

    j = 0;
    for( i = 0 ; i < me->colnum ; ++i )
    {
      tmp_ptr = strstr( me->colname[i], tmp_str );
      if( tmp_ptr != NULL )
      {
        VDfld_set_list_text( form_ptr,
                             VD_CREXP_FLD_TABCOL,
                             j,
                             0,
                             me->colname[i],
                             Selflag );
        ++j;
      }
    }
  }
  else
  {
    num_match = 0;
    for( i = 0 ; i < me->colnum ; ++i )
    {
      strncpy( tmp_str, me->colname[i], num_let );
      tmp_str[num_let] = '\0';
      if( ! strcmp(tmp_str, szFld) )
        ++num_match;
    }
   
    FIfld_set_list_num_rows( form_ptr,
                             VD_CREXP_FLD_TABCOL,
                             0,
                             (int)num_match );

    if( num_match > 10 )
    {
      FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_TABCOL, 1, 1 );
    }
    else
    {
      FIfld_set_list_scroll( form_ptr, VD_CREXP_FLD_TABCOL, 0, 1 );
    }

    j = 0;
    for( i = 0 ; i < me->colnum ; ++i )
    {
      strncpy( tmp_str, me->colname[i], num_let );
      tmp_str[num_let] = '\0';
      if( ! strcmp(tmp_str, szFld) )
      {
        VDfld_set_list_text( form_ptr,
                             VD_CREXP_FLD_TABCOL,
                             j,
                             0,
                             me->colname[i],
                             Selflag );
        ++j;
      }
    }
  }

  quit:
  vdb$RisFreeBuffer( buffer = coldata,
		     size   = me->colnum );

  End
  return OM_S_SUCCESS;
}

method VDSSC_write( IGRlong    *msg;
                    IGRchar    *file_nam )
/*
** This method is to write all the information about the expression
** in a file
*/
{
  FILE          *file_ptr = NULL;
  IGRchar       *exprinfo, temp_str[VD_DRWEXP_PROG_RWFLD+1];
  IGRint	length, ndata;
  IGRint	i, num_rem;
  IGRchar	*temp_ptr = NULL;


  SetProc( VDCmdSSC.VDSSC_write ); Begin

  *msg      = MSSUCC;
  exprinfo  = NULL;
  temp_str[0] = '\0';

  file_ptr = fopen( file_nam, "w" );
  if( file_ptr == NULL )
  {
    goto quit;
  }

  /*
  **	Write out expression type, name, short description
  */

  fprintf( file_ptr, "EXPRESSION INFORMATION\n\n\n" );
  fprintf( file_ptr, "TYPE: %s\n", me->CUR_exptyp );
  fprintf( file_ptr, "NAME: %s\n", me->CUR_expnam );
  fprintf( file_ptr, "DESCRIPTION: %s\n\n", me->SSid_exp.Shdesc );

  /*
  **	Write out date, userid, local
  */

  fprintf( file_ptr, "DATE:   %s\n", me->SSid_exp.Timest );
  fprintf( file_ptr, "USERID: %s\n", me->SSid_exp.Userid );
  if( me->SSid_exp.Local )
  fprintf( file_ptr, "LOCAL:  Yes\n\n" );
  else
  fprintf( file_ptr, "LOCAL:  No\n\n" );

  /*
  **	Retrieve the expression data info
  */

  exprinfo    = _MALLOC( me->nExprData*VD_CREXP_CHR_INFO + 1, IGRchar );
  exprinfo[0] = '\0';
  temp_ptr    = &exprinfo[0];

  for( i = 0 ; i < me->nExprData ; ++i )
  {
    strcat( exprinfo, me->Lexpdata[i].Datinfo );
  }

  length = strlen( exprinfo );
  ndata = length / VD_DRWEXP_PROG_RWFLD + 1;
  num_rem = length - ( ndata - 1 ) * VD_DRWEXP_PROG_RWFLD;

  /*
  **	Write out the expression data info and output format
  */

  fprintf( file_ptr, "EXPRESSION: " );
  for( i = 0 ; i < ndata ; ++i )
  {
    strncpy( temp_str, temp_ptr, VD_DRWEXP_PROG_RWFLD );

    if( i == ndata-1 )
      temp_str[num_rem] = '\0';
    else
    {
      temp_ptr += VD_DRWEXP_PROG_RWFLD;
      temp_str[VD_DRWEXP_PROG_RWFLD] = '\0';
    }

    if( i == 0 )
      fprintf( file_ptr, "%s\n", temp_str );
    else
      fprintf( file_ptr, "            %s\n", temp_str );
  }

  if( me->outmode )
  fprintf( file_ptr, "OUTPUT:  Numeric\n\n" );
  else
  fprintf( file_ptr, "OUTPUT:  ASCII\n\n" );

  quit:
  _FREE( exprinfo );
  fclose( file_ptr );

  End
  return OM_S_SUCCESS;
}

method  VDSSCexp_Reset( IGRlong		*msg;
			char		*form_ptr )
{
  IGRint	status;


  SetProc( VDCmdSSC.VDSSCexp_Reset ); Begin

  *msg = MSSUCC;

  _FREE( me->pExprTyps     );
  _FREE( me->pExprNams     );
  _FREE( me->pExprCats     );
  _FREE( me->CUR_pExpFuncs );
  _FREE( me->CUR_pExpSymbs );
  _FREE( me->pObjParams    );

  me->My_localret   = 0;

  me->nExprTyps     = 0;
  me->nExprNams     = 0;
  me->nExprCats     = 0;
  me->nExprData     = 0;
  me->CUR_nExpFuncs = 0;
  me->nObjParams    = 0;
  me->newflag       = FALSE;
  me->insert_pos    = -1;

  me->CUR_exptyp[0] = '\0';
  me->CUR_expnam[0] = '\0';
  me->CUR_cpynam[0] = '\0';

  me->SSid_exp.Tabtyp[0] = '\0';
  me->SSid_exp.Tabnam[0] = '\0';
  me->SSid_exp.Shdesc[0] = '\0';
  me->SSid_exp.Timest[0] = '\0';
  me->SSid_exp.Userid[0] = '\0';
  me->SSid_exp.Local     = FALSE;
  me->SSid_exp.data_type = VD_DRWEXP_EN_ASCII;

  me->cpymode = VD_DRWEXP_EN_APPEND;
  me->outmode = VD_DRWEXP_EN_ASCII;
  me->insmode = VD_DRWEXP_EN_APPEND;

  vdb$RisFreeBuffer( buffer = me->colname,
                     size   = me->colnum );
  me->colnum = 0;

  status =
  om$vla_set_dimension( varray = me->Lexpdata, size = 0 );
  status =
  om$vla_set_dimension( varray = me->Lexpfunc, size = 0 );

  FIg_erase( form_ptr, VD_CREXP_FLD_TABNAM );
  FIg_erase( form_ptr, VD_CREXP_FLD_TABCOL );
  FIg_erase( form_ptr, VD_CREXP_FLD_FILNAM );
  FIg_erase( form_ptr, VD_CREXP_FLD_TABSEL );
  FIg_erase( form_ptr, VD_CREXP_FLD_COLSEL );
  FIg_erase( form_ptr, VD_CREXP_BTN_TABNAM );
  FIg_erase( form_ptr, VD_CREXP_BTN_TABCOL );

  VDtbl_exp_close( msg );

  End
  return( OM_S_SUCCESS );
}

method VDSSCexp_Save( IGRlong     *msg )
{
  IGRint    	status;
  IGRlong   	retmsg;
  int		vla_size;


  SetProc( VDCmdSSC.VDSSCexp_Save ); Begin

  *msg = MSFAIL;

  if( me->CUR_expnam[0] == '\0' )
  {
    /*
    **  save of empty , do nothing
    */
    *msg = MSSUCC;
    return( OM_S_SUCCESS );
  }

  *msg = MSSUCC;

  vla_size = om$dimension_of( varray = me->Lexpdata );

  __DBGpr_obj( "ID of expression stored", me->My_stored_lo );
  __DBGpr_str( "Type of expression stored", me->SSid_exp.Tabtyp );
  __DBGpr_str( "Name of expression stored", me->SSid_exp.Tabnam );
  __DBGpr_str( "Date on storing expression", me->SSid_exp.Timest );
  __DBGpr_str( "Userid", me->SSid_exp.Userid );
  __DBGpr_str( "Short description", me->SSid_exp.Shdesc );
  __DBGpr_int( "Data type of expression stored", me->SSid_exp.data_type );
  __DBGpr_int( "Local unit", me->SSid_exp.LcUnit );
  __DBGpr_int( "Local", me->SSid_exp.Local );
  __DBGpr_int( "No. of expression data", me->nExprData );
  if( vla_size > 0 )
  {
    __DBGpr_str( "Expression name", me->Lexpdata[0].Datnam );
    __DBGpr_str( "Expression data group", me->Lexpdata[0].Datgrp );
    __DBGpr_str( "Expression data", me->Lexpdata[0].Datinfo );
  }

  status =
  om$send( msg      = message VDcrexp.VDcrexp_init(&retmsg,
						   &me->SSid_exp,
						   (IGRint)me->nExprData,
						   me->Lexpdata),
           targetid = me->My_stored_lo.objid,
           targetos = me->My_stored_lo.osnum);
  as$status();

  return( OM_S_SUCCESS );
}

method VDSSCfill_params( IGRlong	   *msg;
			 struct GRid 	   *object_id;
		         char        	   *object_name;
			 char		   *form_ptr;
		 	 IGRchar	   *szmsg;
			 struct GRmd_env   *md_env )
/*
** struct GRid     *object_id;      -> maco object          
** char            *object_name;    -> macro object         
** char            *form_ptr;       -> active form pointer  
** struct GRmd_env *md_env;         -> module environment   
*/
{
  int                     status, i, idsp, Selflag;
  int			  length;
  long                    sts;
  struct ACrg_coll        *plist;
  struct  GRid            go ;
  char			  *form_ptr;
  IGRchar                 szFld[VD_CREXP_CHR_DESC];

  SetProc( VDSSCfill_params ); Begin

  *msg     = MSSUCC;
  go 	   = *object_id ;
  plist    = NULL;
  Selflag  = FALSE;
  form_ptr = me->forms[me->My_actv_form].form_ptr;

  __DBGpr_obj( "Input object:go", go );

  status =
  om$send( msg      = message NDmacro.ACreturn_foot(&sts,
						    "",
						    &go,
						    NULL,
						    NULL),
           targetid = go.objid,
           targetos = go.osnum );
 
  __DBGpr_obj( "Foot of object", go );

  strcpy( szFld, "Searching parameters of located object ...");
  FIg_set_text( form_ptr, VD_CREXP_FLD_MSG, szFld );

  status =
  vd$get_params( sts             = &sts,
                 object          = object_id,
                 md_env          = md_env,
                 count           = &me->nObjParams,
                 plist           = &plist );
  CheckRC( status, sts );

  __DBGpr_int(" Count ", me->nObjParams );

  if( me->nObjParams )
  {

    me->pObjParams = 
    _MALLOC( (me->nObjParams + 1) * VD_DRWEXP_PARA_NAME, IGRchar );

    if( me->pObjParams == NULL )
    {
      UI_status( VD_SSC_EMSG_MEM );
      _put_response( resp = TERMINATE );
      goto quit;
    }

    FIfld_set_list_num_rows( form_ptr,
			     VD_CREXP_FLD_PARA,
			     0,
			     me->nObjParams );
  }

  if( me->nObjParams > 10 )
  {
    FIfld_set_list_scroll( form_ptr,
                           VD_CREXP_FLD_PARA,
                           1,
                           1 );
  }
  else
  {
    FIfld_set_list_scroll( form_ptr,
                           VD_CREXP_FLD_PARA,
                           0,
                           1 );
  }

  for( i = 0 ; i < me->nObjParams ; i++ )
  {
    idsp = i * VD_DRWEXP_PARA_NAME;

    if( object_name[0] != '\0' )
    {
      length = strlen( object_name ) + strlen( plist[i].name ) + 1;
      sprintf( &me->pObjParams[idsp],"%s:%s", object_name, plist[i].name );
    }
    else
    {
      length = strlen( plist[i].name );
      strcpy( &me->pObjParams[idsp], plist[i].name );
    }
    me->pObjParams[idsp+length] = '\0';

    VDfld_set_list_text( form_ptr,
                         VD_CREXP_FLD_PARA,
                         i,
                         0,
                         &me->pObjParams[idsp],
                         Selflag );
  }

  if( me->nObjParams )
  {
    FIg_set_text( form_ptr, VD_CREXP_FLD_PARA, me->pObjParams );
    FIg_set_text_style( form_ptr, VD_CREXP_FLD_PARA, FI_NORMAL_TEXT );
  }

  strcpy( szmsg, "Searching finished");

  quit:
  _FREE( plist );

  End
  return OM_S_SUCCESS;
}

int VdsRisSelectTable( IGRchar *tabnam,
   		       char    *order,
                       char    *group,
                       int     *p_nbocc,
                       char    ***p_buffer )
{
  int		status;
  IGRint	i, j;
  char          col_nam[80];
  char          where[80];
  char          select[10];
  char          table_name[15];
  IGRshort	underscore_flag;
  IGRshort	start_flag;
  char		**temp_ptr;
  int		temp_num;
  char          *tmp_ptr;


  underscore_flag = FALSE;
  start_flag      = FALSE;
  select[0]       = '\0';
  table_name[0]   = '\0';
  where[0]        = '\0';
  col_nam[0]      = '\0';
  *p_nbocc	  = 0;

  if( VdsVerifyRisTable("ris5tables") != VDS_DBTABLE_FOUND )
  {
    UI_status( "The table ris5tables is not found" );
    return 0;
  }

  j = 0;
  for( i = 0 ; tabnam[i] != '\0' ; ++i )
  {
    if( tabnam[i] == '_' )
    {
      underscore_flag = TRUE;
    }

    if( tabnam[i] == ' ' || tabnam[i] == '\t' )
    {
      ++i;
      continue;
    }

   col_nam[j] = tabnam[i];
   ++j;
  }
  col_nam[j] = '\0';

  strcpy( select, "table_name" );
  strcpy( table_name, "ris5tables" );

  if( underscore_flag )
  {
    if( col_nam[0] == '*' )
    {
      for( i = 1 ; col_nam[i] != '\0' ; ++i )
      {
        if( col_nam[i] == '*' || col_nam[i] == '\0' ) break;
      }
      col_nam[i] = '\0';

      sprintf( where, "table_name like \'%%%s%%\'", &col_nam[1] );
    }
    else
    {
      start_flag = TRUE;

      for( i = 0 ; col_nam[i] != '\0' ; ++i )
      {
        if( col_nam[i] == '*' ) break;
      }
      col_nam[i] = '\0';

      sprintf( where, "table_name like \'%s%%\'", col_nam );
    }

    status=
    vdb$RisSelect( select     = select,
                   table_name = table_name,
                   where      = where,
                   order      = order,
                   group      = group,
                   numselect  = 1,
		   p_numrows  = &temp_num,
                   p_buffer   = &temp_ptr );
    as$status();
    if( !(status & OM_S_SUCCESS) )
    {
      printf( " Error, Select from <%s> where <%s>\n", select, table_name );
      return 0;
    }

    for( i = 0 ; i < temp_num ; ++i )
    {
      if( start_flag )
      {
        tmp_ptr = strstr( temp_ptr[i], col_nam );

        if( tmp_ptr != NULL && tmp_ptr == temp_ptr[i] ) 
          *p_nbocc = *p_nbocc + 1;
      }
      else
      {
        tmp_ptr = strstr( temp_ptr[i], &col_nam[1] );

        if( tmp_ptr != NULL ) *p_nbocc = *p_nbocc + 1;
      }
    }
    VDmalloc_str_list( p_buffer, (int)*p_nbocc, 20 );

    j = 0;
    for( i = 0 ; i < temp_num ; ++i )
    {
      if( start_flag )
      {
        tmp_ptr = strstr( temp_ptr[i], col_nam );

        if( tmp_ptr != NULL && tmp_ptr == temp_ptr[i] ) 
        {
          strcpy( (p_buffer[0])[j], temp_ptr[i] );
          ++j;
        }
      }
      else
      {
        tmp_ptr = strstr( temp_ptr[i], &col_nam[1] );

        if( tmp_ptr != NULL ) 
        {
          strcpy( (p_buffer[0])[j], temp_ptr[i] );
          ++j;
        }
      }
    }

    VdsRisFreeBuffer( temp_ptr, temp_num );
  }
  else
  { 
    if( col_nam[0] == '\0' ||
        (col_nam[0] == '*' && col_nam[1] == '\0') )
    {
      status=
      vdb$RisSelect( select     = select,
                     table_name = table_name,
                     order      = order,
		     group      = group,
                     numselect  = 1,
                     p_numrows  = p_nbocc,
                     p_buffer   = p_buffer );

      as$status();
      if( !(status & OM_S_SUCCESS) )
      {
        printf( " Error, Select from <%s> where <%s>\n", select, table_name );
        return 0;
      }
    }
    else
    {
      if( col_nam[0] == '*' )
      {
        for( i = 1 ; col_nam[i] != '\0' ; ++i )
        {
          if( col_nam[i] == '*' || col_nam[i] == '\0' ) break;
        }
        col_nam[i] = '\0';

        sprintf( where, "table_name like \'%%%s%%\'", &col_nam[1] );
      }
      else
      {
        for( i = 0 ; col_nam[i] != '\0' ; ++i )
        {
          if( col_nam[i] == '*' ) break;
        }
        col_nam[i] = '\0';

        sprintf( where, "table_name like \'%s%%\'", col_nam );
      }

      status=
      vdb$RisSelect( select     = select,
                     table_name = table_name,
                     where      = where,
		     order      = order,
                     group      = group,
                     numselect  = 1,
		     p_numrows  = p_nbocc,
                     p_buffer   = p_buffer );
      as$status();
      if( !(status & OM_S_SUCCESS) )
      {
        printf( " Error, Select from <%s> where <%s>\n", select, table_name );
        return 0;
      }
    }
  }
  
  if( *p_nbocc == 0 || p_nbocc == NULL )
  {
    UI_status( "The table not found" );
  }

  return 1;
}
end implementation VDCmdSSC;
