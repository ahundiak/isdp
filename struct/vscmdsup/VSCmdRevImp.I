/* $Id: VSCmdRevImp.I,v 1.3 2001/02/27 18:23:54 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:       struct/vscmdsup/VSCmdRevImp.I
 *
 * Description: Command Class for "Review Structural Objects" command.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSCmdRevImp.I,v $
 *      Revision 1.3  2001/02/27 18:23:54  ramarao
 *      Modifications to add object id search.
 *
 *      Revision 1.1  2001/02/25 19:21:00  ramarao
 *      Created "Review Structural Objects" command.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      02/25/01        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VSCmdRevObjF;

#include "VDobj.h"
#include "VDmem.h"
#include "VDfrm.h"
#include "VDsa.h"
#include "VSCmdRevFrm.h"
#include "vs.h"
#include "vsmiscmacros.h"

extern GRclassid	OPP_VSplate_class_id, OPP_VSbeam_class_id,
			OPP_VSdivFeature_class_id, OPP_VScpx_class_id,
			OPP_VSfrzPlate_class_id, OPP_VSfrzBeam_class_id;

from NDmacro	import	ACtest_consumed;
from GRvg	import  GRgetname;
from VSfeature  import  VSforwardToOriginal, VSexecuteFunctionAlongGeneration;

static int 	search_criteria;

#define OBJ_SRCH	0
#define PCK_SRCH	1

static int VSsortObjPcmk( struct GRobj_env	*obj1,
			  struct GRobj_env      *obj2 )
{
IGRint		out_int;

     if( search_criteria == PCK_SRCH )
     {
	IGRint          pcmk1_no=0, pcmk2_no=0;
	IGRchar         pcmk1[50], pcmk2[50];

        vdsa$GetStruct( objOE = obj1,
                        name  = "SA_AST:StagingTree:0:pcmk",
                        txt   = pcmk1 );
        pcmk1_no = atoi( pcmk1 );

        vdsa$GetStruct( objOE = obj2,
                        name  = "SA_AST:StagingTree:0:pcmk",
                        txt   = pcmk2 );
        pcmk2_no = atoi( pcmk2 );
 	out_int = ( pcmk1_no == pcmk2_no ) ? 0  :
       	    	  ( pcmk1_no <  pcmk2_no ) ? -1 : 1 ; 
     }
     else 
     {
	IGRlong		id1, id2;

	id1 = obj1->obj_id.objid;
	id2 = obj2->obj_id.objid;

	out_int = ( id1 == id2 ) ? 0  : 
                  ( id1 <  id2 ) ? -1 : 1 ;
     }

     return out_int;
}

method CollectObjects()
{
IGRlong			sts, msg, max_bytes, bytes_size, isConsumed;
IGRint			i, count;
GRclassid		classids[2];
GRspacenum		osnum;
GRrange			range;
struct GRid		mgrID;
struct GRmd_env		loc_env;
struct GRobj_env	*list=NULL;
Form			form;

  me->TotalObjectCount = 0;

  classids[0] = OPP_VSplate_class_id ;
  classids[1] = OPP_VSbeam_class_id ;

  range[0] = range[1] = range[2] = -1.0e+6;
  range[3] = range[4] = range[5] =  1.0e+6;

  max_bytes = sizeof( loc_env );
  gr$get_module_env( msg    = &msg,
		     sizbuf = &max_bytes,
		     buffer = &loc_env,
		     nret   = &bytes_size );

  VD_findall_objects_in_range( range, 2, classids, TRUE, loc_env,
                               &count, &list );

  for( i=0; i<count; ++i )
  {
     isConsumed = 1;
     om$send(msg = message NDmacro.ACtest_consumed( &isConsumed ),
                senderid = NULL_OBJID,
                targetid = list[i].obj_id.objid,
                targetos = list[i].obj_id.osnum );
     if( isConsumed == 0 &&
	 !vs$is_ancestry_valid( object  = &list[i].obj_id,
				classid = OPP_VSdivFeature_class_id ) &&
         !vs$is_ancestry_valid( object  = &list[i].obj_id,
                                classid = OPP_VSfrzPlate_class_id ) &&
         !vs$is_ancestry_valid( object  = &list[i].obj_id,
                                classid = OPP_VSfrzBeam_class_id ) )
     {
	me->TotalObjectCount++;
     }
  }

  om$vla_set_dimension( varray = me->TotalObjects,
                        size   = me->TotalObjectCount );

  me->TotalObjectCount = 0;
  for( i=0; i<count; ++i )
  {
     isConsumed = 1;
     om$send(msg = message NDmacro.ACtest_consumed( &isConsumed ),
                senderid = NULL_OBJID,
                targetid = list[i].obj_id.objid,
                targetos = list[i].obj_id.osnum );
     if( isConsumed == 0 &&
         !vs$is_ancestry_valid( object  = &list[i].obj_id,
                                classid = OPP_VSdivFeature_class_id ) &&
         !vs$is_ancestry_valid( object  = &list[i].obj_id,
                                classid = OPP_VSfrzPlate_class_id ) &&
         !vs$is_ancestry_valid( object  = &list[i].obj_id,
                                classid = OPP_VSfrzBeam_class_id ) )
     {
        me->TotalObjects[me->TotalObjectCount++] = list[i] ;
     }
  }

  mgrID.objid = NULL_OBJID;
  for(osnum = 0; VDosValidate(osnum); osnum++) 
  {
     VDatGetSetMgr( osnum, &mgrID );
     if( mgrID.objid != NULL_OBJID ) break;
  }

  if( mgrID.objid == NULL_OBJID )  search_criteria = OBJ_SRCH;
  else				   search_criteria = PCK_SRCH;

  UI_status( "Preparing Data......" );
  qsort( me->TotalObjects, me->TotalObjectCount, sizeof(struct GRobj_env), 
	 (int (*)())VSsortObjPcmk );
  UI_status( "Done" );

   VSget_revObj_form( &form );

   if( form == NULL ) return MSFAIL;

  if( search_criteria == OBJ_SRCH )
	FIg_set_text( form, FI_MSG_FIELD, "No Staging Tree Information." );
  else  FIg_set_text( form, FI_MSG_FIELD, "Start Search" );

  _FREE( list );

}

method SearchList( IGRchar              *search_txt;
		   IGRint		*count;
		   struct GRobj_env	*list )
{
IGRint			i, loc_cnt=0;
IGRchar			pcmk_or_name[1024], search_pattern[1024];

   for( i=0; i<me->TotalObjectCount; ++i )
   {
       if( !( me->options & SEARCH_PLATES ) &&
	   vs$is_ancestry_valid( object  = &me->TotalObjects[i].obj_id,
				 classid = OPP_VSplate_class_id ) ) 
       {
	  continue;
       }

       if( !( me->options & SEARCH_BEAMS ) &&
           vs$is_ancestry_valid( object  = &me->TotalObjects[i].obj_id,
                                 classid = OPP_VSbeam_class_id ) ) 
       {
	  continue;
       }
	  
       if( me->SearchType == PCMK_SEARCH ) 
       {
           vdsa$GetStruct( objOE = &me->TotalObjects[i],
                           name  = "SA_AST:StagingTree:0:pcmk",
                           txt   = pcmk_or_name );
	   strcpy( search_pattern, search_txt );
       }
       else if( me->SearchType == NAME_SEARCH )
       {
           vdobj$Get( objOE = &me->TotalObjects[i], objPath = pcmk_or_name );
	   sprintf( search_pattern, "*%s*", search_txt );
       }
       else if( me->SearchType == OBJID_SEARCH )
       {
	   sprintf( pcmk_or_name, "%d", me->TotalObjects[i].obj_id.objid );
	   strcpy( search_pattern, search_txt );
       }

       if( VSmatchRE( search_pattern, pcmk_or_name ) )
       {
	  if( list ) list[loc_cnt] =  me->TotalObjects[i];
          loc_cnt++;
       }
   }
   if( count ) *count = loc_cnt;

   return OM_S_SUCCESS;
}

method FillFoundObjectsInForm( IGRchar *search_text )
{
IGRlong			sts, msg;
IGRint			i, oldFoundCount;
IGRchar			pcmk_or_name[1024], *p;
Form			form;

   VSget_revObj_form( &form );

   if( form == NULL ) return MSFAIL;

   oldFoundCount = me->FoundObjectCount;

   FIfld_set_num_rows( form, G_STRUCT_LIST, 0 );

   FIg_set_text( form, FI_MSG_FIELD, "" );

   if( me->TotalObjectCount == 0 || !search_text || search_text[0] == '\0' )
        return MSFAIL;

   om$send ( msg = message VSCmdRevObjF.SearchList( 
			 	search_text, &me->FoundObjectCount, NULL ),
	     targetid = my_id );

   if( me->FoundObjectCount == 0 )
   {
      FIg_set_text( form, FI_MSG_FIELD, "No Objects Found." );
      return 1;
   }

   if( me->FoundObjectCount > oldFoundCount )
   {
      om$vla_set_dimension( varray = me->FoundObjects,
                            size   = me->FoundObjectCount );
   }

   om$send ( msg = message VSCmdRevObjF.SearchList( 
                     	search_text, &me->FoundObjectCount, me->FoundObjects),
             targetid = my_id );

   FIfld_set_num_rows( form, G_STRUCT_LIST, me->FoundObjectCount );

   for( i=0; i<me->FoundObjectCount; ++i )
   {
	if( vs$is_ancestry_valid( object  = &me->FoundObjects[i].obj_id,
				  classid = OPP_VSplate_class_id ) )
	  FIfld_set_text( form, G_STRUCT_LIST, i, 0, "P", FALSE );
	else
	  FIfld_set_text( form, G_STRUCT_LIST, i, 0, "B", FALSE );

	if( search_criteria == OBJ_SRCH )
	   sprintf( pcmk_or_name, "%d", me->FoundObjects[i].obj_id.objid );
	else
	{
	   vdsa$GetStruct( objOE = &me->FoundObjects[i],
                           name  = "SA_AST:StagingTree:0:pcmk",
                           txt   = pcmk_or_name );
	}

	FIfld_set_text( form, G_STRUCT_LIST, i, 1, pcmk_or_name, FALSE );

	vdobj$Get( objOE = &me->FoundObjects[i], objPath = pcmk_or_name );
	if( p = strstr( pcmk_or_name, "usr:" ) )   p += 4;
	else					   p = pcmk_or_name;
	FIfld_set_text( form, G_STRUCT_LIST, i, 2, p, FALSE );
   }

   if( search_criteria == OBJ_SRCH )
     FIg_set_text( form, FI_MSG_FIELD, "No Staging Tree Information." );

   return MSSUCC;
}

static int VSgetChildMacros( const struct GRid       *structObj,
                             VSlistElmtId            *cuList )
{
IGRlong         sts, msg;
IGRint          i, j, count;
struct GRid     *pChild;

   /* Initialization */
   pChild  = NULL;
   count   = 0;

   sts = VSgetChildrenGoThruPretends( &msg, structObj, &count, &pChild );
   if( ! (sts&msg&1) || !count )      goto    wrapup;

   if( *(cuList->pList) )
   {
       *(cuList->pList) = _REALLOC( *(cuList->pList),
                                (*(cuList->pCount) + count), struct GRid );
   }
   else
   {
       *(cuList->pList)  = _MALLOC( count, struct GRid );
   }

   if( !(*(cuList->pList)) )
   {
       printf(" Error : Not enought memory to allocate pList\n" );
       _FREE( pChild );
       return  FALSE;
   }

   for( i=0; i<count; i++ )
   {
       for( j=0; j<(*(cuList->pCount)); ++j )
       {
	  if( (*cuList->pList)[j].objid == pChild[i].objid &&
	      (*cuList->pList)[j].osnum == pChild[i].osnum ) break;
       }
       if( j == (*(cuList->pCount)) )
       {
	  (*cuList->pList)[(*cuList->pCount)] = pChild[i];
	  (*cuList->pCount)++;
       }
   }

