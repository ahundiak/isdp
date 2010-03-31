/* Includes */

#include<stdio.h>
#include<math.h>
#include<memory.h>
#include<alloca.h>

#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWattrib.h"
#include "PWattribid.h"

#include<OMminimum.h>
#include "EMSmsgdef.h"
#include "bs.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bssfeval.h"
#include "bsmdistptsf.h"
#include "bsgeom_cvsf.h"
#include "msdef.h"
#include "ma.h"
#include "maidmx.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "emssfintdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "emsedgedef.h"

/* OMuse includes */

#include "PWapi/sfgeom.h"          
#include "PWapi/cvgeom.h"
#include "PWapi/eded.h"
#include "PWapi/sflp.h"
#include "PWapi/lped.h"
#include "PWapi/mx.h"

/* Pathway Includes */

#include "PWapi/intcoinc.h"        
#include "PWapi/edptproj.h"
#include "PWapi/edintpts.h"
#include "PWapi/partol.h"
#include "PWapi/changedata.h"
#include "PWapi/mdstptgm.h"
#include "PWapi/intcvpts.h"
#include "PWapi/ptpargm.h"
#include "PWapi/push.h"

extern void EMcmpinters 
(
  long *,
  struct EMSinters **
);
/* Static declarations */

static PWboolean IsIntobjPairDeletable
(
   struct EMSintobj  *p_intobj,
   double            xyztol
);

static void      GetDuplicatePairs
(
   struct EMSinters *p_inters,
   struct EMSintobj *p_intcv,
   double           xyztol,
   struct EMSintobj **ret_ptr
);

static PWboolean  AreIntobjsSame
(
  struct EMSintobj  *p_intcv1,
  struct EMSintobj  *p_intcv2,
  double            tol
);

static PWresult  GetIntobjPts
(
  struct EMSintobj  *p_intcv,
  PWpoint           xyzpts[3]
);

static PWboolean ArePtsSpreadBigger
(
  struct EMSintobj  *p_intcv,
  PWpoint           xyzpts[3],
  double            xyztol
);

/*
 *   Application function name : pwProcessDupInt().
 *
 *   Description
 *   -----------
 *   This function markes the duplicate intobjs present in the inters list
 *   as deletable. Only the intobj pair with the best geometry is retained.
 *
 *   Input
 *   -----
 *   EMSinters     *inters                        *
 *                                                 * Inters list with the
 *                                                 * duplicate intobjs not
 *                                                 * not marked for deletion
 *                                                 *
 *   double        xyztol                          * xyz tolerance value
 *                                                 *
 *
 *   Output
 *   ------
 *   EMSinters     *inters                         *
 *                                                  * Inters list with the
 *                                                  * duplicate intobjs marked
 *                                                  * for deletion
 *                                                  *
 */


