/* $Id: VDtoDoList.I,v 1.1 2002/06/07 14:40:29 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        isdp/vds/vdmisc/VDtoDoList.I
 *
 * Description: Functions to accumulate/clear/modify/toggle the To Do List.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDtoDoList.I,v $
 *      Revision 1.1  2002/06/07 14:40:29  ramarao
 *      Implemented To Do List.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      06/07/02        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "VDobj.h"
#include "VDmem.h"

%safe
static IGRint		   enableToDoList=0;
static IGRint   	   toDoCount=0;
static IGRint		   maxToDoSize=0;
static struct GRobj_env	   *toDoList=NULL;
%endsafe

void VDenableToDoList()         { enableToDoList = 1 ; }
void VDdisableToDoList()        { enableToDoList = 0 ; }
int  VDisToDoListEnabled()      { return enableToDoList; }

static void VDtoDoAllocMemory()
{
   if( toDoList == NULL )
   {
      toDoList =  _MALLOC( 10, struct GRobj_env );
      maxToDoSize = 10; 
   }
   else if( toDoCount == maxToDoSize )
   {
      toDoList = _REALLOC( toDoList,
                           (maxToDoSize+10), struct GRobj_env );
      maxToDoSize += 10;
   }
}

void VDclearToDoList()
{
    _FREE( toDoList );
    toDoCount = 0;
    maxToDoSize = 0;
}

IGRlong VDgetToDoList( IGRint		   *count,
		       struct GRobj_env	   **list )
{
IGRint		i;

    if( !list || !count )  return 0;

    *count = 0;
    *list = NULL;

    if( toDoCount == 0 ) return 1;

    (*list) = _MALLOC( toDoCount, struct GRobj_env );

    for( i=0; i<toDoCount; ++i )
    {
	(*list)[i] = toDoList[i];
	(*count)++;
    }
}

void VDaddToDoList( struct GRobj_env	objOE )
{
IGRlong			sts;
IGRint			i;

    if( enableToDoList == 0 )  return;

    sts = om$is_objid_valid( objid = objOE.obj_id.objid,
			     osnum = objOE.obj_id.osnum  );
    if( !(sts&1) ) return;

    for( i=0; i<toDoCount; ++i )
       if( objOE.obj_id.objid == toDoList[i].obj_id.objid &&
	   objOE.obj_id.osnum == toDoList[i].obj_id.osnum     ) break;

    if( i==toDoCount )
    {
       VDtoDoAllocMemory();
       toDoList[toDoCount++] = objOE;
    }
}

void VDremoveFromToDoList( struct GRobj_env    objOE )
{
IGRint                  i, index=0;

    for( i=0; i<toDoCount; ++i )
    {
       if( objOE.obj_id.objid == toDoList[i].obj_id.objid &&
           objOE.obj_id.osnum == toDoList[i].obj_id.osnum     )
       {
	  // Nothing
       } 
       else
       {
	  toDoList[index++] = toDoList[i] ;
       }
    }

    toDoCount = index ;
}

end implementation VDSroot;
