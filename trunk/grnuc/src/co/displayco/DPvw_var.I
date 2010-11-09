/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:21 $
$Locker:  $
*/

/*
HISTORY:
        05/28/92:  Fix bug: ANGLE_ZOOM_TGL was not read in correclty in
	           initialization process -- [TW]. 
*/

class implementation DPvw;

#include <stdio.h>
#include <FI.h>

#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"

#include "grmsg.h"
#include "DPview.h"

static struct DPpyramid_t   DPpyrmd;	/* pyramid structure  */
static struct DPview_wrk_t  DPwrk;	/* working variable   */
static struct DPbase_gg_t   DPbase;	/* base gragad */

OM_S_OBJID   DPview_cmd_my_id;  /* global var, remembering the current view cmd objid */

%safe
#include "DPvw_var.h"
#include "DPvw_cal.h"
#include "DPsetinq.h"
#include "GRdpbfunc.h"
%endsafe

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static void DPform_notification __((int form_label, int gadget_label, 
                                    double value, Form form_ptr));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe



/*************** DPassign_var( ) ********************************/
/*								*/
/* Assign var pointers, let them point to the static var	*/
/*								*/
/****************************************************************/
IGRint DPassign_var(base_pp,wrk_pp,pyrmd_pp)
struct DPbase_gg_t   **base_pp;
struct DPview_wrk_t  **wrk_pp;
struct DPpyramid_t   **pyrmd_pp;
{
    *base_pp = &DPbase;
    *wrk_pp = &DPwrk;
    *pyrmd_pp = &DPpyrmd;

    return(TRUE);
}


/*----------------- Form operations ------------------------*/

/*********************************************************************/
/* If the view form not exist,then create one and initialize wrk_p   */
/*   If the form already exists, just display this form. But some    */
/* gadgets will only be displayed for some  commands.		     */
/*********************************************************************/

IGRint DPprepare_vw_form()
{
    void DPform_notification();
    IGRchar buf[80];
    IGRdouble tmp_double;

    if(DPwrk.view_form == NULL)
    {
       /*
	* create the view command form and initial the wrk_p and pyrmd_p
	* variables
	* This initialization only executed ONCE for the whole design session
	*/

	DPinit_vw_cmd(&DPwrk,&DPpyrmd);
    }

   /*
    * set cmd dependent gadgets and values
    */

   /* clear all cmd dependent gadgets */

    FIg_erase(DPwrk.view_form,ANGLE_TXT);
    FIg_erase(DPwrk.view_form,ANGLE_FLD);
    FIg_erase(DPwrk.view_form,ANGLE_ZOOM_TXT);  /* eye locked text */
    FIg_erase(DPwrk.view_form,ANGLE_ZOOM_TGL);  /* eye locked */
    FIg_erase(DPwrk.view_form,TARGET_LOCK_TXT);
    FIg_erase(DPwrk.view_form,TARGET_LOCK_TGL);

   /* display this cmd dependent gadgets, and set default setting */

    switch(DPwrk.cmd_type)
    {
	   case DP_AROUND_COI:
	   case DP_AROUND_EYE:
	   case DP_PAN:
	   case DP_MV_EYE_TAR:
	   case DP_TILT:
			  break;

	   case DP_ZOOM:
		    FIg_display(DPwrk.view_form,TARGET_LOCK_TXT);
		    FIg_display(DPwrk.view_form,TARGET_LOCK_TGL);
		break;

	   case DP_VWANGLE:
		    if(DPwrk.curr_win == -1 )
		    {
			FIfld_set_text(DPwrk.view_form,ANGLE_FLD,0,0," ",0);	
		    }
		    else if( !(DPwrk.flags & IS_PERSP) )
		    {
			FIfld_set_text(DPwrk.view_form,ANGLE_FLD,0,0,"0.0",0);	
		    }
		    else
		    {
			tmp_double = 180 * ( DPwrk.vw_angle / PI);
			sprintf(buf,"%4.1f",tmp_double);
			FIfld_set_text(DPwrk.view_form,ANGLE_FLD,0,0,
				buf,0);
		    }
		    FIg_display(DPwrk.view_form,ANGLE_TXT);
		    FIg_display(DPwrk.view_form,ANGLE_FLD);
    		    FIg_display(DPwrk.view_form,ANGLE_ZOOM_TXT);  /* eye locked text */
		    FIg_display(DPwrk.view_form,ANGLE_ZOOM_TGL);  /* eye locked */
		break;
    }

    return(TRUE);
}

DPerase_vw_form()
{
    if(DPwrk.view_form)
    	FIf_erase(DPwrk.view_form);
    return(TRUE);
}

DPdelete_vw_form()
{
    if(DPwrk.view_form)
    	FIf_delete(DPwrk.view_form);
    DPwrk.view_form = NULL;
    return(TRUE);
}

