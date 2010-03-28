class implementation DMsrc;

#define AS_DEBUG 1

extern double fabs();

%safe

static struct IGRbsp_curve *CURVE_ACTUAL = NULL;
static struct IGRbsp_curve *CURVE_PROJECTED = NULL;
static struct IGRbsp_curve *CURVE_CREATED = NULL;
static struct IGRbsp_curve *CURVE_CONVERTED = NULL;
static IGRdouble DIM_NORMAL[3], CURVE_NORMAL[3];
static IGRdouble  POINT_ON_CURVE[3];
static IGRdouble UPAR_LOW, UPAR_HIGH;
static struct GRid AS_GRID, GO_GRID, PLAN_GRID;
static IGRdouble CENTER[3];
static IGRdouble RADIUS;
static IGRboolean PLANES_PARALLEL = FALSE;
static IGRboolean CURVE_IS_A_CIRCLE = FALSE;
static IGRboolean DYNAMICS_ON = FALSE;
static IGRboolean CACHE_LOADED = FALSE;
static IGRdouble  UPAR_START;
static IGRdouble  UPAR_END;

%endsafe

#include "bstypes.h"
#include "bsconic.h"
#include "bsparameters.h"
#include "bststcvfln.h"
#include "bststcvfarc.h"
#include "bsprj_cv_pl.h"
#include "bsfreecv.h"
#include "bsdotp.h"
#include "bsbrkcvaprs.h"
#include "bsalloccv.h"
#include "bsactivsplt.h"

from GRconic	import GRgetarc;

