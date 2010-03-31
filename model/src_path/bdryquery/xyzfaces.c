
/* Includes */

#include <stdio.h>
#include <math.h>
#include <memory.h>               /* System */
#include <malloc.h>
#include "alloca.h"

#include "bs.h"                  
#include "bsparameters.h"
#include "bsgeom_cvsf.h"          /* BS */
#include "bsvalues.h"

#include "PWminimum.h"            /* Pathway */
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

/* Prototyeps */
  
#include "PWapi/xyzfaces.h"
#include "PWapi/sflp.h"
#include "PWapi/lped.h"
#include "PWapi/eded.h"
#include "PWapi/edprops.h"
#include "PWapi/lpprops.h"
#include "PWapi/mx.h"
#include "PWapi/edbcxyzgeom.h"
#include "PWapi/sfuptrav.h"
#include "PWapi/sfgeom.h"
#include "PWapi/edgeom.h"

/* Static Functions */

static PWresult pwGetSfFaceLoops
(
  PWobjid sfobj,
  PWosnum os,
  PWboolean needXyz,
  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops
);

static PWobjid get_start_edge
(
  int num_loops,
  int *p_num_edges,
  PWobjid **p_edges,
  PWboolean *p_loops_visited,
  PWboolean **p_edges_visited
);

static void update_visit
(
  PWobjid edge,
  int num_loops,
  int *p_num_edges,
  PWobjid **p_edges,
  PWboolean *p_loops_visited,
  PWboolean **p_edges_visited
);

static PWboolean is_edge_visited
(
  PWobjid edge,
  int num_loops,
  int *p_num_edges,
  PWobjid **p_edges,
  PWboolean **p_edges_visited
);

static PWboolean is_loop_visited
(
  PWobjid loop,
  int num_loops,
  int *p_num_edges,
  PWobjid *p_loops,
  PWboolean *p_loops_visited,
  PWboolean **p_edges_visited
);


/*
  ABSTRACT

  Returns the model-space faces on an EMS surface.

  DESCRIPTION

  Given the surface it returns the faces in the model-space i.e. edges in the
  model-space by killing all the redundant parametric edges i.e. seams on 
  the surface. 

  ARGUMENTS

  sfobj           -  I :  Surfae object 
  os              -  I :  Osnum in which the surface is present
 
  num_faces       -  O :  Number of faces on the surface
  num_loops_face  -  O :  Number of loops per face
  num_edges_loop  -  O :  Number of edges per loop
  face_loops_xyz  -  O :  Geometry of the each XYZ face loop 

  NOTES

  This function is useful when EMS is exposed to the outside world, as most of
  the systems today represent the loops in the model-space where as EMS repre-
  sents them in the parametric space of the surface. 

  One thing worth noting here, the model-space curves are oriented such that 
  the right of it always it points to area. So, if the caller is following a 
  different convention it is his responsibility to reverse the curves or keep
  a flag "reversed".

  All the memory for the output is allocated by this routine. One should call
  "pwFreeGeomloop" to free the allocated geometry.

  HISTORY

  Sanjay     10/18/95       Creation

*/

PWresult pwGetSfFaceLoopsXyz
(
  PWobjid sfobj,
  PWosnum os,
  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops_xyz
)
{
  PWboolean needXyz = TRUE;

  return pwGetSfFaceLoops (sfobj, os, needXyz, num_faces, num_loops_face, num_edges_loop,
                           face_loops_xyz);
}


/*
  ABSTRACT

  Returns the UV curves of faces on an EMS surface.

  DESCRIPTION

  Given the surface it returns the UV curves of faces by killing 
  all the redundant parametric edges i.e. seams on the surface. 

  ARGUMENTS

  sfobj           -  I :  Surfae object 
  os              -  I :  Osnum in which the surface is present
 
  num_faces       -  O :  Number of faces on the surface
  num_loops_face  -  O :  Number of loops per face
  num_edges_loop  -  O :  Number of edges per loop
  face_loops_uv   -  O :  Geometry of the UV curves of each face loop 

  NOTES

  One thing worth noting here, the UV curves are oriented such that 
  the right of it always it points to area. So, if the caller is following a 
  different convention it is his responsibility to reverse the curves or keep
  a flag "reversed".

  All the memory for the output is allocated by this routine. One should call
  "pwFreeGeomloop" to free the allocated geometry.

  The UV curves in the face loop, after killing the seams may not be
  forming a closed loop.
 
  HISTORY

  Sanjay     10/18/95       Creation

*/

