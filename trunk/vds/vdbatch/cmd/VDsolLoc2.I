/* $Id: VDsolLoc2.I,v 1.1.1.1 2001/01/04 21:07:56 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdbatch/cmd/VDsolLoc2.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsolLoc2.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:56  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/01/12  08:50:08  pinnacle
# Replaced: vdbatch/cmd/VDsolLoc2.I for:  by msbraju for vds.240
#
# Revision 1.4  1995/09/18  19:05:22  pinnacle
# Replaced: ./vdbatch/cmd/VDsolLoc2.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/08/31  21:48:08  pinnacle
# Replaced: ./vdbatch/cmd/VDsolLoc2.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/28  13:01:24  pinnacle
# Replaced: vdbatch/cmd/VDsolLoc2.I for:  by msbraju for vds.240
#
# Revision 1.1  1995/07/25  21:01:42  pinnacle
# Created: vdbatch/cmd/VDsolLoc2.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	07/25/95	raju		creation date
 *
 ***************************************************************************/

class implementation Root;
/*
Name
   VDlocateWithSolid2

Abstract
   This function locates elements inside/overlapping a solid. This function
can also be used for just obtaining list of objects which have the needed
relation with solid(s).
   When used for locating objects, only one solid is accepted.
   When list of objects is desired, more than one solid can be input.

Arguments
  long			*msg	    O - return status 
  int			num_sol	    I - num of solids with which
				       objects need to be located.
				       when output_mode == VD_LOCATE_WITH_SOLID
				       num_sol should be 1        
  struct GRid		*sol_list	I - list of solids
  struct GRmd_env	*sol_env_list   I - list of solid envs
					  = NULL, if all are in master OS.
  int			num_qry		I - num of queries
  struct GRid		*qry_list	I - list of query ids
  char			rln_needed      I - objects having this relation with
					    solid will be located.
					    can be one of VD_EL_INSIDE,
					    VD_EL_INSIDE_OVERLAP, VD_EL_OVERLAP.
					    see vdsollocdef.h.
  char			output_mode	I - function is being called for this
					    purpose.
					= VD_LOCATE_WITH_SOLID, locating with
					  a solid. ( output will be an event
					  containing objects located ).
					= VD_LIST_OF_OBJECTS, list of objects
					  is returned to be used by caller.
  struct GRid		*window_id	I - window containing the solids.
					= NULL if not known.
  int			*NbObj		O - No. of objects found.
  struct GRobj_env	**obj_list_out  O - List of objects found. ( valid
					    only when
					    output_mode = VD_LIST_OF_OBJECTS ).
					= NULL if not needed.
Notes
   when output_mode == VD_LOCATE_WITH_SOLID, only one solid is expected.

IMPORTNANT
   when output_mode == VD_LIST_OF_OBJECTS and obj_list_out != NULL,
	obj_list_out is malloced by this function. Should be freed by caller.

History

   13/09/94 : Raju - Genesis
*/
#include "exdef.h"
#include "exmacros.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "madef.h"
#include "bserr.h"
#include "ex.h"
#include "msmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "grmsg.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "comiscmac.h"

#include "grgsmacros.h"
#include "dp.h"
#include "lcdef.h"
#include "lc.h"
#include "grgs.h"
#include "growner.h"
#include "dpdef.h"
#include "EMSmsgdef.h"
#include "comiscmac.h"

#include "vderrmacros.h"
#include "vdsollocdef.h"
#include "vdparmacros.h"
#include "v_miscmacros.h"

#define  VD_RP_INSIDE  1
#define  VD_LIST_INCR	     50

extern OMuword  OPP_ACncpx_class_id,
		OPP_GRclhdr_class_id,
		OPP_GRsmhdr_class_id;

extern  IGRboolean              IGEstop();

from	GRgrset		import	GSstart_transition,
				GSend_transition,
				GSget_object,
				GSremove_member,
				GSdissolve;
