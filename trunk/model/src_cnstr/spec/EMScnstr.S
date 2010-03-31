/*
  DESCRIPTION

    This is an abstract class that is the super class for all geometric
    constraints - mid-plane, offset plane, line as edge, etc. - and sets the 
    protocols for the same. This excludes 2D variational geometry constraints.

  HISTORY
    pp  :  08/10/91  :  Subclassing from NDnodein
    jhw :  07/26/91  :  Added override for GRgetobjinfo.
    jhw :  07/25/91  :  Removed EMis_externally_constrained declaration.
    DLB :  04/12/91  :  Added EMis_externally_constrained declaration.
    SS  :  03/14/91  :  Creation
*/

class specification EMScnstr (2:0) of NDnodein,EMScomposite;

#include "DIdef.h"
#include "DItypedef.h"
#include "exdef.h"
#include "exmacros.h"
#include "expression.h"
#include "asbox.h"
#include "nddef.h"
#include "parametric.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dimdef.h"
#include "dim.h"
#include "dimsrc.h"
#include "dimplan.h"
#include "diminfo.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasprops.h"
#include "EMSasopts.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "emsdattyp.h"

instance EMScnstr
  {
  IGRushort cnstr_props;
  };

message EMinit (IGRlong *msg; IGRushort opts;
                 struct GRmd_env *md_env;
                 IGRint num_parents;
                 struct GRid *parents; 
                 IGRushort cnstr_props; IGRchar *moreinfo;
                 IGRint num_children;
                 struct GRid *children);
                 
message EMvalidate (IGRlong *msg; IGRushort opts;
                    struct GRmd_env *md_env;
                    IGRboolean *is_valid_cnstr;
                    IGRint *num_conflict_cnstr; struct GRid conflict_cnstr[3]);

message EMgetgeomlocus (IGRlong *msg; IGRushort opts;
                        IGRshort *mattyp; IGRmatrix mat;
                        struct EMSgeomdata *geomlocus);

message EMgetprops (IGRlong *msg; IGRushort *props);

message EMchgprops (IGRlong *msg; IGRshort action; IGRushort props);

override 
  GRdisplay,
  GRlocate_owner,
  GRgetobjinfo,
  debug;

reject
  EMgetgeomlocus, EMinit;

override
/*
 * Delete myself.
 */
 NDmove_to_root, 
/*
 * Return that I am only valid for drop macro.
 */
 ACbecome_macro,
/*
 * Connect the dimensional handle to the copied entity.
 */
  NDconnect_graph,
/*
 * Copy myself with geometric handle if it exists.
 */
  ACcopy_to_Groot,
/*
 * Return itself as the graphic object.
 */
  ASreturn_go,
/*
 * Override to display the geometric handle.
 */
  NDdisplay;

end specification EMScnstr;
