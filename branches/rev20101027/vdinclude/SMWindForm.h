/* $Id: SMWindForm.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMWindForm.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMWindForm.h,v $
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

/* Defined for command objects of Wind Area Polygon */

#ifndef SMWindForm_include
#define SMWindForm_include

/* Type of commands */
#define PLACE  0
#define MODIFY 1

/* Compart constant */
#define SM_VOL_MAX_ATT 10

/* Response to state in form */

#define LOCATE_POLY       501 
#define RELOCATE_OBJ      502
#define TOO_MUCH_POLY     503
#define NO_OBJ_LOCATED    504


  
/* Gadget for the first form (compart form)*/
#define G_TITLE        11
#define G_NAME         13
#define G_DESC         15
#define G_POLY_LIST    17
#define G_ADD          22
#define G_REMOVE       26



/* Index of each attribute */
#define NB_POLY_LIST_COLUMN 6

#define GI_NAME         0
#define GI_DESC         1     
#define GI_VZ           2
#define GI_SHAPE_COEF   3
#define GI_CONST_COORD  4
#define GI_NO           5

/* Buffer structure for a volume and his attributes */
struct Wind_Polygon
{
  struct GRid id;      /* Id of the polygon  */
  struct GRmd_env env; /* Env of the polygon */ 
  char name[256];     /* Split name of the polygon */
  struct ACrg_coll ACrg[SM_WIND_NB_MAX_ATTR]; /* Attribut for this polygon*/
  int nb_attr;         /* Number of attribut for this polygon */
};

#endif
