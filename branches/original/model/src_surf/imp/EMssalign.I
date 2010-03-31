/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method is used to align two surfaces 
 given the surfaces, their sides to align, and
 the alignment mode:
               
     0:  modify 1st surface
     1:  modify 2nd surface
     2:  modify both surfaces and fix end points
     3:  modify both surfaces and don't fix end points

 History

    RC : 9/28/86  : Creation Date
   rlw : 03/18/87 : Modified options to pass to math
   rlw : 06/11/87 : Removed pack boundaries stuff and
                    repaired tolerance restoration.        
   dhm : 08/21/87 : Modified to call BSalignsft1
   rlw : 12/30/87 : Totally reworked, renamed it from EMbsalign.
   dhm : 04/06/88 : Added GR_NOTIFY_LISTENERS.
   NP  : 08/26/92 : Modified for ANSI compliance. Typecast for surface geometry 
		    was "IGRchar *" instead of "IGRchar **".
 */

class implementation EMSgenbs;

#include "EMS.h"
#define DEBUG 1

#if DEBUG
#include <stdio.h>
#endif
#include "bs.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"		/* GRgetasbsg macro */

method EMalign_surface(
 struct		GRlc_info *my_surface;
 IGRlong	my_side;
 struct		GRlc_info *his_surface;
 IGRlong	his_side;
 IGRlong	mode;
 IGRlong	*msg)

{
 extern  IGRboolean  GRabsg_del_all();
 extern  IGRboolean  BSfreesf();
 IGRboolean	status;
 IGRlong	sts, i, loc_msg;
 struct		IGRbsp_surface *surface_1, *surface_2;
 struct		IGRbsp_surface *mod_surface_1, *mod_surface_2;
/*
 * Initialize
 */
 *msg = MSSUCC;
 surface_1 = NULL;
 mod_surface_1 = NULL;
 mod_surface_2 = NULL;
/*
 * Get his geometry
 */
 sts = EMget_the_geometry(
   his_surface,
   FALSE,
   FALSE,
   FALSE,
   my_id,
   &surface_2,
   msg);
/*
 * Get my geometry
 */
 {
  struct	GRmdenv_info *mdenv_info;

  mdenv_info = &my_surface->module_info.md_env;
  GRgetabsg(
    msg,
    &mdenv_info->matrix_type, 
    mdenv_info->matrix,
    (IGRchar **) &surface_1,
    i);
   if (! (1 & *msg)) goto wrapup;
 }
/*
 * Call the math
 */
 {
  extern   void		BSalignsft1();
  IGRlong	new_mode;

  switch (mode)
   {
    case 0:
     new_mode = 2;
     break;
    case 2:
     new_mode = 0;
     break;
    default:
     new_mode = mode;
     break;
   }
  BSalignsft1(
    surface_1,
    surface_2,
    my_side,
    his_side,
    new_mode,
    &mod_surface_1,
    &mod_surface_2,
    &loc_msg);
   if (loc_msg != BSSUCC)
    {
#if DEBUG
     fprintf(stderr, "\nBSalignsft1 failure, rc = %d", loc_msg);
#endif
     *msg = MSFAIL;
     goto wrapup;
    }
 }
/*
 * Post my modified geometry if I have changed
 */
 if ((mode != 1) &&
     mod_surface_1)
  {
   GRobjid	newobjid;
   struct	GRpost_info info;

   info.construct_flag = FALSE;
   sts = om$send(
     msg = message GRvg.GRpostabsg(
      msg,
      &my_surface->module_info,
      &info,
      (IGRchar *) mod_surface_1,
      &newobjid),
     targetid = my_id);
    if (! (1 & sts)) goto wrapup;
  }
/*
 * Post his modified geometry if he has changed
 */
 if ((mode != 0) &&
     mod_surface_2)
  {
   GRobjid	newobjid;
   struct	GRid *id;
   struct	GRpost_info info;

   info.construct_flag = FALSE;
   id = &his_surface->located_obj;
   sts = om$send(
     msg = message GRvg.GRpostabsg(
      msg,
      &his_surface->module_info,
      &info,
      (IGRchar *) mod_surface_2,
      &newobjid),
     targetid = id->objid, 
     targetos = id->osnum); 
    if (! (1 & sts)) goto wrapup;
  }
/*
 * eof
 */
wrapup:
 if (surface_2) free(surface_2);
 if (mod_surface_1)
  {
   status = BSfreesf(
    &loc_msg, 
    mod_surface_1);
   status = GRabsg_del_all();
  }
 if (mod_surface_2)
  {
   status = BSfreesf(
    &loc_msg, 
    mod_surface_2);
  }

 GR_NOTIFY_LISTENERS(msg, &sts, GR_GEOM_MODIFIED);

 if (1 & *msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation EMSgenbs;
