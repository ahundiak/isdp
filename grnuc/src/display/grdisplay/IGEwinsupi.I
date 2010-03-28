

class implementation  IGEwinsup;

#include "grimport.h"

method  pre_update(IGRlong *msg; struct GRid *gragad_id; 
		    struct DP_information *dp_info; struct GRmd_env *md_env)

{
   return(OM_S_SUCCESS);
}

method  post_update(IGRlong *msg; struct GRid *gragad_id)
{
   return(OM_S_SUCCESS);
}

method  pre_single_display(IGRlong *msg; struct GRid *gragad_id; 
			   struct GRid *graphic_id)
{
   return(OM_S_SUCCESS);
}

method  post_single_display(IGRlong *msg; struct GRid *gragad_id;
			    struct GRid *graphic_id)
{
   return(OM_S_SUCCESS);
}


method  pre_delete(IGRlong *msg)
{
   return(OM_S_SUCCESS);
}

method  pre_plot(IGRchar *user_data)
{
   return(OM_S_SUCCESS);
}

method  post_plot(IGRchar *user_data)
{
   return(OM_S_SUCCESS);
}

method  view_changed(IGRlong *msg)
{
   return(OM_S_SUCCESS);
}

method view_saved (IGRlong *msg; struct GRid *saved_vw; struct GRid *stub_id)
{
   return(OM_S_SUCCESS);
}

method view_recalled (IGRlong *msg; struct GRid *gragad; struct GRid *stub_id)
{
   return(OM_S_SUCCESS);
}

end implementation IGEwinsup;
