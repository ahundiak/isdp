/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/*
 * OVERVIEW
 *     This file consists of OMuse functions related to Surface-Loop 
 *     connections. These functions can fall under any of the following 
 *     category.
 *      a. Creation
 *      b. Query
 *      c. Manipulation
 *     These functions are also arranged in the same manner as above.
 *
 * NOTES
 *     The functions in this file aims at accessing the instance data 
 *     of the surface objects and manipulating the same.
 */

class implementation Root;

/* Includes */

#include <math.h>

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

#include "bs.h"
#include "bsgeom_cvsf.h"

#include "PWminimum.h"
#include "PWerror.h"

#include "alloca.h"

/* Prototypes */

#include "PWapi/sflp.h"
#include "PWapi/lpprops.h"

/* Externs */

extern OMuword OPP_EMSloopset_class_id;

/*
 * FUNCTION TYPES :  QUERY
 */

/*
 * Surface and Faces
 */

/* 
 * ABSTRACT :
 *   Number of outer faces (first level P-loops) of surface.
 */
int pwNumOuterFacesOfSf 
(
  PWobjid  sfobj,
  PWosnum  os
)
{
  /* status stuff */
  long   OMsts;

  /* loop index */
  int       ls=0;

  /* Number of loopsets and loops on the surface */
  unsigned int num_ls=0, num_lp=0, num=0;

  /* Channels declaration */
  OM_S_CHANSELECT  to_loopset, to_loops;

  /* Loopset Objects */
  OM_S_OBJECT_LINKAGE *p_loopset=NULL;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMmake_chanselect (EMSloopset_to_loops, &to_loops);

  /*
   * get the number of loopsets on the surface
   */
  OMsts = om$get_channel_count (objid = sfobj, osnum = os,
                                p_chanselect = &to_loopset, count = &num_ls);
  if (!(1&OMsts) || !num_ls)
    return (int) 0;

  p_loopset = (OM_S_OBJECT_LINKAGE *) alloca (num_ls *
                                            sizeof(OM_S_OBJECT_LINKAGE));
  if (!p_loopset)
    return (int) 0;

  OMsts = om$get_channel_objects (objid = sfobj, osnum = os,
                                  p_chanselect = &to_loopset, size = num_ls,
                                  list = p_loopset, count = &num);
  if (!(1&OMsts) || (num_ls != num)) 
    return (int) 0;

  /*
   * get the number of loops of each loopset and increment the number of
   * loops.
   */
  for (ls=0; ls<num_ls; ls++)
  {
    num = 0;

    OMsts = om$get_channel_count (objid = p_loopset[ls].S_objid,
                                  osnum = p_loopset[ls].osnum,
                                  p_chanselect = &to_loops,
                                  count = &num);
    if (!(1&OMsts))
      return num_lp;

    num_lp += num;
  }

  return num_lp;
}
  
