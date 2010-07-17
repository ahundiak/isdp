/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

     CLASS NAME : VLstrRpCmd.sl

     ABSTRACT   : Create an ASCII file report of Streching values.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


command_string	VLC_M_STR_VAL_RP, 0, VLStVaRp
command_table	"vl.cmd"
class		VLstrRpCmd
super_class	VLlocateCmd
product_name	"$LOFT"

start_state	ASCII

specification

#include <stdio.h>
#include "msdef.h"
#include "OMmacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "asmacros.h"
#include "macro.h"
#include "griodef.h"
#include "gr.h"
#include "growner.h"
#include "VDSpathdef.h"
#include "DItypedef.h"
#include "vlstrechval.h"

#define MY_ERROR        530

instance
{
int				nb_strech;
variable struct GRobj_env	strech[1];
}

implementation

#include        <stdio.h>
#include        <string.h>
#include	"vlprototype.h"
#include        "madef.h"
#include        "AS_status.h"
#include        "exmacros.h"
#include        "msmacros.h"
#include	"gr.h"
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
#include        "FI.h"
#include        "ACattrib.h"
#include        "msmacros.h"
#include        "vsmiscmacros.h"
#include	"coparamac.h"
#include	"vlmsg.h"
#include        "VDSpathdef.h"
#include        "VDSudp_mac.h"
#include        "OMmacros.h"
#include        "OMprimitives.h"


#define	MY_ERROR 530

/******************************************************************************/
state_table

#include        "vscmddef.h"
#include	"vlmsg.h"
#include	"msdef.h"
#include	"griodef.h"
#define	MY_ERROR 530

/******************************************************************************/
state ASCII
	message_key		VL_S_EV_STRECH_VAL
        prompt_key              VL_P_FillForm
	status			" "
	execute			VLcreateFileForm (&me->ret)
				on RETURN_CODE = VL_S_SUCCESS	state WAIT_FORM
				on ELSE				state ASCII
/******************************************************************************/
state WAIT_FORM
	status			" "
	filter			get_event

	on GR_UNKNOWN_TYPE.VS_K_FILE_ACCEPTED
				do fileFormDismissed(VS_K_FILE_ACCEPTED)
				state TO_STR
	on GR_UNKNOWN_TYPE.VS_K_FILE_CANCELED
				do fileFormDismissed(VS_K_FILE_CANCELED)
				state terminate
	on EX_STRING					state .
/******************************************************************************/
state TO_STR
	status			" "
	execute			VLfreeList ( &me->ret, 1)
	                                            
	on ELSE						state FIRST_STRECH
/******************************************************************************/
state FIRST_STRECH
	prompt_key		VL_P_STRECH_VAL_MAC
	accept_key		VL_M_ACC_NT_STRECH_VAL
	locate_eligible		"VLstretchV"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

	on EX_BACK_UP						state ASCII
        on EX_DATA or EX_OBJID	do VLcontrol_strech (&me->ret)	
                                do VLchaine_locate
								state STRECH
/******************************************************************************/
state STRECH
	prompt_key		VL_P_STRECH_VALUES_MO
	accept_key		VL_M_ACC_NT_STRECH_VAL
	locate_eligible		"VLstretchV"
	locate_owner            "LC_RIGID_COMP  | LC_RIGID_OWNER |
                                 LC_FLEX_COMP   | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	locate_properties       "LC_LC_ONLY | LC_DP_ONLY | LC_RW"
        filter                  locate

        on EX_RJT_MOVEON					state GENERATE
	on EX_BACK_UP						state ASCII
        on EX_DATA or EX_OBJID	do VLcontrol_strech (&me->ret)	
                                do VLchaine_locate
								state .
/******************************************************************************/
state GENERATE
        status_key              VL_S_PROCESS
        prompt			" "
	execute			VLgenerateList (&me->ret)

        on ELSE                                                 state ASCII

/******************************************************************************/

at init do my_cob_init

action VLcontrol_strech(long *sts) 
{
struct GRobj_env        *LocatedObjects;
int                     nb_obj,nb_supprim;
int                     i,j;

  status = 1;  // to avoid warning messages during compilation
  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects,
                 response = me->response,
                 response_data = me->response_data);

  if (nb_obj == 0)
  {
    me->ret = *sts = MY_ERROR;
    ex$message(msgnumb = VL_E_NoObjLoc,time=0,seconds=0);
    goto quit;
  }
  nb_supprim = 0;
  for (i=0; i<nb_obj;i++)
  {
    for (j=0; j<me->nb_strech;j++)
    {
      if (me->strech[j].obj_id.objid == LocatedObjects[i].obj_id.objid)
      {
        LocatedObjects[i].obj_id.objid = NULL_OBJID;
        nb_supprim++;
        break;
      }
    }
  }

  if (nb_supprim)
    ex$message(msgnumb = VL_E_ObjInList,time=0,seconds=0);

  if(nb_obj - nb_supprim + me->nb_strech >
                                om$dimension_of( varray = me->strech)) {
    om$vla_set_dimension(varray = me->strech,size =
                                      nb_obj-nb_supprim+me->nb_strech);
  }

  for (i=0; i<nb_obj; i++)
  {
    if (LocatedObjects[i].obj_id.objid == NULL_OBJID) continue;
    me->strech[i+me->nb_strech] = LocatedObjects[i];
  }
  me->nb_strech += nb_obj - nb_supprim;
  goto quit; // to avoid warning messages during compilation
}
/******************************************************************************/
action VLgenerateList {
long	loc_msg;

        /* Kick-of Apfel-Strudel process */
        status = VLexecStrechValList ( me->nb_strech, me->strech, 
					  &(me->ModuleInfo),
                                          me->Wfile, "RPsetup", &loc_msg);
        as$status ( msg    = "VLexecStrechValList()",
                    test   = (!(status & 0x00000001 & loc_msg)),
                    action = GOTO_VALUE,
                    value  = quit );

        me->nb_strech = 0;
        goto quit; // to avoid warning messages during compilation
}
/******************************************************************************/
action VLchaine_locate
{
IGRlong msg;
IGRlong size = sizeof(struct GRevent) - sizeof(long)*2;

    status = ex$putque(msg = &msg,byte=&size,response=(IGRint *)&me->ret,
                       buffer = (IGRchar *) &me->event1.event);
    if (!(status&msg&1)) {
      printf("Pbs In Queue\n");
      me->ret = MY_ERROR;
      goto quit;
    }
}

action my_cob_init
{

   status = 1;       // to avoid warning messages during compilation
   me->nb_strech = 0;
   goto quit;            // to avoid warning messages during compilation
}
