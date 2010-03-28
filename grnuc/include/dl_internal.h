#if !defined( dl_internal_include )
#define dl_internal_include

#if defined( ENV5 )
#include <gpipe.h>
#include <EG.h>
#endif

#if defined( OPENGL )
#include <GL/gl.h>
#include <GL/glu.h>
#endif

#define DLI_PI	3.14159265358979323846

/* maximum number of vertices that can be handled in the DLIbuf array */
#define DLI_MAX_VERTICES 1000

#define DLI_NUM_SAVED_POINTS 200

/*   Clipping parameters and pipe flag bits  */
#define DLI_CL_ZNEAR          0x00000001   /* clip z near plane */
#define DLI_CL_ZFAR           0x00000002   /* clip z far plane */
#define DLI_CL_IDENTITY       0x00000004   /* current identity matrix */
#define DLI_CL_MOD_IDENTITY   0x00000008  /* modelling matrix identity */
#define DLI_CL_NO_MOVE        0x00000010
#define DLI_CL_MATRIX_CHANGED 0x00000020

/* Feedback buffer pad size.  This is the number of */
/* quad words (doubles) in an individual request.   */
#define DL_FB_PAD2D 3
#define DL_FB_PAD3D 4

/* number of points to allocate on stack for float to double conversion */
#define DLI_NUM_STACK_DPOINTS 1000

#define DLItri_IN  0
#define DLItri_OUT 1

#define DLItri_ON_AEL    0x00000010
#define DLItri_LIVE_EDGE 0x00000020

#define DLItri_ORIGINAL_EDGE   0x00000000
#define DLItri_ADDED_EDGE      0x00000001
#define	DLItri_HORIZONTAL_EDGE 0x00000002

#define DLItri_LOCAL_MINIMUM 0x00000001
#define DLItri_LOCAL_MAXIMUM 0x00000002

#define DLItri_MONO_MADE 0x00000004

#define DLItri_HANDLED       0
#define DLItri_CANNOT_HANDLE 4

#define DLItri_OneKB   1024
#define	DLItri_SixtyKB 61440   /* sixty kilobytes: the "magic size" */
#define	DLItri_FourKB  4096    /* four kilobytes: the other "magic size" */

/* number of points in 60kb of memory */
#define	DLItri_NUM_VERTICES_IN_60KB (DLItri_SixtyKB / sizeof(struct DLItri_vertex))
#define DLItri_NUM_EDGES_IN_60KB      (DLItri_SixtyKB / sizeof (struct DLItri_edge))

/* number of bounds in 4kb of memory */
#define	DLItri_NUM_BOUNDS_IN_4KB      (DLItri_FourKB / sizeof(struct DLItri_loop))

/* number of Mono-polygon pointers in 4kb of memory */
#define	DLItri_NUM_PTRS_IN_4KB        (DLItri_FourKB / sizeof(struct DLItri_polygon_vert))

/* number of points in 8kb */
#define DLItri_NUM_VERTS_IN_8K        (8192 / sizeof(struct DLItri_point))
#define DLItri_NUM_VERTS_IN_56K       4778

#define DLItri_STAT_ALLOC_ERROR       100

#define DLItri_FABS(x)		(((x) > 0.0) ? (x) : (-(x)))
#define DLItri_WITHIN_TOLERANCE( y1, y2, tol )	( DLItri_FABS( ((y2) - (y1)) ) <= (tol) )

/* union used for feedback buffer processing */
union DLIfb_union
{
   double *d;
   WLint16 *s;
   WLint32 *i;
};

/* Viewport ranges */
struct DLviewport
{
   double xlo; /* viewport boundaries in screen coordinates */
   double xhi;
   double ylo;
   double yhi;
   double zlo;
   double zhi;
   double scalex, scaley, scalez;	/* perspective scale to viewport */
   double offsetx, offsety, offsetz;	/* persp offset to viewport */
};

/* B spline attributes for a pipeline */
struct DLbspline_attr
{
   int maxpts;       /* maximum points per bezier span */
   double world_tol; /* world tolerance */
   double dev_tol;   /* device tolerance */
};


