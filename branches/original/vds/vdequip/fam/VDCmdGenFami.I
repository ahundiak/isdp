/* $Id: VDCmdGenFami.I,v 1.2 2002/05/14 19:58:36 jdsauby Exp $ */

/* I/VDS
 *
 * File:     vdequip/fam/VDCmdGenFamii.I
 *
 * Description:
 *      Defines a command object which command creates .f (family)
 *      and .p (part) ascii files for the loading of a VDS data base.
 *
 * Depedencies:
 *      VDCmdGenFam.S
 *      VDCmdGenFam.I
 *      VDgenfamfnc.I
 *
 * Revision History:
 *      $Log: VDCmdGenFami.I,v $
 *      Revision 1.2  2002/05/14 19:58:36  jdsauby
 *      JTSMP TR6319
 *
 *      Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/11/24  11:40:08  pinnacle
# Replaced: vdequip/fam/VDCmdGenFami.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1996/08/26  07:03:16  pinnacle
# Replaced: vdequip/fam/VDCmdGenFami.I for:  by ksundar for vds.241
#
# Revision 1.2  1996/08/09  10:13:54  pinnacle
# Replaced: vdequip/fam/VDCmdGenFami.I for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.8  1996/04/02  20:20:00  pinnacle
# Replaced: vdequip/fam/VDCmdGenFami.I for:  by yzhu for vds.240
#
# Revision 1.7  1996/04/02  19:54:06  pinnacle
# Replaced: vdequip/fam/VDCmdGenFami.I for:  by yzhu for vds.240
#
# Revision 1.5  1996/03/12  00:50:46  pinnacle
# Replaced: vdequip/fam/VDCmdGenFami.I for:  by yzhu for vds.240
#
# Revision 1.4  1996/03/01  17:34:50  pinnacle
# Replaced: vdequip/fam/VDCmdGenFami.I for:  by yzhu for vds.240
#
 *
 * History:
 *      25/02/94       Chaya Rao  Created file from ppl file VDgenfamfil.u.
 *
 *              Changed the form related to the command to give a logical
 *              workflow.  Added a new .mb file which includes prompts,
 *              messages, and status information to the command.
 *
 *	11/24.97	Changed for the CR:179701646
 */

class implementation VDCmdGenFam;

#include <string.h>

%safe
#include <VX_FIproto.h>
%endsafe

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "ACrg_collect.h"
#include "macro.h"
#include "expression.h"
#include "expmacros.h"
#include "vdsmacros.h"
#include "vdbmacros.h"
#include "VDgenfam.h"
#include "VDmsg.h"

#include "vdgenfamfil.h"		/* prototypes */
#include "FI.h"
#include "AS_status.h"
#include "PDUerror.h"

#include "v_dbgmacros.h"
#define AS_DEBUG

//#define VD_DEBUG

#include "VDdebug.h"

from ACmacro_defn	import ACgive_upscan;
from expression		import NDgive_value;
from expression		import give_formula;

extern int	unlink();

/* #define	DEBUG 1; */

