/* $Id: VSexecfnhist.I,v 1.1 2001/02/28 23:27:38 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:        struct/vsmisc/VSexecfnhist.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSexecfnhist.I,v $
 *      Revision 1.1  2001/02/28 23:27:38  ramarao
 *      Profile Card Validation Routines.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      01/24/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "VDobj.h"
#include "vs.h"

from VSfeature	import	VSforwardToOriginal, VSexecuteFunctionAlongGeneration;

int VSgetStepInfo( step, cuList )
const struct GRid     *step;
VSlistElmtId          *cuList;
{

        // accumulate this elements
        if( *(cuList->pList))
                *(cuList->pList) = (struct GRid *) realloc(
                                        *(cuList->pList),
                                        sizeof(struct GRid) *
                                                (*(cuList->pCount) + 1) );

        else *(cuList->pList) = (struct GRid *) malloc(sizeof(struct GRid));

        if( (*(cuList->pList)) == NULL ){
                printf(" Error : not enought memory to allocate pList\n");
                return  FALSE;
        }

        (*cuList->pList)[*(cuList->pCount)] = *step;
        (*cuList->pCount) = (*cuList->pCount) + 1;

        return  TRUE;
}

int  VSgetChildMacros( structObj, cuList )
const struct GRid       *structObj;
VSlistElmtId            *cuList;
{
IGRlong         sts, msg;
IGRint          i, j, count;
struct GRid     *pChild;

   /* Initialization */
   pChild  = NULL;
   count   = 0;

   sts = VSgetChildrenGoThruPretends( &msg, structObj, &count, &pChild );
   if( ! (sts&msg&1) || !count )      goto    wrapup;

   // accumulate this elements
   if( *(cuList->pList))
        *(cuList->pList) = (struct GRid *) realloc(
                                  *(cuList->pList),
                                  sizeof(struct GRid) *
                                  (*(cuList->pCount) + count ) );

   else *(cuList->pList) = (struct GRid *) malloc(count*sizeof(struct GRid));

   if( (*(cuList->pList)) == NULL )
   {
       printf(" Error : Not enought memory to allocate pList\n" );
       if( pChild ) { free( pChild ); pChild = NULL; }
       return  FALSE;
   }

   for( i=0; i<count; i=i+1 )
   {
       for( j=0; j<(*(cuList->pCount)); j=j+1 )
       {
          if( (*cuList->pList)[j].objid == pChild[i].objid &&
              (*cuList->pList)[j].osnum == pChild[i].osnum ) break;
       }
       if( j == (*(cuList->pCount)) )
       {
          (*cuList->pList)[(*cuList->pCount)] = pChild[i];
          (*cuList->pCount) = (*cuList->pCount) + 1;
       }
   }

wrapup :
   if( pChild ) { free( pChild ); pChild = NULL; }
   return  TRUE;
}

void VSexecuteFunctionAlongHistory(  struct GRid	*structObj,
				     int             	(*fct)(), 
				     int		*count,
				     struct GRid	**list    )
{
IGRlong                 sts, msg;
IGRint                  i, loc_cnt;
VSlistElmtId            fctArgs;

   *count = 0;
   *list  = NULL;

   fctArgs.pList  = list;
   fctArgs.pCount = count;

   sts = om$send(  msg = message VSfeature.VSforwardToOriginal( &msg,
                                                              OM_e_wrt_object,
                         message VSfeature.VSexecuteFunctionAlongGeneration(
                                structObj, fct,
                                (void*)&fctArgs, FALSE ) ),
		senderid = structObj->objid,
                targetid = structObj->objid,
                targetos = structObj->osnum  );
   if( ! (sts&msg&1)){ sts = MSFAIL; goto wrapup; }

wrapup:
   return;
}



end implementation VDSroot;