/* Pipeline attributes */
struct DLpipeline
{
   int pipe_id; /* id of this pipeline */
   int type; /* pipe type DL_PERSP_PIPE or DL_ORTHO_PIPE */
   WLuint32 lwin_no; /* pipe attached to this window */
   WLhwin_no hwin_no; /* hardware window number */
   WLuint32 base_context_no;
   struct WLcontext_info base_context_info;
   int clip_flag; /* znear,zfar,shading ... clip parameters */
   int fb_size; /* feedback buffer size */
   int fb_index; /* index into feedback buffer */
   short fb_flag; /* flag word */
   double *fb_buf; /* feedback buffer */
   double matrix[16]; /* transformation matrix -row order */
   double viewing_matrix[16]; /* matrix set by DLset_matrix */
   double modelling_matrix[16]; /* matrix set by DLset_modelling_matrix */
   double eye[3]; /* perspective eye point */
   double vpn[3]; /* perspective view plane normal */
   double vup[3]; /* perspective view up vector */
   double vw_volume[6]; /* perspective view volume */
   double z_depth; /* z depth of the masterfile view volume */
   int matmap[4]; /* matrix characterization map per column */
   struct DLviewport view; /* viewport specs */
   struct DLbspline_attr bspl; /* Bspline parameters */
   WLcolorref color; /* logical color */
   int lstyle; /* logical style */
   WLuint16 blend; /* blend parameter */
   int lweight; /* logical weight */
   int draw_opt; /* drawing options */
#if defined( XGL )
   int using_xgl; /* TRUE, if using XGL for this pipe */
   Xgl_object xgl_context_3D;
   Xgl_object hl_xgl_context_3D;
   Xgl_trans  global_model_trans;
   Xgl_trans  local_model_trans;
   Xgl_trans  view_trans;
   Xgl_trans  hl_global_model_trans;
   Xgl_trans  hl_local_model_trans;
   Xgl_trans  hl_view_trans;
#endif
#if defined( OPENGL )
   int using_opengl; /* TRUE, if using OpenGL for this pipe */
#endif
#if defined( ENV5 )
   int using_gpipe; /* TRUE, if using GPIPE for this pipe */
   int gpipe_id; /* the GPIPE id for this pipe */
   int using_eg; /* TRUE, if using EG for this pipe */
   int eg_vc; /* EG viewing context for this pipe */
   EGViewRep3 view_rep;
   EGIntLimit3 dc_limits;
#endif
};

struct DLItri_vertex
{
   double coord[4];
   double norm[3];
   struct DLItri_vertex *next;
   struct DLItri_edge *In[4], *Out[4];
   unsigned short LocalExtremity;
   short InCardinality, OutCardinality;
};

struct DLItri_loop
{
   struct DLItri_vertex *loop;
   struct DLItri_loop *next;
   int Vertices;
};

struct DLItri_edge
{
   double SlopeInverse, x_intercept;
   struct DLItri_vertex *Top, *Bottom;
   struct DLItri_vertex *Extreme_y;
   struct DLItri_edge *Next;
   unsigned short EdgeStatus;
};

struct DLItri_polygon_vert 
{
   struct DLItri_vertex *Vertex;
   struct DLItri_polygon_vert *Next;
   short Side; /* LEFT_SIDE, RIGHT_SIDE, or NEITHER_SIDE */
   short VertNo;
};

#define      DLItri_NIL_BUFPTR      (struct DLItri_buf_ptr *)NULL

struct DLItri_buf_ptr
{
   char *buffer, *ele_ptr;
   int num_left, ele_size;
   struct DLItri_buf_ptr *next;
};

/* error checking macro */
#define DL_REPORT_ERROR( err_num )                                      \
   if ( DLIreport_errors )                                              \
   {                                                                    \
      fprintf( stderr, "DL ERROR: " );                                  \
      DLIerror_code_to_string( stderr, (err_num) );                     \
      fprintf( stderr, "  File: %s; Line: %d\n",  __FILE__, __LINE__ ); \
   }


/* buffered line string macros */

#define DLI_MOVE2D( pipe, ptx, pty )                    \
   {                                                    \
      /* draw currently buffered line string */         \
      if ( DLInum_points > 1 )                          \
      {                                                 \
         WLdraw_2D_line_string( (pipe)->lwin_no,        \
                                DLInum_points,          \
                                DLIsaved_points );      \
      }                                                 \
                                                        \
      DLInum_points = 0;                                \
      DLIsaved_points[DLInum_points].x = (ptx);         \
      DLIsaved_points[DLInum_points].y = (pty);         \
      DLInum_points++;                                  \
   }


