/* 
 This file contains the options used in the process of cleaning up 
 unwanted topology after a region modification.

History
	SM	09-Feb-88		Creation Date.
        NP      12-Dec-93               Added option EMtplydel_DelInvalidLoops
*/


#define EMtplydel_DeleteElems	0x0001	/* Delete the expendable elements
					   like loop/surface */
#define EMtplydel_NoCommonEdge	0x0002  /* Cleanup process should not be
					   propagated across the common
					   edge channel into the adjacent
					   surface.
					*/
#define EMtplydel_MaintainSplit 0x0004  /* Maintain the EMLP_SPLIT property
					   of a loop even after its
					   removal. This property can later
					   be looked at to deduce partial
					   use of a loop in the final
					   result. The callet takes the 
					   responsibilty of turning the
					   property bit off.
					*/
#define EMtplydel_DelInvalidLoops 0x0008/* Delete any loops that are determined
                                           to be invalid by the "EMlpcleanup"
                                           method. Unlike the options above,
                                           this option is currently ONLY used
					   in "EMlpcleanup" and NOT inside the
                                           "EMtplydelete" method. Instead of
                                           erroring out in "EMlpcleanup" when
                                           an invalid loop is discovered, the
                                           offending loop is deleted.
                                         */
