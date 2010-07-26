#include "grimport.h"
#include "igrtypedef.h"
#include "dpdef.h"

/* prototype files */
#include "DPwldvw.h"

#include "mainvmx.h"
#include "maidmx.h"
#include "mamulmx.h"


IGRboolean DPwld_to_vw_mtx(msg,in_flags,origin,rotation,wldvw_mtx,vw_wld_mtx)

IGRlong *msg;
IGRint  in_flags;
IGRdouble *origin;
IGRdouble *rotation;
IGRdouble *wldvw_mtx;
IGRdouble *vw_wld_mtx;
{
IGRdouble trans_mtx[4][4];
IGRdouble left_mtx[4][4];
IGRdouble left_rot[4][4];
IGRshort four = 4;
IGRboolean sts;

  MAidmx(msg, (IGRdouble *)trans_mtx);

  trans_mtx[0][3] = - origin[0];
  trans_mtx[1][3] = - origin[1];
  trans_mtx[2][3] = - origin[2];

  if (in_flags & DPRIGHT_VIEW)
  {
  	sts = MAmulmx(msg, &four, &four, &four, rotation, 
			(IGRdouble *)trans_mtx,  wldvw_mtx);
  }
  else
  {
	MAidmx(msg, (IGRdouble *)left_mtx);
	left_mtx[2][2] = -1;
    	sts = MAmulmx(msg, &four, &four, &four, (IGRdouble *)left_mtx, 
			rotation, (IGRdouble *)left_rot);
	if (sts)
  	MAmulmx(msg, &four, &four, &four, (IGRdouble *)left_rot, 
		(IGRdouble *)trans_mtx, wldvw_mtx);
  }
  if (vw_wld_mtx)
  {
     if(sts)
	sts = MAinvmx(msg, &four, wldvw_mtx, vw_wld_mtx);
  }
  return(sts);
}
