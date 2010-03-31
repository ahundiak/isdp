/*
This class of objects is simply a storage place for the intersection
data that is not generated in object format (the xyz data for examples).
They are non graphic and have nothing to do with the R-tree. For all practical
purposes, this data can be considered as having been stored in the NMinters
instance data, but is done this way for cleaner implementation.
*/
class specification NMintcurve (1:0) of Root;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "igrdef.h"
#include "ex.h"
#include "emsdef.h"
#include "EMSmsgdef.h"
#include "emserr.h"
#include "nmdef.h"
#include "nmchandef.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"

instance NMintcurve
 {
  IGRuchar		int_props;		/* nmdef.h */
  IGRuchar		bc_props;		/* Bspline properties.	*/
  IGRuchar		order;			/* order of the curve */
  IGRushort		num_poles;		/* number of poles */
  variable IGRdouble	packed_doubles[];	/* poles, weight, knots */
 };

message NMput_curve(IGRlong *EMmsg; struct IGRbsp_curve *curve;
		   IGRuchar int_props);
		
message NMget_curve(IGRlong *EMmsg; struct IGRbsp_curve *curve;
		   IGRuchar *int_props);
		

end specification NMintcurve;