wrapup :
   _FREE( pChild );
   return  TRUE;
}

method CollectChildObjects()
{
IGRlong			sts, msg;
IGRint			i, loc_cnt=0;
struct GRobj_env	structObj;
struct GRid             *mc=NULL;
VSlistElmtId            fctArgs;

   if( me->CurrentIndex == -1 || me->FoundObjectCount == 0 ) return OM_S_SUCCESS;

   structObj = me->FoundObjects[me->CurrentIndex]; 

   fctArgs.pList  = &mc;
   fctArgs.pCount = &loc_cnt;

   msg = -2;
   sts = om$send(  msg = message VSfeature.VSforwardToOriginal( &msg,
                                                              OM_e_wrt_object,
                         message VSfeature.VSexecuteFunctionAlongGeneration(
                                &structObj.obj_id, VSgetChildMacros,
                                (void*)&fctArgs, FALSE ) ),
                senderid = NULL_OBJID,
                targetid = structObj.obj_id.objid,
                targetos = structObj.obj_id.osnum  );
   if( msg == -2 )
   {
        sts = VSgetChildMacros( &structObj.obj_id, &fctArgs );
        if( sts & 1 )   msg = MSSUCC;
   }
   if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

   if( loc_cnt > me->ChildObjectCount )
   {
      om$vla_set_dimension( varray = me->ChildObjects, size = loc_cnt );
   }

   me->ChildObjectCount = 0;
   for( i=0; i<loc_cnt; ++i )
   {
      if( vs$is_ancestry_valid( object  = &mc[i],
                                classid = OPP_VScpx_class_id ) ) continue;
      me->ChildObjects[me->ChildObjectCount] = mc[i];
      me->ChildObjectCount++;
   }

wrapup:
   _FREE( mc ); 
   return OM_S_SUCCESS;
}

