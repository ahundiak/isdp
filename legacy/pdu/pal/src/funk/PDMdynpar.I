class implementation Root ;

/*
	The set of functions in this file are for creation of dynamic
	parameters. Each function corresponds to one mold component
	and does the job of gathering from the user all the dynamic
	parameters required by that component's CImacro. After these
	objects are created (usually of class expression) and loaded 
	into the array "DYNA_GRID_LIST". The number of objects in 
	the list is returned in "NUM_DYNA".
*/

#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <MEMstruct.h>
#include <PDUstr.h>
#include <PDUmacros.h>
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "ex.h"
#include "exdef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "gr.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "ci_mac_def.h"
#include "ci_macro.h"
#include "cisymb.h"
#include "msdef.h"
#include "msmacros.h"
#include "PALmsg.h"
#include "asmacros.h"
#include "asbox.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "lc.h"
#include "dpmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"


#include "FI.h"
#include "MEMstruct.h"
#include "PALglbs.h"

/*#include "PDUproto.h"*/
#ifndef bld21
#include "PALfunkpro.h"
#endif
#include "PALpdmrpro.h"



#define INCH 1.0
extern struct GRid DYNA_GRID_LIST[];

#define DOUBLE_SIZE 8 
static int 		sts ;

plane_dyn_pars(desc,incr)
int  incr ;
char *desc;
{

	IGRdouble	rds[ EX_RESPONSE_DATA_SIZE / DOUBLE_SIZE ];
	IGRchar       * response_data ;
	struct GRid tmp_grid ;
	char     mesg[100];

	response_data =  (char *)rds;

	ex$message( msgnumb = PDR_P_LC,
                 buff    = mesg,
                 type    = "%s",
                 var     = `desc` );

	sts =  plane_locate(response_data,mesg,&tmp_grid);

        if( sts == -1 ) return(0);  // in case of reset button
	if( sts == -2 ) return(-1); // in case of backup button

	as$make_source(go_grid = tmp_grid,
                       as_os = tmp_grid.osnum,
                       as_grid = &DYNA_GRID_LIST[incr]);

	_pdm_debug("pretend: %d", DYNA_GRID_LIST[incr].objid);


	return(1);
}



graph_dyn_pars(desc,incr)
int incr;
char *desc ;
{
   return(0);
}

ref_cs_dyn_pars(desc,incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;


	om$get_classid(classname = "dim_plan",
			p_classid = &classes[1]);
	om$get_classid(classname = "GRgencs",
			p_classid = &classes[0]);
	elig_classes.w_count = 2;
	elig_classes.p_classes = classes;
	elig_classes.w_flags = OM_CLST_subclass;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}

