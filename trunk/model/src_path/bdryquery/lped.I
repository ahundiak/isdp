/*
  OVERVIEW

  This file consists of OMuse functions related to Loop-Edge 
  connections. These functions can fall under any of the 
  following category.
  a. Creation
  b. Query
  c. Manipulation
  These functions are also arranged in the same manner as above.


  NOTES

  The functions in this file aims at accessing the instance data
  of the loop objects and manipulating the same.


  HISTORY

  Sanjay  : Creation
*/

class implementation Root;

#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <malloc.h>

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "PWminimum.h"
#include "PWerror.h"

#include "PWapi/lpprops.h"
#include "PWapi/sfuptrav.h"

extern OMuword OPP_EMSpartedge_class_id, OPP_EMSloop_class_id;


int pwNumEdsOfLp 
(
  PWobjid loopobj,
  PWosnum os
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS;

  /* loop-to-edge channel info */
  OM_S_CHANSELECT  to_edges;

  /* number of edges */
  unsigned int num_edges=0;

  /* 
   * get the loop-to-edge channel info 
   */
  EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

  /*
   * get the number of components on this channel and return
   */
  OMsts = om$get_channel_count (objid = loopobj, osnum = os,
                                p_chanselect = &to_edges, count = &num_edges);
  if (!(1&OMsts))
    return (int) 0;

  return (int) num_edges;
}

int pwEdsOfLp 
(
  PWobjid loopobj,
  PWosnum os,
  PWobjid *p_eds
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS;
  
  /* loop variables */
  int   ed=0, inx, incr;

  /* loop-to-edge channel info */
  OM_S_CHANSELECT  to_edges;

  /* number of edges */
  unsigned int num_edges=0, tnum=0;

  /* edges */
  OM_S_OBJECT_LINKAGE *p_edges=NULL;

  /* 
   * get the loop-to-edge channel info 
   */
  EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

  /*
   * get the number of components on this channel and return
   */
  OMsts = om$get_channel_count (objid = loopobj, osnum = os,
                                p_chanselect = &to_edges, count = &num_edges);

  if (!(1&OMsts) || !num_edges)
    return (int) 0;

  /*
   * allocate the memory and get the edges 
   */
  p_edges = (OM_S_OBJECT_LINKAGE *) alloca (num_edges * 
                                            sizeof(OM_S_OBJECT_LINKAGE));
  if (!p_edges)
    return (int) 0;

  OMsts = om$get_channel_objects (objid = loopobj, osnum = os,
                                  p_chanselect = &to_edges, list = p_edges,
                                  size = num_edges, count = &tnum);
  if (!(1&OMsts) || (num_edges != tnum))
    return (int) 0;

  if (pwIsLpRev (loopobj, os))
  {
    inx = num_edges - 1; incr = -1;
  }
  else
  {
    inx = 0; incr = 1;
  }

  for (ed=0; ed < num_edges; ed++, inx += incr)
    p_eds[inx] = p_edges[ed].S_objid;

  return (int) num_edges;
}

PWobjid pwEdAtInxOfLp
(
  PWobjid  loopobj,
  PWosnum  os,
  int      index
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS;

  /* loop-to-edge channel info */
  OM_S_CHANSELECT  to_edges;

  /* edge id */
  OM_S_OBJID  edge;

  /*
   * get the loop-to-edge channel info
   */
  EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

  /*
   * if the loop is reversed, find the logical index of the edge on the
   * loop.
   */
  if (pwIsLpRev (loopobj, os))
  {
    unsigned int num_edges;

    OMsts = om$get_channel_count (objid = loopobj, osnum = os,
                                  p_chanselect = &to_edges,
                                  count = &num_edges);
    index = num_edges - index - 1;
  }

  /*
   * get the object at the specified index and return 
   */
  OMsts = om$get_objid_at_index (objid = loopobj, osnum = os, index = index,
                                 p_chanselect = &to_edges, objidaddr = &edge,
                                 osnumaddr = &os);
  if (!(1&OMsts))
    return PW_K_NullObjid;

  return (PWobjid) edge;
}


int pwGetEdInxOnLp 
(
  PWobjid  edobj,
  PWosnum  os
)
{
  /* loop of the edge */
  PWobjid  lpobj=PW_K_NullObjid;

  lpobj = pwGetLpOfEd (edobj, os);

  if (lpobj != PW_K_NullObjid)
  {
    /* status stuff */
    long  OMsts=OM_S_SUCCESS;
  
    /* loop-to-edge channel info */
    OM_S_CHANSELECT  to_edges;
  
    /* edge index */
    unsigned int  edinx=0;

    /*
     * get the loop-to-edge channel info
     */
    EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

    /*
     * get the edge index on this loop 
     */
    OMsts = om$get_index (osnum_c = os, objid_c = lpobj, 
                          p_chanselect = &to_edges, objid = edobj, 
                          osnum2 = os, indexaddr = &edinx);
    if (!(1&OMsts))
      return (int) -1;

    /*
     * If the loop is reversed, then find the logical index of the edge
     * and return the logical index.
     */
    if (pwIsLpRev (lpobj, os))
    {
      unsigned int num_edges;

      OMsts = om$get_channel_count (objid = lpobj, osnum = os,
                                    p_chanselect = &to_edges,
                                    count = &num_edges);
      edinx = num_edges - edinx - 1;
    }

    return (int) edinx;
  }

  return (int) -1;
}

/*
  ABSTRACT

  Returns the objid of the loop to which this edge is connected. Note that
  this edge maybe physically connected to more than one loop but only one
  of them is active. If there is no active loop, then the edge is deemed
  NOT CONNECTED to any loop. On such failure (or any failure), a null objid
  is returned.
*/

PWobjid pwLpOfEd
(
  PWobjid edobj,
  PWosnum os
)
{
  return (PW_K_NullObjid);
}

end implementation Root;
