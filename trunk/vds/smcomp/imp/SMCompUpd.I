/* $Id: SMCompUpd.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMCompUpd.I
 *
 * Description:
 *
 *      This file implements functions to update Compartment if change of 
 *	attributes in database.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMCompUpd.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/04  17:04:56  pinnacle
# Replaced: smcomp/imp/SMCompUpd.I for:  by impd for vds
#
# Revision 1.2  1997/10/31  22:13:36  pinnacle
# UnInit warning
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  08:53:28  pinnacle
# Replaced: smcomp/imp/SMCompUpd.I for:  by ksundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      02/01/93        J.Jasinczuck     Creation date.
 *	06/15/94	P. Lacroix	 Add a new function (SMForceRecompute)
 *					 in order to correct a bug on the 
 *					 GRgetrang call.
 *	10/31/97	ah		 Warnings
 *	12/04/97	adz		Add External list for update COMP list
 * -------------------------------------------------------------------------
 */

class implementation SMcomp;

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "nddef.h"
#include "ndmacros.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "SMdef.h"
#include "SMcomp_def.h"
#include "SMmacros.h"
#include "SMCompForm.h"
#include "VDmem.h"


#define DEBUG          1
#define AS_DEBUG       1
/* #define JJ_DEBUG      1   */

#include "AS_status.h"

/*+fi
 -------------------------------------------------------------------------
  Internal Function  copy_attr

  Abstract

	This function is used to Copy one attribut of ACrg to another.
  Returns
         
	nothing since it is a void function
 -------------------------------------------------------------------------
*/

