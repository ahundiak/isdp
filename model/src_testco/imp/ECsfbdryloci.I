/* ###################   APOGEE COMPILED   ################## */
class implementation ECsfbdryloc;

/*
   HISTORY

22 May 1989 jBk Changed GRm_STRING mask to GRm_TEXT_VALUE.

                Changed GRgetevent to co$getevent.

       ss      ??/??/??      Creation Date
       RC      11/30/88      Added code for command 
                             'Toggle xsection update'
       rlw     01/17/88      Modified to accept <cr> or Moveon
       pp      09/20/89      Removed the static variables which we
                             were using with respect to locating
                             boundary elements and made provisions
                             so that we look at the information
                             stored in the DPB via locate control
                             interface.
 05/19/92      :  AMD  :     Message subsystem compliance
       scw     08/14/94      clarified sleep method

*/

#include "EMS.h"
#include <string.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpdef.h"
#include "dp.h"
#include "gr.h"
#include "godef.h"
#include "go.h"
#include "codef.h"
#include "griodef.h"
#include "grio.h"
#include "EMSdpb.h"
# include "griomacros.h"    /* co$getevent */
# include "EMSlogic.h"      /* EMSokay */
#include "msmacros.h"
#include "EC_F.h"
#include "EC_I.h"
#include "EC_M.h"
#include "EC_P.h"
#include "EMSutilmac.h"

/*
 * This is the global flag that indicates whether a surface should
 * even think about processing it's boundary elements for purpose
 * of locating curves.
 */

/*
 * Removed pp (09/20/89)
%safe
IGRboolean EMSbdryelems_locatable_flag = FALSE;
IGRboolean EMSloop_locatable_flag = FALSE;
%endsafe
 */

/*
 * This command-object is used to toggle surface boundaries to locatable
 * and also to toggle loop-locate. The two command-types are defined
 * below.
 */

#define EDGE_LOCATE 0
#define LOOP_LOCATE     1

method init (IGRint type; IGRchar *string)
{
  ME.super_cmd->mytype = type;
  return (OM_S_SUCCESS);
}

method wakeup (IGRint pos)
{
  ex$message (msgnumb = EMS_P_ClearPromptField);

  if (ME.super_cmd->mytype == EDGE_LOCATE)
    ex$message ( msgnumb = EM_M_ToggleSurfaceBndLocate)
  else  if (ME.super_cmd->mytype == LOOP_LOCATE)
    ex$message ( msgnumb = EM_M_ToggleCompositeBndLocate)
  else
    ex$message ( msgnumb = EM_M_ToggleXsectionUpdate)

  return (OM_S_SUCCESS);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func;
  IGRchar msgstr[40], togstr[15];
  IGRint event_size;
  IGRlong event_mask, msg_loc;
  struct GRevent event;

  /*
   * The type indicates a toggle loop locate
   */

  if (ME.super_cmd->mytype == LOOP_LOCATE)
    {
      IGRint EMSloop_locatable_flag;
      extern IGRboolean EFloop_curves_locatable();

      EMSloop_locatable_flag = EFloop_curves_locatable();
      ems$locate_solid_composite_boundary(
                 msg = &msg_loc);
      if (!(1&msg_loc)) return (OM_E_ABORT);

      ex$message ( msgnumb = EMS_S_CompositeBoundariesNow,
                   buff    = msgstr );

      if (EMSloop_locatable_flag)
        ex$message ( msgnumb = EMS_S_Nonlocatable,
                     buff    = togstr)
      else
        ex$message ( msgnumb = EMS_S_Locatable,
                     buff    = togstr)

      strcat (msgstr, " ");
      strcat (msgstr, togstr);

      ex$message ( in_buff = msgstr , field = ERROR_FIELD );
      sleep (2);

      *response = TERMINATE;
      goto ret_end;
    }

  /*
   * The type indicates a toggle boundary locate
   */

  if (ME.super_cmd->mytype == EDGE_LOCATE)
    {
      IGRint EMSedge_locatable_flag;
      extern IGRboolean EFedge_curves_locatable();

      EMSedge_locatable_flag = EFedge_curves_locatable();

      ems$locate_solid_curve_boundary(
                 msg = &msg_loc);
      if(!(1&msg_loc)) return (OM_E_ABORT);

      ex$message ( msgnumb = EMS_S_SurfaceBoundariesNow,
                   buff    = msgstr );

      if (EMSedge_locatable_flag)
        ex$message ( msgnumb = EMS_S_Nonlocatable,
                     buff    = togstr )
      else
        ex$message ( msgnumb = EMS_S_Locatable,
                     buff    = togstr )

      strcat (msgstr, " ");
      strcat (msgstr, togstr);

      ex$message ( in_buff = msgstr , field = ERROR_FIELD );
      sleep (2);

      *response = TERMINATE;
      goto ret_end;
    }

ret_end:
 return (OM_S_SUCCESS);
}