#define _start 0
%safe
static  IGRchar initial_file_pre[132] = { 0 };
%endsafe

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	evaluate_input ( long *sts )
{
  /*
   * this message reads the information from the user
   * and put the information in the message field MESS2
   * which will be activated to treat that as input for
   * evaluation
   */

  int		status = OM_S_SUCCESS;
  IGRint	len;

  SetProc( evaluate_input ); Begin
  __enterMethod ( name = "evaluate_input" );

  len = strlen ( me->event1.event.keyin );

  if ( len )
  {
    /*
     * put string in MESS2 field.
     */
    FIg_set_text ( me->forms[0].form_ptr, MESS2, me->event1.event.keyin );

    /*
     * call form_notification to test the value
     */
    status = om$send (  msg	 = message VDCmdGenFam.form_notification (
								0, MESS2, 1.0,
								me->forms[0].form_ptr ),
			targetid = my_id );

    as$status ( action = RET_STATUS );
  }

  __exitMethod ( name = "evaluate_input" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	process_mac_lib ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  IGRchar	 selectLib[MAXWORD], server[MAXWORD], mesg_fld[MAXWORD];
  IGRchar	*form_ptr;

  SetProc ( process_mac_lib ); Begin
  __enterMethod ( name = "process_mac_lib" );

  /*
   * get the select text from the form a test on validation
   */
  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;
  FIg_get_text ( form_ptr, MAC_LIB, selectLib );

  /* selectlib is the selected macro library  */

  __printf ( "save_text: %s", selectLib );
  __printf ( "macro_lib_name: %s", me->macro_lib );
  __printf ( "%d", me->get_serv );

  if ( !strcmp ( selectLib, "" ) )
  {
    ex$message ( msgnumb = VD_E_NoMtchLst, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );
    ex$message ( msgnumb = VD_E_NoMtchLst );

    *sts = MSSUCC;
    __print_goto ("quit");
    goto quit;
  }

  VDreset_messages_fields ( form_ptr );

  /*
   * when selecting a new macro library, we clean-up the form to
   * restart the select criteria.
   */

  FIg_set_state_off ( form_ptr, FAMILY );

  FIg_erase ( form_ptr, PART_LIST );
  FIg_erase ( form_ptr, PART );
  FIg_erase ( form_ptr, MACRO_TEXT );
  FIg_erase ( form_ptr, MACRO);
  FIg_erase ( form_ptr, FAMILY );
  FIg_erase ( form_ptr, WRITE );
  FIg_erase ( form_ptr, LIST );
  FIg_erase ( form_ptr, APPEND );
  FIg_erase ( form_ptr, HIDDEN_FAM_LIST );
  FIg_erase ( form_ptr, HIDDEN_PART_LIST );
  FIg_erase ( form_ptr, ATT_TYP_TEXT );
  FIg_erase ( form_ptr, ATT_NAME_TEXT );
  FIg_erase ( form_ptr, ATT_CHAR_TEXT );
  FIg_erase ( form_ptr, ATT_DEF_TEXT );

  if ( me->get_serv == 1 )
  {
    strcpy ( server, "pdms_" );
    strcat ( server, selectLib );

    status = om$send (	msg	 = message VDCmdGenFam.VDgetFamilyFromServer ( sts ),
			targetid = my_id );
    as$status ( action = RET_STATUS );
    as$status ( sts = *sts, action = RET_STATUS );
  }
  else
  {
    if ( strcmp ( selectLib, me->macro_lib ) )
    {
      strcpy ( me->macro_lib, selectLib );

      __printf ( "testing library,%s", me->macro_lib );

      status = om$send ( msg	  = message VDCmdGenFam.set_macro_list ( sts ),
			 senderid = NULL_OBJID,
			 targetid = my_id );
      as$status ( sts = *sts, action = RET_STATUS );
      as$status ( action = RET_STATUS );

      __printf ( "%d", me->num_macros );

      status = om$send ( msg	  = message VDCmdGenFam.VD_fill_deflt_list ( sts ),
			 targetid = my_id );
      as$status ( action = RET_STATUS );
      as$status ( sts = *sts, action = RET_STATUS );

      /*
       * clear out the list
       */
      VDcleanup_list ( form_ptr, LIST );

      FIfld_set_active_row ( form_ptr, LIST, 0, 0 );

    }		/* if strcmp( selectLib, me->macro_lib ) */
  }

quit:

  __exitMethod ( name = "process_mac_lib" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	VD_fill_deflt_list ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  IGRchar	*form_ptr, *path, whole_path[MAXWORD], mesg_fld[MAXWORD], sttmp[MAXWORD], s_path[MAXWORD];
  FILE		*fp;
  IGRint	 j;

  SetProc( VD_fill_deflt_list ); Begin
  __enterMethod ( name = "VD_fill_deflt_list" );

*sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;
  j = 0;				/* keeps track of the num of rows in the default text
					 * of the gadget DEF_FILE
					 */
  *sts = ex$get_product_data ( in_logo = "I/VDS", config_path = &path );
  /* gets the product path */

  sprintf ( whole_path, "/bin/ls %sconfig/family > /usr/tmp/temprfile", path );

  __DBGpr_str (  " whole_path ", whole_path);

  status = system ( whole_path );

  /* Begin added for the CR:179701646 by sundar */
  status = ex$get_path ( index = 0,
			path = s_path,
			len = MAXWORD);
  __CheckRC(status, 1, "ex$get_path", quit );
  sprintf ( whole_path, "/bin/ls %s >> /usr/tmp/temprfile", s_path );
  __DBGpr_str (  " s_path ", s_path);
  __DBGpr_str (  " whole_path ", whole_path);
  status = system ( whole_path );
  /* End added for the CR:179701646 by sundar */

   
  /* displays the files in config/family and stores
   * in file /tmp/temprfile
   */

  fp = fopen ( "/usr/tmp/temprfile", "r" );
  if ( fp == NULL )
  {
    ex$message ( msgnumb = VD_E_ConfgEmty, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );
    __print_goto ("quit");
    goto quit;
  }
  else
  {
    while ( ( fscanf ( fp, "%s", sttmp ) ) != EOF )
    {
      if ( !strncmp ( sttmp, predef, 8 ) )
	/* compare if first eight characters of sttmp is equal to
	 * string predef(that is "VDGnFmFl")
	 */
      {
	FIfld_set_list_default_text ( form_ptr, DEF_FILE, j, 0, sttmp, FALSE );
	j++; //moved to here for TR6319
      }
      //j++;
    }
    FIg_set_text ( form_ptr, MESS1, "Select a default file " );
  }
  fclose ( fp ); fp = NULL ;

quit:

  __exitMethod ( name = "VD_fill_deflt_list" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	process_selected_defile ( long *sts )
{
  IGRchar	*form_ptr, mesg_fld[MAXWORD];

  SetProc( process_selected_defile ); Begin
  __enterMethod ( name = "process_selected_defile" );

  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;

  FIfld_set_text ( form_ptr, MESS1, 0, 0, "Select a macro", FALSE );
  FIfld_set_text ( form_ptr, MESS2, 0, 0, "", FALSE );
  FIg_display ( form_ptr, MACRO_TEXT );
  FIg_display ( form_ptr, MACRO );
  if ( me->num_macros == 0 )
  {
    FIg_set_text ( form_ptr, MESS1, " " );
    ex$message ( msgnumb = VD_E_NoMaFnd, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );
    ex$message ( msgnumb = VD_E_NoMaFnd );
    FIg_erase ( form_ptr, MACRO_TEXT );
    FIg_erase ( form_ptr, MACRO );
    FIg_erase ( form_ptr, LIST );
    FIg_erase ( form_ptr, WRITE );
    FIg_erase ( form_ptr, FAMILY );
    FIg_erase ( form_ptr, ATT_TYP_TEXT );
    FIg_erase ( form_ptr, ATT_NAME_TEXT );
    FIg_erase ( form_ptr, ATT_CHAR_TEXT );
    FIg_erase ( form_ptr, ATT_DEF_TEXT );

    *sts = MSSUCC;
    __print_goto ("quit");
    goto quit;
  }
  else
  {
    ex$message ( msgnumb= VD_E_MaFnd,
		 type	= "%d",
		 var	= `me->num_macros ` );
  }

quit:

  __exitMethod ( name = "process_selected_defile" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	init ( int type; char *str_ptr )
{
  int		 status = OM_S_SUCCESS;
  IGRint	 msg = 0;
  IGRlong	 sts;
  IGRchar	*ptr, name[MAXWORD];

  SetProc( init ); Begin
  __enterMethod ( name = "init" );

  unlink ( VDgen_FAM_LIST );

  /* get the design filename.
  *  get_current_filename_and_mod_env();
  */
  me->ret = MSSUCC;

  status = om$send (	msg	 = message VDS_LOCATE.init ( type, str_ptr ),
			mode	 = OM_e_wrt_message,
			targetid = my_id );
  as$status ( action = RET_STATUS );

  ex$get_cur_mod ( osnum = &me->cur_os );
  di$give_pathname ( osnum = me->cur_os, pathname = name );

  __printf ( " name: >%s< ", name );

  ptr = strrchr ( name, ':' );
  ptr = ptr ? ptr + 1 : name;
  strcpy ( me->filename, ptr );

  __printf ( " filename: >%s< ", me->filename );

  __DBGpr_str( " filename ", me->filename );

  FIf_display ( me->forms[0].form_ptr );

  me->input_row = 0;			/* initialize selected row */
  me->outfile = NULL;

  if ( ( me->outfile = fopen ( VDgen_FAM_LIST, "r" ) ) == NULL )
  {
    /*
     * No file found.
     */
    fclose ( me->outfile );

    status = om$send (	msg	 = message VDCmdGenFam.get_server ( &sts ),
			targetid = my_id );
    if ( !( status & sts & 1 ) )
    {
      if ( msg < 0 )
      {
	me->ret = MSFAIL;
	__print_goto ("wrapup");
	goto wrapup;
      }
    }
    else
    {
      fclose ( me->outfile );

      status = om$send (mode	 = OM_e_wrt_message,
			msg	 = message VDCmdGenFam.read_family_list_from_tmp ( &sts ),
			targetid = my_id );
      if ( !( status & sts & 1 ) )
      {
	me->ret = MSFAIL;
	__print_goto ("wrapup");
	goto wrapup;
      }
    }
  }

  __print_goto ("quit");
  goto quit;

wrapup:

  fclose ( me->outfile );

  __exit_error_Method ( name = "init" );

  __DBGpr_com( " error end of init" );
  End
  return ( OM_E_ABORT );

quit:

  __exitMethod ( name = "init" );
  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	form_notification ( int form_label; int gadget_label; double value; char *form_ptr )
{
  int		status = OM_S_SUCCESS;
  IGRchar	selectMac[MAXWORD], save_text[MAXWORD];
  IGRint	save_gadget, stat1, sel_flag, pos, row,	/* get active row */
		row_def, number_rows, count, position_def, position;
  IGRlong	sts;
  IGRchar	pre_supportfile[MAXWORD];

  SetProc(  form_notification ); Begin

  if (!form_ptr) {
      printf("### LOST THE FORM, quitting\n");
      goto quit;
  }

  save_gadget = gadget_label;

  me->unique_flag = TRUE;

  switch ( gadget_label )
  {
  case FI_ACCEPT:
    _put_response ( resp = EX_FORM_FINISHED );
    break;

  case FI_CANCEL:
    _put_response ( resp = EX_FORM_FINISHED );
    break;

  case MESS1:


    /* message field */

    VDreset_messages_fields ( form_ptr );
    break;

  case PART_LIST:
    VDreset_messages_fields ( form_ptr );
    me->modifyrownum = -1;
    read_part_from_part_file ( form_ptr, me->macro_name,&me->modifyrownum,
                               me->append );
    break;

  case FILE_CHECK:
    /*
     * Overwrite button
     */
    VDreset_messages_fields ( form_ptr );

    status = om$send (	msg	 = message VDCmdGenFam.write_out_family_file ( &sts ),
			targetid = my_id );
    as$status ( action = RET_STATUS );

    /* HF 01/10/95 : Missing (?!?!) >>>> break; <<<<	*/

  case FILE_QUIT:
    /*
     * Cancel button
     */
    if ( gadget_label == FILE_QUIT )
      VDreset_messages_fields ( form_ptr );

    FIg_erase ( form_ptr, FILE_CHECK );
    FIg_erase ( form_ptr, FILE_QUIT );

    FIg_enable ( form_ptr, MAC_LIB );
    FIg_enable ( form_ptr, MACRO );
    FIg_enable ( form_ptr, LIST );
    FIg_enable ( form_ptr, HIDDEN_FAM_LIST );
    FIg_enable ( form_ptr, HIDDEN_PART_LIST );
    FIg_enable ( form_ptr, FAMILY );
    FIg_enable ( form_ptr, WRITE );

    /* TR179600319 */
    FIg_get_state ( form_ptr, FAMILY, &me->family );
    break;

  case HIDE_ALL:

    /* toggle button near message field */

    VDreset_messages_fields ( form_ptr );

    FIg_get_state ( form_ptr, HIDE_ALL, &stat1 );
    if ( stat1 == 1 )
    {
      FIg_erase ( form_ptr, LIST );
      if ( me->family == 0 )
	FIg_display ( form_ptr, HIDDEN_FAM_LIST );
      else
	FIg_display ( form_ptr, HIDDEN_PART_LIST );
    }
    else
    {
      FIg_erase ( form_ptr, HIDDEN_FAM_LIST );
      FIg_erase ( form_ptr, HIDDEN_PART_LIST );
      FIg_display ( form_ptr, LIST );
    }
    break;

  case DEF_FILE:

    /* field that displays files in directory config/family
     * and lets the user select one
     */

    FIfld_get_active_row ( form_ptr, DEF_FILE, &row_def, &position_def );
    FIfld_get_text ( form_ptr, DEF_FILE, row_def, 0, 50,
		     ( unsigned char * ) me->initial_file, &sel_flag, &pos );
    FIg_set_text ( form_ptr, MESS1, " " );

    me->family = 0;

    status = om$send (	msg	 = message VDCmdGenFam.process_selected_defile ( &sts ),
			targetid = my_id );
    as$status ( action = RET_STATUS );

    /* TR179601410 */
    selectMac[0] = '\0';
    FIfld_get_text ( form_ptr, MACRO, 0, 0, 50,
                     ( unsigned char * ) selectMac, &sel_flag, &pos );
    if( selectMac[0] != '\0') {
       om$send (   msg      = message VDCmdGenFam.read_create_family (&sts ),
                   targetid = my_id );
       as$status ( action = RET_STATUS );
       as$status ( sts = sts, action = RET_STATUS );
    } 
         
    break;

  case MESS2:

    /* field for user to key in values */

    FIg_get_text ( form_ptr, MESS2, save_text );

    FIfld_get_num_rows ( form_ptr, LIST, &number_rows );
    for ( count = 0; count < number_rows; count++ )
    {
      FIfld_get_select ( form_ptr, LIST, count, 0, &sel_flag );
      if ( sel_flag == TRUE )
      {
	me->input_row = count;
	break;
      }
    }

    VD_avoid_mess2 ( form_ptr, me->family, me->get_serv, save_text, me->input_row );
    break;

  case LIST:

    /* Gadget which displays attributes,attribute types
     * and related  characteristics of attributes
     */

    VD_get_list_data ( form_ptr, me->review_only, me->family );
    break;

  case FAMILY:

    /* Family/Part toggle switch */

    VDreset_messages_fields ( form_ptr );
    FIg_get_state ( form_ptr, FAMILY, &me->family );

    /* Tr179600319: if me->family = 1 (part), disable support file field */
    if( me->family != 1 ) {
        FIg_enable(  form_ptr, DEF_FILE );
        status = om$send (msg	 = message VDCmdGenFam.process_family ( &sts ),
			targetid = my_id );
    	as$status ( action = RET_STATUS );
    }
    else {
         FIg_disable(  form_ptr, DEF_FILE );
    }     
    status = om$send (msg	 = message VDCmdGenFam.process_family ( &sts ),
			targetid = my_id );
   as$status ( action = RET_STATUS );

    break;

  case APPEND:

    /* gadget for adding part */

    VDreset_messages_fields ( form_ptr );
    FIg_get_state ( form_ptr, APPEND, &me->append );

    break;

  case WRITE:

    __DBGpr_com(" WRITE ");

    /* button for writing part or family file that is .p or .f*/
    VDreset_messages_fields ( form_ptr );

    if ( me->family == 0 )
    {
      status = om$send ( msg = message VDCmdGenFam.check_out_family_file(&sts),
			 targetid = my_id );
      as$status ( action = RET_STATUS );
    }
    else
    {
      status = om$send ( msg = message VDCmdGenFam.write_out_part_file ( &sts ),
			 targetid = my_id );
      as$status ( action = RET_STATUS );

      if (me->unique_flag == TRUE) { /* Tr 179600319 */
         status = om$send ( msg = message VDCmdGenFam.reset_parts_list_of_names 
                                   ( &sts ),
			 targetid = my_id );
         as$status ( action = RET_STATUS );
      }
    }

    break;

  case MACRO:

    /* button that displays macro/family list and lets the user select one */

    VDreset_messages_fields ( form_ptr );

    FIfld_get_active_row ( form_ptr, MACRO, &row, &position );
    FIfld_get_text ( form_ptr, MACRO, row, 0, 50,
		     ( unsigned char * ) selectMac, &sel_flag, &pos );
    status = om$send (	msg	 = message VDCmdGenFam.process_macro ( &sts, selectMac ),
			targetid = my_id );
    as$status ( action = RET_STATUS );

    break;

  case MAC_LIB:

    /* button that displays macro library list
     * and lets the user select one
     */

    status = om$send (	msg	 = message VDCmdGenFam.process_mac_lib ( &sts ),
			targetid = my_id );
    as$status ( action = RET_STATUS );

    FIg_display ( form_ptr, DEF_FILE );
    FIg_display ( form_ptr, DEF_TEXT );
    FIg_enable  ( form_ptr, DEF_FILE );

    break;
  }
quit:

  End

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	read_family_list_from_tmp ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  IGRint	 i;
  FILE		*fp;
  IGRchar	*form_ptr, *word_cou, mesg_fld[MAXWORD];

  SetProc(  read_family_list_from_tmp ); Begin
  __enterMethod ( name = "read_family_list_from_tmp" );

  /*
   * activate shell command to find the number of families.
   */
  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;
  if ( NULL == ( fp = fopen ( VDgen_FAM_LIST, "r" ) ) )
  {
    fclose ( fp ); fp = NULL ;
    ex$message ( msgnumb = VD_E_FaiWcOfFa, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );

    ex$message ( msgnumb = VD_E_FaiWcOfFa );

    FIg_set_text ( form_ptr, MESS1, "Select server from list" );
    __print_goto ("quit");
    goto quit;
  }
  else
  {
    fclose ( fp ); fp = NULL ;
    me->get_serv = 0;
    /*
     * find and allocate memery from the number of families.
     */
    word_cou = ( char * ) malloc ( 7 * sizeof ( char ) );
    me->numLines = 0;
    system ( "wc -l /tmp/VDGnFmFl.fam|cut -c'1-7'|sed 's/[	 ]*//'>/tmp/VDGnFmFl.wc" );
    fp = fopen ( FAM_NUMB, "r" );
    fgets ( word_cou, 5, fp );

    /*
     *  numLines is the number of lines in file /tmp/VDGnFmFl.fam
     *  which indicates number of families
     */
    me->numLines = atoi ( word_cou );
    fclose ( fp ); fp = NULL ;
    free ( word_cou );
    me->big_list = ( char * ) malloc ( me->numLines * MAXWORD * sizeof ( char ) );
    for ( i = 0; i < me->numLines; i++ )
    {
      fscanf ( fp, "%s", &me->big_list[i * MAXWORD] );
    }

    FIg_set_text ( form_ptr, MESS1, "Select macro library" );

    status = om$send (	mode	 = OM_e_wrt_message,
			msg	 = message VDCmdGenFam.VDgetAttachedLibraries ( sts ),
			targetid = my_id );
    if ( !( status & 1 ) )
    {
      __print_goto ("quit");
      goto quit;
    }
    __print_goto ("quit");
    goto quit;
  }
quit:

  __exitMethod ( name = "read_family_list_from_tmp" );

  End
  return OM_S_SUCCESS;
}

/* ~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	get_server ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  IGRchar	*form_ptr, mesg_fld[MAXWORD];

  SetProc(  get_server ); Begin
  __enterMethod ( name = "get_server" );

  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;

  me->get_serv = 1;
  if ( VDSverify_login () != PDM_S_SUCCESS )
  {
    /*
     * give warning to the user to log into server
     */
    ex$message ( msgnumb = VD_E_LogSerAvdDu, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );

    ex$message ( msgnumb = VD_E_LogSerAvdDu );

    /*
     * if no server, go on to macros
     */
    me->get_serv = 0;
    FIg_set_text ( me->forms[0].form_ptr, MESS1, "Select macro library" );

    status = om$send (	msg	 = message VDCmdGenFam.VDgetAttachedLibraries ( sts ),
			targetid = my_id );
    if ( !( status & 1 ) )
    {
      __print_goto ("quit");
      goto quit;
    }
  }
  else
  {
    status = om$send (	msg	 = message VDCmdGenFam.VDgetFamilyFromServer ( sts ),
			targetid = my_id );
    if ( !( status & 1 ) )
    {
      __print_goto ("quit");
      goto quit;
    }
  }

quit:

  __exitMethod ( name = "get_server" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	VDgetFamilyFromServer ( long *sts )
{
  int		  status = OM_S_SUCCESS;
  IGRint	  num, i;
  IGRchar	**tab, *form_ptr, mesg_fld[MAXWORD];
  FILE		 *fp;

  SetProc ( VDgetFamilyFromServer ); Begin
  __enterMethod ( name = "VDgetFamilyFromServer" );

  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;

  ex$message ( msgnumb = VD_E_Process );
  ex$message ( msgnumb = VD_E_GetFaTabFrmDb, buff = mesg_fld );
  FIg_set_text ( form_ptr, MESS2, mesg_fld );
  ex$message ( msgnumb = VD_E_GetFaTabFrmDb );

  __prints ( "executing VdsRisSelect" );

  /*
   * read the information from the tables and write the result
   * in the temporary file.
   */

  num = 0;
  tab = NULL;

  status = vdb$RisSelect (	select		= "n_tablename",
				table_name	= "nfmtables",
				where		= "n_tablename like 'y_%'",
				order		= "n_tablename",
				group		= NULL,
				numselect	= 1,
				p_numrows	= &num,
				p_buffer	= &tab );
  as$status ( action = RET_STATUS );

  fp = NULL;
  if ( NULL == ( fp = fopen ( VDgen_FAM_LIST, "w" ) ) )
  {
    for ( i = 0; i < num; i++ )
    {
      fprintf ( fp, "%s\n", &tab[i][2] );
    }
    fclose ( fp ); fp = NULL ;
  }

  __prints ( "executed VdsRisSelect" );

  status = vdb$RisFreeBuffer ( buffer = tab, size = num );
  as$status ( action = RET_STATUS );

  status = om$send (	msg	 = message VDCmdGenFam.read_family_list_from_tmp ( sts ),
			targetid = my_id );
  if ( !( status & *sts & 1 ) )
  {
    printf ( "error in om$send\n" );
  }

  FIg_set_text ( me->forms[0].form_ptr, MESS2, "" );

  __exitMethod ( name = "VDgetFamilyFromServer" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	delete ( int f_defer_flag )
{
  int	status = OM_S_SUCCESS;

  SetProc( delete ); Begin
  __enterMethod ( name = "delete" );

  /*
   * execute the standard delete procedure.
   */
  status = om$send ( msg	= message VDS_LOCATE.delete ( f_defer_flag ),
		     targetid	= my_id,
		     mode	= OM_e_wrt_message );
  as$status ( action = RET_STATUS );

  UI_status ( " " );			/* reset status field */

  /* free memory allocated */
  if ( me->big_list != NULL )
    free ( me->big_list );
  if ( me->big_parts_list != NULL )
    free ( me->big_parts_list );
  if ( me->big_rev_list != NULL )
    free ( me->big_rev_list );
  if ( me->listing != NULL )
    free ( me->listing );

  __exitMethod ( name = "delete" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	VDget_macro_objid ( long *sts )
{
  int		  status = OM_S_SUCCESS;
  DIgrid	 *objs;
  IGRchar	**list, txt[MAXWORD], txt1[MAXWORD], txt2[MAXWORD], formula[120];
  IGRint	  ele_count, i;
  double	  value;

  SetProc( VDget_macro_objid ); Begin
  __enterMethod ( name = "VDget_macro_objid" );

  *sts = MSSUCC;
  objs = NULL;
  list = NULL;

  sprintf ( txt, ":%s:constructs_lib:", me->filename );

  if ( strcmp ( me->macro_lib, "." ) == 0 )
  {
    sprintf ( txt2, ":%s:constructs:", me->filename );
  }
  else
  {
    sprintf ( txt2, "%s%s:constructs:", txt, me->macro_lib );
  }

  __printf ( "filename  %s", me->filename );
  __printf ( "macro_lib %s", me->macro_lib );

  ele_count = 0;

  status = di$find (	start_dir	= txt2,
			lines		= &list,
			grids		= &objs,
			ptr		= &ele_count,
			max_level	= 1,
			deep		= NULL,
			options		= OPT_LEVEL );
  as$status ();

  for ( i = 0; i < ele_count; i++ )
  {
    status = di$split ( pathname	= list[i],
			dirname		= NULL,
			name		= txt1 );
    as$status ();

    if ( !strcmp ( me->macro_name, txt1 ) )
    {
      me->macro_id.objid = ( GRobjid ) objs[i].objid;
      me->macro_id.osnum = ( GRspacenum ) objs[i].osnum;
      __print_goto ("quit");
      goto quit;
    }
  }

  strcat ( txt2, me->macro_name );
  strcat ( txt2, "$def" );

  status = di$find (	start_dir	= txt2,
			lines		= &list,
			grids		= &objs,
			ptr		= &ele_count,
			max_level	= 1,
			deep		= NULL,
			options		= OPT_LEVEL );
  as$status ();

  for ( i = 0; i < ele_count; i++ )
  {
    status = om$get_classname ( objid	  = objs[i].objid,
				osnum	  = objs[i].osnum,
				classname = formula );

    if ( !strcmp ( formula, "Gexp" ) )
    {
      status = om$send ( msg	  = message expression.NDgive_value ( &value ),
			 targetos = objs[i].osnum,
			 targetid = objs[i].objid );
    }
    else if ( !strcmp ( formula, "Gtext_exp" ) )
    {
      status = om$send ( msg	  = message expression.give_formula ( formula ),
			 targetos = objs[i].osnum,
			 targetid = objs[i].objid );
    }
  }

quit:

  __exitMethod ( name = "VDget_macro_objid" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	VDgetAttachedLibraries ( long *sts )
{
  int		  status = OM_S_SUCCESS;
  IGRint	  i;
  IGRchar	**list, txt1[MAXWORD], mesg_fld[MAXWORD], txt[MAXWORD], *form_ptr;
  DIint		  count;

  SetProc( VDgetAttachedLibraries ); Begin
  __enterMethod ( name = "VDgetAttachedLibraries" );

  /*
   * create path in sub-directory subsystem to check the
   * attached libraries in the file.
   *
   * TO DO:
   *      See if local library is used and check macros.
   */
  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;

  sprintf ( txt, ":%s:constructs_lib:", me->filename );

  count = 0;
  list = NULL;

  di$find (	start_dir	= txt,
		lines		= &list,
		ptr		= &count,
		max_level	= 1,
		deep		= NULL,
		options		= OPT_LEVEL );
  as$status ();

  if ( count == 0 )
  {
    ex$message ( msgnumb = VD_E_NoMaLibfnd, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );

    ex$message ( msgnumb = VD_E_NoMaLibfnd );
    __print_goto ("quit");
    goto quit;
  }
  else
  {
    ex$message ( msgnumb = VD_E_MaLibFnd,
		 type	 = "%d",
		 var	 = count );
  }

  FIfld_set_list_num_rows ( me->forms[0].form_ptr, MAC_LIB, 0, 0 );
  FIfld_set_list_num_rows ( me->forms[0].form_ptr, MAC_LIB, 0, count + 1 );
  FIg_set_text ( me->forms[0].form_ptr, MAC_LIB, "" );

  for ( i = 0; i < count; i++ )
  {
    txt1[0] = '\0';

    status = di$split ( pathname = list[i],
			dirname	 = NULL,
			name	 = txt1 );
    as$status ();

    __printf ( " Split[%d]: >%s< >%s< ", `status, list[i], txt1` );

    /* ptr = strrchr(txt1,'/');
     ptr = ptr ? ptr+1 : txt1 ; */

    FIfld_set_list_default_text ( me->forms[0].form_ptr, MAC_LIB, i, 0, txt1, FALSE );
  }

  /*
   *  add internal library to list
   */
  FIfld_set_list_num_rows ( me->forms[0].form_ptr, MAC_LIB, 0, count + 1 );
  FIfld_set_list_default_text ( me->forms[0].form_ptr, MAC_LIB, count, 0,
				".", FALSE );

quit:

  __exitMethod ( name = "VDgetAttachedLibraries" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	set_macro_list ( long *sts )
{
  int			  status = OM_S_SUCCESS;
  IGRchar		  txt[MAXWORD], txt2[MAXWORD], newtxt[MAXWORD];
  IGRint		  i, l, k, skip, tot_up, prop, count;
  IGRchar		**list, txt1[MAXWORD];
  struct digrid		 *grobjs;
  struct sup		 *xdup;
  DIint			  ele_count;

  SetProc( set_macro_list ); Begin
  __enterMethod ( name = "set_macro_list" );

  *sts = MSSUCC;
  list = NULL;
  ele_count = 0;
  k = 0;

  sprintf ( txt, ":%s:constructs_lib:", me->filename );

  if ( strcmp ( me->macro_lib, "." ) == 0 )
  {
    sprintf ( txt2, ":%s:constructs:", me->filename );
  }
  else
  {
    sprintf ( txt2, "%s%s:constructs:", txt, me->macro_lib );
  }

  __printf ( "macro_lib in set_macro_list, %s", txt2 );

  status = di$find (	start_dir	= txt2,
			lines		= &list,
			grids		= &grobjs,
			ptr		= &ele_count,
			max_level	= 1,
			options		= OPT_LEVEL );
  as$status ();

  FIfld_set_list_num_rows ( me->forms[0].form_ptr, MACRO, 0, 0 );
  FIfld_set_text ( me->forms[0].form_ptr, MACRO, 0, 0, "", FALSE );

  for ( i = 0; i < ele_count; i++ )
  {
    status = om$send (	msg	 = message ACmacro_defn.ACgive_upscan (
						   &tot_up, &prop, &xdup ),
			senderid = NULL_OBJID,
			targetid = grobjs[i].objid,
			targetos = grobjs[i].osnum );
    as$status ();

    if ( !tot_up )
      continue;
    if ( !strcmp ( xdup[0].prompt, "~rep" ) )
    {
      /*
       * if  prompt and ~rep are equal.
       */
      strcpy ( txt1, list[i] );

      status = di$split ( pathname = list[i],
			  dirname  = NULL,
			  name	   = txt1 );
      as$status ();

      __printf ( "macro name test ,%s", txt1 );

      /* get the macro$def files out */

      if ( strchr ( txt1, '$' ) != NULL )
      {
	/*
	 * check the name against the list of pdu families
	 */

	skip = 0;

	for ( l = 0; l < me->numLines; l++ )
	{
	  if ( !strcmp ( &me->big_list[l * MAXWORD], txt1 ) )
	    skip = 1;
	}

	if ( skip == 1 )
	{
	  skip = 0;
	}

	FIfld_set_list_num_rows ( me->forms[0].form_ptr, MACRO, 0,
				  k + 1 );
	count = 0;
	while ( txt1[count] != '$' )
	{
	  newtxt[count] = txt1[count];
	  count++;
	}
	newtxt[count] = '\0';

	FIfld_set_list_default_text ( me->forms[0].form_ptr, MACRO,
				      k, 0, newtxt, FALSE );
	k++;
      }
    }
  }
  me->num_macros = k;

  __exitMethod ( name = "set_macro_list" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	process_macro ( IGRlong * sts; IGRchar * selectMac )
{
  int		 status = OM_S_SUCCESS;
  IGRchar	*form_ptr;

  SetProc( process_macro ); Begin
  __enterMethod ( name = "process_macro" );

  *sts = MSSUCC;
  /*
   * process a found macro name
   */
  strcpy ( me->macro_name, selectMac );

  /*
   * reset the form for further use.
   */
  form_ptr = me->forms[0].form_ptr;

  FIg_set_text ( form_ptr, MESS1, "" );
  FIg_set_state_off ( form_ptr, FAMILY );

  FIg_erase ( form_ptr, WRITE );
  FIg_erase ( form_ptr, LIST );
  FIg_erase ( form_ptr, APPEND );
  FIg_erase ( form_ptr, HIDDEN_FAM_LIST );
  FIg_erase ( form_ptr, HIDDEN_PART_LIST );
  FIg_erase ( form_ptr, ATT_DEF_TEXT );
  FIg_erase ( form_ptr, PART_LIST );
  FIg_enable ( form_ptr, DEF_FILE );

  if ( !strcmp ( me->macro_name, "" ) )
  {
    FIg_erase ( form_ptr, FAMILY );
    FIg_erase ( form_ptr, ATT_TYP_TEXT );
    FIg_erase ( form_ptr, ATT_NAME_TEXT );
    FIg_erase ( form_ptr, ATT_CHAR_TEXT );
  }
  else
  {
    status = om$send (	msg	 = message VDCmdGenFam.VDget_macro_objid ( sts ),
			targetid = my_id );
    as$status ( action = RET_STATUS );
    as$status ( sts = *sts, action = RET_STATUS );

    om$send (	msg	 = message VDCmdGenFam.read_create_family ( sts ),
		targetid = my_id );
    as$status ( action = RET_STATUS );
    as$status ( sts = *sts, action = RET_STATUS );

    /*
     * display the found part/family
     */
    FIg_display ( form_ptr, LIST );
    FIg_display ( form_ptr, FAMILY );
    FIg_display ( form_ptr, ATT_TYP_TEXT );
    FIg_display ( form_ptr, ATT_NAME_TEXT );
    FIg_display ( form_ptr, ATT_CHAR_TEXT );
    FIg_display ( form_ptr, ATT_DEF_TEXT );
  }

  __exitMethod ( name = "process_macro" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	read_create_family ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  IGRchar	 macro_filename	[MAXWORD],
		 w_char		[MAXWORD],
		 s1		[MAXWORD],
		 tmp		[MAXWORD],
		 Latt		[MAXWORD],	/* t */
		 Lnam		[MAXWORD],	/* n */
		 Ldef		[MAXWORD],	/* d */
		 Ltype		[MAXWORD],	/* p */
		 mesg_fld	[MAXWORD],	/* message string */
		*form_ptr;
  IGRint	 i, j, h, pfile, k, word_count, row_no, tot_up, prop;
  FILE		*fp;
  struct sup	*xdup;
  IGRint	 num, sel_flag, pos;
  IGRchar	 t[50], n[50], d[50], p[50], output_string[MAXWORD], mname[14];

  SetProc( read_create_family ); Begin
  __enterMethod ( name = "read_create_family" );

  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;

  me->review_only = FALSE;
  strcpy ( macro_filename, me->macro_name );
  strcat ( macro_filename, ".p" );


  pfile = FALSE;
  fp = fopen ( macro_filename, "r" );
  if ( fp == NULL )
  {
    pfile = TRUE;
    FIg_display ( form_ptr, WRITE );
    FIg_set_text ( form_ptr, MESS1, "No parts are defined" );
  }
  else
  {
    FIg_erase ( form_ptr, WRITE );
    me->review_only = TRUE;
    ex$message ( msgnumb = VD_E_FaFilRw, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );

    ex$message ( msgnumb = VD_E_FaFilRw );
  }

  fclose ( fp ); fp = NULL ;

  /*
   * clear out the list
   */

  VDcleanup_list ( form_ptr, LIST );

  /*
   * clear out the hidden family list
   */

  VDcleanup_list ( form_ptr, HIDDEN_FAM_LIST );

  tot_up = 0;
  strcpy ( macro_filename, me->macro_name );
  strcat ( macro_filename, ".f" );

  fp = NULL;
  fp = fopen ( macro_filename, "r" );
  __DBGpr_str( " macro_filename ",   macro_filename);
 
  /* tr179601410 if ( fp == NULL ) */
  /* For tr 179602624 if ( fp == NULL || pfile == TRUE  ) */

  if ( fp == NULL )
  {

    __DBGpr_com( " fp == NULL ");
    /*
     * tot_up indicates that we are working with a new
     * file.
     */
    tot_up = 1;
    fclose ( fp ); fp = NULL ;

    __DBGpr_str( " initial_file ",  me->initial_file);
    __DBGpr_str( " SUB_PATH     ",   SUB_PATH);

    vd$openfile ( file_name	= me->initial_file,
		  sub_path	= SUB_PATH,
		  cur_dir	= TRUE,
		  p_file	= &fp );

    if ( fp == NULL )
    {
      /* Begin changed for the CR:179701646 by sundar */ 
      IGRchar s_path[MAXWORD], sup_file[MAXWORD];
    
      status = ex$get_path ( index = 0,
				path = s_path,
				len = MAXWORD);
      __CheckRC(status, 1, "ex$get_path", quit );
      sprintf (sup_file,"%s%s", s_path, me->initial_file);
      fp = fopen ( sup_file, "r" );

      if ( fp == NULL ) {
         strcpy ( s1, "cannot open file: " );
         strcat ( s1, macro_filename );
         strcat ( s1, "\n" );
         FIg_set_text ( form_ptr, MESS1, s1 );

         *sts = MSFAIL ;
         __print_goto ("quit");
         goto quit;
      }
      /* End changed for the CR:179701646 by sundar */ 
    }

    /*
     * count the number of lines in the default files.
     */
    word_count = 0;
    while ( 1 )
    {
      fgets ( w_char, MAXWORD, fp );

      __printf ( "count[%d]: %s", `word_count, w_char` );

      word_count++;
      if ( w_char[0] == ']' )
	break;
    }
    fclose ( fp ); fp = NULL ;

    vd$openfile ( file_name	= me->initial_file,
		  sub_path	= SUB_PATH,
		  cur_dir	= TRUE,
		  p_file	= &fp );

    /* Begin added for the CR:179701646 by sundar */
    if ( fp == NULL )
    {
	IGRchar s_path[MAXWORD], sup_file[MAXWORD];
	
	status = ex$get_path ( index = 0,
				path = s_path,
				len = MAXWORD);
	__CheckRC(status, 1, "ex$get_path", quit );
	__DBGpr_str( " s_path     ",   s_path);
	sprintf (sup_file,"%s%s", s_path, me->initial_file);
	fp = fopen ( sup_file, "r" );
	if (fp == NULL ) {
		FIg_set_text ( form_ptr, MESS1, "Cannot open Support File" );
		*sts = MSFAIL ;
		__print_goto ("quit");
		goto quit;
	}
    }
    /* End added for the CR:179701646 by sundar */

    /* tr179601410 */
    if(strcmp(initial_file_pre, me->initial_file)){
        FIg_set_text ( form_ptr, MESS2,
                 "Support file is changed, please overwrite the family file" );
    
/*	initial_file_pre[0]='\0';
	strcpy(initial_file_pre, me->initial_file); 
*/
    }
  }
  else
  {
    word_count = 0;
    while ( 1 )
    {
      /* fgets ( w_char, MAXWORD, fp ); For 179602375 */
      if ( fgets ( w_char, MAXWORD, fp ) == NULL ){
                char str[1024] ;
                sprintf(str, "The Family File %s is incomplete\n", macro_filename);
		FIg_set_text ( form_ptr, MESS2, str );
                UI_status(str);
                *sts = MSFAIL ;
                goto quit ;
      }

      word_count++;
      if ( w_char[0] == ']' )
	break;
    }
    fclose ( fp ); fp = NULL ;
    fp = fopen ( macro_filename, "r" );
  }

  /*
   * allocate memory to store the file information to handle in
   * later use.
   */

  if ( me->listing != NULL )
  {
    free ( me->listing );
    me->listing = NULL;
  }
  me->listing = ( char * ) malloc ( word_count * MAXWORD * sizeof ( char ) );

  /*
   * read the VDGnFmFl.def and store in instance
   */
  __printf ( " word_count : %d", word_count );

  __DBGpr_int(" word_count ", word_count );
  i = 0;
  while ( 1 )
  {
    fgets ( &( me->listing[i * MAXWORD] ), MAXWORD, fp );

    __printf ( "Read[%d]: %s", `i, &( me->listing[i * MAXWORD] )` );

    i++;
    if ( me->listing[( i - 1 ) * MAXWORD] == ']' )
      break;
  }

  fclose ( fp ); fp = NULL ;

  /*
   * if tot_up == 1 : we have to store in a new file the family
   *		    information .
   */
  if ( tot_up == 1 )
  {
    me->retmsg = VD_pars_line ( &me->listing[1 * MAXWORD], Latt, Lnam, Ltype, Ldef );
    VD_post_line ( &me->listing[1 * MAXWORD], "", Lnam, Ltype, me->macro_name, me->family );
    me->retmsg = VD_pars_line ( &me->listing[3 * MAXWORD], Latt, Lnam, Ltype,
				Ldef );
    if ( strcmp ( me->macro_lib, "." ) == 0 )
    {
      VD_post_line ( &me->listing[3 * MAXWORD], "", Lnam, Ltype, me->filename, me->family );
    }
    else
    {
      VD_post_line ( &me->listing[3 * MAXWORD], "", Lnam, Ltype, me->macro_lib, me->family );
    }
  }

  me->retmsg = VD_pars_line ( &me->listing[2 * MAXWORD], Latt, Lnam, Ltype, Ldef );

  __prints ( " -----BEFORE FORMS OF k" );

/*  FIfld_set_num_rows( form_ptr, HIDDEN_FAM_LIST, i-1 ); TR179600319 */
  FIfld_set_num_rows( form_ptr, HIDDEN_FAM_LIST, i-2 );
  FIfld_set_num_rows( form_ptr, LIST, word_count );
    __DBGpr_com(  " for LIST ");
    __DBGpr_str(  " Lnam ", Lnam);
    __DBGpr_str(  " Ltype ", Ltype);
    __DBGpr_str(  " Ldef ", Ldef);
  FIfld_set_text ( form_ptr, LIST, 0, 0, "", FALSE );
  FIfld_set_text ( form_ptr, LIST, 0, 1, Lnam, FALSE );
  FIfld_set_text ( form_ptr, LIST, 0, 2, Ltype, FALSE );
  FIfld_set_text ( form_ptr, LIST, 0, 3, Ldef, FALSE );
  FIfld_set_text ( form_ptr, LIST, 0, 4, "1", FALSE );


  __prints ( "BEFORE LOOP OF k" );
  __DBGpr_com (" BEFORE LOOP OF k" );
  h = 1;
  for ( k = 1; k < i - 1; k++ )
  {
    me->retmsg = VD_pars_line ( &me->listing[k * MAXWORD], Latt, Lnam, Ltype, Ldef );
    if ( ( tot_up == 1 ) &&
	 ( strcmp ( Latt, "" ) != 0 ) &&
	 ( strcmp ( Lnam, "" ) != 0 ) )
    {
      __prints ( "we are creating a new family and I found the pipe" );

      break;
    }

    row_no = k - 1;
    __DBGpr_int(  "  row_no ",  row_no);
    __DBGpr_str(  " Latt ", Latt);
    __DBGpr_str(  " Lnam ", Lnam);
    __DBGpr_str(  " Ltype ", Ltype);
    __DBGpr_str(  " Ldef ", Ldef);

    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 0, Latt, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 1, Lnam, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 2, Ltype, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 3, Ldef, FALSE );

    /*
     * if type is a static attribute
     */
    if ( strncmp ( Latt, "p_s", 3 ) == 0 )
    {
      if ( strcmp ( Lnam, "units_set" ) == 0 )
	continue;

      FIfld_set_text ( form_ptr, LIST, h, 0, "static", FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 1, Lnam, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 2, Ltype, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 3, Ldef, FALSE );

      sprintf ( tmp, "%d", ( k - 1 ) );
      FIfld_set_text ( form_ptr, LIST, h, 4, tmp, FALSE );

      h++;
    }
    else if ( strncmp ( Latt, "p_c", 3 ) == 0 )
    {
      /*
       * if type is a dynamic attribute
       */

      FIfld_set_text ( form_ptr, LIST, h, 0, "dynamic", FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 1, Lnam, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 2, Ltype, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 3, Ldef, FALSE );

      sprintf ( tmp, "%d", ( k - 1 ) );
      FIfld_set_text ( form_ptr, LIST, h, 4, tmp, FALSE );

      h++;
    }
  }

  if ( tot_up == 0 )
  {
    /* skip macro info since we read macro.f */
    __print_goto ("quit");
    __DBGpr_com( " tot_up == 0");
    goto quit;
  }

  me->num_cpts = 0;
  me->num_cpts = VDcheck_for_cpt ( &me->macro_id );

  j = 1;
  row_no = k - 2 + j;
    __DBGpr_int(  "  row_no ",  row_no);
  FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 0, "p_s1", FALSE );
  FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 1, "units_set", FALSE );
  FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 2, "smallint", FALSE );
  FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 3, "units_set", FALSE );

  if ( me->num_cpts > 0 )
  {
    __DBGpr_com( " me->num_cpts > 0 ");

    for ( j = 2; j < me->num_cpts + 2; j = j + 1 )
    {
      strcpy ( Ldef, "cp" );
      sprintf ( tmp, "%d", ( j - 2 ) );
      strcat ( Ldef, tmp );
      strcpy ( Latt, "p_o" );
      sprintf ( tmp, "%d", j );
      strcat ( Latt, tmp );

      row_no = k - 2 + j;
    __DBGpr_int(  "  row_no ",  row_no);
    __DBGpr_str(  " Latt ", Latt);
    __DBGpr_str(  " Lnam ", Lnam);
    __DBGpr_str(  " Ltype ", Ltype);
    __DBGpr_str(  " Ldef ", Ldef);
      FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 0, Latt, FALSE );
      FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 1, Ldef, FALSE );
      FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 2, "macro", FALSE );
      FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 3, Ldef, FALSE );
    }
    me->num_cpts++;
  }

  tot_up = 0;
  status = om$send (	msg	 = message ACmacro_defn.ACgive_upscan (
							 &tot_up,
							 &prop,
							 &xdup ),
			senderid = NULL_OBJID,
			targetos = me->macro_id.osnum,
			targetid = me->macro_id.objid );
  as$status ();

  h = 1;
  __DBGpr_com( "after ACmacro_defn.ACgive_upscan ");

  for ( j = 1; j < tot_up; j++ )
  {
    strcpy ( Ldef, xdup[j].prompt );
    strcpy ( Lnam, xdup[j].prompt );

    if ( xdup[j].type == 256 )
    {
      sprintf ( Latt, "p_d%d", ( j + me->num_cpts ) );
      strcpy ( Ltype, "referential" );
    }
    else if ( xdup[j].type == 65552 )
    {
      sprintf ( Latt, "p_c%d", ( j + me->num_cpts ) );
      strcpy ( Ltype, "double" );
      FIfld_set_text ( form_ptr, LIST, h, 0, "dynamic", FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 1, Lnam, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 2, Ltype, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 3, Lnam, FALSE );
      sprintf ( tmp, "%d", ( k - 2 + j + me->num_cpts ) );
      FIfld_set_text ( form_ptr, LIST, h, 4, tmp, FALSE );
      h++;
    }
    else if ( xdup[j].type == 131088 )
    {
      sprintf ( Latt, "p_c%d", ( j + me->num_cpts ) );
      strcpy ( Ltype, "char[80]" );
      FIfld_set_text ( form_ptr, LIST, h, 0, "dynamic", FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 1, Lnam, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 2, Ltype, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 3, Lnam, FALSE );
      sprintf ( tmp, "%d", ( k - 2 + j + me->num_cpts ) );
      FIfld_set_text ( form_ptr, LIST, h, 4, tmp, FALSE );
      h++;
    }
    else if ( xdup[j].type == 8192 )
    {
      sprintf ( Latt, "p_d%d", ( j + me->num_cpts ) );
      strcpy ( Ltype, "curve" );
    }
    else
    {
      sprintf ( Latt, "p_d%d", ( j + me->num_cpts ) );
      strcpy ( Ltype, "generic" );
    }

    __DBGpr_str(  " Latt ", Latt);
    __DBGpr_str(  " Lnam ", Lnam);
    __DBGpr_str(  " Ltype ", Ltype);
    __DBGpr_str(  " Ldef ", Ldef);
    row_no = k - 2 + j + me->num_cpts;
    __DBGpr_int(  "  row_no ",  row_no);
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 0, Latt, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 1, Lnam, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 2, Ltype, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 3, Lnam, FALSE );
  }

  __DBGpr_com ( " k < i - 1; k++ ");
  for ( ; k < i - 1; k++ )
  {
    me->retmsg = VD_pars_line ( &me->listing[k * MAXWORD],
				Latt, Lnam, Ltype, Ldef );
    row_no = k - 2 + j + me->num_cpts;
    __DBGpr_int( "  row_no ",  row_no);
    __DBGpr_str(  " Latt ", Latt);
    __DBGpr_str(  " Lnam ", Lnam);
    __DBGpr_str(  " Ltype ", Ltype);
    __DBGpr_str(  " Ldef ", Ldef);
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 0, Latt, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 1, Lnam, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 2, Ltype, FALSE );
    FIfld_set_text ( form_ptr, HIDDEN_FAM_LIST, row_no, 3, Ldef, FALSE );

    if ( strncmp ( Latt, "p_s", 3 ) == 0 )
    {
      FIfld_set_text ( form_ptr, LIST, h, 0, "static", FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 1, Lnam, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 2, Ltype, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 3, Ldef, FALSE );
      sprintf ( tmp, "%d", ( k - 1 + me->num_cpts ) );
      FIfld_set_text ( form_ptr, LIST, h, 4, tmp, FALSE );
      h++;
    }
    else if ( strncmp ( Latt, "p_c", 3 ) == 0 )
    {
      FIfld_set_text ( form_ptr, LIST, h, 0, "dynamic", FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 1, Lnam, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 2, Ltype, FALSE );
      FIfld_set_text ( form_ptr, LIST, h, 3, Ldef, FALSE );
      sprintf ( tmp, "%d", ( k - 1 + me->num_cpts ) );
      FIfld_set_text ( form_ptr, LIST, h, 4, tmp, FALSE );
      h++;
    }
  }

quit:

  __exitMethod ( name = "read_create_family" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	process_family ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  IGRchar	*form_ptr;
  IGRchar	 title[MAXWORD], mesg_fld[MAXWORD];

  SetProc( process_family ); Begin
  __enterMethod ( name = "process_family" );

  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;
  me->retmsg = 0;

  if ( me->family == 0 )
  {
    FIg_erase ( form_ptr, ATT_DEF_TEXT );
    FIg_set_text ( form_ptr, ATT_DEF_TEXT, "Synonym" );
    FIg_display ( form_ptr, ATT_DEF_TEXT );

    status = om$send (	msg	 = message VDCmdGenFam.VDget_macro_objid ( sts ),
			targetid = my_id );
    as$status ( action = RET_STATUS );
    as$status ( sts = *sts, action = RET_STATUS );

    om$send (	msg	 = message VDCmdGenFam.read_create_family ( sts ),
		targetid = my_id );
    as$status ( action = RET_STATUS );
    as$status ( sts = *sts, action = RET_STATUS );
    FIg_erase ( form_ptr, APPEND );
    FIg_erase ( form_ptr, PART );
    FIg_erase ( form_ptr, PART_LIST );
  }
  else
  {
    ex$message ( msgnumb = VD_E_ChkAtrErr, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );
    ex$message ( msgnumb = VD_E_ChkAtrErr );

    UI_status ( " " );

    me->retmsg = VD_check_for_reserved_words ( form_ptr, me->error_msg );
    if ( me->retmsg == MSFAIL )
    {
      sprintf ( me->buffer_msg, "Errors found ,%s", me->error_msg );
      ex$message ( msgnumb = VD_M_VDGnFmFl, buff = title );
      EX_error_box ( FI_CURRENT_SCREEN, me->buffer_msg, title );
      FIg_set_state_off ( form_ptr, FAMILY );

      me->family = 0;
    }
    else
    {
      me->retmsg = MSSUCC;

      status = om$send (msg	 = message VDCmdGenFam.read_create_part ( sts ),
			targetid = my_id );
      as$status ( action = RET_STATUS );

      if ( me->retmsg == MSSUCC && *sts != MSFAIL )
      {
	FIg_erase ( form_ptr, ATT_DEF_TEXT );
	FIg_set_text ( form_ptr, ATT_DEF_TEXT, "Default" );
	FIg_display ( form_ptr, ATT_DEF_TEXT );
	FIg_display ( form_ptr, APPEND );
      }
      else
	me->family = 0;
    }
  }

  __exitMethod ( name = "process_family" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	read_create_part ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  IGRchar	 err[MAXWORD], macro_filename[MAXWORD];
  IGRchar	*form_ptr;
  FILE		*fp;

  SetProc( read_create_part ); Begin
  __enterMethod ( name = "read_create_part" );

  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;

  FIg_display ( form_ptr, WRITE );

  strcpy ( macro_filename, me->macro_name );
  strcat ( macro_filename, ".f" );

  fp = NULL;
  fp = fopen ( macro_filename, "r" );
  if ( fp == NULL )
  {
    sprintf ( err, "file not found: %s -> write out the file displayed", macro_filename );
    FIfld_set_text ( form_ptr, MESS1, 0, 0, err, FALSE );
    fclose ( fp ); fp = NULL ;
    FIg_set_state_off ( form_ptr, FAMILY );
    me->retmsg = 0;
    *sts = MSFAIL;
    __print_goto ("quit");
    goto quit;
  }
  fclose ( fp ); fp = NULL ;

  strcpy ( macro_filename, me->macro_name );
  strcat ( macro_filename, ".p" );

  fp = NULL ;
  fp = fopen ( macro_filename, "r" );
  if ( fp == NULL )
  {
    sprintf ( err, "file not found: %s -> we will create it", macro_filename );
    FIfld_set_text ( form_ptr, MESS1, 0, 0, err, FALSE );

    fclose ( fp ); fp = NULL ;

    VD_set_up_part_list ( form_ptr, me->macro_name, me->macro_lib, me->filename );
  }
  else
  {
    fclose ( fp ); fp = NULL ;

    VD_set_up_part_list ( form_ptr, me->macro_name, me->macro_lib, me->filename );

    status = om$send (	msg	 = message VDCmdGenFam.reset_parts_list_of_names ( sts ),
			targetid = my_id );
    as$status ( action = RET_STATUS );
    as$status ( sts = *sts, action = RET_STATUS );
  }

  *sts = MSSUCC;

quit:

  __exitMethod ( name = "read_create_part" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	reset_parts_list_of_names ( long *sts )
{
  IGRint	 m, h, i, part_list_num_rows;
  IGRchar	 p[MAXWORD], sttmp[MAXWORD], macro_filename[MAXWORD];
  FILE		*fp;
  IGRchar	*form_ptr;

  SetProc( reset_parts_list_of_names ); Begin

  __enterMethod ( name = "reset_parts_list_of_names" );

  *sts = MSSUCC;

  form_ptr = me->forms[0].form_ptr;

  me->num_parts = 0;
  strcpy ( macro_filename, me->macro_name );
  strcat ( macro_filename, ".p" );
  if ( ( fp = fopen ( macro_filename, "r" ) ) == NULL )
  {
    fclose ( fp ); fp = NULL ;
    __print_goto ("quit");
    goto quit;
  }
  while ( TRUE )
  {
    if ( fgets ( p, MAXWORD, fp ) == NULL )
      break;
    if ( p[0] == ']' )
      me->num_parts++;
  }
  fclose ( fp ); fp = NULL ;

  fp = fopen ( macro_filename, "r" );
  if ( me->big_parts_list != NULL )
  {
    free ( me->big_parts_list );
    me->big_parts_list = NULL;
  }
  if ( me->big_rev_list != NULL )
  {
    free ( me->big_rev_list );
    me->big_rev_list = NULL;
  }

  me->big_parts_list = ( char * ) malloc ( me->num_parts * 32 * sizeof ( char ) );
  me->big_rev_list   = ( char * ) malloc ( me->num_parts * 32 * sizeof ( char ) );

  m = 0;
  while ( TRUE )
  {
    if ( fgets ( p, MAXWORD, fp ) == NULL )
      break;

    /*
     * check if string is -> n_itemname
     */
    if ( strncmp ( p, PDM6, strlen ( PDM6 ) ) == 0 )
    {
      for ( h = strlen ( PDM6 ) + 2; h < strlen ( p ) - 2; h++ )
      {
	me->big_parts_list[( m * 32 ) + h - ( strlen ( PDM6 ) + 2 )] = p[h];
      }
      me->big_parts_list[( m * 32 ) + h - ( strlen ( PDM6 ) + 2 )] = '\0';

      if ( me->num_parts != 1 )
      {
	sprintf ( sttmp, "There are %d parts defined ", me->num_parts );
      }
      else
	strcpy ( sttmp, "There is 1 part defined " );

      FIfld_set_text ( form_ptr, MESS1, 0, 0, sttmp, FALSE );
    }
    else if ( strncmp ( p, PDM5, strlen ( PDM5 ) ) == 0 )
    {
      for ( h = ( strlen ( PDM5 ) + 2 ); h < strlen ( p ) - 2; h++ )
      {
	me->big_rev_list[( m * 32 ) + h - ( strlen ( PDM5 ) + 2 )] = p[h];
      }
      me->big_rev_list[( m * 32 ) + h - ( strlen ( PDM5 ) + 2 )] = '\0';

    }
    if ( p[0] == ']' )
      m++;
  }

  fclose ( fp ); fp = NULL ;

  if ( me->num_parts > 0 )
  {
    FIfld_set_text ( form_ptr, PART_LIST, 0, 0, &me->big_parts_list[0 * 32], FALSE );
    FIfld_get_list_num_rows ( form_ptr, PART_LIST, 0, &part_list_num_rows );
    FIfld_set_list_num_rows ( form_ptr, PART_LIST, 0, me->num_parts );

    for ( i = 0; i < me->num_parts; i++ )
      FIfld_set_list_default_text ( form_ptr, PART_LIST, i, 0, &me->big_parts_list[i * 32], FALSE );
    for ( i = me->num_parts; i < part_list_num_rows; i++ )
      FIfld_set_list_default_text ( form_ptr, PART_LIST, i, 0, "", FALSE );

    FIg_display ( form_ptr, PART );
    FIg_display ( form_ptr, PART_LIST );
    FIg_display ( form_ptr, APPEND );
  }
  else
  {
    FIg_erase ( form_ptr, PART );
    FIg_erase ( form_ptr, PART_LIST );
    FIg_erase ( form_ptr, APPEND );
  }

quit:

  __exitMethod ( name = "reset_parts_list_of_names" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	write_out_part_file ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  IGRint	 num, j, i, overide =0;
  IGRchar	 t[50], n[50], d[50], p[50], r[50], output_string[MAXWORD], mname[MAXWORD];
  IGRint	 hh, tmp_num_rows, number_rows, sel_flag, pos;
  FILE		*tempfile, *fp;
  IGRchar	*form_ptr, sttmp[MAXWORD];
  IGRint         row_def = -1, position_def =0;  

  SetProc( write_out_part_file ); Begin
  __enterMethod ( name = "write_out_part_file" );

  /*
   * Find the part name and revision in the form and put it in p and r
   */

  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;

  FIfld_get_num_rows ( form_ptr, HIDDEN_PART_LIST, &tmp_num_rows );

  for ( hh = 0; hh < tmp_num_rows; hh++ )
  {
    FIfld_get_text ( form_ptr, HIDDEN_PART_LIST, hh, 1, 50,
		     ( unsigned char * ) p, &sel_flag, &pos );
    if ( strcmp ( p, PDM6 ) == 0 )
    {
      FIfld_get_text ( form_ptr, HIDDEN_PART_LIST, hh, 3, 50,
		       ( unsigned char * ) p, &sel_flag, &pos );
      break;
    }
  }

  for ( hh = 0; hh < tmp_num_rows; hh++ )
  {
    FIfld_get_text ( form_ptr, HIDDEN_PART_LIST, hh, 1, 50,
		     ( unsigned char * ) r, &sel_flag, &pos );
    if ( strcmp ( r, PDM5 ) == 0 )
    {
      FIfld_get_text ( form_ptr, HIDDEN_PART_LIST, hh, 3, 50,
		       ( unsigned char * ) r, &sel_flag, &pos );
      break;
    }
  }

  if ( !strcmp ( p, "" ) || !strcmp ( r, "" ) )
  {
    FIg_set_text ( form_ptr, MESS1, "Part Number and Revision are required" );
    __print_goto ("quit");
    goto quit;
  }

  for ( j = 0; j < me->num_parts; j++ )
  {
/*  modify for TR179600319  big_parts_list and big_rev_list should be 32 
    inteval instead of MAXWORD=132
    if ( ( strcmp ( p, &me->big_parts_list[j * MAXWORD] ) == 0 ) &&
	 ( strcmp ( r, &me->big_rev_list[j * MAXWORD] ) == 0 ) )
*/
    if ( ( strcmp ( p, &me->big_parts_list[j * 32] ) == 0 ) &&
	 ( strcmp ( r, &me->big_rev_list[j * 32] ) == 0 ) )
    {

/*    TR 179600319   
      FIg_set_text ( form_ptr, MESS1,
		     "Part Number and Revision are not unique" );
*/
      if ( me->append == 0 )
      {
	*sts = MSSUCC;
  
        FIg_set_text ( form_ptr, MESS1,
		     "Part Number and Revision are not unique" );
        me->unique_flag = FALSE;
	__print_goto ("quit");
	goto quit;
      }
      else
      {
        /* TR179600319: if j != me->modifyrownum, it will duplicate part
           This case happen when modify a part to have same part number
           and version number with other existing part
        */  
        if ( j == me->modifyrownum ) {
	    FIg_set_text ( form_ptr, MESS2, "Changing existing part" );
            overide = 1;
	    break;
        }
        else {
	    FIg_set_text ( form_ptr, MESS2, 
               "Can not change existing part due to duplication" );
            overide = 2;
	    break;
        }
      }
    }
  }

  /*  overide = 0;
  overide = ( j == me->num_parts ) ? 1 : 0;
  */

  i = j;

  /* TR 179600319, set i = me->modifyrownum, to allow user to modify the part
      name or version 
  */
  if(  me->append !=0 ) {
    i = me->modifyrownum;
    if ( i == -1 ) {
      FIfld_set_text ( form_ptr, MESS2, 0, 0, 
        "No part is modified!, Select the part from Parts List first", FALSE );
    }

  }
  strcpy ( mname, me->macro_name );
  strcat ( mname, ".p" );

  fp = NULL;
  fp = fopen ( mname, "r" );
  if ( fp != NULL )
  {

    /* iTR 179600319 : if the part name or version is changed, the pirevious
     code will produce new part
     if ( me->append == 0 || overide == 1 )
    */
    if ( me->append == 0 )
    {
      fclose ( fp ); fp = NULL ;

      fp = fopen ( mname, "a" );
      fputs ( "[\n", fp );
    }
    else if ( i != -1 && overide != 2)
    {
      /* overide == 2, will duplicate the part due to modify part with same
         part number and version number 
      */ 
      status = ex$message ( msgnumb = VD_E_Process );

      tempfile = NULL;
      tempfile = fopen ( "/tmp/part_file", "w" );

      /* tr179600319 duplicated [:  fputs ( "[\n", tempfile ); */

      /*
       * overwrite  the existing part
       */

      FIfld_get_num_rows ( form_ptr, HIDDEN_PART_LIST, &number_rows );

      /* for parts before modified part */
      j = 0;
      for ( j = 0; j < i * ( number_rows + 2 ) + 1; j++ )
      {
	fgets ( sttmp, MAXWORD, fp );
	num = fputs ( sttmp, tempfile );
      }

      /* for  part */
      for ( j = 0; j < number_rows; j++ )
      {
	FIfld_get_text ( form_ptr, HIDDEN_PART_LIST,
			 j, 0, 50, ( unsigned char * ) t, &sel_flag, &pos );
	FIfld_get_text ( form_ptr, HIDDEN_PART_LIST,
			 j, 1, 50, ( unsigned char * ) n, &sel_flag, &pos );
	if ( !strcmp ( n, "" ) )
	{
	  break;
        }	

	FIfld_get_text ( form_ptr, HIDDEN_PART_LIST,
			 j, 2, 50, ( unsigned char * ) d, &sel_flag, &pos );
	FIfld_get_text ( form_ptr, HIDDEN_PART_LIST,
			 j, 3, 50, ( unsigned char * ) p, &sel_flag, &pos );
	if ( strncmp ( d, "char[", 5 ) == 0 &&
	     strcmp ( n, NFM1 ) != 0 )
	{
	  strcpy ( sttmp, "'" );
	  strcat ( sttmp, p );
	  strcat ( sttmp, "'" );
	}
	else
	  strcpy ( sttmp, p );

	VD_post_line ( output_string, "", n, "", sttmp, me->family );

	num = fputs ( output_string, tempfile );

	fgets ( sttmp, MAXWORD, fp );
      }

      /* for  part after modified parts*/

      while ( TRUE )
      {
	if ( fgets ( sttmp, MAXWORD, fp ) == NULL )
	  break;
	num = fputs ( sttmp, tempfile );
      }

      fclose ( tempfile ); tempfile = NULL ;
      fclose ( fp ); fp = NULL ;

      strcpy ( sttmp, "cp /tmp/part_file " );
      strcat ( sttmp, mname );
      system ( sttmp );

      FIfld_set_text ( form_ptr, MESS1, 0, 0, "", FALSE );
      FIfld_set_text ( form_ptr, MESS2, 0, 0, "", FALSE );

      *sts = MSSUCC;
      __print_goto ("quit");
      goto quit;
    }
    else {
      *sts = MSSUCC;
      __print_goto ("quit");
      goto quit;
    } 
  }
  else
  {
    fclose ( fp ); fp = NULL ;

    fp = fopen ( mname, "w" );
    fputs ( "[\n", fp );
  }

  FIfld_get_num_rows ( form_ptr, HIDDEN_PART_LIST, &num );
  for ( j = 0; j < num; j++ )
  {
    FIfld_get_text ( form_ptr, HIDDEN_PART_LIST, j, 0, 50,
		     ( unsigned char * ) t, &sel_flag, &pos );
    FIfld_get_text ( form_ptr, HIDDEN_PART_LIST, j, 1, 50,
		     ( unsigned char * ) n, &sel_flag, &pos );
    if ( !strcmp ( n, "" ) )
      break;

    FIfld_get_text ( form_ptr, HIDDEN_PART_LIST, j, 2, 50,
		     ( unsigned char * ) d, &sel_flag, &pos );
    FIfld_get_text ( form_ptr, HIDDEN_PART_LIST, j, 3, 50,
		     ( unsigned char * ) p, &sel_flag, &pos );

    if ( strncmp ( d, "char[", 5 ) == 0 &&
	 strcmp ( n, NFM1 ) != 0 )
    {
      sprintf ( sttmp, "'%s'", p );
    }
    else
      strcpy ( sttmp, p );

    VD_post_line ( output_string, "", n, "", sttmp, me->family );

    fputs ( output_string, fp );
  }

  fputs ( "]\n", fp );
  fclose ( fp ); fp = NULL ;

quit:

  __exitMethod ( name = "write_out_part_file" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	check_out_family_file ( long *sts )
{
  int		 status = OM_S_SUCCESS;
  FILE		*fp;
  IGRchar	mname[14], mesg_fld[MAXWORD];
  IGRchar	*form_ptr;

  SetProc( check_out_family_file ); Begin
  __enterMethod ( name = "check_out_family_file" );

  *sts = MSSUCC;
  form_ptr = me->forms[0].form_ptr;

  strcpy ( mname, me->macro_name );
  strcat ( mname, ".f" );

  __DBGpr_str( " file name ",  mname);
  fp = NULL;
  fp = fopen ( mname, "r" );
  if( fp == NULL) 
    __DBGpr_com(" fp = NULL ");

  if ( fp != NULL )
  {
    __DBGpr_com( " fp != NULL ");
    ex$message ( msgnumb = VD_E_FaFilExsts, buff = mesg_fld );
    FIg_set_text ( form_ptr, MESS2, mesg_fld );

    ex$message ( msgnumb = VD_E_FaFilExsts );

    fclose ( fp ); fp = NULL ;

    FIg_set_text ( form_ptr, MESS2, "Select Overwrite or Cancel" );

    /*
     * to force the user to select either "override" or "cancel"
     * we disable all other gadgets.
     */

    FIg_disable ( form_ptr, MAC_LIB );
    FIg_disable ( form_ptr, MACRO );
    FIg_disable ( form_ptr, LIST );
    FIg_disable ( form_ptr, HIDDEN_FAM_LIST );
    FIg_disable ( form_ptr, HIDDEN_PART_LIST );
    FIg_disable ( form_ptr, FAMILY );
    FIg_disable ( form_ptr, WRITE );

    FIg_set_state_off ( form_ptr, FILE_QUIT );
    FIg_set_state_off ( form_ptr, FILE_CHECK );
    FIg_display ( form_ptr, FILE_CHECK );
    FIg_display ( form_ptr, FILE_QUIT );

    FIg_set_text ( form_ptr, MESS1, "" );
    FIg_set_text ( form_ptr, MESS2, "" );

    *sts = MSSUCC;
    __print_goto ("quit");
    __DBGpr_com( " quit ");
    goto quit;
  }

  fclose ( fp ); fp = NULL ;
  fp = NULL ;

  status = om$send (	msg	 = message VDCmdGenFam.write_out_family_file ( sts ),
			targetid = my_id );
  as$status ( action = RET_STATUS );

quit:

  __exitMethod ( name = "check_out_family_file" );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method	write_out_family_file ( long *sts )
{
  FILE		*fp;
  IGRint	 num, j, sel_flag, pos;
  IGRchar	 t[50], n[50], d[50], p[50], output_string[MAXWORD], mname[14];
  IGRchar	*form_ptr;

  SetProc( write_out_family_file ); Begin
  __enterMethod ( name = "write_out_family_file" );

  __DBGpr_int( " MAXWORD ", MAXWORD);
  form_ptr = me->forms[0].form_ptr;

  *sts = MSSUCC;

  strcpy ( mname, me->macro_name );
  strcat ( mname, ".f" );

  __DBGpr_str( "file name" , mname); 
  fp = NULL;
  fp = fopen ( mname, "w" );

  if( fp == NULL) 
    __DBGpr_com(" fp = NULL ");

  fputs ( "[\n", fp );

  FIfld_get_num_rows ( form_ptr, HIDDEN_FAM_LIST, &num );
 
  __DBGpr_int( " num ", num);

  for ( j = 0; j < num; j++ )
  {
    __DBGpr_int( " j =  ", j);
    FIfld_get_text ( form_ptr, HIDDEN_FAM_LIST, j, 0, 50,
		     ( unsigned char * ) t, &sel_flag, &pos );
    FIfld_get_text ( form_ptr, HIDDEN_FAM_LIST, j, 1, 50,
		     ( unsigned char * ) n, &sel_flag, &pos );
    FIfld_get_text ( form_ptr, HIDDEN_FAM_LIST, j, 2, 50,
		     ( unsigned char * ) d, &sel_flag, &pos );
    FIfld_get_text ( form_ptr, HIDDEN_FAM_LIST, j, 3, 50,
		     ( unsigned char * ) p, &sel_flag, &pos );

    __DBGpr_str( " t = ", t);
    __DBGpr_str( " n = ", n);
    __DBGpr_str( " d = ", d);
    __DBGpr_str( " p = ", p);
    VD_post_line ( output_string, t, n, d, p, me->family );

    fputs ( output_string, fp );

    __DBGpr_str( " output_string ", output_string);
    __DBGpr_int( " j =  ", j);
    
  }

  fputs ( "]\n", fp );

  fclose ( fp ); fp = NULL ;

  /* tr 179601410 */
  initial_file_pre[0]='\0';
        strcpy(initial_file_pre, me->initial_file);



  __exitMethod ( name = "write_out_family_file" );
  End 
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDCmdGenFam;
