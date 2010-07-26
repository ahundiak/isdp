/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     DPcolor     
        SUBCLASS OF:    global_class

        Abstract:  defines the color table class

-----
%CD%

        CHANNELS DECLARED:


                      
                 
                                         
-----
%MD%

        MESSAGES DECLARED:



-----
%NB%
 
        NOTES:

-----
%CH%

        CHANGE HISTORY

        AET    05/18/87  : Design date.

-----
%PD%
--------------------------------------------------------------------
                C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

class specification IGEcolsup (1:0) of Root;

#include "igrtypedef.h"
#include "igetypedef.h"

instance IGEcolsup
{
   channel { (many_to_one) IGEcolor2; } listener;
};

   /* MESSAGES */
   message color_table_changed(GRobjid color_objid; GRspacenum color_osnum);
	
reject	color_table_changed;
	
end specification IGEcolsup;

