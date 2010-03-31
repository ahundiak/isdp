command_string	"Undo geometry change",0,IDUndo
class			IDundo
super_class		super_cmd
spec_path		"$MODEL/spec"
product_name	"$MODEL"

specification

#include <igetypedef.h>
#include <exmacros.h>
#include <ODE.h>
#include <COBstructs.h>

#include <igr.h>
#include <igrdp.h>
#include <gr.h>
#include <godef.h>
#include <griodef.h>
#include <go.h>
#include <grio.h>
#include <dp.h>

#include <grdpbdef.h>
#include <grdpb.h>

#include <lcdef.h>
#include <lc.h>

/*
Abstract

History

*/

/* ************************************************************	*/
instance
{
  	IGRchar	  *saved_geom;
	IGRint	    saved_geom_type;
}
/* ************************************************************	*/

implementation
/*
Abstract

Algorithm

*/

/*      ************ */

#include "EMS.h"
#include <stdio.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "lcmacros.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "emsdef.h"
#include "lcdef.h"
#include "lc.h"
#include "emserr.h"
#include "ECcmd_def.h"
#include "EMSssprops.h"
#include "bserr.h"
#include "bsparameters.h"
#include "adpdef.h" 
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "igewindef.h"
#include "igecolordef.h"
#include "igecolmacros.h"

#include "exms.h" 
#include "msdef.h"
#include "msmacros.h" 
#include "grmessage.h" 
/* #include "madef.h" */
#include "dpstruct.h" 
#include "dperr.h" 
#include "alloca.h"

#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0

from GRgraphics import GRdisplay, GRgetprops, GRdelete;
from GRvg	import GRgetattr, GRputattr, GRkeypoint, GRmodify;
from GRvg	import GRdynmod, GRgetsize, GRgetgeom, GRpostabsg,GRgetsymb;

state_table
#include <msdef.h>
#include <ECcmd_def.h>
#include "IDffmsg.h"
#include "IDffcmd.h"
#define TRUE 1
#define FALSE 0
#define ID_SURFACE_GEOM		1
#define ID_CURVE_GEOM		0

state start
 on CMD_TYPE = ID_CURVE_GEOM	do message	"Should not print"
                        state start_id

state start_id
 on CMD_TYPE = IDRMPL_CURVE	state start

/* ********************************************************************	*/
/* ********************************************************************	*/
/* ********************************************************************	*/
/* This method frees the memory in which we stored the geometry of the	*/
/* original surface.							*/
/*		frees (dependent on) me->saved_geom			*/
/* 		------------------------------------------------------- */
action delete_saved_geom(IGRint type_bs)
{
  	BSrc			rc;

    if(me->saved_geom)
    {
        if(type_bs == ID_SURFACE_GEOM)
        {
        	BSfreesf( &rc, me->saved_geom);
        	if(rc!= BSSUCC)
        	{
	        	printf("free surface did not work!");
			goto quit;
        	}
        }
        else
        if(type_bs == ID_CURVE_GEOM)
        {
		BSfreecv(&rc, me->saved_geom);
  		if(rc!= BSSUCC)
  		{
			printf("free curve did not work!");
			goto quit;
  		}
        }
	me->saved_geom = NULL;
    }
}

/* ********************************************************************	*/
/* This method switches the geometry of the surface back to what it was	*/
/* originally.  							*/
/*	dependent on:							*/
/*		me->saved_geom						*/
/*		------------------------------------------------------- */
action restore_original_geometry(    IGRlong *msg; 
                                    struct GRlc_info *located_obj;
                                    GRobjid		*the_objid)
{
    struct GRpost_info  	info;
    enum GRdpmode            DisplayMode;

	IGRlong sts; 

    *msg = OM_S_SUCCESS;

    DisplayMode = GRbe;
    status = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(msg,
			&located_obj->module_info.md_env.matrix_type, 
                        located_obj->module_info.md_env.matrix, 
                        &DisplayMode,
                        &located_obj->module_info.md_id),
                   senderid = my_id,
                   targetid = *the_objid,
                   targetos = located_obj->located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(*msg), sts, MSFAIL, ret_end);

    info.construct_flag = FALSE;
    status = om$send(msg = message GRvg.GRpostabsg(msg,
                         &located_obj->module_info, 
                        &info,
                         (IGRchar *) me->saved_geom, 
                        &located_obj->located_obj.objid),
                   targetid = located_obj->located_obj.objid,
                   targetos = located_obj->located_obj.osnum);
    EMomerr_hndlr(status, ret_end, "GRpostabsg error\n");
    EMerr_hndlr(EMis_error(*msg), sts, MSFAIL, ret_end);

    /* put this in to clear the object cache so that we show the new change */
    GRabsg_del_by_objid(the_objid, 
                    &located_obj->located_obj.osnum);

 ret_end:
    DisplayMode = GRbd;
    status = om$send(mode = OM_e_wrt_object,
                   msg = message GRgraphics.GRdisplay(msg,
			&located_obj->module_info.md_env.matrix_type, 
                        located_obj->module_info.md_env.matrix, 
                        &DisplayMode,
                        &located_obj->module_info.md_id),
                   senderid = my_id,
                   targetid = *the_objid,
                   targetos = located_obj->located_obj.osnum);
    EMomerr_hndlr(status, quit, "GRdisplay error\n");
    EMerr_hndlr(EMis_error(*msg), sts, MSFAIL, quit);

}


