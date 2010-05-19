/* $Id: VDCmdFtxt_Nt.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdFtxt_Nt.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdFtxt_Nt.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/05/05  21:54:38  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/11/06  06:43:18  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Nt.I for:  by ksundar for vds
#
# Revision 1.2  1997/11/05  09:11:28  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Nt.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1996/04/15  13:46:52  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Nt.I for:  by yzhu for vds.240
#
# Revision 1.2  1996/03/28  20:19:16  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Nt.I for:  by yzhu for vds.240
#
# Revision 1.1  1994/11/21  20:11:58  pinnacle
# delete by mistake
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      4/15/96         Ad              chnage  ACgive_structure to
 *                                      vd$review_params
 *	11/05/97	Sundar		Changed form_notification by adding
 *					gadgets EXP_TYP_FIELD & EXP_NAM_FIELD
 *      05/05/99	Ming		TR179900036
 * -------------------------------------------------------------------*/

/*****************************************************************************

	File:	VDCmdFtxt_Nt.I
	Date:	April 1992
	Auteur:	Ad Zuurhout

	Description:
		Form notification and other display methods.

	History:
	AdZ	05-Apr-92	Creation date.
	AdZ	05-Oct-92	Add case DELETE_FORMAT in form_notification.

****************************************************************************/

class implementation VDCmdFtxt;

#include <stdio.h>
#include <string.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "FI.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "AS_status.h"
#include "ACattrib.h"
#include "acdef.h"
#include "acmacros.h"
#include "msdef.h"
#include "msmacros.h"

#include "VDmsg.h"
#include "VDSannot.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "vdparmacros.h"
/*
#define vdserrDEBUG 1
#define vdsDEBUG 1
*/
#include "v_dbgmacros.h"

#include "VDdrwlo.h"
#include "vdtblmacros.h"
#include "VDattrexp.h"
#include "VDmem.h"

#define   AS_DEBUG	1

/*
 * used methods
 */
from	ci_macro	import	init;
from	GRvg		import	GRputname;
from	text_exp	import	create;
from	NDmacro		import  ACgive_structure;
from    expression      import  NDgive_value;
from    ACcpx           import  ACfind_temp_obj;



method Get_text (
	/****************************************************************/
	/* method to get text from a form field/col 			*/
	/****************************************************************/
	Form    form_ptr;	/* Pointer to the form			*/
	int	gadget_label;	/* The label of the gadget		*/
	int	row;		/* multi-column row			*/
	int	col;		/* multi-column column			*/
	char	**text;		/* The text contained in the field	*/
	int	*text_size;	/* The space allocated for the text	*/
	)
{
int	status = OM_S_SUCCESS;
IGRint	text_len;
IGRint	field_type;
IGRint	select_flag;
IGRint	pos = 0;

  SetProc(VDCmdFtxt_Nt.Get_text); Begin
  FIg_get_type( form_ptr, gadget_label, &field_type );
  FIfld_get_text_length ( form_ptr, gadget_label, row, col, &text_len );

  /* Increment text_len because of NULL and poss addn format  */
  text_len = text_len+10;

  if( *text_size < text_len ){
    if( *text_size > 0 ){
      /* Realloc space for larger string */
      *text = (char *) om$realloc ( ptr=*text, size=text_len );
    }
    else{
      /* Calloc space for string */
      *text = om$calloc ( num=1, size=text_len );
    }
    *text_size = text_len;
  }

  if( ! *text ){
    /*| Couldn't malloc text */
    *text_size = 0;
    return ( FI_NO_MEMORY );
  }

  FIfld_get_text( form_ptr, gadget_label, row, col, *text_size,
                            *text, &select_flag, &pos );

  End
  return ( status );

} 


/************************************************************************/
/*	METHOD	form_notification					*/
/************************************************************************/

