/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
   DESCRIPION

     These functions are special purpose functions that help in outputting
     "cutting" intersections on curves/linestrings. They are not designed
     for general use. The output from the lower-level intersection functions
     might require some preprocessing to make them amenable for the true
     output. That, and the modularization of code are the main reasons
     for these functions.

  HISTORY

     SS  :  05/02/90  :  Added the options argument to EMint_postprocess
                         and changed it's name to EMint_afterprocess.
     SS  :  09/03/89  :  Added the function EMendint_process.
     PP  :  01/31/88  :  Fixed transferance of data in EMSinthold structure
                         when mallocing was done in EMint_holdproc. 
     PP  :  10/20/87  :  Modularised EMint_preprocess such that the code
                         to hold processing is in a different function
     SS  :  10/10/87  :  Creation
*/

#include "EMS.h"
#include <math.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSbnddef.h"
#include "EMSprop.h"
#include "EMSmsgdef.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsdattyp.h"
#include "emsinter.h"
#include "EMSbnd.h"
#include "emssfint.h"
#include "emserr.h"

/*
 * EMint_preprocess:
 *
 * It accepts enumerated types indicating the relative position on an 
 * element where an intersection occured and indicating it's relative
 * orientation with the other element at the point of intersection.
 * Depending on whether the boundary is being treated as area or hole,
 * it returns a properties word, that retains this information. It alters
 * the C-poly inttype so that it now reflects the topological position
 * relative to the entire C-poly. If the intersection was at the begin
 * or end-point of the C-segment and if these were not the begin and end-points
 * of C-poly itself, the interscetion is retained in the EMSinthold structure
 * for later processing. This, because duplicate internal intersections
 * must be elliminated and this is not done at the lower level.
 */

void EMint_preprocess (msg, wspan, cspan, wpar, cpar, wtype, ctype, intpt,
                       relorient, togprops, remzeropts, num_cpts, edge,
                       props, inthold, hold_proc)
IGRlong *msg;
IGRint wspan, cspan;
IGRdouble wpar, cpar;
enum EMScvinttype wtype, *ctype;
IGRdouble *intpt;
enum EMSrelorient relorient;
IGRboolean togprops, remzeropts;
IGRint num_cpts;
GRobjid edge;
IGRushort *props;
struct EMSinthold *inthold;
IGRboolean *hold_proc;
{
  IGRboolean ignore_inters;
  IGRushort cprops;
  IGRlong msg_loc;
  enum EMScvinttype inttype;
  void EMint_holdproc();

  *msg = EMS_S_Success;

  *props = NULL;
  if (togprops)
    {
    if (relorient == EMSrelorient_area_hole)
      *props |= EMS_PYPT_HOLEAREA;
    else if (relorient == EMSrelorient_hole_area)
      *props |= EMS_PYPT_AREAHOLE;
    else if (relorient == EMSrelorient_hole_hole)
      *props |= EMS_PYPT_AREAAREA;
    else if (relorient == EMSrelorient_area_area)
      *props |= EMS_PYPT_HOLEHOLE;
    else
      *props |= EMS_PYPT_RELUNKNOWN;
    } 
  else
    {
    if (relorient == EMSrelorient_area_hole)
      *props |= EMS_PYPT_AREAHOLE;
    else if (relorient == EMSrelorient_hole_area)
      *props |= EMS_PYPT_HOLEAREA;
    else if (relorient == EMSrelorient_hole_hole)
      *props |= EMS_PYPT_HOLEHOLE;
    else if (relorient == EMSrelorient_area_area)
      *props |= EMS_PYPT_AREAAREA;
    else
      *props |= EMS_PYPT_RELUNKNOWN;
    } 

  inttype = *ctype;
  cprops = *props;
  ignore_inters = FALSE;
  if (inttype != EMScvint_middle && inttype != EMScvint_unknown)
    {
    *hold_proc = TRUE;
    if (num_cpts == 2)
      {
      if (remzeropts &&
          ((inttype == EMScvint_lfend &&
            (cprops & EMS_PYPT_AREAHOLE || cprops & EMS_PYPT_HOLEHOLE)) ||
           (inttype == EMScvint_rtend &&
            (cprops & EMS_PYPT_HOLEAREA || cprops & EMS_PYPT_HOLEHOLE))))
        ignore_inters = TRUE;
      else
        *hold_proc = FALSE;
      }
    else if (cspan == 0)
      {
      if (inttype == EMScvint_rtend)
        *ctype = inttype = EMScvint_middle;
      else if (remzeropts && inttype == EMScvint_lfend &&
               (cprops & EMS_PYPT_AREAHOLE || cprops & EMS_PYPT_HOLEHOLE))
        ignore_inters = TRUE;
      else
        *hold_proc = FALSE;
      }
    else if (cspan == num_cpts-2)
      {
      if (inttype == EMScvint_lfend)
        *ctype = inttype = EMScvint_middle;
      else if (remzeropts && inttype == EMScvint_rtend &&
               (cprops & EMS_PYPT_HOLEAREA || cprops & EMS_PYPT_HOLEHOLE))
        ignore_inters = TRUE;
      else
        *hold_proc = FALSE;
      }
    else
      *ctype = inttype = EMScvint_middle;
    }
  else
    *hold_proc = FALSE;

  if (inttype == EMScvint_lfend)
    *props |= EMS_PYPT_ATSTART;
  else if (inttype == EMScvint_rtend)
    *props |= EMS_PYPT_ATSTOP;
  else if (inttype == EMScvint_middle)
    *props |= EMS_PYPT_ATMIDDLE;
  else
    *props |= EMS_PYPT_POSUNKNOWN;


  if (*hold_proc && !ignore_inters)
    {
    EMint_holdproc (&msg_loc, wspan, cspan, wpar, cpar, wtype, ctype, intpt,
                    props, inthold, edge);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
    }

ret_end:;
}


