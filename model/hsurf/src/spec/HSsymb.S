
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/

 




/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     HSsymb		HSsymbology class 
	SUBCLASS OF:    HStable		table system

        Abstract:  class that keeps display symbologies

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
                  Design            Shridar              

-----
%PD%
--------------------------------------------------------------------
                C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

This class is used to keep the shading symbology.  It actually
contains three  indices; 1 for regular symbology and one for application 
symbology and one for Color, Style and Weight. The regular symbology index 
is an index into a HStable class .  It is connected on the
notification channel at slot 0.  The application will have an
HStable object that controls the application symbology.  It
will also be connect on the notification channel of HSsymb and will 
be sent messages when operations are performed on the HSsymb class.

----*/
/*EH*/

class specification HSsymb(1:0) of HStable;

#include "igrtypedef.h"


	


override create_entry,add_entry,delete_entry,retrieve_entry,wake_up,sleep,super_construct;

end specification HSsymb;
