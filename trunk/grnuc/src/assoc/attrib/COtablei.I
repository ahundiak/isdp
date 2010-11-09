class implementation COtable;

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "AS_status.h"
#include "exmacros.h"
#include "ACattrib.h"

#if defined( NT )
#  include "EXdirent.h"
#  include "EXs5dir.h"
#  define MAXPATHLEN _MAX_PATH
#else
#  include <sys/types.h>
#  include <dirent.h>
#  include <sys/param.h>
#endif

#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "OMmacros.h"
#include "AScmd.h"
#include "ASmsg.h"
#include "coparadef.h"
#include "expression.h"
#include "expmacros.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "nddef.h"

#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#else
#  include <FI.h>
#endif
#else
#  include <FI.h>
#endif

/*
#define FORM_EXEC FI_ACCEPT

#define FORM_ABORT FI_CANCEL
*/

#define TABLE_LIST 11

from NDnode import NDchg_state;
from FIdirform  import  update;

enum possible_actions { NIL,
			ERR,
			GET_TABLE,
			STO_TABLE,
			GET_INDEX,
			STO_INDEX,
			GET_NAME,
			STO_NAME,
			CREATE};

enum possible_states  { INITIAL,
			W_INDEX,
			W_NAME};

enum possible_entry   { 
			PARAM,
			POINT,
			NOENT};
			

static int AStable_select;
static Form form_ptr;

/*
  History
    elp             01/10/93         port to NT
*/

method wakeup(int n)
{
 long status;

 ex$message(msgnumb = AC_M_PlaTablePr );
 form_ptr = NULL;

 status = om$send(msg = message COtable.find_table(),
		  targetid = my_id);

 return om$send(msg = message COpara.wakeup(n),
		targetid = my_id,
		mode = OM_e_wrt_message);

}

method super_cmd.sleep(int n)
{
 if(form_ptr != NULL)
 {
  FIf_erase(form_ptr);
  FIf_delete(form_ptr);
  form_ptr = NULL;
 }
 return om$send(msg = message COpara.sleep(n),
		targetid = my_id,
		mode = OM_e_wrt_message);
}


method find_table()
{
 long status;
 DIR *dir;
 struct dirent *file;
 char full_name[MAXPATHLEN];
 
 int i;

 me->nb_table = 0;

 /* Search .t files in current directory */

 dir = opendir(".");

 if(dir != NULL)
  {
   while(1)
    {
     file = (struct dirent *) readdir(dir);
     if(!file) break;
     status = om$send(msg = message COtable.add_table(file),
		      targetid = my_id);
    }
   closedir(dir);
  }

 /* Search now in the config/table directories */

 for(i=0;i<30;i++)
  {
   status = ex$get_path(index = i,
			 path = full_name,
			 len = 180,
			 type = EX_CONFIG_PATH);
   if(!(status&1)) break;
   strcat(full_name,"/config/table/");
   dir = opendir(full_name);

   if(dir != NULL)
    {
     while(1)
      {
       file = (struct dirent *) readdir(dir);
       if(!file) break;
       status = om$send(msg = message COtable.add_table(file),
		      targetid = my_id);
      }
     closedir(dir);
    }
  }
 return OM_S_SUCCESS;
}

method add_table( struct dirent *file)
{
 long status;
 int name_len,previous_dimension;

 previous_dimension = om$dimension_of(varray = me->table_name);
 if((me->nb_table+1)*MAX_TABLE_NAME >= previous_dimension)
  {
   status = om$vla_set_dimension(varray = me->table_name,
				 size = 10*(1+me->nb_table/10)*MAX_TABLE_NAME);
   as$status(action = RET_STATUS);
  }

 name_len = strlen(file->d_name);

     if(file->d_name[name_len-1] == 't' &&
        file->d_name[name_len-2] == '.')
      {
       OM_BLOCK_MOVE(file->d_name,me->table_name+me->nb_table*MAX_TABLE_NAME,
		     name_len-2);
       me->table_name[name_len-2 + me->nb_table*MAX_TABLE_NAME] = '\0';
       me->nb_table++;
      }

 return OM_S_SUCCESS;
}

method write_table()
{
 char *c;
 int i;
 
 FIfld_set_num_rows(form_ptr,TABLE_LIST,me->nb_table);
 c = me->table_name;


 for(i=0;i<me->nb_table;i++,c+=MAX_TABLE_NAME)
          FIfld_set_text(form_ptr,TABLE_LIST,i,0,c,FALSE);
 FIfld_set_active_row(form_ptr,TABLE_LIST,0,0);
 return OM_S_SUCCESS;
}


