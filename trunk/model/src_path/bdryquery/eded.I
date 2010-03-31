/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
  OVERVIEW
      This file consists of OMuse functions related to Edge-Edge
      connections. These functions can fall under any of the
      following category.
       a. Creation
       b. Query
       c. Manipulation
      These functions are also arranged in the same manner as above.
 
  NOTES
      The functions in this file aims at accessing the instance data
      of the Edge objects and manipulating the same. The prototypes 
      for all the APIs defined in this file are available in $MODEL/
      include/PWdbapi/eded.h
 
  KEYWORDS
      edge, BSedge, Linear edge, Point edge, Dummy edge, Part Edge, Active 
      part edge, loop, loopset, active loop  etc.
 
  HISTORY
      Sanjay       01/25/95     Creation
 
*/

class implementation Root;

/* Includes */

#include <alloca.h>
#include "OMminimum.h"
#include "OMprimitives.h"         /* OM */
#include "OMmacros.h"

#include "emsdef.h"               /* MODEL */

#include "PWminimum.h"
#include "PWerror.h"
#include "PWattrib.h"
#include "PWattribid.h"
#include "PWgmdata.h"             /* Pathway */

/* Prototypes */
#include "PWapi/lped.h"
#include "PWapi/lpprops.h"
#include "PWapi/edprops.h"
#include "PWapi/edgeom.h"
#include "PWapi/edptproj.h"
#include "PWapi/dbglevel.h"

/* External Variables */

extern OMuword  OPP_EMSpartedge_class_id, OPP_EMSloop_class_id;

/* Static Function Prototypes */

%safe 

static PWobjid get_adjacent_edge
(
  PWobjid    edobj,
  PWosnum    os,
  PWboolean  is_next,
  PWboolean  no_degen,
  double     lentol
);

%endsafe


/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
      Returns the highest partedge in the active path, that contains the input
      parameter. If no such paredge exists it returns PW_K_NullObjid.
 
  ARGUMENTS
      PWobjid           edobj       I   edge object ID
      PWosnum           os          I   edge object OS
      struct PWcvparam  *p_edpar    I   parameter on partedge
 
  DESCRIPTION
      Given an edge, OS and a parameter this function returns the highest 
      partedge in the active path (the partedge with ACTIVE bit set), that 
      contains the input parameter. If no such paredge exists it returns 
      PW_K_NullObjid.
 
  NOTES
      None
 
  RETURN VALUES
      The highest Partedge in the active path , if everything goes well.
      PW_K_NullObjid , if no such partedge or if any internal error.
 
  SAMPLE
      PWobjid  parted; struct PWcvparam edpar;
 
      parted = pwGetPartEdOfEd (edobj, os, &edpar);
      if (parted == PW_K_NullObjid)
        Message (Take Necessary Action)
 
  HISTORY
      Sanjay        01/24/95          Creation
 
*/

