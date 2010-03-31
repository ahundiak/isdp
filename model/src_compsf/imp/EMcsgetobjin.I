/*
  RC : 12/03/86    Creation date  
  jhw: 06/21/91    Added check for associative  object.
  AMD: 01/31/92    Added check for single surfaces
  SM : 05/13/92    Message subsystem
*/
class implementation EMScompsurf;

#include "EMS.h"
#include "EMSerrordef.h"
#include "godef.h"
# include "msdef.h"
#include "msmacros.h"
#include "emsclasses.h"
#include "ECmsg.h"

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 IGRlong sts;
 IGRint  num_components;
 OM_S_CHANSELECT to_comps;
 IGRchar myclassname[OM_K_MAXCLASS_LEN], myinfo[30];
 IGRshort action, props = NULL, mask = GRIS_ASSOCIATIVE;

 *msg = EMS_S_Success;
 sts = OM_S_SUCCESS;

 sts = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

 num_components = 0;
 sts = om$send(msg = message GRowner.GRget_number_components
                    (msg, &num_components),
               targetid = my_id);
 EMomerr_hndlr ( sts, ret_end, "GRget_number_components");

 if(num_components == 1)
  {
   /* Unless the component has consistent associative property, the identifier
      returned by it may not be suitable for this object. So temporarily
      make the component associative property consistent with that of this
      object's.

      SM 05/13/92
   */
   sts = om$send(msg = message GRgraphics.GRgetprops(msg, &props), 
         p_chanselect = &to_comps);
   EMomerr_hndlr ( sts, ret_end, "GRgetprops");
   if( (ME.GRgraphics->properties & GRIS_ASSOCIATIVE) &&
       (!(props & GRIS_ASSOCIATIVE)))
    {
     action = 1;
     sts = om$send(msg = message GRgraphics.GRchgprops(msg, &action, &mask), 
           p_chanselect = &to_comps);
     EMomerr_hndlr ( sts, ret_end, "GRchgprops");
     action = 0;
    }
   else if( (!(ME.GRgraphics->properties & GRIS_ASSOCIATIVE)) &&
            (props & GRIS_ASSOCIATIVE))
    {
     action = 0;
     sts = om$send(msg = message GRgraphics.GRchgprops(msg, &action, &mask), 
           p_chanselect = &to_comps);
     EMomerr_hndlr ( sts, ret_end, "GRchgprops");
     action = 1;
    }
   else action = -1;

   sts = om$send(msg = OPPmargs, p_chanselect = &to_comps);
   EMomerr_hndlr ( sts, ret_end, "GRgetobjinfo");   
   if(action != -1)
    {
     sts = om$send(msg = message GRgraphics.GRchgprops(msg, &action, &mask), 
           p_chanselect = &to_comps);
     EMomerr_hndlr ( sts, ret_end, "GRchgprops");
    }

   goto ret_end;
  }

  sts = om$get_classname(objid = my_id, classname = myclassname);
  if(!(1&sts)) goto ret_end;
  
  ex$message(msgname = myclassname, buff = myinfo)

  if (ME.GRgraphics->properties & GRIS_ASSOCIATIVE)
   {
    ex$message(msgnumb = EMS_I_Associative, buff = info->type)
    strcat(info->type, " ");
   }
  else
    info->type[0] = '\0';

  strcat(info->type, myinfo);

ret_end:
    return(sts);
}

end implementation EMScompsurf;


