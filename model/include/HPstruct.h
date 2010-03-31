#include "hsurf.h"
#include "HSplot_str.h"

#define	MAX_LIGHTS	8

#define MAX_USER_LINE_STYLES	256

struct GRhesym  /* hidden edge symbology */
   {
   IGRshort color;
   IGRchar weight;
   IGRchar style;
   IGRshort flags;
   };

typedef union
   {
   IGRdouble m16[16];
   IGRdouble m4x4[4][4];
   }     HPmatrix;

struct HPignore_list
   {
   int		objid;
   short	osnum;
 
   struct HPignore_list	*next;
   };

struct HPglobal_struct
   {
   FILE *pfl;

   HPmatrix  xform;
   IGRdouble viewport_to_wld[16];
   IGRdouble post_rotation[16];
   HPmatrix  rotation;
   IGRdouble viewport[6];
   IGRdouble world_to_viewport_scale;
   IGRdouble resolution;
   IGRdouble line_width_constant;
   IGRdouble scale;
   IGRdouble size_x, size_y;
   IGRchar *queue;

   IGRdouble matrix[16];        /* 4x4 view orientation matrix */
   IGRdouble range[6];  /* diagonal of viewport, (xyz0-xyz1) */
   IGRdouble replication_factor;

   IGRdouble tiling_tolerance;

   IGRdouble elem_spec_refl;
   IGRdouble elem_diff_refl;
   IGRdouble elem_transparency;
   IGRdouble elem_opacity;
   IGRint    elem_finish;

   struct HS_light_source	global_lights[MAX_LIGHTS];
   struct HS_light_source	ambient_light;

   struct GRhesym		hsym;

   struct HPignore_list		*ignore_list;

   unsigned short user_line_styles[MAX_USER_LINE_STYLES];

   IGRint id;

   IGRint total_bands;
   IGRint total_pixels;
   IGRint total_bytes;
   IGRint band_height;
   IGRint band_count;
   IGRint xdits, ydits;
   IGRint tot_phys_mem;
   IGRint tot_buf_mem;
   IGRint rendering_mode;
   IGRint rasterfile_type;

   HSzbuf *band_buffer;

   IGRint active_color;
   IGRint line_width;
   IGRint line_style;
   IGRint overlap;
   IGRint translucency;
   IGRint trans_grid;
   unsigned int debug;
   unsigned int flags;
   IGRint copies;
   IGRint objid;
   IGRshort osnum;

   unsigned short color_table[512][6];
   IGRshort color_table_size;
   IGRshort bytes_per_pixel;
   IGRshort max_line_width;
   IGRshort accuracy;

   IGRchar depth_cue_near;
   IGRchar depth_cue_far;
   IGRchar perspective;
   IGRchar light_coord_sys;
   IGRchar accuracy_mode;
   IGRchar num_global_lights;
   IGRchar rasterfile[80];
   IGRchar *input_textfile;
   IGRchar *output_textfile;
   IGRchar display_hidden_edges;
   IGRchar anti_aliasing;
   IGRshort white_background;
   IGRshort black_and_white_edges;
   IGRchar dont_plot;
   IGRchar heartbeat;

   }; /* global_struct */

struct HPnurb_surface_struct
   {
   struct IGRbsp_surface surface;       /* the surface definition */
   struct IGRbsp_curve *bdry_curves;    /* ptr to boundaries as nurb curves */
   IGRint curves_size;  /* size of boundary curves buffer */
   };

struct HPsoo_info
   {
   IGRdouble parms[2];
   unsigned short color;
   unsigned char style;
   unsigned char weight;
   unsigned char type;
   };

struct HPnurb_curve_struct
   {
   struct IGRbsp_curve curve;
   int num_soos;
   struct HPsoo_info *soos;
   };

typedef union
   {
   IGRchar i8;
   IGRshort i16;
   IGRlong i32;
   IGRdouble f64;
   unsigned char u8;
   unsigned short u16;
   unsigned long u32;
   }     HPsimple_union;


struct HPcommand_line_info_struct
   {
   IGRdouble size_x, size_y;
   IGRdouble scale;
   IGRdouble resolution;
   IGRdouble line_width_constant;
   IGRdouble tiling_tolerance;
   IGRdouble replication_factor;
   IGRint max_line_width;
   IGRint rasterfile_type;
   IGRint flags;
   IGRint copies;
   IGRchar *plotfile;
   IGRchar *input_textfile;
   IGRchar *output_textfile;
   IGRchar *rasterfile;
   IGRchar *device_driver;
   IGRchar *device_port;
   IGRchar *queue;
   IGRchar dont_plot;
   IGRshort black_and_white_edges;
   IGRshort white_background;
   IGRchar bytes_per_pixel;
   IGRchar heartbeat;
   };

struct HPdevice_info_struct
   {
   IGRdouble resolution;
   IGRint ws_no;
#  if defined (CLIX)
   struct ODWsInfo ws_info;
#  endif
   };

struct HPenvironment_variable_info_struct
   {
   IGRdouble line_width_constant;
   IGRint max_line_width;
   unsigned int debug;
   IGRchar *input_textfile;
   IGRchar *output_textfile;
   IGRchar dont_plot;
   };


struct HS_old_light_source
   {
   IGRint index;        /* logical light source number	 */
   IGRint type; /* light source type		 */
   IGRdouble location[3];       /* light source location	 */
   IGRdouble direction[3];      /* light source direction	 */
   IGRdouble radius;    /* light source radius		 */
   IGRdouble angle;     /* light source angle (spot)	 */
   IGRint red, green, blue;
   /* light source RGB (0-255)	 */
   };

struct HS_old_old_light_source
   {
   IGRint index;        /* logical light source number	 */
   IGRint type; /* light source type		 */
   IGRdouble x, y, z;   /* light src location or delta	 */
   IGRdouble radius;    /* point light source radius	 */
   IGRint red, green, blue;
   /* light source RGB (0-255)	 */
   };

struct HPband_info_struct
   {
   IGRdouble clip_range[6];
   IGRdouble x_scale, y_scale, z_scale;
   IGRdouble world_to_view_scale;
   IGRdouble keyed_in_tol;
   IGRdouble tolerance;
   IGRint w_no, pipe_no;
   IGRint org_x, org_y;
   IGRint x_dits, y_dits;
   IGRint screen_door;
   IGRint grid_on;
   IGRint acc_mode;
   IGRint accuracy;
   IGRint trans_pat;
   };

struct HPmipmap_info
   {
   char *mipmap_file;
   char *mipmap_home;
   int  orientation;
   };

/*
 *  Banding info structure.  Contains all the stuff I need
 *  to know re-read and process a surface, curve or edge
 *  from the shaded plotfile.
 */

struct HPbanding_info
   {
   double tiling_tolerance;
   int    width;
   int    count;
   int    style;
   long   object_location;
   int    base_color;
   int    translucent;
   int    translucency_grid;
   int    rendering_mode;
   int    xmin, xmax;
   int    objid;
   short  osnum;
   struct HPbanding_info *next;
   };

