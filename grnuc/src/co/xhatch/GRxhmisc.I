/* #######################    APOGEE COMPILED   ######################## */
class implementation  GRcoxhatch;

#include "coimport.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "igrmacros.h"
#include "comiscmac.h"
#include "msdef.h"
#include "dp.h"
#include "maerr.h"
#include "exdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "grsymmacros.h"

method GRdisyourself(IGRlong *msg; 
		     IGRshort *mx_type; 
		     IGRmatrix matrix; 
		     enum GRdpmode *mode;
		     struct IGRaltdisplay *alt_symb; 
		     struct DP_information *sp_info;
		     OM_p_KEY_DESC range_key)
{
  IGRlong                      status;   
  OM_S_CHANSELECT              chansel;
  
  status = om$make_chanselect(channame     = "GRcmpowner.to_components",
			      p_chanselect = &chansel );

  status = om$send(msg = OPPmargs,
		   p_chanselect = &chansel);

  return(status);
}


method GRdisplay(IGRlong *msg; 
		  IGRshort *type; 
		  IGRmatrix matrix;
		  enum GRdpmode *mode; 
		  struct GRid *display_info)
{
  IGRlong                      status;   
  OM_S_CHANSELECT              chansel;
  
  status = om$make_chanselect(channame     = "GRcmpowner.to_components",
			      p_chanselect = &chansel );

  status = om$send(msg = OPPmargs,
		   p_chanselect = &chansel);

  return(status);
}

end implementation GRcoxhatch;