from 	IGEgragad	import	DPinquire;
from 	GRgraphics	import	GRgetrang;
from 	EMSsurface	import EMputLsIfNotThere;

/*
 This static function gets objid of one of the active gadgets.
*/
static long  VDget_gadget_id(
  long		*msg,
  struct GRid	*gadget_id
)
{
long		 sts;
struct GRid	 mod_id;
OM_S_CHANSELECT  to_windows,
		 win_to_gadgets;
OM_S_OBJECT_LINKAGE  win_link,
		     gadg_link;
OMuint		 num_win, num_gadgets;

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;

    ex$get_cur_mod ( id = &mod_id.objid, osnum = &mod_id.osnum );

    sts = om$make_chanselect (  channame = "module.windows",
				p_chanselect = &to_windows );

    sts = om$get_channel_count( objid           =   mod_id.objid,
				osnum           =   mod_id.osnum,
				p_chanselect    =   &to_windows,
				count           =   &num_win	);
    if ( num_win == 0 )
    {
	sts = OM_E_ABORT;
	*msg = MSFAIL;
	goto wrapup;
    }

    sts = om$get_channel_objects( objid         =  mod_id.objid,
				  osnum         =  mod_id.osnum,
				  p_chanselect  =  &to_windows,
				  list          =  &win_link,
				  size          =  1,
				  count         =  &num_win );
    VDS_ERR_HNDLR( "om$get_channel_objects", sts, MSSUCC, VD_VERBOSE, wrapup );
#ifdef VDS_DBG
    printf("\twindow id = [%d,%d]\n", win_link.S_objid, win_link.osnum);
#endif

    sts = om$make_chanselect ( channame = "IGEgadget.to_children",
				p_chanselect = &win_to_gadgets );

    sts = om$get_channel_count( objid           =   win_link.S_objid,
				osnum           =   win_link.osnum,
				p_chanselect    =   &win_to_gadgets,
				count           =   &num_gadgets      );
    if ( num_gadgets == 0 )
    {
	sts = OM_E_ABORT;
	*msg = MSFAIL;
	goto wrapup;
    }

    sts = om$get_channel_objects( objid         =  win_link.S_objid,
				  osnum         =  win_link.osnum,
				  p_chanselect  =  &win_to_gadgets,
				  list          =  &gadg_link,
				  size          =  1,
				  count         =  &num_gadgets );
    VDS_ERR_HNDLR( "om$get_channel_objects", sts, MSSUCC, VD_VERBOSE, wrapup );
#ifdef VDS_DBG
    printf("\tgadget id = [%d,%d]\n", gadg_link.S_objid, gadg_link.osnum);
#endif

    /* get last point */
/*
struct EX_button button;
int		 sizbuf,
		 NoBytesRet;

    sizbuf = sizeof ( struct EX_button );
    sts = gr$get_last_point(	msg    = msg,
				sizbuf = &sizbuf,
				buffer = &button,
				nret   = &NoBytesRet );
    if ( !(sts& *msg & 1) )
    {
	ex$message(field   = ERROR_FIELD,
		   in_buff = "Please enter a data point in window with solids",
		   justification = CENTER_JUS );
	goto wrapup;
    }
*/

    gadget_id->objid = gadg_link.S_objid;
    gadget_id->osnum = gadg_link.osnum;

wrapup:
    return sts;

}

