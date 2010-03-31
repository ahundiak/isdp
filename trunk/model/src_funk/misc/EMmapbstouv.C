/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"

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

#include "OMmacros.h"
#include "emserr.h"
#include "bserr.h"
#include "EMSerrordef.h"
#include "bsptoldtnw.h"
#include "bslocalcord.h"
#include "bscvoton.h"
#include "bscv_copy.h"

EMmapbstouv (msg, incurve, plane, partol, uvcurve)
 
IGRlong *msg;
struct IGRbsp_curve *incurve;
struct IGRbsp_surface *plane;
IGRdouble *partol;
struct IGRbsp_curve *uvcurve;

/*
 This function maps an xyz bspline curve lying on the plane into uv space
     
    Assumptions:
      The incurve lies on the plane
      The curve is totally enclosed by the natural
      boundaries of the plane. The memory for the uv curve is assumed to
      be allocated. The uv curve has the same properties as the xyz curve and
      the memory should be allocated accordingly.

      For the sake of consistency, the uv curve is returned as a 3d curve
      with z coordinate being 0.

      Not much thought given while writing this. Only written for
      the sake of expediency.
 
    PP      : 04/09/87           Creation
    Sudha   : 07/08/93           Modified for BSprototypes ansification

*/
      
{
  IGRshort		i;
  BSrc			rc;

  IGRpoint		old_pole0,
                        old_pole1,
                        old_pole2,
                        old_pole3,
                        new_pole3;

  IGRvector		translation;
  IGRdouble		scale = 1.0;
  IGRboolean		bssts,
                        right_hand = TRUE;
  IGRdouble		rot[3][3];


  *msg = EMS_S_Success;

  OM_BLOCK_MOVE (&plane->poles[0], old_pole0, sizeof (IGRpoint));
  OM_BLOCK_MOVE (&plane->poles[3], old_pole1, sizeof (IGRpoint));
  OM_BLOCK_MOVE (&plane->poles[6], old_pole2, sizeof (IGRpoint));
  OM_BLOCK_MOVE (&plane->poles[9], old_pole3, sizeof (IGRpoint));

  bssts = BSlocalcord (&rc, old_pole0, old_pole1, old_pole2, &right_hand, rot);
  EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

  for  (i=0 ; i<3; i++)
   translation[i] = old_pole0[i];

  bssts = BScv_copy (&rc, incurve, uvcurve);
  EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);

  bssts = BScvoton (&rc, translation, rot, &scale, incurve, uvcurve);
  EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);
  
  bssts = BSptoldtnw (&rc, translation, rot, &scale, old_pole3, new_pole3);
  EMerr_hndlr (!bssts, *msg, EMS_E_Fail, wrapup);
  



  for (i=0 ; i < uvcurve->num_poles ; i++)
  {
    uvcurve->poles[3*i] = uvcurve->poles[3*i] / new_pole3[X];
    uvcurve->poles[3*i + 1] = uvcurve->poles[3*i + 1] / new_pole3[Y];
    uvcurve->poles[3*i + 2] = 0.0;
  }


wrapup:
;
}

