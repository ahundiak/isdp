/* $Id: vds.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* I/VDS
 *
 * File:        $VDS/include/vds.h
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
 *	$Log: vds.h,v $
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
 * Revision 1.2  1996/03/05  12:28:20  pinnacle
 * Replaced: include/vds.h for:  by svkadamb for vds.240
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
 */

/* ----------------------------------------
 * Protoypes
 */

#ifndef vd_vds_include
#       define vd_vds_include

#define VD_RJT_MOVEON		1000
#define	VD_BACKUP		2000

/*
 * Structure defining a VDS feature : 
 */
struct VD_s_objDef {
        long    info ;          /* Message key of object info   */
	int	type ;
} ;
typedef struct VD_s_objDef VDobjDef ;

#endif /* vd_vds_include */