#define DLI_DRAW2D( pipe, ptx, pty )                    \
   {                                                    \
      if ( DLInum_points >= DLI_NUM_SAVED_POINTS )      \
      {                                                 \
         /* filled up buffer => draw buffered line */   \
         /* string and start a new one             */   \
         WLdraw_2D_line_string( (pipe)->lwin_no,        \
                                DLInum_points,          \
                                DLIsaved_points );      \
                                                        \
      DLIsaved_points[0] =                              \
          DLIsaved_points[(DLInum_points - 1)];         \
      DLInum_points = 1;                                \
      }                                                 \
                                                        \
      DLIsaved_points[DLInum_points].x = (ptx);         \
      DLIsaved_points[DLInum_points].y = (pty);         \
      DLInum_points++;                                  \
   }

#define DLI_TERMINATE_LINE_STRING( pipe )               \
   {                                                    \
      if ( DLInum_points > 1 )                          \
      {                                                 \
         WLdraw_2D_line_string( (pipe)->lwin_no,        \
                                DLInum_points,          \
                                DLIsaved_points );      \
      }                                                 \
                                                        \
      DLInum_points = 0;                                \
   }

#if defined( OPENGL )

#define DLI_SEND_PRIMITIVE_TO_OPENGL( vertfunc, primtype, numverts, verts ) \
                                                                            \
   glBegin( (primtype) );                                                   \
   switch( (numverts) % 4 )                                                 \
   {                                                                        \
      case 1:                                                               \
         (vertfunc)( (verts) );                                             \
         (verts) += 3;                                                      \
         (numverts) -= 1;                                                   \
         break;                                                             \
      case 2:                                                               \
         (vertfunc)( (verts) );                                             \
         (vertfunc)( (verts) + 3 );                                         \
         (verts) += 6;                                                      \
         (numverts) -= 2;                                                   \
         break;                                                             \
      case 3:                                                               \
         (vertfunc)( (verts) );                                             \
         (vertfunc)( (verts) + 3 );                                         \
         (vertfunc)( (verts) + 6 );                                         \
         (verts) += 9;                                                      \
         (numverts) -= 3;                                                   \
         break;                                                             \
   }                                                                        \
                                                                            \
   while ( (numverts) > 0 )                                                 \
   {                                                                        \
      (vertfunc)( (verts) );                                                \
      (vertfunc)( (verts) + 3 );                                            \
      (vertfunc)( (verts) + 6 );                                            \
      (vertfunc)( (verts) + 9 );                                            \
      (verts) += 12;                                                        \
      (numverts) -= 4;                                                      \
   }                                                                        \
   glEnd();                                                                 \

#endif


/* function prototypes */

#if defined(__STDC__) || defined(__cplusplus)
#define __(p) p
#else
#define __(p) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int DLIbbstroke __((
   struct DLpipeline *pipe,
   struct IGRbsp_surface *surf,
   int num_boundary_points,
   double *boundary,
   int draw_opt ));

extern int DLIbezstrok __((
   struct DLpipeline *pipe,
   int order,
   double *poles,
   double *weights,
   int rational,
   double **polyptr,
   int *num_polypnts,
   int draw_opt ));

extern int DLIbspl_curve __((
   struct DLpipeline *pipe,
   int order,
   int num_poles,
   double *npoles,
   double *knots,
   double *weights,
   int rational,
   int num_bndrys,
   double *boundaries,
   int *attr_indexs,
   struct DLattr_bundle *attr_bundle,
   int draw_opt,
   int periodic ));

extern int DLIclip3D __((
   struct DLpipeline *pipe,
   double *points,
   int numpnts ));

extern int DLIclip4D __((
   struct DLpipeline *pipe,
   double *points,
   int numpnts ));

extern int DLIdraw2D __((
   struct DLpipeline *pipe,
   int x, 
   int y ));

extern void DLIerror_code_to_string __((
   FILE *pfile,
   int err_code ));

extern int DLIfb_end __((
   struct DLpipeline *pipe,
   WLint16 flag ));

extern int DLIfb_flag __((
   struct DLpipeline *pipe,
   WLint16 flag ));

