/* ###################   APOGEE COMPILED   ################## */
class implementation EMSplane;

#include "EMS.h"
#include "msdef.h"			/* Has MSSUCC, MSFAIL */
#include "bserr.h"
#include "bsparameters.h"
# include "gocmacros.h" /* GRgetabsg */

method EMplaneDef(IGRlong *EMmsg; IGRshort *mattyp; IGRmatrix mat; 
		  struct IGRplane *def)
{
 struct IGRbsp_surface	*geom;
 extern IGRshort 	MAdetplane();
 IGRint			num_pnts = 3, i;
 IGRlong		sts, rc;
 IGRshort		sts_funk;
 IGRchar		*absptr = NULL;
 IGRdouble		tol;

 BSEXTRACTPAR(&rc, BSTOLCHRDHT, tol);

 GRgetabsg (EMmsg, mattyp, mat, &absptr, i);
 EMerr_hndlr (!(1&*EMmsg) || !absptr, *EMmsg, EMS_E_Fail, wrapup);
 geom = (struct IGRbsp_surface *) absptr; 
 sts_funk = MAdetplane(EMmsg, geom->poles, &num_pnts, &tol, def);
 if(!(1&*EMmsg)) *EMmsg = EMS_E_Fail;

wrapup:
if (absptr) GRabsg_del(absptr);
return(OM_S_SUCCESS);
}

end implementation EMSplane;
