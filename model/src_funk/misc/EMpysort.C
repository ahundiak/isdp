/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
/*
  DESCRIPTION:
 
    This method sorts a linked list of EMSpypoint structures based on the
    single key - (span_inx + param) - of each of the individual elements.
    
    Optionally, this function assumes that these points represent transition
    points between area and holes. These transitions are reflected in the
    props field of the point-structure. The function attempts to maintain the
    sort such that the points toggle between hole and area. If this is
    impossible (within the limits of zero vector length tolerance specified) 
    an informational code is returned indicating this situation. Also,
    if some ambiguity remained about the topology of the first point,
    a different informational code is returned.

  ARGUMENTS

    pypts 		- Input/Output: The linked list containing the
			   points to be sorted. On output, the sorted list
			   is returned.
    dim			- Input: the dimension of the points to be sorted.
			   Any dimension is valid (including 1).
    toginfo		- Input/Output: Optional flag indicating whether the
			   points must be treated as transitions between
			   hole-area. A test is performed to validate such
			   toggling. If NULL, then such a test is ignored.
			   On input, the relative topology of the region
			   BEFORE the first point is indicated (EMS_L_INAREA,
                           EMS_L_INHOLE or EMS_L_UNKNWN (if not known) -
			   see EMSbnddef.h). If on input the location was
                           not known, this function will try to deduce
			   this information from the rest of the points.
                           This deduced information is then returned as
                           output. This output must be read in conjunction
			   with the return code (see RETURN VALUES).
    lentol		- Input: The tolerance within which two points
			   are regarded as identical. This argument will
			   possibly looked at only if toginfo is non-NULL.

  RETURN VALUE

    This is a function returning void. The return code in the msg argument
    could be one of the following:

    EMS_S_Success
      - If all went well

    If the argument - toginfo is non-NULL:
    EMS_I_Ambiguous
      - If there was insufficient data to unambiguously determine the
        relative location of the region before the first point in the
        geometrically sorted list.
    EMS_I_InvalidArg
      - If there was no topology information stored in the props field
        of each of the points.
      - If the points did not toggle correctly between area and hole.
        The erring consecutive points in the sorted linked list were more
        than "lentol" apart.

    EMS_E_NoDynamicMemory
      - Error encountered while allocating dynamic memory.

  ASSUMPTIONS

    This function assumes that the "key" - as defined above - increases
    by atleast unity while going from the begin point of the geometry
    to it's end-point. This assumption comes into play when the geometry
    is closed and there are points in the linked-list representing the
    two end-points.
    
  HISTORY

    SS  :  01/28/88  :  Modified to infer toginfo even if the first two
                        points are geometrically coincident
    SS  :  10/15/87  :  Modification to simplify argument list and take care
                        of toggling between holes and areas.
*/

#include <math.h>
#include "OMminimum.h"
#include "OMprimitives.h"
#include "EMS.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "EMSmsgdef.h"
#include "emsdattyp.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSbnddef.h"

#define INIT_STORE_SIZE 20

/*
 * If the "key" of two points is apart by more than this constant value, then
 * the two points are not coincident. This is based on the assumption
 * listed above.
 */

#define DISTINCT_KEY_DIFF 0.75

struct store
  {
  IGRdouble key;
  struct EMSpypoint *ptr;
  };

/*
 * Given s properties mask for EMSpypoint, these macros determine the type
 * of region into which the geometry is heading or the type of region
 * from which the geomtry is coming out.
 */

#define is_into_area(props) \
         ((props) & EMS_PYPT_HOLEAREA || (props) & EMS_PYPT_AREAAREA)

#define is_from_area(props) \
         ((props) & EMS_PYPT_AREAHOLE || (props) & EMS_PYPT_AREAAREA)

static void swap();
static IGRboolean swapchk();
static IGRdouble ptptsq(), keykey();

