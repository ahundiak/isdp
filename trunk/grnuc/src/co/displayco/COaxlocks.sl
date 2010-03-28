/* #######################    APOGEE COMPILED   ######################## */
/* Command definition section */

options		"t"
product_name	"$GRNUC"	
class		COaxlocks	/* Command Object Class	*/
super_class	CEO_LOCATE 	/* super class of the Command Object */
start_state 		terminate

specification

#include  "codp.h"

instance
{
    struct  DPvwinfo    	info;
    struct  DPprojs_info    	info1;

    IGRdouble                   pnts[12];
    struct IGRline              boreline;
    IGRpoint                    brlnpt1;
    IGRpoint                    brlnpt2;
} 

/* implementation section - code for .I (implementation files) */

implementation

#include <string.h>
#include <stdio.h>
#include "OMprimitives.h"
#include "dpstruct.h"
#include "dp.h"
#include "exmacros.h"
#include "codp.h"
#include "igrdef.h"
#include "OMmacros.h"
#include "maerr.h"
#include "codpdef.h"
#include "dpdef.h"
#include "grmessage.h"
#include "dpmacros.h"
#include "griodef.h"
#include "griomacros.h"
#include "execmsg.h"

%safe
/* structure needed for dp3Ddatapt.h prototypes */
struct pt3d
{
   struct DPele_header elem[2];
   IGRchar first_pnt;
   struct IGRline *line1;
};

#include "COaxlocks1i.h"
#include "GRicvtalfn.h"
#include "dp3Ddatapt.h"
#include "dpbrlnconst.h"
#include "dpdynamics.h"
#include "dpdisplay.h"
#include "dpexbell.h"
#include "numstr.h"

#include "maptsxfor.h"
#include "mabrlncon.h"
#include "ma2lnpro.h"

/* remove when prototypes are included */
/*
extern IGRint DPprojview_cpl ();
extern IGRint DPdbprojn ();
*/
%endsafe

from IGEgragad import DPinrot;

