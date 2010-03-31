command_string	"Display polygon geometry",0,IDDispPoly
class		IDdisp_poly
super_class	super_cmd
spec_path	"$MODEL/spec"
product_name	"$MODEL"

specification

#include <igetypedef.h>
#include <exmacros.h>
#include <ODE.h>
#include <COBstructs.h>

#include <igr.h>
#include <igrdp.h>
#include <gr.h>
#include <godef.h>
#include <griodef.h>
#include <go.h>
#include <grio.h>
#include <dp.h>

#include <grdpbdef.h>
#include <grdpb.h>

#include <lcdef.h>
#include <lc.h>

/*
Abstract

History
	??/??/??	AHC	Creation.
	09/17/92	JSY	Remove parameter objid for both actions.
				Change update_display's type from IGRboolean
				to IGRint since the former does not work
				properly on Sun.

*/

/* ************************************************************	*/
instance
{
  IGRboolean prev_polygon_disp;
}
/* ************************************************************	*/

implementation
/*
Abstract

Algorithm

*/

/* ************ */

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "lcmacros.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "emsdef.h"
#include "lcdef.h"
#include "lc.h"
#include "emserr.h"
#include "ECcmd_def.h"
#include "EMSssprops.h"
#include "bserr.h"
#include "bsparameters.h"
#include "adpdef.h" 
#include "IDffmsg.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "exms.h" 
#include "msdef.h"
#include "msmacros.h" 
#include "grmessage.h" 
/* #include "madef.h" */
#include "dpstruct.h" 
#include "dperr.h" 

#define ID_SURFACE_GEOM	1
#define ID_CURVE_GEOM	0

from GRgraphics import GRdisplay;
from GRvg	import GRgetattr, GRputattr;

state_table
#include <msdef.h>
#include <ECcmd_def.h>
#include "IDffmsg.h"
#define ID_SURFACE_GEOM	1
#define ID_CURVE_GEOM	0

state start
  on CMD_TYPE = ID_CURVE_GEOM
    state start_id

state start_id
  on CMD_TYPE = IDRMPL_CURVE
    state start

/* ********************************************************************	*/
action turn_poly_off(IGRlong *sts;
		     IGRint type_bs; 
		     struct GRlc_info *located_obj;
		     IGRint update_display)
{
  IGRlong msg;
  struct IGResbc esbc;
  struct IGResbs esbs;
  IGRchar *esb;
  enum GRdpmode DisplayMode;

  if (located_obj->located_obj.objid == NULL_OBJID)
  {
    goto quit;
  }
  if (!me->prev_polygon_disp)
  {
    if (type_bs == ID_CURVE_GEOM)
      esb = (IGRchar *) &esbc;
    else
      esb = (IGRchar *) &esbs;

    status = om$send(msg = message GRvg.GRgetattr(&msg, esb),
		     targetid = located_obj->located_obj.objid,
		     targetos = located_obj->located_obj.osnum);
    EMomerr_hndlr(status, quit, "GRgetattr error");
    EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);

    if (update_display)
    {
      DisplayMode = GRbe;
      status = om$send(mode = OM_e_wrt_object,
		       msg = message GRgraphics.GRdisplay(&msg,
							  &located_obj->module_info.md_env.matrix_type,
							  located_obj->module_info.md_env.matrix,
							  &DisplayMode,
							  &located_obj->module_info.md_id),
		       senderid = my_id,
		       targetid = located_obj->located_obj.objid,
		       targetos = located_obj->located_obj.osnum);
      EMomerr_hndlr(status, quit, "GRdisplay error\n");
      EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);
    }

    if (type_bs == ID_CURVE_GEOM)
      esbc.is_polydis = me->prev_polygon_disp;
    else
      esbs.is_polydis = me->prev_polygon_disp;

    status = om$send(msg = message GRvg.GRputattr(&msg, esb),
		     targetid = located_obj->located_obj.objid,
		     targetos = located_obj->located_obj.osnum);
    EMomerr_hndlr(status, quit, "GRputattr error");
    EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);

    if (update_display)
    {
      DisplayMode = GRbd;
      status = om$send(mode = OM_e_wrt_object,
		       msg = message GRgraphics.GRdisplay(&msg,
							  &located_obj->module_info.md_env.matrix_type,
							  located_obj->module_info.md_env.matrix,
							  &DisplayMode,
							  &located_obj->module_info.md_id),
		       senderid = my_id,
		       targetid = located_obj->located_obj.objid,
		       targetos = located_obj->located_obj.osnum);
      EMomerr_hndlr(status, quit, "GRdisplay error\n");
      EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);
    }
    me->prev_polygon_disp = TRUE;
  }
}

/* ********************************************************************	*/
action turn_poly_on(IGRlong *sts;
		    IGRint type_bs; 
                    struct GRlc_info *located_obj;
                    IGRint update_display)
{
  IGRlong msg;
  struct IGResbc esbc;
  struct IGResbs esbs;
  IGRchar *esb;
  enum GRdpmode DisplayMode;

  /*
   * Get the attributes of the curve
   * to see if the polygon display is
   * on or off.  If off, then turn it
   * on.
   */

  if (located_obj->located_obj.objid != NULL_OBJID)
  {
    if (type_bs == ID_CURVE_GEOM)
      esb = (IGRchar *) &esbc;
    else
      esb = (IGRchar *) &esbs;

    status = om$send(msg = message GRvg.GRgetattr(&msg, esb),
		     targetid = located_obj->located_obj.objid,
		     targetos = located_obj->located_obj.osnum);
    EMomerr_hndlr(status, quit, "GRgetattr error");
    EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);

    me->prev_polygon_disp = (type_bs == ID_CURVE_GEOM ? esbc.is_polydis :
			     esbs.is_polydis);

    if (type_bs == ID_CURVE_GEOM ? !esbc.is_polydis : !esbs.is_polydis)
    {
      if (update_display)
      {
	DisplayMode = GRbe;
	status = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRdisplay(&msg,
							    &located_obj->module_info.md_env.matrix_type,
							    located_obj->module_info.md_env.matrix,
							    &DisplayMode,
							    &located_obj->module_info.md_id),
                         senderid = my_id,
                         targetid = located_obj->located_obj.objid,
                         targetos = located_obj->located_obj.osnum);
	EMomerr_hndlr(status, quit, "GRdisplay error\n");
	EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, quit);
      }

      if (type_bs == ID_CURVE_GEOM)
	esbc.is_polydis = GRIS_POLYDIS;
      else
	esbs.is_polydis = EMSIS_POLYDIS;

      status = om$send(msg = message GRvg.GRputattr(&msg, esb),
		       targetid = located_obj->located_obj.objid,
		       targetos = located_obj->located_obj.osnum);
      EMomerr_hndlr(status, quit, "GRputattr error");
      EMerr_hndlr(EMis_error(msg), *sts, OM_E_ABORT, quit);

      if (update_display)
      {
	DisplayMode = GRbd;
	status = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRdisplay(&msg,
							    &located_obj->module_info.md_env.matrix_type,
							    located_obj->module_info.md_env.matrix,
							    &DisplayMode,
							    &located_obj->module_info.md_id),
                         senderid = my_id,
                         targetid = located_obj->located_obj.objid,
                         targetos = located_obj->located_obj.osnum);
	EMomerr_hndlr(status, quit, "GRdisplay error\n");
	EMerr_hndlr(EMis_error(msg), *sts, MSFAIL, quit);
      }
    }
  }
}

/* ********************************************************************	*/
action init
{
  me->prev_polygon_disp = FALSE;
}

