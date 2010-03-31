
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:42:01 $
$Locker:  $
*/

class implementation Root;

#define CHECK_RETURN_CODES 1

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <alloca.h>

#include "bs.h"
#include "bsparameters.h"

#include "OMerrordef.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdp.h"

#include "exdef.h"
#include "ex.h"
#include "exmacros.h"

#include "gr.h"

#include "igewindef.h"
#include "igewinmacros.h"

#include "dpstruct.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"

#include "godef.h"
#include "go.h"

#include "EMSopt.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h"

#include "vedef.h"
#include "ve.h"
#include "ve_inst.h"
#include "vewinmacros.h"
#include "vedpbmacros.h"
#include "veerr.h"

/* Global Variables Used By VE */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEresults_info     VEoutput_data;
extern struct GRmd_env           VEmaster_env;

/* prototype files */
%safe
#include "VEpr_utilfnc.h"
#include "VEpr_utilimp.h"
#include "VEpr_driver.h"
#include "VEpr_gragad.h"
#include "VEpr_dpb.h"

#include "DPsetinq.h"
#include "DPgetggid.h"
#include "EMdmfunc.h"
#include "GRdpbfunc.h"

/* prototypes for static functions */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

static OM_S_OBJID VEcompress_dpr_tree __((
					struct GRid        *elem,
					OMuword            elem_classid,
					struct GRmd_env    *batch_env ));

static void VEfix_layers __((		struct GRid        *new_elem,
					struct VEenv_info  *env,
					IGRboolean         composite ));

#if defined(__cplusplus)
}
#endif

#undef __
%endsafe

/* Global Variables Used By VE */
extern struct VEexecution_parms  VEexec_parms;
extern struct VEexecution_status VEexec_status;
extern struct VEresults_info     VEoutput_data;
extern struct GRmd_env           VEmaster_env;


from GRdpb        import GRput;
from IGEgadget    import change_gadget_size;
from GRvg         import GRconstruct;
from GRgraphics   import GRcopy;
from GRvg         import GRchglevel;
from GRvg         import GRgetsymb;
from EMSdpr       import EMmake_primitive1;
from EMSdatplnmgr import EMget_datums;
from EMSdatpln    import EMtoggle_on_off;

/* External Variables */
extern OMuword OPP_EMSdpr_class_id;


/* macro to send a GRput message to the DPB in the batch object space */
#define SEND_DPB_PUT( parm, var )                                           \
	                                                                    \
	sts = om$send( msg      = message GRdpb.GRput( &msg,                \
	                                               (parm),              \
	                                               (IGRchar *) (var) ), \
	               targetid = dpb_id,                                   \
	               targetos = dpb_os,                                   \
	               senderid = NULL_OBJID );                             \


/*--- VEget_needed_ids --------------------------------------------------------*/

IGRboolean VEget_needed_ids( gragad_name, gragad, invis_module, parent, invis_gragad, invis_parent )

	IGRchar     *gragad_name;
	struct GRid *gragad;
	struct GRid *invis_module;
	struct GRid *parent;
	struct GRid *invis_gragad;
	struct GRid *invis_parent;

