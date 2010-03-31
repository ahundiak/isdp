
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
  
#include "PWapi/uvfaces.h"
#include "PWapi/sflp.h"
#include "PWapi/lped.h"
#include "PWapi/eded.h"
#include "PWapi/edprops.h"
#include "PWapi/lpprops.h"
#include "PWapi/mx.h"
#include "PWapi/sfuptrav.h"
#include "PWapi/edgeom.h"
#include "PWapi/gmdatamem.h"
#include "PWapi/partol.h"
#include "PWapi/sfgeom.h"
#include "PWapi/dbglevel.h"

/* Static Functions */

/*
  ABSTRACT

  Returns the parametric-space faces on an EMS surface.

  DESCRIPTION

  Given the surface it returns the faces in the parametric-space by considering
  each disjointed area as a face. 

  ARGUMENTS

  sfobj           -  I :  Surfae object 
  os              -  I :  Osnum in which the surface is present
 
  num_faces       -  O :  Number of faces on the surface
  num_loops_face  -  O :  Number of loops per face
  num_edges_loop  -  O :  Number of edges per loop
  face_loops      -  O :  Geometry of the each loop 

  NOTES

  One thing worth noting here, the parametric-space curves are oriented such 
  that the right of it always it points to area. So, if the caller is following
  a different convention it is his responsibility to reverse the curves or keep
  a flag "reversed".

  All the memory for the output is allocated by this routine. One should call
  "pwFreeGeomloop" to free the allocated geometry.
 
  HISTORY

  Sanjay     10/18/95       Creation
*/

PWresult pwGetSfFaceLoopsUv
(
  PWobjid sfobj,
  PWosnum os,

  double xyztol,

  int *num_faces,
  int **num_loops_face,
  int ***num_edges_loop,
  struct PWgeomloop **face_loops
)
{
  PWresult PWsts=PW_K_Success;

  int num_holes=0, num_loops=0, loop=0, face=0, edge=0, num_edges=0;
  int fcinx=0, lpinx=0, loc_num_faces=0;
  PWobjid *p_faces=NULL, *p_holes=NULL, *p_edges=NULL;
  PWobjid loopobj=PW_K_NullObjid;

  PWmatrix idmx;
  short mattyp=2; 
  double uvtol=0;
  struct IGRbsp_surface *p_sfgeom=NULL;

  
  struct PWgeomloop *p_loop=NULL;

  /*
   * Initialize the output 
   */
  *num_faces = 0;
  *num_loops_face = NULL;
  *num_edges_loop = NULL;
  *face_loops = NULL;

  /*
   * get all the faces of the surface.
   */
  loc_num_faces = pwNumFacesOfSf (sfobj, os);
  OnErrorState (!loc_num_faces, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                wrapup);

  p_faces = (PWobjid *) alloca ((loc_num_faces) * sizeof (PWobjid));  
  OnErrorState (!p_faces, PWsts, SetError (PW_K_Pathway, PW_K_DynamicMemory),
                 wrapup);

  loc_num_faces = pwFacesOfSf (sfobj, os, p_faces);
  OnErrorState (!loc_num_faces, PWsts, SetError (PW_K_Pathway, PW_K_InvalidArg),
                wrapup);

  /*
   * Get the parametric tolerance.
   */
  PWsts = PW_GetSfBspsfStack (sfobj, os, mattyp, pwIdMx (idmx), p_sfgeom);
  OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);

  uvtol = pwGetParTolSf (p_sfgeom, xyztol);

  /*
   * Allcoate the memory for the output.
   */
  (*num_loops_face) = (int *) malloc ((loc_num_faces) * sizeof (int));
  OnErrorState (!(*num_loops_face), PWsts, SetError (PW_K_Pathway, 
                PW_K_DynamicMemory), wrapup);

  (*num_edges_loop) = (int **) malloc ((loc_num_faces) * sizeof (int *));
  OnErrorState (!(*num_edges_loop), PWsts, SetError (PW_K_Pathway,
                PW_K_DynamicMemory), wrapup);

  for (face=0, fcinx=0; face<loc_num_faces; face++)
  {
    num_holes = pwNumHolesOfFace (p_faces[face], os);

    if (num_holes)      
    {
      p_holes = NULL;

      p_holes = (PWobjid *) alloca (num_holes * sizeof (PWobjid));
      OnErrorState (!p_holes, PWsts, SetError (PW_K_Pathway,
                    PW_K_DynamicMemory), wrapup);

      num_holes = pwHolesOfFace (p_faces[face], os, p_holes);
    }

    num_loops = num_holes + 1;
    (*num_loops_face)[fcinx] = 0;
    (*num_edges_loop)[fcinx] = (int *) malloc (num_loops * sizeof (int));
    OnErrorState (!(*num_edges_loop)[fcinx], PWsts, SetError (PW_K_Pathway,
                  PW_K_DynamicMemory), wrapup);

    for (loop=0, lpinx=0; loop<num_loops; loop++)
    {
      if (loop)
        loopobj = p_holes[loop-1];
      else
        loopobj = p_faces[face];

      num_edges = pwNumEdsOfLp (loopobj, os);
      p_edges = (PWobjid *) alloca (num_edges * sizeof (PWobjid));
      num_edges = pwEdsOfLp (loopobj, os, p_edges);
     
      (*num_edges_loop)[fcinx][lpinx] = 0;

      for (edge=0; edge<num_edges; edge++)
      {
 	if (!pwIsEdDegenTol (p_edges[edge], os, uvtol))
        {
          (*num_edges_loop)[fcinx][lpinx] ++;

          p_loop = pwCreateGeomloop (face_loops);
          OnErrorState (!p_loop, PWsts, SetError (PW_K_Pathway, 
                        PW_K_DynamicMemory), wrapup);
  
          PWsts = PW_GetEdGeomHeap (p_edges[edge], os, p_loop->edge);
          OnErrorState (IsError (PWsts), PWsts, PWsts, wrapup);
  
          p_loop->free_edge = NULL;
        }
      }

      if((*num_edges_loop)[fcinx][lpinx])
      {
        (*num_loops_face)[fcinx] ++;
        lpinx ++;
      }
    }

    if((*num_loops_face)[fcinx])
    {
      (*num_faces) ++;
      fcinx ++;
    }
    else
    {
      free ((*num_edges_loop)[fcinx]);
    }
  }

  if (loc_num_faces != *num_faces)
  {
    if (*num_faces)
    {
      (*num_loops_face) = (int *) realloc ((*num_loops_face), 
                                           (*num_faces) * sizeof (int));
      OnErrorState (!(*num_loops_face), PWsts, SetError (PW_K_Pathway, 
                    PW_K_DynamicMemory), wrapup);

      (*num_edges_loop) = (int **) realloc ((*num_edges_loop),
                                            (*num_faces) * sizeof (int *));
      OnErrorState (!(*num_edges_loop), PWsts, SetError (PW_K_Pathway,
                    PW_K_DynamicMemory), wrapup);
      
    }
    else
    {
      free (*num_loops_face);
      free (*num_edges_loop);
    }
  }

wrapup :

  PW_Wrapup (PWsts, "pwGetSfFaceLoopsUv");
  return PWsts; 
}