PWresult pwGetUvCvsOfSfFaceLoopsXyz
(
  PWobjid sfobj,
  PWosnum os,
  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops_uv
)
{
  PWboolean needXyz = FALSE;

  return pwGetSfFaceLoops (sfobj, os, needXyz, num_faces, num_loops_face, num_edges_loop,
                           face_loops_uv);
}

/*
  ABSTRACT

  Returns the model-space faces or their corresponding UV curves
  on an EMS surface.

  DESCRIPTION

  Given the surface it returns the faces in the model-space i.e. edges in the
  model-space or their corresponding UV curves, by killing all the redundant 
  parametric edges i.e. seams on the surface. 

  ARGUMENTS

  sfobj           -  I :  Surfae object 
  os              -  I :  Osnum in which the surface is present
  needXyz         -  I :  Whether XYZ face curves or their corresponding
                          UV curves are needed.
 
  num_faces       -  O :  Number of faces on the surface
  num_loops_face  -  O :  Number of loops per face
  num_edges_loop  -  O :  Number of edges per loop
  face_loops      -  O :  Geometry of the each loop 

  NOTES

  This function is useful when EMS is exposed to the outside world, as most of
  the systems today represent the loops in the model-space where as EMS repre-
  sents them in the parametric space of the surface. 

  One thing worth noting here, the model-space curves are oriented such that 
  the right of it always it points to area. So, if the caller is following a 
  different convention it is his responsibility to reverse the curves or keep
  a flag "reversed".

  All the memory for the output is allocated by this routine. One should call
  "pwFreeGeomloop" to free the allocated geometry.

  The XYZ loops are closed, but their UV counterparts may not be!!
 
  HISTORY

  Sanjay     10/18/95       Creation

*/

