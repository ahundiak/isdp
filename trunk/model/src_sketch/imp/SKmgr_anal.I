class implementation SKmgr;

#include  "coimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "csdef.h"
#include  "OMmacros.h"
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "OMerrordef.h" 

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr; 
			 enum GRanalyze_types *analyze_option)
{
    IGRint		i;
    IGRlong		status;
    OMuint		comp_count;
    struct GRid		my_grid; 
    OM_S_CHANSELECT	to_comps;
    OM_S_OBJECT_LINKAGE *comp_list = NULL;
    enum GRanalyze_types option; 

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);

    EMmake_chanselect (GRcmpowner_to_components, &to_comps);
    comp_count = 0;
    status = om$get_channel_count (object = me, 
				   p_chanselect = &to_comps,
        			   count = &comp_count);

    comp_list = (OM_p_OBJECT_LINKAGE) alloca (comp_count *
				sizeof(OM_S_OBJECT_LINKAGE));
    
    if (comp_count)
        status = om$get_channel_objects (object = me, 
					 p_chanselect = &to_comps,
          				 list = comp_list, 
					 size = comp_count, 
					 count = &comp_count);

    if ( *analyze_option == DETAILED )
    {
	/* call detailed analysis */
	status = GRprintAssocInfo(rep_file_ptr, &my_grid);

        for ( i = 0; i < comp_count; i ++ )
	{
	    status = om$send(msg = message GRgraphics.GRanalyze_element(
							msg,
							md_env,
							rep_file_ptr,
							analyze_option),
			     targetid = comp_list[i].S_objid,
			     targetos = comp_list[i].osnum);
        }
    } else {

        option = GENERAL; 
        for ( i = 0; i < comp_count; i ++ )
	{
     	   status = om$send(msg = message GRgraphics.GRanalyze_element(
							msg,
							md_env,
							rep_file_ptr,
							&option),
			    targetid = comp_list[i].S_objid,
			    targetos = comp_list[i].osnum);
        }
    }

    return(status);

}

end implementation SKmgr;