int pwOuterFacesOfSf 
(
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_faceloops
)
{
  /* status stuff */
  long   OMsts;

  /* loop index */
  int       ls=0,lp=0;

  /* Number of loopsets and loops on the surface */
  unsigned int num_ls=0, num_lp=0, num=0, tnum=0;

  /* Channels declaration */
  OM_S_CHANSELECT  to_loopset, to_loops;

  /* Loopset Objects */
  OM_S_OBJECT_LINKAGE *p_loopset=NULL, *p_loops=NULL;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMmake_chanselect (EMSloopset_to_loops, &to_loops);

  /*
   * get the number of loopsets on the surface
   */
  OMsts = om$get_channel_count (objid = sfobj, osnum = os,
                                p_chanselect = &to_loopset, count = &num_ls);
  if (!(1&OMsts) || !num_ls)
    return (int) 0;

  p_loopset = (OM_S_OBJECT_LINKAGE *) alloca (num_ls *
                                              sizeof(OM_S_OBJECT_LINKAGE));
  if (!p_loopset)
    return (int) 0;

  OMsts = om$get_channel_objects (objid = sfobj, osnum = os,
                                  p_chanselect = &to_loopset, size = num_ls,
                                  list = p_loopset, count = &num);
  if (!(1&OMsts) || (num_ls != num))
    return (int) 0;

  /*
   * get the number of loops of each loopset and increment the number of
   * loops.
   */
  for (ls=0; ls<num_ls; ls++)
  {
    num = 0;

    OMsts = om$get_channel_count (objid = p_loopset[ls].S_objid,
                                  osnum = p_loopset[ls].osnum,
                                  p_chanselect = &to_loops,
                                  count = &num);
    if (!(1&OMsts))
      return num_lp;

    p_loops = (OM_S_OBJECT_LINKAGE *) alloca (num * sizeof(OM_S_OBJECT_LINKAGE));
    if (!p_loops)
      return (int) 0;

    OMsts = om$get_channel_objects (objid = p_loopset[ls].S_objid, 
                                    osnum = p_loopset[ls].osnum,
                                    p_chanselect = &to_loops,
                                    size = num, list = p_loops,
                                    count = &tnum);
    if (!(1&OMsts) || (num != tnum))
      return num_lp;

    for (lp=0; lp<num; lp++)
      p_faceloops[num_lp+lp] = p_loops[lp].S_objid;

    num_lp += num;
  }

  return num_lp;
}

int pwNumInnersOfLp
(
  PWobjid  loopobj, 
  PWosnum  os
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_inner;

  /* number of inner loops */
  unsigned int  num_inner=0, num_inner_lps=0, lp=0, tnum=0;

  /* Loop Objects */
  OM_S_OBJECT_LINKAGE *p_inner_lps=NULL;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  /*
   * get the number of inner loops on the given loop
   */
  OMsts = om$get_channel_count (objid = loopobj, osnum = os,
                                p_chanselect = &to_inner, count = &num_inner);
  if (!(1&OMsts) || !num_inner) 
    return (int) 0;

  /*
   * get all the inner loops and call this function recursively on all of them
   */
  p_inner_lps = (OM_S_OBJECT_LINKAGE *) alloca (num_inner *
                                               sizeof (OM_S_OBJECT_LINKAGE));
  if (!p_inner_lps)
    return (int) 0;

  OMsts = om$get_channel_objects (objid = loopobj, osnum = os,
                                  p_chanselect = &to_inner, size = num_inner,
                                  list = p_inner_lps, count = &tnum);
  if (!(1&OMsts) || (tnum != num_inner))
    return (int) 0;

  num_inner_lps = 0;
  for (lp=0; lp < num_inner; lp++)
    num_inner_lps += pwNumInnersOfLp (p_inner_lps[lp].S_objid, 
                                      p_inner_lps[lp].osnum);

  num_inner = num_inner + num_inner_lps;

  return num_inner;
}

int pwInnersOfLp
(
  PWobjid  loopobj, 
  PWosnum  os,
  PWobjid  *p_lps
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_inner;

  /* number of inner loops */
  unsigned int  num_inner=0, lp=0, num_inner_lps=0, tnum=0;

  /* Loop Objects */
  OM_S_OBJECT_LINKAGE *p_inner_lps=NULL;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  /*
   * get the number of inner loops on the given loop
   */
  OMsts = om$get_channel_count (objid = loopobj, osnum = os,
                                p_chanselect = &to_inner, count = &num_inner);
  if (!(1&OMsts) || !num_inner) 
    return (int) 0;

  /*
   * allocate the memory and get all the inner loops 
   */
  p_inner_lps = (OM_S_OBJECT_LINKAGE *) alloca (num_inner *
                                                 sizeof (OM_S_OBJECT_LINKAGE));
  if (!p_inner_lps)
    return (int) 0;

  OMsts = om$get_channel_objects (objid = loopobj, osnum = os,
                                  p_chanselect = &to_inner, size = num_inner,
                                  list = p_inner_lps, count = &tnum);
  if (!(1&OMsts) || (tnum != num_inner))
    return (int) 0;

  /*
   * Call recursively this function on each inner loop 
   */
  num_inner_lps = 0;

  for (lp=0; lp < num_inner; lp++)
  {
    p_lps[num_inner_lps++] = p_inner_lps[lp].S_objid;

    num_inner_lps += pwInnersOfLp (p_inner_lps[lp].S_objid, 
                                   p_inner_lps[lp].osnum, 
                                   &p_lps[num_inner_lps]);
  }

  return num_inner_lps;
}

