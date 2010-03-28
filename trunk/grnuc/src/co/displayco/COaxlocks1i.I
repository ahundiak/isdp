
class implementation Root;

#define  ptr_bufrs  ptr_to_buffers -> geometry.polyline

#include <stdio.h>

#include "OMlimits.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "godef.h"
#include "igrdp.h"
#include "griodef.h"
#include "go.h"
#include "ex.h"
#include "grio.h"
#include "dpmacros.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "dp.h"
#include "exmacros.h"
#include "griomacros.h"
#include "codp.h"
#include "codpdef.h"
#include "exdef.h"
#include "igrdef.h"

#include "madef.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "execmsg.h"

%safe 
#include "COaxlocks1i.h"
#include "DPsetinq.h"

#include "madabs.h"
#include "maatan.h"
#include "maptls2di.h"
#include "ma2lnise.h"
#include "maptsxfor.h"
#include "mainvmx.h"
#include "mamulmx.h"
#include "maidmx.h"
%endsafe

IGRint DPprojview_cpl(info, pnt2, mtx, objects, num_objects, buffers,
     		   num_buffers, in_flags1, in_dum2, in_dum3, out_flags1,
		   out_dum2, out_dum3)

struct  DPvwinfo	*info;
struct  EX_button	*pnt2;
	IGRdouble       mtx[16];
struct  GRid	 	**objects;
	IGRint		*num_objects;
struct  DPele_header 	**buffers;
	IGRint		*num_buffers;
	IGRchar		*in_flags1;
	IGRchar		*in_dum2; 
	IGRchar		*in_dum3; 
	IGRint		*out_flags1; 
	IGRchar		*out_dum2; 
struct  DPele_header	**out_dum3;

{

static	IGRdouble      	        wrld_view[4][4];
static	IGRdouble      	        view_wrld[4][4];
static	IGRdouble      	        proj_mat[4][4];
static  IGRdouble		tmp1[3];
static  IGRdouble		tmp2[3];
	IGRlong		  	msg;
	IGRlong		  	num_points= 1;
	IGRshort		i;
	IGRdouble		xdis;
	IGRdouble		ydis;
	IGRdouble		Xdiff;
	IGRdouble		Ydiff;
	IGRdouble		tol;
	IGRdouble   		temp[3];
	IGRdouble		tmp_point1[6];
	IGRdouble		tmp_point2[6];
	IGRdouble		t1[3];
	IGRdouble		t2[3];
        IGRdouble		point11[3];
        IGRdouble		point12[3];
        IGRdouble		point21[3];
        IGRdouble		point22[3];
        IGRdouble		point31[3];
        IGRdouble		point32[3];
 struct IGRline			lin3;
 struct IGRline			Xline;
 struct IGRline			Yline;
 struct IGRline_seg		Xline_seg;
 struct IGRline_seg		Yline_seg;
 struct DPele_header	        *ptr_to_buffers;