void EMsortpypts (msg, pypts, dim, toginfo, lentol)
IGRlong *msg;
struct EMSpypoint **pypts;
IGRshort dim;
IGRint *toginfo;
IGRdouble *lentol;
{
  IGRboolean firstpt_inarea;
  IGRboolean into_area, next_from_area, nextnext_from_area;
  IGRboolean goodswap, ambiguous;
  IGRushort props, next_props, nextnext_props, bit_mask;
  IGRint i, j, inx, numpts;
  IGRdouble sqlentol, *prev_pt, *pt, *next_pt, *nextnext_pt;
  struct EMSpypoint *pyptr, *lastptr;
  struct store *store, store_mem[INIT_STORE_SIZE];

  /*
   * Initialize 
   */

  *msg = EMS_S_Success;
  store = NULL;

  numpts = 0;
  lastptr = *pypts;
  while (lastptr && (lastptr->span_inx >= 0) &&
         !(lastptr->props & EMS_PYPT_EMPTY))
    {
    lastptr = lastptr->next;
    numpts++;
    }
  if (! numpts)
    goto ret_end;

  /*
   * Transfer information into the
   * work structure.
   */

  if (numpts <= INIT_STORE_SIZE)
    store = store_mem;
  else
    {
    store = (struct store *) malloc (numpts * sizeof (struct store));
    EMerr_hndlr (!store, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  pyptr = *pypts;
  for (i=0; i<numpts; i++)
    {
    store[i].key = pyptr->span_inx + pyptr->param;
    store[i].ptr = pyptr;
    pyptr = pyptr->next;
    }

  /*
   * Sort the work structure list based on the key. The sort list
   * should toggle consistently between hole and area. If it does
   * not, check if the two erring points are within tolerance. If so,
   * reverse positions and so on.
   * Assumption: Hole_hole or area_area transitions occur only at the
   * ends of this linked list (nowhere in the middle). If this is not true
   * the following code does not catch some erring combinations.
   */

  for (i=0; i<numpts-1; i++)
    for (j=0; j<numpts-i-1; j++)
      if (store[j].key > store[j+1].key)
        swap (&store[j], &store[j+1]);

  if (toginfo)
    {
    /*
     * Every point in the linked list must contain properties that indicate
     * their orientation w.r.t the area. If such information is not present,
     * set the return code to indicate that the sort may be invalid.
     */

    pyptr = *pypts;
    bit_mask = EMS_PYPT_HOLEAREA | EMS_PYPT_AREAHOLE |
               EMS_PYPT_AREAAREA | EMS_PYPT_HOLEHOLE;
    for (i=0; i<numpts; i++)
      {
      if (pyptr->props & bit_mask)
        pyptr = pyptr->next;
      else
        EMerr_hndlr (TRUE, *msg, EMS_I_InvalidArg, rearrange);
      }

    if (numpts > 1)
      {
      /*
       * The first two points in this linked list must lie at distinct points
       * along the curve. By distinct is meant that the two points are
       * apart from each other by more than tolerance in the natural as well
       * as the parametric space. This latter criteria is important to
       * differentiate between points lying at the end-points of a closed
       * curve. Assuming that the curves in question do not loop on themselves,
       * the parameters of two points which are within tolerance in
       * the natural space yet parametrically distinct (eg, closed case),
       * must be atleast DISTINCT_KEY_DIFF apart.
       *
       * If it turns out that the first two points are not distinct, there 
       * isn't enough information here, to decide which way the toggle
       * should proceed. If information on whether the starting point is
       * in hole or area has been supplied, use that to clear the ambiguity.
       * If not, search for the next point which is not paired with a
       * duplicate. Use the information in this point to determine if the
       * starting point is in hole or area. If such a determination is not
       * possible, proceed with the default situation but return a code
       * indicating an ambiguous state. Also return whether the first
       * point has been considered as in-hole or in-area.
       */

      sqlentol = *lentol * *lentol;

      /*
       * Check to see if ambiguity exists about the first
       * point.
       */

      pt = store[0].ptr->point;
      next_pt = store[1].ptr->point;
      if (ptptsq (pt, next_pt, dim) <= sqlentol &&
          keykey (store) < DISTINCT_KEY_DIFF)
        ambiguous = TRUE;
      else
        ambiguous = FALSE;

      /*
       * If ambiguity exists and the topology of the first point is
       * not known, see if this topology can be obtained by looking ahead into
       * the rest of the points. The first point starting from inx=2, that
       * is distinct from it's previous and subsequent point in the list,
       * becomes the candidate to obtain topology info from.
       */

      if (ambiguous && *toginfo == EMS_L_UNKNWN && numpts >= 3)
        {
        inx = 2;
        while (inx <= numpts-1 && *toginfo == EMS_L_UNKNWN)
          {
          if (inx < numpts-1)
            {
            prev_pt = store[inx-1].ptr->point;
            pt = store[inx].ptr->point;
            next_pt = store[inx+1].ptr->point;
            if ((ptptsq (prev_pt, pt, dim) <= sqlentol &&
                 keykey (&store[inx-1]) < DISTINCT_KEY_DIFF) ||
                (ptptsq (pt, next_pt, dim) <= sqlentol &&
                 keykey (&store[inx]) < DISTINCT_KEY_DIFF))
              {
              inx += 2;
              continue;
              }
            }
          props = store[inx].ptr->props;
          if (is_from_area (props))
            *toginfo = EMS_L_INAREA;
          else
            *toginfo = EMS_L_INHOLE;
          }
        }

      /*
       * If an ambiguity existed about the first point, alter 
       * the list (if necessary) if the topology of the first point
       * was known. If it was unknown, do the best that can be done with
       * the first two nodes and return an information code.
       */

      if (ambiguous)
        {
        props = store[0].ptr->props;
        if (*toginfo != EMS_L_UNKNWN)
          {
          firstpt_inarea = is_from_area (props);
          if ((firstpt_inarea && *toginfo != EMS_L_INAREA) ||
              (!firstpt_inarea && *toginfo != EMS_L_INHOLE))
            {
            goodswap = swapchk (&store[0], &store[1]);
            EMerr_hndlr (!goodswap, *msg, EMS_I_InvalidArg, rearrange);
            }
          }
        else
          {
          into_area = is_into_area (props);
          next_props = store[1].ptr->props;
          next_from_area = is_from_area (next_props);

          if (into_area && !next_from_area || !into_area && next_from_area)
            swap (&store[0], &store[1]);

          *msg = EMS_I_Ambiguous;
          }
        }
  
      /*
       * Proceed to check (if possible correct) if all the points in the
       * list toggle correctly with respect to starting location of
       * the geometry.
       */

      props = store[0].ptr->props;
      if (is_from_area (props))
        *toginfo = EMS_L_INAREA;
      else
        *toginfo = EMS_L_INHOLE;
  
      for (i=1; i<numpts; i++)
        {
        into_area = is_into_area (props);
        next_props = store[i].ptr->props;
        next_from_area =  is_from_area (next_props);

        if (into_area && next_from_area || !into_area && !next_from_area)
          {
          props = next_props;
          continue;
          }
        else
          {
          EMerr_hndlr (i == numpts-1, *msg, EMS_I_InvalidArg, rearrange);

          next_pt = store[i].ptr->point;
          nextnext_pt = store[i+1].ptr->point;
          EMerr_hndlr (ptptsq (next_pt, nextnext_pt, dim) > sqlentol ||
           keykey (&store[i]) > DISTINCT_KEY_DIFF, *msg, EMS_I_InvalidArg,
           rearrange);
    
          nextnext_props = store[i+1].ptr->props;
          nextnext_from_area = is_from_area (nextnext_props);
          EMerr_hndlr (into_area && !nextnext_from_area || 
           !into_area && nextnext_from_area, *msg, EMS_I_InvalidArg,
           rearrange);

          goodswap = swapchk (&store[i], &store[i+1]);
          EMerr_hndlr (!goodswap, *msg, EMS_I_InvalidArg, rearrange);
          props = nextnext_props;
          }
        }
      }
    }

  /*
   * Rearrange the output based on the
   * sorted local structure array.
   */

rearrange:
  pyptr = *pypts = store[0].ptr;
  for (i=1; i<numpts; i++)
    {
    pyptr->next = store[i].ptr;
    pyptr = pyptr->next;
    }    
  pyptr->next = lastptr;

ret_end:
  if (store && numpts > INIT_STORE_SIZE)
    om$dealloc (ptr = store);
}

static void swap (s1, s2)
struct store *s1, *s2;
{
  struct store temp;

  temp = *s1;
  *s1 = *s2;
  *s2 = temp;
}

static IGRboolean swapchk (s1, s2)
struct store *s1, *s2;
{
  IGRboolean goodswap;
  IGRushort props1, props2, inarea1, inarea2;

  props1 = s1->ptr->props;
  inarea1 = is_from_area (props1) ? 0x1 : 0x0;

  props2 = s2->ptr->props;
  inarea2 = is_from_area (props2) ? 0x1 : 0x0;

  goodswap = inarea1 ^ inarea2;
  if (goodswap)
    swap (s1, s2);
  return (goodswap);
}

static IGRdouble ptptsq (pt1, pt2, dim)
IGRdouble *pt1, *pt2;
IGRshort dim;
{
  IGRint i;
  IGRdouble del, distsq;

  distsq = 0.0;
  for (i=0; i<dim; i++)
    {
    del = pt2[i] - pt1[i];
    distsq += del * del;
    }
  return (distsq);
}

static IGRdouble keykey (store)
struct store *store;
{
  IGRdouble keydist;
  struct EMSpypoint *py1, *py2;

  py1 = store[0].ptr;
  py2 = store[1].ptr;
  keydist = (py1->span_inx + py1->param) - (py2->span_inx + py2->param);
  return (fabs (keydist));
}

