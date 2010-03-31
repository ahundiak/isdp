/*
  ABSTRACT

  Handles the GRprint and GRread messages for just the DPR nodes that are
  true Booleans with two (and only two operands). No other types of nodes
  using this class are handled. An appropriate error code is returned.


  HISTORY

  SS  :  03/26/96  :  Creation
*/

class implementation EMSsfboolean;

%safe
#include <string.h>
#include <math.h>
%endsafe

#include "bserr.h"
#include "bsparameters.h"
#include "PWminimum.h"
#include "PWerror.h"
#include "PWgmdata.h"
#include "PWapi/clsid.h"
#include "PWapi/featquery.h"
#include "PWapi/xyztol.h"
#include "PWapi/sftype.h"
#include "PWapi/prminim.h"
#include "PWapi/rdminim.h"

#define MATCH 0

extern IGRboolean _Pathway, _pathway_trim, _pathway_orient;

%safe
static char *getboolstr (enum PWbooltype booltype, char *str);
static enum PWbooltype getbooltype (char *str);
%endsafe

method GRprint
(
  FILE *file;
  IGRint num_indent;
  IGRboolean print_super_class;
  IGRboolean print_full_format; 
)
{
  char space=' ', indent[GR_MAX_CHAR], str[GR_MAX_CHAR];
  int opinx;
  IGRuint num_comps=0;
  PWresult result=PW_K_Success;
  enum PWbooltype booltype;
  OM_S_CHANSELECT chan_to_comps;
  OM_S_OBJECT_LINKAGE comps[2];

  if (pwIsBooleanObj (my_id, OS, &booltype))
  {
    EMmake_chanselect (GRcmpowner_to_components, &chan_to_comps);
    om$get_channel_objects (object = me, 
     p_chanselect = &chan_to_comps, size = 2, 
     count = &num_comps, list = comps,);
    OnErrorState (num_comps != 2, result, SetError (PW_K_Pathway, 
     PW_K_BadData), wrapup);

    /*
     * First give the chance to all the operands to write themselves
     * out. In the case of an intersect-plane save-side the geometry of
     * the plane is explicitly written out by this method.
     */

    for (opinx=FIRST; opinx<=SECOND; opinx++)
    {
      if (opinx == SECOND && booltype == PWbool_saveside)
        continue;
      else
      {
        result = om$send (msg = OPPmargs, targetid = comps[opinx].S_objid,
                  senderid = PW_K_NullObjid);
        OnErrorCode (result, wrapup);
      }
    }

    /*
     * Now write out this object
     */

    if (num_indent)
      memset (indent, space, num_indent * sizeof (char));
    indent[num_indent] = '\0';

    pwPrintId (file, num_indent, my_id, OS); 
    fprintf (file, "%s  %s\n", indent, getboolstr (booltype, str));
    fprintf (file, "%s  %7.14lf (cht)\n", indent, ME.EMSsfboolean->cht);
    fprintf (file, "%s  %7.14lf (bastol)\n", indent, pwActiveXYZLenTol());
    fprintf (file, "%s  Pathway %s\n", indent, 
     ME.EMSdpr->dpr_props & EMS_POST310_OBJECT ? "ON" : "OFF");
    fprintf (file, "%s  First Operand:\n", indent);
    pwPrintId (file, num_indent+4, comps[FIRST].S_objid, OS);
    fprintf (file, "%s  Second Operand:\n", indent);
    if (booltype != PWbool_saveside)
      pwPrintId (file, num_indent+4, comps[SECOND].S_objid, OS);
    else
    {
    }
  }

wrapup:
  PW_WrapupId (result, "EMsfbprtrd.I-GRprint", my_id);
  return (result);
}


