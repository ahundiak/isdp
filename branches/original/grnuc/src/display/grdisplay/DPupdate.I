/*----
%GP% CODE CLASSIFICATION
-----
%HD%
        CLASS NAME:     IGEgragad
        METHOD NAME:    DPupdate

        Abstract:      update a window
-----
%SC%
        GRwn.GRupdate(&msg, &range)
-----
%EN%
        ON ENTRY:

        NAME      DATA TYPE             DESCRIPTION
       ------    -----------            ----------------------------
       *range    struct DPdit_range      area of window to be updated

       *update_all IGRboolean            used by hidden line windows

-----
%EX%
        ON EXIT:

        NAME    DATA TYPE       DESCRIPTION
       ------  -----------    ----------------------------
        *msg    IGRlong         return status
                                  MSSUCC - successfully completed
                                  MSFAIL - unsuccessfully completed
-----
%MD%
        MODULES AND METHODS INVOKED:
        modu:    MAidmx()
                 MAtypemx()
                 MAoptxform()
        methods: GRwn.GRwnerase

-----
%RL%
        RELATIONS REFERENCED:
-----
%NB%
        NOTES:
-----
%CH%
        CHANGE HISTORY

        HT  05/8/86     : Design date.
-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

          This method is used to update a window.  The method
        calculate the range of window , use query plan to locate all
        elements in the window( with a passon message asking graphic
        object to expose itself. 

----*/
/*EH*/


class implementation IGEgragad;

#include "grimport.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"


method DPupdate (IGRlong *msg; struct DPdit_range *range; 
                 IGRboolean *update_all)

{

  IGRint	sts;


       sts = om$send(mode = OM_e_wrt_object,
                     msg = message IGEgragad.DPgen_update(msg,range,
					update_all,GRbd,TRUE ),
                     senderid = my_id,
                     targetid = my_id);


   return(sts);

 }

end implementation IGEgragad;