method form_notification ( int form_label ; int gadget_label ; 
			   double value ; char * form_ptr )
{
int	status = OM_S_SUCCESS;

IGRshort	i;
long		sts;

static	char	*text;
static	int	text_size = 0;
static	int	len = 0;

IGRint		msg, select_flag, n_rows, no_formats;
IGRint		row = 0;
IGRint		act_row = 0;	/* parameter row selected for inclusion */
IGRint		col = 0;
IGRint		pos = 0;
IGRchar		para_text[TEXT_SIZE], my_msg[TEXT_SIZE];
int 		len1;
char 		Feet_Name[DI_PATH_MAX];
struct ACrg_coll	coll;
IGRchar         msgtext[TEXT_SIZE];
int             printf_state = 0;

  SetProc(VDCmdFtxt_Ms.form_notification); Begin

  my_msg[0] = '\0';
  me->my_label = -1;

  /*" label %d, gadg %d\n", form_label, gadget_label */
  FIg_set_text( me->forms[0].form_ptr, FI_MSG_FIELD, "" );

  switch ( gadget_label )
  {
    case FI_ACCEPT:
    case FI_EXECUTE:

      if( me->form_expr.string[0] == '\0' ){
	ex$message( msgnumb = VD_E_NoFormat );
        FIg_set_state_off( form_ptr, gadget_label );
        break;
      }
      /*
       * test for empty tedxt string
       */
      len = strlen( me->form_expr.string );
      for(i=0;i<len;i++) if( me->form_expr.string[i] != ' ' ) break;
      if( i == len ){
	ex$message( msgnumb = VD_E_NoFormat );
        FIg_set_state_off( form_ptr, gadget_label );
        break;
      }

      /* process the found format */
      status =
      om$send(msg = message VDCmdFtxt.process_format( &sts ),
	      targetid = my_id );
      as$status( action = RET_STATUS);

      if( sts == MSSUCC ){ex$message( msgnumb = VD_S_FrTxtCr ); }
      else 	{ex$message( msgnumb = VD_S_NoFrTxtCr ); }

      if( gadget_label == FI_EXECUTE ){

	/*
	 * Reset the form (see FI_RESET)
	 */
	status =
	om$send(msg = message VDCmdFtxt.form_notification(
				form_label, FI_RESET, value, form_ptr ),
		targetid = my_id );
	as$status( action = RET_STATUS );
      }
      else me->my_label = VD_FTEXT_ACCEPT;

      FIg_set_state_off( form_ptr, gadget_label );
      break;

    case FI_CANCEL:

      FIg_set_state_off( form_ptr, gadget_label );
      me->my_label =  VD_FTEXT_CANCEL;
      break;

    case FI_RESET:     

      /*
       * clear FORMAT_OUTPUT gadget
       */
      FIfld_get_num_rows( form_ptr, FORMAT_OUTPUT, &n_rows );
      for(i=0;i<n_rows;i++)  FIfld_set_text(form_ptr,FORMAT_OUTPUT,i,0,"");
      /* set cursor at begin position */
      FIfld_set_text( form_ptr, FORMAT_OUTPUT, 0, 0, "" );
      FIfld_pos_cursor( form_ptr, FORMAT_OUTPUT, 0,0,0,0,0,0); 

      /*
       * clear TXT_OUTPUT gadget
       */
      FIfld_get_num_rows( form_ptr, TXT_OUTPUT, &n_rows );
      for( i=0; i<n_rows; i++ )  FIfld_set_text( form_ptr,TXT_OUTPUT,i,0,"");

      /*
       * clear EXPR_NAME gadget
       */
      FIg_set_text( form_ptr, EXPR_NAME, "" );

      /*
       * reset the parameters select options
       */
      status =
      om$send(msg = message VDCmdFtxt.fill_in_params( &sts ),
	      targetid = my_id );
      as$status( action= RET_STATUS );

      /*
       * get the existing formatted text expressions
       */
      status =
      om$send(msg = message VDCmdFtxt.get_exist_formats( &sts ),
	      targetid = my_id );
      as$status( action = RET_STATUS );

      status = 
      om$send(msg = message VDCmdFtxt.disp_exist_formats( &sts, FALSE ),
	      targetid = my_id );
      as$status( action = RET_STATUS );

      VDSinit_ldexpr( &me->form_expr );
      if( me->form_expr.params[0] != '\0' )
                me->form_expr.params[0] = '\0';

      FIg_set_state_off( form_ptr, gadget_label );

      break;

    case EXIST_FORMAT:

      select_flag = FALSE;
      no_formats = 0;
      FIfld_get_list_num_rows( form_ptr, gadget_label, 0, &no_formats );
      /* no_formats: %d\n", no_formats */

      act_row = 0;
      do{
	FIfld_get_list_select( form_ptr,gadget_label,act_row,0,&select_flag);
        act_row++ ;
      }
      while( select_flag != TRUE && act_row <= no_formats );

      if( act_row <= no_formats ){
	
	/* set active structure */
	row = act_row - 1;
	status =
	om$send(msg = message VDCmdFtxt.set_ldexpr_active( &sts, row ),
		targetid = my_id );
	as$status( action = RET_STATUS );
      }

      FIfld_set_text(form_ptr,gadget_label,0,0,me->macro_name);

      break;	/* after FORMAT */

    case MACRO_NAME:

      /* only review mode */
      break;

    case EXPR_NAME :

      /* define or modify expression name */
      status =
      om$send(msg = message VDCmdFtxt.Get_text( form_ptr, gadget_label, 
					row, col, &text, &text_size ),
	      targetid = my_id );
      as$status( action = RET_STATUS );

      if( len = strlen( text ) > MAX_FORMAT ){
        for(i=MAX_FORMAT-1;i<len;i++) text[i] = '\0';
      }

      strcpy( me->form_expr.formatname, text );
      status =
      om$send(msg = message VDCmdFtxt.check_formatname( &sts, 
						me->form_expr.formatname ),
	      targetid = my_id );
      as$status( action = RET_STATUS );

      /*" formatname: %s\n", me->form_expr.formatname */
      FIg_set_text( form_ptr, gadget_label, me->form_expr.formatname );
      break;

    case PARAS_FIELD:     /* For Selecting Parameters */

      FIfld_get_active_row( form_ptr, gadget_label, &act_row, &pos );

      FIfld_get_text(form_ptr,gadget_label,act_row,0,DI_PATH_MAX,Feet_Name,
		     &select_flag,&pos);

      __DBGpr_int(" act_row ", act_row );
      __DBGpr_str(" FeetName ", Feet_Name );
      __DBGpr_obj(" HDR ", me->hdr );

      select_flag = FALSE;

      strncpy( coll.name , Feet_Name, 79 );
      status =
      vd$review_params(	pMsg		= &sts,
			pComponent	= &me->hdr,
			NbParams	= 1,
			pList		= &coll,
			pMdEnv		= &me->ModuleInfo );
      if( status&sts&1 ){
        switch( coll.desc.type ){
  	  case AC_ATTRIB_DOUBLE :
	    __DBGpr_com(" Type Double ");
	    __DBGpr_dbl(" Found Value ", coll.desc.value.att_exp );
  	    select_flag = TRUE;
	    strcpy( para_text, "%.2f" );
	    break;
	  case AC_ATTRIB_TEXT :
	    __DBGpr_com(" Type Text ");
	    __DBGpr_str(" Found STring ", coll.desc.value.att_txt );
	    select_flag = TRUE;
	    strcpy( para_text, "%s" );
	    break;
	  default :
	    select_flag = FALSE;
        }
      }

      if( ! select_flag ) {

	struct	GRid	Temp;
	IGRdouble	value;

	__DBGpr_com(" Check Templates ");

	status =
	om$send(msg = message ACcpx.ACfind_temp_obj( &msg, Feet_Name, &Temp ),
		senderid = NULL_OBJID,
		targetid = me->hdr.objid,
		targetos = me->hdr.osnum);

	status = 
	om$send(msg = message expression.NDgive_value( &value ),
		senderid = NULL_OBJID,
		targetid = Temp.objid,
		targetos = Temp.osnum );

	if( status & msg & 1 ){
	  select_flag = TRUE;
	  __DBGpr_dbl(" Found Value ", value );
	  strcpy( para_text, "%.2f" );
	}
      }
	
	__DBGpr_str(" params ", me->form_expr.params );
      if( select_flag ){

	__DBGpr_com(" Select_FLAG = 1 ");
	if(me->form_expr.params[0] == '\0')
	  strcpy( me->form_expr.params, Feet_Name);
	else{
          if( strlen(me->form_expr.params) + strlen(Feet_Name)<DB_TEXT_SIZE ){
	    sprintf(me->form_expr.params,"%s, %s", 
                          me->form_expr.params,Feet_Name);
          }
         /* tr 179601237 */ 
          else{
             printf_state = 1;
             sprintf(msgtext," Cut format due to params over %d", DB_TEXT_SIZE); 
	     strcpy( para_text, "" );
             FIg_set_text( form_ptr, FI_MSG_FIELD, msgtext);
          }
	}

	__DBGpr_str(" para_text ", para_text );
	__DBGpr_str(" params ", me->form_expr.params );

	col = 0;
	FIfld_get_active_row ( form_ptr, FORMAT_OUTPUT, &row, &pos );
	status =
	om$send(msg = message VDCmdFtxt.Get_text( form_ptr, FORMAT_OUTPUT, row,
					col, &text, &text_size ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	strcat( text, para_text );
	FIfld_set_text( form_ptr, FORMAT_OUTPUT, row, col, text, TRUE );

	status =
	om$send(msg = message VDCmdFtxt.form_notification(
					0, FORMAT_OUTPUT, 1.0, form_ptr ),
		targetid = my_id );
	as$status( action = RET_STATUS );

        if(printf_state) 
          FIg_set_text( form_ptr, FI_MSG_FIELD, msgtext);
      }

      break;

    case EXP_TYP_FIELD:     /* For Selecting expression type */
	{
		IGRchar 	*Tabnam=NULL, tabl_typ[16];
		IGRlong         msg,status;
        	IGRshort        count=0;
        	IGRint          i;
        	GRspacenum      cur_os;


		FIg_get_text(form_ptr, gadget_label, tabl_typ);
		ex$get_cur_mod (osnum = &cur_os);
        	vd$tblexp_idnd ( msg = &msg,
                        osnum = cur_os,
			p_type = tabl_typ,
                        p_count = &count);
 
		if ( count == 0) break ;

        	Tabnam = _MALLOC(count*VD_CREXP_CHR_NAME, char);
 
        	vd$tblexp_idnd ( msg = &msg,
                        osnum = cur_os,
			p_type = tabl_typ,
                        p_count = &count,
                        p_nams = Tabnam);
 
        	FIfld_set_num_rows( form_ptr, EXP_NAM_FIELD, count );
        	for (i=0; i<count; i++){
                	VDfld_set_list_text( form_ptr,EXP_NAM_FIELD,i,0,
                        	&Tabnam[i*VD_CREXP_CHR_NAME],FALSE);
        	}
 
        	_FREE(Tabnam);

	}
      break;
 
    case EXP_NAM_FIELD:     /* For Selecting expression name */
	{
		IGRchar tabl_name[VD_CREXP_CHR_NAME];

                GRspacenum      cur_os;
                struct GRobj_env        objList;
		struct ACrg_coll 	coll;
		IGRlong			status, msg1;

		tabl_name[0] = '\0';
		FIg_get_text(form_ptr, gadget_label, tabl_name);
		if ( tabl_name[0] == '\0')
			break;
		/*
		strcpy( para_text, "%s" );
		*/
 
                ex$get_cur_mod (osnum = &cur_os);
                objList.mod_env = me->mod_env;
                objList.obj_id     = me->hdr;
                status =
                vd$tblexp_exec( msg     = &msg1,
                                osnum   = cur_os,
                                tabnam  = tabl_name,
                                flag    = TRUE,
                                mode    = VD_EXP_SILENT,
                                num_objs= 1,
                                objList = &objList,
                                attr    = &coll );
 
                if ( status & msg1 & 1 ){
                  if( coll.desc.type == AC_ATTRIB_DOUBLE ){
                    __DBGpr_dbl(" Found Value ", coll.desc.value.att_exp );
			strcpy( para_text, "%.2f" );
                  }
                  else if( coll.desc.type == AC_ATTRIB_TEXT ){
                    __DBGpr_str(" Found String", coll.desc.value.att_txt );
			strcpy( para_text, "%s" );
                  }
                  else{
			printf ("Unknown type\n");
                  }
                }

		if ( me->form_expr.params[0] == '\0')
			sprintf( me->form_expr.params,"%s%s", "~~", tabl_name);
		else {
			if( strlen(me->form_expr.params) + 
				strlen(tabl_name)<DB_TEXT_SIZE ){
            			sprintf(me->form_expr.params,"%s, %s%s",
                          		me->form_expr.params,"~~", tabl_name);
			}
			else{
             			printf_state = 1;
             			sprintf(msgtext,
					" Cut format due to params over %d", 
					DB_TEXT_SIZE);
 
             			strcpy( para_text, "" );
             			FIg_set_text( form_ptr, FI_MSG_FIELD, msgtext);
          		}

		}
		col = 0;
        	FIfld_get_active_row ( form_ptr, FORMAT_OUTPUT, &row, &pos );
        	status =
        	om$send(msg = message VDCmdFtxt.Get_text( form_ptr, 
					FORMAT_OUTPUT, row,
                                        col, &text, &text_size ),
                	targetid = my_id );
        	as$status( action = RET_STATUS );
 
        	strcat( text, para_text );
        	FIfld_set_text( form_ptr, FORMAT_OUTPUT, row, col, text, TRUE );
 
        	status =
        	om$send(msg = message VDCmdFtxt.form_notification(
                                        0, FORMAT_OUTPUT, 1.0, form_ptr ),
                	targetid = my_id );
        	as$status( action = RET_STATUS );
 
        	if(printf_state)
          		FIg_set_text( form_ptr, FI_MSG_FIELD, msgtext);

	}
      break;

    case FORMAT_OUTPUT:

      /* Read in text to format up to 10 (MAX_ROW) lines */
      col=0; row=0;
      status =
      om$send(msg = message VDCmdFtxt.Get_text( form_ptr, gadget_label, row, col, 
				  &text, &text_size ),
	      targetid = my_id );
      as$status( action = RET_STATUS );

      strcpy( me->form_expr.string, text );
      /*" form_expr.string: <%s>\n", text */

      row=1; len=0;
      FIfld_get_text_length( form_ptr, gadget_label, row, col, &len );
      /*" len[1]: %d\n", len */

      while( len > 1 && row < ROW_MAX ){

	status =
	om$send(msg = message VDCmdFtxt.Get_text( form_ptr, gadget_label, row, col, 
						 &text, &text_size ),
		targetid = my_id );
	as$status( action = RET_STATUS );

	/*" row[%d]: %s\n", row, text */

	len = strlen( me->form_expr.string );
	me->form_expr.string[ len ] = 27;
	me->form_expr.string[ len+1 ] = 10;
	me->form_expr.string[ len+2 ] = '\0';
        strcat( me->form_expr.string, text );
	row++;
        FIfld_get_text_length ( form_ptr, gadget_label, row, col, &len);

      } /* while row < 10 */

      /* update FORMAT_OUTPUT / TXT_OUTPUT */
      status =
      om$send(msg = message VDCmdFtxt.format_output( &sts ),
	      targetid = my_id );
      as$status();

      status =
      om$send(msg = message VDCmdFtxt.txt_output( &sts ),
	      targetid = my_id );
      as$status();

      break;

    case DELETE_FORMAT:

      if( me->form_expr.string[0] == '\0' ){
	ex$message( msgnumb = VD_E_NoFormat );
	FIg_set_state_off( form_ptr, gadget_label );
	break;
      }
      /* test for an empty string */
      len = strlen( me->form_expr.string );
      for(i=0;i<len;i++) if( me->form_expr.string[i] != ' ' ) break;
      if( i == len ){
	ex$message( msgnumb = VD_E_NoFormat );
	FIg_set_state_off( form_ptr, gadget_label );
	break;
      }

      /* delete current format from sub directory system. */
      VDSdelete_formats( me->form_expr.formatname,
			 me->macro_name );

      FIg_set_state_off( form_ptr, gadget_label );

      /* update the form ( see FI_RESET ) */
      status =
      om$send(msg = message VDCmdFtxt.form_notification(
				form_label, FI_RESET, value, form_ptr ),
	      targetid = my_id );
      as$status( action = RET_STATUS );

  } /* END switch ( gadget_label ) */

  /* give return value */
  if(	(gadget_label == FI_ACCEPT) || 
	(gadget_label == FI_CANCEL) ){
    /*| put_response */ 
    _put_response( resp = VD_FTEXT_FORM_INFO );
  }

quit: 
  End
  return ( OM_S_SUCCESS );

}

/************************************************************************/
/*	METHOD	format_output						*/
/************************************************************************/

method	format_output( long * sts )
{
int	status = OM_S_SUCCESS;
IGRint	i, row, col;
IGRchar	*token;
char	*fm_ptr;
IGRchar	newline[3];
IGRchar	tmp[TEXT_SIZE*2];

  SetProc(VDCmdFtxt_Ms.format_output); Begin
/*
 * This method clears ans displays the latest layout for the formatted
 * text.
 */

  *sts = MSSUCC;
  /*" string: %s\n", me->form_expr.string */

  /* clear FORMAT_OUTPUT gadget */
  fm_ptr = me->forms[0].form_ptr;
  FIfld_get_num_rows( fm_ptr, FORMAT_OUTPUT, &row );
  for( i=0; i<row; i++ )  FIfld_set_text( fm_ptr, FORMAT_OUTPUT, i, 0, "" );

  col=0; row=0;
  newline[0] = 27;
  newline[1] = 10;
  newline[2] = '\0';

  strcpy( tmp, me->form_expr.string );
  token = strtok( tmp, newline );
  while ( token != (char *)NULL && row < ROW_MAX ){
    /*" token is %s\n", token */
    FIfld_set_text( fm_ptr, FORMAT_OUTPUT, row, col, token );
    token  = strtok( NULL, newline );
    row++;
  }

  End
  return( status );
}


/************************************************************************/
/*	METHOD	txt_output						*/
/************************************************************************/

method txt_output ( long * sts )
{
int	status = OM_S_SUCCESS;
IGRint	i,n_rows;
IGRchar	*output, tmp[TEXT_SIZE*2];
char	*fm_ptr;

  SetProc(VDCmdFtxt_Ms.txt_output); Begin
/*
 * This method clears ans displays the latest layout for the formatted
 * text in full format.
 */

  *sts = MSSUCC;
  output = NULL;

  /*" string: %s\n", me->form_expr.string */
  /*" params: %s\n", me->form_expr.params */

  /* clear TXT_OUTPUT gadget */
  fm_ptr = me->forms[0].form_ptr;
  FIfld_get_num_rows( fm_ptr, TXT_OUTPUT, &n_rows );
  for( i=0; i<n_rows; i++ )  FIfld_set_text( fm_ptr, TXT_OUTPUT, i, 0, "" );

  /*| create text output */
  output = om$calloc( size = TEXT_SIZE*2 );
  output[0] = '\0';

  if( me->form_expr.string[0] != '\0' ){

    /*| call VDcreate_text2 */
    status =
    VDcreate_text2( me->form_expr.string,
		    me->form_expr.params,
		    &me->mod_env,
		    &me->hdr,		/* Input_macro */
		    output );


     if( ! (status&1)){

	status =
	om$send(msg = message VDCmdFtxt.form_notification(
					0, FI_RESET, 1.0, fm_ptr ),
		targetid = my_id );
	as$status( action = RET_STATUS );
     }
     else{
	
      IGRchar	*token;
      IGRchar	newline[3];
      IGRint	row, col;

      col=0; row=0;
      newline[0] = 27; newline[1] = 10; newline[2] = '\0';

      strcpy( tmp, output );
      token = strtok( tmp, newline );  
      while ( token != (char *)NULL && row < ROW_MAX ){
	/*" token is %s\n", token */
	FIfld_set_text( fm_ptr, TXT_OUTPUT, row, col, token );
	token  = strtok( NULL, newline );
	row++;
      }
    }
  }

  if( output ) om$dealloc( ptr = output );
  End
  return( status );
}


/************************************************************************/
/*	METHOD	process_format						*/
/************************************************************************/

method process_format( long * sts )
{
int	status = OM_S_SUCCESS;

  SetProc(VDCmdFtxt_Ms.process_format); Begin
/*
 * This method execute the active formatted text expression, by checking
 *	- duplication of the string + parameters
 *	- duplication of format name (expression name in subdirectory)
 * Then write the accepted formated in the subdirectory systemi in case
 * the method is called by VD_CREATE_FORMAT.
 */

  *sts = MSSUCC;

  /*| test if expression already exists in list */
  status =
  om$send(msg = message VDCmdFtxt.check_format( sts ),
	 targetid = my_id );
  as$status( action = RET_STATUS );

  if( *sts == MSFAIL ){
    /* formatted text expression exist */
    return( OM_S_SUCCESS );
  }

  /*
   * check formatname and display result
   */
  status = 
  om$send(msg = message VDCmdFtxt.check_formatname(sts,me->form_expr.formatname),
	  targetid = my_id );
  as$status( action = RET_STATUS );

  FIg_set_text( me->forms[0].form_ptr, EXPR_NAME, me->form_expr.formatname );

  status =
  om$send(msg = message VDCmdFtxt.create_format( sts, &me->form_expr ),
	  targetid = my_id );
  as$status( action = RET_STATUS );


  End
  return( status );
}


/************************************************************************/
/*	METHOD	check_formatname					*/
/************************************************************************/

method check_formatname( long * sts; char * def_name )
{
int	status = OM_S_SUCCESS;
IGRint	i,index,size;
IGRchar	expr_name[TEXT_SIZE];
IGRchar	tmp_name[TEXT_SIZE];

  SetProc(VDCmdFtxt_Ms.check_formatname); Begin
/*
 * This method checks if expression name for the formatted text is not
 * a duplicate of an already defined formatted expression.
 */

  *sts = MSSUCC;

  if( ! def_name ) return ( OM_E_INVARG );

  /* get size of leaderline expresssion list */
  size = om$dimension_of( varray = me->ldexpr_list );
  /*" size : %d\n", size */

  if( !strcmp( def_name, "" )){
    /*| No name given so generating one */
    sprintf( expr_name, "%s_", me->macro_name );
  }
  else{
    if( strncmp( def_name, me->macro_name, strlen( me->macro_name )) == 0 ){
      /*| names are equal */
      sprintf( expr_name, "%s_", me->macro_name );
    }
    else{
      strcpy( expr_name, def_name );
      /* check existing one */
      for(i=0;i<size;i++)
	if( strcmp( me->ldexpr_list[i].formatname, expr_name ) == 0 ) break;
      if(i == size ){
	/*| It's a unique name, so don't have to generate one */
	return( OM_S_SUCCESS );
      }
      else strcat( expr_name, "_" );
    }
    /*" check name: %s\n", expr_name */
  }

  index = 0;
  while( TRUE ){
    sprintf( tmp_name,"%s%d", expr_name, index ); 
    for(i=0;i<size;i++)
      if( strcmp( me->ldexpr_list[i].formatname, tmp_name ) == 0 ) break;
    if(i == size ){
      /*| found a unique one */
      break;
    }
    index++;
  }

  strcpy( def_name, tmp_name ); 
  /*" def_name: %s\n", def_name  */

  End
  return ( status );
}  

end implementation VDCmdFtxt;
