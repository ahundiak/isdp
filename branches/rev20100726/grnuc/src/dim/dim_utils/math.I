class implementation DMroot;

#define AS_DEBUG 1

%safe
#include "math.h"
%endsafe


#include "bsvalues.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "dimannot.h"
#include "mascalvc.h"
#include "maaddvc.h"
#include "bsxlnsph.h"
#include "bsproj1.h"
#include "bsperpa.h"
#include "bsnorvec.h"
#include "bsmkvec.h"
#include "bslininter.h"
#include "bslenvec.h"
#include "bsdotp.h"
#include "bsdistptpts.h"
#include "bscveval.h"
#include "bscrossp.h"

  
extern  IGRboolean BSproj0();

	IGRint MATH_ptdelta (rc,
			     point,
			     vector,
			     distance,
			     deltapt)
			     /*(
	 IGRint  *rc,
	 IGRdouble  point[3],
	 IGRdouble  vector[3],
	 IGRdouble  distance,
	 IGRdouble  deltapt[3]
	)
	*/
	IGRint *rc;
	IGRdouble point[3];
	IGRdouble vector[3];
	IGRdouble distance;
	IGRdouble deltapt[3];
	/*.MATH_ptdelta*/
	{
		int i;

		/*****************************************

			- Description -

		This routine computes a point "deltapt"
		at a "distance" from the given "point"
		in the given direction - indicated by
		a unit "vector".

		*****************************************/

		*rc = BSSUCC;
		for (i=0; i<3; i++)
		{
			deltapt[i] = point[i] + vector[i] * distance;
		}

		return(TRUE);
	}

	IGRint MATH_proj_along_vector (rc,
				       point,
				       vector,
				       line,
				       projection)
				       /*(
	 IGRint  *rc,
	 IGRdouble  point[3],
	 IGRdouble  vector[3],
	 IGRdouble  line[6],
	 IGRdouble  projection[3]
	)
	*/
	IGRint *rc;
	IGRdouble point[3];
	IGRdouble vector[3];
	IGRdouble line[6];
	IGRdouble projection[3];
	/*.MATH_proj_along_vector*/
	{
		long long_rc;
		IGRdouble endpt[3];
		struct IGRline line_1, line_2, *igrline[2];
		IGRdouble pts[6];
		IGRdouble dist;

		/*****************************************

			- Description -

		This routine computes the "projection" of a
		"point" along a given "vector" on to a given
		"line"

		*****************************************/

		MAaddvc(&long_rc, point, vector, endpt);

		line_1.point1 = &line[0];
		line_1.point2 = &line[3];

		line_2.point1 = point;
		line_2.point2 = endpt;

		igrline[0] = &line_1;
		igrline[1] = &line_2;

		BSint2lns(igrline, pts, &dist, rc);

		projection[0] = pts[0];
		projection[1] = pts[1];
		projection[2] = pts[2];

		return(TRUE);
	}

	IGRint MATH_rotate_vector (rc,
				   vector,
				   angle,
				   plane,
				   rotvec)
				   /*(
	 IGRint  *rc,
	 IGRdouble  vector[3],
	 IGRdouble  angle,
	 IGRdouble  plane[16],
	 IGRdouble  rotvec[3]
	)
	*/
	IGRint *rc;
	IGRdouble vector[3];
	IGRdouble angle;
	IGRdouble plane[16];
	IGRdouble rotvec[3];
	/*.MATH_rotate_vector*/
	{
		IGRdouble local[3], xvec[3], yvec[3];
		IGRdouble rotlocal[3];
		IGRdouble cs, ss;
		IGRint index;
		BSrc bs_rc;

		/*****************************************

			- Description -

		This routine rotates a "vector" by a given
		"angle" about an axis normal to the given
		"plane".

		*****************************************/

		/* - Convert to local coordinates - */

		for (index=0; index<3; index++)
		{
			xvec[index] = plane[index];
			yvec[index] = plane[index + 4];
		}

		BSnorvec(&bs_rc, xvec);
		BSnorvec(&bs_rc, yvec);

		local[0] = xvec[0] * vector[0] +
			   xvec[1] * vector[1] +
			   xvec[2] * vector[2];

		local[1] = yvec[0] * vector[0] +
			   yvec[1] * vector[1] +
			   yvec[2] * vector[2];

		/* - 2D rotation - */

		cs = cos(angle);
		ss = sin(angle);

		rotlocal[0] = local[0] * cs - local[1] * ss;
		rotlocal[1] = local[0] * ss + local[1] * cs;
		rotlocal[2] = 0.0;		

		/* - Convert back to world coordinates - */

		rotvec[0] = xvec[0] * rotlocal[0] +
			    yvec[0] * rotlocal[1];

		rotvec[1] = xvec[1] * rotlocal[0] +
			    yvec[1] * rotlocal[1];

		rotvec[2] = xvec[2] * rotlocal[0] +
			    yvec[2] * rotlocal[1];

		*rc = OM_S_SUCCESS;	
		return(TRUE);
	}

	IGRint MATH_get_box_points (msg,
				    lbsys,
				    box)
				    /*(
	 int  *msg,
	 struct IGRlbsys  *lbsys,
	 double  box[4][3]
	)
	*/
	int *msg;
	struct IGRlbsys *lbsys;
	double box[4][3];
	/*.MATH_get_box_points*/
	{
		double o, xmin, ymin, xmax, ymax;
		double *to_wld;
		int i,j,index;

		xmin = lbsys->diag_pt1[0];
		ymin = lbsys->diag_pt1[1];

		xmax = lbsys->diag_pt2[0];
		ymax = lbsys->diag_pt2[1];

		/*^
			printf("xmin=%lf, ymin=%lf\n", xmin, ymin);
			printf("xmax=%lf, ymax=%lf\n", xmax, ymax);
		*/

		to_wld = lbsys->matrix;

		for (index=0; index<3; index++)
		{
			i = 4*index;
			j = i+1;
			o = to_wld[i+3];

			box[0][index] = to_wld[i]*xmin + to_wld[j]*ymin + o;
			box[1][index] = to_wld[i]*xmax + to_wld[j]*ymin + o;
			box[2][index] = to_wld[i]*xmax + to_wld[j]*ymax + o;
			box[3][index] = to_wld[i]*xmin + to_wld[j]*ymax + o;
		}

		/*^
			print_point("box[0]", box[0]);
			print_point("box[1]", box[1]);
			print_point("box[2]", box[2]);
			print_point("box[3]", box[3]);
		*/

		*msg = OM_S_SUCCESS;
		return(TRUE);
	}

	IGRint MATH_intersect_box_line (msg,
					line,
					box,
					intpt,
					intersect,
					plane)
					/*(
	 IGRint  *msg,
	 IGRdouble  line[2][3],
	 IGRdouble  box[4][3],
	 IGRdouble  intpt[2][3],
	 IGRboolean  *intersect,
	 IGRdouble  plane[16]
	)
	*/
	IGRint *msg;
	IGRdouble line[2][3];
	IGRdouble box[4][3];
	IGRdouble intpt[2][3];
	IGRboolean *intersect;
	IGRdouble plane[16];
	/*.MATH_intersect_box_line*/
	{
		/*****************************************

			- Description -

		This routine intersects a bounded "line"
		defined by end points with a box defined
		by four vertices. Two intersection points
		("intpt") are returned, closest to the
		corresponding end points of the line.
		The boolean "intersect" would indicate
		whether or not intersection exists.
		The matrix defines the plane of intersection.

		ALGORITHM:

		Intersect each edge of the box with the
		given line, find if the intersection is
		on the edge and on the line, if so, save
		this as an intersection point. As many as
		four valid intersections are possible.
		From these compute the ones closest to
		each of the end points.

		To find the intersection of two bounded
		lines in 2D the following routine is used:

		BSxlnln2d(line1, line2, num,
			  int_pts, par1, par2, rc)

		*****************************************/

		IGRint rc;
		BSrc bs_rc;
		IGRdouble line2d[2][2];
		IGRdouble box2d[5][2];
		IGRdouble int_pts[8][2];
		IGRdouble par1[8], par2[8];
		IGRint num, count, index;
		IGRdouble u_par[2];
		IGRint u_ind[2];
		IGRdouble pt_on_plane[3];
		IGRvector norm_to_plane;
		IGRdouble p0[3], p1[3];
		IGRvector xvec, yvec;

		/*| Initialise intersection params */

		*intersect = 0;

		for (index=0; index<3; index++)
		{
			pt_on_plane[index] = plane[4*index + 3];
			norm_to_plane[index] = plane[index + 8];
			xvec[index] = plane[index];
			yvec[index] = plane[index + 4];
		}

		BSnorvec(&bs_rc, xvec);
		BSnorvec(&bs_rc, yvec);
		BSnorvec(&bs_rc, norm_to_plane);

		/*| Convert to local coordinates of dimension plane */

		for (index=0; index<2; index++)
		{
			line2d[index][0] =
				xvec[0] * line[index][0] +
				xvec[1] * line[index][1] +
				xvec[2] * line[index][2];

			line2d[index][1] =
				yvec[0] * line[index][0] +
				yvec[1] * line[index][1] +
				yvec[2] * line[index][2];
		}

		for (index=0; index<4; index++)
		{
			box2d[index][0] =
				xvec[0] * box[index][0] +
				xvec[1] * box[index][1] +
				xvec[2] * box[index][2];

			box2d[index][1] =
				yvec[0] * box[index][0] +
				yvec[1] * box[index][1] +
				yvec[2] * box[index][2];
		}

		/*^
			printf("line2d[0]=%lf, %lf\n",
				line2d[0][0],line2d[0][1]);
			printf("line2d[1]=%lf, %lf\n",
				line2d[1][0],line2d[1][1]);

			for (index=0; index<4; index++)
			{
				printf("box2d[%d]=%lf,%lf\n", index,
					box2d[index][0], box2d[index][1]);
			}
		*/

		/*| Make the array circular */

		box2d[4][0] = box2d[0][0];
		box2d[4][1] = box2d[0][1];

		/*| Compute intersections - BSxlnln2d */

		count = 0;
		for (index=0; index<4; index++)
		{
			/*"index=%d, count=%d\n", index, count*/

			BSxlnln2d(
				line2d,
				box2d[index],
				&num,
				int_pts[count],
				&par1[count],
				&par2[count],
				&rc);

			/*"num=%d\n", num*/

			count += num;
		}

		/*"num_inter=%d\n", count*/

		if (!count)
			return(TRUE);

		u_par[0] = 1.0;		/* Min value */
		u_par[1] = 0.0;		/* Max value */
		u_ind[0] = u_ind[1] = 0;

		for (index=0; index<count; index++)
		{
			if (par1[index] < u_par[0])
			{
				u_par[0] = par1[index];
				u_ind[0] = index;
			}
			
			if (par1[index] > u_par[1])
			{
				u_par[1] = par1[index];
				u_ind[1] = index;
			}
		}

		/*| Convert back to world coordinates */

		for (index=0; index<3; index++)
		{
			p0[index] =
				xvec[index] * int_pts[u_ind[0]][0] +
				yvec[index] * int_pts[u_ind[0]][1];

			p1[index] =
				xvec[index] * int_pts[u_ind[1]][0] +
				yvec[index] * int_pts[u_ind[1]][1];
		}

		BSproj1(&bs_rc,
			p0,
			norm_to_plane,
			pt_on_plane,
			intpt[0]);

		BSproj1(&bs_rc,
			p1,
			norm_to_plane,
			pt_on_plane,
			intpt[1]);

		/*^
			print_point("p0", p0);
			print_point("p1", p1);
			print_point("intpt0", intpt[0]);
			print_point("intpt1", intpt[1]);
		*/

		*intersect = 1;

		*msg = OM_S_SUCCESS;
		return(TRUE);
	}

	IGRint MATH_compute_plan_info (msg,
				       meas_axis,
				       win,
				       act)
				       /*(
	 int  *msg,
	 double  meas_axis[3],
	 double  win[16],
	 double  act[16]
	)
	*/
	int *msg;
	double meas_axis[3];
	double win[16];
	double act[16];
	/*.MATH_compute_plan_info*/
	{
		/*****************************************

			- Description -

		Computes the act plane orientation,
		given the end points of the measurement
		axis and the win plane orientation. 

		*****************************************/

		BSrc bs_rc;
		double sn, cs, scale;
		double x_axis[3], y_axis[3];
		double z_axis[3], origin[3];
		double xvec[3], yvec[3];
		int index;

		for (index=0; index<3; index++)
		{
			xvec[index] = win[index];
			yvec[index] = win[index + 4];
			z_axis[index] = win[index + 8];
			origin[index] = win[4*index + 3];
		}

		BSnorvec(&bs_rc, xvec);
		BSnorvec(&bs_rc, yvec);

		cs =	meas_axis[0] * xvec[0] +
			meas_axis[1] * xvec[1] +
			meas_axis[2] * xvec[2];

		sn =	meas_axis[0] * yvec[0] +
			meas_axis[1] * yvec[1] +
			meas_axis[2] * yvec[2];

		/*"cosA = %lf, sinA = %lf\n", cs, sn*/

		for (index=0; index<3; index++)
			x_axis[index] = win[index] * cs + win[index + 4] * sn;
		BScrossp(&bs_rc, z_axis, x_axis, y_axis);

		/*^
			print_point("x_axis", x_axis);
			print_point("y_axis", y_axis);
			print_point("z_axis", z_axis);
		*/

		BSnorvec(&bs_rc, y_axis);
		scale = BSlenvec(&bs_rc, x_axis);
                MAscalvc(&bs_rc, &scale, y_axis, y_axis);

		/*^
			printf("scale = %f", scale);
			print_point("y_axis", y_axis);
		*/

		if (fabs(cs) > 1e-5)
		{
			/*| Closer to window x_axis */

			if (cs < 0)
			{
				math_v_opposite(x_axis, x_axis);
				math_v_opposite(y_axis, y_axis);
			}
		}
		else
		{
			/*| Closer to window y_axis */

			if (sn < 0)
			{
				math_v_opposite(x_axis, x_axis);
				math_v_opposite(y_axis, y_axis);
			}
		}

		act[0] = x_axis[0];
		act[1] = x_axis[1];
		act[2] = x_axis[2];

		act[4] = y_axis[0];
		act[5] = y_axis[1];
		act[6] = y_axis[2];

		act[8] = z_axis[0];
		act[9] = z_axis[1];
		act[10]= z_axis[2];

		act[3] = origin[0];
		act[7] = origin[1];
		act[11]= origin[2];

		act[12] =
		act[13] =
		act[14] = 0.0;
		act[15] = 1.0;

		/*^
			printf("sn=%lf, cs=%lf\n", sn, cs);
			print_matrix("window_matrix", win);
			print_matrix("actual_matrix", act);
		*/

		*msg = OM_S_SUCCESS;
		return(TRUE);
	}

	IGRint MATH_line_break (msg,
				term_pt,
				break_pt,
				plane,
				box,
				endpt)
				/*(
	 int  *msg,
	 double  term_pt[3],
	 double  break_pt[3],
	 double  plane[16],
	 double  box[4][3],
	 double  endpt[3]
	)
	*/
	int *msg;
	double term_pt[3];
	double break_pt[3];
	double plane[16];
	double box[4][3];
	double endpt[3];
	/*.MATH_line_break*/
	{
                IGRint status;
		double dimline[6];
		IGRboolean intersect;
		double intpt[2][3], dval;
		int rc, index;

		for (index=0; index<3; index++)
		{
			dval = 1000.0 * (break_pt[index] - term_pt[index]);
			dimline[index] = term_pt[index];
			dimline[index + 3] = term_pt[index] + dval;
		}


		status = MATH_intersect_box_line(
			&rc,
			(IGRdouble (*)[])dimline,
			box,
			intpt,
			&intersect,
			plane);
		if (!intersect)
		{
			math_v_equal(endpt, break_pt);
		}
		else
		{
			math_v_equal(endpt, intpt[0]);
		}

		*msg = OM_S_SUCCESS;
		return(TRUE);
	}

	IGRint MATH_line_extend (msg,
				 term_pt,
				 break_pt,
				 box,
				 extpt)
				 /*(
	 int  *msg,
	 double  term_pt[3],
	 double  break_pt[3],
	 double  box[4][3],
	 double  extpt[3]
	)
	*/
	int *msg;
	double term_pt[3];
	double break_pt[3];
	double box[4][3];
	double extpt[3];
	/*.MATH_line_extend*/
	{
	        BSrc bs_rc;
		double dimline[6], vec[3];
		double projvec[3];
		double dist, tdist, projpt[3];
		int ptindx, i;

		DMlineptpt(term_pt, break_pt, dimline);
		BSmkvec(&bs_rc, vec, term_pt, break_pt);

		ptindx = -1;
		dist = 0.0;
		math_v_equal(extpt, break_pt);

		for (i=0; i<4; i++)
		{
			BSproj0(&bs_rc,
				box[i],
				dimline,
				projpt);

			BSmkvec(&bs_rc, projvec, term_pt, projpt);

			if (BSdotp(&bs_rc, vec, projvec) < 0) continue;

			tdist = BSlenvec(&bs_rc, projvec);
			if (tdist > dist)
			{
				dist = tdist;
				math_v_equal(extpt, projpt);
			}
		}

		*msg = OM_S_SUCCESS;
		return(TRUE);
	}

