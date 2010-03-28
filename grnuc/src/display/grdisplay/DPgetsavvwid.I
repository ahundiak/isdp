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

#include <bsvalues.h>
#include "grimport.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "dperr.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

/* prototype files */
%safe
#include "DPgetsavvwid.h"
#include "DPgetid.h"
/* #include "DIstring.h" -> include when prototype file is fixed */
%endsafe


#if defined(__STDC__)
IGRint DPgetvwid( IGRlong      *msg,
		  IGRchar      *name,
		  IGRlong      array_size,
		  IGRlong      *total_num,
		  IGRlong      *numid,
		  struct GRid  *found_ids,
		  GRspacenum   osnum )
#else
IGRint DPgetvwid(msg,name,array_size,total_num,numid,found_ids,osnum)

IGRlong *msg;
IGRchar *name;
IGRlong array_size;
IGRlong *total_num;
IGRlong *numid;
struct GRid *found_ids;
GRspacenum osnum;
#endif

{
  IGRint status;
  DIchar pathname[DI_PATH_MAX];  
  GRspacenum *p_osnum;
  GRspacenum sv_osnum;

    status = OM_S_SUCCESS;
    *msg = MSSUCC;

    if (osnum == 0xFFFF)
    {
	p_osnum = NULL;
    }
    else 
    {
	sv_osnum = osnum;
	p_osnum = &sv_osnum;
    }


DIstmcpy(pathname,"views","savedviews","*",0);

DPgetid(msg,name,array_size,total_num,numid,found_ids,p_osnum,pathname);

if ( *msg == DPNOOBJECTS)
{
    *msg = DPVWSNODEF;
    status = OM_S_SUCCESS;
}
    return(status);
}

end implementation IGEsavedvw;