PWobjid  pwOutterOfLp
(
  PWobjid  loopobj,
  PWosnum  os
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_outter;

  /* number of outter loops */
  unsigned int  num_outter=0;

  /* Loop Objects */
  OM_S_OBJECT_LINKAGE outter_lp;
  
  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_outter, &to_outter);

  OMsts = om$get_channel_count (objid = loopobj, osnum = os,
                                p_chanselect = &to_outter, count = &num_outter);
  if (!(1&OMsts) || !num_outter)
    return PW_K_NullObjid;

  /*
   * Now get the outter loop 
   */
  OMsts = om$get_channel_objects (objid = loopobj, osnum = os,
                                  p_chanselect = &to_outter, size = 1,
                                  list = &outter_lp, count = &num_outter);
  if (!(1&OMsts) || (num_outter != 1))
    return PW_K_NullObjid;

  return outter_lp.S_objid;
}

int pwNumLpsOfSf 
(
  PWobjid  sfobj,
  PWosnum  os
)
{
  /* number of outer faces and inner loops of each loop */
  int  num_outer_faces=0, num_inner_lps=0, num_lps=0;

  /* loop variables */
  int  face=0;

  /* outer faces */
  PWobjid  *p_faces=NULL;

  /* 
   * get the number of outer faces of the surface 
   */
  num_outer_faces = pwNumOuterFacesOfSf (sfobj, os);

  /*
   * allocate the memory for the faces and get the faces 
   */
  p_faces = (PWobjid *) alloca (num_outer_faces * sizeof(PWobjid));
  if (!p_faces)
    return (int) 0;

  num_outer_faces = pwOuterFacesOfSf (sfobj, os, p_faces);

  /*
   * get number of inner loops of each face
   */
  num_inner_lps = 0;
  for (face=0; face<num_outer_faces; face++)
    num_inner_lps += pwNumInnersOfLp (p_faces [face], os);

  num_lps = num_outer_faces + num_inner_lps;

  return num_lps;
}

int pwLpsOfSf
(
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_loops
)
{

  /* number of outer faces and inner loops of each loop */
  int  num_outer_faces=0, num_inner_lps=0, num_lps=0;

  /* loop variables */
  int  face=0;

  /* outer faces */
  PWobjid  *p_faces=NULL;

  /*
   * get the number of outer faces of the surface
   */
  num_outer_faces = pwNumOuterFacesOfSf (sfobj, os);

  /*
   * allocate the memory for the faces and get the faces
   */
  p_faces = (PWobjid *) alloca (num_outer_faces * sizeof(PWobjid));
  if (!p_faces)
    return (int) 0;

  num_outer_faces = pwOuterFacesOfSf (sfobj, os, p_faces);

  /*
   * get number of inner loops of each face
   */
  num_inner_lps = 0;

  for (face=0; face<num_outer_faces; face++)
  {
    p_loops [num_inner_lps ++] = p_faces[face]; 
    num_inner_lps += pwInnersOfLp (p_faces [face], os, 
                                   &p_loops[num_inner_lps]);
  }

  num_lps = num_inner_lps;

  return num_lps;
}


