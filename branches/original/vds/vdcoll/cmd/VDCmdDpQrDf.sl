/* $Id: VDCmdDpQrDf.sl,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdcoll/cmd / VDCmdDpQrDf.sl
 *
 * Description:
 *	 Command Object to
 *	   o Display query definitions
 *	   o Display prefix definitions
 *	   o Display notes variables
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDpQrDf.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
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
# Revision 1.5  1996/05/23  20:31:38  pinnacle
# Replaced: vdcoll/cmd/VDCmdDpQrDf.sl for:  by yzhu for vds.240
#
# Revision 1.4  1995/10/03  17:49:04  pinnacle
# Replaced: vdcoll/cmd/VDCmdDpQrDf.sl for:  by tlbriggs for vds.240
#
 *
 * History:
 * 	11/16/94	Raju    Creation date
 *	10/02/84	tlb	Remove 'Define Prefix Definition' Cmd
 *					CMD_TYPE = 1, mytype = 1
 *
 *************************************************************************/


/****************************************************************************/
/*	CLASS SPECIFICATIONS						*****/
/****************************************************************************/

command_string	VDC_M_DpQrDf, 0, VDDpQrDf
synonym		VDC_M_DpNtVr, 2, VDDpNtVr
class		VDCmdDpQrDf
super_class	CEO_LOCATE
product_name	"$VDS"
command_table	"vds.cmd"

/* form used */
form		"VDDispQrDf",0,0,"-1","-1"

start_state     start

/****************************************************************************/
/*	SPECIFICATION AREA						*****/
/****************************************************************************/

specification

#define  FP		me^^CEO.forms[0].form_ptr


instance
{
 struct GRid		coll_id;
 int			body_fld;
 int			body_width;
}


/****************************************************************************/
/*	IMPLEMENTATION AREA						*****/
/****************************************************************************/

implementation

#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "FI.h"
#include "msdef.h"
#include "msmacros.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "vderrmacros.h"
#include "vdcolldef.h"
#include "vdmemmacros.h"
#include "v_dbgmacros.h"

%safe
  static int x_pos = -1,y_pos = -1;
%endsafe

from  ACrg_collect  import  AClist_attribute;
from  ACrg_collect  import  ACget_attribute_at_index;
from  ACdiowner     import  ACrem_att_at_index;


/****************************************************************************/
/*	STATE TABLE AREA 						*****/
/****************************************************************************/

state_table

#include "VDmsg.h"

state start
on CMD_TYPE = 0	 do message_key VD_M_DpQrDf
					state set_instance
on CMD_TYPE = 2	 do message_key VD_M_DpNtVr
					state set_instance

state set_instance
execute		set_instance_and_form
on SUCCESS	state form_operations
on ELSE		do status "Error setting form" state terminate

state form_operations
display_form		0
prompt_key		VD_P_FormOp
filter			get_event
on EX_FORM_FINISHED	state terminate

at wakeup do set_form_pos
at sleep  do save_form_pos


action  save_form_pos
{

  FIf_get_location(me->forms[0].form_ptr,&x_pos,&y_pos);
  *sts = MSSUCC;

}

action  set_form_pos
{
   if(x_pos != -1 && y_pos != -1)
     FIf_set_location ( me->forms[0].form_ptr, x_pos, y_pos );
}

