class implementation COm_crdef;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asbox.h"


#define AS_DEBUG
from expression import list;

extern char *COm_crdef_form_ptr;

method write_form (char *fp)
{
int i,row,sel;
double d;
char *c;
char text[80];

/*" Display Macro name %s\n",me->macro_name */


  FIfld_set_text(fp,MACRO_NAME,0,0,me->macro_name,FALSE);
 
/*" Display macro template nb %d\n",me->Nb_Max_Temp */
  
  d = 0; /* dummy value */
  row = 0;
  c = me->Temp_Name ;
  for(i=0;i<me->Nb_Max_Temp;i=i+1)
    {
     /*"temp %d name >%s<\n",i,c*/
     COm_display_line(fp,TEMPLATE_LIST,2,row++,c,me->Temp_Value[i].type,
			 me->Temp_Value+i,&NULL_GRID,0);
     c += macro_MAX_CHAR;
     if(me->state == FULL_DEF && me->Temp_Fixed[i])
          FIfld_set_text(fp,TEMPLATE_LIST,i,2,"YES",FALSE);
     else
          FIfld_set_text(fp,TEMPLATE_LIST,i,2,"NO",FALSE);
      
    }
  FIfld_set_num_rows(fp,TEMPLATE_LIST,row);

/*" Display macro foot nb %d\n",me->Nb_Max_Feet */

  FIfld_set_num_rows(fp,FEET_LIST,me->Nb_Max_Feet);
  row = 0;
  c = me->Feet_Name;
  for(i=0;i<me->Nb_Max_Feet;i++,c += macro_MAX_CHAR)
    {
     if(*c == '\0') continue;
     FIfld_set_text(fp,FEET_LIST,row,0,c,FALSE);
     if(me->Feet_Removed[i]) FIfld_set_text(fp,FEET_LIST,row++,1,"YES",FALSE);
     else 		     FIfld_set_text(fp,FEET_LIST,row++,1,"NO",FALSE);
    }
  FIfld_set_num_rows(fp,FEET_LIST,row);

/* what will be the located template */
  if     (me->template_type == (ND_ROOT | ND_BODY)) row = 0;
  else if(me->template_type == ND_ROOT ) row = 1;
  else if(me->template_type == (ND_ROOT|ND_BODY|ND_TEMPLATE_AND_FEET)) row = 2;

   FIfld_get_list_text(fp,TEMPLATE_TYPE,row,0,80,text,&sel);
   FIfld_set_list_select(fp,TEMPLATE_TYPE,row,0,TRUE);
   FIfld_set_text(fp,TEMPLATE_TYPE,0,0,text,FALSE);

 /*| erase error box */
   FIfld_set_text(fp,ERROR_BOX,0,0,"",FALSE);

return(OM_S_SUCCESS);
}

method set_action_and_state(enum possible_actions action;
			    enum possible_states  state)
{
 long size;
 int  resp;
 char data[1];
 IGRlong status,msg;

 /*"set state to %d and action to %d\n",state,action */
     me->action = action;
     me->state =  state;
     me->Entry_Request = NOENT;

     resp = ABS_DIG; /* Just to have an "unkown" */
     data[0]=0;
     size = 1;
     status = ex$putque(msg = &msg, response = &resp,
                      byte = &size, buffer = data);

     return (OM_S_SUCCESS);
}

   

end implementation COm_crdef;