/*
 This static function gets locate criteria.
*/
static void VDget_locate_criteria (
 long			*msg,
 struct GRmd_env	*locate_env,
 struct GRlc_locate	*loc_attributes,
 OM_S_CLASSLIST		*locate_rtree_thing,    /* actual CLASSLIST thing     */
 OM_S_CLASSLIST		*locate_eligible_thing /* actual CLASSLIST thing     */
)
{
int		sizbuf,
		NoBytesRet;

  *msg = MSSUCC;

#if 0
long		sts;
IGRint		criteria_flag;
OMuword		GRgraphics_classid;
 /*
  *  Get the locate criteria.
  */
 sts    = gr$gsget_locate_criteria (
		msg		 =  msg,
		locate_env	 =  locate_env,
		criteria_flag	 =  &criteria_flag,
		attributes	 =  loc_attributes,
		rtree_classes    =  locate_rtree_thing,
		eligible_classes =  locate_eligible_thing  );
 VDS_ERR_HNDLR("gr$gsget_locate_criteria", sts, *msg, VD_VERBOSE, wrapup);

 if (!(criteria_flag & GSPUT_LOCATE_ENV))
 {
    sizbuf = sizeof ( struct GRmd_env );
    gr$get_module_env(msg    = msg,
		      sizbuf = &sizbuf,
		      buffer = locate_env,
		      nret   = &NoBytesRet );	
 }

 if (!(criteria_flag & GSPUT_ATTRIBUTES))
 {
    strcpy (loc_attributes->classes,"GRgraphics");
    loc_attributes->properties = LC_LC_ONLY |
				 LC_RW |
				 LC_DP_ONLY |
				 IGN_MOD_BIT |
				 IGN_PLANAR_BIT;

    loc_attributes->owner_action =  LC_RIGID_OWNER | LC_FLEX_COMP;
 }

 if ( (!(criteria_flag & GSPUT_RTREE_CLASSES)) ||
      (!(criteria_flag & GSPUT_ELIGIBLE_CLASSES)))
 {
    sts    = om$get_classid (classname = "GRgraphics",
			     p_classid = &GRgraphics_classid);

    if (!(criteria_flag & GSPUT_RTREE_CLASSES))
    {
	locate_rtree_thing->w_count = 1;
	locate_rtree_thing->w_flags = OM_CLST_subclass;
	locate_rtree_thing->p_classes = (OMuword *) malloc( sizeof(OMuword) );
	locate_rtree_thing->p_classes[0] = GRgraphics_classid;
    }

    if (!(criteria_flag & GSPUT_ELIGIBLE_CLASSES))
    {
	locate_eligible_thing->w_count = 1;
	locate_eligible_thing->w_flags = OM_CLST_subclass;
	locate_eligible_thing->p_classes = (OMuword *) malloc(sizeof(OMuword));
	locate_eligible_thing->p_classes[0] = GRgraphics_classid;
    }
 }
#endif

    gr$get_module_env(msg    = msg,
		      sizbuf = &sizbuf,
		      buffer = locate_env,
		      nret   = &NoBytesRet );

    strcpy (loc_attributes->classes,"");
    loc_attributes->properties	 = 0x11;
    loc_attributes->owner_action = 0x6f;


    locate_eligible_thing->w_count = 3;
    locate_eligible_thing->w_flags = 1;
    locate_eligible_thing->p_classes = _MALLOC( 3, OMuword );
    locate_eligible_thing->p_classes[0] = OPP_ACncpx_class_id;
    locate_eligible_thing->p_classes[1] = OPP_GRclhdr_class_id;
    locate_eligible_thing->p_classes[2] = OPP_GRsmhdr_class_id;

    
    locate_rtree_thing->w_count = 0;
    locate_rtree_thing->w_flags = 0;
    locate_rtree_thing->p_classes = NULL;

    goto wrapup;

wrapup:
  return;
}

