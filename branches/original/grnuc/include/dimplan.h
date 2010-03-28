#ifndef dim_plan_include

#define dim_plan_include

#define NO_AXIS	0

struct dim_plan_info
{
	IGRshort  matrix_type;
	IGRdouble matrix[16];
	IGRdouble vec_xpos[3];
	IGRdouble vec_ypos[3];
	IGRdouble vec_xneg[3];
	IGRdouble vec_yneg[3];
};

struct DMplan_info
{
	struct dim_plan_info win_plan;
	struct dim_plan_info act_plan;
};

/* - DMplan_attr structure is used as "as_attr" for NDplace.
     if (win_grid.objid == NULL_OBJID) then the matrix
     supplied is used to define the dimension plane else
     the window orientation is used to define dimension plane - */

struct DMplan_attr
{
	struct GRid win_grid;
	IGRmatrix matrix;
};

#endif

