
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:57 $
$Locker:  $
*/

#ifndef HStl_element_include
#define HStl_element_include 1

/*
 * HStl_element.h contains definitions of element-specific tiler variables.
 */

#include "hrmipmap.h"

/*
 * Facet types.
 */

#define	SMOOTH_SHADE		1
#define	CONST_SHADE		2
#define	AREA_FILL		3
#define	RASTER_EDGES		4
#define	REV_EDGES		5
#define	POLYLINE		6
#define	FEM_TILE		7
#define	RENDERED		8
#define	FIND_MIN_X		9
#define FEM_MESH		10

/*
 * Back-plane culling flags.
 */

#define HS_CULL_NONE		0
#define HS_CULL_POSITIVE	1
#define HS_CULL_NEGATIVE	2


/*
 * Per-element rendering parameters.
 */

struct HS_element_rendering_parms
	{
	IGRint			color;			/* Color index                    */
	IGRint			finish;			/* Phong exponent                 */
	IGRdouble		spec_refl;		/* specular reflection coeff      */
	IGRdouble		diff_refl;		/* specular reflection coeff      */
	IGRdouble		transparency;		/* transparency coefficient       */
	struct HRtexture_list	*surface_texture;	/* texture map info               */
	IGRint			texture_orientation;	/* orientation of the surface tex */
	};


/*
 * FEM contour tile tiling parameters.
 */

struct HS_fem_parms
	{
	IGRdouble		A, B, C;		/* forward-diff coefficients	*/
	IGRboolean		triangle;		/* triangular tile flag		*/
	};


/*
 * Element-specific tiling parameters.
 */

struct HS_element_parms
	{
	unsigned int		color;			/* color of the object		*/
	unsigned int		hidden_color;		/* hidden color of the object	*/
	IGRint			visible_weight;		/* weight of visible lines	*/
	IGRint			hidden_weight;		/* weight of hidden lines	*/
	
	/*
	 *  RHL/LVHL style stuff
	 */
	 
	IGRdouble		v_pattern[9];		/* length of each run of a	*/
	IGRdouble		h_pattern[9];		/*   pattern in milimeters	*/
	IGRchar			v_pat_on_off;		/* TRUE if the pattern starts	*/
	IGRchar			h_pat_on_off;		/*   in the on state		*/
	IGRchar			visible_style;		/* The style pattern index for	*/
	IGRchar			hidden_style;		/*   for visible and hidden	*/
	
	
	IGRboolean		delete;			/* delete flag			*/
	IGRdouble		ele_clip_range[6];	/* clip range in dits		*/
	IGRint			facet_type;		/* facet type flag		*/
	IGRdouble		facet_normal[3];	/* scaled facet normal		*/
	IGRdouble		unscaled_facet_normal[3];	/* unscaled facet norm	*/
	IGRboolean		front_facing_facet;	/* facet normal direction flag	*/
	IGRboolean		doing_vertex_normals;	/* vertex normal calc flag	*/
	IGRboolean		culling_back_planes;	/* back plane cull flag		*/
	IGRboolean		marking_edges;		/* edge-marking flag		*/

	IGRdouble		interp_tol;		/* srf interpolate/evaluate tol	*/
	IGRdouble		basis_tol;		/* parameter basis tolerance	*/
	IGRdouble		dis_tol;		/* world distance tolerance	*/
	struct IGRbsp_surface	*surf_geom;		/* surface geometry pointer	*/
	struct HS_fem_parms	fem_parms;		/* FEM tiling parameter struct	*/
	struct HS_element_rendering_parms
				*render_parms;		/* rendering parameter pointer	*/
	IGRuint	 		red,green,blue;		/* color values for psuedo color*/
	IGRuint			color_logical;		/* Slot in the table of color   */
	};

extern struct HS_element_parms	element_parms;

struct fem_rgb
{
	IGRuint		red,green,blue,slot;		/* color of the object		*/
};

#define MAX_NUM_FEM_SHADES   20
extern struct fem_rgb	fem_column[MAX_NUM_FEM_SHADES];
extern int 		fem_background;
extern int 		fem_meshcolor;

#endif
