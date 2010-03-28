class implementation DPvd;

#include <stdio.h>
#include <math.h>
#include <FI.h>

#include "OMindex.h"
#include "OMDB.h"
#include "OMmacros.h"
#include "exdef.h"
#include "msdef.h"
#include "exmacros.h"
#include "msmacros.h"

#include "igrdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbdef.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbmacros.h"
#include "dpstruct.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"

#include "grmsg.h"

#include "EMdtmacros.h"
#include "EMSdatumdef.h"

#include "dpgraphics.h"
#include "dpcodef.h"
#include "dpcomacros.h"
#include "UOMmacros.h"
#include "journal.h"
#include "grcmd.h"

#include "time.h"

#define DPvd_MAX_MODEL_RADIUS 10000000.0

from module import GRmod_passon;

extern IGRboolean DPdynamic_update_in_progress;

%safe
static int       num_frames=0;
%endsafe

/* ----------- */

void DPvd_get_rng_radius_center(IGRdouble *pts, IGRdouble *radius, IGRdouble *center)
{
    IGRlong msg;
    center[0] = (pts[0] + pts[3]) / 2.0;
    center[1] = (pts[1] + pts[4]) / 2.0;
    center[2] = (pts[2] + pts[5]) / 2.0;
    MA2ptdis(&msg,&pts[0],&pts[3],radius);
    *radius /= 2.0;
}


static int DPvd_get_model_range(IGRdouble *rng)
/*
NAME
        DPvd_get_model_range

DESCRIPTION
        This routine find current model's range from the R-tree.

SYNOPSIS
        static int DPvd_get_model_range(IGRdouble *rng)

PARAMETERS
        rng - pointer to an array of 6 doubles.

GLOBALS USED
RETURN VALUES
        TRUE - Sucessful
	FALSE - Failed.
NOTES
HISTORY
        06/20/93    T. Wang
	08/23/93    T. Wang - Don't allow mark "original view" within the cmd.
*/
{
    IGRint              sts;            /* OM return status         */
    IGRlong             msg;
    struct GRmd_env     mdenv;
    IGRlong             num_byte;
    IGRlong             byte_rcvd;   
    OM_S_RTREESTAT	rtree_info;
    OM_S_MESSAGE	rng_msg;
    IGRint		ret;
    IGRint		beg = 0;
    IGRint		fin = 0;

    struct get_rng
    {
	OM_p_RTREESTAT  rt_stat;
	IGRint	   *ret;
    } rng_arg;
 
    rtree_info.request_type = RTREE_PAGE_STATUS;
    rtree_info.rtree_status.page.level_no = 0;

    rng_arg.rt_stat = &rtree_info;
    rng_arg.ret     = &ret;

    /*  get range of rtree  */
    sts = om$make_message (classname = "GRrtree",
			   methodname = "get_stat",
			   size = sizeof(struct get_rng),
			   p_arglist = &rng_arg,
			   p_msg = &rng_msg);
    if (!(sts & 1)) goto error;
 
    num_byte = sizeof(struct GRmd_env);
    gr$get_module_env( 	msg =  (IGRint *)&msg, 
			sizbuf = (IGRint *)&num_byte, 
			buffer = (IGRchar *)&mdenv, 
			nret = (IGRint *)&byte_rcvd);
    if ( ! (1&msg) ) goto error;

    sts = om$send ( msg = message module.GRmod_passon
		   (&msg,&rng_msg,"module.primary",&beg,&fin),
		   targetid = mdenv.md_id.objid,
		   targetos = mdenv.md_id.osnum,
		   senderid = NULL_OBJID);

    if (!(sts & 1)) goto error;

    rng[0] =  rtree_info.rtree_status.page.page_range.r3ddkey.xmin;
    rng[1] =  rtree_info.rtree_status.page.page_range.r3ddkey.ymin;
    rng[2] =  rtree_info.rtree_status.page.page_range.r3ddkey.zmin;
    rng[3] =  rtree_info.rtree_status.page.page_range.r3ddkey.xmax;
    rng[4] =  rtree_info.rtree_status.page.page_range.r3ddkey.ymax;
    rng[5] =  rtree_info.rtree_status.page.page_range.r3ddkey.zmax;

    return(TRUE);

  error:
    printf("error in DPvd_get_model_range()\n");
    return(FALSE);
}


/* Get the model range by fitting a view. Note: this range only works
   for the given view because of layer ON/OFF or element display ON/OFF */ 

int DPvd_fit_model_range(struct GRid *p_gg, struct DPgra_gad *p_gragad,
			 int win_no, IGRdouble *rng )
{
    IGRlong msg = OM_S_SUCCESS;
    enum GRlocate_types loc_type;
    struct GRlc_upd_loc loc_parms;
    struct DP_information dp_info;
    struct GRmd_env     mdenv;

    gr$get_module_env( 	buffer = (IGRchar *)&mdenv);
    
    /* call locate          */
    loc_parms.is_ortho = 1;
    loc_type = GR_upd_loc;
    loc_parms.msg = OM_S_SUCCESS;
    loc_parms.mode = GRbd;
    loc_parms.alt_symb = 0;
    dp_info.gragad = p_gragad;
    dp_info.win_no = win_no;
    dp_info.is_update = TRUE;
    dp_info.is_hidden_line = FALSE;
    dp_info.hline_info = NULL;
    dp_info.hl_tiler = NULL;
    dp_info.is_fit = TRUE;
    dp_info.view_objid = p_gg->objid;
    dp_info.view_osnum = p_gg->osnum;
    
    dp_info.fit_range[0] = IGE_DESIGN_LIMITS_MAX;
    dp_info.fit_range[1] = IGE_DESIGN_LIMITS_MAX;
    dp_info.fit_range[2] = IGE_DESIGN_LIMITS_MAX;
    dp_info.fit_range[3] = IGE_DESIGN_LIMITS_MIN;
    dp_info.fit_range[4] = IGE_DESIGN_LIMITS_MIN;
    dp_info.fit_range[5] = IGE_DESIGN_LIMITS_MIN;
    
    loc_parms.sp_info = &dp_info;
    loc_parms.upd_range[0] = IGE_DESIGN_LIMITS_MIN;
    loc_parms.upd_range[1] = IGE_DESIGN_LIMITS_MIN;
    loc_parms.upd_range[2] = IGE_DESIGN_LIMITS_MIN;
    loc_parms.upd_range[3] = IGE_DESIGN_LIMITS_MAX;
    loc_parms.upd_range[4] = IGE_DESIGN_LIMITS_MAX;
    loc_parms.upd_range[5] = IGE_DESIGN_LIMITS_MAX;

    /* default value, in case it fails in GRlcquery() below */
    rng[0] = -DPvd_MAX_MODEL_RADIUS;
    rng[1] = -DPvd_MAX_MODEL_RADIUS;
    rng[2] = -DPvd_MAX_MODEL_RADIUS;
    rng[3] = DPvd_MAX_MODEL_RADIUS;
    rng[4] = DPvd_MAX_MODEL_RADIUS;
    rng[5] = DPvd_MAX_MODEL_RADIUS;

    if( ! GRlcquery(&msg,&mdenv, &loc_type, (IGRchar *) &loc_parms,NULL,NULL,NULL))
    {
	if( msg != OM_E_NOSUCHCLASS )
	{
	    return(FALSE);
	}
    }
    
    rng[0] = dp_info.fit_range[0];
    rng[1] = dp_info.fit_range[1];
    rng[2] = dp_info.fit_range[2];
    rng[3] = dp_info.fit_range[3];
    rng[4] = dp_info.fit_range[4];
    rng[5] = dp_info.fit_range[5];

    return(TRUE);
} 

