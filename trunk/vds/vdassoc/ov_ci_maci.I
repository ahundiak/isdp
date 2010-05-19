/* $Id: ov_ci_maci.I,v 1.4 2002/06/07 14:36:22 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/ov_ci_maci.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: ov_ci_maci.I,v $
 *      Revision 1.4  2002/06/07 14:36:22  ramarao
 *      Implemented To Do List.
 *
 *      Revision 1.3  2001/12/10 20:33:19  hans
 *      Fix for TR# MP5348
 *
 *      Revision 1.2  2001/05/20 18:25:36  ramarao
 *      Checked in for Ad.
 *
 *      Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1998/03/06  00:42:36  pinnacle
# ov_ci_macro
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/05/98  ah      Creation, added trace to run_ci routine
 * 12/10/01  HF      Fix for TR# MP5348
 ***************************************************************************/

class implementation ov_ci_mac;

/*--------------------------------------------------------------------------*/
/*
/*  ov_ci_maci.I
/*  robert patience
/*  5 sept 1989
/*
/*---------------------------------------------------------------------------
/* */

#define AS_DEBUG	/* debug pre-processor */

#include "ci_macro.h"

#include "memory.h"
#include "igrdef.h"
#include "codef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "macro.h"
#include "DIdef.h"
#include "DIprims.h"
#include "AS_status.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include <stdio.h>
#include "cierrordef.h"
#include "ciexecmacros.h"
#include "grownmacros.h"

#include "VDtypedef.h"
#include "VDbro1.h"

extern IGRint CI_MAC_place ; /* on/off to activate cifile.place/compute  */
extern IGRboolean ASbroadcast_in_progress;


from ci         	import set_value, get_value, is_entry_point;
from ci_mac_def 	import ACgive_cim_desc ;
from ACcpx_defn		import ACgive_feet_desc, ACintpt_foot,ACintpt_foot_dir,
			       ACgive_temp_desc, ACgive_name ;
from ACmacro_defn 	import ACgive_upscan;


run_ci( entry_point,ci_macro_id)
char 			*entry_point;
struct GRid		ci_macro_id;
/*.run_ci*/
{
  IGRboolean 		save_br;
  IGRint             	ret_code,status;
  struct GRid active_owner;
  IGRint actmsg;

  struct GRid 		macID;
  struct GRobj_env	macOE;
  IGRint 		msg;

  save_br=ASbroadcast_in_progress;
  ASbroadcast_in_progress=TRUE;

  gr$get_active_owner ( msg=&actmsg,active_owner=&active_owner);
  if(actmsg == MSSUCC) gr$clear_active_owner(msg= &actmsg);

  if (VDdbgGetTracePPL()) {

    macID.objid = NULL_OBJID;

    om$send(msg = message ci.get_value
	   (&msg,"CI_MACRO_ID",(char *)&macID,sizeof(struct GRid)),
	    senderid = NULL_OBJID,
            targetid = ci_macro_id.objid ,
	    targetos = ci_macro_id.osnum);

    printf("run_ci.%s ",entry_point);
    vdbro$PrintObject(objID = &macID);

  }

  status =ci$run (  file_id = &(ci_macro_id.objid),
	      	    entry   = entry_point,
/*		    delete  = 1,	*/
		    retsize = sizeof(int),
		    retval  = &ret_code,
		    sender_id = NULL_OBJID );


  ci$delete( file_id	= ci_macro_id.objid );

  om$send(msg = message ci.get_value
	   (&msg,"CI_MACRO_ID",(char *)&macID,sizeof(struct GRid)),
	    senderid = NULL_OBJID,
            targetid = ci_macro_id.objid ,
	    targetos = ci_macro_id.osnum);

  macOE.obj_id = macID;
  om$send(msg = message ci.get_value
	            ( &msg,"MOD_ENV",(char *)&macOE.mod_env,
		      sizeof(struct GRmd_env)),
	      senderid = NULL_OBJID,
              targetid = ci_macro_id.objid ,
              targetos = ci_macro_id.osnum );
  if( ret_code == 0 )
  {
      VDaddToDoList( macOE );
  }
  else
  {
      VDremoveFromToDoList( macOE );
  }

  /*" ret_code %d \n", ret_code */
  ASbroadcast_in_progress =save_br;
  if(actmsg == MSSUCC)
		gr$put_active_owner(msg=&actmsg,active_owner=&active_owner);

  return(ret_code);
}

method  ACconstruct_feet ( IGRlong *msg; IGRint cn_type;
                           IGRint count; struct GRid list [];
                           struct GRmd_env *md_env;
                           int *feet_num;
                           struct GRid *feet_list)
{
  char                  *entry;
  struct GRid           ci_macro_id;
  IGRint                status;
  struct GRid           MY_GRID;
  IGRboolean              save_br;
  struct GRid *grobj_ids;


  entry = ((CI_MAC_place) ? "place" : "compute" );
  CI_MAC_place = 0;
  save_br=ASbroadcast_in_progress;

  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
            string = ("element %d not updated because degraded state\n",my_id));
    return(OM_W_ABORT);}

  if(me->STATE  & ncpx_root)
    { /*| Root nci_macro */ *msg = ND_COMP_SUCC;  return( OM_S_SUCCESS ); }

  MY_GRID.objid = my_id; MY_GRID.osnum = OM_Gw_current_OS;


  ASbroadcast_in_progress=TRUE;

  status=om$send(msg = message ov_ci_mac.ci_kl_NDcompute_node
                ( msg,cn_type,count,list,md_env),
                      targetid = my_id  );

  if(!(status&1))
   {
   if(test_ci1( entry, my_id, OM_Gw_current_OS,
                &ci_macro_id, me->internal_buffer ))
     {
      status = om$send( msg = message ci.set_value
                ((int *)msg,"MOD_ENV",(char *) md_env,sizeof(struct GRmd_env)),
                    targetid = ci_macro_id.objid ,
                    targetos = ci_macro_id.osnum);
      as$status ( );
     /* For Jean Luc safety ..... */
     GRabsg_del_all();
     *msg = MSSUCC ;
     *msg  = run_ci( entry,ci_macro_id );
     if(!(*msg&1)){
        goto wrapup;
      }
     }
    else
     {
      printf("No ppl compute entry point found \n");
      *msg = MSFAIL;
      goto wrapup;
     }
   }


  status = ACpull_feet(&MY_GRID,feet_num,&grobj_ids);
  OM_BLOCK_MOVE(grobj_ids,feet_list,*feet_num*sizeof(struct GRid));
  status = ACfree_feet(&MY_GRID);

wrapup :
  ASbroadcast_in_progress = save_br;

// Fix for TR# MP5348
// ALWAYS return OM_S_SUCCESS !!!
// NEVER  return OM_W_ABORT   !!!
//    if(!(*msg&1)) return ( OM_W_ABORT );
  return( OM_S_SUCCESS );
}

end implementation ov_ci_mac;