static void DPform_notification (
  int    form_label,
  int    gadget_label,
  double value,
  Form   form_ptr)
{
    IGRint i;
    IGRlong msg;
    IGRint pos,sel;
    IGRchar buf[80];
    IGRdouble tmp_double;

    struct var_list     inq_array[2];
    IGRlong 		nbytes_ret;
    IGRlong		error_var;
    IGRint		status;
    IGRint flag[2];

    switch(gadget_label)
    {
	case FI_CANCEL:
	case FI_ACCEPT:
		FIg_reset( DPwrk.view_form, gadget_label );
		FIf_erase(DPwrk.view_form);
		break;

	case ANGLE_FLD:
		/*
		 * change (mm) to angle, and set to wrk_p->form_angle,
		 * if curr_window is known (not -1) then change that view
		 * directly (update the window also)
		 * if curr_window not known, ask for current window. and change
 		 * it.
		 */
		 FIfld_get_text(DPwrk.view_form,ANGLE_FLD,0,0,40,buf,&sel,&pos);
		 if(DPwrk.curr_win == -1) 
		 {
		    ex$message(	field = ERROR_FIELD,msgnumb = (IGRlong)GR_E_IdentWinFirst);
		 }
		 else
		 {
		    sscanf(buf,"%lf",&tmp_double);

		    if( -179.9 < tmp_double && tmp_double < 179.9)
		    { 
		        DPset_angle(&msg,&DPbase,&DPwrk,&DPpyrmd,tmp_double);
		    }
		    else
		    {
			ex$message(field=ERROR_FIELD,
				msgnumb = (IGRlong)GR_E_IllegalViewAngle);
		    }
		 }
		 break;

	case AUTO_MOVE_TGL:
		DPwrk.s_auto = (IGRint)value;
		break;

	case DYNAMICS_TGL:
	     	DPwrk.s_real_dyn = (IGRint)value;
		break;

	case CLIP_ON_TGL:
	     	DPwrk.s_clipping = (IGRint)value;

		if(DPwrk.curr_win == -1) break;

	    	inq_array[0].var = GRAGAD_FLAGS;
    		inq_array[0].var_ptr = (char *)flag;
    		inq_array[0].num_bytes = sizeof(IGRint)*2;
		inq_array[0].bytes_returned = &nbytes_ret;
		inq_array[1].var = END_PARAM;

		i = DPwrk.curr_win;

		if(DPwrk.s_clipping==ON)
		{
		    DPbase.gg.flags |= FRONT_CLIP|BACK_CLIP;
		    DPwrk.flags = DPbase.gg.flags;
		    DPwrk.winflags[i] = DPbase.gg.flags;

		    flag[0] = FRONT_CLIP|BACK_CLIP;
		    flag[1] = FRONT_CLIP|BACK_CLIP;
		}
		else
		{
		    DPbase.gg.flags &= ~(FRONT_CLIP|BACK_CLIP);
		    DPwrk.flags = DPbase.gg.flags;
		    DPwrk.winflags[i] = DPbase.gg.flags;

		    flag[0] = FRONT_CLIP|BACK_CLIP;
		    flag[1] = 0;
		}

    		status = dp$inq_set_gragad(msg = &msg,
		          inq0_set1 = 1, calc_info = 1,
			 update = 1,
                      gragad_objid = DPwrk.windows[i].objid,
                             osnum = DPwrk.windows[i].osnum,
                       which_error = &error_var,
                          var_list = inq_array);
	     	break;

	case TARGET_LOCK_TGL:
	     	DPwrk.s_target_locked = (IGRint)value;
	     	break;

	case ANGLE_ZOOM_TGL:
	     	DPwrk.s_angle_zoom = (IGRint)value;
	     	break;

	case INDEX_ON_TGL:
	     	DPwrk.s_indexing = (IGRint)value;

		if( ! DPwrk.s_indexing )
		{
		    DPwrk.idx_flag = 0;
		}
	     	break;

	case AUTO_LOAD_TGL:
		DPwrk.s_auto_load = (int) value;
		break;
    }
}

/************************************************************************/
/* 									*/
/* create the view command form and initial the wrk_p and pyrmd_p	*/
/* variables				 				*/
/* This initialization only executed ONCE for the whole design session	*/
/*									*/
/************************************************************************/


IGRint DPinit_vw_cmd(wrk_p,pyrmd_p)
struct DPview_wrk_t  *wrk_p;
struct DPpyramid_t   *pyrmd_p;
{
    IGRint     i,j,sts,num_rows,sel,pos;
    IGRchar    buf[80];
    IGRint     sizbuf,nret;
    IGRdouble  value;
    IGRint     msg; 

   /*
    * create the view form
    */