  if(info->vw_info.winid == pnt2->objid)
  {
   if(info->g_flags & VALID_ALT_INV)
   {
        tol = 10.;
	lin3.point1 = point31;
	lin3.point2 = point32;
	Xline.point1 = point11;
	Xline.point2 = point12;
	Xline_seg.beg_point = point11;
	Xline_seg.end_point = point12;
	Yline.point1 = point21;
	Yline.point2 = point22;
	Yline_seg.beg_point = point21;
	Yline_seg.end_point = point22;
	if(info->vw_info.flag )  /* Set the transformation matrices */
        {
    		set_for_cpl(pnt2->osnum, pnt2->objid,info,proj_mat);
		info->vw_info.flag = FALSE;
		for(i=0;i<3;i++)
                {
                	tmp1[i]=proj_mat[0][i]*GRDGNLIMITS_MAX_D;
                	tmp2[i]=proj_mat[1][i]*GRDGNLIMITS_MAX_D;
                }
	}
	build_lines(info,proj_mat,point11,point12,point21,point22);
	temp[0] = pnt2 -> x;
	temp[1] = pnt2 -> y;
	temp[2] = pnt2 -> z;

	MAptls2dis(&msg,temp,&Xline_seg,&xdis);
	MAptls2dis(&msg,temp,&Yline_seg,&ydis);

        if(ydis >= xdis)
        {
		for(i=0;i<3;i++)
                {
		   point31[i] = temp[i]-tmp2[i];
		   point32[i] = temp[i]+tmp2[i];
                }
         	if(!(MA2lnisect(&msg, (struct MAline *)&Xline, (struct MAline *)&lin3,
                                &tol,temp,t1,t2)))
                  {
#ifdef DEBUG
                    printf("\n MA2lnisect Xline & line3-- failure in DPprojview_cpl");
#endif
                  }
        }
        else
        {
		for(i=0;i<3;i++)
                {
		   point31[i] = temp[i]-tmp1[i];
		   point32[i] = temp[i]+tmp1[i];
                }
         	if(!(MA2lnisect(&msg,(struct MAline *)&Yline,(struct MAline *)&lin3,
                                &tol,temp,t1,t2)))
                  {
#ifdef DEBUG
                    printf("\n MA2lnisect Yline&line3-- failure in DPprojview_cpl");
#endif
                  }

        }
	info->vw_info.Xproj = temp[0];
	info->vw_info.Yproj = temp[1];
	info->vw_info.Zproj = temp[2];
	pnt2 -> x = temp[0];
	pnt2 -> y = temp[1];
	pnt2 -> z = temp[2];
	ptr_to_buffers = info->vw_info.bufrs_ptr;
	for(i=0;i<3;i++)
        {
	   ptr_bufrs->points[i]= temp[i]-tmp1[i];
	   ptr_bufrs->points[i+3]= temp[i]+tmp1[i];
        }
	ptr_to_buffers ++;
	for(i=0;i<3;i++)
        {
	   ptr_bufrs->points[i]= temp[i]-tmp2[i];
	   ptr_bufrs->points[i+3]= temp[i]+tmp2[i];
        }

	*buffers = info->vw_info.bufrs_ptr;
	*num_buffers = 2;
	*out_flags1 = *out_flags1 | DP_NEW_POINT;
    }
    else
    {
	if(info->vw_info.flag )  /* Set the transformation matrices */
        {
 		set_for_view(pnt2->osnum,pnt2->objid,
				info, wrld_view, view_wrld);
	        info->vw_info.osnum = pnt2->osnum;
		info->vw_info.winid = pnt2->objid;
		info->vw_info.flag = FALSE;
	}
	temp[0] = pnt2 -> x;
	temp[1] = pnt2 -> y;
	temp[2] = pnt2 -> z;
        if(!MAptsxform(&msg, &num_points, (IGRdouble *)wrld_view, temp, temp))
	{
#ifdef DEBUG
	       		if(msg == MSSUCC)
	     	  	     printf("\n successful in MAptsxform");
       	   		else
		  	     printf("\n failure in MAptsxform ");
#endif
	}
	Xdiff = temp[0]-info->vw_info.origin[0];
        Xdiff = MAdabs(&msg,&Xdiff);
	Ydiff = temp[1]-info->vw_info.origin[1];
        Ydiff = MAdabs(&msg,&Ydiff);
	*out_flags1 = *out_flags1 | DP_NEW_POINT;
        if(Xdiff >= Ydiff)
        	temp[1] = info->vw_info.origin[1];
        else
	        temp[0] = info->vw_info.origin[0];
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
        if(!MAptsxform(&msg, &num_points, (IGRdouble *)view_wrld, tmp_point1, 
                       tmp_point1))
        {
#ifdef DEBUG
           if(msg == MSSUCC)
     	        printf("\n successful in MAptsxform");
           else
	        printf("\n failure in MAptsxform ");
#endif
 	}
        if(!MAptsxform(&msg, &num_points, (IGRdouble *)view_wrld, tmp_point2, 
                       tmp_point2))
        {
#ifdef DEBUG
           if(msg == MSSUCC)
     	        printf("\n successful in MAptsxform");
           else
	        printf("\n failure in MAptsxform ");
#endif
 	}
	num_points = 1;
        if(!MAptsxform(&msg, &num_points, (IGRdouble *)view_wrld, temp, temp))
        {
#ifdef DEBUG
           if(msg == MSSUCC)
     	        printf("\n successful in MAptsxform");
           else
	        printf("\n failure in MAptsxform ");
#endif
 	}
	 pnt2 -> x = temp[0];
	 pnt2 -> y = temp[1];
	 pnt2 -> z = temp[2];
	 info->vw_info.Xproj = pnt2->x;
	 info->vw_info.Yproj = pnt2->y;
	 info->vw_info.Zproj = pnt2->z;
	 ptr_to_buffers = info ->vw_info.bufrs_ptr;
	 for(i=0;i<6; i++)
	    ptr_to_buffers -> geometry.polyline->points[i] = tmp_point1[i];

	 ptr_to_buffers ++;
	 for(i=0;i<6; i++)
	    ptr_to_buffers -> geometry.polyline->points[i] = tmp_point2[i];

	 *buffers = info->vw_info.bufrs_ptr;
	 *num_buffers = 2;

   }     /* end of else part of if(info->g_flags & VALID_ALT_INV) */
	 return(MSSUCC);
 }   /* end of if(info->vw_info.winid == pnt2->winid) */
 else
 {
    *num_buffers = 0;
    return(MSSUCC);
 }

}

 project_evntgenpnt(info,pnt2)