action  dspl_buffrs1
{

#define ptr_bufrs  ptr_to_buffers -> geometry.polyline

          IGRlong       msg;
          IGRlong       num_points = 1;
          IGRint        in_flags;
          IGRshort      i;
 struct   DPele_header  elem[2];
 struct   IGRpolyline   line1;
 struct   IGRpolyline   line2;
 struct   IGRdisplay    dis_att;
          IGRdouble     points1[6];
          IGRdouble     points2[6];
          IGRdouble     temp[3];
          IGRdouble     tmp_point1[6];
          IGRdouble     tmp_point2[6];
          IGRdouble     wrld_view[4][4];
          IGRdouble     view_wrld[4][4];
          IGRdouble     proj_mat[4][4];
 struct   DPele_header  *ptr_to_buffers;
 enum     GRdpmode      display_mode;
   
	      /* Obtain the Origin of the Coordinate system */
	*sts = OM_S_SUCCESS;

  	temp[0] = me->event1.event.button.x;
  	temp[1] = me->event1.event.button.y;
  	temp[2] = me->event1.event.button.z;
        inq_gflags(me->event1.event.button.osnum, 
		me->event1.event.button.objid,&me->info.g_flags); 
        if(me->info.g_flags & VALID_ALT_INV)
        {
 	    set_for_cpl(me->event1.event.button.osnum, 
	     me->event1.event.button.objid,&me->info, proj_mat);
        }
        else
        {
 	    set_for_view(me->event1.event.button.osnum, 
	     me->event1.event.button.objid,&me->info,
			wrld_view,view_wrld);
            if(!MAptsxform(&msg, &num_points, (IGRdouble *)wrld_view,temp,temp))
            {
#ifdef DEBUG
       		 if(msg == MSSUCC)
       			 printf("\n successful in MAptsxform");
       		 else
        		 printf("\n failure in MAptsxform ");
#endif
		 me->ret = FunFail;
		 goto quit;
	    }
	}
        for(i=0;i<3;i++)
        {
	    me->info.vw_info.origin[i] = temp[i];
        }
	me->info.vw_info.winid = me->event1.event.button.objid;
	me->info.vw_info.osnum = me->event1.event.button.osnum;
       	line1.num_points = 2;
	line1.points = points1;
	line2.points = points2;
       	line2.num_points = 2;
       	dis_att.color = 2;
       	dis_att.weight = 0;
	dis_att.style = 0;
	dp$build_dis_buffer(buffer = &elem[0],
			type = IGRPY,
			display_att = &dis_att,
			geometry = &line1);
	dp$build_dis_buffer(buffer = &elem[1],
			type = IGRPY,
			display_att = &dis_att,
			geometry = &line2);
	me->info.vw_info.bufrs_ptr = elem;
        if(me->info.g_flags & VALID_ALT_INV)
  	{
        	tmp_point1[0]=temp[0]-proj_mat[0][0]*GRDGNLIMITS_MAX_D;
       		tmp_point1[1]=temp[1]-proj_mat[0][1]*GRDGNLIMITS_MAX_D;
       		tmp_point1[2]=temp[2]-proj_mat[0][2]*GRDGNLIMITS_MAX_D;
       		tmp_point1[3]=temp[0]+proj_mat[0][0]*GRDGNLIMITS_MAX_D;
       		tmp_point1[4]=temp[1]+proj_mat[0][1]*GRDGNLIMITS_MAX_D;
       		tmp_point1[5]=temp[2]+proj_mat[0][2]*GRDGNLIMITS_MAX_D;

       	    	tmp_point2[0]=temp[0]-proj_mat[1][0]*GRDGNLIMITS_MAX_D;
       		tmp_point2[1]=temp[1]-proj_mat[1][1]*GRDGNLIMITS_MAX_D;
       		tmp_point2[2]=temp[2]-proj_mat[1][2]*GRDGNLIMITS_MAX_D;
       		tmp_point2[3]=temp[0]+proj_mat[1][0]*GRDGNLIMITS_MAX_D;
       		tmp_point2[4]=temp[1]+proj_mat[1][1]*GRDGNLIMITS_MAX_D;
       		tmp_point2[5]=temp[2]+proj_mat[1][2]*GRDGNLIMITS_MAX_D;
		num_points = 2;
	}
	else
	{
       		tmp_point1[0]=GRDGNLIMITS_MIN_D;
       		tmp_point1[1]=temp[1];
       		tmp_point1[2]=temp[2];
       		tmp_point1[3]=GRDGNLIMITS_MAX_D;
       		tmp_point1[4]=temp[1];
       		tmp_point1[5]=temp[2];

       		tmp_point2[0]=temp[0];
       		tmp_point2[1]=GRDGNLIMITS_MIN_D;
       		tmp_point2[2]=temp[2];
       		tmp_point2[3]=temp[0];
       		tmp_point2[4]=GRDGNLIMITS_MAX_D;
       		tmp_point2[5]=temp[2];
		num_points = 2;
       	        if(!MAptsxform(&msg, &num_points, (IGRdouble *)view_wrld, 
					tmp_point1, tmp_point1))
       	        {
#ifdef DEBUG
       		     if(msg == MSSUCC)
       			   printf("\n successful in MAptsxform");
       		     else
        		   printf("\n failure in MAptsxform ");
#endif
		 me->ret = FunFail;
		 goto quit;
	        }
       	        if(!MAptsxform(&msg, &num_points, (IGRdouble *)view_wrld, 
				tmp_point2, tmp_point2))
        	{
#ifdef DEBUG
           	     if(msg == MSSUCC)
     	                   printf("\n successful in MAptsxform");
           	     else
	                   printf("\n failure in MAptsxform ");
#endif
		 me->ret = FunFail;
		 goto quit;
 		}
	}/* eof else of  if(me->info.g_flags & VALID_ALT_INV) */

	num_points = 1;
 	ptr_to_buffers = me->info.vw_info.bufrs_ptr;
 	ptr_to_buffers -> geometry.polyline->points=tmp_point1; 
 	ptr_to_buffers ++;
 	ptr_to_buffers -> geometry.polyline->points=tmp_point2; 
        display_mode = GRhd;
   	msg = dp$display(msg = &msg,
		    	osnum = me->event1.event.button.osnum, 
		    	objid = me->event1.event.button.objid, 
		        num_elem = 2,
		    	mode = display_mode,
   	buffer = me->info.vw_info.bufrs_ptr);
       	if(!(msg&1))
      	{
#ifdef DEBUG
	       	printf("\n Error in dp$display in action dspl_buffrs1");
#endif
		goto quit;
       	}

             /* Initialize the buffers inquire & set dynamics flags */

	me->info.vw_info.flag = TRUE;
       	line1.num_points = 2;
	line1.points = points1;
	line2.points = points2;
       	line2.num_points = 2;
        dis_att.color = 2;
       	dis_att.weight = 0;
	dis_att.style = 0;
	dp$build_dis_buffer(buffer = &elem[0],
			type = IGRPY,
			display_att = &dis_att,
			geometry = &line1);
	dp$build_dis_buffer(buffer = &elem[1],
			type = IGRPY,
			display_att = &dis_att,
			geometry = &line2);
	me->info.vw_info.bufrs_ptr = elem;
/*	in_flags = DP_AUTO_DYN | DP_USE_WIN_FLAG | DP_ALL_WINDOWS;  */
	in_flags = DP_AUTO_DYN | DP_USE_WIN_FLAG ;
	ex$message(msgnumb=GR_P_EntPtProj);
       	dp$dynamics(dyn_fun =      DPprojview_cpl,
		    information =  (char *)&me->info,
		    flags =        &in_flags);
}

