/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLupdateCmd

     ABSTRACT   : I/LOFT updates macros using range query.

     ON ENTRY   : 

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   ------------------------------------


     NOTES	: This command object defines the classe VLupdateCmd.
		  This command updates some I/LOFT macros.


     CHANGE HISTORY : file created 	29-MAR-1994	Marc Fournier
		      file upgraded	06-APR-1994	Marc Fournier
		      file upgraded	02-SEP-1994	Marc Fournier

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_UPDATE_LOFT_MACROS, 0, VLUpLoMa
command_table	"vl.cmd"
class		VLupdateCmd
super_class	VLlocateCmd
product_name	"$LOFT"
form		"VLupdate", 0, 0, "-1", "-1"

start_state	UPDATE

specification

#include	"vlupdate.h"

instance {
                IGRint          MacroList[IDX_UPD_SIZE];
}

implementation

#include        <stdio.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msdef.h"
#include        "msmacros.h"
#include        "cotxmacros.h"
#include        "nddef.h"
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
#include        "nddef.h"
#include        "ndmacros.h"
#include        "FI.h"
#include	"macro.h"
#include	"ACattrib.h"

#include	"vlmsg.h"
#include	"vlglobals.h"
#include	"vlupdate.h"
#include	"vlbook.h"

/*	#define	TRACE	*/

/******************************************************************************/
state_table

#include	"vlmsg.h"
#include	"vlupdate.h"

/******************************************************************************/
state UPDATE
	message_key		VL_S_UPDATE_LOFT_MACROS
	status			" "
	prompt			"Perform form operations"
	execute			VLfillForm (&me->ret)

	on ELSE							state WAIT_FORM
/******************************************************************************/
state WAIT_FORM
	filter			get_event

	on EX_FORM_FINISHED					state GEOM
/******************************************************************************/
state	GEOM
        execute                 VLfreeList ( &me->ret, 1)
	execute			VLnonGeometric (&me->ret)
				on RETURN_CODE = VL_E_FAILURE	state TO_MACRO
				on RETURN_CODE = VL_S_SUCCESS	state COMPUTE
				on ELSE				state UPDATE
/******************************************************************************/
state TO_MACRO
	status			" "
        execute                 VLfreeList ( &me->ret, 1)

	on ELSE							state MACRO
/******************************************************************************/
state MACRO
	prompt_key		VL_P_UPD_ZONE
	accept_key		VL_M_UPD_ZONE
	locate_eligible		"+VLabstract,nci_macro,VLunwObj"
	locate_owner		"LC_RIGID_COMP  | LC_RIGID_OWNER |
				 LC_FLEX_COMP   | LC_FLEX_OWNER  "
	locate_properties	"LC_LC_ONLY | LC_DP_ONLY | LC_RW"
	filter			locate

	on EX_BACK_UP						state TO_MACRO
	on EX_OBJID or EX_DATA	do VLstoreResponse (&me->ret)	state EVENT_MAC
/******************************************************************************/
state EVENT_MAC
	status_key		VL_S_PROCESS
	prompt			" "
	execute			VLstoreLocate (&me->ret)
        execute                 VLfreeList ( &me->ret, 1)
        execute                 VLstoreList ( &me->ret, 0, 1)

	on ELSE							state COMPUTE
/******************************************************************************/
state COMPUTE
	status_key		VL_S_PROCESS
	prompt			" "
        execute                 VLloadCst (&me->ret)
        execute                 VLcomputeMacros
        execute                 VLfreeList ( &me->ret, 1)

        on ELSE			do status_key VL_S_SUCCESS	state terminate
