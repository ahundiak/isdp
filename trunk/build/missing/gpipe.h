#ifndef GPIPE_H
#define GPIPE_H
/*   New Routine Name macros   */

#define	GPbsmaxpts		GPBsplineMaxPnts
#define	GPbstolerance		GPBsplineTol
#define	GPbsurf_tiler		GPBsplineTiler
#define	GPcharmatrix		GPCharMatrix
#define	GPcreate_fb		GPCreateFB
#define	GPcreate_win		GPCreateWin
#define	GPdelete		GPDelete
#define	GPenter			GPEnter
#define	GPexit			GPExit
#define	GPfeedback_passthru	GPPassthruFB
#define	GPgetmatrix		GPGetMatrix
#define	GPgetviewport		GPGetViewport
#define	GPinq_gpipe_status	GPInqStatus
#define	GPlinestr2d		GPLinestr2D
#define	GPlinestr2di		GPLinestr2DI
#define	GPlinestr2ds		GPLinestr2DS
#define	GPlinestr3d		GPLinestr3D
#define	GPlinestr3di		GPLinestr3DI
#define	GPlinestr3ds		GPLinestr3DS
#define	GPmap_2d_view		GPMapView2D
#define	GPmap_3d_ortho_view	GPMapOrthoView3D
#define	GPmap_3d_persp_view	GPMapPerspView3D
#define	GPmultmatrix		GPMultMatrix
#define	GPpolyfill2d		GPPolyFill2D
#define	GPpolyfill3d		GPPolyFill3D
#define	GPpoly_constshd		GPPolyConstShd
#define	GPpoly_smoothshd	GPPolySmoothShd
#define	GPputmatrix		GPPutMatrix
#define	GPputviewport		GPPutViewport
#define	GPreset_feedback	GPResetFB
#define	GPreset_matrix		GPResetMatrix
#define	GProtate2d		GPRotate
#define	GProtate_x		GPRotateX
#define	GProtate_y		GPRotateY
#define	GProtate_z		GPRotateZ
#define	GPscale2d		GPScale2D
#define	GPscale3d		GPScale3D
#define	GPset_light_source	GPSetLightSource
#define	GPset_ortho_view_vector	GPSetOrthoViewVector
#define	GPset_persp_eyepoint	GPSetPerspEyepoint
#define	GPset_scale_ratios	GPSetScaleRatios
#define	GPset_shade_table	GPSetShadeTable
#define	GPset_transparency	GPSetTransparency
#define	GPset_zbuffer		GPSetZbuffer
#define	GPset_zclip		GPSetZclip
#define	GPtranslate2d		GPTranslate2D
#define	GPtranslate3d		GPTranslate3D

/*   Geometry Pipeline Operation modes */

#define		GP_2D			0	/* 2D mode	       */
#define		GP_3D_PARALLEL		1	/* 3D parallel mode    */
#define		GP_3D_PERSPECTIVE	2	/* 3D perspective mode */

#define		GP_OFF		0
#define		GP_ON		1

#define		GP_NONRATIONAL	0	/* Nonrational Bsplines */
#define		GP_RATIONAL	1	/* Rational Bsplines    */

#define		GP_POSTMULT	0	/* postmultiply matrices */
#define		GP_PREMULT	1	/* pre-multiply matrices */

#define		GP_INTERSECT	0	/* intersect boundary and surface */
#define		GP_SUBTRACT	1	/* subtract boundary from surface */

#define		GP_WORLD	0	/* world coordinate system  */
#define		GP_DEVICE	1	/* device coordinate system */

#define		GP_MAX_VERTICES	10000	/* max matrix and viewport stack */

#define		GP_MAX_ORDER	16	/* Maximum order of a bspline curve */

#define		GP_Z_MIN_VALUE	0	   /* Minimum Z-buffer fill value */
#define		GP_Z_MAX_VALUE	0x7fffffff /* Maximum Z-buffer fill value */

/*   Shading parameters   */

#define		GP_MAX_LIGHT	8	/* Maximum light sources for shading */

#define		GP_LIGHT_DIRECTIONAL 0  /* directional light source */
#define		GP_LIGHT_POSITIONAL  1	/* point light source	    */

/*   Geometry Pipeline Feedback Buffer header tags.   */

