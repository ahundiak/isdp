/* $Id: SMStructSf.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMStructSf.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMStructSf.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
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
 * Revision 1.3  1996/01/23  06:40:48  pinnacle
 * Replaced: vdinclude/SMStructSf.h for:  by rgade for vds.240
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

/* 
 * I/VDS
 *
 * definition of gadget labels of the form SMStructSf
 */

#ifndef	SMStructSf_include
#define	SMStructSf_include


#define SM_MAINSF_MAX_ATTR	80

#define MAX_CHAR	256


/* Type of commands */

#define PLACE        0
#define MODIFY       1

/* Name of surface type */

#define TYPE_SURF_FILE "SurfType"

/* Response to state in form */

#define NO_OBJ_LOCATED   501
#define BEGIN_ATTR_FORM  503
#define BEGIN_GEOM_FORM  506
#define LOCATE_SURF      507 
#define RELOCATE_OBJ     508
#define ONLY_ONE_PART    509
#define READ_FROM_PDU    510
#define BEGIN_DATA_SEL   511
#define LOAD_DATA_SEL    512 

/* Main Gadgets */

#define GROUP_MAIN       113

#define G_NAME           13
#define G_DESCRIP        15
#define G_DENS           16
#define G_TYPE           21
#define G_CONSUME        28

/*  #define G_CALFLAG	 30   */

#define CALFLAG_NOTCREATED	-1


/* Gadget for selecting volumes, attributes, disp or geom_info */
#define GROUP_SELECT     38

#define G_USER_ATT       35
#define G_GEOM_INFO      23
#define G_LOCATE_SURF    17

/* Gadget for geometric information */
#define GROUP_GEOM     78

#define G_UNIT         55

#define G_COG_X        56
#define G_COG_Y        59
#define G_COG_Z        58

#define G_AREA         60    
#define G_WEIGHT       20

/* What is   form state */
#define GEOM_INFO   7


/* State of the surface in case of a modification */

#define NO_CHANGE       0
#define TO_CHANGE_STATE 0x0001
#define TO_REDISPLAY    0x0010
#define TO_RECOMPUTE    0x0100

#endif

