/*
Name
    GRconstruct

Description
    This method is used to perform the initilization of the drawing 
    view header. 

    *arglist       struct GRvg_construct   Structure used to contain 
                                           arguments for construction.

History
    Gray Winn    02/15/88    Design date.
    Henry Bequet 12/09/91    Fix a bug in the call to scale the cs.
    Jack         07/10/92    Set default tangent edge display mode.
    dhm          09/18/92    changed the way me->orientation is set.
    Jack         10/23/92    Comment out setting of default tangent 
                             edge display mode.
*/

class implementation GRdvattach;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "OMerrordef.h"
#include "grownerdef.h"
#include "detail.h"
#include "detaildef.h"
#include "OMmacros.h"
#include "csdef.h"

from GRgencs   import   GRcssetscale;

method GRconstruct ( struct GRvg_construct *arglist )
{
  long                          om_msg;
  long                          ret_msg;
  int                           size;
  GRobjid                       new_id;
  char                          temp[100];
  double                        scale[3];
  struct GRpost_info            info;
  struct GRdvattach_class_attr  *class_attr;

  *arglist->msg = MSSUCC;
  om_msg = OM_S_SUCCESS;
  class_attr = (struct GRdvattach_class_attr *)arglist->class_attr;

  me->properties = arglist->properties | GRIS_NEW;
  me->orientation = 0;

  if (om_msg & *arglist->msg & 1)
  {
    /* Post the definition of the drawing attachment. */
    info.construct_flag = TRUE;
    om_msg = om$send( msg = message GRvg.GRpostabsg ( arglist->msg,
        arglist->env_info, 
        &info, 
        arglist->geometry, 
        &new_id),
        targetid = my_id );
  }

  if (arglist->class_attr)
  {
    if (class_attr->ref_file.objid != NULL_OBJID)
    {
      om_msg = om$send ( msg = message GRdrawview.GRcomponent_add
          ( &ret_msg, 
          arglist->env_info,
          &class_attr->ref_file,
          GR_DV_REFFILE ), 
          targetid = my_id );
    }
    else 
      me->orientation |= class_attr->orientation;

    /*
     * The default for new drawing views is to have tangent edge display
     * supressed after process detail display is run
     */
/*  me->orientation |= GR_DV_TAN_ED_DIS_OFF_AFTER_PDD; */

    if (class_attr->coord_sys.objid != NULL_OBJID)
      om_msg = om$send ( msg = message GRdrawview.GRcomponent_add
          ( &ret_msg,
          arglist->env_info,
          &class_attr->coord_sys, 
          GR_DV_CS ), 
          targetid = my_id );

    if (class_attr->scale && class_attr->scale[0] != '\0')
    {
      size = strlen(class_attr->scale);
      size++;  /* add one for NULL termination */
      om$vla_set_dimension ( varray = me->scale, size = size );
      strcpy ( me->scale, class_attr->scale );
    }
    else 
    {
      ex$message ( msgnumb = GR_I_11, buff = temp );
      size = strlen ( temp );
      size++;
      om$vla_set_dimension ( varray = me->scale, size = size );
      strcpy ( me->scale, temp );
    }

    if (class_attr->desc && class_attr->desc[0] != '\0')
    {
      size = strlen(class_attr->desc);
      size++;  /* add one for NULL termination */
      om$vla_set_dimension ( varray = me->desc, size = size );
      strcpy ( me->desc, class_attr->desc );
    }

    if (class_attr->coord_sys.objid != NULL_OBJID)
    {
      /* Update the scale of the coordinate system. */
      om_msg = om$send ( msg = message GRdrawview.GRget_drawview_scale
          ( &ret_msg,
          arglist->env_info,
          NULL,
          scale),
          targetid = my_id);

      if (om_msg & ret_msg & 1)
        om_msg = om$send (msg = message GRgencs.GRcssetscale
            ( &ret_msg,
            CS_ABSOLUTE,
            scale), 
            targetid = class_attr->coord_sys.objid,
            targetos = class_attr->coord_sys.osnum);
      else
        *arglist->msg = MSFAIL;
    }
  }

  /* see if we succeeded, and if not, delete the object. */
  if (!(om_msg & *arglist->msg & 1))
  {
    om_msg = OM_E_ABORT;
    om$send(msg = message Root.delete(NULL), targetid = my_id);
  }
  else 
    om$send (msg = message GRowner.GRadd_to_active_owner ( &ret_msg,
        arglist->env_info), 
        targetid = my_id);

  return om_msg;
}

end implementation GRdvattach;
