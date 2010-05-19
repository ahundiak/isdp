/* $Id: SMCrtNotif.I,v 1.1.1.1 2001/01/04 21:07:36 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smreports/cmd / SMCrtNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCrtNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:36  cvs
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
# Revision 1.3  1996/04/29  09:00:48  pinnacle
# Replaced: smreports/cmd/SMCrtNotif.I for:  by ksundar for vds.240
#
# Revision 1.2  1996/03/28  08:52:38  pinnacle
# Replaced: smreports/cmd/SMCrtNotif.I for:  by rgade for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

 /* 
     File             SMCrtNotif.I;
     Creation Date    September 92
     Auteur           Jean Jasinczuk (ISDC)

     Methods  and functions for SMCmdRptObj.S ;

     History
 */

class implementation SMCmdRptObj;

#define DEBUG           1
#define AS_DEBUG	1
/* #define JJ_DEBUG       1   */

#include "AS_status.h"
#include "vdsmacros.h"
#include "VDmem.h"

from NDnode import ASreturn_go,NDdisplay,NDget_objects,NDchg_state;
from expression import create;            
from NDmacro import ACreturn_foot;            
from SMreports import SMGetAttTxt, ACmplace, SMSetAttTxt,
SMRptAddObj,SMRptDelObj,SMRptClean;            
from GRgraphics import GRdisplay,GRputname;
from SMmgr import SMSetAttDbl;

extern GRclassid OPP_EMSsolid_class_id,OPP_SMreports_class_id;
extern GRclassid OPP_EMSsurface_class_id,OPP_ACpretend_class_id;

%safe
static void change_mode_list_field();
static int find_parent_index();
static int del_one_parent();
static void place_one_parent_in_form();
static void place_parents_in_form();
static int find_index_select_parent();
static void select_list_parent();
%endsafe

#define INCR 10
  
/* --------------- static void change_mode_list_field --------------- */
/* Change the state of GI_DENS.. to FI_APPEND or FI_REVIEW            */
  
static void change_mode_list_field(form,mode)
Form form;   /* [I] */
int mode;    /* [I] (FI_APPEND or FI_REVIEW) */
{
  FIfld_set_mode(form,G_PARENT_LIST,GI_DENS,mode);
  FIg_display(form,G_PARENT_LIST);
}

/* --------------- static int find_parent_index -------------------------- */
/* Find the index in the Parent table of the given parent given name or id */
/* Return 0 if not found */

static int find_parent_index(Parent,nb_parent,name,id,parent_ind)
struct RepParent Parent[];   /* [I] the table of parent */
int nb_parent;               /* [I] Number of parent    */
char *name;                  /* [I] name of parent (or NULL)   */
struct GRid *id;             /* [I] Id of the parent (or NULL) */
int *parent_ind;             /* [O] The index of the parent in the table */
{
  int i;

  if(nb_parent == 0) return 0;

  if(name != NULL)
    for(i=0; i<nb_parent; i++)
       if(strcmp(name,Parent[i].name) == 0)
	{
	  if(parent_ind) *parent_ind = i;
	  return 1;
	}

  if(id != NULL)
    for(i=0; i<nb_parent; i++)
      if(id->objid == Parent[i].id.objid &&
	 id->osnum == Parent[i].id.osnum)
       {
	 if(parent_ind) *parent_ind = i;
	 return 1;
       }

  return 0; /* Parent not found if here */
}

/* ------------------ static void gener_default_name ------------------ */
/* Gener a default name for a parent                                    */

static void gener_default_name(id,Parent,nb_parent,name)
struct GRid *id;            /* [I] Id of parent */
struct RepParent Parent[];  /* [I] Table of parent (look for other name) */
int nb_parent;              /* [I] Number of parents */
char *name;                 /* [O] Name return */
{
  char tmp_name[80];
  int i,parent_ind;

  /* Search the name of the new parent : if not found gener default name */ 
  tmp_name[0] = '\0';
  vd$get_name(name = tmp_name, obj = id);
  if(tmp_name[0] == '\0')
    for(i=0;i<2000;i++)
     {
       sprintf(tmp_name,"defined_%d",i);
       if(!find_parent_index(Parent,nb_parent,tmp_name,
			     (struct GRid *)NULL,&parent_ind))
	{
	  strcpy(name,tmp_name);
	  return;
	}
     }
  else
    strcpy(name,tmp_name);
}
 
/* --------------- static int del_one_parent -------------------*/
/*     Delete one parent of the table given by is index          */

static int del_one_parent(Parent,nb_parent,parent_ind)				 
struct RepParent Parent[];   /* [O] the table of parent where to delete */
int *nb_parent;              /* [I/O] Number of parent */
int parent_ind;              /* [I] The indice of the parent to delete */
{
  int i;

  if(*nb_parent <= 0) {printf("No parent defined\n");return 0;}

  if(parent_ind + 1 < *nb_parent)
   {
     for(i = parent_ind ;  i < *nb_parent - 1; i++)
       Parent[i] = Parent[i+1];
   }

  *nb_parent = *nb_parent - 1;
  return 1;
}