void DPvd_print_wrk_info( struct DPvd_wrk_t gg)
/*
NAME
        DPvd_print_wrk_info

DESCRIPTION
        This routine prints the DPvd_wrk_t structure's old and new matrices and
        view volumes for debugging purposes

SYNOPSIS
        void DPvd_print_wrk_info( struct DPvd_wrk_t gg)

PARAMETERS
        gg(IN)	- the DPvd_wrk_t structure to print out

GLOBALS USED
	none

RETURN VALUES
	none

NOTES
HISTORY
	8/10/94 - Creation Date - B. Druzynski
*/
{
   fprintf( stderr, "Printing DPvd_wrk_t data:\n");
   fprintf( stderr, "-------------------------\n");
   fprintf( stderr, "  wrk_t.orig_gg: \n");
   fprintf( stderr, "  wrk_t.orig_gg.flags = %d\n", gg.orig_gg.flags);
   fprintf( stderr, "  wrk_t.orig_gg.origin = %f  %f  %f\n",
                       gg.orig_gg.origin[0],
                       gg.orig_gg.origin[1],
                       gg.orig_gg.origin[2]);
   fprintf( stderr, "  wrk_t.orig_gg.rotation = %f  %f  %f  %f\n",
                       gg.orig_gg.rotation[0][0],
                       gg.orig_gg.rotation[0][1],
                       gg.orig_gg.rotation[0][2],
                       gg.orig_gg.rotation[0][3]);
   fprintf( stderr, "                           %f  %f  %f  %f\n",
                       gg.orig_gg.rotation[1][0],
                       gg.orig_gg.rotation[1][1],
                       gg.orig_gg.rotation[1][2],
                       gg.orig_gg.rotation[1][3]);
   fprintf( stderr, "                           %f  %f  %f  %f\n",
                       gg.orig_gg.rotation[2][0],
                       gg.orig_gg.rotation[2][1],
                       gg.orig_gg.rotation[2][2],
                       gg.orig_gg.rotation[2][3]);
   fprintf( stderr, "                           %f  %f  %f  %f\n",
                       gg.orig_gg.rotation[3][0],
                       gg.orig_gg.rotation[3][1],
                       gg.orig_gg.rotation[3][2],
                       gg.orig_gg.rotation[3][3]);

   fprintf( stderr, "  wrk_t.orig_gg.vw_volume = %f  %f  %f\n",
                       gg.orig_gg.vw_volume[0],
                       gg.orig_gg.vw_volume[1],
                       gg.orig_gg.vw_volume[2] );
   fprintf( stderr, "                            %f  %f  %f\n",
                       gg.orig_gg.vw_volume[3],
                       gg.orig_gg.vw_volume[4],
                       gg.orig_gg.vw_volume[5] );

   fprintf( stderr, "  wrk_t.orig_gg.act_z = %f\n", gg.orig_gg.act_z);

   fprintf( stderr, "  wrk_t.orig_gg.dit_clip_range = %f  %f  %f\n",
                       gg.orig_gg.dit_clip_range[0],
                       gg.orig_gg.dit_clip_range[1],
                       gg.orig_gg.dit_clip_range[2] );
   fprintf( stderr, "                                 %f  %f  %f\n\n",
                       gg.orig_gg.dit_clip_range[3],
                       gg.orig_gg.dit_clip_range[4],
                       gg.orig_gg.dit_clip_range[5] );

   fprintf( stderr, "wrk_t.new_gg: \n");
   fprintf( stderr, "  wrk_t.new_gg.flags = %d\n", gg.new_gg.flags);
   fprintf( stderr, "  wrk_t.new_gg.origin = %f  %f  %f\n",
                       gg.new_gg.origin[0],
                       gg.new_gg.origin[1],
                       gg.new_gg.origin[2]);
   fprintf( stderr, "  wrk_t.new_gg.rotation = %f  %f  %f  %f\n",
                       gg.new_gg.rotation[0][0],
                       gg.new_gg.rotation[0][1],
                       gg.new_gg.rotation[0][2],
                       gg.new_gg.rotation[0][3]);
   fprintf( stderr, "                          %f  %f  %f  %f\n",
                       gg.new_gg.rotation[1][0],
                       gg.new_gg.rotation[1][1],
                       gg.new_gg.rotation[1][2],
                       gg.new_gg.rotation[1][3]);
   fprintf( stderr, "                          %f  %f  %f  %f\n",
                       gg.new_gg.rotation[2][0],
                       gg.new_gg.rotation[2][1],
                       gg.new_gg.rotation[2][2],
                       gg.new_gg.rotation[2][3]);
   fprintf( stderr, "                          %f  %f  %f  %f\n",
                       gg.new_gg.rotation[3][0],
                       gg.new_gg.rotation[3][1],
                       gg.new_gg.rotation[3][2],
                       gg.new_gg.rotation[3][3]);

   fprintf( stderr, "  wrk_t.new_gg.vw_volume = %f  %f  %f\n",
                       gg.new_gg.vw_volume[0],
                       gg.new_gg.vw_volume[1],
                       gg.new_gg.vw_volume[2] );
   fprintf( stderr, "                           %f  %f  %f\n",
                       gg.new_gg.vw_volume[3],
                       gg.new_gg.vw_volume[4],
                       gg.new_gg.vw_volume[5] );

   fprintf( stderr, "  wrk_t.new_gg.act_z = %f\n", gg.new_gg.act_z);
    
   fprintf( stderr, "  wrk_t.new_gg.dit_clip_range = %f  %f  %f\n",
                       gg.new_gg.dit_clip_range[0],
                       gg.new_gg.dit_clip_range[1],
                       gg.new_gg.dit_clip_range[2] );
   fprintf( stderr, "                                %f  %f  %f\n\n\n",
                       gg.new_gg.dit_clip_range[3],
                       gg.new_gg.dit_clip_range[4],
                       gg.new_gg.dit_clip_range[5] );
}


static int DPvd_get_orig_gg(struct GRid *gg_id, struct DPvd_wrk_t *wrk)

/*
NAME
        DPvd_get_orig_gg

DESCRIPTION
        This routine initialize following variables in the wrk structure
	for the window defined by gg_id.
	    1) read in orig_gg.
	    2) calculate wld_to_view, view_to_wld matrix
SYNOPSIS
       static int DPvd_get_orig_gg
                       (struct GRid *gg_id, 
		       struct DPvd_wrk_t *wrk)
PARAMETERS
        gg_id (IN) -- window to get info.
        wrk (OUT) -- See DESCRIPTION.

GLOBALS USED
RETURN VALUES
        TRUE -- Sucessful
	FALSE - Failed
NOTES
HISTORY
        06/20/93    T. Wang
*/
{
    IGRlong             msg;
    IGRint		sts;
    struct var_list     inq_array[2];
    IGRlong 		nbytes_ret;
    IGRlong		error_var;

    IGRdouble		trans[4][4];
    IGRshort four = 4;
    
    /* get gragad */

    inq_array[0].var = GRAGAD_STRUCT;
    inq_array[0].var_ptr = (char *)&wrk->orig_gg;
    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
    inq_array[0].bytes_returned = &nbytes_ret;
    inq_array[1].var = END_PARAM;
    
    sts = dp$inq_set_gragad(msg = &msg,
			    gragad_objid = gg_id->objid,
			    osnum = gg_id->osnum,
			    which_error = &error_var,
			    var_list = inq_array);
    if(!(sts&msg&1)) goto error;

    /* get wld_to_view, and view_to_wld */

    if(wrk->orig_gg.flags & IS_PERSP)
    {
	MAidmx(&msg,(IGRdouble *)trans);
	trans[0][3] = -(wrk->orig_gg).eye_pt[0];
	trans[1][3] = -(wrk->orig_gg).eye_pt[1];
	trans[2][3] = -(wrk->orig_gg).eye_pt[2];
	MAmulmx(&msg,&four,&four,&four,(wrk->orig_gg).rotation,
		(IGRdouble *)trans, wrk->wld_to_view);
    }
    else
    {
	memcpy((char*)wrk->wld_to_view,
	       (char*)(wrk->orig_gg).wld_to_view,sizeof(double)*16);
    }


    DPinvmxRT(wrk->wld_to_view,wrk->view_to_wld);
    
#ifdef DEBUG
    fprintf( stderr, "wrk before memcpy:\n");
    DPvd_print_wrk_info( *wrk );
#endif

    /*
       to avoid garbage in the new_gg field/structure, copy orig_gg.  This
       is to fix TRs #119419270 and 119420681.
     */
    memcpy((char *)&wrk->new_gg, (char *)&wrk->orig_gg,
            sizeof( struct DPgra_gad ));

#ifdef DEBUG
    fprintf( stderr, "wrk after memcpy:\n");
    DPvd_print_wrk_info( *wrk );
#endif

    return(TRUE);

  error:
    return(FALSE);
}


static void DPvd_draw_GN_2buffer(int db_enabled,
				 struct DPvd_draw_GN_t *draw_info,
				 int clear_first,
                                 int use_hilite)
{
    if(db_enabled)
    {
	WLuint32 lwin;
	IGRdouble pts_vwport[3],pts_wld[3];
	
	DPvd_get_GN_location(&lwin,pts_vwport,pts_wld);

	WLenter_db(lwin);
	DPvd_draw_GN(draw_info,clear_first, use_hilite); /* redraw GN */
	WLexit_db(lwin);
num_frames++;

	WLenter_db(lwin);
	DPvd_draw_GN(draw_info,clear_first, use_hilite); /* redraw GN */
	WLexit_db(lwin);
num_frames++;
    }
    else
    {
	DPvd_draw_GN(draw_info,clear_first, use_hilite ); /* redraw GN */
num_frames++;
    }	
}

void DPvd_get_window_center(WLuint32 lwin_no, IGRint *x, IGRint *y)
{
    struct WLbounds bounds,area_bounds;
    
    WLget_window_bounds(lwin_no,&bounds,&area_bounds);

    *x = area_bounds.width/2;
    *y = area_bounds.height/2;
}