/*
NAME
	VEget_needed_ids

DESCRIPTION
	This function gets the gragad and window id's required to transfer
	the data from the current object space to the invisible one.

PARAMETERS
	gragad_name (IN) - name of gragad that batch job is being submitted
	                   from
	gragad (IN) - the GRid of the gragad that the batch job is being
	              submitted from
	invis_module (IN) - module GRid of the invisible object space
	parent (OUT) - the GRid of the parent window of the gragad that the
	               job is being submitted from
	invis_gragad (IN) - the GRid of the gragad in the invisible object
	                    space that will be used
	invis_parent (IN) - the GRid of the parent window of the gragad in
	                    the invisible object space

GLOBALS USED
	none

RETURN VALUES
	TRUE - if everything was o.k.
	FALSE - if a failure occurec

HISTORY
	8/22/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong             sts;
	IGRlong             msg;
	IGRint              num_id;
	OMuint              number_on_channel;
	IGRint             total_found;
	struct GRid         win_ids[40];
	OM_S_OBJECT_LINKAGE vw_list[1];
	OM_S_CHANSELECT     parent_chandef;


	/* see if the seed file has a gragad with the name we want */
	dp$get_gragad_id( msg         = &msg,
	                  name        = gragad_name,
                          array_size  = 40,
                          total_num   = &total_found,
	                  numberofids = &num_id,
	                  found_GRids = win_ids,
	                  type_gragad = ALL_TYPES,
	                  mod_GRid    = invis_module );

	   MSG_ERRCHK( msg, "VEget_needed_ids:  dp$get_gragad_id failed" );
	
	if ( num_id == 0 )
	   {
	   /* seed file doesn't have a gragad with the name we want => get the */
	   /* id of any one of the invisible module's gragads                  */
	   dp$get_gragad_id( msg         = &msg,
	                     name        = "*",
                             array_size  = 40,
                             total_num   = &total_found,
	                     numberofids = &num_id,
	                     found_GRids = win_ids,
	                     type_gragad = ALL_TYPES,
	                     mod_GRid    = invis_module );

	      MSG_ERRCHK( msg, "VEget_needed_ids:  dp$get_gragad_id failed" );

	   if ( num_id == 0 )
	      return( FALSE );
	   }

	invis_gragad->objid = win_ids[0].objid;
	invis_gragad->osnum = win_ids[0].osnum;

	om$make_chanselect( channame     = "IGEgadget.to_parent",
	                    p_chanselect = &parent_chandef );

	/* get the parent window of the VE gragad */
	sts = om$get_channel_objects( objid        = gragad->objid,
	                              osnum        = gragad->osnum,
	                              p_chanselect = &parent_chandef,
	                              list         = vw_list,
	                              size         = 1,
	                              count        = &number_on_channel );

	   OM_ERRCHK( sts, "VEget_needed_ids: om$get_channel_objects failed" );

	parent->objid = vw_list[0].S_objid;
	parent->osnum = vw_list[0].osnum;

	/* get the parent window of the inivisible module's gragad */
	sts = om$get_channel_objects( objid        = invis_gragad->objid,
	                              osnum        = invis_gragad->osnum,
	                              p_chanselect = &parent_chandef,
	                              list         = vw_list,
	                              size         = 1,
	                              count        = &number_on_channel );

	   OM_ERRCHK( sts, "VEget_needed_ids: om$get_channel_objects failed" );

	invis_parent->objid = vw_list[0].S_objid;
	invis_parent->osnum = vw_list[0].osnum;

	return( TRUE );
	}  /* VEget_needed_ids */


/*--- VEsetup_invis_ve_gragad ---------------------------------------------------*/

void VEsetup_invis_ve_gragad( gragad, invis_gragad, parent, invis_parent )

	struct GRid *gragad;
	struct GRid *invis_gragad;
	struct GRid *parent;
	struct GRid *invis_parent;