struct  DPvwinfo	*info;
struct  EX_button	*pnt2;

{
	IGRdouble      	  	wrld_view[4][4];
	IGRdouble      	  	view_wrld[4][4];
	IGRdouble		proj_mat[4][4];
	IGRdouble   	        temp[3];
	IGRlong		  	msg;
	IGRlong		  	num_points= 1;
	IGRdouble		Xdiff;
	IGRdouble		Ydiff;
	IGRdouble    		tol;
        IGRdouble		point11[3];
        IGRdouble		point12[3];
        IGRdouble		point21[3];
        IGRdouble		point22[3];
        IGRdouble		point31[3];
        IGRdouble		point32[3];
	IGRdouble		t1[3];
	IGRdouble		t2[3];
	IGRdouble		xdis;
	IGRdouble		ydis;
 struct IGRline			lin3;
 struct IGRline			Xline;
 struct IGRline			Yline;
 struct IGRline_seg		Xline_seg;
 struct IGRline_seg		Yline_seg;

        temp[0] = pnt2->x;
        temp[1] = pnt2->y;
        temp[2] = pnt2->z;
	if(info->g_flags & VALID_ALT_INV)
        {
    	   set_for_cpl(pnt2->osnum, pnt2->objid, info,proj_mat);
           tol = 1.5;
	   lin3.point1 = point31;
	   lin3.point2 = point32;
	   Xline.point1 = point11;
	   Xline.point2 = point12;
	   Xline_seg.beg_point = point11;
	   Xline_seg.end_point = point12;
	   Yline.point1 = point21;
	   Yline.point2 = point22;
	   Yline_seg.beg_point = point21;
	   Yline_seg.end_point = point22;
	   build_lines(info,proj_mat,point11,point12,point21,point22);

   	   MAptls2dis(&msg,temp,&Xline_seg,&xdis);
	   MAptls2dis(&msg,temp,&Yline_seg,&ydis);

           if(ydis >= xdis)
           {
        	point31[0] = temp[0]-proj_mat[1][0]*GRDGNLIMITS_MAX_D; 
        	point31[1] = temp[1]-proj_mat[1][1]*GRDGNLIMITS_MAX_D; 
       	        point31[2] = temp[2]-proj_mat[1][2]*GRDGNLIMITS_MAX_D; 
        	point32[0] = temp[0]+proj_mat[1][0]*GRDGNLIMITS_MAX_D; 
        	point32[1] = temp[1]+proj_mat[1][1]*GRDGNLIMITS_MAX_D; 
        	point32[2] = temp[2]+proj_mat[1][2]*GRDGNLIMITS_MAX_D; 
         	if(!(MA2lnisect(&msg,(struct MAline *)&Xline,(struct MAline *)&lin3,
                                &tol,temp,t1,t2)))
                  {
#ifdef DEBUG
                    printf("\n MA2lnisect -- failure in DPprojview_cpl");
#endif
                  }
           }
           else
           {
        	point31[0] = temp[0]-proj_mat[0][0]*GRDGNLIMITS_MAX_D; 
        	point31[1] = temp[1]-proj_mat[0][1]*GRDGNLIMITS_MAX_D; 
       	        point31[2] = temp[2]-proj_mat[0][2]*GRDGNLIMITS_MAX_D; 
        	point32[0] = temp[0]+proj_mat[0][0]*GRDGNLIMITS_MAX_D; 
        	point32[1] = temp[1]+proj_mat[0][1]*GRDGNLIMITS_MAX_D; 
        	point32[2] = temp[2]+proj_mat[0][2]*GRDGNLIMITS_MAX_D; 
         	if(!(MA2lnisect(&msg,(struct MAline *)&Yline,(struct MAline *)&lin3,
                                &tol,temp,t1,t2)))
                  {
#ifdef DEBUG
                    printf("\n MA2lnisect -- failure in DPprojview_cpl");
#endif
                  }

           }
        }     /* end of if (.. & VALID_ALT_INV)   */
	else
        {
 	   set_for_view(pnt2->osnum,pnt2->objid,
				info, wrld_view, view_wrld);
            if(!MAptsxform(&msg, &num_points, (IGRdouble *)wrld_view, temp, 
                           temp))
            {
#ifdef DEBUG
              if(msg == MSSUCC)
     	           printf("\n successful in MAptsxform");
              else
	           printf("\n failure in MAptsxform ");
#endif
 	    }
	    Xdiff = temp[0]-info->vw_info.origin[0];
	    Ydiff = temp[1]-info->vw_info.origin[1];
	    Xdiff = MAdabs(&msg,&Xdiff);
	    Ydiff = MAdabs(&msg,&Ydiff);
            if(Xdiff >= Ydiff)
        	temp[1] = info->vw_info.origin[1];
            else
	        temp[0] = info->vw_info.origin[0];
            if(!MAptsxform(&msg, &num_points, (IGRdouble *)view_wrld, temp, 
                            temp))
            {
#ifdef DEBUG
                 if(msg == MSSUCC)
     	           	printf("\n successful in MAptsxform");
                 else
	           	printf("\n failure in MAptsxform ");
#endif
            }
        }     /* end of else (.. & VALID_ALT_INV)   */
   	pnt2 -> x = temp[0];
   	pnt2 -> y = temp[1];
	pnt2 -> z = temp[2];
	info->vw_info.Xproj = pnt2->x;
	info->vw_info.Yproj = pnt2->y;
	info->vw_info.Zproj = pnt2->z;

