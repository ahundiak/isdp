class implementation ASnode;
 
#include  <alloca.h>
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "OMmacros.h"
#include  "grdpbmacros.h"

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr;
                         enum GRanalyze_types *analyze_option)
{

   IGRlong             status;
   struct  GRid       my_grid;
 
   *msg = status = OM_S_SUCCESS;

   my_grid.objid  = my_id;
   my_grid.osnum  = OM_Gw_current_OS;
   status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
   GRprintAssocInfo(rep_file_ptr,&my_grid);

   return(status);
		 
}; 

end implementation ASnode;
