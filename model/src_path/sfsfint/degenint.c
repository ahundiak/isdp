/* Includes */

#include <stdio.h>
#include <math.h>
#include <alloca.h>
#include <bsvalues.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWgmint.h"

#include "OMminimum.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "msdef.h"
#include "ma.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"

/* Prototypes */
#include "maidmx.h"
#include "bssfeval.h"


#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "igrdp.h"
#include "go.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emssfint.h"

#include "EMSpwapi.h"

#include "PWapi/eded.h"
#include "PWapi/lped.h"
#include "PWapi/sflp.h"
#include "PWapi/sfgeom.h"

#include "PWapi/mdstptgm.h"

/*---------------------------------------------------------------------------*/
/*                             API Definition                                */
/*---------------------------------------------------------------------------*/

/*
  ABSTRACT
     Determines the orientation of degenerate intobjs which were produced 
     by the trimming operation while trimming the raw intersection curve.
  
  DESCRIPTION
     Given an 'inters-list' this function processes all the 'intobj' in the 
     'inters-list' taking one 'intobj' at a time. 
  
     This function should be called only after orienting all the non-degenerate
     'intobjs' and deleting all the deletable intobjs. So when control comes
     to this function all the non-degenerate intobjs in the input 'inters-list'
     are oriented properly (intobj->reversed field properly set).

     This function processes only those 'intobjs' which are xyz or uv 
     degenerate. If the intobj is incident on two different edges at the
     start point and stop point then the orientation of this intobj is
     required in order to maintain topological continuity. Any one of the 
     incident edge id is taken here (say the start point incident edgeid)
     along with the corresponding ineteraction point (uv-point). Corresponding
     xyz point is calculated. Common edge corresponding to the incident edge
     is obtained. The 'inters-list' is scanned to obtain the intersections
     (intobjs) on the common edge surface. 

     Intersections on the common edge surface are scanned to find the 
     intersections which have the same interaction point as the degenerate
     'intobj' under investigation. If the number of intobjs found is one
     then the degenerate intobj is oriented depending on whether the 
     interaction point is the start point or stop point of the scanned 
     intersection curve. If the number of intersection curve on the common
     edge surface is more than one then there is no need for orienting the
     degenerate piece as it will form middle of a subgroup during tracing
     and tracing will take care of the orientation (depending upon the 
     previous and next intersection in the subgroup).

  ARGUMENTS
     
     p_inters        I/O  Inters list containing the intersections.
     xyztol          I    xyz tolerance. 

  RETURN CODE

     This function returs the following return values :

     PW_K_Success  - All went well
     PW_K_Internal - Any internal failure.

  KEYWORDS

  CAVEATS

  HISTORY
     Subhasish         Creation
*/
     