static int DPvd_connect_window(struct GRid *gg_id, 
			       OM_S_OBJID myid, int connect) 
{
    OM_S_CHANSELECT to_winsup, to_gragad;
    int sts;
    
    if(gg_id->objid==NULL_OBJID) return(FALSE);
    

    /* Prepare disconnect and connect with the window */
    om$make_chanselect( channame = "IGEgragad.winsup", 
		       p_chanselect = &to_winsup );
    om$make_chanselect( channame = "IGEwinsup.gra_gad", 
		       p_chanselect = &to_gragad );
	
    if(connect)
    {
  	/* Connect to the window channel so that when window get deleted,
	   we can be notified */
	sts = om$send(msg = message Root.connect(to_winsup, NULL,myid, 
					   OM_Gw_current_OS,to_gragad, NULL),
		senderid = myid,
		targetid = gg_id->objid,
		targetos = gg_id->osnum);
    }
    else
    {
	/* Disconnect with old window */
	sts = om$send( msg = message Root.disconnect(to_winsup,
					       myid, OM_Gw_current_OS,
					       to_gragad ),
		senderid = myid,
		targetid = gg_id->objid,
		targetos = gg_id->osnum );
    }

    return(sts);
}


static DPvd_locate_elem_and_reposition_GN
  (struct DPvd_actwin *active_win_p,
   IGRint is_db_enabled,
   struct DPvd_wrk_t *wrk,
   IGRint *response, 
   IGRchar *response_data)
/*
NAME
        DPvd_locate_elem_and_reposition_GN

DESCRIPTION

        This routine try to located an element, or the end of an element.
	If locate is successful, it hilite the object and returns the 
	objid.

	The GN is placed 
	   at the projection point if an element is located, 
	   at the point of the end of element if such thing happens,
	   at the mouse's x,y location preserving the gn_z_screen if nothing
	      is located. 
        wld_ref_point[] is set to the same position as GN.

SYNOPSIS
       
PARAMETERS

GLOBALS USED
RETURN VALUES
        TRUE -- Sucessful
	FALSE - Failed
NOTES
HISTORY
        09/10/93    T. Wang
*/
{
    IGRlong msg;
    IGRint status;
    IGRshort prevstate, setstate;
    WLuint32 lwin;
    IGRdouble pts_vwport[6];
    IGRlong num_pts;

    /* clear */
    wrk->element_id.objid = NULL_OBJID;
    wrk->element_id.osnum = OM_Gw_current_OS;

    /* Turn off message system temporarily so that
       locate() will not make the double buffer dirty */
    ms$onoff(msg = &msg,prevstate = &prevstate, type = MS_OFF);

    /* Locate element, get element_id, rotation_axis, and wld_ref_point */
    status = DPvd_locate_element(active_win_p,wrk,response,response_data);

    /* Resume the message system */
    setstate = prevstate;
    ms$onoff(msg=&msg, prevstate=&prevstate, setstate=setstate, type=MS_SET);

    if(wrk->element_id.objid != NULL_OBJID)
    {
	/* Place GN at wrk->wld_ref_point[] (proj point or end point) */
	num_pts = 1;
	MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk->orig_gg.wld_to_viewport),
		   wrk->wld_ref_point,pts_vwport);
	DPvd_set_GN_location(active_win_p->win_no,pts_vwport,wrk->wld_ref_point);
    }
    else /* not located element, place GN at new x,y position but keep GN old z */
    {
	DPvd_get_GN_location(&lwin,pts_vwport,wrk->wld_ref_point);

	/* The z depth of GN should be re-calculated based on the GN's current wld
	   position, since the z in screeen coord. is incorrect after view changed */
	num_pts = 1;
	MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk->orig_gg.wld_to_viewport),
		   wrk->wld_ref_point,pts_vwport);

	pts_vwport[0] = wrk->x;
	pts_vwport[1] = wrk->y;

	MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk->orig_gg.viewport_to_wld),
		   pts_vwport,wrk->wld_ref_point);
	DPvd_set_GN_location(active_win_p->win_no,pts_vwport,wrk->wld_ref_point);
    }

    /* draw GN */
    DPvd_draw_GN_2buffer(is_db_enabled,NULL,TRUE,TRUE);

    if(wrk->element_id.objid != NULL_OBJID)
    {
       if(is_db_enabled)
       {
	   WLenter_db(active_win_p->win_no);
       }
   	
       /* Hilite the element */
       dp$display(msg = &msg,
	          osnum = active_win_p->grid.osnum,
	          objid = active_win_p->grid.objid,
	          oids = &wrk->element_id,
	          mode = GRhd);
   
       if(is_db_enabled)
       {
	   WLexit_db(active_win_p->win_no);
       }
    }   
    return TRUE;
}


method execute (int *response;
		char *response_data;
		int pos )
/*
NAME
        execute(method)
       
DESCRIPTION
        This is the major control of the view dynamics command.
        It checks events, call routines to change Gnomen state or
        view, until an unkown event arrives. Then it calls co$getevent()
        with mask=0 to setup the "response" variable, and leave this
        method.
       
SYNOPSIS
        method execute (int *response;
                        char *response_data;
	                int pos )
       
PARAMETERS
GLOBALS USED
RETURN VALUES
        Always OM_S_SUCCESS     
NOTES
HISTORY
        06/20/93    T. Wang
*/