/******************************************************************************/
action form_notification {

		IGRlong		i, sts;
		IGRint		code;
		IGRdouble	value;

	status = OM_S_SUCCESS;

	switch (gadget_label) {

		case FI_ACCEPT:

			for ( i=0; i<IDX_UPD_SIZE; i++)
				FIfld_get_select ( form_ptr, UFS, i, 0,
						   &me->MacroList[i] );
			VLencode ( me->MacroList, IDX_UPD_SIZE, &code);
                        om$send ( msg = message VLlocateCmd.VLmodGlobals
                                        ( &sts, NAM_G_UPD, (IGRdouble)code),
                                  targetid = my_id);

		case FI_CANCEL:

			om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &sts, NAM_G_UPD, &value),
                                  targetid = my_id);
			VLdecode ( (IGRint)value, IDX_UPD_SIZE, me->MacroList);
			for ( i=0; i<IDX_UPD_SIZE; i++)
				FIfld_set_select ( form_ptr, UFS, i, 0,
						   me->MacroList[i]);

			FIf_erase (form_ptr);
                        _put_response (resp = EX_FORM_FINISHED);

			goto quit;
	}
}
/******************************************************************************/
action VLfillForm {

			IGRdouble	value=0.0;

	/* Get global code and set text in form */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
                                        ( &me->ret, NAM_G_UPD, &value),
                  targetid = my_id);
	VLdecode ( (IGRint)value, IDX_UPD_SIZE, me->MacroList);

	/* Reset form */
        FIf_reset (me->forms[0].form_ptr);

	FIfld_set_text ( me->forms[0].form_ptr, UFS, IDX_UPD_BALP, 0,
			 NAM_UPD_BALP, me->MacroList[IDX_UPD_BALP]);
	FIfld_set_text ( me->forms[0].form_ptr, UFS, IDX_UPD_STFT, 0,
			 NAM_UPD_STFT, me->MacroList[IDX_UPD_STFT]);
	FIfld_set_text ( me->forms[0].form_ptr, UFS, IDX_UPD_UNWR, 0,
			 NAM_UPD_UNWR, me->MacroList[IDX_UPD_UNWR]);
	FIfld_set_text ( me->forms[0].form_ptr, UFS, IDX_UPD_PCAV, 0,
			 NAM_UPD_PCAV, me->MacroList[IDX_UPD_PCAV]);
	FIfld_set_text ( me->forms[0].form_ptr, UFS, IDX_UPD_PCAT, 0,
			 NAM_UPD_PCAT, me->MacroList[IDX_UPD_PCAT]);
	FIfld_set_text ( me->forms[0].form_ptr, UFS, IDX_UPD_BOOK, 0,
			 NAM_UPD_BOOK, me->MacroList[IDX_UPD_BOOK]);

	/* Display form */
	FIf_display (me->forms[0].form_ptr);

	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
