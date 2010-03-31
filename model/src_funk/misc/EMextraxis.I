/* ###################   APOGEE COMPILED   ################## */
/*
DESCRIPTION
	This function returns an array which contains the axis of revolution of
	the input surface and the center point, respectively.  This method uses
	the surf_info to get the geometry if it is not NULL.  Otherwise, it
	assumes an incoming surface geometry to be passed inside the argument, 
	insurf.

RETURN VALUES
	msg    MSSUCC - successfull
           MSFAIL - if failure
           MSINARG - if one of the arguments is invalid
           MSNOMEM - if no memory could be allocated

NOTES

HISTORY
	dhm		12/28/87	Creation date
        Sudha           07/08/93        Modified for BSprototypes ansification

*/

class implementation GRbspline;

#include "EMS.h"
#include "OMminimum.h"
#include "msdef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "mabcmidpt.h"
#include "bsfreecv.h"
#include "bsaxisrot.h"
#include "bsalloccv.h"

void EMextract_axis(msg, surf_info, insurf, pnt_array)
  IGRlong		*msg;
  struct		GRlc_info		*surf_info;
  struct		IGRbsp_surface	*insurf;
  IGRpoint		pnt_array[3];

{
  IGRchar		errmsg[EMMAXERRMSG_LEN];
  IGRlong		msg_loc, status;
  IGRlong		EMget_the_geometry();
  IGRboolean	sts;
  struct		IGRbsp_surface	*surf;
  struct		IGRbsp_curve	*crv;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
  strcpy(errmsg,"GRbspline.EMrvXtrAxis\n");
  surf = NULL;
  crv = NULL;

  /*
   * Get the geometry of the surface
   * if the locate info was passed in.
   */

  if (surf_info)
  {
     status = EMget_the_geometry(surf_info,
                                 FALSE,			/* Is a curve? */
                                 NULL,			/* Is directed curve? */
                                 FALSE,			/* Separate mallocs? */
                                 NULL_OBJID,
                                 &surf,			/* The geometry */
                                 &msg_loc);
     EMomerr_hndlr(status, ret_end, errmsg);
     EMerr_hndlr_action(EMis_error(msg_loc), *msg, msg_loc,
                        surf = NULL; goto ret_end);
  }
  else if (insurf)
     surf = insurf;
  else
  {
     *msg = MSINARG;
     goto ret_end;
  }

  /*
   * Allocate storage for the axis of revolution line
   */

  BSalloccv(2, 2, NULL, NULL, &crv, &msg_loc);
  EMerr_hndlr(msg_loc != BSSUCC, *msg, MSNOMEM, ret_end);

  /*
   * Call the math routine
   */

  sts = BSaxisrot(&msg_loc, surf, crv);
  EMerr_hndlr( !sts || (msg_loc != BSSUCC), *msg, MSFAIL, ret_end);

  /*
   * Fill the line structure
   */

  if (crv->order == 2)
  {
     pnt_array[0][0] = crv->poles[0];
     pnt_array[0][1] = crv->poles[1];
     pnt_array[0][2] = crv->poles[2];

     pnt_array[1][0] = crv->poles[3];
     pnt_array[1][1] = crv->poles[4];
     pnt_array[1][2] = crv->poles[5];
  }
  else
  {
     *msg = MSFAIL;
     goto ret_end;
  }

  sts = MAbcmidpt(&msg_loc, crv, &pnt_array[2][0]);
  if (!sts) *msg = MSFAIL;


ret_end:
	if ((surf) && (!insurf)) free(surf);
	if (crv) BSfreecv(&msg_loc, crv);

}

end implementation GRbspline;