{
    IGRint                 status = OM_S_SUCCESS;
    long                   msg;

    int                    hwwin;
      
    struct var_list        inq_array[2];
    IGRlong 	           nbytes_ret;
    IGRlong	           error_var;

    struct GRevent         myevent;

    struct DPvd_wrk_t      wrk;
    struct DPvd_draw_GN_t  gn_draw_info;
    struct DPvd_actwin     *active_win_p; /* point to active window structure */
    IGRdouble              pts[6];
    IGRlong                num_pts;
    char                   imp_unit[10];
    double                 dbu_to_imp;
    int                    k, old_gn_mode;
    int                    db_diff = FALSE; /* In DRAG,CONT mode, remember if
                                               we need to sync 2 buffers when
                                               command stops */
    
    IGRint                 double_buffer_enabled;   /* TRUE or FALSE */ 
    IGRint                 actual_double_buffer_enabled;   /* TRUE or FALSE */ 

    IGRint                 gnomen_erased = FALSE; /* TRUE or FALSE */

time_t  tstart=0.0, tend=0.0;

    /* flag no_cartv = No Change After Restore Temporary View
    ** will be set to TRUE, when temporary view restored,
    ** will be set to FALSE, when any window changes.
    ** the next restore temporary view will use the
    ** original view, when no_cartv is TRUE
    */
    int no_cartv = FALSE;

    /* if true, clear the message field */
    int clear_message = FALSE;

    /* put name of command in message field */
    ex$message (field = MESSAGE_FIELD, msgnumb = GRC_M_DisVieDyn);
    ex$message (field = PROMPT_FIELD, msgnumb = GR_M_ZmRotScroll);

    if ( DPvd_status_form_displayed() )
    {
      /* process status form here, so there are no double-buffering */
      /* problems w/ Save/Restore forms                             */
      co$getevent( msg = & msg,
                   event_mask = 0,
                   response = response,
                   response_data = response_data,
                   event = &myevent );

      if ( *response != EX_FORM_FINISHED )
      {
         return( OM_S_SUCCESS );
      }
    }

#if defined( ENV5 )
    if(ige$SR_active())
    {
	ex$message(field = ERROR_FIELD, msgnumb = GR_M_CntCvdSRform);
	*response = TERMINATE;
	return(OM_S_SUCCESS );
    }
#endif

    GRstatus_display_button(TRUE);
    ex$message(field = ERROR_FIELD, msgnumb = GR_M_OptFormAvail); 

    active_win_p = &ME.DPvd->DPvd_active_window;
    wrk.dyn_state = NODYNM_STATE;
    active_win_p->grid.objid = NULL_OBJID; /* no active window yet */
 
    if(JNL_playback())
    {
	/* Speciall JNL Playback for the following while() loop.
	 (Note: any major change in way events are handled in the 
	 following while() loop, especially in the DPvd_get_next_event(),
	 may need to change DPvd_jnl_playback() accordingly ) */
	
	DPvd_jnl_playback();

	/* Skip following while() loop, because it is already repeated in
	   the DPvd_jnl_playback() */
	goto journal_end;
    }

    /*
     ** initialization 
     */
 
    /*  Determine the active window */
    DPvd_get_active_window(&ME.DPvd->DPvd_active_window) ;

    if(active_win_p->grid.objid == NULL_OBJID)
    {
	/* no active window found, exit dynamics command */
	*response = TERMINATE;
	return( OM_S_SUCCESS );
    }
    else
    {
	DPvd_connect_window(&(active_win_p->grid),my_id,TRUE); 

	/* Init for the new window */
	active_win_p->view_changed = FALSE;

	/* For new window, old fitted size may not work */
	wrk.got_fitted_size = FALSE;
    }

    /* Get orig_gg */
    DPvd_get_orig_gg(&active_win_p->grid,&wrk);

    /*  Place gnomen in center of active window, on the active_z plane. 
	This is the initial GN position when entering dynamics */
    {
	IGRint x,y;
	DPvd_get_window_center(active_win_p->win_no,&x,&y);
	pts[0] = x, pts[1] = y, pts[2] = wrk.orig_gg.act_z_screen;
	num_pts = 1;
	MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk.orig_gg.viewport_to_wld),
		   &pts[0],&pts[3]);	
	DPvd_set_GN_location(active_win_p->win_no,&pts[0],&pts[3]);
	DPvd_draw_GN(NULL, TRUE, TRUE);
    }
    
    /* Try to get model range from Rtree root node first. But if
     the root node of the Rtree returns a HUGE range, this means that
     a reference file may have been attached, or some other things made
     this range inaccurate. The HUGE range number may cause dp$display()
     work inproperly. In this case, we'll use the same way as "fit" command
     to get the range. But remember that this range is window dependent. */

    wrk.get_model_size_by_fit = FALSE; 
    DPvd_get_model_range(pts);
    DPvd_get_rng_radius_center(pts,&(wrk.model_radius),wrk.model_center);
    
    if(wrk.model_radius > DPvd_MAX_MODEL_RADIUS)
    {
	/* model size must be inaccurate. Choose to use fit method to
	   get model size when need to fit_clipping planes LATER */
	wrk.get_model_size_by_fit = TRUE;
	wrk.got_fitted_size = FALSE;  /* not gotten yet */

	wrk.model_radius = DPvd_MAX_MODEL_RADIUS;  /* Just for safe */
    }

    wrk.curr_gn_mode = DPvd_get_GN_mode();

    /* Get status form's parameters */
    DPvd_attach_wrk_to_form(&wrk);

    /* Prepare the imp_unit and dbu_to_imp for the distance display in step mode */
    {
	/* convert to working unit */
	char   return_array[3][40];
	short flag = 0;
	short num_default;
			
	status = uom$get_default_units( msg = &msg,
				       table_name = GRIO_DISTANCE,
				       flag = &flag,
				       osnum = active_win_p->grid.osnum,
				       num_defaults = &num_default,
				       default_units = (GRIOalias_name *)return_array );
	strncpy(imp_unit,return_array[0],8);
	status = uom$cvt_dbu_to_value(osnum = active_win_p->grid.osnum,
				      ivalue = 1.0,
				      oalias = return_array[0],
				      ovalue = &dbu_to_imp);
    }


    /* Check if double buffering is possible. If it is,
       sync the double buffer so that it will be faster later */

    if ( WLenter_db(active_win_p->win_no) == WL_SUCCESS)
    {
	double_buffer_enabled = TRUE;
	actual_double_buffer_enabled = TRUE;

#if defined( X11)
        /* Draw to back buffer to sync with front buffer */

        inq_array[0].var = GRAGAD_STRUCT;
	inq_array[0].var_ptr = (char *)&wrk.orig_gg;
	inq_array[0].num_bytes = sizeof(struct DPgra_gad);
	inq_array[0].bytes_returned = &nbytes_ret;
	inq_array[1].var = END_PARAM;
		    
        DPdynamic_update_in_progress = TRUE;
	status = dp$inq_set_gragad(msg = &msg,
				   inq0_set1 = 1,
				   calc_info = 1, 
				   update = 1,
				   osnum = active_win_p->grid.osnum ,
				   gragad_objid = active_win_p->grid.objid ,
				   which_error  = &error_var,
				   var_list = inq_array);
        DPdynamic_update_in_progress = FALSE;

#endif
	DPvd_draw_GN(NULL, TRUE, TRUE);

        WLexit_db(active_win_p->win_no);

#if defined( X11 )
        /* If not on Env5, need to sync both buffers so there is no flash */
        WLenter_db(active_win_p->win_no);
        inq_array[0].var = GRAGAD_STRUCT;
        inq_array[0].var_ptr = (char *)&wrk.orig_gg;
        inq_array[0].num_bytes = sizeof(struct DPgra_gad);
        inq_array[0].bytes_returned = &nbytes_ret;
        inq_array[1].var = END_PARAM;
       
        DPdynamic_update_in_progress = TRUE;
        status = dp$inq_set_gragad(msg = &msg,
                                   inq0_set1 = 1,
                                   calc_info = 1,
                                   update = 1,
                                   osnum = active_win_p->grid.osnum ,
                                   gragad_objid = active_win_p->grid.objid ,
                                   which_error  = &error_var,
                                   var_list = inq_array);
        DPdynamic_update_in_progress = FALSE;
        DPvd_draw_GN(NULL, TRUE, TRUE);
        WLexit_db(active_win_p->win_no);
#endif
    }
    else 
    {
	double_buffer_enabled = FALSE;
	actual_double_buffer_enabled = FALSE;
    }

    if ( wrk.curr_gn_mode == DPvd_STEP )
    {
       double_buffer_enabled = FALSE;
    }


    /*
     * loop until we get an event which should be handled outside
     * our dynamics command
     */
   
    wrk.start_x = -1;
    wrk.start_y = -1;
    wrk.last_x = -1, wrk.last_y = -1;