void EMint_holdproc(msg, wspan, cspan, wpar, cpar, wtype, ctype, intpt,
                    props, inthold, edge)

IGRlong *msg;
IGRint wspan, cspan;
IGRdouble wpar, cpar;
enum EMScvinttype wtype, *ctype;
IGRdouble *intpt;
GRobjid edge;
IGRushort *props;
struct EMSinthold *inthold;

{
  struct EMSpypoint *pyptr, *newpy;
  struct EMSsfintedpar *epptr, *newep;

  *msg = EMS_S_Success;

    inthold->num_inhold++;
    if (inthold->num_inhold == inthold->malloc_at)
      {
      newpy = (struct EMSpypoint *) malloc (inthold->num_inhold * 
               sizeof (struct EMSpypoint));
      EMerr_hndlr (!newpy, *msg, EMS_E_NoDynamicMemory, ret_end);

      OM_BLOCK_MOVE (inthold->pypts, newpy, (inthold->num_inhold-1) *
       sizeof (struct EMSpypoint));
      inthold->pypts = newpy;
   
      if (inthold->epars)
        {
        newep = (struct EMSsfintedpar *) malloc (inthold->num_inhold *
                 sizeof (struct EMSsfintedpar));
        EMerr_hndlr (!newep, *msg, EMS_E_NoDynamicMemory, ret_end);

        OM_BLOCK_MOVE (inthold->epars, newep, (inthold->num_inhold-1) * 
         sizeof (struct EMSsfintedpar));
        inthold->epars = newep;
        }
      }
    else if (inthold->num_inhold > inthold->malloc_at)
      {
      inthold->pypts = (struct EMSpypoint *) realloc
                       (inthold->pypts, inthold->num_inhold * 
                       sizeof (struct EMSpypoint));
      EMerr_hndlr (!inthold->pypts, *msg, EMS_E_NoDynamicMemory, ret_end);

      if (inthold->epars)
        {
        inthold->epars = (struct EMSsfintedpar *) realloc
                         (inthold->epars, inthold->num_inhold * 
                         sizeof (struct EMSsfintedpar));
        EMerr_hndlr (!inthold->epars, *msg, EMS_E_NoDynamicMemory, ret_end);
        }
      }
    
    pyptr = &inthold->pypts[inthold->num_inhold-1];
    pyptr->span_inx = cspan;
    pyptr->param = cpar;
    pyptr->props = *props;
    OM_BLOCK_MOVE (intpt, pyptr->point, 2 * sizeof (IGRdouble));

    if (inthold->epars)
      {
      epptr = &inthold->epars[inthold->num_inhold-1];
      epptr->intloc = wtype;
      epptr->edgepar.span_inx = wspan;
      epptr->edgepar.param = wpar;
      epptr->edgeid = edge;
      OM_BLOCK_MOVE (intpt, epptr->point, 2 * sizeof (IGRdouble));
      }

ret_end :
;
}






