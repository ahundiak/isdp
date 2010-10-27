/* $Id: VDCmdFtxt_Ms.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdFtxt_Ms.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdFtxt_Ms.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
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
# Revision 1.2  1996/03/28  20:18:54  pinnacle
# Replaced: vdannot/cmd/VDCmdFtxt_Ms.I for:  by yzhu for vds.240
#
# Revision 1.1  1994/11/21  20:11:50  pinnacle
# delete by mistake
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*****************************************************************************
 *
 *	File:	VDCndFtxt_Ms.I
 *
 *	Date	April 1992
 *	
 *	Author:	Ad Zuurhout
 *	 
 *
 * 	Description:	Manipulations of the expression is realized by a
 *			dynamics array containing all available macro
 *			expressions of the working directory:
 *				<file_name>:formats:..
 *
 *			Used arrays:
 *			 - "ldexpr_list" contains all available expressions.
 *			   Array entry contains:
 *				- formatname,
 *				- textstring,
 *				- parameters,
 *				- expression identifier.
 *
 *			Form Processing and Setup Methods for Formatted Text 
 *			Commands
 *
 *	History:
 *	April 1992	Creation date
 *
 *
 ****************************************************************************/
class implementation VDCmdFtxt;

#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "OMerrordef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "FI.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"

#include "AS_status.h"
#include "ACattrib.h"
#include "acdef.h"
#include "acmacros.h"
#include "macro.h"
#include "parametric.h"
#include "expression.h"
#include "expmacros.h"

#include "VDmsg.h"
#include "VDSannot.h"
#include "v_dbgmacros.h"

#define   AS_DEBUG	1

/*
 * Externs called functions
 */

from	IGRdir		import	dump;
from	NDnode		import	NDgive_structure;
from	expression	import	give_formula;

/************************************************************************/
/*	METHOD	get_exist_formats					*/
/************************************************************************/

