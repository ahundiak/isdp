class implementation GRgencs;

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
    IGRlong		status;
    struct GRid		my_grid;

    extern IGRlong	GRprint_units_and_cs();

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);

    status = GRprint_units_and_cs(msg, rep_file_ptr);

    fprintf(rep_file_ptr," Orientation : \n");
    {
      fprintf(rep_file_ptr,"\t%lf\t%lf\t%lf\n",me->matrix[0],me->matrix[1],me->matrix[2]); 
      fprintf(rep_file_ptr,"\t%lf\t%lf\t%lf\n",me->matrix[4],me->matrix[5],me->matrix[6]); 
      fprintf(rep_file_ptr,"\t%lf\t%lf\t%lf\n",me->matrix[8],me->matrix[9],me->matrix[10]); 
    };

    fprintf(rep_file_ptr," Origin : \n\t%lf\n\t%lf\n\t%lf\n", me->matrix[3],
					me->matrix[7], me->matrix[11]);

    if ( *analyze_option == DETAILED )
    {		
	/* call detailed analysis */
	status = GRprintAssocInfo(rep_file_ptr, &my_grid);

    }
    return(OM_S_SUCCESS);

}

end implementation GRgencs;
