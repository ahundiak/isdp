class implementation GRxhgg;

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

from NDnode 	import	ASreturn_go;

method GRanalyze_element(IGRlong   *msg; struct GRmd_env   *md_env;
                         FILE      *rep_file_ptr; 
			 enum GRanalyze_types  *analyze_option)
{
    IGRint		i;
    IGRlong		status;
    IGRuint		num_comps;
    OMuword		classid;
    struct GRid		my_grid, xhatch, boundary;
    struct GRobj_info	info;
    OM_S_CHANSELECT	to_comps, to_father, to_owners;
    OM_S_OBJECT_LINKAGE *comp_list = NULL;
    enum GRanalyze_types l_analyze_option;

    extern OMuword	OPP_ASsource_class_id;
    
    *msg = status = OM_S_SUCCESS;
 
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
 
    GRprint_analyze_header(msg, &my_grid, rep_file_ptr);

    if ( *analyze_option == DETAILED )
    {		
	/* call detailed analysis */
        fprintf(rep_file_ptr, " Object id: %d\n", my_id);
    
	/* get the parent curves */
	om$make_chanselect(channame = "GRconnector.to_owners",
			   p_chanselect = &to_owners);

        status = om$get_objid_at_index( object = me,
			                p_chanselect = &to_owners,
			      	        index = 0,
			      		objidaddr = &xhatch.objid,
			      		osnumaddr = &xhatch.osnum);
        if ( !(1 & status) )
	   goto wrapup;

	om$make_chanselect(channame = "NDfather.father",
			   p_chanselect = &to_father);

	status = om$get_objid_at_index( objid = xhatch.objid,
			      		osnum = xhatch.osnum,
			      		p_chanselect = &to_father,
			      		index = 0,
			      		objidaddr = &boundary.objid,
			      		osnumaddr = &boundary.osnum);
        if ( !(1 & status) )
	   goto wrapup;

	om$get_classid(objid = boundary.objid,
		       osnum = boundary.osnum,
		       p_classid = &classid);

	if ( om$is_ancestry_valid(superclassid = OPP_ASsource_class_id,
				  subclassid = classid) == OM_S_SUCCESS)
        {
      	   struct GRid go;
      	   struct GRmd_env obj_env;

       	     status = om$send(msg = message NDnode.ASreturn_go(&go,
                                                   &obj_env.md_env.matrix_type,
                                                   obj_env.md_env.matrix),
                    	      targetid = boundary.objid,
                              targetos = boundary.osnum);
             boundary.objid = go.objid;

             if ( !(1 & status & *msg) )
	   	goto wrapup;
        }

	l_analyze_option = GENERAL;

        status = om$send(msg = message GRgraphics.GRgetobjinfo( msg, &info),
                         targetid = boundary.objid,
                         targetos = boundary.osnum);
 
        if ( !(1 & status & *msg) )
           goto wrapup;

        fprintf(rep_file_ptr, " Parent curves :  %s\n", info.type);

/*
	status = om$send(msg = message GRvg.GRanalyze_element(msg,
							md_env,
							rep_file_ptr,
				                	analyze_option),
			targetid = boundary.objid,
			targetos = boundary.osnum);
        if ( !(1 & status & *msg) )
	   goto wrapup;
*/
	fprintf(rep_file_ptr, " Parent curve Object id : %d \n", boundary.objid);

	/* get the components */
        om$make_chanselect(channame = "GRcmpowner.to_components",
			   p_chanselect = &to_comps);

	status = om$get_channel_count( object = me,
			       	       p_chanselect = &to_comps,
			      	       count = &num_comps);
        if ( !(1 & status) )
	   goto wrapup;

	comp_list = (OM_S_OBJECT_LINKAGE *) om$malloc(size = num_comps *
			(sizeof(OM_S_OBJECT_LINKAGE)) );
	if (comp_list == NULL) return (OM_E_NODYNMEM);

        status = om$get_channel_objects(object = me,
			       		p_chanselect = &to_comps,
			       		list = comp_list,
			       		size = num_comps,
			       		count = &num_comps);
        if ( !(1 & status) )
	   goto wrapup;

	for ( i = 0; i < num_comps; i ++)
	{
	   status = om$send(msg = message GRvg.GRanalyze_element(msg,
							md_env,
							rep_file_ptr,
							&l_analyze_option),
			    targetid = comp_list[i].S_objid,
			    targetos = comp_list[i].osnum);
	   fprintf(rep_file_ptr, " Component Object id: %d\n", comp_list[i].S_objid);

        }	
    }
    return(OM_S_SUCCESS);

wrapup:
    return(status);

}

end implementation GRxhgg;