void     pwProcessDupInt
( 
   struct EMSinters **p_inters, 
   double           xyztol
)
{
  PWresult               retval;
  long                   msg_loc;
  struct EMSinters       *p_inters_loc=NULL;
  struct EMSintobj       *p_this_intobj=NULL, *p_intobj_loc[4],
                         *p_intobj_loc_tmp=NULL, *p_other_intobj=NULL,
                         *p_this_intobj_next=NULL;
  PWboolean              reversed=FALSE, pushing_reqd=TRUE;
  int                    i;

  /* 
   * Initialize 
   */
  retval = PW_K_Success;
  msg_loc = EMS_S_Success;
  for (i=0; i<4; i++)
  {
    p_intobj_loc[i] = NULL;
  }

  /*
   * Wipe out the EMSintobj_marked bit, so that this can be 
   * locally used here
   */
  p_inters_loc = *p_inters;
  while (p_inters_loc)
  {
    p_this_intobj = p_inters_loc->cvs;
    while (p_this_intobj)
    {
      p_this_intobj->props &= ~EMSintobj_marked;
      p_this_intobj->other_intobj_node->props &= ~EMSintobj_marked;
      p_this_intobj = p_this_intobj->next;
    }
    p_inters_loc = p_inters_loc->next;
  }

  p_inters_loc = p_inters[0];
  while (p_inters_loc)
  {
    p_this_intobj = p_inters_loc->cvs;
    while (p_this_intobj)
    {
      p_this_intobj_next = p_this_intobj->next;
      /*
       * Initialize  within the loop
       */
      pushing_reqd = TRUE;
      reversed = IsIntobjPairDeletable (p_this_intobj, xyztol);
      if (!reversed)
      {
        pushing_reqd = FALSE;
      }
      reversed = FALSE;
      for (i=0; i<4; i++)
      {
        p_intobj_loc[i] = NULL;
      }
      /* 
       * If this intobj is not marked to be deleted and is not processed
       * then check if this and/or other intobj runs along an edge.
       */
      if (!(p_this_intobj->props & EMSintobj_marked) &&
          !(p_this_intobj->other_intobj_node->props & EMSintobj_marked) &&
          !(p_this_intobj->props & EMSintobj_deletable) &&
          (p_this_intobj->coinced != NULL_OBJID || 
           p_this_intobj->other_intobj_node->coinced !=NULL_OBJID))
      {
        /*
         * Store this intobj location in p_intobj_loc[0] and search for
         * other duplicate intobjs on this surface and neighbouring
         * surface (only if this intobj runs along an edge)
         */

        p_intobj_loc[0] = p_this_intobj;

        /*
         * Fill the rating value depending upon the intersection 
         * curve types 'rating[0]' (Not implemented)
         */
        
        if (p_this_intobj->coinced != NULL_OBJID)
        {
          GetDuplicatePairs (p_inters[0], p_this_intobj, xyztol, 
                             &p_intobj_loc[1]);
        }
        else if (p_this_intobj->other_intobj_node->coinced != NULL_OBJID)
        {
          /*
           * get p_intobj_loc[0]'s other intobj's coincident
           * intersections.
           */
          GetDuplicatePairs (p_inters[1], p_intobj_loc[0]->other_intobj_node,
                             xyztol, &p_intobj_loc[1]);
          for (i=1; i<=3; i++)
          {
            if (p_intobj_loc[i])
            {
              p_intobj_loc[i] = p_intobj_loc[i]->other_intobj_node;
            }
          }
        }
        if (p_intobj_loc[0]->props & EMSintobj_deletable)
          goto next;

        if ( p_intobj_loc[1] || p_intobj_loc[2] || p_intobj_loc[3])
        {
          /*
           * At this point all the duplicate intobj pairs corresponding to
           * the present intobj pair are collected. They are pointed to by
           * 'p_intobj_loc' array. If there is any intobj pair which runs 
           * along the coincident edge and is not required to be pushed 
           * across the surface, then that intobj pair is retained and all
           * other intobj pairs in the 'p_intobj_loc' array are marked 
           * deletable. In absence of such an intobj pair, intobj pair under
           * consideration is retained and the rest are marked as deletable.
           */
          for (i=0; i<=3; i++)
          {
            if (p_intobj_loc[i])
            {
              reversed = IsIntobjPairDeletable (p_intobj_loc[i], xyztol);
              if (!reversed)
              {
                pushing_reqd = FALSE;
                p_intobj_loc_tmp = p_intobj_loc[i];
                p_intobj_loc[i] = p_intobj_loc[0];
                p_intobj_loc[0] = p_intobj_loc_tmp;
              }
            }
          }
          /*
           * Now p_intobj_loc[0] contains the intobj pair to be retained.
           * all other intobj pairs are marked for deletion.
           */
          for (i=1; i<=3; i++)
          {
            if (p_intobj_loc[i])
            {
              p_intobj_loc[i]->props |= EMSintobj_deletable;
              p_intobj_loc[i]->other_intobj_node->props |= EMSintobj_deletable;
              p_intobj_loc[i]->props |= EMSintobj_marked;
              p_intobj_loc[i]->other_intobj_node->props |= EMSintobj_marked;
            }
          }
        }
        /*
         * Now call the pushing function to push p_intobj_loc[0] and
         * p_intobj[0]->other_intobj_node if required.
         */
        if (pushing_reqd)
        {
          p_other_intobj = p_intobj_loc[0]->other_intobj_node;
          retval = pwPushCoincEdges (&p_inters[0], p_intobj_loc[0], xyztol);
          OnErrorCode (retval, wrapup);
          retval = pwPushCoincEdges (&p_inters[1], p_other_intobj, xyztol);
          OnErrorCode (retval, wrapup);
        }
        if (!pushing_reqd)
        {
          p_intobj_loc[0]->props |= EMSintobj_marked;
          p_intobj_loc[0]->other_intobj_node->props |= EMSintobj_marked;
        }
      }/* if intobj is not deletable and this or the other has coincedid */
      next:
      p_this_intobj = p_this_intobj_next;
    }/* while p_this_intobj */
    p_inters_loc = p_inters_loc->next;
  }/* while inters_loc */

  EMcmpinters (&msg_loc, &p_inters[0]);
  if (!(1&msg_loc))
  {
    retval = SetError (0, PW_K_Internal);
    goto wrapup;
  }
  EMcmpinters (&msg_loc, &p_inters[1]);
  if (!(1&msg_loc))
  {
    retval = SetError (0, PW_K_Internal);
    goto wrapup;
  }
  wrapup:
  return;
}/* end of function  pwProcessDupInt */