action set_instance_and_form
{
long			msg;
char			coll_name[80],
			AttrText[VD_ATTR_LEN],  tmpstr[VD_ATTR_LEN];
struct GRid		loc_coll_id;
int			nb_attr, ii, nb_str, row_num,
			body_fld, body_width, len;
int			start_pos, end_pos;
struct ACrg_coll	att;


   status = OM_S_SUCCESS;
   msg = MSSUCC;

   /* set example in the form */
   if ( me->mytype == 0 )
      FIg_set_text( FP, VD_EXAMPLE_FLD,
  "filter | select VDequidef where (eqp_family = filter) & (eqp_partrev != 0)");

   VDSget_filename ( coll_name );
   strcat ( coll_name, ":IGENOD:" );
   if ( me->mytype == 0 )
   {
	strcat ( coll_name, VD_QRYDEF_DIR_NAME );
	me->body_fld = VD_QRYDEF_BDY_FLD;
	me->body_width = VD_QRYDEF_BDY_WD;
   }
   else if ( me->mytype == 2 )
   {
	strcat ( coll_name, VD_NOTES_DIR_NAME );
	me->body_fld = VD_NOTES_BDY_FLD;
	me->body_width = VD_NOTES_BDY_WD;
   }
   else
   {
      msg = MSFAIL;
      goto wrapup;
   }

   row_num = 0;
   status = di$translate( objname = coll_name,
			  p_objid = &loc_coll_id.objid,
			  p_osnum = &loc_coll_id.osnum  );

   if ( status & 1 )
   {
     me->coll_id = loc_coll_id;
     body_fld = me->body_fld;
     body_width = me->body_width;
     status = om$send( msg = message ACrg_collect.AClist_attribute(
					&msg,
					0,
					NULL,
					&nb_attr ),
			targetid = loc_coll_id.objid,
			targetos = loc_coll_id.osnum );
     VDS_ERR_HNDLR( "ACrg_collect.AClist_attribute", status, msg,
		    VD_VERBOSE,  wrapup );

     FIfld_set_max_num_rows ( FP, body_fld, nb_attr + 100 );

     for(ii=0; ii<nb_attr; ii++)
     {
	status = om$send(msg = message ACrg_collect.ACget_attribute_at_index(
						 &msg, ii, &att ),
			targetid = loc_coll_id.objid,
			targetos = loc_coll_id.osnum );
	VDS_ERR_HNDLR( "ACrg_collect.ACget_attribute_at_index", status, msg,
			VD_VERBOSE,  wrapup );

	status = VDgetAttFromColl ( &msg, loc_coll_id, att.name, AttrText,
				    VD_ATTR_LEN, &nb_str );
	VDS_ERR_HNDLR( "VDgetAttFromColl", status, msg, VD_VERBOSE, wrapup );
	FIfld_set_text ( FP, body_fld, row_num, 0, att.name, FALSE );

	start_pos = 0;
	while ( 1 )
	{
	    len = strlen ( &AttrText[start_pos] );
	    if ( len <= body_width )
	    {
		FIfld_set_text ( FP, body_fld, row_num, 1,
						&AttrText[start_pos], FALSE );
		row_num++;
		break;
	    }
	    else
	    {
		end_pos = body_width;
		/* find position of , character */
		while ( AttrText[start_pos+end_pos] != '\0' &&
			!isspace(AttrText[start_pos+end_pos])  ) end_pos++;
		if ( AttrText[start_pos+end_pos] == '\0' )
		{
		   FIfld_set_text ( FP, body_fld, row_num, 1,
						&AttrText[start_pos], FALSE );
		   row_num++;
		   break;
		}
		else
		{
		   strncpy( tmpstr, &AttrText[start_pos], end_pos+1 );
		   tmpstr[end_pos+1] = '\0';
		   FIfld_set_text ( FP, body_fld, row_num, 1,
						tmpstr, FALSE );
		   row_num++;

		   end_pos++;
		   /* skip blank characters */
		   while ( AttrText[start_pos+end_pos] != '\0' &&
			   isspace(AttrText[start_pos+end_pos])   )
				end_pos++;
		   if ( AttrText[start_pos+end_pos] == '\0' )  break;
		   start_pos = start_pos+end_pos;
		}
	     } /* else of if ( len <= body_width ) */
	} /* while ( 1 ) */

	ii = ii + nb_str;

     } /* for(ii=0; ii<nb_attr; ii++) */

	FIfld_set_num_rows ( FP, body_fld, row_num );
   } /* if ( status & 1 ) */
   else
   {
     me->coll_id.objid = NULL_OBJID;
     status = OM_S_SUCCESS;
   }

   if ( me->mytype != 0 )
   {
     FIg_erase ( FP, VD_QRYDEF_TITLE );
     FIg_erase ( FP, VD_QRYDEF_GRP );
     FIg_display ( FP, VD_NOTES_TITLE );
     FIg_display ( FP, VD_NOTES_GRP );
     }

wrapup :
   if ( status & msg & 1 )
	*sts = MSSUCC;
   else
	*sts = MSFAIL;
}