   return(1);
}

 set_for_view(os1,win1, info, wrld_view, view_wrld)

	 IGRdouble        wrld_view[4][4];
 	 IGRdouble   	  view_wrld[4][4];
 struct  DPvwinfo    	  *info;
	 IGRint		  os1;
	 OM_S_OBJID	  win1;

{
	IGRdouble         vprt_wrld[4][4];
	IGRlong   	  rc;
	IGRshort	  n = 4;
	IGRlong		  retb1;
	IGRlong		  which_error;
	struct var_list	  list_var[3];
 

           list_var[0].var = VIEWPORT_TO_WLD;
	   list_var[0].var_ptr = (IGRchar *)vprt_wrld;
	   list_var[0].num_bytes = sizeof(IGRdouble)*16;
           list_var[0].bytes_returned = &retb1;

           list_var[1].var = WLD_TO_VIEW;
	   list_var[1].var_ptr = (IGRchar *)wrld_view;
	   list_var[1].num_bytes = sizeof(IGRdouble)*16;
           list_var[1].bytes_returned = &retb1;

           list_var[2].var = END_PARAM;
	   list_var[2].var_ptr = NULL;
	   list_var[2].num_bytes = 0;
           list_var[2].bytes_returned = NULL;

	   rc = dp$inq_set_gragad( msg = &rc,
                              osnum = os1,
			      gragad_objid = win1,
			      which_error = &which_error,
			      var_list = list_var);
        if(!(1&rc))
        {
#ifdef DEBUG
          printf("\nError in dp$inq_set_gragad - from set_transf_matrices \n");
#endif
	  goto fini;
        }
	if(!MAinvmx(&rc,&n,(IGRdouble *)wrld_view,(IGRdouble *)view_wrld))
	{
#ifdef DEBUG
	   printf("\n Error in inverting matrix --- set_transf_matrices");
#endif
	}
  fini :
        return(1);
       
}

 set_for_cpl(os1, win1, info, cnstr_plane)

	 IGRdouble	        cnstr_plane[4][4];
 	 struct  DPvwinfo    	*info;
	 IGRint		  	os1;
	 OM_S_OBJID	  	win1;
    {
	struct var_list	  list_var[4];
	IGRlong   	  rc;
	IGRlong   	  which_error;
	IGRlong   	  retb1;
	IGRdouble	  vprt_wrld[4][4];
	IGRdouble	  wrld_view[4][4];

           list_var[0].var = CONSTRUCT_PLANE;
	   list_var[0].var_ptr = (IGRchar *)cnstr_plane;
	   list_var[0].num_bytes = sizeof(IGRdouble)*16;
           list_var[0].bytes_returned = &retb1;

           list_var[1].var = VIEWPORT_TO_WLD;
	   list_var[1].var_ptr = (IGRchar *)vprt_wrld;
	   list_var[1].num_bytes = sizeof(IGRdouble)*16;
           list_var[1].bytes_returned = &retb1;

           list_var[2].var = WLD_TO_VIEW;
	   list_var[2].var_ptr = (IGRchar *)wrld_view;
	   list_var[2].num_bytes = sizeof(IGRdouble)*16;
           list_var[2].bytes_returned = &retb1;

           list_var[3].var = END_PARAM;
	   list_var[3].var_ptr = NULL;
	   list_var[3].num_bytes = 0;
           list_var[3].bytes_returned = NULL;

	   rc = dp$inq_set_gragad( msg = &rc,
                              osnum = os1,
			      gragad_objid = win1,
			      which_error = &which_error,
			      var_list = list_var);
        if(!(1&rc))
        {
#ifdef DEBUG
          printf("\nError in dp$inq_set_gragad - from set_for_cpl \n");
#endif
	  goto fini;
        }
	cnstr_plane[0][3] = 0;
	cnstr_plane[1][3] = 0;
	cnstr_plane[2][3] = 0;
    fini:
	return(1);
   }