method super_cmd.sleep (IGRint pos)
{

  ex$message (msgnumb = EM_M_ClearMessageField);
  ex$message (msgnumb = EMS_S_ClearStatusField);
  ex$message (msgnumb = EMS_P_ClearPromptField);

  return (OM_S_SUCCESS);
}


end implementation ECsfbdryloc;

/*****************************************************

  if (ME.super_cmd->mytype == EDGE_LOCATE)
  {
   if (!EFboundary_curves_locatable())
    {
    event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON;

    stat_func = EMSokay (co$getevent (
        msg = &msg_loc,
        event_mask = event_mask,
        prompt = "Composite boundaries locatable too? y/n [n]",
        response = response,
        response_data = response_data,
        event = &event
    ));

    UI_prompt ("");
    if (msg_loc == GRw_no_value)
     event.response = EX_RJT_MOVEON;

    if (!stat_func)
      {
      UI_status ("Error encountered. Exiting.");
      ems_sleep (2);
      *response = TERMINATE;
      goto ret_end;
      }
    else if (event.response == EX_STRING)
      {
       if (toupper (event.event.keyin[0]) == 'Y')
       {
         ems$locate_solid_composite_boundary(
                 mode = 1,
                 msg = &msg_loc);
         if (!(1&msg_loc)) return (OM_E_ABORT);
       }
       else
       {
         ems$locate_solid_composite_boundary(
                 mode = 0,
                 msg = &msg_loc);
         if (!(1&msg_loc)) return (OM_E_ABORT);
       }
         ems$locate_solid_curve_boundary(
                 mode = 1,
                 msg = &msg_loc);
         if (!(1&msg_loc)) return (OM_E_ABORT);

      }
    else if (event.response == EX_RJT_MOVEON)
      {
        ems$locate_solid_composite_boundary(
                 mode = 0,
                 msg = &msg_loc);
        if (!(1&msg_loc)) return (OM_E_ABORT);

        ems$locate_solid_curve_boundary(
                 mode = 1,
                 msg = &msg_loc);
        if (!(1&msg_loc)) return (OM_E_ABORT);
      }
    else
      goto ret_end;
    }
  else
    {
        ems$locate_solid_curve_boundary(
                 mode = 0,
                 msg = &msg_loc);
        if (!(1&msg_loc)) return (OM_E_ABORT);

        ems$locate_solid_composite_boundary(
                 mode = 0,
                 msg = &msg_loc);
        if (!(1&msg_loc)) return (OM_E_ABORT);

    }

  strcpy (msgstr, "Surface boundaries now ");
  if (!EFboundary_curves_locatable())
    strcpy (togstr, "nonlocatable");
  else
    strcpy (togstr, "locatable");
  strcat (msgstr, togstr);
  UI_status (msgstr);
  sleep (2);
  *response = TERMINATE;
  }

  if (ME.super_cmd->mytype == EDGE_LOCATE) */