/****************************************************************************/
/*	ACTION  form_notification					*****/
/****************************************************************************/
action form_notification
{
char		tmpstr[81], *tmpstr1 = NULL, *tmpstr2 = NULL;
int		body_fld, num_rows;
int		ii, jj, sel_row, sel_pos, sel_flag, r_pos;
long		sts, msg;

    FIg_set_text ( FP, FI_MSG_FIELD, "" );
    body_fld = me->body_fld;

    switch ( gadget_label )
    {
      case  VD_READ_FROM_FILE :
	FIg_erase( FP, VD_WRITE_GRP );
	FIg_display( FP, VD_READ_GRP );
	break;

      case  VD_READ_FILE_FLD :
	FIg_get_text ( FP, VD_READ_FILE_FLD, tmpstr );
	sts = om$send ( msg = message VDCmdDpQrDf.read_from_file (
					&msg, tmpstr ),
			targetid = my_id );
	if ( !(msg&1) ) break;
	FIg_erase( FP, VD_READ_GRP );
	break;

      case VD_WRITE_TO_FILE :
	FIg_erase( FP, VD_READ_GRP );
	FIg_display( FP, VD_WRITE_GRP );
	break;

      case  VD_WRITE_FILE_FLD :
	FIg_get_text ( FP, VD_WRITE_FILE_FLD, tmpstr );
	sts = om$send ( msg = message VDCmdDpQrDf.write_to_file (
				&msg, tmpstr ),
			targetid = my_id );
	if ( !(msg&1) ) break;
	FIg_set_text(FP, FI_MSG_FIELD, "Written to file" );
	FIg_erase( FP, VD_WRITE_GRP );
	break;

      case VD_DEL_ROW_FLD :
	FIfld_get_num_rows ( FP, body_fld, &num_rows );
	tmpstr1 = (char *) malloc ( sizeof(char) * num_rows * 81 );
	tmpstr2 = (char *) malloc ( sizeof(char) * num_rows * 81 );
	FIfld_get_active_row ( FP, body_fld, &sel_row, &sel_pos );
	for ( ii=0; ii<num_rows; ii++ )
	{
	  FIfld_get_text( FP, body_fld, ii, 0, 80, &tmpstr1[ii*81],
			  &sel_flag, &r_pos);
	  FIfld_get_text( FP, body_fld, ii, 1, 80, &tmpstr2[ii*81],
			  &sel_flag, &r_pos);
	}

	jj = 0;
	for ( ii=0; ii<num_rows; ii++ )
	{
	  if ( ii != sel_row )
	  {
	    FIfld_set_text( FP, body_fld, jj, 0, &tmpstr1[ii*81], FALSE );
	    FIfld_set_text( FP, body_fld, jj, 1, &tmpstr2[ii*81], FALSE );
	    jj++;
	  }
	}
	FIfld_set_num_rows ( FP, body_fld, num_rows-1 );
	FIfld_set_select ( FP, body_fld, sel_row, sel_pos, FALSE );

	if ( tmpstr1 )  free ( tmpstr1 );
	if ( tmpstr2 )  free ( tmpstr2 );
	break;

      case VD_INS_ROW_FLD :
	FIfld_get_active_row ( FP, body_fld, &sel_row, &sel_pos );
	FIfld_insert_blank_row ( FP, body_fld, sel_row );
	break;

      case VD_DEL_ALL_ROWS_FLD :
	/* not implemented */
	break;

      case FI_EXECUTE :
      case FI_ACCEPT:
	sts = om$send ( msg = message VDCmdDpQrDf.validate_data ( &msg ),
			targetid = my_id );
	if ( !(msg & 1) ) break;

	sts = om$send ( msg = message VDCmdDpQrDf.save_collection ( &msg ),
			targetid = my_id );
	if ( gadget_label == FI_ACCEPT )
	{
	   _put_response ( resp = EX_FORM_FINISHED );
        }
	break;

      case FI_CANCEL:
	_put_response ( resp = EX_FORM_FINISHED );
	break;

   }

}