static void copy_attr(target,source)
struct ACrg_coll *target;   /* [O] ACrg to fill */
struct ACrg_coll *source;   /* [I] ACrg to copy */
/*
-fi */
{
  strcpy(target->name,source->name);
  target->desc.type = source->desc.type;
  switch(source->desc.type)
   {
   case AC_ATTRIB_TEXT:
     strcpy(target->desc.value.att_txt,source->desc.value.att_txt);
     break;
   case AC_ATTRIB_DOUBLE:
     target->desc.value.att_exp = source->desc.value.att_exp;
     break;
   }
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMUpdCompFromDb

  Abstract

	This function is used to update all attributes of all compartment : 
	all static attributes are retrieve from database, all dynamic 
	attributes come from the design file.

  Returns
         
         1 if success
         0 if fails

 -------------------------------------------------------------------------
*/

int SMUpdCompFromDb(type_obj, inCnt, inList )
IGRshort		type_obj; /* [I] type of object (Ex SM_COMPART) */
IGRint			inCnt;	  /* {I}: Option list of objects.	*/
struct	GRobj_env	*inList;  /* List of objects.			*/
/*
-fi */
{
  IGRlong           status,msg;
  struct SMObjList  list;
  int               i,j, toFree = TRUE ;
  struct ACrg_coll  db_att[SM_MAX_CO_ATTR],new_att[SM_MAX_CO_ATTR],
                    design_att[SM_MAX_CO_ATTR];
  IGRshort          db_type[SM_MAX_CO_ATTR],design_type[SM_MAX_CO_ATTR],
                    new_type[SM_MAX_CO_ATTR];
  IGRint            design_nb_att,db_nb_att,new_nb_att;
  IGRchar           family_name[ATTR_TXT],rev_partid[ATTR_TXT],
                    rev_revision[ATTR_TXT];

  list.list       = NULL;
  list.nb_objects = 0;

  /*
   * Check if the routine has given a sublist of objects. When this is the 
   * case, we process these object and not all in design file.
   */

  if( inCnt && inList ){
	toFree		= FALSE ;
	list.nb_objects	= inCnt ;
	list.list	= inList ;
  }
  else{
	/* Find all compart in file */
    	status = SM$CritSel(msg = &msg, type = type_obj, list  = &list);
	if(!(status & 1) || msg != MSSUCC){
		printf("Error found list of compartments\n");
		return 0;
	}
  }

  if(list.nb_objects <= 0) return 1; /* Nothing to do */

  for(i = 0 ; i < list.nb_objects; i++)
  {
#ifdef JJ_DEBUG
     printf("\n--------------------------------------------------------------\n");
     printf("Update compartment %d,%d\n",
	    list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
#endif

     /* Get list of all attribut for compartment */
     status = om$send(msg = message SMmgr.SMListAtt
		      (&msg,SM_MAX_CO_ATTR,
		       &design_nb_att,design_att,design_type),
		      senderid = NULL_OBJID,
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
     if(!(status & msg & 1))
      {
	printf("Warning: problem get attribut for compart %d,%d\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
	continue;
      }
#ifdef JJ_DEBUG
     else
       printf("List of attributs in design file OK\n");
#endif

     status = om$send(msg = message SMmgr.SMGetAttTxt
		      (&msg,"family",family_name,NULL),
		      senderid = NULL_OBJID,
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
     if(!(status & msg & 1))
      {
	printf("Warning: problem get family name for compart %d,%d\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
	continue;
      } 


     status = om$send(msg = message SMmgr.SMGetAttTxt
		      (&msg,"partno",rev_partid,NULL),
		      senderid = NULL_OBJID,
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
     if(!(status & msg & 1))
      {
	printf("Warning: problem get partno for compart %d,%d\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
	continue;
      } 

     status = om$send(msg = message SMmgr.SMGetAttTxt
		      (&msg,"partrev",rev_revision,NULL),
		      senderid = NULL_OBJID,
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
     if(!(status & msg & 1))
      {
	printf("Warning: problem get partrev for compart %d,%d\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
	continue;
      } 
#ifdef JJ_DEBUG
     else
       printf("Get family = %s partno = %s partrev = %s OK\n",
	      family_name,rev_partid,rev_revision);
#endif    

     db_nb_att = SM_MAX_CO_ATTR;
     /* Get database attribut for compartment */
     if(!SMCompReadDbAtt(family_name,rev_partid,rev_revision,
			 db_att,db_type,&db_nb_att))
      {
	printf("Warning: part %s %s no longer exists in database\n",
	       rev_partid,rev_revision);
	continue;
      }
#ifdef JJ_DEBUG
     else
      {
	printf("Attributs of current part retrieve from Database OK\n");
      }

#endif

     new_nb_att = 0;
     /* Set all static attributes from database */
     for(j = 0; j < db_nb_att; j++)
       if(db_type[j] & SM_STATIC_ATT)
	{
	  /* The value type Static or Dynamic of cmp_props is not set */
	  /* So kludge : cmp_props is dynamic and is in design list */
	  if(strcmp(db_att[j].name,"cmp_props") == 0) continue;
	  if(strcmp(db_att[j].name,"comp_type") ==0) 
	   { 
	     printf("Warning, attribute <comp_type> is reserved by system\n");
	     printf("This attribute will be ignore in the update\n");
	     continue;
	   }
	  copy_attr(&new_att[new_nb_att],&db_att[j]);
	  new_type[new_nb_att] = db_type[j];
	  new_nb_att++;
	}

     /* Set all dynamic attributes from database */
     for(j = 0; j < design_nb_att; j++)
       if(design_type[j] & SM_DYNAMIC_ATT) 
	{
	  copy_attr(&new_att[new_nb_att],&design_att[j]);
	  new_type[new_nb_att] = design_type[j];
	  new_nb_att++;
	}

#ifdef JJ_DEBUG
     printf("------------------------------------------\n");
     printf("Old Attributs \n");
     print_all_attr1(design_att,design_type,design_nb_att);

     printf("------------------------------------------\n");
     printf("New Attributs \n");
     print_all_attr1(new_att,new_type,new_nb_att);
#endif

     status = om$send(msg = message SMmgr.SMResetAtt
		      (&msg,new_nb_att,new_att,new_type),
		      senderid = NULL_OBJID,
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
     if(!(status & msg & 1))
      {
	printf("Warning: problem set attribut for compart %d,%d\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
	continue;
      }
#ifdef JJ_DEBUG
     else
       printf("------ Update for compart %d,%d completed -------\n",
	      list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
#endif

  } 
  
  if( toFree )	_FREE(list.list) ;
  return TRUE;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMForceRecompute

  Abstract

	This function is used to force the recompute of all the compartments
	in the design file.

  Returns
	1 if success
	0 if error

 -------------------------------------------------------------------------
*/


int SMForceRecompute()
{
 IGRint			i, status, cmp_props;
 int 	    		wait_batch,cn_type;
 IGRlong		msg;
 IGRdouble		struct_coef;
  struct SMObjList  	list;

  list.list       = NULL;
  list.nb_objects = 0;

  /* Find all compart in file */

  status = SM$CritSel(msg = &msg, type = SM_COMPART, list  = &list);
  if(!(status & 1) || msg != MSSUCC)
   {printf("Error found list of compart\n");return 0; }

  if(list.nb_objects <= 0) return 1; /* Nothing to do */

  for(i = 0 ; i < list.nb_objects; i++)
   {
	/* Ask the compartment for its cmp_props */
	status = om$send(msg = message SMmgr.SMGetAttDbl
			 (&msg, "cmp_props", &struct_coef,NULL), 
		      	 senderid = NULL_OBJID,
			 targetid = list.list[i].obj_id.objid,
			 targetos = list.list[i].obj_id.osnum);
	if(!(status & msg & 1)) {

   		/* Take all */ 
   		cmp_props = SM_CMP_DSP_RT_COG_PT  | SM_CMP_DSP_RT_COG_NAME |
               		SM_CMP_DSP_CMP_COG_PT | SM_CMP_DSP_CMP_COG_NAME|
	       		SM_CMP_CAL_VOLS	 | SM_CMP_VRF_OVER | SM_CMP_X_POS;
  	}
 	else cmp_props = (int) struct_coef;
 	cmp_props | = SM_CMP_CAL_VOLS	;

	status = om$send(msg = message SMmgr.SMSetAttDbl
			 (&msg, "cmp_props", (IGRdouble) cmp_props,NULL), 
		         senderid = NULL_OBJID,
			 targetid = list.list[i].obj_id.objid,
			 targetos = list.list[i].obj_id.osnum);
 
         as$status(action=RET_STATUS);

	/* recompute the compartment */

     	cn_type    = ND_COMP; /* recompute the object */
     	nd$wait_batch(	type       = GR_GEOM_POSTED,
		  	l_object   = &list.list[i].obj_id,
		  	l_obj_info = &cn_type,
		  	nb_obj     = 1);

     	nd$mod_batch(request    = ND_INQ,p_ret_mode = &wait_batch);
     
     	if(wait_batch != ND_DEFER) /* Else Nothing to do */
       	nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
 }

  _FREE(list.list) ;
  return 1;
}

/* -------------- SOME DEBUG FUNCTIONS ------------ */

#ifdef JJ_DEBUG
/* Method for debug : print an attribute */
static int print_attr1(ACrg,sm_type)
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
print_all_attr1(ACrg,sm_type,nb_attr)
struct ACrg_coll *ACrg;
IGRshort *sm_type;
int nb_attr;
{
  int i;

  printf("Number of attributs found %d\n",nb_attr); 
  for(i=0;i<nb_attr;i++)
    print_attr1(&ACrg[i],sm_type[i]);
  return 1;
}
#endif

end implementation SMcomp;






