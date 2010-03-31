/*
 * FOR Project PATHWAY
 *     Sanjay  : Creation
 */

/* ------------------------------------------------------------------------- */
/*                               API Definition                              */
/* ------------------------------------------------------------------------- */

/*
  ABSTRACT
     
     Determines the regions which are falling IN area / ON boundary from 
     interaction points list on an intersection curve  and  outputs  the 
     regions in a linked list.
 
  DESCRIPTION

     Given the linked list of interaction points list on an intersection
     curve, it outputs the regions falling IN area / ON boundary by loo-
     king at the RIGHT rel. of the node and LEFT rel. of  the next node. 
     If the RIGHT and LEFT rels of the adjacent does not match, then  it 
     errors out. The regions those are ON boundary  is  provided with an 
     attribute which contains the EDGE ID with which it is actually coi-
     ncident.

  NOTES

     All the memory for the output is allocated in this function. So, it
     is the caller's responsibility to free the allocated memory.

     As the output argument is  of  READ-WRITE type, it is the caller's 
     responsibility to  make sure that the argument is either points to 
     NULL or a valid "Cvregion_list". 
 
  ARGUMENTS

     p_cvdata      I   Intersection curve data
     p_cvintpts    I   A linked list of all the interactions on a curve. 
     os            I   Osnum
     tol           I   Tolerance against which the degeneracy of a region
                       need to be decided.
    
     p_cvregions  I/O  A linked list of PWcvregion_list structures  that 
                       conatain all the information about  curve regions  
                       those fall within the area / on the boundaries of 
                       the surface. If this list  on  input is non-NULL, 
                       the output regions are appended to the list.
 
  RETURN CODE

      PW_K_Success     - If everything goes well.
      PW_K_Internal    - Any inetrnal failure.
      PW_K_InvalidArg  - Invalid Arguments.
 
  KEYWORDS

      External API, Boundary, Edge ...

  CAVEATS
 
  HISTORY
     Sanjay                Creation 
*/

/* Includes */

#include <stdio.h>
#include <math.h>                   /* Standard C library Includes */
#include <alloca.h>
#include <memory.h>

#include "igrtypedef.h"
#include "igr.h"        /* BS Include Stuff */
#include "bs.h"
#include "bsparameters.h"

#include "PWminimum.h"
#include "PWgmdata.h"
#include "PWgmint.h"
#include "PWerror.h"                /* PATHWAY Include Stuff */
#include "PWattribid.h"
#include "PWattrib.h"

/* Prototypes */
#include "PWapi/eded.h"
#include "PWapi/samepts.h"
#include "PWapi/mkcvregs.h"
#include "PWapi/edptproj.h"
#include "PWapi/ptpargm.h"

/* ------------------------------------------------------------------------- */
/*                            API Source Code                                */
/* ------------------------------------------------------------------------- */

