/* $Id: SMcache.I,v 1.1.1.1 2001/01/04 21:07:32 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:        smcoll / SMcache.I
 *
 * Description:
 *
 *	This file contains functions used to manage the cache for static
 *	attributes from the database.
 *
 * Dependencies:
 *
 *      Root
 *
 * Revision History:
 *	$Log: SMcache.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:32  cvs
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
# Revision 1.2  1996/04/29  06:27:46  pinnacle
# Replaced: smcoll/SMcache.I for:  by ksundar for vds.240
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
 * -------------------------------------------------------------------------
 */

class implementation Root;

#include  <stdio.h>
#include  "OMerrordef.h"
#include  "OMprimitives.h"
#include  "exmacros.h"
#include  "PDUerror.h"
#include  "PDUstr.h"
#include  "PDMfs.h"
#include  "igrtypedef.h"
#include  "igetypedef.h"
#include  "gr.h"
#include  "nddef.h"
#include  "ACattrib.h"
#include  "ACrg_collect.h"
#include  "VDSutil.h"

#include "expression.h"
#include "expmacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include  "ms.h"
#include  "msdef.h"
#include  "msmacros.h"

#include "SMmsg.h"
#include "VDmsg.h"
#include "SMdef.h"
#include "VDmem.h"

from GRgraphics import GRputname;
from expression import NDgive_value;             
from NDnode import NDchg_state;            
            
from ACrg_collect import AClist_attribute,ACadd_list_attribute,
                         ACget_named_attribute,ACset_list_attribute; 

#define         AS_DEBUG        1

extern  struct	PDUrefresh  *refresh;
extern  double	VDconv_to_vdsunits;

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMCreateCacheDir

  Abstract
  	This function creates the directory for the cache if it doesn't 
	already exists.

  Algorithm

	. if di$translate(obj_dir) fails:
		. if di$translate(cache_dir= osname:IGENOD:CACHE) fails
			di$mkdir(cache_dir)
		. di$mkdir(obj_dir)

  Returns
	1 if success
	0 if fails
 ------------------------------------------------------------------------------
*/   
int SMCreateCacheDir(
char *obj_dir,     /* [I] Directory for this kind of object */
char *osname       /* [I] Name of object space              */             
)
/*
-fi*/
{
  struct GRid tmp_obj;
  DIchar      cache_dir[DI_PATH_MAX];

 /* Look if directory for this kind of object already exists */
  if( di$translate(objname = obj_dir,
		    p_objid = &tmp_obj.objid) != DIR_S_SUCCESS )
   {
     /* Look if directory CACHE is already existing */
     sprintf(cache_dir,"%s:IGENOD:CACHE",osname);
     if(di$translate(objname = cache_dir,
		       p_objid = &tmp_obj.objid) != DIR_S_SUCCESS)
      {
	if(di$mkdir(dirname = cache_dir,
		      p_dirid = &tmp_obj.objid) != DIR_S_SUCCESS)
	  {printf("Error creation %s\n",cache_dir);  return 0;}
      }

     
     /* Create directory for all type of objects */
     if(di$mkdir(dirname = obj_dir,
		   p_dirid = &tmp_obj.objid) != DIR_S_SUCCESS)
      {printf("Error creation %s\n",obj_dir);  return 0;}
   }

  return 1;
}
/*+fi
 -------------------------------------------------------------------------
  Internal Function SMCreateCacheCode

  Abstract
  	This function creates the name of the cache:
		code = osname:IGENOD:CACHE:family_partnum_partrev


  Returns
	1 if success
	0 if fails
 ------------------------------------------------------------------------------
*/