/* --------------- static void place_one_parent_in_form --------------- */
/* Place attribute of a parent from buffer to G_PARENT_LIST in form       */

static void place_one_parent_in_form(form,Parent,ind,row,select)
Form form;                  /* [I] */
struct RepParent Parent[];  /* [I] Buffer of all Parent  */
int ind;                    /* [I] Indice of the parent */
int row;                    /* [I] Row number in the gadget */
IGRboolean select;          /* [I] IF TRUE place parent as select one */
{
  
  FIfld_set_text(form,G_PARENT_LIST,row,GI_NAME,Parent[ind].name,select);
  if(Parent[ind].VolMass >= 0.0)
    FIfld_set_value(form,G_PARENT_LIST,row,GI_DENS,Parent[ind].VolMass,select);
  switch(Parent[ind].type)
   {
   case SM_RP_SL:
     FIfld_set_text(form,G_PARENT_LIST,row,GI_TYPE,"Vol",select);
     break;
   case SM_RP_SF:
     FIfld_set_text(form,G_PARENT_LIST,row,GI_TYPE,"Surf",select);
     break;
   case SM_RP_RP:
     FIfld_set_text(form,G_PARENT_LIST,row,GI_TYPE,"Rep",select);
     break;
   default:
     printf("unknown object given in place_one_parent\n");
     break;
   }
}  


/* --------------- static void place_parents_in_form --------------- */
/* Place the selected parents in the list of parents               */
/* There is no default selected parent                              */

static void place_parents_in_form(form,nb_parent,Parent)
Form form;                  /* [I] */
int nb_parent;              /* [I] */
struct RepParent *Parent;   /* [I] Buffer contanining the parents */
{
  int row = 0;
  
  row = 0;
  for(row = 0; row < nb_parent; row++)
    place_one_parent_in_form(form,Parent,row,row,FALSE);

  FIfld_set_num_rows(form,G_PARENT_LIST,row);
  FIfld_set_max_num_rows(form,G_PARENT_LIST,row);
  if(row == 0)
    /* As no parent selected, nothing can be keyin in form GI_PARENT_LIST */
    change_mode_list_field(form,FI_REVIEW);
  else
    change_mode_list_field(form,FI_APPEND);
}	


/* --------------- static int find_index_select_parent --------------------- */
/* Retrieve the index of the selected parent. Return 0 if no parent selected */

static int find_index_select_parent(form,Parent,nb_parent,parent_ind,row)
Form form;                 /* [I] */
struct RepParent Parent[];  /* [I] the table of parent */
int nb_parent;                /* [I] Number of parent */
int *parent_ind;  /* [O] Index in the RepParent of selected parent (or NULL)*/
int *row;      /* [O] Row in the form list of the selected parent (or NULL)*/
{
  int i,num_rows,sel_flag,r_pos;
  char name[DI_PATH_MAX];

  sel_flag = 0;
  FIfld_get_num_rows(form,G_PARENT_LIST,&num_rows);
  for(i = 0; i < num_rows; i++)
   {
     FIfld_get_select(form,G_PARENT_LIST,i,0,&sel_flag);
     if(sel_flag) break;
   }
  if(!sel_flag) return 0; /* No parent selected */

  FIfld_get_text(form,G_PARENT_LIST,i,0,DI_PATH_MAX,name,&sel_flag,&r_pos);
  if(!find_parent_index(Parent,nb_parent,name,(struct GRid *)NULL,parent_ind))
   {printf("Parent not found\n");return 0;}

  if(row) *row = i;
  return 1;
}

/* --------------- static void select_list_parent ---------------------- */
/* One parent is selected in the list of parents :                    */
/* Two possible actions are possible depanding if user select parent  */
/* for remove or for display attribut                                 */

