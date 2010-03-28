class implementation GRpart;

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
#include  "partdef.h" 

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr;
			 enum GRanalyze_types   *analyze_option)
{
    IGRint		index, i, type;
    IGRlong		status;
    IGRchar		attr[MAX_ATTR], value[MAX_VALUE];
    struct GRid		my_grid;

    extern		GRreport_analyze(), GRprint_analyze_header();

    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;

    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);

    index = -1;
    status = om$send(msg = message GRpart.GRget_attribute(msg,
							NUMBER_NAME,
							&index,
							value,
							NULL),
		     targetid = my_id);
    if ( !(status & *msg & 1) )
       goto wrapup;

    fprintf(rep_file_ptr, " Number : %s \n", value);

    for (i = 0; i < me->nb_attr; i++)
    {
        attr[0] = '\0';
        type = 0;
	status = om$send(msg = message GRpart.GRget_attribute(msg,
							      attr,
							      &i,
							      value,
							      &type),
			 targetid = my_id);
         if ( type & GR_STATIC_ATTR ) {
	   fprintf(rep_file_ptr, " Static attribute : %s \n", attr);
	   fprintf(rep_file_ptr, " Value : %s \n", value);
	 }
    }

    if ( *analyze_option == DETAILED )
    {	
	OM_S_CHANSELECT		to_comps;
        enum GRanalyze_types    option;

	option = GENERAL;
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

end implementation GRpart;