method GRread
(
  FILE *file;
  IGRboolean read_super_class;
  IGRboolean read_full_format;
)
{
  char line[GR_MAX_CHAR], whitespace[4]=" \n\t",  *token;
  int linenum=1;
  double cht, bastol, save_cht, save_bastol;
  IGRlong msg_loc, bs_msg;
  PWboolean done=FALSE, pathway, save_pw, save_pw_trim, save_pw_orient;
  PWresult result=PW_K_Success;
  PWobjid first_op, second_op;
  enum PWbooltype booltype;

  /*
   * Assume the file is positioned to read this class's specific data
   */

  while (!done && fgets (line, GR_MAX_CHAR, file))
  {
    switch (linenum++)
    {
      case 1:
        token = strtok (line, whitespace);
        booltype = getbooltype (token);
        OnErrorState (booltype == PWbool_unknown, result, 
         SetError (PW_K_Pathway, PW_K_BadData), wrapup);
        break;

      case 2:
        token = strtok (line, whitespace);
        sscanf (token, "%lf", &cht);
        break;

      case 3:
        token = strtok (line, whitespace);
        sscanf (token, "%lf", &bastol);
        break;

      case 4:
        token = strtok (line, whitespace);
        token = strtok (NULL, whitespace);
        if (strcmp (token, "ON") == MATCH)
          pathway = TRUE;
        else
          pathway = FALSE;
        break;

      case 5:
        token = strtok (line, whitespace);
        OnErrorState (strcmp (token, "First") != MATCH, result,
         SetError (PW_K_Pathway, PW_K_BadData), wrapup);
        
        linenum++;
        result = ReadObject (file, OS, read_full_format, FALSE, FALSE, 
                  &first_op);
        OnErrorState (result != PW_K_Success, result, 
         SetError (PW_K_Pathway, PW_K_BadData), wrapup);
        break;

      case 7:
        token = strtok (line, whitespace);
        OnErrorState (strcmp (token, "Second") != MATCH, result,
         SetError (PW_K_Pathway, PW_K_BadData), wrapup);

        linenum++;
        if (booltype != PWbool_saveside)
        {
          result = ReadObject (file, OS, read_full_format, FALSE, FALSE,
                    &second_op);
          OnErrorState (result != PW_K_Success, result, 
           SetError (PW_K_Pathway, PW_K_BadData), wrapup);
        }
        done = TRUE;
        break;
    }
  }

  OnErrorState (!done, result, SetError (PW_K_Pathway, PW_K_BadData),
   wrapup);

  /*
   * Now that this object's instance data is gathered up, perform the Boolean
   * operation that completes the initialization of this node.
   */

  BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, save_cht);
  BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, save_bastol);
  BSchangepar (&bs_msg, BSTOLCHRDHT, cht);
  BSchangepar (&bs_msg, BSTOLLENVEC, bastol);

  save_pw = _Pathway;  
  save_pw_trim = _pathway_trim;  
  save_pw_orient = _pathway_orient;  
  if (pathway)
  {
    _Pathway = TRUE;
    _pathway_trim = TRUE;
    _pathway_orient = TRUE;
  }
  else
  {
    _Pathway = FALSE;
    _pathway_trim = FALSE;
    _pathway_orient = FALSE;
  }

  if (booltype == PWbool_union)
    result = pwSfBooleanUnion (first_op, second_op, OS, FALSE, &my_id);
  else if (booltype == PWbool_difference)
    result = pwSfBooleanDifference (first_op, second_op, OS, FALSE, &my_id);
  else if (booltype == PWbool_intersection)
    result = pwSfBooleanIntersection (first_op, second_op, OS, FALSE, &my_id);

  BSchangepar (&bs_msg, BSTOLCHRDHT, save_cht);
  BSchangepar (&bs_msg, BSTOLLENVEC, save_bastol);

  if (_Pathway)
    ME.EMSdpr->dpr_props |= EMS_POST310_OBJECT;
  else
    ME.EMSdpr->dpr_props &= ~EMS_POST310_OBJECT;

  _pathway_trim = save_pw_trim;  
  _pathway_orient = save_pw_orient;  

wrapup:
  PW_WrapupId (result, "EMsfbprtrd.I-GRread", my_id);
  return (result);
}


/*------------------------- STATIC FUNCTIONS ------------------------------*/

static char *getboolstr
(
  enum PWbooltype booltype,
  char *str
)
{
  if (booltype == PWbool_union)
    strcpy (str, "Union");
  else if (booltype == PWbool_intersection)
    strcpy (str, "Intersection");
  else if (booltype == PWbool_difference)
    strcpy (str, "Difference");
  else if (booltype == PWbool_saveside)
    strcpy (str, "Saveside");
  else
    strcpy (str, "*** Unknown ***");

  return (str);
}

static enum PWbooltype getbooltype
(
  char *str
)
{
  if (strcmp (str, "Union") == MATCH)
    return (PWbool_union);
  else if (strcmp (str, "Intersection") == MATCH)
    return (PWbool_intersection);
  else if (strcmp (str, "Difference") == MATCH)
    return (PWbool_difference);
  else if (strcmp (str, "Saveside") == MATCH)
    return (PWbool_saveside);
  else
    return (PWbool_unknown);
}

end implementation EMSsfboolean;
