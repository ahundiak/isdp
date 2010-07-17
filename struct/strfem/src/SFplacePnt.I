class implementation  Root;
/* -------------------------------------------------------------------------
   Doc : SFplacePoint

   Description : This function places a point at the given coordinates

   History :
   06-20-1994	Raju	Creation
------------------------------------------------------------------------- */

#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "OMerrordef.h"
#include  "bserr.h"
#include  "igetypedef.h"
#include  "igrtypedef.h"
#include  "godef.h"
#include  "gr.h"
#include  "igr.h"
#include  "igrdp.h"
#include  "go.h"

#include  "grdpbdef.h"
#include  "grdpbmacros.h"

#include  "dp.h"

extern	OMuword		OPP_GR3dpoint_class_id;	

from	GRgraphics	import	GRdisplay;
from	GRgraphics	import  GRaltconstruct;
from    GRlinear	import	GRputpolyline;

long SFplacePoint(
  long			*msg,		/* O - return status		*/
  double		*coords,	/* I - coordinates of point	*/
  struct GRmd_env	*mod_env,	/* I - create point in this env */
  struct GRid		*PtObj		/* O - point object grid	*/
)
{

long			sts;
struct  IGRdisplay	disp;
struct  GRvg_construct  cst;
int			sizbuf, NoBytesRet;
short			level;
enum	GRdpmode	dpmode = GRbd;
struct  IGRpolyline	pnt;
double			xyz[3];


  *msg = 1;

  /* fill up cst list */
  sizbuf = sizeof ( struct IGRdisplay );
  gr$get_active_display(msg    = msg,
			sizbuf = &sizbuf,
			buffer = &disp,
			nret   = &NoBytesRet);
  disp.weight = 3;

#ifdef SF_DBG
  printf("Entered SFplacePoint\n");
  printf("\tActive display\n");
  printf("\tcolor, wieght, style : [%d], [%d], [%d] \n",
		disp.color, disp.weight, disp.style );
#endif

  sizbuf = sizeof ( short );
  gr$get_active_level( 	msg       = msg,
			sizbuf    = &sizbuf,
			buffer    = &level,
			nret      = &NoBytesRet );
#ifdef SF_DBG
  printf("Active level : [%d]\n", level);
#endif

  cst.msg	 = msg;
  cst.env_info	 = mod_env;
  cst.newflag    = 0;
  cst.level      = level;
  cst.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
  cst.geometry   = (char *) &pnt;
  cst.display    = &disp;
  cst.class_attr = NULL;
  cst.name       = NULL;

  pnt.num_points = 1;
  pnt.points     = xyz;
  pnt.points[0]  = coords[0];
  pnt.points[1]  = coords[1];
  pnt.points[2]  = coords[2];

  sts = om$construct (  classid = OPP_GR3dpoint_class_id,
			osnum   = mod_env->md_id.osnum,
			p_objid = &(PtObj->objid),
			msg = message GRgraphics.GRaltconstruct ( &cst) );
  PtObj->osnum = mod_env->md_id.osnum;
  if ( !(sts & 1) )
  {
	printf("SFplacePoint : om$construct failure\n");
	goto wrapup;
  }

#ifdef SF_DBG
	printf("\tpoint obj = [%d,%d]\n", PtObj->objid, PtObj->osnum );
#endif

  sts = om$send ( msg = message GRgraphics.GRdisplay (
					msg,
					&mod_env->md_env.matrix_type,
					mod_env->md_env.matrix,
					&dpmode,
					&mod_env->md_id ),
		  senderid = NULL_OBJID,
		  targetid = PtObj->objid,
		  targetos = PtObj->osnum );

wrapup:
   return  sts;

}

end implementation  Root;