int pwNumFacesOfSf 
(
  PWobjid  sfobj,
  PWosnum  os
)
{
  /* loop variables */
  int   lp=0;

  /* Number of loops and faces */
  int   num_lps=0, num_faces=0;

  /* loop object ids */
  PWobjid  *p_lps=NULL;

  /* 
   * get the number of loops on this surface 
   */
  num_lps = pwNumLpsOfSf (sfobj, os);

  /*
   * allocate the memory and get all the loops
   */
  p_lps = (PWobjid *) alloca (num_lps * sizeof(PWobjid));
  if (!p_lps)
    return (int) 0;

  num_lps = pwLpsOfSf (sfobj, os, p_lps);

  /*
   * traverse through the loop tree and count the number of Ploops
   */
  num_faces = 0;
  for (lp=0; lp < num_lps; lp++)
    if (pwIsLpFace (p_lps[lp], os))
      num_faces ++;

  return num_faces;
}

int pwFacesOfSf 
(
  PWobjid  sfobj,
  PWosnum  os,
  PWobjid  *p_faceloops
)
{
  /* loop variables */
  int   lp=0;

  /* Number of loops and faces */
  int   num_lps=0, num_faces=0;

  /* loop object ids */
  PWobjid  *p_lps=NULL;

  /* 
   * get the number of loops on this surface 
   */
  num_lps = pwNumLpsOfSf (sfobj, os);

  /*
   * allocate the memory and get all the loops
   */
  p_lps = (PWobjid *) alloca (num_lps * sizeof(PWobjid));
  if (!p_lps)
    return (int) 0;

  num_lps = pwLpsOfSf (sfobj, os, p_lps);

  /*
   * traverse through the loop tree and count the number of Ploops
   */
  num_faces = 0;
  for (lp=0; lp < num_lps; lp++)
  {
    if (pwIsLpFace (p_lps[lp], os))
    {
      p_faceloops[num_faces] = p_lps[lp];
      num_faces ++;
    }
  }

  return num_faces;
}

PWobjid pwFaceAtInxOfSf 
(
  PWobjid  sfobj,
  PWosnum  os,
  unsigned int index
)
{
  int      num_faces=0;
  PWobjid  *p_faces=NULL;

  /*
   * get the number of faces of the surface
   */
  num_faces = pwNumFacesOfSf (sfobj, os);
  if (num_faces < 1 || !num_faces || index > (num_faces - 1))
    return PW_K_NullObjid;

  /* 
   * allocate the memory for the face IDs and get the IDs of the faces
   */
  p_faces = (PWobjid *) alloca (num_faces * sizeof(PWobjid));
  if (!p_faces)
    return PW_K_NullObjid;

  num_faces = pwFacesOfSf (sfobj, os, p_faces);
  if (index > (num_faces - 1))
    return PW_K_NullObjid;

  /*
   * return the face at the specified index.
   */
  return p_faces[index];
}

PWobjid pwOuterFaceAtInxOfSf
(
  PWobjid  sfobj,
  PWosnum  os,
  int      index
)
{
  /* status stuff */
  long   OMsts;

  unsigned int num=0;

  /* Channels declaration */
  OM_S_CHANSELECT  to_loopset, to_loops;

  /* Loopset and Loop Objects */
  OM_S_OBJECT_LINKAGE loopset; 
  PWobjid loop=PW_K_NullObjid;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSsubbs_to_loopset, &to_loopset);
  EMmake_chanselect (EMSloopset_to_loops, &to_loops);

  /*
   * get the loopset on this surface
   */
  OMsts = om$get_channel_objects (objid = sfobj, osnum = os,
                                  p_chanselect = &to_loopset, size = 1,
                                  list = &loopset, count = &num);
  if (!(1&OMsts))
    return (PWobjid) PW_K_NullObjid;

  /*
   * get the number of loops of each loopset and increment the number of
   * loops.
   */
  OMsts = om$get_objid_at_index (objid = loopset.S_objid, osnum = os,
                                 index = index, p_chanselect = &to_loops, 
                                 objidaddr = &loop, osnumaddr = &os);
  if (!(1&OMsts))
    return (PWobjid) PW_K_NullObjid;

  return loop;
}