/*
NAME
	VEsetup_invis_ve_gragad

DESCRIPTION
	This function makes the default VE gragad in the invisible module
	an exact copy of the VE gragad in the current object space by copying
	all of the instance data.  It also copies the dependent extents from
	the parent window in the current object space so the default VE gragad
	will have the same size and position on the screen.

PARAMETERS
	gragad (IN) - gragad GRid in master file
	invis_gragad (IN) - gragad GRid in invisible module
	parent (IN) - parent window GRid in master file
	invis_parent (IN) - parent window GRid in invisible module

GLOBALS USED
	VEexec_parms
	VEoutput_data

HISTORY
	8/22/88    S.P. Rogers
	   Creation date
*/

	{
	IGRlong             sts;
	IGRlong             msg;
	IGRchar             gragad_name[GRNAME_SIZE];
	IGRint              dep_extents[4];
	IGRint              *layer_mask;
	IGRint              win_flags[2];
	IGRlong             ret_bytes;
	IGRlong             which_error;
	struct var_list     var_list[3];
	struct VEbatch_info batch_info;
	struct gragad_inst  gragad_instance_data;

	ve$make_win_ve( msg = &msg,
	                win_id = invis_gragad->objid,
	                win_os = invis_gragad->osnum,
	                display_message = FALSE );

	/* get the wireframe instance data of the gragad and store */
	/* it in the VE gragad in the invisible module             */
	var_list[0].var            = GRAGAD_INST_STRUCT;
	var_list[0].var_ptr        = (IGRchar *) &gragad_instance_data;
	var_list[0].num_bytes      = sizeof( struct gragad_inst );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = GRAGAD_NAME;
	var_list[1].var_ptr        = gragad_name;
	var_list[1].num_bytes      = sizeof( gragad_name );
	var_list[1].bytes_returned = &ret_bytes;
	var_list[2].var            = END_PARAM;

	dp$inq_set_gragad( msg          = &msg,
	                   inq0_set1    = 0,
	                   osnum        = gragad->osnum,
	                   gragad_objid = gragad->objid,
	                   which_error  = &which_error,
	                   var_list     = var_list );

	    MSG_ERRCHK( msg, "VEsetup_invis_ve_gragad: dp$inq_set_gragad failed" );

	/* turn on the visible layer, the hidden layer and the displayed layer */
	/* in the batch gragad                                                 */
	layer_mask = gragad_instance_data.gragad.levels;

	/* first turn off all layers */
	memset( layer_mask, 0, sizeof( IGRint ) * 32 );

	/* turn visible & hidden layers on */
	layer_mask[ VEoutput_data.visible_level >> 5 ] |=
	                             1 << (VEoutput_data.visible_level % 32);
	
	if ( ( (unsigned short) VEoutput_data.hidden_level ) != NO_HIDDEN_OUTPUT )
	   {
	   layer_mask[ VEoutput_data.hidden_level >> 5 ] |=
	                                1 << (VEoutput_data.hidden_level % 32);
	
	   }

	/* turn displayed layer on */
	layer_mask[ VEexec_parms.displayed_layer >> 5 ] |=
	                                1 << (VEexec_parms.displayed_layer % 32);

	dp$inq_set_gragad( msg          = &msg,
	                   inq0_set1    = 1,
	                   osnum        = invis_gragad->osnum,
	                   gragad_objid = invis_gragad->objid,
	                   which_error  = &which_error,
	                   var_list     = var_list );

	    MSG_ERRCHK( msg, "VEsetup_invis_ve_gragad: dp$inq_set_gragad failed" );

	/* clear the ACTIVE bit in the gragad's parent window so it doesn't */
	/* try to update when the dependent extents are changed             */
	var_list[0].var            = WINDOW_FLAGS;
	var_list[0].var_ptr        = (IGRchar *) win_flags;
	var_list[0].num_bytes      = sizeof( IGRint ) * 2;
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	win_flags[0] = WIN_IS_ACTIVE;
	win_flags[1] = 0;

	ige$inq_set_window( msg          = &msg,
	                    inq0_set1    = 1,
	                    osnum        = invis_parent->osnum,
	                    window_objid = invis_parent->objid,
	                    which_error  = &which_error,
	                    var_list     = (struct win_var_list *)var_list );

	    MSG_ERRCHK( msg, "VEsetup_invis_ve_gragad: ige$inq_set_window failed" );

	/* get the dependent extents of the gragad's parent window in the   */
	/* master file and store it in the invisible module's parent window */
	var_list[0].var            = WINDOW_DEP;
	var_list[0].var_ptr        = (IGRchar *) dep_extents;
	var_list[0].num_bytes      = sizeof( dep_extents );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	ige$inq_set_window( msg          = &msg,
	                    inq0_set1    = 0,
	                    osnum        = parent->osnum,
	                    window_objid = parent->objid,
	                    which_error  = &which_error,
	                    var_list     = (struct win_var_list *)var_list );

	    MSG_ERRCHK( msg, "VEsetup_invis_ve_gragad: ige$inq_set_window failed" );


	sts = om$send( msg  = message IGEgadget.change_gadget_size( &msg,
	                                                            IGE_DEPENDENT,
	                                                            (IGRdouble) dep_extents[0],
	                                                            (IGRdouble) dep_extents[1],
	                                                            (IGRdouble) dep_extents[2],
	                                                            (IGRdouble) dep_extents[3] ),
	               targetid = invis_parent->objid,
	               targetos = invis_parent->osnum,
	               senderid = NULL_OBJID );

	   OM_ERRCHK( sts, "VEsetup_invis_ve_gragad: IGEgadget.change_gadget_size send failed" );
	   MSG_ERRCHK( msg, "VEsetup_invis_ve_gragad: IGEgadget.change_gadget_size  failed" );

	ve$copy_dpb_data_to_other_os( osnum = invis_gragad->osnum );

	/* copy the VE instance data from the gragad in the  */
	/* master file to the gragad in the invisible module */
	var_list[0].var            = VE_BATCH_INFO;
	var_list[0].var_ptr        = (IGRchar *) &batch_info;
	var_list[0].num_bytes      = sizeof( struct VEbatch_info );
	var_list[0].bytes_returned = &ret_bytes;
	var_list[1].var            = END_PARAM;

	ve$get_window_instance_data( msg = &msg, win_id = gragad->objid, win_os = gragad->osnum,
	                             which_error = &which_error, var_list = var_list );

	/* Change the batch information in the window to only contain this job. */
	/* This job is the last one in the VLA of submitted jobs.               */
	if ( batch_info.num_jobs > 1 )
	   {
	   memcpy( &batch_info.job_info[0],
	           &batch_info.job_info[batch_info.num_jobs - 1],
	           sizeof( struct VEjob_info ) );
	   batch_info.num_jobs = 1;
	   }

	ve$set_window_instance_data( msg = &msg, win_id = invis_gragad->objid, win_os = invis_gragad->osnum,
	                             which_error = &which_error, var_list = var_list );

	if ( batch_info.job_info )
	   free( (IGRchar *) batch_info.job_info );

	}  /* VEsetup_invis_ve_gragad */


