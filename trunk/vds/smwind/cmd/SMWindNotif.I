/* $Id: SMWindNotif.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smwind/cmd / SMWindNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMWindNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
# Revision 1.2  1996/02/27  10:46:08  pinnacle
# Replaced: smwind/cmd/SMWindNotif.I for:  by rgade for vds.240
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
    File             SMWindNotif.I;
    Creation Date    September 92
    Auteur           Jean Jasinczuk (ISDC)
    
    Methods  and functions for SMCmdWind.S ;

    History
*/

class implementation SMCmdWind;

 #define DEBUG          1
 #define AS_DEBUG	1
/* #define JJ_DEBUG       1   */

#include "DItypedef.h"
#include "DIdef.h" 
#include "AS_status.h"
#include "vdsmacros.h"

from NDnode import ASreturn_go,NDdisplay,NDget_objects;
from NDmacro import ACreturn_foot;            
from SMwind import SMWindGetInfo,SMGetWindPlgs,SMGetAttTxt,ACmplace,
      SMSetAttTxt,SMWindAddPlg,SMWindRemPlg;            
from GRgraphics import GRdisplay,GRputname;


extern GRclassid OPP_SMwind_class_id;
extern GRclassid OPP_GRlinear_class_id;

/* --------------- static int set_att_db ---------------------------- */
/* Set the value of an attribute in the array of ACrg_coll            */
/* If attributes not already exists, create it                        */ 
/* Return 1 if found or create. Return 0 if cannot create             */

static int set_att_db(name,ACrg,nb_attr,f)
IGRchar          name[];   /* [I] Name of the attribute               */
struct ACrg_coll ACrg[];   /* [O] Array of ACrg_col where to modify   */
IGRint          *nb_attr;  /* [I/O] Number of element in the ACrg     */
IGRdouble        f;         /* [I] value of attribut (if double)       */
{
  int i;
  
  for(i = 0; i < *nb_attr; i++)
   {
     if(ACrg[i].name == NULL) continue;
     if(strcmp(name,ACrg[i].name) == 0)
      {
	switch(ACrg[i].desc.type)
	 {
	 case AC_ATTRIB_TEXT :
	   return 0;
	 case AC_ATTRIB_DOUBLE :
	   ACrg[i].desc.value.att_exp = f; 
	   break;
	 }
	return 1;
      }
   }

  /* Attribut not found : create it */
  if(SM_WIND_NB_MAX_ATTR > *nb_attr)
   {
     ACrg[*nb_attr].desc.type = AC_ATTRIB_DOUBLE;
     ACrg[*nb_attr].desc.value.att_exp = f;
     *nb_attr += 1;
     return 1;
   }
  return 0;
}

/* --------------- static int set_att_txt -------------------------- */
/* Set the value of an attribute in the array of ACrg_coll           */
/* If attributes not already exists, create it                       */ 
/* Return 1 if found or create. Return 0 if cannot create            */

static int set_att_txt(name,ACrg,nb_attr,str)
char             name[];  /* [I] Name of the attribute               */
struct ACrg_coll ACrg[];  /* [O] Array of ACrg_col where to modify   */
int             *nb_attr; /* [I/O] Number of element in the ACrg     */   
char             str[];   /* [I] value of attribut (if text)         */
{
  int i;
  
  for(i = 0; i < *nb_attr; i++)
   {
     if(ACrg[i].name == NULL) continue;
     if(strcmp(name,ACrg[i].name) == 0)
       switch(ACrg[i].desc.type)
	{
	case AC_ATTRIB_TEXT:
	  strcpy(ACrg[i].desc.value.att_txt,str);
	  return 1;
	case AC_ATTRIB_DOUBLE:
	  return 0;
	}
   }

  /* Attribut not found : create it */
  if(SM_WIND_NB_MAX_ATTR > *nb_attr)
   {
     ACrg[*nb_attr].desc.type = AC_ATTRIB_TEXT;
     strcpy(ACrg[*nb_attr].desc.value.att_txt,str);
     *nb_attr += 1;
     return 1;
   }
  return 0;
}

/* --------------- static int get_att_db ---------------------------  */
/* Retrieve the value of a double attribute in the array ACrg         */
/* Return 1 if found and 0 if not found                               */

static int get_att_db(name,ACrg,nb_attr,f)
IGRchar          name[];    /* [I] Name of the attribute              */
struct ACrg_coll ACrg[];    /* [I] Array of ACrg_col where to search  */
IGRint           nb_attr;   /* [I] Number of element in the ACrg      */
IGRdouble       *f;         /* [O] double return if AC_ATTRIB_DOUBLE  */
{
  int i;
  
  for(i = 0; i < nb_attr; i++)
   {
     if(ACrg[i].name == NULL) continue;
     if(strcmp(name,ACrg[i].name) == 0)
      {
	switch(ACrg[i].desc.type)
	 {
	 case AC_ATTRIB_TEXT :
	   return 0;
	 case AC_ATTRIB_DOUBLE :
	   if(f) *f= ACrg[i].desc.value.att_exp; 
	   break;
	 }
	return 1;
      }
   }
  return 0;
}

/* --------------- static int get_att_txt --------------------------- */
/* Retrieve the value of a text attribute in the array  ACrg          */
/* Return 1 if found and 0 if not found                               */

static int get_att_txt(name,ACrg,nb_attr,str)
char             name[];  /* [I] Name of the attribute               */
struct ACrg_coll ACrg[];  /* [I] Array of ACrg_col where to search   */
int              nb_attr; /* [I] Number of element in the ACrg       */
char             str[];   /* [O] string return if AC_ATTRIB_TEXT     */
{
  int i;
  
  for(i = 0; i < nb_attr; i++)
   {
     if(ACrg[i].name == NULL) continue;
     if(strcmp(name,ACrg[i].name) == 0)
      {
	switch(ACrg[i].desc.type)
	 {
	 case AC_ATTRIB_TEXT :
	   if(str) strcpy(str,ACrg[i].desc.value.att_txt);
	   break;
	 case AC_ATTRIB_DOUBLE :
	   return 0;
	 }
	return 1;
      }
   }
  return 0;
}