inq_gflags(os1, win1, g_flags)

	IGRint		  os1;
	OM_S_OBJID	  win1;
	IGRint		  *g_flags;

{
	struct var_list	  list_var[2];
	IGRlong   	  rc;
	IGRlong   	  which_error;
	IGRlong   	  retb1;

           list_var[0].var = GRAGAD_FLAGS;
	   list_var[0].var_ptr = (IGRchar *)g_flags;
	   list_var[0].num_bytes = sizeof(IGRint);
           list_var[0].bytes_returned = &retb1;

           list_var[1].var = END_PARAM;
	   list_var[1].var_ptr = NULL;
	   list_var[1].num_bytes = 0;
           list_var[1].bytes_returned = NULL;

	   rc = dp$inq_set_gragad( msg = &rc,
                              osnum = os1,
			      gragad_objid = win1,
			      which_error = &which_error,
			      var_list = list_var);
        if(!(1&rc))
        {
#ifdef DEBUG
          printf("\nError in dp$inq_set_gragad - from inq_gflags \n");
#endif
	  goto fini;
        }
        fini :
	    return(1);
}

build_lines(info,proj_mat,point11,point12,point21,point22)

struct  DPvwinfo                  *info;
        IGRdouble                 proj_mat[4][4];
	IGRdouble		  *point11;
	IGRdouble		  *point12;
	IGRdouble		  *point21;
	IGRdouble		  *point22;

 {


       *point11     = info->vw_info.origin[0]-proj_mat[0][0]*GRDGNLIMITS_MAX_D; 
       *(++point11) = info->vw_info.origin[1]-proj_mat[0][1]*GRDGNLIMITS_MAX_D; 
       *(++point11) = info->vw_info.origin[2]-proj_mat[0][2]*GRDGNLIMITS_MAX_D; 
       *point12     = info->vw_info.origin[0]+proj_mat[0][0]*GRDGNLIMITS_MAX_D; 
       *(++point12) = info->vw_info.origin[1]+proj_mat[0][1]*GRDGNLIMITS_MAX_D; 
       *(++point12) = info->vw_info.origin[2]+proj_mat[0][2]*GRDGNLIMITS_MAX_D; 

       *point21     = info->vw_info.origin[0]-proj_mat[1][0]*GRDGNLIMITS_MAX_D; 
       *(++point21) = info->vw_info.origin[1]-proj_mat[1][1]*GRDGNLIMITS_MAX_D; 
       *(++point21) = info->vw_info.origin[2]-proj_mat[1][2]*GRDGNLIMITS_MAX_D; 
       *point22     = info->vw_info.origin[0]+proj_mat[1][0]*GRDGNLIMITS_MAX_D; 
       *(++point22) = info->vw_info.origin[1]+proj_mat[1][1]*GRDGNLIMITS_MAX_D; 
       *(++point22) = info->vw_info.origin[2]+proj_mat[1][2]*GRDGNLIMITS_MAX_D; 

	return(1);
  }


