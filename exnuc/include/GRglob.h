/*
    H.Bequet                                                       GRglob.h

    ABSTRACT :
    --------

    This file contains the definitions of globals for the group sub-system.

    HISTORY :
    -------

    05/04/1988 : HGB - Creation Date
*/

extern GRint      GR_system             /* The system group index	 */;
extern GRint      GR_cur_gr_ind   	/* The current group index 	 */;
extern GRchar     GR_cur_gr_type	/* The current group type 	 */;
extern GRobjid    GR_cur_gr_id		/* The current group objid	 */;
extern GRspacenum GR_cur_gr_os		/* The current group osnum	 */;
extern GRchar     GR_cur_gr_name []	/* The current group name	 */;
extern GRchar     GR_prev_gr_name []	/* The previous group name	 */;
extern GRchar     GR_G_root [] 		/* The groups directory		 */;
extern GRint      GR_validate           /* The flag for valid operation  */;