/*--- VEcopy_dpb_info ---------------------------------------------------*/

void VEcopy_dpb_info( invis_module )

	struct GRid *invis_module;

/*
NAME
	VEcopy_dpb_info

DESCRIPTION
	This function copies all of the DPB data required to run Visible
	Edges in the invisible module the same way it would run in the
	current object space.

	The data that is currently copied is:

	   Chord Height Tolerance
	   Offset Tolerance
	   Basis Tolerance
	   Arclength Tolerance
	   Maximum Step Size
	   Active Layer
	   Active Display

PARAMTERS
	invis_module (IN) - GRid of the module object in the invisible module

GLOBALS USED
	VEoutput_data

HISTORY
	8/22/88    S.P. Rogers
	   Creation date
*/

	{
	IGRlong           sts;
	IGRint            msg;
	IGRboolean        temp_boolean;
	IGRdouble         temp_double;
	struct IGRdisplay active_display;
	struct GRhesym    edge_sym;
	OM_S_OBJID        dpb_id;
	OMuword           dpb_os;

	/* get the id of the GRdpb in the invis module */
	ex$get_super( mod_id      = invis_module->objid,
	              mod_osnum   = invis_module->osnum,
	              super_name  = "GRdpb",
	              create      = FALSE,
	              super_class = "GRdpb",
	              super_id    = &dpb_id,
	              super_osnum = &dpb_os );

	gr$get_chord_height_tolerance( msg = &msg, buffer = (IGRchar *)&temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: gr$get_chord_height_tolerance failed" );

	SEND_DPB_PUT( grdpb_chord_height_tolerance, &temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (CHT) failed" );

	gr$get_offset_tolerance( msg = &msg, buffer = (IGRchar *)&temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: gr$get_offset_tolerance failed" );

	SEND_DPB_PUT( grdpb_offset_tolerance, &temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (OFFSET) failed" );

	gr$get_arclength_tolerance( msg = &msg, buffer = (IGRchar *)&temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: gr$get_arclength_tolerance failed" );

	SEND_DPB_PUT( grdpb_arclength_tolerance, &temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (ARCLEN) failed" );

	gr$get_basis_tolerance( msg = &msg, buffer = (IGRchar *)&temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: gr$get_basis_tolerance failed" );

	SEND_DPB_PUT( grdpb_basis_tolerance, &temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (BASTOL) failed" );

	gr$get_maximum_step_size( msg = &msg, buffer = (IGRchar *)&temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: gr$get_maximum_step_size failed" );

	SEND_DPB_PUT( grdpb_maximum_step_size, &temp_double );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (STEP) failed" );

	gr$get_active_display( msg = &msg, buffer = (IGRchar *)&active_display );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: gr$get_active_display failed" );

	SEND_DPB_PUT( grdpb_active_display, &active_display );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (DISPLAY) failed" );

	gr$get_hidden_edge_sym( msg = &msg, buffer = (IGRchar *)&edge_sym );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: gr$get_hidden_edge_sym failed" );

	SEND_DPB_PUT( grdpb_hesym, &edge_sym );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (HIDDEN EDGE SYM) failed" );

	gr$get_visible_edge_sym( msg = &msg, buffer = (IGRchar *)&edge_sym );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: gr$get_visible_edge_sym failed" );

	SEND_DPB_PUT( grdpb_visible_edge_sym, &edge_sym );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (VISIBLE EDGE SYM) failed" );

	gr$get_hidden_so_on( msg = &msg, buffer = (IGRchar *)&temp_boolean );

	SEND_DPB_PUT( grdpb_hidden_so_on, &temp_boolean );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (VISIBLE EDGE SYM) failed" );

	/* set active level to be the visible output level */
	SEND_DPB_PUT( grdpb_active_level, &VEoutput_data.visible_level );

	   MSG_ERRCHK( msg, "VEcopy_dpb_info: GRdpb.GRput  (LAYER) failed" );

	}  /* VEcopy_dpb_info */


/*---- VEcompress_dpr_tree -----------------------------------------------------------------*/

static OM_S_OBJID VEcompress_dpr_tree( 	struct GRid     *elem,
					OMuword         elem_classid,
					struct GRmd_env *batch_env )
/*
NAME
	VEcompress_dpr_tree (static)

DESCRIPTION
	This function compresses the state tree for a DPR object in
	the batch object space.  This is done to make the size of the
	batch object space smaller.  If the state tree was compressed,
	this function returns the object id of the new top-level DPR
	object.  If the state tree wasn't compressed, this function
	returns the input object id.

PARAMETERS
	elem (IN) - the element to compress
	elem_classid (IN) - the class id of the element
	batch_env (IN) - the module environment for the element in the
	                 invisible module

RETURN VALUES
	The object id of the compress solid is returned.  If a compress
	was not possible, the object id of the original element is
	returned.

GLOBALS USED
	none

HISTORY
	11/30/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong     sts;
	IGRlong     msg;
	struct GRid new_id;

	if ( om$is_ancestry_valid( subclassid   = elem_classid,
	                           superclassid = OPP_EMSdpr_class_id ) == OM_S_SUCCESS )
	   {
	   /* EMSdpr is in the ancestry of this object => try */
	   /* to compress the DPR state tree                  */
	   sts = om$send( msg      = message EMSdpr.EMmake_primitive1( &msg,
	                                                               batch_env,
	                                                               &new_id ),
	                  senderid = NULL_OBJID,
	                  targetid = elem->objid,
	                  targetos = elem->osnum );

	      OM_ERRCHK( sts, "VEcompress_dpr_tree: EMSdpr.EMmake_primitive1 send failed" );
	      MSG_ERRCHK( msg, "VEcompress_dpr_tree: EMSdpr.EMmake_primitive1 failed" );
	
	   if ( ( 1 & sts & msg ) )
	      return( new_id.objid );  /* compress succeeded */
	   else 
	      return( elem->objid );   /* compress failed */
	   }

	return( elem->objid );

	}  /* VEcompress_dpr_tree */
	

/*---- VEfix_layers ---------------------------------------------------------------------*/

static void VEfix_layers( 	struct GRid        *new_elem,
				struct VEenv_info  *env,
				IGRboolean         composite )

/*
NAME
	VEfix_layers (static)

DESCRIPTION
	This function moves the elements copied to the batch object space
	to levels so they can be processed correctly.  If the element is a
	composite object, each component is checked individually to see if
	it is on a displayed layer in its environment.  If it is, it is moved
	to a layer that is known to be on in the batch object space.  If it
	isn't, it is moved to a layer that is known to be off in the batch
	object space.  If the element is not a composite, it is moved to a
	layer designated for its environment.

PARAMETERS
	new_elem (IN) - the element whose layer is to be changed
	env (IN) - the environment for the element
	composite (IN) - TRUE, if the element is a composite element

GLOBALS USED
	VEexec_parms
	
HISTORY
	11/23/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong            sts;
	IGRlong            msg;
	IGRint             ii;
	IGRint             comp_count;
	struct GRid        *comp_ids;
	struct GRsymbology symb;

	if ( composite )
	   {
	   /* this element is a composite object => change the layer of */
	   /* each component individually depending on whether it was   */
	   /* originally on a displayed layer or not                    */

	   /* get the components of the composite */
	   comp_count = 0;
	   VEget_components( new_elem, &comp_count, NULL );
	   comp_ids = (struct GRid *) alloca( comp_count * sizeof( struct GRid ) );
	   VEget_components( new_elem, &comp_count, comp_ids );

	   for ( ii = 0; ii < comp_count; ii++ )
	      {
	      /* get the layer of this component */
	      sts = om$send( msg      = message GRvg.GRgetsymb( &msg, &symb ),
	                     targetid = comp_ids[ii].objid,
	                     targetos = comp_ids[ii].osnum,
	                     senderid = NULL_OBJID );

	         OM_ERRCHK( sts, "VEfix_layers:  GRvg.GRgetsymb send failed" );
	         MSG_ERRCHK( msg, "VEfix_layers:  GRvg.GRgetsymb failed" );

	      if ( ( (1 << (symb.level % 32) ) & env->layers[symb.level >> 5] ) )
	         {
	         /* component is on a displayed layer => move to displayed layer */
	         sts = om$send( msg      = message GRvg.GRchglevel( &msg,
	                                                            &VEexec_parms.displayed_layer ),
	                        targetid = comp_ids[ii].objid,
	                        targetos = comp_ids[ii].osnum,
	                        senderid = NULL_OBJID );

   	            OM_ERRCHK( sts, "VEfix_layers:  GRvg.GRchglevel send failed" );
	            MSG_ERRCHK( msg, "VEfix_layers:  GRvg.GRchglevel failed" );
	         }
	      else
	         {
	         /* component is on a non-displayed layer => move to non-displayed layer */
	         sts = om$send( msg      = message GRvg.GRchglevel( &msg,
	                                                            &VEexec_parms.non_displayed_layer ),
	                        targetid = comp_ids[ii].objid,
	                        targetos = comp_ids[ii].osnum,
	                        senderid = NULL_OBJID );

	            OM_ERRCHK( sts, "VEfix_layers:  GRvg.GRchglevel send failed" );
	            MSG_ERRCHK( msg, "VEfix_layers:  GRvg.GRchglevel failed" );
	         }

	      }  /* end: for ( ii ... ) */

	   }  /* end: if ( composite ) */
	else
	   {
	   /* element isn't a composite => put it on the displayed layer */
	   sts = om$send( msg      = message GRvg.GRchglevel( &msg,
	                                                      &VEexec_parms.displayed_layer ),
	                  targetid = new_elem->objid,
	                  targetos = new_elem->osnum,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "VEfix_layers:  GRvg.GRchglevel send failed" );
	      MSG_ERRCHK( msg, "VEfix_layers:  GRvg.GRchglevel failed" );
	   }

	}  /* VEfix_layers */

	
/*---- VEcopy_for_batch -------------------------------------------*/

void VEcopy_for_batch(  struct GRid     *elem,
			OMuword         elem_classid,
			IGRmatrix       matrix,
			IGRshort        matrix_type,
			struct GRmd_env *batch_env,
			IGRboolean      composite )
	
/*
NAME
	VEcopy_for_batch

DESCRIPTION
	This function copies an element that was specified for VE processing
	to the object space that will be used for the background job.

PARAMETERS
	elem (IN) - the element to copy
	elem_classid (IN) - the class id of the element
	matrix (IN) - environment matrix for the element
	matrix_type (IN) - environment matrix type
	batch_env (IN) - module environment for the invisible module
	composite (IN) -  - TRUE, if the element is a composite element

GLOBALS USED
	VEmaster_env
	VEexec_parms

HISTORY
	8/22/88    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong              sts;
	IGRlong              msg;
	OM_S_OBJID           new_id;
	struct VEsort_record *sort_rec;
	struct VEenv_info    *env;
	struct GRid          new_elem;
	struct GRmd_env      obj_env;

	env = VEget_environment_info( elem->osnum, matrix, matrix_type, &VEmaster_env, TRUE, batch_env );

	sort_rec = (struct VEsort_record *) malloc( sizeof( struct VEsort_record ) );

	sort_rec->objid = elem->objid;
	sort_rec->env   = env;

	/* add this element to the sort structure => if the element was  */
	/* already there, FALSE is returned and we don't need to copy it */
	if ( VEsort_by_objid( sort_rec ) )
	   {
	   /* copy element to background object space because it wasn't */
	   /* already in the sort structure                             */
	   ex$get_modid( mod_osnum = elem->osnum,
	                 mod_id    = &obj_env.md_id.objid );

	   obj_env.md_id.osnum = elem->osnum;
	   obj_env.md_env.matrix_type = matrix_type;
	   memcpy( obj_env.md_env.matrix, matrix, sizeof( IGRdouble ) * 16 );

	   new_elem.osnum = batch_env->md_id.osnum;

	   sts = om$send( msg      = message GRgraphics.GRcopy( &msg,
	                                                        &obj_env,
	                                                        batch_env,
	                                                        &new_elem.objid ),
	                  targetid = elem->objid,
	                  targetos = elem->osnum,
	                  senderid = NULL_OBJID );

	      OM_ERRCHK( sts, "VEcopy_for_batch:  GRgraphics.GRcopy send failed" );
	      MSG_ERRCHK( msg, "VEcopy_for_batch:  GRgraphics.GRcopy failed" );

	   if ( 1 & sts & msg )
	      {
	      /* make sure components that were off in a composite remain */
	      /* off in the batch object space                            */
	      VEfix_layers( &new_elem, env, composite );

	      /* try to compress the DPR trees of solids to make them smaller */
	      new_id = VEcompress_dpr_tree( &new_elem, elem_classid, batch_env );

	      VEadd_to_objects_dir( new_elem.osnum, env->attach_id, new_id );

	      VEexec_status.VEtotal_elems++;
	      }  /* end: copy succeeded */

	   }  /* end: if */

	}  /* VEcopy_for_batch */

/*--- VEturn_all_ref_planes_off -----------------------------------------*/

void VEturn_all_ref_planes_off()

/*
NAME
	VEturn_all_ref_planes_off

DESCRIPTION
	This function turns all of the reference planes in the current
	module off.  It is intended to be used by the batch mode of CVE.

PARAMETERS
	none

GLOBALS USED
	none

HISTORY
	02/26/92    S.P. Rogers
	   Creation Date
*/

	{
	IGRlong     msg, sts;
	IGRint      ii;
	IGRint      datum_count;
	OM_S_OBJID  mgr_id;
	OMuword     mgr_os;
	struct GRid *datum_GRids;

	ems$get_datum_plane_mgr( msg = &msg,
	                         mgrid = &mgr_id,
	                         mgros = &mgr_os );

	/* get all of the ref. planes that are on */
	sts = om$send( msg = message EMSdatplnmgr.EMget_datums( &msg,
	                                                        EMS_OPT_ON_DATUMS,
	                                                        &datum_count, NULL ),
	               targetid = mgr_id,
	               targetos = mgr_os,
	               senderid = NULL_OBJID );

	if ( !(1 & sts & msg) )
	   return;

	datum_GRids = (struct GRid *) alloca( datum_count * sizeof( struct GRid ) );

	sts = om$send( msg = message EMSdatplnmgr.EMget_datums( &msg,
	                                                        EMS_OPT_ON_DATUMS,
	                                                        &datum_count, datum_GRids ),
	               targetid = mgr_id,
	               targetos = mgr_os,
	               senderid = NULL_OBJID );

	if ( !(1 & sts & msg) )
	   return;

	/* turn them all off */
	for ( ii = 0; ii < datum_count; ii++ )
	   {
	   sts = om$send( msg = message EMSdatpln.EMtoggle_on_off( &msg,
	                                                           EMS_OPT_OFF ),
	                  targetid = datum_GRids[ii].objid,
	                  targetos = datum_GRids[ii].osnum,
	                  senderid = NULL_OBJID );
	   }

	}  /* VEturn_all_ref_planes_off */

end implementation Root;