solid_dyn_pars(desc,incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

	om$get_classid(classname = "EMSsolid",
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}

line_dyn_pars(desc,incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

	om$get_classid(classname = "GR3dlineseg",
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}

conic_dyn_pars(desc,incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;


	om$get_classid(classname = "GRconic",
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}


gr_dyn_pars(desc,incr)
int  incr;
char *desc ;
{

OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

	om$get_classid(classname = "GRgraphics",
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}

macro_dyn_pars(desc, incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

    	/* changed from "nci_macro" to "NDnodein" since macro_generic */
	om$get_classid(classname = "NDnodein", 
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}


ref_or_ci_dyn_pars(desc,incr)
int  incr  ;
char *desc ;
{
int			sts ;
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

	om$get_classid(classname = "GRgencs",
	       p_classid = &classes[0]); 

	om$get_classid(classname = "nci_macro",
	       p_classid = &classes[1]);
	elig_classes.w_count = 2;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}

point_dyn_pars(desc,incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

	om$get_classid(classname = "GR3dpoint",
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);


	return(1);
}
                    
lbs_dyn_pars(desc,incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

	om$get_classid(classname = "GRlbsys",
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}
                    
surf_dyn_pars(desc,incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

	om$get_classid(classname = "EMSsurface",
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}
                    
curve_dyn_pars(desc,incr)
int  incr ;
char *desc ;
{
OMuword			classes[2] ;
OM_S_CLASSLIST		elig_classes;

	om$get_classid(classname = "GRcurve",
			p_classid = &classes[0]);
	elig_classes.w_count = 1;
	elig_classes.w_flags = OM_CLST_subclass;
	elig_classes.p_classes = classes;

	if( (sts = get_object(desc,&elig_classes,incr)) != 1 )
		return(sts);

	return(1);
}

get_object(desc,elig_classes,incr)
char *desc;
int incr ;
OM_S_CLASSLIST		*elig_classes;
{
char prompt[100];
int sts;

	ex$message( msgnumb = PDR_P_LC,
                 buff    = prompt,
                 type    = "%s",
                 var     = `desc` );

	if( (sts = locate_object(prompt,elig_classes,incr)) != 1 )
		return(sts);

	return( 1 );
}                    

locate_object(prompt,elig_classes,incr)
char *prompt;
int incr ;
OM_S_CLASSLIST		*elig_classes;
{
	IGRlong			msg ;
	int			response , sts ;
	struct GRevent		locev, accev;
	IGRchar 		*response_data ;
	IGRdouble		rds[ EX_RESPONSE_DATA_SIZE / DOUBLE_SIZE ];
	struct GRlc_stack	lc_stack;
	struct GRlc_locate	lc_attr;
	IGRlong			locate_display ;
	char 			cname[100]; 


	response_data =  (char *)rds;

	lc_attr.properties = LC_LC_ONLY | LC_DP_ONLY | LC_RW;

	lc_attr.owner_action = LC_RIGID_OWNER | LC_RIGID_COMP | 
                               LC_FLEX_COMP   | LC_FLEX_OWNER |
                               LC_REF_HEADER  | LC_ASSOCIATIVE ;

	if( elig_classes )
	{
		om$get_classname( classid = elig_classes->p_classes[0],
			  classname = cname ); 

		if( !strcmp( cname, "GRgencs")) /* To locate ref. planes */
			lc_attr.owner_action |= LC_HANDLES;
	}

        locate_display  =  ALL_WINDOWS | NO_PROJ_ACCEPT_POINT | ELEM_HILIGHT |
                           ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR ;

repeat:
	lc_stack.number_located = 0;
	lc_stack.num_entries = 0;

	lc$locate(rc = &msg, event1= &locev,
		  event2=&accev,
		  locate_prompt = prompt, 
		  acc_prompt="Accept/Reject",
		  relocate_prompt  = "Relocate",
	          stack = &lc_stack,
		  eligible_classes = elig_classes,
		  display_flag = locate_display,
		  response = &response,
	          attributes = &lc_attr,
       		  response_data = &response_data);


        if(response == RESET) return(0);
        if(response == D_RESET ) return(-1);
        if(response == CLEAR_STACK) return(-1);
        if(response == D_COMMAND) return(-1);
        if(response == TERMINATE) return(-1);

	if( response != DATA ) goto repeat;

	dp$display(
                msg = &sts,
                oids = &lc_stack.entry[0].located_obj ,
                mode = GRhe
               );

	DYNA_GRID_LIST[incr]=lc_stack .entry[0].located_obj ;

	return(1);
}

PALlocate_by_keyin( rc, string, grid )
int *rc;
char *string;
struct GRid *grid;
{
	*rc = 0;

	/* Take the string and convert it into objid using Directory system macros */
       	sts = di$translate(objname=string,
                            p_objid = &grid->objid);

	if( (sts == DIR_S_SUCCESS) && (grid->objid != NULL_OBJID) )
		*rc = 1;

	return(1);
}


PALlocate_by_datapt( rc, no_of_obj, grid, obj_md_env, no_of_gr_classes, gr_classes, locate_ref)
int *rc;
int *no_of_obj;
struct GRid *grid;
struct GRmd_env *obj_md_env;
int no_of_gr_classes;
OMuword *gr_classes;
int locate_ref;
{
	IGRlong  msg;
	struct GRevent event1, event2;
	IGRlong display_flag;
	struct  GRlc_stack stack;
	int	   status;
	int        i;
	struct GRlc_locate attributes;
	OM_S_CLASSLIST	eligible_classes;
	int	    response;
	double	response_data[1024];
	int     number_located;
	int	    num_entries;
/*	struct GRid LC_part[10];
	struct GRmd_env *LC_part_env[10];
*/	extern OMuword OPP_GRgencs_class_id;

	*rc = 0;
	*no_of_obj = 0;

        display_flag  =  ALL_WINDOWS | NO_PROJ_ACCEPT_POINT |
                           NO_ACC_REJ_CYCLE | DO_NOT_RELOCATE | LC_REGULAR_HIGHLIGHT |
                           LC_ERASE_ALL | LC_ACCEPT_CURSOR ;

	eligible_classes.w_flags = OM_CLST_subclass;
	eligible_classes.w_count = no_of_gr_classes;
	eligible_classes.p_classes = gr_classes;

	if ( locate_ref )
	{
		attributes.owner_action = LC_FLEX_COMP | LC_ASSOCIATIVE | 
				  LC_RIGID_OWNER |
				  LC_RIGID_COMP |
				  LC_FLEX_OWNER |
				  LC_REF_HEADER |
				  LC_EXTERN_CONSTRAINED |
				  LC_REF_OBJECTS;
		attributes.properties = LC_LC_ONLY |
				LC_RW |
				LC_DP_ONLY;
	}
	else
	{
		attributes.owner_action = LC_FLEX_COMP | LC_ASSOCIATIVE | 
				  LC_RIGID_OWNER |
				  LC_RIGID_COMP |
				  LC_FLEX_OWNER |
				  LC_EXTERN_CONSTRAINED |
				  LC_REF_HEADER;
		attributes.properties = LC_LC_ONLY |
				LC_RW |
				LC_DP_ONLY;
	}

	if (gr_classes)	/* 16/Nov/93 - raj. Avoid if gr_classes == NULL	*/
	if( gr_classes[0] == OPP_GRgencs_class_id )
		attributes.owner_action |= LC_HANDLES;

	for (i=0; i<MAX_LCSTACK_LEN; i++)
		stack.entry[i].located_obj.objid = NULL_OBJID;

	stack.number_located = 0;
	stack.num_entries = 0;

	status = lc$locate(
		rc = &msg,
		event1 = &event1,
		event2 = &event2,
		locate_prompt = "",
		acc_prompt = "",
		relocate_prompt = "",
		display_flag = display_flag,
		attributes = &attributes,
		stack = &stack,
		response_data = response_data,
		response = &response,
		stack_size = MAX_LCSTACK_LEN,
		eligible_classes = &eligible_classes );

	if (!status)
	{
		printf("lc$locate failure in locate_filter\n");
		printf("Report to Intergraph Personnel\n");
		return(OM_S_SUCCESS);
	}

	if (msg == LC_OBJS_IN_STACK)
	{
		num_entries = stack.num_entries; 
		number_located = 0;

		for (i=0; i<MAX_LCSTACK_LEN; i++)
			if (stack.entry[i].located_obj.objid != NULL_OBJID)
				number_located++;
			else	break;

		for (i=0; i<number_located; i++)
		{
			grid[*no_of_obj].objid = stack.entry[i].located_obj.objid;
			grid[*no_of_obj].osnum = stack.entry[i].located_obj.osnum;
			if ( obj_md_env )
			memcpy( &obj_md_env[*no_of_obj], &stack.entry[i].module_info,
							sizeof( struct GRmd_env ) );
			(*no_of_obj)++;
		}
			
		if (*no_of_obj)
			*rc = 1;
	}

	return(1);
}

end implementation Root;

