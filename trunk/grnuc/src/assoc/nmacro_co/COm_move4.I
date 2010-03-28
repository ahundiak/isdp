class implementation COm_move;

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
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "grclasses.h"

#define AS_DEBUG

from expression import list;
from ACpretend import ACgive_downscan,ACfind_parent;
from GRvg import GRgetname;

#argsused
COm_display_move_line(fp,num_col,i,root,clone,Temp_Value,Temp_List)
char *fp;
int num_col,i;
char *root,*clone;
struct ret_struct *Temp_Value;
struct GRid *Temp_List;
{
 char text[DI_PATH_MAX],text1[DI_PATH_MAX],text2[DI_PATH_MAX];
 IGRlong status,msg;
 char *c,*strchr();

/*| root and clone names */
     FIfld_set_text(fp,TEMPLATE_LIST,i,0,root,FALSE);
 
     FIfld_set_text(fp,TEMPLATE_LIST,i,1,clone,FALSE);


/*| type or value */

     if     (Temp_Value->type == ~0) {	/*   strcpy(text,"other type");*/
        ex$message (msgnumb = AS_S_OthrType, buff = text);
     }
     else if(Temp_Value->type & line_generic) { /*     strcpy(text,"line");*/
        ex$message (msgnumb = AS_S_Line, buff = text);
     }
     else if(Temp_Value->type & point_generic) {/*    strcpy(text,"point");*/
        ex$message (msgnumb = GC_I_point, buff = text);
     }
     else if(Temp_Value->type & conic_generic)  {/*   strcpy(text,"circle");*/
        ex$message (msgnumb = GC_I_circle, buff = text);
     }
     else if(Temp_Value->type & parameter_generic)  {
          if(Temp_Value->type == double_type) {/*    strcpy(text,"double");*/
            ex$message (msgnumb = AS_S_Double, buff = text);
          }
          else   {/*          strcpy(text,"text");*/
            ex$message (msgnumb = GC_I_text, buff = text);
          }
     }
     else if(Temp_Value->type & lbs_generic)  { /*     strcpy(text,"text");*/
        ex$message (msgnumb = GC_I_text, buff = text);
     }
     else if(Temp_Value->type & ref_generic)  {/* strcpy(text,"coord. system");*/
        ex$message (msgnumb = AS_S_CoordSys, buff = text);
     }
     else if(Temp_Value->type & macro_generic) {/*strcpy(text,"construction")/*
        ex$message (msgnumb = AS_S_Constrct, buff = text);
     }
     else if(Temp_Value->type & curve_generic) {/*strcpy(text,"general curve");*/
        ex$message (msgnumb = AS_S_GenCurve, buff = text);
     }
     else  {			       	/* strcpy(text,"other type");*/
        ex$message (msgnumb = AS_S_OthrType, buff = text);
     }

     c = text;

     if((Temp_Value->type & parameter_generic)&& (Temp_Value->type!= ~0))
      {
       if(Temp_List->objid != NULL_OBJID)
        {
         status=om$send(msg = message expression.list(text),
			senderid = NULL_OBJID,
                        targetid = Temp_List->objid,
                        targetos = Temp_List->osnum);
	 if(!(status&1))Temp_List->objid = NULL_OBJID;
         else
          {
           char *b1,*b2;
           /*" remove the shit in %s\n",text */
           if(text[0] == '\\')
            {if( strchr(text,'=') != NULL) c = strchr(text,'=')+1;}

           for(; *c == ' ' ; c++);

           for(b1=c,b2=c;*b1 != '[' && *b1 != '\0';b1++)
            {if( *b1 != ' ') *b2++ = *b1;}
           *b2 = '\0';
           /*"result %s\n",c*/
          }
        }
       else status = 0;

       if(!(status&1))
        { if(Temp_Value->type == double_type)
	    sprintf(text,"%g",Temp_Value->var.root_pm_st.value);
	  else
	    strcpy(text,Temp_Value->var.text_st.text_string);
        }
      }
     else
      {
       status = om$send(msg = message ACpretend.ACgive_downscan(text1),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
       if(status&1)
        {
         struct GRid mac;
	 status = om$send(msg = message ACpretend.ACfind_parent(&mac,NULL,NULL),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
         if(status&1)
           {
            status = om$send(msg = message GRvg.GRgetname(&msg,text2),
		      senderid = NULL_OBJID,
                      targetid = mac.objid,
                      targetos = mac.osnum);
 	    if(status&msg&1)
              { strcat(text2,":");strcat(text2,text1); c = text2; }
	   }
	}
      else
        {
         status = om$send(msg = message GRvg.GRgetname(&msg,text1),
		      senderid = NULL_OBJID,
                      targetid = Temp_List->objid,
                      targetos = Temp_List->osnum);
         if(status&msg&1) c = text1;
        }
     }

     /*"value %s\n",text */
     FIfld_set_text(fp,TEMPLATE_LIST,i,2,c,FALSE);
 return 1;
}


method write_form (char *fp)
{
int i;

/*" Display macro template nb %d\n",me->Nb_Max_Temp */

  FIfld_set_num_rows(fp,TEMPLATE_LIST,me->Nb_Max_Temp);
  for(i=0;i<me->Nb_Max_Temp;i=i+1)
    {
     COm_display_move_line(fp,3,i,me->Temp_Name+i*macro_MAX_CHAR,
				  me->Temp_Clone_Name+i*macro_MAX_CHAR,
		             me->Temp_Value+i,me->Temp_Clone+i);
    }

  FIfld_set_num_rows(fp,FEET_LIST,me->Nb_Max_Feet);
  for(i=0;i<me->Nb_Max_Feet;i=i+1)
    {
     FIfld_set_text(fp,FEET_LIST,i,0,me->Feet_Name+i*macro_MAX_CHAR,FALSE);
    }


return(OM_S_SUCCESS);
}

method set_action_and_state(enum possible_actions action;
			    enum possible_states  state)
{
 int  resp;
 long size;
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
end implementation COm_move;