/*
 *   Application Function: GetDuplicatePairs().
 *   -------------------------------------------
 *
 *   Description
 *   -----------
 *   This function takes in an intersection pointer and looks for a duplicate
 *   intersection on the same surface.
 *
 *   Input
 *   -----
 *   struct EMSinters      *p_inters                *  inters list on which
 *                                                     this intobj is found.
 *
 *   struct EMSintobj      *p_intcv                 *  Input intersection
 * 						    *
 *   double                xyztol                   *  Input xyz tolerance
 *						    *
 *   Output
 *   ------
 *   struct EMSintobj      **ret_ptr                * Coincident intersection
 *                                                  *  
 *
 */

static void      GetDuplicatePairs
( 
  struct EMSinters *p_inters,
  struct EMSintobj *p_intcv,
  double           xyztol,
  struct EMSintobj **ret_ptr
)
{
  PWresult               retval;
  PWboolean              coincident=FALSE, other_intobj_found=FALSE;
  struct EMSintobj       *p_intobj_loc=NULL;
  struct EMSinters       *p_inters_loc=NULL;
  PWobjid                coincedid;
  struct PWid            edid_loc;
  struct IGRbsp_surface  *p_this_surf=NULL, *p_other_surf=NULL;
  PWpoint                this_intobj_pts[3], other_intobj_pts[3];   
  double                 this_uvtol, other_uvtol=0.0;
  PWboolean              this_is_bigger=FALSE, other_is_bigger=FALSE;
  unsigned short         mattyp=2;
  PWmatrix               mat;
  PWobjid                commEdid, commLpid, commSfid;

  /*
   * Initialize
   */
  retval = PW_K_Success;
  edid_loc.osnum = p_intcv->this_obj_node->this_obj.osnum;
  /*
   * Get the surface geometry
   */
  if (p_intcv->this_obj_node->more_info)
  p_this_surf = (struct IGRbsp_surface*)p_intcv->this_obj_node->more_info;
  else
  {
    retval = PW_GetSfBspsfStack (p_intcv->this_obj_node->this_obj.objid, 
                        p_intcv->this_obj_node->this_obj.osnum, mattyp, mat,
                        p_this_surf);
    OnErrorCode (retval, wrapup);
  }
  /*
   * Get this_uvtol from the xyztol
   */
  this_uvtol = pwGetParTolSf (p_this_surf, xyztol);

  p_intobj_loc = p_intcv->this_obj_node->cvs;
  coincedid = p_intcv->coinced;
  while (p_intobj_loc)
  {
    if (!(p_intobj_loc->props & EMSintobj_deletable) &&
        !(p_intobj_loc->props & EMSintobj_marked) &&
         (p_intobj_loc != p_intcv))
    {
      if (p_intobj_loc->coinced == coincedid)
      {
        coincident = AreIntobjsSame (p_intcv, p_intobj_loc, this_uvtol);
        if (coincident)
        {
          /*
           * Here 'coincident' has a special meaning. It means that one of
           * intobjobj is a subset or is equal to the other intobj
           */
          /*
           * If the input intobj is a subset then goto wrapup
           */
          if (p_intcv->props & EMSintobj_deletable)
          {
            goto wrapup;
          }
          if (!(p_intobj_loc->props & EMSintobj_deletable)) 
          ret_ptr[0] = p_intobj_loc;
          coincident=FALSE;
        }/* if coincident */
      }/* coincedid  */
    }/* if not deletable and not same ptr */
    p_intobj_loc = p_intobj_loc->next;
  }/* end of while (p_intobj_loc) */

  /*
   * Now  search for any duplicate intobj that runs along the common 
   * edge to this coincident edge. 
   */

  /*
   * Get the common edge id from the coincident edge
   */
  commEdid = pwGetCommonEd (coincedid, edid_loc.osnum);
  if (commEdid != PW_K_NullObjid)
  {
    commLpid = pwGetLpOfEd (commEdid, edid_loc.osnum);
    commSfid = pwSfOfLp (commLpid, edid_loc.osnum);
    /*
     * Search the inters list to find an inters node with this surface
     * id
     */
    p_inters_loc = p_inters;
    while (p_inters_loc)
    {
      if (p_inters_loc->this_obj.objid == commSfid)
      {
        /*
         * Get this surface geometry
         */
        if (p_inters_loc->more_info)
          p_other_surf = (struct IGRbsp_surface*)p_inters_loc->more_info;
        else
        {
          retval = PW_GetSfBspsfStack (commSfid, edid_loc.osnum, mattyp, mat,
                              p_other_surf);
          OnErrorCode (retval, wrapup);
        }
        /*
         * Get the other_uvtol
         */
        other_uvtol = pwGetParTolSf (p_other_surf, xyztol);     

        /*
         * Check whether there is an intersection on this surface which
         * matches with the given intersection. Only if there is an 
         * intersection which is a candidate for further testing we will 
         * do further testing.
         */
        p_intobj_loc = p_inters_loc->cvs;
        while (p_intobj_loc)
        {
          if (!(p_intobj_loc->props & EMSintobj_deletable) &&
              !(p_intobj_loc->props & EMSintobj_marked) &&
              (p_intobj_loc->coinced == commEdid))
          {
            other_intobj_found = TRUE;
            break;
          }
          p_intobj_loc = p_intobj_loc->next;
        }
      }/* if p_inters_loc->this_obj.objid == commSfid */
      if (other_intobj_found)
        break;
      p_inters_loc = p_inters_loc->next;
    }/* while p_inters_loc */

    if (other_intobj_found)
    {
      /*
       * Get the internal and end points of the input intobj
       */
      retval = GetIntobjPts (p_intcv, this_intobj_pts);
      OnErrorCode (retval, wrapup);

      p_intobj_loc = p_inters_loc->cvs;
      while (p_intobj_loc)
      {
        if (!(p_intobj_loc->props & EMSintobj_deletable) &&
            !(p_intobj_loc->props & EMSintobj_marked) &&
            (p_intobj_loc->coinced == commEdid))
        {
          /*
           * Using the input intobj's points, check if they lie within 
           * tolerance of this candidate "other" intobj.
           */
          this_is_bigger = ArePtsSpreadBigger (p_intobj_loc, this_intobj_pts,
                            xyztol);

          /* 
           * Get the internaland end points of this candidate "other" intobj
           * and check if they lie within tolerance of "this" intobj.
           */

          retval = GetIntobjPts (p_intobj_loc, other_intobj_pts);
          OnErrorCode (retval, wrapup);

          other_is_bigger = ArePtsSpreadBigger (p_intcv, other_intobj_pts, 
                             xyztol);

          /*
           * If neither point-spreads indicate that they are smaller or 
           * contained within the other intobj in the pair, we conclude that
           * there is no overlap. On the other hand, the one intobj that
           * appears fully contained within the other of the pair, will be
           * marked for deletion.
           *
           * In the case, when the input intobj ("this"), gets marked for 
           * deletion, no further processing needs to be carried out. There
           * can be no other coincident pairs involving the input intobj. But
           * finding an "other" intobj as the one to be deleted should not
           * stop processing, as there may still be other 'small' other-intobjs
           * that may still get deleted by being found coincident with the
           * input.
           */

          if (this_is_bigger && other_is_bigger)
          {
            coincident=FALSE;
          }
          else
          {
            coincident = TRUE;
            if (this_is_bigger)
            {
              p_intobj_loc->props |= EMSintobj_deletable;
              p_intobj_loc->other_intobj_node->props |= EMSintobj_deletable;
            }
            else
            {
              p_intcv->props |=EMSintobj_deletable;
              p_intcv->other_intobj_node->props |= EMSintobj_deletable;
              goto wrapup;
            }
          }
          this_is_bigger=FALSE;
          other_is_bigger=FALSE;
        }/* if intobj is not deletable and has same coincedid */

        if (coincident)
        {
          if (ret_ptr[1])
          { 
            if (!(p_intobj_loc->props&EMSintobj_deletable))
            ret_ptr[2] = p_intobj_loc;
          }
          else 
          {
            if (!(p_intobj_loc->props&EMSintobj_deletable))
            ret_ptr[1] = p_intobj_loc;
          }
          coincident=FALSE;
        }
        p_intobj_loc = p_intobj_loc->next;
      }/* while intobj_loc */
    }/* if other intobj found */
  }/* commEdid != PW_K_NullObjid */
  wrapup:
  return;
}/* end of function GetDuplicatePairs  */



