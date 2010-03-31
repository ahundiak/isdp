
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

#define VERTS_PER_EXTENT 55

#define	VERT_LIST	1
#define	BUST_LIST	2

/* Data structures used in the tesselation algorithm.
 * Put together 2/90 by M. R. Giesy
 */

struct	HSshd_vertex
{
	struct	HSshd_vertex	*flink;		/* forward link */
	struct 	HSshd_vertex	*blink;		/* backward link */
	double			coord[4];	/* up to 4d - homogeneous coordinates */
	union {
		double	intensity[3];		/* FEM case -- shade, u, v.  Other - [0] used for percent */
		double	normal[3];		/* rendering - vertex normal */
	} illum;
	int		mrk;			/* contains FEM natural edge marks */
};

struct	HSshd_edge {
	
	struct	HSshd_vertex	*v0, *v1;
};


