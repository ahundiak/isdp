/* $Id: SMNewComp.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMNewComp.I
 *
 * Description:
 *
 *      This file implements function used to update Compartment from 
 *	older version to 2.4.
 *
 * Dependencies:
 *
 *      Root
 *
 * Revision History:
 *	$Log: SMNewComp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
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
# Revision 1.2  1996/04/29  08:54:12  pinnacle
# Replaced: smcomp/imp/SMNewComp.I for:  by ksundar for vds.240
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
 *      08/13/93	J. Jasinczuck	Creation date.
 *	08/22/93	A. Zuurhout	Corr in SMUpCompNewVers.
 *					Check if compartment is new.
 *
 * -------------------------------------------------------------------------
 */
    

class implementation SMcoll;

#include "ACattrib.h"
#include "ACrg_collect.h"
#include "ACdyn_col.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "SMCompForm.h"
#include "nddef.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "VDmem.h"

/* #define DEBUG          1*/
#define AS_DEBUG       1
/* #define JJ_DEBUG      1   */

#include "AS_status.h"

#ifdef JJ_DEBUG
from SMcomp import SMListAtt;
#endif

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMUpdCompNewVers

  Abstract

	This function updates the compartments from older version to 2.4 
	version.
	Basically it removes all the static attributes coming from database
	in the first parent of the compartment (ACrg_coll).
	These attributes are putin the cache.

  Algorithm

	- Find all the compartment objects in the design file (SM$CritSel).
	- for all the compart:
		- get the ACrg root :NDget_objects(ND_ROOT, &ACdyn) 
		- get the list of attributes in that ACrg ->nb_att, list_att
		- nb_new_att = 0;
		- add a new attribute object_type = compartment:
			new_list_att[nb_new_att].name = "object_type" ..
		- nb_new_att++
		- nb_cache_att = 0
		- for j=0 j< nb_att
			- send ACdyn_col.ACget_att_prop to ACdyn
			- if int_prop[j] & AC_ATTRIB_LOCK and if list_att is not
			family, partno or partrev, put this att in the cache
			(cache_att[nb_cache_att++])
			- if if is "family" -> store the att in code_att[0]
			- if if is "partno" -> store the att in code_att[1]
			- if if is "partrev" -> store the att in code_att[2]
			- fill new_int_prop, new_user_prop and new_list_att
			with int_prop, user_prop and list_att
		- create the cache if not already existing:
			SMcreateCacheCode(code_att[0,1,2]-> code)
			if(di$translate(code = cache_obj) not success)
				- SMCreateCacheDir
					("osname":IGENOD:CACHE:compartment)

				- construct cache_obj as an ACrg_collect
				- GRputname (code) to cache_obj
				- ACset_list_attribute (cache_att) to cache_obj
			
		- ACset_list_attribute (new_list_att) to ACdyn
		- ACset_att_prop(new_int_prop,new_user_prop) to ACdyn


  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
