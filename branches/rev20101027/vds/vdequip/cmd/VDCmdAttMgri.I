/* $Id: VDCmdAttMgri.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $ pinnacle */
/* -------------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdequip/com / VDCmdAttMgri.I
 *
 * Description:
 *
 *	Command object for the management of the attributes in a form.
 *	The attributes are stored in 3 ACrg_coll (static, dynamic and user).
 *
 *	The instances need to be initialised by the subclasses.
 *
 *
 * Dependencies:
 *
 *      VDS_LOCATE
 *
 * Revision History:
 *	$Log: VDCmdAttMgri.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1997/10/30  22:15:22  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/03/20  21:04:42  pinnacle
# Replaced: vdequip/cmd/VDCmdAttMgri.I by tdumbach r#
#
# Revision 1.2  1995/02/16  19:49:34  pinnacle
# Replaced: vdequip/cmd/VDCmdAttMgri.I by jwfrosch r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *	12/01/93	P. Lacroix	Creation date
 *	10/30/97	ah		UnInit references
 * -------------------------------------------------------------------------
 */

class implementation VDCmdAttMgr;

#include <string.h>
#include <ctype.h>
#include <math.h>
#include "SMmsg.h"
#include "coparadef.h"
#include "coparamac.h"

#include "dpdef.h"
#include "vardef.h"

#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "FI.h"

#include "VDSequipdef.h"
#include "AS_status.h"
#include "VDSeqpfidef.h"
#include "vdsfimacros.h"
#include "VDmacdef.h"
#include "VDGadgDef.h"
#include "VDSLocateDef.h"

//#define VD_DEBUG

#include "VDdebug.h"

/*+fi
 -------------------------------------------------------------------------
  Internal Function VDFindIndexAtt

  Abstract
	This function looks for the given name in a list.

  Returns
	1 if the name has been found.
	0 otherwise.

 -------------------------------------------------------------------------
*/

