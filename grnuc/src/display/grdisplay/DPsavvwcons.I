/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEsavedvw 
	METHOD NAME:	savedvw_cons

	Abstract:
-----
%SC%

	VALUE =

-----
%EN%

	ON ENTRY:
									
	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

	ON EXIT:

	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%RL%

	RELATIONS REFERENCED:


-----
%NB%


	
-----
%CH%

	CHANGE HISTORY

	MAS   08/12/86	: Design date.

-----
%PD%
--------------------------------------------------------------------
		M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation IGEsavedvw;

#include <string.h>
#include <stdio.h>

#include "grimport.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "exmacros.h"
#include "dpmacros.h"

/* prototype files */
%safe
#include "DPsavvwcons.h"
#include "DPaddvwname.h"
#include "DPgetsavvwid.h"

#include "maidmx.h"
#include "maptsxfor.h"
#include "mamulmx.h"
%endsafe


#define DEBUG 1

from IGEwinsup import view_saved;

#if defined(__STDC__) || defined(__cplusplus)
IGRint DPsavevw_cons ( IGRlong      *msg,
                       GRspacenum   *osnumber,
                       IGRchar      *vw_name,
                       struct GRid  *gg_id,
                       IGRshort     inflags,
                       IGRchar      *struct_pass,
                       IGRchar      *descript,
                       IGRdouble    *origin )
#else
IGRint DPsavevw_cons (msg,osnumber,vw_name,gg_id,inflags,struct_pass,descript,origin)

    IGRlong *msg;
    GRspacenum *osnumber;
    IGRchar *vw_name;
    struct GRid *gg_id;
    IGRshort inflags;
    IGRchar *struct_pass;
    IGRchar *descript;
    IGRdouble *origin;
#endif

{
    IGRint status;		/* OM status which is returned */
    IGRlong num_vw;
    IGRlong error;
    GRobjid vw_objid;    
    struct GRid vwid[32];
    struct GRid savevw_id;
    IGRlong return_bytes;
    struct var_list var_list[2];
    struct gragad_inst gad;
    IGRchar *struct_pt;
    IGRchar *default_name=NULL;
    IGRchar *name;
    GRspacenum vw_os;
    struct GRid savedvw_id;
    GRobjid mod_objid;
    OM_S_CHANSELECT chandef;

status = OM_S_SUCCESS;  
*msg = MSSUCC;

if (osnumber == NULL)
{
	ex$get_cur_mod( id=&mod_objid, osnum=&vw_os);
/* get current os */
}
else
{
    vw_os = *osnumber;
}

    if (gg_id != NULL)
    {
    	var_list[0].var = GRAGAD_INST_STRUCT;
    	var_list[0].var_ptr = (IGRchar *)&gad;
    	var_list[0].num_bytes = sizeof(struct gragad_inst);
    	var_list[0].bytes_returned = &return_bytes;
    	var_list[1].var = END_PARAM;

    	status = om$send(mode = OM_e_wrt_object,
                             msg = message IGEgragad.DPinquire 
			     (msg, &error, 
			      var_list),
                             senderid = NULL,
                 targetid = gg_id->objid,
                 targetos = gg_id->osnum);
                    if ( !(status & 1))
                    {
#ifdef DEBUG
                      	printf("\nin COsavevw  DPinquire failed\n");
			om$report_error(sts = status);
#endif
			goto fini;
                    }
	struct_pt = (IGRchar *)&gad;
	inflags = GGI_STRUCT;
	/* get the graphic gadget's name and set default_name = the that
		pointer */
    }
    else
    {
	struct_pt = struct_pass;
	if (inflags == GG_STRUCT || inflags == GGI_STRUCT)
	{
		;
	}
	else
	{
/*	    default_name = struct_pt->name; */
	}
    }
    if (vw_name != NULL)
    {
	    name = vw_name;
    }
    else
	{
	    if (default_name == NULL)
	    {
/* either return an error or generate a default name as for window 
		*msg =
*/

	    }
	    name = default_name;
	}	
	    num_vw = 0;
		    status = dp$get_saved_vw_id(msg=msg,
				osnum=vw_os,
				name=name,
				numberofids=&num_vw,
				found_GRids=vwid);
                    if ( !(status & 1))
		    {
#ifdef DEBUG
			printf("error in dp$getvwid ... COsavevwi.I ");
#endif
			goto fini;
		    }
		    if (num_vw == 0)
		    {
			status = om$construct(
					obj_osnum = vw_os,
					osnum = vw_os,
                                        classname = "IGEsavedvw",
                                        p_objid = &vw_objid,
					msg = message IGEsavedvw.savedvw_cons
					(msg,inflags,name,
					struct_pt, descript, origin));
			savevw_id.osnum = vw_os;
			savevw_id.objid = vw_objid;
			if (!( 1 & status))
			{
#ifdef DEBUG
			    printf("Error in constructing the view");
			    om$report_error(sts = status);
#endif
			    goto fini;
			}
		    	if (gg_id != NULL)
    			{
			    status = om$make_chanselect
					(channame = "IGEgragad.winsup",
					p_chanselect = &chandef);
			    if (!( 1 & status))
			    {
#ifdef DEBUG
			    	printf("Error in channel to winsup DPsavvwcons");
			    	om$report_error(sts = status);
#endif
			    	goto fini;
			    }
			    savedvw_id.osnum = vw_os;
			    savedvw_id.objid = vw_objid;
			    status = om$send (msg = message IGEwinsup.view_saved
					(msg, &savedvw_id,NULL),
					senderid = gg_id->objid,
					targetos = gg_id->osnum,
					p_chanselect = &chandef);

                            /* protect against unknown objects */
                            if (status == OM_E_NOSUCHCLASS ) status = OM_S_SUCCESS;
			    if (!( 1 & status))
			    {
#ifdef DEBUG
			    	printf("Error in channel to winsup DPsavvwcons");
			    	om$report_error(sts = status);
#endif
			    	goto fini;
			    }
			}
		    }
		    else
		    {
			*msg = DPDUPLICNM;
			status = OM_E_ABORT;
		    }
fini:

return (status);

}

