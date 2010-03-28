class implementation GRgrgrp;

#include  "coimport.h"
#include  "msdef.h"
#include  "godef.h"
#include  "griodef.h"
#include  "grdpbdef.h"
#include  "OMmacros.h"
#include  "griomacros.h"
#include  "grdpbmacros.h"
#include  "exmacros.h"
#include  "OMerrordef.h"
 
method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr;
                         enum GRanalyze_types  *analyze_option)
{
    IGRint		list_size;
    IGRlong		status;
    struct GRid		my_grid;
    struct GRreport_processor	processor;

    extern 			GRreport_analyze(), GRprint_analyze_header();
    extern IGRlong		GRprint_unis_and_cs();

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);
   
    /* call GRreport_defaluts */
    status = om$send(msg = message GRgraphics.GRreport_defaults( msg,
							NULL,
							NULL,
							&list_size,
							NULL),
		     targetid = my_id);
    if ( (1 & status & *msg) )
    {

      processor.report_function = GRreport_analyze;
      processor.report_info = NULL;
      processor.report_file = (IGRchar *) rep_file_ptr;

      status = om$send(msg = message GRgraphics.GRreport( msg,
							md_env,
							&list_size,
							NULL,
							&processor),
		     targetid = my_id);

     }
    if ( *analyze_option == DETAILED )
    {	
	OM_S_CHANSELECT		to_comps;
	enum GRanalyze_types    option =GENERAL;

	status = om$make_chanselect(channame = "GRcmpowner.to_components",
				    p_chanselect = &to_comps);

	status = om$send(msg = message GRgraphics.GRanalyze_element(
							msg,
							md_env,
							rep_file_ptr,
							&option),
			 p_chanselect = &to_comps);
	if ( !(status & 1 & *msg) )
	   goto wrapup;

    }
    return(OM_S_SUCCESS);

wrapup:
    return(status);

}

end implementation GRgrgrp;
