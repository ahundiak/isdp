/* ###################   APOGEE COMPILED   ################## */
class implementation Root;

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "ems_m_inc.h"		/* Includes everything */
#include "bserr.h"		/* Math error return codes */
#include "bsnorvec.h"
#include "bscvnormal.h"
#include "bscveval_b.h"
#include "bscrossp.h"
#include "bsbx2.h"

/*  
    History 

    Tapadia  10/14/91 - Most of the code taken from 
			EFdisplay_curve_normal_or tangent. This function 
			returns the new point of the curve normal 
    Sudha   06/02/93        modified to include for BSprototype headers
*/

from GRvg import GRgenabsg;

IGRlong EFret_crv_norpt(loc_info, reverse_vector, new_pt, msg)	

struct		GRlc_info *loc_info;
IGRboolean	reverse_vector;
IGRpoint 	new_pt;
IGRlong		*msg;
{
	IGRlong		sts, loc_msg;
	IGRpoint	point_on_curve, left_derv[2], right_derv[2];
	IGRvector	tangent_vector, normal_vector, curve_normal;
	GRrange	range;
	struct	IGRbsp_curve *curve;
	IGRdouble 	length, temp_length, u_value, u_low, u_hig, min_len;
	IGRint 		i, number_of_derivatives;
	IGRchar		*generic_pointer;
	struct	GRid *id;
	struct	GRmdenv_info *mdenv_info;
	IGRboolean	status, evaluate_boundaries, was_discontinuous;

	/* Initialize */
	*msg = MSSUCC;

	/* Get the curve geometry */
	mdenv_info = &loc_info->module_info.md_env;
	id = &loc_info->located_obj;
	sts = om$send( msg = message GRvg.GRgenabsg(
	    		msg, &mdenv_info->matrix_type,
	    		mdenv_info->matrix, &generic_pointer),
	    	senderid = NULL_OBJID,
	    	targetid = id->objid,
	    	targetos = id->osnum);

	if (! (1 & sts)) goto wrapup;
	curve = (struct IGRbsp_curve *) generic_pointer;

	/* Compute the tangent vector of the curve */
	u_low = curve->knots[curve->order - 1];
	u_hig = curve->knots[curve->num_poles];
	u_value = (u_hig - u_low) / 2.0;
	evaluate_boundaries = TRUE;
	number_of_derivatives = 1;

	status = BScveval_b( &loc_msg, curve, &u_value, 
			&number_of_derivatives, &evaluate_boundaries,
		    	&was_discontinuous, left_derv, right_derv);

	if (! status) {
		*msg = MSFAIL;
		goto wrapup;
	}
		
	/* If the tangent was not continuous at the chosen
 	 parameter then average the left and right tangents */
	if(was_discontinuous) {
		left_derv[1][0] += right_derv[1][0];
		left_derv[1][0] /= 2.0;
		left_derv[1][1] += right_derv[1][1];
		left_derv[1][1] /= 2.0;
		left_derv[1][2] += right_derv[1][2];
		left_derv[1][2] /= 2.0;
	}

	/* Normalize the tangent vector */
	status = BSnorvec(&loc_msg, left_derv[1]);

	if (!status) {
		if (loc_msg != BSDGENRAT) *msg = MSFAIL;
		goto wrapup;
	}

  	point_on_curve[0] = left_derv[0][0];
  	point_on_curve[1] = left_derv[0][1];
  	point_on_curve[2] = left_derv[0][2];
	tangent_vector[0] = left_derv[1][0];
	tangent_vector[1] = left_derv[1][1];
	tangent_vector[2] = left_derv[1][2];

	/* Get the curve normal */
	status = BScvnormal2(&loc_msg, curve, normal_vector);

	/* Cross the plane normal with the curve tangent to yield the 
	curve normal */
	status = BScrossp(&loc_msg, normal_vector, tangent_vector, 
		curve_normal);

	status = BSnorvec( &loc_msg, curve_normal); 

	if (!status) {
		*msg = MSFAIL;
		goto wrapup;
	}
		
	/* Get the range of the curve. This is used to determine the length 
	of the vector for the new point */

	/* If the curve range is very large then & if the value is greater 
	than the default (0.1) then assign min_len as 0.1 */

	status = BSbx2( &loc_msg, &curve->num_poles, (IGRpoint *)curve->poles,
		(curve->rational ? curve->weights : NULL),
		&range[0], &range[3]);

	if (! status) {
		*msg = MSFAIL;
		goto wrapup;
	}

	length = range[3] - range[0];
	temp_length = range[4] - range[1];
	if (temp_length > length)
		length = temp_length;
	temp_length = range[5] - range[2];
	if (temp_length > length)
		length = temp_length;
	length *= 0.01;

	if(length > 0.1) 
		min_len = 0.1;
	else 
		min_len = length;

	if (reverse_vector) 	min_len *= -1.0;
	for(i = 0; i < 3; i++) 
		new_pt[i] = point_on_curve[i] + (min_len * curve_normal[i]);

wrapup:
	if (1 & *msg)
		return(TRUE);
	else
		return(FALSE);
}


end implementation Root;