#argsused        
	IGRint MATH_get_box_pt_upar (msg,
				     flag,
				     upar,
				     point,
				     text_grid,
				     md_env)
				     /*(

	 int  *msg,
	 short  flag,
	 double  *upar,
	 double  point[3],
	 struct GRid  text_grid,
	 struct GRmd_env  *md_env
	)
	*/
	int *msg;
	short flag;
	double *upar;
	double point[3];
	struct GRid text_grid;
	struct GRmd_env *md_env;
	/*.MATH_get_box_pt_upar*/
	{
		int rc, num_pts, status, side,i;
		BSrc bs_rc;
		long long_rc;
		short num_par;
		double pts[15], nvec[3],points[4][3];
		struct IGRlbsys *lbs_geom;
		IGRshort matrix_type;
		IGRmatrix matrix;
		IGRdouble poles[15], knots[7], weights[5];
		struct IGRbsp_curve bsp_curve;

		status =
		om$send(msg = message NDnode.ASreturn_go(
						&text_grid,
						&matrix_type,
						matrix),
			senderid = NULL_OBJID,
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);

		status =
		om$send(msg = message GRvg.GRgenabsg(
					&long_rc,
					&matrix_type,
					matrix,
					(char **)&lbs_geom),
			senderid = NULL_OBJID,
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);

		MATH_get_box_points(&rc, lbs_geom, points);

                for(i=0; i<4; i++)
		{  
		    pts[3*i]   = points[i][0];
		    pts[3*i+1] = points[i][1];
		    pts[3*i+2] = points[i][2];
                }

		pts[12] = pts[0];
		pts[13] = pts[1];
		pts[14] = pts[2];

		bsp_curve.poles = poles;
		bsp_curve.knots = knots;
		bsp_curve.weights = weights;

		num_pts = 5;

		status =
		BSlininter(&bs_rc, &num_pts, pts, &bsp_curve, nvec);
		if( !status || bs_rc != BSSUCC)
		{
			/*"BSlininter fails: rc=%d, status=%d\n", rc, status*/
			return(OM_E_ABORT);
		}


		if(flag)
		{
			status =
			BSperpa(&bs_rc,
				&bsp_curve,
				point,
				point,
				&num_par,
				upar,
				&side);
			if( !status || bs_rc != BSSUCC)
			{
				/*"BSperpa fails: rc=%d, status=%d\n", rc, status*/
				return(OM_E_ABORT);
			}
		}
		else
		{
			BScveval(&bsp_curve, *upar, 0, (IGRpoint *)point, &bs_rc);
		}

		*msg = OM_S_SUCCESS;
		return(TRUE);
	}

	double MATH_fix_dbl (d)
	 double  d;
 /*
	double d;
 */
	{
		double x;
		int i;

		x = d + 0.00005;
		i = (int)(x * 10000.0);
		return( ((double)i) / 10000.0 );
	}

