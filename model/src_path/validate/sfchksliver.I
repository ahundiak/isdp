class implementation EMSsurface;

#include "PWminimum.h"
#include "PWerror.h"
#include "PWapi/sfdntrav.h" 
#include "PWapi/sfchksliver.h" 

%safe
struct s_chksliver
{
  short mattyp;
  double *mat;
  double xyztol;
  int num_samplepts;

  int num_sliver_sfs;
  PWobjid **sliver_sfs;
};

static PWresult chksliver
(
  PWobjid sfobj,
  PWosnum os,
  void *d_chksliver
);
%endsafe

/*
  DESCRIPTION

  The following API can be used to return all the simple surfaces inside a
  surface entity (which may be a simple surface itself, in the limiting case)
  that has a "sliver" boundary -- 'sliver_sfs'. The memory for the output is
  malloc-ed by the function. This argument can be NULL if the caller is not
  interested in the surface ids.

  A sliver is defined when two distinct edges of a simple surface share an
  overlapping region. An extreme form of slivers is when the entire natural 
  surface is degenerate. In this case, each of the four natural edges of the
  surface seem to overlap every other.

  The XYZ tolerance within which two edges are said to be close enough for an
  overlap has to be input (usually the cht). Also, the number of sample-points
  to be used to detect overlap needs to be passed in. This is a trade-off
  that is in the hands of the caller. Recommended number is 3.

  The processing will be interrupted if the user hits the "Stop" sign during
  the process. The number of surfaces being returned in such a case is always
  zero!


  RETURN VALUE

  The function returns the number of simple surfaces that are found with
  slivers. 


  BUGS

  This version of the function cannot faithfully detect slivers formed when
  two edges partially overlap. Atleast one of the edges in the overlapping
  pair needs to be completely overlapped by the other.

  Also, if the natural surface is such that two opposite sides of the surface
  are overlapping each other, this function does not detect those case. Note
  that in this case, the boundary in parametric space looks perfectly clean.
  The overlap in this case is purely in XYZ.


  HISTORY

  SS    : 02/28/96  :  Creation
*/

int pwGetSliverSfs
(
  PWobjid sfobj,
  PWosnum os,
  short mattyp,
  PWmatrix mat,
  double xyztol,
  int num_samplepts,
  PWobjid **sliver_sfs
)
{
  PWresult result=PW_K_Success;
  struct s_chksliver d_chksliver;

  if (sliver_sfs)
    *sliver_sfs = NULL;

  d_chksliver.mattyp = mattyp;
  d_chksliver.mat = mat;
  d_chksliver.xyztol = xyztol;
  d_chksliver.num_samplepts = num_samplepts;

  d_chksliver.num_sliver_sfs = 0;
  d_chksliver.sliver_sfs = sliver_sfs;

  result = pwTraverseSfSfs (sfobj, os, 
            (PWresult (*)()) chksliver, (void *) &d_chksliver);
  if (GetCode (result) == PW_K_Interrupt)
  {
    d_chksliver.num_sliver_sfs = 0;
    if (sliver_sfs && *sliver_sfs)
    {
      free (*sliver_sfs);
      *sliver_sfs = NULL;
    }
  }

  return (d_chksliver.num_sliver_sfs);
}


/*-------------------  Static function ----------------------*/

static PWresult chksliver
(
  PWobjid sfobj,
  PWosnum os,
  void *pd_chksliver
)
{
  int nsfs;
  IGRlong msg_loc;
  PWresult result=PW_K_Success;
  PWobjid *sfs;
  struct s_chksliver *d_chksliver;

  d_chksliver = (struct s_chksliver *) pd_chksliver;

  result = om$send (msg = message EMSsurface.EMchksliver (&msg_loc,
            EMS_O_External | EMS_O_Internal | EMS_O_Majority | EMS_O_Stop,
            &d_chksliver->mattyp, d_chksliver->mat, d_chksliver->xyztol,
            d_chksliver->num_samplepts, NULL, NULL), targetid = sfobj,
            targetos = os, senderid = PW_K_NullObjid);
  if (!IsError (result & msg_loc))
  {
    if (msg_loc == EMS_I_Found)
    {
      /*
       * A sliver surface has been found. Return it's details. 
       * Set return code to reflect the "found".
       */

      nsfs = ++(d_chksliver->num_sliver_sfs);
      if (d_chksliver->sliver_sfs)
      {
        sfs = *d_chksliver->sliver_sfs;
        if (sfs)
          sfs = (PWobjid *) realloc (sfs, nsfs * sizeof (PWobjid));
        else
          sfs = (PWobjid *) malloc (sizeof (PWobjid));

        if (sfs)
          sfs[nsfs-1] = sfobj;

        *d_chksliver->sliver_sfs = sfs;
      }
      result = SetInfo (PW_K_Pathway, PW_K_Found);
    }

    else if (msg_loc == EMS_I_Interrupt)
    {
      /*
       * A user interrup took place (Stop button).
       * Set return code to reflect the interrup.
       */

      result = SetInfo (PW_K_Pathway, PW_K_Interrupt);
    }

    else 
    {
      /*
       * No sliver surface was found.
       * Set return code to reflect the "not found".
       */

      result = SetInfo (PW_K_Pathway, PW_K_NotFound);
    }
  }
 
  else
  {
    /*
     * An internal error occurred. But continue the processing on to other
     * surfaces in the traversal. Set return code to an informational to
     * reflect the "internal error". 
     */

    result = SetInfo (PW_K_Pathway, PW_K_Internal);
  }

  return (result);
}

end implementation EMSsurface;

