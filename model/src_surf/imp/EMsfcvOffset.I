/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
#include "godef.h"
#include "gocmacros.h"
#include "emsdef.h"
#include "msdef.h"
#include "grerr.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "bserr.h"
#include "bstypes.h"
#include "EMSerrordef.h"
#include "emserr.h"


method EMsfcvoffset(  IGRlong               *EMmsg;
		      IGRshort              *mattype;
		      IGRmatrix             matrix;
                      struct GRvg_construct *const_list;
                      struct GRid           *cur_info;
                      IGRboolean            right_side;
                      IGRdouble             distance1;
                      IGRdouble             distance2;
                      IGRboolean            linear;
                      IGRboolean            uniform;
                      struct IGRbsp_curve   *lawcv;
                      struct GRid           *off_crv_id )
                      

 {
 
  IGRlong                      i, sts;
  BSrc                         rc;
  struct IGRbsp_curve          *cur_geom = NULL, *res_crv = NULL;
  struct IGRbsp_surface        *sur_geom;
  IGRchar                      *cur_ptr = NULL, *sur_ptr = NULL;
  extern OMuword               OPP_GRbcsubbc_class_id; 

  extern IGRlong               EMgetvggeom();
  extern IGRboolean            BSfreecv();
  extern void                  BSoffcvfrsf();
  IGRint                       data_type;

  sts    = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  EMgetvggeom( EMmsg,
               mattype,
               matrix,
               cur_info,
               &cur_ptr,
               &data_type);   
              
  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  cur_geom = (struct IGRbsp_curve *) cur_ptr;

  GRgetabsg(EMmsg,
            mattype,
            matrix,
            &sur_ptr,
            i);

  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

  sur_geom = (struct IGRbsp_surface *) sur_ptr;

  BSoffcvfrsf(cur_geom, sur_geom, right_side, uniform, distance1, distance2, 
              linear, lawcv, 0.0, 1.0, &res_crv, &rc);

  if (rc != BSSUCC)

  fprintf(stderr,"Math has failed");

  EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_OMerror, wrapup);

  const_list->newflag = FALSE;
  const_list->geometry = (IGRchar *) res_crv;
  off_crv_id->osnum = const_list->env_info->md_id.osnum;

  sts = om$construct( classid = OPP_GRbcsubbc_class_id,
                      msg     = message GRvg.GRconstruct(const_list),
                      p_objid = &off_crv_id->objid,
                      osnum   = off_crv_id->osnum );

  EMerr_hndlr(!(1&sts), *EMmsg, EMS_E_OMerror, wrapup);

 wrapup:

  if(cur_geom) 
    {
 /* fix for mlk */
    om$dealloc(ptr = cur_geom);
    cur_geom = NULL;
    }
  if(res_crv) BSfreecv (&rc, res_crv);
 
 return(sts);

}

end implementation EMSsubbs; 
