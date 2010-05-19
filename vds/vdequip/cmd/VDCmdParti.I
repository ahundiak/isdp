/* $Id: VDCmdParti.I,v 1.1.1.1 2001/01/04 21:08:42 cvs Exp $ pinnacle */
/* -------------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdequip/com / VDCmdParti.I
 *
 * Description:
 *
 *	Command object for the management of the selection of a part
 *	in the database, using a form.
 *
 *	The instances need to be initialised by the subclasses.
 *
 *
 * Dependencies:
 *
 *      CEO
 *
 * Revision History:
 *	$Log: VDCmdParti.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:42  cvs
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
# Revision 1.3  1996/04/03  11:49:36  pinnacle
# Replaced: vdequip/cmd/VDCmdParti.I for:  by ksundar for vds.240
#
# Revision 1.2  1995/02/16  19:51:12  pinnacle
# Replaced: vdequip/cmd/VDCmdPart* by jwfrosch r#
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
 *
 * -------------------------------------------------------------------------
 */

class implementation VDCmdPart;

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "SMmsg.h"
#include "coparadef.h"
#include "coparamac.h"
#include "PDUerror.h"

#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "DIdef.h"
#include "vardef.h"

#include "acdef.h"
#include "PDUerror.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "FI.h"

#include "AS_status.h"
#include "VDGadgDef.h"
#include "VDSutil.h"

#include "vdsmacros.h"
#include "VDSequipdef.h"
#include "VDScheckdef.h"
#include "VDDbtbldef.h"
#include "VDSeqpfidef.h"
#include "vdsfimacros.h"
#include "vdbmacros.h"
#include "VDmacdef.h"
#include "VDmsg.h"

//#define VD_DEBUG

#include "VDdebug.h"

#define NB_MAX_CATALOG 5

/*+fi
 -------------------------------------------------------------------------
  Internal Function VDFindIndexAtt

  Abstract
	This function looks for an attribute given by its name
	in the list.
	It returns the index of the attribute in the list.

  Returns
	1 if the attribute has been found.
	0 otherwise.


 -------------------------------------------------------------------------
*/

