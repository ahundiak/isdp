
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

        CLASS NAME:     HSviewdyn       shaded view dynamics
        SUBCLASS OF:    GRviewdyn       wireframe view dynamics

        Abstract:  defines the hline view dynamics class

-----
%CD%

        CHANNELS DECLARED:

        module
                      
                 
                                         
-----
%MD%

        MESSAGES DECLARED:



-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY

        AET    11/15/88  : Design date.

-----
%PD%
--------------------------------------------------------------------
                C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

----*/

class specification HSviewdyn (1:0) of GRviewdyn, HSgragad;

	override DPupd_app_init,DPgen_update, GRviewdyn_set_up, GRviewdyn_reset,
                 DPdisplay_for_dlist, DPsetup_for_dlist_feedback;
	
end specification HSviewdyn;

