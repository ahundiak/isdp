/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLprjTplCmd

     ABSTRACT   : I/LOFT project 3D templates

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLprjTplCmd.
		  This command project 3D templates in 2D position.


     CHANGE HISTORY : file created 	08-DEC-1992     Marc Fournier
                      file modified     14-JAN-1993     Marc Fournier
                      file modified     18-JAN-1993     Marc Fournier
                      file modified     17-MAR-1993     Marc Fournier
                      file modified     09-JUN-1993     Marc Fournier
		      file modified     17-JUN-1993     Marc Fournier
		      file modified     17-AUG-1993     Marc Fournier
		      file upgraded     14-APR-1994     Marc Fournier
		      file modified     01-JUN-1995     Marc Fournier
		      file modified     28-JUN-1995     Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_3D_PROJECT, 0, VLPr3dTe
command_table	"vl.cmd"
class		VLprjTplCmd
super_class	VLtpl2dCmd
product_name	"$LOFT"
status_display  "VLtemplate", "-1", "-1"

start_state	TO_TEMPL

specification

instance {
		IGRint		SpineTpl;
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
#include        "grmacros.h"
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
#include        "FI.h"

#include        "vsmiscmacros.h"

#include	"vlmsg.h"
#include	"vlglobals.h"
#include	"vltemplate.h"
#include        "vlmiscmacros.h"
#include        "vluserkey.h"

from	ACncpx		import	ACfind_exp_temp_obj;
from    ACrg_collect    import  AClist_attribute, ACset_list_attribute;
from	GRowner		import	GRget_number_components;
from	GRvg		import	GRgetname, GRgetsymb, GRputsymb;
from	NDmacro		import	ACgive_structure;
from	NDnode		import	NDchange_connect;
from	expression	import	NDgive_value;

extern	void		qsort();
extern	IGRchar		*strrchr();
extern	IGRint		VLsortName();

/*	#define	TRACE	*/
/*	#define	TRACE_MEMORY	*/

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vltemplate.h"

/******************************************************************************/
state TO_TEMPL
	message_key		VL_S_3D_PROJECT
	status_key		VL_S_STATUS_FORM
	execute			VLfreeList ( &me->ret, 3)

	on ELSE							state TEMPL
/******************************************************************************/
state TEMPL
	prompt_key		VL_P_TEMPLATE_MGR
	accept_key		VL_M_TEMPLATE_MGR
	locate_eligible		"VLtplMgr"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP                                           state TO_TEMPL
        on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_TPL
/******************************************************************************/
state EVENT_TPL
        status_key              VL_S_PROCESS
        prompt			" "
        execute                 VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 3)
        execute                 VLstoreList ( &me->ret, 0, 3)

        on ELSE                                                 state RIB_CS
/******************************************************************************/
state RIB_CS
        status			" "
        prompt_key              VL_P_TPL_COOR_SYS
        accept_key              VL_M_TPL_COOR_SYS
        locate_eligible		"+GRgencs"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP                                           state TO_TEMPL
        on EX_DATA or EX_OBJID  do VLstoreLocate (&me->ret)
				do VLstoreResponse (&me->ret)
                                do VLstoreCoorSyst (&me->ret) state EVALUATE
/******************************************************************************/
state EVALUATE
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLevaluateSpiTemplate (&me->ret)
				on RETURN_CODE = VL_S_SUCCESS
					do status_key VL_S_SUCCESS
								state SPI_CS
				on ELSE
					do status_key VL_E_FAILURE
								state SORT
/******************************************************************************/
state SPI_CS
        status			" "
        prompt_key              VL_P_SPI_COOR_SYS
        accept_key              VL_M_SPI_COOR_SYS
        locate_eligible		"+GRgencs"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_BACK_UP                                           state RIB_CS
        on EX_DATA or EX_OBJID  do VLstoreLocate (&me->ret)
				do VLstoreResponse (&me->ret)
                                do VLstoreSpiCsys (&me->ret) 	state SORT
/******************************************************************************/
state SORT
        status_key              VL_S_PROCESS
        prompt			" "
	execute			VLsortMgr (&me->ret)
	execute			VLunplug (&me->ret)
        execute                 VLfreeList ( &me->ret, 3)
        execute                 VLfreeList ( &me->ret, 1)

        on ELSE                                                 state TO_TEMPL