/*
   Function that drives other functions.
*/
long  VDlocateWithSolid2(
  long			*msg,
  int			num_sol,
  struct GRid		*sol_list,
  struct GRmd_env	*sol_env_list,
  int			num_qry,
  struct GRid		*qry_list,
  char			rln_needed,
  char			output_mode,
  struct GRid		*window_id,
  char			*sts_str,
  OM_S_CHANSELECT	*locate_chan,
  GRobjid		cmdId,
  int			*NbObj,
  struct GRobj_env	**obj_list_out
)
{
long			sts;
struct GRmd_env		mod_env,
			locate_env,
			sol_env;

int			sizbuf, NoBytesRet;
struct GRid		loc_window_id,
			sol_id;

struct GRlc_locate	loc_attributes;
OM_S_CLASSLIST          locate_rtree_thing;   /* actual CLASSLIST thing     */
OM_S_CLASSLIST          locate_eligible_thing;/* actual CLASSLIST thing     */
struct GRlc_classes     classinfo;

int			gs_properties;
struct IGRrt_prism      right_prism;
double			wld_to_lcl_mx[16];
IGRint			prism_type;
IGRdouble		prism_poles[15];
int			ii, tenprc;
IGRint			layers_defined;
struct GRrp_action_args rp_action_args;
IGRint			prism_attr, inside_outside;
extern IGRint		GRgs_rp_action();

int			index, cnt, ListSize,
			num_grsets, set_ind;
OM_S_CHANSELECT		to_owners,
			to_components,
			grset_to_sets;
OM_S_OBJECT_LINKAGE	*grsetLinkage = NULL;
struct GRobj_env	*setcomps = NULL;
char			loc_sts_str[80];

struct GRid		gs_id;
struct GRid		sv_id;


 sts = OM_S_SUCCESS;
 *msg = MSSUCC;



 if ( output_mode == VD_LOCATE_WITH_SOLID && num_sol != 1 )
 {
    *msg = MSFAIL;  /* replace by invalid arguments */
    goto wrapup;
 }

 sizbuf = sizeof ( struct GRmd_env );
 gr$get_module_env(msg    = msg,
		   sizbuf = &sizbuf,
		   buffer = &mod_env,
		   nret   = &NoBytesRet );

 if ( window_id == NULL )
 {
    sts = VDget_gadget_id( msg, &loc_window_id );
    VDS_ERR_HNDLR( "VDget_gadget_id", sts, *msg,
		   VD_VERBOSE, wrapup );
 }
 else
    loc_window_id = *window_id;

 __DBGpr_obj("loc_window_id", loc_window_id );

 VDget_locate_criteria(  msg, &locate_env, &loc_attributes,
			 &locate_rtree_thing, &locate_eligible_thing );
 VDS_ERR_HNDLR( "VDget_locate_criteria", OM_S_SUCCESS, *msg,
		 VD_VERBOSE, wrapup );

 __DBGpr_int("locate_rtree_thing.w_count",locate_rtree_thing.w_count);
 __DBGpr_int("locate_eligible_thing.w_count",locate_eligible_thing.w_count);


 right_prism.polygon.points     = prism_poles;

 *NbObj = 0;
 ListSize = VD_LIST_INCR;
 if ( obj_list_out ){
   *obj_list_out = _MALLOC( ListSize, struct GRobj_env );
 }

 for( index =0; index < num_sol; index++)
 {

   if ( IGEstop() ) break;

   if ( sol_env_list )
	sol_env = sol_env_list[index];
   else
	sol_env = mod_env;
   sol_id = sol_list[index];

   gs_id.osnum = mod_env.md_id.osnum;
   sts    = gr$gsinit (msg = msg, flag = 2, p_objid = &gs_id.objid,
	    senderid = NULL_OBJID,
            osnum = mod_env.md_id.osnum,
            p_chanselect = locate_chan );
   VDS_ERR_HNDLR( "gr$gsinit", sts, *msg, VD_VERBOSE, wrapup );
   __DBGpr_obj ( "gs id", gs_id);

   gs_properties = 0;
   sts = om$send (
            msg = message GRgrset.GSstart_transition
            ( msg, &mod_env, &gs_properties, NULL, &sv_id),
	    senderid = NULL_OBJID,
            targetid = gs_id.objid,
            targetos = gs_id.osnum);
   VDS_ERR_HNDLR( "GRgrset.GRstart_transition", sts, *msg, VD_VERBOSE, wrapup );
   __DBGpr_obj ( "sv_id", sv_id );


   sts   = GRbuild_prism_helper ( msg, &loc_window_id, NULL, NULL,
		NULL, NULL, NULL, NULL, wld_to_lcl_mx, NULL);
   VDS_ERR_HNDLR( "VDbuild_prism_helper", OM_S_SUCCESS, *msg,
		  VD_VERBOSE, wrapup );

   sts = VDbuild_right_prism1 ( msg, &sol_id, &sol_env, wld_to_lcl_mx,
			       &loc_window_id, &prism_type, &right_prism );
   VDS_ERR_HNDLR( "VDbuild_right_prism", sts, *msg, VD_VERBOSE, END_TRANSITION);

   sts   = GRbuild_prism_helper ( msg, &loc_window_id, NULL, NULL,
		NULL, NULL, NULL, right_prism.matrix, NULL, NULL);
   VDS_ERR_HNDLR( "VDbuild_prism_helper", OM_S_SUCCESS, *msg,
		 VD_VERBOSE, wrapup );

   layers_defined = FALSE;
   rp_action_args.clip_flag = FALSE;
   rp_action_args.gs_id = gs_id;
   rp_action_args.sv_id = sv_id;

   /*
    * setting the following to VD_EL_INSIDE case
    * to make it 0 warning program
    */

   prism_attr = GO_INSIDE;
   rp_action_args.rp_relation = GO_INSIDE;
   inside_outside = VD_RP_INSIDE;
   switch ( rln_needed )
   {
     case VD_EL_INSIDE :
	 prism_attr = GO_INSIDE;
	 rp_action_args.rp_relation = GO_INSIDE;
	 inside_outside = VD_RP_INSIDE;
	 break;

     case VD_EL_INSIDE_OVERLAP :
	 prism_attr = GO_INSIDE | GO_OVERLAP;
	 rp_action_args.rp_relation = GO_INSIDE | GO_OVERLAP;
	 inside_outside = VD_RP_INSIDE;
	 break;

     case VD_EL_OVERLAP :
	 /* 
	  * give inside also because prism created may be bigger than
	  * actual solid
	  */
	 prism_attr = GO_OVERLAP | GO_INSIDE;
	 rp_action_args.rp_relation = GO_OVERLAP | GO_INSIDE;
	 inside_outside = VD_RP_INSIDE;
	 break;
   }

   classinfo.rtree_classes    = &locate_rtree_thing;
   classinfo.eligible_classes = &locate_eligible_thing;



   sts = gr$gsprism_locate ( msg = msg,
            mod_env = &locate_env,
            window_id = &loc_window_id,
            attributes = &loc_attributes,
            classinfo = &classinfo,
            prism_type = prism_type,
            prism = (IGRchar *)&right_prism,
            prism_attr = prism_attr,
            inside_outside = inside_outside,
            layers = NULL,
            action_handler = GRgs_rp_action,
            action_args = &rp_action_args);

   VDS_ERR_HNDLR ("gr$gsprism_locate", sts, *msg, VD_VERBOSE, END_TRANSITION );

   if ( IGEstop() ) goto END_TRANSITION;

   sts = om$make_chanselect(channame = "GRconnector.to_owners",
                            p_chanselect = &to_owners);

   sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
			     p_chanselect = &to_components);

   sts = om$make_chanselect(channame     = "GRgrset.to_sets",
			     p_chanselect = &grset_to_sets);

   sts = om$get_channel_count(  osnum        = gs_id.osnum,
				objid        = gs_id.objid,
				p_chanselect = &grset_to_sets,
				count        = (OMuint *) &num_grsets );
   if ( num_grsets == 0 )  continue;

   grsetLinkage = _MALLOC( num_grsets, OM_S_OBJECT_LINKAGE );
   if ( !grsetLinkage )
   {
	*msg = EMS_E_NoDynamicMemory;
	sts  = OM_E_NODYNMEM;
	goto wrapup;
   }

   sts = om$get_channel_objects (  osnum	 = gs_id.osnum,
				   objid	 = gs_id.objid,
				   p_chanselect  = &grset_to_sets,
				   list          = grsetLinkage,
				   size          = num_grsets,
				   count         = (OMuint *)&num_grsets );
   VDS_ERR_HNDLR("om$get_channel_objects",sts,MSSUCC,VD_VERBOSE,END_TRANSITION);

   if ( num_grsets )
   {
    sts = om$send(msg = message EMSsurface.EMputLsIfNotThere(msg, 
	    &sol_env.md_env, NULL, NULL, NULL, NULL), senderid = NULL_OBJID, 
	    targetid = sol_id.objid, targetos = sol_id.osnum);
    VDS_ERR_HNDLR("EMSsurface.EMputLsIfNotThere",sts,*msg, VD_VERBOSE, wrapup );
   }

   for( set_ind=0; set_ind<num_grsets; set_ind++)
   {
     struct GRid  grset;
     int	  arrsize, cnt1;

     if ( IGEstop() ) break;

     grset.objid = grsetLinkage[set_ind].S_objid;
     grset.osnum = grsetLinkage[set_ind].osnum;
     sts = om$get_channel_count(osnum        = grset.osnum,
				objid        = grset.objid,
				p_chanselect = &to_components,
				count        = (OMuint *) &cnt1 );
    if ( cnt1 == 0 )  continue;

    setcomps = _MALLOC( cnt1, struct GRobj_env );
    if ( !setcomps )
    {
	*msg = EMS_E_NoDynamicMemory;
	sts  = OM_E_NODYNMEM;
	goto wrapup;
    }

    arrsize = sizeof(struct GRobj_env) * cnt1;
    cnt = 0;
    sts = om$send( msg = message GRgrset.GSget_object (
					msg,
					setcomps,
                    			arrsize,
					&cnt,
					0,
					OM_K_MAXINT ),
		   targetid = grset.objid,
		   targetos = grset.osnum,
		   senderid = NULL_OBJID   );
    VDS_ERR_CONTINUE( "GRsvset.GSget_object", sts, *msg, VD_VERBOSE);

    if ( sts_str )
	strcpy ( loc_sts_str, sts_str );
    else
	loc_sts_str[0] = '\0';

    ex$message (  field		= ERROR_FIELD,
		  justification = CENTER_JUS,
		  in_buff	= loc_sts_str );
    tenprc = cnt/10 + 1;

    for(ii=cnt-1; ii>-1; ii--)
    {
	int  NbObjOut;

	if ( IGEstop() ) break;

	/* display status string */
	if ( (ii/tenprc)*tenprc == ii )
	{
	  strcat ( loc_sts_str, "." );	
	  ex$message (  field		= ERROR_FIELD,
			justification	= CENTER_JUS,
			in_buff		= loc_sts_str );
	}

	NbObjOut = 0;
	__DBGpr_com("Calling VDsolidFilter");
	__DBGpr_obj("Calling for object", setcomps[ii].obj_id);
	__DBGpr_mat("Environ matrix", setcomps[ii].mod_env.md_env.matrix);
	sts = VDsolidFilter ( msg, &sol_id, &sol_env,
			      rln_needed, 1, &setcomps[ii], &NbObjOut, NULL );
	VDS_ERR_HNDLR("VDsolidFilter", sts, *msg, VD_VERBOSE, END_TRANSITION);

	/*
	 * do not consider if the component is solid itself
	 */
	if ( setcomps[ii].obj_id.objid == sol_id.objid &&
	     setcomps[ii].obj_id.osnum == sol_id.osnum )
	    NbObjOut = 0;

	if ( NbObjOut && num_qry )
	{
	    NbObjOut = 0;

	    sts = vd$qry_process (  sts		=  msg,
				    objects	=  &setcomps[ii],
				    nb_objects	=  1,
				    queries	=  qry_list,
				    nb_queries	=  num_qry,
				    nb_found	=  &NbObjOut  );
	    VDS_ERR_CONTINUE("vd$qry_process", sts, *msg, VD_VERBOSE);
	}

	if ( output_mode == VD_LOCATE_WITH_SOLID && NbObjOut == 0 )
	{
	     sts = om$send ( msg = message GRgrset.GSremove_member(
						msg, &setcomps[ii].obj_id ),
			     senderid = NULL_OBJID,
			     targetid = grset.objid,
			     targetos = grset.osnum  );
	     VDS_ERR_HNDLR ( "GRgrset.GRremove_member", sts, *msg,
			     VD_VERBOSE, END_TRANSITION );
/*
	     sts  =om$send ( msg = message Root.disconnect (
					to_components,
					setcomps[ii].obj_id.objid,
					setcomps[ii].obj_id.osnum,
					to_owners ),
			     senderid = NULL_OBJID,
			     targetid = grset.objid,
			     targetos = grset.osnum );
	     VDS_ERR_CONTINUE( "Root.disconnect", sts, MSSUCC, VD_VERBOSE);
*/
	}

	if ( output_mode == VD_LIST_OF_OBJS && NbObjOut == 1 )
	{
	   if ( obj_list_out && ( *NbObj + 1 > ListSize) )
	   {
	     ListSize += VD_LIST_INCR;
	     *obj_list_out = _REALLOC( *obj_list_out, 
					ListSize,
					struct GRobj_env );
	   }
	   if ( obj_list_out)  (*obj_list_out)[*NbObj] = setcomps[ii];
	}
	if ( NbObjOut ) (*NbObj)++;

    } /* for(ii=cnt-1; ii>-1; ii--) */
    _FREE( setcomps );

   } /* for( set_ind=0; set_ind<num_grsets; set_ind++) */
   _FREE( grsetLinkage );

END_TRANSITION:

   sts = om$send (msg = message GRgrset.GSend_transition ( msg, NULL ),
		targetid = gs_id.objid, targetos = gs_id.osnum,
		senderid = NULL_OBJID );

 } /*  for( index =0; index < num_sol; index++) */

 if ( output_mode == VD_LOCATE_WITH_SOLID )
 {
   /*
    *  put set on queue if set contains atleast one element
    */
   if ( *NbObj )
   {
	struct GRevent          event;
	long			size;
	int			response;

      /*
       *  Define the graphics set as the active select set.
       */
      sts = gr$gsput_select_set ( msg	        = msg,
			          mod_env	= &mod_env,
			          select_set_id = &gs_id );

      co$build_button( msg = msg,
                       objid = loc_window_id.objid,
                       osnum = loc_window_id.osnum,
                       button = &event.event.button);

      event.num_id = 1;
      event.located_object[0].located_obj = gs_id;
      event.located_object[0].module_info = mod_env;

      size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

     /*
      * Put EX_OBJID event on front of software queue
      */
     response = EX_OBJID;
     ex$putque( msg = msg,
              response = &response,
              byte     = &size,
              buffer   = (IGRchar *)&event.event.button );

   } /* end of if ( *NbObj ) */
   else
   {
     ex$message (   msgnumb = GR_E_EleNotFnd,
		    field   = ERROR_FIELD,
		    justification = CENTER_JUS );
/*
     sts = om$send ( msg = message GRgrset.GSdissolve ( msg ),
		     targetid = gs_id->objid,
		     targetos = gs_id->osnum,
		     senderid = NULL_OBJID  );
     VDS_ERR_HNDLR( "GRgrset.GSdissolve", sts, *msg, VD_VERBOSE, wrapup );
*/
     *msg = MSSUCC;

     goto wrapup;
   }

  } /* if ( output_mode == VD_LOCATE_WITH_SOLID ) */
  else if (output_mode == VD_LIST_OF_OBJS )
  {
    sts = gr$gsput_select_set ( msg		= msg,
				mod_env		= &mod_env,
				select_set_id	= &gs_id);

    sts = gr$gsempty (	msg		= msg, 
			senderid	= cmdId,
			p_chanselect	= locate_chan );
  }

	wrapup:
		_FREE( setcomps );
		_FREE( grsetLinkage );
		_FREE( locate_rtree_thing.p_classes );
		_FREE( locate_eligible_thing.p_classes );
	
  		__DBGpr_int ( "No. of objects found", *NbObj );
		return OM_S_SUCCESS;
}