IGRint MATH_ang_bet_lines (vec1,
		    vec2,
		    angle,
		    norm)
		    /*
	 double  *vec1,
	 double  *vec2,
	 double  *angle,
	 double  *norm
	)
	*/
double *vec1,*vec2,*norm;
double *angle;
/*.MATH_ang_bet_lines*/
{
	BSrc bs_rc;
	double cost,sint, dotp;
	double perp_vec[3];

	BScrossp(&bs_rc,vec1,vec2,perp_vec);

	sint = BSlenvec(&bs_rc,perp_vec);
	cost = BSdotp(&bs_rc,vec1,vec2);
	*angle = atan2(sint,cost);
	
	dotp = BSdotp(&bs_rc,norm,perp_vec);
	if( dotp < 0)
	{
		if( *angle < 0) *angle = - *angle;
		else  *angle = 2* M_PI - *angle;
	}
	else if( *angle < 0 )  *angle = 2 * M_PI + *angle;
	
	return(TRUE);
}

IGRint MATH_get_dir_vec (rc,
		  centerpt,
		  startpt,
		  endpt,
		  norm_vec,
		  flag)
		  /* (
	 int  *rc,
	 double  *centerpt,
	 double  *startpt,
	 double  *endpt,
	 double  *norm_vec,
	 int  *flag
	)
	*/