action project_point1
{
	IGRlong			eventsize;
        IGRint	 		rc;
	IGRlong 		msg;

		    /* Insert the point projected in the event queue */

       *sts = OM_S_SUCCESS;

       eventsize = sizeof(struct GRevent);

       if(me->event1.event.button.objid != me->info.vw_info.winid)
       {
           ex$message(msgnumb=GR_E_PtoutWin);
	   sleep(2);
           ex$message(msgnumb=EX_S_Clear);
	   ex$message(msgnumb=GR_P_EntPtProj);
       }
       else
       {  
	  if(me->event1.subtype != GRst_REGULAR)
          {
 		project_evntgenpnt(&me->info,&me->event1.event.button);
          }
   	  me->event1.event.button.x = me->info.vw_info.Xproj;
   	  me->event1.event.button.y = me->info.vw_info.Yproj;
	  me->event1.event.button.z = me->info.vw_info.Zproj;
  	  rc = ex$putque(msg = &msg,
	                 response = &(me->event1.response),
		         byte = &eventsize,
		         buffer = (IGRchar *)&(me->event1.event.button));
          if(!(1&rc))
	  {
#ifdef DEBUG
	 	printf("\nError in inserting the event -- ex$putque  \n");
#endif
	  }
       } /*  eof else if event1.event.button.objid!=info.vw_info.winid */
}

action dspl_buffrs