extern int DLIfb_insert __((
   struct DLpipeline *pipe ));

extern int DLIfb_start __((
   struct DLpipeline *pipe,
   WLuint16 tag,
   WLint16 flag ));

extern int DLIfb_tags __((
   WLint32 tag1,
   WLint32 tag2 ));

extern int DLImat_mult __((
   struct DLpipeline *pipe,
   double *matrix,
   int mult_type ));

extern int DLImove2D __((
   struct DLpipeline *pipe,
   int x,
   int y ));

extern int DLIpoint2D __((
   struct DLpipeline *pipe,
   int x,
   int y ));

extern int DLIterminate_line_string __((
   struct DLpipeline *pipe ));

extern int DLIupdate_pipe_symbology __((
   struct DLpipeline *pipe,
   int draw_opt,
   WLcolorref color,
   int lstyle,
   int lweight,
   WLuint16 blend ));

extern int DLIvalidate_pipe __((
   int pipe_id,
   struct DLpipeline **pipe ));

extern int DLIxform3D __((
   double *bufin,
   double *bufout,
   int numpnts,
   double matrix[16],
   int matmap[4] ));

extern int DLIxform4D __((
   double *bufin,
   double *bufout,
   int numpnts,
   double matrix[16],
   int matmap[4] ));

extern int DLIdump_fb_buffer __((
   void *fb_buffer ));

extern int DLItri_create_mesh __((
   struct DLItri_polygon_vert *,
   int,
   int,
   int,
   double,
   int (*mesh_processor)( struct DLItri_mesh * ) ));

extern struct DLItri_vertex **DLItri_setup_list __((
   struct DLItri_loop *,
   int,
   int,
   int ));

extern void DLItri_quick_sort __((
   int,
   int ));

extern void DLItri_get_intercepts __((
   struct DLItri_vertex *,
   double, short ));

extern int DLItri_process_facet __((
   struct DLItri_loop *,
   int,
   int,
   int,
   double,
   int (*mesh_processor)( struct DLItri_mesh * ) ));

extern void DLItri_create_edges __((
   struct DLItri_loop *,
   int,
   int,
   double ));

extern void DLItri_free_edge __((
   void ));

extern void DLItri_add_edge __((
   struct DLItri_vertex *,
   struct DLItri_vertex *,
   unsigned short,
   int,
   int,
   struct DLItri_edge *,
   struct DLItri_edge *,
   double ));

extern int DLItri_handle_crossing_edges __((
   struct DLItri_edge *,
   struct DLItri_edge *,
   int,
   int ));

extern struct DLItri_vertex **DLItri_get_array __((
   int ));

extern struct DLItri_polygon_vert *DLItri_alloc_vert_ptr __((
   void ));

extern void DLItri_add_vertex __((
   double, 
   double, 
   double, 
   double, 
   char, 
   double, 
   double, 
   double, 
   double, 
   double ));
                               
extern struct DLItri_loop *DLIalloc_tri_loop __((
   void ));

extern void DLItri_end_loop __((
   void ));

extern void DLItri_dispose_facet __((
   void ));

extern void DLItri_add_vertex __((
   double, 
   double, 
   double, 
   double, 
   char, 
   double, 
   double, 
   double, 
   double, 
   double ));

extern void DLItri_mesh_loops __((
   double, 
   double *,
   int (*mesh_processor)() ));

extern int DLItriangulate __((
  int,
  int *,
  double *,
  double,
  int (*mesh_processor)() ));

extern int DLItriangulate_f __((
  int,
  int *,
  float *,
  double,
  int (*mesh_processor)() ));

extern int DLIsetup_DL_window __((
   struct DLpipeline *pipe ));

#if defined( ENV5 )
extern int DLIsetup_EG_window __((
   struct DLpipeline *pipe ));
#endif

#if defined( XGL )
extern int DLIsetup_XGL_window __((
   struct DLpipeline *pipe,
   short viewport_changed ));
#endif
   
#if defined( OPENGL )
extern int DLIsetup_OPENGL_window __((
   struct DLpipeline *pipe,
   short viewport_changed ));

extern int DLIsync_OPENGL_hilite_matrices __((
   struct DLpipeline *pipe ));
#endif

#if defined(__cplusplus)
}
#endif

#undef __

#endif