#define		FB_LXY		0xffff	/* linestring 2D */
#define		FB_LXYZ		0xfffe	/* linestring 3D */
#define		FB_PXY		0xfffd	/* filled polygon 2D set */
#define		FB_PXYZ		0xfffc	/* filled polygon 3D set */
#define		FB_PXYZI	0xfffb	/* filled polygon w/ intensity */
#define		FB_PXYZC	0xfffa	/* constant shaded polygon */
#define		FB_TXY		0xfff9	/* filled 2D trapezoids */
#define		FB_TXYZ		0xfff8	/* filled 3D trapezoids */
#define		FB_TXYZI	0xfff7	/* filled trapezoid w/ intensity */
#define		FB_TXYZC	0xfff6	/* contant shade trapezoid */
#define		FB_BSC_LXY	0xfff5	/* 2D Bspline curve */
#define		FB_BSC_PXY	0xfff4	/* Bspline curve filled polygon */
#define		FB_BSC_TXY	0xfff3	/* Bspline curve filled trapezoid  */
#define		FB_BSC_LXYZ	0xfff2	/* 3D Bspline curve */
#define		FB_BSC_PXYZ	0xfff1	/* Bspline curve filled polygon */
#define		FB_BSC_TXYZ	0xfff0	/* Bspline curve filled trapezoid  */
#define		FB_BSC_PXYZC	0xffef	/* constant shaded polygons */
#define		FB_BSC_TXYZC	0xffee	/* constant shaded trapezoids  */
#define		FB_BSS_LXYZ	0xffed	/* 3D Bspline surface */
#define		FB_BSS_PXYZ	0xffec	/* Bspline surface filled polygon */
#define		FB_BSS_TXYZ	0xffeb	/* Bspline surface filled trapezoid  */
#define		FB_BSS_PXYZI	0xffea	/* polygon w/ intensity  */
#define		FB_BSS_TXYZI	0xffe9	/* trapezoid w/ intensity  */
#define		FB_BSS_PXYZC	0xffe8	/* constant shaded polygons */
#define		FB_BSS_TXYZC	0xffe7	/* constant shaded trapezoids  */
#define		FB_PXYZRGBS	0xffe6	/* smooth shaded RGB polygon */
#define		FB_PXYZRGBC	0xffe5	/* constant shaded RGB polygon */
#define		FB_TXYZRGBS	0xffe4	/* smooth shaded RGB trapezoid */
#define		FB_TXYZRGBC	0xffe3	/* constant shaded RGB trapezoid */
#define		BSC_FB_PXYZRGBS	0xffe2	/* smooth shaded RGB polygon */
#define		BSC_FB_PXYZRGBC	0xffe1	/* constant shaded RGB polygon */
#define		BSC_FB_TXYZRGB	0xffe0	/* smooth shaded RGB trapezoid */
#define		BSC_FB_TXYZRGBC	0xffdf	/* constant shaded RGB trapezoid */
#define		BSS_FB_PXYZRGB	0xffde	/* smooth shaded RGB polygon */
#define		BSS_FB_PXYZRGBC	0xffdd	/* constant shaded RGB polygon */
#define		BSS_FB_TXYZRGB	0xffdc	/* smooth shaded RGB trapezoid */
#define		BSS_FB_TXYZRGBC	0xffdb	/* constant shaded RGB trapezoid */
#define		FB_PNTXY	0xffda	/* 2D Point String */
#define		FB_PNTXYZ	0xffd9	/* 3D Point String */

/*   Feedback flags   */

#define		FB_OVERFLOW	0x8000	/* Feedback buffer overflow */
#define		FB_BAD_DATA	0x4000	/* Feedback buffer incomplete */
					/* due to bad data */

/*  Feedback Bspline element additional information tags  */

#define		FB_BS_SOLID_HOLE   1	/* Category: Solid or Hole */

#define		FB_BS_BOUNDARY	   2	/* Category: curve/surface boundary */

#define		FB_BS_ATTRIBUTE	   3	/* Category: attributes for span */


/*   Graphics Options flags  -  options that  apply to all graphics
 *   element routines (linestr, polyfill, bsplines) are in the low 16 bits,
 *   options that apply to an individual routine are in the high 16 bits.
 */

#define		GR_DONT_CLIP	0x00000001  /* don't clip linestr, poly etc */
#define		GR_DONT_XFORM	0x00000002  /* don't transform */
#define		GR_BS_BOUNDARY	0x00020000  /* Bspline stroke boundary */
#define		GR_BSC_CONSTANT 0x00040000  /* Bspline curve constant */
					    /* shading */
#define		GR_BSC_SOLID	0x00080000  /* Bspline curve solid fill */
#define		GR_BST_CONSTANT 0x00100000  /* Bspline surface tiler */
					    /* constant shading */
#define		GR_BST_SMOOTH	0x00200000  /* Bspline surface tiler smooth */
					    /* Gouraud shading */
#define		GR_BST_SOLID	0x00400000  /* Bspline surf tiler solid fill */
#define		GR_BST_TRANSP	0x00800000  /* Bspline tiler transparancy */
#define		GR_POLY_CONVEX  0x01000000  /* Polygons are convex only */
#define		GR_POLY_TRAP_FB 0x02000000  /* Feedback polygon trapezoids */
#define		GR_SHD_RGB	0x04000000  /* Shade color table in RGB */ 
#define		GR_CULL_BACKFACE 0x08000000 /* Cull backfaces */
#define		GR_SPECULAR	0x10000000  /* Use specular reflection */