int VDIsInStringArray
(
  char	 *name,			/* [I] name to find in the array	*/
  char	**StrArray,		/* [I] array of names where to search	*/
  int	  nb_inlist		/* [I] nb elements in the array		*/
)
/*
-fi */
{
  int	i;

  __enterFunction ( name = "VDIsInStringArray" );

  __printf ( "name = <%s>", name );

  for ( i = 0; i < nb_inlist && StrArray ; i++ )
  {
    if ( strcmp ( name, StrArray[i] ) == 0 )
    {
      __exitFunction  ( name = "VDIsInStringArray" );
      return 1;
    }
  }
  __exit_error_Function  ( name = "VDIsInStringArray" );
  return 0;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
 	form_notification from CEO

  Abstract

 CEO.form_notification is called whenever a I/Forms form is given input
 by the user.  It is analogous to super_cmd.form_input(); however, no input
 is present in the "value" argument if the gadget type is a field.  See the
 I/Forms Forms documentation about querying a form's gadgets to get their
 values.

 It has been overriden to implement the selection of a part in the database.

  Arguments

  int    	form_label;  	label of form which received user  input
  int    	gadget_label;   gadget label  which received user  input
  double 	value;          value of gadget ( or field row # )
  char 		* form_ptr ;    ptr to I/Forms form which received input

 -------------------------------------------------------------------------
-mo*/

method form_notification
(
  int		 form_label;
  int		 label;
  double	 value;
  char		*fp
)
{
  IGRlong	 msg;
  int		 state;
  IGRchar	 my_message[80];

  __enterMethod ( name = "form_notification" );

  if ( label == FI_RESET || label == me->GadgToggle )
  {
    om$send ( msg	= message VDCmdAttMgr.VDSelectTog ( &msg ),
	      targetid	= my_id );
    if ( !( msg & 1 ) )
      printf ( "ERROR VDSelectTog\n" );
  }
  else if ( label == FI_EXECUTE )
  {
    /* Nothing to save if static att */

    FIg_get_state ( me->form_att_ptr, me->GadgToggle, &state );
    if ( state == 1 )
    {
      om$send ( msg	 = message VDCmdAttMgr.VDSaveListDyn ( &msg, my_message ),
		targetid = my_id );
    }
    if ( !( msg & 1 ) )
    {
      __exit_error_Method  ( name = "form_notification" );
      return OM_S_SUCCESS;
    }
    FIg_set_state_off ( me->form_att_ptr, FI_EXECUTE );
  }
  else
  {
    if ( label == me->StatDynFld || label == me->UserFld )
      me->g_list = label;

    om$send ( msg	= message VDS_LOCATE.form_notification (
							form_label,
							label,
							value,
							fp ),
	      mode	= OM_e_wrt_message,
	      targetid	= my_id );
  }

  __exitMethod  ( name = "form_notification" );

  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	init_all from VDS_LOCATE

  Abstract
	That method initialise the instances.
	It has been overriden in order to initialise my instances.

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

method init_all ( long * sts )
{
  *sts = OM_S_SUCCESS;

  __enterMethod ( name = "init_all" );

  om$send ( msg		= message VDS_LOCATE.init_all ( sts ),
	    targetid	= my_id,
	    mode	= OM_e_wrt_message );

  me->static_att	= NULL;
  me->dynamic_att	= NULL;
  me->user_att		= NULL;

  me->nb_static = me->nb_dynamic = me->nb_user = 0;
  me->UserFld	= -1;			/* we need to know if it has been defined */

  me->NonDsp	= NULL;
  me->nb_NonDsp	= 0;

  me->form_att_ptr = NULL;

  *sts = OM_S_SUCCESS;

  __exitMethod  ( name = "init_all" );
  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	delete_all from VDS_LOCATE

  Abstract
	That method is called at the delete of the command. It basically
	free all the allocated arrays.

	It has been overriden to free my own instances.

  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

method delete_all ( long * sts )
{
  int	i;

  __enterMethod ( name = "delete_all" );

  *sts = OM_S_SUCCESS;

  if ( me->static_att )
  {
    free ( me->static_att );
    me->static_att = NULL;
  }
  if ( me->dynamic_att )
  {
    free ( me->dynamic_att );
    me->dynamic_att = NULL;
  }
  if ( me->user_att )
  {
    free ( me->user_att );
    me->user_att = NULL;
  }
  if ( me->NonDsp )
  {
    for ( i = 0; i < me->nb_NonDsp; i++ )
    {
      free ( me->NonDsp[i] );
      me->NonDsp[i] = NULL;
    }
    free ( me->NonDsp );
    me->NonDsp = NULL;
  }

  __exitMethod  ( name = "delete_all" );

  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	verify_input_row from VDS_LOCATE

  Abstract

      Verify the user input in the given label field.

      It has been overriden to use my me->StatDynFld and me->UserFld
      gadgets.

  Arguments
	long 		*sts		O	Completion code
        char    	*form_ptr       I       form pointer
        int     	label           I       gadget label where to verify

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

method verify_input_row
(
  long	*sts;
  char	*form_ptr;
  int	 label
)
{
  char		my_msg[80];
  int		sel, col, pos, row;
  unsigned char	val_txt[ATTR_TXT], attr_type[ATTR_TXT], name[ATTR_TXT];
  IGRdouble	val_db;

  __enterMethod ( name = "verify_input_row" );

  *sts = OM_S_SUCCESS;

  FImcf_get_active_col	( form_ptr, label, &col, &pos );
  FIfld_get_active_row	( form_ptr, label, &row, &pos );
  FIfld_get_text	( form_ptr, label, row, col, ATTR_TXT, val_txt, &sel, &pos );

  switch ( col )
  {
  case GI_NAM:				/* attribute name */

    break;

  case GI_TYP:				/* attribute type */

    switch ( val_txt[0] )
    {
    case 'd':
    case 'D':
      FIfld_set_text ( form_ptr, label, row, col, "db", 0 );
      break;
    case 't':
    case 'T':
      FIfld_set_text ( form_ptr, label, row, col, "txt", 0 );
      break;

    case '\0':
      break;

    default:
      FIfld_set_text ( form_ptr, label, row, col, "txt", 0 );
      break;
    }
    break;

  case GI_VAL:				/* attribute value */

    name[0] = '\0';

    /* Attribute name not defined : suppress row */

    FIfld_get_text ( form_ptr, label, row, GI_NAM, ATTR_TXT, name, &sel, &pos );

    if ( name[0] == '\0' && row > 0 )
    {
      FIfld_pos_cursor  ( form_ptr, label, row - 1, 0, 0, 0, 0, 0 );
      FIfld_delete_rows ( form_ptr, label, row, 1 );
      break;
    }

    /* Nothing in field : quit */

    if ( val_txt[0] == '\0' )
      break;

    /* Control or set type of attribut */

    FIfld_get_text ( form_ptr, label, row, GI_TYP, ATTR_TXT, attr_type, &sel, &pos );

    if ( SMget_double ( form_ptr, label, row, GI_VAL, &val_db ) )
    {
      if ( attr_type[0] == '\0' )
	FIfld_set_text ( form_ptr, label, row, GI_TYP, "db", 0 );
    }
    else if ( attr_type[0] == '\0' )
      FIfld_set_text ( form_ptr, label, row, GI_TYP, "txt", 0 );
    else if ( attr_type[0] == 'd' )
    {
      ex$message ( msgnumb	= SM_E_CmBadValAttr, buff = my_msg,
		   type		= "%s"		   , var  = `name ` );

      FIg_set_text ( form_ptr, FI_MSG_FIELD, my_msg );
    }
    break;
  }

  *sts = OM_S_SUCCESS;

  __exitMethod  ( name = "verify_input_row" );
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDSetAttList

  Abstract
	Set the appropriate list of attributes in the form depending
	on the type:
			type = 0 for static attributes
 			type = 1 for dynamic
 			type = 2 for users

	It Takes into account the non displayable attributes.

  Arguments

   long 		* sts		O: Completion code
   IGRint		type		I: 0 = static, 1=dynamic, 2=user

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method VDSetAttList
(
  long		*sts; 	/* (O) Completion code 		   */
  IGRint	 type	/* (I) 0=static, 1=dynamic, 2=user */
)
{
  int			 i, row, col, field, nb_att;
  struct ACrg_coll	*ACrg;
  char			 txt_val[ATTR_TXT];

  __enterMethod ( name = "VDSetAttList" );

  // Init to get rid of warnings
  nb_att = 0;
  field  = 0;
  ACrg   = NULL;

  FIfld_set_active_row ( me->form_att_ptr, me->StatDynFld, 0, 0 );

  *sts = OM_S_SUCCESS;

  /* display the right field in the form and set its editing mode */

  switch ( type )
  {
  case 0:				/* static */

    nb_att	= me->nb_static;
    ACrg	= me->static_att;
    field	= me->StatDynFld;
    for ( col = 0; col < NUM_COL_ATT; col++ )
      FIfld_set_mode ( me->form_att_ptr, field, col, FI_REVIEW );

    break;

  case 1:				/* dynamic */

    nb_att	= me->nb_dynamic;
    ACrg	= me->dynamic_att;
    field	= me->StatDynFld;
    for ( col = 0; col < NUM_COL_ATT; col++ )
      FIfld_set_mode ( me->form_att_ptr, field, col, FI_APPEND );

    /* if a user field is defined, that means the dynamic are	*/
    /* isolated from the user -> don't allow to change their	*/
    /* name and type.						*/

    if ( me->UserFld >= 0 )
    {
      for ( col = 0; col < NUM_COL_ATT - 1; col++ )
	FIfld_set_mode ( me->form_att_ptr, field, col, FI_REVIEW );
    }
    break;

  case 2:				/* user */

    nb_att	= me->nb_user;
    ACrg	= me->user_att;
    field	= me->UserFld;
    for ( col = 0; col < NUM_COL_ATT; col++ )
      FIfld_set_mode ( me->form_att_ptr, field, col, FI_APPEND );
    break;
  }

  /* put the attributes in the field, if they are not in the	*/
  /* non_displayable list.					*/

  row = 0;
  for ( i = 0; i < nb_att; i++ )
  {
    if ( VDIsInStringArray ( ACrg[i].name, me->NonDsp, me->nb_NonDsp ) )
      continue;

    FIfld_set_text ( me->form_att_ptr, field, row, GI_NAM, ACrg[i].name, 0 );

    if ( ACrg[i].desc.type == AC_ATTRIB_DOUBLE )
    {
      sprintf ( txt_val, "%g", ACrg[i].desc.value.att_exp );
      FIfld_set_text ( me->form_att_ptr, field, row, GI_TYP, "db", 0 );
      FIfld_set_text ( me->form_att_ptr, field, row, GI_VAL, txt_val, 0 );
    }
    else
    {
      FIfld_set_text ( me->form_att_ptr, field, row, GI_TYP, "txt", 0 );
      FIfld_set_text ( me->form_att_ptr, field, row, GI_VAL,
		       ACrg[i].desc.value.att_txt, 0 );
    }
    row++;
  }
  FIfld_set_num_rows ( me->form_att_ptr, field, row );

  *sts = OM_S_SUCCESS;

  __exitMethod  ( name = "VDSetAttList" );
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDSaveListDyn

  Abstract
 	Save the dynamic and user attributes displayed in the form
	into the instances.

  Arguments

   long 		* sts		O: Completion code
   IGRchar 		* my_message	O: message info

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method VDSaveListDyn
(
  long		*sts; 	/* (O)	Completion code */
  IGRchar	*my_msg	/* (O)	message info    */
)
{
  IGRchar		 name[ATTR_TXT], val_txt[ATTR_TXT], type_txt[ATTR_TXT];
  int			 i_att, num_rows, row, sel, pos;
  IGRdouble		 val_db;
  int			 buf_nb_att, type;
  struct ACrg_coll	*buf_att = NULL;

  __enterMethod ( name = "VDSaveListDyn" );

  *sts = OM_S_SUCCESS;
  my_msg[0] = '\0';

  /* ---
  	update the values of the dynamic attributes (the number of attributes
	 and their names cannot have changed )
   --- */

  row = 0;

  for ( i_att = 0; i_att < me->nb_dynamic; i_att++ )
  {
    /* don't take into account the non displayable attributes */

    if ( VDIsInStringArray ( me->dynamic_att[i_att].name,
			     me->NonDsp,
			     me->nb_NonDsp ) )
      continue;

    FIfld_get_text ( me->form_att_ptr, me->StatDynFld, row, GI_NAM, ATTR_TXT,
		     name, &sel, &pos );

    if ( me->dynamic_att[i_att].desc.type == AC_ATTRIB_DOUBLE )
    {
      if ( !SMget_double ( me->form_att_ptr,
			   me->StatDynFld,
			   row,
			   GI_VAL,
			   &val_db ) )
      {
	ex$message ( msgnumb	= SM_E_CmBadValAttr,
		     buff	= my_msg,
		     type	= "%s",
		     var	= `name ` );
	__print_goto ("wrapup");
	goto wrapup;
      }
      else
	me->dynamic_att[i_att].desc.value.att_exp = val_db;
    }
    else
    {
      FIfld_get_text ( me->form_att_ptr, me->StatDynFld, row,
		       GI_VAL, ATTR_TXT, val_txt, &sel, &pos );
      strcpy ( me->dynamic_att[i_att].desc.value.att_txt, val_txt );
    }
    row++;
  }

  /* Now, save the user attributes */

  FIfld_get_num_rows ( me->form_att_ptr, me->UserFld, &num_rows );

  buf_att = ( struct ACrg_coll * ) malloc ( num_rows * sizeof ( struct ACrg_coll ) );
  if ( !buf_att )
  {
    printf ( "Not enough memory\n" );
    __print_goto ("wrapup");
    goto wrapup;
  }

  buf_nb_att = 0;

  for ( row = 0; row < num_rows; row++ )
  {
    FIfld_get_text ( me->form_att_ptr, me->UserFld, row, GI_NAM, ATTR_TXT,
		     name, &sel, &pos );

    FIfld_get_text ( me->form_att_ptr, me->UserFld, row, GI_VAL, ATTR_TXT,
		     val_txt, &sel, &pos );

    FIfld_get_text ( me->form_att_ptr, me->UserFld, row, GI_TYP, ATTR_TXT,
		     type_txt, &sel, &pos );

    if ( name[0] == '\0' )
    {
      if ( val_txt[0] == '\0' && type_txt[0] == '\0' )
	continue;
      else
      {
	ex$message ( msgnumb	= SM_E_CmNeedAttName, buff = my_msg,
		     type	= "%d"		    , var  = `row ` );
	__print_goto ("wrapup");
	goto wrapup;
      }
    }

    switch ( type_txt[0] )
    {
    case 'd':
    case 'D':
      type = AC_ATTRIB_DOUBLE;
      break;
    case 't':
    case 'T':
      type = AC_ATTRIB_TEXT;
      break;
    default:
      ex$message ( msgnumb = SM_E_CmBadAttType, buff = my_msg,
		   type    = "%s"	      , var  = `name ` );
      __print_goto ("wrapup");
      goto wrapup;
    }

    if ( type == AC_ATTRIB_DOUBLE &&
	 !SMget_double ( me->form_att_ptr, me->UserFld, row, GI_VAL, &val_db ) )
    {
      ex$message ( msgnumb = SM_E_CmBadValAttr, buff = my_msg,
		   type    = "%s"	      , var  = `name ` );
      __print_goto ("wrapup");
      goto wrapup;
    }

    if ( !SMSetAttr ( name, buf_att, NULL, &buf_nb_att,
		      type, val_db, val_txt, 0, NB_MAX_USER_ATT ) )
    {
      printf ( "Error saving attributes %s\n", name );
      __print_goto ("wrapup");
      goto wrapup;
    }

  }

  if ( me->user_att )
  {
    free ( me->user_att );
    me->user_att = NULL;
  }
  me->user_att = ( struct ACrg_coll * ) malloc ( buf_nb_att * sizeof ( struct ACrg_coll ) );
  if ( !me->user_att )
  {
    printf ( "Not enough memory\n" );
    __print_goto ("wrapup");
    goto wrapup;
  }

  memcpy ( me->user_att, buf_att, buf_nb_att * sizeof ( struct ACrg_coll ) );
  me->nb_user = buf_nb_att;

  __exitMethod  ( name = "VDSaveListDyn" );

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;

wrapup:

  if ( buf_att )
  {
    free ( buf_att );
    buf_att = NULL;
  }
  *sts = OM_E_ABORT;

  __exit_error_Method  ( name = "VDSaveListDyn" );
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDSelectTog

  Abstract
	Called when the toggle static/dynamic is changing state.
	It displays the good list of attributes (static or dynamic)
	in the form.

  Arguments

   long 		* sts		O: Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method VDSelectTog( long *sts)
{
  int	state;

  __enterMethod ( name = "VDSelectTog" );

  *sts = OM_S_SUCCESS;

  /* put the instances in the form (state = 0 static) */

  FIg_get_state ( me->form_att_ptr, me->GadgToggle, &state );

  if ( state == 0 )
  {
    FIg_set_text ( me->form_att_ptr, FI_MSG_FIELD,
		   "Warning, the dynamic attributes are not saved" );

    om$send ( msg	= message VDCmdAttMgr.VDSetAttList ( sts, 0 ),
	      targetid	= my_id );

    FIg_erase ( me->form_att_ptr, me->UserFld );
    FIg_display ( me->form_att_ptr, me->StatDynFld );
  }
  else
  {
    /* display the UserFld */

    om$send ( msg	= message VDCmdAttMgr.VDSetAttList ( sts, 1 ),
	      targetid	= my_id );

    om$send ( msg	= message VDCmdAttMgr.VDSetAttList ( sts, 2 ),
	      targetid	= my_id );

    FIg_display ( me->form_att_ptr, me->StatDynFld );
    FIg_display ( me->form_att_ptr, me->UserFld );
  }

  __exitMethod  ( name = "VDSelectTog" );

  return OM_S_SUCCESS;
}

end implementation VDCmdAttMgr;
