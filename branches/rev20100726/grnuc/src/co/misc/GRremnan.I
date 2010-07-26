class implementation Root;

#include <stdio.h> 
#include <string.h> 
#include "OMmacros.h"
#include "OMminimum.h"

#include "igetypedef.h"
#include "igrtypedef.h"
#include "GRtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "msdef.h"

#include "OMspecify.h"
#include "OMprimitives.h" 
#include "OMindex.h"
#include "OMDB.h"
#include "OMrtreedef.h"
#include "grmacros.h"
#include "godef.h"

extern OM_p_OSD        *OM_GA_OSDs;
extern OMuword         OM_Gw_maxOS;
extern OM_p_CLASSDEF   *OM_GA_active_classes;

extern IGRboolean SearchNanArr();
#define NumRemRtrObj 100
%safe
static OM_S_OBJID *sRemNanRtrObjList=NULL;
static int sNumOfRemNanRtrObj=0;
%endsafe

extern int dump_space();
extern void dump_trnmap();

from OMCluster import fault;
    
GRProcessRtreeLeafNode( rtree )
R_PAGE_3D_FLT *rtree;
{
   int i, status;
   unsigned count;
   double arr[6];

   count = rtree->Header.Key_count;

   for( i = 0; i < count; i = i+1 )
   {

    arr[0] = (double)rtree->Key[i].xmin;
    arr[1] = (double)rtree->Key[i].ymin;
    arr[2] = (double)rtree->Key[i].zmin;
    arr[3] = (double)rtree->Key[i].xmax;
    arr[4] = (double)rtree->Key[i].ymax;
    arr[5] = (double)rtree->Key[i].zmax;

    if( ( status = GRvalidate_rtree_range( arr ) ) == 0 )
    {
      /*** 
       Object has bad range in rtree. Hence object is removed
           from the rtree.

      printf("Object %d has bad range. Removing from the rtree.\n", 
            rtree->Objid[i] );
          ***/

      /* copying the Objid into the static array for later use */
      if(sNumOfRemNanRtrObj == 0)
      {
        sRemNanRtrObjList = (OM_S_OBJID *)malloc(sizeof(OM_S_OBJID) *
					NumRemRtrObj);
      }
      else
      {
        if(sNumOfRemNanRtrObj % NumRemRtrObj == 0)
        sRemNanRtrObjList = (OM_S_OBJID *)realloc(sRemNanRtrObjList,
				sizeof(OM_S_OBJID) * 
				(sNumOfRemNanRtrObj + NumRemRtrObj));
      }
      if(SearchNanArr(rtree->Objid[i]) == FALSE)
        sRemNanRtrObjList[sNumOfRemNanRtrObj++] = rtree->Objid[i] ;

      GRRemNanEntry(rtree, i);
      count = rtree->Header.Key_count;
      i = i-1;
    }
   }
   return(1);

}

/** 
Abstract:

Function:
RemNanEntry

return  value:
        removed : 1 failed  : 0
**/

GRRemNanEntry( prtree, obj_pos )

R_PAGE_3D_FLT *prtree;
int obj_pos;
{
   int j;
   int count;

   count = (prtree)->Header.Key_count; 
   if( obj_pos < count-1 )
   {
    for( j=obj_pos; j<count-1; j++ )
        {
            prtree->Objid[j] = prtree->Objid[j+1];
            memcpy( &prtree->Key[j], &prtree->Key[j+1], sizeof(DB_3D_FLT_BOX) );
        }
        prtree->Header.Key_count = prtree->Header.Key_count-1;
   }
   else
   {
    prtree->Header.Key_count = prtree->Header.Key_count-1;
   }    
   return(1);
}

    
/** 
Abstract:

Function:
GRGetRip

return  value:
        SUCCESS : 0   FAILURE : 1

**/

GRGetRip( objid, osnum, rip )
OM_S_OBJID        objid;
OMuword           osnum;
OM_p_RIP          rip;
{
   int            sts;
   OM_p_OSD       p_OSD;
   OM_S_OBJID     cluster_oid;

   p_OSD = OM_GA_OSDs[osnum];
   if ( (p_OSD == NULL) || (osnum > OM_Gw_maxOS) )
   {
      printf("No such OS\n");
   }
   if ((IF_NULL_OBJID(objid)) || (objid >= p_OSD->CurSpaceMapSize)) 
   {
      printf("No such OS\n");
      return(1);
   }

   rip->p_mapentry = &p_OSD->Spacemap[objid];

   /*=====================================*/
   /*  check if spacemap entry is in use  */
   /*=====================================*/

   if ( !(OM_OBJ_INVALID(rip->p_mapentry->flags) ) )
   {
      /*===========================================*/
      /*  check if cluster needs to be faulted in  */
      /*===========================================*/

      if (OM_OBJ_IN_FILE(rip->p_mapentry->flags))
      {
         cluster_oid = p_OSD->Clusters
           [rip->p_mapentry->state.filed_obj.clusterid]->oid;

/*
         printf ("Sending fault msg to cluster oid = %d in OS %d\n",
                   cluster_oid, osnum);
*/

         if (!(1&(sts = om$send ( msg=message OMCluster.fault(0),
                                  senderid=NULL_OBJID,
                                  targetid=cluster_oid,
                                  targetos = osnum  ))))
         {
            som_report_error(sts);
            return(1);
         }
      } /* if (OM_OBJ_IN_FILE  */
      rip->p_object = rip->p_mapentry->state.object;

      return(0);
   } /* if !(OM_OBJ_INVALID  */
   printf("No such object exists.\n"); 
   return(1);
   
} /* GRGetRip */


