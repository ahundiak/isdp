/* ###################   APOGEE COMPILED   ################## */

/*
Abstract



Notes



History
	RV	Just Before he vanished		Creation.
	SM	21-Sep-88			Fixed bugs.
*/

#include <math.h>

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
#include "EMSbnddef.h"
#include "EMSmsgdef.h"
#include "EMS.h"


IGRboolean EMis_iso_edge(num_points, points, tol, iso_points)

IGRint num_points;
IGRdouble *points, *iso_points;
IGRdouble tol;

{
   IGRdouble set_u,  set_v;
   IGRint i;
   IGRboolean iso_u,  iso_v;

   iso_u = iso_v = TRUE;
   set_u = points[0];
   set_v = points[1];

   for (i=1; i<num_points; i++)
     if (fabs(points[i*2] - set_u) > tol)  {iso_u = FALSE; break;}

   for (i=1; i<num_points; i++)
     if (fabs(points[i*2+1] - set_v) > tol)  {iso_v = FALSE; break;}

   if (iso_u && iso_v) return FALSE;
   else if (iso_u || iso_v)
   {
     iso_points[0] = points[0];
     iso_points[1] = points[1];
     iso_points[2] = points[num_points*2 - 2];
     iso_points[3] = points[num_points*2-1];
     return TRUE;
   }
   else return FALSE;
}
