/* $Id: SMglobi.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smglob/imp / SMglobi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMglobi.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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

/*         File SMglobi.I                                          */
/* Author Jean Jeasinczuk (ISDC)                                   */
/* History                                                         */
/*          June  92 : Creation date                               */
/*          April 93 : Recompile for 2.2                           */

class implementation SMglob;

#include "OMmacros.h"
#include "exmacros.h"
#include "string.h"
#include "gr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "VDDbDef.h"
#include "vdsmacros.h"
#include "grerr.h"
#include "vds.h"
#include "VDmsg.h"
#include "SMmsg.h"

#include "SMmacros.h"

#define NB_GLOB_TEMP 4

#include "AS_status.h"
#define AS_DEBUG 1

/*#define DEBUG 1  */

extern GRclassid OPP_ACrg_collect_class_id,OPP_GRcontext_class_id,
       OPP_SMcoll_class_id,OPP_ASsourcein_class_id;

from SMCsPp import SMGetParameters;            
from SMframe import SMfind_frm_syst;            
from SMfrm_syst import SMfind_frame_objid;            
from  ACrg_collect import ACadd_list_attribute,ACget_named_attribute,
                           ACmod_list_attribute,AClist_attribute;

%safe
static int CsSfPrint();
%endsafe

/* ******************* MSG SMWhoAreYou() ************************ */
/* Give type SM_SHIP_ATT */

method SMWhoAreYou(IGRlong *msg; IGRshort *type, *sub_type)
{
  if(type) *type = SM_SHIP_ATT;
  if(sub_type) *sub_type = 0xFFFF;
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/* ****************** MSG ACmplace_from_def () ************************	*/

method ACmplace_from_def(int *rc, prop; char rep;char *macro_name;
	       	int num_temp;	struct GRid *temp_list;
		struct GRid *def_occ;
		struct GRmd_env *md_env )

{
 IGRlong status;

 /* Put the properties to no protect:
 /*	- Does not create source,
 /*	- Does not verify the number 
 /*	- Does not verify the template types
 /* */
 prop = prop | AChdr_noprotect | ACcant_place_sym;
 status = om$send(msg = message ACncpx.ACmplace_from_def(rc, prop, rep, 
		         macro_name, num_temp, temp_list, def_occ, md_env),
                  mode     = OM_e_wrt_message,
                  targetid = my_id );
 as$status(action = RET_STATUS);
 
 /* Create as a new one */
 status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
                  targetid = my_id );
 as$status(action = RET_STATUS);
 
 return	OM_S_SUCCESS;
}

/* ********************** MSG ACconstruct_feet() ****************** */

method	ACconstruct_feet(IGRlong *rc; IGRint cn_type; 
           		 IGRint count; struct GRid list[];
			 struct GRmd_env *md_env;
			 IGRint *fcount; struct GRid *feet_list )
{
  IGRlong          status,msg;
  struct GRid      rg;
  IGRint           len_list;
  struct ACrg_coll att[NB_GLOB_ATTRIB];
  
  rg.osnum = md_env->md_id.osnum;
  status = om$construct(classid = OPP_ACrg_collect_class_id,
			osnum   = rg.osnum,
			p_objid = &rg.objid);
  as$status(action = GOTO_VALUE,value = wrapup);
 
  status = om$send(msg = message ACrg_collect.AClist_attribute
		   (&msg,NB_GLOB_ATTRIB,att,&len_list),
		   targetid = list[0].objid,
		   targetos = list[0].osnum);
  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
  
  status = om$send(msg = message ACrg_collect.ACadd_list_attribute
		   (&msg,len_list,att),
		   targetid = rg.objid,
		   targetos = rg.osnum);
  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);
  
  feet_list[0] = rg;
  
  *fcount = 1;
  feet_list[0] = rg;
  *rc = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  *fcount = 1;
  feet_list[0].objid = NULL_OBJID;
  *rc = 0;
  return OM_W_ABORT;
}


/* ******************* MSG SMGetConnected() ************************	*/