{
          IGRlong		msg;
          IGRint		in_flags;
struct    DPele_header		elem[3];
struct    IGRpolyline		line1;
struct    IGRpolyline		line2;
struct    IGRpolyline		line3;
struct    IGRdisplay		dis_att;
          IGRdouble 		points1[6];
          IGRdouble 		points2[6];
          IGRdouble 		points3[6];
struct    DPele_header		*ptr_to_buffers;
enum 	  GRdpmode		display_mode;
   

       /* Obtain the Origin of the Coordinate system */
    *sts = OM_S_SUCCESS;
    me->info1.origin[0] = me->event1.event.button.x ;
    me->info1.origin[1] = me->event1.event.button.y ;
    me->info1.origin[2] = me->event1.event.button.z ;
    me->info1.winid = me->event1.event.button.objid;
    me->info1.osnum = me->event1.event.button.osnum; 
    line1.num_points = 2;
    line1.points = points1;
    line2.points = points2;
    line2.num_points = 2;
    line3.points = points3;
    line3.num_points = 2;
    dis_att.color = 2;
    dis_att.weight = 0;
    dis_att.style = 0;
    dp$build_dis_buffer(buffer = &elem[0],
				type = IGRPY,
				display_att = &dis_att,
				geometry = &line1);
    dp$build_dis_buffer(buffer = &elem[1],
				type = IGRPY,
				display_att = &dis_att,
				geometry = &line2);
    dp$build_dis_buffer(buffer = &elem[2],
				type = IGRPY,
				display_att = &dis_att,
				geometry = &line3);
    me->info1.bufrs_ptr = elem;
    ptr_to_buffers = me->info1.bufrs_ptr;
    ptr_to_buffers -> geometry.polyline->points[0] = GRDGNLIMITS_MIN_D;
    ptr_to_buffers -> geometry.polyline->points[1] = me->event1.event.button.y;
    ptr_to_buffers -> geometry.polyline->points[2] = me->event1.event.button.z;
    ptr_to_buffers -> geometry.polyline->points[3] = GRDGNLIMITS_MAX_D;
    ptr_to_buffers -> geometry.polyline->points[4] = me->event1.event.button.y;
    ptr_to_buffers -> geometry.polyline->points[5] = me->event1.event.button.z;

    ptr_to_buffers ++;
    ptr_to_buffers -> geometry.polyline->points[0] = me->event1.event.button.x;
    ptr_to_buffers -> geometry.polyline->points[1] = GRDGNLIMITS_MIN_D;
    ptr_to_buffers -> geometry.polyline->points[2] = me->event1.event.button.z;
    ptr_to_buffers -> geometry.polyline->points[3] = me->event1.event.button.x;
    ptr_to_buffers -> geometry.polyline->points[4] = GRDGNLIMITS_MAX_D;
    ptr_to_buffers -> geometry.polyline->points[5] = me->event1.event.button.z;

    ptr_to_buffers ++;
    ptr_to_buffers -> geometry.polyline->points[0] = me->event1.event.button.x;
    ptr_to_buffers -> geometry.polyline->points[1] = me->event1.event.button.y;
    ptr_to_buffers -> geometry.polyline->points[2] = GRDGNLIMITS_MIN_D;
    ptr_to_buffers -> geometry.polyline->points[3] = me->event1.event.button.x;
    ptr_to_buffers -> geometry.polyline->points[4] = me->event1.event.button.y;
    ptr_to_buffers -> geometry.polyline->points[5] = GRDGNLIMITS_MAX_D;
    display_mode = GRhd;
    msg = dp$display(msg = &msg,
		    	osnum = me->event1.event.button.osnum,
		    	objid = me->event1.event.button.objid,
		        num_elem = 3,
		    	mode = display_mode,
		    	buffer = me->info1.bufrs_ptr);
    if(!(msg&1))
    {
#ifdef DEBUG
 	   printf("\n Error: .. call to dp$display in action dspl_buffrs");
#endif
    }
    me->info1.flag = TRUE;
    in_flags = 0;
    line1.num_points = 2;
    line1.points = points1;
    line2.points = points2;
    line2.num_points = 2;
    line3.points = points3;
    line3.num_points = 2;
    dis_att.color = 2;
    dis_att.weight = 0;
    dis_att.style = 0;
    dp$build_dis_buffer(buffer = &elem[0],
			type = IGRPY,
			display_att = &dis_att,
			geometry = &line1);
    dp$build_dis_buffer(buffer = &elem[1],
			type = IGRPY,
			display_att = &dis_att,
			geometry = &line2);
    dp$build_dis_buffer(buffer = &elem[2],
			type = IGRPY,
			display_att = &dis_att,
			geometry = &line3);
    me->info1.bufrs_ptr = elem;
    ex$message(msgnumb = GR_P_EntPtProj);
    in_flags = DP_AUTO_DYN | DP_USE_WIN_FLAG | DP_ALL_WINDOWS ;
    dp$dynamics(dyn_fun =      DPdbprojn,
		information =  (char *)&me->info1,
		flags =        &in_flags);
}

