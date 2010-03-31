/* This file defines the data type of the input arguments to
 *  method EMsweep_compsite_curve: which sweeps a composite curve 
 *  either a vector (compsite surface of projection) or around an 
 *  axis(composite surface of revolution) to create a composite 
 *  surface           
 */

# ifndef EMSsweep_include
# define EMSsweep_include 

/* Below are the options which describes the type of sweep to the method.
 *	options: EMProject		Sweep along a vector ( project ).
 *			 EMRevolve      Sweep around an axis ( revolve ).
 */
enum EMSsweep_type
{
	EMProject,

	EMRevolve
};

/* Below is the structure which describes the project data */
struct EMSprj_data
{
		IGRpoint			*point1, *point2;
};

/* Below is the structure which describes the revolve data */
struct EMSrev_data
{
		double				*axis, start_angle, sweep_angle;
		int					full_rev;
};

/* Depending on the options EMSsweep_data contains one of the following:
 *  
 *	o Project data (struct prj_data).
 *
 *	o Revolve data (struct rev_data).
 */							
union EMSsweep_data
{
			struct			EMSprj_data			prj_data;
	
			struct			EMSrev_data			rev_data;
};


/*  EMSdataselect inspired this structure, and was modified for sweeping
 *   composite curve to create compsite suraface.
 */
struct EMSsweep
{
	enum  EMSsweep_type		type;
	union EMSsweep_data		data;
};

# endif
