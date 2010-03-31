
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hstiler_include
#define hstiler_include 1

/*
 * hstl.h contains those definitions and structures that are used only in
 * the tiling section of HSURF.
 */


/*
 * HSURF tiler DEBUG codes.
 */

#define DEBUG_OUTPUT	0
#define DEBUG_EMS	0
#define DEBUG_CURVE	0
#define DEBUG_SURF	0
#define DEBUG_BOUND	0
#define PLOT_BOUNDS	0
#define VIEW_DYN_DEBUG	0


/*
 * HSURF tiler point structure.
 */

struct HSpoint
 {
   IGRdouble	u, v;
   IGRdouble	x, y, z, w;
   IGRdouble	nx, ny, nz;			/* FEM coding: nx=shade, ny=edge mark */
   IGRboolean	mark;
   struct
      HSpoint	*next, *next_along_side;
 };


/*
 * HSURF tiler boundary structure.
 */

struct HSbound
 {
   struct
      HSpoint	*start_pt,
		*nxt_last_pt,
		*end_pt;
   struct
      HSbound	*next;
   IGRboolean	been_parent;
 };


/*
 * HSURF tiler intersection structure.
 */

struct HSxsect
 {
   IGRboolean	is_start;
   IGRdouble	sort_key;
   IGRshort	side_cut;
   struct
      HSpoint	*bndry;
   struct
      HSbound	*bnd_hdr;
   struct
      HSxsect	*other_end;   
   struct
      HSxsect	*next;
 };


/*
 * HSURF tiler vertex list structure.
 */

struct	HSvertex
	{
	IGRdouble	coord[4];	/* point coordinates		     */
	IGRpoint	norm;		/* normals			     */
	IGRdouble	u, v;		/* parametric coord' of this vert    */
	struct HSvertex	*next;		/* link to next point		     */
	short		edge_flag;	/* FEM: TRUE if this edge is natural */
	short		percent;	/* FEM: color percentage	     */
	};


/*
 * HSURF tiler loop list (polygon) structure.
 */

struct	HSloop
 {
   struct
      HSvertex	*loop;			/* link to vertex on loop	     */
   struct
      HSloop	*next;			/* link to next loop		     */
 };


/*
 * HSURF tiler buffer structure.
 */

struct HSbufptr
 {
   char		*buffer, *ele_ptr;
   int		num_left, ele_size;
   struct
      HSbufptr	*next;
 };


/*
 * HSURF tiler NULL structure definitions.
 */

#define	NIL_BOUND	(struct HSbound *)	0
#define	NIL_POINT	(struct HSpoint *)	0
#define	NIL_XSECT	(struct HSxsect *)	0
#define	NIL_VERTEX	(struct HSvertex *)	0
#define	NIL_LOOP	(struct HSloop *)	0
#define	NIL_BUFPTR	(struct HSbufptr *)	0

#endif

struct HSpb_master
	{
	int			flink;	
	int			blink;
	union
		{
		double	xendpt;
		int	flag[2];
		}		f1;
	double			pt[5];  /* x,y,z,w, i */
	double			u_pt, v_pt; /* (u,v) value of vertex, for FEM shading */
	int			mrk;
	double			u, v;	/* (u,v) for texture */
	};


struct HSpb_edge {
 	double	x0;
	double	x1;
	double	y0;
	double	y1;
	double	zslope;	/* yz slope */
	double 	islope; /* yi slope */
	int	mesh_mark; /* marks a mesh line for FEM rasterizing */
	int	pad_to_56;
	double	u0;	  /* u,v points at edge endpoints for FEM, */
	double 	u1;	  /* x and y components of endpoint normals for Phong/Watkins rendering mode */
	double	v0;
	double	v1;
	double	nz0, nz1;	/* z components of normals for Phong/Watkins */
	double  u0_texture, u1_texture;
	double  v0_texture, v1_texture;
	double	w0, w1;		/* w at each endpoint for Phong/Watkins */
	};


