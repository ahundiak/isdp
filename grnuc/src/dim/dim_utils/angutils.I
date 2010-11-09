class implementation DMroot;

#define AS_DEBUG 1

#include "bsvalues.h"

#include "dimangular.h"
#include "bsxln.h"
#include "bsproj1.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bsdistptpt.h"
#include "bscrossp.h"

#argsused
IGRint DMselect_sector (msg,
                        line1,
			line2,
			selpt,
			plan_info,
			trak_dist,
                        sector)
	 IGRint  *msg;
	 IGRdouble line1[2][3];
	 IGRdouble line2[2][3];
	 IGRdouble  *selpt;
	 struct DMplan_info  *plan_info;
	 IGRdouble  *trak_dist;
	 int  *sector;
 /*
IGRint *msg;
IGRdouble line1[2][3];
IGRdouble line2[2][3];
IGRdouble *selpt;
struct DMplan_info *plan_info;
double *trak_dist;
int *sector;
 */
/*.DMselect_sector*/
{
	IGRdouble sector_vec[3];
	IGRdouble vector1[3],vector2[3];
	IGRint status ,rc;
	IGRdouble norm_pl[3],pt_on_plane[3];
	IGRdouble interpt[3];
	IGRvector cross_vec1, cross_vec2;
	IGRdouble vec_dotp;
	IGRdouble select_pt[3];
	IGRint orig_dir, meas_dir;
	IGRdouble sec_start[3], sec_end[3];
	IGRint i, flag;
	BSrc bs_rc;

	for (i=0; i<3; i++)
	{
		norm_pl[i] = plan_info->win_plan.matrix[8 +i];
		pt_on_plane[i] = plan_info->win_plan.matrix[4*i+3];
	}

	/*| project allpoints on dim plane*/

	DMproject_points(
		&rc,
		line1[0],
		line1[1],
		line2[0],
		line2[1],
		norm_pl,
		pt_on_plane);

	status = BSproj1(&bs_rc,selpt,norm_pl,pt_on_plane,select_pt);
	dm$status( action = RET_STATUS);

	bs_rc = BSSUCC;
	status=BSxln( &bs_rc,line1[0],line1[1],
		      line2[0],line2[1],interpt);
	if (bs_rc == BSCOINCIDENT)
	{
		IGRdouble dist1, dist2, mdist1, mdist2;

		/*- The lines are coincident find the
		    common point (or closest pt) and
		    return it as origin
		*/

		dist1 = BSdistptpt(&bs_rc, line1[0], line2[0]);
		dist2 = BSdistptpt(&bs_rc, line1[0], line2[1]);

		if (dist1 > dist2)
			mdist1 = dist2;
		else	mdist1 = dist1;

		dist1 = BSdistptpt(&bs_rc, line1[1], line2[0]);
		dist2 = BSdistptpt(&bs_rc, line1[1], line2[1]);

		if (dist1 > dist2)
			mdist2 = dist2;
		else	mdist2 = dist1;

		if (mdist1 > mdist2)
		{
		   vec_equal( line1[1],interpt);
		}
		else
		{
		   vec_equal( line1[0],interpt);
		}
	}
	else if( bs_rc != BSSUCC)
	{
		printf("Intersection error\n");
		return(OM_E_ABORT);
	}
	dm$status(action=RET_STATUS);
	/*"intersecton pt:%lf|%lf|%lf\n",interpt[0],interpt[1],interpt[2]*/
	
	for( i = 0; i<3; i++)
	{
		sector_vec[i] = select_pt[i] - interpt[i];
		vector1[i]  = line1[1][i] - line1[0][i];
		vector2[i]  = line2[1][i] - line2[0][i];
	}

	*trak_dist = BSlenvec(&bs_rc, sector_vec);
	BSnorvec(&bs_rc, vector1);
	BSnorvec(&bs_rc, vector2);

	/*"sector_vec:%lf|%lf|%lf\n",sector_vec[0],sector_vec[1],sector_vec[2]*/

   	BScrossp (&bs_rc, vector1, sector_vec, cross_vec1); if (bs_rc != BSSUCC) return (FALSE);
   	BScrossp (&bs_rc, sector_vec, vector2, cross_vec2); if (bs_rc != BSSUCC) return (FALSE);
   	BSnorvec (&bs_rc, cross_vec1)                   ; if (bs_rc != BSSUCC) return (FALSE);
   	BSnorvec (&bs_rc, cross_vec2)                   ; if (bs_rc != BSSUCC) return (FALSE);

   	vec_dotp= BSdotp(&bs_rc, cross_vec1, cross_vec2)     ; if (bs_rc != BSSUCC) return (FALSE);
   	for(i=0; i<3; i++)
		 cross_vec1[i]= vector1[i]+ vec_dotp*vector2[i];
   
   	BSnorvec (&bs_rc, cross_vec1)                   ; if (bs_rc != BSSUCC) return (FALSE);

   	vec_dotp = BSdotp (&bs_rc, cross_vec1,sector_vec)     ; if (bs_rc != BSSUCC) return (FALSE) ;

	if( vec_dotp < 0.0)
	{
		vec_neg(cross_vec1,sector_vec);
	}
	else
	{
		vec_equal(cross_vec1,sector_vec);
	}

	/* initilialize the sector*/
	*sector = 0;
	BSnorvec(&bs_rc,vector1);
	BSnorvec(&bs_rc,vector2);
	/*"bisect_vec:%lf|%lf|%lf\n",sector_vec[0],sector_vec[1],sector_vec[2]*/
	/*"vector1:%lf|%lf|%lf\n",vector1[0],vector1[1],vector1[2]*/
	/*"vector2:%lf|%lf|%lf\n",vector2[0],vector2[1],vector2[2]*/
		
	orig_dir =(BSdotp( &bs_rc,sector_vec,vector1) < 0);
	meas_dir =(BSdotp(&bs_rc,sector_vec,vector2)  < 0);

	BSnorvec(&bs_rc,vector1);
	BSnorvec(&bs_rc,vector2);
	/*"orig_dir:%ld\tmeas_dir:%ld\n",orig_dir,meas_dir*/
	if(orig_dir){
		*sector|=ORIG_START;
		for( i = 0; i<3;i++)
			sec_start[i] =interpt[i] - vector1[i];
	}
	else
	{
		for( i = 0; i<3;i++)
			sec_start[i] = interpt[i] + vector1[i];		
	}

	if(meas_dir){
		*sector|=MEAS_START;
		for( i = 0; i<3;i++)
			sec_end[i] =interpt[i] - vector2[i];
	}
	else
	{
		for( i = 0; i<3;i++)
			sec_end[i] =interpt[i] + vector2[i];		
	}


	/*"sec_start:%lf|%lf|%lf\n",sec_start[0],sec_start[1],sec_start[2]*/
	/*"sec_end:%lf|%lf|%lf\n",sec_end[0],sec_end[1],sec_end[2]*/
	/*"interpt:%lf|%lf|%lf\n",interpt[0],interpt[1],interpt[2]*/
	/*"norm_pl:%lf|%lf|%lf\n",norm_pl[0],norm_pl[1],norm_pl[2]*/
	flag = 0;
	status= MATH_get_dir_vec(&rc,interpt,sec_start,sec_end,norm_pl,&flag);

	if(flag == CLOCK_DIR)
		*sector|=CLOCK_WISE;
	/*"direction:%d\n",flag*/

	*msg = MSSUCC;
	return(TRUE);
}

