/* ###################   APOGEE COMPILED   ################## */
class specification EMSmassprop (1:1) of EMScomposite, GRlistener;

/* igr.h replacement */


# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */

#include "OMerrordef.h" /* OM message codes */
#include <math.h>
#include "emsmacros_c.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMSerrnumdef.h"
#include "emsmass.h"

#define MAX_CHAR_LEN 80

/*

 DESCRIPTION
      This is a mass property abstract class.

 HISTORY
           gupta     07/06/89     Creation Date
*/

instance EMSmassprop
{
  channel {(many_to_one) GRnotify.notification;} to_object;

  IGRint      operation_type;
  IGRboolean  mp_valid;
  IGRdouble   mass_props[NUMB_PROPS];
  IGRint      axes_orient;
  IGRpoint    refer_pnt;
  IGRdouble   glo_loc[9];
  IGRdouble   density;
  IGRdouble   my_geometry[9];
  IGRdouble   p_axes[6];
};


message EMmprecalc (IGRlong          *EMmsg);

message EMretn_mass_prop (IGRlong          *EMmsg;
                          IGRboolean       *validity;
                          IGRdouble        *mass_prop);

message EMload_mass_prop (IGRlong          *EMmsg;
                          IGRboolean       validity;
                          IGRdouble        *mass_prop);

message EMset_density (IGRlong *EMmsg;
                       IGRdouble density);

message EMget_density (IGRlong *EMmsg;
                       IGRdouble *density);

message EMget_orient (IGRlong *EMmsg;
                      IGRlong *orient);

message EMget_objectid (IGRlong     *EMmsg;
                        struct GRid *mp_objectid);

message EMinitialize (IGRlong *EMmsg);

message EMset_type (IGRlong *EMmsg;
                    IGRint  operation_type);

message EMreadprop (IGRlong                *EMmsg;
                    struct GRmd_env        *my_env;
                    IGRint                 *option;
                    IGRint                 *prop_type;
                    IGRdouble              *prop;
                    IGRdouble              *ref_pnt;
                    IGRdouble              *glo_loc;
                    IGRdouble              *p_axes;
                    IGRdouble              *density);

message EMintcopy (IGRlong                 *EMmsg;
                   struct GRmd_env         *obj_mdenv;
                   struct GRmd_env         *new_mdenv;
                   GRobjid                 *newobjid;
                   struct EMcp_info        *copy_info);

message EMintxform (IGRlong         *EMmsg;
                    struct GRmd_env *md_env;
                    IGRshort        *matrix_type;
                    IGRmatrix       matrix;
                    GRobjid         *newobjid);

message EMedit_mass_prop (IGRlong *EMmsg;
                          struct GRmd_env *my_env;
                          IGRboolean validity;
                          IGRdouble *mass_props;
                          IGRdouble density;
                          IGRpoint refer_point;
                          IGRdouble *glo_loc;
                          IGRlong axes_orient);

message EMupdate_props (IGRlong                 *EMmsg;
                        IGRdouble               new_density);

message EMupdate_orient (IGRlong                *EMmsg;
                         IGRdouble              *new_orient);

message EMmpdisplay (IGRlong *EMmsg;
                     struct GRmd_env *my_env;
                     enum GRdpmode *display_mode);


message EMmpdelete (IGRlong *EMmsg;
                    struct GRmd_env *my_env);

message EMstore_geometry (IGRlong *EMmsg;
                          IGRdouble *mp_geom);

message EMget_geometry (IGRlong *EMmsg;
                        IGRdouble *mp_geom);


message EMget_gloloc (IGRlong *EMmsg;
                      IGRdouble *glo_loc);

message EMrefxform (IGRlong         *EMmsg;
                    struct GRmd_env *md_env;
                    IGRshort        *matrix_type;
                    IGRmatrix       matrix;
                    IGRdouble       *refer_point;
                    IGRdouble       *prop;
                    IGRdouble       *in_glo_loc;
                    IGRboolean      *validity);

message EMload_prin_axes (IGRlong *EMmsg;
                          IGRdouble *mass_props);

override  
 GRnotifylis,
 GRgetobjinfo,
 GRcopy,
 GRconstruct,
 GRxform;

end specification EMSmassprop;
