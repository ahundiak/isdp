/* $Id: exp_util.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc / exp_util.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: exp_util.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*

Name
  exp_util.I

Notes
  Changed DIgive_output method.  Storing prefix (leading blanks) before
  calling EXPBuildFormula.  Conacatenate the output "formula" of EXPBuildFormula
  with the prefix, to get complete indented name.  Return this as the new
  output formula.

Revision
 
	06/28/94	rmn	
*/

class implementation expression;

/* from interface import wakeup; */

#include <tools.h>
#include <stdio.h> 
#include <string.h> 
#include <OMminimum.h>
#include <OMmacros.h>
#include "exproto.h"
#include "expression.h"
#include "DIdef.h"

#define AS_DEBUG

method DIgive_output ( char *formula )
{
  char my_name [DI_PATH_MAX];
  char prefix [DI_PATH_MAX];
  int i = 0, max_length = DI_PATH_MAX;
  
  /*
   * Do we need to convert the syntax to a 2.1 format?
   */  
  om$send( msg = message expression.convert_to_new_syntax (),targetid = my_id );

/*
 * Store prefix (leading blanks for indentation of output)
 */
  strcpy ( prefix, formula );

  while( prefix[i] != '\0' && prefix[i] == ' ')
    i++;
  prefix[i]  = '\0';

  strcpy ( my_name, formula );
  EXPBuildFormula ( my_name, my_id, me->pretty_print, me->value, formula );
  
/* If string is too long, print error message */
  if( strlen( prefix ) + strlen( formula ) + 1 > DI_PATH_MAX )
  {
	/* 
	 * max_length = No of characters to concatenate with prefix to get 
	 * full name 
	 */
	max_length = DI_PATH_MAX - strlen(prefix) - 1;
	UI_status("String terminated : Too long");
  }
  strncat( prefix, formula, max_length );
  strcpy( formula, prefix );
  
  return EXP_S_SUCCESS;
}


end implementation expression ;
