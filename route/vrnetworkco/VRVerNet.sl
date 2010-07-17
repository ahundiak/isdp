/* $Id: VRVerNet.sl,v 1.1.1.1 2001/01/04 21:12:58 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrnetworkco/VRVerNet.sl
 *
 * Description:
 *	Verify Product Network
 *
 	    This command is used to verify route objects.  The user is 
            prompted to select the tip of a network to validate.  The 
            entire network is selected and hightlighted for the user to 
            approve.  The command is broken into three subcommands 
	    corresponding to the three products (piping, HVAC, RWAY).  The
            user is restricted to selecting networks of this type. An error 
	    report is produced and the user is given the option to produce
            a verbose report summarizing all of the verifications done on 
            all of the objects. 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRVerNet.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:58  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.6  1996/04/04  21:21:28  pinnacle
# Replaced: vrnetworkco/VRVerNet.sl for:  by hverstee for route240
#
# Revision 1.5  1996/01/17  00:10:04  pinnacle
# Replaced: vrnetworkco/VRVerNet.sl for:  by r240_int for route240
#
# Revision 1.4  1995/12/08  21:22:26  pinnacle
# Replaced: vrnetworkco/VRVerNet.sl for:  by r240_int for route240
#
 *
 * History:
 *	11/94	   Lori		creation
 *	12/06/95	tlb		Remove VRcmd.h
 *	01/15/96	tlb	Add VX_FIproto.h, prototypes
 *
 *************************************************************************/

command_string          VRC_M_PpVerify,0,VRPpVfy
synonym                 VRC_M_HvVerify,1,VRHvVfy
synonym                 VRC_M_RwVerify,2,VRRwVfy 
class                   VRVerNet
super_class             VRVerify
product_name            "$ROUTE"
command_table           "route.cmd"

specification
instance
{
}


implementation

#include <stdio.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "EXgrid.h"
#include "AS_status.h"
#include "VRverify.h"
#include "VRverifymac.h"
#include "ACrg_collect.h"
#include "vrmacros.h"
#include "vrdef.h"
#include "grdpbmacros.h" 
#include "VDmem.h"
#include "VRmsg.h"
#include "coparamac.h"
#include "GM.h"
#include "GMmacros.h"
#include "GMhcode.h"
#include "GMndg.h"
#include "GMlist.h"
#include "VRsize.h"
#include "GMdef.h"
#include "GMerrordef.h"
#include "vrtools_pto.h"
#include "vrtrace_pto.h"

%safe
#include "VX_FIproto.h"
%endsafe


from NDnode import NDdisplay;

extern GRclassid OPP_VRPiping_class_id;
extern GRclassid OPP_VRHvac_class_id;
extern GRclassid OPP_VRRway_class_id;
extern GMsel_and();
extern GMh_key();

state_table
#include  "VRmsg.h"
#include  "VRverify.h"

#define TRUE 1
#define FALSE 0


state start

      on ELSE
               state GET_OBJ

state GET_OBJ
      prompt_key           VR_P_VerSelTip
      accept_key           VR_P_AccReject
      locate_owner         "LC_RIGID_COMP | LC_FLEX_COMP | LC_REF_OBJECTS"
      filter               locate

      on EX_DATA or EX_OBJID
	   do prompt "                "
	   do VRGetNetObj( &me->ret )
                  on ERROR
                          state .
	      state ACC_NET

      on EX_RJT_MOVEON
	do prompt "                "
	do VRGetAll ( &me->ret )
                  on ERROR
                      state GET_OBJ
		state ACC_NET
        
      on ELSE
              state terminate

state ACC_NET
	prompt_key         VR_P_VerAccNet
        filter             get_event


        on EX_BACK_UP state -

	on EX_DATA 
		do dehighlight
		state GET_FILE_NAME_ERR

	on EX_RJT_MOVEON
		do dehighlight
		state GET_OBJ

	on ELSE
	      state terminate