method SMGetConnected(IGRlong *msg; struct GRid *cs;
		      struct GRid *frm; struct GRmd_env *frm_env;
		      struct GRid *hull)
{
  IGRlong         status;
  struct GRid     temp[NB_GLOB_TEMP],frame0;
  int             count;
  struct GRmd_env *my_env,mod_env;
  
  if(frm_env == NULL) my_env = &mod_env;
  else                my_env = frm_env;

  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,temp,3,NULL,1,3,&count),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  if(count != 4) {*msg = MSFAIL; return OM_S_SUCCESS;}
  
  if(cs)       *cs       = temp[0];
  if(hull)     *hull     = temp[2];
  if(frm) 
   { 
     /* If we are connected to ASsourcein return frame */
     /* Else return frame and module env               */

     status = om$send(msg = message NDmacro.ACreturn_foot
		      (msg,"",&frame0,
		       &my_env->md_env.matrix_type,my_env->md_env.matrix),
		      targetid = temp[1].objid,
		      targetos = temp[1].osnum);
     as$status(sts = (status & *msg),action = RET_STATUS;);
	
     my_env->md_id.osnum = frame0.osnum;
     status = ex$get_modid(mod_osnum = my_env->md_id.osnum,
			   mod_id =   &my_env->md_id.objid);
     as$status(action = RET_STATUS);

     
#ifdef DEBUG
  printf("frame0 = %d,%d temp recuperer = %d,%d\n",
	  frame0.objid,frame0.osnum,temp[1].objid,temp[1].osnum);
#endif

     /* We are connected to frame 0 so retrieve frame system */
     status = om$send(msg = message SMframe.SMfind_frm_syst
		      (msg,frm),
		      targetid = frame0.objid,
		      targetos = frame0.osnum);
     as$status(sts = (status & *msg),action = RET_STATUS);
   }

  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/* ******************* MSG SMcreate() ************************	*/
/* Construct a ACrg_coll, Set the parameter in the ACrg, connect */
/* to ACrg and hull*/

method SMcreate(IGRlong *msg;struct GRid *cs;
		struct GRid *frm; struct GRmd_env *frm_mod_env;
		struct GRid *hull; struct ACrg_coll *att)
{
  IGRlong         status;
  struct GRid     temp[NB_GLOB_TEMP],frame0;
  IGRlong         sizebuf, nret; 
  struct GRmd_env mod_env;

  *msg = MSFAIL;
  
  SMGlobMacDef();

