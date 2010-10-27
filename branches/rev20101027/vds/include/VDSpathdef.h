/* $Id: VDSpathdef.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSpathdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSpathdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
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

#ifndef VDSpathdef_include
#define VDSpathdef_include

/**********************************************/
/*
/* 	Definition of the constants used
/* 	in user_path.
/*
/**********************************************/

#define REF_PATH	0
#define MAIN_PATH	1
#define SEARCH_PATH	3

#define MY_MAX		120
#define NAME_MAX	16
#define MY_PATH_MAX	100

					/* PATH_MAX	256 */
#define SYMB_VAL	5
#define MAX_FIELD	60
#define LAYER_CHAR	50		/* LAYER_CHAR   52 */
#define SYMB_CHAR	30		/* SYMB_CHAR	32 */


struct txt_symb 
 {
	char			color[SYMB_CHAR];
	char			style[SYMB_VAL];
	char			layer[SYMB_VAL];
	char			weight[SYMB_VAL];
	char			layer_name[LAYER_CHAR];
 };

struct constr_path
 {
 	char			path[MY_PATH_MAX];
	char			name[NAME_MAX];
 	struct  txt_symb	symbology;
 };

struct current_path
 {
   char				reference_path[DI_PATH_MAX];
   struct constr_path		main_cst_path;
   struct constr_path		search_cst_path;
 }; 

#endif