state GET_FILE_NAME_ERR
	prompt_key        VR_P_GetERepFile
 	filter            get_event
	
	on EX_BACK_UP	state start
	
	on EX_STRING      do set_error
			  do store_file_name( &me->ret )
			  on RETURN_CODE = VR_K_FileIsDirectory
	                       do status_key VR_E_CantCreateEFile	                                                  state .
	                  on RETURN_CODE = VR_K_FileExist
			                    state OVER_FILE_ERR
	                  state ASK_VERBOSE
	                  
state OVER_FILE_ERR
	prompt_key        VR_P_Overwrite
	filter            get_event
	
        on EX_BACK_UP    state -

	on EX_STRING do check_response_y( &me->ret )
	                 on RETURN_CODE = FALSE state -
	                 state ASK_VERBOSE

state ASK_VERBOSE
	prompt_key       VR_P_AskVerbose 
	filter           get_event

	on EX_STRING do check_response_n( &me->ret )
		on RETURN_CODE = TRUE
			do set_verbose
			state GET_FILE_NAME_VER
		on RETURN_CODE = FALSE
			state VERIFY
		state .

state GET_FILE_NAME_VER
	prompt_key        VR_P_GetVRepFile
	filter            get_event
	
	on EX_BACK_UP	state GET_FILE_NAME_ERR
	
	on EX_STRING do store_file_name( &me->ret )
			  on RETURN_CODE = VR_K_FileIsDirectory
	                       do status_key VR_E_CantCreateVFile	                                                  state .
	                  on RETURN_CODE = VR_K_FileExist
			                    state OVER_FILE_VER
	                  state VERIFY


state OVER_FILE_VER
	prompt_key        VR_P_Overwrite
	filter            get_event
	
  
        on EX_BACKUP     state -
	on EX_STRING do check_response_y( &me->ret )
	                 on RETURN_CODE = FALSE state -
	                 state VERIFY

state VERIFY
        status_key       VR_M_Processing
        on ELSE
	        do open_files( &me->ret )
	        on RETURN_CODE =  VR_K_CantCreateErrFile
			do status_key VR_E_CantCreateEFile
                           state GET_FILE_NAME_ERR
		on RETURN_CODE = VR_K_CantCreateVerbFile
			do status_key VR_E_CantCreateVFile
                           state ASK_VERBOSE
		do title_reports
                do VRVerifyNet
                do free_memory
		do end_reports
		do close_files
                	state terminate

action init
{
  /*A Call parent init message */
  status =
  om$send( msg    = message VRVerify.init ( type, str_ptr ),
           mode   = OM_e_wrt_message,
         targetid = my_id);
  as$status( action = RET_STATUS );
  
  /*A initialize instance data */
  me->bNetCommand = TRUE;

  /*A set up arrays to get corrections and control segments from cmp */
  me->NewObj[CORR_OBJ_NUM].ObjCount = 0;
  me->NewObj[CORR_OBJ_NUM].ArraySize = 10;
  me->NewObj[CORR_OBJ_NUM].object = _MALLOC (10, struct GRid);

  me->NewObj[CS_OBJ_NUM].ObjCount = 0;
  me->NewObj[CS_OBJ_NUM].ArraySize = 10;
  me->NewObj[CS_OBJ_NUM].object = _MALLOC (10, struct GRid);

  me->NewObj[PLANE_OBJ_NUM].ObjCount = 0;
  me->NewObj[PLANE_OBJ_NUM].ArraySize = 10;
  me->NewObj[PLANE_OBJ_NUM].object = _MALLOC (10, struct GRid);
    
  /*A Set up eligible classes for locate */
  me->locate_eligible_thing.w_count = 1;
  me->locate_eligible_thing.w_flags = OM_CLST_subclass;
  om$vla_set_dimension( varray = me->eligible_classids,
                        size   = me->locate_eligible_thing.w_count );
  
  switch( type )
  {
    case 0:
	me->Product = VR_PIPING;
	me->eligible_classids[0] = OPP_VRPiping_class_id;
	break;

    case 1:
	me->Product = VR_HVAC;
	me->eligible_classids[0] = OPP_VRHvac_class_id;
	break;

    case 2:
	me->Product = VR_RWAY;
	me->eligible_classids[0] = OPP_VRRway_class_id;
	break;

    default:
        status = OM_I_STOP_SENDING;
        break;
  }

  me->locate_eligible_thing.p_classes = me->eligible_classids;
  me->locate_eligible = &me->locate_eligible_thing;

  return status;

} /* end init */