  /* I delete myself when one of my parents is deleted */
  status = om$send(msg = message NDnode.NDchg_state
		   (ND_DONT_MVRT ,ND_DONT_MVRT),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  /* Create ACrg */
  temp[0].osnum = OM_Gw_current_OS;
  status = om$construct(classid = OPP_ACrg_collect_class_id,
			osnum   = temp[0].osnum,
			p_objid = &temp[0].objid);
  as$status(action = RET_STATUS);
  
  status = om$send(msg = message ACrg_collect.ACadd_list_attribute
		   (msg,NB_GLOB_ATTRIB,att),
		   targetid = temp[0].objid, targetos = temp[0].osnum);
  as$status(sts = (status & *msg),action = RET_STATUS);

  status = om$send(msg = message NDnode.NDchg_state
		   (ND_DEL_NO_CH | ND_WAIT_DEL,
		    ND_DEL_NO_CH | ND_WAIT_DEL),
		   targetid = temp[0].objid,
		   targetos = temp[0].osnum);
  as$status(action = RET_STATUS);

  temp[1] = *cs; 
  temp[3] = *hull;

  /* Cannot connected to frame system, so connect to frame 0 */
  status = om$send(msg = message SMfrm_syst.SMfind_frame_objid
		   (msg,0,&frame0),
		   targetid = frm->objid,
		   targetos = frm->osnum);
  as$status(sts = (status & *msg),action = RET_STATUS);
  
  status = as$make_source(go_grid = frame0, mod_env = frm_mod_env,
			  as_grid = &temp[2]);
  as$status(action = RET_STATUS); 

#ifdef DEBUG
  printf("frame0 = %d,%d temp[2] = %d,%d\n",
	  frame0.objid,frame0.osnum,temp[2].objid,temp[2].osnum);
#endif

  sizebuf = sizeof(struct GRmd_env);
  gr$get_module_env(msg     = msg,
		    sizbuf  = &sizebuf,
		    buffer  = &mod_env,
		    nret    = &nret);
  


  status = om$send(msg = message ACncpx.ACmplace
		   ((IGRint *)msg, AChdr_nodisplay ,0,
		    "SMglob", NB_GLOB_TEMP, temp, &mod_env),
		   targetid = my_id);
  as$status(sts = (status & *msg),action = RET_STATUS);
  
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/* ------------------ method SMModify ------------------ */
method SMModify(IGRlong *msg; struct GRid *cs;
		struct GRid *frm; struct GRmd_env *frm_mod_env;
		struct GRid *hull; struct ACrg_coll *ACrg)
{
  IGRlong     status;
  struct GRid old_cs,old_hull,old_frame0;
  struct GRid frame0,as_frame0,mac;
  struct GRid temp[NB_GLOB_TEMP];
  int         count;
  int         cn_type,wait_batch;

  status = om$send(msg = message SMmgr.SMResetAtt
		   (msg,NB_GLOB_ATTRIB,ACrg,NULL),
		   targetid = my_id);
  as$status(sts = (status & *msg),action = RET_STATUS);
 
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,temp,3,NULL,1,3,&count),
		   targetid = my_id);
  as$status(action = RET_STATUS);
  if(count != 4) {*msg = MSFAIL; return OM_S_SUCCESS;}

  old_cs      = temp[0];
  old_frame0  = temp[1];
  old_hull    = temp[2];

  if(old_cs.objid != cs->objid || old_cs.osnum != cs->osnum)
   {
     status = om$send(msg = message NDnode.NDchange_connect
		      (1,&old_cs,cs),
		      targetid = my_id);
     as$status(action = RET_STATUS);
   }

  if(frm != NULL)
   {
     /* Cannot connected to frame system, so connect to frame 0 */
     status = om$send(msg = message SMfrm_syst.SMfind_frame_objid
		      (msg,0,&frame0),
		      targetid = frm->objid,
		      targetos = frm->osnum);
     as$status(sts = (status & *msg),action = RET_STATUS);
     
     as$make_source(go_grid = frame0, mod_env = frm_mod_env,
		    as_grid = &as_frame0);

#ifdef DEBUG
  printf("frame0 = %d,%d pretend= %d,%d\n",
	  frame0.objid,frame0.osnum,as_frame0.objid,as_frame0.osnum);
#endif

     if(old_frame0.objid != as_frame0.objid
	|| old_frame0.osnum != as_frame0.osnum)
      {
	status = om$send(msg = message NDnode.NDchange_connect
			 (1,&old_frame0,&as_frame0),
			 targetid = my_id);
	as$status(action = RET_STATUS);
      }
   }  

  if(old_hull.objid != hull->objid || old_hull.osnum != hull->osnum)
   {
     status = om$send(msg = message NDnode.NDchange_connect
		      (1,&old_hull,hull),
		      targetid = my_id);
     as$status(action = RET_STATUS);
   }
  
  mac.objid = my_id;
  mac.osnum = OM_Gw_current_OS;
  cn_type    = ND_COMP; /* recompute the object */
  status = nd$wait_batch(type       = GR_GEOM_POSTED,
			 l_object   = &mac,
			 l_obj_info = &cn_type,
			 nb_obj     = 1);
  
  nd$mod_batch(request = ND_INQ,p_ret_mode = &wait_batch);
     
