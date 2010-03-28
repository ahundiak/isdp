class implementation COm_move;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "exmacros.h"
#include "exdef.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expression.h"
#include "expmacros.h"
#include "nddef.h"
#include "griomacros.h"
#include "dpmacros.h"

#define AS_DEBUG

from NDnode import NDchg_state,NDgive_structure;

extern char *COm_move_option_ptr;
extern       COm_move_option();

method form_notification (int f_label, g_label;double value;char *fp;
			  int init_notif)
{
int status,msg;
int row,col,pos,index;

status = OM_S_SUCCESS;
switch(g_label)
 {

 case FORM_RESTART :
   status = om$send(msg = message COm_move.set_action_and_state
                                                (RESTART,INITIAL),
                    targetid = my_id);
   break;

 case FORM_ABORT : /*| Abort command						      */
  {
   int  resp;
   long size;
   char data[1];

   resp = TERMINATE;
   data[0]=0;
   size = 1;
   status = ex$putque(msg = (IGRlong *)&msg, response = &resp,
		      byte = &size, buffer = data);
   break;
  }
   

 case TEMPLATE_LIST : /*| Get one of the template			      */

   FIfld_get_active_row (fp,g_label,&row,&pos);
   FImcf_get_active_col (fp,g_label,&col,&pos);
   index = row;
   /*"init_notif %d row %d col %d --> template %d\n",init_notif,row,col,index*/

   if(col == 0)
    {
     /*| Hilight initial root */
     dp$erase_hilite(msg = &msg);
     COm_hilite_elem(me->Temp_List+index,me->Temp_Value[index].type,
		     GRhdo,&me->ModuleInfo);
    }

   else if(col == 1)
    {
     /*| Hilight clone root and ask for reselection */
     dp$erase_hilite(msg = &msg);
     COm_hilite_elem(me->Temp_Clone+index,me->Temp_Value[index].type,
		     GRhdo,&me->ModuleInfo);
     me->index_to_locate = index;
     status = om$send(msg = message COm_move.set_action_and_state
					(PRO_TEMP,WAIT_TEM),
		      targetid = my_id);
     as$status();
    }
   break;
   
  case FEET_LIST : /*| Just hilight feet for control */
   FIfld_get_active_row (fp,g_label,&row,&pos);
   index = row;
   dp$erase_hilite(msg = &msg);
   COm_hilite_elem(me->Feet_List+index,me->Feet_Type[index],
		     GRhdo,&me->ModuleInfo);
   break;

  case FORM_COPY :
     status = om$send(msg = message COm_move.set_action_and_state
					(COPY,FULL_DEF), 
		      targetid = my_id);
     as$status();
   break;
 
  case FORM_MOVE :
     status = om$send(msg = message COm_move.set_action_and_state
					(MOVE,FULL_DEF),
		      targetid = my_id);
     as$status();
   break;
 }

 return(status);
}

end implementation COm_move;
