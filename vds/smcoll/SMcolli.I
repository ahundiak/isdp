/* $Id: SMcolli.I,v 1.1.1.1 2001/01/04 21:07:32 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        smcoll / SMcolli.I
 *
 * Description:
 *
 *	This class manage a collection of dynamic attributes and database 
 *      attributes with a cache. 
 *      If an attribute is user, it's directly retrieve in the collection
 *      If it's fail an database key exists, it's retreive through the cache
 *
 *
 * Dependencies:
 *
 *      ACdyn_col
 *
 * Revision History:
 *	$Log: SMcolli.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/01/15  18:04:30  pinnacle
# Replaced: smcoll/SMcolli.I for:  by v250_int for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/04/29  08:45:36  pinnacle
# Replaced: smcoll/SMcolli.I for:  by ksundar for vds.240
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
 *	08/17/93	J. Jasinczuk	Creation Date
 *      08/15/94        R. Manem        Modified AClist_attribute method -
 *                                      not to return OM_W_ABORT if no
 *                                      space available for database attributes.
 * -------------------------------------------------------------------------
 */
class implementation SMcoll;

#include "ACdyn_col.h"
#include "VDmem.h"

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMget_cache_id 

  Abstract
  	This function retreives the identificateur of the cache if given the
  	ACrg_coll (it creates the cache if not existing).

  Algorithm

	. send SMGetDbInfo to collid (get obj_type, fam, partnum, partrev)
	. if it fails cache_id = NULL_OBJID
	. else
		SMGetCacheAtt that retreives the cache if it already exists 
		or load it if from database if not.

  Returns
	1 if success
	0 if SMGetCacheAtt fails (DB info exist but cache cannot be loaded).
 ------------------------------------------------------------------------------
*/   
    
static int SMget_cache_id(
GRobjid      collid,         /* [I] Objid of the collection */
GRspacenum   collos,         /* [I] Osnum of the collection */
struct GRid *cache_id        /* [O] Id of the cache         */
)
/*
-fi*/
{
  char             object_type[80],family[80],partno[80],partrev[80];
  int              status;
  IGRlong          loc_msg;

  object_type[0] = family[0] = partno[0] = partrev[0] = '\0';

  status = om$send(msg = message SMcoll.SMGetDbInfo
		   (&loc_msg,object_type,family,partno,partrev),
		   senderid = NULL_OBJID,
		   targetid = collid,
		   targetos = collos,);
  if(!(status & loc_msg & 1)) cache_id->objid = NULL_OBJID;
  else
   {
        
     if(!SMGetCacheAtt(object_type,family,partno,partrev,OM_Gw_current_OS,
		       cache_id,NULL,NULL,FALSE))
      {
#ifdef JJ_DEBUG
	printf("Error SMGetCache for %s %s %s %s\n",
	       object_type,family,partno,partrev);
#endif
	return 0;
      }
   }
  return 1;
}

/*+me
 -------------------------------------------------------------------------
 Public Message SMGetDbInfo

 Abstract
   	That message gets the object_type,family,partno,partrev attributes. 

 Arguments

   IGRlong             *msg            O : Completion code.
   char                *object_type    O : The cache will be in directory
                                           IGENOD:object_type
   char                *family         O : family part  
   char                *partno         O : part number
   char                *partrev        O : part revision 	

 Status/Return code
	
  OM_S_SUCCESS		always
 -------------------------------------------------------------------------
-me*/