static void select_list_parent(form,Parent,nb_parent,state_list)
Form form;                 /* [I] */
struct RepParent Parent[];  /* [I] the table of parent */
int nb_parent;                /* [I] Number of parent */
IGRboolean state_list;     /* [I] control delete state or not */
{ 
  char my_msg[80];
  int sel_flag,parent_ind;

  sel_flag = find_index_select_parent(form,Parent,nb_parent,&parent_ind,(int *)NULL);
  
  if(state_list == DEL_STATE) /* User select for remove */
   {
     if(sel_flag)  /* One row is selected : user must valid with del button*/
      {
	ex$message( msgnumb = SM_I_RpValParentDel, buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
      }
     else /* First select row */
      {
	ex$message( msgnumb = SM_I_RpSelParentDel, buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
      }
     return;
   }
} 


/* -------------------- method save_parent ------------------------ */
/*    This method save the attributes of all parents of the report  */
/*    The parent list is in the work_parent.                        */

method save_parent(long *sts)
{
  int ind;
  int row,num_rows,sel_flag,r_pos;
  char name[80],my_msg[80];
  double val_db;
  

  FIfld_get_num_rows(me->forms[0].form_ptr,G_PARENT_LIST,&num_rows);
  
  for(row=0; row < num_rows; row++)
   {
     /* Get name of parent and retrieve it's index in the save list */
     name[0] = '\0'; 
     FIfld_get_text(me->forms[0].form_ptr,G_PARENT_LIST,row,GI_NAME,
		    80,name,&sel_flag,&r_pos);
     if(name[0] == '\0' ||
	!find_parent_index(me->work_parent,me->work_nb_parent,name,
			   (struct GRid *)NULL,&ind))
      {printf("Can't find index of parent %s\n",name); goto wrapup;}
   
    /* Get density */
     if(me->work_parent[ind].type == SM_RP_SF ||
	me->work_parent[ind].type == SM_RP_SL)
      {
	if(!(SMget_double(me->forms[0].form_ptr,G_PARENT_LIST,
			  ind,GI_DENS,&val_db)))
	 {
	   ex$message(msgnumb = SM_E_RpNeedDens , buff = my_msg,
		      type = "%d" , var = `row`);
	   FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	   goto wrapup;
	 }
	me->work_parent[ind].VolMass = val_db; 
      }
   }		 

#ifdef JJ_DEBUG
     print_parent_attr(me->work_parent,me->work_nb_parent);
#endif
  
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;

 wrapup:
  *sts = OM_E_ABORT;   
  return OM_S_SUCCESS;
}


/* ------------------- method form_notification -------------------- */

method form_notification (int form_label; int gadget_label ; double value ;
			  char * form_ptr)
{
  int status = OM_S_SUCCESS;
  long sts;
  
  if ( form_ptr == NULL ) return( OM_E_INVARG ); 
  
  FIg_set_text(form_ptr,FI_MSG_FIELD, "");
  
  switch( gadget_label )
   {
   case FI_ACCEPT :
     om$send(msg = message SMCmdRptObj.save_all(&sts),
	     targetid = my_id);
     
     FIg_set_state_off(form_ptr,FI_ACCEPT);
     if(sts == OM_S_SUCCESS)
       _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_EXECUTE :
     om$send(msg = message SMCmdRptObj.save_all(&sts),
	     targetid = my_id);
     
     FIg_set_state_off(form_ptr,FI_EXECUTE);
     if(sts == OM_S_SUCCESS)
       _put_response(resp = RELOCATE_OBJ);
     goto quit;
     
   case FI_CANCEL :
     _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_RESET :
     om$send(msg = message SMCmdRptObj.reset_all(&sts),
	     targetid = my_id);
     goto quit;
     
   case G_NAME:
   case G_DESC:	
     break;
     
   case G_PARENT_LIST:
     select_list_parent(me->forms[0].form_ptr,
		      me->work_parent,me->work_nb_parent,me->state_list);
     break;
     
     
   case G_ADD:
     me->state_list = ADD_STATE;
     _put_response( resp = LOCATE_PARENT ); 
     goto quit;
     
   case G_REMOVE:
     om$send(msg = message SMCmdRptObj.select_delete_parent(&sts),
	     targetid = my_id);
     if(!(sts & 1)){printf("Erreur delete parent\n");}
     goto quit;
   }
  
 quit: return OM_S_SUCCESS;
}

/* -------------- method init_form_new_rep ------------------  */
/*     This method initialize the form for a new reports       */

method init_form_new_rep(long *sts )
{
  /* No parents */
  me->save_nb_parent = me->work_nb_parent = 0;

  /* Init value and default value for rep area */
  SMVA_set_default_text(me->forms[0].form_ptr,2,
			G_NAME,"",
			G_DESC,"");

  FIfld_set_num_rows(me->forms[0].form_ptr,G_PARENT_LIST,0);
 
  /* As no parent selected, nothing can be keyin in form GI_PARENT_LIST */
  change_mode_list_field(me->forms[0].form_ptr,FI_REVIEW);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* ------------------- method control_report ----------------------  */
/*         Method call after locate of a report                      */
/* It put all attributes in the form and retrieve all the templates  */

method control_rep( long *sts )
{
  IGRlong msg,status;
  char desc[ATTR_TXT],name[DI_PATH_MAX];
  int i;
  IGRint nb_roots;
  struct GRid *roots, *rts = NULL;
  IGRshort type;
  struct SMrpt *Info = NULL;

  me->save_nb_parent = me->work_nb_parent = 0;

  /* Get the parents */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT|ND_IN_BUF, NULL,
		    0, &roots, 1, OM_K_MAXINT, &nb_roots),
		   targetid = me->rep_id.objid,
		   targetos = me->rep_id.osnum);
  as$status(action = RET_STATUS);
  if(nb_roots < 2){
    printf("Error, to few roots for reports %d,%d\n",
	   me->rep_id.objid,me->rep_id.osnum);
    goto wrapup;
  }

  nb_roots -= 1; /* The ACrg collection must not be counted in the parents */

  /* must copy into a local structure and free afterwards (recursion) */
  rts = _MALLOC(nb_roots, struct GRid);
  if(!rts) {printf("Error alloc memory\n"); goto wrapup;}

  for(i=0;i<nb_roots;i++) rts[i] = roots[i];
 
  if(SMFillRpt(nb_roots, rts, SM_RPT_OBJ_LIGHT, &Info) != 1) {
    printf("Error fill report structure\n");
    goto wrapup;
   }

  status = om$vla_set_dimension(varray = me->save_parent,size = nb_roots);
  as$status(action = RET_STATUS);

  /* Affect structure for parents */
  for(i=0; i<nb_roots; i++)
   {
     switch(Info[i].type)
      {
      case SM_RP_SF: case SM_RP_SL:
	if(!GetEnvFrObj(&rts[i],
			&me->save_parent[me->save_nb_parent].env,
			&me->save_parent[me->save_nb_parent].id))
	 {printf("Error GetEnvFrObj Object %d %d\n",rts[i].objid,rts[i].osnum);
	  goto wrapup;}
	me->save_parent[me->save_nb_parent].type = Info[i].type;
	me->save_parent[me->save_nb_parent].VolMass = Info[i].VolMass;
	gener_default_name(&me->save_parent[me->save_nb_parent].id,
			   &me->save_parent[0],me->save_nb_parent,
			   me->save_parent[me->save_nb_parent].name);
	me->save_nb_parent++;
	break;

      case SM_RP_RP:
	me->save_parent[me->save_nb_parent].id = rts[i];
	me->save_parent[me->save_nb_parent].env = me->ModuleInfo;
	me->save_parent[me->save_nb_parent].type = Info[i].type;
	me->save_parent[me->save_nb_parent].VolMass = NO_DENSITY;
	gener_default_name(&me->save_parent[me->save_nb_parent].id,
			   &me->save_parent[0],me->save_nb_parent,
			   me->save_parent[me->save_nb_parent].name);
	me->save_nb_parent++;
	break;
	
      default: /* Volumetric mass : do nothing */
	break;
      }
   }

  if(!SMGetSplitName(&me->rep_id,name)) goto wrapup;

  /* Find the description */
  desc[0] = '\0';
  status = om$send(msg = message SMreports.SMGetAttTxt
		   (&msg,"description",desc,&type),
		   targetid = me->rep_id.objid,
		   targetos = me->rep_id.osnum);
  as$status(); as$status(sts = msg);
  
  SMVA_set_default_text(me->forms[0].form_ptr,2,
			G_NAME,name,
			G_DESC,desc);
 
  /* Put all parents attribut in the form */
  place_parents_in_form(me->forms[0].form_ptr,
			me->save_nb_parent,&me->save_parent[0]);

  om$send(msg = message SMCmdRptObj.copy_param(sts,SAVE_TO_WORK),
	  targetid = my_id);

  _FREE(Info) ;
  _FREE(rts) ;
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;

 wrapup:
  _FREE(Info) ;
  _FREE(rts) ;
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;
} 

/* -------------------- method SMplace_rep ------------------------- */
/*           Construct and place reports  macro                      */
/* It also need the me->work_parent struct for parents parameters    */
/* It affects the me->rep_id.                                        */

method SMplace_rep(IGRlong *msg; char *name ; char *desc) 
{
  IGRlong status,loc_msg;
  struct GRid mac;
  int sts;
  int i,nb_root;
  struct GRid TEMP[MAX_TEMP]; /* Template of the reports is an ACrg */
  IGRlong msgcode;
  char my_msg[80],tmp[80];
  IGRshort  rc2;
  IGRdouble old_density;

  msgcode   = 0;
  mac.objid = NULL_OBJID;
  
  /* Create and init the collection */
  if(SMRptInitCol(&TEMP[0], &me->ModuleInfo) == 0)
   { printf("Error SMRptInitCol\n"); goto wrapup; }

  /* Construct the reports object */
  mac.osnum = me->ModuleInfo.md_id.osnum;
  status = om$construct(classid = OPP_SMreports_class_id,
			osnum   = mac.osnum,
			p_objid = &mac.objid );
  as$status(action = GOTO_VALUE, value = wrapup);

  nb_root     =  1; /* First was ACrg */
  old_density = -1.0;

  for(i=0; i < me->work_nb_parent; i++)
   {
     switch(me->work_parent[i].type)
      {
      case SM_RP_SL:
      case  SM_RP_SF:

	if(old_density != me->work_parent[i].VolMass)
	 {
	   old_density = me->work_parent[i].VolMass;
	   /* So we create only one expression for each surface */
	   /* with same density*/

	   TEMP[nb_root].osnum = me->ModuleInfo.md_id.osnum;
	   status = om$construct(classid = OPP_expression_class_id,
				 osnum   = TEMP[nb_root].osnum,
				 p_objid = &TEMP[nb_root].objid);
	   as$status(action = RET_STATUS);
	   
	   tmp[0] = '\0';
	   sprintf(tmp, "%g",me->work_parent[i].VolMass);
	   
	   status = om$send(msg = message expression.create(NULL, tmp , &rc2 ),
			    targetid = TEMP[nb_root].objid,
			    targetos = TEMP[nb_root].osnum);
	   as$status(sts = (status & rc2),action = RET_STATUS);
	
	   status = om$send(msg = message NDnode.NDchg_state
			    (ND_DEL_NO_CH | ND_WAIT_DEL,
			     ND_DEL_NO_CH | ND_WAIT_DEL),
			    targetid = TEMP[nb_root].objid,
			    targetos = TEMP[nb_root].osnum);
	   as$status(action = GOTO_VALUE, value = wrapup);
	   nb_root++;
	   /* No break as we must set next template with parent */
	 }
      case SM_RP_RP:
	status = as$make_source(go_grid = me->work_parent[i].id,
				mod_env = &me->work_parent[i].env,
				as_grid = &TEMP[nb_root]);
	as$status(action = GOTO_VALUE, value = wrapup);
	nb_root++;
	break;

      default:
	printf("Unknown type %d\n",me->work_parent[i].type);
	break;
      }
   }
#ifdef JJ_DEBUG
  for(i=0;i<nb_root;i=i+1)
    printf("temp: %d, %d\n", TEMP[i].objid, TEMP[i].osnum);
#endif

  status = om$send(msg = message SMreports.ACmplace
		   (&sts, AChdr_nodisplay,
		    0, "SMrpt", nb_root, TEMP, &me->ModuleInfo),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  as$status(sts = (status & sts),action = GOTO_VALUE,value = wrapup);
  
  if(name[0] != '\0')
   {
     status = om$send(msg = message GRgraphics.GRputname(&loc_msg,name),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     if(!(status & loc_msg & 1))
       printf("Warning can't set name of object %d %d\n",mac.objid,mac.osnum);
   }
  
  status = om$send(msg = message SMreports.SMSetAttTxt
		   (&loc_msg,"description",desc,SM_DYNAMIC_ATT | SM_SYST_ATT),
		   targetid = mac.objid,targetos = mac.osnum);
  as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);
  
  status = om$send(msg = message NDnode.NDdisplay(0, GRbd, &me->ModuleInfo),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  as$status(action = GOTO_VALUE,value = wrapup);
  
  /* Assign me->rep_id */
  me->rep_id = mac;

  *msg = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  
  if(mac.objid != NULL_OBJID)
    om$send(msg = message Root.delete(0),
	    targetid = mac.objid,targetos = mac.osnum);
  
  if(msgcode != 0)
   {
     ex$message( msgnumb = msgcode,buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
   }

  *msg = MSFAIL;
  return OM_S_SUCCESS;
}

/* -------------------- method SMmodif_rep ------------------------------  */
/* It modify the reports  macro with the new parameter saved in the form   */

method SMmodif_rep(IGRlong *msg; char *name; char *desc)
{
  IGRlong status,loc_msg;
  int i;
  int put_batch,wait_batch,cn_type,index;
  struct GRid as_parent;
  IGRboolean *Add_parent = NULL;
  
  put_batch = FALSE;
 
  /* First we delete all what must be deleted : */
  /* Parents who are not in the new list or whose VolMass have been modified */
  /* Second we add new parents or parents whose  VolMass have been modified   */

  Add_parent = _CALLOC(me->work_nb_parent, IGRboolean);
  if(!Add_parent) {printf("Not enough memory\n");goto wrapup;}

  /* Delete parent who doesn't belong to the new list */
  for(i=0; i<me->save_nb_parent; i++)
   {
     if(!find_parent_index(me->work_parent,me->work_nb_parent,
			   (char *)NULL,&me->save_parent[i].id,&index))
       {
#ifdef JJ_DEBUG
	printf("Must delete parent  %d \n",me->save_parent[i].id.objid);
#endif
	status = as$make_source(go_grid = me->save_parent[i].id,
				mod_env = &me->save_parent[i].env,
				as_grid = &as_parent);
	as$status(action = GOTO_VALUE, value = wrapup);

	status = om$send(msg = message SMreports.SMRptDelObj
			 (&loc_msg,&as_parent),
			 targetid = me->rep_id.objid,
			 targetos = me->rep_id.osnum);
	if(!(status & loc_msg & 1))
	 {printf("Echec remove parent %d %d \n",
		 me->save_parent[i].id.objid, me->save_parent[i].id.osnum);
	  goto wrapup;}
	put_batch = TRUE;
      }
   }

  /* Search new parents and parents whose VolMass have been modified */
  for(i = 0; i < me->work_nb_parent; i++)
   {
     if(find_parent_index(me->save_parent,me->save_nb_parent,
			  (char *)NULL,&me->work_parent[i].id,&index))
     {
       if(me->work_parent[i].type == SM_RP_RP) continue;
       if(me->work_parent[i].VolMass == me->save_parent[index].VolMass)
	 continue;

       /* VolMass is different : first disconnect object */
       status = as$make_source(go_grid = me->work_parent[i].id,
			       mod_env = &me->work_parent[i].env,
			       as_grid = &as_parent);
       as$status(action = GOTO_VALUE, value = wrapup);

       status = om$send(msg = message SMreports.SMRptDelObj
			(&loc_msg,&as_parent),
			targetid = me->rep_id.objid,
			targetos = me->rep_id.osnum);
       if(!(status & loc_msg & 1))
	{printf("Echec remove parent %d %d \n",
		me->save_parent[i].id.objid, me->save_parent[i].id.osnum);
	 goto wrapup;}
       Add_parent[i] = put_batch = TRUE; 
     }
     else   /* A completly new parent */
       Add_parent[i] = put_batch = TRUE; 
   }
     
  /* Clean all */
  if(put_batch)
   {
     status = om$send(msg = message SMreports.SMRptClean(&loc_msg),
		      targetid = me->rep_id.objid,
		      targetos = me->rep_id.osnum);
     as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);
   }

  /* Add All parent's who need */
  for(i = 0; i < me->work_nb_parent; i++)
   { 
     if(!Add_parent[i]) continue;

     status = as$make_source(go_grid = me->work_parent[i].id,
			     mod_env = &me->work_parent[i].env,
			     as_grid = &as_parent);
     as$status(action = GOTO_VALUE, value = wrapup);
     
     status = om$send(msg = message SMreports.SMRptAddObj
		      (&loc_msg,me->work_parent[i].VolMass,
		       me->work_parent[i].type,&as_parent),
		      targetid = me->rep_id.objid,
		      targetos = me->rep_id.osnum );
     if(!(status & loc_msg & 1))
      {
	printf("Error add parent %d,%d\n",as_parent.objid,as_parent.osnum);
	goto wrapup;
      }
     put_batch = TRUE;
   }
  
  if(name[0] != '\0' )
   {
     if(!SMChgElemName(&me->rep_id,name,&me->ModuleInfo))
       printf("Warning : can't change_name objid = %d\n",me->rep_id.objid);
   }

  status = om$send(msg = message SMreports.SMSetAttTxt
		   (&loc_msg,"description",desc,SM_DYNAMIC_ATT | SM_SYST_ATT),
		   targetid = me->rep_id.objid,targetos = me->rep_id.osnum);
  if(!(status & loc_msg & 1))
   {printf("Erreur set description of rep area %d %d\n",
	   me->rep_id.objid, me->rep_id.osnum); goto wrapup;}

  /* Put the compute_flag as 1 for the modify */
  status = om$send(msg = message SMreports.SMSetAttDbl
		   (&loc_msg,"compute_flag",1.0,SM_DYNAMIC_ATT | SM_SYST_ATT),
		   targetid = me->rep_id.objid,targetos = me->rep_id.osnum);

  if(put_batch)
   {
     cn_type    = ND_COMP; /* recompute the object */
     status = nd$wait_batch(type       = GR_GEOM_POSTED,
			    l_object   = &me->rep_id,
			    l_obj_info = &cn_type,
			    nb_obj     = 1);

     nd$mod_batch(request = ND_INQ,p_ret_mode = &wait_batch);
     
     if(wait_batch != ND_DEFER) /* Else Nothing to do */
       nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
   }

  _FREE(Add_parent) ;
  *msg = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  _FREE(Add_parent) ;
  *msg = MSFAIL;
  return OM_S_SUCCESS;
}


/* ------------------- method save_all --------------------------------------- */
/*               Method called when user selected save                         */
/* It found all parameter in the form and call the appropriate place or modify */

method save_all( long *sts )
{
  IGRlong msg,status;
  IGRlong msgcode;   
  char name_rep[256],desc[256];
  char my_msg[80];

  msgcode = 0;
  
  /* Retrieve rep area Name */
  name_rep[0] = '\0';
  FIg_get_text(me->forms[0].form_ptr,G_NAME,name_rep); 
  if(name_rep[0] == '\0')  
   { msgcode = SM_E_RpNeedName; goto wrapup; }
  else
   {
     if(!SMCanChgElemName(&me->rep_id,name_rep))
      { msgcode = SM_E_RpCanChgName; goto wrapup ; }
   }
 
  /* Retrieve rep description */
  FIg_get_text(me->forms[0].form_ptr,G_DESC,desc);
  
  /* save all attributes */
  if(me->work_nb_parent == 0)
   { msgcode = SM_E_RpNoParent; goto wrapup; }

  om$send(msg = message SMCmdRptObj.save_parent(sts),targetid = my_id);
  if(!(*sts & 1)) goto wrapup;
 
  switch(me->mytype)
   {
   case PLACE: 
     status = om$send( msg = message SMCmdRptObj.SMplace_rep
		      (&msg,name_rep,desc),
		      targetid = my_id);
     if (!(status & msg & 1))
      { ex$message(msgnumb = SM_E_RpBadPl); goto wrapup; }
     break;

   case MODIFY: 
     status = om$send( msg = message SMCmdRptObj.SMmodif_rep
		      (&msg,name_rep,desc),
		      targetid = my_id);
     if (!(status & msg & 1))
      { ex$message( msgnumb = SM_E_RpBadMd); goto wrapup; }
     break;
   }

  om$send(msg = message SMCmdRptObj.copy_param(sts ,WORK_TO_SAVE),
	  targetid = my_id);

  if(me->mytype == PLACE)
    SMVA_set_default_text(me->forms[0].form_ptr,2,
			  G_NAME,"",
			  G_DESC,"");
 
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
  
 wrapup:
  if(msgcode != 0)
   {
     ex$message( msgnumb = msgcode, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
   }
  
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;
}

/* -------------------- method reset_all ----------------------------------- */
/* This method copy the save list of parents to the work list of parent    */
/* It also place all parent in the list and clear the attribute list gadget */

method reset_all( long *sts )
{
  om$send(msg = message SMCmdRptObj.copy_param(sts,SAVE_TO_WORK),
	  targetid = my_id);
  
  place_parents_in_form(me->forms[0].form_ptr,
			me->save_nb_parent,me->save_parent);
 
  om$send(msg = message SMCmdRptObj.chg_state_button(sts,TRUE),
	  targetid = my_id);

  FIg_set_state_off(me->forms[0].form_ptr,G_ADD);
  FIg_set_state_off(me->forms[0].form_ptr,G_REMOVE);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}  

/* -------------------- method add_locate_parent -------------------- */
/*                   Add parent(s) located by the users               */
/* The last selected parents becomes the current parent               */

method add_locate_parent( long *sts )
{
  IGRlong status,msg;
  int    nb_obj,nb_add,i,parent_ind,row;
  struct GRobj_env *LocatedObjects;
  struct GRid parent_id;
  enum GRdpmode DisplayMode;
  struct GRmd_env parent_env;

  nb_add = 0;
  nb_obj = 0;
  
  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects, 
                 response = me->response, 
                 response_data = me->response_data);
  if(nb_obj == 0)
   {*sts = NO_OBJ_LOCATED; goto quit;}
  
  /* Insert the new(s) parent(s) at end of the existing one */ 
  FIfld_get_num_rows(me->forms[0].form_ptr,G_PARENT_LIST,&row);
  for(i = 0; i < nb_obj ; i++)
   {
     if(SMIsKindOf(&LocatedObjects[i].obj_id,OPP_SMreports_class_id) ||
        SMIsKindOf(&LocatedObjects[i].obj_id,OPP_EMSsolid_class_id) ||
	SMIsKindOf(&LocatedObjects[i].obj_id,OPP_EMSsurface_class_id))
      {
	parent_id   = LocatedObjects[i].obj_id; 
	parent_env  = LocatedObjects[i].mod_env;
      }
     else
       if(SMIsKindOf(&LocatedObjects[i].obj_id,OPP_ACpretend_class_id))
	{
	  if(!GetEnvFrObj(&LocatedObjects[i].obj_id, &parent_env,&parent_id))
	    continue;
	}
       else
	 continue;
       
  
     /* If parent already in the list for rep area , ignore it */
     if(find_parent_index(&me->work_parent[0],me->work_nb_parent,(char *)NULL,
			  &parent_id,&parent_ind))
       continue;
  
     /* Put parameters for this parent */
     if(om$dimension_of(varray = me->work_parent) < me->work_nb_parent + 1)
       om$vla_set_dimension(varray = me->work_parent,
			    size = me->work_nb_parent + INCR);

     me->work_parent[me->work_nb_parent].id  = parent_id;
     me->work_parent[me->work_nb_parent].env = parent_env;
     me->work_parent[me->work_nb_parent].VolMass = NO_DENSITY;

     /* gener the type of report */
     if(SMIsKindOf(&parent_id,OPP_SMreports_class_id))
       me->work_parent[me->work_nb_parent].type = SM_RP_RP;
     else if(SMIsKindOf(&parent_id,OPP_EMSsolid_class_id))
       me->work_parent[me->work_nb_parent].type = SM_RP_SL;
     else if(SMIsKindOf(&parent_id,OPP_EMSsurface_class_id))
       me->work_parent[me->work_nb_parent].type = SM_RP_SF;

     gener_default_name(&parent_id,&me->work_parent[0],me->work_nb_parent,
			me->work_parent[me->work_nb_parent].name);
     me->work_parent[me->work_nb_parent].VolMass = NO_DENSITY;
     
     /* Put the new parent in form */
     place_one_parent_in_form(me->forms[0].form_ptr,me->work_parent,
			      me->work_nb_parent,row,FALSE);
   
     DisplayMode = GRhhd;
     status = om$send(msg = message GRgraphics.GRdisplay
		      (&msg,&me->ModuleInfo.md_env.matrix_type,
		       me->ModuleInfo.md_env.matrix,&DisplayMode,
		       &me->ModuleInfo.md_id),
		      targetid = parent_id.objid,
		      targetos = parent_id.osnum);
     as$status(action = CONTINUE);

     me->work_nb_parent++;
     nb_add++;
     row++;
   }
  ASend_fence();
		 
  if(nb_add == 0) {*sts = NO_OBJ_LOCATED; goto quit;}
  
  /* IF before this locate no parent and now some */
  /* Change the selectable mode of GI_PARENT_LIST */
  if(me->work_nb_parent > 0 && (me->work_nb_parent == nb_add))
    change_mode_list_field(me->forms[0].form_ptr,FI_APPEND);
   
  if(me->work_nb_parent > 0)
    FIfld_set_max_num_rows(me->forms[0].form_ptr,G_PARENT_LIST,
			   me->work_nb_parent);

#ifdef JJ_DEBUG
     print_parent_attr(me->work_parent,me->work_nb_parent);
#endif

  *sts = MSSUCC;
 quit:
  return OM_S_SUCCESS;
}

/* ------------------- method select_delete_parent -------------------- */
/*         Method called when pushed on the deleted parent button       */
/* The state_list flag control if it's first time or second time          */
/* del button is pushed                                                  */

method select_delete_parent( long *sts )
{
  IGRlong status,msg;
  int parent_ind,sel_flag,num_rows,row;
  char my_msg[80];
  enum GRdpmode DisplayMode;

  FIfld_get_num_rows(me->forms[0].form_ptr,G_PARENT_LIST,&num_rows);
  if(num_rows <= 0)
   {
     ex$message( msgnumb = SM_E_RpNoParentToDel, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
     FIg_set_state_off(me->forms[0].form_ptr,G_REMOVE);
     goto quit;
   }

  /* We come from non delete state : ask the name of a parent */
  /* Deselect all selected parents and disable some gadget */
  if(me->state_list == NORMAL_STATE) 
   {
     SMSetSingleSelectMode(me->forms[0].form_ptr,G_PARENT_LIST,num_rows,3);
   
     me->state_list = DEL_STATE;
     /* Disable ADD_PARENT etc ... */
     om$send(msg = message SMCmdRptObj.chg_state_button(sts,FALSE),
	     targetid = my_id);
     ex$message( msgnumb = SM_I_RpSelParentDel, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
     goto quit;
   }

  /* We are in a delete state */
  sel_flag = find_index_select_parent
    (me->forms[0].form_ptr,me->work_parent,me->work_nb_parent,&parent_ind,&row);

  /* One parent is selected, delete it*/
  if(sel_flag) 
   {
     del_one_parent(me->work_parent,&me->work_nb_parent,parent_ind);
     FIfld_delete_rows(me->forms[0].form_ptr,G_PARENT_LIST,row,1);

     /* Enable ADD_PARENT etc ... */
     om$send(msg = message SMCmdRptObj.chg_state_button(sts,TRUE),
	     targetid = my_id);
     
     ex$message( msgnumb = SM_I_RpParentDel, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);

     DisplayMode = GRhe;
     status = om$send(msg = message GRgraphics.GRdisplay
		      (&msg,&me->ModuleInfo.md_env.matrix_type,
		       me->ModuleInfo.md_env.matrix,
		       &DisplayMode,&me->ModuleInfo.md_id),
		      targetid = me->work_parent[parent_ind].id.objid,
		      targetos = me->work_parent[parent_ind].id.osnum);
     as$status(action = CONTINUE);
   }

  SMStopSingleSelectMode(me->forms[0].form_ptr,G_PARENT_LIST,3,
			 FI_REVIEW,FI_REVIEW,FI_APPEND);
			

  me->state_list = NORMAL_STATE;
  if(me->work_nb_parent == 0)
    /* As no parent selected, nothing can be keyin in form GI_PARENT_LIST */
    change_mode_list_field(me->forms[0].form_ptr,FI_REVIEW);
  else
   {
     FIfld_get_num_rows(me->forms[0].form_ptr,G_PARENT_LIST,&num_rows);
     FIfld_set_max_num_rows(me->forms[0].form_ptr,G_PARENT_LIST,num_rows);
   }

 quit:
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}


/* -------------------- method copy_param ---------------------- */
/* Copy me->save_.. to me->work_ or vice versa depanding on flag */ 

method copy_param( long *sts ; int flag )
{
  int i;

  switch(flag)
   {
   case WORK_TO_SAVE:
     me->save_nb_parent = me->work_nb_parent;
     
     if(me->save_nb_parent > om$dimension_of( varray = me->save_parent))
       om$vla_set_dimension(varray = me->save_parent, size = me->save_nb_parent);
     for(i=0; i < me->save_nb_parent; i++)
       me->save_parent[i] = me->work_parent[i];
     break;
   
   case SAVE_TO_WORK:
     me->work_nb_parent = me->save_nb_parent ;

     if(me->work_nb_parent > om$dimension_of( varray = me->work_parent))
       om$vla_set_dimension(varray = me->work_parent, size = me->work_nb_parent);
     for(i=0; i < me->save_nb_parent; i++)
       me->work_parent[i] = me->save_parent[i];
     break;
   }
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

   
#ifdef JJ_DEBUG
print_parent_attr(Parent,nb_parent)
struct RepParent Parent[];
int nb_parent;
{
  int i;

  printf("Sauvegarde des attributs\n");
  printf("Nombre de parents %d \n",nb_parent);
  for(i=0;i<nb_parent;i++)
   {
     printf("\nParent Id %d,%d name %s type %d dens %g\n",i,
	    Parent[i].id.objid, Parent[i].id.osnum,Parent[i].name,
	    Parent[i].type, Parent[i].VolMass);
   }
  return 1;
}
#endif

end implementation SMCmdRptObj;







