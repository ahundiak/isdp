class specification FEmpman (1:0) of Root;

#include	"OMerrordef.h"
#include	"igetypedef.h"
#include	"igrtypedef.h"
#include	"gr.h"
#include	"APdef.h"
#include	"APerrmac.h"
#include	"FDstruct.h"
#include	"FEfdstruct.h"
#include	<stdio.h>

/* Doc: FEmpman

   Abstract: Manager of materials and properties.
	
   History:

	Date		Who		Why
	---------	------		----------------------------------
	12-29-87	kk		Creation
	03-11-88	ahs		Implemented FD_INFO
	04-06-88	kk		Added buf_size & mp_types as argument
						for show_list
	11-13-88	kk		Added manage_verif_mp message
	07-09-89	kk		Added type_count message
*/
/* *****************************H H H H H******************************* */

instance FEmpman {
	channel {(one_to_many)
		FEgenmp.to_mpman;}	to_material;
	channel {(one_to_many)
		FEgenmp.to_mpman;}	to_property;
};

message	init(
	long		*msg;		/* o - Return Status		*/
	);

message	show_list (
	long		*msg;		/* o - Return Status		*/
	long		mp_category;	/* i - MAT_CATEGORY: show materials
					       PROP_CATEGORY: show property */
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE,...  */
	long		buf_size;	/* i - Size of name ptr buffer	*/
	char		*names[];	/* o - list of names		*/
	char		mp_types[];	/* o - list of types ISOMAT_TYPE.. */
	long		*list_count;	/* o - number of entries found	*/
	);

message	show_data (
	long		*msg;		/* o - Return Status		*/
	long		mp_category;	/* i - MAT_CATEGORY : show materials
					       PROP_CATEGORY : show property*/
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE,...  */
	char		name[];		/* i - name of entry		*/
	long		unif_data_size;	/* i - size of unif data in bytes */
	long		num_var_data;	/* i - number of var data	*/
	char		*found;		/* o - TRUE if name matches	*/
	FD_INFO		*matprop_info;	/* o - Includes ISO, ORTHO .. for
					       materials and BMPROP, PANPROP..
					       for properties		*/
	char		unif_fd_data[]; /* o - data that cannot have
							graphics help	*/
	double		var_fd_data[];	/* o - data that can have
							graphics help	*/
	);

message	add_to_list (
	long		*msg;		/* o - Return Status		*/
	char		name[];		/* i - name of entry		*/
	FD_INFO		matprop_info;	/* i - Includes MAT or PROP _CATEGORY*/
	char		unif_fd_data[]; /* i - those that cannot have
							graphics help	*/
	double		var_fd_data[];	/* i - those that can have
							graphics help	*/
	OM_S_OBJID	grxhlp_objid;	/* i - objid of graphic help	*/
	);

message	delete_from_list (
	long		*msg;		/* o - Return Status		*/
	long		mp_category;	/* i - MAT_CATEGORY ..		*/
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE,...  */
	char		name[];		/* i - name of entry		*/
	);

message	match_name (
	long		*msg;		/* o - Return Status		*/
	long		mp_category;	/* i - MAT_CATEGORY: match materials.. */
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE,...  */
	char		name[];		/* i - name of entry		*/
	char		*found;		/* o - TRUE if name matches	*/
	struct GRid	*mp_grid;	/* o - GRid of matched name	*/
);

message total_mp (
	long		*msg;		/* o - Return Status		*/
	long		mp_category;	/* i - MAT_CATEGORY ..		*/
	char		mp_type;	/* i - ISOMAT_TYPE,BMPROP_TYPE,...  */
	long		*count;		/* o - Count			*/
);

message manage_verif_mp (
	long		*msg;		/* Return status		*/
	long		mode;		/* INIT, MP_USED or REPORT_AND_RESET
						as defined in FEisasdef.h */
	OM_S_OBJID	mp_objid;	/* Mat or prop objid		*/
	long		category;	/* MAT_ or PROP_ as in FEisasdef.h */
	long		analysis_type;	/* i - structural, heat_transfer..
					       as defined in FEisasdef.h */
);

message type_count (
	struct fempstats *mp_stats;	/* i/o Mat/prop statistics	*/
);

end specification FEmpman; 
