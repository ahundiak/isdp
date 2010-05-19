/* $Id: VDsolLoc.I,v 1.1.1.1 2001/01/04 21:09:01 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdpocket/func/VDsolLoc.I
 *
 * Description:
 *		Functions to determine the relationship between
 *		an objects and a constraint solid.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsolLoc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:01  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/10/16  09:23:32  pinnacle
# Replaced: vdpocket/func/VDsolLoc.I for:  by msbraju for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.15  1995/09/18  19:03:56  pinnacle
# Replaced: ./vdpocket/func/VDsolLoc.I for:  by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			raju		creation date
 *	09/17/95	raju		add stop checking.
 *
 ***************************************************************************/

class implementation Root;
/*
Name
   VDlocateWithSolid

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
#include "dpmacros.h"
#include "EMSmsgdef.h"
#include "comiscmac.h"

#include "vderrmacros.h"
#include "vdsollocdef.h"
#include "vdparmacros.h"

#include "VDmem.h"

#define  VD_RP_INSIDE  1
#define  VD_LIST_INCR	     50


from  GRgrset	import	GSstart_transition;
from  GRgrset	import	GSend_transition;
from  IGEgragad	import	DPinquire;
from  GRgraphics import	GRgetrang;
from  GRgrset	import  GSget_object;
from  GRgrset   import  GSremove_member;
from  EMSsurface import EMputLsIfNotThere;
from  GRgrset   import  GSdissolve;

extern	IGRboolean	IGEstop();


/*
 This static function gets objid of one of the active gadgets.
*/
long  VDget_gadget_id1(
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
 This function builds a right prism from solid. The right prism
 for should be in local coordinates of the window in which objects
 are located. Range of solid is obtained in local coordinates of window.
 For doing this, the transformation matrix from world_to_local is sent
 to GRgetrang method.
*/
long  VDbuild_right_prism1(
 long		 *msg,
 struct GRid	 *solid,
 struct GRmd_env *solid_env,
 double		 *wld_to_lcl_mx,
 struct GRid	 *loc_window_id,
 IGRint		 *prism_type,
 struct IGRrt_prism  *right_prism
)
{
IGRboolean	world = TRUE;
double		sol_win_range[6];   /* range in solid in window coordinates */
long		sts;
struct var_list	var_list[2];
IGRdouble	*prism_poles;
IGRdouble	depths[6] = {0,0,0,0,0,0};
IGRdouble	display_depths[2];
IGRlong		which_error;
IGRlong		ret_bytes;

int		ii, jj;
double  	trans_mx[16];
short   	mx_type;


   *msg = MSSUCC;
   /*
    *  form a transformation matrix which gets the range of the solid
    *  in the window coordinates.
    */
   if ( solid_env->md_env.matrix_type == MAIDMX )
   {
      for(ii=0; ii<16; ii++)
	trans_mx[ii] = wld_to_lcl_mx[ii];
   }
   else
   {
       double	*temp_mx;
       /*
	* multiply  solid env matrix and wld_to_lcl_mx
	*/

       temp_mx = solid_env->md_env.matrix;

       for ( ii=0; ii<4; ii++)
	  for ( jj=0; jj<4; jj++)
	     trans_mx[ii*4+jj] = wld_to_lcl_mx[ii*4]    *   temp_mx[jj]   +
				 wld_to_lcl_mx[ii*4+1]  *   temp_mx[jj+4] +
				 wld_to_lcl_mx[ii*4+2]  *   temp_mx[jj+8] +
				 wld_to_lcl_mx[ii*4+3]  *   temp_mx[jj+12] ;
/*
       for ( ii=0; ii<4; ii++)
         for ( jj=0; jj<4; jj++)
             trans_mx[ii*4+jj] = temp_mx[ii*4]    *   wld_to_lcl_mx[jj]   +
				 temp_mx[ii*4+1]  *   wld_to_lcl_mx[jj+4] +
				 temp_mx[ii*4+2]  *   wld_to_lcl_mx[jj+8] +
				 temp_mx[ii*4+3]  *   wld_to_lcl_mx[jj+12] ;
*/
   }

   sts = MAtypemx ( msg, trans_mx, &mx_type);
   sts = om$send ( msg = message GRgraphics.GRgetrang (
					msg,
					&mx_type,
					trans_mx,
					&world,
					sol_win_range ),
		   senderid = NULL_OBJID,
		   targetid = solid->objid,
		   targetos = solid->osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRgetrange", sts, *msg, VD_VERBOSE, wrapup );

#if 0
double   	wld_range[6],       /* range of solid in world coordinates */

   sts = om$send ( msg = message GRgraphics.GRgetrang (
					msg,
					&(solid_env->md_env.matrix_type),
					solid_env->md_env.matrix,
					&world,
					wld_range ),
		   senderid = NULL_OBJID,
		   targetid = solid->objid,
		   targetos = solid->osnum );
   VDS_ERR_HNDLR ( "GRgraphics.GRgetrange", sts, *msg, VD_VERBOSE, wrapup );



   printf("solid range in wld cs: [%lf],[%lf],[%lf],[%lf]\n", wld_range[0],
				wld_range[1], wld_range[2],wld_range[3] );
   printf("              [%lf],[%lf]\n", wld_range[4], wld_range[5]);


   /*
    * get range in window coordinate system. x,y points are sufficient.
    */
   sol_win_range[0] =	wld_to_lcl_mx[0] * wld_range[0] +
			wld_to_lcl_mx[1] * wld_range[1] +
			wld_to_lcl_mx[2] * wld_range[2] +
			wld_to_lcl_mx[3] ;
   sol_win_range[1] =	wld_to_lcl_mx[4] * wld_range[0] +
			wld_to_lcl_mx[5] * wld_range[1] +
			wld_to_lcl_mx[6] * wld_range[2] +
			wld_to_lcl_mx[7] ;
   sol_win_range[2] =	0.0;

   sol_win_range[3] =	wld_to_lcl_mx[0] * wld_range[3] +
			wld_to_lcl_mx[1] * wld_range[4] +
			wld_to_lcl_mx[2] * wld_range[5] +
			wld_to_lcl_mx[3] ;
   sol_win_range[4] =	wld_to_lcl_mx[4] * wld_range[3] +
			wld_to_lcl_mx[5] * wld_range[4] +
			wld_to_lcl_mx[6] * wld_range[5] +
			wld_to_lcl_mx[7] ;
   sol_win_range[5] =	0.0;
#endif

#ifdef VDS_DBG
   printf("range in wind cs: [%lf],[%lf],[%lf],[%lf]\n", sol_win_range[0],
			sol_win_range[1], sol_win_range[2], sol_win_range[3] );
   printf("              [%lf],[%lf]\n", sol_win_range[4], sol_win_range[5]);
#endif


   /*
    * enquire display depths
    */
   var_list[0].var = WLD_DISPLAY_DEPTHS;
   var_list[0].var_ptr = (IGRchar *)display_depths;
   var_list[0].num_bytes = sizeof(IGRdouble)*2;
   var_list[0].bytes_returned = &ret_bytes;

   var_list[1].var = END_PARAM;

   sts = om$send(  msg = message IGEgragad.DPinquire
				( msg, &which_error, var_list),
		    senderid = NULL_OBJID,
		    targetid = loc_window_id->objid,
		    targetos = loc_window_id->osnum);
   VDS_ERR_RPT ( "IGEgragad.DPinquire", sts, *msg, VD_VERBOSE );

#ifdef VDS_DBG
   printf("wld_display_depths : [%lf,%lf]\n",	display_depths[0],
						display_depths[1] );
#endif

   depths[2] = sol_win_range[2] - wld_to_lcl_mx[11];
   depths[5] = sol_win_range[5] - wld_to_lcl_mx[11];

/*
 Do not take existing display_depths into consideration - Raju - 16 Oct 1996
   if ( depths[2] < display_depths[0] ) depths[2] = display_depths[0];
   if ( depths[5] > display_depths[1] ) depths[5] = display_depths[1];
*/

#ifdef VDS_DBG
   printf(" sol_win_range[2,5]= [%f, %f]\n",sol_win_range[2],sol_win_range[5]);
   printf(" depths[2,5]       = [%f, %f]\n",depths[2], depths[5] );
#endif

   /*
    * set window depths to depths of solid
    */
   sts = dp$view_vol(	msg		= msg,
			gg_id		= loc_window_id,
			display_depths	= depths,
			update		= FALSE		);
   VDS_ERR_RPT ( "dp$view_vol", sts, *msg, VD_VERBOSE );

   /*
    * generate right prism from solid range
    */

   *prism_type = GR_RIGHT_PRISM;

   right_prism->polygon.num_points = 5;
   prism_poles			   = right_prism->polygon.points;

   right_prism->height	      = depths[5] - depths[2];

   prism_poles[0]  = sol_win_range[0];
   prism_poles[1]  = sol_win_range[1];
   prism_poles[2]  = 0.0;  		/* sol_win_range[2]; */

   prism_poles[3]  = sol_win_range[3];
   prism_poles[4]  = sol_win_range[1];
   prism_poles[5]  = 0.0;  		/* sol_win_range[2]; */

   prism_poles[6]  = sol_win_range[3];
   prism_poles[7]  = sol_win_range[4];
   prism_poles[8]  = 0.0;  		/* sol_win_range[2]; */

   prism_poles[9]  = sol_win_range[0];
   prism_poles[10] = sol_win_range[4];
   prism_poles[11] = 0.0;  		/* sol_win_range[2]; */

   prism_poles[12] = prism_poles[0];
   prism_poles[13] = prism_poles[1];
   prism_poles[14] = prism_poles[2];

wrapup:
   return sts;
}

/*
   Function that drives other functions.
*/
long  VDlocateWithSolid1(
  long			*msg,
  int			num_sol,
  struct GRid		*sol_list,
  struct GRmd_env	*sol_env_list,
  int			num_qry,
  struct GRid		*qry_list,
  char			rln_needed,
  char			output_mode,
  int			*NbObj,
  struct GRobj_env	**obj_list_out,
  char			*sts_str,
  struct GRid		*gs_id,
  int			num_obj_rm,
  struct GRid		*rm_objs
)
{
long			sts;
struct GRmd_env		mod_env, sol_env;

int			sizbuf, NoBytesRet;
struct GRid		sol_id;

int			ii, tenprc;

int			index, cnt, ListSize,
			num_grsets, set_ind, rm_indx;
OM_S_CHANSELECT		to_owners,
			to_components,
			grset_to_sets;
OM_S_OBJECT_LINKAGE	*grsetLinkage = NULL;
struct GRobj_env	*setcomps = NULL;
char			loc_sts_str[80], processObj;


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

 *NbObj = 0;
 ListSize = 0;
 if ( obj_list_out )
 {
   ListSize = VD_LIST_INCR;
   *obj_list_out = (struct GRobj_env *) malloc( sizeof(struct GRobj_env) *
						ListSize );
 }

 for( index =0; index < num_sol; index++)
 {

   if ( IGEstop() ) break;

   if ( sol_env_list )
	sol_env = sol_env_list[index];
   else
	sol_env = mod_env;
   sol_id = sol_list[index];


   sts = om$make_chanselect(channame = "GRconnector.to_owners",
                            p_chanselect = &to_owners);

   sts = om$make_chanselect(channame     = "GRcmpowner.to_components",
			     p_chanselect = &to_components);

   sts = om$make_chanselect(channame     = "GRgrset.to_sets",
			     p_chanselect = &grset_to_sets);

   sts = om$get_channel_count(  osnum        = gs_id->osnum,
				objid        = gs_id->objid,
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

   sts = om$get_channel_objects (  osnum	 = gs_id->osnum,
				   objid	 = gs_id->objid,
				   p_chanselect  = &grset_to_sets,
				   list          = grsetLinkage,
				   size          = num_grsets,
				   count         = (OMuint *)&num_grsets );
   VDS_ERR_HNDLR("om$get_channel_objects",sts,MSSUCC,VD_VERBOSE, wrapup );

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

    setcomps = _MALLOC ( cnt1, struct GRobj_env );
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

	/* check if the object is one of the objects to be removed */
	processObj = TRUE;
	for( rm_indx=0; rm_indx < num_obj_rm; rm_indx++)
	{
	   if( setcomps[ii].obj_id.objid == rm_objs[rm_indx].objid &&
	       setcomps[ii].obj_id.osnum == rm_objs[rm_indx].osnum    )
	   {
		processObj = FALSE;
		break;
	   }
	}

	if ( processObj )
	{

	  __DBGpr_com("Calling VDsolidFilter");
	  __DBGpr_obj("Calling for object", setcomps[ii].obj_id);
	  sts = VDsolidFilter ( msg, &sol_id, &sol_env,
			      rln_needed, 1, &setcomps[ii], &NbObjOut, NULL );
	  VDS_ERR_HNDLR("VDsolidFilter", sts, *msg, VD_VERBOSE, wrapup);
	}

	if ( NbObjOut && num_qry )
	{
	    struct GRid  obj;

	    obj = setcomps[ii].obj_id;
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
			     VD_VERBOSE, wrapup );
	}

	if ( output_mode == VD_LIST_OF_OBJS && NbObjOut == 1 )
	{
	   if ( obj_list_out && ( *NbObj + 1 > ListSize) )
	   {
	     ListSize += VD_LIST_INCR;
	     *obj_list_out = (struct GRobj_env *) realloc( *obj_list_out,
					sizeof(struct GRobj_env) * ListSize );
	   }
	   if ( obj_list_out)  (*obj_list_out)[*NbObj] = setcomps[ii];
	}
	if ( NbObjOut ) (*NbObj)++;

    } /* for(ii=cnt-1; ii>-1; ii--) */
    _FREE ( setcomps );

   } /* for( set_ind=0; set_ind<num_grsets; set_ind++) */
   _FREE ( grsetLinkage );

 } /*  for( index =0; index < num_sol; index++) */

wrapup:
  _FREE ( setcomps ) ;
  _FREE ( grsetLinkage ) ;
  __DBGpr_int ( "No. of objects found", *NbObj );

  return OM_S_SUCCESS;
}

long  VDlocateWithSolid(
  long			*msg,
  int			num_sol,
  struct GRid		*sol_list,
  struct GRmd_env	*sol_env_list,
  int			num_qry,
  struct GRid		*qry_list,
  char			rln_needed,
  char			output_mode,
  struct GRid		*window_id,
  int			*NbObj,
  struct GRobj_env	**obj_list_out,
  char			*sts_str
)

{
long	sts;


  *msg = MSSUCC;
  sts = OM_S_SUCCESS;

/* Supress compilation warnings */
  if (	num_sol || sol_list || sol_env_list || num_qry ||
	qry_list || rln_needed || output_mode || window_id || NbObj ||
	obj_list_out || sts_str )

	;


  return sts;

}

end implementation Root;