/* --------------- static void change_mode_list_field --------------- */
/* Change the state of GI_DESC.. to FI)_APPEND or FI_REVIEW           */
 
static void change_mode_list_field(form,mode)
Form form;    /* [I]                          */
int  mode;    /* [I] (FI_APPEND or FI_REVIEW) */
{
  int col;

  for(col = 1; col < NB_POLY_LIST_COLUMN; col++)
    FIfld_set_mode(form,G_POLY_LIST,col,mode);

  FIg_display(form,G_POLY_LIST);
}

/* ------------------- static int FIfldget_double ---------------------------- */
/* Fonction called to retrieve a permeability or struct coef in form           */
/* It also affect the corresponding field in Wind_Polygon struct               */


static int FIfldget_double(form,label,poly_ind,row,col,Poly,
			   name_attr,need_conv,msgcode)
Form                form;       /* [I] Pointer to form                         */
int                 label;      /* [I] label of the gadget to read             */
int                 poly_ind;   /* [I] index of working polygon                */
int                 row;        /* [I] row to read in polygon list             */
int                 col;        /* [I] Number of working column                */
struct Wind_Polygon Poly[];     /* [O] the table of polygon                    */
char               *name_attr;  /* [I] name of the attribut                    */
IGRboolean          need_conv;  /* [I] True: convertion from Ext to Intern data*/
long                msgcode;    /* [I] code of the error if failed             */
{
  char   my_msg[80];
  double val_db;
  char   value[50];
  
  if(!SMget_double(form,label,row,col,&val_db))
   {
     ex$message( msgnumb = msgcode , buff = my_msg);
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     get_att_db(name_attr,Poly[poly_ind].ACrg,Poly[poly_ind].nb_attr,&val_db);
     sprintf(value,"%g",val_db);
     FIfld_set_text(form,label,row,col,value,0);
     return 0;
   }

  if(need_conv)
    SMConvDistExtInt(val_db,&val_db,2);

  set_att_db(name_attr,Poly[poly_ind].ACrg,&Poly[poly_ind].nb_attr,val_db);
     
  return 1;
}


/* --------------- static int find_poly_index --------------------------- */
/* Find the index in the Poly table of the given polygon given name or id */
/* Return 0 if not found                                                  */

static int find_poly_index(Poly,nb_poly,name,id,poly_ind)
struct Wind_Polygon Poly[];    /* [I] the table of polygon                */
int                 nb_poly;   /* [I] Number of polygon                   */
char               *name;      /* [I] name of polygon (or NULL)           */
struct GRid        *id;        /* [I] Id of the polygon (or NULL)         */
int                *poly_ind;  /* [O] Index of the polygon in the table   */
{
  int i;

  if(nb_poly == 0) return 0;

  if(name != NULL)
    for(i=0; i<nb_poly; i++)
       if(strcmp(name,Poly[i].name) == 0)
	{
	  if(poly_ind) *poly_ind = i;
	  return 1;
	}

  if(id != NULL)
    for(i=0; i<nb_poly; i++)
      if(id->objid == Poly[i].id.objid &&
	 id->osnum == Poly[i].id.osnum)
       {
	 if(poly_ind) *poly_ind = i;
	 return 1;
       }

  return 0; /* Polygon not found if here */
}

/* -------------------- static int add_one_polygon --------------------------- */
/* Add one polygon to the list given the id and rg_collection id               */
/* It also affect the name to the polygon                                      */
/* It retrieves all attributes for this polygon if already_defined             */
/* It return the index where polygon have been add or -1 if problem            */

static int add_one_polygon(wind_id,Poly,nb_poly,id,env,already_defined)
struct GRid *wind_id;        /* [I] id of the wind area                        */
struct Wind_Polygon Poly[];  /* [O] Table of poly where the new will be added  */
int                *nb_poly; /* [O] Number of polygons                         */
struct GRid        *id;      /* [I] Id of the polygon to add                   */
struct GRmd_env    *env;     /* [I] Mod env of the polygon                     */
IGRboolean  already_defined; /* [I] If TRUE retrieve attribute else init struct*/
{
  char        name[256];
  int         i,poly_ind;
  IGRlong     status,msg;
  struct GRid poly_root;

  if(*nb_poly >= SM_MAX_ALLOW_PLG) return -1;

  /* Search the name of the new polygon : if not found gener default name */ 
  name[0] = '\0';
  vd$get_name(name = name, obj = id);
  if(name[0] == '\0')
   {
     for(i=0;i<SM_MAX_ALLOW_PLG;i++)
      {
	sprintf(name,"defined_%d",i);
	if(!find_poly_index(Poly,*nb_poly,name,(struct GRid *)NULL,&poly_ind))
	 {
	  strcpy(Poly[*nb_poly].name,name);
	  break;
	}
      }
   }
  else
    strcpy(Poly[*nb_poly].name,name);
   
  Poly[*nb_poly].id  = *id;
  Poly[*nb_poly].env = *env;
  if(!(already_defined))
   {
     Poly[*nb_poly].nb_attr  = 0;

     /* Fill ACrg collection for this polygons with default value */
     SMWindInitPlgAtt(&Poly[*nb_poly].nb_attr,Poly[*nb_poly].ACrg,*nb_poly);
   }
  else
   {
     /* Make source because SMWindGetInfo compare with assoc object */
     status = as$make_source(go_grid = *id, mod_env = env,as_grid = &poly_root);
     if(!(status & 1)) poly_root = *id;
			     
     status = om$send(msg = message SMwind.SMWindGetInfo
		      (&msg,NULL,&poly_root,
		       &Poly[*nb_poly].nb_attr,Poly[*nb_poly].ACrg),
		      senderid = NULL_OBJID,
		      targetid = wind_id->objid,
		      targetos = wind_id->osnum);
     if(!(status & msg & 1))
       {printf("Error get attributes for polygon objid %d osnum %d wind_id %d\n",
	       id->objid,id->osnum,wind_id->objid); return -1; }
   }

  (*nb_poly) += 1;
  return *nb_poly - 1;
}
 
/* --------------- static int del_one_polygon ----------------------------- */
/*     Delete one polygon of the table given by is index                    */