num_frames=0;
    while(TRUE)
    {
	/* wait for event. Note, cannot put this into double buffering  */
	status = DPvd_get_next_event(wrk.dyn_state != NODYNM_STATE,
				     active_win_p->win_no,
				     &wrk.button, &wrk.transition, 
				     &wrk.x, &wrk.y,
				     &hwwin);


	/*
	 * if an unknown event type happened (perhaps a new command request)
	 * then drop out of the execute method and let command server take
	 * charge
	 */
	if (!(1&status)) goto wrapup;

	if(IGEstop())
        {
            IGEresetstop();
	}  

	if(wrk.button==NO_BUTTON)
	  /* in dynamics */
	{
	    /* Do nothing, if it is not in dynamics state */
	    if(wrk.dyn_state == NODYNM_STATE) continue;

	    /* For non continuous mode, if mouse position is not changed, do
	       nothing */
	    if(wrk.curr_gn_mode != DPvd_CONT &&
	       wrk.last_x == wrk.x && wrk.last_y == wrk.y) continue;

	    /* Change view according to mouse movement */
	    DPvd_change_view(active_win_p,&wrk);
	    no_cartv = FALSE;

	    /* Draw gnomen with rubber band and update view */
	    gn_draw_info.rubber_band[1].x = wrk.x;
	    gn_draw_info.rubber_band[1].y = wrk.y;

	    /* In align state, change the direction of the tangent and redraw
               the Gnomen if the rubber line is opposite and the length is 
               longer than 3 pixels and the angle between rubber line and
               tangent line is less than 45 degrees */

	    if(wrk.last_new_orig_same && wrk.new_orig_same &&
	       wrk.selected_axis == DPvd_GN_ELEMENT &&
	       DPvd_get_GN_align_state()!= 0) /* only this case need to check */
	    {
		int dx,dy;
		double proj1,proj2;
			
		dx = wrk.x - wrk.start_x;
		dy = -(wrk.y - wrk.start_y); /* UP positive y */
		if(dx*dx+dy*dy >= 9)  /* >=3 pixels distance */
		{
		    proj1 = dx*wrk.element_tangent_vw[0] + dy*wrk.element_tangent_vw[1];
		    
		    if(proj1 < 0.0)
		    {
			proj2 = dx*(-wrk.element_tangent_vw[1]) + dy*wrk.element_tangent_vw[0];

			if(fabs(proj1) > fabs(proj2))
			{
			    /* change tangent direction. 
			       notice, draw_info->elem_tangent pointing to wrk.ele.. */
			    wrk.rotation_axis[0] = -wrk.rotation_axis[0];
			    wrk.rotation_axis[1] = -wrk.rotation_axis[1];
			    wrk.rotation_axis[2] = -wrk.rotation_axis[2];
			    wrk.element_tangent_vw[0] = -wrk.element_tangent_vw[0];
			    wrk.element_tangent_vw[1] = -wrk.element_tangent_vw[1];
			    wrk.element_tangent_vw[2] = -wrk.element_tangent_vw[2];
				    
			    /* Let re-create gnomen lines */
			    gn_draw_info.first_elem_line = TRUE;

			    /* Redraw gnomen */
			    DPvd_draw_GN_2buffer(double_buffer_enabled,
                                                 &gn_draw_info,
                                                 TRUE,
                                                 TRUE);
			}
		    }
		}
	    } /* end change align tangent direction */


	    /* Display */

	    if(wrk.curr_gn_mode==DPvd_DRAG || wrk.curr_gn_mode==DPvd_CONT)
	    {
		if(wrk.last_new_orig_same && wrk.new_orig_same)
		{
		    /* New and orig are the same for at least 2 times, so
		       there is no need to set gragad and update view. */
		}
		else
		{
		    if(double_buffer_enabled)
                    {
                        WLenter_db(active_win_p->win_no);/* pair 1 */ 
                    }

		    /*
		     ** set new gragad and update window
		     */
		    inq_array[0].var = GRAGAD_STRUCT;
		    inq_array[0].var_ptr = (char *)&wrk.new_gg;
		    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
		    inq_array[0].bytes_returned = &nbytes_ret;
		    inq_array[1].var = END_PARAM;
		    
                    DPdynamic_update_in_progress = TRUE;
		    status = dp$inq_set_gragad(
                                        msg = &msg,
                                        inq0_set1 = 1,
					calc_info = 1, 
					update = 1,
					osnum = active_win_p->grid.osnum ,
					gragad_objid = active_win_p->grid.objid,
					which_error  = &error_var,
					var_list = inq_array);
                    DPdynamic_update_in_progress = FALSE;

		    db_diff = TRUE; /* 2 buffers may different now */
		    active_win_p->view_changed = TRUE;

		    wrk.last_new_orig_same = wrk.new_orig_same;

		    /* Draw gnomen with rubber band. We choose to erase the
                       hilite plane first, because shaded view update doesn't
                       erase hilite plane for us */
                    if( !gnomen_erased )
                    {
                       DPvd_erase_GN();
                       gnomen_erased = TRUE;
                    }

		    DPvd_draw_GN(&gn_draw_info,TRUE, FALSE);

		    if(double_buffer_enabled)
                    {
                        WLexit_db(active_win_p->win_no); /* pair 1 */
                        num_frames++;
                    }
		}
	    }
	    else /* step mode */
	    {
		if(wrk.x!=wrk.last_x || wrk.y!=wrk.last_y)
		{
		   /* Draw gnomen with rubber band and step value */
		    if((wrk.dyn_state==SCALE_STATE && 
			wrk.new_gg.flags&IS_PERSP && !wrk.limited_zoom)||
		       wrk.dyn_state == TRANSL_STATE)
		    {
			sprintf(gn_draw_info.step_string,"%.2f %s",
				wrk.step_value*dbu_to_imp, imp_unit);
		    }
		    else
		    {
			sprintf(gn_draw_info.step_string,"%d",
                                (int)wrk.step_value);
		    }
	    
		    DPvd_draw_GN_2buffer(double_buffer_enabled,
                                         &gn_draw_info,
                                         TRUE,
                                         TRUE);
		}
	    }
	    
	    wrk.last_x = wrk.x;
	    wrk.last_y = wrk.y;

	    /* For continuous mode, read in the current gragad info */
	    if(wrk.curr_gn_mode == DPvd_CONT)
	    {
		DPvd_get_orig_gg(&(active_win_p->grid),&wrk);

		/* For perspective unlimited zoom, we need to move GN to the
                   new active_z plane, because otherwise, when view changes,
                   GN may be outside of view volume, or even behind new eye_pt,
                   which will cause problems. Also need to get the new
                   wld_ref_point[] */

		if(wrk.dyn_state==SCALE_STATE &&
		   (wrk.orig_gg.flags & IS_PERSP) &&
		   !wrk.limited_zoom)
		{
		    DPvd_get_GN_location(&active_win_p->win_no,&pts[0],&pts[3]);
		    pts[2] = wrk.orig_gg.act_z_screen;
		    num_pts = 1;
		    MAptsxform(&msg,
                               &num_pts,
                               (IGRdouble *)(wrk.orig_gg.viewport_to_wld),
			       &pts[0],
                               &pts[3]);
		    DPvd_set_GN_location(active_win_p->win_no,&pts[0],&pts[3]);

		    /* Since old wld_ref_point may be behind new eye_pt, get a
		       new wld_ref_point which keeps the same zoom direction */
		    wrk.wld_ref_point[0] = pts[3];
		    wrk.wld_ref_point[1] = pts[4];
		    wrk.wld_ref_point[2] = pts[5];
		}
	    }
	}
	else  /* Button or key events, change states */
	{
	    /* Process common to all buttons */

            if(clear_message)
	    {
		/* clear the error field */
   	        ex$message (field = ERROR_FIELD, in_buff="");
		clear_message = FALSE;
	    }

	    /* When a dynamics phase ends and in double buffering mode, we need 
	       to copy the newest view into another display buffer so that they
               are the same and there is no shake when we enter the other
               buffer later.  But for step mode and align operation, we don't
               use double buffer to display, so don't need to do this here. If
               the active window is changed, there is no need to do this.

	       To redisplay the same thing in another buffer is awkward! But on
               CLIX, we don't have a routine to sync the 2 buffers. On SUN or
               other machines, we may need to use WLsync_buffers() to avoid the
               following piece of code [TW] */
	    
	    if(double_buffer_enabled && 
	       wrk.dyn_state != NODYNM_STATE /* was in dynamics */ &&
	       db_diff /* two display buffers diff */ &&
	       wrk.curr_gn_mode != DPvd_STEP &&
	       !(wrk.selected_axis == DPvd_GN_ELEMENT && DPvd_get_GN_align_state()!= 0) /* not align */ )
	    {
		if(IGEstop())
		{
		    IGEresetstop();

		    DPvd_draw_GN(NULL,TRUE, TRUE);
		}
		else
		{
		    /* Sync. the other buffer by dp$display() to it */
		    WLenter_db(active_win_p->win_no); /* pair 2 */
		
		    inq_array[0].var = GRAGAD_STRUCT;
		    inq_array[0].var_ptr = (char *)&wrk.new_gg;
		    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
		    inq_array[0].bytes_returned = &nbytes_ret;
		    inq_array[1].var = END_PARAM;

		    DPdynamic_update_in_progress = TRUE;
		    status = dp$inq_set_gragad(msg = &msg,
					   inq0_set1 = 1,
					   calc_info = 1, 
					   update = 1,
					   osnum = active_win_p->grid.osnum ,
					   gragad_objid = active_win_p->grid.objid ,
					   which_error  = &error_var,
					   var_list = inq_array);
		    DPdynamic_update_in_progress = FALSE;

		    /* Erase the old GN in this buffer */
		    DPvd_erase_GN();

		    WLexit_db(active_win_p->win_no); /* pair 2 */
num_frames++;

#if defined( X11 )
                    /* if on X, we need to make another call to dp$display
                       to make sure the buffers are synced */
		    WLenter_db(active_win_p->win_no); /* pair 2 */
		
		    inq_array[0].var = GRAGAD_STRUCT;
		    inq_array[0].var_ptr = (char *)&wrk.new_gg;
		    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
		    inq_array[0].bytes_returned = &nbytes_ret;
		    inq_array[1].var = END_PARAM;

		    DPdynamic_update_in_progress = TRUE;
		    status = dp$inq_set_gragad(msg = &msg,
					   inq0_set1 = 1,
					   calc_info = 1, 
					   update = 1,
					   osnum = active_win_p->grid.osnum ,
					   gragad_objid = active_win_p->grid.objid ,
					   which_error  = &error_var,
					   var_list = inq_array);
		    DPdynamic_update_in_progress = FALSE;

		    /* Erase the old GN in this buffer */
		    DPvd_erase_GN();

		    WLexit_db(active_win_p->win_no); /* pair 2 */
num_frames++;
#endif
		}	
	    }

	    if(wrk.button==DPvd_MIDDLE_MOUSE || wrk.button==DPvd_LEFT_MOUSE ||
	       wrk.button==DPvd_RIGHT_MOUSE)
	    {
		if(wrk.curr_gn_mode == DPvd_STEP && 
		   wrk.dyn_state != NODYNM_STATE &&
		   /* wrk.transition == DPvd_UP && */
		   !wrk.new_orig_same)
		{
		    /*
                       step mode finished, update window.  Use double buffering
                       to sync buffers.
		    */

		    if(IGEstop())
                    {
                        IGEresetstop();
                    }

		    inq_array[0].var = GRAGAD_STRUCT;
		    inq_array[0].var_ptr = (char *)&wrk.new_gg;
		    inq_array[0].num_bytes = sizeof(struct DPgra_gad);
		    inq_array[0].bytes_returned = &nbytes_ret;
		    inq_array[1].var = END_PARAM;
		    
                    DPdynamic_update_in_progress = TRUE;
		    status = dp$inq_set_gragad(
                                        msg = &msg,
				        inq0_set1 = 1,
				        calc_info = 1, 
				        update = 1,
				        osnum = active_win_p->grid.osnum ,
			                gragad_objid = active_win_p->grid.objid,
					which_error  = &error_var,
					var_list = inq_array);
                    DPdynamic_update_in_progress = FALSE;

		    active_win_p->view_changed = TRUE;

#ifdef ENV5
                    if(double_buffer_enabled)
		    {
#endif
                        WLenter_db( active_win_p->win_no);

			/* sync buffers for non CLIX machine. */
                        inq_array[0].var = GRAGAD_STRUCT;
                        inq_array[0].var_ptr = (char *)&wrk.new_gg;
                        inq_array[0].num_bytes = sizeof(struct DPgra_gad);
                        inq_array[0].bytes_returned = &nbytes_ret;
                        inq_array[1].var = END_PARAM;
		    
                        DPdynamic_update_in_progress = TRUE;
		        status = dp$inq_set_gragad(
                                        msg = &msg,
			 	        inq0_set1 = 1,
					calc_info = 1, 
					update = 1,
				        osnum = active_win_p->grid.osnum,
				        gragad_objid = active_win_p->grid.objid,
					which_error  = &error_var,
				        var_list = inq_array);
                        DPdynamic_update_in_progress = FALSE;

                        WLexit_db( active_win_p->win_no);
#ifdef ENV5
                    }
#endif
                }

		/* Check if the active window is changed.  Get new orig_gg */
		if(wrk.dyn_state == NODYNM_STATE &&
		   (wrk.transition==DPvd_DOWN ||
                    wrk.transition==DPvd_SINGLE_CLICK))
		{
		    struct GRid old_grid;

		    /* Check if the active window is changed */

		    old_grid = active_win_p->grid;
		    DPvd_get_active_window_id(hwwin, active_win_p);

		    if( old_grid.objid != active_win_p->grid.objid )
		    {
			/*
                           Active window changed. Erase old GN and draw 
			   new GN. Don't use double buffer here so that
			   the buffers will be synchronized later.
			   (Don't draw GN here so that element will be located
                           first
                        */

			DPvd_erase_GN();

			/* disconnect old and connect new */
			DPvd_connect_window(&old_grid,my_id,FALSE);
			DPvd_connect_window(&(ME.DPvd->DPvd_active_window.grid),my_id,TRUE);

		        /* Old view changed. Remember this in the window's
                           array for JNL */
		        DPvd_mark_changed(&old_grid);

			
			/* Init for the new window */
			active_win_p->view_changed = FALSE;
			wrk.got_fitted_size = FALSE;

			/* In the new view nothing is changed until now */
		        no_cartv = FALSE;

			/* Set GN location on the new window's active_z plane
                           since current GN's z depth may not work in the new
                           window.  Put GN outside window, so that the axis will
                           not be selected in the later code and a locate will
                           be performed first*/

			DPvd_get_orig_gg(&active_win_p->grid,&wrk);
			pts[0] = -100.0;
                        pts[1]= -100.0;
                        pts[2]=wrk.orig_gg.act_z_screen;
			num_pts = 1;
			MAptsxform(&msg,
                                   &num_pts,
                                   (IGRdouble *)(wrk.orig_gg.viewport_to_wld),
				   &pts[0],&pts[3]);
			DPvd_set_GN_location(active_win_p->win_no, &pts[0], &pts[3]);
		    }
		    else
		    {
			/* Init orig_gg */
			DPvd_get_orig_gg(&(active_win_p->grid),&wrk);
		    }
		}
	    }

	    /* For perspective unlimited zoom, we need to move GN to the new
	       active_z plane, because otherwise, when view changes, GN may 
	       be outside of view volume, or even behind new eye_pt, which will
	       cause problems. Also need to get new wld_ref_point[] */

	    if((wrk.orig_gg.flags & IS_PERSP) && 
	       wrk.dyn_state==SCALE_STATE &&
	       !wrk.limited_zoom)
	    {
		DPvd_get_GN_location(&active_win_p->win_no,&pts[0],&pts[3]);
		pts[2] = wrk.orig_gg.act_z_screen;
		num_pts = 1;
		MAptsxform(&msg,
                           &num_pts,
                           (IGRdouble *)(wrk.orig_gg.viewport_to_wld),
			   &pts[0],&pts[3]);
		DPvd_set_GN_location(active_win_p->win_no,&pts[0],&pts[3]);
	    }

	    /* These events allways stop dyn_state. */
	    wrk.dyn_state = NODYNM_STATE;
	    db_diff = FALSE;	/* init for new command */
	    
	    /* reset step string and value for step mode */
	    *gn_draw_info.step_string = '\0';
	    wrk.step_value = 0.0;

	    /*
	     * Additional process for each events
	     */

	    switch(wrk.button)
	    {
	      case DPvd_MIDDLE_MOUSE:	/* rotate button */

		switch(wrk.transition)
		{
		  case DPvd_DOWN:

		    /* Check if it changes operation mode. 
		       if GN mode changed, go back to get event */
		    old_gn_mode = DPvd_get_GN_mode();
		    wrk.curr_gn_mode = DPvd_check_toggle_GN_mode(active_win_p->win_no,wrk.x,wrk.y);
                    if ( wrk.curr_gn_mode == DPvd_STEP )
                    {
                        double_buffer_enabled = FALSE;
                    }
                    else
                    {
                        double_buffer_enabled = actual_double_buffer_enabled;
                    }

time(&tstart);
		    if(wrk.curr_gn_mode != old_gn_mode) 
		    {
			DPvd_draw_GN_2buffer(double_buffer_enabled,
                                             NULL,
                                             TRUE,
                                             TRUE);
			break;
		    }
		    
		    /* Check if it is on the X,Y,Z area of GN. 
		       if it is, rotate aound these axis */
		    wrk.selected_axis = DPvd_check_select_GN_axis(
                                                         active_win_p->win_no,
                                                         wrk.x,
                                                         wrk.y);

		    /* rotation dyn_state begins */
		    wrk.dyn_state = ROTATE_STATE;
		    wrk.last_new_orig_same = TRUE;
		    
		    /* Define rotation axis */
		    gn_draw_info.draw_flags = wrk.selected_axis;
		    if(wrk.selected_axis == DPvd_GN_XAXIS)
		    {
			wrk.rotation_axis[0] = wrk.orig_gg.rotation[0][0];
			wrk.rotation_axis[1] = wrk.orig_gg.rotation[0][1];
			wrk.rotation_axis[2] = wrk.orig_gg.rotation[0][2];
		    }
		    else if(wrk.selected_axis == DPvd_GN_YAXIS)
		    {
			wrk.rotation_axis[0] = wrk.orig_gg.rotation[1][0];
			wrk.rotation_axis[1] = wrk.orig_gg.rotation[1][1];
			wrk.rotation_axis[2] = wrk.orig_gg.rotation[1][2];
		    }
		    else if(wrk.selected_axis == DPvd_GN_ZAXIS)
		    {
			wrk.rotation_axis[0] = wrk.orig_gg.rotation[2][0];
			wrk.rotation_axis[1] = wrk.orig_gg.rotation[2][1];
			wrk.rotation_axis[2] = wrk.orig_gg.rotation[2][2];
		    }
		    else if(wrk.selected_axis == DPvd_GN_CENTER)
		    {
			/* this init has no use.  */
			wrk.rotation_axis[0] = 1.0;
			wrk.rotation_axis[1] = 0.0;
			wrk.rotation_axis[2] = 0.0;
		    }
		    else if(wrk.selected_axis == 0) /* no GN axis selected */
		    {
			/* Try to locate element, and reposition GN */
			DPvd_locate_elem_and_reposition_GN(
                                           active_win_p,
					   double_buffer_enabled,
					   &wrk,
					   response,
                                           response_data);

			if(wrk.element_id.objid != NULL_OBJID &&
                           wrk.locate_pt_type==1)
			{
			    wrk.selected_axis = DPvd_GN_ELEMENT;
			}
			else
			{
			    /* free rotate at new GN position */
			    wrk.selected_axis = DPvd_GN_CENTER;
			}
		    }
		    else 
		    {
			/* control can not reach here */
		    }
		    

		    /* Clear GN align state if it was ON. (In the
                       DPvd_GN_ELEMENT case, align operation is possible.) */
		    if(wrk.selected_axis != DPvd_GN_ELEMENT)
		    {
			DPvd_set_GN_align_state(0);
		    }

		    /* Make the center of GN the wld_ref_point */
		    {
			WLuint32 win;
			DPvd_get_GN_location(&win,pts,wrk.wld_ref_point);
		    }

		    /* start of rubber band */
		    if(wrk.selected_axis == DPvd_GN_ZAXIS ||
		       wrk.selected_axis == DPvd_GN_CENTER ||
		       wrk.selected_axis == DPvd_GN_ELEMENT)
		    {
			/* start of rubber band */
			wrk.start_x = pts[0];
			wrk.start_y = pts[1];
		    }
		    else
		    {
			wrk.start_x = wrk.x;
			wrk.start_y = wrk.y;
		    }

		    if(wrk.selected_axis == DPvd_GN_ZAXIS)
		    {
			/* set tilt base vectore based on rubber band */
			DPvd_set_tilt_base_vec(&wrk);
		    }
		    
		    /* set GN rubber band info */
		    gn_draw_info.draw_flags = DPvd_GN_RUBBER;
		    gn_draw_info.rubber_band[0].x = wrk.start_x;
		    gn_draw_info.rubber_band[0].y = wrk.start_y;
		    gn_draw_info.rubber_band[1].x = wrk.start_x;
		    gn_draw_info.rubber_band[1].y = wrk.start_y;

		    /* rubber line tolerance for rotation */
		    /* wrk.rubber_tolerance = DPvd_get_GN_size() * 0.8; */
		    if(DPvd_get_GN_align_state() != 0)
		      wrk.rubber_tolerance = 12;
		    else
		      wrk.rubber_tolerance = 5; 

		    /* set GN element tangent line info */
		    if(wrk.selected_axis == DPvd_GN_ELEMENT)
		    {
			/* Calculate the vector in the window. */

			if(!(wrk.orig_gg.flags & IS_PERSP))
			{
			    num_pts = 1;
			    MAptsxform(&msg,
                                       &num_pts,
                                       (IGRdouble *)(wrk.orig_gg.rotation),
				       wrk.rotation_axis,
                                       wrk.element_tangent_vw);
			}
			else /* perspective */
			{
			    IGRdouble vec1[3];
			    
			    /* Use wld_to_viewport to solve the perspective
                               projection problem */
			    pts[0] = wrk.wld_ref_point[0];
			    pts[1] = wrk.wld_ref_point[1];
			    pts[2] = wrk.wld_ref_point[2];
			    pts[3] = pts[0] + wrk.rotation_axis[0];
			    pts[4] = pts[1] + wrk.rotation_axis[1];
			    pts[5] = pts[2] + wrk.rotation_axis[2];
			    num_pts = 2;
			    MAptsxform(&msg,
                                     &num_pts,
                                     (IGRdouble *)(wrk.orig_gg.wld_to_viewport),
                                     pts,
                                     pts);

			    vec1[0] = pts[3] - pts[0];
			    vec1[1] = pts[4] - pts[1];
			    vec1[2] = pts[5] - pts[2];
      			    MAunitvc(&msg,vec1,wrk.element_tangent_vw);

			    wrk.element_tangent_vw[1] = -wrk.element_tangent_vw[1]; /* make up direc positive */   
			}
			
			gn_draw_info.draw_flags |= DPvd_GN_ELEMENT;
			gn_draw_info.elem_tangent = wrk.element_tangent_vw;
			gn_draw_info.elem_id = &wrk.element_id;
			gn_draw_info.gg_id = &(active_win_p->grid);

			gn_draw_info.first_elem_line = TRUE;
		    }
		    
		    /* Hilite rotation axis */
		    gn_draw_info.draw_flags |= wrk.selected_axis;

		    /* draw gnomen with highlighted element 
		       or highlighted rotation axis, so that user can see
		       before the view changes */
		    DPvd_draw_GN_2buffer(double_buffer_enabled,
                                         &gn_draw_info,
                                         TRUE,
                                         TRUE);

#                   if defined (XGL) || defined (OPENGL)
                    if ( wrk.curr_gn_mode != DPvd_STEP )
                       {
                       /*fprintf( stderr, "---------Hilite Disabled---------\n" );*/
		       WLdisable_hilite();
                       }
#                   endif
		    break;

		  case DPvd_UP: /* rotation end */
		   
#                   if defined (XGL) || defined (OPENGL)
                    if ( wrk.curr_gn_mode != DPvd_STEP )
                       {
                       /*fprintf( stderr, "---------Hilite Enabled---------\n" );*/
                       WLenable_hilite( active_win_p->win_no );
                       }
#                   endif
 
		    /* printf("middle up event\n"); */
		    
		    /* Check if it is an align operation */
		    if(wrk.selected_axis == DPvd_GN_ELEMENT &&
		       (DPvd_get_GN_align_state()) != 0)
		    {
                        DPvd_align_view( active_win_p, &wrk );

			if(IGEstop()) IGEresetstop();

			/*
			 ** set new gragad and update window
			 */

			inq_array[0].var = GRAGAD_STRUCT;
			inq_array[0].var_ptr = (char *)&wrk.new_gg;
			inq_array[0].num_bytes = sizeof(struct DPgra_gad);
			inq_array[0].bytes_returned = &nbytes_ret;
			inq_array[1].var = END_PARAM;
		    
                        DPdynamic_update_in_progress = TRUE;
			status = dp$inq_set_gragad(msg = &msg,
					   inq0_set1 = 1,
					   calc_info = 1, 
					   update = 1,
					   osnum = active_win_p->grid.osnum ,
					   gragad_objid = active_win_p->grid.objid ,
					   which_error  = &error_var,
					   var_list = inq_array);
                        DPdynamic_update_in_progress = FALSE;

			active_win_p->view_changed = TRUE;

			DPvd_set_GN_align_state(0); /* turn off align */

			if(double_buffer_enabled)
			{
			    /* Sync buffer */
                            WLenter_db( active_win_p->win_no);
			    inq_array[0].var = GRAGAD_STRUCT;
                            inq_array[0].var_ptr = (char *)&wrk.new_gg;
                            inq_array[0].num_bytes = sizeof(struct DPgra_gad);
                            inq_array[0].bytes_returned = &nbytes_ret;
                            inq_array[1].var = END_PARAM;
 
                            DPdynamic_update_in_progress = TRUE;
                            status = dp$inq_set_gragad(msg = &msg,
                                           inq0_set1 = 1,
                                           calc_info = 1,
                                           update = 1,
                                           osnum = active_win_p->grid.osnum ,
                                           gragad_objid = active_win_p->grid.objid ,
                                           which_error  = &error_var,
                                           var_list = inq_array);
                            DPdynamic_update_in_progress = FALSE;
 
                            WLexit_db( active_win_p->win_no);
                        }
		    }

		    DPvd_erase_GN();

		    DPvd_draw_GN_2buffer(double_buffer_enabled,NULL,TRUE,TRUE);
time(&tend);
/*fprintf(stderr, "frames per sec = %f\n",
                 num_frames/((float)( tend - tstart)));*/
num_frames=0;
gnomen_erased = FALSE;
		    break;
		    
		  case DPvd_SINGLE_CLICK:
		    
		    /* check if it changes operation mode. 
		       if GN mode changed, go back to get event */
		    old_gn_mode = DPvd_get_GN_mode();
		    wrk.curr_gn_mode = DPvd_check_toggle_GN_mode(active_win_p->win_no,wrk.x,wrk.y);
                    if ( wrk.curr_gn_mode == DPvd_STEP )
                    {
                       double_buffer_enabled = FALSE;
                    }
                    else
                    {
                       double_buffer_enabled = actual_double_buffer_enabled;

                       /* Sync buffers if old mode was step and new mode 
                          is not step */
                       if ( double_buffer_enabled && old_gn_mode == DPvd_STEP )
                       { 
/*
                          WLsync_buffers( active_win_p->win_no );
*/
                       } 
                    }

		    if(wrk.curr_gn_mode != old_gn_mode) 
		    {
			DPvd_draw_GN_2buffer(double_buffer_enabled,
                                             NULL,
                                             TRUE,
                                             TRUE );
			break;
		    }

		    /* check if it is on the X,Y,Z area of GN. 
		       if it is, prepare or cancel align states */
		    
		    k = DPvd_get_GN_align_state();
		    wrk.selected_axis = DPvd_check_set_GN_align_state(active_win_p->win_no,wrk.x,wrk.y);
		    if(wrk.selected_axis != k) 
		    { 
			DPvd_draw_GN_2buffer(double_buffer_enabled,
                                             NULL,
                                             TRUE,
                                             TRUE);
			break; /* align state changed */
		    }
		    
		    /* Try to locate element, and reposition GN */
		    DPvd_locate_elem_and_reposition_GN(active_win_p,
						       double_buffer_enabled,
						       &wrk,
						       response,response_data);
		    break;

                  default:
                       goto wrapup;
		}
		break;
		
		
	      case DPvd_RIGHT_MOUSE:
		
		switch(wrk.transition)
		{
		  case DPvd_DOWN:
			    
		    /* pan mode starts */
		    wrk.dyn_state = TRANSL_STATE;
		    wrk.last_new_orig_same = TRUE;

		    /* Try to locate element, and reposition GN */
		    DPvd_locate_elem_and_reposition_GN(active_win_p,
						       double_buffer_enabled,
						       &wrk,
						       response,response_data);

		    /* Make the center of GN the wld_ref_point */
		    {
			WLuint32 win;
			DPvd_get_GN_location(&win,pts,wrk.wld_ref_point);
		    }
		    
		    wrk.start_x = wrk.x;
		    wrk.start_y = wrk.y;
		    
		    /* draw GN rubber band info */
		    gn_draw_info.draw_flags = DPvd_GN_RUBBER;
		    gn_draw_info.rubber_band[0].x = wrk.start_x;
		    gn_draw_info.rubber_band[0].y = wrk.start_y;
		    gn_draw_info.rubber_band[1].x = wrk.start_x;
		    gn_draw_info.rubber_band[1].y = wrk.start_y;
	    
		    break;
		    
		  case DPvd_UP: 
		    /* pan mode end. For drag and step mode, if the end point
		     is inside window, place new GN there. */
		    DPvd_draw_GN_2buffer(double_buffer_enabled,NULL,1,TRUE);
		    break;
		    
		  case DPvd_SINGLE_CLICK:
		    /* Display GN at center of current window */
		    {
			WLuint32 lwin;
			IGRint x,y;
			DPvd_get_GN_location(&lwin,&pts[0],&pts[3]);

			num_pts = 1;
			MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk.orig_gg.wld_to_viewport),
				   &pts[3],&pts[0]); /* Calculate z depth based on new view */
			DPvd_get_window_center(lwin, &x,&y);
			pts[0] = x;
			pts[1] = y;
			MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk.orig_gg.viewport_to_wld),
				   &pts[0],&pts[3]);
			DPvd_set_GN_location(active_win_p->win_no,&pts[0],&pts[3]);
			DPvd_draw_GN_2buffer(double_buffer_enabled,NULL,1,TRUE);
		    }
		    
		    break;

                  default:
                       goto wrapup;
		}
		break;
		
		
	      case DPvd_LEFT_MOUSE:
		
		switch(wrk.transition)
		{
		  case DPvd_DOWN:
		    
		    /* zoom mode on */
		    wrk.dyn_state = SCALE_STATE;
		    wrk.last_new_orig_same = TRUE;

		    /* Try to locate element, and reposition GN */
		    DPvd_locate_elem_and_reposition_GN(active_win_p,
						       double_buffer_enabled,
						       &wrk,
						       response,response_data);
		    
		    /* Make GN center the wld_ref_point */
		    {
			WLuint32 win;
			DPvd_get_GN_location(&win,pts, wrk.wld_ref_point); 
		    }

		    wrk.start_x = wrk.x;
		    wrk.start_y = wrk.y;

		    /* draw GN rubber band info */
		    gn_draw_info.draw_flags = DPvd_GN_RUBBER;
		    gn_draw_info.rubber_band[0].x = wrk.start_x;
		    gn_draw_info.rubber_band[0].y = wrk.start_y;
		    gn_draw_info.rubber_band[1].x = wrk.start_x;
		    gn_draw_info.rubber_band[1].y = wrk.start_y;
	    
		    break;
		    
		  case DPvd_UP: 

		    DPvd_draw_GN_2buffer(double_buffer_enabled,NULL,TRUE,TRUE);
		    break;
		    
		  case DPvd_SINGLE_CLICK:

		    /* Try to locate element, and reposition GN */
		    DPvd_locate_elem_and_reposition_GN(active_win_p,
						       double_buffer_enabled,
						       &wrk,
						       response,response_data);
		    break;

                  default:
                       goto wrapup;
		}
		break;


	      case PF2:
	      case C2:
		/* resp. F2 on SGI/SUN */
		/* mark and store current (temporary) view */
		if(DPvd_mark_view(FALSE, &active_win_p->grid, NULL)==0)
		{
   	           ex$message (field = ERROR_FIELD,
                      msgnumb = GR_I_CntMrkVie);
		}   
		else
		{
   	           ex$message (field = ERROR_FIELD,
                      msgnumb = GR_I_MrkTmpVie);

		   /* Save the marked view in the JNL file */
		   if(JNL_journal())
		   {
		       DPvd_jnl_mark_view(FALSE, &active_win_p->grid);
		   }
		}
		clear_message = TRUE;
		break;

