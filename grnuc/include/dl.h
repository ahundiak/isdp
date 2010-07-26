#if !defined( dl_include )
#define dl_include 1

/****
Depends on:

   wl.h
   igrtypedef.h
   igr.h

****/

#if !defined( FALSE )
#define FALSE	0
#endif

#if !defined( TRUE )
#define	TRUE	1
#endif

#define	DL_MAX_PIPES	50	/* max pipes allowed */

#define	DL_MAX_ORDER	16	/* Maximum order of a bspline curve */

/* Geometry Pipeline Operation modes */
#define	DL_ORTHO_PIPE		0x00000001	/* 3D parallel mode    */
#define	DL_PERSP_PIPE		0x00000002	/* 3D perspective mode */

/* Matrix multiplication types */
#define	DL_POST_MULTIPLY	0x00000001	/* postmultiply matrices */
#define	DL_PRE_MULTIPLY		0x00000002	/* pre-multiply matrices */

/* Feedback buffer header tags */
#define	DL_FB_LXYZ      (WLuint16) 0xfffe /* linestring 3D */
#define	DL_FB_PXYZ      (WLuint16) 0xfffc /* filled polygon 3D set */
#define	DL_FB_BSC_LXYZ  (WLuint16) 0xfff2 /* 3D Bspline curve */
#define	DL_FB_BSC_PXYZ  (WLuint16) 0xfff1 /* Bspline curve filled polygon */
#define	DL_FB_BSS_LXYZ  (WLuint16) 0xffed /* 3D Bspline surface */
#define	DL_FB_PNTXYZ    (WLuint16) 0xffd9 /* 3D Point String */

/* Feedback buffer flags */

#define	DL_FB_OVERFLOW (WLint16) 0x8000	/* Feedback buffer overflow */
#define	DL_FB_BAD_DATA (WLint16) 0x4000	/* Feedback buffer incomplete */
					/* due to bad data */

/* Feedback Bspline element additional information tags */
#define	DL_FB_BS_SOLID_HOLE 1 /* Category: Solid or Hole */
#define	DL_FB_BS_BOUNDARY   2 /* Category: curve/surface boundary */
#define	DL_FB_BS_ATTRIBUTE  3 /* Category: attributes for span */

/* Drawing options flags */
#define DL_OPT_NONE		0x00000000
#define DL_OPT_DONT_CLIP	0x00000001  /* don't clip before displaying     */
#define DL_OPT_DONT_XFORM	0x00000002  /* don't xform before displaying    */
#define DL_OPT_FILL		0x00000004  /* solid fill                       */
#define DL_OPT_BOUNDARY		0x00000008  /* draw surface boundaries          */
#define DL_OPT_CONVEX		0x00000010  /* polygons are only convex         */
#define DL_OPT_BASE_MODE        0x00000060  /* mask to isolate base mode bits   */
#define DL_OPT_BASE_NOOP        0x00000000  /* don't change the base planes     */
#define DL_OPT_BASE_DRAW	0x00000020  /* draw into the base planes        */
#define DL_OPT_BASE_ERASE	0x00000040  /* erase the base planes            */
#define DL_OPT_HILITE_MODE      0x00000180  /* mask to isolate hilite mode bits */
#define DL_OPT_HILITE_NOOP      0x00000000  /* don't change the hilite plane    */
#define DL_OPT_HILITE_DRAW	0x00000080  /* draw into the hilite plane       */
#define DL_OPT_HILITE_ERASE	0x00000100  /* erase the hilite plane           */
#define DL_OPT_USE_LAST_SYMB    0x00000200  /* use the last symbology specified */
                                            /* to the pipeline                  */
#define DL_OPT_LOCPLOT_MODE     0x00000400  /* Special processing for local plot*/

/* Error Messages */
#define DL_SUCCESS                      0x00000000
#define DL_CANNOT_INITIALIZE            0x00000001
#define DL_BAD_PIPELINE_TYPE            0x00000002
#define DL_BAD_WINDOW_NUMBER            0x00000003
#define DL_BAD_PIPELINE_ID              0x00000004
#define DL_BAD_PARAMETER                0x00000005
#define DL_BAD_MULT_TYPE                0x00000006
#define DL_BAD_DRAW_OPTIONS             0x00000007
#define DL_BAD_COLOR_REF                0x00000008
#define DL_BAD_WEIGHT                   0x00000009
#define DL_BAD_STYLE                    0x0000000A
#define DL_FEEDBACK_OVERFLOW            0x0000000B
#define DL_BAD_POLYGON                  0x0000000C
#define DL_NO_MORE_PIPES                0x0000000D
#define DL_ERROR                        0x0000000E
#define	DL_ILLEGAL_BSPLINE_ORDER        0x0000000F
#define DL_CANT_ALLOC_TEMP_MEM          0x00000010
#define DL_CANT_SPLIT_BEZIER            0x00000020
#define DL_BSPLINE_ERROR                0x00000030
#define DL_FEEDBACK_NOT_ALLOWED         0x00000040

/* attribute bundle struct for 3D Bspline Curve drawing */
struct DLattr_bundle
{
   int flags;
   WLcolorref color;
   int lstyle;
   WLuint16 blend;
   int weight;
};

/* Stuff for the triangulator --------------------- */
struct DLItri_point
    {
    float     x, y, z;
    };

struct DLItri_color
    {
    float     red;
    float     green;
    float     blue;
    };