static PWboolean IsIntobjPairDeletable
(
   struct EMSintobj  *p_intobj,
   double            xyztol
)
{
  long                    rc;
  unsigned long           retval;
  struct EMSintobj        *p_other_intobj=NULL;
  struct IGRbsp_surface   *p_this_surf=NULL, *p_other_surf=NULL;
  PWmatrix                mat;
  short                   mattyp;
  double                  this_uvtol=0, other_uvtol=0;
  PWboolean               this_reversed=FALSE, other_reversed=FALSE, aflag=0;
  PWobjid                 commEdid;
  struct GRmd_env         rfenv;

  if(aflag = pwIsActivationOn())
  {
    pwGetActiveModuleEnv(&rfenv);
    memcpy(mat, rfenv.md_env.matrix, sizeof(PWmatrix));
    mattyp = rfenv.md_env.matrix_type;
  }
  else
  {
    mattyp = 2;
    MAidmx( &rc, mat);
  }

  if( p_intobj->coinced != PW_K_NullObjid )
  {
    /* 
     * Get the surface geometry for this intobj 
     */
    retval = PW_GetSfBspsfStack (p_intobj->this_obj_node->this_obj.objid,
                        p_intobj->this_obj_node->this_obj.osnum, mattyp,
                        mat, p_this_surf);
    OnErrorCode( retval, wrapup );

    this_uvtol = pwGetParTolSf( p_this_surf, xyztol);
    this_reversed = pwDetIntReversal( p_intobj->coinced, p_intobj,
                                      this_uvtol );
    if (this_reversed)
    {
      commEdid = pwGetCommonEd (p_intobj->coinced, 
                                p_intobj->this_obj_node->this_obj.osnum);
      if (commEdid == PW_K_NullObjid)
      {
        this_reversed=FALSE;
        /** p_intobj->reversed = !(p_intobj->reversed); **/
      }
    }
  }
  p_other_intobj = p_intobj->other_intobj_node;
  if( p_other_intobj->coinced != PW_K_NullObjid )
  {
    /* 
     * Get the surface geometry for this intobj 
     */
    retval = PW_GetSfBspsfStack( 
                        (p_other_intobj->this_obj_node->this_obj.objid),
                        (p_other_intobj->this_obj_node->this_obj.osnum), 
                        mattyp, mat, p_other_surf);
    OnErrorCode( retval, wrapup );

    other_uvtol = pwGetParTolSf( p_other_surf, xyztol);
    other_reversed = pwDetIntReversal( p_other_intobj->coinced, 
                                       p_other_intobj, other_uvtol);
    if (other_reversed)
    {
      commEdid = pwGetCommonEd (p_other_intobj->coinced,
                                p_other_intobj->this_obj_node->this_obj.osnum);
      if (commEdid == PW_K_NullObjid)
      {
        other_reversed=FALSE;
        /* p_other_intobj->reversed = !(p_other_intobj->reversed); */
      }
    }
  }
   
  wrapup:
  if( this_reversed || other_reversed )
    return (TRUE ); 
  else
    return(FALSE);
}/* end of function IsIntobjPairDeletable */



