#include <math.h>
#include "bsvalues.h"
#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMindex.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "exdef.h"
#include "msdef.h"
#include "madef.h"
#include "SSdef.h"
#include "SS.h"
#include "SSmacros.h"


/*

Name
  SSListKeyptActiveIndex ( objid, osnum, action, index )
  SSListKeyptActiveMask  ( objid, osnum, action, mask  )
  SSListKeyptActivePoint ( objid, osnum, action, point )

Abstract
  This function searches the SSObjects list for a specified element (objid,
  osnum) and then performs an action (set/unset/toggle) on the specified 
  keypoint of that element.  

Synopsis
  int SSListKeyptActiveIndex ( objid, osnum, action, index )
  int SSListKeyptActiveMask  ( objid, osnum, action, mask  )
  int SSListKeyptActivePoint ( objid, osnum, action, point )

  GRobjid     objid  (IN)  The object we look for in the SSObjects list
  GRspacenum  osnum  (IN)  Object space of the element (if 0, master assumed)
  int         action (IN)  SSUNSET_KEYPT  : makes keypoint inactive
                           SSSET_KEYPT    : makes keypoint active
                           SSTOGGLE_KEYPT : toggle active state of keypoint
  int          mask  (IN)  element independent keypt mask (see SSdef.h)
  int          index (IN)  element specific keypoint index (see SSdef.h)
  double      *point (IN)  approximate location of key point

Description
  Finds the element (objid/osnum) in the list and then acts upon one or more 
  of the element's keypoints (specified by mask, index, or point). Specified
  keypoints are either activated, deactivated, or toggled - depending on the 
  action flag (action) passed in.

Return Value
  OM_S_SUCCESS   -  Success (this happens when Smart Sketch is not active, too)
  OM_E_NOSUCHOBJ -  The element was not in the SSObjects list
  OM_E_INVARG    -  Bad argument (probably 'action'), or MA2ptdis() failed

Notes

Index

Keywords
  smart-sketch,key-point

History
  08/30/93 : Shelley R. Heard : New functionality for Smart Sketch

 */

int SSListKeyptActivePt ( action, objid, osnum, point )
  int         action;
  GRobjid     objid;
  GRspacenum  osnum;
  IGRdouble  *point;
{
  int       rc = OM_S_SUCCESS;
  long      sts = TRUE;
  int       i_ss_obj;
  int       ndx;
  int       keypt_index = 0;
  double    current_distance = MAXFLOAT;
  double    closest_distance = 0.0;

  /* 
   * we check because this may be called directly and unconditionally from 
   * a command 
   */

  if (ss$is_active())
  {
    /*
     * if our objid is in the list, operate on it
     */
    if ( SSListMember( objid, 0, &i_ss_obj) )
    { 
      /* find the closest key point */
      for ( ndx = 0; ndx < SSObjects [i_ss_obj].NbKeyPoints; ndx++ )
      {
        if ( MA2ptdis ( &sts, 
                         SSObjects[i_ss_obj].KeyPoints[ndx], 
                         point, 
                        &current_distance) )
        {
          current_distance = fabs(current_distance); 
        }
        else
        {
          rc = OM_E_INVARG; /* for lack of a better return code */
        }

        if ( current_distance < closest_distance )
        {
          closest_distance = current_distance;     
          keypt_index = ndx;  
        }
      }

      /*
       * SSObjects[i_ss_obj].KeyPoints[keypt_index] is now the 
       * closest keypoint to the point specified by the caller.
       */
      SSListKeyptActiveIndex ( objid, osnum, action, keypt_index );
    }
    else
    {
      rc = OM_E_NOSUCHOBJ;  /* objid not found in the SSObjects[] list */
    }
  }
  return rc;
}


int SSListKeyptActiveIndex ( objid, osnum, action, index )
  GRobjid     objid;
  GRspacenum  osnum;
  int         action;
  int         index;
{
  int       rc = OM_S_SUCCESS;
  int       i_ss_obj;
 
  if (ss$is_active())
  {
    if ( SSListMember( objid, osnum, &i_ss_obj) )
    { 
      switch (action)
      {
        case SSSET_KEYPT :
        {
          SSObjects [i_ss_obj].KeyPointActive[index] = TRUE;
          break;
        }
  
        case SSUNSET_KEYPT :
        {
          SSObjects [i_ss_obj].KeyPointActive[index] = FALSE;
          break;
        }
  
        case SSTOGGLE_KEYPT :
        {
          SSObjects [i_ss_obj].KeyPointActive[index] = 
            (!SSObjects [i_ss_obj].KeyPointActive[index]);
          break;
        }
  
        default:
        {
          rc = OM_E_INVARG;
        }
      }
    }
    else
    {
      rc = OM_E_NOSUCHOBJ;  /* objid not found in the SSObjects[] list */
    }
  }
  return rc;
}