GRSearchNonLeafNode( omrtree_objid, osnum )
R_PAGE_3D_FLT   *omrtree_objid;
OMuword  osnum;
{
   int          sts, i;
   int          count;
   OM_S_RIP     rip;
   R_PAGE_3D_FLT   *p_rtree;

   count = omrtree_objid->Header.Key_count;
   
   for( i = 0; i < count; i = i+1 )
   {
    sts = GRGetRip( omrtree_objid->Objid[i], osnum, &rip );

    if( sts )
    {
           printf(" Problem getting OMrtree instance with oid : %d\n", 
                   omrtree_objid->Objid[i] );
           return( 1 );
    }

    p_rtree = (R_PAGE_3D_FLT *) 
            ( (int)rip.p_object + sizeof(OM_S_OBJECTHDR) +
                                  sizeof(int) + sizeof(OM_S_OBJID) );

    if( ! IS_R_LEAF( p_rtree->Header.Page_type ) )
        GRSearchNonLeafNode( p_rtree, osnum );
    else
              GRProcessRtreeLeafNode( p_rtree );
   }
   return( 1 );
}

int GRProcess_Rtree( )
{
   OM_S_OBJID      grrtree_objid;
   OMuword         osnum;
   R_PAGE_3D_FLT   *p_rtree;
   OM_S_RIP        rip ;
   int             sts, i;
   int         found;

   OM_S_CHANSELECT  chan_to_prim;
   OM_S_OBJECT_LINKAGE *list;
   OMuint  l_count, count;
   char classname[300];

   long rt, NumberOfBytes, BytesReceived;
   struct GRmd_env  local_env;

   NumberOfBytes = sizeof( local_env );
   gr$get_module_env( msg = &rt,
                        sizbuf = &NumberOfBytes,
                        buffer = &local_env,
                        nret = &BytesReceived );


   sts = om$make_chanselect( channame = "module.primary",
            p_chanselect = &chan_to_prim);

   sts = om$get_channel_count(  osnum = local_env.md_id.osnum,
                objid = local_env.md_id.objid,
                p_chanselect = &chan_to_prim,
                                count = &l_count);

   list = (OM_S_OBJECT_LINKAGE *)malloc( l_count * sizeof(OM_S_OBJECT_LINKAGE));

   sts = om$get_channel_objects( osnum = local_env.md_id.osnum,
                                 objid = local_env.md_id.objid,
                 p_chanselect = &chan_to_prim,
                               list = list,
                               size = ( int )l_count,
                               count = &count);
   found = FALSE;

   for( i = 0; i < count; i++)
   {
        om$get_classname( objid = list[i].S_objid,
                        osnum = list[i].osnum,
                        classname = classname );

        if( om$is_ancestry_valid( subclassname = classname,
                      superclassname="GRrtree") == OM_S_SUCCESS )
    {
        found = TRUE;
            break;
    }
  }
  if ( found )
  {
      grrtree_objid = list[i].S_objid;
      osnum = list[i].osnum;
  }

   /* get the resultant instance pointer for the GRrtree object */

   sts = GRGetRip( grrtree_objid, osnum, &rip );
   if (sts)
   {
      printf("Problem getting GRrtree instance.\n");
      return(1);
   }
   
   /* Store the r-tree root in p_rtree */
   p_rtree = (R_PAGE_3D_FLT *) ( (int)rip.p_object + sizeof(OM_S_OBJECTHDR) +
                                  sizeof(int) + sizeof(OM_S_OBJID) );

    /* 
    * If the GRrtree object itself is the leaf node, then there are 
    * no OMrtree objects present. This essentially means that the 
    * GRrtree object itself holds the keys of various objects. 
    * Now, traverse thro' the individual objects and search for the
    * corrupted object id.
    */
 
   if ( IS_R_LEAF( p_rtree->Header.Page_type ) )
    GRProcessRtreeLeafNode( p_rtree );
   else
    GRSearchNonLeafNode( p_rtree, osnum );

   return(1);
}

IGRboolean SearchNanArr(obj)
OM_S_OBJID obj;
{
  IGRboolean sts = FALSE;
  int LpIndx;
  for(LpIndx = 0; LpIndx < sNumOfRemNanRtrObj; LpIndx++)
  {
    if(sRemNanRtrObjList[LpIndx] == obj)
      {
      sts = TRUE;
      break;
      }
  }
  return(sts);
}

GetNanObjList(ObjList, NumObj)
OM_S_OBJID **ObjList;
int *NumObj;
{
  int LpIndx;

  *ObjList = NULL;
  *NumObj = sNumOfRemNanRtrObj;

  (*ObjList) = (OM_S_OBJID *)malloc(sizeof(OM_S_OBJID) * sNumOfRemNanRtrObj);

  for(LpIndx = 0; LpIndx < sNumOfRemNanRtrObj ; LpIndx++)
    (*ObjList)[LpIndx] = sRemNanRtrObjList[LpIndx];
}
end implementation Root;
