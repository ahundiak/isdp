/*
  DESCRIPTION

    This is the abstract class for all variables in the system. These
    could be points or double-values.
*/

class specification SKvariable (2:0) of Root;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "OMindex.h"
#include "OMerrordef.h"
#include "OMlimits.h"
#include "igrdef.h"
#include "madef.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "lcdef.h"
#include "lc.h"
#include "dpstruct.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "SKdef.h"
#include "SKinc.h"
#include "SKgraphdef.h"
#include "SKgraph.h"

instance SKvariable
  {
  IGRushort props;
  channel {(many_to_many, rel_ordered)} to_constraints;
  channel {(many_to_many, rel_ordered)} to_geometries;
  channel {(many_to_one)} to_mgr;
  };

message SKgetvar (IGRlong *msg; IGRushort options;
                  IGRshort *matrix_type; IGRmatrix matrix;
                  IGRdouble *var);



#ifndef BASE_EMS
message SKgetmgr (IGRlong *msg; GRobjid *sk_mgr_id);

message SKputvar (IGRlong *msg; IGRushort opts;
                  IGRshort *mattyp; IGRdouble *matrix;
                  IGRdouble *var);

/*
  ABSTRACT

    These messages are used to put/obtain the current value of the variable.
    The value (eg: point) can be put/obtained wrt a transformation matrix.

    o Specifying NULL pointer for the matrix_type and/or matrix will cause the
      value to be stored/returned untransformed.

    o If the matrix passed in just the module-transformation matrix (wherein,
      options is NOT set to SK_OPT_FULL_TRANSFORM), the variable goes up to
      it's manager object and obtains the transformation to/from it's xy-space
      from/to the xyz-space and then combines with the module-transform being
      passed in. The resultant matrix is used for the store/return.

    o The complete transform to/from the local xy-space from/to the
      module-space amy be passed in (wherein, options IS set to
      SK_OPT_FULL_TRANSFORM). This matrix is used as is.
*/

message SKgetvarlist (IGRlong *msg; IGRushort opts; 
                      struct SKsolvevars **varlist);

message SKintcopy (IGRlong *msg; IGRushort options;
                   struct GRmd_env *obj_env, *new_mdenv;
                   GRobjid *newobjid; struct EMcp_info *copy_info);

message SKintdelete (IGRlong *msg; IGRushort options;
                     struct GRmd_env *md_env);

message SKgetprops (IGRlong *msg; IGRushort *props);

message SKchgprops (IGRlong *msg; IGRshort action; IGRushort props);


message SKinit (IGRlong *msg; IGRushort opts;
                IGRushort varprops;
                IGRdouble *varvalue;
                GRobjid mgrobjid;
                IGRchar *moreinfo); 

message SKswap (IGRlong *msg; IGRushort opts; GRobjid new_vgvar);
                     
reject
   SKputvar, SKgetvarlist, SKinit;

#endif
reject
   SKgetvar;

end specification SKvariable;