IGRint DMang_compute_proj_line (src_line,
				term_pt,
				proj_line,
				proj_extn,
				proj_offs)
				/*(
	 struct DMdim_root  *src_line,
	 IGRdouble  term_pt[3],
	 IGRdouble  proj_line[6],
	 IGRdouble  proj_extn,
	 IGRdouble  proj_offs
	)
 */
struct DMdim_root *src_line;
IGRdouble term_pt[3],proj_line[6];
IGRdouble proj_extn,proj_offs;
/*.DMang_compute_proj_line*/
{
	IGRdouble d1, d2, v[3], *pt;
	IGRint i;
	BSrc bs_rc;

	d1 = BSdistptpts(&bs_rc,src_line->point1,term_pt);
	d2 = BSdistptpts(&bs_rc,src_line->point2,term_pt);
	pt = (d1 < d2)?src_line->point1:src_line->point2;

	BSmkvec(&bs_rc, v, pt, term_pt);
	BSnorvec(&bs_rc, v);
	for (i=0; i<3; i++)
	{
		proj_line[i] = term_pt[i] + proj_extn * v[i];
		proj_line[i+3] = pt[i] + proj_offs * v[i];
	}

	return(TRUE);
}

DMget_ang_txt_info (plan_info,
		    p_loc,
		    txt_vec_orie,
		    norm_vec,
		    txt_just,
		    breakpt,
		    centerpt,
		    leader,
		    lead_dist)
		    /*(
	 struct DMplan_info  *plan_info,
	 struct DMloc_param  *p_loc,
	 double  *txt_vec_orie,
	 double  *norm_vec,
	 IGRshort  *txt_just,
	 double  *breakpt,
	 double  *centerpt,
	 int  leader,
	 double  lead_dist
	)
	*/