#ifdef NOTUSED
	/* 08/23/93, T.Wang: Don't allow mark original view from inside
              view dynamics. */

	      case PF2_SHIFT:
	      case B2:
		/* resp. SHIFT_F2 on SGI/SUN */
		/* mark current view as original view */
		if(DPvd_mark_view(TRUE, &active_win_p->grid, NULL)==0)
		{
   	           ex$message (field = ERROR_FIELD,
                      msgnumb = GR_I_CntMrkVie);
		}
		else
		{
   	           ex$message (field = ERROR_FIELD,
                      msgnumb = GR_I_MrkOriVie);
		}
		clear_message = TRUE;
		break;
#endif
		
	      case PF3:
	      case C3:

#ifdef NOTUSED 09/14/93 T.Wang: Make restore view act consistently with the 
		"restore view" command
		/* resp. F3 on SGI/SUN */
		if(no_cartv )
		{
		  DPvd_clear_view(FALSE, &active_win_p->grid);
		}

		/* restore to the last saved marked view */
		/* and update window */
		DPvd_restore_view(FALSE, &active_win_p->grid);
		/* Draw gnomen no need to erase hilite */
		DPvd_draw_GN(NULL,0);
		/* when there is no change, the next PF3/C3 should
                ** restore the original view
                */
		no_cartv = TRUE;
