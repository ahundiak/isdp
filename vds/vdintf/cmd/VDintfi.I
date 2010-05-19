/* $Id: VDintfi.I,v 1.3 2001/07/24 19:22:11 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdintf/cmd / VDintfi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDintfi.I,v $
 *	Revision 1.3  2001/07/24 19:22:11  hans
 *	Fix for TR# MP5464
 *	
 *	Revision 1.2  2001/01/12 19:11:10  hans
 *	SP16 import to CVS
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:52  cvs
 *	Initial import to CVS
 *
# Revision 1.15  2000/11/09  21:52:40  pinnacle
# Replaced: vds/vdintf/cmd/VDintfi.I for:  by jwfrosch for Service Pack
#
# Revision 1.9  2000/06/22  22:26:10  pinnacle
# Replaced: vds/vdintf/cmd/VDintfi.I for:  by jwfrosch for Service Pack
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/16/94	HF		Partial rewrite to COB (except for execute method)
 *					Added Options Form capability
 *
 *	03/29/96	HF		TR # 179601161
 *					message CEO_LOCATE.delete was
 *					missing in "action delete"
 *					TR # 179600635
 *					Extended eligible classes to include
 *					EMSsurface & subclasses
 *
 *	04/15/96	HF		TR #:179601630
 *					Replaced "EMSaction.h" by "VDSaction.h"
 *
 * VDSaction.h contains "struct VDSaction_handler", which is a new version of
 * "struct EMSaction_handler", to allow dynamic allocation of the lc_info pointer.
 * The lc_info member of the union NEEDS TO BE dynamically allocatable, because
 * p.e. for Interference Checking, because in VDS & ROUTE,
 * locate operations can easily result in thousands of elements being located
 * in a single set, while multiple sets are possible as well, which at the end
 * might result in a total of well over ten-thousand('s ?!? of) elements.
 *
 * The user has to malloc() & free() the required memory for the lc_info pointer !!!
 *		   =================
 *
 *	05/21/96	HF		Removed function EMstop_record(), because
 *					of multiply defined symbol when linking an
 *					integrated MODEL_VDS_... executable.
 *
 *	06/26/97	HF		Phase (1) of major restructuring:
 *					Make interferences ASSOCIATIVE in stead of
 *					just dumb graphics.
 *
 *	10/30/97	ah		UnInit Warning
 *
 *	12/22/97	HF		Changed from using instance variable "STATE" of ci_macro
 *					(this was causing problems for "nested" macros) for
 *					storing of interference_flags, to using the instance variable
 *					"internal_buffer" (==>>union state intf_flags) instead.
 *
 *					The ci_macro method give_internal_ptr will return a pointer
 *					to this instance variable.
 *					Since we manipulate a pointer into the instance data of the
 *					ci_macro, it is IMPORTANT to be VERY carefull in order to not
 *					corrupt the ci_macro !!!
 *					Because of this change it is not necessary anymore to play
 *					tricks with "assoc_opt".
 *
 *					The possibility to change the ELEMENT REPRESENTATION for
 *					all assoc_opt (0,1 &2) has been changed to ONLY allow this
 *					for NON-associative interference analysis (assoc_opt=0).
 *
 *					The reason for this change is, that is too confusing, because,
 *					when an assoc. interference with changed repr. has been performed,
 *					the effect of restoring to the original representation will trigger
 *					a recompute of the ci_macro which would seem to undo the original.
 *
 *					[It is simple to restore the original functionality (allowing Change
 *					 of Representation in ALL cases), by disabling everywhere in this file
 *					 the test : "if ( alloc_opt == 0 )" &&
 *					    look for following string :
 *						"DON'T ALLOW CHANGE of ELEMENT REPRESENTATION"
 *					 (Actually reactivating the :
 *						message VDintf.VDintf_modif_repr(&msg) &
 *						message VDintf.VDintf_reset_repr(&msg)
 *					  is all that is required, at least for testing purposes.)
 *					]
 *	03/18/99	ejm	TR_179900413: Limitation of 8 envelopes
 *				Increased LIST_SIZE to 20
 *
 *	05/30/00	HF	TR 179901258
 *                              Functionality to prevent generating so-called 'false' interferences...
 *
 *	11/02/2000	HF	No TR
 *                              Added functionality to enable/disable Reduce_Range of objects...
 *
 * -------------------------------------------------------------------*/

/*
ABSTRACT
  Command object for: VDS Interference Analysis

History:
  SM	  6/05/89	Creation.
  Tapadia 5/22/92	Modified for message sub system compliance
  Sudha   7/05/93	Modified for BSprototypes ansification

RETURN VALUES
	Response contains information for the command server.
	If response is TERMINATE then the command is deleted by
	the command server.
*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

class implementation VDintf;

#include	<EMS.h>
#include	<RAPdefs.h>

# ifndef DEBUG
# define DEBUG 0
# endif

/* mytypes */
#define Intf		0
#define IntfXsec	1
#define IntfBxsec	2
#define IntfToggleWrite 3
#define IntfBatch	4

#include	<stdio.h>
#include	<codef.h>
#include	<ECdlb.h>
#include	<igr.h>
#include	<igrtypedef.h>
#include	<griodef.h>
#include	<exdef.h>
#include	<EMSmsgdef.h>
#include	<dpmacros.h>
#include	<exmacros.h>
#include	<OMmacros.h>
#include	<OMprimitives.h>
#include	<griomacros.h>
#include	<grdpbmacros.h>
#include	<lcmacros.h>
#include	<emsdattyp.h>
#include	<emsinter.h>
#include	<EMSbnddef.h>
#include	<EMSbnd.h>
#include	<EMSopt.h>
#include	<EMSlmdef.h>
#include	<grgsdef.h>		/* Needed for the macros */
#include	<grgsmacros.h>		/* gr$gsput_locate_criteria() */
#include	<EC_M.h>		/* Command strings */
#include	<EC_I.h>		/* Status strings */
#include	<EC_P.h>		/* Prompt strings */
#include	<EC_F.h>		/* Error box strings */
#include	<EC_E.h>		/* Error strings */

//#include	<EMSaction.h>		/* Structure definition for select handler */
#include	<VDSaction.h>		/* TR #:179601630	*/

#include	<emsdef.h>
#include	<emserr.h>
#include	<EMSmsgdef.h>
#include	<EMSintf.h>
#include	<bserr.h>
#include	<bsparameters.h>
#include	<madetplan.h>
#include	<bsdistnct2.h>

#include	<DItypedef.h>
#include	<DIdef.h>
#include	<DIglob.h>
#include	<DIprims.h>

#include 	<ACattrib.h>
#include	<ACrg_collect.h>

#include	<acrepdef.h>		/* #define AC_2D_REP etc. */
#include	<VDintf_rpr.h>		/* struct for storing VDS repr to be used with reffiles	*/
#include	<nddef.h>
#include	<ndmacros.h>
#include	<VDmsg.h>
#include	<v_miscmacros.h>
#include "AS_status.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/* AND, ISNT ... */
# ifndef EMSlogic_include
# include	<EMSlogic.h>
# endif

#include	<FI.h>

#define	UNSIGNED_CHAR_0		((unsigned char) ~0)

/* Gadgets info for Status Form */

#define MCF_1		12
#define REP_FIELD	13
#define TXT_GADG	20
#define MCF_1_NUM_COL	 5
#define ASSOC_FIELD	14
#define PROGR_MESSG	15
#define DELETE_ASSOC	16
#define DELETE_EMPTY	17
#define AVOID_FALSE	18
#define REDUC_RANGE	19

/* Externs */

extern		 GRstatus_display_button();
extern IGRdouble get_intf_shrinkage();

extern int	FIg_get_text_length(),
		FIfld_get_select(),
		FIfld_set_select(),
		FIfld_get_text(),
		FIfld_set_text(),
		FIfld_set_active_row(),
		FIf_display(),
		FIf_reset(),
		FIg_enable(),
		FIg_disable(),
		FIg_display(),
		FIg_erase(),
		FIfld_get_active_row(),
		FImcf_get_active_col();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * HF: 06/26/97	  Make interferences ASSOCIATIVE in stead of just dumb graphics
 *
 * temporary static GLOBAL variables for DATA transfer between
 *   method form_notification() & the other methods in this file AND
 *   function : VD_EManalyzeIntf()
 *
 * Can be removed once incorporation in instance data has occurred !!!!
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static  IGRint		msg_opt;
static  IGRint		skip_reduce_range;
static  IGRint		assoc_opt;	/* Stored in instance variable STATE of ci_macro
					   (of course ONLY if (assoc_opt != 0)  */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * HF: 05/30/00 TR 179901258  Functionality to prevent generating so-called 'false' interferences
 *
 * This is implemented by
 * -1- introducing the sibling functionality for STRUCT classes VSbeam & VSplate
 *     (for SP13 temporarily implemented as overwrite of GRowner.I in
 *      struct/vsmisc/GRowneri.I and struct/vsmisc/VSgetsibling.I !!!)
 *     Needs to be replaced by overwrite of the GRget_siblings method for these classes !!!
 *     ====================================================================================
 *
 * -2- Generating a temporary shrunken object (shrink factor .999) of the smaller of the
 *     two objects about to be intersected against each other...
 */

static  IGRint VD_avoid_false_interf;   /* Option to avoid generating 'false' interferences */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static  IGRint VD_use_old_intf;   /* toggle between Old & New Interference (uses EMintersect_two_element) */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static  IGRint		del_all_intf;
static  IGRint		del_emp_intf;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	Static variable to save the status_form position between invocations	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
static int	VDintf_x_memo, VDintf_y_memo;
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

//#define DEBUG

#if DEBUG
#define ERRORs(sts_stupid, error_number, error_message, label)\
 {\
	if (EMSmsgReport (sts_stupid, error_message, FALSE) OR \
		EMSmsgReport (error_number, error_message, FALSE)) \
		goto label; \
 }
#else
#define ERRORs(sts_stupid, error_number, error_message, label)\
 {\
  if (! (1 & sts_stupid)) goto label;\
 }
#endif

from GRgraphics		import	GRdisplay, GRdelete;
from EMSsurface		import	EMshow_normals,
				EMrevorient,
				EManalyzeIntfAlongXsec;

from	ACncpx		import	ACget_NV_rep,
				ACset_NV_rep;
from	ACrg_collect	import	AClist_attribute;
from	ACcpx_defn	import	ACgive_name;
from	ACcpx		import	find_macro;

extern OMuword	OPP_EMSsurface_class_id,
		OPP_GRvg_class_id,
		OPP_EMSsubbs_class_id,
		OPP_EMSsolid_class_id,
		OPP_GRowner_class_id,
		OPP_GRcurve_class_id,
		OPP_EMSplane_class_id,
		OPP_GRsvset_class_id,
		OPP_ACncpx_class_id,
		OPP_ACpl_hold_class_id,
		OPP_GRclhdr_class_id,
		OPP_GRsmhdr_class_id,
		OPP_nci_macro_class_id;

extern OMuword	OPP_VDSroot_class_id, OPP_ASnode;
//extern OMuword	OPP_VRPCorentity_class_id;

extern IGRboolean EMSintfWriteFlag;

