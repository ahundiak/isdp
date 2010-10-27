/* $Id: VDplace.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/*************************************************************************
/* I/VDS
 *
 * File:         ~VDS/vdannot/func/VDplace.I
 *
 * Description:
 *  		function to place annotation/item referred from
 * 		GRNUC/src/dim/dim_utils/place.I
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDplace.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/09/18  03:11:22  pinnacle
# Replaced: vdannot/func/VDplace.I for:  by mdong for vds
#
# Revision 1.2  1997/08/26  22:09:20  pinnacle
# Replaced: vdannot/func/VDplace.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/05/09  22:28:18  pinnacle
# Replaced: vdannot/func/VDplace.I for:  by yzhu for vds.240
#
 *
 * History:
 *      05/06/96        yzhu    Change VDtxbox to VDfrmtxt
 *************************************************************************/

class implementation DMroot;

#define AS_DEBUG 1

#include "msdef.h"
#include "exmacros.h"
#include "gr.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "dpmacros.h"
#include "exdef.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#include "dimdef.h"
#include "dim.h"
#include "dimlinear.h"
#include "dimradial.h"
#include "dimdyn.h"
#include "dimmod.h"
#include "diminst.h"
#include "dimco.h"
#include "dimsrc.h"
#include "dimplcmacros.h"
#include "dimannot.h"
#include "DMmsg.h"
#include "v_miscmacros.h"
#include "cimath.h"
#include "VDSannot.h"

#define VD_DEBUG

#include "VDdebug.h"


from DMplan_mgr import create_dim_plane;
from DMplan import give_parents;
from VDfrmtxt import VDsetAttribute;

extern GRclassid OPP_dim_plan_class_id,
		 OPP_DMplan_class_id,
		 OPP_VDfrmtxt_class_id,
		 OPP_VDtxldr_class_id;

extern IGRdouble 	VDCmdtxldr_text_angle;
extern unsigned char    VDCmdtxldr_flag;
extern IGRlong          VDCmdtxldr_text_flag;

IGRint VDplace_annot2(annot_type,
		      geom_type,
		      attach_ele1,
		      attach_ele2,
		      attach_pt1,
		      attach_pt2,
		      num_brkpt,brkpt,text_length,text_string,
		      plane_grid,list,
		      owner,color,weight,dim_grid,value_type)