  if(wait_batch != ND_DEFER) /* Else Nothing to do */
    nd$exec_batch(mode = 0);

  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/*   ******************* MSG SMFillSfFile() ************************	*/
/*   Print in seasafe file global data, frame system, active cs         */

method SMFillSfFile(IGRlong *msg; FILE *p_file; IGRshort options; IGRboolean tag;
		    IGRshort out_units; struct GRmdenv_info *obj_env, *trans_env)
{
  IGRlong           status,loc_msg;
  struct ACrg_coll  ACrg[9];
  IGRshort          type[9];
  IGRint            i;
  IGRlong           unit,msgnumb;
  IGRdouble         cv_value;
  struct GRid       as_cs,frm;
  struct GRmd_env   frm_mod_env;
  char              proj_nb[80],proj_rev[80];
  struct VDSproject proj_att;
  int               ship_no;
  IGRint            prj_units;

  *msg = MSFAIL;

  if(VDSverify_project() != OM_S_SUCCESS)
   {
     printf("Project not defined\n");
     return OM_S_SUCCESS;
   }

  if(VDGetProjectNumRev( proj_nb,proj_rev,&prj_units) != OM_S_SUCCESS)
    return OM_S_SUCCESS;
  
  if(!VdsSetProjectData(proj_nb,proj_rev, &proj_att, &msgnumb))
    return OM_S_SUCCESS;
  
  strcpy(ACrg[0].name,S_FLAG_STATE);
  ACrg[0].desc.type = AC_ATTRIB_TEXT;
  
  strcpy(ACrg[1].name,S_AREA_OP);
  ACrg[1].desc.type = AC_ATTRIB_TEXT;

  strcpy(ACrg[2].name,S_LPP);
  ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
  
  strcpy(ACrg[3].name,S_MOULD_BREADTH);
  ACrg[3].desc.type = AC_ATTRIB_DOUBLE;
  
  strcpy(ACrg[4].name,S_MOULD_DEPTH);
  ACrg[4].desc.type = AC_ATTRIB_DOUBLE;
  
  strcpy(ACrg[5].name,S_OVERALL_LENGTH);
  ACrg[5].desc.type = AC_ATTRIB_DOUBLE;
  
  strcpy(ACrg[6].name,S_DESIGN_DRAFT);
  ACrg[6].desc.type = AC_ATTRIB_DOUBLE; 
  
  strcpy(ACrg[7].name,S_SHELL_PLATING);
  ACrg[7].desc.type = AC_ATTRIB_DOUBLE;
  
  strcpy(ACrg[8].name, S_KEEL_PLATING);
  ACrg[8].desc.type = AC_ATTRIB_DOUBLE;
  
  status = om$send(msg = message SMglob.SMGetAtt
		   (msg,9,ACrg,type),
		   targetid = my_id);
  as$status(sts = (status & *msg), action = RET_STATUS);
  
  status = om$send(msg = message SMglob.SMGetConnected
		   (msg,&as_cs,&frm,&frm_mod_env,NULL),
		   targetid = my_id);
  as$status(sts = (status & *msg), action = RET_STATUS);
  
  if(!VdsGetShipNum(proj_att.prj_descr,&ship_no))
    ship_no = 91; /* Seasafe demo ship */
     

  if(options & SM_ASCII_FILE)
   {
     fprintf(p_file,"GLOBAL ");
     fprintf(p_file,"\"%s\" ",proj_att.prj_number);
     fprintf(p_file,"\"%s\" ",proj_att.prj_name);
     fprintf(p_file,"\"%s\" ",proj_att.ship_name);
     fprintf(p_file,"\"%s\" ",proj_att.ship_number);
     
     fprintf(p_file,"%d \n",ship_no);
     fprintf(p_file,"\"%s\" ",proj_att.prj_client);
	
     /* Flag state (HARD CODE for now) */
     fprintf(p_file,"%s ",ACrg[0].desc.value.att_txt);
  
     /* Area of operation (HARD CODE for now) */
     fprintf(p_file,"%s ",ACrg[1].desc.value.att_txt);

     fprintf(p_file,"\"%s\" ",proj_att.ship_user);
     fprintf(p_file,"\"%s\" ",proj_att.dept_name);
     
     /* Printf units */
     unit = out_units;
	   
     /* Add unit of angle to units */
     SMRetAnglUnitFlag(&unit,OM_Gw_current_OS);
     unit |= SM_UNIT_CEL; /* Put celsius degree by default */
     fprintf(p_file,"\n%d ",unit);     

     /* Print all double value retrieve from global data */
     for(i = 2; i < 9; i++)
      {
	SMConvDistIntUnit(ACrg[i].desc.value.att_exp,out_units,
			  &cv_value,OM_Gw_current_OS);
	fprintf(p_file,"%g ",cv_value);
      }
     fprintf(p_file,"\n\n");

     if(!CsSfPrint(&as_cs,p_file,options,out_units))
       printf("Error Seasafe extraction of the active cs \n");

     status = om$send( msg = message SMmgr.SMFillSfFile
		      (&loc_msg,p_file, options,tag,
		       out_units, &frm_mod_env.md_env,trans_env),
		      targetid = frm.objid, 
		      targetos = frm.osnum);
     if(!(status & loc_msg & 1))
       printf("Error Seasafe extraction of the active frame system \n");

     *msg = MSSUCC;
   }
  else
   {
     /* It is a binary file */
     printf("Binary file not yet implemented\n");
     return OM_W_ABORT;
   }
  
  return OM_S_SUCCESS;
}


/* ------------------------- SMReadShipTypes ------------------------------- */
/* Read all the type defined in the file ship_type and put them in ship_type */

int SMReadShipTypes(name_file,ship_type,nb_ship_type)
char *name_file;                  /* [I] Name of the file containing ship_type */
struct SMspec_attrib ship_type[]; /* [O] Struct containing ship type */    
int *nb_ship_type;                /* [O] Number of ship type */  
{
  FILE *fp;
  char 	buffer[MAX_CHAR_LINE], *ptr;
  int   i,row;
  
  fp = NULL;
  /* Have to look inside the config */
  vd$openfile(  file_name 	= name_file,
	      product_name 	= "Vds",
	      sub_path	= "config",
	      cur_dir	  	= TRUE,
	      p_file	  	= &fp);
  if(fp == NULL)
   {printf("Error,cannot open the file: %s\n",name_file); return 0;}
  
  row = 0;
  while(fgets(buffer,MAX_CHAR_LINE-1, fp) != NULL)
   {
     if(strlen(buffer) < 1) continue;  /* Take out the blank line */
     buffer[strlen(buffer)-1] = '\0'; /* To take into account the return */
     
     /* Skip blank characters */
     i = 0;
     while(isspace(buffer[i]) && buffer[i] != '\0') i++;
     ptr = &buffer[i];
     
     if(*ptr == '#') continue; /* A comment line (starting by #) */
     
     if(*ptr) /* Not blank line */
      {
	if(sscanf(ptr,"%d",&ship_type[row].num) != 1)
	  goto wrapup;
	
	while((isdigit(*ptr) || isspace(*ptr)) && *ptr) ptr++;
	if(*ptr == '\0') goto wrapup;
	
	strcpy(ship_type[row].name,ptr);
	row++;
	*nb_ship_type = row;
      }
   }
  
  if(fp) fclose(fp);
  return 1;
  
 wrapup:
  printf("Bad file format %s\n",name_file);
  if(fp) fclose(fp);
  return 0;
} 


/* -------------------- SMGetShipTypeNum ------------------------- */
/* Retrieve the number of a ship type given is name                */

int SMGetShipTypeNum(ship_type,nb_ship_type,type_name,type_num)
struct SMspec_attrib *ship_type;  /* [I] Struct containing ship type */    
int nb_ship_type;                 /* [I] Number of ship type */
char *type_name;                  /* [I] Char type name */
int *type_num;                    /* [O] Type number */
{
  int i;
  
  for(i=0; i< nb_ship_type; i++)
    if(strcmp(ship_type[i].name,type_name) == 0)
     {*type_num = ship_type[i].num;return 1;}
  return 0;
}

/* -------------------- SMGetShipTypeNum ------------------------- */
/* Retrieve the name of an attribute given the number              */

int SMGetShipTypeName(ship_type,nb_ship_type,type_num,type_name)
struct SMspec_attrib *ship_type;  /* [I] Struct containing ship type */    
int nb_ship_type;                 /* [I] Number of ship type */
int type_num;                     /* [I] Type number */
char *type_name;                  /* [O] Char type name */
{
  int i;
  
  for(i=0; i< nb_ship_type; i++)
    if(type_num == ship_type[i].num)
     { strcpy(type_name,ship_type[i].name); return 1; }
  return 0;
}



/* ------------------ int SMGlobMacDef ------------------ */
/*  Create macro definition for global data               */

int SMGlobMacDef()
{
  char	*temp_list[NB_GLOB_TEMP], tmp_temp[NB_GLOB_TEMP * macro_MAX_CHAR];
  char	*feet_list[1], tmp_feet[1 * macro_MAX_CHAR];
  int	temp_type[NB_GLOB_TEMP];	
  struct GRid	 mac_id;
  
  /* Template initialization */
  strcpy(&tmp_temp[0 * macro_MAX_CHAR], "user_dyn");
  temp_list[0] = &tmp_temp[0];
  temp_type[0] = other_generic; 

  strcpy(&tmp_temp[1 * macro_MAX_CHAR], "cs");
  temp_list[1] = &tmp_temp[1 * macro_MAX_CHAR ];
  temp_type[1] = other_generic;
  
  strcpy(&tmp_temp[2 * macro_MAX_CHAR], "frame");
  temp_list[2] = &tmp_temp[2  * macro_MAX_CHAR];
  temp_type[2] = other_generic;
  
  strcpy(&tmp_temp[3 * macro_MAX_CHAR], "hull");
  temp_list[3] = &tmp_temp[3  * macro_MAX_CHAR];
  temp_type[3] = other_generic;
 
  /* Feet initialization */
  strcpy(&tmp_feet[0*macro_MAX_CHAR],"parameter");
  feet_list[0] = &tmp_feet[0*macro_MAX_CHAR];
  
  return(SMCrtMacDef("SMglob", "SMPrivMac", NB_GLOB_TEMP, temp_list, temp_type, 
		     1, feet_list, 0, NULL, NULL, &mac_id));
}


/* ------------------ static int CsSfPrint ------------------ */
/* Print the active cs in seasafe file                        */
/* WARNING : Consider cs is middle of perp                    */

static int CsSfPrint(as_cs,p_file,options,out_units)
struct GRid *as_cs;
FILE *p_file;
IGRshort options,out_units;
{
  IGRlong     status, msg;
  IGRmatrix   matrix,mat_env;
  char        name[DI_PATH_MAX], my_name[DI_PATH_MAX], *pt;
  IGRshort    mat_env_type;
  int         i;
  struct GRid cs;
  struct IGRbsp_surface *surf;
  struct ACrg_coll	 crit ;

  status = om$send(msg = message NDmacro.ACreturn_foot
		   (&msg,"",&cs,&mat_env_type,mat_env),
		   senderid = NULL_OBJID,
		   targetid = as_cs->objid,
		   targetos = as_cs->osnum);
  if(!(status & msg & 1)) return 0;
  
  /* Get the name */
  status = om$send(msg = message GRvg.GRgetname(&msg, my_name),
		   senderid = NULL_OBJID,
		   targetid = cs.objid,
		   targetos = cs.osnum); 
  if(!(status &1) || msg != MSSUCC)
   {
     /* No name !!! */
     return 0;
   }
  
  if(my_name[0] == '\0') { my_name[1] = '\0'; pt = &my_name[0]; }
  else pt = strrchr(my_name,':');
  
  if(pt == NULL) name[0] = '\0';
  else strcpy(name, &pt[1]);
  
  /* Seasafe name only 4 characteres */
  name[17] = '\0';
  
  status = om$send(msg=message GRvg.GRgenabsg
		   (&msg, &mat_env_type, mat_env,(IGRchar **)&surf),
		   senderid = NULL_OBJID,
		   targetid = cs.objid,
		   targetos = cs.osnum);
  as$status(action = RET_STATUS);
  if(!(msg & 1)) return 0;
  
  for(i=0;i<16;i++) matrix[i] = ((struct IGRlbsys *) surf)->matrix[i];
  
  /* KLUDGE : define CS position by middle of two perpendiculars */
  /* Search all perpendiculars */
 {
   IGRdouble 		ap_pos, fp_pos;
   struct GRid          ap_id, fp_id;
   struct SMObjList  	list;
   static IGRdouble 	trans_mat[4][4] = {{1.0,0.0,0.0,0.0},{0.0,1.0,0.0,0.0},
					  {0.0,0.0,1.0,0.0},{0.0,0.0,0.0,1.0}};
   IGRmatrix tmp_mat;
   IGRboolean bsts;
   
   list.nb_objects = 0;
   list.list = NULL;

   /* 
    * Now more than one perp set can exist, just get the design perp set 
    */

   crit.desc.type = AC_ATTRIB_DOUBLE;
   strcpy(crit.desc.value.att_txt,"1");
   strcpy(crit.name,"is_analysis");

   status = SM$CritSel(msg  	= &msg,
		       type 	= SM_PP,
		       nb_crit 	= 1,
		       crit 	= &crit,
		       list 	= &list);
   if(list.nb_objects != 1)
    {
      printf("No design perpendicular defined\n");
      if (list.nb_objects && list.list) free(list.list);
      return 0; 
    } 
   
  status = om$send(msg = message SMCsPp.SMGetParameters
		   (&msg, NULL, &ap_id, &fp_id, NULL, NULL,NULL),
		   senderid = NULL_OBJID,
		   targetid = list.list[0].obj_id.objid,
		   targetos = list.list[0].obj_id.osnum);
   if(!(status & msg & 1))
    { 
     printf("Error get parameters of %d\n",list.list[0].obj_id.objid);
     return 0; 
    }
     
   if(!SMGetExpDist(&ap_id,&fp_id,&ap_pos,&fp_pos,
		    (IGRchar *)NULL,(IGRchar *)NULL))
    {
      printf("ERROR SMGetExpDist\n");
      return 0;
    }
   
   SMConvDistIntUnit(ap_pos,out_units,&ap_pos,OM_Gw_current_OS);
   SMConvDistIntUnit(fp_pos,out_units,&fp_pos,OM_Gw_current_OS);

   if(list.nb_objects && list.list) free(list.list);
   
   /* Temporary negative value due to seasafe bug */
   trans_mat[0][3] = -1.0 * (ap_pos + fp_pos / 2.0);
   
   BSmult_mats(4,4,matrix,0,4,4,trans_mat,0,tmp_mat,&bsts);
   for(i=0;i<16;i++) matrix[i] = tmp_mat[i];
 } 
  
  if(options & SM_ASCII_FILE)
   {
     /* Use an ascii file */
     fprintf(p_file, "ACT_CS \"%s\"\n",name);
     if(!(options & SM_SF_SHORT_EXT))
      {
	fprintf(p_file,"%g %g %g\n",matrix[3],matrix[7],matrix[11]);
	fprintf(p_file,"%g %g %g\n",matrix[0],matrix[4],matrix[8]);
	fprintf(p_file,"%g %g %g\n",matrix[1],matrix[5],matrix[9]);
	fprintf(p_file,"%g %g %g\n",matrix[2],matrix[6],matrix[10]);
      }
     fprintf(p_file, "\n");
   }
  else
   {
     /* It is a binary file */
     printf("Binary file not yet implemented\n");
     return 0;
   }
  return 1;
}  


/*----------------------------------------------------------------------------*/
method VDgetObjDef( long *msg ; VDobjDef *myDef ) {

	long		sts ;	/* OM return code	*/

	/*
	 * name.
	 */
	myDef->info		= SM_I_ObjGlob ;
	myDef->type		= 0 ;

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VDgetObjdDef */
/*----------------------------------------------------------------------------*/

end implementation SMglob;