PWboolean AreIntobjsSame
(
   struct EMSintobj  *p_intcv1,
   struct EMSintobj  *p_intcv2,
   double            tol
)
{
  PWresult          retval;
  long              rc;
  int               i, ii;
  double            ddist=0.0, sqdist=0.0;
  struct PWcvpt     p_intpts[3];
  struct PWcvdata   cvdata[2];
  struct PWcvdata   *p_temp_cvdata1=NULL, *p_temp_cvdata2=NULL;
  PWpoint           minpt;
  struct PWcvparam  minpar;
  PWboolean         intobj_coinc=TRUE, free_cvdata[2];
  unsigned short    mattyp;
  PWmatrix          mat;
  PWboolean         first_is_bigger=FALSE, second_is_bigger=FALSE, aflag=0;
  struct GRmd_env   rfenv;

  /* Initialize */
  retval = PW_K_Success;
  for (i=0; i<=1; i++)
  {
    free_cvdata[i]=FALSE;
  }

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
  /*
   * If one of the intersection is xyzclosed then that is the bigger
   * intersection. So the other one needs to be deleted. If both the
   * intersections are xyz closed then they are real duplicates.
   */
  if (p_intcv1->props & EMSintobj_xyz_closed)
    first_is_bigger = TRUE;
  if (p_intcv2->props & EMSintobj_xyz_closed)
    second_is_bigger = TRUE;
 
  if ( !(p_intcv1->props & EMSintobj_xyz_closed) &&
       !(p_intcv2->props & EMSintobj_xyz_closed) )
  {  
    /*
     * Convert the input dataselect (this_uvintobj) into a PWcvdata
     * structure
     */
    retval = pwChangeEMSCvdata (&p_intcv1->this_uvintobj, &cvdata[0], 
                                mattyp, mat, &free_cvdata[0]);
    OnErrorCode (retval, wrapup);
    retval = pwChangeEMSCvdata (&p_intcv2->this_uvintobj, &cvdata[1],
                                mattyp, mat, &free_cvdata[1]);
    OnErrorCode (retval, wrapup);


    for( i=0; i<=1; i++)
    { 
      p_temp_cvdata1 = i? &cvdata[1] : &cvdata[0];
      p_temp_cvdata2 = i? &cvdata[0] : &cvdata[1];
      /*
       * Take 1 internal point and 2 end points on p_intcv1 and project it 
       * onto p_intcv2
       */
      retval = pwGetInternalCvPts (p_temp_cvdata1, 1, PWtopopos_middle,
                                   p_intpts);
      pwGetEndPtCvdata (p_temp_cvdata1, FALSE, FALSE, p_intpts[1].pt);
      pwGetEndPtCvdata (p_temp_cvdata1, FALSE, TRUE, p_intpts[2].pt);
      /* 
       * Project the 3 pts obtained above onto the other intersection and
       * get the minimum distance between this point and the projected point
       */
      for (ii=0; ii<3; ii++)
      {
        sqdist = pwMinDistSqPtCvdata (p_intpts[ii].pt, p_temp_cvdata2, minpt,
                                      &minpar);
        /*
         *  Check if the mindist returned by ptproject is within the uvtol
         */
        ddist = sqrt(sqdist);
        if (fabs (ddist) > 10*tol)
        {
          if (!i)
            first_is_bigger=TRUE;
          else
            second_is_bigger=TRUE;
          break;
        }
      }
    }
  }/* if none of the intobjs are closed */
  if (first_is_bigger && second_is_bigger)
    intobj_coinc = FALSE;
  else
  {
    /*
     * If the intobjs are coincident and one intobj is smaller than the
     * other then mark the smaller intobj as 'deletable'.
     */ 
    intobj_coinc = TRUE;
    if (first_is_bigger)
    {
      p_intcv2->props |=EMSintobj_deletable;
      p_intcv2->other_intobj_node->props |= EMSintobj_deletable;
    } 
    else if (second_is_bigger)
    {
      p_intcv1->props |=EMSintobj_deletable;
      p_intcv1->other_intobj_node->props |= EMSintobj_deletable;
    }
  }
  wrapup:
  for (i=0; i<=1; i++)
  {
    if (free_cvdata[i])
    {
      pwFreeCvdata (&cvdata[i]);
    }
  }
  if ( GetCodeType( retval) == PW_K_Error )
  {
      return (FALSE);
  }
  return(intobj_coinc );
}/* end of function pwAreIntobjsCoinc */



