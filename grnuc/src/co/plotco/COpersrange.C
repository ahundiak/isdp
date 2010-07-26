/*
Name
        COget_persvw_range()

Description
        This function returns the box range for a perspective view in both
	viewing coordinate system and world system. The front and back planes
	of this box is defined by the view's near and far planes. The width
	and length of the box can be determined by the near plane (mode=0),
	active_z plane(mode=1) and far plane(mode=2).

	In the returned values, [0-2] contains the smaller numbers, while
	[3-6] contains the larger numbers.

	Note: the returned world box and view box maybe different, since
	if the view is not aligned, we want the world box (2 corner pts) to
	be larger to include the whole view box.
	

Return Values
        IGRint ()       TRUE - successful
                        FALSE - unsuccessful
	IGRlong msg	TRUE - successful
                        FALSE - unsuccessful

History
        04/20/92	created by Tiesheng Wang
  scw   07/17/92        ansi conversion
  dhm   10/07/92        changed the dimension of the matrix passed to
                        MAinvmx to be a short.

*/


#include "grimport.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igrdp.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpstruct.h"
#include "dpmacros.h"


COget_persvw_range(msg,window,view_range,wld_range,mode)

IGRlong   *msg;
struct    GRid	  *window;
IGRdouble *view_range;
IGRdouble *wld_range;
IGRint	  mode;			/* range determined by: 	  	  */
				/*  0-near plane, 1-active_z, 2-far plane */
{
      struct var_list   inq_array[7];
      IGRlong           which_error,num_vals;
      IGRint            gg_flags;
      IGRdouble         vw_angle;
      IGRdouble         dit_clip_range[6];
      IGRdouble         vw_volume[6];
      IGRdouble         act_z;

      IGRdouble         width,length,dist,tan_x,tan_y;
      IGRlong		sts;
      IGRshort          four=4;
      struct IGRlbsys   lbsys;              /* represents window range */

      extern IGRdouble  tan();
            
      dist = 0.0;
      *msg = TRUE;
      
      inq_array[0].var = GRAGAD_FLAGS;
      inq_array[0].var_ptr = (IGRchar *)&gg_flags;
      inq_array[0].num_bytes = sizeof(gg_flags);
      inq_array[0].bytes_returned = &num_vals;

      inq_array[1].var = VIEW_ANGLE;
      inq_array[1].var_ptr = (IGRchar *)&vw_angle;
      inq_array[1].num_bytes = sizeof(vw_angle);
      inq_array[1].bytes_returned = &num_vals;

      inq_array[2].var = DIT_CLIP_RANGE;
      inq_array[2].var_ptr = (IGRchar *)dit_clip_range;
      inq_array[2].num_bytes = sizeof(dit_clip_range);
      inq_array[2].bytes_returned = &num_vals;

      inq_array[3].var = WLD_TO_VIEW;
      inq_array[3].var_ptr = (IGRchar *)lbsys.matrix;
      inq_array[3].num_bytes = 16*sizeof(IGRdouble);
      inq_array[3].bytes_returned = &num_vals;


      inq_array[4].var = ACT_Z;
      inq_array[4].var_ptr = (IGRchar *)&act_z;
      inq_array[4].num_bytes = sizeof(act_z);
      inq_array[4].bytes_returned = &num_vals;


      inq_array[5].var = VW_VOLUME;
      inq_array[5].var_ptr = (IGRchar *)vw_volume;
      inq_array[5].num_bytes = sizeof(vw_volume);
      inq_array[5].bytes_returned = &num_vals;

      inq_array[6].var = END_PARAM;
      inq_array[6].var_ptr = NULL;
      inq_array[6].num_bytes = 0;
      inq_array[6].bytes_returned = NULL;

      sts = dp$inq_set_gragad(msg = msg,
                  inq0_set1 = 0,
                      osnum = window->osnum,
               gragad_objid = window->objid,
                which_error = &which_error,
                   var_list = inq_array);
      if(! (sts & *msg & 1) ) goto error;


      view_range[2] = vw_volume[2];
      view_range[5] = vw_volume[5];
      
      width = dit_clip_range[3] - dit_clip_range[0];
      length = dit_clip_range[4] - dit_clip_range[1];
            
      if(width < length) {
            tan_x = tan(vw_angle/2.0);
            tan_y = (tan_x/width) * length;
      }
      else {
            tan_y = tan(vw_angle/2.0);
            tan_x = (tan_y/length) * width;
      }
      
      switch(mode) {
            case 0:
                  dist = vw_volume[2];    /* near plane */
                  break;
            case 1:
                  dist = act_z;
                  break;
            case 2:
                  dist = vw_volume[5];    /* far plane */
                  break;
      }
    
      view_range[3] = tan_x * dist;
      view_range[4] = tan_y * dist;
      
      view_range[0] = -view_range[3];
      view_range[1] = -view_range[4];

      /* calc wld_range[] */

      lbsys.diag_pt1[0] = view_range[0];
      lbsys.diag_pt1[1] = view_range[1];
      lbsys.diag_pt1[2] = view_range[2];
      lbsys.diag_pt2[0] = view_range[3];
      lbsys.diag_pt2[1] = view_range[4];
      lbsys.diag_pt2[2] = view_range[5];

      MAinvmx (msg, &four, lbsys.matrix, lbsys.matrix);
      MAlbextents (msg, &lbsys, wld_range, &wld_range[3]);


      return(TRUE);
error:
      return(FALSE);

}