int *rc;
double *centerpt,*startpt,*endpt;
double *norm_vec;
int *flag;
/*.MATH_get_dir_vec*/
{

	BSrc bs_rc;
	double cross_p[3], dot_p;
	double vector1[3],vector2[3];
	
	
	v_sub(startpt,centerpt,vector1);
	v_sub(endpt,startpt,vector2);

	v_cross( vector1,vector2,cross_p);
	dot_p = BSdotp(&bs_rc,cross_p,norm_vec);

	if( dot_p > 0)
		*flag = ANTI_CLOCK_DIR;
	else  
		*flag = CLOCK_DIR;

	*rc = bs_rc;
	return(TRUE);
}

#argsused
MATH_intersect_circle_line (msg,
			    centerpt,
			    rad,
			    num_inter,
			    interpt,
			    box_in,
			    plane)
         /*(
	 IGRint  *msg,
	 IGRdouble  centerpt[3],
	 IGRdouble  rad,
	 IGRint  *num_inter,
	 IGRdouble  interpt[2][3],
	 IGRdouble  box_in[4][3],
	 IGRdouble  plane[16]
	)
	*/
IGRint *msg;
IGRdouble centerpt[3],rad;
IGRdouble box_in[12];
IGRint *num_inter;
IGRdouble interpt[2][3];
IGRdouble plane[16];
/*.MATH_intersect_circle_line*/
{
	IGRint i, j;
	BSrc bs_rc;
	IGRpoint intpts[2];
	IGRint count;
	IGRshort num;
	IGRdouble dist1,dist2,dist3;
	IGRdouble box[5][3];

	memcpy(box, box_in, 12*sizeof(double));
	vec_equal(box[0], box[4]);

	count = 0;
	for (i=0; i<4; i++)
	{
		num = 0;

		BSxlnsph(
			box[i],
			box[i+1],
			centerpt,
			rad,
			&num,
			intpts,
			&bs_rc);

		if (!num) continue;

	        /* find the intersection point on the curve */

		dist1 = BSdistptpts(&bs_rc, box[i], box[i+1]);

		for (j=0; j<num; j++)
		{
			dist2 = BSdistptpts(&bs_rc, box[i] ,intpts[j]);
			dist3 = BSdistptpts(&bs_rc, box[i+1], intpts[j]);

			if ((dist2<dist1) && (dist3<dist1))
			{
				vec_equal(intpts[j], interpt[j]);
				count++;
			}
		}
	}

	*num_inter = count;
	*msg = OM_S_SUCCESS;
	return(TRUE);
}