PWresult pwOrientDegenInt
(
  struct EMSinters  **p_inters,
  double            xyztol
)
{
  PWresult                retval;
  long                    rc;
  double                  uvpt1[2], uvpt2[2], xyzpt[3],
                          uvptint[2], xyzptint[3];
  struct IGRbsp_surface   *p_surf=NULL, *p_intsfgeom=NULL;
  PWboolean               edge1_found, edge2_found, degen_intobj_reversed,
                          degen_int_delete, startpt;
  struct EMSintobj        *p_intobj_loc=NULL, *p_intobj_tmp=NULL;
  struct EMSinters        *p_inters_loc=NULL, *p_inters_tmp=NULL;
  PWobjid                 sfobjid, intsfobjid, commEdid, commLpid, commSfid,
                          edgeid1, edgeid2, edgeid;
  PWosnum                 sfos, intsfos;
  double                  dist=0.0;
  unsigned short          mattyp;
  PWmatrix                mat;
  PWboolean               tmp_posorient=FALSE, posorient=FALSE, aflag=0;
  struct GRmd_env         rfenv;
 
  /*
   * Initialize
   */
  retval = PW_K_Success;

  if(aflag = pwIsActivationOn())
  {
    pwGetActiveModuleEnv(&rfenv);
    memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
    mattyp = rfenv.md_env.matrix_type;
  }
  else
  {
    mattyp = 2;
    MAidmx (&rc, mat);
    OnErrorState (rc!=MSSUCC, retval, 
                  SetError (PW_K_BspMath, PW_K_Internal), wrapup);
  }

  p_inters_loc = p_inters[0];
  while (p_inters_loc)
  {
    p_intobj_loc = p_inters_loc->cvs;
    while (p_intobj_loc)
    {
      /*
       * Initialize within the loop
       */
      edge1_found = FALSE;
      edge2_found = FALSE;
      degen_int_delete = FALSE;
      degen_intobj_reversed = FALSE;
      posorient = FALSE;
      tmp_posorient=FALSE;
      /*
       * Check whether this is a degenerate intobj
       */
      if (((p_intobj_loc->props & EMSintobj_uvdegenerate) ||
          (p_intobj_loc->props & EMSintobj_xyzdegenerate)) &&
           !(p_intobj_loc->props & EMSintobj_deletable)) 
      {
        sfobjid = p_intobj_loc->this_obj_node->this_obj.objid;
        sfos = p_intobj_loc->this_obj_node->this_obj.osnum;
        /*
         * Check if the end points of the intobj lies on two different edges
         * If this happens then we have to orient this intobj in order to 
         * maintain topological continuity.
         */
        if (p_intobj_loc->more_info)
        {
          edgeid1 = ((struct EMSsfintedpar *)p_intobj_loc->more_info)->edgeid;
          if (edgeid1 != PW_K_NullObjid)
          {
            uvpt1[0] =((struct EMSsfintedpar *)p_intobj_loc->more_info)
                        ->point[0];
            uvpt1[1] =((struct EMSsfintedpar *)p_intobj_loc->more_info)
                        ->point[1];
          }
          if (((struct EMSsfintedpar *)p_intobj_loc->more_info)->next)
          {
            edgeid2 = ((struct EMSsfintedpar *)p_intobj_loc->more_info)
                       ->next->edgeid;
            if (edgeid2 != PW_K_NullObjid)
            {
              uvpt2[0] = ((struct EMSsfintedpar *)p_intobj_loc->more_info)
                           ->next->point[0];
              uvpt2[1] = ((struct EMSsfintedpar *)p_intobj_loc->more_info)
                           ->next->point[1];
            }
          }
        }

        /*
         * If the start point of the degenerate intersection lies on an 
         * edge then all the calculations are done based on the start point
         * Otherwise the stop point is considered.
         */
        if (edgeid1 != PW_K_NullObjid)
        {
          startpt = TRUE;
          edgeid = edgeid1;
        }
        else if (edgeid2 != PW_K_NullObjid)
        {
          startpt = FALSE;
          edgeid = edgeid2;
        }
        if (((edgeid1 != PW_K_NullObjid) || (edgeid2 != PW_K_NullObjid)) &&
            (edgeid1 != edgeid2)) 
        {
          /*
           * Obtain the xyz point corresponding to the uvpoints
           */
          if (p_intobj_loc->this_obj_node->more_info)
          {
            p_surf = (struct IGRbsp_surface *)p_intobj_loc
                      ->this_obj_node->more_info;
          }
          else
          {
            retval = PW_GetSfBspsfStack (sfobjid, sfos, mattyp, mat, p_surf);
            OnErrorCode (retval, wrapup);
          }
          posorient = p_surf->pos_orient;
          if (startpt)
          {
            BSsfeval (p_surf, uvpt1[U], uvpt1[V], 0, &xyzpt, &rc);
            OnErrorState (rc!=BSSUCC, retval, 
                          SetError (PW_K_BspMath, PW_K_Internal), wrapup);
          }
          else
          {
            BSsfeval (p_surf, uvpt2[U], uvpt2[V], 0, &xyzpt, &rc);
            OnErrorState (rc!=BSSUCC, retval,
                          SetError (PW_K_BspMath, PW_K_Internal), wrapup);
          }
        
          /*
           * Here we need to traverse the inters list and go to the surface
           * corresponding to the common edge of edge1. Check whether
           * there is an intersection on this surface which has one of its
           * end points on the common edge and the interaction point is
           * equal to xyzpt within tolerance. If such an intersection 
           * exist then depending upon the intersection flow we can orient
           * the degenerate intersection.
           *
           * There may be more than one intersection ending at the desired 
           * point. In that case the degenerate intersection has no role 
           * to play in topology modification. So the degenerate intersection 
           * can be deleted in such case.
           */
          
          /*
           * Get the common edge corresponding to edgeid
           */
          commEdid = pwGetCommonEd (edgeid, sfos);
          commLpid = pwGetLpOfEd (commEdid, sfos);
          commSfid = pwSfOfLp (commLpid, sfos);
          p_inters_tmp = p_inters[0];
          while (p_inters_tmp && p_inters_tmp->this_obj.objid != commSfid)
          {
            p_inters_tmp = p_inters_tmp->next;
          }
          if (p_inters_tmp)
          {
            p_intobj_tmp = p_inters_tmp->cvs;
            while (p_intobj_tmp)
            {
              if ((p_intobj_tmp->more_info) && 
                  (((struct EMSsfintedpar *)p_intobj_tmp->more_info)
                   ->edgeid == commEdid))
              {
                tmp_posorient=FALSE;
                intsfobjid = p_intobj_tmp->this_obj_node->this_obj.objid;
                intsfos = p_intobj_tmp->this_obj_node->this_obj.osnum;

                /*
                 * Get the interaction point for this intersection
                 */
                uvptint[0] = ((struct EMSsfintedpar *)p_intobj_tmp->more_info)
                              ->point[0];
                uvptint[1] = ((struct EMSsfintedpar *)p_intobj_tmp->more_info)
                              ->point[1];

                /*
                 * Get the surface geometry for the current surface
                 */
                if (p_intobj_tmp->this_obj_node->more_info)
                {
                  p_intsfgeom = (struct IGRbsp_surface *)(p_intobj_tmp->
                                this_obj_node->more_info);
                }
                else
                {
                  retval = PW_GetSfBspsfStack (intsfobjid, intsfos, mattyp, mat,
                                               p_intsfgeom);
                  OnErrorCode (retval, wrapup);
                }
                tmp_posorient = p_intsfgeom->pos_orient;
                BSsfeval (p_intsfgeom, uvptint[U], uvptint[V], 0, &xyzptint,
                          &rc);
                OnErrorState (rc!=BSSUCC, retval,
                              SetError (PW_K_BspMath, PW_K_Internal), wrapup);

                /*
                 * Check if both the points are same within tolerance
                 */
                dist = pwDistPtPt (xyzpt, xyzptint);
                if (dist <= xyztol)
                {
                  if (!edge1_found)
                  {
                    edge1_found = TRUE;
                    if ( (!(p_intobj_tmp->reversed) 
                           && (tmp_posorient == posorient)) ||
                         ((p_intobj_tmp->reversed) 
                          &&(tmp_posorient != posorient)) )
                    {
                      if (startpt)
                        degen_intobj_reversed = TRUE;
                      else
                        degen_intobj_reversed = FALSE;
                    }
                    else
                    {
                      if (startpt)
                        degen_intobj_reversed = FALSE;
                      else
                        degen_intobj_reversed = TRUE;
                    }
                  }/* !edge1_found */
                  else
                  {
                    edge2_found = TRUE;
                  }
                }/* dist <= xyztol */
              }/*p_intobj_tmp->more_info->edgeid == edgeid1 */
              else if (((struct EMSsfintedpar *)p_intobj_tmp->more_info)->next
                       &&
                       (((struct EMSsfintedpar *)p_intobj_tmp->more_info)->next
                       ->edgeid == commEdid)) 
              {
                intsfobjid = p_intobj_tmp->this_obj_node->this_obj.objid;
                intsfos = p_intobj_tmp->this_obj_node->this_obj.osnum;

                /*
                 * Get the interaction point for this intersection
                 */
                uvptint[0] = ((struct EMSsfintedpar *)p_intobj_tmp->more_info)
                              ->next->point[0];
                uvptint[1] = ((struct EMSsfintedpar *)p_intobj_tmp->more_info)
                              ->next->point[1];

                /*
                 * Get the surface geometry for the current surface
                 */
                if (p_intobj_tmp->this_obj_node->more_info)
                {
                  p_intsfgeom = (struct IGRbsp_surface *)p_intobj_tmp->
                                this_obj_node->more_info;
                }
                else
                {
                  retval = PW_GetSfBspsfStack (intsfobjid, intsfos, mattyp, mat,
                                               p_intsfgeom);
                  OnErrorCode (retval, wrapup);
                }
                tmp_posorient = p_intsfgeom->pos_orient;
                BSsfeval (p_intsfgeom, uvptint[U], uvptint[V], 0, &xyzptint,
                          &rc);
                OnErrorState (rc!=BSSUCC, retval,
                              SetError (PW_K_BspMath, PW_K_Internal), wrapup);

                /*
                 * Check if both the points are same within tolerance
                 */
                dist = pwDistPtPt (xyzpt, xyzptint);
                if (dist <= xyztol)
                {
                  if (!edge1_found)
                  {
                    edge1_found = TRUE;
                    if (((p_intobj_tmp->reversed) && 
                         (tmp_posorient == posorient)) ||
                        ((!p_intobj_tmp->reversed) &&
                         (tmp_posorient != posorient)) )
                    {
                      if (startpt)
                        degen_intobj_reversed = TRUE;
                      else
                        degen_intobj_reversed = FALSE;
                    }
                    else
                    {
                      if (startpt)
                        degen_intobj_reversed = FALSE;
                      else
                        degen_intobj_reversed = TRUE;
                    }
                  }/* !edge1_found */
                  else
                  {
                    edge2_found = TRUE;
                  }
                }/* dist <= xyztol */
              }/*p_intobj_tmp->more_info->next->edgeid == edgeid1 */

              if (edge2_found)
              {
                degen_int_delete = TRUE;
                break;
              }
              p_intobj_tmp = p_intobj_tmp->next;
            }/* while p_intobj_tmp */ 
          }/* if p_inters_tmp */

          if (degen_int_delete)
          {
            p_intobj_loc->props |= EMSintobj_deletable;
            p_intobj_loc->other_intobj_node->props |= EMSintobj_deletable;
          }
          else if (edge1_found)
          {
            if (degen_intobj_reversed)
            {
              p_intobj_loc->reversed = TRUE;
            }
            else
            {
              p_intobj_loc->reversed = FALSE;
            }
          }/* if edge1_found */
        }/* if edgeid1 || edgid2 are not PW_K_NullObjid & are not same */
      }
      p_intobj_loc = p_intobj_loc->next;
    }
    p_inters_loc = p_inters_loc->next;
  }
  wrapup:
  /*
   * Wipe out the EMSintobj_marked bit
   */
  p_inters_loc = *p_inters;
  while (p_inters_loc)
  {
    p_intobj_loc = p_inters_loc->cvs;
    while (p_intobj_loc)
    {
      p_intobj_loc->props &= ~EMSintobj_marked;
      p_intobj_loc->other_intobj_node->props &= ~EMSintobj_marked;
      p_intobj_loc = p_intobj_loc->next;
    }
    p_inters_loc = p_inters_loc->next;
  }
  return (retval);
}/* end of function pwOrientDegenInt */
