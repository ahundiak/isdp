/* $Id: SMgraph.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / SMgraph.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMgraph.h,v $
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


#ifndef SMgraph_include

#define SMgraph_include

/*
 * allocation constants
 */
#define MAX_ELTS	50
#define INCR_ALLOC	5

/*
 * definition of an intersection curve 
 *	- cv_geom must be free according to alloc flag :
 *			TRUE=BSfreecv FALSE= free)) 
 *	- sf1 = -1 for support and curve (because no verif on intersection)
 */

struct SMsfinters{
	int			sf1;	 /* index of the first surf */
	int			sf2;	 /* index of the second surf */
	struct GRid		cvint_id;/* id of the intersection curve */
	IGRboolean		alloc_flag; /* TRUE= alloccv, FALSE= malloc */
	struct IGRbsp_curve 	*cv_geom;/* geom of the curve */
};

/*
 * intersection curves on a surface
 */

struct SMsurf{
	int	nb_intcv; /* nb curve on that surf */
	int	*cv_index;/* curves index */
};

/*
 * definition of an elt of the graph
 */

struct gr_arc{
		int		cv; /* arc associe au sommet */
		int		pt; /*sommet du graphe */
		int		part_nb; /* if closed curve and 2 intpts ,there
					  are 2 arcs with same pt,cv*/
		int		nb_next;
		int 		next[4]; /* suivants sur cet arc max 4*/
		int		next_taken;/* init a 0*/
};

/*
 * intersection pts on a curve (the pts must be in order)
 */

struct SMcurve{
	int			nb_intpt;
	int			*pt_index;
        struct IGRbsp_curve     *cv_geom;/* geom of the curve */
};

/*
 * definition of an intersection pt
 */

struct SMinters{
	int	cv1;	/* index of the first curve of the surface*/
	int	cv2;	/* index of the second curve of the surface*/
	double	par1;	/* param on cv1 */
	double	par2;	/* param on cv2 */
	double	pt[3];
};

/*
 * definition of exact intersection pt on the surface
 */

struct SMIntOnSf{
	int			index;	/* index of the surface */
	int			typesf; /* type of the surface */
	struct  IGRbsp_surface	*geom;	/* geom of the surface */
	double			u_par;  /*  param of the intersection*/
	double			v_par;  /*     pt on the surface */
};

/*
 * definition of the exact intersection pt between 3 surfaces
 */

struct SMExactInt{
	struct SMIntOnSf	surf[3];  /* the 3 surfaces */
	double			point[3]; /* the exact intersection pt */
};

/*
 * mark for arc already taken
 */

struct mark{
	int	pt1;
	int	pt2;
	int	curve;
        int     part_nb; /* if closed curve and 2 intpts ,there
                                          are 2 arcs with same pt,cv*/
};

/*
 * def of an arc for a solid
 */

struct sl_arc{
	int	index_cv; /* curve between pt1 and pt2 */
	int	index_pt1;
	int	index_pt2;
        int     part_nb; /* if closed curve and 2 intpts ,there
	                        are 2 arcs with same pt,cv*/
	                                                          
};

struct one_loop{
	int	nb_edge;
	int 	*edge;
};

struct loop_on_surf{
	int		nb_loop;
	struct one_loop	*one_loop;
};

struct one_solid
{
  int nb_surf;
  int *surf_index; 
  int *loop_index;
};

#endif
