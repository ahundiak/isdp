class implementation GRgsmgr;

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
#include  "grgsdef.h"
#include "dpmacros.h"
#include  "DIdef.h"
#include  "DItypedef.h"
#include  "DIprims.h"
#include  "DIglob.h"
#include  "DImacros.h"

from GRvg import	GRgetsymb;

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr; 
			 enum GRanalyze_types *analyze_option)
{
    IGRint		list_size, size = 40;
    IGRlong		status;
    IGRchar	        dgn_file_name[OM_K_MAXOSNAME_LEN],
               	 	element_name[MAXNAMSIZE], layer_name[40];

    OM_S_CHANSELECT	chansel;
    OM_S_OBJECT_LINKAGE	list;
    OMuint		count = 0;
    OMuword		classid;
    struct GRid		my_grid;
    struct GRsymbology  symbology;
    struct GRobj_info   info;
    struct GRreport_processor	processor;

    extern OMuword	OPP_GR3dpolygon_class_id;
    extern 		GRprint_analyze_header(), GRreport_analyze();
    extern IGRlong	GRauto_nester();


    *msg = status = OM_S_SUCCESS;

    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    /* initialize */
    layer_name[0] = dgn_file_name[0] = '\0';
    strcpy(info.type,"");
 
    /*  get the file name  */
    om$os_number_to_name ( osnum = OM_Gw_current_OS,
                           osname = dgn_file_name );

    element_name[0] = '\0';
    status = om$send ( msg = message GRvg.GRgetname (msg, element_name ),
                     targetid = my_id);
 
  if ( 1 & status & *msg )
        di$cvt_name_for_output(s_path = element_name);

    status = om$send(msg = message GRgraphics.GRgetobjinfo( msg, &info),
                     targetid = my_id);
 
    if ( !(1 & status & *msg) )
        goto wrapup;
 
    /* inquire the layer #, color, weight, style */
    status = om$send ( msg = message GRvg.GRgetsymb  ( msg, &symbology ),
                       targetid = my_id);
 
    if ( !(1 & status & *msg) )
      goto wrapup;
 
    dp$levels_number_to_name (msg = msg,
                              number =  symbology.level,
                              size_name_buffer = &size,
                              name = layer_name,
                              osnum = OM_Gw_current_OS );

    fprintf(rep_file_ptr, " Element Type: %s\n", element_name);
    fprintf(rep_file_ptr, " Fence Object id: %d\n", my_id);
    fprintf(rep_file_ptr, " File Name: %s\n", dgn_file_name);
    fprintf(rep_file_ptr, " Layer: %d  %s; Color: %d; Weight: %d; Style: %d\n",
            symbology.level, layer_name, symbology.display_attr.color,
            symbology.display_attr.weight, symbology.display_attr.style);
 
    chansel.type = OM_e_name;
    chansel.u_sel.name = "GRcmpowner.to_components";
 
    status = om$get_channel_objects (object = me,
                                     p_chanselect = &chansel,
                                     list = &list,
                                     size = 1,
                                     count = &count);

    om$get_classid(objid = list.S_objid,
		   p_classid = &classid);

    if ( classid != OPP_GR3dpolygon_class_id ) 
      fprintf(rep_file_ptr," Element Name:  Rectangular Fence\n");
    else
      fprintf(rep_file_ptr," Element Name:  Polygon Fence\n");

    if ( *analyze_option == DETAILED )
    {
        enum GRanalyze_types	option;
 	struct GRid		window;
	IGRlong			num_objects = 0, inx;
   	IGRchar			name[80];
	struct GRlc_info	lc_info, *ret_objects = NULL;
   	OMuword			classid;
	OM_S_CLASSLIST		eligible_classes;
	
        option = GENERAL;	

        om$get_classname( objid = list.S_objid,
                          osnum = list.osnum,
                          classname = name);

	fprintf(rep_file_ptr,"\n Component name : %s\n", name);

    	status = om$send(msg = message GRgraphics.GRreport_defaults( msg,
							NULL,
							NULL,
							&list_size,
							NULL),
                         targetid = list.S_objid,
                         targetos = list.osnum);
    	if ( !(1 & status & *msg) )
       	   goto wrapup;

    	processor.report_function = GRreport_analyze;
    	processor.report_info = NULL;
    	processor.report_file = (IGRchar *) rep_file_ptr;

    	status = om$send(msg = message GRgraphics.GRreport( msg,
							md_env,
							&list_size,
							NULL,
							&processor),
                         targetid = list.S_objid,
                         targetos = list.osnum);
    	if ( !(1 & status & *msg) )
       	   goto wrapup;

	/* get the elements inside fence using GRauto_nester */
	lc_info.located_obj.objid = list.S_objid;
	lc_info.located_obj.osnum = list.osnum;
	lc_info.module_info = *md_env;

	status = om$send (msg = message GRgsmgr.GRget_prism (msg, 
							     md_env,
               						     0, NULL,
						   	     &window), 
			  targetid = my_id);

	om$get_classid(classname = "GRgraphics", p_classid = &classid);

        eligible_classes.w_flags = OM_CLST_subclass;
        eligible_classes.w_count = 1;
        eligible_classes.p_classes = &classid;
			   
	status = GRauto_nester(msg,
			       &lc_info,
			       window,
			       &me->attributes,
			       &eligible_classes,
			       &ret_objects,
			       &num_objects);

fprintf(rep_file_ptr, " Number of Objects inside fence : %d \n", num_objects);

	for ( inx = 0; inx < num_objects; inx ++ )
	{
	  fprintf(rep_file_ptr, " Object ( %d ) id : %d \n", inx+1, 
				ret_objects[inx].located_obj.objid);
 

	}

    }
    return(OM_S_SUCCESS);

wrapup:
    return(status);

}

end implementation GRgsmgr;
