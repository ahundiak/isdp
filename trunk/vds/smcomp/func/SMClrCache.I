/* $Id: SMClrCache.I,v 1.2 2001/11/09 18:56:42 ylong Exp $ */
/*---------------------------------------------------------------------------
/* I/VDS
 *
 * File:        SMcomp/func/SMClrCache.I
 *
 * Description:
 *
 *      This file implements function used to  CACHE:compartment
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMClrCache.I,v $
 *	Revision 1.2  2001/11/09 18:56:42  ylong
 *	TR3057
 *	
 *	Revision 1.1  2001/11/05 18:14:29  ylong
 *	*** empty log message ***
 *	
 *	
 * History:
 *
 *	11/05/01	ylong	Creation for TR3061
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
#include "VDobj.h"
#include "v_dbgmacros.h"

#define AS_DEBUG       1

#include "AS_status.h"

from	SMcomp	import	SMResetAtt;
from	SMcomp	import	SMListAtt;
//from	ACrg_collect	import	ACset_list_attribute;


/*+fi
 -------------------------------------------------------------------------
  Internal Function SMClrCacheDir

  Abstract

	This function delete ACrg_collect object from cache dir if
	there is no corresponding compartment object exists.

  Algorithm

	- Find all the compartment objects in the design file (SM$CritSel).
	- Find all ACrg_collect objects under CASHE:compartment
	- For each ACrg_collect object, 
		Check if its dir has a corresponding entry in the compartment
		object. If not found, delete the ACrg_collect.

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
IGRint SMClrCacheDir()
{
  IGRlong		status,msg;
  IGRint		i,j;
  IGRint		nb_att = 0, nb_roots = 0, nb_dir = 0;
  IGRchar		osname[DI_PATH_MAX],
			obj_dir[DI_PATH_MAX];
  IGRchar		**dir_list = NULL, *ptr = NULL;
  DIgrid		*dir_ids = NULL;
  struct GRid		ACdyn, cache_obj;
  struct ACrg_coll	code_att[3];
  struct SMObjList	list;
  OM_S_CLASSLIST	classes;
  VDclassid		classIDs[2];

  struct {
	struct GRobj_env	*objList;
	IGRchar			(*codeList)[DI_PATH_MAX];
	IGRint			nbList;
  } compList;	

	     
  list.list         = NULL;
  list.nb_objects   = 0;

  compList.objList  = NULL;
  compList.codeList = NULL;
  compList.nbList   = 0;

  /* Find all compart in file */

  status = SM$CritSel(msg = &msg, type = SM_COMPART, list  = &list);
  if(!(status & 1) || msg != MSSUCC)
  {
    printf("Error found list of compart\n");
    goto wrapup; 
  }
  if(list.nb_objects <= 0) 
  {
    printf("No compartment objects found\n");
    goto wrapup;
  }
   
  /* Initialize compList */

  compList.codeList = (IGRchar (*)[DI_PATH_MAX]) 
			malloc( sizeof(IGRchar)*DI_PATH_MAX*list.nb_objects);
  if( !compList.codeList )
  {
    printf("Failed to allocate compList.codeList\n");
    goto wrapup;
  }

  compList.objList = _MALLOC( list.nb_objects, struct GRobj_env );
  if( !compList.objList ) 
  {
    printf("Failed to allocate compList.objList\n");
    goto wrapup;
  }

  compList.nbList = list.nb_objects;

  for(i = 0 ; i < compList.nbList; i++)
  {
    //printf("obj list[%d]: ", i); vdobj$Print(objID=&list.list[i].obj_id);
    compList.objList[i] = list.list[i];
    compList.codeList[i][0] = '\0';
  } 

  nb_att = 3;
  strcpy(code_att[0].name,"family");
  strcpy(code_att[1].name,"partno");
  strcpy(code_att[2].name,"partrev");
  code_att[0].desc.type = AC_ATTRIB_TEXT;
  code_att[1].desc.type = AC_ATTRIB_TEXT;
  code_att[2].desc.type = AC_ATTRIB_TEXT;

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

     /* Get list of attributs for compartment */
     
     for( j = 0; j < nb_att; j++ ) 
     {
       code_att[j].desc.value.att_txt[0] = '\0';
       status = om$send(msg      = message ACdyn_col.ACget_named_attribute
		      				(&msg,&code_att[j]),
		      senderid = NULL_OBJID,
		      targetid = ACdyn.objid,
		      targetos = ACdyn.osnum);
       if(!(status & msg & 1)) break;
     }

     if (!(status & msg & 1)) continue;

     /* Create name of cache */
     status = SMCreateCacheCode (
			"compartment",
			code_att[0].desc.value.att_txt,  /* family  */
			code_att[1].desc.value.att_txt,  /* partno  */
			code_att[2].desc.value.att_txt,  /* partrev */
	                compList.objList[i].obj_id.osnum,
	                compList.codeList[i] );
      //printf("code[%d]: [%s]\n", i, compList.codeList[i]);
  }
     
  /* Get existing dirs  */
        
  if(di$give_pathname (	osnum = ACdyn.osnum,
			pathname = osname) != DIR_S_SUCCESS)
  {
     printf("Error pathname of osnum %d\n", ACdyn.osnum); 
     goto wrapup;
  }
	
  sprintf((char *)obj_dir,"%s:IGENOD:CACHE:compartment",osname);
	
  if (!( di$translate (	objname = obj_dir,
			p_objid = &cache_obj.objid,
			p_osnum = &cache_obj.osnum )& 1 ) )
  {
     printf("%s does not exist.\n");
     status = 1;
     goto wrapup;
  }
	
  DIstrcat( obj_dir, "*" );

  classes.p_classes = classIDs;
  om$get_classid (	classname = "ACrg_collect",
			p_classid = &classes.p_classes[0]);
  classes.w_flags = OM_CLST_subclass;
  classes.w_count = 1;

  status = di$dump (	regexp		= obj_dir,
			p_classes	= &classes,
			lines		= &dir_list,
			grids		= &dir_ids,
			ptr		= &nb_dir);
  if( !(status&1) ) goto wrapup;

  for( i = 0; i < nb_dir; i++ )
  {
     ptr = strstr( dir_list[i], "()");
     if( ptr ) *ptr = 0;
     for(j = 0 ; j < compList.nbList; j++)
     {
        if( !strcmp(compList.codeList[j], dir_list[i]) )
        {
	    break;
        }
     }

     if( j == compList.nbList )
     {
	gr$delete_object(msg=&msg, object_id = &dir_ids[i]);
	dir_ids[i].objid = NULL_OBJID;
        //printf("---- deleted dir[%d]: [%s]\n", i, dir_list[i]);
     }
     //else printf("++++ dir[%d]: [%s]\n", i, dir_list[i]);
  }
		
  status = 1;

