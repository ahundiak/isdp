/*
This abstract class is intended to serve as a common hook for all associative, 
non manifold nodes.

History
	SM	15-Apr-91	Genesis.
*/

class specification NMnonmani (1:0) of NMassoctrans, GRflxown;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "igrdp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"

#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasnuc.h"
#include "EMSasnucdef.h"
#include "EMSasopts.h"
#include "OMmacros.h"
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
#include "nm.h"

#include "nddef.h"
#include "ndmacros.h"


/* Reject the EMSassoc instance data.
*/
override EMSassoc;
override
	EMput_info, EMget_info;


override 
	 NDconnect,     /* Establish flexible ownership */
	 NDdisconnect;	/* Remove flexible ownership */

end specification NMnonmani;
