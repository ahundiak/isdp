/*----
%GP% CODE CLASSIFICATION
-----
%HD%
        CLASS NAME:     IGEgragad
        METHOD NAME:    DPfit

        Abstract:      does a fit on a window
-----
%SC%
        IGEgragad.DPfit(&msg, &fit_flag)
-----
%EN%
        ON ENTRY:

        NAME      DATA TYPE             DESCRIPTION
       ------    -----------            ----------------------------
       *fit_flag  IGRint	         whether a slow fit or a fast fit


-----
%EX%
        ON EXIT:

        NAME    DATA TYPE       DESCRIPTION
       ------  -----------    ----------------------------
        *msg    IGRlong         return status
                                  MSSUCC - successfully completed
                                  MSFAIL - unsuccessfully completed
-----
%MD%
        MODULES AND METHODS INVOKED:

-----
%RL%
        RELATIONS REFERENCED:
-----
%NB%
        NOTES:
-----
%CH%
        CHANGE HISTORY

        HT  05/8/86     : Design date.
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

          This method will calculate the fit range, adjust the view
	  volume accordingly, and the update the screen.
	
----*/
/*EH*/


class implementation IGEgragad;

#include <stdio.h>
#include "grimport.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMindex.h"
#include "OMDB.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "execmsg.h"
#include "dpcodef.h"
#include "dpcomacros.h"

/* prototype files */
#include "DPfitpersp.h"
#include "DPcodpbi.h"
#include "GRdpbfunc.h"
#include "GRlcquery.h"
#include "dpgetrng.h"
#include "dpalignper.h"

#include "madabs.h"
#include "maptsxfor.h"


#ifndef NULL
#define NULL            (0)
#endif
#define BORDER_PERC .03

struct get_rng
{
   OM_p_RTREESTAT  rt_stat;
   IGRint	   *ret;
};

from module import GRmod_passon;

method DPfit (IGRlong *msg; IGRint  fit_flag) 

