/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLmodTplCmd

     ABSTRACT   : I/LOFT modify templates

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLmodTplCmd.
		  This command modify templates.


     CHANGE HISTORY : 	file created 	25-AUG-1993     Marc Fournier
			file upgraded	14-APR-1994	Marc Fournier
			file modified	25-SEP-1995	Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_MODIFY_TPL, 0, VLMoTe
command_table	"vl.cmd"
class		VLmodTplCmd
super_class	VLlocateCmd
product_name	"$LOFT"
form		"VLmodifyTpl", 0, 0, "-1", "-1"

start_state	TEMPLATE

specification

#include        "ACrg_collect.h"
#include        "vltemplate.h"

instance {
	struct	ACrg_coll	attr[NUM_TM_ATTR];
		IGRboolean	rib_proj;
		IGRboolean	spi_proj;
		IGRboolean	form_state;
	struct	GRid		Ofoot[3];
	struct	GRid		Nfoot[3];
}

implementation

#include        <stdio.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include        "dpmacros.h"
#include        "lcmacros.h"
#include        "grdpbmacros.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "asmacros.h"
#include        "godef.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "grmacros.h"
#include        "FI.h"
#include        "ACattrib.h"
#include        "vsmiscmacros.h"

#include	"vlmsg.h"
#include	"vluserkey.h"
#include        "vlmiscmacros.h"

#define	FORM_FIELD	101
#define	FORM_TOGGL	102

from	ACncpx		import	ACfind_exp_temp_obj;
from    ACrg_collect    import  AClist_attribute, ACset_list_attribute;
from	NDnode		import	NDchange_connect, NDchg_state;
from	GRvg		import	GRgetsymb, GRputsymb;

extern  GRclassid       OPP_ACrg_collect_class_id;
extern  GRclassid       OPP_GRgencs_class_id;
extern  GRclassid       OPP_VLtplSpi_class_id;

/*	#define	TRACE	*/

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vltemplate.h"

/******************************************************************************/
state TEMPLATE
	message_key		VL_S_MODIFY_TPL
	status			" "
	prompt_key		VL_P_TEMPLATE_MGR
	accept_key		VL_M_TEMPLATE_MGR
	locate_eligible		"VLtplMgr"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_DATA		do VLstoreLocate (&me->ret)
				do VLstoreAttr (&me->ret)	state WAIT_FORM
/******************************************************************************/
state WAIT_FORM
        status			" "
        filter                  get_event

        on EX_FORM_FINISHED					state COMPUTE
/******************************************************************************/
state COMPUTE
        status_key              VL_S_PROCESS
        prompt			" "
	execute			VLtplCompute (&me->ret)

        on ELSE                                                 state TEMPLATE
