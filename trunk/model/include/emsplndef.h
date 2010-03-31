/* This file defines the data type of the input arguments to
    method EMtest_planar: which tests planarity of composited surfaces. */

# ifndef emsplndef_include
# define emsplndef_include

/* Below are the options which describes the input to EMtest_planar() 
	options: EMComposite_Id		Input: pointer to composite surface id.
			 EMIndividual_Ids   Input: pointer to individual surface id 
								 pointers.
			 EMIndividual_Geoms Input: pointer to individual surface 
								 geometry pointers                      */

enum EMSplan_options
{
	EMComposite_Id,
	
	EMIndividual_Ids,

	EMIndividual_Geoms
};

/* Depending on the options EMSplan_data contains:
   
	o Pointer to composite surface Id.

	o Pointer to individual surface id pointers.

    o Pointer to individual surface geometryy pointers.                 */
							
union EMSplan_data
{
			GRobjid			*comp_id;
	
			GRobjid			**sf_ids;

	struct 	IGRbsp_surface 	**sf_geoms;
};


/*  EMSdataselect inspired this structure, and was modified for checking
     planarity of group of surfaces 								 */

struct EMStest_plan_group
{
	enum  EMSplan_options	option;
	union EMSplan_data		data;
		  IGRlong			num_sfs;
};

# endif