PWobjid pwLpAtInxOfSf
(
  PWobjid  sfobj,
  PWosnum  os,
  int      index
)
{
  /* number of loops and loop IDs */
  int      num_lps=0;
  PWobjid  *p_lps=NULL;
 
  /*
   * get the number of loops of the surface.
   */
  num_lps = pwNumLpsOfSf (sfobj, os);
  if (num_lps < 0 || !num_lps || index > (num_lps - 1))
    return PW_K_NullObjid;

  /*
   * allocate the memory for the loops and get the loop IDs
   */
  p_lps = (PWobjid *) alloca (num_lps * sizeof(PWobjid));
  if (!p_lps)
    return PW_K_NullObjid;

  num_lps = pwLpsOfSf (sfobj, os, p_lps);
  if (index > (num_lps - 1))
    return PW_K_NullObjid;

  /*
   * return the loop at the given index.
   */
  return p_lps [index-1]; 
}


int pwNumHolesOfFace 
(
  PWobjid  faceloop, 
  PWosnum  os
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_inner;

  /* number of inner loops */
  unsigned int  num_inner=0;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  /*
   * get the number of inner loops on the given loop
   */
  OMsts = om$get_channel_count (objid = faceloop, osnum = os,
                                p_chanselect = &to_inner, count = &num_inner);
  if (!(1&OMsts) || !num_inner)
    return (int) 0;

  return num_inner;
}

int pwHolesOfFace 
(
  PWobjid  faceloop, 
  PWosnum  os,
  PWobjid  *p_holeloops
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_inner;

  /* number of inner loops */
  unsigned int  num_inner=0, lp=0, tnum=0;

  /* Loop Objects */
  OM_S_OBJECT_LINKAGE *p_inner_lps=NULL;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  /*
   * get the number of inner loops on the given loop
   */
  OMsts = om$get_channel_count (objid = faceloop, osnum = os,
                                p_chanselect = &to_inner, count = &num_inner);
  if (!(1&OMsts) || !num_inner)
    return (int) 0;

  /*
   * allocate the memory and get all the inner loops
   */
  p_inner_lps = (OM_S_OBJECT_LINKAGE *) alloca (num_inner *
                                                 sizeof (OM_S_OBJECT_LINKAGE));
  if (!p_inner_lps)
    return (int) 0;

  OMsts = om$get_channel_objects (objid = faceloop, osnum = os,
                                  p_chanselect = &to_inner, size = num_inner,
                                  list = p_inner_lps, count = &tnum);
  if (!(1&OMsts) || (tnum != num_inner))
    return (int) 0;

  for (lp=0; lp<num_inner; lp++)
    p_holeloops[lp] = p_inner_lps[lp].S_objid;

  return num_inner;
}

int pwNumInnerFacesOfHole 
(
  PWobjid  holeloop, 
  PWosnum  os
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_inner;

  /* number of inner loops */
  unsigned int  num_inner=0;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  /*
   * get the number of inner loops on the given loop
   */
  OMsts = om$get_channel_count (objid = holeloop, osnum = os,
                                p_chanselect = &to_inner, count = &num_inner);
  if (!(1&OMsts) || !num_inner)
    return (int) 0;

  return num_inner;
}
  