int VDFindIndexAtt
(
  char			*name,		/* [I] name of attribute to search	*/
  struct temp_attr	*list_att,	/* [I] list of attributes		*/
  int			 nb_inlist,	/* [I] number of attributes in the list */
  int			*index		/* [O] index of the attribute in the	*/
					/*     if it has been found.		*/
)
/*
-fi */
{
  int	i;

  __enterFunction ( name = "VDFindIndexAtt" );

  *index = -1;

  for ( i = 0; i < nb_inlist; i++ )
  {
    if ( strcmp ( name, list_att[i].attr_name ) == 0 )
    {
      *index = i;
      __exitFunction ( name = "VDFindIndexAtt" );
      return 1;
    }
  }

  __exit_error_Function ( name = "VDFindIndexAtt" );

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
  double 	value;	  value of gadget ( or field row # )
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

  __enterMethod ( name = "form_notification" );

  if ( label == me->g_search )
  {
    om$send ( msg	= message VDCmdPart.VDQueryDb ( &msg ),
	      targetid	= my_id );
    FIg_set_state_off ( me->form_sel_part, me->g_search );
  }
  else if ( label == me->g_reset )
  {
    om$send ( msg	= message VDCmdPart.VDSwitchPartDb ( &msg, me->g_reset ),
	      targetid	= my_id );
    FIg_set_state_off ( me->form_sel_part, me->g_reset );
  }
  else if ( label == me->g_minus )
  {
    om$send ( msg	= message VDCmdPart.VDSwitchPartDb ( &msg, me->g_minus ),
	      targetid	= my_id );
  }

  else if ( label == me->g_plus )
  {
    om$send ( msg	= message VDCmdPart.VDSwitchPartDb ( &msg, me->g_plus ),
	      targetid	= my_id );
  }
  else if ( label == me->g_num_part )
  {
    om$send ( msg	= message VDCmdPart.VDKeyinPartNum ( &msg ),
	      targetid	= my_id );
  }
  else
  {
    /* unknown gadget */
    __print_goto ("quit");
    goto quit;
  }

quit:

  __exitMethod  ( name = "form_notification" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message init_all

  Abstract
	That method initialise the instances.

  Arguments
	long	*sts	O 	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-me*/

method	init_all ( long *sts )
{
  __enterMethod ( name = "init_all" );

  *sts = OM_S_SUCCESS;

  me->list_catalog	= NULL;
  me->list_descrip	= NULL;
  me->list_critsel	= NULL;

  me->nb_catalog	= 0;

  me->parts		= NULL;
  me->nb_parts		= 0;
  me->cur_part		= -1;

  me->att_critsel	= NULL;
  me->nb_critsel	= 0;

  me->form_sel_part	= NULL;
  me->units_set_exists	= FALSE;

  *sts = OM_S_SUCCESS;

  __exitMethod  ( name = "init_all" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message delete_all

  Abstract
	That method is called at the delete of the command. It basically
	free all the allocated arrays.

  Arguments

	long	*sts	O 	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-me*/

method	delete_all ( long *sts )
{
  __enterMethod ( name = "delete_all" );

  *sts = OM_S_SUCCESS;

  /* Free list of catalog */

  VDSfree_arrays ( me->nb_catalog  , me->list_catalog,
		   me->list_descrip, me->list_critsel );
  me->list_catalog = me->list_descrip = me->list_critsel = NULL;

  /* Free old selected parts */

  if ( me->parts != NULL )
  {
    VDfree_allocated_parts ( me->nb_parts, me->parts, NULL );
    me->parts	= NULL;
    me->nb_parts = 0;
  }

  if ( me->att_critsel )
  {
    om$dealloc ( ptr = me->att_critsel );
    me->att_critsel = NULL;
  }

  __exitMethod  ( name = "delete_all" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDRefreshFormPart

  Abstract
      Refresh all the fields in the form.

  Algorithm:

	- displays the list of catalogs and their descriptions
 	- displays the attribute names of the select criteria
 	- display the list of attribute values if a part has already been
	selected.

  Arguments
      none

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method	VDRefreshFormPart ()
{
  int		i, row;
  Form		form_ptr;
  IGRlong	msg;

  __enterMethod ( name = "VDRefreshFormPart" );

  form_ptr = me->form_sel_part;

  FIg_enable ( form_ptr, FI_EXECUTE );

  /* write the list of catalogs and their descriptions */

  for ( i = 0; i < me->nb_catalog; i++ )
  {
    FIfld_set_text ( form_ptr, me->g_cata_list, i, 0, me->list_catalog[i], 0 );
    FIfld_set_text ( form_ptr, me->g_cata_list, i, 1, me->list_descrip[i], 0 );
  }

  /* write the attributes of the select criteria */

  FIfld_set_num_rows ( form_ptr, me->g_db_list, me->nb_critsel );
  FIfld_set_max_num_rows ( form_ptr, me->g_db_list, me->nb_critsel );

  /* Put the attribute names in the form (col 0) */

  for ( row = 0; row < me->nb_critsel; row++ )
    FIfld_set_text ( form_ptr, me->g_db_list, row, 0, me->att_critsel[row].name, 0 );

  /* Display the list of attribute values for the current part */

  om$send ( msg		= message VDCmdPart.VDPlaceDbAttInList ( &msg ),
	    targetid	= my_id );

  __exitMethod  ( name = "VDRefreshFormPart" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDCstQuery

  Abstract
      Construct the query from the selection in the form.
      Basically, it fills the structure query (op, name, type) for
      each attribute that has been given a value (with or without operator)
      by the user. (ie if the column 3 (att value) is empty, the corresponding
      attribute will not appear in the query list).

     name_att contains the attributes written in the form (in order)

     query is allocated in the method and must be deallocated by the user.

  Notes/Remarks
     For the new operator "between" the type in query must be text
     (the syntax is "between x and y").

  Arguments

	IGRlong 		*sts;	    (O) completion code
	int  			nb_attr;    (I) nb_attribute in name_att
	struct temp_attr  	*name_att;  (I) list of attributes to test
	int			*nb_query;  (O) number of query
	struct query_attr 	**query     (O) constructed query

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method VDCstQuery
(
  IGRlong		 *sts;		/* (O) Completion Code			*/
  int			  nb_attr;	/* (I) nb of attributes in the list	*/
  struct temp_attr	 *name_att;	/* (I) list of attributes to test	*/
  int			 *nb_query;	/* (O) number of constructed queries	*/
  struct query_attr	**query		/* (O) list of constructed queries	*/
)
{
  int			row, num_att;
  int			sel, pos;
  unsigned char		val_txt[ATTR_TXT];
  char			my_msg[80], op_txt[15];
  IGRdouble		val_db;
  IGRboolean		IsBetween;

  __enterMethod ( name = "VDCstQuery" );

  *sts = OM_S_SUCCESS;

  if ( query == NULL || nb_query == NULL || name_att == NULL )
  {
    printf ( "Error VDCstQuery, invalid argument\n" );
    __print_goto ("wrapup");
    goto wrapup;
  }
  *nb_query = 0;
  *query = NULL;

  *query = ( struct query_attr * ) om$malloc ( size = nb_attr * sizeof ( struct query_attr ) );
  if ( !( *query ) )
  {
    printf ( "Cannot allocate memory for query\n" );
    __print_goto ("wrapup");
    goto wrapup;
  }

  /* Construct query */

  for ( row = 0; row < nb_attr; row++ )
  {
    IsBetween = FALSE;
    num_att = row+1;
    val_txt[0] = '\0';

    /*
     * Get in the form the values and operators for each attributes
     */

    FIfld_get_text ( me->form_sel_part, me->g_db_list, row, 3, ATTR_TXT, val_txt, &sel, &pos );

    val_txt[ATTR_TXT - 1] = '\0';
    if ( val_txt[0] == '\0' )
      continue;

    op_txt[0] = '\0';

    FIfld_get_text ( me->form_sel_part, me->g_db_list, row, 2, 14,
		     ( unsigned char * ) op_txt, &sel, &pos );
    op_txt[14] = '\0';

    if ( op_txt[0] == '\0' )
      strcpy ( op_txt, "=" );

    EXP_strip ( op_txt );

    /*
     * 13 Dec:	add the possibility to define intervalls (operator = IN,
     *		type = AC_ATTRIB_DOUBLE or SM_ATTRIB_INT, but value in a text)
     */

    switch ( name_att[num_att].type )
    {
    case AC_ATTRIB_DOUBLE:
    case SM_ATTRIB_INT:

      /*
       * treatment of intervals (between a and b) need to be treated
       * in SMcomp/SMCompDb.C VDquery_parts :April 94
       */

      if ( strncmp ( op_txt, "between", 7 ) == 0 )
      {
	strcpy ( ( *query )[*nb_query].Operator, op_txt );
	strcpy ( ( *query )[*nb_query].value.att_txt, ( char * ) val_txt );
	IsBetween = TRUE;
	break;
      }

      if ( ! SMget_double( me->form_sel_part,
			   me->g_db_list,
			   row,
			   3,
			   &val_db )
	   || ( name_att[num_att].type == SM_ATTRIB_INT
	   && ( ( fabs ( val_db - floor ( val_db ) ) > 0.000001 ) ) ) )
      {
	ex$message ( msgnumb	= SM_E_CmBadValAttr,
		     buff	= my_msg,
		     type	= "%s",
		     var	= `name_att[num_att].attr_name ` );
	FIg_set_text ( me->form_sel_part, FI_MSG_FIELD, my_msg );
	__print_goto ("wrapup");
	goto wrapup;
      }

      if (    strncmp ( op_txt, "=" , 1 ) && strncmp ( op_txt, "<" , 1 )
	   && strncmp ( op_txt, ">" , 1 ) && strncmp ( op_txt, "<=", 2 )
	   && strncmp ( op_txt, ">=", 2 ) && strncmp ( op_txt, "IN", 2 ) )
      {
	ex$message ( msgnumb	= SM_E_CmBadValOp,
		     buff	= my_msg,
		     type	= "%s",
		     var	= `name_att[num_att].attr_name ` );
	FIg_set_text ( me->form_sel_part, FI_MSG_FIELD, my_msg );
	__print_goto ("wrapup");
	goto wrapup;
      }
      else
	strcpy ( ( *query )[*nb_query].Operator, op_txt );

      if ( name_att[num_att].type == SM_ATTRIB_INT )
	( *query )[*nb_query].value.att_int = ( int ) val_db;
      else
	( *query )[*nb_query].value.att_dbl = val_db;

      break;

    case AC_ATTRIB_TEXT:

      if ( strncmp ( op_txt, "=", 1 ) && strncmp ( op_txt, "like", 4 ) )
      {
	ex$message ( msgnumb	= SM_E_CmBadValOp,
		     buff	= my_msg,
		     type	= "%s",
		     var	= `name_att[num_att].attr_name ` );
	FIg_set_text ( me->form_sel_part, FI_MSG_FIELD, my_msg );
	__print_goto ("wrapup");
	goto wrapup;
      }
      else
	strcpy ( ( *query )[*nb_query].Operator, op_txt );

      strcpy ( ( *query )[*nb_query].value.att_txt, ( char * ) val_txt );
      break;
    }

    strcpy ( ( *query )[*nb_query].name, name_att[num_att].attr_name );
    ( *query )[*nb_query].type = name_att[num_att].type;

    /*
     * particular case for operator "between" where type is set to TXT
     */

    if ( IsBetween )
      ( *query )[*nb_query].type = AC_ATTRIB_TEXT;

    ( *nb_query )++;
  }

  *sts = OM_S_SUCCESS;

  __exitMethod  ( name = "VDCstQuery" );

  return OM_S_SUCCESS;

wrapup:
  /* Free before reallocating */

  if ( query && ( *query ) )
  {
    om$dealloc ( ptr = ( *query ) );
    ( *query ) = NULL;
  }
  *sts = OM_E_ABORT;

  __exit_error_Method  ( name = "VDCstQuery" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDQueryDb

  Abstract

      This method is called when the "search" button is pushed.

      Query the database to retrieve all the parts corresponding to the
      select criteria.
      It fills the structure me->parts which contains select attributes
      for all parts.

      The query is constructed with the selection displayed in the form
      (att op value). (For now we take the same query for each catalog,
      which is the intersection of all the select criteria).

      Then, the query is performed in the database for each catalog, and the
      selected attributes are put in me->parts.

      The last part found is displayed in the form.

  Arguments
	long		*sts		O 	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method	VDQueryDb ( IGRlong * sts )
{
  int			 row;
  struct query_attr	*query = NULL;
  int			 nb_query = 0;
  char			 my_msg[80];
  struct temp_attr	*list_all_attr = NULL;
  int			 nb_all_stat, i, index;
  struct temp_attr	*name_att = NULL;	/* Name of static attributes	*/
						/* if critsel			*/
  int			 nb_stat_sel = 0;	/* Number of static attributes	*/
						/* in critsel			*/
  struct part_attr	*parts[NB_MAX_CATALOG];
  int			 nb_parts[NB_MAX_CATALOG], tot_nb_parts;

  __enterMethod ( name = "VDQueryDb" );

  *sts = OM_S_SUCCESS;

  if ( me->nb_critsel <= 0 || me->att_critsel == NULL || me->nb_catalog == 0
       || me->list_catalog == NULL )
  {
    __print_goto ("wrapup");
    goto wrapup;
  }
  /* Free old selected parts */

  if ( me->parts != NULL )
  {
    VDfree_allocated_parts ( me->nb_parts, me->parts, NULL );
    me->parts	= NULL;
    me->nb_parts= 0;
  }

  /*
   * We don't know at this point the type of each attributes.
   * But we know the select criteria.
   * We first retrieve the type of all the attributes for a part
   * (a function still exists) and we  keep only attribute in CritSel
   */

  /* Get list of all attributes for part 0 */

  /* VDquery_att_name in SMcomp/SMCompDb.C retrieve the list of attributes
	    for the given family */

  if ( !VDquery_att_name ( me->list_catalog[0], &nb_all_stat, &list_all_attr,
			   &me->units_set_exists ) )
  {
    printf ( "Error getting list of attributes family %s\n", me->list_catalog[0] );
    __print_goto ("wrapup");
    goto wrapup;
  }

  name_att = ( struct temp_attr * ) om$malloc (	size = nb_all_stat * sizeof ( struct temp_attr ) );
  if ( !name_att )
  {
    printf ( "Cannot allocate memory for attributes\n" );
    __print_goto ("wrapup");
    goto wrapup;
  }

  nb_stat_sel = 0;

  /*
   * For all attribut in select criteria, find if it is in list_of_all_attr
   * Find also the type of attribut
   * I have to be carefull to put in the same order the list of attributes
   * in critsel and in name_att.
   */

  for ( i = 0; i < me->nb_critsel; i++ )
  {
    /*
     * find the index of me->att_critsel[i].name in list_all_att
     */

    VDFindIndexAtt ( me->att_critsel[i].name,
		     list_all_attr,
		     nb_all_stat,
		     &index );
    if ( index < 0 )
    {
      printf ( "Error attribut %s exists in select criteria but not in family %s\n",
	       me->att_critsel[i].name,
	       me->list_catalog[0] );
      __print_goto ("wrapup");
      goto wrapup;
    }
    strcpy ( name_att[nb_stat_sel].attr_name, me->att_critsel[i].name );
    name_att[nb_stat_sel].type = list_all_attr[index].type;
    nb_stat_sel++;
  }

  if ( nb_stat_sel == 0 )
  {
    FIg_set_text ( me->form_sel_part, FI_MSG_FIELD, "No attributes in select criteria" );
    __print_goto ("wrapup");
    goto wrapup;
  }

  /*
   * construct the query list, ie get in the form the attributes that has 
   * been given a value by the user (col 3 not empty)
   */

  om$send ( msg		= message VDCmdPart.VDCstQuery (
						sts,
						nb_stat_sel,
						name_att,
						&nb_query,
						&query ),
	    targetid	= my_id );
  if ( !( *sts ) & 1 )
  {
    printf ( "Error VDCstQuery \n" );
    __print_goto ("wrapup");
    goto wrapup;
  }

  /*
   * Now, find all the parts, in each catalog, that respond to the query
   * (To add in  VDquery_parts (SMcomp/SMCompDb.C): test of interval)
   */

  if ( me->nb_catalog == 1 )
    VDquery_parts ( me->list_catalog[0],
		    nb_stat_sel,
		    name_att,
		    nb_query,
		    query,
		    me->units_set_exists,
		    &me->nb_parts,
		    &me->parts,
		    NULL );
  else if ( me->nb_catalog > 1 )
  {
    /*
     * The same query is asked for all catalogs
     */

    me->nb_parts = 0;
    for ( i = 0; i < me->nb_catalog; i++ )
    {
      VDquery_parts ( me->list_catalog[i],
		      nb_stat_sel,
		      name_att,
		      nb_query,
		      query,
		      me->units_set_exists,
		      &nb_parts[i],
		      &parts[i],
		      NULL );
      me->nb_parts += nb_parts[i];
    }

    /* Correction PL June 94, bad index in memcpy */

    tot_nb_parts = 0;
    if ( me->nb_parts > 0 )
    {
      me->parts = om$calloc ( num = me->nb_parts, structure = struct part_attr );
      if ( me->parts == NULL )
      {
	printf ( "Memory problem\n" );
	__print_goto ("wrapup");
	goto wrapup;
      }
      for ( i = 0; i < me->nb_catalog; i++ )
      {
	if ( nb_parts[i] > 0 )
	{
	  tot_nb_parts + = ( i > 0 ? nb_parts[i - 1] : 0 );
	  memcpy ( me->parts + tot_nb_parts,
		   parts[i],
		   sizeof ( struct part_attr ) * nb_parts[i] );
	  om$dealloc ( ptr = parts[i] );
	  parts[i] = NULL;
	}
      }
    }
  }

  /*
   * Display in the form, the attributes of the last part found
   */

  if ( me->nb_parts == 0 || me->parts == NULL )
  {
    ex$message ( msgnumb = SM_E_CmNoPartFound, buff = my_msg );

    FIg_set_text ( me->form_sel_part, FI_MSG_FIELD, my_msg );
    FIg_set_value ( me->form_sel_part, me->g_num_part, 0.0 );

    me->cur_part = 0;
    for ( row = 0; row < me->nb_critsel; row++ )
      FIfld_set_text ( me->form_sel_part, me->g_db_list, row, 1, "", FALSE );
  }
  else
  {
    me->cur_part = me->nb_parts;
    om$send ( msg	= message VDCmdPart.VDPlaceDbAttInList ( sts ),
	      targetid	= my_id );
  }

  /* Free before reallocating */

  if ( name_att )
  {
    om$dealloc ( ptr = name_att );
    name_att = NULL;
  }
  if ( query )
  {
    om$dealloc ( ptr = query );
    query = NULL;
  }
  if ( list_all_attr )
  {
    om$dealloc ( ptr = list_all_attr );
    list_all_attr = NULL;
  }

  *sts = OM_S_SUCCESS;

  __exitMethod  ( name = "VDQueryDb" );

  return OM_S_SUCCESS;

wrapup:

  /* Free before reallocating */

  if ( name_att )
  {
    om$dealloc ( ptr = name_att );
    name_att = NULL;
  }
  if ( query )
  {
    om$dealloc ( ptr = query );
    query = NULL;
  }
  if ( list_all_attr )
  {
    om$dealloc ( ptr = list_all_attr );
    list_all_attr = NULL;
  }
  *sts = OM_E_ABORT;

  __exit_error_Method  ( name = "VDQueryDb" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDPlaceDbAttInList

  Abstract
      Displays the attributes of the current part in the me->g_db_list
      gadget of the form.

      It basically displays the attributes for  me->parts[cur_index]
      with cur_index = me->cur_part - 1.

      If no part has been already selected, it displays the default
      criteria values (if there are some)

  Arguments
	long		*sts		O 	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-me*/

method	VDPlaceDbAttInList ( long *sts )
{
  int			 cur_index;
  int			 col, row, num_att;
  char			 val_txt[ATTR_TXT];
  struct part_attr	*part;

  __enterMethod ( name = "VDPlaceDbAttInList" );

  *sts = OM_S_SUCCESS;

  /*
   *	 me->cur_part is the number ( 1 to nb_part) of selected parts,
   *	 and it is displayed in the field g_num_part.
   *	 It is, in fact the index (+ 1) of the displayed part.
   */

  cur_index = me->cur_part - 1;

  /*
   * if there is no part to display, write in the form the default criteria
   */

  if ( cur_index < 0 || cur_index >= me->nb_parts || me->parts == NULL )
  {
    for ( row = 0; row < me->nb_critsel; row++ )
    {
      for ( col = 1; col < 4; col++ )
	FIfld_set_text ( me->form_sel_part, me->g_db_list, row, col, "", 0 );

      /*
       * Put default criteria from USR_DEF_TBL if some values are defined
       */

      if ( me->att_critsel[row].desc.value.att_txt[0] != '\0' )
      {
	FIfld_set_text ( me->form_sel_part, me->g_db_list, row, 2, "=", 0 );
	FIfld_set_text ( me->form_sel_part, me->g_db_list, row, 3,
			 me->att_critsel[row].desc.value.att_txt, 0 );
      }
    }

    FIg_set_text ( me->form_sel_part, me->g_num_part, "" );
    *sts = OM_S_SUCCESS;
    __print_goto ("quit");
    goto quit;
  }

  part = &me->parts[cur_index];		/* this is the part to be displayed */

  FIg_set_value ( me->form_sel_part, me->g_num_part, ( double ) ( me->cur_part ) );
  sprintf ( val_txt, "%d", me->cur_part );
  FIfld_set_default_text ( me->form_sel_part, me->g_num_part, 0, 0, val_txt, FALSE );

  /*
   * Place all the attribute values of that part in the field (col 1)
   */

  for ( num_att = 0; num_att < part->nb_att; num_att++ )
  {
    row = num_att;
    if ( part->att[num_att].attr.desc.type == AC_ATTRIB_DOUBLE )
    {
      sprintf ( val_txt, "%-9.6g", part->att[num_att].attr.desc.value.att_exp );
      FIfld_set_text ( me->form_sel_part, me->g_db_list, row, 1, val_txt, 0 );
    }
    else
    {
      FIfld_set_text ( me->form_sel_part, me->g_db_list, row, 1,
		       part->att[num_att].attr.desc.value.att_txt, 0 );
    }
  }
  *sts = OM_S_SUCCESS;

quit:

  __exitMethod  ( name = "VDPlaceDbAttInList" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDSwitchPartDb

  Abstract
  	This message is called when the user asks for the next or preceding
	part or at the RESET_SEARCH.

  	Depending on the asking gadget, it basically sets me->cur_part
	to the part to be displayed and it displays its attributes in
	the form.

  Arguments
	long		*sts		O 	Completion code
	int		label 		I 	label of the gadget that calls
 						the method (reset,minus,plus).

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method VDSwitchPartDb
(
  long		*sts; 	/* (O) Completion code				   */
  int		 label	/* (I) calling label gadget (reset, minus or plus) */
)
{
  int		 cur_part;	/* Number in array of parts of current part */
  char		 my_msg[80];

  __enterMethod ( name = "VDSwitchPartDb" );

  *sts = OM_S_SUCCESS;

  if ( label == me->g_reset )
  {
    /* Blank columm in form */

    me->cur_part = -1;			/* No part selected */

    om$send ( msg	= message VDCmdPart.VDPlaceDbAttInList ( sts ),
	      targetid	= my_id );

    /* Free all preceding selected parts */

    if ( me->parts != NULL )
    {
      VDfree_allocated_parts ( me->nb_parts, me->parts, NULL );
      me->parts = NULL;
      me->nb_parts = 0;
    }
    __print_goto ("quit");
    goto quit;
  }
  else if ( label == me->g_plus || label == me->g_minus )
  {
    cur_part = me->cur_part;

    if ( label == me->g_plus )
      cur_part++;
    else
      cur_part--;

    if ( me->nb_parts == 0 || cur_part > me->nb_parts || cur_part <= 0 )
    {
      ex$message ( msgnumb = SM_I_CmEndData, buff = my_msg );
      FIg_set_text ( me->form_sel_part, FI_MSG_FIELD, my_msg );
      *sts = OM_E_ABORT;
      __print_goto ("quit");
      goto quit;
    }
    else
      me->cur_part = cur_part;

    /*
     * Display all the attributes in the list
     */

    om$send ( msg	= message VDCmdPart.VDPlaceDbAttInList ( sts ),
	      targetid	= my_id );
  }

  *sts = OM_S_SUCCESS;

quit:

  __exitMethod  ( name = "VDSwitchPartDb" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDKeyinPartNum

  Abstract
  	Display the attributes of the part the user keys in the
	gadget g_num_part.

  Arguments
	long		*sts		O 	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always


 -------------------------------------------------------------------------
-me*/

method	VDKeyinPartNum ( long *sts )
{
  char		my_msg[80];
  double	val_db;

  __enterMethod ( name = "VDKeyinPartNum" );

  *sts = OM_S_SUCCESS;

  if ( !SMget_double ( me->form_sel_part, me->g_num_part, 0, 0, &val_db ) ||
       ( int ) val_db <= 0 || ( int ) val_db > me->nb_parts )
  {
    if ( me->nb_parts )
    {
      ex$message ( msgnumb = SM_I_CmNoPartNum, buff = my_msg,
		   type    = "%d%d"	     , var = `( int ) val_db, me->nb_parts ` );
    }
    else
      ex$message ( msgnumb = SM_E_CmNoPartFound, buff = my_msg );

    FIg_set_text ( me->form_sel_part, FI_MSG_FIELD, my_msg );

    if ( me->cur_part >= 0 )
      FIg_set_value ( me->form_sel_part, me->g_num_part, ( double ) me->cur_part );
    else
      FIg_set_text ( me->form_sel_part, me->g_num_part, "" );
  }
  else
  {
    me->cur_part = ( int ) ( val_db );
    om$send ( msg	= message VDCmdPart.VDPlaceDbAttInList ( sts ),
	      targetid	= my_id );
  }

  *sts = OM_S_SUCCESS;

  __exitMethod  ( name = "VDKeyinPartNum" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDLoadSelPart

  Abstract
 	This message loads the selected part.
	At this level it only sets the db_info structure.
	(Need to be overriden to load the part into a given structure)

  Arguments
	long		*sts		O 	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method	VDLoadSelPart ( long *sts )
{
  char	my_msg[80];
  int	cur_index;

  __enterMethod ( name = "VDLoadSelPart" );

  *sts = OM_S_SUCCESS;

  /*
   * Verify if there is one selected part
   */

  if ( me->nb_parts == 0 || me->parts == NULL || me->cur_part <= 0 ||
       me->cur_part > me->nb_parts )
  {
    ex$message ( msgnumb = SM_E_CmNoPartSel, buff = my_msg );
    FIg_set_text ( me->form_sel_part, FI_MSG_FIELD, my_msg );
    __print_goto ("wrapup");
    goto wrapup;
  }

  cur_index = me->cur_part - 1;

  me->db_info.catalog [0] = me->db_info.part_num[0] = '\0';
  me->db_info.revision[0] = '\0';

  /*
   * Set db_info structure (Information for checkin)
   */

  strcpy ( me->db_info.catalog , me->parts[cur_index].att[0].attr.desc.value.att_txt );
  strcpy ( me->db_info.part_num, me->parts[cur_index].att[1].attr.desc.value.att_txt );
  strcpy ( me->db_info.revision, me->parts[cur_index].att[2].attr.desc.value.att_txt );

  *sts = OM_S_SUCCESS;

  __exitMethod  ( name = "VDLoadSelPart" );

  return OM_S_SUCCESS;

wrapup:
  *sts = OM_E_ABORT;

  __exit_error_Method  ( name = "VDLoadSelPart" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message VDReadFromPdu

  Abstract
	Get the part from PDU.
	Does nothing at that level.

  Arguments
	long		*sts		O 	Completion code


  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method	VDReadFromPdu ( long *sts )
{
  __enterMethod ( name = "VDReadFromPdu" );

  *sts = OM_E_ABORT;

  __exitMethod  ( name = "VDReadFromPdu" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message init_db

  Abstract
      Get the parts from the me->db_info.catalog.
      It fills the structure me->save_att if there is only one part.

  Arguments
	long		*sts		O 	Completion code

  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method	init_db ( long *sts )
{
  int			  status	= OM_S_SUCCESS;
  char			**part_names	= NULL,
			**revision_names= NULL;
  int			  nb_parts	= 0;
  struct VDSatt_family	 *stat_att	= NULL,
			 *dyn_att	= NULL;
  int			  nb_stat, nb_dyn;

  __enterMethod ( name = "init_db" );

  *sts = OM_S_SUCCESS;

  me->parts = NULL;
  me->nb_parts = 0;

  /*
   * Retrieve  number of parts in database
   */

  ex$message ( msgnumb	= VD_I_RetPartCat,
	       type	= "%s",
	       var	= `me->db_info.catalog ` );

  status =
    vdb$RisGetNumberOfParts ( table_name	= me->db_info.catalog,
			      count		= &nb_parts );

  if ( status != SUCCESS || nb_parts == 0 )
  {
    ex$message ( msgnumb = SM_E_CmNoDbParts );
    *sts = OM_E_ABORT;
    __print_goto ("quit");
    goto quit;
  }
  if ( nb_parts == 1 )
  {
    if ( !VDSget_family_parts ( me->db_info.catalog, &nb_parts,
				&part_names, &revision_names ) || nb_parts == 0 )
    {
      ex$message ( msgnumb = SM_E_CmNoDbParts );
      *sts = OM_E_ABORT;
      __print_goto ("quit");
      goto quit;
    }

    me->save_nb_att = SM_MAX_CO_ATTR;
    /*
     * Retrieves attributes for this parts in database
     */
    if ( !VDSget_attr ( me->db_info.catalog, part_names[0], revision_names[0], "",
			&nb_stat, &stat_att, &nb_dyn, &dyn_att ) )
    {
      ex$message ( msgnumb = SM_E_CmNoDbAtt );
      __print_goto ("free_mem");
      *sts = OM_E_ABORT;
      goto free_mem;
    }

    om$send ( msg	= message VDCmdPart.fill_attr_from_part
						( sts, nb_stat, stat_att, nb_dyn, dyn_att ),
	      targetid	= my_id );
    if ( !( *sts & 1 ) )
    {
      printf ( "Error copy attributes\n" );
      __print_goto ("free_mem");
      *sts = OM_E_ABORT;
      goto free_mem;
    }

    strcpy ( me->db_info.part_num, part_names[0] );
    strcpy ( me->db_info.revision, revision_names[0] );

    FIg_delete ( me->form_sel_part, G_READ_PDU );
    FIg_delete ( me->form_sel_part, G_DATA_SEL );

    *sts = ONLY_ONE_PART;

free_mem:

    VDSfree_arrays ( nb_parts, part_names, revision_names, NULL );
    if ( stat_att )
      om$dealloc ( ptr = stat_att );
    if ( dyn_att )
      om$dealloc ( ptr = dyn_att );

    __print_goto ("quit");
    goto quit;
  }

  status = OM_S_SUCCESS;
  *sts = OM_S_SUCCESS;

quit:

  __exitMethod  ( name = "init_db" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message fill_attr_from_part

  Abstract
     Parse the static and dynamic attributes into me->save_att.
     Does nothing at this level.

  Arguments
	long 		     *sts	O	Completion code
	int 		     nb_stat	I	number of static attributes
	struct VDSatt_family *stat_att	I	the static attributes
	int 		     nb_dyn	I	number of dynamic attributes
	struct VDSatt_family *dyn_att)  I	the dynamic attributes


  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method fill_attr_from_part
(
  long			*sts;
  int			 nb_stat;
  struct VDSatt_family	*stat_att;
  int			 nb_dyn;
  struct VDSatt_family	*dyn_att
)
{
  __enterMethod ( name = "fill_attr_from_part" );

  *sts = OM_E_ABORT;

  __exitMethod  ( name = "fill_attr_from_part" );

  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message  VDLoadDbAttr

  Abstract
	Load the name of the static attributes and displays them in the
	form.

  Arguments
	long		*sts		O 	Completion code


  Status/Return Code
      status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-me*/

method	VDLoadDbAttr ( long *sts )
{
  int	row;

  __enterMethod ( name = "VDLoadDbAttr" );

  *sts = OM_S_SUCCESS;

  if ( me->name_att == NULL )
  {
    me->nb_stat = 0;
    if ( !VDquery_att_name ( me->db_info.catalog, &me->nb_stat, &me->name_att,
			     &me->units_set_exists ) )
    {
      __print_goto ("wrapup");
      goto wrapup;
    }
  }

  /*
   * Put attribute name in form : ignore first attribute (family name)
   */
  for ( row = 0; row < me->nb_stat - 1; row++ )
  {
    FIfld_set_text ( me->forms[0].form_ptr, me->g_db_list, row, 0,
		     me->name_att[row + 1].attr_syn, 0 );
  }

  FIfld_set_num_rows     ( me->forms[0].form_ptr, me->g_db_list, me->nb_stat - 1 );
  FIfld_set_max_num_rows ( me->forms[0].form_ptr, me->g_db_list, me->nb_stat - 1 );

  om$send ( msg      = message VDCmdPart.VDPlaceDbAttInList ( sts ),
	    targetid = my_id );

  *sts = OM_S_SUCCESS;
  __print_goto ("quit");
  goto quit;

wrapup:
  *sts = OM_E_ABORT;

quit:

  __exitMethod  ( name = "VDLoadDbAttr" );

  return OM_S_SUCCESS;
}

end implementation VDCmdPart;