PWresult pwMakeCvRegions
(
  struct PWcvintpt_list  **p_cvintpts,
  struct PWcvdata        *p_cvdata,
  PWosnum                os,
  double                 tol,
  struct PWcvregion_list **p_cvregions 
)
{
  PWresult  PWsts=PW_K_Success;

  enum PWcontaintype      reg_cont, lf_int_cont, rt_int_cont; 

  struct PWcvregion_list   *p_regnode=NULL, *p_reglist=NULL;
  struct PWcvintpt_list    *p_intnode=NULL;
  
  PWobjid  cvid=PW_K_NullObjid;

  /* 
   * check for the validity of the incoming arguments 
   */
  if (!p_cvintpts || !*p_cvintpts || !p_cvregions)  
    OnErrorState (TRUE, PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg), 
                  wrapup);

  p_intnode = *p_cvintpts; 

  while (p_intnode->p_next)
  {
    /*
     * Initialize the loop variables
     */
    cvid = PW_K_NullObjid;
    p_regnode = NULL;

    /*
     * Is the region between this node and next node represents area/bdry. If
     * so, create region node and post the information, otherwise move on to 
     * the next node.
     */

    reg_cont = pwGetContainCvintptList (p_intnode, NEXT);

    if (reg_cont == PWcontain_in || reg_cont == PWcontain_on)
    {
      /*
       * This region is IN area or ON the boundary. Get the LEFT and RIGHT
       * containment of the nodes comprising this region.
       */

      rt_int_cont = pwGetContainCvintptList (p_intnode, RIGHT);
      lf_int_cont = pwGetContainCvintptList (p_intnode->p_next, LEFT);

      /*
       * If these do not toggle w.r.t each other or if they do not toggle w.r.t
       * the region classification, error out.
       */

      OnErrorState (rt_int_cont != lf_int_cont || rt_int_cont != reg_cont,
       PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg), wrapup);

      OnErrorState (
       pwGetContainCvintpt (&p_intnode->intpt, RIGHT) != rt_int_cont || 
       pwGetContainCvintpt (&p_intnode->p_next->intpt, LEFT) != lf_int_cont, 
       PWsts, SetError (PW_K_Trimming, PW_K_InvalidArg), wrapup);     

      /*
       * Create the Curve region node. 
       */

      p_regnode = pwCreateCvregionList (&p_reglist);
      OnErrorState (!p_regnode, PWsts, 
                    SetError (PW_K_Trimming, PW_K_DynamicMemory), wrapup);

      /*
       * Set the region properties.
       *  1) CONTAINMENT
       *  2) DEGENERACY
       *
       * TBD : In case of a closed curve if the interaction points are at the
       *       ends of the curve, care should be taken to consider the param-
       *       etrization of the curve rather than the points itself.
       */

      pwSetContainCvregion (&p_regnode->cvregion, reg_cont);

      if ((pwGetTopoposCvpt (&p_intnode->intpt.cvpt) ==
           pwGetTopoposCvpt (&p_intnode->p_next->intpt.cvpt)) &&
           pwIsSamePt (p_intnode->intpt.cvpt.pt, 
                      p_intnode->p_next->intpt.cvpt.pt, tol)) 
      {
        pwSetDegenCvregion (&p_regnode->cvregion);
      }

      /*
       * Set the interaction node's data
       */

      memcpy (&p_regnode->cvregion.regbounds[0], &p_intnode->intpt, 
              sizeof(struct PWcvintpt));
      memcpy (&p_regnode->cvregion.regbounds[1], &p_intnode->p_next->intpt,
              sizeof(struct PWcvintpt));

      /*
       * Copy the interacion node's attribute data
       */

      p_regnode->cvregion.regbounds[0].p_attrib = 
                          pwCopyAttribList (p_intnode->intpt.p_attrib); 
      p_regnode->cvregion.regbounds[1].p_attrib = 
                          pwCopyAttribList (p_intnode->p_next->intpt.p_attrib); 
      p_regnode->cvregion.regbounds[0].cvpt.p_attrib = 
                          pwCopyAttribList (p_intnode->intpt.cvpt.p_attrib); 
      p_regnode->cvregion.regbounds[1].cvpt.p_attrib = 
                 pwCopyAttribList (p_intnode->p_next->intpt.cvpt.p_attrib); 
      p_regnode->cvregion.regbounds[0].sibling.p_attrib = 
                          pwCopyAttribList (p_intnode->intpt.sibling.p_attrib); 
      p_regnode->cvregion.regbounds[1].sibling.p_attrib = 
                 pwCopyAttribList (p_intnode->p_next->intpt.sibling.p_attrib); 

      if (reg_cont == PWcontain_on)
      {
        double par, midpt[3];
        struct PWcvparam midpar, *p_startpar, *p_stoppar;

        /*
         * This region is ON the boundary, which means that it is coincident
         * with one of the edges. So, get the intervening  edge  with  which 
         * the region is coincident and store it as an attribute.
         */

        p_startpar = &p_intnode->intpt.cvpt.cvparam;
        p_stoppar = &p_intnode->p_next->intpt.cvpt.cvparam;
        par = ( p_startpar->spaninx + p_startpar->spanpar + 
                p_stoppar->spaninx  + p_stoppar->spanpar ) / 2.0;
        midpar.spaninx = (int) par;
        midpar.spanpar = par - (int) par;
      
        PWsts = pwPtAtParCvdata (p_cvdata, &midpar, midpt);
        OnErrorState (IsError (PWsts), PWsts, SetError (PW_K_Trimming, 
         PW_K_Internal), wrapup);
     
        cvid = pwGetInterveningEdge (os, p_intnode->intpt.sibling.cvid,
                          pwGetTopoposCvpt (&p_intnode->intpt.sibling), 
                          p_intnode->p_next->intpt.sibling.cvid,
                          pwGetTopoposCvpt (&p_intnode->p_next->intpt.sibling),
                          midpt, tol);
        OnErrorState (cvid == PW_K_NullObjid, PWsts, 
                      SetError (PW_K_Trimming, PW_K_InvalidArg), wrapup);

        pwCreateIntAttrib (&p_regnode->cvregion.p_attrib, 
                           PW_AttribIdent (PW_K_Trimming, PW_K_EdgeIdAttr, 0),
                           cvid);

      } /* if (reg_cont == PWcontain_on) ON BOUNDARY*/

    } /* if (reg_cont == PWcontain_in ...  IN AREA / ON BOUNDARY*/

    /*
     * Move to the next node
     */
    p_intnode = p_intnode->p_next;

  } /* while ... */

  /*
   * Append the region list to the incoming region list
   */
  pwAppendCvregionList (p_cvregions, p_reglist);

wrapup :

  if (IsError(PWsts) && p_reglist)
    pwFreeCvregionList (p_reglist); 

  PW_Wrapup (PWsts, "pwMakeCvRegions");
  return PWsts;
}
