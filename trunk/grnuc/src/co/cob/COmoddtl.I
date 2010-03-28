class implementation COmeasure;

#include "stdio.h"
#include "coimport.h"
#include "codebug.h"

#include "exmacros.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"
#include "coniarray.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "dpdef.h"
#include "var.h"
#include "madef.h"
#include "msdef.h"
#include "dp.h"
#include   "grownmacros.h"

#define TOL_VAL 1.0e-12


from dim_plan   import give_plane;
from IGEgragad  import DPinrot;
from Super_rfmgr import  GRget_channel_objects;
from GRreffile   import  GRgetscale;

%safe
extern IGRlong COmeasure_proj_delta();
extern IGRlong COmeasure_delta_2pts();
extern IGRlong COmeasure_view_values();
extern IGRlong COmeasure_detail_fun();
extern IGRlong COmeasure_act_proj_delta();
extern IGRlong COmeasure_get_ref_scale();
%endsafe


IGRlong COmeasure_detail_fun(msg, delta, act_flag, ref_flag,
			     dat_flag,ref_lock_flag,scale, events, md_env)

IGRlong          *msg;
IGRdouble        *delta;
IGRboolean       *dat_flag,*act_flag,*ref_flag,*ref_lock_flag;
IGRdouble        *scale;
struct GRevent   *events[];
struct GRmd_env  *md_env;
{
	IGRint           status=OM_S_SUCCESS;
	IGRpoint         point_to_proj1,point_to_proj2;
	IGRlong          long_rc;
	GRclassid        classid, GRdrawview_class_id;
	struct  GRid     act_own_id;
        IGRdouble       matrix[16];
        struct GRid     win_grid;
        IGRlong         rc;
        IGRint          ref_lock_state;
        IGRdouble       in_pts[6];
        IGRdouble       out_pts[6];
        double        ref_scale;
        struct  GRevent  event[2];
        IGRint          i;
        
        memcpy((char *)&event[0],(char *)events[3],sizeof(struct GRevent));
        memcpy((char *)&event[1],(char *)events[4],sizeof(struct GRevent));

       
	*msg   = MSSUCC;
        long_rc=1;
        rc =1;
        *ref_flag = FALSE;

	point_to_proj1[0] = events[3]->event.button.x;
	point_to_proj1[1] = events[3]->event.button.y;
	point_to_proj1[2] = events[3]->event.button.z;

	point_to_proj2[0] = events[4]->event.button.x;
	point_to_proj2[1] = events[4]->event.button.y;
	point_to_proj2[2] = events[4]->event.button.z;

	status = gr$get_active_owner ( msg = &long_rc,
	    			       mod_id =&md_env->md_id,
	    			       active_owner = &act_own_id);

        if (status & long_rc & 1) {

        /* check for active drawing view */
	status = om$get_classid (osnum = act_own_id.osnum,
				 objid = act_own_id.objid,
				 p_classid = &classid);

	status = om$get_classid (classname = "GRdrawview",
	    		         p_classid = &GRdrawview_class_id);

	if (classid == GRdrawview_class_id) 
		*act_flag = TRUE;
        }
        else *act_flag = FALSE;

	if (!(events[3]->subtype == GRst_REGULAR) &&  
		    ((events[3]->subtype >= GRst_KEYPOINT) && 
		    (events[3]->subtype <= GRst_ENDPOINT)))
          {
			/* Element generator is used */

			*dat_flag = FALSE;

				/* Element located is in Reference file */
                            status = COmeasure_view_values(msg,
                                              delta,
                                              events[3]->event.button.objid,
                                              events[3]->event.button.osnum,
                                              event);

                            status = COmeasure_get_ref_scale(msg,
                                 events[3]->located_object[0].located_obj.osnum,
                                 &events[3]->located_object[0].module_info,
                                 ref_flag,
                                 &ref_scale);
                            *scale  = ref_scale;
                            if (*ref_flag) return(TRUE);

	}
	else 
	{
			/* treat as data point */
            *dat_flag = TRUE;
        }

