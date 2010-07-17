/* $Id: VRcopy.sl,v 1.1.1.1 2001/01/04 21:12:48 cvs Exp $  */

/***********************************************************************
* I/ROUTE
 *
 * File:	vrcopy/VRcopy.sl
 *
 * Description:
 *
 *	This is the COB for "Copying a Network" ( either in a design
 *	file or across the design files )
 *
 * Revision History:
 *	$Log: VRcopy.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1996/08/19  06:38:08  pinnacle
# Replaced: vrcopy/VRcopy.sl for:  by apazhani for route
#
# Revision 1.4  1996/03/01  23:47:06  pinnacle
# Replaced: vrcopy/VRcopy.sl for:  by hverstee for route240
#
# Revision 1.3  1996/01/16  22:39:12  pinnacle
# Replaced: vrcopy/VRcopy.sl for:  by r240_int for route240
#
 *
 * History:
 *
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 *	11/06/91	momo		Creation
 *
 *	09/06/94	Manyam		Modified the action "VRGetGraph()"
 *					so as to attach the "PidMacroLib"
 *					if required( Fix for the error mess-
 *					ages that get displayed when a schem-
 *					atic network is copied from a ref
 *					file to a master file )
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/16/96	tlb		Add prototypes
 ***********************************************************************/

command_string       VRC_M_CopyNetwork,0,VRCpNt
class                VRcopy
super_class          VDB_LOCATE
product_name         "$ROUTE"
command_table	     "route.cmd"
	
specification

#include "GMdef.h"
#include "GM.h"
#include "graph.h"
#include "ACrg_collect.h"
#include "VRsize.h"

instance
{
  IGRdouble			first_pt[3];/* first point                                  */
  IGRdouble			next_pt[3]; /* next point                                   */
  struct 	GRmd_env 	loc_env;    /* Locate environment                           */
  struct 	GMgraph		graph;      /* graph containing the elements of the net     */
  struct 	VRgrinfo 	grinfo;     /* Information for graph manager's functions    */
  struct 	GMlist   	l_plane;    /* List of planes                               */
}


implementation

#include "nddef.h"
#include "VRcompdef.h"
#include "bstypes.h"
#include "GMerrordef.h"
#include "GMmacros.h"
#include "ndmacros.h"
#include "AS_status.h"
#include "acrepdef.h"
#include "VRPid.h"

#include "vrflow_pto.h"
#include "vrinit_pto.h"
#include "vrtools_pto.h"
#include "vrcopy_pto.h"
#include "maidmx.h"

#define	AS_DEBUG	  1
#define VR_DISC_NOZZLE 	0x2
#define VR_DISC_REF	0x3

extern  GMgridcmp();          /* Function to compare GRid                     */
extern	NDget_list();	      /* Function to get the elements of the graph    */


from	NDnode		import	NDcopy, NDget_objects;
from	VRGeneric	import	VRGetStatus;
from	ACncpx		import	ACget_NV_rep;

/**********************************************************/

state_table

#include "VRmsg.h"

#define VR_DISC_NOZZLE 	0x2
#define VR_DISC_REF	0x3

state start

   on ELSE		do VRInitGraph( &me->ret )		state GET_OBJ


state GET_OBJ

   message_key          VR_M_CopyNetwork
   prompt_key		VR_P_IdComp
   dynamics		off
   locate_class		"+VRGeneric"
   locate_owner		"LC_REF_OBJECTS"
   accept_key		VR_P_AccReject
   relocate_key		VR_S_CompNotFound
   filter		locate
 
   on EX_BACK_UP or EX_RJT_MOVEON				state .

   on EX_DATA			do VRGetGraph( &me->ret )	
      on RETURN_CODE = VR_DISC_NOZZLE
				do status "Please disconnect the network from the equipement"
				do VRFreeGraph( &me->ret )	state start
      on RETURN_CODE = VR_DISC_REF
				do status "Please disconnect the network from the reference file"
				do VRFreeGraph( &me->ret )	state start
      on ERROR			do VRFreeGraph( &me->ret )	state start
								state ACC_REJ