/******************************************************************************/
action wakeup {

        /* Execute method wakeup of upper class */
	me->StatusDisplay = TRUE;
        me->ret = om$send ( msg      = message VLprjTplCmd.wakeup (pos),
                            mode     = OM_e_wrt_parent,
                            targetid = my_id );
        as$status(sts = me->ret);

        /* Change some fields mode */
        FIfld_set_mode(me->status_display_form_ptr, TF_MD, 0, FI_REVIEW);
        FIfld_set_mode(me->status_display_form_ptr, TF_AX, 0, FI_REVIEW);
        FIfld_set_mode(me->status_display_form_ptr, TF_EX, 0, FI_REVIEW);
        FIfld_set_mode(me->status_display_form_ptr, TF_XM, 0, FI_REVIEW);
        FIg_disable   (me->status_display_form_ptr, TF_BX);
        FIg_disable   (me->status_display_form_ptr, TF_IN);
	FIg_set_text  (me->status_display_form_ptr,TF_TIT,"Project Templates");

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action VLevaluateSpiTemplate {

		IGRint		i, suc, num;
	struct	GRid		attr_id;
	struct	ACrg_coll	attr[NUM_TM_ATTR];

	*sts = VL_E_FAILURE;
	me->SpineTpl = 0;

	for ( i=0; i<me->Cnt3; i++) {

		/* Get <param_box> template */
		status = om$send ( msg      = message ACncpx.ACfind_exp_temp_obj
						(&suc, IDX_TM_ATTR, &attr_id),
				   targetid = me->Lst3[i].obj_id.objid,
				   targetos = me->Lst3[i].obj_id.osnum );
		as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(ATTR)",
                	    test   = (!(status & 0x00000001 & suc)),
               		    action = GOTO_VALUE,
               		    value  = quit );
#ifdef TRACE
printf( "<%s> : (%d|%d)\n", NAM_TM_ATTR, attr_id.osnum, attr_id.objid);
#endif

		/* Get attributes list */
		status = om$send ( msg = message ACrg_collect.AClist_attribute
						( sts, NUM_TM_ATTR, attr, &num),
				   targetid = attr_id.objid,
				   targetos = attr_id.osnum );
		as$status ( msg    = "ACrg_collect.AClist_attribute",
             		    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = quit );
		if (num != NUM_TM_ATTR) {
			printf( "Trouble in ACrg_collect <%s>\n", NAM_TM_ATTR);
			*sts = MSFAIL;
			goto quit; }

		if (attr[IDX_TM_SPIN].desc.value.att_exp == 1.0) {
			*sts = VL_S_SUCCESS;
			me->SpineTpl = 1;
			goto quit;
		}
	}
}
/******************************************************************************/
action VLsortMgr {

			IGRint		i, suc;
	struct		GRid		dummy, VSplate;
	struct		GRobj_env	*Tmgr;
	struct		VLsortTpl	*Sort;
			IGRchar		name[DI_PATH_MAX];

	/* Initialize */
	Sort = NULL;
	Tmgr = NULL;

	/* Allocate memory */
#ifdef TRACE_MEMORY
printf( "om$calloc (%d,<struct VLsortTpl>)\n", me->Cnt3);
#endif
	Sort = om$calloc ( num = me->Cnt3, structure = struct VLsortTpl );

#ifdef TRACE_MEMORY
printf( "om$calloc (%d,<struct GRobj_env>)\n", me->Cnt3);
#endif
	Tmgr = om$calloc ( num = me->Cnt3, structure = struct GRobj_env );

	for ( i=0; i<me->Cnt3; i++) {

		/* Fill Tmgr array */
		Tmgr[i] = me->Lst3[i];

		/* Store index */
		Sort[i].idx = i;

		/* Get <tpl_plate> template */
		status = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
						(&suc, IDX_TM_PLAT, &dummy),
				   targetid = me->Lst3[i].obj_id.objid,
				   targetos = me->Lst3[i].obj_id.osnum );
		*sts = (IGRlong) suc;
		as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(PLAT)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );

		/* Get <tpl_plate> object */
		status = vl$return_foot ( msg    = sts,
	                                  objId  = &dummy,
	                                  footId = &VSplate );
		as$status ( msg    = "vl$return_foot",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );

		/* Get <tpl_plate> name */
		status = om$send ( msg = message GRvg.GRgetname (sts, name),
				   targetid = VSplate.objid,
				   targetos = VSplate.osnum );
		if (!((*sts)&1)) strcpy ( Sort[i].name, "Unknown");
		else		 strcpy ( Sort[i].name, &strrchr(name,':')[1]);
		if (Sort[i].name[0] == '\0')
				 strcpy ( Sort[i].name, "Empty");
	}

	/* Sort template managers by VSplate name */
	qsort ( Sort, me->Cnt3, sizeof(struct VLsortTpl), 
					(int (*)())VLsortName );

	/* Put the sorting result in array 3 */
	for ( i=0; i<me->Cnt3; i++)	me->Lst3[i] = Tmgr[Sort[i].idx];

	*sts = VL_S_SUCCESS;

