class implementation IGEgragad;

#include <stdio.h>
#include "OMmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "dpstruct.h"

method debug()

/*
DESCRIPTION
	Print out instance data
*/
{
    int i;

    fprintf(stderr, "IGEgragad INSTANCE DATA\n\n");
    fprintf(stderr, "   MIN-X-DEP:  %d\n", me->min_x_dep);
    fprintf(stderr, "   MIN-Y-DEP:  %d\n", me->min_y_dep);
    fprintf(stderr, "   MAX-X-DEP:  %d\n", me->max_x_dep);
    fprintf(stderr, "   MAX-Y-DEP:  %d\n", me->max_y_dep);
    fprintf(stderr, "   MIN-X-INDEP:  %d\n", me->min_x_indep);
    fprintf(stderr, "   MIN-Y-INDEP:  %d\n", me->min_y_indep);
    fprintf(stderr, "   MAX-X-INDEP:  %d\n", me->max_x_indep);
    fprintf(stderr, "   MAX-Y-INDEP:  %d\n", me->max_y_indep);
    fprintf(stderr, "   VIEW-FLAGS:  0x%X\n", me->gragad.flags );
    fprintf(stderr, "   GRID-PER-REF-X:  %d\n", me->gragad.grid_per_ref_x);
    fprintf(stderr, "   GRID-PER-REF-Y:  %d\n", me->gragad.grid_per_ref_y);
    fprintf(stderr, "   WORLD-VIEWPORT-TYPE:  %d\n", 
				me->gragad.wld_viewport_type);
    fprintf(stderr, "   DISPLAY-MODE:  %d\n", me->gragad.display_mode);
    fprintf(stderr, "   GPIPE-ID:  %d\n", me->gragad.gpipe_id);
    fprintf(stderr, "   UOR-PER-REF-X:  %4.4lf\n", me->gragad.grid_per_ref_x);
    fprintf(stderr, "   UOR-PER-REF-Y:  %4.4lf\n", me->gragad.grid_per_ref_y);
    fprintf(stderr, "   ORIGIN:  %4.4lf %4.4lf %4.4lf\n", 
				me->gragad.origin[0], 
				me->gragad.origin[1], 
				me->gragad.origin[2]);
    fprintf(stderr, "\n   ROTATION:	%4.4lf %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.rotation[0][0], 
					me->gragad.rotation[0][1], 
					me->gragad.rotation[0][2], 
					me->gragad.rotation[0][3]);
    for (i=1; i<4; i++)
    {	
       fprintf(stderr, "      		%4.4lf %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.rotation[i][0], 
					me->gragad.rotation[i][1], 
					me->gragad.rotation[i][2], 
					me->gragad.rotation[i][3]);
    }
    fprintf(stderr, "\n   VIEW VOLUME:	%4.4lf %4.4lf %4.4lf\n", 
					me->gragad.vw_volume[0], 
					me->gragad.vw_volume[1], 
					me->gragad.vw_volume[2]); 
    fprintf(stderr, "      		%4.4lf %4.4lf %4.4lf\n", 
					me->gragad.vw_volume[3], 
					me->gragad.vw_volume[4], 
					me->gragad.vw_volume[5]); 
    fprintf(stderr, "\n   ACTIVE-Z (VIEW):  %4.4lf\n", me->gragad.act_z);
    fprintf(stderr, "   ACTIVE-Z (SCREEN):  %4.4lf\n", me->gragad.act_z_screen);
    fprintf(stderr, "   DIT-TOL:  %4.4lf\n", me->gragad.dit_tol);
    fprintf(stderr, "\n   WORLD-TO-VIEWPORT MATRIX: ");
    fprintf(stderr, "%4.4lf %4.4lf %4.4lf %4.4lf\n",
					me->gragad.wld_to_viewport[0][0], 
					me->gragad.wld_to_viewport[0][1], 
					me->gragad.wld_to_viewport[0][2], 
					me->gragad.wld_to_viewport[0][3]);
    for (i=1; i<4; i++)
    {
    fprintf(stderr, " 			     %4.4lf %4.4lf %4.4lf %4.4lf\n",
					me->gragad.wld_to_viewport[i][0], 
					me->gragad.wld_to_viewport[i][1], 
					me->gragad.wld_to_viewport[i][2], 
					me->gragad.wld_to_viewport[i][3]);
    }
    fprintf(stderr, "\n   VIEWPORT-TO-WORLD MATRIX: " );  
    fprintf(stderr, "%4.4lf %4.4lf %4.4lf %4.4lf\n",
					me->gragad.viewport_to_wld[0][0], 
					me->gragad.viewport_to_wld[0][1], 
					me->gragad.viewport_to_wld[0][2], 
					me->gragad.viewport_to_wld[0][3]);
    for (i=1; i<4; i++)
    {
       fprintf(stderr, "			     " );
       fprintf(stderr, "%4.4lf %4.4lf %4.4lf %4.4lf\n",
					me->gragad.viewport_to_wld[i][0], 
					me->gragad.viewport_to_wld[i][1], 
					me->gragad.viewport_to_wld[i][2], 
					me->gragad.viewport_to_wld[i][3]);
    }
    fprintf(stderr, "\n   ALTERNATE VIEWPORT-TO-WORLD MATRIX: ");
    fprintf(stderr, "%4.4lf %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.alt_vwport_to_wld[0][0], 
					me->gragad.alt_vwport_to_wld[0][1], 
					me->gragad.alt_vwport_to_wld[0][2], 
					me->gragad.alt_vwport_to_wld[0][3]);
    for (i=1; i<4; i++)
    {
       fprintf(stderr, "				       " );   
       fprintf(stderr, "%4.4lf %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.alt_vwport_to_wld[i][0], 
					me->gragad.alt_vwport_to_wld[i][1], 
					me->gragad.alt_vwport_to_wld[i][2], 
					me->gragad.alt_vwport_to_wld[i][3]);
    }

    fprintf(stderr, "\n   CONSTRUCTION PLANE:  %4.4lf %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.construct_plane[0][0], 
					me->gragad.construct_plane[0][1], 
					me->gragad.construct_plane[0][2], 
					me->gragad.construct_plane[0][3]);
    for (i=1; i<4; i++)
    {
       fprintf(stderr, "		        %4.4lf %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.construct_plane[i][0], 
					me->gragad.construct_plane[i][1], 
					me->gragad.construct_plane[i][2], 
					me->gragad.construct_plane[i][3]);
    }
    fprintf(stderr, "\n   WORLD-TO-VIEW MATRIX:  %4.4lf %4.4lf %4.4lf %4.4lf\n",
					me->gragad.construct_plane[0][0], 
					me->gragad.construct_plane[0][1], 
					me->gragad.construct_plane[0][2], 
					me->gragad.construct_plane[0][3]);
    for (i=1; i<4; i++)
    {
       fprintf(stderr, "                          " );
       fprintf(stderr, "%4.4lf %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.construct_plane[i][0], 
					me->gragad.construct_plane[i][1], 
					me->gragad.construct_plane[i][2], 
					me->gragad.construct_plane[i][3]);
    }
    fprintf(stderr, "\n   DIT CLIP-RANGE:   %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.dit_clip_range[0], 
					me->gragad.dit_clip_range[1], 
					me->gragad.dit_clip_range[2]); 
    fprintf(stderr, "      		     %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.dit_clip_range[3], 
					me->gragad.dit_clip_range[4], 
					me->gragad.dit_clip_range[5]); 
    fprintf(stderr, "\n   VIEW VOLUME VIEWPORT SCALE:  %4.4lf\n", 
					me->gragad.vvol_viewport_scale);
    fprintf(stderr, "   EYE POINT:  %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.eye_pt[0], 
					me->gragad.eye_pt[1], 
					me->gragad.eye_pt[2]);
    fprintf(stderr, "   CENTER OF INTEREST:  %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.coi[0], 
					me->gragad.coi[1], 
					me->gragad.coi[2]);
    fprintf(stderr, "   VIEW ANGLE: %4.4lf\n", me->gragad.vw_angle);
    fprintf(stderr, "   VIEW REFERENCE POINT: %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.vrp[0], 
					me->gragad.vrp[1], 
					me->gragad.vrp[2]);
    fprintf(stderr, "   VIEW PLANE NORMAL: %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.vpn[0], 
					me->gragad.vpn[1], 
					me->gragad.vpn[2]);
    fprintf(stderr, "   VIEW UP VECTOR: %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.vup[0], 
					me->gragad.vup[1], 
					me->gragad.vup[2]);
    fprintf(stderr, "\n   RANGE CHECK: %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.range_chk.xlo, 
					me->gragad.range_chk.ylo,	
					me->gragad.range_chk.zlo);
    fprintf(stderr, "      		%4.4lf %4.4lf %4.4lf\n", 
					me->gragad.range_chk.xhi,	
					me->gragad.range_chk.yhi,	
					me->gragad.range_chk.zhi);	
    fprintf(stderr, "\n   VIEW RANGE CHECK:  %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.vv_range_chk.xlo, 
					me->gragad.vv_range_chk.ylo, 
					me->gragad.vv_range_chk.zlo);

    fprintf(stderr, "      		      %4.4lf %4.4lf %4.4lf\n", 
					me->gragad.vv_range_chk.xhi, 
					me->gragad.vv_range_chk.yhi, 
					me->gragad.vv_range_chk.zhi);	
    return( OM_S_SUCCESS );

}  /* debug */

end implementation IGEgragad;