action validate_data ( long *msg )
{
int		ii, jj, num_rows, sel_flag, r_pos,
		nb_attr, body_fld;
char		name[ATTR_NAME],
		AttText[VD_ATTR_LEN], body[VD_ATTR_LEN],
		name1[ATTR_NAME], first_check;
char		**names = NULL, **values = NULL;

  *msg = MSSUCC;
  nb_attr = 0;
  body_fld = me->body_fld;
  FIfld_get_num_rows ( FP, body_fld, &num_rows );
  if ( num_rows == 0 )
  {
    goto wrapup;
  }

  /*
   * get num of attributes and also make sure that there is a name
   * for value
   */
  FIfld_get_num_rows ( FP, body_fld, &num_rows );
  first_check = 0;
  for ( ii=0; ii<num_rows; ii++)
  {
     FIfld_get_text ( FP, body_fld, ii, 0, ATTR_NAME, name, &sel_flag, &r_pos);
     if ( !first_check )
     {
	FIfld_get_text( FP, body_fld, ii, 1, VD_ATTR_LEN, AttText,
			&sel_flag, &r_pos);
	if ( name[0] == '\0'  &&  AttText[0] != '\0' )
	{
	   FIg_set_text ( FP, FI_MSG_FIELD, "Attribute name not defined" );
	   *msg = MSFAIL;
	   goto wrapup;
	}
	if ( name[0] != '\0' ) first_check = 1;
     }
     if ( name[0] == '\0' ) continue;
     nb_attr++;
  }

  if ( nb_attr == 0 )
  {
     FIg_set_text ( FP, FI_MSG_FIELD, "Attribute Name(s) not defined" );
     *msg = MSFAIL;
     goto wrapup;
  }

  /*
   * allocate memory and get the attributes
   */
  if(!vd$malloc_str_list (  str_list = &names,
				 str_size = ATTR_NAME,
				 num_str  = nb_attr )) {
     	*msg = MSFAIL;
	goto wrapup;
	}

  if (!vd$malloc_str_list (  str_list = &values,
				 str_size = VD_ATTR_LEN,
				 num_str  = nb_attr )) {
     	*msg = MSFAIL;
	goto wrapup;
	}

  nb_attr = 0;
  for ( ii=0; ii<num_rows; ii++)
  {
	FIfld_get_text ( FP, body_fld, ii, 0, ATTR_NAME, name,
			 &sel_flag, &r_pos);
	if ( name[0] == '\0' ) continue;
	strcpy( names[nb_attr], name );
	FIfld_get_text ( FP, body_fld, ii, 1, VD_ATTR_LEN, AttText, &sel_flag,
			   &r_pos);
	jj=0;
	while ( 1 )
	{
	    FIfld_get_text ( FP, body_fld, ii+jj+1, 0, ATTR_NAME,
						name1, &sel_flag, &r_pos);

	    FIfld_get_text ( FP, body_fld, ii+jj+1, 1, VD_ATTR_LEN,
						body, &sel_flag, &r_pos);
	    if ( name1[0] != '\0' ) break;
	    if ( name1[0] == '\0' && body[0] == '\0' ) break;
	    strcat ( AttText, " ");
	    strcat ( AttText, body );
	    jj++;
	}

	ii = ii + jj;
	strcpy ( values[nb_attr], AttText );
	nb_attr ++;

  } /*  for ( ii=0; ii<num_rows; ii++)  */
    
  /*
   * validate
   */

  /* make sure names of attributes are distinct */
  for ( ii=0; ii<nb_attr-1; ii++)
    for ( jj=ii+1; jj<nb_attr; jj++)
	if ( !strcmp( names[ii], names[jj] ) )
	{
	   FIg_set_text ( FP, FI_MSG_FIELD, "ERROR: Duplicate Attribute Names");
	   *msg = MSFAIL;
	   goto wrapup;
	}

wrapup:
  if ( names ) vd$free_str_list ( str_list = names,
				  num_str  = nb_attr );
  if ( values) vd$free_str_list ( str_list = values,
				  num_str  = nb_attr );


}


