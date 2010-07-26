
/*
	COdm:	Abstract class serving as the parent
		class for all dimensioning command
		objects. Defines the basic set of
		messages common to all the dimensioning
		commands.
*/

class specification COdim (2:0) of super_cmd;

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

#include "FI.h"
#include "FEI.h"

#include "dimdef.h"
#include "dim.h"
#include "dimglobal.h"
#include "dimerror.h"
#include "dimplan.h"
#include "dimext.h"
#include "dimacc.h"
#include "dimdload.h"
#include "dimmacros.h"
#include "diminfo.h"
#include "dimcomplex.h"
#include "dm_status.h"

#include "dimlinear.h"
#include "dimcoord.h"
#include "dimangular.h"
#include "dimradial.h"
#include "dimcenline.h"
#include "dimlocate.h"
#include "dimsrc.h"
#include "dimmod.h"
#include "dimgraph.h"
#include "dimco.h"
#include "DMmsg.h"
#include "DMcmd.h"
#include "codef.h"
#include "gotextdef.h"
#include "gotext.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "fontdef.h"
#include "font.h"
#include "dimannot.h"
#include "dimanform.h"
#include "dimweld.h"
#include "dimdyn.h"

instance COdim
{
	IGRint msgnumb;				/* Message Key */

	IGRint  locate_rc;			/* Return code from locate */
	IGRint	loc_key, acc_key, rel_key;	/* locate, accpt and rel keys */
	IGRchar locate_prompt[MAX_PROMPT_SIZE];	/* locate prompt */
	IGRchar acc_prompt[MAX_PROMPT_SIZE];	/* accept prompt */
	IGRchar relocate_prompt[MAX_PROMPT_SIZE];/* relocate prompt */

	struct  GRevent event1;			/* Locate Event */
	struct  GRevent event2;			/* Accept Event */

	IGRint  mask1, mask2;
	IGRint  display_flag;
	struct  GRlc_locate attr;		/* Locae Attributes */
	struct  DMact_info  act_parms;		/* Action handler params */
	struct  GRlc_dynamics lc_dyn;		/* Locate dynamics info */

	struct  GRmd_env md_env;
	struct  GRmd_env dyn_env;
};

message locate_parent(
	IGRint *response;
	IGRchar *response_data;
	struct GRevent *loc_event;
	IGRboolean putque_acc;
	IGRint locate_key;
	IGRint acc_key;
	IGRint relocate_key);

message load_obj_info(
	struct GRevent *loc_event;
	struct DMobj_info *obj_info);

message getevent(
	IGRint msgkey;
	IGRint *response;
	IGRchar *response_data;
	struct GRevent *event);

message LC_selection(
	IGRint *msg;
	struct GRlc_info *lc_info);

message LC_preproc(
	IGRint *msg;
	struct GRlc_info *lc_info);

message LC_postproc();

message LC_dynamics(
	IGRint *msg;
	struct GRid *obj;
	struct GRevent *event);

message create_form(
	int form_label;
	char *form_name;
	Form *form);

message notify_form(
	int form_label;
	int label;
	double value;
	Form form);

override init, wakeup, super_cmd.sleep;

reject LC_selection, LC_postproc, LC_preproc, LC_dynamics;
reject notify_form;

end specification COdim;
