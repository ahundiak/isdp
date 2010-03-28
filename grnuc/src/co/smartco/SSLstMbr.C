/*
Name
  SSLstMbr.C

 */

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


/*

Name
  SSListMember

Abstract

Synopsis
  int SSListMember( GRobjid objid; GRspacenum osnum; int *p_index; )
     
    objid   (IN)   The SMObjects[] list is searched to find this objid
    osnum   (IN)   Should be set to 0 until multiple osnums are supported
    p_index (OUT)  Index in SMObjects[] list where *p_grid was found. This will
                   be equal to SSnb_objects if the grid is not in the list

Description

Return Value
  TRUE  - if the specified grid was found in the SMObjects list
  FALSE - if the specified grid was NOT in the SMObjects list

Notes
  Private

Index

Keywords

History
  09/07/93 : Shelley R. Heard : created

 */

int SSListMember( objid, osnum, p_index )
  GRobjid    objid;
  GRspacenum osnum;
  int       *p_index;
{
  int loc_index;
  loc_index = *p_index;

  for ( loc_index = 0;  loc_index < SSnb_objects; loc_index++ )
  {
    if (    SSObjects [loc_index].grid.objid == objid 
	 && ( !osnum || SSObjects [loc_index].grid.osnum == osnum ))
    {
      break;
    }
  }
  *p_index = loc_index;
  /*
   * if (*p_index < SSnb_objects), then the object is a member of the list
   */
  return ( *p_index < SSnb_objects );
}

