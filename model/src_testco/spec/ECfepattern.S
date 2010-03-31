class specification ECfepattern(2:4) of super_cmd;
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"

#include "igetypedef.h"
#include "igrtypedef.h"

#include "exdef.h"
#include "ex.h"
#include "exmacros.h"

#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"

#include "godef.h"
#include "go.h"

#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

#include "parametric.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "ma.h"
#include "bserr.h"
#include "codef.h"
#include "FI.h"
#include "FEI.h"
#include "GRascopy.h"
#include "EMpattern.h"


instance  ECfepattern
{
	IGRint locate_rc;
	IGRint ref_props;	/* Reference plane properties. */
	struct GRlc_locate attr;
	IGRint msgkey;
	IGRint form_displayed;
	IGRchar locate_prompt[MAX_PROMPT_SIZE];
	IGRchar acc_prompt[MAX_PROMPT_SIZE];
	IGRchar reloc_prompt[MAX_PROMPT_SIZE];
	
	struct GRevent event1;
	struct GRevent event2;
	struct GRevent locate_event;
	
	IGRint eventmask1,eventmask2;
	IGRint display_flag;
	struct GRmd_env md_env;
	struct GRid pattern_id,plane_id;
	IGRint count;
	struct GRid list[MAX_FEATURE_PARENTS];
	Form  form;
	IGRdouble ref_point[3],center[3];
	IGRint valid_feature;
	IGRint fea_props,fea_count;
	struct GRid feature[10];
	IGRmatrix plane;
	struct GRid next_grid;
	struct GRas_pattern pattern;
	struct GRlc_stack stack;
};

message locate_element(
	IGRint *response;
	IGRchar *response_data;
	IGRint putq_acc;
	IGRint locate_key;
	IGRint acc_key;
	IGRint reloc_key);

message display_next( IGRlong *msg);

message select_axis( IGRlong *msg;
                   IGRint *response;
                   IGRchar *response_data);

message show_axis( IGRlong *msg;
                   struct GRevent *event);

message construct_pattern(IGRlong *msg);

message set_ref_props(IGRlong *msg; IGRint inq0_set1; IGRint *ref_props);

message notify_form(
     int     f_label;
     int     g_label;
     double  value;  
     Form    fp);

override init,wakeup,super_cmd.sleep,execute;
override delete;

end specification ECfepattern;