method SMGetDbInfo(IGRlong *msg; char *object_type; char *family;
		   char *partno; char *partrev)
{
  static char *name_att[] = {"object_type","family","partno","partrev",NULL};
  int          i;
  struct ACrg_coll attrib;
  int              status;
  IGRlong          loc_msg;

  i = 0;
  
  while(name_att[i])
   {
     strcpy(attrib.name,name_att[i]);
 
     status = om$send(msg = message ACdyn_col.ACget_named_attribute
		      (&loc_msg,&attrib),
		      targetid = my_id,
		      mode = OM_e_wrt_message);
     if(status & loc_msg & 1)
       switch(i)
	{
	case 0: strcpy(object_type,attrib.desc.value.att_txt); break;
	case 1: strcpy(family,attrib.desc.value.att_txt); break;
	case 2: strcpy(partno,attrib.desc.value.att_txt); break;
	case 3: strcpy(partrev,attrib.desc.value.att_txt); break;
	}
     else
      {*msg = OM_E_ABORT; return OM_S_SUCCESS;}
     i++;
   }
  
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
 Public Message SMSetDbInfo

 Abstract
   That message sets the object_type,family,partno,partrev attributes. 
   If this attributes are defined, for each operation, the collection
   will look in database to found the corresponding cache.
   This is the only method to change the database parameters.
   To change this parameter with ACadd_attribute will not work.

 Arguments

   IGRlong             *msg            O : Completion code.
   char                *object_type    I : The cache will be in directory
                                           IGENOD:object_type
   char                *family         I : family part  
   char                *partno         I : part number
   char                *partrev        I : part revision 	

 Status/Return code
	
  OM_S_SUCCESS		always
 -------------------------------------------------------------------------
-me*/

method SMSetDbInfo(IGRlong *msg; char *object_type; char *family;
		   char *partno; char *partrev)
{
  struct ACrg_coll list_att[4];
  IGRlong          loc_msg;
  IGRint           status;

  strcpy(list_att[0].name,"object_type");
  list_att[0].desc.type = AC_ATTRIB_TEXT;
  strcpy(list_att[0].desc.value.att_txt,object_type);

  strcpy(list_att[1].name,"family");
  list_att[1].desc.type = AC_ATTRIB_TEXT;
  strcpy(list_att[1].desc.value.att_txt,family);

  strcpy(list_att[2].name,"partno");
  list_att[2].desc.type = AC_ATTRIB_TEXT;
  strcpy(list_att[2].desc.value.att_txt,partno);
  
  strcpy(list_att[3].name,"partrev");
  list_att[3].desc.type = AC_ATTRIB_TEXT;
  strcpy(list_att[3].desc.value.att_txt,partrev);

  /* Try to add attribute : doesn't work if already existing */

  status = om$send(msg = message ACdyn_col.ACadd_list_attribute
		   (&loc_msg,4,list_att),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  if(!(status & loc_msg & 1))
   {
     status = om$send(msg = message ACdyn_col.ACmod_list_attribute
		      (&loc_msg,4,list_att),
		      targetid = my_id,
		      mode = OM_e_wrt_message);
   }

  *msg = loc_msg;
  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message

        ACgive_structure from NDmacro

  Abstract

   Given a foot name returns the corresponding geometric structure.
   It has been overriden to look for the foot also in the cache.

  Arguments
      int               *suc              O     0 FAILED 1 SUCCESS
      int               *direct_index     O/I   Very dangeous used only by
                                                symbol macros
      char              *footname         I     the name of the foot to find

      struct ret_struct *ptr_rst          O     the found struct.
      struct GRmd_env   *md_env           I     module environnement information



  Status/Return Code
      status == OM_S_SUCCESS    if success;
      status == OM_E_ABORT      if fails

 -------------------------------------------------------------------------
-mo*/

method ACgive_structure(int *suc,*direct_index;char *footname;
			struct ret_struct *ptr_rst;struct GRmd_env *md_env)
{
  IGRint           status;
  struct GRid      cache_id;

  status = om$send(msg = message ACdyn_col.ACgive_structure
		   (suc,direct_index,footname,ptr_rst,md_env),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  if(status & *suc & 1) return status;
 
  if(!SMget_cache_id(my_id,OM_Gw_current_OS,&cache_id))
    return status;
  
  if(cache_id.objid != NULL_OBJID)
   {
     status = om$send(msg = message ACdyn_col.ACgive_structure
		      (suc,direct_index,footname,ptr_rst,md_env),
		      targetid = cache_id.objid,
		      targetos = cache_id.osnum);
     return status;
   }
  else 
    return status;
 
}

/*+mo
 -------------------------------------------------------------------------
 Overridden Message AClist_attribute

        AClist_attribute from ACrg_collect

 Abstract
   	Overriden to return attributes that are in the cache and in the 
	collection.
 	This message doesn't reset the object_type, family, partname, partrev 

 Arguments
	IGRlong		 *msg		O	Completion code
	IGRint		 list_len	I	size of list_att
	struct ACrg_coll *list_att	O	The collection to fill with 
						attributes
	IGRint		 *nb_attr	O	total nb attributes in the 
						collection
 Status/Return code

	OM_S_SUCCESS	if success
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-mo*/

method AClist_attribute(IGRlong *msg; IGRint list_len;
			struct ACrg_coll *list_att; IGRint *nb_attr )
{
  char             object_type[80],family[80],partno[80],partrev[80];
  IGRlong          loc_msg;
  IGRint           status;
  int              nb_db_att;
  
  status = om$send(msg = message ACdyn_col.AClist_attribute
		   (msg,list_len,list_att,nb_attr),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  if(!(status & *msg & 1)) return status;
 
  status = om$send(msg = message SMcoll.SMGetDbInfo
		   (&loc_msg,object_type,family,partno,partrev),
		   targetid = my_id);
  if(!(status & loc_msg & 1)) goto success;

  if(list_len == 0) nb_db_att = 0;
  else              nb_db_att = list_len - *nb_attr;

  /* List len = 0 means user just want to list number of attributes */ 

/* deleted the setting of return message to OM_E_ABORT  - rmn
   there may not be any database attributes at all for the object.

  if(list_len > 0 && nb_db_att <= 0) {*msg = OM_E_ABORT; return OM_S_SUCCESS;}
*/
  if(list_len > 0 && nb_db_att <= 0) { return OM_S_SUCCESS;}
    
  if(!(SMGetCacheAtt(object_type,family,partno,partrev,OM_Gw_current_OS,
		     NULL,list_att ? &list_att[*nb_attr] : NULL,
		     &nb_db_att,1)))
   {
#ifdef JJ_DEBUG
     printf("Error SMGetCache for %s %s %s %s\n",
	    object_type,family,partno,partrev);
#endif
     *msg = MSFAIL;
     return OM_S_SUCCESS;
   }
  *nb_attr += nb_db_att;

 success:
  *msg  = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
 Overridden Message ACget_named_attribute

        ACget_named_attribute from ACrg_collect

 Abstract
	Get an attribute in the ACrg_collect if given its name.
   	Overriden to look for the attribute name also in the cache.

 Arguments
	IGRlong		 *msg		O	Completion code 
						msg = TRUE if attribute exists
						FALSE else.
	struct ACrg_coll *attrib	I/O	I = attribute name to find
						O = attribute value and type

 Status/Return code

	OM_S_SUCCESS	if success
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-mo*/

method ACget_named_attribute(IGRlong *msg; struct ACrg_coll *attrib)
{
  IGRint           status;
  struct GRid      cache_id;
  
  /* Try to find attributes in my own attributes           */

  status = om$send(msg = message ACdyn_col.ACget_named_attribute
		   (msg,attrib),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  if(status & *msg & 1) return status;
 
  /* Not found , try to find it in the cache               */

  if(!SMget_cache_id(my_id,OM_Gw_current_OS,&cache_id))
    return status;

  status = om$send(msg = message ACrg_collect.ACget_named_attribute
		   (msg,attrib),
		   targetid = cache_id.objid,
		   targetos = cache_id.osnum);
  if(!(status & *msg & 1)){ return OM_S_SUCCESS;}
  else return OM_S_SUCCESS;
  
}

/*+mo
 -------------------------------------------------------------------------
 Overridden Message ACget_attribute_at_index

        ACget_attribute_at_index from ACrg_collect

 Abstract
	Get an attribute in the ACrg_collect if given its name.
   	Overriden to look for the attribute also in the cache.
	By definition lower index are in my own collection and higher are in 
	the cache.

 Arguments
	IGRlong		 *msg		O	Completion code 
						msg = TRUE if attribute exists
						FALSE else.
	IGRint		 index		I	index of the attribute to find.
	struct ACrg_coll *attrib	O	returned attribute at index.


 Status/Return code

	OM_S_SUCCESS	if success
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-mo*/


method ACget_attribute_at_index(IGRlong *rc; IGRint index;
				struct ACrg_coll *attrib )
{
  IGRlong      msg;
  IGRint       status,nb_attr,my_own_nb_attr; 
  struct  GRid cache_id;

  *rc = MSFAIL;

  if( index < 0) return OM_S_SUCCESS;
  
  /* Found number of attributes in my own list */

  status = om$send(msg = message ACdyn_col.AClist_attribute
		   (&msg,0,0,&my_own_nb_attr),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  if(!(status & msg & 1)) return status;

  /* Look for this attribute in my_own attributes */  

  if( index < my_own_nb_attr)
  {
    status = om$send(msg = message ACdyn_col.ACget_attribute_at_index
		     (rc,index,attrib ),
		     targetid = my_id,
		     mode = OM_e_wrt_message);
    return status;
  }
  else
   {
     /* Look for this attribute in cache */

     index -= my_own_nb_attr;
     if(!SMget_cache_id(my_id,OM_Gw_current_OS,&cache_id))
       return OM_S_SUCCESS;
  
     if(cache_id.objid != NULL_OBJID)
      {
	status = om$send(msg = message ACrg_collect.ACget_attribute_at_index
			 (rc,index,attrib ),
			 targetid = cache_id.objid,
			 targetos = cache_id.osnum);
	return status;
      }
     else
       return OM_S_SUCCESS;
   }
}

/*+mo
 -------------------------------------------------------------------------
 Overridden Message ACadd_list_attribute

        ACadd_list_attribute from ACrg_collect

 Abstract
   	Overriden to add attributes only if they are not already in the cache.

 Arguments
	IGRlong		 *msg		O	Completion code
	IGRint		 list_len	I	size of list_att
	struct ACrg_coll *list_att	I	The list of attributes to add.

 Status/Return code

	OM_S_SUCCESS	if success
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-mo*/

method ACadd_list_attribute(IGRlong *msg; IGRint list_len;
			    struct ACrg_coll *list_att )
{
  int              status;
  IGRlong          loc_msg;
  int              i;
  struct GRid      cache_id;
  struct ACrg_coll tmp_attrib;

  if(!SMget_cache_id(my_id,OM_Gw_current_OS,&cache_id))
   {*msg = MSFAIL; return OM_S_SUCCESS;}

  for(i=0;i<list_len;i++)
   {
     /* Ignore family,partname,partrev,object_type    */

     if(!(strcmp(list_att[i].name,"object_type")) ||
	!(strcmp(list_att[i].name,"family"))      ||
	!(strcmp(list_att[i].name,"partno"))      ||
	!(strcmp(list_att[i].name,"partrev")))
       continue;

     /* Add the attribute only if not existing in the cache */

     if(cache_id.objid == NULL_OBJID) status = 2; /* No cache existing */
     else
      {
	strcpy(tmp_attrib.name,list_att[i].name);
	status = om$send(msg = message ACdyn_col.ACget_named_attribute
			 (&loc_msg,&tmp_attrib),
			 targetid = cache_id.objid,
			 targetos = cache_id.osnum);
      }
     
     if(!(status & loc_msg & 1))
      {
	status = om$send(msg = message ACdyn_col.ACadd_list_attribute
			 (msg, 1, &list_att[i]),
			 targetid = my_id,
			 mode = OM_e_wrt_message);
	if(!(status & *msg & 1)) return status; 
      }
   }

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
 Overridden Message ACmod_list_attribute

        ACmod_list_attribute from ACrg_collect

 Abstract
   	Overriden to modify attributes only if they are not already in the 
	cache.

 Arguments
	IGRlong		 *msg		O	Completion code
	IGRint		 list_len	I	size of list_att
	struct ACrg_coll *list_att	I	The list of attributes to add.

 Status/Return code

	OM_S_SUCCESS	if success
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-mo*/

method ACmod_list_attribute(IGRlong *msg; IGRint list_len;
			    struct ACrg_coll *list_att )
{
  int              status;
  IGRlong          loc_msg;
  int              i;
  struct GRid      cache_id;
  struct ACrg_coll tmp_attrib;

  if(!SMget_cache_id(my_id,OM_Gw_current_OS,&cache_id))
    {*msg = MSFAIL; return OM_S_SUCCESS;}

  for(i=0;i<list_len;i++)
   {
     /* Ignore family,partname,partrev,object_type    */

     if(!(strcmp(list_att[i].name,"object_type")) ||
	!(strcmp(list_att[i].name,"family"))      ||
	!(strcmp(list_att[i].name,"partno"))      ||
	!(strcmp(list_att[i].name,"partrev")))
       continue;

      /* Add the attribute only if not existing in the cache */

     if(cache_id.objid == NULL_OBJID) status = 2; /* No cache existing */
     else
      {
	strcpy(tmp_attrib.name,list_att[i].name);
	status = om$send(msg = message ACdyn_col.ACget_named_attribute
			 (&loc_msg,&tmp_attrib),
			 targetid = cache_id.objid,
			 targetos = cache_id.osnum);
      }
     
     if(!(status & loc_msg & 1))
      {
	status = om$send(msg = message ACdyn_col.ACmod_list_attribute
			 (msg, 1, &list_att[i]),
			 targetid = my_id,
			 mode = OM_e_wrt_message);
	if(!(status & *msg & 1)) return status; 
      }
   }

  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
 Overridden Message ACset_list_attribute

        ACset_list_attribute from ACrg_collect

 Abstract
	Kills all existing attributes and set the ACrg_coll with the
	new one.
   	Overriden to do not set attributes who belongs to the cache .

 Arguments
	IGRlong		 *msg		O	Completion code
	IGRint		 list_len	I	size of list_att
	struct ACrg_coll *list_att	I	The list of attributes to set.

 Status/Return code

	OM_S_SUCCESS	if success
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-mo*/

method ACset_list_attribute(IGRlong *msg; IGRint list_len;
			    struct ACrg_coll *list_att)
{
  char             object_type[80],family[80],partno[80],partrev[80];
  int              status;
  IGRlong          loc_msg;
  int              i;
  struct GRid      cache_id;
  struct ACrg_coll tmp_attrib,*real_list_att = NULL;
  int              real_list_len = 0;

  /* We need family, partno,partrev below */

  status = om$send(msg = message SMcoll.SMGetDbInfo
		   (&loc_msg,object_type,family,partno,partrev),
		   targetid = my_id);
  if(!(status & loc_msg & 1)) cache_id.objid = NULL_OBJID;
  else
   {
     if(!SMGetCacheAtt(object_type,family,partno,partrev,OM_Gw_current_OS,
		       &cache_id,NULL,NULL,FALSE))
      {
#ifdef JJ_DEBUG
	printf("Error SMGetCache for %s %s %s %s\n",
	       object_type,family,partno,partrev);
#endif
	*msg = MSFAIL;
	return OM_S_SUCCESS;
      }
   }
  
  /* We want to set only attributes which are not database identifier and *
   * which are not already in the cache. We create this list now.         *
   */

  if(list_len > 0)
   {
     real_list_att = _MALLOC(list_len, struct ACrg_coll);
     if(!real_list_att)
       {printf("Memory problem\n"); *msg = MSFAIL; return OM_S_SUCCESS; }
   }
  
  
  for(i=0;i<list_len;i++)
   {
     if(!(strcmp(list_att[i].name,"object_type")) ||
	!(strcmp(list_att[i].name,"family"))      ||
	!(strcmp(list_att[i].name,"partno"))      ||
	!(strcmp(list_att[i].name,"partrev")))
       continue;


#ifdef	NO_MORE_CHECKING
     /* Add the attribute only if not existing in the cache */

     if(cache_id.objid == NULL_OBJID) status = 2; /* No cache existing */
     else
      {
	strcpy(tmp_attrib.name,list_att[i].name);
	status = om$send(msg = message ACrg_collect.ACget_named_attribute
			 (&loc_msg,&tmp_attrib),
			 targetid = cache_id.objid,
			 targetos = cache_id.osnum);
      }

     if(!(status & loc_msg & 1))
      {
	memcpy(&real_list_att[real_list_len],list_att[i].name,
	       sizeof(struct ACrg_coll));
	real_list_len++;
      }
#endif

	/*
	 * We will copy all the attributes in the collector.
	 */
	memcpy(&real_list_att[real_list_len],list_att[i].name,
	       sizeof(struct ACrg_coll));
	real_list_len++;
   }

  status = om$send(msg = message ACdyn_col.ACset_list_attribute
		   (msg,real_list_len,real_list_att),
		   targetid = my_id,
		   mode = OM_e_wrt_message);
  if(!(status & *msg & 1))
   {printf("Error select list attribute\n");goto wrapup;}
  
  if(cache_id.objid != NULL_OBJID)
   {
     status = om$send(msg = message SMcoll.SMSetDbInfo
		      (&loc_msg,object_type,family,partno,partrev),
		      targetid = my_id);
     if(!(status &loc_msg & 1)) goto wrapup;
   }
		      

  _FREE(real_list_att) ;
  *msg = OM_S_SUCCESS;
  return  OM_S_SUCCESS;

 wrapup:
  _FREE(real_list_att) ;
  *msg = MSFAIL;
  return  OM_S_SUCCESS;
}



/*+mo
 -------------------------------------------------------------------------
 Overridden Message ACset_att_prop

        ACset_att_prop from ACdyn_col

 Abstract
        Set the properties of an attribute.
   	Overriden to set attribute properties only if these attributes does
	not belong to the cache.

 Arguments
	IGRlong		 *msg		O	Completion code
	IGRchar		 *att_name	I	name of the attribute
	IGRshort	 int_prop	I	internal properties to set.
	IGRshort	 user_prop	I	user properties to set.

 Status/Return code

	OM_S_SUCCESS	if success
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-mo*/

method ACset_att_prop(IGRlong *msg; IGRchar *att_name;
		      IGRshort int_prop; IGRshort user_prop )
{
  int              status;
  IGRlong          loc_msg;
  struct GRid      cache_id;
  struct ACrg_coll tmp_attrib;

  if(!SMget_cache_id(my_id,OM_Gw_current_OS,&cache_id))
   {*msg = MSFAIL; return OM_S_SUCCESS;}

  if(!(strcmp(att_name,"object_type")) ||
     !(strcmp(att_name,"family"))      ||
     !(strcmp(att_name,"partno"))      ||
     !(strcmp(att_name,"partrev")))
    goto success;


  /* Set the properties of attribute only if not existing in the cache */
  if(cache_id.objid == NULL_OBJID) status = 2; /* No cache existing */
  else
   {
     strcpy(tmp_attrib.name,att_name);
     status = om$send(msg = message ACdyn_col.ACget_named_attribute
		      (&loc_msg,&tmp_attrib),
		      targetid = cache_id.objid,
		      targetos = cache_id.osnum);
   }

  if(!(status & loc_msg & 1))
   {
     status = om$send(msg = message ACdyn_col.ACset_att_prop
		      (msg,att_name,int_prop, user_prop),
		      targetid = my_id,
		      mode = OM_e_wrt_message);
     if(!(status & *msg & 1)) return status; 
   }   

 success:
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/*+mo
 -------------------------------------------------------------------------
 Overridden Message ACget_att_prop

        ACget_att_prop from ACdyn_col

 Abstract
        Get the user and internal properties of an attribute.
 	If the attribute belongs to the cache (from database), int_prop is set 
	to AC_ATTRIB_LOCK and user_prop to 0. 
 	In the other case, it returns ACdyn_coll properties.

 Arguments
	IGRlong		 *msg		O	Completion code
	IGRchar		 *att_name	I	name of the attribute
	IGRshort	 *int_prop	O	returned internal properties .
	IGRshort	 *user_prop	O	returned user properties .

 Status/Return code

	OM_S_SUCCESS	if success
	OM_E_ABORT	if fails
 -------------------------------------------------------------------------
-mo*/

method ACget_att_prop(IGRlong *msg; IGRchar *att_name;
		      IGRshort *int_prop; IGRshort *user_prop )
{
  int              status;
  IGRlong          loc_msg;
  struct GRid      cache_id;
  struct ACrg_coll tmp_attrib;

  if(!SMget_cache_id(my_id,OM_Gw_current_OS,&cache_id))
   {*msg = MSFAIL; return OM_S_SUCCESS;}

  if(!(strcmp(att_name,"object_type")) ||
     !(strcmp(att_name,"family"))      ||
     !(strcmp(att_name,"partno"))      ||
     !(strcmp(att_name,"partrev")))
    {*int_prop = AC_ATTRIB_LOCK; *user_prop = 0; goto success; }

  /* Get the properties of attribute only if not existing in the cache */

  if(cache_id.objid == NULL_OBJID) status = 2; /* No cache existing */
  else
   {
     strcpy(tmp_attrib.name,att_name);
     status = om$send(msg = message ACdyn_col.ACget_named_attribute
		      (&loc_msg,&tmp_attrib),
		      targetid = cache_id.objid,
		      targetos = cache_id.osnum);
   }

  if(!(status & loc_msg & 1))
   {
     status = om$send(msg = message ACdyn_col.ACget_att_prop
		      (msg,att_name,int_prop, user_prop),
		      targetid = my_id,
		      mode = OM_e_wrt_message);
     if(!(status & *msg & 1)) return status; 
   } 
  else
    { *int_prop = AC_ATTRIB_LOCK; *user_prop = 0; }/* Comes from database */

 success:
  *msg = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

end implementation SMcoll;







