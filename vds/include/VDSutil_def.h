/* $Id: VDSutil_def.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / VDSutil_def.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSutil_def.h,v $
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

#ifndef VDSutil_def_include
#define VDSutil_def_include

#define PLAN	1
#define SURF	2
#define CURV	3
#define COMP_SF	4
#define SOL	5
#define E_ERROR	-1

/* 3 kinds of planes size (view scale indep.) */
#define SMALL_PL_SZ  -1
#define MEDIUM_PL_SZ  0
#define LARGE_PL_SZ  -2

/* 3 justifications available */
#define VD_PL_CENT	0
#define VD_PL_POS	1
#define VD_PL_NEG	2

/************************************************************************/

struct curve_info
  {
   IGRboolean 	done;	/* flag */
   double	pt1[3];	/* end point 1 */
   double	pt2[3];	/* end point 2 */
  };
struct pt_info
  {
    int		index_adj;
    int		index_end;
  };

/************************************************************************/


/* vd$cnst_txt_pt macro, definition of props */

#define VD_NO_DISP_TXT  0x0001   /* Don't display the text.  	*/
#define VD_NO_DISP_PT   0x0002   /* Don't display the graphic point. */

/* The following allows defining a justification */

#define VD_X_POS	0x0010		/*   X side */	  
#define VD_X_NEG	0x0020		/*  -X side */	  
#define VD_Y_POS	0x0040		/*   Y side */	  
#define VD_Y_NEG	0x0080		/*  -Y side */	  

/************************************************************************/

#endif