IGRint DPdbprojn(info, pnt2, mtx, objects, num_objects, buffers,
     		   num_buffers, in_flags1, in_dum2, in_dum3, out_flags1,
		   out_dum2, out_dum3)

struct  DPprojs_info	*info;
struct  EX_button	*pnt2;
	IGRdouble       mtx[16];
struct  GRid	 	**objects;
	IGRint		*num_objects;
struct  DPele_header 	**buffers;
	IGRint		*num_buffers;
	IGRchar		*in_flags1;
	IGRchar		*in_dum2; 
	IGRchar		*in_dum3; 
	IGRint		*out_flags1; 
	IGRchar		*out_dum2; 
struct  DPele_header	**out_dum3;

{
	IGRdouble   		  temp[3];
	IGRlong		  	  msg;
	IGRdouble		  temp_diff[3];
	IGRdouble		  amax;
	IGRshort		  axis1;
	IGRshort 		  i;
struct  DPele_header	          *ptr_to_buffers;


         if(info->flag  || info->winid != pnt2->objid)
	 {
         	info->winid = pnt2->objid;
		info->osnum = pnt2->osnum;
		info->flag = FALSE;
	 }
	temp[0] = pnt2 -> x;
	temp[1] = pnt2 -> y;
	temp[2] = pnt2 -> z;
        for(i=0; i<3; i++)
	{
		temp_diff[i]= temp[i]-info->origin[i];
        	temp_diff[i] = MAdabs(&msg,&temp_diff[i]);
        }
	amax = temp_diff[0];
	axis1 = 0;
	for(i=0; i<3; i++)
	{
   		if(temp_diff[i] > amax)
		{
	    		amax = temp_diff[i];
	    		axis1 = i;
		}
	}
	for(i=0; i<3; i++)
	{
		if(i != axis1)
	   		temp[i] = info->origin[i];
	}
	*out_flags1 = *out_flags1 | DP_NEW_POINT;
	pnt2 -> x = temp[0];
	pnt2 -> y = temp[1];
	pnt2 -> z = temp[2];
	info-> Xproj = pnt2->x;
	info-> Yproj = pnt2->y;
	info-> Zproj = pnt2->z;
	ptr_to_buffers = info -> bufrs_ptr;
	ptr_to_buffers -> geometry.polyline->points[0] = GRDGNLIMITS_MIN_D;
	ptr_to_buffers -> geometry.polyline->points[1] = pnt2->y;
	ptr_to_buffers -> geometry.polyline->points[2] = pnt2->z;
	ptr_to_buffers -> geometry.polyline->points[3] = GRDGNLIMITS_MAX_D;
	ptr_to_buffers -> geometry.polyline->points[4] = pnt2->y;
	ptr_to_buffers -> geometry.polyline->points[5] = pnt2->z;