{


   IGRint       sts;            /* OM return status         */
   IGRdouble    rng[6];         /* window range               */
   IGRdouble    x_rng_delta;
   IGRdouble    y_rng_delta;
   IGRdouble    z_rng_delta;
   IGRdouble    rng_delta;
   IGRdouble    wld_to_view[4][4];
   IGRdouble	ex_mtx[4][4];
   IGRdouble 	new_z;
   IGRdouble 	pnear;
   IGRdouble	pfar;
   enum GRdpmode mode;
   enum GRlocate_types loc_type;
   struct GRlc_upd_loc loc_parms;
   struct GRmd_env     mdenv;
   struct DP_information dp_info;
   IGRint		beg = 0;
   IGRint		fin = 0;
   IGRdouble		new_range[6];
   IGRboolean		upd_flag = FALSE;
   struct  get_rng      rng_arg;
   OM_S_RTREESTAT	rtree_info;
   OM_S_MESSAGE		rng_msg;
   IGRint		ret;
   IGRushort		pflag;
   IGRlong		one = 1;   


   rtree_info.request_type = RTREE_PAGE_STATUS;
   rtree_info.rtree_status.page.level_no = 0;

   rng_arg.rt_stat = &rtree_info;
   rng_arg.ret     = &ret;
   sts = OM_S_SUCCESS; 

#ifndef IDRAW
   if (ME.IGEgragad->gragad.flags & IS_PERSP)
   {
    	DPalignper(msg,DPLEFT_VIEW, ME.IGEgragad->gragad.vpn,
			ME.IGEgragad->gragad.vup, ME.IGEgragad->gragad.eye_pt,
			(IGRdouble *)ex_mtx, (IGRdouble *)wld_to_view);
   }
   else
#endif /* IDRAW */
   {
	OM_BLOCK_MOVE(ME.IGEgragad->gragad.wld_to_view, wld_to_view, (sizeof(IGRdouble) *16));
   }


/*  get range of rtree  */

    sts = om$make_message (classname = "GRrtree",
			   methodname = "get_stat",
			   size = sizeof(struct get_rng),
			   p_arglist = &rng_arg,
			   p_msg = &rng_msg);

    if (!(sts & 1))
    {
#ifdef DEBUG
       printf("Error in DPfit's make message\n");
       om$report_error(sts = sts);
#endif
       goto wrapup;
    }

    gr$get_module_env( 	buffer = (IGRchar *)&mdenv);


    sts = om$send ( msg = message module.GRmod_passon(msg,&rng_msg,
					"module.primary",&beg,&fin),
		    targetid = mdenv.md_id.objid,
		    targetos = mdenv.md_id.osnum);
		
    if (!(sts & 1))
    {
#ifdef DEBUG
       printf("Error in DPfit's send to module\n");
       om$report_error(sts = sts);
#endif
       goto wrapup;
    }

    if (ret == DB_I_EMPTYTREE)
    {
	goto wrapup;
    }
    else 
    {
       if (ret != DB_SUCCESS)
       {
#ifdef DEBUG
	  printf("Error in DPfit's send to the Rtree\n");
#endif
	  *msg = MSFAIL;
	  goto wrapup ;
       }
    }

    ex$message ( msgnumb = GR_I_FitProg);

    if (fit_flag == 1) /*  slow fit  */
    {

      /* call locate          */
      loc_parms.is_ortho = 1;
      loc_type = GR_upd_loc;
      loc_parms.msg = *msg;
      mode = GRbd;
      loc_parms.mode = mode;
      loc_parms.alt_symb = 0;
      dp_info.gragad = &ME.IGEgragad->gragad;
      dp_info.win_no = ME.IGEgadget->win_no;
      dp_info.is_update = TRUE;
      dp_info.is_hidden_line = FALSE;
      dp_info.hline_info = NULL;
      dp_info.hl_tiler = NULL;
      dp_info.is_fit = TRUE;
      dp_info.view_objid = my_id;
      dp_info.view_osnum = OM_Gw_current_OS;

      dp_info.fit_range[0] = IGE_DESIGN_LIMITS_MAX;
      dp_info.fit_range[1] = IGE_DESIGN_LIMITS_MAX;
      dp_info.fit_range[2] = IGE_DESIGN_LIMITS_MAX;
      dp_info.fit_range[3] = IGE_DESIGN_LIMITS_MIN;
      dp_info.fit_range[4] = IGE_DESIGN_LIMITS_MIN;
      dp_info.fit_range[5] = IGE_DESIGN_LIMITS_MIN;

      loc_parms.sp_info = &dp_info;




      loc_parms.upd_range[0] =
	              rtree_info.rtree_status.page.page_range.r3ddkey.xmin;

      loc_parms.upd_range[1] =
	              rtree_info.rtree_status.page.page_range.r3ddkey.ymin;

      loc_parms.upd_range[2] =
	              rtree_info.rtree_status.page.page_range.r3ddkey.zmin;

      loc_parms.upd_range[3] =
	              rtree_info.rtree_status.page.page_range.r3ddkey.xmax;

      loc_parms.upd_range[4] =
	              rtree_info.rtree_status.page.page_range.r3ddkey.ymax;

      loc_parms.upd_range[5] =
	              rtree_info.rtree_status.page.page_range.r3ddkey.zmax;

      if( ! GRlcquery(msg,&mdenv, &loc_type, (IGRchar *) &loc_parms,NULL,NULL,NULL))
      {
	if( *msg != OM_E_NOSUCHCLASS )
	{
        	*msg = MSFAIL;
        	goto wrapup;
	}
      }

      rng[0] = dp_info.fit_range[0];
      rng[1] = dp_info.fit_range[1];
      rng[2] = dp_info.fit_range[2];
      rng[3] = dp_info.fit_range[3];
      rng[4] = dp_info.fit_range[4];
      rng[5] = dp_info.fit_range[5];

   }
   else
   {

/*  fast fit - make range the range of the r-tree  */	



      rng[0] =  rtree_info.rtree_status.page.page_range.r3ddkey.xmin;

      rng[1] =  rtree_info.rtree_status.page.page_range.r3ddkey.ymin;

      rng[2] =  rtree_info.rtree_status.page.page_range.r3ddkey.zmin;

      rng[3] =  rtree_info.rtree_status.page.page_range.r3ddkey.xmax;

      rng[4] =  rtree_info.rtree_status.page.page_range.r3ddkey.ymax;

      rng[5] =  rtree_info.rtree_status.page.page_range.r3ddkey.zmax;
	

   }
  /* adjust view volume to correspond to calculated range  */

    if (rng[0] != IGE_DESIGN_LIMITS_MAX)
    {
       if (!DPgetrng (msg, (IGRdouble *)wld_to_view,
			  &ME.IGEgragad->gragad.vv_range_chk,rng,new_range))
       {
#ifdef DEBUG
	  printf("error in DPfit's DPgetrng call\n");
#endif
	  goto wrapup;
       }
	x_rng_delta = (new_range[3] - new_range[0]);
    	y_rng_delta = (new_range[4] - new_range[1]);
    	z_rng_delta = (new_range[5] - new_range[2]);

	x_rng_delta = MAdabs(msg,&x_rng_delta);
	y_rng_delta = MAdabs(msg,&y_rng_delta);
	z_rng_delta = MAdabs(msg,&z_rng_delta);

	if (ME.IGEgragad->gragad.flags & AXIS_WLD_ALIGN)
	{
	    if (x_rng_delta > y_rng_delta)
    	    {
	    	rng_delta = x_rng_delta;
	    }
	    else
	    {
	    	rng_delta = y_rng_delta;
	    }
    	}	
	else
	{
	    if (x_rng_delta > y_rng_delta)
    	    {
	    	if (x_rng_delta > z_rng_delta)
	    	{
	    	    rng_delta = x_rng_delta;
	    	}
	    	else
	    	{
	    	    rng_delta = z_rng_delta;
	    	}
    	    }
    	    else /* y is greater */
    	    {
	    	if (y_rng_delta > z_rng_delta)
	    	{
	    	    rng_delta = y_rng_delta;
	    	}
	    	else
	    	{
	    	    rng_delta = z_rng_delta;
	    	}
    	    }	
	}

        rng_delta = rng_delta * BORDER_PERC;

	  new_range[0] -= rng_delta;
    	  new_range[3] += rng_delta;

	  ME.IGEgragad->gragad.vw_volume[0] = new_range[0];
	  ME.IGEgragad->gragad.vw_volume[3] = new_range[3];

	  new_range[1] -= rng_delta;
	  new_range[4] += rng_delta;
	
	  ME.IGEgragad->gragad.vw_volume[1] = new_range[1];
	  ME.IGEgragad->gragad.vw_volume[4] = new_range[4];

    	  new_range[2] -= rng_delta;
    	  new_range[5] += rng_delta;
	
	  ME.IGEgragad->gragad.vw_volume[2] = new_range[2];
	  ME.IGEgragad->gragad.vw_volume[5] = new_range[5];


#ifndef IDRAW
     	if (ME.IGEgragad->gragad.flags & IS_PERSP)
	{
	    dp$codpb_get_persp_flags( persp_flags= &pflag );
	    if (pflag & PERSP_CHANGE_ANGLE) 
		ME.IGEgragad->gragad.vw_angle =DEF_VWANGLE;
	    DPfitpersp (msg,0,ME.IGEgragad->gragad.vw_volume,
				&ME.IGEgragad->gragad.act_z,	
				(IGRdouble *)wld_to_view,
				ME.IGEgragad->gragad.coi,
				ME.IGEgragad->gragad.vrp,
				ME.IGEgragad->gragad.vw_angle, 
				ME.IGEgragad->gragad.vrp,
				ME.IGEgragad->gragad.eye_pt,
				ME.IGEgragad->gragad.coi,
				&pnear,&pfar,
				&new_z);
	   ME.IGEgragad->gragad.vw_volume[2] = pnear;
	   ME.IGEgragad->gragad.vw_volume[5] = pfar;

	}
#endif /* IDRAW */

	sts = om$send (msg = message IGEgragad.DPcal(msg),
		      targetid = my_id);

#ifndef IDRAW
     	if (!(ME.IGEgragad->gragad.flags & IS_PERSP))
#endif /* IDRAW */
	{
		ME.IGEgragad->gragad.coi[0] = (ME.IGEgragad->gragad.dit_clip_range[0]+
	  				ME.IGEgragad->gragad.dit_clip_range[3])/2.0;
		ME.IGEgragad->gragad.coi[1] = (ME.IGEgragad->gragad.dit_clip_range[1]+
	  				ME.IGEgragad->gragad.dit_clip_range[4])/2.0;
		ME.IGEgragad->gragad.coi[2] = ME.IGEgragad->gragad.act_z_screen;
		if (!MAptsxform(msg, &one, (IGRdouble *)ME.IGEgragad->gragad.viewport_to_wld,
			ME.IGEgragad->gragad.coi, ME.IGEgragad->gragad.coi))
		{
			goto wrapup;
		}
	}

       if (!(sts & 1))
       {
#ifdef DEBUG
	  printf("error in DPfit on DPcal request\n");
	  om$report_error(sts = sts);
#endif
	  goto wrapup;
       }
    	ex$message ( msgnumb = EX_S_Clear);

	if (!(ME.IGEgragad->gragad.flags & DP_DELAY))
	{
	   sts = om$send (msg = message IGEdisplay.DPupdate(msg,NULL,&upd_flag),
		      targetid = my_id);

	   if (!(sts & 1))
	   {
#ifdef DEBUG
	      printf("error in DPfit on update request\n");
	      om$report_error(sts = sts);
#endif
	   }
	}
	else
	{
	   ex$message( msgnumb = GR_I_DlyOn);	
	}
    } /* end of if (rng[0] != IGE...)  */
    else
    {
    	ex$message ( msgnumb = EX_S_Clear);
    }

wrapup:

   return(sts);
 }

end implementation IGEgragad;