DMget_direction (src_pt,
		 test_pt,
		 plane,
		 flag)
	 IGRdouble  *src_pt;
	 IGRdouble  *test_pt;
	 IGRdouble  *plane;
	 IGRint  *flag;
/*.DMget_direction*/
{
	IGRdouble point1[2],point2[2];

		point1[0] =	plane[0] * src_pt[0] +	plane[1] * src_pt[1]  +
				plane[2] * src_pt[2] ;

		point1[1] =	plane[4] * src_pt[0] +  plane[5] * src_pt[1]  +
				plane[6] * src_pt[2];

		point2[0] =	plane[0] * test_pt[0] +	plane[1] * test_pt[1] +
				plane[2] * test_pt[2] ;

		point2[1] =	plane[4] * test_pt[0] +  plane[5] * test_pt[1] +
				plane[6] * test_pt[2];

		if( point1[0] > point2[0])
			*flag = AN_BEFORE;
		else 
			*flag = AN_AFTER;
		return(TRUE);
}

IGRint DMlineptpt (point1,point2,line)
/*(
	 IGRdouble  point1[3],
	 IGRdouble  point2[3],
	 IGRdouble  line[2][3]
	)
*/
IGRdouble point1[3];
IGRdouble point2[3];
IGRdouble line[2][3];
{
	IGRint index;

	for (index=0; index<3; index++)
	{
		line[0][index] = point1[index];
		line[1][index] = point2[index];
	}

	return(TRUE);
}