wrapup:

  di$free( lines = dir_list, count = nb_dir );
  _FREE(dir_ids);
  _FREE(compList.codeList) ;
  _FREE(compList.objList) ;
  _FREE(list.list) ;
  return status;
}     


/*+fi
 -------------------------------------------------------------------------
  Internal Function SMAttRev

  Abstract

	This function clear ACrg_coll if duplicate names found

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
IGRint SMAttRev (IGRint			*nb_att,
		struct ACrg_coll	*att,
		IGRshort		*type )
{
  IGRint		status = 0, flag = 0;
  IGRint		i, j, cnt = 0, size;
  IGRint		nb_tmp   = 0;
  struct ACrg_coll	*tmpAtt  = NULL;
  IGRshort		*tmpType = NULL;



  if( !(*nb_att) || !nb_att || !att ) goto wrapup;

  tmpAtt = _MALLOC( *nb_att, struct ACrg_coll );
  if(!tmpAtt) goto wrapup;

  if( type )
  {
     tmpType = _MALLOC( *nb_att, IGRshort );
     if(!tmpType) goto wrapup;
  }

  size =  sizeof(struct ACrg_coll);
  
  cnt = 0;
  for( i = 0; i < *nb_att; i++ )
  {
     for( j = 0; j < cnt && j < *nb_att; j++ )
     {
	if( !strcmp( att[i].name, tmpAtt[j].name ) ) break;
     }
     if( j == cnt )
     {
	memset( &tmpAtt[cnt], 0, size );
	memcpy( &tmpAtt[cnt], &att[i], size );
	if( type ) tmpType[cnt] = type[i];
	cnt++;
     }
  }

  if( cnt < *nb_att )
  {
     for( j = 0; j < cnt; j++ )
     {
	memset( &att[j], 0, size );
	memcpy( &att[j], &tmpAtt[j], size );
	if( type ) type[j] = tmpType[j];
     }

     for( ; j < *nb_att; j++ )
     {
	memset( &att[j], 0, size );
	if( type ) type[j] = 0;
     }

     *nb_att = cnt;
  }
  else goto wrapup;

  status = 1;
wrapup:
  _FREE( tmpAtt);
  return status;
}

/*+fi
 -------------------------------------------------------------------------
  Internal Function SMRevACrg

  Abstract

	This review ACrg_collect to check if attribute names duplicate

  Returns
         1 if success
         0 if fails
 -------------------------------------------------------------------------
*/
IGRint SMRevACrg ( struct GRid	*objId )
{
  IGRlong		msg;
  IGRint		status = 0;
  IGRint		nb_att = 0, i;
  struct ACrg_coll	att[SM_MAX_CO_ATTR];
  IGRshort		type[SM_MAX_CO_ATTR];
  struct SMObjList	list;

  list.nb_objects = 0;
  list.list       = NULL;

  if( !objId ) {

     status = SM$CritSel(msg = &msg, type = SM_COMPART, list  = &list);
     if(!(status & 1) || msg != MSSUCC)
     {
        printf("Error found list of compart\n");
        goto wrapup; 
     }

     if(list.nb_objects <= 0) 
     {
        printf("No compartment objects found\n");
        goto wrapup;
     }
  }
  else {
     list.nb_objects = 1;
     list.list = _MALLOC( 1, struct GRobj_env );
     if( !list.list ) goto wrapup;

     list.list[0].obj_id = *objId;
  }

  for(i = 0 ; i < list.nb_objects; i++)
  {
     /* Get the ACrg of compartment */
     status = om$send(	msg = message SMcomp.SMListAtt (
						&msg,
						SM_MAX_CO_ATTR ,
                     				&nb_att, 
						att, 
						type),
			senderid = NULL_OBJID,
			targetid = list.list[i].obj_id.objid,
			targetos = list.list[i].obj_id.osnum);
     if( !(status&msg&1) || nb_att < 1 ) continue;
     if( !SMAttRev ( &nb_att, att, type ) ) continue;

     status = om$send(	msg = message SMcomp.SMResetAtt (
						&msg,
						nb_att,
						att,
						type),
			senderid = NULL_OBJID,
     			targetid = list.list[i].obj_id.objid,
     			targetos = list.list[i].obj_id.osnum);
      __DBGpr_obj("Comp obj", list.list[i].obj_id);
  }

  status = 1;
wrapup:
  return status;
}

end implementation SMcoll;