#endif
		DPvd_restore_view2(FALSE,&active_win_p->grid);
		active_win_p->view_changed = TRUE;
		break;

	      case DPvd_WINDOW_EVENT:
		/* In the DPvd_get_next_event() routine, DPhandle_event() has
		   been called. So the necceary message has been sent through
		   the "winup" channel. Now we process the GN accordingly 

		   Becuase window size change can cause gragad change, also can
		   cause old GN to be outside view, we need to process these 
		   cases */

		
		if(active_win_p->grid.objid != NULL_OBJID) 
		{
		    /* get new gragad */
		    DPvd_get_orig_gg(&active_win_p->grid,&wrk);
		    active_win_p->view_changed = TRUE;

		    /* Reposition GN if needed */
		    DPvd_get_GN_location(&active_win_p->win_no,&pts[0],&pts[3]);
		    num_pts = 1;
		    MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk.orig_gg.wld_to_viewport),
			       &pts[3],&pts[0]);
		    if(pts[0]<0.0 || pts[0]>wrk.orig_gg.dit_clip_range[3] ||
		       pts[1]<0.0 || pts[1]>wrk.orig_gg.dit_clip_range[4] )
		    {
			pts[0] = wrk.orig_gg.dit_clip_range[3]/2.0;
			pts[1] = wrk.orig_gg.dit_clip_range[4]/2.0;
			MAptsxform(&msg,&num_pts,(IGRdouble *)(wrk.orig_gg.viewport_to_wld),
				   &pts[0],&pts[3]);
			DPvd_set_GN_location(active_win_p->win_no,&pts[0],&pts[3]);
		    }
		    
		    /* Display GN */
                    if ( double_buffer_enabled )
                    {
                       WLsync_buffers( active_win_p->win_no );
                    }
		    DPvd_draw_GN_2buffer(double_buffer_enabled,NULL,TRUE,TRUE);
		    
		}
		else /* active window got killed */
		{
		    goto wrapup;
		}
		
		break;

	      default:
		/* an unknown button, may be another command
		 ** request, leave command 
		 */
		goto wrapup;
	    }
	} /* button was pressed */
    } /* while get an event */

  wrapup:

    if(JNL_journal())
    {
	if(active_win_p->grid.objid != NULL_OBJID /* window could be deleted */ &&
	   active_win_p->view_changed)
	{
	    DPvd_mark_changed(&active_win_p->grid);
	}
			
	/* Save changed view to journal file */
	DPvd_jnl_save_changed();

	/* Write jnl end mark */
	DPvd_jnl_mark_end();
    }

  journal_end:

    /* dettach the wrk from the form, since wrk variable no longer exists
       outside this execute() */
    DPvd_attach_wrk_to_form((struct DPvd_wrk_t*) NULL);

    /* Let any other command, event to terminate this command. So
       this command is more like a "mode".
    *response = TERMINATE; 
    */