method	get_exist_formats( long * sts )
{
int	status = OM_S_SUCCESS;
int	msg;
IGRchar	macro_dir[TEXT_SIZE];
IGRchar	for_exp[TEXT_SIZE], par_exp[TEXT_SIZE];
struct	GRid		macro_obj, for_obj, par_obj;
struct	ret_struct	for_str, par_str;

IGRchar	**exprs;
DIgrid	*expr_ids;
IGRint	i,ii,nb_exprs;
char    *pr1, *pr2, for_formula[DB_TEXT_SIZE], par_formula[DB_TEXT_SIZE];

  SetProc(VDCmdFtxt_Ms.get_exist_formats); Begin 

  /*
   * This method read all exist formatted text expression of a defined
   * macro, which is given by it's name (macro_name).
  */
  
  *sts = MSSUCC;
  expr_ids = NULL;
  exprs    = NULL;
  nb_exprs = 0;

  /* create dynamic memory */
  status =
  om$vla_set_dimension( varray = me->ldexpr_list, size = 0 );

  if( me->macro_name[0] == '\0' ){
    /*| No macroname defined */
    *sts = MSFAIL;
    goto wrapup;
  }

  /* get macro directory */
  sprintf( macro_dir, "%s:%s", me->dir_name, me->macro_name );

  macro_obj.objid = NULL_OBJID;
  status = di$translate(objname = macro_dir,
			p_objid = &macro_obj.objid,
			p_osnum = &macro_obj.osnum );
  if( status != DIR_S_SUCCESS ){
    /*| No expression for this macro */
    goto wrapup;
  }

  /* find all defined expressions */
  status = 
  om$send(msg = message IGRdir.dump(	&msg,
					"*",
					NULL,
					&exprs,
					&expr_ids,
					&nb_exprs,
					0 ),
	  targetid = macro_obj.objid,
	  targetos = macro_obj.osnum,
	  senderid = NULL_OBJID );
  as$status(action = GOTO_VALUE, value=wrapup);

  if( nb_exprs == 0 ){
    goto wrapup;
  }

  /* create dynamic memory */
  status = om$vla_set_dimension( varray = me->ldexpr_list,
				 size   = nb_exprs );

  ii = 0;
  for( i=0; i<nb_exprs; i++){

    if( strcmp( exprs[i], VD_FOR_DEFAULT ) == 0 ) continue;

    sprintf( for_exp, "%s:%s:%s", macro_dir, exprs[i], VD_FTEXT_STRING );
    sprintf( par_exp, "%s:%s:%s", macro_dir, exprs[i], VD_FTEXT_PARAMS );

    /* get format text string */
    for_obj.objid = NULL_OBJID;
    status = di$translate(	objname = for_exp,
				p_objid = &for_obj.objid,
				p_osnum = &for_obj.osnum );
    if( status != DIR_S_SUCCESS ){
      /*" expression %s:%s not found\n", exprs[i], VD_FTEXT_STRING  */
      continue;
    }

    /* tr179601237 */
    status =
    om$send(msg = message expression.give_formula(for_formula),
            targetid = for_obj.objid,
            targetos = for_obj.osnum,
            senderid = NULL_OBJID );
    if( !(status&1)){
      continue;
    }
    
    pr1 = NULL;
    pr2 = NULL; 
    pr1 = strchr(for_formula, '"');
    pr2 = strrchr(for_formula, '"');
    if(  pr1 != pr2) {
       strcpy(for_formula, &pr1[1]);
       for_formula[strlen(for_formula)-1]='\0';
    }
 
/*
    status =
    om$send(msg = message NDnode.NDgive_structure(	sts,
							&for_str,
							&me->mod_env ),
	    targetid = for_obj.objid,
	    targetos = for_obj.osnum,
	    senderid = NULL_OBJID );
    if( !(status&*sts&1)){
      continue;
    }
*/

    /* get parameters string */
    par_obj.objid = NULL_OBJID;
    status = di$translate(	objname = par_exp,
				p_objid = &par_obj.objid,
				p_osnum = &par_obj.osnum );
    if( status != DIR_S_SUCCESS ){
      /*" expression %s: %s not found\n", exprs[i], VD_FTEXT_STRING  */
      continue;
    }

    /* tr179601237 */
    status =
    om$send(msg = message expression.give_formula(par_formula),
            targetid = par_obj.objid,
            targetos = par_obj.osnum,
            senderid = NULL_OBJID );
    if( !(status&1)){
      continue;
    }

    pr1 = NULL;
    pr2 = NULL;
    pr1 = strchr(par_formula, '"');
    pr2 = strrchr(par_formula, '"');
    if(  pr1 != pr2) {
       strcpy(par_formula, &pr1[1]);
       par_formula[strlen(par_formula)-1]='\0';
    }
    if( strlen ( par_formula ) > 80) 
       par_formula[79] = '\0'; 
/*
    status =
    om$send(msg = message NDnode.NDgive_structure(	sts,
							&par_str,
							&me->mod_env ),
	    targetid = par_obj.objid,
	    targetos = par_obj.osnum,
	    senderid = NULL_OBJID );
    if( !(status&*sts&1) ){
      continue;
    }
*/
    /* find format expression name */
    {
      IGRchar	*ptr;
      ptr = strrchr( exprs[i], ':' );
      ptr = ptr ? ptr+1 : exprs[i] ; 
      strcpy( me->ldexpr_list[ii].formatname, ptr );
    }
/* TR179601237 
    strcpy( me->ldexpr_list[ii].string, for_str.var.text_st.text_string );
    strcpy( me->ldexpr_list[ii].params, par_str.var.text_st.text_string );
*/
    strcpy( me->ldexpr_list[ii].string, for_formula );
    strcpy( me->ldexpr_list[ii].params, par_formula );
    me->ldexpr_list[ii].expr_id.objid = expr_ids[i].objid;
    me->ldexpr_list[ii].expr_id.osnum = expr_ids[i].osnum;

    ii++;
  }

  if( ii < nb_exprs ){
    status = om$vla_set_dimension( varray = me->ldexpr_list, size   = ii );
  }

wrapup:
  /* free memory */
  di$free( lines = exprs, count = nb_exprs );
  if( nb_exprs ) DIfree( expr_ids );

  *sts = MSSUCC;
  End
  return( OM_S_SUCCESS );
}

/************************************************************************/
/*	METHOD	disp_exist_formats					*/
/************************************************************************/

method	disp_exist_formats(	long * sts;
				int active )
{
int	status = OM_S_SUCCESS;
IGRint	i,size;
IGRchar	full_str[2*TEXT_SIZE];
char	*fm_ptr;

  SetProc(VDCmdFtxt_Ms.disp_exist_formats); Begin
/*
 * This method displays the formatted expression, stored in the list
 * ldexpr_list, in the gadget EXIST_FORMAT.
 * The parameter active can have the following options:
 *	TRUE:	The formatted text expression is set to active.
 *	FALSE:	No formatted text expression is displayed.
 */

  fm_ptr = me->forms[0].form_ptr;
  size   = om$dimension_of( varray = me->ldexpr_list );

  /* reset list to null */
  FIfld_set_list_num_rows( fm_ptr, EXIST_FORMAT, 0, 0 );

  for( i=0; i<size; i++ ){
    sprintf( full_str,"%s: \"%s\", %s", me->ldexpr_list[i].formatname,
					me->ldexpr_list[i].string,
					me->ldexpr_list[i].params );
    FIfld_set_list_default_text( fm_ptr, EXIST_FORMAT, i, 0, full_str, FALSE);
    if( i == 0 && active ){
      /*
       * create active form expression
       */
      status = 
      om$send(msg = message VDCmdFtxt.set_ldexpr_active( sts, i ),
	      targetid = my_id );
      as$status();
    }
  }
  *sts = MSSUCC;
  End
  return( status );
}


/************************************************************************/
/*	METHOD	disp_exist_macros					*/
/************************************************************************/

