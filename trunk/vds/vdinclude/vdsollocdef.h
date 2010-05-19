#ifndef vdsollocdef_include
#define vdsollocdef_include

/*
 * relation of objects with solid. Input option while getting a list of objects
 * which have the following relation with solid.
 */
#define  VD_EL_INSIDE		0
#define  VD_EL_INSIDE_OVERLAP	1
#define  VD_EL_OVERLAP		2

/*
 * The objects are being obtained for the following purpose.
 */
#define  VD_LOCATE_WITH_SOLID	0	/* for locating objects. eg pocket menu
					   command */
#define  VD_LIST_OF_OBJS	1	/* just list of objects for further
					   processing. eg by model view     */


#endif
