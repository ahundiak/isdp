class implementation NMvertex;

#include "OMmacros.h"
#include "godef.h"
#include "grimport.h"
#include  "igrdef.h"
#include  "msdef.h"
#include  "godef.h"
#include  "dpmacros.h"
#include  "gocmacros.h"
#include  "dperr.h"
#include  "dpdef.h"
#include  "igrdp.h"


extern IGRboolean NMvertex_display_and_Rtree;

method GRdisyourself(IGRlong *msg; IGRshort *type; IGRmatrix matrix;
		 enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
		 struct DP_information *sp_info; OM_p_KEY_DESC key)
{
 struct IGRaltdisplay	mydisp;
 unsigned char	myweight = VtxDispWeight;
 IGRlong		sts = OM_S_SUCCESS;

 *msg = EMS_S_Success;
 if(!NMvertex_display_and_Rtree) goto wrapup;

 mydisp.rgb_value = alt_symb ? alt_symb->rgb_value : NULL;
 mydisp.color = alt_symb ? alt_symb->color : NULL;
 mydisp.weight = &myweight;
 mydisp.style = alt_symb ? alt_symb->style : NULL;

 sts = om$send(mode = OM_e_wrt_message, 
       msg = message GRpoint.GRdisyourself(msg, type, matrix, mode, &mydisp, 
       sp_info, key), targetid = my_id);

wrapup:
return(sts);
}

end implementation NMvertex;
