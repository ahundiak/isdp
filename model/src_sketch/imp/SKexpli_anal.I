class implementation SKexplicit;

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
    IGRboolean		world = 1;
    IGRlong		status;
    GRrange		range;
    struct GRid		my_grid, dim_grid;
    OM_S_CHANSELECT	to_comp;

    extern IGRlong	GRprint_units_and_cs();

    *msg = status = OM_S_SUCCESS;
     
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);
 
    status = GRprint_units_and_cs(msg, rep_file_ptr);

    fprintf(rep_file_ptr, " Dimension text: %lf \n", ME.expression->value);

    om$make_chanselect(channame = "GRcmpowner.to_components",
		       p_chanselect = &to_comp);

    status = om$get_objid_at_index(object = me,
				   p_chanselect = &to_comp,
				   index = 0,
				   objidaddr = &dim_grid.objid,
				   osnumaddr = &dim_grid.osnum);

    status = om$send(msg = message GRgraphics.GRgetrang(msg,
						  &md_env->md_env.matrix_type,
                                                  md_env->md_env.matrix,
                                                  &world,
                                                  range),
                         targetid = dim_grid.objid,
			 targetos = dim_grid.osnum);
    fprintf(rep_file_ptr," Dimension Range : \n");
    fprintf(rep_file_ptr,"\t%lf\t%lf\t%lf\n\t%lf\t%lf\t%lf\n", range[0], range[1],range[2],range[3],range[4],range[5]);

    fprintf(rep_file_ptr,"\n"); 	
    if ( *analyze_option == DETAILED )
    {		
	/* send analyze to dimension components */

	status = om$send(msg = message GRgraphics.GRanalyze_element(msg,
							md_env,
							rep_file_ptr,
							analyze_option),
			 targetid = dim_grid.objid,
			 targetos = dim_grid.osnum);

	status = GRprintAssocInfo(rep_file_ptr, &my_grid);

    }
    return(status);

}

end implementation SKexplicit;