static PWresult  GetIntobjPts
(
  struct EMSintobj  *p_intcv,
  PWpoint           xyzpts[3]
)
{
  PWmatrix               mat;
  struct PWcvdata        cvdata;
  struct PWcvpt          cvpt_loc;
  PWboolean              free_cvdata=FALSE;
  PWresult               retval;

  retval = PW_K_Success;

  /*
   * Convert the input intobj's xyzdata into PWcvdata structure
   */

  retval = pwChangeEMSCvdata (&p_intcv->this_xyzintobj, &cvdata, MAIDMX,
            pwIdMx (mat), &free_cvdata);
  OnErrorCode (retval, wrapup);

  /*
   * Get 2 end points and 1 intobj internal point.
   */
  retval = pwGetInternalCvPts (&cvdata, 1, PWtopopos_middle, &cvpt_loc);
  OnErrorCode (retval, wrapup);
  memcpy (xyzpts[FIRST], cvpt_loc.pt, sizeof (PWpoint));

  pwGetEndPtCvdata (&cvdata, FALSE, FALSE, xyzpts[SECOND]);
  pwGetEndPtCvdata (&cvdata, FALSE, TRUE, xyzpts[THIRD]);


wrapup:
  if (free_cvdata)
  {
    pwFreeCvdata (&cvdata);
    free_cvdata = FALSE;
  } 
  return (retval);
}