extern void	VDdelete_all_intf_macros();
extern int	VDpms_find_objects();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Function to enable toggling the value of VD_use_old_intf (toggle between Old & New Interference)
// from within a PPL.
// Execute PPL: ci=toggle_intf
//
int toggle_old_intf()
{
  if (VD_use_old_intf)
  {
    VD_use_old_intf = 0;
  }
  else
  {
    VD_use_old_intf = 1;
  }
  return VD_use_old_intf;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Function to enable toggling the value of msg_opt (Display Progress Messages)
// from within a PPL.
// Execute PPL: ci=toggle_pmsg
int toggle_progress_messages()
{
  if (msg_opt)
  {
    msg_opt = 0;
  }
  else
  {
    msg_opt = 1;
  }
  return msg_opt;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Function to enable toggling the value of VD_avoid_false_interf from within a PPL.
// Execute PPL: ci=false_intf
int toggle_false_interf()
{
  int sts;

  // Toggle also the static variable REV_avoid_false_interf in "Review Interference Objects" ...
  // This will allow enabling "Suppress False Interferences" in already placed macros...
  sts = toggle_false_interf_review();

  if (VD_avoid_false_interf)
  {
    VD_avoid_false_interf = 0;
    if (sts)
      toggle_false_interf_review();
  }
  else
  {
    VD_avoid_false_interf = 1;
    if (! sts)
      toggle_false_interf_review();
  }
  return VD_avoid_false_interf;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
// Function to enable toggling the value of skip_reduce_range
// from within a PPL.
// Execute PPL: ci=toggle_rdrg
int toggle_reduce_range()
{
  if (skip_reduce_range)
  {
    skip_reduce_range = 0;
  }
  else
  {
    skip_reduce_range = 1;
  }
  return skip_reduce_range;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

// Sorting with ascending osnum (primary key) and ascending objid (secundary key)
// If descending order is required, just return(sts = -sts)

static int compare_osnum_and_objid
(
  struct GRlc_info	*istr,
  struct GRlc_info	*ostr
)
{
  int         sts   = 0;
  struct GRid in_id = istr->located_obj;
  struct GRid of_id = ostr->located_obj;

  if ( in_id.osnum == of_id.osnum && in_id.objid == of_id.objid )
  {
    sts = 0;
  }
  else if ( in_id.osnum == of_id.osnum )
  {
    if ( in_id.objid < of_id.objid )
    {
      sts = -1;
    }
    else if ( in_id.objid > of_id.objid )
    {
      sts = 1;
    }
  }
  else if ( in_id.osnum < of_id.osnum )
  {
    sts = -1;
  }
  else if ( in_id.osnum > of_id.osnum )
  {
    sts = 1;
  }

  return ( sts );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void VDintf_check_located_obj
(
  IGRlong		*number_of_objects,
  struct GRlc_info	**objcts
)
{
  /*
   * HF 8/29/94	KLUDGE KLUDGE KLUDGE KLUDGE KLUDGE
   *
   * Filter to weed out superfluous OBJIDS generated by the EMselective_fence()
   * function in case the :
   * 'Select All Elements in File' event-generator has been activated.
   *
   * In this case not only the top-level objects of the allowed classes, but also
   * the nested objects on the 'to_components' channel are selected, causing incorrect
   * results because interference is checked for top-level objects as well as nested objects.
   * Besides this, also processing time increases dramatically because processing time is related to
   * the square of the number of interfering objects.
   *
   * Algorithm :
   *
   * - Find the number of objects on the 'to_owners' channel for each located object
   *   - If '#_of_owners: cnt == 0' increment offset counter (j0)
   *   - If '#_of_owners: cnt == 1', get the owner_object and check if its classid
   *     equals OPP_GRsvset_class_id.
   *     If it does, copy the GRlc_info structure 'objects' from [i0] to [j0]
   *     and increment the offset counter (j0)
   *   - If '#_of_owners: cnt >= 1' DO NOT ACCEPT THE OBJECT (do not modify offset j0)
   *				if ANY (except classid GRsvset) of its owners is already
   *				present in the list of 'objects'.
   *				If NO OWNER is found in 'objects' (except classid GRsvset),
   *				copy the GRlc_info structure 'objects' from [i0] to [j0]
   *				and increment the offset counter (j0)
   * - Reset number_of_objects to j0
   *
   * HF: 06/20/97
   * Modified function in order to accomodate "<Assoc> VDS Interference Analysis"
   *
   * - Check for nci_macro objects with name "VDinterf_cvs" and remove these from list.
   *   This test can be removed once the "Interference" object will be a new separate Class,
   *   (which can be excluded in the locate filter).
   * - KLUDGE
   *   Elements subclassed of VRCorrection need special treatment : they need to be replaced by the
   *   VRComponent object on their to_component channel.
   *   TO_DO : what if there is MORE than 1 object on the to_component channel ?!?!?
   */

  /*
   *   10/30/97 Art Hundiak
   *
   *   Anyone every wondered why UnInit ref to status warning was being
   *   generated even though status does not appear to be used?
   *   Why even have it?
   *
   *   Because silly, as$status uses sts = status to check codes by default
   *   so all of the status error checking is useless
   *
   *   taking out status and adding sts = sts to error checks
   *
   *   By the way, there are a whole bunch of status codes not being checked.
   */

  IGRint		i0, k0, m0, sts, old_num = *number_of_objects, sorted_and_cleaned = 0;
  IGRlong		msg = EMS_S_Success;
  OMuint		cnt = 0;
  OMuword		clid;
  int			j0 = 0;
  char			*supercls1 = {"VRCorrection"};
  char			*supercls2 = {"VRComponent"};
  OM_S_CHANSELECT	my_chansel;
  OM_S_OBJECT_LINKAGE	lobj;
  OM_S_OBJECT_LINKAGE	*p_lobj = NULL;
  struct GRlc_info	*objects = NULL, *objndup = NULL, *route_objects = NULL;

  __enterFunction ( name = "VDintf_check_located_obj" );
  __printf ( ">>>>> *number_of_objects = %d", `*number_of_objects` );

  // EMselective_fence() not always sets all fields correctly, in particular "module_info",
  // so that is why we do it here ...
  for( i0=0; i0 < *number_of_objects; i0++ )
  {
    (*objcts)[i0].module_info.md_id.osnum = (*objcts)[i0].located_obj.osnum;
    ex$get_modid ( mod_osnum =  (*objcts)[i0].module_info.md_id.osnum,
                   mod_id    = &(*objcts)[i0].module_info.md_id.objid );

    __printf ( " >>>>> (*objcts)[%d] = [%d,%d], module_info.md_id = [%d,%d]",
               `i0, (*objcts)[i0].located_obj.osnum, (*objcts)[i0].located_obj.objid,
                    (*objcts)[i0].module_info.md_id.osnum, (*objcts)[i0].module_info.md_id.objid` );
  }
  /*
   * Copy the pointer to array of "objts" to "objects"
   */
  if ( *number_of_objects )
    objects = _MALLOC ( *number_of_objects, struct GRlc_info );
  if ( ! objects )
  {
    goto quit;
  }
  else
  {
    memcpy ( objects, *objcts, *number_of_objects * sizeof ( struct GRlc_info ) );
  }

  /*
   * First remove ALL nci_macro's with name "VDinterf_cvs" from the set (temporarily)
   */

  j0 = *number_of_objects;
  i0 = 0;

  while ( i0 < j0 )
  {
    char		*c = NULL;
    struct GRid		macro;
    enum GRdpmode	Display_Mode = GRhe;

    om$get_classid ( objid	= objects[i0].located_obj.objid,
		     osnum	= objects[i0].located_obj.osnum,
		     p_classid	= &clid);

    if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_nci_macro_class_id) == OM_S_SUCCESS)
    {
      sts =
	om$send (	msg	 = message ACcpx.find_macro ( &macro ),
			targetid = objects[i0].located_obj.objid,
			targetos = objects[i0].located_obj.osnum,
			senderid = NULL_OBJID);
      as$status(sts = sts);
      sts =
	om$send (	msg	 = message ACcpx_defn.ACgive_name ( &c ),
			targetid = macro.objid,
			targetos = macro.osnum,
			senderid = NULL_OBJID);
      as$status(sts = sts);
      __printf ("ACcpx_defn.ACgive_name:objects[%d] = [%d,%d], name = <%s>",
		`i0, objects[i0].located_obj.osnum, objects[i0].located_obj.objid, c` );

      if ( c && strcmp ( c, "VDinterf_cvs" ) == 0 )
      {
	Display_Mode = GRhe;
	sts = om$send(
			msg	 = message GRgraphics.GRdisplay(
							   &msg,
							   &objects[i0].module_info.md_env.matrix_type,
							    objects[i0].module_info.md_env.matrix,
							   &Display_Mode,
							   &objects[i0].module_info.md_id),
			targetid = objects[i0].located_obj.objid,
			targetos = objects[i0].located_obj.osnum,
			senderid = NULL_OBJID);

	j0--;

//	OM_BLOCK_MOVE ( &objects[i0+1], &objects[i0], (j0 - i0) * sizeof(struct GRlc_info) );
	memcpy	      ( &objects[i0], &objects[i0+1], (j0 - i0) * sizeof(struct GRlc_info) );
      }
      else
      {
	i0++;
      }
    }
    else
    {
      i0++;
    }
  }

  *number_of_objects = j0;

  __printf ( "<<<<<>>>>> *number_of_objects = %d, j0 = %d", `*number_of_objects, j0` );

  /*
   * Check for OPP_GRsvset_class_id objects
   */
  my_chansel.type	= OM_e_name;
  my_chansel.u_sel.name = "to_owners";

  for( i0=0, j0=0; i0 < *number_of_objects; i0++ )
  {
    sts = om$get_channel_count (
				osnum		= objects[i0].located_obj.osnum,
				objid		= objects[i0].located_obj.objid,
				p_chanselect	= &my_chansel,
				count		= &cnt );
    if ( cnt == 0 )
    {
      j0++;
    }
    else if ( cnt == 1 )
    {
      sts = om$get_channel_objects(
				   osnum	= objects[i0].located_obj.osnum,
				   objid	= objects[i0].located_obj.objid,
				   p_chanselect	= &my_chansel,
				   size		= cnt,
				   list		= &lobj,
				   count	= &cnt );

      om$get_classid (	objid		= lobj.S_objid,
			osnum		= lobj.osnum,
			p_classid	= &clid );

      if ( clid == OPP_GRsvset_class_id )
      {
	if (j0 < i0)
	{
	  memcpy( &objects[j0], &objects[i0], sizeof(struct GRlc_info) );
	}
	j0++;
      }
    }
    else
    {
      p_lobj = _MALLOC ( cnt, OM_S_OBJECT_LINKAGE );
      if ( p_lobj )
      {
	sts = om$get_channel_objects(
				     osnum		= objects[i0].located_obj.osnum,
				     objid		= objects[i0].located_obj.objid,
				     p_chanselect	= &my_chansel,
				     size		= cnt,
				     list		= p_lobj,
				     count		= &cnt );

	for ( m0=0; m0 < cnt; m0++ )
	{
	  om$get_classid (	objid		= p_lobj[m0].S_objid,
				osnum		= p_lobj[m0].osnum,
				p_classid	= &clid );

	  for( k0=0; k0 < *number_of_objects; k0++ )
	  {
	    if ( p_lobj[m0].S_objid == objects[k0].located_obj.objid &&
		 p_lobj[m0].osnum   == objects[k0].located_obj.osnum &&
		 clid != OPP_GRsvset_class_id)
	    {
	      goto ignore_obj;
	    }
	  }
	}

	if (j0 < i0)
	{
	  memcpy( &objects[j0], &objects[i0], sizeof(struct GRlc_info) );
	}
	j0++;
      }

    ignore_obj:

      if ( p_lobj )
      {
	_FREE ( p_lobj );
      }
    }
  }
  *number_of_objects = j0;

  __printf ( "<<<<< *number_of_objects = %d, j0 = %d", `*number_of_objects, j0` );

  /*
   * Check for VRCorrections : if found replace them with the VRComponent on the to_component channel
   */
  my_chansel.type	= OM_e_name;
  my_chansel.u_sel.name = "to_components";

  j0 = *number_of_objects;
  i0 = k0 = 0;

  while ( i0 < j0 )
  {
    char	cl_nm[DI_PATH_MAX];
    int		memory_moved;
    struct GRid	cmp;

    memory_moved = FALSE;

    om$get_classid ( objid	= objects[i0].located_obj.objid,
		     osnum	= objects[i0].located_obj.osnum,
		     p_classid	= &clid);

    if ( om$is_ancestry_valid ( subclassid = clid, superclassname = supercls1 ) == OM_S_SUCCESS)
    {
      __printf ( "Found VRCorrection : objects[%d] = [%d,%d]",`i0, objects[i0].located_obj.osnum, objects[i0].located_obj.objid` );
      sts = om$get_channel_count (
				osnum		= objects[i0].located_obj.osnum,
				objid		= objects[i0].located_obj.objid,
				p_chanselect	= &my_chansel,
				count		= &cnt );
      if ( cnt == 1 )
      {
	sts = om$get_channel_objects(
				osnum		= objects[i0].located_obj.osnum,
				objid		= objects[i0].located_obj.objid,
				p_chanselect	= &my_chansel,
				size		= cnt,
				list		= &lobj,
				count		= &cnt );

	cmp.osnum = lobj.osnum;
	cmp.objid = lobj.S_objid;

	__printf ( "to_component object: cmp = [%d,%d]",`cmp.osnum, cmp.objid` );

	om$get_classname(	objid		= lobj.S_objid,
				osnum		= lobj.osnum,
				classname	= cl_nm );

	if ( om$is_ancestry_valid ( subclassname = cl_nm, superclassname = supercls2 ) == OM_S_SUCCESS)
	{
	  __printf ( "Found VRComponent  : replacing objects[%d] = [%d,%d] with [%d,%d] <%s>",
		     `i0, objects[i0].located_obj.osnum, objects[i0].located_obj.objid, cmp.osnum, cmp.objid, cl_nm` );

	  objects[i0].located_obj = cmp;
	}
      }
      else if ( cnt > 1 )
      {
	__printf ("Found %d objects on to_component channel of correction[%d] = [%d,%d]",
		  `cnt, i0, objects[i0].located_obj.osnum, objects[i0].located_obj.objid` );

	route_objects	 = _MALLOC ( cnt, struct GRlc_info );
	p_lobj		 = _MALLOC ( cnt, OM_S_OBJECT_LINKAGE );

	if ( p_lobj && route_objects )
	{
	  sts = om$get_channel_objects(
				osnum		= objects[i0].located_obj.osnum,
				objid		= objects[i0].located_obj.objid,
				p_chanselect	= &my_chansel,
				size		= cnt,
				list		= p_lobj,
				count		= &cnt );

	  for ( m0=0; m0 < cnt; m0++ )	// Initialize route_objects
	  {
	    memcpy( &route_objects[m0], &objects[i0], sizeof(struct GRlc_info) );
	  }

	  for ( m0=0, k0=0 ; m0 < cnt; m0++ )
	  {
	    cmp.osnum = p_lobj[m0].osnum;
	    cmp.objid = p_lobj[m0].S_objid;

	    om$get_classname (	objid		= p_lobj[m0].S_objid,
				osnum		= p_lobj[m0].osnum,
				classname	= cl_nm );

	    if ( om$is_ancestry_valid ( subclassname = cl_nm, superclassname = supercls2 ) == OM_S_SUCCESS)
	    {
	      route_objects[k0].located_obj = cmp;
	      k0++;
	    }
	  }
	  old_num = *number_of_objects - 1;
	  *number_of_objects += k0-1;

	  objects = _REALLOC ( objects, *number_of_objects , struct GRlc_info );

	  if ( VDcomment )
	  {
	    printf ( "Found %d VRComponents : removing objects[%d] = [%d,%d], appending at end [%d]",
		     k0, i0, objects[i0].located_obj.osnum, objects[i0].located_obj.objid, old_num );

	    for ( m0=0 ; m0 < k0; m0++ )
	    {
	      printf ( ", [%d] = [%d,%d] ", m0, route_objects[m0].located_obj.osnum, route_objects[m0].located_obj.objid );
	    }
	    printf ("\n");
	  }
	  memory_moved = TRUE;	// Only increment i0 if NO memory reshuffling occurs !!!

	  memcpy( &objects[i0]     , &objects[i0+1], (old_num - i0) * sizeof(struct GRlc_info) );
	  memcpy( &objects[old_num], route_objects, k0 * sizeof(struct GRlc_info) );
	}

	_FREE ( p_lobj );
	_FREE ( route_objects );
	j0--;
      }
    }
    if ( memory_moved == FALSE ) i0++;
  }

  /*
   * We need to SORT the struct GRlc_info[] objects[i0] with ascending osnum & objid
   * in order to be able to remove duplicate [osnum, objid] occurrences ...
   */

  if ( *number_of_objects )
  {
    qsort ( (char *) (objects), *number_of_objects, sizeof ( struct GRlc_info ),
	    (int (*) (const void *, const void *) ) compare_osnum_and_objid );
    /*
     * Allocate temporary storage for the cleaned array without duplicates ...
     */
    objndup = _MALLOC ( *number_of_objects, struct GRlc_info );
    if ( ! objndup )
    {
      goto quit;
    }

    objndup[0] = objects[0];
    j0 = 1;

    for ( i0=1; i0 < *number_of_objects; i0++ )
    {
      if (objects[i0-1].located_obj.osnum == objects[i0].located_obj.osnum)
      {
        if (objects[i0-1].located_obj.objid == objects[i0].located_obj.objid)
        {
          continue;
        }
        else
        {
          //objndup[j0] = objects[i0];
          memcpy( &objndup[j0], &objects[i0], sizeof(struct GRlc_info) );
          j0++;
        }
      }
      else
      {
        //objndup[j0] = objects[i0];
        memcpy( &objndup[j0], &objects[i0], sizeof(struct GRlc_info) );
        j0++;
      }
    }
    *number_of_objects = j0;
    sorted_and_cleaned = 1;
  }

  j0 = *number_of_objects;

  if ( j0 == 0 ) j0 = 1;

  *objcts = (struct GRlc_info *) realloc ( *objcts, j0 * sizeof ( struct GRlc_info ) );
  if ( ! *objcts )
  {
    goto quit;
  }
  else
  {
    if (sorted_and_cleaned)
    {
      memcpy ( *objcts, objndup, j0 * sizeof ( struct GRlc_info ) );
    }
    else
    {
      memcpy ( *objcts, objects, j0 * sizeof ( struct GRlc_info ) );
    }
  }

  for( i0=0; i0 < *number_of_objects; i0++ )
  {
    __printf ( " <<<<< objects[%d] = [%d,%d], module_info.md_id = [%d,%d]",
               `i0, (*objcts)[i0].located_obj.osnum, (*objcts)[i0].located_obj.objid,
                    (*objcts)[i0].module_info.md_id.osnum, (*objcts)[i0].module_info.md_id.objid` );
  }

quit:
  _FREE ( objects );
  _FREE ( objndup );

  __exitFunction ( name = "VDintf_check_located_obj" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#define _start 0

method VDintf_init ( long * sts )
{
  *sts = MSSUCC;

  __enterMethod ( name = "VDintf_init" );

  me->num_located		= 0;
  me->num_ornted		= 0;
  me->num_sets			= 0;
  me->add_to_set		= FALSE;
  me->stdreportonly		= FALSE;
  me->nocurves			= TRUE;
  me->novol			= TRUE;
  me->noarea			= TRUE;
  me->plpts_input		= FALSE;
  me->remove_flag		= FALSE;
  me->status_form_initialized	= FALSE;
  me->tot_nr_fls		= 1;

  del_all_intf = 0;	// ALWAYS INITIALIZE to ZERO ( 0 ) !!!
  del_emp_intf = 0;	// ALWAYS INITIALIZE to ZERO ( 0 ) !!!

  if ( VDintf_x_memo != 0 && VDintf_y_memo != 0 )
  {
    me->origin_x = VDintf_x_memo;
    me->origin_y = VDintf_y_memo;
  }
  else
  {
    me->origin_x = 0;
    me->origin_y = 150;
  }

  if ( me->status_display_form_ptr )
  {
    FIf_set_location ( me->status_display_form_ptr, me->origin_x, me->origin_y );
    FIg_disable      ( me->status_display_form_ptr, FI_EXECUTE );

    FIg_set_state    ( me->status_display_form_ptr, PROGR_MESSG,  msg_opt );
    FIg_set_state    ( me->status_display_form_ptr, REDUC_RANGE,  skip_reduce_range );

    if ( assoc_opt == 0 )
    {
      FIg_enable	  ( me->status_display_form_ptr, MCF_1 );
      FIg_enable	  ( me->status_display_form_ptr, AVOID_FALSE );
    }
    else		// DON'T ALLOW CHANGE of ELEMENT REPRESENTATION
    {
      FIg_disable	  ( me->status_display_form_ptr, MCF_1 );
    }
    FIg_set_state         ( me->status_display_form_ptr, AVOID_FALSE,  VD_avoid_false_interf );

    if ( assoc_opt == 1 )
    {
      FIfld_set_active_row( me->status_display_form_ptr, ASSOC_FIELD, 1, 0 );
      FIg_set_text        ( me->status_display_form_ptr, FI_MSG_FIELD,
			    "Macro is deleted when Interference is resolved" );
    }
    else if ( assoc_opt == 2 )
    {
      FIfld_set_active_row( me->status_display_form_ptr, ASSOC_FIELD, 2, 0 );

      FIg_set_color	  ( me->status_display_form_ptr, FI_MSG_FIELD, FI_YELLOW );
      FIg_set_text        ( me->status_display_form_ptr, FI_MSG_FIELD,
			    "This option may dramatically increase file-size: Use with CAUTION" );
      FIg_set_color	  ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );
    }
  }
  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  __exitMethod ( name = "VDintf_init" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method wakeup ( int pos )
{
  enum GRdpmode	Display_Mode = GRhhd;
  IGRint		sts = OM_S_SUCCESS, i;
  IGRlong		msg = EMS_S_Success;

  __enterMethod ( name = "wakeup" );

  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  sts = om$send ( mode     = OM_e_wrt_message,
		  msg      = message CEO_LOCATE.wakeup( pos ),
		  targetid = my_id);

  if (me->num_located)
  {
    for (i = 0; i < me->num_located; i++)
    {
      sts = om$send (	mode	 = OM_e_wrt_object,
			msg	 = message GRgraphics.GRdisplay(
						&msg,
						&me->ModuleInfo.md_env.matrix_type,
						me->ModuleInfo.md_env.matrix,
						&Display_Mode,
						&me->ModuleInfo.md_id),
			targetid = me->locate_info[i].located_obj.objid,
			targetos = me->locate_info[i].located_obj.osnum);

      ERRORs(sts, msg, "VDintf_wakeup draw hi", quit);
    }
  }

  if ( ME.super_cmd->mytype == Intf)
  {
    ex$message ( msgnumb = VD_M_IntfAna );
  }
  else if ( ME.super_cmd->mytype == IntfXsec )
  {
    ex$message ( msgnumb = EM_M_AnalyzeIntfXsec );
  }
  else if ( ME.super_cmd->mytype == IntfBxsec )
  {
    ex$message ( msgnumb = EM_M_AnalyzeIntfBxsec );
  }
  else if ( ME.super_cmd->mytype == IntfToggleWrite )
  {
    ex$message ( msgnumb = EM_M_TogIntCurWrite );
  }
  else if ( ME.super_cmd->mytype == IntfBatch )
  {
    ex$message ( msgnumb = ( ex$is_batch() ) ? EM_M_AnalyzeIntfBatch : EM_M_AnalyzeIntfPBatch );
  }

  if ( ME.super_cmd->mytype == Intf)
  {
    ex$message ( field = ERROR_FIELD, msgnumb = EMS_I_InvkStatusFrm );
    GRstatus_display_button(1);
  }

  if ( me->status_display_form_ptr )
  {
    FIg_enable ( me->status_display_form_ptr, FI_FORM_GROUP );	// Enable status_form

    if ( assoc_opt == 0 )
    {
      FIg_enable	  ( me->status_display_form_ptr, MCF_1 );
      FIg_enable	  ( me->status_display_form_ptr, AVOID_FALSE );
    }
    else		// DON'T ALLOW CHANGE of ELEMENT REPRESENTATION
    {
      FIg_disable	  ( me->status_display_form_ptr, MCF_1 );
    }
    FIg_set_state         ( me->status_display_form_ptr, AVOID_FALSE,  VD_avoid_false_interf );
    FIg_set_state         ( me->status_display_form_ptr, PROGR_MESSG,  msg_opt );
    FIg_set_state         ( me->status_display_form_ptr, REDUC_RANGE,  skip_reduce_range );

    if ( del_all_intf || del_emp_intf )
    {
      FIg_enable  ( me->status_display_form_ptr, FI_EXECUTE );
    }
    else
    {
      FIg_disable ( me->status_display_form_ptr, FI_EXECUTE );
    }
  }

  __exitMethod ( name = "wakeup" );
quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method sleep ( int pos )
{
  IGRint	sts = OM_S_SUCCESS;
  IGRlong	msg = EMS_S_Success;

  __enterMethod ( name = "sleep" );

  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  sts = dp$erase_hilite(msg = &msg);
  ERRORs(sts, msg, "VDintf_sleep erase hi", quit);

  ex$message(msgnumb = EM_M_ClearMessageField);
  ex$message(msgnumb = EMS_I_00000);
  ex$message(msgnumb = EMS_P_00000);

  if ( me->status_display_form_ptr )
  {
//    FIf_erase   ( me->status_display_form_ptr );
    FIg_disable ( me->status_display_form_ptr, FI_FORM_GROUP );	// Disable status_form
  }

  __exitMethod ( name = "sleep" );
quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method delete ( int f_defer_flag )
{
  IGRint  i0, sts;
  IGRlong msg;

  __enterMethod ( name = "delete" );

  sts = om$send ( mode     = OM_e_wrt_message,
		  msg      = message CEO_LOCATE.delete ( f_defer_flag ),
		  targetid = my_id);

  for (i0=0; i0 < me->num_located; i0++)
  {
    if (me->reversed[i0])
    {
      sts = om$send (	msg	 = message EMSsurface.EMrevorient (&msg),
			targetid = me->locate_info[i0].located_obj.objid,
			targetos = me->locate_info[i0].located_obj.osnum);
      me->reversed[i0] = FALSE;
    }
  }
  ERROR(sts, EMS_S_Success, "ECbool_delete delete", quit);

  /*
   * Reset VDS Representation to original
   */

  sts = om$send (	msg	 = message VDintf.VDintf_reset_repr(&msg),
			targetid = my_id);

  if ( me->origin_x >= 0 && me->origin_y >= 0 )
  {
    VDintf_x_memo = me->origin_x;
    VDintf_y_memo = me->origin_y;
  }

  if ( me->status_display_form_ptr )
  {
    FIf_erase( me->status_display_form_ptr );
  }

  __exitMethod ( name = "delete" );
quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method execute ( int * response ; char * response_data ; int pos )
{
  IGRboolean		sfintf;
  IGRchar		loc_prompt  [GR_MAX_CHAR], acc_prompt[GR_MAX_CHAR];
  IGRchar		reloc_prompt[GR_MAX_CHAR], elemtype  [GR_MAX_CHAR];
  IGRint		sts, display_flag;
  IGRlong		msg;
  IGRlong		size = sizeof(struct GRevent);
  IGRint		locate_mask, accept_mask, token = 0, i, j;
  IGRint		num_loc_sets, num_sets, *num_in_set;
  enum   GRdpmode	Display_Mode;
  struct GRlc_locate	attr;
  OM_S_CLASSLIST	rtree_classes, elig_classes;
  OMuword		rclass, eliclass[8];
  struct GRlc_info	*obj_infos, *set_info;
  IGRboolean		stats;
  IGRlong		loc_msg, num_pnts = 3;

  extern IGRint		ECdisplayPointSetByBuffer();
  extern void		EMstop_record ( IGRlong *msg );
  extern IGRlong	VD_EManalyzeIntf();

#   define NUM_TOKENS 6
  /* */ static /* */ int Tokens[NUM_TOKENS] =
  {
    EX_BACK_UP, DATA, EX_OBJID, STRING, EX_RJT_MOVEON, GR_UNKNOWN_TYPE
  };

  enum actions
  {
    NIL, ERR, init, rem_obj, store_obj, dummy, dummy1
  };

#   define NUM_STATES 10
  enum states
  {
    plpt1, plpt2, plpt3, start, filename, ask_cv, ask_vol, ask_ort, ask_area, analyze
  };

  static enum states NextState[NUM_STATES][NUM_TOKENS] =
  {
    /*  token:	     BACK_UP	DATA		OBJ		STRING		MOVEON		UNK
	old state: */
    /* plpt1   */   {plpt1,	plpt2,		plpt1,		plpt1,		plpt1,		plpt1},
    /* plpt2   */   {plpt1,	plpt3,		plpt2,		plpt2,		plpt2,		plpt2},
    /* plpt3   */   {plpt2,	start,		plpt3,		plpt3,		plpt3,		plpt3},
    /* start   */   {start,	start,		start,		start,		start,		start},
    /* filename*/   {start,	filename,	filename,	ask_cv,		ask_cv,		filename},
//  /* ask_cv  */   {filename,	ask_cv,		ask_cv,		ask_vol,	ask_vol,	ask_cv},	//
    /* ask_cv  */   {filename,	ask_cv,		ask_cv,		analyze,	analyze,	ask_cv},
    /* ask_vol */   {ask_cv,	ask_vol,	ask_vol,	ask_ort,	ask_ort,	ask_vol},
    /* ask_ort */   {ask_ort,	ask_ort,	ask_ort,	ask_ort,	ask_ort,	ask_ort},
    /* ask_area*/   {filename,	ask_area,	ask_area,	analyze,	analyze,	ask_area},
    /* analyze */   {plpt1,	plpt1,		plpt1,		plpt1,		plpt1,		plpt1}
  };

  static enum actions NextAction[NUM_STATES][NUM_TOKENS] =
  {
    /*  token:      BACK_UP    DATA       OBJ	   STRING	 MOVEON     UNK
	old state: */
    /* plpt1    */ {NIL,	NIL,	  NIL,	     NIL,	  NIL,	    NIL},
    /* plpt2    */ {NIL,	NIL,	  NIL,	     NIL,	  NIL,	    NIL},
    /* plpt3    */ {NIL,	NIL,	  NIL,	     NIL,	  NIL,	    NIL},
    /* start    */ {rem_obj,  store_obj, store_obj, store_obj,   dummy,	    NIL},
    /* filename */ {NIL,	NIL,	  NIL,	     NIL,	  NIL,	    NIL},
    /* ask_cv   */ {NIL,	NIL,	  NIL,	     NIL,	  NIL,	    NIL},
    /* ask_vol  */ {NIL,	NIL,	  NIL,	     NIL,	  NIL,	    NIL},
    /* ask_ort  */ {dummy1,   dummy1,    dummy1,    dummy1,      dummy1,   dummy1},
    /* ask_area */ {NIL,	NIL,	  NIL,	     NIL,	  NIL,	    NIL},
    /* analyze  */ {NIL,	NIL,	  NIL,	     NIL,	  NIL,	    NIL}
  };

  __enterMethod ( name = "execute" );

  if(ME.super_cmd->mytype == IntfToggleWrite)
  {
    EMSintfWriteFlag   = ! EMSintfWriteFlag;
    ex$message ( msgnumb = EMSintfWriteFlag ? EMS_S_IntCurWrOn : EMS_S_IntCurWrOff);

    sleep(4);
    *response = TERMINATE;
    __exitMethod ( name = "execute" );
    return(OM_S_SUCCESS);
  }

  if (ME.super_cmd->mytype == Intf || ME.super_cmd->mytype == IntfBatch)
    sfintf = TRUE;
  else
    sfintf = FALSE;

  do
  {
    sts = OM_S_SUCCESS;
    switch (me->my_action)
    {
    case NIL:
    case ERR:
    case init:
      {
	break;
      }
    case rem_obj:
      {
	__prints ( ">>>>> case rem_obj" );

	if (me->num_located)
	{
	  struct GRlc_info *junk;
	  junk = &me->locate_info[me->num_located - 1];

	  if (me->num_located == 1)
	  {
	    sts = dp$erase_hilite(msg = &msg);
	    ERRORs(sts, msg, "VDintf_exec erase hi", wrapup);
	  }
	  else
	  {
	    Display_Mode = GRhe;
	    sts = om$send(	msg = message GRgraphics.GRdisplay(&msg,
							 &me->ModuleInfo.md_env.matrix_type,
							 me->ModuleInfo.md_env.matrix,
							 &Display_Mode,
							 &me->ModuleInfo.md_id),
				targetid = junk->located_obj.objid,
				targetos = junk->located_obj.osnum);
	    ERRORs(sts, msg, "VDintf_exec erase", wrapup);
	  }

	  if(me->reversed[me->num_located - 1])
	  {
	    sts = om$send ( msg	 = message EMSsurface.EMrevorient (&msg),
			    targetid = junk->located_obj.objid,
			    targetos = junk->located_obj.osnum);
	    ERRORs(sts, msg, "VDintf_exec erase", wrapup);
	    me->reversed[me->num_located - 1] = FALSE;
	  }

	  me->num_located--;
	  me->num_in_set[me->num_sets-1]--;
	  if (! me->num_in_set[me->num_sets-1])
	  {
	    me->num_sets--;
	    me->add_to_set = FALSE;
	  }
	  else
	    me->add_to_set = TRUE;
	}
	else if(token == 0)			/* If back up */
	  ME.super_cmd->state = plpt3;
	else
	{
	  me->num_sets = 0;
	  me->add_to_set = FALSE;
	}
	__prints ( "<<<<< case rem_obj" );

	break;
      }
    case store_obj:
      {
	IGRlong		number_of_objects;
	struct		GRlc_info *objects, static_object;
	OMuword		list1[10], list2;
	OM_S_CLASSLIST	yes_classes, no_classes;

	extern		IGRlong EMselective_fence();

	__prints ( ">>>>> case store_obj" );

	number_of_objects = 0;
	objects = NULL;

	/*
	 * If a set was located then decompose it into leaf nodes ensuring
	 * that only surfaces and composite surfaces are present. Record the
	 * object-id of the set. If the set is a fence, then put in NULL_OBJID.
	 * Remove any duplicates in the set being recorded.
	 */

	/* SM 2/12/93

	   There seems to be some confusion over the list1 (yes classes) in
	   case if sfintf is TRUE. The original code (RCS version 201.5) was
	   to consider EMSsurface AND GRowner to be o.k. This was changed to
	   consider EMSsurface only to fix a TR 92n3780. Doing this however
	   causes VDS generated owners to become unacceptable. This new TR
	   us 119300995.

	   I have tried to go back to the TR 92n3780 in an effort to fix both
	   problems, but noone around seems to remember exactly what the problem
	   was. The TR description for 92n3780 does not help either.

	   So, according to the law of minimum perturbation, I have decided to
	   not add GRowner back again, but a class ACncpx. Vds owners are all
	   subclassed off of ACncpx. This should make everyone happy.

	   SM 2/19/93 - KLUDGE - Added another class to the yes list called
	   'VRCorrection' if it is known.

	   SM 3/15/93 - KLUDGE CONTINUES - Added symbols and cells. I will clean
	   this up for 2.4 and put back the original GRowner class.

	   HF 8/29/94 - Locate only objects subclassed from VDSroot + VRPCorentity
	   HF 9/5/94  - Changed VRPCorentity to ASnode in order to allow implementation at
	   VDS level (this removes I_ROUTE dependency)
	 */
	if (sfintf)
	{
	  list1[0] = OPP_VDSroot_class_id;
	  list1[1] = OPP_EMSsurface_class_id;
	  list1[2] = OPP_ASnode_class_id;
	  yes_classes.w_count = 3;
	}
	else
	{
	  list1[0] = OPP_EMSsurface_class_id;
	  yes_classes.w_count = 1;
	}
	yes_classes.p_classes = list1;

	list2 = OPP_GRcurve_class_id;
	no_classes.w_count = 1;
	no_classes.p_classes = &list2;

	sts = EMselective_fence(
			    &yes_classes,
			    &no_classes,
			    &me->locate_event.located_object[0],
			    FALSE,
			    sfintf ? FALSE : TRUE,
			    my_id,
			    &number_of_objects,
			    &objects,
			    &msg);
	ERRORs(sts, msg, "ECmkcompsf_exec EMselective_fence", wrapup);
	__printf ( ">>>>> number_of_objects = %d, me->locate_event.located_object[0] = [%d,%d]",
                   `number_of_objects, me->locate_event.located_object[0].located_obj.osnum,
                                       me->locate_event.located_object[0].located_obj.objid` );

	VDintf_check_located_obj( &number_of_objects, &objects );	/* KLUDGY ; See Comment inside Function def. above */

	__printf ( "<<<<< number_of_objects = %d, objects = %#x", `number_of_objects, objects` );


	if (me->add_to_set && (num_sets = me->num_sets))
	{
	  IGRboolean found;
	  IGRint	startinx, inxlim, num_processed;
	  extern	IGRboolean EMisElementSame();

	  num_in_set = me->num_in_set;
	  startinx = 0;
	  for (i=0; i<num_sets; i++)
	    startinx += num_in_set[i];

	  inxlim = me->num_located;

	  obj_infos = me->locate_info;
	  for (i=startinx; i<inxlim; i++)
	  {
	    found = FALSE;
	    num_processed = 0;
	    while ( ! found && num_processed < number_of_objects)
	    {
	      if (EMisElementSame (&objects[num_processed].located_obj,
				   &obj_infos[i].located_obj,
				   objects[num_processed].module_info.md_env.matrix_type,
				   obj_infos[i].module_info.md_env.matrix_type,
				   objects[num_processed].module_info.md_env.matrix,
				   obj_infos[i].module_info.md_env.matrix))
		found = TRUE;
	      else
		num_processed++;
	    }
	    if (found)
	    {
	      if (num_processed < number_of_objects-1)
		OM_BLOCK_MOVE (&objects[num_processed+1], &objects[num_processed], sizeof (struct GRlc_info));
	      number_of_objects--;

	      __printf ( "<<<<< EMisElementSame() : number_of_objects = %d", `number_of_objects` );
	    }
	  }
	}

	if (number_of_objects)
	{
	  IGRboolean	put_on_queue;
	  IGRlong	total_count;

	  /*
	   * Add the processed element set to the processed list.
	   */

	  put_on_queue = me->locate_event.response != EX_OBJID;
	  total_count  = me->num_located + number_of_objects + 2; /* Conservative */

	  __printf ( "me->num_located = %d + number_of_objects = %d + 2 --> total_count = %d",
		     `me->num_located, number_of_objects, total_count` );

	  sts = om$vla_set_dimension(
				 varray = me->ac_rpr,
				 size = total_count);
	  ERRORs(sts, EMS_S_Success, "VDintf_exec expand vla", wrapup);

	  for ( i=0; i < number_of_objects; i++ )
	  {
	    sts = om$send ( msg	 = message ACncpx.ACget_NV_rep ( &me->ac_rpr[i + me->num_located] ),
			    targetid = objects[i].located_obj.objid,
			    targetos = objects[i].located_obj.osnum);
	  }

	  sts = om$vla_set_dimension(
				 varray = me->locate_info,
				 size = total_count);
	  ERRORs(sts, EMS_S_Success, "VDintf_exec expand vla", wrapup);

	  sts = om$vla_set_dimension(
				 varray = me->reversed,
				 size = total_count);
	  ERRORs(sts, EMS_S_Success, "VDintf_exec expand vla", wrapup);


	  __printf ( "dimension_of (varray = me->ac_rpr)      = %d", om$dimension_of (varray = me->ac_rpr     ));
	  __printf ( "dimension_of (varray = me->locate_info) = %d", om$dimension_of (varray = me->locate_info));
	  __printf ( "dimension_of (varray = me->reversed)    = %d", om$dimension_of (varray = me->reversed   ));

	  OM_BLOCK_MOVE(objects, &me->locate_info[me->num_located],
			number_of_objects * sizeof(struct GRlc_info));
	  me->num_located += number_of_objects;

////////////////////////////////////////////////////
	  /*
	   * Modify (temporarily) VDS Representation according to selected options
	   */

//      sts = om$send (	msg	 = message VDintf.VDintf_modif_repr(&msg),
//			targetid = my_id);
////////////////////////////////////////////////////
	  num_sets = me->num_sets;
	  if (! me->add_to_set)
	  {
	    if (om$dimension_of (varray = me->num_in_set) < num_sets+1)
	    {
	      sts = om$vla_set_dimension (varray = me->num_in_set,
					  size = num_sets+1);
	      __printf ( "dimension_of (varray = me->num_in_set)  = %d", om$dimension_of (varray = me->num_in_set));

	      EMerr_hndlr (EMSerror (sts), msg, EMS_E_NoDynamicMemory, wrapup);
	    }

	    if (om$dimension_of (varray = me->set_info) < num_sets+1)
	    {
	      sts = om$vla_set_dimension (varray = me->set_info,
					  size = num_sets+1);
	      __printf ( "dimension_of (varray = me->set_info)    = %d", om$dimension_of (varray = me->set_info ));

	      EMerr_hndlr (EMSerror (sts), msg, EMS_E_NoDynamicMemory, wrapup);
	    }
	  }
	  num_in_set = me->num_in_set;
	  set_info   = me->set_info;

	  if (me->add_to_set)
	  {
	    struct GRlc_info *loc_set_info;

	    num_in_set[num_sets-1] += number_of_objects;

	    /*
	     * The only way the set can have the name of the first element
	     * located is when the set consists of that element alone. Since
	     * elements are being added into this set, that violates this rule.
	     * Hence, make this set-id NULL.
	     */

	    loc_set_info = &set_info[num_sets-1];
	    loc_set_info->located_obj.objid = NULL_OBJID;
	  }
	  else
	  {
	    num_in_set[num_sets] = number_of_objects;
	    set_info[num_sets] = me->locate_event.located_object[0];
	    num_sets = ++me->num_sets;
	  }
	  for(i = 0; i<me->num_located; i++)
	    me->reversed[i] = FALSE;

	  /*
	   * Put the accept event on the queue if the object
	   * was not a specified object (fence).
	   */

	  if (put_on_queue)
	  {
	    sts = ex$putque(
			    msg = &msg,
			    response = response,
			    byte = &size,
			    buffer = (char *)&me->locate_event.event);
	    ERRORs(sts, EMS_S_Success, "VDintf_exec put que", wrapup);
	    __prints ( "After ex$putque()" );
	  } /* if (put_on_queue) */

	  /*
	   * After this point, objects need to be added to the current
	   * set, unless explicitly indicated by the user (move-on).
	   */

	  me->add_to_set = TRUE;

	} /* if (number_of_objects) */

	/*
	 * Erase the highlighed object and tell the operator
	 * if we have thrown everything away.  Note that fences
	 * do not need to be erased as they are never highlighted.
	 */

	else
	{
	  if (me->locate_event.response != EX_OBJID)
	  {
	    if (me->num_located)
	    {
	      struct	GRlc_info *info;

	      info = &me->locate_event.located_object[0];
	      Display_Mode = GRhe;
	      sts = om$send(
			msg	 = message GRgraphics.GRdisplay(
							   &msg,
							   &me->ModuleInfo.md_env.matrix_type,
							   me->ModuleInfo.md_env.matrix,
							   &Display_Mode,
							   &me->ModuleInfo.md_id),
			targetid = info->located_obj.objid,
			targetos = info->located_obj.osnum);
	      ERRORs(sts, msg, "VDintf GRdisplay", wrapup);
	    } /* if (me->num_located) */
	    else
	    {
	      sts = dp$erase_hilite(msg = &msg);
	      ERRORs(sts, msg, "VDintf erase hilite", wrapup);
	    } /* ELSE FOR if (me->num_located) */
	  } /* if (me->locate_event.response != EX_OBJID) */

	  ex$message(msgnumb = EMS_I_00092);
	  ems_sleep(2);
	}

	/*
	 * Free the memory
	 */

	if (objects && objects != &static_object)
	{
	  __printf ( "<<<<< free(objects) : number_of_objects = %d, objects = %#x", `number_of_objects, objects` );

	  free ( objects );
	  objects = NULL;
	}

	__prints ( "<<<<< case store_obj" );

	break;
      }
    case dummy:
      {
	/*
	 * Will come here only under a 'move on' response from the user. So
	 * start a new set. If a new set had just been started and there is
	 * atleast one element already located, then all locates are done.
	 */
	__prints ( ">>>>> case dummy" );

	if (!me->add_to_set && me->num_located)
	  ME.super_cmd->state = filename;

	me->add_to_set = FALSE;

	__prints ( "<<<<< case dummy" );

	break;
      }
    case dummy1:
      {
	__prints ( ">>>>> case dummy1" );

	if(me->num_ornted == me->num_located) /* forward march */
	  ME.super_cmd->state = ask_area;
	else if(me->num_ornted < 0)
	{
	  ME.super_cmd->state = ask_vol; /* backing up*/
	  me->num_ornted = 0;
	}
	__prints ( "<<<<< case dummy1" );
	break;
      }
    default:
      {
	ERRORs(OM_E_ABORT, EMS_E_Fail, "action garbage", wrapup);
	break;
      }
    } /*end switch */


    switch(ME.super_cmd->state)
    {
    case plpt1:
    case plpt2:
    case plpt3:
      {
	IGRint	st, i;

	if( ( ME.super_cmd->mytype == Intf )      ||
	    ( ME.super_cmd->mytype == IntfBatch ) ||
	    ( ME.super_cmd->mytype == IntfBxsec ) )
	{
	  token = 1;	/* Simulate data event */
	  break;
	}

	__prints ( ">>>>> case plpt123" );

	if(ME.super_cmd->state == plpt1) st = 1;
	else if(ME.super_cmd->state == plpt2) st = 2;
	else st = 3;

	i = st - 1;

	locate_mask = GRm_DATA | GRm_BACK_UP;
	if( (st == 1) && me->plpts_input)
	{
	  locate_mask |= GRm_RJT_MOVEON;
	  ex$message(msgnumb = EMS_P_Plpt1MvOn, type = "%d", var = `st`);
	}
	else
	{
	  ex$message(msgnumb = EMS_P_00130, type = "%d", var = `st`);
	}

	if(st >1)
	{
	  sts = ECdisplayPointSetByBuffer(&msg, ME.CEO_LOCATE->ActiveDisplay,
					  me->ModuleInfo, my_id, i, &me->points[0][0],
					  TRUE);
	  EFrblineseg(&me->points[st-2][0], &ME.CEO_LOCATE->ActiveDisplay);
	}
	token = GRget_token(&msg, Tokens, &locate_mask,
			    &me->locate_event, &size,
			    response, response_data);
	ex$message ( msgnumb = EMS_S_ClearStatusField);
	ex$message ( msgnumb = EMS_P_ClearPromptField);

	if (st > 1)
	  sts = ECdisplayPointSetByBuffer(&msg, ME.CEO_LOCATE->ActiveDisplay,
					  me->ModuleInfo, my_id, st-1,
					  &me->points[0][0], FALSE);


	/* If we have anything other than data point, break and stay on
	   the same state. If previously entered 3 points are to be reused,
	   simulate the condition as if the third point was input.
	 */
	if( (st == 1) && (me->plpts_input) && (token == 4))
	{
	  ME.super_cmd->state = plpt3;
	  token = 1;
	  break;
	}
	if(token != 1) break;
	me->points[i][0] = me->locate_event.event.button.x;
	me->points[i][1] = me->locate_event.event.button.y;
	me->points[i][2] = me->locate_event.event.button.z;
	if(st == 2)
	{
	  stats = BSdistnct2(&loc_msg, me->points[0], me->points[1]);
	  if (!stats)
	  {
	    ex$message(msgnumb = EMS_I_00001);
	    token = 5;	/* Simulate unknown event to stay on the same state*/
	  }
	}
	else if(st == 3)
	{
	  IGRdouble tolerance;

	  BSEXTRACTPAR(&msg, BSTOLLENVEC, tolerance);
	  me->plane.point = &me->plane_point[0];
	  me->plane.normal = &me->plane_normal[0];
	  stats = MAdetplane(&msg, (IGRdouble *)me->points, &num_pnts, &tolerance,
			     &me->plane);
	  if (!stats)
	  {
	    ex$message(msgnumb = EMS_I_00001);
	    token = 5;	/* Simulate unknown event to stay on the same state*/
	  }
	  else me->plpts_input = TRUE;
	}
	__prints ( "<<<<< case plpt123" );

	break;
      }
    case start:
      {
	__prints ( ">>>>> case start" );

	if ( me->status_display_form_ptr )
	{
	  char txt[80];

	  if ( me->num_located > 0 )
	  {
	    sprintf ( txt, "Total number of objects located = %d", me->num_located );
	    FIg_set_text ( me->status_display_form_ptr, FI_MSG_FIELD, txt );
	  }
	  else if ( assoc_opt == 0 )
	  {
	    FIg_set_text ( me->status_display_form_ptr, FI_MSG_FIELD, "" );
	    FIg_enable	 ( me->status_display_form_ptr, MCF_1 );
            FIg_enable	 ( me->status_display_form_ptr, AVOID_FALSE );
	  }
	}

	num_sets = me->num_sets;
	if (me->add_to_set)
	  num_loc_sets = num_sets;
	else
	  num_loc_sets = num_sets + 1;

	if (ME.super_cmd->mytype == IntfBxsec)
	  strcpy (elemtype, "cross-section plane");
	else
	  strcpy (elemtype, "surface/solid");

	locate_mask = GRm_DATA | GRm_BACK_UP | GRm_OBJID | GRm_SPECIFIED_OBJ | GRm_TEXT_VALUE;

	if (me->num_located)
	{
	  locate_mask |= GRm_RJT_MOVEON;
	  ex$message (msgnumb = EMS_P_IdElemMvOn, buff = loc_prompt,
		      type = "%s %d", var = `elemtype, num_loc_sets`);
	}
	else
	{
	  ex$message (msgnumb = EMS_P_IdElem, buff = loc_prompt,
		      type = "%s %d", var = `elemtype, num_loc_sets`);
	}

	accept_mask = GRm_DATA | GRm_TEXT_VALUE;
	ex$message (msgnumb = EMS_P_AcElemRj, buff = acc_prompt,
		    type = "%s %d", var = `elemtype, num_loc_sets`);

	ex$message (msgnumb = EMS_I_00013, buff = reloc_prompt);

	display_flag = ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT |
	  LC_ERASE_ALL;

	attr.properties =	LC_LC_ONLY	|	/* Locate locatable objects */
				LC_DP_ONLY	|	/* Locate displayable objects */
				IGN_MOD_BIT	|	/* Ignore modified and new props */
				IGN_PLANAR_BIT	|	/* Ignore planar checks */
				LC_RW;			/* I am only going to read*/
	attr.owner_action =	LC_RIGID_OWNER	|	/* Composites */
				LC_RIGID_COMP	|	/* Members of composites */
				LC_FLEX_OWNER	|	/* Graphic groups, etc. */
				LC_FLEX_COMP	|	/* Members of graphic groups, etc. */
				LC_REF_OBJECTS	|	/* Objects in ref. files are allowed */
				LC_NO_REF_HEADER;	/* No reference file headers */

	rtree_classes.w_count = 1;
	elig_classes.w_count  = (ME.super_cmd->mytype == IntfBxsec) ? 1 : 4;
	rtree_classes.w_flags = elig_classes.w_flags = OM_CLST_subclass;

	rclass = (ME.super_cmd->mytype == IntfBxsec) ? OPP_EMSplane_class_id : OPP_EMSsubbs_class_id;

	if(ME.super_cmd->mytype == IntfBxsec)
	  eliclass[0] = OPP_EMSplane_class_id;
	else
	{
//        eliclass[0] = OPP_EMSsurface_class_id;
//        eliclass[1] = OPP_GRowner_class_id;
//        eliclass[0] = OPP_VRPCorentity_class_id;
	  eliclass[0] = OPP_ASnode_class_id;
	  eliclass[1] = OPP_VDSroot_class_id;
	  eliclass[2] = OPP_EMSsurface_class_id;
	  eliclass[3] = OPP_GRowner_class_id;
	}

	rtree_classes.p_classes = &rclass;
	elig_classes.p_classes  = &eliclass[0];

	/*
	 * Call the graphic set deposit function.  This will help
	 * us weed out garbage from the fence.
	 */

	sts = gr$gsput_locate_criteria(
				       msg = &msg,
				       attributes = &attr,
				       rtree_classes = &rtree_classes,
				       eligible_classes = &elig_classes);
	ERRORs(sts, msg, "ECintf_exec gsput_locate_criteria", wrapup);

	/*
	 * call an action handler to mark already located
	 * objects as not eligible for locate.
	 */

	{
	  extern IGRlong		VD_EFlocate_action_handler();
	  struct VDSaction_handler	already_located;	/* HF : TR #:179601630		*/

	  already_located.next			= NULL;
	  already_located.option		= 0;		/* Don't locate objects in list	*/
	  already_located.type			= 0;		/* passing GRlc_info's		*/
	  already_located.num_objects		= 0;
	  already_located.objects.lc_info	= NULL;

	  if ( me->num_located > 0 )
	  {
	    already_located.objects.lc_info = _MALLOC ( me->num_located, struct GRlc_info * );

	    __printf ( "already_located.num_objects = %d, me->num_located = %d, already_located.objects.lc_info = %#x",
		       `already_located.num_objects, me->num_located, already_located.objects.lc_info` );

	    if ( already_located.objects.lc_info )
	    {
	      already_located.num_objects	= me->num_located;

	      for ( i=0; i < me->num_located; i++ )
	      {
		already_located.objects.lc_info[i] = &me->locate_info[i];
	      }
	    }
	    else
	    {
	      __print_goto ( "wrapup" );
	      sts = 0;
	      EMerr_hndlr ( sts, msg, EMS_E_NoDynamicMemory, wrapup);
	    }
	  }

	  lc$locate(	rc		= &msg,
			event1		= &me->locate_event,
			event2		= &me->locate_event,
			mask1		= locate_mask,
			mask2		= accept_mask,
			eventsize	= &size,
			display_flag	= display_flag,
			response	= response,
			response_data	= response_data,
			unhilight_mode	= (enum GRdpmode) GRhhd,
			locate_prompt	= loc_prompt,
			acc_prompt	= acc_prompt,
			relocate_prompt	= reloc_prompt,
			attributes	= &attr,
			act_handler	= VD_EFlocate_action_handler,
			act_args	= &already_located,
			stack		= &me->locate_stack,
			rtree_classes	= &rtree_classes,
			eligible_classes= &elig_classes,
			regex		= TRUE);

	  _FREE ( already_located.objects.lc_info );
	}

	token = GRloc_token(&msg, Tokens, &me->locate_event);
	__prints ( "<<<<< case start" );
	break;
      }
    case filename:
      {
	FILE	*ptr = NULL;

	__prints ( ">>>>> case filename" );

	ex$message(msgnumb = EMS_P_ReportFileName);
	locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;

	token = GRget_token(&msg, Tokens, &locate_mask,
			    &me->locate_event, &size,
			    response, response_data);
	ex$message (msgnumb = EMS_S_ClearStatusField);
	ex$message (msgnumb = EMS_P_ClearPromptField);

	if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
	  me->stdreportonly = TRUE;
	else if(Tokens[token] == STRING)
	{
	  strcpy(me->filename, me->locate_event.event.keyin);
	  me->stdreportonly = FALSE;
	  ptr = fopen(me->filename, "r");
	  if(ptr)
	  {
	    ex$message(msgnumb = EMS_I_FileExistsWillApp);
	    ems_sleep(3);
	    fclose(ptr);
	  }
	}
	__prints ( "<<<<< case filename" );

	break;
      }
    case ask_cv:
      {
	int	sts, is_displayed = 0;

	if( (ME.super_cmd->mytype == IntfXsec) ||
	    (ME.super_cmd->mytype == IntfBxsec))
	{
	  me->nocurves = TRUE;
	  token = 3;	/* Simulate string event */
	  break;
	}

	if ( me->status_display_form_ptr )
	{
	  sts = FIf_is_displayed ( me->status_display_form_ptr, &is_displayed );
	}

	if ( is_displayed )
	{
	  token = 3;	/* Simulate string event: We don't need to prompt now */
	  break;
	}

	__prints ( ">>>>> case ask_cv" );

	UI_prompt ("Generate interference macros? (NO=0,REAL=1,ALL=2)[0]");

//  ex$message(msgnumb = EMS_P_CrIntfCv);

	locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;

	token = GRget_token(&msg, Tokens, &locate_mask,
			    &me->locate_event, &size,
			    response, response_data);
	ex$message (msgnumb = EMS_S_ClearStatusField);
	ex$message (msgnumb = EMS_P_ClearPromptField);

	me->nocurves = FALSE;
	assoc_opt = 0;

	if ((Tokens[token] == EX_RJT_MOVEON) || (msg == GRw_no_value))
	{
	  assoc_opt = 0;
	  FIg_enable	  ( me->status_display_form_ptr, MCF_1 );
	}
	else if(Tokens[token] == STRING)
	{
	  if      (me->locate_event.event.keyin[0] == '1')
	  {
	    assoc_opt = 1;
	  }
	  else if (me->locate_event.event.keyin[0] == '2')
	  {
	    assoc_opt = 2;
	  }
	  else
	  {
	    assoc_opt = 0;
	  }

	  if ( assoc_opt == 0 )
	  {
	    FIg_enable	  ( me->status_display_form_ptr, MCF_1 );
	    FIg_enable	  ( me->status_display_form_ptr, AVOID_FALSE );
	  }
	  else		// DON'T ALLOW CHANGE of ELEMENT REPRESENTATION
	  {
	    FIg_disable	  ( me->status_display_form_ptr, MCF_1 );
	  }
          FIg_set_state   ( me->status_display_form_ptr, AVOID_FALSE,  VD_avoid_false_interf );
	}
/*  NOT USED ANYMORE
    if ((Tokens[token] == EX_RJT_MOVEON) || (msg == GRw_no_value))
      me->nocurves = TRUE;
    else if(Tokens[token] == STRING)
    {
      if(toupper(me->locate_event.event.keyin[0]) == 'Y')
	me->nocurves = FALSE;
      else me->nocurves = TRUE;
    }
*/
	__printf ( "<<<<< case ask_cv : assoc_opt = %d, me->nocurves = %d", `assoc_opt, me->nocurves`);

	break;
      }
    case ask_vol:
      {
	if( (ME.super_cmd->mytype == IntfXsec) ||
	    (ME.super_cmd->mytype == IntfBxsec))
	{
	  me->novol = TRUE;
	  token = 3;	/* Simulate string event */
	  break;
	}

	__prints ( ">>>>> case ask_vol" );

	ex$message(msgnumb = EMS_P_CrIntfVl);
	locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;

	token = GRget_token(&msg, Tokens, &locate_mask,
			    &me->locate_event, &size,
			    response, response_data);
	ex$message (msgnumb = EMS_S_ClearStatusField);
	ex$message (msgnumb = EMS_P_ClearPromptField);

	if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
	  me->novol = TRUE;
	else if(Tokens[token] == STRING)
	{
	  if(toupper(me->locate_event.event.keyin[0]) == 'Y')
	    me->novol = FALSE;
	  else me->novol = TRUE;
	}
	__prints ( "<<<<< case ask_vol" );

	break;
      }
    case ask_ort:
      {
	IGRint	i;
	OMuword	locclassid;
	struct GRid	sfid;
	if( (me->num_ornted == me->num_located) ||
	    (ME.super_cmd->mytype == IntfXsec) ||
	    (ME.super_cmd->mytype == IntfBxsec))
	{
	  if( (ME.super_cmd->mytype == IntfXsec) ||
	      (ME.super_cmd->mytype == IntfBxsec))
	    me->num_ornted = me->num_located;

	  token = 3;	   /* Simulate string event */
	  break;
	}

	__prints ( ">>>>> case ask_ort" );

	for(i=me->num_ornted; i<me->num_located; i++)
	{
	  sfid = me->locate_info[i].located_obj;

	  sts = om$get_classid(objid = sfid.objid, osnum = sfid.osnum,
			       p_classid = &locclassid);
	  if ((om$is_ancestry_valid (subclassid = locclassid,
				     superclassid = OPP_EMSsolid_class_id) == OM_S_SUCCESS) ||
	      (om$is_ancestry_valid (subclassid = locclassid,
				     superclassid = OPP_EMSsurface_class_id) != OM_S_SUCCESS))
	  {
	    me->num_ornted++;
	    continue;
	  }
	  else
	  {
	    struct GRmd_env	*junk;

	    junk = &me->ModuleInfo; /*&me->locate_info[i].module_info;*/

	    sts = om$send ( msg	 = message EMSsurface.EMshow_normals (&msg,
								junk, &ME.CEO_LOCATE->ActiveDisplay, GRhd),
			    targetid = sfid.objid, targetos = sfid.osnum);
	    ERRORs(sts, msg, "VDintf EMshow_normals", wrapup);

	    ex$message(msgnumb = EMS_P_VlSdDef);
	    locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;

	    token = GRget_token(&msg, Tokens, &locate_mask,
				&me->locate_event, &size,
				response, response_data);
	    ex$message ( msgnumb = EMS_S_ClearStatusField);
	    ex$message ( msgnumb = EMS_P_ClearPromptField);

	    sts = om$send ( msg	 = message EMSsurface.EMshow_normals (&msg,
								junk, &ME.CEO_LOCATE->ActiveDisplay, GRhe),
			    targetid = sfid.objid, targetos = sfid.osnum);
	    ERRORs(sts, msg, "VDintf EMshow_normals", wrapup);

	    if(Tokens[token] == STRING)
	    {
	      if(toupper(me->locate_event.event.keyin[0]) == 'N')
	      {
		sts = om$send ( msg	     = message EMSsurface.EMrevorient (&msg),
				targetid = sfid.objid, targetos = sfid.osnum);
		ERRORs(sts, msg, "VDintf EMrevorient", wrapup);
		me->reversed[i] = !me->reversed[i];
	      }
	    }

	    if(Tokens[token] == EX_BACK_UP)
	    {
	      if(me->num_ornted)
	      {
		struct GRid junk;
		junk = me->locate_info[me->num_ornted - 1].located_obj;
		if(me->reversed[me->num_ornted - 1])
		{
		  sts = om$send (msg = message EMSsurface.EMrevorient (&msg),
				 targetid = junk.objid,
				 targetos = junk.osnum);
		  ERRORs(sts, msg, "VDintf_exec erase", wrapup);
		  me->reversed[me->num_ornted - 1] = FALSE;
		}
	      }
	      me->num_ornted--;
	      break;
	    }
	    else if ( Tokens[token] == EX_RJT_MOVEON ||
		      (Tokens[token] == STRING && toupper(me->locate_event.event.keyin[0]) == 'D') )
	    {
	      me->num_ornted = me->num_located;
	      break;
	    }
	    else if ((msg == GRw_no_value) ||
		     (Tokens[token] == STRING))
	      me->num_ornted++;
	    else
	      break;
	  } /* if not a solid */

	}/* for(i=me->num_ornted; i<me->num_located; i++) */

	if (ME.super_cmd->mytype == IntfBatch)
	{
	  if (!me->novol || !me->nocurves)
	  {
	    IGRlong stat_func, msg_loc, eventmask;
	    struct GRevent event;

	  askfile:
	    ex$message (msgnumb = EMS_P_FileForCvsVls);

	    eventmask = GRm_STRING;
	    stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
				     response = response, response_data = response_data,
				     event = &event);
	    ex$message (msgnumb = EMS_P_ClearPromptField);
	    if (event.response != EX_STRING)
	    {
	      ex$message(msgnumb = EMS_S_InpIgnored);
	      goto askfile;
	    }
	    else
	    {
	      FILE *fileptr;

	      fileptr = fopen (event.event.keyin, "w");
	      if (!fileptr)
	      {
		ex$message (msgnumb = EMS_E_InvalidFile);
		ems_sleep (2);
		goto askfile;
	      }
	      else
	      {
		fclose (fileptr);
		strcpy (me->savefile, event.event.keyin);
	      }
	    }
	  }

	  if (!ex$is_batch())
	  {
	    IGRint stat_func, msg_loc, eventmask;
	    struct GRevent event;

	  askmoveon:
	    ex$message(msgnumb = EMS_S_IntAnaInBatch);
	    ex$message(msgnumb = EMS_P_MvonBatFilCre);

	    eventmask = GRm_RJT_MOVEON;
	    stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
				     response = response, response_data = response_data,
				     event = &event);
	    ex$message(msgnumb = EMS_P_ClearPromptField);
	    if (event.response != EX_RJT_MOVEON)
	    {
	      ex$message(msgnumb = EMS_S_InpIgnored);
	      goto askmoveon;
	    }

	    *response = TERMINATE;
	    token = 5;
	  }
	}
	__prints ( "<<<<< case ask_ort" );

	break;
      }
    case ask_area:
      {
	if(ME.super_cmd->mytype == Intf || ME.super_cmd->mytype == IntfBatch)
	{
	  me->noarea = TRUE;
	  token = 3;	/* Simulate string event */
	  break;
	}
	__prints ( ">>>>> case ask_area" );

	ex$message(msgnumb = EMS_P_CrIntfAr);
	locate_mask = GRm_STRING | GRm_RJT_MOVEON | GRm_BACK_UP;

	token = GRget_token(&msg, Tokens, &locate_mask,
			    &me->locate_event, &size,
			    response, response_data);
	ex$message ( msgnumb = EMS_S_ClearStatusField);
	ex$message ( msgnumb = EMS_P_ClearPromptField);

	if ((Tokens[token] == EX_RJT_MOVEON)  || (msg == GRw_no_value))
	  me->noarea = TRUE;
	else if(Tokens[token] == STRING)
	{
	  if(toupper(me->locate_event.event.keyin[0]) == 'Y')
	       me->noarea = FALSE;
	  else me->noarea = TRUE;
	}
	__prints ( "<<<<< case ask_area" );

	break;
      }
    case analyze:
      {
        FILE                  *fpdb = NULL;
        IGRchar                prog_msg[80], act_fil[80], *ptr = NULL;
        IGRchar                filnam[DI_PATH_MAX], cl_nm[DI_PATH_MAX];
        IGRboolean             hilted = FALSE;
        IGRushort              options = NULL;
        IGRint                 i, num_result = 0, total_result = 0;
        IGRlong                rc;
        IGRdouble              scale = 1;
        struct EMSintf        *result = NULL;
        struct GRvg_construct  konst;

	extern void            EMintf_free();
	extern int             VD_Interference_Analysis;	/* GLOBAL : TRUE if VDS Interference Analysis is active	*/
                                                                /* 	    FALSE otherwise				*/
	__prints ( ">>>>> case analyze" );

	konst.msg		= (IGRlong *)&msg;
	konst.class_attr	= NULL;
	konst.level		= ME.CEO_LOCATE->ActiveLevel;
	konst.display		= &ME.CEO_LOCATE->ActiveDisplay;
	konst.env_info		= &me->ModuleInfo;
	konst.newflag		= FALSE;
	konst.name		= NULL;
	konst.properties	= GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
	konst.geometry		= NULL;

	sts = dp$erase_hilite(msg = &msg);
	ERRORs(sts, msg, "VDintf_exec erase hi", wrapup);
	ex$message (msgnumb = EMS_I_Processing);
	ex$message (msgnumb = EMS_P_ClearPromptField);

	/*
	 * Send message for analysis. In the case of multiple sets, process
	 * the sets in a combinatoric manner.
	 */

	if(me->nocurves) options  = EMSintf_NoCurves;
	if(me->novol)    options |= EMSintf_NoVolElems;
	if(me->noarea)   options |= EMSintf_NoAreaElems;

	if(! msg_opt)    options |= EMSintf_NoStatMsg;

	if(!me->stdreportonly) options |= EMSintf_ReportBoth;
	options |= EMSintf_Display;

	if(ME.super_cmd->mytype == IntfBxsec)
	  options |= EMSintf_InputXsec;

	options |= EMSintf_NoCrossHatch;

	num_sets   = me->num_sets;
	num_in_set = me->num_in_set;
	set_info   = me->set_info;

////////////////////////////////////////////////////
	/*
	 * Save & Remove objects from me->locate_info & me->num_in_set
	 */

	sts = om$send (	msg	 = message VDintf.VDintf_sav_locat_info(&msg),
			targetid = my_id);

	/*
	 * Modify (temporarily) VDS Representation according to selected options,
	 * but ONLY if "assoc_opt == 0"
	 * otherwise	DON'T ALLOW CHANGE of ELEMENT REPRESENTATION
	 */
	if (assoc_opt == 0)
	{
	  sts = om$send ( msg	   = message VDintf.VDintf_modif_repr(&msg),
                          targetid = my_id);
	  nd$exec_batch();
	}
////////////////////////////////////////////////////
        if (TRUE)    // msg_opt
        {
          sts = ex$filename (name = filnam, len = DI_PATH_MAX);
          strcpy (prog_msg, "Progress_VDS_Intf_");

          ptr = strrchr (filnam, '/') + 1;
          strcpy (act_fil, ptr);
          ptr = strrchr (act_fil, '.');
          if (ptr)
            *ptr = 0;
          strcat (prog_msg, act_fil);
          __printf("<<<<< %s >>>>>", `prog_msg`);

          fpdb = fopen(prog_msg, "w");
          if (fpdb)
          {
            char   *supercls1 = {"Use_Old_Interf = 1"};
            char   *supercls2 = {"Use_New_Interf = 1"};
            char   *supercls3 = {"Do_NOT_Reduce_Range"};
            char   *supercls4 = {"Reduce_Range = 1"};
            char   *ptr0, *ptr1;
            OMuword clid;
            int     idx = 0;

            // Scale can be varied between 0.9 - 0.9999 ...
            scale = get_intf_shrinkage();

            if (VD_use_old_intf)
              ptr0 = supercls1;
            else
              ptr0 = supercls2;

            if (skip_reduce_range)
              ptr1 = supercls3;
            else
              ptr1 = supercls4;

            if (VD_avoid_false_interf)
            {
              fprintf(fpdb, "\n%s\n\n  Assoc_Option = %d, Suppress_False_Interf = %d, Scaling_Factor = %lg, %s, %s\n\n",
                      filnam, assoc_opt, VD_avoid_false_interf, scale, ptr0, ptr1);
            }
            else
            {
              fprintf(fpdb, "\n%s\n\n  Assoc_Option = %d, Suppress_False_Interf = %d, %s, %s\n\n",
                      filnam, assoc_opt, VD_avoid_false_interf, ptr0, ptr1);
            }

            for (i=0; i < num_sets; i++)
            {
              for (j=0; j < num_in_set[i]; j++)
              {
                om$get_classid ( objid     = me->locate_info[idx].located_obj.objid,
                                 osnum     = me->locate_info[idx].located_obj.osnum,
                                 p_classid = &clid);

                om$get_classname(classid   = clid,
                                 classname = cl_nm );

                fprintf(fpdb, "Set [i = %d] - objID [j =%4d] = [%d,%4d]\tClassID = %4d\tClassName = %s\n", i, j,
                        me->locate_info[idx].located_obj.osnum,
                        me->locate_info[idx].located_obj.objid, clid, cl_nm);
                idx++;
              }
              fprintf(fpdb, "\n");
            }
            fprintf(fpdb, "==================================================\n\n");

            if (num_sets > 1)
            {
              for (i=0; i < num_sets; i++)
              {
                fprintf(fpdb, "Number of Objects in Set [%d] = %d\n", i, num_in_set[i]);
              }
              fprintf(fpdb, "\n==================================================\n\n");
            }
            fclose (fpdb);
          }
        }
////////////////////////////////////////////////////
	for (i=0; num_sets == 1 && i == 0 ? TRUE : i<num_sets-1; i++)
	{
	  for (j=i+1; num_sets == 1 && j == i+1 ? TRUE : j<num_sets; j++)
	  {
	    IGRint a, inx1, inx2;

	    inx1 = 0;
	    for (a=0; a<i; a++)
	      inx1 += num_in_set[a];

	    inx2 = 0;
	    for (a=0; a<j; a++)
	      inx2 += num_in_set[a];

	    /*
	     * HF 9/5/94  - Set GLOBAL VD_Interference_Analysis to TRUE to enable the function
	     * 		EMintf_report() to differentiate between EMS & VDS Interefence Analysis
	     *		(This function is called from within:	VD_EManalyzeIntf() or
	     *							EMSsurface.EManalyzeIntfAlongXsec()
	     */

	    VD_Interference_Analysis = TRUE;

	    if (ME.super_cmd->mytype == Intf || ME.super_cmd->mytype == IntfBatch)
            {
              int avoid_false_interf = VD_avoid_false_interf;
              if (avoid_false_interf == 1)
                  avoid_false_interf += 3;
	      sts = VD_EManalyzeIntf(&rc,
                                     &set_info[i],
                                     &me->locate_info[inx1],
                                      num_in_set[i],
                                      i+1,
                                     &set_info[num_sets == 1 ? i : j],
                                     &me->locate_info[num_sets == 1 ? inx1 : inx2],
                                      num_in_set[num_sets == 1 ? i : j],
                                      num_sets == 1 ? i+1 : j+1,
                                      options,
                                      me->stdreportonly ? NULL : me->filename,
                                     &konst,
                                     &result,
                                     &num_result,
                                      me->status_display_form_ptr,
                                     assoc_opt, avoid_false_interf, VD_use_old_intf, skip_reduce_range,
                                     prog_msg);
            }
	    else
	      sts = om$send(msg = message EMSsurface.EManalyzeIntfAlongXsec(
					&rc,
					&set_info[i],
					&me->locate_info[inx1],
					num_in_set[i],
					i+1,
					&set_info[num_sets == 1 ? i : j],
					&me->locate_info[num_sets == 1 ? inx1 : inx2],
					num_in_set[num_sets == 1 ? i : j],
					num_sets == 1 ? i+1 : j+1,
					options,
					me->stdreportonly ? NULL : me->filename,
					&konst,
					ME.super_cmd->mytype == IntfBxsec ? NULL : &me->plane,
					&result,
					&num_result),
			    targetid = me->locate_info[inx1].located_obj.objid,
			    targetos = me->locate_info[inx1].located_obj.osnum);
	    total_result += num_result;

	    VD_Interference_Analysis = FALSE;	/* Reset GLOBAL to FALSE */

	    if (rc == EMS_E_FileOpen)
	    {
	      ex$message(msgnumb = EMS_E_OpenFileW, type = "%s", var = me->filename);
	      ems_sleep(2);
	      rc = EMS_S_Success;
	      sts = OM_S_SUCCESS;
	    }

	    if (rc == EMS_I_Interrupt)
	    {
	      ex$message(msgnumb = EMS_I_ProcessingInterrupt);
	      ems_sleep(2);
	    }

	    if (EMSerror (rc & sts))
	    {
	      ex$message(msgnumb = EMS_E_AnalysisFailed);
	    }
	    else if (!num_result)
	    {
	      ex$message(msgnumb = EMS_I_NoIntfFound);
	    }
	    else
	    {
	      ex$message(msgnumb = EMS_I_AnalysisComplete);

	      hilted = FALSE;
	      if (!me->nocurves)
	      {
		IGRint i, j;

		for (i=0; i<num_result && !hilted; i++)
		  for(j=0; j<result[i].numintf && !hilted; j++)
		    if (!IF_NULL_OBJID (
					result[i].info.qualitative[j].inters.objid))
		      hilted = TRUE;
		if (hilted)
		{
		  ex$message(msgnumb = EMS_I_AnlCompCvHiLted);
		  ems_sleep(2);
		}
	      }

	      hilted = FALSE;
	      if (!me->noarea)
	      {
		IGRint i, j, m;

		for (i=0; i<num_result && !hilted; i++)
		  for (j=0; j<result[i].numintf && !hilted; j++)
		    for (m=0; m<NumIntfCases && !hilted; m++)
		      if (!IF_NULL_OBJID(result[i].info.xsec[j].areas[m].objid))
			hilted = TRUE;
		if (hilted)
		{
		  ex$message(msgnumb = EMS_I_AnlCompAreaHiLted);
		  ems_sleep(2);
		}
	      }

	      hilted = FALSE;
	      if (ME.super_cmd->mytype == IntfXsec)
	      {
		IGRint i, j, m;

		for (i=0; i<num_result && !hilted; i++)
		  for (j=0; j<result[i].numintf && !hilted; j++)
		    for (m=0; m<NumIntfCases && !hilted; m++)
		      if (result[i].info.xsec[j].linesegs[m][0] ||
			  result[i].info.xsec[j].linesegs[m][1])
			hilted = TRUE;

		if (hilted)
		{
		  ex$message(msgnumb = EMS_I_AnlCompMinMaxSegHiLted);
		  ems_sleep(2);
		}
	      }

	      hilted = FALSE;
	      if (!me->novol)
	      {
		IGRint i, j;

		for (i=0; i<num_result && !hilted; i++)
		  for(j=0; j<result[i].numintf && !hilted; j++)
		    if (!IF_NULL_OBJID (
					result[i].info.qualitative[j].volelem.objid))
		      hilted = TRUE;

		if (hilted)
		{
		  ex$message(msgnumb = EMS_I_AnlCompVolHiLted);
		  ems_sleep(2);
		}
	      }
	    }

	    if (result)
	      EMintf_free (result, num_result);
	  }
	}
        // Delete ProgressMessages file if msg_opt == 0
        if ( msg_opt == 0 )
        {
          unlink(prog_msg);
        }

////////////////////////////////////////////////////
	/*
	 * Restore objects which have been removed from me->locate_info & me->num_in_set
	 */

	sts = om$send (	msg	 = message VDintf.VDintf_restore_locat_info(&msg),
			targetid = my_id);

	/*
	 * Reset to original VDS Representation
	 */
	if (assoc_opt == 0)
	{
	  sts = om$send (	msg	 = message VDintf.VDintf_reset_repr(&msg),
				targetid = my_id);
	}
////////////////////////////////////////////////////

	/*
	 * If this is batch processing and if curves/volumes have been
	 * generated, then save the active file into the the new file
	 * specified earlier.
	 */

	if (ME.super_cmd->mytype == IntfBatch)
	{
	  if ((!me->novol || !me->nocurves) &&
	      total_result)
	    ex$save_module (ftype = EX_visible,
			    newfilename = me->savefile);

	  *response = TERMINATE;
	  token = 5;
	}

	me->num_located		= 0;
	me->num_ornted		= 0;
	me->num_sets		= 0;
	me->add_to_set		= 0;
	me->stdreportonly	= FALSE;
	me->nocurves		= TRUE;
	me->novol		= TRUE;
	me->noarea		= TRUE;

	__prints ( "<<<<< case analyze" );

	break;
      }
    default:
      ERRORs(OM_E_ABORT, EMS_E_Fail, "VDintf_exec state garbage", wrapup);
      break;
    }

    me->my_action  = NextAction[ME.super_cmd->state][token];
    ME.super_cmd->state = NextState[ME.super_cmd->state][token];

  } while(Tokens[token] != GR_UNKNOWN_TYPE);

  if ( *response == CLEAR_STACK &&
       ME.super_cmd->mytype == IntfBatch &&
       ! ex$is_batch())
  {
    IGRlong msg_loc;

    EMstop_record(&msg_loc);
  }

  if ( me->status_display_form_ptr )
  {
    FIf_get_location ( me->status_display_form_ptr, &VDintf_x_memo, &VDintf_y_memo );
    me->origin_x = VDintf_x_memo;
    me->origin_y = VDintf_y_memo;
  }
  __printf ( "me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  __exitMethod ( name = "execute" );

  return (sts);

wrapup:
  ex$message(msgnumb = EMS_F_0002);
  *response = TERMINATE;

  __exitMethod ( name = "execute" );

  return(OM_E_ABORT);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
# define	LIST_SIZE	(20)
# define	USER_SIZE	(80)
# define	USER_FLD_SIZE	(8)

  char		txt[80];

  IGRlong	msg;
  int		i0, j0, k0, act_row, act_clm, pos, sts, s_flg;
  int		rep_fld_flag = 0, data_size = 0;
  int		sel_flag[MCF_1_NUM_COL];
  unsigned char	rep_txt [USER_SIZE+1], null_txt[] = { "" };
  struct GRid		rg_coll;
  struct ACrg_coll	rg_list[LIST_SIZE];

  __enterMethod ( name = "form_notification" );

  if ( form_ptr )
  {
    if ( form_ptr != me->status_display_form_ptr )
    {
      me->status_display_form_ptr = form_ptr;
    }
  }
  else
  {
    __print_goto ( "quit" );
    goto quit;
  }

  sts = FIg_get_text         ( me->status_display_form_ptr, ASSOC_FIELD, txt );
  sts = FIfld_get_active_row ( me->status_display_form_ptr, ASSOC_FIELD, &act_row, &pos );
  assoc_opt = act_row;

  sts = FIg_get_state        ( me->status_display_form_ptr, DELETE_ASSOC, &del_all_intf );
  sts = FIg_get_state        ( me->status_display_form_ptr, DELETE_EMPTY, &del_emp_intf );

  if ( assoc_opt == 0 )
  {
    FIg_enable	  ( me->status_display_form_ptr, MCF_1 );
    FIg_enable	  ( me->status_display_form_ptr, AVOID_FALSE );
  }
  else		// DON'T ALLOW CHANGE of ELEMENT REPRESENTATION
  {
    FIg_disable	  ( me->status_display_form_ptr, MCF_1 );
  }

  if ( del_all_intf || del_emp_intf )
  {
    FIg_enable  ( me->status_display_form_ptr, FI_EXECUTE );
  }
  else
  {
    FIg_disable ( me->status_display_form_ptr, FI_EXECUTE );
  }

  __printf ( ">>>>> form_ptr = %#x, assoc_opt = %d, msg_opt = %d, del_all_intf = %d, VD_avoid_false_interf = %d, skip_reduce_range = %d",
             `form_ptr, assoc_opt, msg_opt, del_all_intf, VD_avoid_false_interf, skip_reduce_range` );

  switch ( gadget_label )
  {
  case FI_CANCEL:
    {
//      _put_response ( resp = STRING /* EX_FORM_FINISHED */ );		// DOES NOT WORK ==>> SIGSEGV !?!?!?!
    }
  case FI_ACCEPT:     /* Member of group FI_CTRL_GROUP */
    {
      /* Erase the displayed form */

      FIf_erase ( form_ptr );
      me->form_requested = FALSE;

      /* Process form data */

      break;
    }
  case PROGR_MESSG:
    {
      __printf ( ">>>>> case PROGR_MESSG: msg_opt = %d", `msg_opt` );

      sts = FIg_get_state        ( me->status_display_form_ptr, PROGR_MESSG, &msg_opt );

      __printf ( "<<<<< case PROGR_MESSG: msg_opt = %d", `msg_opt` );

      break;
    }
  case REDUC_RANGE:
    {
      __printf ( ">>>>> case REDUC_RANGE: skip_reduce_range = %d", `skip_reduce_range` );

      sts = FIg_get_state        ( me->status_display_form_ptr, REDUC_RANGE, &skip_reduce_range );

      if ( skip_reduce_range )
      {
	sts = FIg_set_text ( me->status_display_form_ptr, FI_MSG_FIELD, "Do NOT Reduce Range of Elements..." );
      }
      else
      {
	sts = FIg_set_text ( me->status_display_form_ptr, FI_MSG_FIELD, "Reduce Range of Elements..." );
      }

      __printf ( "<<<<< case REDUC_RANGE: skip_reduce_range = %d", `skip_reduce_range` );

      break;
    }
  case FI_EXECUTE:     /* Member of group FI_CTRL_GROUP */
    {
      if ( del_all_intf )
      {
	/*
       * Delete ALL existing Interference Macros
       * =======================================
       */
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_DK_RED );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD, "Deleting ALL Interference Macros..." );

	VDdelete_all_intf_macros ( me->status_display_form_ptr, &me->ModuleInfo, 0 );

	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );

	sts = FIg_set_state      ( me->status_display_form_ptr, DELETE_ASSOC, FALSE );
	sts = FIg_disable	 ( me->status_display_form_ptr, FI_EXECUTE );
	del_all_intf = FALSE;
      }
      else if ( del_emp_intf )
      {
	/*
       * Delete EMPTY Interference Macros
       * ================================
       */
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_DK_BLUE );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD,
				   "Deleting EMPTY Interference Macros (without graphics)..." );

	VDdelete_all_intf_macros ( me->status_display_form_ptr, &me->ModuleInfo, 1 );

	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );

	sts = FIg_set_state      ( me->status_display_form_ptr, DELETE_EMPTY, FALSE );
	sts = FIg_disable	 ( me->status_display_form_ptr, FI_EXECUTE );
	del_emp_intf = FALSE;
      }

      break;
    }
  case AVOID_FALSE:
    {
      IGRdouble scale;
      char strng[80];

      __printf ( ">>>>> case AVOID_FALSE: VD_avoid_false_interf = %d", `VD_avoid_false_interf` );

      sts = FIg_get_state        ( me->status_display_form_ptr, AVOID_FALSE, &VD_avoid_false_interf );

      // Scale can be varied between 0.9 - 0.9999 ...
      scale = get_intf_shrinkage();

      // Toggle also the static variable REV_avoid_false_interf in "Review Interference Objects" ...
      // This will allow enabling "Suppress False Interferences" in already placed macros...
      sts = toggle_false_interf_review();
      if (VD_avoid_false_interf)
      {
        if (! sts)
          toggle_false_interf_review();
      }
      else
      {
        if (sts)
          toggle_false_interf_review();
      }

      if ( VD_avoid_false_interf )
      {
        sprintf(strng,"Suppress creation of 'False' Interferences (Scale_Factor = %lg)...", scale);
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_DK_BLUE );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD, strng );
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );
	sts = FIg_enable	 ( me->status_display_form_ptr, AVOID_FALSE );
      }
      else
      {
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD, "" );
      }

      __printf ( "<<<<< case AVOID_FALSE: VD_avoid_false_interf = %d, scale = %lg", `VD_avoid_false_interf, scale` );

      break;
    }
  case DELETE_ASSOC:
    {
      __printf ( ">>>>> case DELETE_ASSOC: del_all_intf = %d", `del_all_intf` );

      sts = FIg_get_state        ( me->status_display_form_ptr, DELETE_ASSOC, &del_all_intf );
      if ( del_all_intf )
      {
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_DK_RED );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD,
				   "Pressing the RUN/EXECUTE button will delete ALL Interference Macros" );
	sts = FIg_enable	 ( me->status_display_form_ptr, FI_EXECUTE );
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );

	del_emp_intf = FALSE;
	sts = FIg_set_state      ( me->status_display_form_ptr, DELETE_EMPTY, FALSE );
      }
      else
      {
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD, "" );
	sts = FIg_disable	 ( me->status_display_form_ptr, FI_EXECUTE );
      }

      __printf ( "<<<<< case DELETE_ASSOC: del_all_intf = %d", `del_all_intf` );

      break;
    }
  case DELETE_EMPTY:
    {
      __printf ( ">>>>> case DELETE_EMPTY: del_emp_intf = %d", `del_emp_intf` );

      sts = FIg_get_state        ( me->status_display_form_ptr, DELETE_EMPTY, &del_emp_intf );
      if ( del_emp_intf )
      {
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_DK_BLUE );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD,
				   "Pressing the RUN/EXECUTE button will delete EMPTY Interference Macros" );
	sts = FIg_enable	 ( me->status_display_form_ptr, FI_EXECUTE );
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );

	del_all_intf = FALSE;
	sts = FIg_set_state      ( me->status_display_form_ptr, DELETE_ASSOC, FALSE );
      }
      else
      {
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD, "" );
	sts = FIg_disable	 ( me->status_display_form_ptr, FI_EXECUTE );
      }

      __printf ( "<<<<< case DELETE_EMPTY: del_emp_intf = %d", `del_emp_intf` );

      break;
    }
  case ASSOC_FIELD:
    {
      __printf ( ">>>>> case ASSOC_FIELD: assoc_opt = %d", `assoc_opt` );

      sts = FIg_get_text         ( me->status_display_form_ptr, ASSOC_FIELD, txt );
      sts = FIfld_get_active_row ( me->status_display_form_ptr, ASSOC_FIELD, &act_row, &pos );
      assoc_opt = act_row;

      if ( assoc_opt == 0 )
      {
	FIg_enable	  ( me->status_display_form_ptr, MCF_1 );
        FIg_enable	  ( me->status_display_form_ptr, AVOID_FALSE );
      }
      else		// DON'T ALLOW CHANGE of ELEMENT REPRESENTATION
      {
	FIg_disable	  ( me->status_display_form_ptr, MCF_1 );

	sts = FIg_set_text( me->status_display_form_ptr, FI_MSG_FIELD,
			    "Cannot change representation if Assoc Option > 0 (AsIs will be used)" );
	sleep (3);
      }
      FIg_set_state       ( me->status_display_form_ptr, AVOID_FALSE,  VD_avoid_false_interf );

      if ( act_row == 0 )
      {
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD, "" );
      }
      else if ( act_row == 1 )
      {
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD,
				   "Macro is deleted when Interference is resolved" );
      }
      else if ( act_row == 2 )
      {
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_YELLOW );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD,
				   "This option may dramatically increase file-size: Use with CAUTION" );
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );
      }

      __printf ( "<<<<< case ASSOC_FIELD: assoc_opt = act_row = %d, txt = <%s>", `act_row, txt` );

      break;
    }
  case MCF_1:
    {
      for ( i0=0; i0 < me->tot_nr_fls; i0++ )
      {
	/*
	 * Get the select_status of the 1st column in the MCF
	 */
	sts = FIfld_get_select ( me->status_display_form_ptr, MCF_1, i0, 0, &sel_flag[0] );

	if ( sts == FI_SUCCESS )
	{
	  if ( sel_flag[0] )
	  {
	    sts = FIfld_get_active_row ( me->status_display_form_ptr, MCF_1, &act_row, &pos );
	    sts = FImcf_get_active_col ( me->status_display_form_ptr, MCF_1, &act_clm, &pos );

	    /*
	     * Make sure that ONLY ONE field of columns 2, 3 & 4 can be selected
	     */

	    for ( j0=1; j0 < MCF_1_NUM_COL; j0++ )
	    {
	      if ( act_row == i0 )
	      {
		if ( act_clm == j0 )
		{
		  sts = FIfld_set_select ( me->status_display_form_ptr, MCF_1, i0, j0, TRUE );
		}
		else
		{
		  sts = FIfld_set_select ( me->status_display_form_ptr, MCF_1, i0, j0, FALSE );
		}
	      }
	      sts = FIfld_get_select ( me->status_display_form_ptr, MCF_1, i0, j0, &sel_flag[j0] );
	    }

	    /*
	     * Depending on the select_status of columns 2, 3 & 4 , set the instance var. for the
	     * representation accordingly, and erase text in column 5
	     */

	    if ( sel_flag[1] )
	    {
	      me->ref_rpr[i0].ref_rpr = 0;
	      sts = FIfld_set_text ( me->status_display_form_ptr, MCF_1, i0, 4, null_txt, FALSE );
	    }
	    else if ( sel_flag[2] )
	    {
	      me->ref_rpr[i0].ref_rpr = AC_3D_REP;
	      sts = FIfld_set_text ( me->status_display_form_ptr, MCF_1, i0, 4, null_txt, FALSE );
	    }
	    else if ( sel_flag[3] )
	    {
	      me->ref_rpr[i0].ref_rpr = AC_ENV_REP;
	      sts = FIfld_set_text ( me->status_display_form_ptr, MCF_1, i0, 4, null_txt, FALSE );
	    }
	    else if ( sel_flag[4] )
	    {
	      /*
	       * User wants to choose a representation from the POSSIBLE_REP list,
	       * so we have to enable & display the appropiate gadgets
	       */

	      FIg_enable ( me->status_display_form_ptr, REP_FIELD );
	      FIg_display( me->status_display_form_ptr, REP_FIELD );
	      FIg_enable ( me->status_display_form_ptr, TXT_GADG  );
	      FIg_display( me->status_display_form_ptr, TXT_GADG  );

	      rep_fld_flag = TRUE;

	      /*
	       * Get the GRid of the ACrg_collect object in the selected object space
	       * and use this GRid to find the (struct ACrg_coll) rg_list, containing
	       * the possible representations.
	       * Fill out the text_field (REP_FIELD) with the names of the representations.
	       */

	      VDintf_get_possible_rep_col ( me->ref_rpr[i0].osnum, &rg_coll );

	      data_size = 0;
	      sts = om$send (	msg	 = message ACrg_collect.AClist_attribute(
									&msg,
									 LIST_SIZE,
									 rg_list,
									&data_size ),
				targetid = rg_coll.objid,
				targetos = rg_coll.osnum);

	      if ( (sts & msg & 1) && data_size )
	      {
		for ( k0=0; k0 < data_size; k0++ )
		{
		  sts = FIfld_set_text ( me->status_display_form_ptr, REP_FIELD, k0, 0, rg_list[k0].name, FALSE );
		}
	      }
	    }
	  }
	  else
	  {
	    /*
	     * One of the fields in column 1 has been 'un'selected, so 'un'select
	     * ALL other fields in this row, and also erase text in column 5 !
	     */

	    for ( j0=1; j0 < MCF_1_NUM_COL; j0++ )
	    {
	      sts = FIfld_set_select ( me->status_display_form_ptr, MCF_1, i0, j0, FALSE );
	      if ( j0 == 4 )
		sts = FIfld_set_text ( me->status_display_form_ptr, MCF_1, i0, j0, null_txt, FALSE );
	    }
	    /*
	     * Set value to UNSIGNED_CHAR_0 to indicate that objects with this
	     * Representation should be removed from the locate_info lists
	     */

	    me->ref_rpr[i0].ref_rpr = UNSIGNED_CHAR_0;
	  }
	}
	else
	{
	  break;
	}
      }

      if ( ! rep_fld_flag )
      {
	FIg_disable ( me->status_display_form_ptr, REP_FIELD );
	FIg_erase   ( me->status_display_form_ptr, REP_FIELD );
	FIg_disable ( me->status_display_form_ptr, TXT_GADG  );
	FIg_erase   ( me->status_display_form_ptr, TXT_GADG  );
      }

      for ( i0=0; i0 < me->tot_nr_fls; i0++ )
      {
	sts = FIfld_get_select ( me->status_display_form_ptr, MCF_1, i0, 0, &sel_flag[0] );

	if ( sts == FI_SUCCESS )
	{
	  if ( ! sel_flag[0] )
	  {
	    /*
	     * remove_flag = TRUE means that objects which meet criteria (equal osnum's for
	     * objects from locate_info list and 'un'selected line in MCF) will be removed
	     * from locate_info list in 'action VDintf_sav_locat_info'
	     */

	    me->remove_flag = TRUE;

	    break;
	  }
	}
      }

      if ( assoc_opt && ( sel_flag[2] || sel_flag[3] || sel_flag[4] ) )
      {
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_RED );
	sts = FIg_set_text	 ( me->status_display_form_ptr, FI_MSG_FIELD,
				   "The selected Representation is stored in the Macro and never updated" );
//				   "A recompute will occur when finished, but representation info will be saved" );
//				   "The RUN button will convert ALL Interference Macros to Assoc Option 2" );
	sts = FIg_set_color	 ( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );
      }

      break;
    }
  case REP_FIELD:
    {
      sts = FIfld_get_active_row ( me->status_display_form_ptr, REP_FIELD, &act_row, &pos );

      if ( sts == FI_SUCCESS )
      {
	/*
	 * Get the text of the active (selected) row in the REP_FIELD
	 */

	sts = FIfld_get_text ( me->status_display_form_ptr, REP_FIELD, act_row, 0, USER_SIZE+1, rep_txt, &s_flg, &pos );

	/*
	 * Find which field in the "User" column (col 5) of the MCF has been selected.
	 * Copy the text to this field, after first having determined which representation
	 * this text represents in the ACrg_collect object.
	 * The value for the representation (rg_list[k0].desc.value.att_exp) is copied to
	 * the instance var. (me->ref_rpr[i0].ref_rpr).
	 */

	for ( i0=0; i0 < me->tot_nr_fls; i0++ )
	{
	  sts = FIfld_get_select ( me->status_display_form_ptr, MCF_1, i0, 4, &sel_flag[4] );

	  if ( sts == FI_SUCCESS )
	  {
	    if ( sel_flag[4] )
	    {
	      VDintf_get_possible_rep_col ( me->ref_rpr[i0].osnum, &rg_coll );

	      data_size = 0;
	      sts = om$send (	msg	 = message ACrg_collect.AClist_attribute(
									&msg,
									 LIST_SIZE,
									 rg_list,
									&data_size ),
				targetid = rg_coll.objid,
				targetos = rg_coll.osnum);

	      if ( (sts & msg & 1) && data_size )
	      {
		for ( k0=0; k0 < data_size; k0++ )
		{
		  if ( rg_list[k0].desc.type == 2 && strcmp( rg_list[k0].name, (char *)rep_txt ) == 0 )
		  {
		    me->ref_rpr[i0].ref_rpr = (unsigned char) rg_list[k0].desc.value.att_exp;

		    break;
		  }
		}
	      }

	      rep_txt[USER_FLD_SIZE] = '\0';
	      sts = FIfld_set_text ( me->status_display_form_ptr, MCF_1, i0, 4, rep_txt, TRUE );

	      break;
	    }
	  }
	}
      }

      break;
    }
  } /* END switch ( gadget_label ) */

  __printf ( "<<<<< form_ptr = %#x, assoc_opt = %d, msg_opt = %d, del_all_intf = %d, skip_reduce_range = %d",
             `form_ptr, assoc_opt, msg_opt, del_all_intf, skip_reduce_range` );

  __exitMethod ( name = "form_notification" );

quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method status_disp ( )
{
#define	MAX_REF		(500)

  extern	VDfind_ref_files();

  char		osname[OM_K_MAXOSNAME_LEN];
  GRspacenum	ref[MAX_REF];
  int 		i0, nb_ref, sts, FI_sts, tot_cnt = 2;

  __enterMethod ( name = "status_disp" );

  nb_ref = 0;
  FI_sts = FI_SUCCESS;

  __printf ( ">>>>> me->origin = [%d,%d], VDintf_memo = [%d,%d]", `me->origin_x, me->origin_y, VDintf_x_memo, VDintf_y_memo` );

  sts = om$send ( msg	   = message CEO.status_disp(),
		  targetid = my_id,
		  mode	   = OM_e_wrt_message);

  __printf ( "<<<<< me->origin = [%d,%d]", `me->origin_x, me->origin_y` );

  if ( me->status_display_form_ptr && ( del_all_intf || del_emp_intf ) )
  {
    FIg_enable  ( me->status_display_form_ptr, FI_EXECUTE );
  }
  else
  {
    FIg_disable ( me->status_display_form_ptr, FI_EXECUTE );
  }

  VDfind_ref_files( ref, MAX_REF, &nb_ref);

  if ( nb_ref > 1 )
  {
    tot_cnt = nb_ref + 1;

    sts = om$vla_set_dimension(	varray	= me->ref_rpr,
				size	= tot_cnt);
    ERRORs(sts, EMS_S_Success, "VDintf_exec expand ref_rpr", quit);
  }

  sts = om$os_number_to_name (	osnum	= 2,
				osname	= osname);

  if ( me->status_display_form_ptr )
  {
    if ( me->status_form_initialized == FALSE || me->tot_nr_fls != nb_ref + 1 )
    {
      FIf_reset( me->status_display_form_ptr );

      if ( sts == OM_S_SUCCESS )
      {
	FI_sts =  FIfld_set_text   ( me->status_display_form_ptr, MCF_1, 0, 0, osname, TRUE );
	FI_sts =  FIfld_set_select ( me->status_display_form_ptr, MCF_1, 0, 1, TRUE );
      }

      for ( i0=0; i0 < nb_ref; i0++ )
      {
	sts = om$os_number_to_name (osnum	= ref[i0],
				    osname	= osname);
	if (sts == OM_S_SUCCESS)
	{
	  FI_sts =  FIfld_set_text   ( me->status_display_form_ptr, MCF_1, i0+1, 0, osname, TRUE );
	  FI_sts =  FIfld_set_select ( me->status_display_form_ptr, MCF_1, i0+1, 1, TRUE );
	}
      }
      if ( sts == OM_S_SUCCESS && FI_sts == FI_SUCCESS )
      {
	me->ref_rpr[0].osnum   = 2;
	me->ref_rpr[0].ref_rpr = 0;

	for ( i0=0; i0 < nb_ref; i0++ )
	{
	  me->ref_rpr[i0+1].osnum   = ref[i0];
	  me->ref_rpr[i0+1].ref_rpr = 0;
	}
	me->status_form_initialized = TRUE;
	me->form_requested	  = TRUE;
      }
    }
  }

  me->tot_nr_fls = nb_ref + 1;

  FIg_set_state  ( me->status_display_form_ptr, PROGR_MESSG,  msg_opt );
  FIg_set_state  ( me->status_display_form_ptr, REDUC_RANGE,  skip_reduce_range );

  if ( assoc_opt == 0 )
  {
    FIg_enable	  ( me->status_display_form_ptr, MCF_1 );
    FIg_enable	  ( me->status_display_form_ptr, AVOID_FALSE );
  }
  else		// DON'T ALLOW CHANGE of ELEMENT REPRESENTATION
  {
    FIg_disable	  ( me->status_display_form_ptr, MCF_1 );
  }
  FIg_set_state   ( me->status_display_form_ptr, AVOID_FALSE,  VD_avoid_false_interf );

  if ( assoc_opt == 1 )
  {
    FIfld_set_active_row( me->status_display_form_ptr, ASSOC_FIELD, 1, 0 );
    FIg_set_text        ( me->status_display_form_ptr, FI_MSG_FIELD,
			  "Macro is deleted when Interference is resolved" );
  }
  else if ( assoc_opt == 2 )
  {
    FIfld_set_active_row( me->status_display_form_ptr, ASSOC_FIELD, 2, 0 );

    FIg_set_color	( me->status_display_form_ptr, FI_MSG_FIELD, FI_YELLOW );
    FIg_set_text        ( me->status_display_form_ptr, FI_MSG_FIELD,
			  "This option may dramatically increase file-size: Use with CAUTION" );
    FIg_set_color	( me->status_display_form_ptr, FI_MSG_FIELD, FI_BLACK );
  }

  __exitMethod ( name = "status_disp" );
quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method VDintf_reset_repr ( long * sts )
{
  int           i0, sts;
  unsigned char nv_rep = UNSIGNED_CHAR_0;

  __enterMethod ( name = "VDintf_reset_repr", argfmt = "nv_rep(UNSIGNED_CHAR_0) = %d", args = `nv_rep` );

  for ( i0=0; i0 < me->num_located; i0++ )
  {
    sts = om$send ( msg      = message ACncpx.ACget_NV_rep( &nv_rep ),
                    targetid = me->locate_info[i0].located_obj.objid,
                    targetos = me->locate_info[i0].located_obj.osnum);

    if( nv_rep != me->ac_rpr[i0] )
    {
      sts = om$send ( msg      = message ACncpx.ACset_NV_rep (
                                            me->ac_rpr     [i0],
                                          &(me->locate_info[i0]).module_info),
                      targetid = me->locate_info[i0].located_obj.objid,
                      targetos = me->locate_info[i0].located_obj.osnum);

    }
  }
  __exitMethod ( name = "VDintf_reset_repr" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method VDintf_modif_repr ( long * sts )
{
  int	i0, j0, sts;

  __enterMethod ( name = "VDintf_modif_repr" );

  for ( i0=0; i0 < me->num_located; i0++ )
  {
    unsigned char	repr   = me->ac_rpr     [i0];
    struct GRid		obj_id = me->locate_info[i0].located_obj;

    for ( j0=0; j0 < me->tot_nr_fls; j0++ )
    {
      struct VDref_rep	rf_rp = me->ref_rpr[j0];

      if ( rf_rp.ref_rpr &&
	   rf_rp.ref_rpr != UNSIGNED_CHAR_0 &&
	   rf_rp.ref_rpr != repr &&
	   rf_rp.osnum   == obj_id.osnum )
      {
        __printf("obj_id[%d] = [%d,%d], me->ac_rpr[%d] = %d, me->ref_rpr[%d] = %d",
                 `i0, obj_id.osnum, obj_id.objid, i0, repr, j0, rf_rp.ref_rpr`);

	sts = om$send(	msg = message ACncpx.ACset_NV_rep (
						  rf_rp.ref_rpr,
						&(me->locate_info[i0]).module_info ),
			targetid = obj_id.objid,
			targetos = obj_id.osnum);
      }
    }
  }
  __exitMethod ( name = "VDintf_modif_repr" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method VDintf_sav_locat_info ( long * sts )
{
  int		i0, j0, k0 = 0, m0 = 0, n0 = -1, sts;
  IGRint	n_i_s;		/* DEBUG purpose only */
  IGRlong	msg;

  __enterMethod ( name = "VDintf_sav_locat_info" );

  if ( me->remove_flag == FALSE )
  {
    __exitMethod ( name = "VDintf_sav_locat_info" );
    return 1;
  }

  /*
   * First allocate memory for saving 'me->locate_info' & 'me->num_sets'
   */

  sts = om$vla_set_dimension(	varray	= me->sav_locat_info,
				size	= me->num_located+2 );
  EMerr_hndlr (EMSerror (sts), msg, EMS_E_NoDynamicMemory, quit);

  sts = om$vla_set_dimension(	varray	= me->sav_nm_in_set,
				size	= me->num_sets );
  EMerr_hndlr (EMSerror (sts), msg, EMS_E_NoDynamicMemory, quit);

  OM_BLOCK_MOVE ( me->locate_info, me->sav_locat_info, me->num_located * sizeof(struct GRlc_info) );

  for ( i0=0; i0 < me->num_sets; i0++)
  {
    me->sav_nm_in_set[i0] = me->num_in_set[i0];
  }

  me->sav_nm_located = me->num_located;

  /*
   * Next remove from 'me->locate_info' those objects which meet the 'un'select criteria
   * from the Status_Form and adjust 'me->num_sets' accordingly.
   * (correct result for this operation depends on carefully adjusting index n0)
   */

  for ( i0=0, n0=0; i0 < me->sav_nm_located; i0++, ++n0)
  {
    for ( j0=0; j0 < me->tot_nr_fls; j0++)
    {
      if (	me->ref_rpr[j0].ref_rpr == UNSIGNED_CHAR_0  &&
		me->ref_rpr[j0].osnum   == me->sav_locat_info[i0].located_obj.osnum )
      {
	OM_BLOCK_MOVE ( &me->sav_locat_info[i0+1], &me->locate_info[n0],
			(me->sav_nm_located - (i0+1)) * sizeof (struct GRlc_info));

	me->num_located--;
	n0--;

	for ( k0=0; k0 < me->num_sets; k0++)
	{
	  m0 += me->sav_nm_in_set[k0];
	  if ( i0 < m0 )
	  {
	    me->num_in_set[k0]--;
	    n_i_s = me->num_in_set[k0];
	    break;
	  }
	}
	m0 = 0;
      }
    }
  }
  __exitMethod ( name = "VDintf_sav_locat_info" );
quit:
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method VDintf_restore_locat_info ( long * sts )
{
  int		i0;

  __enterMethod ( name = "VDintf_restore_locat_info" );

  if ( me->remove_flag == FALSE )
  {
    __exitMethod ( name = "VDintf_restore_locat_info" );
    return 1;
  }

  me->num_located = me->sav_nm_located;

  OM_BLOCK_MOVE ( me->sav_locat_info, me->locate_info, me->num_located * sizeof (struct GRlc_info));

  for ( i0=0; i0 < me->num_sets; i0++)
  {
    me->num_in_set[i0] = me->sav_nm_in_set[i0];
  }
  __exitMethod ( name = "VDintf_restore_locat_info" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

void	VDdelete_all_intf_macros
(
  Form		  *form_ptr,
  struct GRmd_env *mod_env,
  IGRint	   delete_option	/* 0 = delete ALL ; 1 = delete EMPTY */
)
{
  char			txt[80];
  IGRint		sts = OM_S_SUCCESS, i0 = 0, j0, cnt, number_of_empties = 0;
  IGRlong		msg;
  OM_S_OBJID		*list = NULL;
  OM_S_CHANSELECT	my_chansel;
  OM_S_OBJECT_LINKAGE	lobj;
  enum GRdpmode		Display_Mode = GRbehe;

  __enterFunction ( name = "VDdelete_all_intf_macros" );

  sts = VDpms_find_objects ( (OMuword)2, OPP_nci_macro_class_id, &cnt, NULL );
  __printf ( ">>>>>>>>>> VDpms_find_objects() : sts = %d, Number of nci_macros = %d", `sts, cnt` );

  if ( cnt )
  {
    list = _MALLOC ( cnt, OM_S_OBJID );
    if ( list == NULL ) goto quit;
  }
  else
  {
    goto quit;
  }
  /*
   * Find ALL objects of class nci_macro
   */
  sts = VDpms_find_objects ( (OMuword)2, OPP_nci_macro_class_id, &cnt, list );

  sprintf ( txt, "Found a total of %d Macros...", cnt );
  if ( form_ptr )
  {
    sts = FIg_set_text	 ( form_ptr, FI_MSG_FIELD, txt );
  }
  else
  {
    UI_status ( txt );
  }

  /*
   * ONLY MACROS with name VDinterf_cvs should be deleted !!!!
   */
  j0 = cnt;

//////////////////////////////////
  while ( i0 < j0 )
  {
    char		*c = NULL;
    OMuword		clid;
    struct GRid		macro;

    om$get_classid ( objid	= list[i0],
		     osnum	= (OMuword)2,
		     p_classid	= &clid);

    if ( om$is_ancestry_valid ( subclassid = clid, superclassid = OPP_nci_macro_class_id) == OM_S_SUCCESS)
    {
      sts =
	om$send (	msg	 = message ACcpx.find_macro ( &macro ),
			targetid = list[i0],
			targetos = (OMuword)2,
			senderid = NULL_OBJID);
      sts =
	om$send (	msg	 = message ACcpx_defn.ACgive_name ( &c ),
			targetid = macro.objid,
			targetos = macro.osnum,
			senderid = NULL_OBJID);

      if ( c && strcmp ( c, "VDinterf_cvs" ) != 0 )
      {
	j0--;
	memcpy( &list[i0], &list[i0+1], (j0 - i0) * sizeof(OM_S_OBJID) );
      }
      else
      {
	/*
	 * This is a VDinterf_cvs macro which needs to be kept in the list
	 */
	if ( delete_option == TRUE )	// Remove REAL VDinterf_cvs (NON-EMPTY) Macros from the list
	{
	  /*
	   * Check for ACpl_hold on the to_component channel : if found KEEP them IN the list
	   */
	  my_chansel.type	= OM_e_name;
	  my_chansel.u_sel.name = "to_components";

	  sts = om$get_channel_objects(
				osnum		= (OMuword)2,
				objid		= list[i0],
				p_chanselect	= &my_chansel,
				size		= (cnt=1),
				list		= &lobj,
				count		= (OMuint *)&cnt );

	  om$get_classid (	objid		= lobj.S_objid,
				osnum		= lobj.osnum,
				p_classid	= &clid );

	  if ( clid != OPP_ACpl_hold_class_id )
	  {
	    /*
	     * This is a REAL VDinterf_cvs macro which needs to be removed from the list
	     */
	    j0--;
	    memcpy( &list[i0], &list[i0+1], (j0 - i0) * sizeof(OM_S_OBJID) );
	  }
	  else
	  {
	    __printf ("ACcpx_defn.ACgive_name: i0 = %d, list[%d] = [%d,%d], name = <%s>", `i0, j0, 2, list[i0], c` );

	    i0++;
	    number_of_empties++;	// Counting empty Interferences
	  }
	}
	else
	{
	  i0++;
	}
      }
    }
  }
//////////////////////////////////

  cnt = j0;
  __printf ( ">>>>>>>>>> VDpms_find_objects() : sts = %d, Number of VDinterf_cvs macros = %d", `sts, cnt` );

  if ( delete_option )
  {
    sprintf ( txt, "Found %d EMPTY Interference Macros...", cnt );
  }
  else
  {
    sprintf ( txt, "Found %d Interference Macros...", cnt );
  }

  if ( form_ptr )
  {
    sts = FIg_set_text	 ( form_ptr, FI_MSG_FIELD, txt );
  }
  else
  {
    UI_status ( txt );
  }

  for ( i0=0; i0 < cnt; i0++ )
  {
/**/
    sts =
      om$send(	msg	 = message GRgraphics.GRdisplay(
						   &msg,
						   &mod_env->md_env.matrix_type,
						    mod_env->md_env.matrix,
						   &Display_Mode,
						   &mod_env->md_id),
		targetid = list[i0],
		targetos = (OMuword)2,
		senderid = NULL_OBJID);
/**/
    sts =
      om$send (	msg	 = message GRgraphics.GRdelete ( &msg, mod_env),
		targetid = list[i0],
		targetos = (OMuword)2,
		senderid = NULL_OBJID);
  }
//  sts = dp$update ( msg = &msg, osnum = (OMuword)2 );

  if ( delete_option )
  {
    sprintf ( txt, "Deleted %d EMPTY Interference Macros...", cnt );
  }
  else
  {
    sprintf ( txt, "Deleted %d Interference Macros...", cnt );
  }

  if ( form_ptr )
  {
    sts = FIg_set_text	 ( form_ptr, FI_MSG_FIELD, txt );
  }
  else
  {
    UI_status ( txt );
  }

quit:

  _FREE ( list );
  __exitFunction ( name = "VDdelete_all_intf_macros" );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDintf;
