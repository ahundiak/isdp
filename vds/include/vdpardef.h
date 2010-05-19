/* $Id: vdpardef.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* I/VDS
 *
 * File:        $VDS/include/vdpardef.h
 *
 * Description:
 *      This include file provides constants used 
 *      to review specific parameters of a component,
 *      to get the list of all parameters of a component,
 *      to get the list of user attributes of a 
 *      component, and to modify the user attributes.
 *
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdpardef.h,v $
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
 *      08/20/94        A. Zuurhout        Creation 
 *      09/03/94        Y. Zhu             Add EQ, == 
 */

/* ----------------------------------------
 * Protoypes
 */

#ifndef vd_pardef_include
#       define vd_pardef_include

/*
 * Attribute type VD_ATTRIB_DELETE is used to indicate to the 
 * vd$modUsrAttributes macro that the user attribute is to be deleted.
 */

#define  VD_ATTRIB_DELETE   0

/*
 * Object symbology definitions.
 */

#define		VD_str_symb_LEVEL		"level"
#define		VD_str_symb_COLOR		"color"
#define		VD_str_symb_WEIGHT		"weight"
#define		VD_str_symb_STYLE		"style"


#define		VD_cnt_qry_NONE			0	/* none */
#define		VD_cnt_qry_EQUAL		1	/* == */
#define		VD_cnt_qry_N_EQUAL		2	/* == */
#define		VD_cnt_qry_G_EQUAL		3	/* >= */
#define		VD_cnt_qry_L_EQUAL		4	/* <= */
#define		VD_cnt_qry_G_THAN		5	/* >  */
#define		VD_cnt_qry_L_THAN		6	/* <  */

#define         VD_str_qry_EQUAL		"EQ"	/* == */ 
#define         VD_str_qry_N_EQUAL              "NE"    /* != */
#define         VD_str_qry_G_EQUAL              "GE"    /* >= */
#define         VD_str_qry_L_EQUAL              "LE"    /* <= */
#define         VD_str_qry_G_THAN               "GT"    /* >  */
#define         VD_str_qry_L_THAN               "LT"    /* <  */

#define         VD_sym_qry_EQUAL		"=="	/* ER */ 
#define         VD_sym_qry_N_EQUAL              "!="    /* NE */
#define         VD_sym_qry_G_EQUAL              ">="    /* GE */
#define         VD_sym_qry_L_EQUAL              "<="    /* LE */
#define         VD_sym_qry_G_THAN               ">"     /* GT */
#define         VD_sym_qry_L_THAN               "<"     /* LT */

#endif /* vd_pardef_include */