struct DLItri_mesh
    {
    int                 numVerts;
    int                 numFacetNormals;
    struct DLItri_point *verts;
    struct DLItri_color *vColors;
    struct DLItri_point *vNorms;
    struct DLItri_color *fColors;
    struct DLItri_point *fNorms;
    };

/* Stuff for the triangulator --------------------- */

/* function prototypes */
#if defined(__STDC__) || defined(__cplusplus)
#define __(p) p
#else
#define __(p) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int DLcharacterize_matrix __((
   int pipe_id ));

extern int DLcreate_drawing_pipeline __((
   int type,
   WLuint32 lwin_no,
   int *p_pipe_id ));

extern int DLcreate_feedback_pipeline __((
   int type,
   double *buffer,
   int buf_size,
   int *p_pipe_id ));

extern int DLdelete_drawing_pipeline __((
   int pipe_id ));

extern int DLdraw_2D_line_string __((
   int pipe_id,
   double *points,
   int num_points,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt ));

extern int DLdraw_2D_point_string __((
   int pipe_id,
   double *points,
   int num_points,
   WLcolorref color,
   int lweight,
   int draw_opt ));

int DLdraw_2D_polygons __((
   int pipe_id,
   double *points,
   int *num_points,
   int num_polys,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt ));

extern int DLdraw_3D_line_string __((
   int pipe_id,
   double *points,
   int num_points,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt ));

extern int DLdraw_3D_line_string_f __((
   int pipe_id,
   float *points,
   int num_points,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt ));

extern int DLdraw_3D_point_string __((
   int pipe_id,
   double *points,
   int num_points,
   WLcolorref color,
   int lweight,
   int draw_opt ));

extern int DLdraw_3D_point_string_f __((
   int pipe_id,
   float *points,
   int num_points,
   WLcolorref color,
   int lweight,
   int draw_opt ));

int DLdraw_3D_polygons __((
   int pipe_id,
   double *points,
   int *num_points,
   int num_polys,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt ));

int DLdraw_3D_polygons_f __((
   int pipe_id,
   float *points,
   int *num_points,
   int num_polys,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt ));

extern int DLdraw_3D_curve __((
   int pipe_id,
   struct IGRbsp_curve *curve,
   int *attr_index,
   struct DLattr_bundle *attr_bundle,
   int bundle_size, 
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt ));

extern int DLdraw_surface __((
   int pipe_id,
   struct IGRbsp_surface *surf,
   int u_num_rules,
   int v_num_rules,
   double *u_rules,
   double *v_rules,
   int *u_num_bounds,
   int *v_num_bounds,
   double **u_bounds,
   double **v_bounds,
   WLcolorref color,
   int lstyle,
   WLuint16 blend,
   int lweight,
   int draw_opt ));

extern int DLexit __((
   void ));

extern int DLget_matrix __((
   int pipe_id,
   double *matrix ));

extern int DLget_viewport __((
   int pipe_id,
   double *xlo,
   double *ylo,
   double *zlo,
   double *xhi,
   double *yhi,
   double *zhi ));

extern void DLuse_gpipe __((
   void ));

extern int DLinitialize __((
   void ));

extern int DLmatrix_multiply __((
   int pipe_id,
   double *matrix,
   int mult_type ));

extern int DLpass_to_feedback __((
   int pipe_id,
   WLint16 tag,
   WLint16 flag,
   WLint32 data ));

extern int DLreset_feedback __((
   int pipe_id ));

extern int DLreset_matrix __((
   int pipe_id ));

extern int DLresize_feedback __((
   int pipe_id,
   double *buffer,
   int buf_size ));

extern int DLset_curve_max_points __((
   int pipe_id,
   int max_points ));

extern int DLset_z_depth ( int pipe_id, double z_depth );

extern int DLset_curve_tolerance __((
   int pipe_id,
   double world_tolerance,
   double device_tolerance ));

extern int DLset_matrix __((
   int pipe_id, 
   double *matrix,
   double *eye_in,
   double *vpn_in,
   double *vup_in ));

extern int DLset_viewport __((
   int pipe_id,
   double xlo,
   double ylo,
   double zlo,
   double xhi,
   double yhi,
   double zhi,
   double *vw_volume ));

extern int DLset_z_clipping __((
   int pipe_id,
   int nearz,
   int farz ));

extern int DLupdate_windowing_data __((
   int pipe_id,
   WLuint32 new_lwin_no ));

extern int DLreset_for_wireframe __((
   int pipe_id ));

extern int DLget_modelling_matrix __((
   int pipe_id,
   double *mod_matrix ));

extern int DLset_modelling_matrix __((
   int pipe_id,
   double *mod_matrix ));

extern int DLreset_modelling_matrix __((
   int pipe_id ));

#if defined( ENV5 )
extern int DLget_EG_data __((
   int pipe_id,
   int *vc_no ));

extern int DLget_GPIPE_data __((
   int pipe_id,
   int *gpipe_id ));
#endif

extern double	DLItri_magnitude( double *, double *, double * );
extern double	DLItri_magnitude_f( float *, float *, double * );
extern void	DLItri_cross( double *, double *, double * );
extern double	DLItri_dot( double *, double * );
extern void	DLItri_set_status( int );
extern void	DLItri_free_edges( void );

#if defined(__cplusplus)
}
#endif

#define DL_FLAG_ZBUFFER   0x00000001

void DLset_flag( int );
void DLclear_flag( int );
int  DLflag( int );

#undef __

#endif