IGRint annot_type;
IGRint geom_type;
struct GRid *attach_ele1;
struct GRid *attach_ele2;
IGRdouble attach_pt1[3];
IGRdouble attach_pt2[3];
IGRint num_brkpt;
IGRdouble *brkpt;
IGRint text_length;
IGRchar *text_string;
struct GRid *plane_grid;
struct GRid *list;
struct GRid *owner;
IGRint color;
IGRint weight;
struct GRid *dim_grid;
IGRint value_type;
/*.VDplace_annot2*/
{
        IGRint status, rc, index;
        IGRshort txt_length = 0;
        IGRchar *txt_string = NULL;
        IGRint num_parents;
        IGRlong long_rc, chan_index, msg;
        struct GRid context[MAX_DIM_ROOTS];
        struct annot_attr an_attr;
        struct GRmd_env md_env;
        struct GRas assoc_lis;
        struct GRid null_id, go_grid;
        IGRchar classname[20];
        struct DMsenv_param par_senv;
	IGRlong text_flag;

  __enterFunction ( name = "VDannot_place2" );

        /*| Get module info */

        status = DMget_module_info(&md_env);
        dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

        for (index=0; index<MAX_DIM_ROOTS; index++)
        {
                context[index].objid = NULL_OBJID;
                context[index].osnum = md_env.md_id.osnum;
        }
    
        status =
        dm$get_dim_param(type = DM_SENV_PARAM,
                        p_grid = &list[DIM_ROOT_SENV],
                        p_data = (char *)&par_senv);
        dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

        /*| Get dimension parameter */

        if (annot_type != LEADER_LINE)
        {
                txt_length = text_length;
                txt_string = _MALLOC ( 1024, char );
                if (txt_string == NULL)
                {
                        printf("DMplace_annot: malloc failed\n");

			__exit_error_Function ( name = "VDannot_place2" );

                        return(OM_E_ABORT);
                }
        }

        switch(annot_type)
        {
                case TEXT_WITH_LEADER:
                strcpy(classname, "VDfrmtxt");
                num_parents = NO_TEXT_LEADER_ROOTS+1;
                memcpy(txt_string, text_string, txt_length);
                break;

                case TEXT_WITH_BALLOON:
                strcpy(classname, "VDitem");
                num_parents = NO_TEXT_LEADER_ROOTS+1;
                memcpy(txt_string, text_string, txt_length);
                break;

                default:
                printf("DMplace_annot : wrong annot_type %d\n",annot_type);

		__exit_error_Function ( name = "VDannot_place2" );

                return(OM_E_ABORT);
        }

        /*| Get dimension plane */

        null_id.objid = NULL_OBJID;

                __printf ( "plane_grid = [%d,%d]", `plane_grid->osnum, plane_grid->objid` );

                if (DMancestry_valid(*plane_grid, OPP_dim_plan_class_id))
                {
                        /*|- Plane already a dim_plan object */

                        list[DIM_ROOT_PLAN].objid = plane_grid->objid;
                        list[DIM_ROOT_PLAN].osnum = plane_grid->osnum;
                }
                else
                {
                        status = dm$get_dim_plane(
                                win_grid = *plane_grid,
                                md_env = (struct GRmd_env *) &md_env,
                                p_grid = &list[DIM_ROOT_PLAN]);
                        dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }
                }

        an_attr.dim_type    = annot_type;
        an_attr.geom_type   = geom_type;
        an_attr.display     = 0;
        an_attr.dim_state   = DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE;
        an_attr.leader      = (num_brkpt == 0)? FALSE:TRUE;
        an_attr.text_length = txt_length;
        an_attr.text_string = (IGRuchar *)txt_string;
        an_attr.num_brkpt   = num_brkpt;
        an_attr.dual_mode   = 0;
        an_attr.brkpt       = brkpt;
        an_attr.tol_symbol  = 0;
        an_attr.bln_dir     = 0; 

	if (annot_type == LEADER_LINE)
	   an_attr.leader = TRUE;

        for(index = 0; index <3; index++)       
        an_attr.start_pt[index] = attach_pt1[index];

        if (DMancestry_valid(*attach_ele1, OPP_VDtxldr_class_id))
        {
                status =
                om$send(msg = message DMroot.return_dim_go(
                                                &rc,
                                                DIM_TEXT,
                                                FALSE,
                                                DM_TEXT,
                                                &md_env,
                                                &go_grid),
                        senderid = NULL_OBJID,
                        targetid = attach_ele1->objid,
                        targetos = attach_ele1->osnum);
                dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

                list[AN_ROOT_ELEM1] = go_grid;
        }
        else    list[AN_ROOT_ELEM1] = *attach_ele1;
        if (attach_ele2)
        {
                list[AN_ROOT_ELEM2] = *attach_ele2;
                for(index = 0; index <3; index++)       
                an_attr.end_pt[index] = attach_pt2[index];
        }

        assoc_lis.parents = list;
        assoc_lis.num_parents = num_parents;
        assoc_lis.context = context;
        assoc_lis.as_attr = (char *)&an_attr;
        assoc_lis.go_attr = NULL;
        assoc_lis.go_objid.objid = NULL_OBJID;
        assoc_lis.my_context.objid = NULL_OBJID;
        assoc_lis.my_context.osnum = md_env.md_id.osnum;

        /*| construct dimension */

        dim_grid->osnum = md_env.md_id.osnum;
        status =
        om$construct(
                classname = classname,
                p_objid = &dim_grid->objid,
                osnum = dim_grid->osnum);
        dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

        __printf ( "dim_grid = [%d,%d]", `dim_grid->osnum, dim_grid->objid` );

	if (DMancestry_valid(*dim_grid, OPP_VDfrmtxt_class_id) &&
	    VDCmdtxldr_flag)
	{
		text_flag = TEXTANGLE;
		status =
        	om$send ( msg      = message VDfrmtxt.VDsetAttribute(
				             &msg,
					     text_flag,
                                             (IGRchar *)&VDCmdtxldr_text_angle),
		  	  senderid = NULL_OBJID,
                  	  targetid = dim_grid->objid,
                  	  targetos = dim_grid->osnum);

                if(VDCmdtxldr_text_flag & VD_text_CAPS)
                {
                  text_flag = TEXTCAPS;
                  status=
                  om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
		  	   senderid = NULL_OBJID,
                           targetid = dim_grid->objid,
                           targetos = dim_grid->osnum);
                }
		else
		{
                  text_flag = TEXTCAPS_NO;
                  status=
                  om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                           senderid = NULL_OBJID,
                           targetid = dim_grid->objid,
                           targetos = dim_grid->osnum);
                }

                if(VDCmdtxldr_text_flag & VD_text_MIRROR)
                {
                  text_flag = TEXTMIRROR;
                  status=
                  om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
		  	   senderid = NULL_OBJID,
                           targetid = dim_grid->objid,
                           targetos = dim_grid->osnum);
                }
		else
		{
                  text_flag = TEXTMIRROR_NO;
                  status=
                  om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                           senderid = NULL_OBJID,
                           targetid = dim_grid->objid,
                           targetos = dim_grid->osnum);
                }

                if(VDCmdtxldr_text_flag & VD_text_REVERSE)
                {
                  text_flag = TEXTREVERSE;
                  status=
                  om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
		  	   senderid = NULL_OBJID,
                           targetid = dim_grid->objid,
                           targetos = dim_grid->osnum);
                }
		else
		{
                  text_flag = TEXTREVERSE_NO;
                  status=
                  om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                           senderid = NULL_OBJID,
                           targetid = dim_grid->objid,
                           targetos = dim_grid->osnum);
                }

	}

        if(owner)
        {
                /*|- connect owner to myself */

                chan_index = 0;

                status =
                om$send(msg = message GRconnector.GRrigidconn(
                                                &long_rc,
                                                owner,
                                                &chan_index),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }
        }

        status =
        om$send(msg = message NDnode.NDplace(
                                        &assoc_lis,
                                        &md_env,
                                        NULL),
                senderid = NULL_OBJID,
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

        /*"color = %d, weight = %d\n",color, weight*/

        if (( color != -1) || (weight != -1) || value_type >0)
        {
                /*|- edit the senv_param and post the correct values */

                status =
                dm$get_dim_param(
                        type = DM_SENV_PARAM,
                        dim_objid = dim_grid->objid,
                        dim_osnum = dim_grid->osnum,
                        p_data = (char *)&par_senv);
                dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

                if (color != -1) par_senv.dim_colr = color;
                if (weight != -1) par_senv.dim_weig = weight;
                par_senv.value_type = value_type;

                /*| Set dim to state EDIT */

                status =
                om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

                /*| Put environment */

                status =
                dm$put_dim_param(
                        type = DM_SENV_PARAM,
                        dim_objid = dim_grid->objid,
                        dim_osnum = dim_grid->osnum,
                        p_data = (char *)&par_senv);
                dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

                /*| Clear EDIT state */

                status =
                om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
                        senderid = NULL_OBJID,
                        targetid = dim_grid->objid,
                        targetos = dim_grid->osnum);
                dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }
        }

        status =
        dm$change_node(
                as_grid = *dim_grid,
                md_env = &md_env,
                broadcast = FALSE);
        dm$status(); if ( ! (status & 1) ) { __print_goto ("wrapup"); goto wrapup; }

        status =
        om$send(msg = message DMroot.set_dim_state(BIT_SET, 0),
                senderid = NULL_OBJID,
                targetid = dim_grid->objid,
                targetos = dim_grid->osnum);
        dm$status();

wrapup:

        _FREE ( txt_string );

  __exitFunction ( name = "VDannot_place2" );

        return(OM_S_SUCCESS);
}

end implementation DMroot;