action VRGetAll
{
  IGRlong retmsg;
  IGRint i;
  IGRlong NumberOfBytes, BytesReceived;
  enum  GRdpmode          mode;
  struct GRid             *TempObj;

  me->NumOfObjects = 0;

  /*A get rid of any previously selected objects */
  if ( me->LocatedObjects )
    {
      status = om$send( msg = message VRVerify.dehighlight(&retmsg),
		       targetid = my_id);
      status = om$send( msg = message VRVerify.free_memory(&retmsg),
		       targetid = my_id);

      if ( !(retmsg&1) || !(status & 1))
	{
	  *sts = MSFAIL;
	  goto quit;
	}
    }

  /*A select all the objects to be verified in the file */
  vr$select_component( pMsg           = &retmsg,
                      Product         = me->Product,
                      pAddrList       = &TempObj,
                      pNumber         = &me->NumOfObjects);

  
  if( (me->NumOfObjects <= 0) || !(retmsg & 1) ) 
    {
      *sts = MSFAIL;
      goto quit;
    }
	

  me->LocatedObjects = _MALLOC (me->NumOfObjects, struct GRid);
  
  if( !me->LocatedObjects )
    {
      *sts = MSFAIL;
      VRFreeStaticSelect();
      printf("Could not allocate memory\n");
      return OM_E_NODYNMEM;
    }

  for(i = 0; i <me->NumOfObjects; i++)
    me->LocatedObjects[i] = TempObj[i];

  NumberOfBytes = sizeof( struct GRmd_env );

  status = gr$get_model_env(
			    msg    = &retmsg,
			    sizbuf = &NumberOfBytes,
			    buffer = &me->md_env,
			    nret   = &BytesReceived );

  as$status( action = RET_STATUS );
  as$status( sts = retmsg, action = RET_STATUS );

  /*A hightlight selected objects */
  mode = GRhd;
  for ( i = 0; i < me->NumOfObjects; i++)
    {
      status = om$send(msg = message NDnode.NDdisplay(0,mode, &me->md_env),
                       targetid = me->LocatedObjects[i].objid,
                       targetos = me->LocatedObjects[i].osnum);
      
      
    }
  me->bHighlight = TRUE;

} /* end VRGetAll */

action VRGetNetObj
{
  struct GRid          TipObject;
  struct GMndgraph     graph;
  struct VRgrinfo      info_list;
  unsigned short       *p_key;
  IGRint               nb_elmt, index1;
  enum  GRdpmode       mode;
  unsigned short       type;
  IGRlong              retmsg;

  
  me->NumOfObjects = 0;

  /*A get rid of any previously selected objects */
  if ( me->LocatedObjects )
    {
      status = om$send( msg = message VRVerify.dehighlight(&retmsg),
		       targetid = my_id);
      status = om$send( msg = message VRVerify.free_memory(&retmsg),
		       targetid = my_id);

      if ( !(retmsg&1) || !(status & 1))
	{
	  *sts = MSFAIL;
	  goto quit;
	}
    }

  /*C the tip object is the located object */
  TipObject = me->event1.located_object[0].located_obj;  
  
  /*A activate graph */
  status = GMndg_activate(DEF_MODULO,DEF_SIZE,&graph);
  gm$status();

  info_list.p_md_env = &me->event1.located_object[0].module_info;
  info_list.p_add = (IGRchar *) &graph;

  status = GMndg_getgraph(&TipObject,1,VRget_allow_connect,
			  (IGRchar *)&info_list,&graph);
  gm$status();
  status = GMh_getlist(&graph.hcode,NULL,NULL,&p_key,&nb_elmt);

  /*A return error if no objects were found */
  if ( nb_elmt == 0)
    {
      *sts = MSFAIL;
      goto quit;
    }

  /*A  Assign module environment */
  me->md_env = me->event1.located_object[0].module_info;

  me->NumOfObjects = nb_elmt;

  /*A  Allocate memory for located objects */
  me->LocatedObjects = _MALLOC (nb_elmt, struct GRid);
  
  if( !me->LocatedObjects )
    {
      *sts = MSFAIL;
      printf("Could not allocate memory\n");
      return OM_E_NODYNMEM;
    }

  /*A hightlight selected objects */
  mode = GRhd;
  type = GM_BODY|GM_EXTERN;
  info_list.p_add    = (char *)&mode;
  
  /*A store graph objects in local list and highlight */
  for(index1=0; index1<nb_elmt; index1++)
    {
      me->LocatedObjects[index1] = 
	* (struct GRid *)GMh_key(&(graph.hcode),p_key[index1]);

      status = om$send(msg = message NDnode.NDdisplay
		       (0,mode,&me->md_env),
		       targetid = me->LocatedObjects[index1].objid,
		       targetos = me->LocatedObjects[index1].osnum);
    }
  me->bHighlight = TRUE;
  /*A remove the graph */
  GMndg_disactivate(&graph);

 exception:
}


