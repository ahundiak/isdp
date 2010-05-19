/* $Id: SMsection.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdinclude / SMsection.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMsection.h,v $
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

/* File SMCmdSect.h : Definition for CO of calculation section  */

#ifndef SMsection_def_include

#define SMsection_def_include

/* Type of command */

#define PLACE  0
#define MODIFY 1

/* Gadget definition */

#define G_TITLE       11
#define G_MODE_LIST   12
#define G_COMP        26
#define G_COMP_NAME   27
#define G_END_OFFSET  14
#define G_X_AXIS      15
#define G_Y_AXIS      16
#define G_Z_AXIS      17
#define G_SECT_LIST  18
#define G_NB_SECT_TEXT 19
#define G_NB_SECT     20
#define G_FROM_FRAME  21
#define G_FR_DX       23
#define G_TO_FRAME    22
#define G_TO_DX       24
#define G_NB_SECT_LAB 25
#define G_LOCATE_FR   29

/* Some Return state */
#define LOCATE_COMP     500
#define LOCATE_FR       501
#define RELOCATE_OBJ    502
#define NO_OBJ_LOCATED  503
#define TOO_MUCH_OBJECT 504

struct SMsect_int{
	IGRdouble	pos_on_axis; /* position of the curves */
	IGRdouble	cv_area; /* area of the curves */
	int		nb_cv; 	/* nb intersection curves*/
	struct GRid	*curves;	/* gpe of curves intersections */
	
};

struct SMsectdef{
	struct GRobj_env	coord_syst;   /* cs of the plane def */
	struct GRobj_env	solid;   /* solid where sections are defined*/
	char			axis;	      /* axis for the plane */
	double			first_pos;   /* initial pos for the planes */
	double			incr;         /* increment for the planes */
	double			last_pos;     /* pos of the last plane  */
	int			nb_pos; /* nb of plane regularly spaced */
};
struct SMVolSect{
	struct SMsectdef	sectdef;   /* cs of the plane def */
	int			nb_planes;    /* nb of plane		*/
	int			nb_alloc;  /* nb of allocated sect_int*/
	int			*tab;/* index of ordered cv */
	struct SMsect_int	*sect_int;	
};


/* 
   last_pos is normally pos_on_axis + (nb_pos-1)*increment 
   or last pos of the volume if last plane is not defined on this end
   (cf spec). sect_int are filled in the order of construction planes.
   If there is no intersection curves, or the curve is deleted,
   sect_int[k].curves is deallocated and tab is reorder (nb_planes decremented).
   if a curve is added tab is reorder (reallocated if needed) and nb_planes
   is increased. When we need to access sect_int, we must index it with tab[k].
   
*/



#endif