state ACC_REJ

   prompt_key		VR_P_AccGph
   dynamics		off
   filter		get_event


   on EX_DATA			do VRGetFrstPt( &me->ret )	state GET_PT

   on EX_RJT_MOVEON or EX_BACK_UP					
                                do VRRejectGraph( &me->ret )		
				do VRFreeGraph( &me->ret )	
								state start

state GET_PT

   prompt_key		VR_P_EnterDistPt
   dynamics		off
   filter		get_event


   on EX_DATA			do VRGetPlanes( &me->ret )
      on ERROR			do VRFreeGraph( &me->ret )	state start
				do VRCopyGraph( &me->ret )
				do VRFreeGraph( &me->ret )	state start

   on EX_RJT_MOVEON						state Get_FstPT

   on EX_BACK_UP                do VRRejectGraph( &me->ret )
				do VRFreeGraph( &me->ret )	state start


state Get_FstPT

   prompt_key		VR_P_EnterFromPt
   dynamics		off
   filter		get_event


   on EX_DATA		do VRGetFrstPt( &me->ret )		state GET_PT

   on EX_RJT_MOVEON or EX_BACK_UP					
                                do VRRejectGraph( &me->ret )			
                                do VRFreeGraph( &me->ret )	state start


  at delete do VRFreeGraph( &me->ret )


/********************************************************************************************/

action VRGetFrstPt

{
  me->ret = MSSUCC;

  me->first_pt[0] = me->event1.event.button.x;
  me->first_pt[1] = me->event1.event.button.y;
  me->first_pt[2] = me->event1.event.button.z;
}


/********************************************************************************************/

action VRInitGraph

{
  /* ---------------------------- */
  /* Select the origin of the net */
  /* ---------------------------- */

  status = gm$init_graph(p_graph = &me->graph);
  gm$status();

exception :

}

/********************************************************************************************/

action VRGetGraph

