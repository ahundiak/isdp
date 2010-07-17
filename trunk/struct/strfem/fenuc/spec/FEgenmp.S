class specification FEgenmp (1:0) of FEfemfd;

/* *****************************H H H H H******************************* */
/* Doc: FEgenmp

   Abstract: Abstract parent class for material and property feature
	descriptors. Instance data and messages common to both material and
	properties are declared in this class.

   History:

	Date		Who	Version	Why
	---------	------	-------	----------------------------------
	12-29-87	kk		Creation
	03-11-88	ahs		Implemeted FD_INFO
	04-06-88	kk		Added mp_type as argument for
						xpose_name
						xpose_data
	06-29-88	kk		Added put_mp_on_list message
	08-03-88	ahs		Override GRnotifylis
	11-10-88	kk		Added verify message
	07-09-89	kk		Added type_count message
	03-30-91	kk		Added desvar_mode argument to xpose_data
	12/27/91	raj	2.0.0	Changed parent from FEfd to FEfemfd.
	06/19/92	raj	2.0.1	Override 'NDcopy_graph'.
*/
/* *****************************H H H H H******************************* */

#include	"FElimits.h"

instance FEgenmp
{
	char				name[FE_MAX_MPNAME_SIZE];
	channel {(many_to_one)}		to_mpman;
};

message	genmp_init(
	long		*msg;		/* o - Return Status		*/
	char		name[];		/* i - name of entry		*/
	FD_INFO		mp_info;	/* i - Misc info structure	*/
	char		unif_fd_data[]; /* i - data that cannot have
							graphics help	*/
	double		var_fd_data[];	/* i - data that can have
							graphics help	*/
	);

message	xpose_name(
	long		*msg;		/* o - Return Status		*/
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE..*/
	long		buf_size;	/* i - Size of name ptr buffer	*/
	char		*names[];	/*i/o- List to add name to	*/
	char		mp_types[];	/* o - list of types ISOMAT_TYPE.. */
	long		*list_count;	/*i/o- Count to be incremented
						Seed to zero		*/
	);

message match_name(
	long		*msg;		/* o - Return Status		*/
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE..*/
	char		name[];		/* i - Name to check against	*/
	char		*found;		/* o - TRUE if name matches	*/
	OM_S_OBJID	*match_objid;	/* o - Objid of mp that matches	*/
	);

message xpose_data(
	long		*msg;		/* o - Return Status		*/
	char		name[];		/* i - Name to check against	*/
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE,...  */
	double		*uv;		/* i - 'uv' parameter/s of point at
						which the value of feature
						descriptor required.
				     Dimension	: uv
					 0	: not applicable
					 1	: u parameter of b-spline curve
					 2	: uv[0,1] = u,v parameters
							of b-spline surface
					 3	: uv[0,1,2] = x,y,z coordinates
							of point within solid */
	long		unif_data_size;	/* i - size of unif data in bytes */
	long		num_var_data;	/* i - number of var data	*/
	char		desvar_mode;	/* i - TRUE: return value defined by design variable
					       FALSE : return values stored in FEfd instance */
	char		*found;		/* o - TRUE if name matches	*/
	FD_INFO		*mp_info;	/* o - Includes Iso, Ortho .. for
					       materials and Linprop, Panprop..
					       for properties		*/
	char		unif_fd_data[]; /* o - data that cannot have
							graphics help	*/
	double		var_fd_data[];	/* o - data that can have
							graphics help	*/
	);

message count (
	long		*msg;		/* o - Return Status		*/
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE,...  */
	long		*count;		/* o - Count. init to 0		*/
);

message	put_mp_on_list (
	IGRlong		*msg;		/* o - Return Status		*/
	IGRchar		mat_name[];	/* o - Name of material		*/
	IGRchar		*mat_type;	/* o - Material type		*/
	OM_S_OBJID	*mat_objid;	/* o - Material object id	*/
	IGRchar		prp_name[];	/* o - Name of property		*/
	IGRchar		*prop_type;	/* o - Property type		*/
	OM_S_OBJID	*prp_objid;	/* o - Property object id	*/
	);

message	rename_mp (
	long		*msg;		/* o - Return Status		*/
	char		name[];		/* i - Entrie's new name	*/
	);

message verify (
	long		*msg;		/* o - Return status		*/
	long		analysis_type;	/* i - structural, heat_transfer..
					       as defined in FEisasdef.h */
	long		print_flag;	/* i - Print error messages	*/
	);

message type_count (
	struct fempstats *mp_stats;	/* i/o Mat/prop statistics	*/
);

/*
**  -------------------------------------------------------------------
**  Overrides:
**  -------------------------------------------------------------------
*/
override delete,
	 debug,
	 GRnotifylis,
	 NDcopy_graph;

/*
**  -------------------------------------------------------------------
**  Reject:
**  -------------------------------------------------------------------
*/
reject verify;

end specification FEgenmp;