action VRVerifyNet
{
  IGRlong  retmsg;

  /*A make sure memory is allocated to get corrections and control
     segments  and planes */
  if ( (me->NewObj[CORR_OBJ_NUM].ArraySize == 0) || 
       (! me->NewObj[CORR_OBJ_NUM].object)       ||
       ( me->NewObj[CORR_OBJ_NUM].ObjCount != 0)    )
    {
       me->NewObj[CORR_OBJ_NUM].ObjCount = 0;
       me->NewObj[CORR_OBJ_NUM].ArraySize = 10;
       me->NewObj[CORR_OBJ_NUM].object = _MALLOC (10, struct GRid);
     }
  if ( (me->NewObj[CS_OBJ_NUM].ArraySize == 0) ||
       (! me->NewObj[CS_OBJ_NUM].object)       ||
       (me->NewObj[CS_OBJ_NUM].ObjCount != 0))
    {
       me->NewObj[CS_OBJ_NUM].ObjCount = 0;
       me->NewObj[CS_OBJ_NUM].ArraySize = 10;
       me->NewObj[CS_OBJ_NUM].object = _MALLOC (10, struct GRid);
     }
  if ( (me->NewObj[PLANE_OBJ_NUM].ArraySize == 0) || 
       (! me->NewObj[PLANE_OBJ_NUM].object)       ||
       ( me->NewObj[PLANE_OBJ_NUM].ObjCount != 0)    )
    {
       me->NewObj[PLANE_OBJ_NUM].ObjCount = 0;
       me->NewObj[PLANE_OBJ_NUM].ArraySize = 10;
       me->NewObj[PLANE_OBJ_NUM].object = _MALLOC (10, struct GRid);
     }

  me->ObjToProcess = me->LocatedObjects;
  me->NumToProcess = me->NumOfObjects;

  /*A Verify the components */
  status = om$send(msg = message VRVerify.VRVerifyObjects(&retmsg),
		   targetid = my_id);

  as$status(action = RET_STATUS);

  if (!me->bUserExit)
  {
    /*A Verify the corrections */
    me->ObjToProcess = me->NewObj[CORR_OBJ_NUM].object;
    me->NumToProcess = me->NewObj[CORR_OBJ_NUM].ObjCount;

    status = om$send(msg = message VRVerify.VRVerifyObjects(&retmsg),
  		   targetid = my_id);

    as$status(action = RET_STATUS);
  }

  if (!me->bUserExit)
  {
    /*A Verify the control segments */
    me->ObjToProcess = me->NewObj[CS_OBJ_NUM].object;
    me->NumToProcess = me->NewObj[CS_OBJ_NUM].ObjCount;

    status = om$send(msg = message VRVerify.VRVerifyObjects(&retmsg),
		   targetid = my_id);
  
    as$status(action = RET_STATUS);
  }

  if (!me->bUserExit)
  { 
   /*A Verify the planes */
    me->ObjToProcess = me->NewObj[PLANE_OBJ_NUM].object;
    me->NumToProcess = me->NewObj[PLANE_OBJ_NUM].ObjCount;

    status = om$send(msg = message VRVerify.VRVerifyObjects(&retmsg),
		   targetid = my_id);
  
    as$status(action = RET_STATUS);  
  }

} /* end VRVerifyNet */