static int del_one_polygon(Poly,nb_poly,poly_ind)				 
struct Wind_Polygon Poly[];   /* [O]   Table of polygon where to delete    */
int                *nb_poly;  /* [I/O] Number of polygon                   */
int                 poly_ind; /* [I]   Indice of the polygon to delete     */
{
  if(*nb_poly <= 0) {printf("No polygon defined\n");return 0;}

  if(poly_ind + 1 < *nb_poly)
   {
     memcpy(&Poly[poly_ind],&Poly[poly_ind+1],
	    (*nb_poly - poly_ind - 1) * sizeof(struct Wind_Polygon));
   }
  *nb_poly = *nb_poly - 1;
  return 1;
}


/* --------------- static void place_one_polygon_in_form --------------- */
/* Place attribute of a polygon from buffer to G_POLY_LIST in form       */

static void place_one_polygon_in_form(form,Poly,ind,row,select)
Form                form;    /* [I]                                      */
struct Wind_Polygon Poly[];  /* [I] Buffer of all Polygon                */
int                 ind;     /* [I] Indice of the poly 			 */
int                 row;     /* [I] Row number in the gadget 		 */
IGRboolean          select;  /* [I] IF TRUE place polygon as select one  */
{
  char      desc[ATTR_TXT],tmp[ATTR_TXT];
  IGRdouble s_coef,c_coef,p_type,p_no;

  get_att_txt("desc",Poly[ind].ACrg,Poly[ind].nb_attr,desc);
  FIfld_set_text(form,G_POLY_LIST,row,GI_DESC,desc,select);
  
  get_att_db("s_coef",Poly[ind].ACrg,Poly[ind].nb_attr,&s_coef);
  sprintf(tmp,"%-7.3g",s_coef);
  FIfld_set_text(form,G_POLY_LIST,row,GI_SHAPE_COEF,tmp,select);
  
  get_att_db("c_coord",Poly[ind].ACrg,Poly[ind].nb_attr,&c_coef);
  SMConvDistIntExt(c_coef,&c_coef,2);
  sprintf(tmp,"%-7.3g",c_coef);
  FIfld_set_text(form,G_POLY_LIST,row,GI_CONST_COORD,tmp,select);

  get_att_db("p_type",Poly[ind].ACrg,Poly[ind].nb_attr,&p_type);
  switch((int)p_type) {
  case 1: strcpy(tmp,"y"); break;
  case 2: strcpy(tmp,"z"); break;
  }
  FIfld_set_text(form,G_POLY_LIST,row,GI_VZ,tmp,select);
  
  get_att_db("p_no",Poly[ind].ACrg,Poly[ind].nb_attr,&p_no);
  sprintf(tmp,"%d",(int)p_no);
  FIfld_set_text(form,G_POLY_LIST,row,GI_NO,tmp,select);
  
  /* Put the name of the polygon */
  FIfld_set_text(form,G_POLY_LIST,row,GI_NAME,Poly[ind].name,select);
}  


/* --------------- static void place_polygons_in_form --------------- */
/* Place the selected polygons in the list of polygons                */
/* There is no default selected polygon                               */

static void place_polygons_in_form(form,nb_poly,Poly)
Form                 form;     /* [I]                                 */
int                  nb_poly;  /* [I] Number of polygons in buffer    */
struct Wind_Polygon *Poly;     /* [I] Buffer contanining the polygons */
{
  int i;
  int row = 0;
  
  row = 0;
  for(i = 0; i < nb_poly; i++)
    place_one_polygon_in_form(form,Poly,i,i,FALSE);

  FIfld_set_num_rows(form,G_POLY_LIST,row);
  FIfld_set_max_num_rows(form,G_POLY_LIST,row); 
  if(row == 0)
    /* As no polygon selected, nothing can be keyin in form GI_POLY_LIST */
    change_mode_list_field(form,FI_REVIEW);
  else
    change_mode_list_field(form,FI_APPEND);
}	


/* --------------- static int find_index_select_polygon --------------------- */
/* Retrieve the index of the selected polygon. Return 0 if no polygon selected */

static int find_index_select_polygon(form,Poly,nb_poly,poly_ind,row)
Form  form;     /* [I]                                                         */
struct Wind_Polygon Poly[];  /* [I] Table of polygon                           */
int  nb_poly;   /* [I] Number of polygon                                       */
int *poly_ind;  /* [O] Index in the Wind_Polygon of the selected poly (or NULL)*/
int *row;       /* [O] Row in the form list of the selected poly (or NULL)     */
{
  int  i,num_rows,sel_flag,r_pos;
  char name[DI_PATH_MAX];

  sel_flag = 0;
  FIfld_get_num_rows(form,G_POLY_LIST,&num_rows);
  for(i = 0; i < num_rows; i++)
   {
     FIfld_get_select(form,G_POLY_LIST,i,0,&sel_flag);
     if(sel_flag) break;
   }
  if(!sel_flag) return 0; /* No polygon selected */

  FIfld_get_text(form,G_POLY_LIST,i,0,DI_PATH_MAX,
		 (unsigned char*)name,&sel_flag,&r_pos);
  if(!find_poly_index(Poly,nb_poly,name,(struct GRid *)NULL,poly_ind))
   {printf("Polygon not found\n");return 0;}

  if(row) *row = i;
  return 1;
}

/* --------------- static void select_list_poly ----------------------- */
/* One polygon is selected in the list of polygons :                    */
/* Two possible actions are possible depanding if user select polygon   */
/* for remove or for display attribut                                   */