action save_collection ( long  *msg )
{
int			ii, jj, num_rows, sel_flag, r_pos,
			nb_attr, body_fld, len;
char			name[ATTR_NAME], coll_name[80],
			AttText[VD_ATTR_LEN], body[VD_ATTR_LEN],
			name1[ATTR_NAME];
struct GRid		coll_id;

  *msg = MSSUCC;
  body_fld = me->body_fld;
  FIfld_get_num_rows ( FP, body_fld, &num_rows );
  if ( num_rows == 0 && me->coll_id.objid == NULL_OBJID ) goto quit;

  if ( me->coll_id.objid == NULL_OBJID )
  {
     if ( me->mytype == 0 )
	strcpy ( coll_name, VD_QRYDEF_DIR_NAME );
     else
	strcpy ( coll_name, VD_NOTES_DIR_NAME );

     status = VDgetVdCollId ( msg, coll_name, 0, TRUE, &coll_id );
     VDS_ERR_HNDLR( "VDretCollId", status, *msg, VD_VERBOSE, quit );
     me->coll_id = coll_id;
  }
  else
     coll_id = me->coll_id;

  status = om$send( msg = message ACrg_collect.AClist_attribute(
					msg,
					0,
					NULL,
					&nb_attr ),
			targetid = coll_id.objid,
			targetos = coll_id.osnum );
  VDS_ERR_HNDLR( "ACrg_collect.AClist_attribute", status, *msg,
		  VD_VERBOSE,  quit );

  for( ii=nb_attr-1; ii > -1; ii--)
  {
	status = om$send(msg = message ACdiowner.ACrem_att_at_index
			 ( msg, ii ),
		 senderid = NULL_OBJID,
		 targetid = coll_id.objid,
		 targetos = coll_id.osnum);
	VDS_ERR_HNDLR( "ACdiowner.ACrem_att_at_index", status, *msg,
		    VD_VERBOSE, quit );
  }

  FIfld_get_num_rows ( FP, body_fld, &num_rows );
  for ( ii=0; ii<num_rows; ii++)
  {
	FIfld_get_text ( FP, body_fld, ii, 0, ATTR_NAME, name,
			 &sel_flag, &r_pos);
	if ( name[0] == '\0' ) continue;
	FIfld_get_text ( FP, body_fld, ii, 1, VD_ATTR_LEN, AttText, &sel_flag,
			   &r_pos);
	jj=0;
	do
	{
	    FIfld_get_text ( FP, body_fld, ii+jj+1, 0, ATTR_NAME,
						name1, &sel_flag, &r_pos);

	    FIfld_get_text ( FP, body_fld, ii+jj+1, 1, VD_ATTR_LEN,
						body, &sel_flag, &r_pos);
	    if ( name1[0] != '\0' ) break;
	    if ( name1[0] == '\0' && body[0] == '\0' ) break;
	    strcat ( AttText, " ");
	    strcat ( AttText, body );
	    jj++;
	} while ( 1 );

	ii = ii + jj;

	len = strlen ( AttText );
        if ( len )
	{
	   len--;
	   while ( isspace(AttText[len]) ) len--;
	   AttText[len+1] = '\0';
	}
	status = VDputAttInColl ( &msg, coll_id, name, AttText );

  } /*  for ( ii=0; ii<num_rows; ii++)  */


}

