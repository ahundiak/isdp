
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

        CLASS NAME:     HSapp		Application Symbology class.
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

                  Design Shridar

-----
%PD%
--------------------------------------------------------------------
                C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

This class is used to keep the application symbology.

----*/
/*EH*/

class specification HSapp(1:0) of HStable;

#include "igrtypedef.h"


	


override create_entry,add_entry,delete_entry,retrieve_entry,wake_up,sleep,super_construct,debug;

/* 
Allows one to redefine or ( increase the size of all the entries in the table 
*/

message redefine_app_entry(IGRlong msg; char * app_entry);

/*
Returns the size of an entry in the table 
*/

message get_app_entry_size (IGRlong msg; int *size);

message get_app_num_fields (IGRlong msg; int *num_fields);

end specification HSapp;