        if (*act_flag)  
           if (!(dat_flag))
              return(TRUE);

        ems$ref_plane_lock(
            msg = &rc,
            options = EMS_REF_PLANE_LOCK_INQ,
            mode = &ref_lock_state);
        if (!(1&rc))
                ref_lock_state = 0;


        if (ref_lock_state & EMS_REF_PLANE_LOCK_ON)
        {
             *ref_lock_flag=FALSE;

             ems$get_active_datum_plane( msg = &rc,
                                datpln = &win_grid);

             status =
                om$send(msg = message dim_plan.give_plane(
                                                (int *)&rc,
                                                matrix,
                                                md_env),
                        senderid = NULL_OBJID,
                        targetid = win_grid.objid,
                                             targetos = win_grid.osnum);

             in_pts[0] = events[3]->event.button.x;
             in_pts[1] = events[3]->event.button.y;
             in_pts[2] = events[3]->event.button.z;

             in_pts[3] = events[4]->event.button.x;
             in_pts[4] = events[4]->event.button.y;
             in_pts[5] = events[4]->event.button.z;

             i=2;
             MAptsxform(msg,&i,matrix,in_pts,out_pts);

             status =
                    COmeasure_delta_2pts(msg, delta, out_pts, &out_pts[3]);

             return(status);
        }  /* ref_plane lock on */
        else
        {
                /* ref lock off */
             *ref_lock_flag=TRUE;
                  COmeasure_proj_delta(msg,delta,events);
        }
        return(TRUE);
}


IGRlong COmeasure_proj_delta(msg, delta, events)
IGRlong         *msg;
IGRdouble       *delta;
struct GRevent  *events[];

{
	int              i;
	IGRint           status=OM_S_SUCCESS;
	IGRdouble        in_pts[6];
	IGRdouble        out_pts[6];
	IGRmatrix        matrix;


	*msg = MSSUCC;
	in_pts[0] = events[3]->event.button.x;
	in_pts[1] = events[3]->event.button.y;
	in_pts[2] = events[3]->event.button.z;

	in_pts[3] = events[4]->event.button.x;
	in_pts[4] = events[4]->event.button.y;
	in_pts[5] = events[4]->event.button.z;

	status =  om$send(msg = message IGEgragad.DPinrot(msg,
							matrix),
		                senderid = NULL_OBJID,
		                targetid = events[3]->event.button.objid,
		                targetos = events[3]->event.button.osnum);

	i=2;
	MAptsxform(msg,&i,matrix,in_pts,out_pts);

	status =
	         COmeasure_delta_2pts(msg, delta, out_pts, &out_pts[3]);

	return(status);
}


IGRlong COmeasure_delta_2pts( msg,delta,point1,point2)
IGRlong *msg;
IGRdouble       *delta;
IGRpoint        point1,point2;
{

	*msg = MSSUCC;

	delta[0] = point2[0] - point1[0] ;
	delta[1] = point2[1] - point1[1] ;
	delta[2] = point2[2] - point1[2] ;

        if(delta[0] < 0.0) delta[0] -= TOL_VAL;
          else             delta[0] += TOL_VAL;
        if(delta[1] < 0.0) delta[1] -= TOL_VAL;
          else             delta[1] += TOL_VAL;
        if(delta[2] < 0.0) delta[2] -= TOL_VAL;
          else             delta[2] += TOL_VAL;
	return(TRUE);
}

IGRlong COmeasure_act_proj_delta(msg,
                                 delta,
                                 events)
IGRlong           *msg;
IGRdouble         *delta;
struct  GRevent   *events[];
{
   IGRpoint       point_to_proj1, point_to_proj2;
   IGRint         status= OM_S_SUCCESS;

      *msg = MSSUCC;
      point_to_proj1[0] = events[3]->event.button.x;
      point_to_proj1[1] = events[3]->event.button.y;
      point_to_proj1[2] = events[3]->event.button.z;
      point_to_proj2[0] = events[4]->event.button.x;
      point_to_proj2[1] = events[4]->event.button.y;
      point_to_proj2[2] = events[4]->event.button.z;

