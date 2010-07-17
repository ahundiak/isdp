/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLmodMapCmd

     ABSTRACT   : I/LOFT modifies layout points command

     ON ENTRY   :

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES      : This command object defines the classe VLmodMapCmd.


     CHANGE HISTORY : file created      03-NOV-1993     Marc Fournier
	11/05/95	tlb	EMS 3.2 - change cs.h to grcoordsys.h

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string  VLC_M_MODIFY_LAYOUT, 0, VLMoPjLa
command_table   "vl.cmd"
class           VLmodMapCmd
super_class     VLlocateCmd
product_name    "$LOFT"
form		"VLmodLayout", 0, 0, "-1", "-1"

start_state     start

specification

#include        "gr.h"
#include        "growner.h"
#include        "csdef.h"
#include        "grcoordsys.h"
#include        "dpdef.h"
#include        "dp.h"
#include        "godef.h"
#include        "go.h"
#include        "igrtypedef.h"
#include        "igrdef.h"
#include        "igr.h"
#include        "ACrg_collect.h"

instance {
		struct	ACrg_coll	*Iattr;
		struct	ACrg_coll	*Oattr;
			IGRint		Lattr;
			IGRint		Lform;
		struct	GRid		Imap_id;
		struct	GRid		Omap_id;
			IGRboolean	form_state;
}

implementation

#include        <stdio.h>
#include        "vlprototype.h"
#include        "madef.h"
#include        "nddef.h"
#include        "ndmacros.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include        "msdef.h"
#include        "dpmacros.h"
#include        "grmacros.h"
#include        "lcmacros.h"
#include        "grdpbmacros.h"
#include        "expression.h"
#include        "expmacros.h"
#include        "asmacros.h"
#include        "macro.h"
#include        "DIdef.h"
#include        "DItypedef.h"
#include        "DIglob.h"
#include        "DIprims.h"
#include        "FI.h"
#include        "bsvalues.h"
#include        "ACattrib.h"
#include        "ACrg_collect.h"
#include        "ACdyn_col.h"

#include        "vlglobals.h"
#include        "vluserkey.h"
#include        "vlmsg.h"
#include        "vllayout.h"
#include        "vlmiscmacros.h"

#define	FORM_FIELD	100

from	ACncpx		import	ACfind_exp_temp_obj;
from	ACdyn_col	import	AClist_attribute, ACset_list_attribute,
				ACget_att_prop, ACset_att_prop;
from	NDnode		import	NDchange_connect;

extern  GRclassid       OPP_ACdyn_col_class_id;

/******************************************************************************/
state_table

#include        "vlmsg.h"

/******************************************************************************/
state start
        message_key             VL_S_MODIFY_LAYOUT
	prompt_key		VL_P_LAYOUT_OBJECT
	accept_key		VL_M_LAYOUT_OBJECT
	status			" "
	locate_class		"VLlayout"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER"
        locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_DATA		do VLstoreLocate (&me->ret)
				do VLstoreMapAttr (&me->ret)	state WAIT_FORM
/******************************************************************************/
state WAIT_FORM
	status			" "
	filter			get_event

	on EX_FORM_FINISHED					state MODIFY
/******************************************************************************/
state MODIFY
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLlayoutModify (&me->ret)

	on ELSE							state start
