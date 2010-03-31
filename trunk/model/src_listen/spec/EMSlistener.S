/* ###################   APOGEE COMPILED   ################## */
class specification EMSlistener (1:0) of GRlistener;

/*
History

    17 December 87  AIC     Added include files to define arguments
                            of the messages declared at this class.

    12/09/87        RC      Moved EMdelete from EMSgradata to EMSlistener.
*/

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef EMcp_include
# include "EMcp.h"
# endif

message EMascopy(IGRlong *EMmsg; struct GRid *new_geom_id;
                 struct EMcp_info *copy_info);

override
    GRnotifylis;

reject
    EMascopy;

end specification EMSlistener;