action project_point

{
	IGRlong		eventsize;
	IGRint	 	rc;
	IGRlong 	msg;
        
	  /* Insert the projected point into event queue */
  *sts = OM_S_SUCCESS;
  if(me->event1.subtype != GRst_REGULAR)
  {
          /* Data point is from event generator .. project it   */

      project_evntpnt(&me->info1,&me->event1.event.button);
  }
  me->event1.event.button.x = me->info1.Xproj;
  me->event1.event.button.y = me->info1.Yproj;
  me->event1.event.button.z = me->info1.Zproj;
  eventsize = sizeof(struct GRevent);
  rc = ex$putque(msg = &msg,
           response = &(me->event1.response),
           byte = &eventsize,
           buffer = (IGRchar *)&(me->event1.event.button));
  if(!(1&rc))
  {
#ifdef DEBUG
 	printf("\nError in inserting the event -- ex$putque  \n");
#endif
  }
}

action get_pt11
{
	*sts = OM_S_SUCCESS;
	ex$message(msgnumb=GR_P_EntPt1);
    	DP3Ddatapt (me->pnts,1,NULL);
}

action get_pt22
{
	*sts = OM_S_SUCCESS;
	ex$message(msgnumb=GR_P_EntPt2);
	DP3Ddatapt (me->pnts,0,&me->boreline);
}

action get_pt1
{
    struct IGRline boreline;
    IGRpoint brlnpt1;
    IGRpoint brlnpt2;
    IGRpoint pnt_boreln;
    IGRmatrix mtx;
    IGRlong  msg;


*sts = OM_S_SUCCESS;
me->boreline.point1 = me->brlnpt1;
me->boreline.point2 = me->brlnpt2;

boreline.point1 = brlnpt1;
boreline.point2 = brlnpt2;

		pnt_boreln[0] = me->event1.event.button.x;
		pnt_boreln[1] = me->event1.event.button.y;
		pnt_boreln[2] = me->event1.event.button.z;
		
		status = om$send( msg = message IGEgragad.DPinrot(&msg,mtx),
                                   senderid = my_id,
                                   targetid = me->event1.event.button.objid,
                                   targetos = me->event1.event.button.osnum);
                if ( !(status & 1))
                {
#ifdef DEBUG
		    printf("ERROR in inquire");
		    om$report_error(sts = status);
#endif
		    *sts = status;
		    goto quit;
		}
	        if (! DPbrlnconstr(&msg,pnt_boreln,
			me->event1.event.button.objid,
			me->event1.event.button.osnum,&boreline))
	        {
#ifdef DEBUG
		     printf("Error in CO3D at DPbrlnconstr");
#endif
		     *sts = FunFail;
		     goto quit;
  	   	}
	    	me->pnts[0] = brlnpt1[0];
	   	me->pnts[1] = brlnpt1[1];
	  	me->pnts[2] = brlnpt1[2];
	    	me->pnts[3] = brlnpt2[0];
	   	me->pnts[4] = brlnpt2[1];
	  	me->pnts[5] = brlnpt2[2];

	    	if (! MAbrlnconstr(&msg,pnt_boreln,mtx,&me->boreline))
	    	{
#ifdef DEBUG
	    	    printf("Error in MAbrlnconstr");
#endif
		     *sts = FunFail;
		     goto quit;
	    	}	

 }  /* end of action get_pt1   */ 