/******************************************************************************/
action init {

	me->ret = om$send ( msg = message VLmodMapCmd.init (type, str_ptr),
			    mode = OM_e_wrt_parent,
                            targetid = my_id );
        as$status ( sts = me->ret );

	/* Initialize instances */
	me->Iattr = NULL;
	me->Oattr = NULL;
	me->Lattr = 0;
	me->Lform = 0;
	me->Imap_id.objid = NULL_OBJID;
	me->Imap_id.osnum = me->Current.md_id.osnum;
	me->Omap_id.objid = NULL_OBJID;
	me->Omap_id.osnum = me->Current.md_id.osnum;

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action delete {

	me->ret = om$send ( msg = message VLmodMapCmd.delete (0),
			    mode = OM_e_wrt_parent,
                            targetid = my_id );
        as$status ( sts = me->ret );

	/* Free instance */
	if (me->Iattr) { om$dealloc (ptr = me->Iattr); me->Iattr = NULL; }
	if (me->Oattr) { om$dealloc (ptr = me->Oattr); me->Oattr = NULL; }

	status = OM_S_SUCCESS;
        goto quit;
}
/******************************************************************************/
action form_notification {

		IGRint		i, j, row, sel, pos, cn_type=ND_COMP;
		IGRdouble	val;
		IGRlong		sts;
		IGRchar		txt[DI_PATH_MAX];
	struct	GRid		foot;

	switch (gadget_label) {

		case FORM_FIELD:
			dp$erase_hilite (msg = &sts);
			FIfld_get_active_row( form_ptr, FORM_FIELD, &row, &pos);
			if (row >= me->Lform)	FIfld_set_num_rows ( form_ptr,
                                                     		     FORM_FIELD,
                                                     		     me->Lform);
			else if ( (row >= 3) && (value == -1.0) ) {
				sprintf ( txt, "%s%d", NAM_LF_VARF, row-3);
				status = vl$return_foot ( msg    = &sts,
						          name   = txt,
			                                  objId  =
							  &me->Loc_env.obj_id,
			                                  footId = &foot );
			        as$status ( msg    = "vl$return_foot(VARF)",
			                    test   = (!(status & 1 & sts)),
			                    action = GOTO_VALUE );
				gr$display_object ( object_id = &foot,
						    md_env    = &me->Current,
						    mode      = GRhd );
			}
                        goto quit;

		case FI_ACCEPT:
                        FIf_erase (form_ptr);
		case FI_EXECUTE:

			/* Set default values */
			for ( i=0; i<me->Lattr; i++) {
				strcpy ( me->Oattr[i].name, me->Iattr[i].name);
				me->Oattr[i].desc.type = me->Iattr[i].desc.type;
			}

			/* Get displayed values */
for ( i=0; i<me->Lform; i++) {
	FIfld_get_text ( form_ptr, FORM_FIELD, i, 0, DI_PATH_MAX,txt,&sel,&pos);
	for ( j=0; j<me->Lattr; j++) {
		if (!strcmp ( txt, me->Oattr[j].name) ) {
			FIfld_get_value(form_ptr,FORM_FIELD,i,1,&val,&sel,&pos);
			me->Oattr[j].desc.value.att_exp = val;
			j = me->Lattr;
		}
	}
}

			/* Get column/line number from input */
			me->Oattr[IDX_LB_COL].desc.value.att_exp
			= me->Iattr[IDX_LB_COL].desc.value.att_exp;
			me->Oattr[IDX_LB_LIN].desc.value.att_exp
			= me->Iattr[IDX_LB_LIN].desc.value.att_exp;

			/* Uniform grid flag */
			if (  (  me->Oattr[IDX_LB_XPI].desc.value.att_exp
      			      != me->Iattr[IDX_LB_XPI].desc.value.att_exp)
   			   || (  me->Oattr[IDX_LB_YPI].desc.value.att_exp
      			      != me->Iattr[IDX_LB_YPI].desc.value.att_exp) )
				me->Oattr[IDX_LB_UNI].desc.value.att_exp = 1.0;
			else	me->Oattr[IDX_LB_UNI].desc.value.att_exp = 0.0;

			om$construct ( classid = OPP_ACdyn_col_class_id,
                                       osnum   = me->Omap_id.osnum,
                                       p_objid = &me->Omap_id.objid );

			status = om$send (
                                 msg = message ACdyn_col.ACset_list_attribute
                                                ( &sts, me->Lattr, me->Oattr),
                                 targetid = me->Omap_id.objid,
                                 targetos = me->Omap_id.osnum);
                        as$status ( msg   = "ACdyn_col.ACset_list_attribute",
                                    test  = (!(status & 0x00000001 & sts)),
                                    action= GOTO_VALUE,
                                    value = nighthawk );

			/* Set internal properties */
        		status = om$send (
				 msg = message ACdyn_col.ACset_att_prop (
                                                        &sts,
                                                        NAM_LB_COL,
                                                        AC_ATTRIB_PRIVATE,
                                                        0 ),
                                 targetid = me->Omap_id.objid,
                                 targetos = me->Omap_id.osnum);
                        as$status ( msg   = "ACdyn_col.ACset_att_prop(COL)",
                                    test  = (!(status & 0x00000001 & sts)),
                                    action= GOTO_VALUE,
                                    value = nighthawk );

        		status = om$send (
				 msg = message ACdyn_col.ACset_att_prop (
                                                        &sts,
                                                        NAM_LB_LIN,
                                                        AC_ATTRIB_PRIVATE,
                                                        0 ),
                                 targetid = me->Omap_id.objid,
                                 targetos = me->Omap_id.osnum);
                        as$status ( msg   = "ACdyn_col.ACset_att_prop(LIN)",
                                    test  = (!(status & 0x00000001 & sts)),
                                    action= GOTO_VALUE,
                                    value = nighthawk );

        		status = om$send (
				 msg = message ACdyn_col.ACset_att_prop (
                                                        &sts,
                                                        NAM_LB_UNI,
                                                        AC_ATTRIB_PRIVATE,
                                                        0 ),
                                 targetid = me->Omap_id.objid,
                                 targetos = me->Omap_id.osnum);
                        as$status ( msg   = "ACdyn_col.ACset_att_prop(UNI)",
                                    test  = (!(status & 0x00000001 & sts)),
                                    action= GOTO_VALUE,
                                    value = nighthawk );

			status = om$send ( msg = message NDnode.NDchange_connect
                                                (1, &me->Imap_id, &me->Omap_id),
                                           targetid = me->Loc_env.obj_id.objid,
                                           targetos = me->Loc_env.obj_id.osnum);
                        as$status ( msg   = "NDnode.NDchange_connect",
                                    test  = (!(status & 0x00000001)),
                                    action= GOTO_VALUE,
                                    value = nighthawk );

                        nd$wait_batch ( type       = GR_GEOM_POSTED,
                                        nb_obj     = 1,
                                        l_object   = &me->Loc_env.obj_id,
                                        l_obj_info = &cn_type );

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
action VLstoreMapAttr {

		IGRint		i, suc;
	struct	GRid		foot;
		IGRshort	Iprop, Uprop;

	/* Erase hilite */
	dp$erase_hilite (msg = sts);

	/* Get <grid_attr> template  of the located <VLlayout> macro */
	status = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
				( &suc, IDX_LT_GRID, &me->Imap_id),
			   targetid = me->Loc_env.obj_id.objid,
			   targetos = me->Loc_env.obj_id.osnum );
	as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(GRID)",
                    test   = (!(status & 0x00000001 & suc)),
                    action = GOTO_VALUE );

	/* Get <grid_attr> foot of the located <VLlayout> macro */
	status = vl$return_foot ( msg    = sts,
			          name   = NAM_LF_GRID,
                                  objId  = &me->Loc_env.obj_id,
                                  footId = &foot );
        as$status ( msg    = "vl$return_foot(GRID)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE );

	/* Get the parameter box (number) */
	status = om$send ( msg = message ACdyn_col.AClist_attribute
					( sts, 0, NULL, &me->Lattr ),
			   targetid = foot.objid,
			   targetos = foot.osnum );
	as$status ( msg    = "ACdyn_col.AClist_attribute",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE );

	/* Allocate memory */
	me->Iattr = om$calloc ( num	  = me->Lattr,
			        structure = struct ACrg_coll );
	if (!me->Iattr) {	printf( "Unable to allocate <%d> bytes\n",
                                	me->Lattr * sizeof(struct ACrg_coll) );
                        	goto quit;    }
	me->Oattr = om$calloc ( num	  = me->Lattr,
			        structure = struct ACrg_coll );
	if (!me->Oattr) {	printf( "Unable to allocate <%d> bytes\n",
                                	me->Lattr * sizeof(struct ACrg_coll) );
                        	goto quit;    }

	/* Get the parameter box (number) */
	status = om$send ( msg = message ACdyn_col.AClist_attribute
					( sts, me->Lattr, me->Iattr, NULL ),
			   targetid = foot.objid,
			   targetos = foot.osnum );
	as$status ( msg    = "ACdyn_col.AClist_attribute",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE );

	/* Reset form's gadgets */
        FIf_reset (me->forms[0].form_ptr);

        /* Fill the multi columns field */
        for ( i=0; i<me->Lattr; i++) {
		status = om$send ( msg = message ACdyn_col.ACget_att_prop (
						sts,
						me->Iattr[i].name,
						&Iprop,
						&Uprop ),
			   	   targetid = foot.objid,
			   	   targetos = foot.osnum );
		as$status ( msg    = "ACdyn_col.ACget_att_prop",
                    	    test   = (!(status & 0x00000001 & (*sts))),
                    	    action = GOTO_VALUE );

		if (Iprop != AC_ATTRIB_PRIVATE) {
                	FIfld_set_text ( me->forms[0].form_ptr,
					 FORM_FIELD,
					 me->Lform,
					 0,
					 me->Iattr[i].name,
					 FALSE );
                	FIfld_set_value( me->forms[0].form_ptr,
					 FORM_FIELD,
					 me->Lform,
					 1,
					 me->Iattr[i].desc.value.att_exp,
					 TRUE );
			me->Lform++;
		}
        }
        FIfld_set_num_rows ( me->forms[0].form_ptr, FORM_FIELD, me->Lform);

	/* Display form */
        FIf_display (me->forms[0].form_ptr);
}
/******************************************************************************/
action VLlayoutModify {

	status = OM_S_SUCCESS;

	if (me->Iattr) { om$dealloc (ptr = me->Iattr); me->Iattr = NULL; }
	if (me->Oattr) { om$dealloc (ptr = me->Oattr); me->Oattr = NULL; }
	me->Lattr = me->Lform = 0;

	if (me->form_state) {

		/* Erase old VLlayout object */
		gr$display_object ( object_id = &me->Loc_env.obj_id,
				    md_env    = &me->Loc_env.mod_env,
				    mode      = GRbe );

		/* Compute new VLlayout object */
		nd$exec_batch();

		/* Display new VLlayout object */
		gr$display_object ( object_id = &me->Loc_env.obj_id,
				    md_env    = &me->Loc_env.mod_env,
				    mode      = GRbd );
	}
	else			goto quit;
}
/******************************************************************************/