int pwInnerFacesOfHole 
(
  PWobjid  holeloop, 
  PWosnum  os,
  PWobjid  *p_faceloops
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_inner;

  /* number of inner loops */
  unsigned int  num_inner=0, lp=0, tnum=0;

  /* Loop Objects */
  OM_S_OBJECT_LINKAGE *p_inner_lps=NULL;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  /*
   * get the number of inner loops on the given loop
   */
  OMsts = om$get_channel_count (objid = holeloop, osnum = os,
                                p_chanselect = &to_inner, count = &num_inner);
  if (!(1&OMsts) || !num_inner)
    return (int) 0;

  /*
   * allocate the memory and get all the inner loops
   */
  p_inner_lps = (OM_S_OBJECT_LINKAGE *) alloca (num_inner *
                                                 sizeof (OM_S_OBJECT_LINKAGE));
  if (!p_inner_lps)
    return (int) 0;

  OMsts = om$get_channel_objects (objid = holeloop, osnum = os,
                                  p_chanselect = &to_inner, size = num_inner,
                                  list = p_inner_lps, count = &tnum);
  if (!(1&OMsts) || (tnum != num_inner))
    return (int) 0;

  for (lp=0; lp<num_inner; lp++)
    p_faceloops[lp] = p_inner_lps[lp].S_objid;

  return num_inner;
}

PWobjid pwHoleAtInxOfFace
(
  PWobjid  faceloop,
  PWosnum  os, 
  int      index
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_inner;

  /* Loop Objects */
  PWobjid inner_lp;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  /*
   * get the number of loops of each loopset and increment the number of
   * loops.
   */
  OMsts = om$get_objid_at_index (objid = faceloop, osnum = os,
                                 index = index, p_chanselect = &to_inner,
                                 objidaddr = &inner_lp, osnumaddr = &os);
  if (!(1&OMsts))
    return (PWobjid) PW_K_NullObjid;

  return inner_lp;
}

PWobjid pwInnerFaceAtInxOfHole
(
  PWobjid  holeloop,
  PWosnum  os, 
  int      index
)
{
  /* status  stuff */
  long  OMsts=OM_S_SUCCESS;

  /* Channels declaration */
  OM_S_CHANSELECT  to_inner;

  /* Loop Objects */
  PWobjid inner_lp;

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloop_to_inner, &to_inner);

  /*
   * get the number of loops of each loopset and increment the number of
   * loops.
   */
  OMsts = om$get_objid_at_index (objid = holeloop, osnum = os,
                                 index = index, p_chanselect = &to_inner,
                                 objidaddr = &inner_lp, osnumaddr = &os);
  if (!(1&OMsts))
    return (PWobjid) PW_K_NullObjid;

  return inner_lp;
}

PWobjid pwSfOfLp 
(
  PWobjid  loopobj,
  PWosnum  os
)
{

  /* status stuff */
  long  OMsts=OM_S_SUCCESS;

  /* outer loops id and its classid */
  PWobjid      outter_loop;
  OMuword      classid;
  unsigned int count;

  /* Channels declaration */
  OM_S_CHANSELECT  to_surface;

  /* surface id */
  OM_S_OBJECT_LINKAGE     srf;

  do
  {
    /*
     * get the Outer loop of this loop if any.
     */
    outter_loop = pwOutterOfLp (loopobj, os);
    if (outter_loop == PW_K_NullObjid)
      return (PWobjid) PW_K_NullObjid;

    /*
     * get the outer loop classid, check whether it is a loopset, if so break
     * the loop. 
     */
    om$get_classid (objid = outter_loop, osnum = os, p_classid = &classid);
    
    loopobj = outter_loop;

  } while (om$is_ancestry_valid (subclassid = classid,
              superclassid = OPP_EMSloopset_class_id) != OM_S_SUCCESS); 

  /*
   * Get the channels addresses
   */
  EMmake_chanselect (EMSloopset_to_surface, &to_surface);

  /*
   * get the surface on this channel
   */
  OMsts = om$get_channel_objects(objid = outter_loop, osnum = os,
                                 p_chanselect=&to_surface, list = &srf,
                                 size = 1, count = &count);
  if (!(1&OMsts))
    return (PWobjid) PW_K_NullObjid;
  else
    return (srf.S_objid); 
}

end implementation Root;