/******************************************************************************/
action form_notification {

		IGRlong		sts;
		IGRint		i, sel, pos, sta, cn_type=ND_COMP;
		IGRdouble	val;
	struct	ACrg_coll	attr[NUM_TM_ATTR];

	switch (gadget_label) {

		case FORM_TOGGL:
			FIg_get_state ( form_ptr, FORM_TOGGL, &sta);

			if ((!sta) && (me->rib_proj)) {
				status =
				exp$create(exp_name   = NULL,
					   exp_syntax = "tpl_cs",
					   osnum      = me->Current.md_id.osnum,
					   p_exp_id   = &me->Nfoot[0].objid,
					   p_osnum    = &me->Nfoot[0].osnum,
					   type_rq    = EXP_TEXT );
				if (status != EXP_S_SUCCESS) goto quit;
			}
			else	me->Nfoot[0] = me->Ofoot[0];

			if ((!sta) && (me->spi_proj)) {
				status =
				exp$create(exp_name   = NULL,
					   exp_syntax = "spi_cs",
					   osnum      = me->Current.md_id.osnum,
					   p_exp_id   = &me->Nfoot[1].objid,
					   p_osnum    = &me->Nfoot[1].osnum,
					   type_rq    = EXP_TEXT );
			}
			else	me->Nfoot[1] = me->Ofoot[1];

			goto quit;

		case FORM_FIELD:
			if ((IGRint)value >= NUM_TM_ATTR)
				FIfld_set_num_rows ( form_ptr,
						     FORM_FIELD,
						     NUM_TM_ATTR );
			goto quit;

		case FI_ACCEPT:

			for ( i=0; i<NUM_TM_ATTR; i++) {
				strcpy ( attr[i].name, me->attr[i].name);
				attr[i].desc.type = AC_ATTRIB_DOUBLE;
				FIfld_get_value ( form_ptr, FORM_FIELD, i, 1,
						  &val, &sel, &pos);
				attr[i].desc.value.att_exp = val;
			}

			/* Deny spine-template add in 2D plate-template */
			if (  (me->rib_proj)
			   && (  (attr[IDX_TM_SPIN].desc.value.att_exp
			      != (me->attr[IDX_TM_SPIN].desc.value.att_exp)))) {
#ifdef TRACE
printf( "\nme->rib_proj = %d\n", me->rib_proj);
printf( "me->spi_proj = %d\n", me->spi_proj);
printf( "attr[%d]      = %g\n",
	IDX_TM_SPIN, attr[IDX_TM_SPIN].desc.value.att_exp);
printf( "me->attr[%d]  = %g\n",
	IDX_TM_SPIN, me->attr[IDX_TM_SPIN].desc.value.att_exp);
#endif
			        if( me->attr[IDX_TM_SPIN].desc.value.att_exp )
				{
                                   ex$message ( msgnumb
                                                 = VL_E_ONLY_3D_REM_SPINE_TPL );
				}
				else {
				   ex$message ( msgnumb
					         = VL_E_ONLY_3D_ADD_SPINE_TPL );
				}
				attr[IDX_TM_SPIN].desc.value.att_exp
				= me->attr[IDX_TM_SPIN].desc.value.att_exp;
				FIf_erase (form_ptr);
				_put_response(resp = TERMINATE);
				goto quit;
			}

			FIf_erase (form_ptr);

			me->Nfoot[2].objid = NULL_OBJID;
			me->Nfoot[2].osnum = me->Current.md_id.osnum;
			om$construct ( classid = OPP_ACrg_collect_class_id,
                               	       osnum   = me->Nfoot[2].osnum,
                               	       p_objid = &me->Nfoot[2].objid );

			status = om$send (
				 msg = message ACrg_collect.ACset_list_attribute
						( &sts, NUM_TM_ATTR, attr),
				 targetid = me->Nfoot[2].objid,
				 targetos = me->Nfoot[2].osnum);
			as$status ( msg   = "ACrg_collect.ACset_list_attribute",
			            test  = (!(status & 0x00000001 & sts)),
			            action= GOTO_VALUE,
			            value = nighthawk );
#ifdef TRACE
for ( i=0; i<3; i++)
printf( "me->Ofoot[%d] : (%d|%d)\t--> me->Nfoot[%d] : (%d|%d)\n",
	i, me->Ofoot[i].osnum, me->Ofoot[i].objid,
	i, me->Nfoot[i].osnum, me->Nfoot[i].objid);
#endif
			status = om$send ( msg = message NDnode.NDchange_connect
						( 3, me->Ofoot, me->Nfoot),
			   		   targetid = me->Loc_env.obj_id.objid,
			   		   targetos = me->Loc_env.obj_id.osnum);
			as$status ( msg   = "NDnode.NDchange_connect",
			            test  = (!(status & 0x00000001)),
			            action= GOTO_VALUE,
			            value = nighthawk );

			nd$wait_batch ( type	   = GR_GEOM_POSTED,
					nb_obj	   = 1,
					l_object   = &me->Loc_env.obj_id,
					l_obj_info = &cn_type );

			gr$delete_object ( msg	     = &sts,
					   md_env    = &me->Loc_env.mod_env,
					   object_id = &me->Ofoot[2] );

nighthawk:
			me->form_state = TRUE;
                        _put_response (resp = EX_FORM_FINISHED);
                        goto quit;

		case FI_CANCEL:
			FIf_erase (form_ptr);
			me->form_state = FALSE;
                        _put_response (resp = EX_FORM_FINISHED);
                        goto quit;

		default:
			me->form_state = FALSE;
			goto quit;
	}
}
/******************************************************************************/
action VLstoreAttr {

		IGRint		i, suc, num;
	struct	GRid		foot;

	*sts = VL_S_SUCCESS;
	me->rib_proj = FALSE;
	me->spi_proj = FALSE;

	/* Rib Templates : coordinate system or plug */
	status = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
					(&suc, IDX_TM_R_CS, &me->Ofoot[0]),
			   targetid = me->Loc_env.obj_id.objid,
			   targetos = me->Loc_env.obj_id.osnum );
	as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(R_CS)",
		    test   = (!(status & 0x00000001 & suc)),
		    action = GOTO_VALUE,
		    value  = quit );
	me->Nfoot[0] = me->Ofoot[0];

	status = vl$return_foot ( msg    = sts,
				  objId  = &me->Ofoot[0],
				  footId = &foot );
	as$status ( msg    = "vl$return_foot(R_CS)",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = quit );

	if (vs$is_ancestry_valid ( object  = &foot,
                                   classid = OPP_GRgencs_class_id ) )
		me->rib_proj = TRUE;
	
	/* Spine Template : coordinate system or plug */
	status = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
					(&suc, IDX_TM_B_CS, &me->Ofoot[1]),
			   targetid = me->Loc_env.obj_id.objid,
			   targetos = me->Loc_env.obj_id.osnum );
	as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(B_CS)",
		    test   = (!(status & 0x00000001 & suc)),
		    action = GOTO_VALUE,
		    value  = quit );
	me->Nfoot[1] = me->Ofoot[1];

	status = vl$return_foot ( msg    = sts,
				  objId  = &me->Ofoot[1],
				  footId = &foot );
	as$status ( msg    = "vl$return_foot(B_CS)",
		    test   = (!(status & 0x00000001 & (*sts))),
		    action = GOTO_VALUE,
		    value  = quit );

	if (vs$is_ancestry_valid ( object  = &foot,
                                   classid = OPP_GRgencs_class_id ) )
		me->spi_proj = TRUE;

	/* Get parameter box ID */
	status = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
					(&suc, IDX_TM_ATTR, &me->Ofoot[2]),
			   targetid = me->Loc_env.obj_id.objid,
			   targetos = me->Loc_env.obj_id.osnum );
	as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(ATTR)",
		    test   = (!(status & 0x00000001 & suc)),
		    action = GOTO_VALUE,
		    value  = quit );
	me->Nfoot[2] = me->Ofoot[2];

	/* Get parameter box length */
	status = om$send ( msg = message ACrg_collect.AClist_attribute
					( sts, NUM_TM_ATTR, me->attr, &num),
                           targetid = me->Ofoot[2].objid,
                           targetos = me->Ofoot[2].osnum );
        as$status ( msg    = "ACrg_collect.AClist_attribute",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = quit );
        if (num != NUM_TM_ATTR) {
		printf( "Trouble ith ACrg_collect <%s>\n", NAM_TM_ATTR);
                *sts = MSFAIL; goto quit; }

	/* Reset form's gadgets */
	FIf_reset (me->forms[0].form_ptr);

	/* Fill the multi columns field */
	FIfld_set_num_rows ( me->forms[0].form_ptr, FORM_FIELD, NUM_TM_ATTR);
	for ( i=0; i<NUM_TM_ATTR; i++) {
		FIfld_set_text  ( me->forms[0].form_ptr, FORM_FIELD, i, 0,
				  me->attr[i].name, FALSE );
		FIfld_set_value ( me->forms[0].form_ptr, FORM_FIELD, i, 1,
				  me->attr[i].desc.value.att_exp, TRUE );
	}

	/* Manage unprojection toggle */
	if (!me->rib_proj) {
		FIg_set_state ( me->forms[0].form_ptr, FORM_TOGGL, 0);
		FIg_disable ( me->forms[0].form_ptr, FORM_TOGGL);
	}
	else {	FIg_set_state ( me->forms[0].form_ptr, FORM_TOGGL, 1);
		FIg_enable ( me->forms[0].form_ptr, FORM_TOGGL);
	}

	/* Display form */
	FIf_display (me->forms[0].form_ptr);
}
/******************************************************************************/
action VLtplCompute {

	struct	GRid		spi_foot;

	if (me->form_state) 	nd$exec_batch();

	/* Get spine foot from template-manager */
	spi_foot.objid = NULL_OBJID;
	spi_foot.osnum = me->Current.md_id.osnum;
	status = vl$return_foot ( msg    = sts,
				  name   = NAM_TM_TSPI,
				  objId  = &me->Loc_env.obj_id,
				  footId = &spi_foot );

	/* Set good symbology for spine foot */
	if (vs$is_ancestry_valid ( object  = &spi_foot,
                                   classid = OPP_VLtplSpi_class_id ) )	{

		struct  GRsymbology     loc_symb;

		/* Get symbology from template-manager */
                status = om$send ( msg = message GRvg.GRgetsymb
						( sts, &loc_symb),
                                   targetid = me->Loc_env.obj_id.objid,
                                   targetos = me->Loc_env.obj_id.osnum );
                as$status ( msg    = "GRvg.GRgetsymb",
                            test   = (!(status & 0x00000001 & (*sts))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Set symbology of spine-box-manager */
		status = om$send ( msg = message GRvg.GRputsymb
                                                ( sts, &loc_symb),
				   targetid = spi_foot.objid,
				   targetos = spi_foot.osnum );
                as$status ( msg    = "GRvg.GRputsymb",
                            test   = (!(status & 0x00000001 & (*sts))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* Redisplay spine-box-manager foot */
		gr$display_object ( object_id = &spi_foot,
				    md_env    = &me->Current);
	}

wrapup:
        status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
