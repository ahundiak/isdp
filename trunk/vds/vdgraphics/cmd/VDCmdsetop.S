class specification VDCmdsetop (1:0) of VDS_LOCATE;



#include "FI.h"
#include "FEI.h"


instance VDCmdsetop
{
	Form		my_form;
        long		elem_set_num;
        long		del_set_num;
        char		**elem_set_name;
        char		**del_set_name;
        char		set_a_name[32],
			set_b_name[32],
			set_c_name[32];
        struct GRid	set_a_grid,
			set_b_grid,
			set_c_grid;
        short		operator; /* == 1, difference,
				     == 2, union,
				     == 3, intersection */
	struct GRid	gs_id;
	IGRboolean      delete_flag;
        long		totsets;
	int		setFlag ;
	variable struct GRobj_env  sets[1];
};


override init;

message VDInitForm ( long * sts );

message VDdisplay_form ( long * sts );

message VDsetup_data ( long * sts );

message VDshow_ref_sets ( long * sts );

message VDcheck_set_in_ref_file ( long *sts; IGRchar *selected_set );

message VDfree_data ( long * sts );

override delete;

message VDset_operations ( long * sts );

override form_notification;

message VDput_setqueue ( long *sts; IGRchar *set_chosen );

message VDput_intoq ( long * sts );

end specification VDCmdsetop;
