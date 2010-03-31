class specification ECtpanaly (1:0) of super_cmd;

/*

CLASS NAME
    ECtpanaly

KEYWORD
    Analyze Adjacency between Surfaces

HISTORY
    3/17/94 G. Werner

*/
#include <stdio.h>	/* for FILE	*/
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "igrdp.h"
#include "go.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "OMlimits.h"
#include "dp.h"         /* for lc.h     */
#include "lcdef.h"      /* for lc.h     */
#include "lc.h"
#include "ex.h"

#include "FI.h"

#include "TOtopology.h"
#include "TOstruct1.h"

instance ECtpanaly
{
  struct GRevent    locate_event;
  struct GRevent    accept_event;

  struct GRlc_stack locate_stack;

  struct topology   top;        /* this attribute stores everything,
                                ** which is necessary for topology analyzer
				*/

  struct TOPO_param save_param; /* parameters when form appears, before changes
			         * occured. This block is used to 
                                 * reapply old parameters, when reject is 
				 * pressed
				 */

  Form form1_form;		 /* pointer to the form */
  int  form1_visible;		 /* flag if form1 is created or (in)visible */

  struct GRlc_info  *surface_list;/* allocated list of all selected surfaces*/
  int               n_surface_list; /* number of elements */
  int               alloc_surface_list;/* allocated elements */

  struct GRlc_info  *del_sur_list;/* allocated list of all surfaces to remove*/
  int               n_del_sur_list; /* number of elements */
  int               alloc_del_sur_list;/* allocated elements */

  int               recalculate; /* if true, recalculate top calculation */
 
  int               version;     /* 0 restricted, 1, full */
                                 /* this flag is used to be able 
                                 ** to code the full implementation
                                 ** of the command, while only
                                 ** the preliminary command execution is
                                 ** visible to the user
				 */
  struct GRid      *edge_list;   /* allocated list of all edge displayed
                                    during analysis topology */
  struct edge      **ed_list;    /* allocated list of pointers
                                    for all selectable edges */
  int              n_ed_list;    /* number of elements */
  int              n_edge;       /* number of elements to compare = 2*/
  struct edge      *ed[2];       /* edge pointers for investigation */
  struct GRlc_info edge[2];
};

message form1_do_form(IGRlong *msg; IGRint form_label; IGRint gadget_label;
               IGRdouble value; Form fp);
message setup_form();
message execute_current_action();
message locate_surfaces(int *msg; int *response; char *response_data;
	int typ);
message locate_edges(int *msg; int *response; char *response_data;
	int typ);
message highlight_surfaces(int mode; int also_deleted);



override

    init,   /* setup default values */
    wakeup, /* Justification: Display selected graphics      */
    sleep,  /* Justifacation: Unhighlight selected graphics  */
    execute,/* Justification: Perform topology analysis      */
    delete, /* free all allocated space */
    status_disp;/* allow option form */

end specification ECtpanaly;