/* *******************************************************************	*/
action save_original_geometry(  IGRlong     *msg;   
                                char        *geom_ptr; 
                                int      type_bs)
{
 	IGRlong sts, x;
	BSrc	rc;
	IGRint *num_points;
        struct IGRbsp_surface * surf_ptr;
        struct IGRbsp_curve * curve_ptr;

 	sts = OM_S_SUCCESS;

    if(type_bs == ID_SURFACE_GEOM)
    {
        surf_ptr = (struct IGRbsp_surface *) geom_ptr;

	num_points = 0;
	if(surf_ptr->num_boundaries > 0 )
	{ 
		num_points = (IGRint * )
			alloca(surf_ptr->num_boundaries * sizeof(IGRint) );
		if(!num_points)
		{
			sts = OM_E_ERROR;
			goto fini;
		}

		for(x=0; x < surf_ptr->num_boundaries; x++)
		{
		    num_points[x] = (IGRint) surf_ptr->bdrys->num_points; 
		}

 	}

        BSallocsfwb( surf_ptr->u_order, surf_ptr->v_order, 
                surf_ptr->u_num_poles, surf_ptr->v_num_poles, 
                surf_ptr->rational, surf_ptr->num_boundaries, 
                num_points, &me->saved_geom, &rc );
        if(rc!= BSSUCC)
        {
	        printf("alloc surface did not work!");
		sts = OM_E_ERROR;
		goto fini;
        }
        BSsf_copy(&rc,surf_ptr, me->saved_geom);
        if(rc!= BSSUCC)
        {
	        printf("copy surface did not work!");
		sts = OM_E_ERROR;
		goto fini;
        }
        me->saved_geom_type = ID_SURFACE_GEOM;

    }
    else
    if(type_bs == ID_CURVE_GEOM)
    {
        curve_ptr = (struct IGRbsp_curve *) geom_ptr;

        BSalloccv(curve_ptr->order, curve_ptr->num_poles, curve_ptr->rational,
		curve_ptr->num_boundaries, 
                &me->saved_geom, &rc);
        if(rc!= BSSUCC)
        {
	    printf("alloc curve did not work!");
	    goto fini;
        }
        BScv_copy(&rc, curve_ptr, me->saved_geom);
        if(rc!= BSSUCC)
        {
	    printf("copy curve did not work!");
	    goto fini;
        }
        me->saved_geom_type = ID_CURVE_GEOM;

    }

fini:
	*msg = sts;
	return (sts);

}
/* ******************************************************************** */
/*		------------------------------------------------------- */
action get_and_save_original_geometry(  IGRlong             *msg;   
                                        struct GRlc_info    *located_obj;
                                        GRobjid		    *the_objid;
                                        IGRint              type_bs)
{
    IGRchar          *geom_ptr;
    IGRlong                  num_bytes; 
    IGRlong sts;

    geom_ptr = NULL;

    *msg = OM_S_SUCCESS;

    /* ------------------------------------	*/
    /* Compute the number of bytes required */
    /* ------------------------------------	*/
    sts = om$send(
    msg = message GRvg.GRgetsize(
            msg, 
            &located_obj->module_info.md_env.matrix_type,
            located_obj->module_info.md_env.matrix,
            &num_bytes), 
        senderid = my_id, 
        targetid = *the_objid, 
        targetos = located_obj->located_obj.osnum); 
    if (!(1 & sts & *msg))   
    {
	sts = MSFAIL;
	goto quit;
    }

    /* ----------------------------------------------------	*/
    /* Alloc the required memory off the stack		*/
    /* ----------------------------------------------------	*/
    geom_ptr = (IGRchar *) alloca(num_bytes);
    if (!geom_ptr)
    {
	printf("No memory available in Remove Pole");
    	sts = MSFAIL; 
    	goto quit;
    }

    /* ------------------------------------	*/
    /* Get the geometry			*/
    /* ------------------------------------	*/
    sts = om$send(
            msg = message GRvg.GRgetgeom(
                msg, 
                &located_obj->module_info.md_env.matrix_type,
                located_obj->module_info.md_env.matrix,
                geom_ptr),
            senderid = my_id, 
            targetid = *the_objid, 
            targetos = located_obj->located_obj.osnum); 
    if (!(1 & sts & *msg))
    {
	sts = MSFAIL;
	goto quit;
    }

    status = om$send (msg = message IDundo.save_original_geometry(
                                msg, 
                                geom_ptr, 
                                type_bs),
                    mode = OM_e_wrt_message,
                    targetid = my_id);

}

/* ********************************************************************	*/
action init
{
        me->saved_geom = NULL;
}

/* ********************************************************************	*/
action delete
{
    status = om$send(msg = message 
            IDundo.delete_saved_geom(me->saved_geom_type),
                   targetid = my_id);
    EMomerr_hndlr(status, quit, "delete method:IDundo.delete_obj\n");

}

/* ********************************************************************	*/