action read_from_file ( long *msg; char *filename )
{
FILE		*fp = NULL;
char		str[VD_ATTR_LEN], name[ATTR_NAME], *pc = NULL,
		tmpstr[VD_ATTR_LEN], AttText[VD_ATTR_LEN];
int		body_fld, body_width, row_num, len;
int		start_pos, end_pos, c, read_app_tgl;
int 	        is_query_def;
	
   *msg = MSSUCC;

   body_fld = me->body_fld;
   body_width = me->body_width;

   fp = fopen(filename,"r");
   if ( fp == NULL )
   {
      sprintf( str, "Can not open file '%s'", filename );
      FIg_set_text( FP, FI_MSG_FIELD, str );
      *msg = MSFAIL;
      goto quit;
   }

   FIg_get_state ( FP, VD_READ_APP_TGL, &read_app_tgl );
   if ( read_app_tgl )
	row_num = 0;
   else
	FIfld_get_num_rows ( FP, body_fld, &row_num );


   is_query_def = 0;
   while ( fgets (str, VD_ATTR_LEN, fp) )
   {
	/* read name of attribute */
	name[0] = '\0';
	sscanf( str, "%s", name );

        __DBGpr_str(" name ", name);
 
        /* tr 179601817 */
        if ( name[0] == '\0' || name[0] == '#' )  {
          if( !strcmp(name, "#QUERY_TEMPLATE") )
            is_query_def = 1;
          continue;
        }

        if( is_query_def == 0) {
          sprintf( str, "'%s' is not query_template file", filename );
          FIg_set_text( FP, FI_MSG_FIELD, str );
          UI_status(str);
          break;
        }


	/* skip the name of attribute */
	pc = str;
	while (   isspace(pc[0]) ) pc++;
	while ( ! isspace(pc[0]) ) pc++;
	while (   isspace(pc[0]) && (pc[0] != '\n') ) pc++;

	/* copy rest of line AttText */
	len = strlen( pc );
	pc[len-1] = ' ';	/* replace newline char with blank char*/
	strcpy( AttText, pc );

	/* read next lines and add it to AttText if started with tab */

	while ( 1 )
	{
	   c = fgetc ( fp );
	   if ( c == '#' )
	   {
 		fgets(str, VD_ATTR_LEN, fp);
		continue;
	   }
	   else if ( c == '\t' )
	   {
		ungetc( c, fp );
		fgets(str, VD_ATTR_LEN, fp);
		pc = str;
		while ( isspace(pc[0]) && (pc[0] != '\n') ) pc++;
		len = strlen( pc );
		pc[len-1] = ' ';	/* replace newline char with blank char*/
		strcat( AttText, pc );
	   }
	   else
	   {
		ungetc( c, fp );
		break;
	   }
	}

	FIfld_set_text ( FP, body_fld, row_num, 0, name, FALSE );

	start_pos = 0;
	while ( 1 )
	{
	    len = strlen ( &AttText[start_pos] );
	    if ( len <= body_width )
	    {
		FIfld_set_text ( FP, body_fld, row_num, 1,
						&AttText[start_pos], FALSE );
		row_num++;
		break;
	    }
	    else
	    {
		end_pos = body_width;
		/* find position of , character */
		while ( AttText[start_pos+end_pos] != '\0' &&
			!isspace(AttText[start_pos+end_pos])  ) end_pos++;
		if ( AttText[start_pos+end_pos] == '\0' )
		{
		   FIfld_set_text ( FP, body_fld, row_num, 1,
						&AttText[start_pos], FALSE );
		   row_num++;
		   break;
		}
		else
		{
		   strncpy( tmpstr, &AttText[start_pos], end_pos+1 );
		   tmpstr[end_pos+1] = '\0';
		   FIfld_set_text ( FP, body_fld, row_num, 1,
						tmpstr, FALSE );
		   row_num++;

		   end_pos++;
		   /* skip blank characters */
		   while ( AttText[start_pos+end_pos] != '\0' &&
			   isspace(AttText[start_pos+end_pos])   )
				end_pos++;
		   if ( AttText[start_pos+end_pos] == '\0' )  break;
		   start_pos = start_pos+end_pos;
		}
	     }
	} /* while ( 1 ) */
   }
   FIfld_set_num_rows ( FP, body_fld, row_num );

   fclose ( fp );
 
}

