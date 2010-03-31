class implementation GRcompcurve;

#include "coimport.h"
#include "igrtypedef.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grio.h"
#include "griodef.h"
#include "griomacros.h"
#include "grmessage.h"
#include "go.h"
#include "msmacros.h"
#include "csmacros.h"
#include "revieweledef.h"
#include "msdef.h"
#include "csdef.h"
#include "OMerrordef.h"

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr; 
			 enum GRanalyze_types   *analyze_option)
{
    IGRint		num_comps;
    IGRlong             status;
    IGRdouble		length, startpt[3], endpt[3];
    GRrange		range;
    IGRboolean		world=TRUE;
    struct GRprops	props;
    struct GRid		my_grid;
 
    extern              GRreport_analyze(), GRprint_analyze_header();
    extern IGRlong	GRprint_units_and_cs();
 
    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);
 
    status = om$send (msg = message GRvg.GRgeomprops( msg,
                          		&md_env->md_env.matrix_type,
                           		md_env->md_env.matrix,
                          		&props),
                      targetid = my_id);
 
    if (!(status & *msg & 1))
       goto wrapup;
 
    status = om$send ( msg =  message GRcurve.GRtotlength(msg, 
                                     	&md_env->md_env.matrix_type,
                                        md_env->md_env.matrix,
                                        &length),
                       targetid = my_id);
 
    if (!(status & *msg & 1))
      goto wrapup;

    status = om$send (msg = message GRcurve.GRendpts(msg, 
                           		&md_env->md_env.matrix_type,
                           		md_env->md_env.matrix,
                           		startpt, endpt),
                      targetid = my_id);
 
    if (!(status & *msg & 1))
       goto wrapup;
 
    status = om$send(msg = message GRgraphics.GRgetrang(msg,
                          		&md_env->md_env.matrix_type,
                           		md_env->md_env.matrix,
                          		&world, range),
                     targetid = my_id);
 
    if (!(status & *msg & 1))
       goto wrapup;

    status = om$send(msg = message GRowner.GRget_number_components(msg,
                                			&num_comps),
                     targetid = my_id);
 
    if (!(status & *msg & 1))
       goto wrapup;

    if ( props.planar )
      fprintf(rep_file_ptr," Planar : YES ");
    else
      fprintf(rep_file_ptr," Planar : NO ");

    if ( props.phy_closed )
      fprintf(rep_file_ptr," Closed : YES \n ");
    else
      fprintf(rep_file_ptr," Closed : NO \n ");

    status = GRprint_units_and_cs(msg, rep_file_ptr);

    fprintf(rep_file_ptr," Number of components : %d \n",num_comps);
    fprintf(rep_file_ptr," Curve Length : %lf \n", length);
    fprintf(rep_file_ptr," Start pt : \n\t%lf\n\t%lf\n\t%lf\n", startpt[0],
					startpt[1], startpt[2]);
    fprintf(rep_file_ptr," End pt : \n\t%lf\n\t%lf\n\t%lf\n", endpt[0],
					endpt[1], endpt[2]);
    fprintf(rep_file_ptr," Min Range : \n\t%lf\n\t%lf\n\t%lf\n", range[0],
					range[1], range[2]);
    fprintf(rep_file_ptr," Max Range : \n\t%lf\n\t%lf\n\t%lf\n", range[0],
					range[1], range[2]);
    
    if ( *analyze_option == DETAILED )
    {
	OM_S_CHANSELECT		to_comp;
	IGRint			i;
	struct GRid		comp_id;
        enum GRanalyze_types    option;

 	status = om$make_chanselect(channame = "GRcmpowner.to_components",
                                    p_chanselect = &to_comp);
        if ( !(1 & status) )
          goto wrapup;

        option = GENERAL;
	for ( i = 0; i < num_comps; i ++ )
   	{
           /* send review element message to each component */
           status = om$get_objid_at_index( object = me,
                                           p_chanselect = &to_comp,
                                           index = i,
                                           objidaddr = &comp_id.objid,
                                           osnumaddr = &comp_id.osnum);
           if ( !(1 & status) )
             goto wrapup;
 
           status = om$send(msg = message GRvg.GRanalyze_element(msg,
                                                        md_env,
                                                        rep_file_ptr,
                                                        &option),
                            targetid = comp_id.objid,
                            targetos = comp_id.osnum);
           if ( !(1 & status) )
             goto wrapup;
        }
 
        fprintf(rep_file_ptr, " \ncurve object id : %d \n", my_id);
 
        /* get its parents & dependents */
        status = GRprintAssocInfo(rep_file_ptr, &my_grid);
 
    }
wrapup:
    return(status);
}
end implementation GRcompcurve;
