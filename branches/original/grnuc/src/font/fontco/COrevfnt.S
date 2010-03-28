/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP%
----
%HD%
    CLASS NAME:  COrevfont
    SUBCLASS OF: super_cmd

    Abstract: review fonts

----
%CD%
    CHANNELS DECLARED:

----
%MD%

    MESSAGES DECLARED:

----
%NB%

 NOTES:

----
%CH%
 CHANGE HISTORY:

           DEK 08/04/88 : Design Date.
           DEK 08/04/88 : Creation Date.
           msm 05/09/91 : changed to c-based form.
           WBC 10/24/91 : Removed override of wakeup and added overrides
                          for init and delete.
----
%PD%
----------------------------------------------------------------------
                 C L A S S  D E S C R I P T I O N
----------------------------------------------------------------------
     This is an abstract class for the review fonts command object.
---- */
/*EH*/

class specification COrevfnt (1:0) of super_cmd;

#include "fontdef.h"
#include "ex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "FI.h"

instance COrevfnt
{
   struct GRid       fontmgr;                /* objid/osnum of fontmgr       */
   IGRshort          num_entries;            /* number defined font entries  */
   IGRshort          entries[MAXFONT];       /* list of defined font entries */
   IGRint            sample;                 /* true if sample on form       */
   variable struct EXlstfnt font_struct[];   /* font info                    */
   Form              form1;                  /* form pointer                 */
   IGRint            row;                    /* selected row number          */

 };
override  init, execute, sleep, delete;

message send_font_info (IGRlong *msg);

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);

end specification COrevfnt;
