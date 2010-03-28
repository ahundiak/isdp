/* #######################    APOGEE COMPILED   ######################## */
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igrtypedef.h"
#include "griodef.h"
#include "gr.h"
#include "godef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "dpezmac.h"
#include "DPsetinq.h"
#include "DPsvinquire.h"

DP_inq_win_nam(mesg,osnumber,win_name,vw_origin,vw_rot,view_vol,world_vol,act_z,wld_to_vw)
IGRlong *mesg;
GRspacenum osnumber;
IGRchar *win_name;
IGRdouble *vw_origin,*vw_rot,*view_vol,*act_z,*world_vol,*wld_to_vw;
{
int i;
IGRlong ret[10],wh_err;
struct var_list var_arr[10];
i=0;
if (vw_origin)
{
	var_arr[i].var=VIEW_ORIGIN;
	var_arr[i].var_ptr=(char *)vw_origin;
	var_arr[i].num_bytes= 3*(sizeof(IGRdouble));
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (vw_rot)
{
	var_arr[i].var=VIEW_ROTATION;
	var_arr[i].var_ptr=(char *)vw_rot;
	var_arr[i].num_bytes=16*(sizeof(IGRdouble)) ;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (view_vol)
{
	var_arr[i].var=VW_VOLUME;
	var_arr[i].var_ptr=(char *)view_vol;
	var_arr[i].num_bytes= 6 *(sizeof(IGRdouble)) ;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (world_vol)
{
	var_arr[i].var=WLD_VOLUME;
	var_arr[i].var_ptr=(char *)world_vol;
	var_arr[i].num_bytes= 6 *(sizeof(IGRdouble)) ;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (act_z)
{
	var_arr[i].var=ACT_Z;
	var_arr[i].var_ptr=(char *)act_z;
	var_arr[i].num_bytes= sizeof(IGRdouble);
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (wld_to_vw)
{
	var_arr[i].var=WLD_TO_VIEWPORT;
	var_arr[i].var_ptr=(char *)wld_to_vw;
	var_arr[i].num_bytes= 16*(sizeof(IGRdouble));
	var_arr[i].bytes_returned=&ret[i];
	i++;
}
 

var_arr[i].var=END_PARAM;

dp$inq_set_gragad(msg=mesg,osnum=osnumber,gragad_name=win_name,
                  which_error=&wh_err,var_list=var_arr);
}







DP_inq_win_oid(mesg,osnumber,win_id,vw_origin,vw_rot,view_vol,world_vol,act_z,wld_to_vw)
IGRlong *mesg;
GRspacenum osnumber;
GRobjid win_id;
IGRdouble *vw_origin,*vw_rot,*view_vol,*act_z,*world_vol,*wld_to_vw;
{
int i;
IGRlong ret[10],wh_err;
struct var_list var_arr[10];
i=0;
if (vw_origin)
{
	var_arr[i].var=VIEW_ORIGIN;
	var_arr[i].var_ptr=(char *)vw_origin;
	var_arr[i].num_bytes= 3*(sizeof(IGRdouble)) ;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (vw_rot)
{
	var_arr[i].var=VIEW_ROTATION;
	var_arr[i].var_ptr=(char *)vw_rot;
	var_arr[i].num_bytes= 16*(sizeof(IGRdouble))  ;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (view_vol)
{
	var_arr[i].var=VW_VOLUME;
	var_arr[i].var_ptr=(char *)view_vol;
	var_arr[i].num_bytes=6 * (sizeof(IGRdouble)) ;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (world_vol)
{
	var_arr[i].var=WLD_VOLUME;
	var_arr[i].var_ptr=(char *)world_vol;
	var_arr[i].num_bytes= 6* (sizeof(IGRdouble)) ;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (act_z)
{
	var_arr[i].var=ACT_Z;
	var_arr[i].var_ptr=(char *)act_z;
	var_arr[i].num_bytes=  (sizeof(IGRdouble));
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (wld_to_vw)
{
	var_arr[i].var=WLD_TO_VIEWPORT;
	var_arr[i].var_ptr=(char *)wld_to_vw;
	var_arr[i].num_bytes= 16 *(sizeof(IGRdouble))  ;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}
 

var_arr[i].var=END_PARAM;

dp$inq_set_gragad(msg=mesg,osnum=osnumber,gragad_objid=win_id,
                   which_error=&wh_err,var_list=var_arr);
}





dpinq_sd_vwname(mesg,osnumber,vw_name,sav_name,desc,size_desc,view_ty)
IGRlong *mesg;
GRspacenum osnumber;
IGRchar  *vw_name,*sav_name,*desc;
IGRint *size_desc,*view_ty;
{
int i;
IGRlong ret[10],wh_err;
struct var_list var_arr[10];
i=0;
if (sav_name)
{
	var_arr[i].var=SAV_VW_NAME;
	var_arr[i].var_ptr=sav_name;
	var_arr[i].num_bytes= 80;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (desc)
{
	var_arr[i].var=DESCRIPT;
	var_arr[i].var_ptr=desc;
	var_arr[i].num_bytes=  80;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (size_desc)
{
	var_arr[i].var=SIZE_DESCRIPT;
	var_arr[i].var_ptr=(char *)size_desc;
	var_arr[i].num_bytes= sizeof(IGRint);
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (view_ty)
{
	var_arr[i].var=VIEW_TYPE;
	var_arr[i].var_ptr=(char *)view_ty;
	var_arr[i].num_bytes=sizeof(IGRint); 
	var_arr[i].bytes_returned=&ret[i];
	i++;
}


var_arr[i].var=END_PARAM;

dp$inq_set_saved_view(msg=mesg,osnum=osnumber,vw_name=vw_name,
                      which_error=&wh_err,var_list=var_arr);
}

dpinq_sd_vwoid(mesg,osnumber,vw_objid,sav_name,desc,size_desc,view_ty)
IGRlong *mesg;
GRspacenum osnumber;
IGRchar  *sav_name,*desc;
GRobjid vw_objid;
IGRint *size_desc,*view_ty;
{
int i;
IGRlong ret[10],wh_err;
struct var_list var_arr[10];
i=0;
if (sav_name)
{
	var_arr[i].var=SAV_VW_NAME;
	var_arr[i].var_ptr=sav_name;
	var_arr[i].num_bytes= 80;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (desc)
{
	var_arr[i].var=DESCRIPT;
	var_arr[i].var_ptr=desc;
	var_arr[i].num_bytes=  80;
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (size_desc)
{
	var_arr[i].var=SIZE_DESCRIPT;
	var_arr[i].var_ptr=(char *)size_desc;
	var_arr[i].num_bytes= sizeof(IGRint);
	var_arr[i].bytes_returned=&ret[i];
	i++;
}

if (view_ty)
{
	var_arr[i].var=VIEW_TYPE;
	var_arr[i].var_ptr=(char *)view_ty;
	var_arr[i].num_bytes=sizeof(IGRint); 
	var_arr[i].bytes_returned=&ret[i];
	i++;
}


var_arr[i].var=END_PARAM;

dp$inq_set_saved_view(msg=mesg,osnum=osnumber,vw_objid=vw_objid,
                      which_error=&wh_err,var_list=var_arr);
}
