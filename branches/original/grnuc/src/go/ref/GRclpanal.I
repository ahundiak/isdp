class implementation GRclippoly;

#include  "coimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "csdef.h"
#include  "wl.h"
#include  "igecolor.h"
#include  "igecolmacros.h"
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
    IGRboolean		world;
    GRrange		range;
    struct GRid		my_grid;
    
    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);
 
    world = 1;
    status = om$send(msg = message GRvg.GRgetrang(msg,
					&md_env->md_env.matrix_type,
					md_env->md_env.matrix,
					&world, range),
		     targetid = my_id);

    fprintf(rep_file_ptr, " Clipping Polygon Range : \n");
 
    for ( i = 0; i < 6 ; i ++ )
       fprintf(rep_file_ptr, "%lf  ", range[i]);
 
    fprintf(rep_file_ptr,"\n");

    if ( *analyze_option == DETAILED )
    {		
      enum GRanalyze_types	option;
 
        option = GENERAL;
	status = om$send(msg = message GRgraphics.GRanalyze_element(msg,
							md_env,
							rep_file_ptr,
							&option),
			 targetid = me->cv_objid);

        fprintf(rep_file_ptr, " Object id of Clipping Polygon : %d\n",
					me->cv_objid);

    }

    return(status);

}

end implementation GRclippoly;