int SMUpdCompNewVers()
{
  IGRlong           status,msg;
  struct SMObjList  list;
  int               i,j;
  struct ACrg_coll  list_att[SM_MAX_CO_ATTR];
  struct ACrg_coll  new_list_att[SM_MAX_CO_ATTR],cache_att[SM_MAX_CO_ATTR],
                    code_att[5];
  int               nb_att,nb_new_att,nb_cache_att;
  IGRshort          int_prop[SM_MAX_CO_ATTR],user_prop[SM_MAX_CO_ATTR];
  IGRshort          new_int_prop[SM_MAX_CO_ATTR],new_user_prop[SM_MAX_CO_ATTR];
  struct GRid       ACdyn, cache_obj;
  int               nb_roots;	
  IGRchar           code[DI_PATH_MAX],osname[DI_PATH_MAX],obj_dir[DI_PATH_MAX];
	     

  list.list       = NULL;
  list.nb_objects = 0;

  /* Find all compart in file */

  status = SM$CritSel(msg = &msg, type = SM_COMPART, list  = &list);
  if(!(status & 1) || msg != MSSUCC)
   {printf("Error found list of compart\n");return 0; }

  if(list.nb_objects <= 0) return 1; /* Nothing to do */
   
  for(i = 0 ; i < list.nb_objects; i++)
   {
     /* Get the ACrg of compartment */
     status = om$send(msg = message NDnode.NDget_objects
		      (ND_ROOT,&ACdyn,1,NULL, 0,0,&nb_roots),
		      senderid = NULL_OBJID,
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
		      
     if(!(status & 1))
      {
	printf("Warning, compartment %d,%d has no parent\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
	continue;
      }

     /* Get list of all attributs for compartment */
     status = om$send(msg = message ACdyn_col.AClist_attribute
		      (&msg,SM_MAX_CO_ATTR,list_att,&nb_att),
		      mode = OM_e_wrt_message,
		      senderid = NULL_OBJID,
		      targetid = ACdyn.objid,
		      targetos = ACdyn.osnum);
     if(!(status & msg & 1))
      {
	printf("Warning: problem get attribut for compart %d,%d\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
	continue;
      }

     
     /* attribute object type don't exists in old version */
     /* Add it now                                        */

     if( strcmp( list_att[0].name, "object_type" ) == 0 ){
       /*
	* Object is from new type -> do nothing.
	*/
       continue;
     }
    
     nb_new_att = 0;
     strcpy(new_list_att[nb_new_att].name,"object_type");
     new_list_att[nb_new_att].desc.type = AC_ATTRIB_TEXT;
     strcpy(new_list_att[nb_new_att].desc.value.att_txt,"compartment");
     new_int_prop[nb_new_att]  = AC_ATTRIB_LOCK;
     new_user_prop[nb_new_att] = SM_SYST_ATT;

     nb_new_att++;

#if 0
     printf("-------------------------------------\n");
#endif

     nb_cache_att = 0;
     /* Get properties of all attributes */
     for(j = 0; j < nb_att; j++)
      {
	status = om$send(msg = message ACdyn_col.ACget_att_prop
			 (&msg,list_att[j].name,&int_prop[j],&user_prop[j]),
			 mode = OM_e_wrt_message,
			 senderid = NULL_OBJID,
			 targetid = ACdyn.objid,
			 targetos = ACdyn.osnum); 
	if(!(status & msg & 1))
	 { int_prop[j] = 0; user_prop[j] = SM_USER_ATT;}
	
	if(int_prop[j] & AC_ATTRIB_LOCK)
	 {
	   /* If it's not family - partname - partrev - put it in cache */
	   if(strcmp(list_att[j].name,"family") &&
	      strcmp(list_att[j].name,"partno") &&
	      strcmp(list_att[j].name,"partrev"))
	    {
	      memcpy(&cache_att[nb_cache_att],
		     &list_att[j],sizeof(struct ACrg_coll));
	      nb_cache_att++;
	    }
	   else /* Remember family - partno - partrev */
	    {
	      if(strcmp(list_att[j].name,"family") == 0)
		memcpy(&code_att[0],&list_att[j],sizeof(struct ACrg_coll));
	      if(strcmp(&list_att[j].name,"partno") == 0)
		memcpy(&code_att[1],&list_att[j],sizeof(struct ACrg_coll));
	      if(strcmp(list_att[j].name,"partrev") == 0)
		memcpy(&code_att[2],&list_att[j],sizeof(struct ACrg_coll));
	    }
	 }
	new_int_prop[nb_new_att]  = int_prop[j];
	new_user_prop[nb_new_att] = user_prop[j];
	
	memcpy(&new_list_att[nb_new_att],&list_att[j],
	       sizeof(struct ACrg_coll));
	nb_new_att++;
      }

#if 0
     print_all_attr(new_list_att,int_prop,nb_new_att);
#endif
     /* Create a cache if not already existing */

     /* Create name of cache */
     if(!SMCreateCacheCode("compartment",
			   code_att[0].desc.value.att_txt,  /* family  */
			   code_att[1].desc.value.att_txt,  /* partno  */
			   code_att[2].desc.value.att_txt,  /* partrev */
	                   list.list[i].obj_id.osnum,
	                   code))
       return 0;
     
     /* If the cache does not exists, create a new one an add to it */
     /* all static attributes of the compartment                    */
        
     if (!( di$translate (objname = code,
			  p_objid = &cache_obj.objid,
			  p_osnum = &cache_obj.osnum )& 1 ) )
      {
	
	if(di$give_pathname(osnum = ACdyn.osnum,
			    pathname = osname) != DIR_S_SUCCESS)
	 {printf("Error pathname of osnum %d\n",
		 ACdyn.osnum); return 0;}
	
	sprintf((char *)obj_dir,"%s:IGENOD:CACHE:compartment",osname);
	
	if(!SMCreateCacheDir(obj_dir,osname)) 
	 {printf("Error creation of directory %s\n",obj_dir);}

	/* Construct the ACrg_collection for cache */
	cache_obj.osnum = ACdyn.osnum;
	status = om$construct(classid = OPP_ACrg_collect_class_id,
			      p_objid = &cache_obj.objid,
			      osnum   = cache_obj.osnum);
	if(!(status & 1))
	 { printf("Error construct cache object\n");return 0;}
	
	 status = om$send(msg = message GRgraphics.GRputname(&msg,code),
			  senderid = NULL_OBJID,
			  targetid = cache_obj.objid,
			  targetos = cache_obj.osnum);
	if(!(status & msg & 1))
	 {
	   /* Big mistake because we cannot retrieve this object */
	   printf("Error, can't name cache object %s\n",code);
	   return 0;
	 }
	
	 status = om$send(msg = message ACrg_collect.ACset_list_attribute
			  (&msg,nb_cache_att ,cache_att),
			  senderid = NULL_OBJID,
			  targetid = cache_obj.objid,
			  targetos = cache_obj.osnum);
	if(!(status & msg & 1))
	 {
	   printf("Cannot add attribute in cache for compart %d,%d cache_obj_coll %d,%d\n",
		  list.list[i].obj_id.objid,list.list[i].obj_id.osnum,
		  cache_obj.objid,cache_obj.osnum);
	   return 0;
	 }
      }

     /* Next line are curious : if I call directly ACset_list_attribute */
     /* with new_list_att, family, partname, partrev are not update     */
     /* Actually the reason is ACset_list_attribute call ACadd_list_attribute */
     /* with respect to object. This message ignore all this attributes */
     /* So I first remove all attributes and add one by one in new coll */

     status = om$send(msg = message ACrg_collect.ACset_list_attribute
		      (&msg, 0, NULL),
		       mode = OM_e_wrt_message,
		      senderid = NULL_OBJID,
		      targetid = ACdyn.objid,
		      targetos = ACdyn.osnum);
     if(!(status & msg & 1))
      {
	printf("Cannot reset attribute to compartment %d,%d ACdyn_coll %d,%d\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum,
	       ACdyn.objid,ACdyn.osnum);
       continue;
      }

     status = om$send(msg = message ACrg_collect.ACadd_list_attribute
		      (&msg, nb_new_att, new_list_att),
		      mode = OM_e_wrt_message,
		      senderid = NULL_OBJID,
		      targetid = ACdyn.objid,
		      targetos = ACdyn.osnum);
     if(!(status & msg & 1))
      {
	printf("Cannot add attribute to compartment %d,%d ACdyn_coll %d,%d\n",
	       list.list[i].obj_id.objid,list.list[i].obj_id.osnum,
	       ACdyn.objid,ACdyn.osnum);
	continue;
      }
     
     
     /* Set the properties of each attributes  */  
     for(j = 0; j < nb_new_att;  j++)
      {
	status = om$send(msg = message ACdyn_col.ACset_att_prop
			 (&msg,new_list_att[j].name,
			  new_int_prop[j],new_user_prop[j]),
			 mode = OM_e_wrt_message,
			 senderid = NULL_OBJID,
			 targetid = ACdyn.objid,
			 targetos = ACdyn.osnum); 
	if(!(status & msg & 1))
	 { printf("Cannot set properties of atributes %s\n",new_list_att[j].name);}
      }

     

#ifdef JJ_DEBUG
    {
      int              nb_att;
      struct ACrg_coll ACrg[SM_MAX_CO_ATTR];
      IGRshort         att_type[SM_MAX_CO_ATTR];
         
        /* Get attributes of the compart */
      status = om$send( msg = message SMcomp.SMListAtt
		       (&msg,SM_MAX_CO_ATTR ,&nb_att,ACrg,att_type),
		       senderid = NULL_OBJID,
		       targetid = list.list[i].obj_id.objid,
		       targetos = list.list[i].obj_id.osnum);
      if(!(status & msg & 1)) 
       {
	 printf("Problem with SMListAtt %d.%d\n",
		list.list[i].obj_id.objid,list.list[i].obj_id.osnum);
       }
      else
       {
	 print_all_attr(ACrg,att_type,nb_att);
       }
    }
#endif
   } 

  _FREE(list.list) ;
  return 1;
}     


end implementation SMcoll;