      status = COcvt_pts_to_lcl_coord(msg,
                                       1,
                                       point_to_proj1,
                                       point_to_proj1);

      status = COcvt_pts_to_lcl_coord(msg,
                                       1,
                                       point_to_proj2 ,
                                       point_to_proj2 );
      status = COmeasure_delta_2pts(msg,
                           delta,
                           point_to_proj1,
                           point_to_proj2);
      return(TRUE);
}

                                 
IGRlong COmeasure_get_ref_scale(msg,locate_os,loc_env,ref_flag,ref_scale)
IGRlong *msg;
OMuword locate_os;
struct GRmd_env *loc_env;
IGRboolean *ref_flag;
double *ref_scale;
{
	IGRlong rc;
        IGRint status=OM_S_SUCCESS;
        struct GRid context;
        OM_S_OBJECT_LINKAGE  ref_objid[2];
        OM_S_CHANSELECT chan;
	OMuint count;
	
		/*|- Get Ref_Mgr ID -*/


        *msg = MSSUCC;
        
                context.objid = NULL_OBJID;

                status =
                GRfindcontext(
                        &rc,
                        &loc_env->md_env.matrix_type,
                        loc_env->md_env.matrix,
                        &locate_os,
                        &context);
		if(!(status & rc & 1) || context.objid ==NULL_OBJID)
		{
			/* Object in the Master OS */
                         *ref_flag = FALSE;
                         *ref_scale = 1;
		}
		else
		{
			/* Object in the Ref os */

                        *ref_flag = TRUE;

                        status=
                        om$make_chanselect ( channame="GRcontext.to_reffile",
                                     p_chanselect = &chan );

			status=
			om$get_channel_objects ( osnum=context.osnum,
                                 objid= context.objid,
                                 p_chanselect = &chan,
                                 list = ref_objid,
                                 size = 1,
                                 count  = &count);

			/* Get the Scale from the reffile object */

			if(count)
			{
			status=
			om$send(msg = message GRreffile.GRgetscale(&rc,
							ref_scale),
				senderid = NULL_OBJID,
				targetid = ref_objid[0].S_objid,
				targetos = ref_objid[0].osnum);
			}
			else
			{
				printf("  DANGER: ref file\n");
				*ref_scale = 1;
			}

		}

    return(TRUE);
}

IGRlong COmeasure_view_values(msg,delta,objid,osnum,events)
IGRlong         *msg;
IGRdouble       *delta;
OM_S_OBJID	objid;
OMuword		osnum;
struct GRevent  events[2];
{
 
    struct var_list list_var[2];
    int             i;
    IGRint          status=OM_S_SUCCESS;
    IGRdouble       in_pts[6];
    IGRdouble       out_pts[6];
    IGRmatrix       matrix;
    IGRlong         long_rc;
    IGRint          sts=MSSUCC;

        *msg = 1;
        in_pts[0] = events[0].event.button.x;
        in_pts[1] = events[0].event.button.y;
        in_pts[2] = events[0].event.button.z;

        in_pts[3] = events[1].event.button.x;
        in_pts[4] = events[1].event.button.y;
        in_pts[5] = events[1].event.button.z;


	list_var[0].var = VW_ROT_NO_CON;
	list_var[0].var_ptr = (char *)matrix;
	list_var[0].num_bytes = sizeof (IGRmatrix);
	list_var[0].bytes_returned = (IGRlong *)&long_rc;

	list_var[1].var = END_PARAM;
	list_var[1].var_ptr = NULL;
	list_var[1].num_bytes = 0;
        list_var[1].bytes_returned = NULL;

	sts=
             dp$inq_set_gragad (msg = &long_rc,
                                osnum = osnum,
                                gragad_objid = objid,
                                which_error = &long_rc,
                                var_list = list_var);

        i=2;
        MAptsxform(msg,&i,matrix,in_pts,out_pts);

        status =
                 COmeasure_delta_2pts(msg, delta, out_pts, &out_pts[3]);

        return(status);
}


end implementation COmeasure;