static void select_list_poly(form,Poly,nb_poly,state_del)
Form       form;             /* [I]                                     */
struct Wind_Polygon Poly[];  /* [I] the table of polygon                */
int        nb_poly;          /* [I] Number of polygon                   */
IGRboolean *state_del;       /* [I] control delete state or not         */
{ 
  char my_msg[80];
  int sel_flag,poly_ind;

  sel_flag = find_index_select_polygon(form,Poly,nb_poly,&poly_ind,(int *)NULL);
  
  if(*state_del) /* User select for remove */
   {
     if(sel_flag)  /* One row is selected : user must valid with del button*/
      {
	ex$message( msgnumb = SM_I_WdValPolyDel, buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
      }
     else /* First select row */
      {
	ex$message( msgnumb = SM_I_WdSelPolyDel, buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
      }
     return;
   }
} 


/* -------------------- static int save_attrib -------------------- */
/*    This function save the attributes of all polygons             */
/* The poly list is in the work_poly. It copy it in the save_poly   */

static int save_attrib(form,work_poly,work_nb_poly,save_poly,save_nb_poly)
Form                 form;          /* [I] */
struct Wind_Polygon *work_poly;     /* [I] */
int                  work_nb_poly;  /* [I] */
struct Wind_Polygon *save_poly;     /* [O] */
int                 *save_nb_poly;  /* [O] */
{
  int    ind;
  int    row,num_rows,sel_flag,r_pos;
  char   name[80],tmp[80];
  double val_db;

  FIfld_get_num_rows(form,G_POLY_LIST,&num_rows);
  
  for(row=0; row < num_rows; row++)
   {
     /* Get name of polygon and retrieve is index in the save list */
     name[0] = '\0'; 
     FIfld_get_text(form,G_POLY_LIST,row,GI_NAME,80,
		    (unsigned char*)name,&sel_flag,&r_pos);
     if(name[0] == '\0' ||
	!find_poly_index(work_poly,work_nb_poly,name,(struct GRid *)NULL,&ind))
      {printf("Can't find index of polygon %s\n",name); return 0;}
    
     /* Get description of polygon */
     tmp[0] = '\0';
     FIfld_get_text(form,G_POLY_LIST,row,GI_DESC,80,
		    (unsigned char*)tmp,&sel_flag,&r_pos);
     tmp[79] = '\0';
     set_att_txt("desc",work_poly[ind].ACrg,&work_poly[ind].nb_attr,tmp);
     
     /* Get Vz */
     tmp[0] = '\0'; 
     FIfld_get_text(form,G_POLY_LIST,row,GI_VZ,80,
		    (unsigned char*)tmp,&sel_flag,&r_pos);
     tmp[79] = '\0';
     if(strcmp(tmp,"y") == 0) val_db = 1.0;
     else
       if(strcmp(tmp,"z") == 0) val_db = 2.0;
       else
	{
	  ex$message(msgnumb = SM_E_WdBadVz,buff = tmp);
	  FIg_set_text(form,FI_MSG_FIELD,tmp);
	  return 0;
	}
     set_att_db("p_type",work_poly[ind].ACrg,&work_poly[ind].nb_attr,val_db);
     
     /* Get Shape coef */
     if(!FIfldget_double(form,G_POLY_LIST,ind,row,GI_SHAPE_COEF,
			 work_poly,"s_coef",FALSE,(long)SM_E_WdBadShp))
       return 0;

    /* Get Const coord */
     if(!FIfldget_double(form,G_POLY_LIST,ind,row,GI_CONST_COORD,work_poly,
			 "c_coord",TRUE,(long)SM_E_WdBadCoord))
       return 0;
     
     /* Get No */
     if(!FIfldget_double(form,G_POLY_LIST,ind,row,GI_NO,work_poly,
			 "p_no",FALSE,(long)SM_E_WdBadNo))
       return 0;
   }

  memcpy(save_poly,work_poly,SM_MAX_ALLOW_PLG * sizeof(struct Wind_Polygon));
  *save_nb_poly = work_nb_poly ;
     
#ifdef JJ_DEBUG
     print_poly_attr(save_poly,*save_nb_poly);
#endif
  
  return 1;
}


/* ------------------- method form_notification -------------------- */

method form_notification (int form_label; int gadget_label ; double value ;
			  char * form_ptr)
{
  int  status = OM_S_SUCCESS;
  long sts;
  
  if ( form_ptr == NULL ) return( OM_E_INVARG ); 
  
  FIg_set_text(form_ptr,FI_MSG_FIELD, "");
  
  switch( gadget_label )
   {
   case FI_ACCEPT :
     om$send(msg = message SMCmdWind.save_all(&sts),
	     targetid = my_id);
     
     FIg_set_state_off(form_ptr,FI_ACCEPT);
     if(sts == OM_S_SUCCESS)
       _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_EXECUTE :
     om$send(msg = message SMCmdWind.save_all(&sts),
	     targetid = my_id);
     
     FIg_set_state_off(form_ptr,FI_EXECUTE);
     if(sts == OM_S_SUCCESS)
       _put_response(resp = RELOCATE_OBJ);
     goto quit;
     
   case FI_CANCEL :
     _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_RESET :
     om$send(msg = message SMCmdWind.reset_all(&sts),
	     targetid = my_id);
     goto quit;
     
   case G_NAME:
   case G_DESC:	
     break;
     
   case G_POLY_LIST:
     select_list_poly(me->forms[0].form_ptr,
		      me->work_poly,me->work_nb_poly,&me->state_del);
     break;
     
     
   case G_ADD:
     _put_response( resp = LOCATE_POLY ); 
     goto quit;
     
   case G_REMOVE:
     om$send(msg = message SMCmdWind.select_delete_polygon(&sts),
	     targetid = my_id);
     if(!(sts & 1)){printf("Erreur delete poly\n");}
     goto quit;
   }
  
 quit: return OM_S_SUCCESS;
}

/* -------------- method init_form_new_wind ------------------  */
/*     This method initialize the form for a new compartment    */

method init_form_new_wind( long *sts )
{
  /* No polygons */
  me->save_nb_poly = me->work_nb_poly = 0;

  /* Init the default collection for the wind area */
  me->NbWindAtt = SM_WIND_NB_MAX_ATTR;
  SMWindDynColl(me->WindACrg,&me->NbWindAtt);
  
  /* Init value and default value for wind area */
  SMVA_set_default_text(me->forms[0].form_ptr,2,
			G_NAME,"",
			G_DESC,"");

 
  /* As no polygon selected, nothing can be keyin in form GI_POLY_LIST */
  change_mode_list_field(me->forms[0].form_ptr,FI_REVIEW);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* ------------------- method control_polygon ---------------------- */
/*         Method call after locate of a wind area polygon           */
/* It put all attributes in the form and retrieve all the templates  */

method control_wind( long *sts )
{
  IGRlong             msg,status;
  char                desc[ATTR_TXT],name[DI_PATH_MAX];
  struct GRid         poly[SM_MAX_ALLOW_PLG];
  struct GRmdenv_info poly_env_info[SM_MAX_ALLOW_PLG];
  int                 i,poly_in_list;
  IGRshort            type;
  struct GRmd_env     tmp_env;

  int nb_roots;
 
  /* Get the list of polygons */
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,poly,SM_MAX_ALLOW_PLG,NULL,
		    2,OM_K_MAXINT,&nb_roots),
		   targetid = me->wind_id.objid,
		   targetos = me->wind_id.osnum);
  as$status(action = RET_STATUS);

  me->save_nb_poly = nb_roots - 2;
  for(i=0; i < me->save_nb_poly ; i++)
   {
     status = om$send(msg = message NDmacro.ACreturn_foot
		      (&msg,"",&poly[i],
		       &poly_env_info[i].matrix_type,poly_env_info[i].matrix),
		      targetid = poly[i].objid,
		      targetos = poly[i].osnum);
     as$status(action = RET_STATUS);
   }

#if 0    /* It would be nice if it can be use */
  int tt_number;
  status = om$send( msg = message SMwind.SMGetWindPlgs
		   (&msg,SM_MAX_ALLOW_PLG,&me->save_nb_poly,&tt_number,
		    poly,poly_env_info),
		   targetid = me->wind_id.objid,
		   targetos = me->wind_id.osnum);
  
  if(!(status & msg & 1) || tt_number != me->save_nb_poly)
   {printf("Error get polygons for wind area id %d \n",me->wind_id.objid);
    goto wrapup;}
#endif

  poly_in_list = 0;
  for(i = 0 ; i < me->save_nb_poly; i++)
   {
     tmp_env.md_env = poly_env_info[i];
     tmp_env.md_id.osnum  = poly[i].osnum;
     ex$get_modid(mod_osnum = tmp_env.md_id.osnum,
		  mod_id = &tmp_env.md_id.objid);
     add_one_polygon(&me->wind_id,me->save_poly,&poly_in_list,
		     &poly[i],&tmp_env,TRUE);
   }


   /* Init the default collection for the wind area */
  me->NbWindAtt = SM_WIND_NB_MAX_ATTR;
  SMWindDynColl(me->WindACrg,&me->NbWindAtt);

  /* Get name and description  of the wind area polygon*/
  status = om$send(msg = message SMwind.SMGetAttTxt
		   (&msg,"description",desc,&type),
		   targetid = me->wind_id.objid,
		   targetos = me->wind_id.osnum);
  if(!(status & msg & 1))
   {printf("Erreur get description for object %d %d\n",
	   me->wind_id.objid,me->wind_id.osnum); goto wrapup;}
  
  /* Get name of wind area polygon */
  SMGetSplitName(&me->wind_id,name);
  
  SMVA_set_default_text(me->forms[0].form_ptr,2,
			G_NAME,name,
			G_DESC,desc);

  /* Put all polygon attribut in the form */
  for(i=0; i<me->save_nb_poly; i++)
    place_one_polygon_in_form(me->forms[0].form_ptr,me->save_poly,i,i,FALSE);

  /* Copy all information about polygon in the work poly structure */
  memcpy(me->work_poly,me->save_poly,
	 SM_MAX_ALLOW_PLG * sizeof(struct Wind_Polygon));
  me->work_nb_poly = me->save_nb_poly;

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;

 wrapup:
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;

} 

/* -------------------- method SMplace_wind ------------------------- */
/*           Construct and place the wind area macro                  */
/* It also need the me->save_poly struct for polygons parameters      */
/* It affects the me->wind_id.                                        */

method SMplace_wind(IGRlong *msg; char *name) 
{
  IGRlong     status,loc_msg;
  struct GRid mac,as_poly;
  struct GRid TEMP[2]; /* Template of the wind area */
  IGRlong     msgcode;
  int         i,cn_type;
  char        desc[ATTR_TXT],my_msg[80];
 
  msgcode   = 0;
  mac.objid = NULL_OBJID;
 
  /* Create and init the collection */
  if(SMWindInitCol(&TEMP[0], &me->ModuleInfo, 0) == 0)
   { printf("Error SMWindInitCol\n"); goto wrapup; }
  
 
  /* Get the active CS , it's template 1 */
   status = SMGetDefCs(TRUE,                   /* Take EMS cs by default */
		      (struct GRid *)NULL,     /* Connected with glob not need */
		      (IGRshort *)NULL,        /* State not used */ 
		      (struct GRid *)NULL,     /* Graphic object not important */
		      &TEMP[1],                /* Associative cs is template 1 */
		      (struct GRmd_env *)NULL, /* No mod env */
		      (IGRboolean *)NULL);     /* No flag needed */
 
  if(!status || TEMP[1].objid == NULL_OBJID)
   { msgcode = SM_E_WdNoActCs; goto wrapup;}

  /* Construct the wind area */
  mac.osnum = me->ModuleInfo.md_id.osnum;
  status = om$construct(classid = OPP_SMwind_class_id,
			osnum   = mac.osnum,
			p_objid = &mac.objid );
  if(!(status & 1))
   {printf("erreur creating macro\n"); goto wrapup; }

  status = om$send( msg = message SMwind.ACmplace
		   ((int *)&loc_msg, AChdr_nodisplay | AChdr_nocompute,
		    0, "SMwind", 2, TEMP, &me->ModuleInfo),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  if(!(status & loc_msg & 1)) goto wrapup;
 
  for(i=0; i < me->save_nb_poly; i++)
   {
     as$make_source(go_grid = me->save_poly[i].id,
		    mod_env = &me->save_poly[i].env,
		    as_grid = &as_poly);
     status = om$send(msg = message SMwind.SMWindAddPlg
		      (&loc_msg,&as_poly,
		       me->save_poly[i].nb_attr,
		       me->save_poly[i].ACrg),
		      targetid = mac.objid,
		      targetos = mac.osnum );
     if(!(status & loc_msg & 1))
      {
	printf("Error add polygon objid: %d\n",as_poly.objid);
	goto wrapup;
      }
   }

  if(name[0] != '\0')
   {
     status = om$send(msg = message GRgraphics.GRputname(&loc_msg,name),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     if(!(status & loc_msg & 1))
       printf("Warning can't set name of object %d %d\n",mac.objid,mac.osnum);
   }

  get_att_txt("description",me->WindACrg,me->NbWindAtt,desc);
  status = om$send(msg = message SMwind.SMSetAttTxt
		   (&loc_msg,"description",desc,SM_DYNAMIC_ATT),
		   targetid = mac.objid,targetos = mac.osnum);
  if(!(status & loc_msg & 1))
   {printf("Error set description of wind area %d %d\n",
	   mac.objid,mac.osnum); goto wrapup;}

  cn_type    = ND_COMP; /* recompute the object */
  status = nd$wait_batch(type       = GR_GEOM_POSTED,
			 l_object   = &mac,
			 l_obj_info = &cn_type,
			 nb_obj     = 1);
 
  status = om$send(msg = message NDnode.NDdisplay(0, GRbd, &me->ModuleInfo),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  if(!(status & 1))
   {printf("Error displaying objid = %d osnum = %d\n",mac.objid,mac.osnum);
    goto wrapup;}
 
  /* Assign me->wind_id */
  me->wind_id = mac;

  *msg = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  
  if(mac.objid != NULL_OBJID)
   {
     om$send(msg = message Root.delete(0),
	     targetid = mac.objid,targetos = mac.osnum);
   }  

  if(msgcode != 0)
   {
     ex$message( msgnumb = msgcode,buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
   }

  *msg = MSFAIL;
  return OM_S_SUCCESS;
}

/* -------------------- method SMmodif_wind ------------------------------  */
/* It modify the wind area macro with the new parameter saved in the form   */

method SMmodif_wind(IGRlong *msg;char *name)
{
  IGRlong         status,loc_msg;
  int             old_nb_poly,nb_exist,i,j;
  struct GRid     old_poly[SM_MAX_ALLOW_PLG];
  struct GRmd_env old_env[SM_MAX_ALLOW_PLG];
  int             put_batch,wait_batch,cn_type,index;
  IGRchar         desc[ATTR_TXT];
  struct GRid     as_poly;
  

  put_batch = FALSE;

 
  /* Get the list of polygons */

  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,old_poly,SM_MAX_ALLOW_PLG,NULL,
		    2,OM_K_MAXINT,&old_nb_poly),
		   targetid = me->wind_id.objid,
		   targetos = me->wind_id.osnum);
  as$status(action = RET_STATUS);
  
  old_nb_poly = old_nb_poly - 2; /* First two roots are not poly */
  for(i=0; i < old_nb_poly ; i++)
   {
     status = om$send(msg = message NDmacro.ACreturn_foot
		      (&loc_msg,"",&old_poly[i],
		       &old_env[i].md_env.matrix_type,
		       old_env[i].md_env.matrix),
		      targetid = old_poly[i].objid,
		      targetos = old_poly[i].osnum);
     as$status(action = RET_STATUS);
     old_env[i].md_id.osnum = old_poly[i].osnum;
     ex$get_modid(mod_osnum = old_env[i].md_id.osnum,
		  mod_id = &old_env[i].md_id.objid);
   }

#if 0  /* It would be nice if it work's */
  int tt_number;

  status = om$send( msg = message SMwind.SMGetWindPlgs
		   (&loc_msg,SM_MAX_ALLOW_PLG,&old_nb_poly,&tt_number,
		    old_poly,NULL),
		   targetid = me->wind_id.objid,
		   targetos = me->wind_id.osnum);
  
  if(!(status & loc_msg & 1) || tt_number != old_nb_poly)
   {printf("Error get polygons for wind area id %d \n",me->wind_id.objid);
    goto wrapup;}
#endif 
   
  /* Delete polygon who doesn't belong to the new list */
  for(i=0; i<old_nb_poly; i++)
   {
     if(!find_poly_index(me->save_poly,me->save_nb_poly,
			(char *)NULL,&old_poly[i],&index))
       {
#ifdef JJ_DEBUG
	printf("Must delete poly  %d \n",old_poly[i].objid);
#endif
	as$make_source(go_grid = old_poly[i],
		       mod_env = &old_env[i],
		       as_grid = &as_poly);
	status = om$send(msg = message SMwind.SMWindRemPlg
			 (&loc_msg,&as_poly,&nb_exist),
			 targetid = me->wind_id.objid,
			 targetos = me->wind_id.osnum);
	if(!(status & loc_msg & 1))
	 {printf("Echec remove polygon %d %d \n",
		 old_poly[i].objid,old_poly[i].osnum);goto wrapup;}
	put_batch = TRUE;
      }
   }
     
  /* Search if polygon to add (to know if we must put in batch) */
  for(i = 0; i < me->save_nb_poly; i++)
   {
     int find = FALSE;

     for(j=0; j < old_nb_poly; j++)
       if(me->save_poly[i].id.objid == old_poly[j].objid &&
	  me->save_poly[i].id.osnum == old_poly[j].osnum)
	 {find = TRUE; break;}

     if(!find) {put_batch = TRUE; break;}
   }

  /* Replace globally the parameters for polygon */
  for(i=0 ; i < me->save_nb_poly; i++)
   {
     as$make_source(go_grid = me->save_poly[i].id,
		    mod_env = &me->save_poly[i].env,
		    as_grid = &as_poly); 
     status = om$send(msg = message SMwind.SMWindAddPlg
		      (&loc_msg,
		       &as_poly,
		       me->save_poly[i].nb_attr,me->save_poly[i].ACrg),
		      targetid = me->wind_id.objid,
		      targetos = me->wind_id.osnum);
     if(!(status & loc_msg & 1))
      {  printf("Error add polygon objid: %d\n",as_poly.objid);
	 goto wrapup;}
   }
  
  if(name[0] != '\0' )
   {
     if(!SMChgElemName(&me->wind_id,name,&me->ModuleInfo))
       printf("Warning : can't change_name objid = %d\n",me->wind_id.objid);
   }

  get_att_txt("description",me->WindACrg,me->NbWindAtt,desc);
  status = om$send(msg = message SMwind.SMSetAttTxt
		   (&loc_msg,"description",desc,SM_DYNAMIC_ATT),
		   targetid = me->wind_id.objid,targetos = me->wind_id.osnum);
  if(!(status & loc_msg & 1))
   {printf("Erreur set description of wind area %d %d\n",
	   me->wind_id.objid, me->wind_id.osnum); goto wrapup;}


  if(put_batch)
   {
     cn_type    = 1; /* recompute the object */
     status = nd$wait_batch(type       = GR_GEOM_POSTED,
			    l_object   = &me->wind_id,
			    l_obj_info = &cn_type,
			    nb_obj     = 1);

     nd$mod_batch(request = ND_INQ,p_ret_mode = &wait_batch);
     
     if(wait_batch != ND_DEFER) /* Else Nothing to do */
       nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
   }

  
  *msg = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  *msg = MSFAIL;
  return OM_S_SUCCESS;
}


/* ------------------- method save_all --------------------------------------- */
/*               Method called when user selected save                         */
/* It found all parameter in the form and call the appropriate place or modify */

method save_all( long *sts )
{
  IGRlong msg,status;
  IGRlong msgcode = 0;   
  char    name_wind[256],desc[256],my_msg[80];
  int     sel,pos;

  /* Retrieve wind area Name */
  name_wind[0] = '\0';
  FIfld_get_text(me->forms[0].form_ptr,G_NAME,0,0,255,
		 (unsigned char*)name_wind,&sel,&pos);
  name_wind[255] = '\0';
  if(name_wind[0] == '\0')  
   { msgcode = SM_E_WdPolyName; goto wrapup; }
  else
   {
     if(!SMCanChgElemName(&me->wind_id,name_wind))
      { msgcode = SM_E_WdNamEx; goto wrapup ; }
   }
 
  /* Retrieve wind area description */
  desc[0]  = '\0';
  FIfld_get_text(me->forms[0].form_ptr,G_DESC,0,0,255,
		 (unsigned char*)desc,&sel,&pos);
  desc[255] = '\0';
  set_att_txt("description",me->WindACrg,&me->NbWindAtt,desc);
  
  /* save all attributes */
  if(!save_attrib(me->forms[0].form_ptr,me->work_poly,me->work_nb_poly,
		  me->save_poly,&me->save_nb_poly))
    goto wrapup;

  if(me->save_nb_poly == 0)
   { msgcode = SM_E_WdNoPoly; goto wrapup; }
  
  switch(me->mytype)
   {
   case PLACE: 
     status = om$send( msg = message SMCmdWind.SMplace_wind(&msg,name_wind),
		      targetid = my_id);
     if (!(status & msg & 1))
      { ex$message(msgnumb = SM_E_WdBadPl); goto wrapup; }
     break;

   case MODIFY: 
     status = om$send( msg = message SMCmdWind.SMmodif_wind(&msg,name_wind),
		      targetid = my_id);
     if (!(status & msg & 1))
      { ex$message( msgnumb = SM_E_WdBadMd); goto wrapup; }
     break;
   }

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
/* This method copy the save list of polygons to the work list of polygon    */
/* It also place all polygon in the list and clear the attribute list gadget */

method reset_all( long *sts )
{
  memcpy(me->work_poly,me->save_poly,
	 SM_MAX_ALLOW_PLG * sizeof(struct Wind_Polygon));
  me->work_nb_poly = me->save_nb_poly; 
  
  place_polygons_in_form(me->forms[0].form_ptr,me->save_nb_poly,me->save_poly);
 
  om$send(msg = message SMCmdWind.chg_state_button(sts,TRUE),
	  targetid = my_id);

  FIg_set_state_off(me->forms[0].form_ptr,G_ADD);
  FIg_set_state_off(me->forms[0].form_ptr,G_REMOVE);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}  

/* -------------------- method add_locate_polygon -------------------- */
/*                   Add polygon(s) located by the users               */
/* The last selected polygons becomes the current polygon              */

method add_locate_polygon( long *sts )
{
  IGRlong          status,msg;
  int              nb_obj,nb_add,i,poly_ind,row;
  struct GRobj_env *LocatedObjects;
  struct GRid      poly_id;
  enum   GRdpmode  DisplayMode;
  struct GRmd_env  poly_env;

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
  
  /* Insert the new(s) polygon(s) at end of the existing one */ 
  FIfld_get_num_rows(me->forms[0].form_ptr,G_POLY_LIST,&row);
  for(i = 0; i < nb_obj ; i++)
   {
     /* It can be a pretend */
     status = om$send(msg = message NDmacro.ACreturn_foot
		      (&msg,"",&poly_id,
		       &poly_env.md_env.matrix_type,poly_env.md_env.matrix),
		      targetid = LocatedObjects[i].obj_id.objid,
		      targetos = LocatedObjects[i].obj_id.osnum);
     if(status & msg & 1)
      {
	poly_env.md_id.osnum   = poly_id.osnum;
	ex$get_modid(mod_osnum = poly_env.md_id.osnum,
		     mod_id = &poly_env.md_id.objid);
      }
     else
      {
	poly_id  = LocatedObjects[i].obj_id; 
	poly_env = LocatedObjects[i].mod_env;
      }

     /* Be wise with locate by name */
     if(!SMIsKindOf(&poly_id,OPP_GRlinear_class_id)) 
       continue;
     
     /* If polygon already in the list for wind area , ignore it */
     if(find_poly_index(me->work_poly,me->work_nb_poly,(char *)NULL,
		       &poly_id,&poly_ind))
       continue;

     poly_ind = add_one_polygon(&me->wind_id,me->work_poly,&me->work_nb_poly,
				&poly_id,&poly_env,FALSE);
     if(poly_ind == -1)
      { *sts = TOO_MUCH_POLY; ASend_fence(); goto quit;}
     /* Initialises the fields with null -TR#179600692 -Ravi */
     
     FIfld_set_text(me->forms[0].form_ptr,G_POLY_LIST,row,GI_NAME, "",FALSE);
     FIfld_set_text(me->forms[0].form_ptr,G_POLY_LIST,row,GI_DESC, "",FALSE);
     FIfld_set_text(me->forms[0].form_ptr,G_POLY_LIST,row,GI_VZ, "",FALSE);
     FIfld_set_text(me->forms[0].form_ptr,G_POLY_LIST,row,
						GI_SHAPE_COEF, "",FALSE);
     FIfld_set_text(me->forms[0].form_ptr,G_POLY_LIST,row,
						GI_CONST_COORD, "",FALSE);
     FIfld_set_text(me->forms[0].form_ptr,G_POLY_LIST,row,GI_NO, "",FALSE);

     /* Put the name of the polygon */
     FIfld_set_text(me->forms[0].form_ptr,G_POLY_LIST,row,GI_NAME,
		    me->work_poly[poly_ind].name,FALSE);
           
     
     DisplayMode = GRhhd;
     status = om$send(msg = message GRgraphics.GRdisplay
		      (&msg,&me->ModuleInfo.md_env.matrix_type,
		       me->ModuleInfo.md_env.matrix,&DisplayMode,
		       &me->ModuleInfo.md_id),
		      targetid = me->work_poly[poly_ind].id.objid,
		      targetos = me->work_poly[poly_ind].id.osnum);
     as$status(action = CONTINUE);

     nb_add++;
     row++;
   }
  ASend_fence();
		 
  if(nb_add == 0) {*sts = NO_OBJ_LOCATED; goto quit;}
  
  /* IF before this locate no polygon and now some */
  /* Change the selectable mode of GI_POLY_LIST */
  if(me->work_nb_poly > 0 && (me->work_nb_poly - nb_add) == 0)
    change_mode_list_field(me->forms[0].form_ptr,FI_APPEND);
   
  FIfld_set_max_num_rows(me->forms[0].form_ptr,G_POLY_LIST, me->work_nb_poly);
  
  *sts = MSSUCC;
 quit:
  return OM_S_SUCCESS;
}

/* ------------------- method select_delete_polygon -------------------- */
/*         Method called when pushed on the deleted polygon button       */
/* The state_del flag control if it's first time or second time          */
/* del button is pushed                                                  */

method select_delete_polygon( long *sts )
{
  IGRlong       status,msg;
  int           poly_ind,sel_flag,num_rows,row;
  char          my_msg[80];
  enum GRdpmode DisplayMode;

  FIfld_get_num_rows(me->forms[0].form_ptr,G_POLY_LIST,&num_rows);
  if(num_rows <= 0)
   {
     ex$message( msgnumb = SM_I_WdNoPolyToDel, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
     FIg_set_state_off(me->forms[0].form_ptr,G_REMOVE);
     goto quit;
   }

  /* We come from non delete state : ask the name of a polygon */
  /* Deselect all selected polygons and disable some gadget */
  if(me->state_del == FALSE) 
   {
     SMSetSingleSelectMode(me->forms[0].form_ptr,G_POLY_LIST,num_rows,6);
   
     me->state_del = TRUE;
     /* Disable ADD_POLY etc ... */
     om$send(msg = message SMCmdWind.chg_state_button(sts,FALSE),
	     targetid = my_id);
     ex$message( msgnumb = SM_I_WdSelPolyDel, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
     goto quit;
   }

  /* We are in a delete state */
  sel_flag = find_index_select_polygon
    (me->forms[0].form_ptr,me->work_poly,me->work_nb_poly,&poly_ind,&row);

  /* One polygon is selected, delete it*/
  if(sel_flag) 
   {
     del_one_polygon(me->work_poly,&me->work_nb_poly,poly_ind);
     FIfld_delete_rows(me->forms[0].form_ptr,G_POLY_LIST,row,1);

     /* Enable ADD_POLY etc ... */
     om$send(msg = message SMCmdWind.chg_state_button(sts,TRUE),
	     targetid = my_id);
     
     ex$message( msgnumb = SM_I_WdPolyDel, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);

     DisplayMode = GRhe;
     status = om$send(msg = message GRgraphics.GRdisplay
		      (&msg,&me->ModuleInfo.md_env.matrix_type,
		       me->ModuleInfo.md_env.matrix,
		       &DisplayMode,&me->ModuleInfo.md_id),
		      targetid = me->work_poly[poly_ind].id.objid,
		      targetos = me->work_poly[poly_ind].id.osnum);
     as$status(action = CONTINUE);
   }

  SMStopSingleSelectMode(me->forms[0].form_ptr,G_POLY_LIST,6,
			 FI_REVIEW,FI_APPEND,FI_APPEND,FI_APPEND,
			 FI_APPEND,FI_APPEND);

  me->state_del = FALSE;
  if(me->work_nb_poly == 0)
    /* As no polygon selected, nothing can be keyin in form GI_POLY_LIST */
    change_mode_list_field(me->forms[0].form_ptr,FI_REVIEW);
  else
   {
     FIfld_get_num_rows(me->forms[0].form_ptr,G_POLY_LIST,&num_rows);
     FIfld_set_max_num_rows(me->forms[0].form_ptr,G_POLY_LIST,num_rows);
   }

 quit:
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

    
#ifdef JJ_DEBUG
/* Method for debug : print an attribute */
static int print_attr(ACrg)
struct ACrg_coll *ACrg;
{
  printf("Attr name <%s>",ACrg->name);
  
  switch((ACrg->desc).type)
   {
   case AC_ATTRIB_TEXT:
     printf(" value <%s> \n",(ACrg->desc).value.att_txt);
     break;
   case  AC_ATTRIB_DOUBLE:
     printf(" value <%lf> \n",(ACrg->desc).value.att_exp);
     break;
   default: printf(" value unknown\n");
   }
  return 1; 
}


/* print all attribute of a collection */
print_all_attr(ACrg,nb_attr)
struct ACrg_coll *ACrg;
int nb_attr;
{
  int i;

  for(i=0;i<nb_attr;i++)
    print_attr(&ACrg[i]);
  return 1;
}
 
print_poly_attr(Poly,nb_poly)
struct Wind_Polygon Poly[];
int nb_poly;
{
  int i;

  printf("Sauvegarde des attributs\n");
  printf("Nombre de polygon %d \n",nb_poly);
  for(i=0;i<nb_poly;i++)
   {
     printf("\nPolygon %d Id %d name %s \n",i,Poly[i].id.objid,Poly[i].name);
     print_all_attr(Poly[i].ACrg,Poly[i].nb_attr);
   }
  return 1;
}
#endif

end implementation SMCmdWind;







