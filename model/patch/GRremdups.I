class implementation Root;
/*****************************************************************************

    Name:remdups.I
    Desc:Removes multiple entries of objects in rtree.

*****************************************************************************/
#include <stdio.h>
#include <string.h>
#include "OMmacros.h"
#include "OMminimum.h"
#include "msdef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
 
#include "GRtypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMindex.h"
#include "OMDB.h"

#include "godef.h"

#define NUM_RTREE_OBJ 100000
#define MAXDOUBLE 1e+300

from OMrtree import find_and_remove, find_key;
from OMindex import translate;
from GRgraphics import GRaddwrng;
from GRvg import GRgetrang;

extern int GRProcess_Rtree();


IGRboolean SearchObjArr(NanObj,ObjArr,NumObj)
OM_S_OBJID NanObj;
OM_S_OBJID *ObjArr;
int NumObj;
{
  IGRboolean FoundInArr = FALSE;
  int LpIndx;
  for(LpIndx = 0; LpIndx < NumObj; LpIndx++)
  {
    if(ObjArr[LpIndx] == -1) continue;
    if(ObjArr[LpIndx] == NanObj)
    {
      FoundInArr = TRUE;
      break;
    }
  }
  return(FoundInArr);
}


void RemDupEntInRtree()
{
  OM_S_CHANSELECT   chan;
  IGRchar          name[8];
  DB_3D_DBL_BOX     rtrange_test;
  IGRlong NumberOfBytes, BytesReceived, rt, status;
  struct GRmd_env local_env;
  int  LpIndx,NumOfNanObj = 0,msg,loop1,loop2, ret_bis,array_size;
  IGRboolean FoundInObjArr ,more_than_one;
  OM_S_KEY_DESC select_key_search_range, select_key_rtree_range,rtree_key_test;
  GRrange search_range, rtree_range;
  OM_S_OBJARRAY *obj_array=NULL;
  OM_S_OBJID  *NanObjList = NULL,*arr=NULL;
  
  GRrange  design_obj_rng;
  IGRshort   matrix_type=2;
  IGRboolean  world =0;
  IGRmatrix matrix;


  status = GRProcess_Rtree();

  if (status != OM_S_SUCCESS)
  {
#ifdef DEBUG
     printf("Something happened.\n");
#endif
     exit( 1 );
  }

  /* get module environment */

  NumberOfBytes = sizeof( local_env );
  gr$get_module_env( msg = &rt,
            sizbuf = &NumberOfBytes,
            buffer = &local_env,
            nret = &BytesReceived );

  strcpy(name, "primary");
  chan.type = OM_e_name;
  chan.u_sel.name = name;

  rtree_key_test.type = KEY_3D_DBL;
  rtree_key_test.key.p_3ddbl = &rtrange_test;
  
  array_size = ( sizeof( OM_S_OBJID ) * NUM_RTREE_OBJ ) + sizeof(OM_S_OBJARRAY);

  obj_array = ( OM_S_OBJARRAY * )om$malloc( size = array_size );
  obj_array->size = array_size;

  obj_array->count = 0;
  obj_array->tree_type = KEY_3D_DBL;

  /* search Rtree with the design limits */

  rtrange_test.xmin = -MAXDOUBLE;
  rtrange_test.ymin = -MAXDOUBLE;
  rtrange_test.zmin = -MAXDOUBLE;
  
  rtrange_test.xmax = MAXDOUBLE;
  rtrange_test.ymax = MAXDOUBLE;
  rtrange_test.zmax = MAXDOUBLE;

  status = om$send( msg = message OMindex.translate( obj_array, 
                                                    &rtree_key_test, 
                                                    NULL,NULL,&ret_bis ),
                    senderid  = local_env.md_id.objid,
                    targetos = local_env.md_id.osnum,
                    p_chanselect = &chan );

  if( ret_bis != DB_SUCCESS ) 
  {
#ifdef DEBUG
    printf("failed to get rtree objects\n");
#endif
    goto wrapup;
  }

  search_range[0] = -MAXDOUBLE;
  search_range[1] = -MAXDOUBLE;
  search_range[2] = -MAXDOUBLE;
  search_range[3] = MAXDOUBLE;
  search_range[4] = MAXDOUBLE;
  search_range[5] = MAXDOUBLE;


  /* arr contains all the rtree object ids */
  
  arr = obj_array->array;
  select_key_search_range.type = KEY_3D_DBL;
  select_key_search_range.key.p_3ddbl = ( DB_3D_DBL_BOX * )search_range;
  select_key_rtree_range.type = KEY_3D_DBL;
  select_key_rtree_range.key.p_3ddbl = ( DB_3D_DBL_BOX * )rtree_range;
  

  /* loop thru the array to remove multiple entries of objects */
#ifdef DEBUG
  printf("Number of objects = %d\n",obj_array->count);
#endif


  for( loop1=0; loop1<obj_array->count; loop1=loop1+1 )
  {
    more_than_one = FALSE;
    if( arr[loop1] == -1 ) continue;

    for( loop2=loop1+1; loop2<obj_array->count; loop2=loop2+1 )
    {
      if( arr[loop1] == arr[loop2] ) 
      {

        status = om$send( msg = message OMrtree.find_key(
                                                      &select_key_search_range,
                                                      &arr[loop2],
                                                      &select_key_rtree_range,
                                                      0, &msg ),
                              senderid  = local_env.md_id.objid,
                              targetos = local_env.md_id.osnum,
                              p_chanselect = &chan );
                            

        if(msg == DB_SUCCESS)
        {
          rtrange_test.xmin = rtree_range[0];
          rtrange_test.ymin = rtree_range[1];
          rtrange_test.zmin = rtree_range[2];
        
          rtrange_test.xmax = rtree_range[3];
          rtrange_test.ymax = rtree_range[4];
          rtrange_test.zmax = rtree_range[5];

          status = om$send( msg = message OMrtree.find_and_remove(
                                                        &rtree_key_test, 
                                                        &arr[loop2],
                                                        0 ,&ret_bis ),
                                         senderid  = local_env.md_id.objid,
                                         targetos = local_env.md_id.osnum,
                                         p_chanselect = &chan );

          if(ret_bis != DB_SUCCESS) 
          {
#ifdef DEBUG
            printf( "Failed to remove duplicate object from Rtree:%d\n",
                             arr[loop2] );
#endif
          }
          else 
          {
#ifdef DEBUG
            printf("Removed duplicate object: %d\n", arr[loop2]);
#endif
            arr[loop2] = -1;
          }
        }
        else
        {
#ifdef DEBUG
          printf( "Failed to find the object in the Rtree:%d\n", arr[loop2] );
#endif
        }
      }
    }
  }

  for( loop1 = 0 ; loop1 < obj_array->count; loop1++ )
  {
    if( arr[loop1] == -1 ) continue;
    status = om$send( msg = message OMrtree.find_key(
                                    &select_key_search_range,
                                    &arr[loop1],
                                    &select_key_rtree_range,
                                    0, &msg ),
                         senderid  = local_env.md_id.objid,
                         targetos = local_env.md_id.osnum,
                         p_chanselect = &chan );

    if( msg == DB_SUCCESS )
    {
      rtrange_test.xmin = rtree_range[0];
      rtrange_test.ymin = rtree_range[1];
      rtrange_test.zmin = rtree_range[2];
           
      rtrange_test.xmax = rtree_range[3];
      rtrange_test.ymax = rtree_range[4];
      rtrange_test.zmax = rtree_range[5];

      status = om$send( msg = message OMrtree.find_and_remove( 
                                                &rtree_key_test, 
                                                &arr[loop1], 
                                                0 ,
                                                &ret_bis ),
                             senderid  = local_env.md_id.objid,
                             targetos = local_env.md_id.osnum,
                             p_chanselect = &chan );

      if( ret_bis == DB_SUCCESS )
      {
                /** 
                    Object is removed from Rtree. Now take the range from
                    the design and Check if the key has valid range , if it 
                    has then add to the GRrtree
                **/

        status = om$send( msg = message GRvg.GRgetrang( &rt,
                                                &matrix_type, 
                                                matrix , 
                                                &world, 
                                                design_obj_rng ),
                                senderid = NULL_OBJID,
                                 targetid = arr[loop1],
                                 targetos = local_env.md_id.osnum );

        if( ( status = 
            GRvalidate_rtree_range( (double * )design_obj_rng ) )
                    == 1 )
        {
          status = om$send( msg = message GRgraphics.GRaddwrng( &rt,
                                                                &local_env ),
                                     senderid = NULL_OBJID,
                                     targetid = arr[loop1],
                                     targetos = local_env.md_id.osnum );

          if( ! ( status & rt & 1 ) )
          {
#ifdef DEBUG
            printf( "failed to add object to Rtree: %d \n", 
                            arr[loop1] );
#endif
          }
        }
      }
      else
      {
#ifdef DEBUG
        printf("Failed to remove obj from Rtree %d\n",arr[loop1]);
#endif
      }
    }
  }

  GetNanObjList(&NanObjList,&NumOfNanObj);
  for( LpIndx = 0 ; LpIndx < NumOfNanObj; LpIndx++ )
  {
    FoundInObjArr = FALSE;
    FoundInObjArr = SearchObjArr(NanObjList[LpIndx],arr,obj_array->count);
    if(FoundInObjArr) continue;
   
    status = om$send( msg = message GRvg.GRgetrang( &rt,
                                                &matrix_type,
                                                matrix ,
                                                &world,
                                                design_obj_rng ),
                                senderid = NULL_OBJID,
                                 targetid = NanObjList[LpIndx],
                                 targetos = local_env.md_id.osnum );
    if(!(status & rt & 1))
    {
#ifdef DEBUG
      printf("Failed to get the range from GRgetrang for Object %d\n",
		 NanObjList[LpIndx]);
#endif
      continue;
    }
 
        if( ( status =
            GRvalidate_rtree_range( (double * )design_obj_rng ) )
                    == 1 )
        {
          status = om$send( msg = message GRgraphics.GRaddwrng( &rt,
                                                                &local_env ),
				     senderid = NanObjList[LpIndx],
                                     targetid = NanObjList[LpIndx],
                                     targetos = local_env.md_id.osnum );
 
          if( ! ( status & rt & 1 ) )
          {
#ifdef DEBUG
            printf("Failed to Add Nan Object to Rtree:%d\n",
			NanObjList[LpIndx]);
#endif
          }
        }

    
     

  }
wrapup:
if (obj_array)
    om$dealloc(ptr = obj_array);

}

end implementation Root;
