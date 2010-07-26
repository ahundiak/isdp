#include "stdio.h"
#include "wl.h"
#include "OMminimum.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igecolor.h"
#include "msdef.h"
#include "madef.h"
#include "mapriv.h"
#include "dpgraphics.h"

int RSstroke(
        IGRint *msg,
        struct IGRlbsys *lbsys,
        struct IGResrs *ele_att,
        IGRint *win_no,
        IGRshort *mat_type,
        IGRdouble *wld_to_viewport,
        IGRdouble *dit_clip_range)
{
	return(65535);
}


IGRint GRrsloadctb(IGRint *sts, 
		   OM_S_OBJID *objid, 
	 	   OMuword *osnum )
{
	return(65535);

}

IGRint RSget_tc_vlt( IGRint *tc_vlt_no )
{

	return(65535);
}


IGRint RSstub_file()
{
  IGRint vlt_no;

#ifndef X11
    Alloc_vlt(0,&vlt_no);
    activevltno(0,vlt_no);
#endif
    return(1);
}

IGRint RSis_true_color()
{
	IGRint status;

	status = 0;

	if (status == 0)
	{
	    status = 1;
	}	

	return(status - 1);

}

int RSsep_select_options(
        IGRchar   *tablename,
        IGRdouble ucr_factor,
	IGRchar   *dot_gain_name,
	IGRushort *red_calib,
	IGRushort *green_calib,
	IGRushort *blue_calib)
{
	return(65535);
}


IGRint	COcvigdsige_COcvigdsige_cvt_type8788_method()
{

	return(65535);

}
