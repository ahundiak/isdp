/* $Id: SMCompNotif.I,v 1.3 2001/11/09 18:56:16 ylong Exp $  */

/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	SMcomp/SMCompNotif.I
 *
 * Description:	
 *
 *	This file contains methods and functions for the SMCmdComp command
 *	object.
 *
 * Dependencies:
 *	SMCmdComp
 *
 * Revision History:
 *	$Log: SMCompNotif.I,v $
 *	Revision 1.3  2001/11/09 18:56:16  ylong
 *	TR3057
 *	
 *	Revision 1.2  2001/11/07 14:23:12  ylong
 *	SP14 for TR3064
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.4  1999/05/06  21:04:08  pinnacle
# TR_179900488
#
# Revision 1.2  1999/01/28  16:07:06  pinnacle
# TR_179900099
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.6  1998/04/16  15:56:02  pinnacle
# TR179800992
#
# Revision 1.5  1998/04/05  15:34:44  pinnacle
# Replaced: smcomp/cmd/SMCompNotif.I for:  by v250_int for vds
#
# Revision 1.4  1998/02/16  08:57:16  pinnacle
# Replaced: smcomp/cmd/SMCompNotif.I for:  by ssranade for vds
#
# Revision 1.3  1998/01/27  18:37:28  pinnacle
# Replaced: smcomp/cmd/SMCompNotif.I for:  by impd for vds
#
# Revision 1.2  1997/06/23  15:01:56  pinnacle
# Fixed TR 179603233
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.6  1996/11/05  21:47:40  pinnacle
# Replaced: smcomp/cmd/SMCompNotif.I for: fix for deleting volumes when S2150 button is selected: Rishad  by msmanem for vds.241
#
# Revision 1.5  1996/10/25  14:23:02  pinnacle
# Incorporated fix for TR#179603298.
#
# Revision 1.4  1996/10/24  21:32:18  pinnacle
# Replaced: smcomp/cmd/SMCompNotif.I for:  by msmanem for vds.241
#
# Revision 1.3  1996/10/06  04:38:26  pinnacle
# Replaced: smcomp/cmd/SMCompNotif.I for:  by msmanem for vds.241
#
# Revision 1.1  1996/03/01  19:59:56  pinnacle
# created to maintain the vds clix portion of pme
#
# Revision 1.2  1995/07/24  20:41:00  pinnacle
# Replaced: smcomp/cmd/SMCompNotif.I for:  by hverstee for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	08/01/92	Jean Jasinczuk: Creation Date.
 *	10/01 92	JJ:             Modif to integrate the user attributes 
 *      12/01/92 	JJ:             Take attributes in database
 *	02/01/93 	JJ:             A super command object SMCoDb have been made
 *	04/01/93 	JJ:             Add compart tracking
 *	04/01/93 	JJ:             Recompile for 2.2
 *	08/01/93 	JJ:             Update to work with collection and cache.
 *	05/01/94	P. Lacroix :	Subclass SMCmdComp from VDCmdAttMgr
 *			                and VDCmdPart instead of SMCoDb that has been removed.
 *	06/15/94	P. Lacroix	Correct a bug on the computation of
 *					the cog of the volume.
 *	07/19/96	Mallik		Reconcile PME changes.
 *	09/17/96	msm		Fix TR179603074
 *	10/03/96	msm		Disallow placement of PME compartments
 *					if file is frozen or revised.
 *      02/12/98        SSR             Fix TR # 179800477
 *	04/05/98	vini 		TR179800514
 *      04/16/98        ah              TR179800992 Some debug statements left on
 *	01/19/98	ejm	TR_179900099: Modify Compartment
 *				put_comp_att_in_form: change only G_NAME to
 *					FI_APPEND
 *				put_geom_info: do not change G_EXP_AREA and
 *					G_EXP_VOL to FI_APPEND
 *	04/22/99	ejm	TR_179900488: Modify Compartment
 *					      Exclude listing incorrect -
 *					      commented out FIfld_set_num_rows
 *					      and FIfld_set_max_num_rows.
 *	11/06/01	ylong	TR3064
 * -------------------------------------------------------------------------
 */


class implementation SMCmdComp;

#define AS_DEBUG       1

#include "go.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VDmem.h"
#include "VDPdm2.h"
#include "execmsg.h"
/*
#define vdsDEBUG   1
#include "v_dbgmacros.h"
*/
/*
#define JJ_DEBUG    Causes crash
*/

#include "AS_status.h"

from SMgroup    import SMGetSbGrp,SMGetSgrpId;
from SMcoll     import SMSetDbInfo;            
from ACdb_info  import ACset_db_info;            
from NDmacro    import ACreturn_foot;            
from NDnode     import NDchange_connect,NDget_objects,NDdisplay;
from GRgraphics import GRputname;
from SMcomp     import ACmplace,SMSetDwSymb,SMGetGrp,SMSetAtt,
                       SMResetAtt,SMGetDw,SMGetVolInfo,SMDiscRoots,
                       SMAddRoots,SMModPtTxt,SMListAtt;
from SMcoll     import ACadd_list_attribute,AClist_attribute,
                       ACmod_list_attribute,ACset_list_attribute;
from SMmgr      import SMGetShortName,SMGetAttDbl,SMGetAttTxt,
                       SMChgState,SMSetState;
from GRvg	import GRputsymb;


extern GRclassid        OPP_SMcomp_class_id;
extern GRclassid        OPP_EMSsolid_class_id;

extern VDgetEmsBooleanStatus();

/*+fi
 -------------------------------------------------------------------------
  Internal Function FIset_justif

  Abstract
	Get the justification for the display from the corresponding 
	gadgets in the given form.

  Returns
	nothing, it is a void function.


 -------------------------------------------------------------------------
*/