struct DMplan_info *plan_info;
struct DMloc_param *p_loc;
IGRdouble lead_dist;
int leader;
IGRdouble *txt_vec_orie,*breakpt,*centerpt,*norm_vec;
IGRshort *txt_just;
/*.DMget_ang_txt_info*/
{
	double angle;
	BSrc bs_rc;
	double radius_vector[3];

	if(leader)
	{
		/*|leader exits*/
		switch(p_loc->txt_orie)
		{
		case TXT_ORIE_HORIZONTAL:
			vec_equal(plan_info->win_plan.vec_xpos,txt_vec_orie);
			break;

		case TXT_ORIE_VERTICAL:
			vec_equal(plan_info->win_plan.vec_ypos,txt_vec_orie);
			break;

		case TXT_ORIE_PERPENDICULAR:
			vec_sub(breakpt,centerpt,txt_vec_orie);
			BSnorvec(&bs_rc,txt_vec_orie);

			MATH_ang_bet_lines(
				plan_info->win_plan.vec_xpos,
				txt_vec_orie,
				&angle,
				&plan_info->win_plan.matrix[8]);

			angle = (angle * 180.0)/M_PI;

			if( angle > 90.0 && angle < 270.0)
			{
				vec_neg(txt_vec_orie,txt_vec_orie);
			}
			break;
		}
		if(p_loc->txt_posn == TXT_POSN_EMBEDDED)
			*txt_just = (lead_dist < 0 ? RIGHT_CENTER:LEFT_CENTER);
		else
			*txt_just = (lead_dist < 0 ? LEFT_BASE:RIGHT_BASE);
	}
	else{

		switch(p_loc->txt_orie)
		{
		case TXT_ORIE_HORIZONTAL:
			vec_equal(plan_info->win_plan.vec_xpos,txt_vec_orie);
			*txt_just = CENTER_CENTER;
			break;
		case TXT_ORIE_VERTICAL:
			vec_equal(plan_info->win_plan.vec_ypos,txt_vec_orie);
			*txt_just = CENTER_CENTER;
			break;
		case TXT_ORIE_PERPENDICULAR:

			vec_sub(breakpt,centerpt,radius_vector);
			BSnorvec(&bs_rc,radius_vector);
			vec_equal(radius_vector,txt_vec_orie);

			MATH_ang_bet_lines(
				plan_info->win_plan.vec_xpos,
				radius_vector,
				&angle,
				&plan_info->win_plan.matrix[8]);

			angle = (angle * 180.0)/M_PI;

			if(p_loc->txt_posn == TXT_POSN_ABOVE)
				*txt_just = LEFT_CENTER;
			else
				*txt_just = CENTER_CENTER;

			if( angle > 90.0 && angle < 270.0)
			{
				vec_neg(txt_vec_orie,txt_vec_orie);
				if( p_loc->txt_posn == TXT_POSN_ABOVE)
					*txt_just = RIGHT_CENTER;
			}
			break;
		case TXT_ORIE_PARALLEL:
			vec_sub(breakpt,centerpt,radius_vector);
			vec_cross(radius_vector,norm_vec,txt_vec_orie);
			BSnorvec(&bs_rc,txt_vec_orie);

			MATH_ang_bet_lines(
				plan_info->win_plan.vec_xpos,
				radius_vector,
				&angle,
				&plan_info->win_plan.matrix[8]);

			angle = (angle * 180.0)/M_PI;

			if( angle > 180.0)
				vec_neg(txt_vec_orie,txt_vec_orie);

			if(p_loc->txt_posn == TXT_POSN_ABOVE)
				*txt_just = CENTER_BOTTOM;
			else
				*txt_just = CENTER_CENTER;
			break;
		}
	}
	return(TRUE);
}