PWobjid pwGetPartEdOfEd
(
  PWobjid           edobj,
  PWosnum           os,
  struct PWcvparam  *p_edpar
)
{
  /* status stuff */
  long  OMsts = OM_S_SUCCESS;

  /* edge to common edge channel info */
  OM_S_CHANSELECT  to_owners;

  /* general stuff */
  int  own=0;
  unsigned int  tnum=0;

  /* owners of the edge */
  unsigned int  num_owners=0;
  OM_S_OBJECT_LINKAGE  *p_owners=NULL;

  PWclassid  own_class;

  PWobjid   lpobj=PW_K_NullObjid, parted=PW_K_NullObjid;

  /*
   * get the edge to owner channel info
   */
  EMmake_chanselect (EMSedge_to_owner, &to_owners);

  /*
   * get all the objects on this channel
   */
  OMsts = om$get_channel_count (objid = edobj, osnum = os, 
                               p_chanselect = &to_owners, count = &num_owners);
  if (!(1&OMsts) || !num_owners)
    return PW_K_NullObjid;
  
  p_owners = (OM_S_OBJECT_LINKAGE *) alloca (num_owners * 
                                             sizeof (OM_S_OBJECT_LINKAGE));
  if (!p_owners)
    return PW_K_NullObjid;

  OMsts = om$get_channel_objects (objid = edobj, osnum = os, 
                                  p_chanselect = &to_owners, size = num_owners,
                                  list = p_owners, count = &tnum);
  if (!(1&OMsts) || (num_owners != tnum))
    return PW_K_NullObjid;

  /*
   * For each owner, if it is a part edge and is active 
   */

  /*
   * go through each owner and see, whether there is any part edge, if so
   * return NULL, otherwise continue till U hit an active Ploop and return
   * this active Ploop
   */
  for (own=0; own<num_owners; own++)
  {
    /*
     * get the owner's class
     */
    OMsts = om$get_classid (objid = p_owners[own].S_objid,
                            osnum = p_owners[own].osnum,
                            p_classid = &own_class);
    if (!(1&OMsts))
      continue;

    /*
     * if the owner is a part edge, then this edge is not connected to an
     * active loop. So error out.
     */
    if (om$is_ancestry_valid(subclassid = own_class,
              superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
    {
      lpobj = PW_K_NullObjid;
      break;
    }
    else if(om$is_ancestry_valid(subclassid = own_class,
                  superclassid = OPP_EMSloop_class_id) == OM_S_SUCCESS)
           /* It is a loop */
    {
      /*
       * check whether this loop is active or not. If active return this
       * loop otherwise continue.
       */
      if (pwIsLpActive (p_owners[own].S_objid, p_owners[own].osnum))
      {
        lpobj = p_owners[own].S_objid;
        break;
      }
    }
  }

  if (lpobj != PW_K_NullObjid)
  {
    PWclassid  ed_class=0; 

    /*
     * get the end pars of the loop and check whether the given parameter is 
     * lying on the edge or not. If it is lying on this edge, then return the
     * this edge id as the part edge id otherwise return NullObjid.
     */
    OMsts = om$get_classid (objid = edobj, osnum = os, p_classid = &ed_class);
    if (!(1&OMsts))
      return PW_K_NullObjid;

    /*
     * if the owner is a part edge, then this edge is not connected to an
     * active loop. So error out.
     */
    if (om$is_ancestry_valid(subclassid = ed_class,
              superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
    {
      struct PWcvparam start_par, stop_par;

      pwGetEdEndPars (edobj, os, &start_par, &stop_par);

      if (p_edpar->spaninx >= start_par.spaninx && 
          p_edpar->spanpar >= start_par.spanpar &&
          p_edpar->spaninx <= stop_par.spaninx &&
          p_edpar->spanpar <= stop_par.spanpar)
        return edobj;
      else
        return PW_K_NullObjid;
    }
    else
      return PW_K_NullObjid;
  }
  else
  {
    for (own=0; own<num_owners; own++)
    {
      /*
       * get the owner's class
       */
      OMsts = om$get_classid (objid = p_owners[own].S_objid,
                              osnum = p_owners[own].osnum,
                              p_classid = &own_class);
      if (!(1&OMsts))
        continue;
  
      /*
       * if the owner is a part edge, then this edge is not connected to an
       * active loop. So error out.
       */
      if (om$is_ancestry_valid(subclassid = own_class,
                superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
      {
        parted = pwGetPartEdOfEd (p_owners[own].S_objid, p_owners[own].osnum,
                                  p_edpar); 
        if (parted != PW_K_NullObjid)
          return parted;
      }
    }
  }


  /* TBD */

  return parted;
}


/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

     Given an edge it returns the edge on the common edge channel.
  
  RETURN CODE
 
     The common edge if one exists otherwise PW_K_NullObjid.

*/

PWobjid pwGetCommonEd 
(
  PWobjid  edobj,
  PWosnum  os
)
{
  /* status stuff */
  long  OMsts = OM_S_SUCCESS;

  /* edge to common edge channel info */
  OM_S_CHANSELECT  to_common_edge;

  /* general stuff */
  unsigned int  tnum=0;

  /* common edge */
  OM_S_OBJECT_LINKAGE  common_edge;

  /* 
   * get the common edge channel info 
   */
  EMmake_chanselect (EMSedge_to_common_edge, &to_common_edge);

  /* 
   * get the object on this channel, which is nothing but the common edge 
   */
  OMsts = om$get_channel_objects (objid = edobj, osnum = os,
                                  p_chanselect = &to_common_edge,
                                  list = &common_edge, size = 1, 
                                  count = &tnum);
  if (!(1&OMsts) || (tnum != 1))
    return PW_K_NullObjid;

  return  (PWobjid) common_edge.S_objid;
}


/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

     Returns the edge which is topologically next to a given edge. If the edge
     is closed it returns PW_K_NullObjid.

  RETURN CODE

     The next edge. NullObjid can be returned in one of the follwing cases.
       o If the edge is closed. 
       o If the loop is open and asking for the next edge of the last edge.
*/

PWobjid pwGetNextEd
(
  PWobjid  edobj,
  PWosnum  os
)
{
  return get_adjacent_edge (edobj, os, TRUE, FALSE, 0);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT

     Returns the edge which is topologically previous to a given edge. If the 
     edge is closed it returns PW_K_NullObjid.

  RETURN CODE

     The previous edge. NullObjid can be returned in one of the follwing cases.
       o If the edge is closed.
       o If the loop is open and asking for the previous edge of the first edge.
*/


PWobjid pwGetPrevEd
(
  PWobjid  edobj,
  PWosnum  os
)
{
  return get_adjacent_edge (edobj, os, FALSE, FALSE, 0);
}

/*
  ABSTRACT

     Returns a non-degenerate edge which is topologically next to the  given 
     edge. If the edge is closed it returns PW_K_NullObjid.

  RETURN CODE

     The next edge. NullObjid can be returned in one of the follwing cases.
       o If the edge is closed.
       o If the loop is open and asking for the next edge of the last edge.
       o If there is no non-degenerate edge is found in the path.
*/


PWobjid pwGetNextEdNoDegen
(
  PWobjid  edobj,
  PWosnum  os,
  double   lentol
)
{
  return get_adjacent_edge (edobj, os, TRUE, TRUE, lentol);
}

/*
  ABSTRACT

     Returns the non-degenerate edge which is topologically previous to a given
     edge. If the edge is closed it returns PW_K_NullObjid.

  RETURN CODE

     The previous edge. NullObjid can be returned in one of the follwing cases.
       o If the edge is closed.
       o If the loop is open and asking for the previous edge of the first edge.
       o If there is no non-degenerate edge is found in the path.
*/

PWobjid pwGetPrevEdNoDegen
(
  PWobjid  edobj,
  PWosnum  os,
  double   lentol
)
{
  return get_adjacent_edge (edobj, os, FALSE, TRUE, lentol);
}


/*
  ABSTRACT

    Static function which gets the adjacent edge depending on the options.
*/

static PWobjid get_adjacent_edge
(
  PWobjid    edobj,
  PWosnum    os,
  PWboolean  is_next,
  PWboolean  no_degen,
  double     lentol
)
{
  /* loop of edge */
  PWobjid  lpobj=PW_K_NullObjid, edge=PW_K_NullObjid;

  /* index of edge on loop and number of edges on loop*/
  int edinx, num_edges=0;

  PWboolean lpopen=FALSE;

  /*
   * get loop of the edge
   */
  lpobj = pwGetLpOfEd (edobj, os);
  if (lpobj == PW_K_NullObjid)
    return PW_K_NullObjid;

  /*
   * get the index of the edge on loop
   */
  edinx = pwGetEdInxOnLp (edobj, os);
  if (edinx < 0)
    return PW_K_NullObjid;

  /*
   * get the number of edges on loop
   */
  num_edges = pwNumEdsOfLp (lpobj, os);
  if (num_edges == 1)
    return edobj;

  edge = edobj;

  lpopen = pwIsLpOpen (lpobj, os);

  do
  {
    if (lpopen && (is_next ? (edinx == num_edges - 1) : !edinx))
      return PW_K_NullObjid;

    if (is_next)
      edinx = (edinx == num_edges-1) ? 0 : (++edinx);
    else
      edinx = edinx ? (--edinx) : (num_edges-1);

    edge = pwEdAtInxOfLp (lpobj, os, edinx);
    if (edge == edobj)
      return PW_K_NullObjid;

    if (no_degen && pwIsEdDegenTol (edge, os, lentol))
      continue;

    return edge;

  } while(TRUE);
}

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
 
  ARGUMENTS
 
  DESCRIPTION
 
  NOTES
 
  RETURN VALUES
 
  KEYWORDS
 
*/

PWobjid pwGetEdOfPartEd
(
  PWobjid  edobj,
  PWosnum  os
)
{
  /* status stuff */
  long  OMsts=OM_S_SUCCESS;

  /* edge class id */
  OMuword  edclass;

  /*
   * get the edge class 
   */
  OMsts = om$get_classid (objid = edobj, osnum = os, p_classid = &edclass);
  if (!(1&OMsts))
    return (PWobjid) PW_K_NullObjid;

  /*
   * If it is a part edge, then return full edge id i.e. the owner of the
   * part edge otherwise return this edge.
   */
  if (om$is_ancestry_valid (subclassid = edclass,
            superclassid = OPP_EMSpartedge_class_id) == OM_S_SUCCESS)
  {
    /* partedge-to-edge channel info */
    OM_S_CHANSELECT      to_edges;
    unsigned int         tnum=0;
    OM_S_OBJECT_LINKAGE  edge;

    /*
     * get the partedge-to-edge channel info
     */
    EMmake_chanselect (EMSbd_owner_to_comps, &to_edges);

    /*
     * get the edge on this channel
     */
    OMsts = om$get_channel_objects (objid = edobj, osnum = os,
                                    p_chanselect = &to_edges, list = &edge,
                                    size = 1, count = &tnum);
    if (!(1&OMsts) || (tnum != 1))
      return (PWobjid) PW_K_NullObjid;

    /*
     * Call this function recursively on this edge
     */
    return pwGetEdOfPartEd (edge.S_objid, edge.osnum);
  }
  else
  {
    return edobj;
  }
}

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

/*
  DESCRIPTION

  This function returns the id of the edge that intervenes  between  two
  topologically defined points. The topological definition of a point is
  simply the edge-id on which it lies and the topo-position of the point
  on the edge (start, middle, stop). Any degenerate edges coming in between
  the two points are discarded from consideration. For this reason, 'uvtol'
  is input in order to figure out degeneracy.

  In case of ambiguity, viz, when the topological information is not 
  sufficient (this information taken alone yields two possible solutions as 
  in the case of a two-edge loop and the two input points are the vertices 
  within this loop), a geometric discriminant is needed. This is provided by 
  a geometric point lying on the intervening edge. Obviously, this geometric 
  point needs to be known a priori.


  NOTES

  The circumstance in which this function performs  a  non-trivial task
  is when one or both the topo-defs of the points indicate vertices and
  the vertex definition includes the id of the adjacent edge.


  HISTORY

  Sanjay  :  06/21/95  :  Creation
*/

PWobjid  pwGetInterveningEdge
(
  PWosnum            os,
  PWobjid            ed1,
  enum PWtopopostype topo1,
  PWobjid            ed2,
  enum PWtopopostype topo2, 
  PWpoint2d          midpt,
  double             uvtol
)
{
  PWresult PWsts=PW_K_Success;
  PWobjid  retid=PW_K_NullObjid;
  PWobjid  adjed1=PW_K_NullObjid, adjed2=PW_K_NullObjid;

  if (ed1 == ed2)
    retid = ed1;
  else if (topo1 == PWtopopos_middle && topo2 == PWtopopos_middle)
  {
    retid = PW_K_NullObjid;
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg), 
                  wrapup);
  }
  if (topo1 == PWtopopos_middle)
    retid = ed1;
  if (topo2 == PWtopopos_middle)
    retid = ed2;
  else
  {
    if (topo1 == PWtopopos_stop)
      adjed1 = pwGetNextEdNoDegen (ed1, os, uvtol);
    else if (topo1 == PWtopopos_start)
      adjed1 = pwGetPrevEdNoDegen (ed1, os, uvtol);

    if (topo2 == PWtopopos_stop)
      adjed2 = pwGetNextEdNoDegen (ed2, os, uvtol);
    else if (topo2 == PWtopopos_start)
      adjed2 = pwGetPrevEdNoDegen (ed2, os, uvtol);

    if (adjed1 != ed2 || adjed2 != ed1)
    {
      if (adjed1 == ed2)
        retid = ed2;
      else if (adjed2 == ed1)
        retid = ed1;
    }
    else
    {
      double dist;
      struct PWcvpt edpt;
      struct PWid edid;

      edid.objid = ed1; edid.osnum = os;

      PWsts = pwEdPtProject (&edid, 1, (PWpoint2d *) midpt, uvtol, &edpt);
      OnErrorState (IsError (PWsts), PWsts, SetError (PW_K_Trimming, 
                    PW_K_Internal), wrapup);

      if (pwGetDoubleAttrib (edpt.p_attrib, PW_AttribIdent (PW_K_Pathway,
                             PW_K_DistanceAttr, NULL), &dist))
      {
        if (dist < 2 * uvtol)
          retid = ed1;
        else 
          retid = ed2;
      }
      else
        OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_Internal), 
                      wrapup);
    }
  }

wrapup :
  PW_WrapupIdId (PWsts, "pwGetInterveningEdge", ed1, ed2);
  return (retid);
}

end implementation Root;