method FillChildObjectsInForm( )
{
IGRint		i, loc_cnt, oldChildFoundCount;
IGRchar		macName[40], clsName[40], objName[100], txt[200], name[40];
Form		form;

   VSget_revObj_form( &form );

   if( form == NULL ) return MSFAIL;

   oldChildFoundCount = me->ChildFoundObjectCount;

   FIfld_set_num_rows( form, G_CHILD_LIST, 0 );

   FIg_set_text( form, FI_MSG_FIELD, "" );

   FIg_get_text( form, G_CHILD_TYPE, txt ) ;

   name[0] = '\0';

   if( !strcmp( txt, "Unwrap" ) )  		strcpy( name, "VLunwObj" );
   else if( !strcmp( txt, "Profile Card") ) 	strcpy( name, "PCardText" );
   else if( !strcmp( txt, "Drawing" ) )		strcpy( name,  "*drw*" );
   else
   {
      FIg_get_text( form, G_MACRO_SEARCH, txt ) ;
      sprintf( name, "*%s*", txt );
   }

   if( me->ChildObjectCount == 0 || name[0] == '\0' )
        return MSFAIL;

   loc_cnt = 0;
   for( i=0; i<me->ChildObjectCount; ++i )
   {
      vdobj$Get( objID = &me->ChildObjects[i], macName = macName );
      if( VSmatchRE( name, macName ) ) loc_cnt++;
   }

   if( loc_cnt > oldChildFoundCount )
   {
      om$vla_set_dimension( varray = me->ChildFoundObjects, size = loc_cnt );
   }

   me->ChildFoundObjectCount = 0;
   for( i=0; i<me->ChildObjectCount; ++i )
   {
      vdobj$Get( objID = &me->ChildObjects[i], macName = macName );
      if( VSmatchRE( name, macName ) ) 
      {
	 me->ChildFoundObjects[me->ChildFoundObjectCount] = me->ChildObjects[i];
	 me->ChildFoundObjectCount++;
      }
   }

   FIfld_set_num_rows( form, G_CHILD_LIST, me->ChildFoundObjectCount );

   for( i=0; i<me->ChildFoundObjectCount; ++i )
   {
      vdobj$Get( objID = &me->ChildFoundObjects[i], macName = macName );
      vdobj$Get( objID = &me->ChildFoundObjects[i], className = clsName );
      vdobj$Get( objID = &me->ChildFoundObjects[i], objName = objName );

      sprintf( txt, "%s %s %s", clsName, macName, objName );

      FIfld_set_text( form, G_CHILD_LIST, i, 0, txt, FALSE );
   }
   return OM_S_SUCCESS;
}

