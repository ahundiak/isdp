/* ###################   APOGEE COMPILED   ################## */
class specification EMSdimoff (2:0) of dim_src,dim_plan,NDnodein;

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

instance EMSdimoff
{
 unsigned int offset_control;
};



message EMofcvdim ( IGRlong             *EMmsg;
                   unsigned int        octrl;
                   struct GRmd_env     *md_env);
override give_plane,
         NDupdate,
         give_axis,
         ASreturn_go,
         DMgive_structure;


end specification EMSdimoff;