/*

Name
  SSListKeyptActiveMask 

Abstract

Synopsis
  int SSListKeyptActiveMask ( objid, osnum, action, mask )

  GRobjid     objid;
  GRspacenum  osnum;
  int       action  (IN)     0 = deactivate keypt indicated in mask 
                             1 = activate keypt indicated in mask
  int       mask    (IN)     Which Key point(s) 


Description

Return Value

Notes

Index

Keywords

History
  09/20/93 : Shelley R. Heard : created

 */

int SSListKeyptActiveMask( objid, osnum, action, mask )
  GRobjid     objid;
  GRspacenum  osnum;
  int         action;
  int         mask;
{
  int rc = OM_S_SUCCESS;
  int i_ss_obj;
  int indices[ SS_MAX_KEYPOINTS ];
  int nbr_keypts = 0;

  /* 
   * 1) find object in list; 
   * 2) deternime the keypoint index;
   * 3) call SSListKeyptActiveIndex()
   */

  if ( SSListMember( objid, osnum, &i_ss_obj ) )
  {
    switch (SSObjects[i_ss_obj].type)
    {
      case SSPOINT:
      {
        if ( mask & SSKP_ORIGIN )
        {
          indices[nbr_keypts] = SSPOINT_ORIGIN;
          nbr_keypts++;
        }

        break; 
      }
  
      case SSLINE :
      {
        if ( mask & SSKP_ENDPT1 )
        {
          indices[nbr_keypts] = SSLINE_ENDPT1;
          nbr_keypts++;
        }
        if ( mask & SSKP_ENDPT2 )
        {
          indices[nbr_keypts] = SSLINE_ENDPT2;
          nbr_keypts++;
        }
        if ( mask & SSKP_MIDPT )
        {
          indices[nbr_keypts] = SSLINE_MIDPT;
          nbr_keypts++;
        }

        break; 
      }
  
      case SSARC:
      {
        if ( mask & SSKP_ENDPT1 )
        {
          indices[nbr_keypts] = SSARC_ENDPT1;
          nbr_keypts++;
        }
        if ( mask & SSKP_ENDPT2 )
        {
          indices[nbr_keypts] = SSARC_ENDPT2;
          nbr_keypts++;
        }
        if ( mask & SSKP_CENTER )
        {
          indices[nbr_keypts] = SSARC_CENTER;
          nbr_keypts++;
        }
        break;
      }
  
      case SSCIRCLE:
      {
        if ( mask & SSKP_CENTER )
        {
          indices[nbr_keypts] = SSCIRCLE_CENTER;
          nbr_keypts++;
        }
  
        if (SSObjects [i_ss_obj].NbKeyPoints == SSCIRCLE_NBR_KP_RP_ON )
            
        {
          if ( mask & SSKP_QUADPT1 )
          {
            indices[nbr_keypts] = SSCIRCLE_QUADPT1;
            nbr_keypts++;
          }
          if ( mask & SSKP_QUADPT2 )
          {
            indices[nbr_keypts] = SSCIRCLE_QUADPT2;
            nbr_keypts++;
          }
          if ( mask & SSKP_QUADPT3 )
          {
            indices[nbr_keypts] = SSCIRCLE_QUADPT3;
            nbr_keypts++;
          }
          if ( mask & SSKP_QUADPT4 )
          {
            indices[nbr_keypts] = SSCIRCLE_QUADPT4;
            nbr_keypts++;
          }
        }
        break;
      }
  
      case SSBSCURVE :
      {
        if ( mask & SSKP_ENDPT1 )
        {
          indices[nbr_keypts] = SSBSCURVE_ENDPT1;
          nbr_keypts++;
        }
        if ( mask & SSKP_ENDPT2 )
        {
          indices[nbr_keypts] = SSBSCURVE_ENDPT2;
          nbr_keypts++;
        }
        if ( mask & SSKP_MIDPT )
        {
          indices[nbr_keypts] = SSBSCURVE_MIDPT;
          nbr_keypts++;
        }

        break; 
      }
  
      default:
        rc = MSINARG;
    }
    if (rc == OM_S_SUCCESS)
    {
      int ndx;
      for (ndx = 0; ndx < nbr_keypts; ndx ++ )
      {
        rc = SSListKeyptActiveIndex ( objid, osnum, action, indices[ndx] );
      }
    }
  }

  return rc;
}


