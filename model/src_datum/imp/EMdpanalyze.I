class implementation EMSdatpln;

#include  "coimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "grdpb.h"
#include  "csdef.h"
#include  "OMmacros.h"
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "OMerrordef.h" 

method GRanalyze_element(IGRlong                *msg;
                         struct GRmd_env        *md_env;
                         FILE                   *rep_file_ptr;
                         enum GRanalyze_types   *analyze_option)
{
    IGRlong		status;
    IGRdouble		pts[12];
    struct GRid		my_grid;

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);

    fprintf(rep_file_ptr," Coordinates of lines : \n");
    status = om$send(msg = message EMSdatpln.EMget_pln_info(msg,
							NULL,
							md_env,
							&pts[0],
							&pts[3],
							&pts[6],
							&pts[9],
							NULL),
		     targetid = my_id);
     if ( !(status & *msg & 1) )
	 goto wrapup; 

    fprintf(rep_file_ptr," X axis : %lf\t%lf\t%lf\n", pts[0], pts[1], pts[2]);
    fprintf(rep_file_ptr," Y axis : %lf\t%lf\t%lf\n", pts[3], pts[4], pts[5]);
    fprintf(rep_file_ptr," Z axis : %lf\t%lf\t%lf\n", pts[6], pts[7], pts[8]);
    fprintf(rep_file_ptr," Origin : %lf\t%lf\t%lf\n", pts[9], pts[10], pts[11]);

    if ( *analyze_option == DETAILED )
    {	
	status = GRprintAssocInfo(rep_file_ptr, &my_grid);
    }
    return(OM_S_SUCCESS);

wrapup:
    return(status);

}
end implementation EMSdatpln;