#argsused
DMget_txt_length (text_grid,
                  min_length,
		  max_length,
		  md_env,
		  plan_info)
		  /*(
	 struct GRid  text_grid,
	 double  *min_length,
	 double  *max_length,
	 struct GRmd_env  *md_env,
	 struct DMplan_info  *plan_info
	)
	*/
struct GRid text_grid;
IGRdouble *min_length, *max_length;
struct GRmd_env *md_env;
struct DMplan_info *plan_info;
{
	struct ret_struct text_struct;
	double len1,len2;
	
	as$any_give_structure(go_grid = text_grid,
			      mod_env = md_env,
			      inst = &text_struct);
		      
	len1 = text_struct.var.lb_st.diag_pt2[0] - 
		text_struct.var.lb_st.diag_pt1[0];
	len2 = text_struct.var.lb_st.diag_pt2[1] - 
		text_struct.var.lb_st.diag_pt1[1];

	if(len1 > len2)
	{
		*max_length = len1;
		*min_length = len2;
	}
	else
	{
		*max_length = len2;
		*min_length = len1;
	}

	return(TRUE);
}

int DMget_inter_point (cenpt,endpt,intpt,loc_pt)
	 IGRdouble  *cenpt;
	 IGRdouble  *endpt;
	 IGRdouble  *intpt;
	 IGRdouble  *loc_pt;
/*DMget_inter_point*/
{
	int i;
	double dotp[2];
	double vec1[3],vec2[3];

	vec_sub( endpt,cenpt,vec1);

	for( i = 0; i< 2; i++)
	{
		vec2[3*i]   = intpt[3*i]   - cenpt[0];
		vec2[3*i+1] = intpt[3*i+1] - cenpt[1];
		vec2[3*i+2] = intpt[3*i+2] - cenpt[2];

		dotp[i] = vec_dot(vec1,vec2);
	}

	if(dotp[0] > dotp[1])
	{
		for( i = 0; i< 3; i++)
			loc_pt[i] = intpt[i];
	}
	else
	{
		for( i = 0; i< 3 ; i++)
			loc_pt[i] = intpt[3 + i];
	}
	return(TRUE);
}

int DMget_pt_at_angle (pt1,pt2,arc_r,plane,endpt,ext_len,type)
	 IGRdouble  *pt1;
	 IGRdouble  *pt2;
	 IGRdouble  arc_r;
	 IGRdouble  plane[16];
	 IGRdouble  *endpt;
	 IGRdouble  ext_len;
	 int  type;
/*.DMget_pt_at_angle*/
{
	int rc;
	double angle, output_vec[3],dir_vec[3];

	vec_sub( pt2,pt1,dir_vec);
	angle = ext_len/arc_r;

	if( type == CLOCK_DIR) angle = -angle;

	MATH_rotate_vector(&rc,dir_vec,angle,plane,output_vec);

	/*^
		printf("arc_r = %f, ext_len = %f, angle = %f\n",
			arc_r, ext_len, angle);
		print_point("dir_vec", dir_vec);
		print_point("output_vec", output_vec);
	*/

	vec_add(pt1,output_vec,endpt);

	/*^ print_point("endpt", endpt); */

	return(TRUE);
}

end implementation DMroot;

