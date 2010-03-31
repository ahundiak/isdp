class specification HSsdpform (1:0) of CEO_LOCATE;



#include "FI.h"
#include "wl.h"
#include "HSsdpform.h"
#include "hsurf.h"
#include "vemsg.h"
#include "grdpbdef.h"
#include "grdpb.h"


instance HSsdpform
{
	struct GRhesym		hidden_symbology;
	IGRint			max_styles;
	IGRboolean		display_hidden_lines;

	IGRint 			transparency_grid;
	IGRdouble		polygon_generation_tol;
	IGRdouble		depth_cue_intensity;
	IGRdouble		stereo_eye_seperation;
	IGRuint			shaded_display; 
	IGRuint			old_shaded_display; 

/* shaded display is used for both shaded wireframe display and light source 
   display */
	};


message set_defaults ( long * sts );

override form_notification;

message process ( long * sts );

end specification HSsdpform;