method	disp_exist_macros( long * sts )
{
int	msg, status = OM_S_SUCCESS;
struct	GRid	format_obj;
IGRint	i, first;
IGRchar	classname[TEXT_SIZE];
DIint	nb_macros;
DIchar	**macros;
DIgrid	*macro_ids;
char	*fm_ptr;

  SetProc(VDCmdFtxt_Ms.disp_exist_macros); Begin
/*
 * This method read all macro definitions which has formatted text expressions
 * and display them in the gadget MACRO_LIST
 */

  *sts = MSSUCC;
  nb_macros = 0;
  macros    = NULL;
  macro_ids = NULL;

  fm_ptr = me->forms[0].form_ptr;
  FIfld_set_list_num_rows( fm_ptr, MACRO_LIST, 0, 0 );

  format_obj.objid = NULL_OBJID;
  if( me->dir_name[0] != '\0' ){
    status = di$translate(objname = me->dir_name,
		  	  p_objid = &format_obj.objid,
			  p_osnum = &format_obj.osnum );
    if( !(status & 1) ){
      status =
      di$mkdir(	dirname = me->dir_name,
		p_dirid = &format_obj.objid,
		p_osnum = &format_obj.osnum );
    }
  }

  if( format_obj.objid == NULL_OBJID ){
    /* no directory available */
    return( OM_S_SUCCESS );
  }

  /* find all defined macro groups */
  status = 
  om$send(msg = message IGRdir.dump(	&msg,
					"*",
					NULL,
					&macros,
					&macro_ids,
					&nb_macros,
					0 ),
	  targetid = format_obj.objid,
	  targetos = format_obj.osnum,
	  senderid = NULL_OBJID );
  as$status(action = GOTO_VALUE, value=wrapup);

  first = TRUE;
  for( i=0; i<nb_macros; i++){
    /* test object class */
    om$get_classname(	osnum   = macro_ids[i].osnum,
			objid   = macro_ids[i].objid,
			classname = classname );
    if( strcmp( classname, "ACrg_collect" ) == 0 ){
      /*| class equal to ACrg_collect */
      continue;
    }
    if( first ){
      FIg_set_text( fm_ptr, MACRO_LIST, macros[i] );
      first = FALSE;
    }
    FIfld_set_list_default_text( fm_ptr, MACRO_LIST, i, 0, macros[i], FALSE);
  }

  /* free memory of dump */
wrapup:
  di$free( lines = macros, count = nb_macros );
  if( nb_macros ) DIfree( macro_ids );

  End
  return( OM_S_SUCCESS );
}

/************************************************************************/
/* 	METHOD	set_ldexpr_active					*/
/************************************************************************/

method set_ldexpr_active(	long * sts;
				int index )
{
int	status = OM_S_SUCCESS;
IGRint	ld_size;

  SetProc(VDCmdFtxt_Ms.set_ldexpr_active); Begin
/*
 * This method create a active formatted test from the ldexpr_list.
 * The active formatted text is equal to the array index "index".
 * The following actions are taken place:
 *	Set the valus to the form expression structure,
 *	Clear form gadgets,
 *	Create formatted text in predefined gadgets.
 */

  *sts  = MSSUCC;

  index = (index>0) ? index : 0 ;
  ld_size = om$dimension_of( varray = me->ldexpr_list );

  if( index < ld_size ){
    /*| found in macro_list */
    strcpy( me->form_expr.formatname, me->ldexpr_list[index].formatname );
    strcpy( me->form_expr.string, me->ldexpr_list[index].string ); 
    strcpy( me->form_expr.params, me->ldexpr_list[index].params ); 

    me->form_expr.expr_id.objid = me->ldexpr_list[index].expr_id.objid;
    me->form_expr.expr_id.osnum = me->ldexpr_list[index].expr_id.osnum;

    /* update TXT_OUTPUT */
    status =
    om$send(msg = message VDCmdFtxt.txt_output( sts ),
	    targetid = my_id );
    as$status( action = RET_STATUS );
    
    if( me->mytype == VD_CREATE_FORMAT ){

      /* update FORMAT_OUTPUT */
      status =
      om$send(msg = message VDCmdFtxt.format_output( sts ),
	      targetid = my_id );
      as$status( action = RET_STATUS );

      FIg_set_text( me->forms[0].form_ptr, EXPR_NAME, me->form_expr.formatname);
    }
  }

  *sts = MSSUCC;
  End
  return( status );  
}

/************************************************************************/
/*	METHOD	create_format						*/
/************************************************************************/

method create_format(	long * sts;
			struct VDldline_expr * expr )
{
int	status = OM_S_SUCCESS;

  SetProc(VDCmdFtxt_Ms.create_format); Begin
/*
 * This method write a format in the directory system.
 */

  *sts = MSSUCC;

  if( !expr ){
    /* no expression */
    return(OM_S_SUCCESS );
  }

  status = VDSwrite_formats(	expr->formatname,
				expr->string,
				expr->params,
				me->macro_name,
				TRUE );	/* override option */
  as$status();
 
  End 
  return( status );
}

end implementation VDCmdFtxt;
