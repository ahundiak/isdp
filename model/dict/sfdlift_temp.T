#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"

   struct GRid                          /* object identifier structure  */
   {
        GRspacenum osnum;               /* space number of object       */
        GRobjid    objid;               /* object id of object          */
   };

struct EMSint_info {
        struct  GRid            sf_GRid;
        unsigned char           lift_operation;
        IGRvector               draft_vec;
        IGRdouble               mx_exlp_dangle;
        IGRboolean              uniform_surface;
        IGRboolean              no_fillets;
        IGRint                  num_ed_infos;
        IGRint                  num_lps;
        struct  EMSint_lp_info  *lps_info;
};

struct EMSint_lp_info {
        struct  GRid            lp_GRid;
        IGRboolean              is_uniform;
        IGRdouble               draft_angle;
        IGRboolean              fillet;
        IGRint                  num_eds;
        struct  EMSint_ed_info  *ed_info;
};


struct EMSint_ed_info {
        struct  GRid            ed_GRid;
        unsigned short          ed_sf_type;
        unsigned char           ed_cv_type;
        unsigned short          ed_constraint_type;
        IGRdouble               draft_angle;
        IGRint                  offset_code;
};

#template  struct  EMSint_info		EMSinfo_T

#template  struct  EMSint_lp_info	EMSlp_info_T

#template  struct  EMSint_ed_info	EMSed_info_T