method generate_hdr_name(int *name_changed)
{
 IGRlong msg;
 char *c,*c1,*strrchr();
 int i;
 struct GRid Object_GRid;
 
 *name_changed = 0;

  /*| Automatic name generation for occurences */

 if(me->hdr_name[0] == '\0') return OM_S_SUCCESS;
 c = strrchr(me->hdr_name,'_');

/* 
   searchs if an object with that name already exists 
*/

 msg = di$translate(objname = me->hdr_name,
                    p_objid = &Object_GRid.objid,
                    p_osnum = &Object_GRid.osnum );
 if( msg != DIR_S_SUCCESS) return OM_S_SUCCESS;

/* if the name is name_##, find pointer to the suffix */ 

  c = strrchr(me->hdr_name,'_');

  if(c != NULL)
   {
    i = strtol(c+1,&c1,10);
    if(*c1 != '\0') c = NULL;
   }

  if(c == NULL) c = me->hdr_name + strlen(me->hdr_name);

/* find correct suffix */

  for(i=0;i<1000;i++)
   {
    if(i<100) sprintf(c,"_%02d",i);
    else      sprintf(c,"_%03d",i);
    /*" hdr_name %s\n",me->hdr_name*/
    msg = di$translate(objname = me->hdr_name,
                       p_objid = &Object_GRid.objid,
                       p_osnum = &Object_GRid.osnum );
    if( msg != DIR_S_SUCCESS) break;
   }

/* generate name + suffix */

  if(i>=1000) me->hdr_name[0] = '\0';
  else
   { c = strrchr(me->hdr_name,':');
     if(c == NULL) c = me->hdr_name;
     else c++;
     strcpy(me->hdr_name,c);
   }
  *name_changed = 1;
  return OM_S_SUCCESS;
}