static PWboolean ArePtsSpreadBigger
(
  struct EMSintobj  *p_intcv,
  PWpoint           xyzpts[3], 
  double            xyztol
)
{
  struct PWcvdata   cvdata;
  PWboolean         free_cvdata=FALSE;
  PWresult          retval;
  PWmatrix          mat;
  PWpoint           dum_minpt;
  struct PWcvparam  dum_minpar;
  int               i;
  double            dist_loc[3];
  PWboolean         spread_is_bigger=FALSE;

  retval = PW_K_Success;

  /*
   * Convert the intobj's xyzdata into PWcvdata structure
   */

  retval = pwChangeEMSCvdata (&p_intcv->this_xyzintobj, &cvdata,
                              MAIDMX, pwIdMx (mat), &free_cvdata);
  OnErrorCode (retval, wrapup);

  /*
   * Find the minimum distances between the input points and the input
   * intobj.
   */

  for (i=0; i<3; i++)
    dist_loc[i] = pwMinDistSqPtCvdata (xyzpts[i], &cvdata, dum_minpt,
                   &dum_minpar);

  /*
   * Check if the mindists returned are all within the tolerance. If any
   * one of them is not, we conclude that the spread defined by the input
   * points is larger than the length of the intobj.
   */

  for (i=0; i<3; i++)
  {
    if (sqrt (dist_loc[i]) > xyztol)
    {
      spread_is_bigger = TRUE;
      break;
    }
  }

wrapup:
  if (free_cvdata)
  {
    pwFreeCvdata (&cvdata);
    free_cvdata = FALSE;
  }
  return (spread_is_bigger);
}