{
  IGRint         		exception_type; /* Type of exception to do                   */
  enum 		GRdpmode	mode;           /* Mode to highligth the net                 */
  struct 	GRid 		tip_object;     /* Start object of the selected net          */

  me->ret        = MSSUCC;
  exception_type = NULL;

  tip_object  = me->event1.located_object[0].located_obj;
  me->loc_env = me->event1.located_object[0].module_info;
  /*"loc_env = %d %d\n", me->loc_env.md_id.objid, me->loc_env.md_id.osnum */

  /*| get corresponding graph */

  me->grinfo.p_add    = (char *)&me->graph;
  me->grinfo.p_md_env = &me->loc_env;
     
  status = gm$get_graph( l_tip        = &tip_object,
                         nb_tip       = 1,
                         ancestor_fct = VRget_diconnect,
                         p_anc_arg    = &me->grinfo,
                         p_graph      = &me->graph );
  gm$status(type = EXCEPTION_1);

  /* detect if the graph is connected to an equipement via nozzle or connected
  /* to a component in ref. file
  /**/

  {
	IGRshort	cmp_type;
	IGRint		i, nb_elm;
	IGRlong		retcode=MSSUCC;
	GRclassid	obj_classid;
	struct	GRid	*p_list=NULL;
	IGRuchar	cRep;
	IGRboolean	bIsPid=FALSE;
	 
	extern	GRclassid OPP_VRNozzle_class_id;
	extern	GRclassid OPP_VRCptIn_class_id;

	/*| get the list of the elements in the graph */
	status = GMget_list( &me->graph, NULL, NULL, &p_list, &nb_elm );
	gm$status();

	for(i=0; i<nb_elm; i++)
	{
		/*A processing for copy across ref files	*/
		if ( !bIsPid && p_list[i].osnum != me->ModuleInfo.md_id.osnum )
		{
			/*A get the representation of the element	*/
			status =
			om$send( msg      = message ACncpx.ACget_NV_rep(
						&cRep ),
              			targetid = p_list[i].objid,	
				targetos = p_list[i].osnum);
			gm$status();

			/*A test whether it is PID or not and attach
			the corresponding macro library accordingly	*/
			if ( bVR_IS_PID( cRep ) )
			{
				VRInitPid();
				bIsPid = TRUE;
			}

		}

		/*"p_list[%d] = %d\n", i, p_list[i].objid */

    		om$get_classid( objid     = p_list[i].objid,
		    		osnum     = p_list[i].osnum,
                    		p_classid = &obj_classid );

    		if(om$is_ancestry_valid( subclassid   = obj_classid,
                             		 superclassid = OPP_VRCptIn_class_id) == OM_S_SUCCESS)
		{
			*sts = VR_DISC_REF;
			return OM_S_SUCCESS;
		}
				
    		if(om$is_ancestry_valid( subclassid   = obj_classid,
                             		 superclassid = OPP_VRNozzle_class_id) == OM_S_SUCCESS)
		{
  			status = om$send( msg     = message VRGeneric.VRGetStatus
     						          	( &retcode, &cmp_type ),
              			  	  senderid = NULL_OBJID,
              			  	  targetid = p_list[i].objid,
              			  	  targetos = p_list[i].osnum);
  			gm$status();

			if( ! ( cmp_type & VR_OUT_MACRO ) )  
			{
				*sts = VR_DISC_NOZZLE;
				return OM_S_SUCCESS;
			}
		}
	}
  }
	
  /* Highlight this graph */

  UI_status("Display Network in progress");

  mode = GRhd;
  me->grinfo.p_add    = (char *)&mode;
  status = gm$broadcast_graph( broad_fct    = VRdisplay_elmt,
                               p_broad_info = &me->grinfo,
                               broad_mode   = GM_ORDER,
                               p_graph      = &me->graph);
  gm$status(type = EXCEPTION_1);
  UI_status("");

exception:
  switch( exception_type )
  {
    case EXCEPTION_1: *sts = MSFAIL;
  }

}      

/*******************************************************************************************/

action VRRejectGraph

{
  IGRint         		exception_type; /* Type of exception to do                   */
  enum 		GRdpmode	mode;           /* Mode to highligth the net                 */

  exception_type = 0;

  mode = GRheo;
  me->grinfo.p_add    = (char *)&mode;
  status = gm$broadcast_graph( broad_fct    = VRdisplay_elmt,
                               p_broad_info = &me->grinfo,
                               broad_mode   = GM_ORDER,
                               p_graph      = &me->graph);
  gm$status(type = EXCEPTION_1);

exception:
  switch( exception_type )
  {
    case EXCEPTION_1: me->ret = MSFAIL;
  }
}


/********************************************************************************************/

action VRGetPlanes

{
  IGRint         		size_struct;    /* Size of the structure in the list         */
  IGRint         		exception_type; /* Type of exception to do                   */
  enum 		GRdpmode	mode;           /* Mode to highligth the net                 */

  exception_type = 0;

  me->next_pt[0] = me->event1.event.button.x;
  me->next_pt[1] = me->event1.event.button.y;
  me->next_pt[2] = me->event1.event.button.z;

  /*| dishighlight the graph */
  mode = GRbe;
  me->grinfo.p_add    = (char *)&mode;
  status = gm$broadcast_graph( broad_fct    = VRdisplay_elmt,
                               p_broad_info = &me->grinfo,
                               broad_mode   = GM_ORDER,
                               p_graph      = &me->graph);
  gm$status(type = EXCEPTION_1);

  /*| Get the planes from the graph */
  size_struct = sizeof(struct GRid);
  status = GMl_activate
           ( GMH_DEF_SIZE,GMH_DEF_SIZE,size_struct,GMgridcmp,NULL,NULL,&me->l_plane );
  gm$status(type = EXCEPTION_2);

  /*| Add planes */
  me->grinfo.p_add = ( IGRchar * ) &me->l_plane;
  status = gm$broadcast_graph( broad_fct    = VRadd_plane,
                               p_broad_info = &me->grinfo,
                               broad_mode   = GM_ORDER,
                               p_graph      = &me->graph);

  /*^
      for( GMl_first(&me->l_plane); !GMl_at_end(&me->l_plane); GMl_next(&me->l_plane) )
      {
  	struct 	GRid 		*p_object;
        p_object = (struct GRid *)GMl_current(&me->l_plane);
        printf("list of planes = %d\n", p_object->objid );
      }
  */

exception:
  switch( exception_type )
  {
    case EXCEPTION_2:
    case EXCEPTION_1: me->ret = MSFAIL;
  }
}

