class specification HSsaraform (1:0) of CEO_GSLOCATE;



#include "wl.h"
#include "igecolor.h"
#include "FI.h"

#define RGB_XMAX 128
#define RGB_YMAX 128


instance HSsaraform
{
	IGRint		finish;			/* Phong shading parameters */
	IGRdouble	spec_refl, diff_refl, transparency;
	IGRint		switch1;
	IGRint		texture_active;			
	IGRint		linear_rng;			
	unsigned short  *sph_fin000;  
	unsigned short  *sph_fin100; 
	unsigned short  *sph_fin050;
	unsigned short  *sph_dif;
	unsigned short  *sph_trn;  
	unsigned short  *sph_texture;  
        IGRchar         textfname[16];  	/* filename of the texture */
        IGRchar         curr_dname[256],temp_dir[256]; /* current directory */
        int     	SR_active;
        int     	selected;		/* texture file is selected */
  	IGRuchar orient;			
	int		no_texture, no_transparency;
 	int 		no_fin0, no_fin1;	
	unsigned short  textindex;
	IGRchar 	textname[100];
	unsigned short  sph_index;
	int 		color_plane;
	double		exp_save;
	int		slider_reset;
	int 		trans_active_msg;
	int 		from_active, update_color;
        WLhwin_no	hwin_no;
        WLuint16	lscreen_no;
        WLuint32	context_no;
        WLuint32	lwin_no;
	short           init_rgb_called;
#ifdef X11
	int 		allocated_window;
	unsigned long   planemask;
#endif
	};


message which_state ( long * sts );

message set_form_defaults ( long * sts );

message adjust_form_buttons ( long * sts );

override form_notification;

message HS_wakeup ( long * sts );

message display_sphere_init ( long * sts );

message read_spheres ( long * sts );

message display_sphere ( long * sts );

message print_file_name ( long * sts );

message process_color_form ( long * sts );

message texture_form_defaults (int *sts; GRspacenum osnum);

message texture_form_notification ( int form_label; int gadget_label; 
				   double value; Form form_ptr );

message restore_color_table ( long * sts );

message free_buffers ( long * sts );

end specification HSsaraform;