IGRint DMlineptvec (point1,vector,line)
/*(
	 IGRdouble  point1[3],
	 IGRdouble  vector[3],
	 IGRdouble  line[2][3]
	)
*/
IGRdouble point1[3];
IGRdouble vector[3];
IGRdouble line[2][3];
{
	IGRint index;

	for (index=0; index<3; index++)
	{
		line[0][index] = point1[index];
		line[1][index] = point1[index] + vector[index];
	}

	return(TRUE);
}

IGRint DMmat_diff ( m1,m2)
/*(
	 IGRdouble  m1[16],
	 IGRdouble  m2[16]
	)
*/
IGRdouble m1[16], m2[16];
/*.DMmat_diff*/
{
	IGRint index;
	BSrc bs_rc;
	IGRvector vec_x1, vec_y1;
	IGRvector vec_x2, vec_y2;
	IGRdouble dotp_x, dotp_y;
	IGRdouble min_dotp, max_dotp;

	for (index=0; index<3; index++)
	{
		vec_x1[index] = m1[index];
		vec_y1[index] = m1[index+4];
		vec_x2[index] = m2[index];
		vec_y2[index] = m2[index+4];
	}

	min_dotp = MINIMUM_DOTP_TOLERANCE;
	max_dotp = 2 - MINIMUM_DOTP_TOLERANCE;

	dotp_x = BSdotp(&bs_rc, vec_x1, vec_x2);
	dotp_y = BSdotp(&bs_rc, vec_y1, vec_y2);

	/*^
		print_point("vec_x1", vec_x1);
		print_point("vec_x2", vec_x2);
		print_point("vec_y1", vec_y1);
		print_point("vec_y2", vec_y2);
		printf("dotp_x=%lf\n", dotp_x);
		printf("dotp_y=%lf\n", dotp_y);
	*/

	if ((dotp_x > min_dotp && dotp_x < max_dotp) &&
	    (dotp_y > min_dotp && dotp_y < max_dotp))
	{
		/*| - Window Not Rotated - */
		return(FALSE);
	}
	else
	{
		/*| - Window Rotated - */
		return(TRUE);
	}
}