#if defined( ENV5 )
    /* In ENV5 control key events other than C2,C3 might have been taken 
       out from the event queue and were unable to be put back. In this
       case, we save the control keys to the journal file directly. 
    */
    DPvd_put_control_key_to_jnl();
#endif

    /* This will process the Status Form and some other events.
       (Note, some events, like a click on the empty space of the panel menu,
       will make next co$getevent() wait. User has to input some meaningful
       event to continue. But we don't have a good solution to this non-serise
       problem) */
    co$getevent(msg = & msg,
                event_mask = 0,
	        /* msgnum = GR_P_IdWin, */
	        response = response,
	        response_data = response_data,
	        event = &myevent );

    /* Clean up */
    if(active_win_p->grid.objid != NULL_OBJID && 
       !JNL_playback() /* when playback, GN may not be initialized well */ )
    {
	/* window not deleted */
	DPvd_erase_GN();
    }

    /* Turn off the status form button */
    GRstatus_display_button(FALSE);
    
    return ( OM_S_SUCCESS );

}/* end execute method */


method status_disp()
{
    DPvd_display_status_form( TRUE );
    return( OM_S_SUCCESS );
}

method wakeup(int pos )

{
    IGRlong msg;

    /* read the gn_mode from the design file through the DPcodpb  */
    /* messages and assign it to the current gn_mode value -- HSG */
    DPvd_set_GN_mode();

    DPvd_display_status_form( FALSE );

    /* if edge curves are currently not locatable,
     ** set this mode locally (will be reset when sleep)
     */
    ME.DPvd->edges_locatable = EFedge_curves_locatable();
    if(! ME.DPvd->edges_locatable)
      EFset_locate_eligibility(&msg, 1, "EMSedge");
    
   return( OM_S_SUCCESS );
}

method sleep(int pos )

{
    IGRlong msg;
    
    DPvd_erase_status_form();
    
    /* reset edge locatability */
    if(! ME.DPvd->edges_locatable)
      EFset_locate_eligibility(&msg, 0, "EMSedge");

   return( OM_S_SUCCESS );
}

method pre_delete(
  IGRlong *msg )
{
    *msg = OM_S_SUCCESS;

    /* The window.grid may not be set in journal playback. So we don't
       disconnect with the window. It doesn't matter any way. (TW)
       DPvd_connect_window(&(ME.DPvd->DPvd_active_window.grid),my_id,FALSE);
     */

    ME.DPvd->DPvd_active_window.grid.objid = NULL_OBJID;

    DPvd_delete_status_form();

    return( OM_S_SUCCESS );
}

end implementation DPvd;