method  savedvw_cons ( IGRlong *msg; IGRshort inflags; IGRchar *vw_name; 
			IGRchar *struct_ptr; 
			IGRchar *descript; IGRdouble *origin)
	{
	IGRlong status;
	IGRlong num_points = 1;		
	IGRdouble temp_pt[3];
	IGRshort i, four = 4;
	IGRdouble trans[4][4];
	IGRdouble wld_to_view[4][4];
	struct gragad_inst *ggi;
	struct DPsavevw   *init_vw=NULL;
	struct DPgra_gad   *gg;

	status = OM_S_SUCCESS;
	*msg = MSSUCC;

	MAidmx(msg, (IGRdouble *)trans);


	status = DPadd_vw_name_dir(msg,0,OM_Gw_current_OS, my_id, GRDP_SAVEDVIEWS, GRDP_GRSAVEDVIEWS,vw_name);
	if (status == DPDUPLICNM)
	{
	    goto fini;
	}
	else if(!(1&status))
	{
	    #ifdef DEBUG
    	    om$report_error(sts = status);
            #endif
            goto fini;
	}

if (!(descript == NULL))
{
    om$vla_set_dimension (varray = me^^IGEsavedvw.descript, 
				  size = (strlen(descript) + 1));	
    OM_BLOCK_MOVE( descript,
                       me->descript,
                       (strlen(descript) + 1));	
}

if (inflags == GG_STRUCT)
{
	gg = (struct DPgra_gad *)struct_ptr;
	me->gragad = *gg;

	if (gg->flags & CONST_PLANE_ON)
	{
	    me->gragad.flags |= VALID_ALT_INV;
	}

	me->min_x_indep = 0;
	me->min_y_indep = 0;
	me->max_x_indep = 1;
	me->max_y_indep = 1;

	if (origin != NULL)
	{
	    trans[0][3] = - gg->origin[0];
	    trans[1][3] = - gg->origin[1];
	    trans[2][3] = - gg->origin[2];

	    MAmulmx(msg, &four, &four, &four, (IGRdouble *)gg->rotation,
			(IGRdouble *)trans, (IGRdouble *)wld_to_view);

	    OM_BLOCK_MOVE( origin,
                       me->gragad.origin,
                       sizeof(me->gragad.origin));
            if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, origin,
				temp_pt))
            {
#ifdef DEBUG
           	printf("\nin savvwcons pt transfrom failed\n");
#endif
                goto fini;
       	    }            
            for (i = 0; i < 3 ; ++i)
            {
               	me->gragad.vw_volume[i] = 
					gg->vw_volume[i] - temp_pt[i];
               	me->gragad.vw_volume[i+3] =
                     	gg->vw_volume[i+3] - temp_pt[i];
            }
	}
}
else if (inflags == GGI_STRUCT)
{
	ggi = (struct gragad_inst *)struct_ptr;
	me->gragad = ggi->gragad;
	if (ggi->gragad.flags & CONST_PLANE_ON)
	{
	    me->gragad.flags |= VALID_ALT_INV;
	}
	me->min_x_indep = ggi->min_x_indep;
	me->min_y_indep = ggi->min_y_indep;
	me->max_x_indep = ggi->max_x_indep;
	me->max_y_indep = ggi->max_y_indep;
	if (origin != NULL)
	{
	    trans[0][3] = - ggi->gragad.origin[0];
	    trans[1][3] = - ggi->gragad.origin[1];
	    trans[2][3] = - ggi->gragad.origin[2];

	    MAmulmx(msg, &four, &four, &four, (IGRdouble *)ggi->gragad.rotation,
			(IGRdouble *)trans, (IGRdouble *)wld_to_view);

	    OM_BLOCK_MOVE( origin,
                       me->gragad.origin,
                       sizeof(me->gragad.origin));
	    
            if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, origin,
				temp_pt))
            {
#ifdef DEBUG
           	printf("\nin savvwcons pt transfrom failed\n");
#endif
                goto fini;
       	    }            
            for (i = 0; i < 3 ; ++i)
            {
               	me->gragad.vw_volume[i] = 
					ggi->gragad.vw_volume[i] - temp_pt[i];
               	me->gragad.vw_volume[i+3] =
                     	ggi->gragad.vw_volume[i+3] - temp_pt[i];
            }
            me->gragad.act_z = ggi->gragad.act_z - temp_pt[2];
	}
}
else
{
	me->gragad.flags = init_vw->flags;
	if (init_vw->flags & CONST_PLANE_ON)
	{
	    me->gragad.flags |= VALID_ALT_INV;
	}
	
	OM_BLOCK_MOVE( init_vw->levels,
                       me->gragad.levels,
			sizeof (IGRint) * ((DP_NUM_OF_LEVELS -1)/32 +1));

	me->min_x_indep = 0;
	me->min_y_indep = 0;
	me->max_x_indep = 1;
	me->max_y_indep = 1;

	me->gragad.grid_per_ref_x = init_vw->grid_per_ref_x;

	me->gragad.grid_per_ref_y = init_vw->grid_per_ref_y;

	me->gragad.uor_per_ref_x = init_vw->uor_per_ref_x;

	me->gragad.uor_per_ref_y = init_vw->uor_per_ref_y;
	if (origin == NULL)
	{
	    OM_BLOCK_MOVE(init_vw->origin,
                       me->gragad.origin,
                       sizeof(me->gragad.origin));
	}
	else
	{
	    trans[0][3] = - init_vw->origin[0];
	    trans[1][3] = - init_vw->origin[1];
	    trans[2][3] = - init_vw->origin[2];

	    MAmulmx(msg, &four, &four, &four, (IGRdouble *)init_vw->rotation,
				(IGRdouble *)trans, (IGRdouble *)wld_to_view);

	    OM_BLOCK_MOVE( origin,
                       me->gragad.origin,
                       sizeof(me->gragad.origin));
	}
	
	OM_BLOCK_MOVE( init_vw->rotation,
                       me->gragad.rotation,
                       sizeof(init_vw->rotation));

	if (origin != NULL)
	{
            if(!MAptsxform(msg, &num_points, (IGRdouble *)wld_to_view, origin,
					temp_pt))
            {
#ifdef DEBUG
           	printf("\nin savvwcons pt transfrom failed\n");
#endif
                goto fini;
       	    }            

            for (i = 0; i < 3 ; ++i)
            {
               	me->gragad.vw_volume[i] = 
					init_vw->vw_volume[i] - temp_pt[i];
               	me->gragad.vw_volume[i+3] =
                     	init_vw->vw_volume[i+3] - temp_pt[i];
            }
	}
	else
	{
	    OM_BLOCK_MOVE( init_vw->vw_volume,
                       me->gragad.vw_volume,
                       sizeof(init_vw->vw_volume));
	}
	me->gragad.act_z = init_vw->act_z;

	OM_BLOCK_MOVE( init_vw->construct_plane,
                       me->gragad.construct_plane,
                       sizeof(init_vw->construct_plane));

 	OM_BLOCK_MOVE( init_vw->eye_pt,
                        me->gragad.eye_pt,
                        sizeof(init_vw->eye_pt ));
 	OM_BLOCK_MOVE( init_vw->coi,
                        me->gragad.coi,
                        sizeof(init_vw->coi ));
 	me->gragad.vw_angle = init_vw->vw_angle;
 	OM_BLOCK_MOVE( init_vw->vrp,
                        me->gragad.vrp,
                        sizeof(init_vw->vrp ));
 	OM_BLOCK_MOVE( init_vw->vpn,
                        me->gragad.vpn,
                        sizeof(init_vw->vpn ));
 	OM_BLOCK_MOVE( init_vw->vup,
                        me->gragad.vup,
                        sizeof(init_vw->vup ));

}

fini:		
return (status);

}

	end implementation IGEsavedvw;