action VLnonGeometric (	IGRlong	*sts	)
{
	IGRdouble	val;
	IGRint          idx[IDX_UPD_SIZE];

	/* Get the update code */
	status = om$send ( msg = message VLlocateCmd.VLgetGlobals
					( sts, NAM_G_UPD, &val),
                           targetid = my_id);
	as$status ( msg    = "VLlocateCmd.VLgetGlobals(UPD)",
                    action = GOTO_VALUE,
                    value  = quit );
	VLdecode ( (IGRint)val, IDX_UPD_SIZE, idx);

	if (  (!idx[IDX_UPD_BALP]) && (!idx[IDX_UPD_STFT])
	   && (!idx[IDX_UPD_UNWR]) && (!idx[IDX_UPD_PCAV])
	   && (!idx[IDX_UPD_PCAT]) && ( idx[IDX_UPD_BOOK])  )
		*sts = VL_S_SUCCESS;
	else	*sts = VL_E_FAILURE;

	goto quit;
}
/******************************************************************************/
action VLcomputeMacros {

		IGRint		i, j, k, ndef, ntot=0, cn_type=ND_COMP;
		IGRchar		macdef[IDX_UPD_SIZE*DI_PATH_MAX];
		IGRdouble	value;
		IGRchar		path[DI_PATH_MAX], user[DI_PATH_MAX];
		IGRchar		rexp[DI_PATH_MAX];
		IGRint		siz=sizeof(struct GRobj_env);

	/* Get the update code */
	om$send ( msg = message VLlocateCmd.VLgetGlobals
				( sts, NAM_G_UPD, &value),
                  targetid = my_id);
	VLdecode ( (IGRint)value, IDX_UPD_SIZE, me->MacroList);

	/* Discard null input */
	if ((!me->Cnt1) && (!me->MacroList[IDX_UPD_BOOK]))	goto wrapup;

	/* Initialize filter on macro_definition names */
	strcpy ( &macdef[DI_PATH_MAX*IDX_UPD_BALP], DEF_UPD_BALP);
	strcpy ( &macdef[DI_PATH_MAX*IDX_UPD_STFT], DEF_UPD_STFT);
	strcpy ( &macdef[DI_PATH_MAX*IDX_UPD_UNWR], DEF_UPD_UNWR);
	strcpy ( &macdef[DI_PATH_MAX*IDX_UPD_PCAV], DEF_UPD_PCAV);
	strcpy ( &macdef[DI_PATH_MAX*IDX_UPD_PCAT], DEF_UPD_PCAT);
	strcpy ( &macdef[DI_PATH_MAX*IDX_UPD_BOOK], DEF_UPD_BOOK);
	strcpy ( &macdef[DI_PATH_MAX*IDX_UPD_UNWN], DEF_UPD_UNWN);

	if (me->MacroList[IDX_UPD_BOOK]) {
		di$give_pathname ( osnum    = me->Current.md_id.osnum,
				   pathname = path );
		sprintf ( user, "%s:usr", path);
	}

	me->MacroList[IDX_UPD_UNWN] = me->MacroList[IDX_UPD_UNWR];

	/* Filter on macro_definition names */
	for ( i=0; i<IDX_UPD_SIZE; i++) {
		if 	( (i != IDX_UPD_BOOK) && (me->MacroList[i]) ) {
			ndef = 0;
			VLfilterDef ( me->Cnt1 - ntot, &me->Lst1[ntot],
			 		 &ndef, &macdef[DI_PATH_MAX*i]);
			ntot += ndef;
#ifdef TRACE
printf( "%d <%s> macro definition found ...\n", ndef, &macdef[DI_PATH_MAX*i]);
#endif
		}
		else if ( (i == IDX_UPD_BOOK) && (me->MacroList[i]) ) {
			for ( j=0; j<VL_PREP_BOOK_ROW; j++) {
				sprintf ( rexp, "%s:%s:*", user,
					  VLindexToDirName(j) );
				ndef = 0;
				di$start_ls ( regexp  = rexp,
					      ptr     = &ndef,
					      options = OPT_LEVEL );
				if (ndef) {
if (!me->Lst1)	me->Lst1 = om$calloc ( num       = ntot+ndef,
				       structure = struct GRobj_env );
else		me->Lst1 = (struct GRobj_env *)
				om$realloc ( ptr = (IGRchar *)me->Lst1,
					     size = (ntot+ndef) * siz );

					for ( k=0; k<ndef; k++) {
					di$fetch_ls ( line  = path,
						      index = k );
me->Lst1[ntot].obj_id.objid = NULL_OBJID;
me->Lst1[ntot].obj_id.osnum = me->Current.md_id.osnum;
me->Lst1[ntot].mod_env      = me->Current;
di$translate ( objname = path, p_objid = &me->Lst1[ntot].obj_id.objid );
						ntot++;
					}
				}
			}
		}
	}
	if (!ntot)	goto wrapup;

	/* Update Selected macros */
#ifdef TRACE
printf( "%d macros to update ...\n", ntot);
#endif
	for ( i=0; i<ntot; i++)
		nd$wait_batch ( type       = GR_GEOM_POSTED,
				nb_obj     = 1,
				l_object   = &me->Lst1[i].obj_id,
				l_obj_info = &cn_type );
	nd$exec_batch();

wrapup :
	status = OM_S_SUCCESS;
	goto quit;
}
/******************************************************************************/
