class specification ECPlPrt (1:0) of COpara;

#include "igetypedef.h"
#include "igrtypedef.h"
#include <gr.h>
#include <grdpbdef.h>
#include "assemdef.h"
#include "assem.h"

instance ECPlPrt
{
	char *fp1;                   /* Main form, for part selection */
	char *fp2;		     /* Subform, for placement options */
	int  active_form;	     /* currently active form */
	int  form_displayed;         /* is form displayed ? */

	char selected_part[128];     /* Filename of the part selected */
	int  num_inst_attrs;         /* Number of instance attributes */
        EMattr *inst_attrs;          /* instance attributes */

	int	num_sv_ids;	     /* Number of saved views in the part */
	char	saved_views[20][20]; /* names of saved views */
	int     change_itemno;       /* indicates if itemno can be changed */
        char    *itemno;             /* itemno generated */
};


message do_form1( IGRlong *msg; int form_label; int gadget_label; double value);

message do_form2( IGRlong *msg; int form_label; int gadget_label; double value);

message get_default_attrs( IGRlong *rc );

message ECplcmnt_opts( IGRlong *rc );


override init, status_disp, sleep, wakeup, execute, delete;

end specification ECPlPrt;