IGRint DMload_cache (list,convert_linestr,set_upar_limit,upar,md_env)
/*(
	 struct GRid  list[2],
	 IGRboolean  convert_linestr,
	 IGRboolean  set_upar_limit,
	 IGRdouble  *upar,
	 struct GRmd_env  *md_env
	)
*/
struct GRid list[2];
IGRboolean convert_linestr;
IGRboolean set_upar_limit;
IGRdouble *upar;
struct GRmd_env *md_env;
/*.DMload_cache*/
{
	IGRint status;
	IGRlong long_rc, size;
	IGRshort matrix_type, is_line, tst_plan;
	IGRmatrix matrix, dim_plan;
	struct IGRplane igr_plane;
	struct IGRarc arc;
	IGRdouble dotp;
	IGRlong num_poles;
	IGRdouble *knots, *d_knots;
	IGRdouble inc, sum, tol;
	IGRint index, index2;
	IGRint num_knots, num;
	struct IGRbsp_curve **cvs, *arc_curve, *arc_split;
	IGRpoint pt1, pt2;
	extern GRclassid OPP_GRconic_class_id;
	BSrc bs_rc;

        IGRboolean aflag = 0;

	if (CACHE_LOADED)
	{
	/*| Cache already loaded */
		return(OM_S_SUCCESS);
	}

	DMclear_cache();

	AS_GRID = list[0];
	PLAN_GRID = list[1];

	if (set_upar_limit)
	{
		UPAR_LOW = 0.0;
		UPAR_HIGH  = 1.0;
		UPAR_START = 0.0;
		UPAR_END = 1.0;
	}

	/*"Get go_grid\n"*/

	status =
	om$send(msg = message NDnode.ASreturn_go(
					&GO_GRID,
					&matrix_type,
					matrix),
		senderid = NULL_OBJID,
		targetid = AS_GRID.objid,
		targetos = AS_GRID.osnum);
	dm$status(action = RET_STATUS);


	/*^ print_grid("go_grid", &GO_GRID); */

	/*|GRgetsize*/

	status =
	om$send(msg = message GRvg.GRgetsize(
					&long_rc,
					&matrix_type,
					matrix,
					&size),
		senderid = NULL_OBJID,
		targetid = GO_GRID.objid,
		targetos = GO_GRID.osnum);
	dm$status(action = RET_STATUS);

	/*"size=%d\n", size*/

	CURVE_ACTUAL = (struct IGRbsp_curve *)om$malloc(size = size);
	if (CURVE_ACTUAL == NULL)
	{
		printf("DMload_cache: Malloc failed\n");
		return(OM_E_ABORT);
	}

	/*|GRgetgeom*/

	status =
	om$send(msg = message GRvg.GRgetgeom(
					&long_rc,
					&matrix_type,
					matrix,
					(char *)CURVE_ACTUAL),
		senderid = NULL_OBJID,
		targetid = GO_GRID.objid,
		targetos = GO_GRID.osnum);
	dm$status(action = RET_STATUS);

	igr_plane.normal = CURVE_NORMAL;
	igr_plane.point  = POINT_ON_CURVE;

	/*|GRdetplane*/
	status =
	om$send(msg = message GRvg.GRdetplane(
					&long_rc,
					&matrix_type,
					matrix,
					&igr_plane),
		senderid = NULL_OBJID,
		targetid = GO_GRID.objid,
		targetos = GO_GRID.osnum);
	dm$status(action = RET_STATUS);

	/*|get_window_plane*/

        if(aflag = pwIsActivationOn())
        {   
        struct GRmd_env id_env; 

        pwGetActiveModuleEnv(&id_env);
        MAidmx(&long_rc, id_env.md_env.matrix);
        id_env.md_env.matrix_type = MAIDMX;
     
	dm$get_plan_info(
		plan_objid = PLAN_GRID.objid,
		osnum = PLAN_GRID.osnum,
		md_env = &id_env,
		win_matrix = dim_plan);
        }
        else
        { 
	dm$get_plan_info(
		plan_objid = PLAN_GRID.objid,
		osnum = PLAN_GRID.osnum,
		md_env = md_env,
		win_matrix = dim_plan);
        }
	DIM_NORMAL[0] = dim_plan[8];
	DIM_NORMAL[1] = dim_plan[9];
	DIM_NORMAL[2] = dim_plan[10];

	dotp = fabs(BSdotp(&bs_rc, CURVE_NORMAL, DIM_NORMAL));
	PLANES_PARALLEL = (dotp > DOTP_LOWER_BOUND && dotp < DOTP_UPPER_BOUND);
	CURVE_IS_A_CIRCLE = FALSE;

	/*^ 
		print_point("DIM_NORMAL", DIM_NORMAL);
		print_point("CURVE_NORMAL", CURVE_NORMAL);
		printf("dotp=%lf\n", dotp);
	*/

	if (PLANES_PARALLEL)
	{
		/*|PLANES_PARALLEL*/

		CURVE_PROJECTED = CURVE_ACTUAL;

		if (DMancestry_valid(GO_GRID, OPP_GRconic_class_id))
		{
			/*|Object is a conic*/

			status =
			om$send(msg = message GRconic.GRgetarc(
							&long_rc,
							&matrix_type,
							matrix,
							&arc),
				senderid = NULL_OBJID,
				targetid = GO_GRID.objid,
				targetos = GO_GRID.osnum);
			dm$status(action = RET_STATUS);

			if (fabs(arc.prim_axis - arc.sec_axis) < 1e-08)
			{
				/*| Curve IS a circle */

				CURVE_IS_A_CIRCLE = TRUE;
				RADIUS = arc.prim_axis;
				math_v_equal(CENTER, arc.origin);
			}
		}
	}
	else
	{
		/*|PLANES NOT PARALLEL*/

		BSalloccv(
			CURVE_ACTUAL->order,
			CURVE_ACTUAL->num_poles,
			CURVE_ACTUAL->rational,
			CURVE_ACTUAL->num_boundaries,
			&CURVE_PROJECTED,
			&bs_rc);
		if (bs_rc != BSSUCC)
		{
			printf("DMload_cache: BSalloccv Fail\n");
			return(OM_E_ABORT);
		}

		/*|Project curve onto dim_plane*/

		status =
		BSprj_cv_pl(
			&bs_rc,
			CURVE_ACTUAL,
			POINT_ON_CURVE,
			DIM_NORMAL,
			DIM_NORMAL,
			CURVE_PROJECTED);
		if (!status || bs_rc != BSSUCC)
		{
			printf("DMload_cache: BSprj_cv_pl fails\n");
			return(OM_E_ABORT);
		}
	}

	if (CURVE_PROJECTED->order == 2
	&&  CURVE_PROJECTED->num_poles > 3
	&&  convert_linestr)
	{
		/*| Line string with more than three poles */
		if (CURVE_PROJECTED->phy_closed)
			num_poles = CURVE_PROJECTED->num_poles + 1;
		else	num_poles = CURVE_PROJECTED->num_poles;

		BSalloccv(
			3,
			num_poles,
			CURVE_PROJECTED->rational,
			CURVE_PROJECTED->num_boundaries,
			&CURVE_CREATED,
			&bs_rc);
		if (bs_rc != BSSUCC)
		{
			printf("DMload_cache: BSalloccv Fail\n");
			return(OM_E_ABORT);
		}

		CURVE_CREATED->order = 3;
		CURVE_CREATED->periodic = CURVE_PROJECTED->periodic;
		CURVE_CREATED->non_uniform = CURVE_PROJECTED->non_uniform;
		CURVE_CREATED->num_poles = num_poles;
		CURVE_CREATED->num_knots = num_poles + 3;
		CURVE_CREATED->num_boundaries = CURVE_PROJECTED->num_boundaries;
		CURVE_CREATED->rational = CURVE_PROJECTED->rational;
		CURVE_CREATED->weights = CURVE_PROJECTED->weights;
		CURVE_CREATED->planar = CURVE_PROJECTED->planar;
		CURVE_CREATED->phy_closed = CURVE_PROJECTED->phy_closed;
		CURVE_CREATED->num_boundaries = CURVE_PROJECTED->num_boundaries;
		CURVE_CREATED->bdrys = CURVE_PROJECTED->bdrys;

		memcpy(	CURVE_CREATED->poles,
			CURVE_PROJECTED->poles,
			3 * CURVE_PROJECTED->num_poles * sizeof(double));

		if (CURVE_PROJECTED->phy_closed)
		{
			/*| Closed line string */

			for (index=0; index<3; index++)
			{
				index2 = 3*(num_poles - 1) + index;

				CURVE_CREATED->poles[index] =
				CURVE_CREATED->poles[index2] =
				(CURVE_PROJECTED->poles[index] +
				 CURVE_PROJECTED->poles[index+3]) * 0.5;
			}
		}

		/*| Initialise knot values */

		inc = 1.0/(num_poles - 2);
		sum = 0.0;
		knots = CURVE_CREATED->knots;

		knots[0] =
		knots[1] =
		knots[2] = 0.0;
		knots[num_poles] =
		knots[num_poles + 1] =
		knots[num_poles + 2] = 1.0;

		for (index=3; index<num_poles; index++)
		{
			sum += inc;
			knots[index] = sum;
		}
	}
	else	CURVE_CREATED = CURVE_PROJECTED;

	if (CURVE_CREATED->order > 2
	&&  CURVE_CREATED->num_poles > 3
	&&  set_upar_limit
	&&  (!CURVE_IS_A_CIRCLE))
	{
		/*| set upar limit for merged curve */
		num_knots = CURVE_CREATED->order + CURVE_CREATED->num_poles;
		knots = CURVE_CREATED->knots;
		d_knots = (IGRdouble *)om$malloc(size = sizeof(IGRdouble) * num_knots);
		if (d_knots == NULL)
		{
			printf("DMload_cache: Malloc Failed\n");
			return(OM_E_ABORT);
		}

		(void)BSEXTRACTPAR(&bs_rc,BSTOLKNOT,tol);		
		if (bs_rc != BSSUCC)
		{
			printf("DMload_cache: BSEXTRACTPAR Fails\n");
	                if (d_knots != NULL)
                           om$dealloc(ptr = d_knots);
			return(OM_E_ABORT);
		}


		num = 1;
		d_knots[0] = knots[0];
		for(index=0; index<num_knots-1; index++)
		{
			if(fabs(knots[index] - knots[index+1]) > tol)
			{
				num +=1;
				d_knots[num-1] = knots[index+1];
			}
		}

		cvs = (struct IGRbsp_curve **)om$malloc(size = sizeof(struct IGRbsp_curve) * num_knots);
		if (cvs == NULL)
		{
			printf("DMload_cache: Malloc failed\n");
			if (d_knots != NULL)
                           om$dealloc(ptr = d_knots);
			return(OM_E_ABORT);
		}

		BSbrkcvaprs(
			CURVE_CREATED,
			num,
			d_knots,
			FALSE,
			cvs,
			&bs_rc);
		if (bs_rc != BSSUCC)
		{
			printf("DMload_cache: BSbrkcvaprs Fails\n");
			if (d_knots != NULL)
                           om$dealloc(ptr = d_knots);
                        if (cvs != NULL)
                           om$dealloc(ptr = cvs);
			return(OM_E_ABORT);
		}
		for(index=0; index<num-1; index++)
	        {
                        BStstcvfln(cvs[index], &is_line, pt1, pt2, &bs_rc);
                        if (bs_rc != BSSUCC)
                        {
                                printf("DMload_cache: BStstcvfln Fails\n");
                                if (d_knots != NULL)
                                   om$dealloc(ptr = d_knots);
                                if (cvs != NULL)
                                   om$dealloc(ptr = cvs);
                                return(OM_E_ABORT);
                        }
		
                        if (is_line)
                        {
               if ((*upar > d_knots[index]) && (*upar < d_knots[index+1]))
                                {
                                        /*| cannot measure linear element */
                                        if (d_knots != NULL)
                                           om$dealloc(ptr = d_knots);
                                        if (cvs != NULL)
                                           om$dealloc(ptr = cvs);
                                        return(OM_E_ABORT);
                                }

                                if (*upar > d_knots[index+1])
                                        UPAR_START = d_knots[index+1];

                                if (*upar < d_knots[index])
				{
				UPAR_END = d_knots[index];
                                break;
                                }
                        }
                }
	
		for(index=0; index<num-1; index++)
		{
			BStstcvfln(cvs[index], &is_line, pt1, pt2, &bs_rc);
			if (bs_rc != BSSUCC)
			{
				printf("DMload_cache: BStstcvfln Fails\n");
				if (d_knots != NULL)
                                   om$dealloc(ptr = d_knots);
                                if (cvs != NULL)
                                   om$dealloc(ptr = cvs);
				return(OM_E_ABORT);
			}
			
			/*| check if curve is line */

			if (is_line)
			{
				if ((*upar > d_knots[index]) && (*upar < d_knots[index+1]))
				{
					/*| cannot measure linear element */
/* At this point the user is trying to access straightline of the curve part
		to put radial dimension eventhough it is easy for it to point
		to the nearest arc it is not preferable to show it as it
		will not modify the upar of the arc                      */
					if (d_knots != NULL)
                                           om$dealloc(ptr = d_knots);
                                        if (cvs != NULL)
                                           om$dealloc(ptr = cvs);
					return(OM_E_ABORT);
				}

				if (*upar > d_knots[index+1])
					UPAR_LOW = d_knots[index+1];

				if (*upar < d_knots[index])
				{
					UPAR_HIGH = d_knots[index];
					break;
				}
			}
/* Every time we cannot expect an arc to be surrounded by st lines, if it is
	not done then this will not handle the cases of two arcs drawn side
	by side and merged                           */
			else
			{
				if((*upar >= d_knots[index]) &&(*upar <= d_knots[index+1]))
			{ UPAR_HIGH = d_knots[index+1];
			  UPAR_LOW = d_knots[index];
			  break;
			}
			}
		}
		if (d_knots != NULL) om$dealloc(ptr = d_knots);
	        if (cvs != NULL) om$dealloc(ptr = cvs);

	}
	if((UPAR_START <= UPAR_LOW) && (UPAR_END >= UPAR_HIGH))
		{
			UPAR_LOW = UPAR_START;
			UPAR_HIGH = UPAR_END;
		}

	if ((UPAR_LOW != 0.0) || (UPAR_HIGH != 1.0))
	{
		/*| convert the curve to the new upar limit */

		BSalloccv(
			CURVE_CREATED->order,
			CURVE_CREATED->num_poles,
			CURVE_CREATED->rational,
			CURVE_CREATED->num_boundaries,
			&arc_split,
			&bs_rc);
		if (bs_rc != BSSUCC)
		{
			printf("DMload_cache: BSalloccv Fail\n");
			return(OM_E_ABORT);
		}

		tst_plan = FALSE;
		BSactivsplt(
			&bs_rc,
			CURVE_CREATED,
			&UPAR_LOW,
			&UPAR_HIGH,
			arc_split,
			&tst_plan);
		if (bs_rc != BSSUCC)
		{
			printf("DMload_cache: BSactivsplt Fails\n");
			if (arc_split)
                          BSfreecv(&bs_rc, arc_split);
			return(OM_E_ABORT);
		}

		BSalloccv(
			arc_split->order,
			arc_split->num_poles,
			arc_split->rational,
			arc_split->num_boundaries,
			&arc_curve,
			&bs_rc);
		if (bs_rc != BSSUCC)
		{
			printf("DMload_cache: BSalloccv Fail\n");
			if (arc_split)
                          BSfreecv(&bs_rc, arc_split);
			return(OM_E_ABORT);
		}

		/*|- Test Curve for arc */

		BStstcvfarc(
			arc_split,
			&CURVE_IS_A_CIRCLE,
			CENTER,
                        &RADIUS,
			arc_curve,
			&bs_rc);
		if(bs_rc != BSSUCC)
		{
			printf("DMload_cache: BStstcvfarc() Fails\n");
			if (arc_split)
                          BSfreecv(&bs_rc, arc_split);
                        if (arc_curve)
                          BSfreecv(&bs_rc, arc_curve);
			return(OM_E_ABORT);
		}
		if (CURVE_IS_A_CIRCLE)
		{
			/*|- Curve is Arc */
/* It is not desirable to reparametrise the merged curve to arc portion as
	when the merged curve is moved the upar value which will be loaded in
me->data will be absurd and not at all useful for further considerations.  */
/* If the arc is a part of merged curve then do not reparametrise it     */
		
		if((CURVE_CREATED->order > 2)
        &&  (CURVE_CREATED->num_poles > 3))
			 CURVE_CONVERTED = CURVE_CREATED;
			
	else	CURVE_CONVERTED = arc_curve;
			if (arc_split) {
                          BSfreecv(&bs_rc, arc_split);
                          arc_split = NULL;
                        }
		}
		else
		{
	       if((CURVE_CREATED->order > 2)&& (CURVE_CREATED->num_poles > 3))
                      {  CURVE_CONVERTED = CURVE_CREATED;
		UPAR_LOW = UPAR_START;
		UPAR_HIGH =UPAR_END;
		       }
		else	CURVE_CONVERTED = arc_split;
			if (arc_curve) {
                          BSfreecv(&bs_rc, arc_curve);
                          arc_curve = NULL;
                        		}
		} 
	}
	else CURVE_CONVERTED = CURVE_CREATED;
	CACHE_LOADED = TRUE;
	return(OM_S_SUCCESS);
}