static int VSgetStepInfo( const struct GRid 	*step,
                          VSlistElmtId 		*cuList )
{

        // accumulate this elements
        if( *(cuList->pList))
                *(cuList->pList) = (struct GRid *) realloc(
                                        *(cuList->pList),
                                        sizeof(struct GRid) *
                                                (*(cuList->pCount) + 1) );

        else *(cuList->pList) = (struct GRid *) malloc(sizeof(struct GRid));

        if( ! (*(cuList->pList)) ){
                printf(" Error : not enought memory to allocate pList\n");
                return  FALSE;
        }

        (*cuList->pList)[*(cuList->pCount)] = *step;
        (*cuList->pCount) ++;

        return  TRUE;
}
void VSRevGetStepInfo( 	struct GRobj_env	*structObj,
			IGRint			*nbSteps,
			struct GRid		**stepInfo )	
{
IGRlong			sts, msg;
IGRint			i, loc_cnt;
VSlistElmtId            fctArgs;

   fctArgs.pList  = stepInfo;
   fctArgs.pCount = nbSteps;

   msg = -2;
   sts = om$send(  msg = message VSfeature.VSforwardToOriginal( &msg,
                                                              OM_e_wrt_object,
                         message VSfeature.VSexecuteFunctionAlongGeneration(
                                &structObj->obj_id, VSgetStepInfo,
                                (void*)&fctArgs, FALSE ) ),
                senderid = NULL_OBJID,
                targetid = structObj->obj_id.objid,
                targetos = structObj->obj_id.osnum  );
   if( msg == -2 )
   {
        sts = VSgetStepInfo( &structObj->obj_id, &fctArgs );
        if( sts & 1 )   msg = MSSUCC;
   }
   if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

wrapup:
   return;
}

end implementation VSCmdRevObjF;