	ptr_to_buffers ++;
	ptr_to_buffers -> geometry.polyline->points[0] = pnt2->x;
	ptr_to_buffers -> geometry.polyline->points[1] = GRDGNLIMITS_MIN_D;
	ptr_to_buffers -> geometry.polyline->points[2] = pnt2->z;
	ptr_to_buffers -> geometry.polyline->points[3] = pnt2->x;
	ptr_to_buffers -> geometry.polyline->points[4] = GRDGNLIMITS_MAX_D;
	ptr_to_buffers -> geometry.polyline->points[5] = pnt2->z;

	ptr_to_buffers ++;
	ptr_to_buffers -> geometry.polyline->points[0] = pnt2->x;
	ptr_to_buffers -> geometry.polyline->points[1] = pnt2->y;
	ptr_to_buffers -> geometry.polyline->points[2] = GRDGNLIMITS_MIN_D;
	ptr_to_buffers -> geometry.polyline->points[3] = pnt2->x;
	ptr_to_buffers -> geometry.polyline->points[4] = pnt2->y;
	ptr_to_buffers -> geometry.polyline->points[5] = GRDGNLIMITS_MAX_D;

	*buffers = info->bufrs_ptr;
	*num_buffers = 3;
	return(MSSUCC);
 
}

 project_evntpnt(info,pnt2)

struct  DPprojs_info	*info;
struct  EX_button	*pnt2;

{
	IGRdouble   	        temp[3];
	IGRlong       		msg;
	IGRdouble		temp_diff[3];
	IGRdouble		amax;
	IGRshort		axis1;
	IGRshort		i;

	temp[0] = pnt2 -> x;
	temp[1] = pnt2 -> y;
	temp[2] = pnt2 -> z;
        for(i=0; i<3; i++)
	{
		temp_diff[i]= temp[i]-info->origin[i];
        	temp_diff[i] = MAdabs(&msg,&temp_diff[i]);
        }
	amax = temp_diff[0];
	axis1 = 0;
	for(i=0; i<3; i++)
	{
	   if(temp_diff[i] > amax)
	   {
		amax = temp_diff[i];
		axis1 = i;
	   }
	}
	for(i=0; i<3; i++)
	{
	    if(i != axis1)
   		temp[i] = info->origin[i];
	}
	 pnt2 -> x = temp[0];
	 pnt2 -> y = temp[1];
	 pnt2 -> z = temp[2];
	 info-> Xproj = pnt2->x;
	 info-> Yproj = pnt2->y;
	 info-> Zproj = pnt2->z;
  
  return(1);

}
end implementation Root;