wrapup:
	if (Tmgr) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Tmgr)\n");
#endif
		om$dealloc (ptr = Tmgr);
		Tmgr = NULL;
	}
	if (Sort) {
#ifdef TRACE_MEMORY
printf( "om$dealloc (ptr = Sort)\n");
#endif
		om$dealloc (ptr = Sort);
		Sort = NULL;
	}
	goto quit;
}
/******************************************************************************/
action VLunplug {

		IGRint		i, suc=OM_S_SUCCESS, num;
	struct	GRid		old_cs[2], new_cs[2], attr_id, dummy;
	struct	ACrg_coll	attr[NUM_TM_ATTR];
		IGRdouble	Bp_num=0.0,Bw_max=0.0,Bx_rng=0.0,By_rng=0.0;
		IGRdouble	Rp_num=0.0,Rw_max=0.0,Rx_rng=0.0,Ry_rng=0.0;
		IGRint		cn_type=ND_COMP;
		IGRdouble	page_h=0, page_w=0, page_s=0;
	struct	GRid		Rbox, Sbox, Tspi;
	struct	GRsymbology	loc_symb;

	/* Initialize */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PGH, &page_h),
                           targetid = my_id);
        as$status ( msg    = "VLlocateCmd.VLgetGlobals(PGH)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );

        status = om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PGW, &page_w),
                           targetid = my_id);
        as$status ( msg    = "VLlocateCmd.VLgetGlobals(PGW)",
                    test   = (!(status & 0x00000001 & (*sts))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Transform located cs in an ASsource */
	as$make_source ( go_grid = me->GrdCsys.obj_id,
			 mod_env = &me->GrdCsys.mod_env,
			 as_os   = me->Current.md_id.osnum,
			 as_grid = &new_cs[0] );
#ifdef TRACE
printf( "\nCoordinate system : (%d|%d) --> (%d|%d)\n",
	me->GrdCsys.obj_id.osnum, me->GrdCsys.obj_id.objid,
	new_cs[0].osnum, new_cs[0].objid );
#endif

	if (me->SpineTpl) {
		as$make_source ( go_grid = me->SpineRef.obj_id,
			 	 mod_env = &me->SpineRef.mod_env,
			 	 as_os   = me->Current.md_id.osnum,
			 	 as_grid = &new_cs[1] );
#ifdef TRACE
printf( "\nCoordinate system : (%d|%d) --> (%d|%d)\n",
	me->SpineRef.obj_id.osnum, me->SpineRef.obj_id.objid,
	new_cs[1].osnum, new_cs[1].objid );
#endif
	}

	for ( i=0; i<me->Cnt3; i++) {

		/* Get <tpl_csys> template ("plug" text expression) */
		status = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
						(&suc, IDX_TM_R_CS, &old_cs[0]),
				   targetid = me->Lst3[i].obj_id.objid,
				   targetos = me->Lst3[i].obj_id.osnum );
		as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(CSYS)",
                	    test   = (!(status & 0x00000001 & suc)),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
#ifdef TRACE
printf( "<%s> : (%d|%d)\n", NAM_TM_R_CS, old_cs[0].osnum, old_cs[0].objid);
#endif

		/* Get <spi_csys> template ("plug" text expression) */
		status = om$send ( msg = message ACncpx.ACfind_exp_temp_obj
						(&suc, IDX_TM_B_CS, &old_cs[1]),
				   targetid = me->Lst3[i].obj_id.objid,
				   targetos = me->Lst3[i].obj_id.osnum );
		as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(B_CS)",
                	    test   = (!(status & 0x00000001 & suc)),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
#ifdef TRACE
printf( "<%s> : (%d|%d)\n", NAM_TM_B_CS, old_cs[1].osnum, old_cs[1].objid);
#endif

		/* Get <param_box> template */
		status = om$send ( msg      = message ACncpx.ACfind_exp_temp_obj
						(&suc, IDX_TM_ATTR, &attr_id),
				   targetid = me->Lst3[i].obj_id.objid,
				   targetos = me->Lst3[i].obj_id.osnum );
		as$status ( msg    = "ACncpx.ACfind_exp_temp_obj(ATTR)",
                	    test   = (!(status & 0x00000001 & suc)),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
#ifdef TRACE
printf( "<%s> : (%d|%d)\n", NAM_TM_ATTR, attr_id.osnum, attr_id.objid);
#endif

		/* Get attributes list */
		status = om$send ( msg = message ACrg_collect.AClist_attribute
						( sts, NUM_TM_ATTR, attr, &num),
				   targetid = attr_id.objid,
				   targetos = attr_id.osnum );
		as$status ( msg    = "ACrg_collect.AClist_attribute",
             		    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		if (num != NUM_TM_ATTR) {
			printf( "Trouble in ACrg_collect <%s>\n", NAM_TM_ATTR);
			*sts = MSFAIL;
			goto wrapup; }

		/* Change some attributes value */
		status = om$send ( msg = message VLlocateCmd.VLgetGlobals
                                                ( sts, NAM_G_PGS, &page_s),
                         	   targetid = my_id);
		as$status ( msg    = "VLlocateCmd.VLgetGlobals",
             		    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );

		/* The last template-manager must generate a template-box */
		if (i == (me->Cnt3-1))
			attr[IDX_TM_FULL].desc.value.att_exp = -1.0;
		else	attr[IDX_TM_FULL].desc.value.att_exp =  1.0;

		attr[IDX_TM_SCAL].desc.value.att_exp = page_s;
		attr[IDX_TM_PGH].desc.value.att_exp  = page_h;
		attr[IDX_TM_PGW].desc.value.att_exp  = page_w;
		attr[IDX_TM_RPNI].desc.value.att_exp = Rp_num;
		attr[IDX_TM_RWMI].desc.value.att_exp = Rw_max;
		attr[IDX_TM_RXRI].desc.value.att_exp = Rx_rng;
		attr[IDX_TM_RYRI].desc.value.att_exp = Ry_rng;
		attr[IDX_TM_BPNI].desc.value.att_exp = Bp_num;
		attr[IDX_TM_BWMI].desc.value.att_exp = Bw_max;
		attr[IDX_TM_BXRI].desc.value.att_exp = Bx_rng;
		attr[IDX_TM_BYRI].desc.value.att_exp = By_rng;
	
		/* Set attributes list */
		status = om$send (
			 msg = message ACrg_collect.ACset_list_attribute
						( sts, NUM_TM_ATTR, attr),
			 targetid = attr_id.objid,
			 targetos = attr_id.osnum );
		as$status ( msg    = "ACrg_collect.ACset_list_attribute",
             		    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );

		/* Connect the sources cs intead of "plug" */
		if (attr[IDX_TM_SPIN].desc.value.att_exp == 1.0)
			status = om$send ( msg = message NDnode.NDchange_connect
							( 2, old_cs, new_cs),
				   	   targetid = me->Lst3[i].obj_id.objid,
				   	   targetos = me->Lst3[i].obj_id.osnum);
		else	status = om$send ( msg = message NDnode.NDchange_connect
							( 1, old_cs, new_cs),
				   	   targetid = me->Lst3[i].obj_id.objid,
				   	   targetos = me->Lst3[i].obj_id.osnum);

		as$status ( msg    = "NDnode.NDchange_connect",
                	    action = GOTO_VALUE,
                	    value  = wrapup );

		/* Set working object space ID instead of NULL_OBJID */
		me->Lst3[i].mod_env.md_id.objid = me->Current.md_id.objid;

		/* Put ci_macro in the batch queue */
		nd$wait_batch ( type	   = GR_GEOM_POSTED,
				nb_obj	   = 1,
				l_object   = &me->Lst3[i].obj_id,
				l_obj_info = &cn_type );

		/* Execute batch */
		nd$exec_batch ();

		/* Retrieve Page Number */
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_BPNO,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &dummy );
		as$status ( msg    = "vl$return_foot(BPNO)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		status = om$send ( msg = message expression.NDgive_value
							(&Bp_num),
				   targetid = dummy.objid,
				   targetos = dummy.osnum );
		as$status ( msg    = "expression.NDgive_value(BPNO)",
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Retrieve Width Max */
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_BWMO,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &dummy );
		as$status ( msg    = "vl$return_foot(BWMO)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		status = om$send ( msg = message expression.NDgive_value
							(&Bw_max),
				   targetid = dummy.objid,
				   targetos = dummy.osnum );
		as$status ( msg    = "expression.NDgive_value(BWMO)",
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Retrieve X range */
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_BXRO,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &dummy );
		as$status ( msg    = "vl$return_foot(BXRO)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		status = om$send ( msg = message expression.NDgive_value
							(&Bx_rng),
				   targetid = dummy.objid,
				   targetos = dummy.osnum );
		as$status ( msg    = "expression.NDgive_value(BXRO)",
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Retrieve Y range */
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_BYRO,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &dummy );
		as$status ( msg    = "vl$return_foot(BYRO)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		status = om$send ( msg = message expression.NDgive_value
							(&By_rng),
				   targetid = dummy.objid,
				   targetos = dummy.osnum );
		as$status ( msg    = "expression.NDgive_value(BYRO)",
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Retrieve Page Number */
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_RPNO,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &dummy );
		as$status ( msg    = "vl$return_foot(RPNO)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		status = om$send ( msg = message expression.NDgive_value
							(&Rp_num),
				   targetid = dummy.objid,
				   targetos = dummy.osnum );
		as$status ( msg    = "expression.NDgive_value(RPNO)",
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Retrieve Width Max */
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_RWMO,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &dummy );
		as$status ( msg    = "vl$return_foot(RWMO)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		status = om$send ( msg = message expression.NDgive_value
							(&Rw_max),
				   targetid = dummy.objid,
				   targetos = dummy.osnum );
		as$status ( msg    = "expression.NDgive_value(RWMO)",
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Retrieve X range */
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_RXRO,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &dummy );
		as$status ( msg    = "vl$return_foot(RXRO)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		status = om$send ( msg = message expression.NDgive_value
							(&Rx_rng),
				   targetid = dummy.objid,
				   targetos = dummy.osnum );
		as$status ( msg    = "expression.NDgive_value(RXRO)",
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Retrieve Y range */
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_RYRO,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &dummy );
		as$status ( msg    = "vl$return_foot(RYRO)",
                	    test   = (!(status & 0x00000001 & (*sts))),
               		    action = GOTO_VALUE,
               		    value  = wrapup );
		status = om$send ( msg = message expression.NDgive_value
							(&Ry_rng),
				   targetid = dummy.objid,
				   targetos = dummy.osnum );
		as$status ( msg    = "expression.NDgive_value(RYRO)",
			    action = GOTO_VALUE,
			    value  = wrapup );

		/* Set wright symbology to evanescent feet */
		Rbox.objid = Sbox.objid = Tspi.objid = NULL_OBJID;
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_RBOX,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &Rbox );
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_SBOX,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &Sbox );
		status = vl$return_foot ( msg    = sts,
					  name   = NAM_TM_TSPI,
	                                  objId  = &me->Lst3[i].obj_id,
	                                  footId = &Tspi );

		if (  (Rbox.objid != NULL_OBJID)
		   || (Sbox.objid != NULL_OBJID)
		   || (Tspi.objid != NULL_OBJID) ) {

			/* Get symbology from template-manager */
			status =  om$send ( msg = message GRvg.GRgetsymb
							( sts, &loc_symb),
				  targetid = me->Lst3[i].obj_id.objid,
				  targetos = me->Lst3[i].obj_id.osnum );
			as$status ( msg    = "GRvg.GRgetsymb",
	                	    test   = (!(status & 0x00000001 & (*sts))),
	               		    action = GOTO_VALUE,
	               		    value  = wrapup );

			/* Set symbology of rib-box-manager */
			if (Rbox.objid != NULL_OBJID) {
				om$send ( msg = message GRvg.GRputsymb
						( sts, &loc_symb),
					  targetid = Rbox.objid,
					  targetos = Rbox.osnum );
				gr$display_object ( object_id = &Rbox,
						    md_env    = &me->Current);
			}

			/* Set symbology of spine-box-manager */
			if (Sbox.objid != NULL_OBJID) {
				om$send ( msg = message GRvg.GRputsymb
						( sts, &loc_symb),
					  targetid = Sbox.objid,
					  targetos = Sbox.osnum );
				gr$display_object ( object_id = &Sbox,
						    md_env    = &me->Current);
			}

			/* Set symbology of spine-template-box-manager */
			if (Tspi.objid != NULL_OBJID) {
				om$send ( msg = message GRvg.GRputsymb
						( sts, &loc_symb),
					  targetid = Tspi.objid,
					  targetos = Tspi.osnum );
				gr$display_object ( object_id = &Tspi,
						    md_env    = &me->Current);
			}
		}
	}

	*sts = VL_S_SUCCESS;

wrapup :
	if (!(0x00000001 & suc))	*sts = (IGRlong) suc;
	goto quit;
}
/******************************************************************************/