#if 0
void vd_tmp_call( int os, char mode)
{
  long sts, msg;
  struct GRid  solid, window;
  struct GRobj_env *objlist = NULL;
  int    NbObj;
struct GRmd_env		sol_env;
int			i, sizbuf, NoBytesRet;


 sizbuf = sizeof ( struct GRmd_env );
 gr$get_module_env(msg    = &msg,
		   sizbuf = &sizbuf,
		   buffer = &sol_env,
		   nret   = &NoBytesRet );	

  solid.objid = 189;  solid.osnum = os;
  sol_env.md_id.osnum = os;
  window.objid = 107; window.osnum = 2;
  sts = VDlocateWithSolid2( &msg,
			1,
			&solid,
			&sol_env,
			0,
			NULL,
			0,
			mode,
			NULL,
			&NbObj,
			&objlist,
			"Processing" );
  if ( mode == 1 )
  {
    for ( i=0; i<NbObj; i++)
       printf("Obj[%d] = [%d,%d]\n", i, objlist[i].obj_id.objid,
					objlist[i].obj_id.osnum);

    _FREE( objlist );
  }

}
#endif

#if 0

action set_locate_criteria
{
OMuword        GRgraphics_classid;
IGRint         i;

   me->locate_env = me->ModuleInfo;

   me->attributes.classes[0]	= '\0';
   me->attributes.properties	= 0x11;
   me->attributes.owner_action	= 0x6f;

   me->locate_rtree_thing.w_count		= 0;
   me->locate_rtree_thing.w_flags		= 0;
   me->locate_rtree_thing.p_classes		= NULL;


   /*
    * allocate space for and copy the rtree and eligible classids
    */
/*
   if (me->locate_rtree_thing.w_count)
   {
      status = om$vla_set_dimension(varray = me->rtree_classids,
                                    size = me->locate_rtree_thing.w_count);

      if (me->criteria_flag_old & GSPUT_RTREE_CLASSES)
      {
         for (i = 0; i < (IGRint)me->locate_rtree_thing_old.w_count; ++i)
         {
            me->rtree_classids[i] = me->locate_rtree_thing_old.p_classes[i];
         }
      }
      else
      {
         me->rtree_classids[0] = GRgraphics_classid;
      }
   }
*/

   me->locate_eligible_thing.w_count	= 3;
   me->locate_eligible_thing.w_flags	= 1;

   if (me->locate_eligible_thing.w_count)
   {
        status = om$vla_set_dimension(varray = me->eligible_classids,
                                    size = me->locate_eligible_thing.w_count);

	status =
	om$get_classid(	classname	= "ACncpx" ,
			p_classid	= &me->eligible_classids[0] );

	status =
	om$get_classid(	classname	= "GRclhdr" ,
			p_classid	= &me->eligible_classids[1] );

	status =
	om$get_classid(	classname	= "GRsmhdr" ,
			p_classid	= &me->eligible_classids[2] );

   }

   me->locate_rtree_thing.p_classes = me->rtree_classids;
   me->locate_eligible_thing.p_classes = me->eligible_classids;
   me->locate_rtree = &me->locate_rtree_thing;
   me->locate_eligible = &me->locate_eligible_thing;

/*
   status = om$send ( msg = message COgrpevent.build_locate_criteria ( sts ),
		      mode = OM_e_wrt_message,
		      targetid = my_id );
*/

}
#endif


end implementation Root;
