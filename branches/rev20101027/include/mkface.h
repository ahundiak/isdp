/* $Id: mkface.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / mkface.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: mkface.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

#ifndef mkface_include
#define mkface_include

#define  MACRO_NAME    "mkface"     /* Name of the macro                      */
#define  MAX_TEMPLATE   12          /* Number of template of the macro        */
#define  NB_FEET       1            /* Number of feet of the macro            */

/*
 * Definition of the names of the objects of the macro
 */

#define  BASE_SURF  "BSF"    /* Base of the support face                */

char *template_name[MAX_TEMPLATE];/* Names of the templates of the macro     */
char *feet_names[NB_FEET];        /* Names of the feet of the macro          */
struct GRid temp_obj[MAX_TEMPLATE];/* Template objects of the macro          */
GRobj  macro_def_id;             /* Identifier of the macro definition      */
struct GRid CI_MACRO_ID;         /* object of the cimacro                   */
 
#endif

