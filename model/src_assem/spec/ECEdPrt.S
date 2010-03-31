class specification ECEdPrt (1:0) of COpara;

#include "igetypedef.h"
#include "igrtypedef.h"
#include <gr.h>
#include <grdpbdef.h>
#include "assemdef.h"
#include "assem.h"

instance ECEdPrt
{
	char *fp;                   /* part attributes form */
	int  form_displayed;        /* is form displayed ? */

	struct GRid partid;	    /* id of the active part */
	int    type;		    /* type of the active part */
	int    props;		    /* display properties */

	int    num_attrs;      	    /* Number of attributes */
        EMattr *attrs; 		    /* attributes */
};


message do_form( IGRlong *msg; int form_label; int gadget_label; double value);

message form_update_attributes( IGRlong *rc );

message form_update_props( IGRlong *rc );

override init, sleep, wakeup, execute, delete;

end specification ECEdPrt;
