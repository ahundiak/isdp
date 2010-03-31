
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hsdisplay_include
#define hsdisplay_include 1
/*
 * hsdisplay.h contains all the variables and definitions that are used
 * only in the display segment of HSURF.
 */


/* 
 * FEM trapezoid edge-marking flags.
 */

#define RIGHT_EDGE	1
#define	TOP_EDGE	2
#define BOTTOM_EDGE	4
#define LEFT_EDGE	8


/*
 *  Data structure for trapezoid
 */

struct	trapezoid
	{
	long		id;
	long		ya;
	long		yb;
	long		x0;
	long		x1;
	unsigned long	z0;
	unsigned long	z1;
	long		x2;
	long		x3;
	unsigned long	z2;
	unsigned long	z3;
	unsigned char	shade0;
	unsigned char	shade1;
	unsigned char	shade2;
	unsigned char	shade3;
	};

/*
 *  Data structure for trapezoid
 */

struct	hsfem_tritrap
	{
	long		id;
	long		ya;
	long		yb;
	long		x0;
	long		x1;
	unsigned long	z0;
	unsigned long	z1;
	long		x2;
	long		x3;
	unsigned long	z2;
	unsigned long	z3;
	int		shade0[3];
	int		shade1[3];
	int		shade2[3];
	int		shade3[3];
	};

/*
 *  Data structure for FEM trapezoid
 */

struct	hsfem_trapezoid
	{
	long		id;			/* contains coded edge marks	*/
	long		ya;
	long		yb;
	long		x0;
	long		x1;
	long		x2;
	long		x3;
	long		u0;
	long		u1;
	long		u2;
	long		u3;
	long		v0;
	long		v1;
	long		v2;
	long		v3;
	unsigned long	z0;
	unsigned long	z1;
	unsigned long	z2;
	unsigned long	z3;
	unsigned char	shade0;
	unsigned char	shade1;
	unsigned char	shade2;
	unsigned char	shade3;
	};


#define	HR_NORMAL_SIZE	16

typedef	short	HRnormal;

struct HRspan_trapezoid
	{
	struct HRspan_trapezoid			*nexty;
	int					y_lo;
	struct HRspan_trapezoid			*nextz;
	struct HRspecial_rendering_parms	*attr;
	int					x_max;
	int					y_hi;
	int					dy_lo_dx, dy_hi_dx;
	double					z_lo, z_hi, dz_lo_dx, dz_hi_dx, dz_dy;
	double					w_lo, w_hi, dw_lo_dx, dw_hi_dx, dw_dy;
	HRnormal				nx_lo, ny_lo, nz_lo;
	HRnormal				nx_hi, ny_hi, nz_hi;
	HRnormal				dnx_lo_dx, dny_lo_dx, dnz_lo_dx;
	HRnormal				dnx_hi_dx, dny_hi_dx, dnz_hi_dx;
	struct HRspan_deltas			*deltas;
	struct HRtrapezoid_uv			*tparms;
	};

struct HRspan_deltas
	{
	HRnormal		dnx_dy, dny_dy, dnz_dy;
	HRnormal		front_facing;
	};

typedef	float	HRuv;
	
struct	HRtrapezoid_uv
	{
	HRuv	u_lo, u_hi, du_dx, du_dy, du_lo_dx, du_hi_dx;
	HRuv	v_lo, v_hi, dv_dx, dv_dy, dv_lo_dx, dv_hi_dx;
	};
	
struct	HRtexture_interp_parms
	{
	double	matrix[9];
	};
	
struct HRspan_intersect
	{
	struct HRspan_intersect	*next;
	struct HRspan_trapezoid	*t1, *t2;
	int			y;
	};

/*
 * Data structures for polylines
 */

struct	polyline_vertex
	{
	long		x;
	long		y;
	long		z;
	};

#endif
