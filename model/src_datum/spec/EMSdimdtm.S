/* ###################   APOGEE COMPILED   ################## */
class specification EMSdimdtm (2:0) of dim_src,dim_plan,NDnodein;

#include "dimdef.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimplcmacros.h"
#include "dimplan.h"
#include "diminfo.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "parametric.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasprops.h"
#include "EMSmsgdef.h"
#include "EMSmsgnumdef.h"

message EMdelete_dim_support (IGRlong *EMmsg; struct GRmd_env *md_env);
message EMautodim ( IGRlong             * msg;
                    struct GRmd_env     * mod_env );

override give_plane, 
	 NDmake_source,
         EMautodim,
         NDupdate,
         NDgive_structure,
         NDdisplay,
         ASreturn_go,
         ACbecome_macro,
         give_axis, 
         DMgive_structure;

end specification EMSdimdtm;