IGRint DMclear_cache ()
/*(
	 void
	)
*/
/*.DMclear_cache*/
{
	BSrc bs_rc;

	if (CURVE_CONVERTED == CURVE_CREATED)
		CURVE_CONVERTED = NULL;

	if (CURVE_CREATED == CURVE_PROJECTED)
		CURVE_CREATED = NULL;

	if (CURVE_PROJECTED == CURVE_ACTUAL)
		CURVE_PROJECTED = NULL;

	if (CURVE_ACTUAL)
	{
		om$dealloc(ptr = CURVE_ACTUAL);
		CURVE_ACTUAL = NULL;
	}

	if (CURVE_PROJECTED)
	{
		BSfreecv(&bs_rc, CURVE_PROJECTED);
		CURVE_PROJECTED = NULL;
	}

	if (CURVE_CREATED)
	{
		BSfreecv(&bs_rc, CURVE_CREATED);
		CURVE_CREATED = NULL;
	}

	if (CURVE_CONVERTED)
	{
		BSfreecv(&bs_rc, CURVE_CONVERTED);
		CURVE_CONVERTED = NULL;
	}

	CACHE_LOADED = FALSE;
	return(TRUE);
}

IGRint DMset_dyn_flag (flag)
/*(
	 IGRboolean  flag
	)
*/
IGRboolean flag;
/*.DMset_dyn_flag*/
{
	DYNAMICS_ON = flag;
	return(TRUE);
}