method execute (int *response; char *response_data;int  pos)
{

#define NUM_STATES 3
#define NUM_TOKENS 5

static IGRint TokenList[] =
                      {
                        RESET,
                        DATA ,
			STRING ,
                        GR_UNKNOWN_TYPE ,
                        LOC_PARAM
                      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ************************** TOKENS **********
   Old State*    RESET     , DATA    , STRING    , UNKNOWN   ,  PARAM      */
/* INITIAL  */{ INITIAL    , W_INDEX , INITIAL   , INITIAL   ,  INITIAL    },
/* W_INDEX  */{ INITIAL    , W_INDEX , W_INDEX   , W_INDEX   ,  W_NAME     },
/* W_NAME   */{ INITIAL    , INITIAL , INITIAL   , W_NAME    ,  W_NAME     }};


static enum possible_actions NewAction[NUM_STATES][NUM_TOKENS] = {

/*          ************************** TOKENS **********
   Old State*    RESET     , DATA     , STRING   , UNKNOWN   ,  PARAM      */
/* INITIAL  */{ GET_TABLE  , STO_TABLE, GET_TABLE, GET_TABLE ,  GET_TABLE  },
/* W_INDEX  */{ GET_TABLE  , GET_INDEX, GET_INDEX, GET_INDEX ,  STO_INDEX  },
/* W_NAME   */{ CREATE     , STO_NAME , STO_NAME , GET_NAME  ,  GET_NAME   }};

int entry_requested,name_changed,FORM,token;
int AStable_read();
long status;
long Input_Mask, Locate_Mask, Display_Flag;
struct GRevent Event_Ac, Event_Loc;
struct GRid Object_GRid;
double Param;
int Size;


 FORM = 0;
 entry_requested = 0;
 token = 0;
 Size = sizeof(struct GRevent);
 



 if(me->nb_table<=0)
 {
  ex$message(msgnumb = AS_S_NoTab);
  return OM_W_ABORT;
 }
 
 do
 {

 switch (me->action)
 {
 case GET_TABLE :
  /* Display form with list of available table */
  AStable_select = -1;
  if(form_ptr == NULL) FIf_new(FORM,"ASTable",AStable_read,&form_ptr);
  if(form_ptr == NULL) return OM_W_ABORT;
  status = om$send(msg = message COtable.write_table(),
 		   targetid = my_id);
  ex$message(msgnumb = AS_P_SelTab);
  entry_requested = POINT;
  Input_Mask = GRm_DATA | GRm_RESET;
  FIf_display(form_ptr);
  break;

 case STO_TABLE : 
  if(AStable_select < 0)
   {
    me->state = INITIAL;
    me->action = GET_TABLE;
    entry_requested = NOENT;
    break;
   }

  if(form_ptr != NULL)
  {
   FIf_erase(form_ptr);
   FIf_delete(form_ptr);
   form_ptr = NULL;
  }
  me->selected_table = AStable_select;
  sprintf(me->hdr_name,"%s_00",
	  me->table_name+me->selected_table*MAX_TABLE_NAME);
  status = om$send(msg = message COtable.generate_hdr_name(&name_changed),
		   targetid = my_id);
  status = exp$create(osnum = me->ModuleInfo.md_id.osnum,
		   exp_name = NULL,
		   exp_syntax=me->table_name+me->selected_table*MAX_TABLE_NAME,
		   p_exp_id = &me->Temp_List[1].objid,
		   type_rq = EXP_TEXT);
  me->Temp_List[1].osnum = me->ModuleInfo.md_id.osnum;
  status = om$send(msg = message NDnode.NDchg_state
				   (ND_SUP_ONLY,ND_SUP_ONLY),
		   targetid = me->Temp_List[1].objid,
		   targetos = me->Temp_List[1].osnum);

		


 case GET_INDEX : /* ask index of table */

  ex$message(msgnumb = AS_P_KeyIndex,
	     buff = me->loc_prompt);
  entry_requested = PARAM;
  Locate_Mask = GRm_DATA | GRm_RESET;
  Input_Mask = GRm_DATA | GRm_RESET;
  break;

 case STO_INDEX :
  as$make_source(go_grid = Object_GRid,
		 as_os = me->ModuleInfo.md_id.osnum,
		 as_grid = me->Temp_List);

 case GET_NAME :
   ex$message(msgnumb = AS_P_KeyOcc, type = "%s" , var = `me->hdr_name`);
   Input_Mask = GRm_STRING | GRm_RESET;
   entry_requested = POINT;
   break;

 case STO_NAME :
  strcpy(me->hdr_name,response_data);
  status = om$send(msg= message COtable.generate_hdr_name(&name_changed),
		   targetid = my_id);
  if(name_changed)
   {
    me->action = GET_NAME;
    me->state = W_NAME;
    entry_requested = NOENT;
    break;
   }

 case CREATE : 
   status = om$send(msg = message COtable.place_table(),
		    targetid = my_id);
   ex$message(msgnumb = AS_S_TabCreated, type = "%s" , var = `me->hdr_name`);

  di$send( msg        = message FIdirform.update(),
           targetname = "IGENOD:DirCmds",
           targetos   = OM_Gw_current_OS );


   status = om$send(msg= message COtable.generate_hdr_name(&name_changed),
		   targetid = my_id);
   Input_Mask = GRm_STRING | GRm_RESET;
   me->action = GET_INDEX;
   me->state = W_INDEX;
   entry_requested = NOENT;
   break;

 }/* end switch on actions */


 switch (entry_requested)
  {
          case PARAM :
        token = ASget_param (
                &status,                        TokenList,
                &Event_Loc,                     &Event_Ac,
                &Locate_Mask,                   &Input_Mask,
                &Size,                          &Display_Flag,
                response,                               response_data,
                me->loc_prompt,          me->acc_prompt,
                me->reloc_prompt,        &me->attr,
                &me->locate_stack,
                &Object_GRid, &Param);
	 break;


          case POINT :
            token = GRget_token(&status,TokenList,&Input_Mask,&Event_Loc,
                     &Size,response,response_data);
	    break;



          case NOENT :
	       break; 
     
  }  /* end switch entry_requested  */

 /* new action and new state */

 if(entry_requested != NOENT)
  {
   me->action = (IGRint) NewAction[   me->state ][ token ];
   me->state =  (IGRint) NewState[ me->state ][ token ];
  }

}  while(entry_requested == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);


return OM_S_SUCCESS;
}

#argsused
AStable_read(
  int    form_label,
  int    label,
  double value,
  char  *form_ptr)
{
  long size;
  int  resp,pos;
  long status,msg;
  char data[1];

  data[0]=0;
  size = 1;

 switch(label)
  {
   case TABLE_LIST :
     FIfld_get_active_row(form_ptr,TABLE_LIST,&AStable_select,&pos);
     break;
   case FI_ACCEPT :
     resp = DATA;
     status = ex$putque(msg = &msg, response = &resp,
                        byte = &size, buffer = data);
     FIf_erase(form_ptr);
     break;
   case FI_CANCEL :
     resp = TERMINATE;
     status = ex$putque(msg = &msg, response = &resp,
                        byte = &size, buffer = data);
     FIf_erase(form_ptr);
     break;

  }
 return OM_S_SUCCESS;
}

 

 

end implementation COtable;
