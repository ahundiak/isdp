/*
  DESCRIPTION

    This is an abstract class that is the super class for all "intelligent"
    parameters - points, lines, planes, values, etc. - and sets the 
    protocols for the same. This excludes 2D variational geometry intelligent
    parameters.

  HISTORY
    pp  :  08/08/91  :  Deleted NDmake_source
    DLB :  04/20/91  :  Added and rejected EMparam_xform.
    DLB :  04/19/91  :  Added EMis_externally_constrained and EMparam_delete
    SS  :  03/14/91  :  Creation
*/

class specification EMSparameter (2:0) of NDnodein;

#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "madef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "emsdef.h"

message EMis_externally_constrained(IGRlong *EMmsg;
                                    IGRboolean *is_externally_constrained);

message EMparam_delete(IGRlong *EMmsg;
                       struct GRmd_env *md_env);

message EMparam_xform(IGRlong *EMmsg; 
                      struct GRmd_env *md_env;
                      IGRshort *matrix_type;
                      IGRmatrix matrix;
                      GRobjid *newobjid);

message EMgetdimgeom (IGRlong *msg; IGRushort opts;
                      IGRshort *mattyp; IGRmatrix mat;
                      struct IGRplane *dim_plane;
                      IGRdouble *dim_plane_xaxis;
                      struct EMSgeomdata *dimgeomdata;
                      IGRint *dim_type);

message EMpasschild (IGRlong *msg; IGRushort opts;
                     OM_p_MESSAGE messg);

reject EMparam_xform;

end specification EMSparameter;