IGRint DMget_cache_data (curve_actual,curve_projected,curve_converted,dynamics_on,
                         point_on_curve,curve_normal,dim_normal,planes_parallel,
                         const_radius,center,radius,upar_low,upar_high)
/*(
	 struct IGRbsp_curve  **curve_actual,
	 struct IGRbsp_curve  **curve_projected,
	 struct IGRbsp_curve  **curve_converted,
	 IGRboolean  *dynamics_on,
	 IGRdouble  **point_on_curve,
	 IGRdouble  **curve_normal,
	 IGRdouble  **dim_normal,
	 IGRboolean  *planes_parallel,
	 IGRboolean  *const_radius,
	 IGRdouble  **center,
	 IGRdouble  *radius,
	 IGRdouble  *upar_low,
	 IGRdouble  *upar_high
	)
*/
struct IGRbsp_curve **curve_actual;
struct IGRbsp_curve **curve_projected;
struct IGRbsp_curve **curve_converted;
IGRboolean *dynamics_on;
IGRdouble **point_on_curve;
IGRdouble **curve_normal;
IGRdouble **dim_normal;
IGRboolean *planes_parallel;
IGRboolean *const_radius;
IGRdouble **center;
IGRdouble *radius;
IGRdouble *upar_low;
IGRdouble *upar_high;
/*.DMget_cache_data*/
{
	if (!CACHE_LOADED)
		return(OM_E_ABORT);

	*curve_actual		= CURVE_ACTUAL;
	*curve_projected	= CURVE_PROJECTED;
	*curve_converted	= CURVE_CONVERTED;
	*dynamics_on		= DYNAMICS_ON;
	*point_on_curve		= POINT_ON_CURVE;
	*curve_normal		= CURVE_NORMAL;
	*dim_normal		= DIM_NORMAL;
	*planes_parallel	= PLANES_PARALLEL;
	*const_radius		= CURVE_IS_A_CIRCLE;
	*center			= CENTER;
	*radius			= RADIUS;
	*upar_low		= UPAR_LOW;
	*upar_high		= UPAR_HIGH;

	return(TRUE);
}

end implementation DMsrc;