static PWresult pwGetSfFaceLoops
(
  PWobjid sfobj,
  PWosnum os,
  PWboolean needXyz,
  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops
)
{
  PWresult PWsts=PW_K_Success;

  int lp=0, pt=0, *p_num_edges=NULL, num_loops=0, num_visited=0, tot_edges=0;
  PWobjid *p_loops=NULL, **p_edges=NULL;
  PWboolean *p_loops_visited=NULL, **p_edges_visited=NULL, loop_closed=FALSE;
  PWobjid edobj=PW_K_NullObjid, cmedobj=PW_K_NullObjid, lpobj=PW_K_NullObjid;
  PWobjid start_edobj=PW_K_NullObjid;
  PWboolean is_already_visited=FALSE;

  int bufsize=5, face_bufsize=5, *p_loop_bufsize=0, knt=0, loop=0, face=0;
  PWboolean is_created=FALSE;
  struct PWgeomloop *p_loop=NULL; 
  struct IGRbsp_curve *p_xyzed=NULL;
  struct PWsfdata sfdata;

  short mattyp=2;
  PWmatrix idmx;

  /*
   * Initialize the output.
   */
  *num_faces = 0;
  *num_loops_face = 0; 
  *num_edges_loop = 0;
  *face_loops = NULL;

  /*
   * Get the all the loops and edges on the surface and initialize the 
   * visited bits of the edges.
   */
  num_loops = pwNumLpsOfSf (sfobj, os);
  OnErrorState (!num_loops, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                wrapup);

  p_loops = (PWobjid *) alloca (num_loops * sizeof (PWobjid));
  OnErrorState (!p_loops, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                wrapup);

  num_loops = pwLpsOfSf (sfobj, os, p_loops);
  OnErrorState (!num_loops, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                wrapup);

  p_num_edges = (int *) alloca (num_loops * sizeof (int));
  p_edges = (PWobjid **) alloca (num_loops * sizeof (PWobjid *));
  p_loops_visited = (PWboolean *) alloca (num_loops * sizeof (PWboolean));
  p_edges_visited = (PWboolean **) alloca (num_loops * sizeof (PWboolean *));
  OnErrorState (!p_num_edges || !p_edges || !p_loops_visited || 
                !p_edges_visited, PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  memset (p_loops_visited, 0, num_loops * sizeof (PWboolean));
  tot_edges = 0;

  for (lp=0; lp<num_loops; lp++)
  {
    p_num_edges[lp] = pwNumEdsOfLp (p_loops[lp], os);
 
    p_edges[lp] = (PWobjid *) alloca (p_num_edges[lp] * sizeof (PWobjid));
    OnErrorState (!p_num_edges[lp], PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);

    p_num_edges[lp] = pwEdsOfLp (p_loops[lp], os, p_edges[lp]);
    tot_edges += p_num_edges[lp];

    p_edges_visited[lp] = (PWboolean *) alloca (p_num_edges[lp] * 
                                            sizeof (PWboolean));
    OnErrorState (!p_edges_visited[lp], PWsts, SetError (PW_K_Pathway,
                  PW_K_DynamicMemory), wrapup);

    memset (&p_edges_visited[lp][0], 0, p_num_edges[lp] * sizeof (PWboolean));
  }

  /*
   * Get the surface geometry.
   */
  memset (&sfdata, 0, sizeof (struct PWsfdata));
  sfdata.datatype = PWsfdata_bspsf;

  PWsts = PW_GetSfBspsfStack (sfobj, os, mattyp, pwIdMx (idmx), 
                              sfdata.data.p_bspsf);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  
  /*
   * To start with, allocate some memory forthe number of loops and number of
   * edges per loop.
   */
  (*num_loops_face) = (int *) malloc (bufsize * sizeof (int));
  OnErrorState (!*num_loops_face, PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  (*num_edges_loop) = (int **) malloc (face_bufsize * sizeof (int *));
  OnErrorState (!*num_edges_loop, PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  p_loop_bufsize = (int *) malloc (face_bufsize * sizeof (int *));

  for (knt=0; knt<face_bufsize; knt++)
  {
    p_loop_bufsize [knt] = 5;

    (*num_edges_loop)[knt] = (int *) malloc (p_loop_bufsize[knt] * 
                                             sizeof (int));
    OnErrorState (!(*num_edges_loop)[knt], PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);

    memset ((*num_edges_loop)[knt], 0, p_loop_bufsize[knt] * sizeof (int));
  }

  (*num_loops_face)[0] = 0;

  /*
   * Till all the edges are visited of the surface, go on creating the loops.
   */
  num_visited = 0;
  face = loop = 0;

START_OVER:

  do 
  {
    /*
     * Get an edge which is not yet visited.
     */
    start_edobj = get_start_edge (num_loops, p_num_edges, p_edges, 
                                 p_loops_visited, p_edges_visited);
    edobj = start_edobj;

    if (edobj == PW_K_NullObjid)
      break;

    lpobj = pwGetLpOfEd (edobj, os);
    OnErrorState (lpobj == PW_K_NullObjid, PWsts, SetError (PW_K_Pathway,
                  PW_K_Internal), wrapup);

    if (!is_loop_visited (lpobj, num_loops, p_num_edges, p_loops, 
           p_loops_visited, p_edges_visited) && pwIsLpFace (lpobj, os))
    {
      /*
       * The loop of this edge is not yet visited and it is a face. So, most 
       * probably we may form a face out of this loop.
       */
      if (*num_faces)
      {
        if ((*num_loops_face) [(*num_faces) - 1])
          (*num_faces) ++;
      }
      else
        (*num_faces) ++;

      if ((*num_faces) >= bufsize) 
      {
        bufsize += 5;
        (*num_loops_face) = (int *) realloc ((*num_loops_face), bufsize * 
                                             sizeof (int));
        OnErrorState (!*num_loops_face, PWsts, SetError (PW_K_Pathway, 
                      PW_K_DynamicMemory), wrapup);

      }

      (*num_loops_face)[(*num_faces) - 1] = 0;
    }

    /*
     * Initialize all the local variables and also the face and loop indices.
     * If the allocated memory is insufficient allocate the memory.
     */
    loop_closed = FALSE;
    is_created = FALSE;
    face = (*num_faces) - 1;
    loop = (*num_loops_face)[face];

    if (face >= face_bufsize)
    {
      face_bufsize += 5;
 
      (*num_edges_loop) = (int **) realloc ((*num_edges_loop), 
                                            face_bufsize * sizeof (int *));
      OnErrorState (!*num_edges_loop, PWsts, SetError (PW_K_Pathway,
                    PW_K_DynamicMemory), wrapup);

      p_loop_bufsize = (int *) realloc (p_loop_bufsize, 
                                        face_bufsize * sizeof (int));

      for (knt=face; knt<face_bufsize; knt++)
      {
        p_loop_bufsize [knt] = 5; 

        (*num_edges_loop)[knt] = (int *) malloc (p_loop_bufsize[knt] * 
                                                 sizeof (int));
        OnErrorState (!(*num_edges_loop)[knt], PWsts, SetError (PW_K_Pathway,
                      PW_K_DynamicMemory), wrapup);

        memset ((*num_edges_loop)[knt], 0, p_loop_bufsize[knt] * sizeof (int));
      }
    }

    if (loop >= p_loop_bufsize[face])
    {
      p_loop_bufsize [face] += 5;

      (*num_edges_loop)[face] = (int *) realloc ((*num_edges_loop)[face], 
                                          p_loop_bufsize[face] * sizeof (int));
    }

    /*
     * Initialize the number of edges of this loop to be zero.
     */
    (*num_edges_loop)[face][loop] = 0;

    do
    {
      is_already_visited = is_edge_visited (edobj, num_loops, p_num_edges, 
                                            p_edges, p_edges_visited);
      if (!is_already_visited)
      {
        num_visited ++;
        update_visit (edobj, num_loops, p_num_edges, p_edges, p_loops_visited, 
                      p_edges_visited);
      }

      if (pwIsEdDegen (edobj, os))
      {
        /*
         * If we have visited this degenerate edge before, then
         * obviously we are in an infinite loop, without the loop
         * ever closing.
         */

        if(is_already_visited)
          goto START_OVER;

        edobj = pwGetNextEd (edobj, os); 
        continue;
      }

      if (pwIsEdSeam (edobj, os) && 
          ((cmedobj = pwGetCommonEd (edobj, os)) != PW_K_NullObjid) &&
          (pwGetSfOfEd (cmedobj, os) == sfobj))  
      {
        /*
         * Seam edge whose common edge is from the same surface.
         */

        if (!is_edge_visited (cmedobj, num_loops, p_num_edges, p_edges, 
                              p_edges_visited))
        {
          num_visited ++;
          update_visit (cmedobj, num_loops, p_num_edges, p_edges, 
                        p_loops_visited, p_edges_visited);
        }

        edobj = pwGetNextEd (cmedobj, os); 
      }
      else if (!is_already_visited)
      {
        /*
         * Non-seam edge OR seam edge without a common edge OR seam edge whose
         * common edge is not from the same surface.
         */
        is_created = TRUE;

        p_loop = pwCreateGeomloop (face_loops);
        OnErrorState (!p_loop, PWsts, SetError (PW_K_Pathway, 
                      PW_K_DynamicMemory), wrapup);

        if(needXyz)
        {
          p_xyzed = NULL;

          PWsts = pwGetEdbcXyzGeom (edobj, os, &sfdata, &p_xyzed);
          OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

          if (p_xyzed->order == 2 && !p_xyzed->non_uniform && 
              !p_xyzed->periodic && !p_xyzed->rational)
          {
            p_loop->edge.datatype = PWcvdata_py;
            p_loop->edge.data.py.p_pts = (PWpoint *)
                    malloc (p_xyzed->num_poles * sizeof (PWpoint));
            OnErrorState (!p_loop->edge.data.py.p_pts, PWsts, 
                          SetError (PW_K_Pathway, PW_K_DynamicMemory), wrapup);

            p_loop->edge.data.py.num_pts = p_xyzed->num_poles;
            for (pt=0; pt<p_xyzed->num_poles; pt++)
            {
              p_loop->edge.data.py.p_pts[pt][X] = p_xyzed->poles[pt*3+X]; 
              p_loop->edge.data.py.p_pts[pt][Y] = p_xyzed->poles[pt*3+Y]; 
              p_loop->edge.data.py.p_pts[pt][Z] = p_xyzed->poles[pt*3+Z]; 
            }

            free (p_xyzed);
            p_xyzed = NULL;
          }
          else
          {
            p_loop->edge.datatype = PWcvdata_bspcv;
            p_loop->edge.data.p_bspcv = p_xyzed;
            p_xyzed = NULL;
          }
        } 
        else
        {
          PWsts = pwGetEdGeom (edobj, os, &p_loop->edge);
          OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
        }

        if (pwIsEdClosedXYZ (edobj, os))
          loop_closed = TRUE;

        edobj = pwGetNextEd (edobj, os); 

        (*num_edges_loop) [face][loop] += 1;
      }
      else
      {
        loop_closed = TRUE;
      }

      if (edobj == start_edobj)
      {
        loop_closed = TRUE;
      }

    } while (!loop_closed);    

    if (is_created)
      (*num_loops_face)[face] += 1;

  } while (num_visited < tot_edges);


  if ((*num_loops_face)[0] == 0)
  {
    *num_faces = 0;
    free ((*num_loops_face));
  }
  else
  {
    (*num_loops_face) = (int *) realloc ((*num_loops_face), (*num_faces) * 
                                         sizeof (int));
    OnErrorState (!*num_loops_face, PWsts, SetError (PW_K_Pathway, 
                  PW_K_DynamicMemory), wrapup);
  }
 
wrapup :

  if (IsError (PWsts))
  {
    p_loop = *face_loops;
    while (p_loop)
    {
      if (p_loop->edge.datatype == PWcvdata_py)
        free (p_loop->edge.data.py.p_pts);
      else
        free (p_loop->edge.data.p_bspcv);

      p_loop = p_loop->p_next;
    }
  }

  PW_Wrapup (PWsts, "pwGetSfFaceLoopsXyz");
  return PWsts;
}


/* ------------------------ Static Functions Listing ------------------------ */


/*
  ABSTRACT

  Gets the non-visited edge found first in the edge list. If none found 
  returns NullObjid.

  NOTES

  None.
*/

static PWobjid get_start_edge
(
  int num_loops,
  int *p_num_edges,
  PWobjid **p_edges,
  PWboolean *p_loops_visited,
  PWboolean **p_edges_visited
)
{
  int lp=0, ed=0;

  for (lp=0; lp<num_loops; lp++)
  {
    if (!p_loops_visited[lp])
    {
      for (ed=0; ed<p_num_edges[lp]; ed++)
      {
        if (!p_edges_visited[lp][ed])
          return p_edges[lp][ed];
      }
    }
  }

  return PW_K_NullObjid;
}


/*
  ABSTRACT

  Updates the `visited` bit of an edge given the edge ID.

  NOTES

  None.
*/

static void update_visit
(
  PWobjid edge,
  int num_loops,
  int *p_num_edges,
  PWobjid **p_edges,
  PWboolean *p_loops_visited,
  PWboolean **p_edges_visited
)
{
  int lp=0, ed=0;

  for (lp=0; lp<num_loops; lp++)
  {
    if (!p_loops_visited[lp])
    {
      for (ed=0; ed<p_num_edges[lp]; ed++)
      {
        if (!p_edges_visited[lp][ed] && p_edges[lp][ed] == edge)
          p_edges_visited[lp][ed] = TRUE;
      }

      p_loops_visited[lp] = TRUE;

      for (ed=0; ed<p_num_edges[lp]; ed++)
      {
        if (!p_edges_visited[lp][ed])
        {
          p_loops_visited[lp] = FALSE;
          break;
        }
      }
    }
  }

  return;
}


/*
  ABSTRACT

  Returns TRUE if the edge is already visited once, otherwise FALSE given the
  edge ID.
 
  NOTES

  None.
*/

static PWboolean is_edge_visited
(
  PWobjid edge,
  int num_loops,
  int *p_num_edges,
  PWobjid **p_edges,
  PWboolean **p_edges_visited
)
{
  int lp=0, ed=0;

  for (lp=0; lp<num_loops; lp++)
  {
    for (ed=0; ed<p_num_edges[lp]; ed++)
    {
      if (p_edges[lp][ed] == edge)
        return  p_edges_visited[lp][ed];
    }
  }

  return TRUE;
}


/*
  ABSTRACT

  Returns TRUE if the loop is already visited once, otherwise FALSE given the
  loop ID.
 
  NOTES

  None.
*/

static PWboolean is_loop_visited 
(
  PWobjid loop,
  int num_loops,
  int *p_num_edges,
  PWobjid *p_loops,
  PWboolean *p_loops_visited,
  PWboolean **p_edges_visited
)
{
  int lp=0, ed=0;

  /*
   * Suppress the compiler warning.
   */
  p_loops_visited = p_loops_visited;

  for (lp=0; lp<num_loops; lp++)
  {
    if (p_loops[lp] == loop)
    {
      for (ed=0; ed<p_num_edges[lp]; ed++)
      {
        if (p_edges_visited[lp][ed])
          return TRUE;
      }
      return FALSE;
    }
  } 

  return TRUE;
}

/* ---------------------- End Of Static Functions Listing ------------------- */
