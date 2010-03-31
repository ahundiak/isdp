/* #######################    APOGEE COMPILED   ######################## */
class implementation GRgraphics;

#include "grimport.h"
#include <stdio.h>
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "madef.h"
#include "comiscmac.h"
#include "go.h"
#include "grwireframe.h"
#include "grmacros.h"
#include "griodef.h"
#include "grio.h"


from GRlinear import GRgetpolyline;
from GRconic import GRgetarc;
from GRcurve import GRendpts,GRrevparm;
from GRvg import GRgetsize,GRgetgeom, GRpostabsg;

from GRsubbc import EMcurve_by_poles, EMleast_squares_fit_curvee;


/*
Name:
     GRcreate_curve_by_option(msg,md_env,option,tolerance,
	num_points,points,object_id,order,periodic,avg_error,max_error,
	new_id,name,display_flag)

 Abstract:

	This function will create a curve.

 Arguments:

 IGRint		*msg		O	completion code
					   MSSUCC- Successful completion
					   MSFAIL - error
 struct GRmd_env *md_env	I	module environment for construction
					   (optional)
 IGRint		option		I	option flag
					   0 - by poles
					   1 - by direct fit
 IGRdouble	*tolerance	I	the tolerance for fit
 IGRint		num_points	I 	number of input points
 IGRdouble	*points		I	input points
 struct GRid	*object_id	I	the object for reference 
 struct GRmd_env *object_env	I	the enviornment of reference
					 object
 IGRint		order		I	order of curve (2-16)
 IGRshort	periodic	I   	periodic or not indicator
 IGRdouble      *avg_error 	O	average error (fit only)
 IGRdouble      *max_error 	O	maximum error (fit only)
 struct GRid	*new_id		O	object id of constructed object
 IGRchar	*name		I/O	name 
					 if the name supplied has already
					  been used, a suffix will
					  be added to make the name unique
 IGRint		display_flag	I	display option.
					   0 (default) do not display
					   1 display constructed object
*/

int     GRcreate_curve_by_option(msg,md_env,option,tolerance,
	num_points,points,object_id,object_env,order,periodic,
	avg_error,max_error,new_id,name,display_flag)

 IGRlong	*msg;
 struct GRmd_env *md_env;
 IGRint		option;
 IGRdouble	*tolerance;
 IGRint		num_points;
 IGRdouble	*points;
 struct GRid	*object_id;
 struct GRmd_env *object_env;
 IGRint		order;
 IGRshort	periodic;
 IGRdouble 	*avg_error;
 IGRdouble 	*max_error;
 struct GRid	*new_id;
 IGRchar	*name;
 IGRint		display_flag;

{
    IGRint OMmsg,num_bytes,num_bytes_ret;
    struct GRmd_env *env,local_env;
    struct GRvg_construct cst;
    struct IGRdisplay local_symbology;
    struct GRlc_info lc_info;
    enum GRdpmode mode;
    IGRdouble	local_tol;
    IGRdouble *avg,*max,d1,d2;
    IGRlong max_ind;
    IGRdouble max_seg[6];
/*
    struct GRid *id;
*/
    struct GRlc_info *id;
    
    GRgetmd_env(md_env,&local_env,&env);

    cst.msg = msg;
    cst.env_info = env;
    cst.newflag = FALSE;

    num_bytes = sizeof(short);

    gr$get_active_level(
	msg = msg,
	sizbuf = &num_bytes,
	buffer = &cst.level,
	nret = &num_bytes_ret);

    num_bytes = sizeof( local_symbology );
    gr$get_active_display(msg = msg,
                           sizbuf = &num_bytes,
                           buffer = &local_symbology,
                           nret = &num_bytes_ret );

    cst.display = &local_symbology;
    
    num_bytes = sizeof(IGRshort);
    gr$get_active_prop(msg = msg,
                      sizbuf = &num_bytes,
                      buffer = &cst.properties,
                      nret = &num_bytes_ret );
    cst.name = NULL;
    cst.geometry = NULL;
    cst.class_attr = NULL;

    if (object_id)
    {
	lc_info.located_obj = *object_id;
	lc_info.module_info = *object_env;
	lc_info.proj_pnt[0] = 0.0;
	lc_info.proj_pnt[1] = 0.0;
	lc_info.proj_pnt[2] = 0.0;
	lc_info.geom_parms.u = 0.0;
	lc_info.geom_parms.v = 0.0;
	id = &lc_info;
    }
    else
    {
	id = NULL;
    }

    if (option == 0)
    {
        OMmsg = om$construct(classname = "GRbcsubbc",
                osnum = env->md_id.osnum,
		p_objid = &new_id->objid,
		msg = message GRsubbc.EMcurve_by_poles(
        		order,periodic,num_points,(IGRpoint *)points,id,&cst));
    }
    else
    {
	if (tolerance)
	{
	    num_bytes = sizeof (double);

	    gr$get_chord_height_tolerance
		(msg = msg,
		 sizbuf= &num_bytes,
		 buffer = &local_tol,
		 nret = &num_bytes_ret);

	    gr$put_chord_height_tolerance
		(msg = msg,
		 sizbuf= &num_bytes,
		 buffer = tolerance);
	}

	avg = (avg_error ? avg_error : &d1);
	max = (max_error ? max_error : &d2);
	    
        OMmsg = om$construct(classname = "GRbcsubbc",
		p_objid = &new_id->objid,
                osnum = env->md_id.osnum,
		msg = message GRsubbc.EMleast_squares_fit_curvee(
        		order,NULL,num_points,(IGRpoint *)points,id,
			0,0,0,0,avg,max,&max_ind,(IGRpoint *)max_seg,&cst));
	if (tolerance)
	{
	    gr$put_chord_height_tolerance
		(msg = msg,
		 sizbuf= &num_bytes,
		 buffer = &local_tol);
	}
    }

    if ( 1 & *msg)
    {
	new_id->osnum = env->md_id.osnum;
        gr$put_name(msg = msg,object_id = new_id,name =name);

    }

    if (display_flag)
    {
	mode = GRbd;

	OMmsg = om$send(msg= message  GRgraphics.GRdisplay
		(msg,&env->md_env.matrix_type,env->md_env.matrix,&mode,
		 &env->md_id),
            	senderid = NULL_OBJID,
		targetid=new_id->objid,
		targetos=new_id->osnum);
   }
   return(OM_S_SUCCESS);

}

end implementation GRgraphics;
