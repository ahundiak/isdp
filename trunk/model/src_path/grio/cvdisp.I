class implementation GRcurve;

#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/cvdisp.h"

%safe
static enum GRdpmode GetGRdpmodeFromPWdisplaymode
(
  enum PWdisplaymode pwmode
);
%endsafe
/*
  DESCRIPTION
  
  The following function can be used to display an IGRbsp_curve structure.
  The display mode is specified. If the drawing is to occur in background 
  (PWbackground_draw) the active color, weight and line-styles are used. 
  If the drawing is called for with highlight, the highlight plane is used.


  HISTORY

  SS  :  03/07/96  :  Creation
*/

PWresult pwDisplayCv
(
  struct IGRbsp_curve *cv,
  enum  PWdisplaymode dpmode
)
{
  PWresult result=PW_K_Success;
  long msg;
  struct DPele_header dphdr;
  struct IGResbc esbc;
  struct IGRdisplay dispattr;
  struct GRmd_env md_env;
  enum GRdpmode grmode;
 
  esbc.is_polydis = FALSE;
  esbc.is_curvedis = TRUE;

  grmode =  GetGRdpmodeFromPWdisplaymode(dpmode);
  gr$get_active_display (buffer = &dispattr);

  gr$get_module_env (buffer = &md_env);

  dp$build_dis_buffer (buffer = &dphdr, type = IGRBC,
   display_att = &dispattr, ele_spec_att = &esbc, geometry = cv);

  dp$display (msg = &msg, osnum = md_env.md_id.osnum, 
   objid = md_env.md_id.objid, mode = grmode, num_elem = 1,
   buffer = &dphdr);
  OnErrorState (IsError (msg), result, SetError (PW_K_Pathway, 
   PW_K_Error), wrapup);

wrapup:
  return (result);
}

static enum GRdpmode GetGRdpmodeFromPWdisplaymode
(
  enum PWdisplaymode pwmode
)
{
    switch(pwmode)
    {
	case  PWbackground_draw :
              return GRbd;
	case  PWbackground_erase :
              return GRbe;
        case  PWhighlight_draw   :
              return GRhd;
        case  PWhighlight_erase  :
              return GRhe;
        case  PWunknown :
              return -1;
    }
}

end implementation GRcurve;