    sts = FIf_new(100,"GRViewManip",DPform_notification,&wrk_p->view_form);
    if(sts)
    {
	fprintf(stderr,"DPvw_var.I: Can't create form GRViewManip\n");
	fflush(stderr);
	return(FALSE);
    }

   /*
    * init the wrk_p's status variable from the form's initial values 
    */

    FIg_get_value(wrk_p->view_form,DYNAMICS_TGL,&value);
    wrk_p->s_real_dyn = (int) value;

    FIg_get_value(wrk_p->view_form,CLIP_ON_TGL,&value);
    wrk_p->s_clipping = (int) value;

    FIg_get_value(wrk_p->view_form,TARGET_LOCK_TGL,&value);
    wrk_p->s_target_locked = (int) value;

    FIg_get_value(wrk_p->view_form,ANGLE_ZOOM_TGL,&value);
    wrk_p->s_angle_zoom = (int) value;

    FIg_get_value(wrk_p->view_form,INDEX_ON_TGL,&value);
    wrk_p->s_indexing = (int) value;

    FIg_get_value(wrk_p->view_form,AUTO_MOVE_TGL,&value);
    wrk_p->s_auto = (int) value;

    FIg_get_value(wrk_p->view_form,AUTO_LOAD_TGL,&value);
    wrk_p->s_auto_load = (int) value;


   /*
    * read in view angle indexing stops
    */

    FIfld_get_list_num_rows(wrk_p->view_form,ANGLE_FLD,0,&num_rows);

    if( num_rows > NUM_FOCAL_INDEX)
    {
        fprintf(stderr,"DPvw_var.I:  System -- Too many focal indexing stops\n"); 
        num_rows = NUM_FOCAL_INDEX;
    }

    for( i=0;i<num_rows; i++)  /* make the order of angles increasing */
    {
        FIfld_get_list_text(wrk_p->view_form,ANGLE_FLD,i,0,40,buf,&sel,&pos);

        if(sscanf(buf,"%lf",&(wrk_p->idx_angle[i]))!= 1)
        {
    	    fprintf(stderr,"DPvw_var.I: Error view form\n");
        }
    }

    for(i=num_rows;i<NUM_FOCAL_INDEX;i++)
    {
        wrk_p->idx_angle[i] = -10000.0;  /* unused values */
    }



    /*
     * init indexing tolerance values
     */

    wrk_p->idx_view_tol = 0.996;    	/* cosin(5deg) 	*/
    wrk_p->idx_cursor_tol = 0.087;	/* tan(5 deg) 	*/
    wrk_p->idx_horizon_tol = 0.087; 	/* sin(5deg)  	*/
    wrk_p->idx_angle_tol = 2.0;     	/* degree 	*/

   /*
    * build up pyramid elements structure,(their connections)
    */

    sizbuf = sizeof(struct IGRdisplay);
    gr$get_active_display(msg = &msg,
			  sizbuf = &sizbuf,
			  buffer = (char *)&pyrmd_p->dis_att,
			  nret = &nret );


    for(i=0;i<7;i++)
    {
	if(i < 5 ) 
 	{
	     pyrmd_p->lines[i].points = pyrmd_p->lines_pts[i];
    	     pyrmd_p->lines[i].num_points = 2;
	     dp$build_dis_buffer( buffer = &pyrmd_p->elements[i],
			type = IGRPY,
			display_att = &pyrmd_p->dis_att,
			geometry = &pyrmd_p->lines[i]);
	}
	else
       	{
	    j = i - 5;
	    pyrmd_p->planes[j].points = pyrmd_p->planes_pts[j];
	    pyrmd_p->planes[j].num_points = 5; 
	    dp$build_dis_buffer( buffer = &pyrmd_p->elements[i],
			type = IGRPY,
			display_att = &pyrmd_p->dis_att,
			geometry = &pyrmd_p->planes[j]);
	}
    }

    /* init pyrmd_p->p_lines[] */

    for(i=0;i<5;i++)
    {
	pyrmd_p->p_lines[i] = pyrmd_p->lines[i].points;
    }

    pyrmd_p->p_lines[5] = & pyrmd_p->planes_pts[0][0];
    pyrmd_p->p_lines[6] = & pyrmd_p->planes_pts[0][6];
    pyrmd_p->p_lines[7] = & pyrmd_p->planes_pts[1][6];
    pyrmd_p->p_lines[8] = & pyrmd_p->planes_pts[1][0];
    pyrmd_p->p_lines[9] = & pyrmd_p->planes_pts[0][3];
    pyrmd_p->p_lines[10] = & pyrmd_p->planes_pts[0][9];
    pyrmd_p->p_lines[11] = & pyrmd_p->planes_pts[1][9];
    pyrmd_p->p_lines[12] = & pyrmd_p->planes_pts[1][3];
  
    return(TRUE);
}

end implementation DPvw;

