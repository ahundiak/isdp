/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPgetvwid

          Abstract:   This routine will return saved view id in the array
                      if the name matches.
----
%SC%

     VALUE = DPgetvwid(msg,name,numid,smid )
----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      name             *IGRchar                  name to be matched
----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------
                        GRid                   array of saved view id's 
----
%MD%
 
     MODULES INVOKED:  

----
%NB%

      NOTES:

----
%CH%

       MAS   08/13/86   : Creation date

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------

This routine will match the input name with the view name in instance
data. If it matches, then the view objid is put in the vwid array and 1
is added to the numid. The name may be of the form  win[a-z]e, win*, win?ow 
or win[abcd].

win[a-z]e will match name starts with "win" and any character between 
a and z then ends with e.

win* will match any name starts with "win"

win?ow will match any name starts with "win" then any single
character and then "ow"
 
win[abcd] will match any name starts with "win" and any one
character that appeared within the brackets.

---*/
/*EH*/

class implementation IGEsavedvw;


#include "grimport.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

/* prototype files */
%safe
#include "DPgetsavvwid.h"
#include "DPtotnumvw.h"
%endsafe

/*
#include "GRdef.h"
#include "GRtypedef.h"
#include "GRprims.h"
*/

#define DEBUG 1

IGRint DPtotal_num_svw(msg,total_num,osnum)

IGRlong *msg;
IGRlong *total_num;
GRspacenum *osnum;

{
    IGRint status;
    GRobjid mod_id;
    GRspacenum sv_osnum;
    IGRlong numid;

    *msg = MSSUCC;

	if (osnum == NULL)
	{
	    ex$get_cur_mod( id=&mod_id, osnum=&sv_osnum);
	}
	else
	{
	    sv_osnum = *osnum;
	}

status = DPgetvwid(msg,"*",0,total_num,&numid,NULL,sv_osnum);

return(status);
}

end implementation IGEsavedvw;
