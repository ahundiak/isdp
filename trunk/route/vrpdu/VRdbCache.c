/* $Id: VRdbCache.c,v 1.1.1.1 2001/01/04 21:13:01 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:  vrpdu / VRdbCache.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *  $Log: VRdbCache.c,v $
 *  Revision 1.1.1.1  2001/01/04 21:13:01  cvs
 *  Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1997/08/15  19:34:34  pinnacle
 * Replaced: vrpdu for:  by hverstee for route
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.3  1996/04/22  13:57:16  pinnacle
 * Replaced: vrpdu/VRdbCache.c for:  by hverstee for route240
 *
 * Revision 1.2  1996/01/17  17:31:08  pinnacle
 * Replaced: vrpdu/VRdbCache.c for:  by r240_int for route240
 *
 *
 * History:
 *     10/26/94  Lori  CR#179422038 added spec to HVAC - change
 *                         initial previous cache product from 0 to -1
 *                         so not to be confused with VR_HVAC (which is 0)
 *     01/17/96  tlb   Add prototypes
 *
 *************************************************************************/

#include <stdio.h>
#include "VRDbCache.h"
#include "vrpdu_pto.h"

/* Global Cache structure */

#if 0

struct VRDbCacheIndex
       {
           int        prj_no;             /* Project no   */
           short      PnpdAllCached;
           short      PnozNpdFlg;
           char       PnpdLstSpec[15];
           short      PnpdLstPrjUFlg;
           char       PCodSpec[15];
           char       PAdptSpec[15];
           short      PSpLstApp;
       };

static struct VRDbCacheIndex  VRDbCacheIdx = { -1, 0, 0, "", 0, "", "" , -1};
 
void VRdbInitCacheIdx ()
{
      /* Initialize all the cache indices */

      VRDbCacheIdx.prj_no            = -1;
      VRDbCacheIdx.PnpdAllCached     = 0;
      VRDbCacheIdx.PnozNpdFlg        = 0;
      VRDbCacheIdx.PnpdLstSpec[0]    = 0;
      VRDbCacheIdx.PnpdLstPrjUFlg    = 0;
      VRDbCacheIdx.PCodSpec[0]       = 0;
      VRDbCacheIdx.PAdptSpec[0]      = 0;
      VRDbCacheIdx.PSpLstApp         = -1;

      return;
}

int VR_DbC_Clear ()
{
  VR_DbC_Clunt ();

  VR_DbC_Cltab ();

  VR_DbC_Clhvc ();

  VR_DbC_Clnpd ();

  VR_DbC_Clpid ();

  VR_DbC_Clnoz ();

  VR_DbC_Clhdb ();

  VRdbInitCacheIdx ();

  VR_DbC_ClRIS ();

  UI_status ("Route DB cache cleared");

  return 0;
}

int VRdbCheckCacheIndx (int     index,
                        int    *value,
                        char   *string)
{
    
      switch( index)      
      {
          case VRDB_PRJ_IDX1:
                 if(VRDbCacheIdx.prj_no !=  *value)
                 {
                   VRdbInitCacheIdx ();              
                   VRDbCacheIdx.prj_no = *value;
                   return 1;
                 }
                 else
                    return 0;
          case VRDB_NPD_IDX2:
                 if(VRDbCacheIdx.PnpdAllCached == 0)
                 {
                   VRDbCacheIdx.PnpdAllCached = 1;
                   return 1;
                 }
                 else
                    return 0;

          case VRDB_NOZ_IDX3:
                 if(VRDbCacheIdx.PnozNpdFlg == 0)
                 {
                   VRDbCacheIdx.PnozNpdFlg = 1;
                   return 1;
                 }
                 else
                    return 0;
          case VRDB_NPD_IDX4:
                 if(strcmp(VRDbCacheIdx.PnpdLstSpec, string))
                 {
                   strcpy(VRDbCacheIdx.PnpdLstSpec, string);
                   return 1;
                 }
                 else
                    return 0;
          case VRDB_NPD_IDX5:
                 if(VRDbCacheIdx.PnpdLstPrjUFlg == 0)
                 {
                   VRDbCacheIdx.PnpdLstPrjUFlg = 1;
                   return 1;
                 }
                 else
                    return 0;
          case VRDB_COD_IDX6:
                 if(strcmp(VRDbCacheIdx.PCodSpec, string))
                 {
                   strcpy(VRDbCacheIdx.PCodSpec, string);
                   return 1;
                 }
                 else
                    return 0;

          case VRDB_ADP_IDX7:
                 if(strcmp(VRDbCacheIdx.PAdptSpec, string))
                 {
                   strcpy(VRDbCacheIdx.PAdptSpec, string);
                   return 1;
                 }
                 else
                    return 0;
          case VRDB_SPL_IDX8:
                 if(VRDbCacheIdx.PSpLstApp != *value)
                 {
                   VRDbCacheIdx.PSpLstApp = *value;
                   return 1;
                 }
                 else
                    return 0;
          default:
                   return 0;           
        
      }                               
                                                 
}           

#endif