#define		GP_DONT_CLIP	0x00000001  /* don't clip linestr, poly etc */
#define		GP_DONT_XFORM	0x00000002  /* don't transform */
#define		GP_BS_BOUNDARY	0x00020000  /* Bspline stroke boundary */
#define		GP_BSC_CONSTANT 0x00040000  /* Bspline curve constant */
					    /* shading */
#define		GP_BSC_SOLID	0x00080000  /* Bspline curve solid fill */
#define		GP_BST_CONSTANT 0x00100000  /* Bspline surface tiler */
					    /* constant shading */
#define		GP_BST_SMOOTH	0x00200000  /* Bspline surface tiler smooth */
					    /* Gouraud shading */
#define		GP_BST_SOLID	0x00400000  /* Bspline surf tiler solid fill */
#define		GP_BST_TRANSP	0x00800000  /* Bspline tiler transparancy */
#define		GP_POLY_CONVEX  0x01000000  /* Polygons are convex only */
#define		GP_POLY_TRAP_FB 0x02000000  /* Feedback polygon trapezoids */
#define		GP_SHD_RGB	0x04000000  /* Shade color table in RGB */ 
#define		GP_CULL_BACKFACE 0x08000000 /* Cull backfaces */
#define		GP_SPECULAR	0x10000000  /* Use specular reflection */

/*   Error Messages   */

#define		GP_WINDOW_NOT_DEFINED		-1
#define		GP_GPIPE_NOT_DEFINED		-2
#define		GP_FEEDBACK_OVERFLOW		-3
#define		GP_NO_DATA_FEDBACK		-4
#define		GP_STACK_OVERFLOW		-5
#define		GP_IFB_NOT_PRESENT		-6
#define		GP_WRONG_GPIPE_MODE		-7
#define		GP_CANT_ALLOC_POLYGON_MEM	-8
#define		GP_CANT_ALLOC_SCRATCH_MEM	-9
#define		GP_ILLEGAL_BSPLINE_ORDER	-10
#define		GP_CANT_SPLIT_BEZIER		-11
#define		GP_CANT_FIND_KNOT_INTERVAL	-12
#define		GP_VIEWPORT_TO_BIG		-13
#define		GP_CANT_ALLOC_ZBUF		-14
#define		GP_TO_MANY_POLY_VERTICES	-15
#define		GP_TOO_MANY_VERTICES		-15
#define		GP_NOT_ENOUGH_MESH_POINTS	-16
#define		GP_FB_RECEIVED_TERM		-17
#define		GP_NOT_ENOUGH_PLANES		-18
#define		GP_INVALID_DEPTH_CUE_PARAMS	-19
#define		GP_ILLEGAL_KNOT_VECTOR		-20
#define		GP_ILLEGAL_POLY_DEFINITION	-21
#define		GP_INTERNAL_ERROR		100

/*   Coordinate structures   */

typedef	struct
	{
	   double   x,y;		/* 2D coordinate (x,y) */
	} GPxy;

typedef	struct
	{
	   double   x,y,z;		/* 3D ortho coordinate (x,y,z) */
	} GPxyz;

typedef	struct
	{
	   float   x,y;			/* 2D coordinate (x,y) single prec */
	} GPxyF;

typedef	struct
	{
	   float   x,y,z;		/* 3D ortho coordinate (x,y,z) single */
	} GPxyzF;

typedef	struct
	{
	   int   x,y;			/* 2D integer coordinate (x,y) */
	} GPixy;

typedef	struct
	{
	   int   x,y,z;		/* 3D ortho integer coordinate (x,y,z) */
	} GPixyz;

typedef	struct
	{
	   double   x,y,z,w;		/* 3D persp coordinate (x,y,z,w) */
	} GPxyzw;

typedef struct
	{
	   double   x,y,z;		/* 3D coordinate with normals */
	   double   nx,ny,nz;
	} GPxyzn;

typedef struct			/* Bspline symbology attributes */
	{
	   int	flags;		/* bit 0 = 1 will stroke this curve portion */
	   int 	color;
	   int	lstyle;
	   int  wgt;
	   int 	blend;
	} GPattribute;

typedef struct
	{
	   int	no_pnts;		/* Bspline boundary values */
	   double *boundary;
	} GPboundary;

	
typedef struct			/* shading light source parameters */
	{
	    double lx,ly,lz;	/* light vector */
	    double intensity;	/* light intensity */
	    double pntrad;	/* point light source radius */
	    int	source;		/* 0=infinite light  1=point light */
	} GPlight;

typedef struct			/* shading light source parameters for RGB */
	{
	    double lx,ly,lz;	/* light vector */
	    double Ir, Ig, Ib;	/* light color/intensity */
	    double pntrad;	/* point light source radius */
	    int	source;		/* 0=infinite light  1=point light */
	} GPRGBlight;

#endif