static void FIget_justif(form,justif)
Form      form;      /* [I] form pointer */
IGRshort  *justif;   /* [O] justificattion for display */
/*
-fi */
{
  int state;
  
  FIg_get_state(form,G_X_POS_Y_POS,&state);
  if(state) *justif = *justif | SM_CMP_X_POS | SM_CMP_Y_POS;
  FIg_get_state(form,G_X_POS_Y_C,&state);
  if(state) *justif = *justif | SM_CMP_X_POS ;
  FIg_get_state(form,G_X_POS_Y_NEG,&state);
  if(state) *justif = *justif | SM_CMP_X_POS | SM_CMP_Y_NEG;

  FIg_get_state(form,G_X_C_Y_POS,&state);
  if(state) *justif = *justif | SM_CMP_Y_POS;

  /* if X_Center Y_center  nothing to do */

  FIg_get_state(form,G_X_C_Y_NEG,&state);
  if(state) *justif = *justif | SM_CMP_Y_NEG;

  FIg_get_state(form,G_X_NEG_Y_POS,&state);
  if(state) *justif = *justif | SM_CMP_X_NEG | SM_CMP_Y_POS;
  FIg_get_state(form,G_X_NEG_Y_C,&state);
  if(state) *justif = *justif | SM_CMP_X_NEG ;
  FIg_get_state(form,G_X_NEG_Y_NEG,&state);
  if(state) *justif = *justif | SM_CMP_X_NEG | SM_CMP_Y_NEG;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function FIset_justif

  Abstract
	Set the justification for the display = set the state of the
	corresponding gadgets in the form.

  Returns
	nothing, it is a void function.

 -------------------------------------------------------------------------
*/

static void FIset_justif(form,justif)
Form form;           /* [I] form pointer */
int  justif;         /* [I] justification for display */
/*
-fi */
{
  FIg_set_state_off(form,G_X_POS_Y_POS);
  FIg_set_state_off(form,G_X_POS_Y_C);
  FIg_set_state_off(form,G_X_POS_Y_NEG);
  FIg_set_state_off(form,G_X_C_Y_POS);
  FIg_set_state_off(form,G_X_C_Y_C);
  FIg_set_state_off(form,G_X_C_Y_NEG);
  FIg_set_state_off(form,G_X_NEG_Y_POS);
  FIg_set_state_off(form,G_X_NEG_Y_C);
  FIg_set_state_off(form,G_X_NEG_Y_NEG);

  if(justif & SM_CMP_X_POS)
   {
     if(justif & SM_CMP_Y_POS)
       FIg_set_state_on(form,G_X_POS_Y_POS);
     else
       if(justif & SM_CMP_Y_NEG)
	 FIg_set_state_on(form,G_X_POS_Y_NEG);
       else
	 FIg_set_state_on(form,G_X_POS_Y_C);
     return;
   }
 
  if(justif & SM_CMP_X_NEG)
   {
     if(justif & SM_CMP_Y_POS)
       FIg_set_state_on(form,G_X_NEG_Y_POS);
     else
       if(justif & SM_CMP_Y_NEG)
	 FIg_set_state_on(form,G_X_NEG_Y_NEG);
       else
	 FIg_set_state_on(form,G_X_NEG_Y_C);
     return;
   }

  if(justif & SM_CMP_Y_POS)
    FIg_set_state_on(form,G_X_C_Y_POS);
  else
    if(justif & SM_CMP_Y_NEG)
      FIg_set_state_on(form,G_X_C_Y_NEG);
    else
      FIg_set_state_on(form,G_X_C_Y_C);
 
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMget_list_dead_weight

  Abstract
	Get the dead weight list and put it in the specified gadget list.
	if put_def put also the list as the default value.


  Returns
	1 if success
	0 if fails

 -------------------------------------------------------------------------
*/


int SMget_list_dead_weight(form,put_def)
Form       form;          /* [I] Pointer to the form                 */
IGRboolean put_def;       /* [I] If TRUE put also as default value   */
/*
-fi */
{
  IGRlong           status,msg;
  struct SMObjList  list;
  int               i;
  char              name[DI_PATH_MAX];
  
  list.list = NULL;

  /* Get the dead weight list */

  status = SM$CritSel(msg = &msg, type = SM_DW, list  = &list);
  if(!(status & 1) || msg != MSSUCC) {printf("Error dead weight\n");return 0; }
  if(list.nb_objects <= 0) return 0;
  
  /* get the names */

  for(i=0;i<list.nb_objects;i++)
   {

     status = om$send(msg = message SMmgr.SMGetShortName(&msg, name),
		      senderid = NULL_OBJID,
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
     if(!(status & msg & 1))
      {
	printf("Erreur finding name of the dead weight: %d, %d\n", 
	       list.list[i].obj_id.objid, list.list[i].obj_id.osnum);
	continue;
      }

     VDfld_set_list_text(form,G_DEAD_LIST,i,0,name,0);
     if(put_def)
       FIfld_set_list_default_text(form,G_DEAD_LIST,i,0,name,0);
   }

  /* Put a blank line as last selection */

  VDfld_set_list_text(form,G_DEAD_LIST,i,0,"",0);
  if(put_def)
    FIfld_set_list_default_text(form,G_DEAD_LIST,i,0,"",0);

  if(list.list != NULL) free(list.list);
  return 1;
}
/*+fi
 -------------------------------------------------------------------------
  Internal Function SMget_list_group

  Abstract
	Get the group list and put it in the specified gadget list.
	if put_def put also the list as the default value.


  Returns
	1 if success
	0 if fails

 -------------------------------------------------------------------------
*/


int SMget_list_group(form,put_def)
Form       form;          /* [I] Pointer to the form                */
IGRboolean put_def;       /* [I] If TRUE put also as default value  */
/*
-fi */
{ 
  IGRlong           status,msg;
  struct SMObjList  list;
  int               i;
  char              name[DI_PATH_MAX];

  list.list = NULL;
  /* Get the group list */
  status = SM$CritSel(msg = &msg, type = SM_GRP,list = &list);
  if(!(status & 1) || msg != MSSUCC) { printf("No group defined"); return 0; }
  if(list.nb_objects == 0) return 0;

  /* get the names */
  for(i=0;i<list.nb_objects;i++)
   {
     status = om$send(msg = message SMmgr.SMGetShortName(&msg, name),
		      senderid = NULL_OBJID,
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
     if(!(status & 1) || msg != MSSUCC)
      {
	printf("Erreur finding name of the group: %d, %d\n", 
	       list.list[i].obj_id.objid, list.list[i].obj_id.osnum);
	continue;
      }
     VDfld_set_list_text(form,G_GROUP_LIST,i,0,name,0);
     if(put_def)
       FIfld_set_list_default_text(form,G_GROUP_LIST,i,0,name,0);
   }

  if(list.list != NULL) free(list.list);
  return 1;
}
/*+fi
 -------------------------------------------------------------------------
  Internal Function SMget_list_sub_group

  Abstract
	Get the sub_group list and put it in the specified gadget list.
	if put_def put also the list as the default value.


  Returns
	1 if success
	0 if fails

 -------------------------------------------------------------------------
*/

int SMget_list_sub_group(form,group,put_def)
Form        form;        /*  [I] Pointer to the form                     */
struct GRid *group;	 /*  [I] Group from which we want subgroup       */
IGRboolean  put_def;     /*  [I] If TRUE put also as default value       */
/*
-fi */
{
  IGRlong status,msg;
  IGRint  NbSubGroup;
  IGRchar **name = NULL;
  int     i;

  status = om$send(msg = message SMgroup.SMGetSbGrp
		   (&msg,0,&NbSubGroup,NULL),
		   senderid = NULL_OBJID,
		   targetid = group->objid,
		   targetos = group->osnum);
  if(!(status & msg & 1))
   {
     printf("Error retreiving sub group of group : %d %d\n",
	    group->objid,group->osnum);
     return 0;
   }
  
  /* Blank all list */
  if(NbSubGroup == 0)
   {
     FIfld_set_num_rows(form,G_ATT_LIST,0);
     FIfld_set_text(form,G_SUB_GROUP_LIST,0,0,"",0);
     if(put_def)
       FIfld_set_default_text(form,G_SUB_GROUP_LIST,0,0,"",0);
     return 1;
   }

  name = _CALLOC(NbSubGroup, char *);
  if(!name){printf("Not enough memory\n");return 0;}
  for( i = 0 ; i < NbSubGroup; i++)
   {
     name[i] = _CALLOC(ATTR_TXT, char);
     if(!name[i]){
      printf("Not enough memory\n");
      goto freemem ; /* return 0; */ 
     }
   }
  
  status = om$send(msg = message SMgroup.SMGetSbGrp
		   (&msg,NbSubGroup,&NbSubGroup,name),
		   senderid = NULL_OBJID,
		   targetid = group->objid,
		   targetos = group->osnum);
  if(!(status & msg & 1))
   {printf("Error get sub group for group %d,%d\n",group->objid,group->osnum);
    goto freemem ; /* return 0; */}

  for(i=0; i<NbSubGroup; i++)
   {
     VDfld_set_list_text(form,G_SUB_GROUP_LIST,i,0,name[i],0);
     if(put_def)
       FIfld_set_list_default_text(form,G_SUB_GROUP_LIST,i,0,name[i],0);
   }

  FIfld_set_num_rows(form,G_ATT_LIST,NbSubGroup);
  
freemem :
  if(name)
   {
     for(i=0;i<NbSubGroup;i++) _FREE(name[i]) ;
     _FREE(name);
   }

  return 1;
}
/*+fi
 -------------------------------------------------------------------------
  Internal Function FIget_list_hull 

  Abstract
	Get all possible "hull_type" and put them in form.

  Returns
	nothing, it is a void function.

 -------------------------------------------------------------------------
*/


static void FIget_list_hull(form)
Form form;     /* [I] form pointer*/
/*
-fi */
{
  static char *hull_type[]={"STA","STR","BONJ","SUBD","GRN"};
  int i;

    for(i=0;i<5;i++)
     {
       VDfld_set_list_text(form,G_HULL_LIST,i,0,hull_type[i],0);
       FIfld_set_list_default_text(form,G_HULL_LIST,i,0,hull_type[i],0);
     }
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function find_vol_index

  Abstract
	Find the index in the Volume table of the given volume given 
	either by its name or by its id.

  Returns
	1 if volume is found
	0 if not or if error

 -------------------------------------------------------------------------
*/


static int find_vol_index(Vol,nb_vol,name,id,vol_ind)
struct Comp_Volume Vol[];      /* [I] Table of volume                      */
int                nb_vol;     /* [I] Number of volume                     */
char               *name;      /* [I] name of volume (or NULL if by id)    */
struct GRid        *id;        /* [I] Id of the volume (or NULL if by name)*/
int                *vol_ind;   /* [O] The index of the volume in the table */
/*
-fi */
{
  int i;

  if(nb_vol == 0) return 0;

  if(name != NULL)
    for(i=0; i<nb_vol; i++)
       if(strcmp(name,Vol[i].name) == 0)
	{*vol_ind = i; return 1;}

  if(id != NULL)
    for(i=0; i<nb_vol; i++)
      if(id->objid == Vol[i].id.objid &&
	 id->osnum == Vol[i].id.osnum)
       {*vol_ind = i; return 1;}

  return 0; /* Volume not found if here */
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function update_display_volume

  Abstract
       Update the hilite between the previous and the new list of volumes.
       It erase the hilite of the old ones and hilite the new ones.

  Returns
        nothing, it is a void function.


 -------------------------------------------------------------------------
*/

static void update_display_volume(new_vol,new_nb_vol,old_vol,old_nb_vol,sel_vol)
struct Comp_Volume new_vol[];   /* [I] Update list of volume   */
int                new_nb_vol;  /* [I]                         */
struct Comp_Volume old_vol[];   /* [I] Previous list of volume */
int                old_nb_vol;  /* [I]                         */
struct GRid        *sel_vol;    /* [I] Volume hilited          */
/*
-fi */
{
  IGRlong status,msg;
  int     i,vol_ind;

  if(sel_vol->objid != NULL_OBJID)
   {
     dp$display(msg = &msg, oids = sel_vol, mode = GRhhd);
     sel_vol->objid = NULL_OBJID;
   }

  /* First erase volume who belongs to old list and not new */ 

  for(i = 0; i< old_nb_vol; i++)
    if(!find_vol_index(new_vol,new_nb_vol,(char *)NULL,&old_vol[i].id,&vol_ind))
     {
       status = dp$display(msg = &msg,
			   oids = &old_vol[i].id,
			   mode = GRhe);
       as$status(sts = (status & msg));
     } 

 /* Second display volume who belongs to new list and not preceding list */ 

  for(i = 0; i< new_nb_vol; i++)
    if(!find_vol_index(old_vol,old_nb_vol,(char *)NULL,&new_vol[i].id,&vol_ind))
      {
	status = dp$display(msg  = &msg,
			    oids = &new_vol[i].id,
			    mode = GRhhd);
	as$status(sts = (status & msg));
      } 
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function add_one_volume

  Abstract

	Add one volume to the list of Comp_Volume, given its id and its 
	rg_collection id .
	It also affects a default name to the volume (defined_%d) if it 
	has not one.
	It retrieves all the attributes for this volume if rg != NULL 
	otherwise it affects default values to the rg_coll.

  Returns

	-1 if error
	else the index of the added volume in the list.

 -------------------------------------------------------------------------
*/

static int add_one_volume(Vol,nb_vol,id,mod_env,rg)
struct Comp_Volume Vol[];  /* [O] Table of volume where the vol will be added */
int                *nb_vol;/* [I/O] Number of volume */
struct GRid        *id;    /* [I] Id of the volume */
struct GRmd_env    *mod_env;/* [I] Mod env of the volume */ 
struct GRid        *rg;     /* [I] Id of the ACrg_collection (or NULL) */
/*
-fi */
{
  char    name[256];
  int     i;
  int     vol_ind;
  IGRlong status,msg;

  if(*nb_vol >= SM_MAX_ALLOW_VOL) return -1;

  /* Search the name of the new volume : if not found gener default name */ 

  name[0] = '\0';
  vd$get_name(name = name, obj = id);

  if(name[0] == '\0')
   {
     for(i=0;i<SM_MAX_ALLOW_VOL;i++)
      {
	sprintf(name,"defined_%d",i);
	if(!find_vol_index(Vol,*nb_vol,name,(struct GRid *)NULL,&vol_ind))
	 {
	  strcpy(Vol[*nb_vol].name,name);
	  break;
	}
      }
   }
  else
    strcpy(Vol[*nb_vol].name,name);
   
  Vol[*nb_vol].id = *id;
  Vol[*nb_vol].mod_env = *mod_env;
  if(rg == NULL) 
   {
     Vol[*nb_vol].rg.objid = NULL_OBJID;
     Vol[*nb_vol].nb_attr  = SM_VOL_MAX_ATT;

     /* Fill ACrg collection for this volumes with default value */

     SMCompVolColl(Vol[*nb_vol].ACrg,&Vol[*nb_vol].nb_attr);
     
     for(i=0;i<Vol[*nb_vol].nb_attr;i++)
       Vol[*nb_vol].type[i] = SM_DYNAMIC_ATT;
   }
  else
   {
     Vol[*nb_vol].rg = *rg;
     status = om$send(msg = message SMcoll.AClist_attribute
		      (&msg,SM_VOL_MAX_ATT,Vol[*nb_vol].ACrg,
		       &Vol[*nb_vol].nb_attr),
		      senderid = NULL_OBJID,
		      targetid = rg->objid,
		      targetos = rg->osnum);
     if(!(status & msg & 1))
      {printf("Error get attributes for volume id %d collection%d\n",
	      id->objid,rg->objid); return -1; }

     /* KLUDGE NO USER ATTRIBUTE YET */
     for(i=0;i<Vol[*nb_vol].nb_attr;i++)
       Vol[*nb_vol].type[i] = SM_DYNAMIC_ATT |  SM_SYST_ATT;
   }

  (*nb_vol) += 1;
  return *nb_vol - 1;
}
 
/*+fi
 -------------------------------------------------------------------------
  Internal Function del_one_volume

  Abstract
     Delete one volume in the Comp_Volume list if given its index.
     It also output the new number of volumes in the list.

  Returns
	1 if success
	0 if fails

 -------------------------------------------------------------------------
*/

static int del_one_volume(Vol,nb_vol,vol_ind)				 
struct Comp_Volume Vol[];   /* [O]   Table of volume where to delete */
int               *nb_vol;  /* [I/O] Number of volume */
int                vol_ind; /* [I]   The indice of the volume to delete */
/*
-fi */
{
  if(*nb_vol <= 0) {printf("No volume defined\n");return 0;}

  if(vol_ind + 1 < *nb_vol)
   {
     memcpy(&Vol[vol_ind],&Vol[vol_ind+1],
	    (*nb_vol - vol_ind - 1) * sizeof(struct Comp_Volume));
   }
  *nb_vol = *nb_vol - 1;
  return 1;
}
/*+fi
 -------------------------------------------------------------------------
  Internal Function SMfound_object_by_name

  Abstract
	Given the split name of a SMAN object and its type, retrieve the 
	corresponding id and mod_env of that object.

  Returns
	1 if success
	0 if fails


 -------------------------------------------------------------------------
*/
int SMfound_object_by_name(name,type,object,mod_env)
char             *name;    /* [I] name to search                             */
IGRshort          type;    /* [I] Type of the object                         */
struct GRid      *object;  /* [O] The returned object (can be NULL)          */ 
struct GRmd_env  *mod_env; /* [O] The module env of the object (can be NULL) */
/*
-fi */
{
  IGRlong           status,msg;
  struct SMObjList  list;
  struct ACrg_coll  crit;
 

  strcpy(crit.name, "name");
  crit.desc.type = AC_ATTRIB_TEXT;
  strcpy(crit.desc.value.att_txt,name);
  list.list = NULL;
  status = SM$CritSel(msg     = &msg, 
		      options = 0,
		      type    = type,
		      nb_crit = 1,
		      crit    = &crit,
		      list    = &list);
  if(!(status & 1) || msg != MSSUCC)
   { printf("Error Criter Selection"); return 0; }
  if(list.nb_objects <= 0) return 0;
 
  if(object)  *object = list.list[0].obj_id;
  if(mod_env) *mod_env = list.list[0].mod_env;
  if(list.list) free(list.list);
  return 1;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function get_display_option

  Abstract
	Fill the structure Disp_Opt with the info given in the form.
  Returns
        nothing, it is a void function.

 -------------------------------------------------------------------------
*/
 

static void get_display_option(form,disp)
Form             form;          /* [I] form pointer    */
struct Disp_Opt *disp;          /* [O] display options */
/*
-fi */
{
  int    state;
  double offset;

  disp->opt = 0;

  /* Get the selected justification button */

  FIget_justif(form,&disp->opt);

  /* Option for compart */

  FIg_get_state(form,G_COMP_COG,&state);
  if(state) disp->opt |= SM_CMP_DSP_CMP_COG_PT; 
  FIg_get_state(form,G_COMP_NAME,&state);
  if(state) disp->opt |= SM_CMP_DSP_CMP_COG_NAME;

  /* Option for Volume */

  FIg_get_state(form,G_VOL_COG,&state);
  if(state) disp->opt |= SM_CMP_DSP_RT_COG_PT; 
  FIg_get_state(form,G_VOL_NAME,&state);
  if(state) disp->opt |= SM_CMP_DSP_RT_COG_NAME;

 /* MODIF PL JUNE 94 : if displays the volumes cog or name they need */
  /* to be computed */

  if( (disp->opt & SM_CMP_DSP_RT_COG_NAME) || (disp->opt & SM_CMP_DSP_RT_COG_PT))
        disp->opt |= SM_CMP_CAL_VOLS;
  
  FIg_get_value(form,G_DX,&offset);
  disp->dx = (int)offset;
  FIg_get_value(form,G_DY,&offset);
  disp->dy = (int)offset;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function is_exclude

  Abstract
	Determine if the given volume is exclude or include . 

  Returns
	1 if the volume is exclude
	0 otherwise

 -------------------------------------------------------------------------
*/

static int is_exclude(one_vol)
struct Comp_Volume *one_vol;  /* [I] The volume to determine */
/*
-fi */
{
  int i;

  if(one_vol->nb_attr <= 0)
   {printf("Error, no attribute for volume %d\n",one_vol->id.objid);return 0;}
  for(i=0; i < one_vol->nb_attr; i++)
   {
     if(strcmp(one_vol->ACrg[i].name,"exclude") == 0)
       if(strcmp(one_vol->ACrg[i].desc.value.att_txt,"no") == 0) return 0;
	  else return 1;
   } 
  return 0;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function one_include_vol

  Abstract
	Determine if there is at least one include volume defined
	in the Comp_Volume list.

  Returns
	1 if there is at least one
	0 otherwise

 -------------------------------------------------------------------------
*/

static int one_include_vol(Vol,nb_vol)
struct Comp_Volume Vol[];               /* [I] the table of volume */
int                nb_vol;              /* [I] Number of volume    */
/*
-fi */
{
  int i;

  if(nb_vol == 0) return 0;
  for(i = 0; i < nb_vol; i++)
    if(!is_exclude(&Vol[i])) return 1;
  return 0;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function place_volume_in_form

  Abstract
	Displays the list of the volumes in the form, depending on
	the form_state (INC_LIST or EXC_LIST).

  Algorithm

	For each volume in the Comp_Volume list
	    if it is an exclude volume and form_state = EXC_LIST or
	    if it is not an exclude volume and form_state = INC_LIST

		Then put that volume name in the G_VOL_LIST field.
		(It also verify if it is a compart to put a '*' in the next col)


  Returns
        nothing, it is a void function.


 -------------------------------------------------------------------------
*/

static void place_volume_in_form(form,nb_vol,Vol,form_state)
Form               form;         /* [I] form pointer                   */
int                nb_vol;       /* [I] number of volumes              */
struct Comp_Volume Vol[];        /* [I] Buffer contanining the volumes */
IGRint             form_state;   /* [I] INC_LIST or EXC_LIST           */
/*
-fi */
{
  int i,exclude;
  int is_exc,row;


#ifdef vdsDEBUG
  printf("\tnb_vol: %d\n", nb_vol);
  for(i = 0; i < nb_vol; i++)
   {
     printf("\t  Vol[%d]: name:%s  id:%d  os:%d\n", 
			i,Vol[i].name, Vol[i].id.objid, Vol[i].id.osnum);
   }
#endif

  /* Clear field of any previous row information */ 
  FIfld_set_num_rows(form, G_VOL_LIST, 0);

  exclude = (form_state == EXC_LIST) ? 1 : 0;
  row = 0;

  for(i = 0; i < nb_vol; i++)
   {
     is_exc = is_exclude(&Vol[i]);

     if( (exclude && is_exc) || (!exclude && !is_exc) )
      {
	FIfld_set_text(form,G_VOL_LIST,row,0,Vol[i].name,0);
  	FIfld_set_default_text(form,G_VOL_LIST,row,0,Vol[i].name,0);
	if(SMIsKindOf(&Vol[i].id,OPP_SMcomp_class_id))
	 {
	   FIfld_set_text(form,G_VOL_LIST,row,1,"*",0);
	   FIfld_set_default_text(form,G_VOL_LIST,row,1,"*",0);
	 }
	row++;
      }
   }

/* TR_179900488: Makes Exclude listing incorrect as it's typically larger
		 than Include listing, so, commented out next two lines.
		 Also, each line is automatically allocated.
  FIfld_set_num_rows(form,G_VOL_LIST,row);
  FIfld_set_max_num_rows(form,G_VOL_LIST,row);
*/

}	

/*+fi
 -------------------------------------------------------------------------
  Internal Function find_index_select_volume

  Abstract
	Retrieve the index in the Comp_Volume table and the row 
	in the G_VOL_LIST gadget of the selected volume. 

  Returns
	0 if there is no selected volume or if it is not in the table
	1 otherwise.

 -------------------------------------------------------------------------
*/


static int find_index_select_volume(form,Vol,nb_vol,vol_ind,row)
Form             form;     /* [I] form pointer                               */
struct Comp_Volume Vol[];  /* [I] the table of volume                        */
int              nb_vol;   /* [I] Number of volume                           */
int              *vol_ind; /* [O] Index in the table of the selected vol     */
int              *row;     /* [O] Row in the form list of the selected vol   */
/*
-fi */
{
  int  i,num_rows,sel,pos;
  char name[DI_PATH_MAX];

  sel = 0;
  FIfld_get_num_rows(form,G_VOL_LIST,&num_rows);
  for(i = 0; i < num_rows; i++)
   {
     FIfld_get_select(form,G_VOL_LIST,i,0,&sel);
     if(sel) break;
   }
  if(!sel) return 0; /* No volume selected */

  FIfld_get_text(form,G_VOL_LIST,i,0,DI_PATH_MAX,(unsigned char*)name,&sel,&pos);
  if(!find_vol_index(Vol,nb_vol,name,(struct GRid *)NULL,vol_ind))
   {printf("Volume not found\n");return 0;}

  if(row) *row = i;
  return 1;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function select_list_vol

  Abstract

	This function is called when there is one volume selected 
	in the form.
	It erases hilite on the previous selected vol and hilite the
	new one.
	Then if state_del = 1, that means the volume is selected to be
	deleted.

  Returns
        nothing, it is a void function.


 -------------------------------------------------------------------------
*/


static void select_list_vol(form,Vol,nb_vol,state_del,sel_vol)
Form               form;        /* [I] form pointer                        */
struct Comp_Volume Vol[];       /* [I] Table of volume                     */
int                nb_vol;      /* [I] Number of volume                    */
IGRboolean         state_del;   /* [I] control delete state or not         */
struct GRid        *sel_vol;    /* [I/O] Preceding and new select volume   */
/*
-fi */
{ 
  IGRlong msg;
  char    my_msg[80];
  int     sel,vol_ind;

  sel = find_index_select_volume(form,Vol,nb_vol,&vol_ind,(int *)NULL);
  
  /* Dehilite preceding volumes and hilite new select */

  if(sel_vol->objid != NULL_OBJID)
    dp$display(msg = &msg, oids = sel_vol, mode = GRhhd);
    
  if(sel)
   {
     dp$display(msg = &msg, oids = &Vol[vol_ind].id, mode = GRhd);
     *sel_vol = Vol[vol_ind].id;
   }
  else sel_vol->objid = NULL_OBJID;
     
  if(state_del) /* User select for remove */
   {
     if(sel)  /* One row is selected : user must valid with del button*/
      {
	ex$message( msgnumb = SM_I_CmValDel, buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
      }
     else /* First select row */
      {
	ex$message( msgnumb = SM_I_CmSelVolDel, buff = my_msg);
	FIg_set_text(form,FI_MSG_FIELD,my_msg);
      }
     return;
   }
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function ret_all_comp_att 

  Abstract
	Retrieve all the attributes of the given compartment and assign 
	them a type (SM_STATIC_ATT | SM_SYST_ATT if they are needed,
	SM_STATIC_ATT | SM_USER_ATT if not).

  Returns

	1 if success
	0 if fails

 -------------------------------------------------------------------------
*/

static int ret_all_comp_att(
struct GRid      *comp_id,   /* [I] Compartment id                    */        
int              *nb_att,    /* [O] Number of attributes              */
struct ACrg_coll *ACrg,      /* [O] ACrg_collection of all Attributes */
IGRshort         *att_type   /* [O] att_type                          */
)
/*
-fi */
{
  int     i,j;
  IGRlong msg;
  IGRint  status;

  /* List of needed attributes for a compartment */

  static char *NeedAtt[] = {
    "name", "dead_weight", "grp", "sub_grp", "h_type", "short_desc",
    "descript", "location", "struct_coef", "permeability", "zone", "overlap",
    "tightness", "expected_vol", "expected_area", "space_class",
    "pseudo", "x_offset", "y_offset",NULL};
		
  
  /* Get attributes of the compart */

  status = om$send( msg = message SMcomp.SMListAtt
		   (&msg,SM_MAX_CO_ATTR ,nb_att,ACrg,att_type),
		   senderid = NULL_OBJID,
		   targetid = comp_id->objid,
		   targetos = comp_id->osnum);
  if(!(status & msg & 1)) 
    {printf("Problem getting compartment attributes %d,%d\n",
	    comp_id->objid,comp_id->osnum);return 0;}


   /* For static attributes, check if Needed (SM_STATIC_ATT) or not    */
   /* This is done because this info is lost for database attributes */

  for(i = 0; i < *nb_att; i++)
   {
     j = 0;
     if(!(att_type[i] & SM_STATIC_ATT)) continue;
     while(NeedAtt[j])
     {
       if(!strcmp(NeedAtt[j],ACrg[i].name))
	{att_type[i] = SM_STATIC_ATT | SM_SYST_ATT; break;}
       j++;
     }
     if(!NeedAtt[j]) /* attributes is user */
       att_type[i] = SM_STATIC_ATT | SM_USER_ATT;
   }
  return 1;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function is_define_attr

  Abstract
	This function look for the given attribute name in the list
	of attributes.

  Returns
	1 if the attribute is found in the list.
	0 otherwise.

 -------------------------------------------------------------------------
*/

static int is_define_attr(att_name,att,nb_att)
char att_name[];              /* [I] name of the attribute to find      */
struct	ACrg_coll  att[];     /* [I] list of attributes where to search */
int nb_att;                   /* [I] nb of attributes in the att list   */
/*
-fi */
{
  int i;

  for(i=0;i<nb_att;i++)
    if(strcmp(att_name,att[i].name) == 0) return 1;
  return 0;
}
	      

/*+fi
 -------------------------------------------------------------------------
  Internal Function parse_att

  Abstract
	That function parses the list of attributes (static or dynamic given
	by type_fam) into an ACrg_coll.
	It also output the type of the attribute:
		. type_fam | SM_SYST_ATT if the attribute is in NeedAtt .
		. type_fam | SM_USER_ATT otherwise.

  Returns
        nothing, it is a void function.


 -------------------------------------------------------------------------
*/

static void parse_att(NeedAtt,att_fam,nb_to_parse,type_fam,
		      att,att_type,nb_attr)
struct init_att        *NeedAtt;    /* [I] Need Attributes for object */
struct  VDSatt_family  att_fam[];   /* [I] Family to parse */
int                    nb_to_parse; /* [I] Number of element of family */
IGRshort               type_fam;    /* [I] SM_STATIC_ATT or SM_DYNAMIC_ATT */
struct	ACrg_coll      att[];       /* [O] Array of attributes */
IGRshort               att_type[];  /* [O] Array of type of attributes */ 
int                    *nb_attr;    /* [I/O] Number of attributes    */
/*
-fi */
{     
  int i,j;

#ifdef JJ_DEBUG
  if(type_fam ==  SM_STATIC_ATT)
    printf("\n-------------- Static attributes -------------------\n");
  else
    printf("\n-------------- Dynamic attrinutes ------------------\n");
#endif


  for(i = 0; i < nb_to_parse; i++)
   {

#ifdef JJ_DEBUG
     printf("Attribut %s ",att_fam[i].attr.name);
     if(att_fam[i].attr.desc.type == AC_ATTRIB_TEXT)
       printf("Value %s \n",att_fam[i].attr.desc.value.att_txt);
     else
       printf("Value %g \n",att_fam[i].attr.desc.value.att_exp);
#endif

     strcpy(att[*nb_attr].name,att_fam[i].attr.name);
     j = 0;
     while(NeedAtt[j].name)
      {
	if(strcmp(att_fam[i].attr.name,NeedAtt[j].name) == 0)
	 {
	   att_type[*nb_attr] =  SM_SYST_ATT | type_fam;
	   break;
	 }
	j++;
      }
     if(!NeedAtt[j].name)
       att_type[*nb_attr] = SM_USER_ATT | type_fam;
     
     switch(att_fam[i].attr.desc.type)
      {
      case AC_ATTRIB_TEXT:
	att[*nb_attr].desc.type =  AC_ATTRIB_TEXT;
	strcpy(att[*nb_attr].desc.value.att_txt,
	       att_fam[i].attr.desc.value.att_txt);
	break;
      case AC_ATTRIB_DOUBLE:
	att[*nb_attr].desc.type =  AC_ATTRIB_DOUBLE;
	att[*nb_attr].desc.value.att_exp = att_fam[i].attr.desc.value.att_exp;
	break;
      default:
	printf("Unknown type of attributes\n");
      }
     (*nb_attr)++;
   }
}
/*+fi
 -------------------------------------------------------------------------
  Internal Function SMParseDynColl

  moved (with a copy of statics parse_att and is_define_att)
  to smcomp/func/SMCompDyn.I

 -------------------------------------------------------------------------
*/

/*+fi
 -------------------------------------------------------------------------
  Internal Function del_one_attrib

  Abstract
      Delete one attribute in the given ACrg_coll, if given its name.


  Returns
  	0 if the attribute is not found or if the list is empty
	1 otherwise.

 -------------------------------------------------------------------------
*/

int 
del_one_attrib(work_att,work_att_type,work_nb_att,name) 
struct ACrg_coll work_att[];         /* [O] Array of ACrg_col to put attr    */
IGRshort         work_att_type[];    /* [O] Array of sman type of attributes */
int              *work_nb_att;       /* [O] Number of element in  ACrg       */
char             *name;              /* [I] Name of attribute to delete      */
/*
-fi */
{
  int att_ind = 0,i;

  if(*work_nb_att <= 0) {printf("No attribute defined\n");return 0;}

  for(i = 0; i < *work_nb_att; i++)
    if(strcmp(work_att[i].name,name) == 0)
     {
       att_ind = i;
       break;
     }
  
  if(i ==  *work_nb_att) return 0; /* Attribute not found */

  if(att_ind + 1 < *work_nb_att)
   {
     memcpy(&work_att[att_ind],&work_att[att_ind+1],
	    (*work_nb_att - att_ind - 1) * sizeof(struct ACrg_coll));
     memcpy(&work_att_type[att_ind],&work_att_type[att_ind+1],
	    (*work_nb_att - att_ind - 1) * sizeof(IGRshort));
   }

  *work_nb_att = *work_nb_att - 1;
  return 1;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMput_alternate_gadget

  Abstract
	Set the gadget with the property FI_POPUP_ASSO_LIST or disable 
	FI_POPUP_ASSO_LIST if the attribute to set is static, 
	then put the value in the gadget field.

  Algorithm

  Returns
        nothing, it is a void function.

 -------------------------------------------------------------------------
*/

void 
SMput_alternate_gadget(form,label,sm_type,val_txt)
Form     form;         /* [I] Pointer to the form          */
int      label;        /* [I] Alternate gadget if dynamic  */
IGRshort sm_type;      /* [I] Type of attributes           */
char     *val_txt;     /* [I] String to put in gadget      */

/*
-fi */

{
  long attr_mask;

  SetProc ( SMput_alternate_gadget ); Begin

  /* Jean 1 July 93 : put SM_OTHER_ATT (calculate attribute) as non modifiable */

  if(sm_type & SM_STATIC_ATT || sm_type & SM_OTHER_ATT)
   {
     FIfld_get_attr(form,label,0,&attr_mask);
     if(attr_mask & FI_POPUP_ASSO_LIST)
       FIfld_set_attr(form,label,0,attr_mask ^ FI_POPUP_ASSO_LIST); 
   }
  else
   {
     FIfld_get_attr(form,label,0,&attr_mask);
     FIfld_set_attr(form,label,0,attr_mask | FI_POPUP_ASSO_LIST);
   }
  SMVA_set_default_text(form,1,label,val_txt);

  End
}



/*+me
 -------------------------------------------------------------------------
  Public Message init_form_new_comp

  Abstract
	
	It initialise the form for a new compart.

  Arguments
	long	*sts		O 	completion code.
	IGRboolean bClearVols	I	Flag to indicate wether the vols
					associated with the comp should
					be cleared or not

				TRUE	Clear Volumes
				FALSE	Don't Clear Volumes

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method init_form_new_comp( long *sts;
			   IGRboolean bClearVols )
{
  int 	type;

  SetProc ( init_form_new_comp ); Begin
  *sts = OM_S_SUCCESS;

  /* No compart defined */
  me->comp_id.objid = NULL_OBJID;
  me->sel_vol.objid = NULL_OBJID;

  if( bClearVols )	/* Clear Volumes */
  { 
    /* No volumes */
    me->save_nb_vol = me->work_nb_vol = 0;
  }

  /* Copy attributes */
  memcpy(me->work_att,me->save_att, me->save_nb_att * sizeof(struct ACrg_coll));
  memcpy(me->work_att_type,me->save_att_type,me->save_nb_att * sizeof(IGRshort));
  me->work_nb_att =  me->save_nb_att;

  /* If compartment then search first list of all dead weight and group */
  /* If hull compart, the dead weight and group are fixed */

  switch(me->mytype)
   {
   case PLACE: case MODIFY:
          
     /* Change attribut "comp_type" to SM_REG */ 
     SMSetAttr("comp_type",me->work_att,me->work_att_type,&me->work_nb_att,
	       AC_ATTRIB_TEXT,0.0,"compartment",
	       SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
     break;
	
   case PL_COMP_HULL: case MD_COMP_HULL:
     /* Change attribut "comp_type" if hull compartment */ 
     SMSetAttr("comp_type",me->work_att,me->work_att_type,&me->work_nb_att,
	       AC_ATTRIB_TEXT,0.0,"hull compartment",
	       SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
     break;
   }

  /* Put main parameters in form */ 
  __DBGpr_int ( "select option ", me->select_opt );
/*  if ( me->select_opt != PME_SELECT ) { */
    om$send(msg = message SMCmdComp.put_comp_att_in_form(sts),
	    targetid = my_id);
    as$status(sts = (*sts),action = GOTO_VALUE,value = wrapup);
/*  } */
  
  /* Put display parameters in form */
  om$send(msg = message SMCmdComp.put_disp_att_in_form(sts),
	  targetid = my_id);
 
  /* Put user attribut in form */
  
  type = me->form_state == DYN_LIST ? 1 : 0;
  om$send(msg = message SMCmdComp.VDSetRgAtt(sts),
	     targetid = my_id);
  om$send(msg = message SMCmdComp.VDSetAttList(sts, type),
	     targetid = my_id);


  /* Put geometric information in form */
  om$send(msg = message SMCmdComp.put_geom_info(sts),targetid = my_id);

 /* FIfld_pos_cursor(me->forms[me->idx_form].form_ptr,G_NAME,0,0,0,0,0,0); */
 
  *sts = MSSUCC;
  End
  return OM_S_SUCCESS;

 wrapup:

  *sts = OM_E_ABORT;
  End
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message control_comp

  Abstract
	
	It displays all the parameters for the located compart and fills 
	the instances with the info.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method control_comp( long *sts )
{
  IGRlong             msg,status;
  struct GRid         vol[SM_MAX_ALLOW_VOL],rg[SM_MAX_ALLOW_VOL];
  struct GRmdenv_info md_env[SM_MAX_ALLOW_VOL];
  struct GRmd_env     vol_env;
  int                 type, tt_number,i,vol_in_list; 

  SetProc ( control_comp ); Begin
  *sts = OM_S_SUCCESS;
  me->sel_vol.objid = NULL_OBJID;

  /* Get the list of volumes */
  status = om$send( msg = message SMcomp.SMGetVolInfo
		   (&msg,SM_MAX_ALLOW_VOL,&me->save_nb_vol,&tt_number,
		    vol,rg,NULL,md_env),
		   targetid = me->comp_id.objid,
		   targetos = me->comp_id.osnum);
  if(!(status & msg & 1))
   {printf("Error get volumes for compart id %d \n",me->comp_id.objid);
    goto wrapup;}

  vol_in_list = 0;
  for(i = 0 ; i < me->save_nb_vol; i++)
   {
     vol_env.md_env = md_env[i];
     vol_env.md_id.osnum = vol[i].osnum;
     ex$get_modid(mod_osnum = vol_env.md_id.osnum,
		  mod_id = &vol_env.md_id.objid);
     add_one_volume(me->save_vol,&vol_in_list,&vol[i],&vol_env,&rg[i]);
   }

  /* Copy volumes */
  memcpy(me->work_vol,me->save_vol,SM_MAX_ALLOW_VOL *sizeof(struct Comp_Volume));
  me->work_nb_vol = me->save_nb_vol;

  /* Get attributes of the compart */
  if(!ret_all_comp_att(&me->comp_id,
		       &me->save_nb_att,me->save_att,me->save_att_type))
    goto wrapup;

#ifdef JJ_DEBUG     
   print_all_attr(me->save_att,me->save_att_type,me->save_nb_att);
#endif

  /* Copy attributes */
  memcpy(me->work_att,me->save_att, me->save_nb_att * sizeof(struct ACrg_coll));
  memcpy(me->work_att_type,me->save_att_type,me->save_nb_att * sizeof(IGRshort));
  me->work_nb_att =  me->save_nb_att;
 
  /* Set the compartment type  whether from NFM or from PME */ 
  om$send(msg = message SMCmdComp.set_compart_dbtype(sts),
	  targetid = my_id);

  /* Put main parameters in form */ 
  om$send(msg = message SMCmdComp.put_comp_att_in_form(sts),
	  targetid = my_id);
  
  /* Retrieve display option for compart and volume */
  om$send(msg = message SMCmdComp.put_disp_att_in_form(sts),
	  targetid = my_id);

  /* Put user attribut in form */

  type = me->form_state == DYN_LIST ? 1 : 0;
  om$send(msg = message SMCmdComp.VDSetRgAtt(sts),
	     targetid = my_id);
  om$send(msg = message SMCmdComp.VDSetAttList(sts, type),
	     targetid = my_id);

   
  memcpy(me->work_vol,me->save_vol,
	 SM_MAX_ALLOW_VOL * sizeof(struct Comp_Volume));
  me->work_nb_vol = me->save_nb_vol;

  *sts = OM_S_SUCCESS;
  End
  return OM_S_SUCCESS;

 wrapup:
  *sts = OM_E_ABORT;
  End
  return OM_S_SUCCESS;

} 

/*+me
 -------------------------------------------------------------------------
  Public Message SMplace_comp

  Abstract
	
	It constructs and place the compart macro .
	It also need the me->work_vol struct for volumes parameters.

  Arguments
	long	*msg		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method SMplace_comp(IGRlong *msg)
{
  IGRlong 	status, rc;
  struct GRid 	mac;
  int 		suc,i, cn_type;
  int 		nb_temp;   /* Number of templates of the compart */
  struct GRid 	CompDynRoots[SM_MAX_ALLOW_VOL];
  struct GRid 	temp[3 + 3 * SM_MAX_ALLOW_VOL]; /* Template of the compart */
  char 		name_comp[DI_PATH_MAX],val_txt[ATTR_TXT];
  IGRchar	FileId[VDPOBID_LEN];
  OMuword	curOs;
  IGRchar	my_msg[80];
  struct GRsymbology	symb;
  IGRlong		size, nret;

  SetProc ( SMplace_comp ); Begin
  *msg = OM_S_SUCCESS;
 
  /* Create ACrg Compart attribute  */
  if(!SMCompInitCol(&temp[0],me->work_nb_vol,CompDynRoots,
		    &me->ModuleInfo))
   { printf("Error SMCompInitCol for comp\n"); goto wrapup;}
  
  nb_temp = 1;  /* First root is ACrg */
  for(i = 0; i < me->work_nb_vol; i++)
   {
     temp[nb_temp] = CompDynRoots[i] ; 
     nb_temp++;
     status = as$make_source(go_grid = me->work_vol[i].id,
			     mod_env = &me->work_vol[i].mod_env,
			     as_grid = &temp[nb_temp]);
     as$status(action = RET_STATUS);
     nb_temp++;
   }

// TR179800992 The ifdef was commented out
#ifdef JJ_DEBUG     
  for(i = 0; i < nb_temp; i++) {
    printf("temp: %d, %d\n", temp[i].objid, temp[i].osnum); 
  }
#endif
  
  /* Construct the compart */
  mac.osnum = me->ModuleInfo.md_id.osnum;
  status = om$construct(classid = OPP_SMcomp_class_id,
			osnum   = mac.osnum,
			p_objid = &mac.objid );
  if(!(status & 1))
   {printf("erreur creating macro\n"); goto wrapup; }
 
  /* Put the attributes of each volume */
  for( i=0; i<me->work_nb_vol; i++)
   {
     status = om$send(msg = message SMcoll.ACmod_list_attribute
		      (msg,me->work_vol[i].nb_attr,me->work_vol[i].ACrg),
		      targetid = CompDynRoots[i].objid,
		      targetos = CompDynRoots[i].osnum);
     if(!(status & *msg & 1))
      {printf("Erreur Modify list attributes vol %d col %d\n",
	      me->work_vol[i].id.objid,CompDynRoots[i].objid);
       goto wrapup;}
   }
  
  status = om$send( msg = message SMcomp.ACmplace
		   (&suc, AChdr_nodisplay | AChdr_nocompute,0,
		    "SMcomp", nb_temp, temp, &me->ModuleInfo),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  if(!(status & suc & 1))
   {
     printf("Placement of the compartment_macro failed\n");
     om$send(msg = message Root.delete(0),
	     targetid = mac.objid,
	     targetos = mac.osnum);
     goto wrapup;
   }

  /* Jean 8/10/93 */

 if ( me->select_opt == DB_SELECT )
 {
   char family[80],partno[80],partrev[80];

  if(!SMGetAttr("family",me->work_att,(IGRshort *)NULL,me->work_nb_att,
		(int *)NULL,(IGRdouble *)NULL,family,
		(IGRshort *)NULL) ||
     !SMGetAttr("partno",me->work_att,(IGRshort *)NULL,me->work_nb_att,
		(int *)NULL,(IGRdouble *)NULL,partno,
		(IGRshort *)NULL) ||
     !SMGetAttr("partrev",me->work_att,(IGRshort *)NULL,me->work_nb_att,
		(int *)NULL,(IGRdouble *)NULL,partrev,
		(IGRshort *)NULL))
   {printf("Erreur retreiving compart info for database\n"); goto wrapup;}
  
   status = om$send(msg = message SMcoll.SMSetDbInfo
		   (msg,"compartment",family,partno,partrev),
		    targetid = temp[0].objid,
		    targetos = temp[0].osnum);
   if(!(status & *msg & 1))
    {printf("Error set database info in SMcoll\n");goto wrapup;}
   
 }

  for ( i = 0; i < me->work_nb_att; i++ )
  {
     __DBGpr_int ( "Attr No ", i );
     __DBGpr_int ( "Work Att Type ", me->work_att_type[i] );
     __DBGpr_str ( "Att Name ", me->work_att[i].name );
     __DBGpr_int ( "Att Type ", me->work_att[i].desc.type );
     __DBGpr_str ( "Att Value ", me->work_att[i].desc.value.att_txt );
  }

  /* Put the attributes of the compart */
  status = om$send(msg = message SMmgr.SMSetAtt
		   (msg,me->work_nb_att,me->work_att,me->work_att_type),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  as$status(sts = (status & *msg),action = GOTO_VALUE, value = wrapup);

  SMGetAttr("name",me->work_att,me->work_att_type,me->work_nb_att,
	   (int *)NULL,(double *)NULL,name_comp,(IGRshort *)NULL);
  
  status = om$send(msg = message GRgraphics.GRputname(msg, name_comp),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  if(!(status & *msg & 1))
   {printf("Error put name of the compart\n");goto wrapup;}
 
  cn_type  = ND_COMP;     /* recompute the object */
  nd$wait_batch(type       = GR_GEOM_POSTED,
		l_object   = &mac,
		l_obj_info = &cn_type,
		nb_obj     = 1); 

  nd$exec_batch(mode = 0);
	  /* addedfor TR-179800514 */
	status = VDgetEmsBooleanStatus(msg);
	if( *msg == 0 ){
     	om$send(msg = message Root.delete(0),
             targetid = mac.objid,
             targetos = mac.osnum);
	      mac.objid = NULL_OBJID;
	      mac.osnum = 0;
	    me->comp_id = mac;
	return 0;
	}

  if(me->mytype == PLACE && me->select_opt == DB_SELECT ) /* Jean : 6/28/93 : Don't put symbology if HULL */
   {
     status = om$send(msg = message SMcomp.SMSetDwSymb(msg),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     if(!(status & *msg & 1)) {
	ex$message(msgnumb = SM_W_CmNoSymb, buff = my_msg);
	FIg_set_text(me->forms[me->idx_form].form_ptr, FI_MSG_FIELD, my_msg );
     }
   }
 else
   {
        size = sizeof( struct GRsymbology );
        gr$get_active_display( msg    = &rc ,
                                sizbuf = &size ,
                                buffer = &symb.display_attr ,
                                nret   = &nret  );

        gr$get_active_level(  msg    = &rc,
                                sizbuf = &size,
                                buffer = &symb.level,
                                nret   = &nret );

        status = om$send( msg = message GRvg.GRputsymb( &rc, &symb),
                        targetid = mac.objid,
                        targetos = mac.osnum );

        if ( !(status & rc & 1) ) printf("\tGRvg.GRputsymb failed\n");

   }


  status = om$send(msg = message NDnode.NDdisplay(0, GRbd, &me->ModuleInfo),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  as$status();

  status = om$send(msg = message SMmgr.SMSetState(SM_NEW),
		   targetid = mac.objid,
		   targetos = mac.osnum);
  as$status(); 

  // TR179800992 These are debug statements, added ifdef
  /* Put compart  in database only if real compart */
#ifdef JJ_DEBUG     
    printf ("quantity = %d\n", me->db_info.quantity);
    printf ("serial_no= %d\n", me->db_info.serial_no);
    printf ("catalog  = %s\n", me->db_info.catalog);
    printf ("part_num = %s\n", me->db_info.part_num);
    printf ("revision = %s\n", me->db_info.revision);
    printf ("usage    = %s\n", me->db_info.usage);
#endif

  SMGetAttr("pseudo",me->work_att,me->work_att_type,me->work_nb_att,
	   (int *)NULL,(double *)NULL,val_txt,(IGRshort *)NULL);
  if(strcmp(val_txt,"no") == 0)
   {
     status = om$send(msg = message ACdb_info.ACset_db_info(msg,&me->db_info),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     as$status(sts = (status & *msg));
   }

  me->comp_id = mac;

  if ( me->CompPMObid[0] != '\0' )
  {
    __DBGpr_str ("Compartment PM Obid", me->CompPMObid );

    ex$get_cur_mod( osnum = &curOs );
    status = VDPGetFileId( msg, curOs, FileId );
    CheckRC( status, *msg );

    status = VDPPmeEnable( msg, me->comp_id, me->CompPMObid );
    CheckRC ( status, *msg );

    /* Place compartment in the database */

    __DBGpr_obj( "Compartment Object Id", me->comp_id );

    status =  VDPplaceSpatialContext (  msg,
					'C',
					me->CompPMObid,
					FileId,
					me->comp_id.objid );
    if (!(status & *msg & 1 ))
	UI_status ("Compartment not posted");
    __CheckRC( status, *msg, "VDPplaceSpatialContext", wrapup );

  }

  *msg = MSSUCC;
  End
  return OM_S_SUCCESS;

 wrapup:
  *msg = MSFAIL;
  End
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message SMmodif_comp

  Abstract
	
	 It modify the compart macro with the new parameter saved in the form.

  Arguments
	long	*msg		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method SMmodif_comp(IGRlong *msg)
{
  IGRlong   status;
  int 	    modif_flag,wait_batch,cn_type;
  IGRchar   new_name[DI_PATH_MAX],old_name[DI_PATH_MAX],
  	    symb_att[ATTR_TXT],old_symb[ATTR_TXT],new_symb[ATTR_TXT];
  IGRdouble val_db;
  struct    Disp_Opt old_disp;
  int       old_nb_att;
  struct    ACrg_coll old_ACrg[SM_MAX_CO_ATTR ];
  int	    oldAttRev = 0, workAttRev = 0;

  SetProc ( SMmodif_comp ); Begin
  *msg = OM_S_SUCCESS;

  modif_flag = NO_CHANGE;

  /* Change eventually list of volumes for the compart and their attributes */
  om$send(msg = message SMCmdComp.SMChgListVol(msg,&modif_flag),
	  targetid = my_id);
  as$status(sts = *msg,action = GOTO_VALUE,value = wrapup);
 
  if ( me->select_opt == DB_SELECT )
  {

  if(!SMGetSymbTrack(symb_att,NULL))
   {printf("Error attribute driven symbology\n"); goto wrapup;}
 
  /* Retreive old dead weight before modifying attributes */
  status = om$send(msg = message SMcomp.SMGetAttTxt
		   (msg,symb_att,old_symb,(IGRshort *)NULL),
		   targetid = me->comp_id.objid,
		   targetos = me->comp_id.osnum);
  if(!(status & *msg & 1))
   {printf("Erreur get dead weight for object %d %d\n",
	   me->comp_id.objid,me->comp_id.osnum); goto wrapup;}
  }
  
  status = om$send( msg = message SMcomp.SMListAtt
		    (msg,SM_MAX_CO_ATTR ,
		     &old_nb_att,old_ACrg,NULL),
		    targetid = me->comp_id.objid,
		    targetos = me->comp_id.osnum);
  as$status(sts = (status & *msg),action = GOTO_VALUE, value = wrapup);

  /* 
   * Some duplicate attributes found. Have to review attibutes first to
   * remove duplicate ones
   */
  oldAttRev  = SMAttRev(&old_nb_att, old_ACrg, NULL);
  workAttRev = SMAttRev(&me->work_nb_att, me->work_att, me->work_att_type);
  //if(!SMIsACrgEqual(old_ACrg,old_nb_att,me->work_att,me->work_nb_att) )
  if(!SMIsACrgEqual(old_ACrg,old_nb_att,me->work_att,me->work_nb_att) 
     || oldAttRev || workAttRev ) 
  {
#ifdef DEBUG
    int i;
    for(i = 0; i < old_nb_att; i++)
    {
        printf("old coll[%d]: name[%s], ", i, old_ACrg[i].name);
        if( old_ACrg[i].desc.type == AC_ATTRIB_TEXT )
        {
    	printf("value[%s]\n", 
    		old_ACrg[i].desc.value.att_txt);
        }
        else if( old_ACrg[i].desc.type == AC_ATTRIB_DOUBLE )
        {
    	printf("value[%d]\n", 
    		old_ACrg[i].desc.value.att_exp);
        }
        else printf("AC_ATTRIB_TYPE_NOT_DEF\n");
    }
    for(i = 0; i < me->work_nb_att; i++)
    {
        printf("work coll[%d]: name[%s], ", i, me->work_att[i].name);
        if( me->work_att[i].desc.type == AC_ATTRIB_TEXT )
        {
    	printf("value[%s]\n", 
    		me->work_att[i].desc.value.att_txt);
        }
        else if( me->work_att[i].desc.type == AC_ATTRIB_DOUBLE )
        {
    	printf("value[%d]\n", 
    		me->work_att[i].desc.value.att_exp);
        }
        else printf("AC_ATTRIB_TYPE_NOT_DEF\n");
    }
#endif

     /* Eventually put attributes of the compartment */
     status = om$send(msg = message SMcomp.SMResetAtt
		      (msg,me->work_nb_att,me->work_att,me->work_att_type),
		      targetid = me->comp_id.objid,
		      targetos = me->comp_id.osnum);
     as$status(sts = (status & *msg),action = GOTO_VALUE,value = wrapup);
     
     modif_flag |= TO_CHANGE_STATE;

    if ( me->select_opt == DB_SELECT )
    {
     /* Is it a change of attribute driven symbology ? */
     SMGetAttr(symb_att,me->work_att,me->work_att_type,me->work_nb_att,
	      (int *)NULL,(double *)NULL,new_symb,(IGRshort *)NULL);

     /* Change of dead weight ==> change of symbology */
     if(strcmp(old_symb,new_symb))
       {
	 status = om$send(msg = message SMcomp.SMSetDwSymb(msg),
			  targetid = me->comp_id.objid,
			  targetos = me->comp_id.osnum);
	 if(!(status & *msg & 1))
	   printf("Warning : can't put dead weight symbology\n");
	 modif_flag |= TO_REDISPLAY;
       }
    }
   }
  
  /* Search if display must be modified */
  /* get all option */
  SMGetAttr("x_offset",old_ACrg,(IGRshort *)NULL,old_nb_att,
	   (int *)NULL,&val_db,(char *)NULL,(IGRshort *)NULL);
  old_disp.dx = (int)val_db;

  SMGetAttr("y_offset",old_ACrg,(IGRshort *)NULL,old_nb_att,
	   (int *)NULL,&val_db,(char *)NULL,(IGRshort *)NULL);
  old_disp.dy = (int)val_db;

  SMGetAttr("cmp_props",old_ACrg,(IGRshort *)NULL,old_nb_att,
	   (int *)NULL,&val_db,(char *)NULL,(IGRshort *)NULL);
  old_disp.opt = (int)val_db;
  	
  if(old_disp.dx  != me->disp.dx ||
     old_disp.dy  != me->disp.dy ||
     old_disp.opt != me->disp.opt)
    modif_flag |= TO_REDISPLAY;

  /* eventually change the name of the compart */

  SMGetAttr("name",me->work_att,me->work_att_type,me->work_nb_att,
	   (int *)NULL,(double *)NULL,new_name,(IGRshort *)NULL);
  SMGetSplitName(&me->comp_id,old_name);

  switch(SMChgElemName(&me->comp_id,new_name,&me->ModuleInfo))
   {
   case 0:
     printf("Warning : can't change_name objid = %d\n",me->comp_id.objid);
     break;
   case 1: modif_flag |= TO_REDISPLAY; break;  /* Real change of name */
   case 3: break;  /* Nothing change */                            
   }
 
  if(modif_flag & TO_RECOMPUTE)
   {
     cn_type    = ND_COMP; /* recompute the object */
     nd$wait_batch(type       = GR_GEOM_POSTED,
		  l_object   = &me->comp_id,
		  l_obj_info = &cn_type,
		  nb_obj     = 1);

     nd$mod_batch(request    = ND_INQ,p_ret_mode = &wait_batch);
     
     if(wait_batch != ND_DEFER) /* Else Nothing to do */
       nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
   }
  else if(modif_flag & TO_REDISPLAY)
   {

     status = om$send(msg = message NDnode.NDdisplay
		      (1,GRbe,&me->ModuleInfo),
		      targetid = me->comp_id.objid,
		      targetos = me->comp_id.osnum);
     as$status();

     status = om$send(msg = message SMcomp.SMModPtTxt
		      (msg,
		       (me->disp.dx != old_disp.dx) ? (&me->disp.dx) : NULL,
		       (me->disp.dy != old_disp.dy) ? (&me->disp.dy) : NULL,
		       (me->disp.opt != old_disp.opt) ? (&me->disp.opt) : NULL,
		       strcmp(new_name,old_name) ? new_name : NULL),
		      targetid = me->comp_id.objid,
		      targetos = me->comp_id.osnum);
     as$status(sts = (status & *msg));

     status = om$send(msg = message NDnode.NDdisplay
		      (1,GRbd,&me->ModuleInfo),
		      targetid = me->comp_id.objid,
		      targetos = me->comp_id.osnum);
     as$status(); 
   }

  if(modif_flag != NO_CHANGE)
   {
     status = om$send(msg = message SMcomp.SMChgState(SM_STATE,SM_MOD),
		      targetid = me->comp_id.objid,
		      targetos = me->comp_id.osnum);
     as$status();
   }

  /* Add it to transaction List */
  status = VDPPmeUpdate ( msg, me->comp_id, me->comp_id );
  CheckRC ( status, *msg );

  *msg = MSSUCC;
  End
  return OM_S_SUCCESS;

 wrapup:
  *msg = MSFAIL;
  End
  return OM_S_SUCCESS;
}



/*+me
 -------------------------------------------------------------------------
  Public Message put_disp_att_in_form

  Abstract
	
	Place the display option in the form in fonction of attributes.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method put_disp_att_in_form(long *sts)
{
  int       type;
  IGRdouble val_db;

  SetProc ( put_disp_att_in_form ); Begin
  *sts = OM_S_SUCCESS;

  if(SMGetAttr("cmp_props",me->work_att,me->work_att_type,me->work_nb_att,
	      &type,&val_db,(char *)NULL,(IGRshort *)NULL))
    me->disp.opt = (IGRshort)val_db;
  else 
    me->disp.opt =  SM_CMP_DSP_CMP_COG_PT | SM_CMP_DSP_CMP_COG_NAME;

  /* get x and y offset */
  if(SMGetAttr("x_offset",me->work_att,me->work_att_type,me->work_nb_att,
	      &type,&val_db,(char *)NULL,(IGRshort *)NULL))
    me->disp.dx = (IGRshort)val_db;
  else 
    me->disp.dx = 0; 

  if(SMGetAttr("y_offset",me->work_att,me->work_att_type,me->work_nb_att,
	      &type,&val_db,(char *)NULL,(IGRshort *)NULL))
    me->disp.dy = (IGRshort)val_db;
  else
    me->disp.dy = 0; 

  FIset_justif(me->forms[me->idx_form].form_ptr,me->disp.opt);
  SMVA_set_default_state(me->forms[me->idx_form].form_ptr,4,
			 G_COMP_COG  , me->disp.opt & SM_CMP_DSP_CMP_COG_PT,
			 G_COMP_NAME , me->disp.opt & SM_CMP_DSP_CMP_COG_NAME,
			 G_VOL_COG   , me->disp.opt & SM_CMP_DSP_RT_COG_PT,
			 G_VOL_NAME  , me->disp.opt & SM_CMP_DSP_RT_COG_NAME);
  SMVA_set_default_value(me->forms[me->idx_form].form_ptr,2,
                         G_DX        , (double)me->disp.dx,
                         G_DY        , (double)me->disp.dy);

  *sts = OM_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message put_list_vol

  Abstract
	
	Put the list of volumes in G_LIST_VOL. 
	Place volume gadget in selectable state.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method put_list_vol(long *sts) 
{
  IGRlong msg;

  SetProc ( put_list_vol ); Begin
  *sts = OM_S_SUCCESS;

  me->state_del = FALSE;
  SMSetSingleSelectMode(me->forms[me->idx_form].form_ptr,G_VOL_LIST,me->work_nb_vol,2);

  if(me->sel_vol.objid != NULL_OBJID)
   {
     dp$display(msg = &msg, oids = &me->sel_vol, mode = GRhhd);
     me->sel_vol.objid = NULL_OBJID;
   }

  place_volume_in_form(me->forms[me->idx_form].form_ptr,
		       me->work_nb_vol,me->work_vol,me->form_state);
  
  SMVA_enable(me->forms[me->idx_form].form_ptr,4,G_ADD_VOL,FI_RESET,FI_ACCEPT,FI_EXECUTE);
  FIg_set_state_off(me->forms[me->idx_form].form_ptr,G_ADD_VOL);
  FIg_set_state_off(me->forms[me->idx_form].form_ptr,G_DEL_VOL);
  FIg_set_state(me->forms[me->idx_form].form_ptr,G_INCLUDE_TOG,
		me->form_state == INC_LIST ? TRUE : FALSE);

  if(me->mytype == PLACE || me->mytype == PL_COMP_HULL)
    if(me->work_nb_vol == 0) { *sts = LOCATE_VOL; goto quit; }

  *sts = OM_S_SUCCESS; 
 quit:
  End
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message add_locate_volume

  Abstract
	
     Add volume(s) located by the users.
     The last selected volumes becomes the current volume               .

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/


method add_locate_volume( long *sts )
{
  IGRlong           status,msg;
  IGRint            nb_obj,nb_add,i,j,vol_ind,num_rows;
  struct GRobj_env  *LocatedObjects;
  struct GRid       vol_id;
  struct GRmd_env   vol_env;
 
  SetProc ( add_locate_volume ); Begin
  *sts = OM_S_SUCCESS;

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
  
  /* Insert the new(s) volume(s) at end of the existing one */ 
  FIfld_get_num_rows(me->forms[me->idx_form].form_ptr,G_VOL_LIST,&num_rows);
  for(i = 0; i < nb_obj ; i++)
   {
     if(!SMIsKindOf(&LocatedObjects[i].obj_id,OPP_SMcomp_class_id) &&
	!SMIsKindOf(&LocatedObjects[i].obj_id,OPP_EMSsolid_class_id)) 
       continue;
   
     /* It can be a pretend */
     status = om$send(msg = message NDmacro.ACreturn_foot
		      (&msg,"",&vol_id,
		       &vol_env.md_env.matrix_type,vol_env.md_env.matrix),
		      targetid = LocatedObjects[i].obj_id.objid,
		      targetos = LocatedObjects[i].obj_id.osnum);
     if(!(status & msg & 1))
      {
	vol_id  = LocatedObjects[i].obj_id;
	vol_env = LocatedObjects[i].mod_env;
      }
     else
      {
	vol_env.md_id.osnum = vol_id.osnum;
	ex$get_modid(mod_osnum = vol_env.md_id.osnum,
		     mod_id = &vol_env.md_id.objid);
      }   

     /* If volume already in the list for compart , ignore it */
     if(find_vol_index(me->work_vol,me->work_nb_vol,(char *)NULL,
		       &vol_id,&vol_ind))
      {
	dp$display(msg = &msg, oids = &vol_id, mode = GRhhd);
	continue;
      }

     vol_ind = add_one_volume(me->work_vol,&me->work_nb_vol,
			      &vol_id,&vol_env,(struct GRid *)NULL);
     if(vol_ind == -1)
      {
	dp$display(msg = &msg, oids = &vol_id, mode = GRhe);
	*sts = TO_MUCH_VOL; ASend_fence(); goto quit;
      }
     
     /* Put attributes include or exclude for the volume */
     SMSetAttr("exclude",me->work_vol[vol_ind].ACrg,
	       me->work_vol[vol_ind].type,
	       &me->work_vol[vol_ind].nb_attr,AC_ATTRIB_TEXT,0.0,
	       me->form_state == EXC_LIST ? "yes" : "no",
	       SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );

     /* Put the name of the volume in form */
     FIfld_set_text(me->forms[me->idx_form].form_ptr,G_VOL_LIST,num_rows,0,
		    me->work_vol[vol_ind].name,FALSE);

     for(j=0; j< num_rows; j++)
      {
        FIfld_set_select(me->forms[me->idx_form].form_ptr,G_VOL_LIST,j,0,FALSE);
	FIfld_set_select(me->forms[me->idx_form].form_ptr,G_VOL_LIST,j,1,FALSE);
      }

     /* Put an asterix if it's a compart and not a volume */
     if(SMIsKindOf(&LocatedObjects[i].obj_id,OPP_SMcomp_class_id))
      {
	/* Verify it's not myself */
	if(me->comp_id.objid == LocatedObjects[i].obj_id.objid &&
	   me->comp_id.osnum == LocatedObjects[i].obj_id.osnum)
	  continue;
	/* Put an asterix in the form */
	FIfld_set_text(me->forms[me->idx_form].form_ptr,G_VOL_LIST,
		       num_rows,1,"*",FALSE);
      }
     
     dp$display(msg = &msg, oids = &me->work_vol[vol_ind].id,mode = GRhhd);
     
     nb_add++;
     num_rows++;
   }
  ASend_fence();
		 
  if(nb_add == 0) {*sts = NO_OBJ_LOCATED; goto quit;}

  FIfld_set_max_num_rows(me->forms[me->idx_form].form_ptr,G_VOL_LIST,me->work_nb_vol);
  
  *sts = MSSUCC;
 quit:
  End
  return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------
  Public Message select_delete_volume

  Abstract
	
         Method called when pushed on the deleted volume button       
 The state_del flag control if it's first time or second time         
 del button is pushed.                                               

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/


method select_delete_volume( long *sts )
{
  IGRlong msg;
  int     vol_ind,select,num_rows,row;
  char    my_msg[80];

  SetProc ( select_locate_volume ); Begin
  *sts = OM_S_SUCCESS;

  FIfld_get_num_rows(me->forms[me->idx_form].form_ptr,G_VOL_LIST,&num_rows);
  if(num_rows <= 0)
   {
     ex$message( msgnumb = SM_I_CmNoVolToDel, buff = my_msg);
     FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
     FIg_set_state_off(me->forms[me->idx_form].form_ptr,G_DEL_VOL);
     goto quit;
   }

  /* We come from non delete state : ask the name of a volume */
  /* Deselect all selected volumes and disable some gadget */

  if(me->state_del == FALSE) 
   {
     SMSetSingleSelectMode(me->forms[me->idx_form].form_ptr,G_VOL_LIST,num_rows,2);
     if(me->sel_vol.objid != NULL_OBJID)
      {
	dp$display(msg = &msg, oids = &me->sel_vol, mode = GRhhd);
	me->sel_vol.objid = NULL_OBJID;
      }
		
     /* Disable ADD_VOL etc ... */
     SMVA_disable(me->forms[me->idx_form].form_ptr,4,
		  G_ADD_VOL,FI_RESET,FI_ACCEPT,FI_EXECUTE);
     me->state_del = TRUE;
     ex$message( msgnumb = SM_I_CmSelVolDel, buff = my_msg);
     FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
     goto quit;
   }

  /* We are in a delete state */
  select = find_index_select_volume
    (me->forms[me->idx_form].form_ptr,me->work_vol,me->work_nb_vol,&vol_ind,&row);

    /* One volume is selected, delete it*/
  if(select) 
   {
     dp$display(msg = &msg, oids = &me->work_vol[vol_ind].id,mode = GRhe);
     del_one_volume(me->work_vol,&me->work_nb_vol,vol_ind);
     FIfld_delete_rows(me->forms[me->idx_form].form_ptr,G_VOL_LIST,row,1);
   
     ex$message( msgnumb = SM_I_CmVolDel, buff = my_msg);
     FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);

     me->sel_vol.objid = NULL_OBJID;
   }

  /* Enable others gadget */
  SMVA_enable(me->forms[me->idx_form].form_ptr,4,G_ADD_VOL,FI_RESET,FI_ACCEPT,FI_EXECUTE);
  
  me->state_del = FALSE;

 quit:
  *sts = OM_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message put_comp_att_in_form

  Abstract
	Retrieve main parameters for a compart and display them in form.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/


method put_comp_att_in_form(long *sts)
{
  char        val_txt[ATTR_TXT];
  IGRdouble   val_db;
  int         i,type;
  IGRshort    sm_type;
  long 	      attr_mask;
  IGRboolean  inside,real,calc;
  struct GRid group;


#define NB_COMP_TEXT_ATT 6
  static char *text_attr[] = {"name","short_desc","zone","tightness",
				"space_class","descript"};
  static int text_gadget[] = {G_NAME,G_SHORT_DESC,G_ZONE,G_TIGHTNESS,
				G_CLASS,G_DESCRIP };
#define NB_COMP_DBL_ATT 2
  static char *dbl_attr[] = {"struct_coef" ,"permeability"};
  static int dbl_gadget[] = {G_COEF_COMP,G_PERM_COMP};

  SetProc ( put_comp_att_in_form ); Begin
  *sts = OM_S_SUCCESS;


  switch(me->mytype)
   {
   case PLACE: case MODIFY:
     
    if( me->select_opt == DB_SELECT ) /* only if NFM attributes */
    {
     if(!SMGetAttr("dead_weight", me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,val_txt,&sm_type))
      {printf("No dead weight\n");goto wrapup;}
     SMput_alternate_gadget(me->forms[me->idx_form].form_ptr,G_DEAD_LIST,sm_type,val_txt);

     /* Put value of group */
     if(!SMGetAttr("grp",me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,val_txt,&sm_type))
      {printf("No grp\n"); goto wrapup;}
     SMput_alternate_gadget(me->forms[me->idx_form].form_ptr,G_GROUP_LIST,sm_type,val_txt);

     /* Put list of group and sub group */
     if(SMfound_object_by_name(val_txt,SM_GRP,&group,(struct GRmd_env *)NULL))
       SMget_list_sub_group(me->forms[me->idx_form].form_ptr,&group,TRUE);
     
     if(!SMGetAttr("sub_grp",me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,val_txt,&sm_type))
      {printf("No sub group\n");goto wrapup;}
     SMput_alternate_gadget(me->forms[me->idx_form].form_ptr,G_SUB_GROUP_LIST,
			    sm_type,val_txt);
     break;
    }
    else 
    {
    if( me->mytype == MODIFY )
    { 
	/* FOR PME - SPECIAL TREATMENT */

     if(!SMGetAttr("name", me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,val_txt,&sm_type))
      {printf("No name defined\n"); /*goto wrapup; */}

     FIfld_get_attr(me->forms[me->idx_form].form_ptr,G_PMECOMP_NAME,0,&attr_mask);
     if(attr_mask & FI_POPUP_ASSO_LIST)
       FIfld_set_attr(me->forms[me->idx_form].form_ptr,G_PMECOMP_NAME,0,attr_mask ^ FI_POPUP_ASSO_LIST); 
     SMVA_set_default_text(me->forms[me->idx_form].form_ptr,1,G_PMECOMP_NAME,val_txt);

     val_txt[0] = '\0';
     if(!SMGetAttr("descript", me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,val_txt,&sm_type))
      {printf("No description\n");}
     SMVA_set_default_text(me->forms[me->idx_form].form_ptr,1,G_COMP_DESC,val_txt);

     val_txt[0] = '\0';
     if(!SMGetAttr("sscs_no", me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,val_txt,&sm_type))
      {printf("No SSCS No \n");}
     SMVA_set_default_text(me->forms[me->idx_form].form_ptr,1,G_SSCS_NO,val_txt);
    }
    }

   case PL_COMP_HULL: case MD_COMP_HULL:
     FIget_list_hull(me->forms[me->idx_form].form_ptr);
     SMGetAttr("h_type",me->save_att,me->save_att_type,me->save_nb_att,
	      &type,(double *)NULL,val_txt,&sm_type);
     SMput_alternate_gadget(me->forms[me->idx_form].form_ptr,G_HULL_LIST,
			    sm_type,val_txt);
     break;
   } 

  /* Retrieve text attributes */
  for(i = 0 ; i < NB_COMP_TEXT_ATT; i++)
   {
     if(!SMGetAttr(text_attr[i],me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,val_txt,&sm_type))
      {val_txt[0] = '\0'; sm_type = SM_USER_ATT | SM_DYNAMIC_ATT;}

     if(strcmp(text_attr[i],"tightness") == 0) /* Attribute is tightness */
       SMput_alternate_gadget(me->forms[me->idx_form].form_ptr,text_gadget[i],
			      sm_type,val_txt);
     else /* All other attributes */
      {
	/* Gener a default name if name attribut          */
	if(i == 0  /* name attribut */ &&
	   me->mytype == PLACE         &&
	   (sm_type & SM_DYNAMIC_ATT) &&
	   me->old_name[0] != '\0'    &&
	   val_txt[0] == '\0') 
	  GetDefName(me->old_name,val_txt);
	
	SMVA_set_default_text(me->forms[me->idx_form].form_ptr,1,text_gadget[i],val_txt); 

	/* Jean 1 July 93 . SM_OTHER_ATT are put not writable */
	if(sm_type & SM_STATIC_ATT || sm_type & SM_OTHER_ATT )
	{
	  FIfld_set_mode(me->forms[me->idx_form].form_ptr,text_gadget[i],0,FI_REVIEW);
	}
	else
	{
  	  if( text_gadget[i] == G_NAME) 
	    FIfld_set_mode(me->forms[me->idx_form].form_ptr,text_gadget[i],0,FI_APPEND);
	}
      }
   }

  /* Retrieve double attributes */
   for(i = 0 ; i < NB_COMP_DBL_ATT; i++)
   {
     if(!SMGetAttr(dbl_attr[i],me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,&val_db,(IGRchar *)NULL,&sm_type))
      {val_txt[0] = '\0'; sm_type = SM_USER_ATT | SM_DYNAMIC_ATT;}
     else
       sprintf(val_txt,"%-9.6g",val_db);
     
     SMVA_set_default_text(me->forms[me->idx_form].form_ptr,1,dbl_gadget[i],val_txt) ; 
     if(sm_type & SM_STATIC_ATT)
       FIfld_set_mode(me->forms[me->idx_form].form_ptr,dbl_gadget[i],0,FI_REVIEW);
     else
       FIfld_set_mode(me->forms[me->idx_form].form_ptr,dbl_gadget[i],0,FI_APPEND);
   }

  /* Retrieve compart calculation */
  val_txt[0] = '\0';
  SMGetAttr("cal_inc",me->work_att,me->work_att_type,me->work_nb_att,
	    (int *)NULL,(double *)NULL,val_txt,(IGRshort *)NULL);
  calc  = strcmp(val_txt,"no") == 0 ? 0 : 1; 
   
  SMVA_set_default_state(me->forms[me->idx_form].form_ptr,1,G_CALC,calc);

  /* Retrieve inside/outside for normal compart only */ 
  if(me->mytype == PLACE || me->mytype == MODIFY)
   {
     /* Retrieve compart inside outside */
     val_txt[0] = '\0';
     SMGetAttr("location",me->work_att,me->work_att_type,me->work_nb_att,
	      (int *)NULL,(double *)NULL,val_txt,(IGRshort *)NULL);
     inside = strcmp(val_txt,"inside") == 0 ? 1 : 0; 
     SMVA_set_default_state(me->forms[me->idx_form].form_ptr,1,G_INSIDE,inside);
   }

  /* Retrieve pseudo */
  val_txt[0] = '\0';
  SMGetAttr("pseudo",me->work_att,me->work_att_type,me->work_nb_att,
	   (int *)NULL,(double *)NULL,val_txt,(IGRshort *)NULL); 
  real = strcmp(val_txt,"yes") == 0 ? 0 : 1;
  SMVA_set_default_state(me->forms[me->idx_form].form_ptr,1,G_PSEUDO,real);

  /* Put geometric information in form */
  om$send(msg = message SMCmdComp.put_geom_info(sts),targetid = my_id);
  
  *sts = OM_S_SUCCESS;
  End
  return OM_S_SUCCESS;

 wrapup:
  *sts = OM_E_ABORT;
  End
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message put_geom_info

  Abstract
	Get all geometrical info from me->work_att and put them 
	in the form.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method put_geom_info(long *sts)
{
  int        i;
  char       val_txt[ATTR_TXT];
  IGRdouble  val_db;
  IGRshort   sm_type;
  IGRlong    status,msg;

  static char *geom_attr[]   = {
    "expected_vol","volume","section_volume",
    "expected_area","area","floor_area",
    "cog_x","cog_y","cog_z"};				  

  static int gadget_num[] = {
    G_EXP_VOL, G_REAL_VOL,G_SECT_VOL,
    G_EXP_AREA,G_TOT_AREA,G_FLOOR_AREA,
    G_COG_X,G_COG_Y,G_COG_Z}; 
  
  SetProc ( put_geom_info ); Begin
  *sts = OM_S_SUCCESS;


  for(i=0;i<9;i++)
   {
     sm_type = -1;

     if(i == 0 || i == 3)
      {
	if(!SMGetAttr(geom_attr[i],me->work_att,me->work_att_type,me->work_nb_att,
		     (int *)NULL,&val_db,(IGRchar *)NULL,&sm_type))
	 {msg = MSFAIL; sm_type = SM_DYNAMIC_ATT |  SM_SYST_ATT;}
	else msg = MSSUCC;
      }
     else if(me->comp_id.objid != NULL_OBJID)
      {
	/* Ask the compartment for its values */
	status = om$send(msg = message SMmgr.SMGetAttDbl
			 (&msg, geom_attr[i], &val_db,NULL), 
			 targetid = me->comp_id.objid,
			 targetos = me->comp_id.osnum);
	if(!(status & msg & 1)) {msg = MSFAIL;}
      }
     else msg = MSFAIL;
     
     if(msg & 1) /* A Value was retrieve : convert */
      {
	switch(i)
	 {
	 case 0: case 1: case 2:      /* a volume */
	   if(val_db <= 0.0) val_txt[0] = '\0';
	   else
	    {
	      if( i != 0 )
	        SMConvVolIntExt(val_db,&val_db,me->ModuleInfo.md_id.osnum);
	      sprintf(val_txt,"%-9.6g",val_db);
	    }
	   break;
	   
	 case 3: case 4: case 5:           /* an area */
	   if(val_db <= 0.0) val_txt[0] = '\0';
	   else
	    {
	      if( i != 3 )
	        SMConvSurfIntExt(val_db,&val_db,me->ModuleInfo.md_id.osnum);
	      sprintf(val_txt,"%-9.6g",val_db);
	    }
	   break;

	 case 6: case 7: case 8:          /* center of gravity */
	   SMConvDistIntExt(val_db,&val_db,me->ModuleInfo.md_id.osnum);
	   sprintf(val_txt,"%-9.6g",val_db);
	   break;
	 }
      }
     else val_txt[0] = '\0';

     SMVA_set_default_text(me->forms[me->idx_form].form_ptr,1,gadget_num[i],val_txt);
     if(sm_type != -1)
       if(sm_type & SM_STATIC_ATT)
	 FIfld_set_mode(me->forms[me->idx_form].form_ptr,gadget_num[i],0,FI_REVIEW);
       else
       {
	 if( gadget_num[i] == G_EXP_AREA || gadget_num[i] == G_EXP_VOL )
	   FIfld_set_mode(me->forms[me->idx_form].form_ptr,gadget_num[i],0,FI_REVIEW);
       }
   }
  *sts = OM_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message SMChgListVol

  Abstract
	This method is called at the modify, to change the list of
	the volumes and their attributes.
	The argument modif_flag returns the type of modif needed.

  Arguments
	long	*msg		O 	completion code.
	int	*modif_flag	I/O	type of modif needed

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method SMChgListVol(IGRlong *msg; int *modif_flag)
{
  IGRlong              status;
  IGRint               tt_number,nb_vol,nb_to_del,index,i,j;
  struct GRid          to_add_root[2];
  struct GRid          to_del_root[3 + 2 * SM_MAX_ALLOW_VOL];
  struct GRid          old_vol[SM_MAX_ALLOW_VOL],old_rg[SM_MAX_ALLOW_VOL];
  struct GRmdenv_info  old_md_env[SM_MAX_ALLOW_VOL];
  struct GRmd_env      old_vol_env;
  IGRint               old_nb_att;
  struct ACrg_coll     old_ACrg[SM_MAX_CO_ATTR ];
  IGRshort             valid,find;

  SetProc ( SMChgListVol ); Begin
  *msg = OM_S_SUCCESS;


  /* Get list of volumes */
  status = om$send( msg = message SMcomp.SMGetVolInfo
		   (msg,SM_MAX_ALLOW_VOL,&nb_vol,&tt_number,
		    old_vol,old_rg,NULL,old_md_env),
		   targetid = me->comp_id.objid,
		   targetos = me->comp_id.osnum);
  if(!(status & *msg & 1))
   {printf("Error get volumes for compart id %d \n",me->comp_id.objid);
    goto wrapup;}
  
  /* Search volume to delete */
  nb_to_del = 0;
  for(i=0; i<nb_vol; i++)
   {
     if(!find_vol_index(me->work_vol,me->work_nb_vol,
			(char *)NULL,&old_vol[i],&index))
       {
	 old_vol_env.md_env      = old_md_env[i];
	 old_vol_env.md_id.osnum = old_vol[i].osnum;
	 ex$get_modid(mod_osnum  = old_vol_env.md_id.osnum,
		      mod_id     = &old_vol_env.md_id.objid);

	 as$make_source(go_grid = old_vol[i],
			mod_env = &old_vol_env,
			as_grid = &to_del_root[nb_to_del]); 
	 nb_to_del++;
	
#ifdef JJ_DEBUG
	printf("Must delete vol  %d \n",old_vol[i].objid);
#endif
      }
   }

  if(nb_to_del > 0)
   {
     status = om$send( msg = message SMcomp.SMDiscRoots
		      (msg,nb_to_del,to_del_root,&valid),
		      targetid = me->comp_id.objid,
		      targetos = me->comp_id.osnum);
	if(!(status & *msg & 1))
	 {printf("Error delete volume\n");goto wrapup;}
     *modif_flag |= TO_RECOMPUTE;
   }
  
  for(i=0; i < me->work_nb_vol; i++)
   {
     find = FALSE;

     /* Search volume to add */
     for(j=0; j < nb_vol; j++)
       if(me->work_vol[i].id.objid == old_vol[j].objid &&
	  me->work_vol[i].id.osnum == old_vol[j].osnum)
	{ find = TRUE; break; }
	   
     if(!find) /* This volume is to add */
      {
	as$make_source(go_grid =  me->work_vol[i].id,
		       mod_env =  &me->work_vol[i].mod_env,
		       as_grid = &to_add_root[1]);

	if(!SMCompInitCol(NULL,1,&to_add_root[0],&me->ModuleInfo))
	 { printf("Error SMCompInitCol for comp\n"); goto wrapup;}
	me->work_vol[i].rg = to_add_root[0];

#ifdef JJ_DEBUG
	printf("Add volume id = %d rg = %d\n",
	       to_add_root[1].objid,me->work_vol[i].rg.objid);
#endif

	status = om$send( msg = message SMcomp.SMAddRoots
			 (msg,2,to_add_root),
			 targetid = me->comp_id.objid,
			 targetos = me->comp_id.osnum);
	as$status(sts = (status & *msg),action = GOTO_VALUE,value = wrapup);
	
	status = om$send(msg = message SMcoll.ACset_list_attribute
			 (msg,me->work_vol[i].nb_attr,me->work_vol[i].ACrg),
			 targetid = me->work_vol[i].rg.objid,
			 targetos = me->work_vol[i].rg.osnum);
	if(!(status & *msg & 1))
	 {printf("Erreur add list attributes vol %d col %d\n",
		 me->work_vol[i].id.objid,me->work_vol[i].rg.objid);
	  goto wrapup;}

	*modif_flag |= TO_RECOMPUTE;
      }
     else /* This volume already exists */
      {
	status = om$send(msg = message SMcoll.AClist_attribute
		      (msg,SM_VOL_MAX_ATT,old_ACrg,&old_nb_att),
		      targetid = me->work_vol[i].rg.objid,
		      targetos = me->work_vol[i].rg.osnum);
	as$status(sts = (status & *msg),action = GOTO_VALUE, value = wrapup);
	
	if(!SMIsACrgEqual(old_ACrg,old_nb_att,
			  me->work_vol[i].ACrg,me->work_vol[i].nb_attr))
	 {
	   /* Put the attributes of volume */
	  
	   status = om$send(msg = message SMcoll.ACset_list_attribute
			    (msg,me->work_vol[i].nb_attr,me->work_vol[i].ACrg),
			    targetid = me->work_vol[i].rg.objid,
			    targetos = me->work_vol[i].rg.osnum);
	   if(!(status & *msg & 1))
	    {printf("Erreur add list attributes vol %d col %d\n",
		    me->work_vol[i].id.objid,me->work_vol[i].rg.objid);
	     goto wrapup;}
	   *modif_flag |= TO_CHANGE_STATE; 
	 }
      } /* else this volume exists */
   } /* for each volume */	
  
  *msg = MSSUCC;
  End
  return OM_S_SUCCESS;

 wrapup:
  *msg = MSFAIL;
  End
  return OM_S_SUCCESS;
}



/*+mo
 -------------------------------------------------------------------------
  Overridden Message

	form_notification from CEO

  Abstract

 CEO.form_notification is called whenever a I/Forms form is given input     
 by the user.  It is analogous to super_cmd.form_input(); however, no input 
 is present in the "value" argument if the gadget type is a field.  See the 
 I/Forms Forms documentation about querying a form's gadgets to get their   
 values.                                                                    


  Arguments

  int    	form_label;  	label of form which received user  input 
  int    	gadget_label;   gadget label  which received user  input 
  double 	value;          value of gadget ( or field row # )       
  char 		* form_ptr ;    ptr to I/Forms form which received input 


 -------------------------------------------------------------------------
-mo*/

method form_notification (int form_label; int gadget_label ; double value ;
			  char * form_ptr)
{
  int         status = OM_S_SUCCESS;
  long        sts, msg;
  int         state,sel,i,nbComps=0;
  char        name[DI_PATH_MAX];
  char        CompartName[VDPNAME_LEN];
  char	      tmpstr[300], tmpstr1[300];
  struct GRid group;
  OMuword	curOs;
  IGRint	fileState=0;
  IGRchar	errmsg[256];
  IGRchar	OldObid[VDPOBID_LEN]; /* OBID of the last selected comp.*/
  
  SetProc ( form_notification ); Begin
  if ( form_ptr == NULL ) return( OM_E_INVARG ); 
  
  FIg_set_text(form_ptr,FI_MSG_FIELD, "");
  switch( gadget_label )
   {
   case G_SEARCH:
   case G_MINUS:
   case G_PLUS:  
   case G_RESET:
   case G_NUM_PART:
 

     om$send(msg = message VDCmdPart.form_notification
	     (form_label, gadget_label,value,form_ptr),
	     targetid = my_id,
	     mode = OM_e_wrt_message);
     break;

   case FI_RESET :
   case FI_ACCEPT :
   case FI_CANCEL :
     if(me->mytype == MODIFY && gadget_label == FI_RESET)
     { /* TR3064, by ylong */
	om$send(msg = message SMCmdComp.chg_state_db(&sts,FALSE),
		targetid = my_id);

	om$send(msg = message SMCmdComp.control_form_state(&sts),
		targetid = my_id);

	SMVA_set_default_text (	me->forms[me->idx_form].form_ptr,15,
				G_NAME,"",
				G_SHORT_DESC,"",
				G_DESCRIP,"",
				G_TOT_AREA,"",
				G_REAL_VOL,"",
				G_SECT_VOL,"",
				G_EXP_VOL,"",
				G_TOT_AREA,"",
				G_FLOOR_AREA,"",
				G_ZONE,"",
				G_CLASS,"",
				G_DEAD_LIST,"",
				G_GROUP_LIST,"",
				G_SUB_GROUP_LIST,"",
				G_TIGHTNESS,"");
  
	ex$message(msgnumb = SM_M_CmMd);
       	_put_response(resp = RELOCATE_OBJ);
	break;
     }

     if( gadget_label == FI_ACCEPT &&
	 me->select_opt == PME_SELECT &&
	 me->b2150AttSet == FALSE )
     {
       FIg_set_text( me->forms[me->idx_form].form_ptr, FI_MSG_FIELD,
		     "Set 2150 attributes for this compartment" );
       break;
     }

     om$send(msg = message VDS_LOCATE.form_notification
	     (form_label, gadget_label,value,form_ptr),
	     targetid = my_id,
	     mode = OM_e_wrt_message);


     /* Buttons redisplayed for the solaris system */
     /* Change made on 06/19/97                    */
     if(gadget_label == FI_RESET)
     {
        FIg_display(me->forms[me->idx_form].form_ptr,G_PME_OPT);
        FIg_display(me->forms[me->idx_form].form_ptr,G_DATA_SEL);
        FIg_display(me->forms[me->idx_form].form_ptr,G_READ_PDU);
     }

     break;
     
   case FI_EXECUTE :
     if( me->select_opt == PME_SELECT &&
	 me->b2150AttSet == FALSE )
     {
       FIg_set_text( me->forms[me->idx_form].form_ptr, FI_MSG_FIELD,
		     "Set 2150 attributes for this compartment" );
       break;
     }

     status = om$send(msg = message SMCmdComp.save_all(&sts),
             targetid = my_id);

     FIg_set_state_off(me->forms[me->idx_form].form_ptr,FI_EXECUTE);
     if( (me->mytype % 2) == 1 /* Means we are in modify command */
	&& sts == OM_S_SUCCESS)
       		_put_response(resp = RELOCATE_OBJ);
     UI_status("Display complete ");

     switch(me->mytype)
     {
	 case PLACE:
	  ex$message(msgnumb = SM_M_CmPl);
	  ex$message(msgnumb =  SM_P_CmFrMod);
	  break;
	case MODIFY:
	  ex$message(msgnumb = SM_M_CmMd);
	  break;
     }

     break;
  

   case G_USER_ATT:   
     /* Display form attributes for the compartment */

     me->old_form_state = me->form_state;
     me->form_state = DYN_LIST;
     _put_response(resp = BEGIN_ATTR_FORM);
     goto quit; 
     
   case G_STATIC_TOG:
     me->old_form_state = me->form_state;
     om$send(msg = message SMCmdComp.VDSelectTog(&sts),
	     targetid = my_id);
     break;
 
   case G_DEL_ATT:
   case G_ATT_LIST:
            om$send(msg = message VDCmdAttMgr.form_notification
             (form_label, gadget_label,value,form_ptr),
             targetid = my_id,
             mode = OM_e_wrt_message);

     break;

   case G_READ_PDU:
     _put_response(resp = READ_FROM_PDU);
     break;

   case G_DATA_SEL:
     me->old_form_state = me->form_state;
     me->form_state = DB_SELECT;
     me->select_opt = DB_SELECT;
     _put_response(resp = BEGIN_DATA_SEL);
     break;

   case G_PME_OPT:
     ex$get_cur_mod( osnum = &curOs );
     status = VDPGetFileState( &msg, curOs, &fileState );
     if( !(status & 1))
     {
        FIg_set_text(form_ptr,FI_MSG_FIELD, "PME Required Data Not Set");
        //_put_response(resp =TERMINATE );   SSR TR# 179800477
        break;
     }

     if( fileState == VDP_FILE_REVISED )
     {
         strcpy(errmsg,"The current design file is revised in PME. It should also be revised in PDU. ");
         ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
         _put_response( resp = TERMINATE );
	 break;
     }
     else if( fileState == VDP_FILE_FROZEN )
     {
         strcpy(errmsg,"The current design file is frozen in PME. It should  be revised before further executing PME commands ");
         ex$message( msgnumb = EX_F_Var1, type = "%s", var=errmsg );
         _put_response( resp = TERMINATE );
	 break;
     }

     status = _VD_SEND_MY ( SMCmdComp.SMqueryCompartments ( &msg ));
     CheckRC ( status, msg );

     me->old_form_state = me->form_state;
     me->form_state = PME_SELECT;
     me->select_opt = PME_SELECT;
     me->b2150AttSet = FALSE;		/* 2150 atts not set for cur comp.*/
     _put_response( resp = PME_DATA_SEL);
     break;

   case G_LOAD:
     _put_response( resp = LOAD_DATA_SEL);
     break;

   case G_SEL_PMECOMP :
     strcpy( OldObid, me->CompPMObid );	/* Save the comp OBID.*/
     FIg_get_text (me->forms[me->idx_form].form_ptr, G_SEL_PMECOMP, tmpstr );
     __DBGpr_str ( "String from the gadget", tmpstr );
     nbComps = om$dimension_of (varray = me->CompNameDesc );
     __DBGpr_int ( "Nb Comps ", nbComps );

     for (i=0; i < nbComps; i++ )
     {
	FIfld_get_list_text (me->forms[me->idx_form].form_ptr, G_SEL_PMECOMP, 
				i, 0, 300, (unsigned char *)tmpstr1, &sel );
	__DBGpr_str( "String from the Associated List", tmpstr1 );

	if (!strcmp(tmpstr, tmpstr1))
	{
	    FIg_set_text (me->forms[me->idx_form].form_ptr, G_PMECOMP_NAME, me->CompNameDesc[i].Name );
	    FIg_set_text (me->forms[me->idx_form].form_ptr, G_COMP_DESC, me->CompNameDesc[i].Description );
	    FIg_set_text (me->forms[me->idx_form].form_ptr, G_SSCS_NO, me->CompNameDesc[i].SSCSnum );
	    strcpy ( me->CompPMObid, me->CompNameDesc[i].CompObid );
	    break;
	}
     }

     if( strcmp(OldObid, me->CompPMObid) != 0 ) /* A new comp was selected.*/
      me->b2150AttSet = FALSE;

     break;

   case G_PMECOMP_NAME:
     FIg_get_text(me->forms[me->idx_form].form_ptr, G_PMECOMP_NAME, CompartName );
/*
     nbComps = om$dimension_of (varray = me->CompNameDesc );
     __DBGpr_int ( "Nb Comps ", nbComps );

     for (i=0; i < nbComps; i++ )
     {
	if (!strcmp(CompartName, me->CompNameDesc[i].Name ))
	{
	    FIg_set_text (me->forms[me->idx_form].form_ptr, G_COMP_DESC, me->CompNameDesc[i].Description );
	    FIg_set_text (me->forms[me->idx_form].form_ptr, G_SSCS_NO, me->CompNameDesc[i].SSCSnum );
	    strcpy ( me->CompPMObid, me->CompNameDesc[i].CompObid );
	break;
	}
     }
*/

     break;

   case G_DEF2150_ATTR :
     _put_response(resp = LOAD_PME_DATA);
     break;

   case G_NAME:
   case G_DESCRIP:	
   case G_DEAD_LIST:
   case G_CALC:
     break;
     
   case G_GROUP_LIST:
     FIg_get_text(me->forms[me->idx_form].form_ptr,G_GROUP_LIST,name);
     if(SMfound_object_by_name(name,SM_GRP,&group,(struct GRmd_env *)NULL))
      {
	SMget_list_sub_group(me->forms[me->idx_form].form_ptr,&group,FALSE);
	FIfld_get_list_text(me->forms[me->idx_form].form_ptr,G_SUB_GROUP_LIST,0,0,
			    DI_PATH_MAX,(unsigned char*)name,&sel);
	FIg_set_text(me->forms[me->idx_form].form_ptr,G_SUB_GROUP_LIST,name);
      }
     break;
     
   case G_SUB_GROUP_LIST:
     break;
     
   case G_VOLUMES:
     me->old_form_state = me->form_state;
     me->form_state = INC_LIST;
     _put_response(resp = BEGIN_VOL_FORM);
     break;
     
   case G_DISP_OPT:
     /* Display form display options for the compartment */
     me->old_form_state = me->form_state;
     me->form_state = DISP_OPT;
     _put_response(resp = BEGIN_DISP_FORM);
     break;
     
   case G_GEOM_INFO:
     /* Display form for geometry */
     me->old_form_state = me->form_state;
     me->form_state = GEOM_INFO;
     _put_response(resp = BEGIN_GEOM_FORM);
     break;


   case G_VOL_LIST:
     select_list_vol(me->forms[me->idx_form].form_ptr,
		     me->work_vol,me->work_nb_vol,me->state_del,&me->sel_vol);
     break;
     
   case G_INCLUDE_TOG:
     FIg_get_state(me->forms[me->idx_form].form_ptr,G_INCLUDE_TOG,&state);
     me->old_form_state = me->form_state;
     me->form_state = state ? INC_LIST : EXC_LIST;
     om$send(msg = message SMCmdComp.put_list_vol(&sts),
	     targetid = my_id);
     break;

   case G_ADD_VOL:
     _put_response( resp = LOCATE_VOL ); 
     goto quit;
     
   case G_DEL_VOL:
     om$send(msg = message SMCmdComp.select_delete_volume(&sts),
	     targetid = my_id);
     if(!(sts & 1)){printf("Erreur delete vol\n");}
     goto quit;

   }
  
 quit: 
    End
    return OM_S_SUCCESS;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	reset_all from VDS_LOCATE

  Abstract
	That method is called at the FI_RESET.
	It basically reset the form and the instances.

	It has been overriden in order to take into account the state of
	the form.
	
  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/


method reset_all( long *sts )
{
  SetProc( reset_all ); Begin
  *sts = OM_S_SUCCESS;

  if(me->form_state == DB_SELECT)
   {
     om$send(msg = message SMCmdComp.chg_state_select_db(sts,TRUE),
	     targetid = my_id);
     goto control_form;
   }

  if(me->form_state == PME_SELECT || me->select_opt == PME_SELECT )
   {
     om$send(msg = message SMCmdComp.chg_state_select_pme(sts,TRUE),
	     targetid = my_id);
/*     goto control_form; */
   }

  update_display_volume(me->save_vol,me->save_nb_vol,
			me->work_vol,me->work_nb_vol,&me->sel_vol);

  if((me->mytype == PLACE || me->mytype == PL_COMP_HULL))
   {
     om$send(msg = message SMCmdComp.init_form_new_comp(sts, TRUE),
	     targetid = my_id);
     if(!(*sts & 1)) return OM_S_SUCCESS;
   }
  else
   {
     om$send(msg = message SMCmdComp.control_comp(sts),
	     targetid = my_id);
     if(!(*sts & 1)) return OM_S_SUCCESS;
   }

 control_form:

  om$send(msg = message SMCmdComp.empty_form_state(sts),
	  targetid = my_id);

  om$send(msg = message SMCmdComp.set_compart_dbtype(sts),
	  targetid = my_id);

  om$send(msg = message SMCmdComp.chg_state_db(sts,FALSE),
	     targetid = my_id);

  om$send(msg = message SMCmdComp.control_form_state(sts),
	  targetid = my_id);

  *sts = OM_S_SUCCESS;
  End
  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	save_all from VDS_LOCATE

  Abstract
	That method is called at the FI_EXECUTE and FI_ACCEPT.

	At this level, it retrieves all the parameters in the form and
	call the appropriate place or modify method.
	
  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

method save_all( long *sts )
{
  IGRlong 	   msg,status;
  IGRlong 	   msgcode;   
  char 	  	   name_comp[ATTR_TXT],name[ATTR_TXT],
  	  	   sub_name[ATTR_TXT],val_text[ATTR_TXT];
  char   	   my_msg[80];
  int     	   val_int,i,sel,pos,type;
  double  	   val_db;
  struct GRobj_env dw_obj,grp_obj;
  struct GRid 	   sub_grp;
  IGRshort 	   sm_type;
  char             family[ATTR_TXT],partnum[ATTR_TXT],partrev[ATTR_TXT];
  int              already_placed;

#define NB_SAVE_COMP_ATT 7
  static char *comp_attr[] = {"short_desc","descript","zone",
				"tightness","space_class",
				"expected_vol","expected_area"};
 
  static int num_gadget[] = {G_SHORT_DESC,G_DESCRIP,G_ZONE,
			     G_TIGHTNESS,G_CLASS,
			     G_EXP_VOL,G_EXP_AREA};
  
  SetProc ( save_all ); Begin
  *sts = OM_S_SUCCESS;

  msgcode = 0;

  /* Reinitialze me->comp_id in case of place */
  if(me->mytype == PLACE || me->mytype == PL_COMP_HULL)

    me->comp_id.objid = NULL_OBJID;

  /* Verify we have at least one include volume */
  if(!one_include_vol(me->work_vol,me->work_nb_vol))
   { msgcode = SM_E_CmNoVol; goto wrapup; } 
  
  /* Retrieve compart Name */

  name_comp[0] = '\0';
  if ( me->select_opt == DB_SELECT )
    FIfld_get_text(me->forms[me->idx_form].form_ptr,G_NAME,0,0,ATTR_TXT,
		   (unsigned char*)name_comp,&sel,&pos); 
  else
    FIfld_get_text(me->forms[me->idx_form].form_ptr,G_PMECOMP_NAME,0,0,ATTR_TXT,
		   (unsigned char*)name_comp,&sel,&pos); 
  name_comp[ATTR_TXT - 1] = '\0';
  if(name_comp[0] == '\0')
   { msgcode = SM_E_CmVolName; goto wrapup; }
  else
   {
     if(!SMCanChgElemName(&me->comp_id,name_comp))
      { msgcode = SM_E_CmNamEx; goto wrapup ; }
	
     SMSetAttr("name",me->work_att,me->work_att_type,&me->work_nb_att,
	      AC_ATTRIB_TEXT,0.0,name_comp,
	      SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
   }

  if( me->select_opt == PME_SELECT || me->select_opt == PME_MODIFY )
  {
    val_text[0] = '\0';
    FIfld_get_text(me->forms[me->idx_form].form_ptr,G_COMP_DESC,0,0,ATTR_TXT,
		   (unsigned char*)val_text,&sel,&pos); 
    SMSetAttr("descript",me->work_att,me->work_att_type,&me->work_nb_att,
	      AC_ATTRIB_TEXT,0.0,val_text,
	      SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );

    val_text[0] = '\0';
    FIfld_get_text(me->forms[me->idx_form].form_ptr,G_SSCS_NO,0,0,ATTR_TXT,
		   (unsigned char*)val_text,&sel,&pos); 
    SMSetAttr("sscs_no",me->work_att,me->work_att_type,&me->work_nb_att,
	      AC_ATTRIB_TEXT,0.0,val_text,
	      SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
  }

  /* Check another time if part not already placed */

  if(me->mytype == PLACE && me->compart_track)
   { 
     if(!SMGetAttr("family",me->work_att,(IGRshort *)NULL,me->work_nb_att,
		   (int *)NULL,(IGRdouble *)NULL,family,
		   (IGRshort *)NULL) ||
	!SMGetAttr("partno",me->work_att,(IGRshort *)NULL,me->work_nb_att,
		   (int *)NULL,(IGRdouble *)NULL,partnum,
		   (IGRshort *)NULL) ||
	!SMGetAttr("partrev",me->work_att,(IGRshort *)NULL,me->work_nb_att,
		   (int *)NULL,(IGRdouble *)NULL,partrev,
		   (IGRshort *)NULL))
      {printf("Erreur retreiving compart info for database\n"); goto wrapup;}

     om$send(msg = message SMCmdComp.check_already_placed
	     (sts,family,partnum,partrev,&already_placed),
	     targetid = my_id);
     if(already_placed) goto wrapup;
   }


  /* Retrieve compart text attributes */

  for(i=0; i <  NB_SAVE_COMP_ATT; i++)
   {
     /* Get type of attributes : if not exists don't set attributes */
     if(!SMGetAttr(comp_attr[i],me->save_att,me->save_att_type,me->save_nb_att,
		  &type,(IGRdouble *)NULL,(char *)NULL,&sm_type))
       continue;

     switch(type)
      {
      case  AC_ATTRIB_TEXT:
	val_text[0] = '\0';
	FIfld_get_text(me->forms[me->idx_form].form_ptr,num_gadget[i],0,0,ATTR_TXT,
		       (unsigned char*)val_text,&sel,&pos);
	val_text[ATTR_TXT - 1] = '\0';
	SMSetAttr(comp_attr[i],me->work_att,me->work_att_type,&me->work_nb_att,
		 AC_ATTRIB_TEXT,0.0,val_text,sm_type,SM_MAX_CO_ATTR );
	break;
	
      case  AC_ATTRIB_DOUBLE:
	if(!SMget_double(me->forms[me->idx_form].form_ptr,num_gadget[i],0,0,&val_db) ||
	   val_db < 0.0)
	  val_db = 0.0;
	
/***
	if(val_db > 0)
	  if(strcmp(comp_attr[i],"expected_vol") == 0)
	    SMConvVolExtInt(val_db,&val_db,me->ModuleInfo.md_id.osnum);
	  else  if(strcmp(comp_attr[i],"expected_area") == 0)
	    SMConvSurfExtInt(val_db,&val_db,me->ModuleInfo.md_id.osnum);
 ***/
	
	SMSetAttr(comp_attr[i],me->work_att,me->work_att_type,&me->work_nb_att,
		 AC_ATTRIB_DOUBLE,val_db,(char *)NULL,sm_type,SM_MAX_CO_ATTR );
	break;
      }
   }
  
  /* Retrieve compart calculation */

  FIg_get_state(me->forms[me->idx_form].form_ptr,G_CALC,&val_int);
  SMSetAttr("cal_inc",me->work_att,me->work_att_type,&me->work_nb_att,
	   AC_ATTRIB_TEXT,0.0,val_int ? "yes" : "no",
	   SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
  
  
  /* Retrieve compart real or theoretical */
  /* Retrieve compart inside outside (not for hull) */
  /* Get type of attributes : if not exists put dynamic */
  if(!SMGetAttr("pseudo",me->save_att,me->save_att_type,me->save_nb_att,
	       (int *)NULL,(IGRdouble *)NULL,(char *)NULL,&sm_type))
    sm_type = SM_DYNAMIC_ATT | SM_SYST_ATT;
  
  val_int = 1;
  FIg_get_state(me->forms[me->idx_form].form_ptr,G_PSEUDO,&val_int);
  SMSetAttr("pseudo",me->work_att,me->work_att_type,
	   &me->work_nb_att,AC_ATTRIB_TEXT,0.0,val_int ? "no" : "yes",
	   sm_type,SM_MAX_CO_ATTR );

  if(me->mytype == PLACE || me->mytype == MODIFY)
   {
     static char *struct_attr[]  = {"struct_coef","permeability"};
     static int struct_gadgets[] = {G_COEF_COMP,G_PERM_COMP};

     /* Get type of attributes : if not exists put dynamic */
     if(!SMGetAttr("location",me->save_att,me->save_att_type,
		  me->save_nb_att,(int *)NULL,(IGRdouble *)NULL,(char *)NULL,
		  &sm_type))
       sm_type = SM_DYNAMIC_ATT | SM_SYST_ATT;
     
     FIg_get_state(me->forms[me->idx_form].form_ptr,G_INSIDE,&val_int);
     SMSetAttr("location",me->work_att,me->work_att_type,&me->work_nb_att,
	      AC_ATTRIB_TEXT,0.0,val_int ? "inside" : "outside",
	      sm_type,SM_MAX_CO_ATTR );

     /* Retrieve compart struct coeff and permeability */
     for(i=0;i<2;i++)
      {
        /* Get type of attributes : if not exists put dynamic */
	if(!SMGetAttr(struct_attr[i],me->save_att,me->save_att_type,
		     me->save_nb_att,(int *)NULL,(IGRdouble *)NULL,(char *)NULL,
		     &sm_type))
       sm_type = SM_DYNAMIC_ATT | SM_SYST_ATT;

     if(!SMget_double(me->forms[me->idx_form].form_ptr,struct_gadgets[i],0,0,&val_db) ||
	val_db < 0.0 || val_db > 1.0)
      {
	switch(struct_gadgets[i])
	 {
	 case G_COEF_COMP:
	  { msgcode = SM_E_CmStCoef ; goto wrapup; }
	case G_PERM_COMP:
	 { msgcode = SM_E_CmPerm ; goto wrapup; }
	}
      }
	SMSetAttr(struct_attr[i],me->work_att,me->work_att_type,&me->work_nb_att,
		 AC_ATTRIB_DOUBLE,val_db,(char *)NULL,sm_type,SM_MAX_CO_ATTR );
      }
   }

  /* Get all user attributes */

  if(me->form_state == DYN_LIST)
   {
     om$send(msg = message SMCmdComp.VDSaveListDyn(sts, my_msg),
	     targetid = my_id);
     if(!(*sts & 1)) {
	FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
	goto wrapup;
     }
   }

  /* Put display option for compart and volume  */
  get_display_option(me->forms[me->idx_form].form_ptr,&me->disp);
  
  SMSetAttr("cmp_props",me->work_att,me->work_att_type,&me->work_nb_att,
	   AC_ATTRIB_DOUBLE,(double)me->disp.opt,(char *)NULL,
	   SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
  
  /* Put x and y offset */
  SMSetAttr("x_offset",me->work_att,me->work_att_type,&me->work_nb_att,
	   AC_ATTRIB_DOUBLE,(double)me->disp.dx,(char *)NULL,
	   SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
  
  SMSetAttr("y_offset",me->work_att,me->work_att_type,&me->work_nb_att,
	   AC_ATTRIB_DOUBLE,(double)me->disp.dy,(char *)NULL,
	   SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );

  switch(me->mytype)
   {
   case PLACE: case MODIFY:
    if ( me->select_opt == DB_SELECT )
    {
     /* Found the dead weight  */
     if(!SMGetAttr("dead_weight",me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,(char *)NULL,&sm_type))
      {name[0] = '\0'; sm_type =  SM_DYNAMIC_ATT | SM_SYST_ATT;}
 
     name[0] = '\0';
     FIg_get_text(me->forms[me->idx_form].form_ptr,G_DEAD_LIST,name);
   
     if(name[0] != '\0' &&
	!SMfound_object_by_name(name,SM_DW,&dw_obj.obj_id,&dw_obj.mod_env))
      { msgcode = SM_E_CmNoDead; goto wrapup; }

     SMSetAttr("dead_weight",me->work_att,me->work_att_type,&me->work_nb_att,
	      AC_ATTRIB_TEXT,0.0,name,sm_type,SM_MAX_CO_ATTR );
  
     /* Get the group object */
     if(!SMGetAttr("grp",me->work_att,me->work_att_type,me->work_nb_att,
		  (int *)NULL,(double *)NULL,(IGRchar *)NULL,&sm_type))
       name[0] = '\0'; 

     name[0] = sub_name[0] = '\0';
     FIg_get_text(me->forms[me->idx_form].form_ptr,G_GROUP_LIST,name);
     FIg_get_text(me->forms[me->idx_form].form_ptr,G_SUB_GROUP_LIST,sub_name);
       
     /* If name is set, verify group exists */
     if(name[0] != '0' &&
	!SMfound_object_by_name(name,SM_GRP,&grp_obj.obj_id,&grp_obj.mod_env))
      { msgcode = SM_E_CmNoGroup; goto wrapup; }
     
     SMSetAttr("grp",me->work_att,me->work_att_type,&me->work_nb_att,
	      AC_ATTRIB_TEXT,0.0,name,sm_type,SM_MAX_CO_ATTR );

     if(SMGetAttr("sub_grp",me->work_att,me->work_att_type,me->work_nb_att,
		 (int *)NULL,(double *)NULL,(IGRchar *)NULL,&sm_type))
      {
        /* Verify sub name */
	if(sub_name[0] != '\0')
	 {
	   status = om$send(msg = message SMgroup.SMGetSgrpId
			    (&msg,sub_name,&sub_grp, 
			     &grp_obj.mod_env.md_env.matrix_type,
			     grp_obj.mod_env.md_env.matrix),
			    targetid = grp_obj.obj_id.objid, 
			    targetos = grp_obj.obj_id.osnum);
	   as$status(action = RET_STATUS);
	   if(!(msg & 1))
	    {
	      printf("Sub group: %s does not exist for group: %s id = %d os = %d\n",
		     sub_name,name,grp_obj.obj_id.objid,grp_obj.obj_id.osnum);
	      goto wrapup;
	    }
	 }
	SMSetAttr("sub_grp",me->work_att,me->work_att_type,&me->work_nb_att,
		 AC_ATTRIB_TEXT,0.0,sub_name,sm_type,SM_MAX_CO_ATTR);
      }
    }
    break;

     /* Get hull type if compartment hull */
   case PL_COMP_HULL: case MD_COMP_HULL:
     SMGetAttr("h_type",me->work_att,me->work_att_type,me->work_nb_att,
	      (int *)NULL,(double *)NULL,(IGRchar *)NULL,&sm_type);
     FIg_get_text(me->forms[me->idx_form].form_ptr,G_HULL_LIST,val_text);
     SMSetAttr("h_type",me->work_att,me->work_att_type,&me->work_nb_att,
	      AC_ATTRIB_TEXT,0.0,val_text,sm_type,SM_MAX_CO_ATTR );
     break;
   }

#ifdef JJ_DEBUG
     print_all_attr(me->work_att,me->work_att_type,me->work_nb_att);
#endif  
  switch(me->mytype)
   {
   case PLACE: case PL_COMP_HULL:
     status = om$send( msg = message SMCmdComp.SMplace_comp(&msg),
		      targetid = my_id);
     if (!(status & msg & 1))
      { msgcode = SM_E_CmBadPlace;
     /* added for TR-179800514 */ 
      if(me->comp_id.objid == NULL_OBJID) return 0;
      goto wrapup; }

     if( me->select_opt != PME_SELECT )
     {
     /* Display geom info after placing compart */
     me->old_form_state = me->form_state;
     me->form_state     =  GEOM_INFO; 
     om$send(msg = message SMCmdComp.control_form_state(sts),targetid = my_id);
     
     /* Get attributes of the compart (because some have been add) */
     if(!ret_all_comp_att(&me->comp_id,
			  &me->work_nb_att,me->work_att,me->work_att_type))
       goto wrapup;
     
     om$send(msg = message SMCmdComp.put_comp_att_in_form(sts),targetid = my_id);

     /* Add new compart in design list of already placed compart */
     if(me->mytype == PLACE && me->compart_track)
      {
	om$send(msg = message SMCmdComp.realloc_dsgn_list(sts,1),
		targetid = my_id);
	if(!(*sts & 1)) goto wrapup;
	
	om$send(msg = message SMCmdComp.add_dsgn_list(sts,family,partnum,partrev),
		targetid = my_id);
	if(!(*sts & 1)) goto wrapup;
      }
     strcpy(me->old_name,name_comp); /* Save preceding name to increment */
     }
     else
     {
	/* first reset the form */

	FIf_reset( me->forms[me->idx_form].form_ptr );

	/* then do all the reset processing */

        status = om$send(msg = message SMCmdComp.reset_all(&msg),
             targetid = my_id);
     }
     break;
     
   case MODIFY: case MD_COMP_HULL:
     status = om$send( msg = message SMCmdComp.SMmodif_comp(&msg),
		      targetid = my_id);
     if (!(status & msg & 1))
      { msgcode = SM_E_CmBadModif; goto wrapup; }

     SMVA_set_default_text(me->forms[me->idx_form].form_ptr,11,
			   G_NAME,"",
			   G_SHORT_DESC,"",
			   G_DESCRIP,"",
			   G_TOT_AREA,"",
			   G_REAL_VOL,"",
			   G_SECT_VOL,"",
			   G_EXP_VOL,"",
			   G_TOT_AREA,"",
			   G_FLOOR_AREA,"",
			   G_ZONE,"",
			   G_CLASS,"");
  
     SMVA_set_default_state(me->forms[me->idx_form].form_ptr,3,
			    G_PSEUDO,1,
			    G_CALC,1,
			    G_INSIDE,1);

     break;
   }

  /* Blank all value too */

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
  
 wrapup:
  if(msgcode != 0)
   {
     ex$message( msgnumb = msgcode, buff = my_msg);
     FIg_set_text(me->forms[me->idx_form].form_ptr,FI_MSG_FIELD,my_msg);
   }
  *sts = OM_E_ABORT;
  End
  return OM_S_SUCCESS;
}

/* ------------------- some debug functions --------------------------  */
   
#ifdef JJ_DEBUG
/* Method for debug : print an attribute */
static int print_attr(ACrg,sm_type)
struct ACrg_coll *ACrg;
IGRshort sm_type; 
{
  printf("Name <%s>",ACrg->name);
  
  switch((ACrg->desc).type)
   {
   case AC_ATTRIB_TEXT :
     printf(" value <%s> type <%x>\n",(ACrg->desc).value.att_txt, sm_type);
     break;
   case  AC_ATTRIB_DOUBLE :
     printf(" value <%lf> type <%x>\n",(ACrg->desc).value.att_exp,sm_type);
     break;
     default : printf(" value unknown\n");
   }
  return 1; 
}


/* print all attriibute of a collection */
print_all_attr(ACrg,sm_type,nb_attr)
struct ACrg_coll *ACrg;
IGRshort *sm_type;
int nb_attr;
{
  int i;

  for(i=0;i<nb_attr;i++)
    print_attr(&ACrg[i],sm_type[i]);
  return 1;
}
 
print_vol_attr(Vol,nb_vol)
struct Comp_Volume Vol[];
int nb_vol;
{
  int i;

  printf("Sauvegarde des attributs\n");
  printf("Nombre de volumes %d \n",nb_vol);
  for(i=0;i<nb_vol;i++)
   {
     printf("\nVolume %d Id %d Osnum %d name %s rg %d\n",i,Vol[i].id.objid,
	    Vol[i].id.osnum,Vol[i].name,Vol[i].rg.objid);
     print_all_attr(Vol[i].ACrg,Vol[i].type,Vol[i].nb_attr);
   }
  return 1;
}
#endif
end implementation SMCmdComp;