/*
 * EMint_process:
 *
 * This function is used to create the two linked lists - EMSpypoint
 * and EMSsfintedpar. Some processing of the data may be required in the
 * case of partinfo being non-NULL.
 */

void EMint_process (msg, winters, cinters, wspan, cspan, wpar, cpar,
                    wtype, ctype, intpt, wedgeid, cprops, partinfo)
IGRlong *msg;
struct EMSsfintedpar **winters;
struct EMSpypoint **cinters;
IGRint wspan, cspan;
IGRdouble wpar, cpar;
enum EMScvinttype wtype, ctype;
IGRdouble *intpt;
GRobjid wedgeid;
IGRushort cprops;
struct EMSpartedinfo *partinfo;
{
  IGRint start_parinx, stop_parinx;
  IGRlong msg_loc;
  struct EMSpypoint *pyptnode;
  struct EMSsfintedpar *eparnode;
  struct EMSedgebound inpar, outpar;
  struct EMSpypoint *EMmkpyptlist();
  struct EMSsfintedpar *EMmkeparlist();
  void EMcnvtedpar();

  *msg = EMS_S_Success;

  if (cinters)
    {
    pyptnode = EMmkpyptlist (&msg_loc, cinters, cspan, cpar, intpt, cprops, 
                NULL, 2, FALSE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    }
  else
    pyptnode = NULL;

  if (winters)
    {
    if (partinfo)
      {
      inpar.span_inx = wspan;
      inpar.param = wpar;
      start_parinx = (partinfo->edprops & EMED_REVERSED ? 1 : 0);
      stop_parinx = (partinfo->edprops & EMED_REVERSED ? 0 : 1);
      EMcnvtedpar (&msg_loc, &partinfo->edbdry[start_parinx], 
       &partinfo->edbdry[stop_parinx], &inpar, &outpar);
      wspan = outpar.span_inx;
      wpar = outpar.param;
      }
       
    eparnode = EMmkeparlist (&msg_loc, winters, wtype, wedgeid, wspan, wpar,
                intpt, pyptnode, FALSE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
    if (pyptnode)
      pyptnode->info = (IGRchar *) eparnode;
    }

ret_end:;
}



/*
 * EMint_afterprocess:
 *
 * This function is used to process those intersections that have been
 * deferred until all the intersections are in. Primarily those which
 * fall on end-points of C-segments. Any duplicate interesections are
 * rejected. The rest are output using EMint_process. Under an option
 * setting (EMS_INTER_ONEOFTWO, vide emsinterdef.h).
 */

void EMint_afterprocess (msg, options, winters, cinters,
                         num_inters, inthold, partinfo)
IGRlong *msg;
IGRushort options;
struct EMSsfintedpar **winters;
struct EMSpypoint **cinters;
IGRint *num_inters;
struct EMSinthold *inthold;
struct EMSpartedinfo *partinfo;
{
  IGRushort cprops;
  IGRint i, j, num_proc, wspan, cspan;
  IGRlong msg_loc;
  IGRdouble wpar, cpar, intpt[2];
  IGRdouble searchkey, nodekey;
  GRobjid wedgeid;
  enum EMScvinttype wtype, ctype;
  struct EMSpypoint *pyptr, *pyptr1, *pyptr2;
  struct EMSsfintedpar *epptr;
  void EMint_process();

  *msg = EMS_S_Success;
  num_proc = inthold->num_inhold;  

  pyptr = inthold->pypts;
  for (i=0; i<inthold->num_inhold; i++)
    {
    pyptr1 = &pyptr[i];
    searchkey = pyptr1->span_inx + pyptr1->param;
    for (j=i+1; j<inthold->num_inhold; j++)
      {
      pyptr2 = &pyptr[j];
      if (pyptr2->span_inx >= 0)
        {
        nodekey = pyptr2->span_inx + pyptr2->param;
        if (fabs (nodekey - searchkey) < MINDOUBLE)
          {
          pyptr2->span_inx = -1;
          if (! (options & EMS_INTER_ONEOFTWO))
            {
            pyptr1->span_inx = -1;
            if (inthold->epars)
              {
              inthold->epars[i].edgepar.span_inx = -1;
              inthold->epars[j].edgepar.span_inx = -1;
              }
            num_proc -= 2;
            }
          else
            num_proc--;
          }
        }
      }
    }

  if (num_proc)
    {
    wspan = cspan = 0;
    wpar = cpar = 0.0;
    wtype = ctype = EMScvint_unknown;
    cprops = NULL;
    wedgeid = NULL_OBJID;
    for (i=0; i<inthold->num_inhold; i++)
      {
      pyptr = &inthold->pypts[i];
      if (pyptr->span_inx >= 0)
        {
        cspan = pyptr->span_inx;
        cpar = pyptr->param;
        cprops = pyptr->props;
        OM_BLOCK_MOVE (pyptr->point, intpt, 2 * sizeof (IGRdouble));

        if (inthold->epars)
          {
          epptr = &inthold->epars[i];
          wspan = epptr->edgepar.span_inx;
          wpar = epptr->edgepar.param;
          wtype = epptr->intloc;
          wedgeid = epptr->edgeid;
          }
        EMint_process (&msg_loc, winters, cinters, wspan, cspan, wpar, cpar,
         wtype, ctype, intpt, wedgeid, cprops, partinfo);
        EMerr_hndlr (EMSerror (msg_loc), *msg, msg_loc, ret_end);
        }
      }
    (*num_inters) += num_proc;
    }

ret_end:;
}



/*
 * EMendint_process:
 * 
 * This function can be called to process intersections on a polyline to
 * further classify and remove intersections that are non-cutting and lie
 * at the end-points. This is specially useful when the intersections
 * have been obtained with the options set to return end-point intersections
 * regardless of them being cutting or not. If there are more than one
 * potentially non-cutting interesctions at an end-point this function
 * will not remove any of those, but will return a an EMS_I_Ambiguous
 * code indicating the condition.
 */

void EMendint_process (msg, numint, pylist)
IGRlong *msg;
IGRint *numint;
struct EMSpypoint **pylist;
{
  IGRushort props, zeroatstart, zeroatstop;
  IGRint i, numint_loc, num_atstart, num_atstop;
  struct EMSpypoint *pypt, *pypt_zeroatstart, *pypt_zeroatstop;
  struct EMSpypoint *prevpypt, *prevpypt_zeroatstart, *prevpypt_zeroatstop;
  void EMpypoint_free();
 
  *msg = EMS_S_Success;

  num_atstart = 0;
  num_atstop = 0;
  if (*numint)
    {
    /*
     * Determine the points lying at the start/stop and those
     * which are "zero-ends".
     */

    zeroatstart = EMS_PYPT_AREAHOLE | EMS_PYPT_HOLEHOLE;
    zeroatstop = EMS_PYPT_HOLEAREA | EMS_PYPT_HOLEHOLE;
    prevpypt_zeroatstart = NULL;
    prevpypt_zeroatstop = NULL;
    pypt_zeroatstart = NULL;
    pypt_zeroatstop = NULL;
    numint_loc = *numint;
    prevpypt = NULL;
    pypt = *pylist;
    for (i=0; i<numint_loc; i++)
      {
      props = pypt->props;
      if (props & EMS_PYPT_ATSTART)
        {        
        num_atstart++;
        if (props & zeroatstart)
          {
          prevpypt_zeroatstart = prevpypt;
          pypt_zeroatstart = pypt;
          }
        }
      else if (props & EMS_PYPT_ATSTOP)
        {
        num_atstop++;
        if (props & zeroatstop)
          {
          prevpypt_zeroatstop = prevpypt;
          pypt_zeroatstop = pypt;
          }
        }
      prevpypt = pypt;
      pypt = pypt->next;
      }

    /*
     * Only if at start/stop there is a single point and it is
     * a zero-end, remove it from the list.
     */

    if (pypt_zeroatstart && num_atstart == 1)
      {
      if (prevpypt_zeroatstart)
        prevpypt_zeroatstart->next = pypt_zeroatstart->next;
      else
        *pylist = pypt_zeroatstart->next;
      (*numint)--;

      if (prevpypt_zeroatstop == pypt_zeroatstart)
        prevpypt_zeroatstop = prevpypt_zeroatstart;
      EMpypoint_free (pypt_zeroatstart, 1);
      }
    if (pypt_zeroatstop && num_atstop == 1)
      {
      if (prevpypt_zeroatstop)
        prevpypt_zeroatstop->next = pypt_zeroatstop->next;
      else
        *pylist = pypt_zeroatstop->next;
      (*numint)--;

      EMpypoint_free (pypt_zeroatstop, 1);
      }
    }

  /*
   * If there are more than one points at the start or the ends, the
   * return code is set to indicate the ambiguous case.
   */

  if (num_atstart > 1 || num_atstop > 1)
    *msg = EMS_I_Ambiguous;
  return;
}
