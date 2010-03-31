
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

class specification HSdpb2 (2:0) of global_class;

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "hsurf.h"
#include "hslight.h"

instance HSdpb2
	{
	struct HS_light_source       dblight[MAX_LIGHTS]; /* NOT USED, DATA NOW STORED     */
	                                                  /* IN LIGHT SOURCE OBJECTS       */
	struct HSrender_bundle       rend_bundle;         /* bundle of shading symbologies */
	struct HSextra_render_bundle extra_rend_bundle;   /* bundle of extra render parms  */
	IGRdouble	             tolerance;           /* global shading tolerance      */
	IGRdouble                    eye_separation;      /* eye separation for stereo     */
	IGRuint                      shading_flags;       /* global shading flags          */
	IGRuint                      rendering_flags;     /* rendering flags               */
	IGRuint                      save_image_flags;    /* save image flags              */
	IGRuint	                     vhl_flags;           /* Vector hidden line flags      */
	IGRuint                      rend_attr_flags;     /* Copy rendering attr. flags    */
	IGRint                       accuracy;            /* global shading accuracy       */
	IGRushort                    vhl_visible_layer;   /* visible layer for VHL curves  */
	IGRushort                    vhl_hidden_layer;    /* hidden layer for VHL curves   */
	IGRushort                    vhl_text_layer;      /* text layer for VHL            */
	IGRuchar                     far_depth_cue;       /* far depth cue intensity       */
	IGRuchar                     amb_red,
	                             amb_green,
	                             amb_blue;            /* amb light color               */
	IGRuchar                     last_shading_style;  /* last style chosen in SWDM     */
	IGRuchar                     last_region_style;   /* last style chosen in DR       */
	struct HSvhl_symb            hidden_symb;         /* NOT USED - DATA NOW STORED    */
	                                                  /* IN GRNUC GRDPB OBJECT         */

	/* shaded plotting data */
	IGRuint                      hplot_flags;         /* flags word for plotting       */ 
	IGRchar                      plot_file[132];      /* last plot file name           */
	IGRchar                      raster_file[132];    /* last raster file name         */
	IGRchar                      text_file[132];      /* last text file name           */
	IGRchar                      plot_queue[32];      /* last plot queue               */
	IGRdouble                    plot_x_size;         /* last plot size in x           */
	IGRdouble                    plot_y_size;         /* last plot size in y           */
	IGRdouble                    plot_scale;          /* last plot scale               */
	IGRint                       num_copies;          /* last number of copies         */
	IGRchar                      date[32];            /* last starting date/time       */
	IGRdouble                    line_width_const;    /* last line width constant      */
	IGRint                       max_line_width;      /* last max line width           */
	IGRint                       raster_type;         /* last raster type              */

	/* render image data */
	variable IGRchar             image_filename[1];   /* last image file name          */
	variable IGRchar             device_res[1];       /* last device resolution        */
	variable IGRchar             media_size[1];       /* last media size               */
	IGRint                       image_width;         /* last image width              */
	IGRint                       image_height;        /* last image height             */
	IGRuchar                     bg_render_orient;    /* orientation of rendering bg   */
	variable IGRchar             bg_render_file[1];   /* rendering background file     */

	/* place/modify light data */
	IGRint                       last_light_num;      /* last light source selected    */
	IGRuint                      light_flags;         /* flags word                    */

	/* room for expansion */
	variable IGRdouble           d_expansion[0];      /* room for expansion            */
	variable IGRint              i_expansion[0];      /* room for expansion            */

	channel	{
			(many_to_many, initial=9, increment=0, abs_ordered)
		} to_light_sources;
	};

/****
   Use of the expansion VLA's
      d_expansion[0-1] - cycle delay times for Display Images
      d_expansion[2-3] - frame delay times for Display Images
****/

override super_construct, wake_up, debug;

message copy_instance_to_other_HSdpb2( OM_S_OBJID objid; OMuword osnum );

message get_shading_tol( IGRdouble *shading_tol );
message put_shading_tol( IGRdouble shading_tol );

message get_shading_flags( IGRuint *shading_flags; IGRuint *rendering_flags;
	                   IGRuint *save_image_flags; IGRuint *vhl_flags;
	                   IGRuint *rend_attr_flags; );

message put_shading_flags( IGRuint *shading_flags; IGRuint *rendering_flags;
	                   IGRuint *save_image_flags; IGRuint *vhl_flags;
	                   IGRuint *rend_attr_flags; );

message get_global_lights( struct HS_light_source *lights );
message set_global_lights( struct HS_light_source *lights );

message get_ambient_light( struct HS_light_source *amb );
message set_ambient_light( struct HS_light_source amb );

message get_shading_accuracy( IGRint *accuracy );
message set_shading_accuracy( IGRint accuracy );

message get_rendering_bundles( struct HSrender_bundle *rend_bundle;
	                       struct HSextra_render_bundle *extra_rend_bundle );

message set_rendering_bundles( struct HSrender_bundle *rend_bundle;
	                       struct HSextra_render_bundle *extra_rend_bundle );

message get_depth_cues( IGRuchar *far_depth_cue );
message set_depth_cues( IGRuchar far_depth_cue );

message get_vhl_layers( IGRushort *vhl_visible_layer;
	                IGRushort *vhl_hidden_layer;
	                IGRushort *vhl_text_layer );
message set_vhl_layers( IGRushort vhl_visible_layer;
	                IGRushort vhl_hidden_layer;
	                IGRushort vhl_text_layer );

message get_render_image_info( IGRchar *image_filename;
	                       IGRint *width;
	                       IGRint *height;
	                       IGRchar *device_res;
	                       IGRchar *media_size );
message set_render_image_info( IGRchar *image_filename;
	                       IGRint width;
	                       IGRint height;
	                       IGRchar *device_res;
	                       IGRchar *media_size );

message get_last_styles( IGRuchar *last_shading_style;
		         IGRuchar *last_region_style );
message set_last_styles( IGRuchar *last_shading_style;
		         IGRuchar *last_region_style );

message get_hplot_info(	IGRuint         *hplot_flags;
	                IGRchar         *plot_file;
	                IGRchar         *raster_file;
	                IGRchar         *text_file;
	                IGRchar         *plot_queue;
	                IGRdouble       *plot_x_size;
	                IGRdouble       *plot_y_size;
	                IGRdouble       *plot_scale;
	                IGRint          *num_copies;
	                IGRchar         *date;
	                IGRdouble       *line_width_const;
	                IGRint          *max_line_width;
	                IGRint          *raster_type );

message set_hplot_info(	IGRuint         *hplot_flags;
	                IGRchar         *plot_file;
	                IGRchar         *raster_file;
	                IGRchar         *text_file;
	                IGRchar         *plot_queue;
	                IGRdouble       *plot_x_size;
	                IGRdouble       *plot_y_size;
	                IGRdouble       *plot_scale;
	                IGRint          *num_copies;
	                IGRchar         *date;
	                IGRdouble       *line_width_const;
	                IGRint          *max_line_width;
	                IGRint          *raster_type );

message get_place_light_info( IGRint *last_light_num; IGRuint *light_flags );
message set_place_light_info( IGRint last_light_num; IGRuint light_flags );

message get_display_image_delays( IGRdouble *cycle_delay; IGRdouble *frame_delay );
message set_display_image_delays( IGRdouble *cycle_delay; IGRdouble *frame_delay );

end specification HSdpb2;