action write_to_file ( long *msg; char *filename )
{
FILE		*fp = NULL;
char		str[VD_ATTR_LEN], name[ATTR_NAME],
		tmpstr[VD_ATTR_LEN], AttText[VD_ATTR_LEN],
		name1[ATTR_NAME];

int		body_fld, body_width, num_rows, row, len,
		ii, jj,
		sel_flag, r_pos, start_pos, end_pos, over_write;

  *msg = MSSUCC;

  body_fld = me->body_fld;
  body_width = me->body_width;

  FIg_get_state( FP, VD_WRITE_TGL_FLD, &over_write );
  if ( !over_write )
  {
     fp = fopen(filename, "r+" );
     if ( fp != NULL )
     {
	FIg_set_text( FP, FI_MSG_FIELD, "File already exists" );
	fclose ( fp );
	*msg = MSFAIL;
	goto quit;
     }
  }

  fp = fopen(filename,"w");
  if ( fp == NULL )
  {
      sprintf( str, "Can not open file '%s' for writing", filename );
      FIg_set_text( FP, FI_MSG_FIELD, str );
      *msg = MSFAIL;
      goto quit;
  }
  else
  {
      /* print file header */
      fprintf(fp, "#QUERY_TEMPLATE\n#\t\tI/VDS\n");
      if ( me->mytype == 0 )
	fprintf(fp, "#\n#\tQuery Definitions\n#\n" );
      else
	fprintf(fp, "#\n#\tNotes Variables\n#\n" );
  }

  FIfld_get_num_rows ( FP, body_fld, &num_rows );
  for ( ii=0; ii<num_rows; ii++)
  {
	FIfld_get_text ( FP, body_fld, ii, 0, ATTR_NAME,
			 name,&sel_flag, &r_pos);
	if ( name[0] == '\0' ) continue;
	FIfld_get_text ( FP, body_fld, ii, 1, VD_ATTR_LEN, AttText, &sel_flag,
			   &r_pos);
	jj=0;
	do
	{
	    FIfld_get_text ( FP, body_fld, ii+jj+1, 0, ATTR_NAME,
						name1, &sel_flag, &r_pos);

	    FIfld_get_text ( FP, body_fld, ii+jj+1, 1, VD_ATTR_LEN,
						str, &sel_flag, &r_pos);
	    if ( name1[0] != '\0' ) break;
	    if ( name1[0] == '\0' && str[0] == '\0' ) break;
	    strcat ( AttText, " ");
	    strcat ( AttText, str );
	    jj++;
	} while ( 1 );

	ii = ii + jj;

	/* write to file */
	fprintf( fp, "%s ", name );
	len = strlen ( name );
	if ( len < 8 )
	  fprintf( fp, "\t\t\t" );
	else if ( len < 16 )
	  fprintf( fp, "\t\t" );
	else fprintf( fp, "\t" );

	row = 0;
	start_pos = 0;
	while ( 1 )
	{
	    len = strlen ( &AttText[start_pos] );
	    if ( len <= 60 )
	    {
		if ( row == 0 ) fprintf( fp, "%s\n", &AttText[start_pos] );
		else		fprintf( fp, "\t\t\t%s\n", &AttText[start_pos]);
		break;
	    }
	    else
	    {
		end_pos = 60;
		/* find position of space character */
		while ( AttText[start_pos+end_pos] != '\0' &&
			!isspace(AttText[start_pos+end_pos])  ) end_pos++;
		if ( AttText[start_pos+end_pos] == '\0' )
		{
		   if ( row == 0 ) fprintf( fp, "%s\n", &AttText[start_pos] );
		   else		   fprintf( fp, "\t\t\t%s\n",
							&AttText[start_pos] );
		   break;
		}
		else
		{ 
		   strncpy( tmpstr, &AttText[start_pos], end_pos+1 );
		   tmpstr[end_pos+1] = '\0';

		   if ( row == 0 ) fprintf( fp, "%s\n", tmpstr );
		   else		   fprintf( fp, "\t\t\t%s\n", tmpstr );


		   /* see if all the string is processed */
		   /* if ( AttText[start_pos+end_pos+1] == len ) break; */

		   start_pos = start_pos+end_pos+1;
		}
		row++;
	    }
	}

	
  } /*  for ( ii=0; ii<num_rows; ii++)  */

  fclose ( fp );
}