action get_pt2
{
    IGRlong           msg;
    struct EX_button  button;
    IGRlong           size_event;
    struct IGRline    boreline;
    IGRdouble	      t1;
    IGRdouble	      t2;
    IGRpoint          brlnpt1;
    IGRpoint          brlnpt2;
    IGRpoint          pnt_boreln;
    IGRpoint          proj_pnt1;
    IGRpoint          proj_pnt2;
    IGRmatrix         mtx;
    IGRshort          num_alias;
    IGRshort          field_size = sizeof(IGRchar) *  DP_MAX_ALIAS_SIZE;
    IGRchar           cvt_list[3][52];
    IGRchar           *cvt_list_ptr[3];
    IGRint            new_strlen[3];


*sts = OM_S_SUCCESS;

boreline.point1 = brlnpt1;
boreline.point2 = brlnpt2;


		pnt_boreln[0] = me->event1.event.button.x;
		pnt_boreln[1] = me->event1.event.button.y;
		pnt_boreln[2] = me->event1.event.button.z;
		
		status = om$send(msg=message IGEgragad.DPinrot(&msg,mtx),
                                   senderid = my_id,
                                   targetid = me->event1.event.button.objid,
                                   targetos = me->event1.event.button.osnum);
                if ( !(status & 1))
                {
#ifdef DEBUG
		    printf("ERROR in inquire");
		    om$report_error(sts = status);
#endif
		    *sts = status;
		    goto quit;
		}
	    	if (! MAbrlnconstr(&msg,pnt_boreln,mtx,&boreline))
	    	{
#ifdef DEBUG
	    	    printf("Error in MAbrlnconstr");
#endif
		    *sts = FunFail;
		    goto quit;
	    	}	
	    	if (!MA2lnproj(&msg,&me->boreline,&boreline,proj_pnt1,proj_pnt2,&t1,&t2))
	    	{
#ifdef DEBUG
	    	    printf("Error in CO3D at MA2lnproj");
#endif
		    *sts = FunFail;
		    goto quit;
	    	}		
		if (!(msg == MAINFSOLUTION))
		{
		      num_alias = 1;
			cvt_list_ptr[0] = (IGRchar *)cvt_list;
			cvt_list_ptr[1] = &cvt_list[1][0];
			cvt_list_ptr[2] = &cvt_list[2][0];
		      status = co$cvt_imp_to_alias (msg = &msg,
			     	osnum = me->event1.event.button.osnum,
			     	unit_type = GRIO_DISTANCE, 
			     	working_units = proj_pnt1,
			     	num_alias = &num_alias, 
			        inverse_scale_flag=GRIO_NO_SCALE,
			     	num_conversions = 3,
				field_size = &field_size,
			     	cvt_list = cvt_list_ptr);
			if (!(status & 1)) 
                          {
		    		*sts = status;
		    		goto quit;
                          }
			numstr(&msg,cvt_list_ptr,cvt_list_ptr,DP_MAX_ALIAS_SIZE,
				2,new_strlen);

			if ((new_strlen[0] + new_strlen[1] + strlen(cvt_list_ptr[2]) + 3) > 42)
			{
		   	    ex$message ( msgnumb = GR_I_XEq, type ="%s", 
	     		                     var = `cvt_list_ptr[0]`, 
			           justification = LEFT_JUS);
			   sleep(1);
			   ex$message ( msgnumb = GR_I_YEq, type ="%s", 
			                    var = `cvt_list_ptr[1]`, 
			          justification = LEFT_JUS);
			   sleep(1);
			   ex$message ( msgnumb = GR_I_ZEq, type ="%s", 
			                    var = `cvt_list_ptr[2]`, 
			          justification = LEFT_JUS);

			}
			else
			{

				ex$message ( msgnumb = GR_I_Pt , 
						type = "%s%s%s", 
						 var = `cvt_list_ptr[0],cvt_list_ptr[1],cvt_list_ptr[2]`, 
				       justification = LEFT_JUS);
			}
		    	sleep(2);

			button = me->event1.event.button;

			button.x = proj_pnt1[0];
			button.y = proj_pnt1[1];
			button.z = proj_pnt1[2];

		    	size_event = sizeof(struct EX_button);	
		    	if (! ex$putque(msg=&msg,response=&me->event1.response,
					byte = &size_event,
					buffer= (IGRchar *)&button))
		        {
#ifdef DEBUG
			    printf("ERROR in putque");
#endif
			    *sts = FunFail;
			    goto quit;
		    	}		
		}
		else
		{
		    ex$message ( msgnumb = GR_E_InvInp);
		    EX_bell();
		    sleep(3);
		}
}   /* end of action get_pt2  */