/********************************************************************************************/

action VRFreeGraph

{
  /* Free the memory */

  if( me->graph.p_hcode ) gm$free_graph(p_graph = &me->graph);
  if( me->l_plane.elmt  ) GMl_disactivate(&me->l_plane);

  /* To reset the VRsolver to NULL_OBJID */
  VRreset_solver();

}

/********************************************************************************************/

action VRCopyGraph

{
  IGRint		i;
  IGRlong		retcode;
  BSrc			bsretcode;
  IGRmatrix		matrix;
  struct	GRid	*p_object, *NewId;
  enum 		GRdpmode	mode;           /* Mode to highligth the net                 */


  /*"nb plane to copy = %d\n", me->l_plane.nb_elmt */

  MAidmx( &bsretcode, matrix );

  matrix[3]  = me->next_pt[0] - me->first_pt[0];
  matrix[7]  = me->next_pt[1] - me->first_pt[1];
  matrix[11] = me->next_pt[2] - me->first_pt[2];

  /*"trans = %f %f %f\n", matrix[3], matrix[7], matrix[11] */

  NewId = (struct GRid *) malloc( me->l_plane.nb_elmt * me->l_plane.elmt_size );

  for( GMl_first(&me->l_plane), i=0; !GMl_at_end(&me->l_plane); GMl_next(&me->l_plane), i++ )
  {
    p_object = (struct GRid *)GMl_current(&me->l_plane);

    /*"obj to copy = %d %d\n", p_object->objid, p_object->osnum */
    status = om$send( msg      = message NDnode.NDcopy
                                 ( &retcode, 0, &me->loc_env, &me->ModuleInfo, &NewId[i] ),
                      targetid = p_object->objid,
                      targetos = p_object->osnum );

    /*"NewId = %d %d\n", NewId[i].objid, NewId[i].osnum */

    status = VRskxform( &retcode, matrix, &NewId[i], &me->ModuleInfo );
    as$status( action = GOTO_VALUE, value = exception );
    as$status( sts = retcode, action = GOTO_VALUE, value = exception );
  }

  status =
  nd$get_graph( p_root     = (struct GRid *) me->l_plane.elmt,
		nb_root    = me->l_plane.nb_elmt );
  as$status( action = GOTO_VALUE, value = exception );

  status =
  nd$copy_graph( msg        = &retcode,
		 type_graph = ND_COPY_TIP | ND_COPY_EXT,
		 p_root     = NewId,
		 nb_root    = me->l_plane.nb_elmt,
  	         from_info  = &me->loc_env,
		 to_info    = &me->ModuleInfo );
  as$status();

exception:

  nd$exec_batch();

  mode = GRbd;
  me->grinfo.p_add    = (char *)&mode;
  status = gm$broadcast_graph( broad_fct    = VRdisplay_elmt,
                               p_broad_info = &me->grinfo,
                               broad_mode   = GM_ORDER,
                               p_graph      = &me->graph);

  if( NewId ) free( NewId );
}
