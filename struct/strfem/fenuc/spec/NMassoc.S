/*
Common hook for non manifold associativity.
The subclassing off GRlistener is a kludge to trap GRnotifylis and get into
the ND batch system.
*/
class specification NMassoc (1:0) of EMSassoc;

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
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsbool.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "nmdef.h"
#include "nmchandef.h"
#include "OMminimum.h"
#include "godef.h"
#include "gocmacros.h"
#include "OMerrordef.h"
#include "EMSmsgdef.h"
#include "EMSasopts.h"

/* The EMSassoc override does some parameter related stuff, specific to
it.
*/
from NDnode inherit NDdelete, NDmove_to_root;

override
	EMinit_associative;     /* EMtransform_to_assoc to avoid source*/


message NMget_parent_info(IGRlong *EMmsg; struct EMSobject_info **parents;
        IGRint inbufsize, *count);
			
end specification NMassoc;