IGRint DMextend_points (p1,p2,p3,p4,x_dir,y_dir,x_off,y_off)
/*(
	 IGRdouble  *p1,
	 IGRdouble  *p2,
	 IGRdouble  *p3,
	 IGRdouble  *p4,
	 IGRdouble  *x_dir,
	 IGRdouble  *y_dir,
	 IGRdouble  x_off,
	 IGRdouble  y_off
	)
	*/
IGRdouble *p1,*p2,*p3,*p4;
IGRdouble *x_dir,*y_dir;
IGRdouble x_off,y_off;
/*.DMextend_points*/
{
	IGRdouble diag1_dir[3],diag2_dir[3];
	IGRint i;

	for(i = 0; i<3;i++)
	{
		diag1_dir[i] = - x_dir[i]*x_off - y_dir[i]*y_off;
		diag2_dir[i] =   x_dir[i]*x_off - y_dir[i]*y_off;
	}
	
	for( i = 0; i<3; i++)
	{
		p1[i] = p1[i] + diag1_dir[i];
		p2[i] = p2[i] + diag2_dir[i];
		p3[i] = p3[i] - diag1_dir[i];
		p4[i] = p4[i] - diag2_dir[i];
	}

	return(TRUE);
}

IGRint DMproject_points (msg,
			  p0,
			  p1,
			   p2,
			   p3,
			   norm,
			   pt)
			   /*(
	 IGRint  *msg,
	 IGRpoint  p0,
	 IGRpoint  p1,
	 IGRpoint  p2,
	 IGRpoint  p3,
	 IGRvector  norm,
	 IGRpoint  pt
	)
	*/
IGRint *msg;
IGRpoint p0, p1, p2, p3;
IGRvector norm;
IGRpoint pt;
{
	IGRint status;
	BSrc bs_rc;
	IGRpoint projpt;

	if (p0)
	{
		status = BSproj1(&bs_rc, p0, norm, pt, projpt);
		dm$status(action = RET_STATUS);
		vec_equal(projpt, p0);
	}

	if (p1)
	{
		status = BSproj1(&bs_rc, p1, norm, pt, projpt);
		dm$status(action = RET_STATUS);
		vec_equal(projpt, p1);
	}

	if (p2)
	{
		status = BSproj1(&bs_rc, p2, norm, pt, projpt);
		dm$status(action = RET_STATUS);
		vec_equal(projpt, p2);
	}

	if (p3)
	{
		status = BSproj1(&bs_rc, p3, norm, pt, projpt);
		dm$status(action = RET_STATUS);
		vec_equal(projpt, p3);
	}

	*msg = OM_S_SUCCESS;
	return(TRUE);
}


end implementation DMroot;