int SMCreateCacheCode(
char    type_obj[],     /* [I] Type of object */
char    family[],       /* [I] Catalog name   */
char    partnum[],      /* [I] Part Id        */
char    partrev[],      /* [I] Part revision  */
OMuword osnum,          /* [I] osnum          */ 
char    code[]          /* [O] Created code   */   
)
/*
-fi*/
{
  char osname[DI_PATH_MAX];

  if(!code) return 0;
  code[0] = '\0';
  osname[0] = '\0';
  if(di$give_pathname(osnum = osnum, pathname = osname) != DIR_S_SUCCESS)
    {printf("Error pathname of osnum %d\n",osnum); return 0;}
  sprintf(code,"%s:IGENOD:CACHE:%s:%s_%s_%s",
	  osname,type_obj,family,partnum,partrev);
  return 1;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMLoadCache

  Abstract
  	This function loads the corresponding parts from database and    
 	creates the cache (it fills it with the DB attributes of that part).
 	The caller has to assume that the corresponding cache does not   
 	already exists .                                                 
 	Return the grid cache_id (if not NULL)                           

  Algorithm

  	. VDSverify_login   (else return 0)
 	. VDSverify_project (else return 0)
 	. retrieve the attributes of the given part (return 0 if fail)
  	(VDSGetPartAtt( nb_stat, stat_att) )
 	. create the cache dir in the given osnum: 
 		obj_dir = "osname:IGENOD:CACHE:type_obj"
 	. construct the ACrg_collect (cache_id) in this osnum
 	. if osnum != cur_os save_flag = 0 (cache never saved in ref)
 	. look for the expression "obj_dir: DestroyAtSave" 
 	. if it doesn't exist save_flag = 1
 	. else give its value and set save_flag
  	. if save_flag = 0 send NDnode.NDchange_state(ND_DEL_NO_CH) to
 	the cache (it will not be saved )
 	. GRputname to the cache 
 		(osname:IGENOD:CACHE:type_obj:family_partnum_partrev)
 	. if it fails delete the cache.
 	. put the attributes in the cache (ACset_list_att with stat_att[3])
	

  Returns
	1 if success
	0 if fails
 ------------------------------------------------------------------------------
*/
static int SMLoadCache(
char         type_obj[],     /* [I] Type of object              */
char         family[],       /* [I] Catalog name                */
char         partnum[],      /* [I] Part Id                     */
char         partrev[],      /* [I] Part revision               */
OMuword      osnum,          /* [I] osnum                       */ 
struct GRid *cache_id        /* [O] Cache id of the new object  */ 
)
/*
-fi*/
{
  IGRlong               msg;
  IGRint                status;      
  struct GRid           tmp_cache,*p_cache,tmp_obj;
  int                   return_code = 1;
  struct ACrg_coll     *stat_att = NULL;
  int                   nb_stat;
  DIchar                obj_dir[DI_PATH_MAX],
                        osname[DI_PATH_MAX],exp_name[DI_PATH_MAX];
  IGRchar               code[DI_PATH_MAX];
  double                val;
  IGRboolean            save_flag; 
  GRspacenum            cur_os;

  p_cache = cache_id ? cache_id : &tmp_cache ;


  if(VDSverify_login() != PDM_S_SUCCESS)
  {
    ex$message(msgnumb = SM_E_CmNoDbLog);
    return 0;
  }

  if(VDSverify_project() != OM_S_SUCCESS)
   {
     ex$message(msgnumb = VD_E_PrUsNotSel);
     return 0;
   }

  /* Retrieve all static attributes for this parts  */



  if(!VDSGetPartAtt(family,partnum,partrev,NULL,&nb_stat,&stat_att,
		   (int *)NULL,(struct ACrg_coll *)NULL))
   {  
     ex$message(msgnumb = SM_E_CmNoDbAtt);
     return_code = 0;
     goto free_mem;
   }

  /* The cache is created in a directory depending on reference file */

  if(di$give_pathname(osnum = osnum, pathname = osname) != DIR_S_SUCCESS)
   {printf("Error pathname of osnum %d\n",osnum); return 0;}

  sprintf((char *)obj_dir,"%s:IGENOD:CACHE:%s",osname,type_obj);
 
  if(!SMCreateCacheDir(obj_dir,osname)) return 0;
 
  p_cache->osnum = osnum;

  /* Construct the ACrg_collection for this parameters */

  status = om$construct(classid = OPP_ACrg_collect_class_id,
			p_objid = &p_cache->objid,
			osnum   = p_cache->osnum);
  if(!(status & 1))
   { printf("Error construct ACrg\n"); return_code = 0; goto free_mem; }

  /* Look if an expression saying to not save exists in this directory */
  /* Default will be save cache                                        */
  /* The cache will never be saved if reference file                   */

  ex$get_cur_mod( osnum = &cur_os);
  if(osnum != cur_os) save_flag = 0;
  else
   {
     sprintf(exp_name,"%s:DestroyAtSave",obj_dir);
     if(di$translate(objname = exp_name,
		       p_objid = &tmp_obj.objid,
		       p_osnum = &tmp_obj.osnum) != DIR_S_SUCCESS )
       save_flag = 1;
     else
      {
	status = om$send(msg =message expression.NDgive_value(&val),
			 senderid = NULL_OBJID,
			 targetid = tmp_obj.objid,
			 targetos = tmp_obj.osnum);
	if(!(status & 1) || val != 1.0)save_flag = 1;
	else                           save_flag = 0;
      }
   }

  /* If not save then put delete if no parent for ACrg collection */

  if(!save_flag)
   {
     status = om$send(msg = message
		      NDnode.NDchg_state(ND_DEL_NO_CH | ND_WAIT_DEL,
					 ND_DEL_NO_CH | ND_WAIT_DEL),
		      senderid = NULL_OBJID,
		      targetid = p_cache->objid,
		      targetos = p_cache->osnum );
     if(!(status & 1)) 
      {printf("Cannot change state of ACrg %d,%d\n",
	      p_cache->objid,p_cache->osnum ); return_code = 0; goto free_mem;}
   }

  /* Put the name to the cache */

  sprintf(code,"%s:IGENOD:CACHE:%s:%s_%s_%s",
	  osname,type_obj,family,partnum,partrev);


  status = om$send(msg = message GRgraphics.GRputname(&msg,code),
		   senderid = NULL_OBJID,
		   targetid = p_cache->objid,
		   targetos = p_cache->osnum);
  if(!(status & msg & 1))
   {
     /* Big mistake because we cannot retrieve this object */
     printf("SMLoadCache : Can't name cache object %s\n",code);
     om$send(msg = message Root.delete(0),
	     senderid = NULL_OBJID,
	     targetid = p_cache->objid,
	     targetos = p_cache->osnum);
     return_code = 0; goto free_mem; 
   }
  
  
  /* Don't copy family, partno,partrev (so start with attribute 3)  */
  
  status = om$send(msg = message ACrg_collect.ACset_list_attribute
		   (&msg, nb_stat - 3,&stat_att[3]),
		   senderid = NULL_OBJID,
		   targetid = p_cache->objid,
		   targetos = p_cache->osnum);
  if(!(status & msg & 1))
   { printf("Error ACadd_list_attribute\n"); return_code = 0; goto free_mem; }


 free_mem:
     
  _FREE(stat_att) ;
  goto quit;
  
 quit:
  return return_code;

}

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMGetCacheAtt

  Abstract
  	This function retrieves the static attributes from the cache.
 	It can retrieve them all or some by their names (ACrg.name must be 
	filled).
 
 	It also returns the cache id (if not NULL).
 	ACrg can be NULL if attributes are not wanted, but otherwise it must be 
 	allocated by the user of nb_att.

 Algorithm

 	. Create the cache code 
		(osname:IGENOD:CACHE:type_obj:family_partnum_partrev)
	. if it doesn't exist (di$translate) load it from database.	  
	. if all_att (all att required):
		. nb_allocate = *nb_att
		. get total number of attributes by sending AClist_attribute 
		to cache_id -> *nb_att
		. if(ACrg)
			. if nb_att > nb_allocated => error return 0
			. get all the attributes in ACrg (AClist_attribute
		. else get each attribute by name
	

  Returns
	1 if success
	0 if fails
 ------------------------------------------------------------------------------
*/

int SMGetCacheAtt(
char               type_obj[],   /* [I]   Type of the object (compart,..)*/
char               family[],     /* [I]   Catalog name                   */
char        	   partnum[],    /* [I]   Part Id                        */
char        	   partrev[],    /* [I]   Part revision                  */   
OMuword      	   osnum,        /* [I]   osnum where to find the cache  */  
struct GRid 	  *cache_id,     /* [O]   Cache id of the new object     */  
struct ACrg_coll  *ACrg,         /* [I/O] List of attrib to retrieve     */  
int               *nb_att,       /* [I/O] Number of attrib  retrieve     */   
IGRboolean         all_att       /* [I]   TRUE : all attributes required */  
)
/*
-fi*/
{
  struct GRid tmp_cache, *p_cache;
  char        code[DI_PATH_MAX]; 
  IGRlong     msg;
  IGRint      status;
  int         i,nb_allocate = 0;

  
#ifdef CHRONOS
  int t1,t2;
  t1 = clock();
#endif

  p_cache = cache_id ? cache_id : &tmp_cache ;

  if(ACrg && (*nb_att <= 0)) return 0;

  /* Create cache code */


  if(!SMCreateCacheCode(type_obj,family,partnum,partrev,osnum,code))
    return 0;

  /* Look if cache already loaded. */

  if ( di$translate (objname = code,
			 p_objid = &p_cache->objid,
			 p_osnum = &p_cache->osnum ) != DIR_S_SUCCESS) 
   {

     /* Load cache from database. */                 
     if(!SMLoadCache(type_obj,family,partnum,partrev,
		     osnum,p_cache))
      {
	ex$message(msgnumb = SM_E_CmNoLoadPart,type = "%s %s %s",
		   var = `family,partnum,partrev`);
	return 0;
      }
   }

  if(!nb_att && !all_att) return 1;

  if(all_att)  /* All attributes required */
   {
     if(!nb_att)
      {printf("Need number of attributes in SMGetCacheAtt\n"); return 0;}

     nb_allocate = *nb_att;

     /* Found total number of attributes */
     status = om$send(msg = message ACrg_collect.AClist_attribute
		      (&msg, NULL, NULL, nb_att ),
		      senderid = NULL_OBJID,
		      targetid = p_cache->objid,
		      targetos = p_cache->osnum);
     if(!(status & msg & 1))
      { printf("Error getting number attributes in SMGetCacheAtt\n"); return 0;}
   
     if(ACrg)
      {
	if(*nb_att > nb_allocate)  
	 {printf("To small allocation in SMGetCacheAtt\n"); return 0;}

	status = om$send(msg = message ACrg_collect.AClist_attribute
			 (&msg,nb_allocate,ACrg,nb_att ),
			 senderid = NULL_OBJID,
			 targetid = p_cache->objid,
			 targetos = p_cache->osnum);
	if(!(status & msg & 1))
	 {printf("Error getting attributes in SMGetCacheAtt\n"); return 0;}
      }
   }
  else
   {
     for(i=0;i<*nb_att;i++)
      {


	status = om$send(msg = message ACrg_collect.ACget_named_attribute
			 (&msg,&ACrg[i]),
			 senderid = NULL_OBJID,
			 targetid = p_cache->objid,
			 targetos = p_cache->osnum);
	if(!(status & msg & 1)) return 0;
      }
   }
  
#ifdef CHRONOS
  t2 = clock();
  printf("Time for SMGetPartAtt  = %d\n",t2 - t1);
#endif

  return 1;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMGetFlagCache

  Abstract
  	This function get the flag for the cache for the static attributes.
	The cache is only searched in the current os.


  Algorithm
	get the value of the expression :
		osname:IGENOD:CACHE:type_obj:DestroyAtSave

  Returns
	1 if success
	0 if fails
 ------------------------------------------------------------------------------
*/   

int SMGetFlagCache(
char        type_obj[],           /* [I]  Type of the object (compart,..)*/
GRspacenum    osnum,              /* [I]  Osnum                          */ 
IGRboolean *save_flag             /* [O]  IF TRUE save cache             */
)
/*
-fi*/
{
 
  IGRchar        osname[DI_PATH_MAX],exp_name[DI_PATH_MAX];
  struct GRid    tmp_obj;
  IGRint         status;
  IGRdouble      val;
  
  /* Default value TRUE */
  *save_flag = 1;

  if(!type_obj) return 0;

  /* Look only in current os : nothing done for reference file          */

  if(di$give_pathname(osnum = osnum, pathname = osname) != DIR_S_SUCCESS)
   {printf("Error pathname of osnum %d\n",osnum); return 0;}

  sprintf(exp_name,"%s:IGENOD:CACHE:%s:DestroyAtSave",
	  osname,type_obj);

  /* Expression not exists return save */
  if(di$translate(objname = exp_name,
		    p_objid = &tmp_obj.objid,
		    p_osnum = &tmp_obj.osnum) != DIR_S_SUCCESS )
    { *save_flag = 1; return 1; }

  status = om$send(msg =message expression.NDgive_value(&val),
		   senderid = NULL_OBJID,
		   targetid = tmp_obj.objid,
		   targetos = tmp_obj.osnum);
  if(!(status & 1) || val == 0.0) *save_flag = 1;
  else                            *save_flag = 0;
 
  return 1;
}    

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMSetFlagCache

  Abstract
  	This function set the flag DestroyAtSave to the given value.
	(the cache for the static attributes will be save if  DestroyAtSave
	  is 0).


  Algorithm
 	. look if the expr osname:IGENOD:CACHE:type_obj:DestroyAtSave
	exist (look only in current os)
	. if not -> create the expression with the given value 
	. else 	modify the expression if needed
	. if the expression has been modified send the message 
	NDnode.NDchg_state (ND_DEL_NO_CH) to all the collection in the
 	directory.

  Returns
	1 if success
	0 if fails
 ------------------------------------------------------------------------------
*/ 
SMSetFlagCache(
char       type_obj[],           /* [I]  Type of the object (compart,..)*/
IGRboolean save_flag             /* [I]  IF TRUE save cache             */
)
/*
-fi*/
{
  GRspacenum     cur_os;
  IGRchar        cur_dir[DI_PATH_MAX],obj_dir[DI_PATH_MAX],exp_name[DI_PATH_MAX],
                 osname[DI_PATH_MAX],regexp[DI_PATH_MAX];
  IGRboolean     old_save_flag = 1; /* Save by default */
  struct GRid    tmp_obj;
  IGRint         status;
  IGRdouble      val;

  if(!type_obj) return 0;

  /* Look only in current os : nothing done for reference file          */

  ex$get_cur_mod(osnum = &cur_os);
  if(di$give_pathname(osnum = cur_os, pathname = osname) != DIR_S_SUCCESS)
   {printf("Error pathname of osnum %d\n",cur_os); return 0;}
  
  sprintf((char *)obj_dir,"%s:IGENOD:CACHE:%s",osname,type_obj);
  sprintf(exp_name,"%s:DestroyAtSave",obj_dir);

  /* Change the value of the expression for save not save */

  /* Expression not exists : create it */
  if(di$translate(objname = exp_name,
		    p_objid = &tmp_obj.objid,
		    p_osnum = &tmp_obj.osnum) != DIR_S_SUCCESS)
   {
     /* Look if cache directory already exists : if not create here */
     if(!SMCreateCacheDir(obj_dir,osname)) return 0;
     
     di$pwd(dirname = cur_dir);
     di$cd(dirname = obj_dir);
     status = exp$create(exp_name  = "DestroyAtSave",
			 osnum     =  cur_os,
			 p_exp_id  = &tmp_obj.objid,
			 exp_value = save_flag ? 0.0 : 1.0);
     di$cd(dirname = cur_dir);

     if(!(status & 1))
      {printf("Can't create expression %s:DestroyAtSave\n",obj_dir);
       return 0;}
   }
  else
   {
     char tmp[10];
     
     status = om$send(msg =message expression.NDgive_value(&val),
		      senderid = NULL_OBJID,
		      targetid = tmp_obj.objid,
		      targetos = tmp_obj.osnum);
     if(!(status & 1) || val == 0.0) old_save_flag = 1;
     else                            old_save_flag = 0;

     if(old_save_flag != save_flag)
      {
	sprintf(tmp,"%lf",save_flag ? 0.0 : 1.0);
	exp$modify(exp_id     = tmp_obj.objid,
		   osnum      = tmp_obj.osnum,
		   exp_syntax = tmp);
      }
   }
	
  /* Some cache should change their flag (save/not save)          */
  /* Pass the message to all colection in the specified directory */

  if(old_save_flag != save_flag)
   {
     OM_S_CLASSLIST class_list;
     OMuword        class_id;
     OM_S_MESSAGE   state_message;
     IGRint         how_big;
     struct chg_state_arg
      {
	IGRchar mask;
	IGRchar n_state;
      }state_arg;

     state_arg.mask   = ND_DEL_NO_CH | ND_WAIT_DEL; 
     state_arg.n_state = save_flag ? 0 :	ND_DEL_NO_CH | ND_WAIT_DEL;

     class_list.w_flags        = OM_CLST_subclass;
     class_list.w_count        = 1;
     class_list.p_classes      = &class_id;
     om$get_classid (classname = "ACrg_collect", p_classid = &class_id);

     how_big = sizeof(struct chg_state_arg);
     
     om$make_message (classname  = "NDnode",
		      methodname = "NDchg_state",
		      size       = how_big,
		      p_arglist  = &state_arg,
		      p_msg      = &state_message);

     sprintf(regexp,"%s:*",obj_dir);
     di$pass(regexp    = regexp,
	     msg       = &state_message,
	     p_classes = &class_list);
   }

  return 1;
}
    
end implementation Root;
