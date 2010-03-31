#include "EMS.h"
#include <string.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "msdef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "igetypedef.h"
#include "dpstruct.h"
#include "dp.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "ex.h"
#include "igrdef.h"
#include "dpmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "bserr.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "SKdef.h"
#include "SKinc.h"

#define FIRST  0
#define SECOND 1

#define X 0
#define Y 1

void SKaddvarlist (msg, opts, varlist, props, varobj, constrid1, constrid2,
                   var, varname)
IGRlong *msg;
IGRushort opts;
struct SKsolvevars **varlist;
IGRushort props;
GRobjid varobj;
IGRint constrid1, constrid2;
IGRdouble *var;
IGRchar *varname;
{
  IGRint lenstr;
  IGRlong stat_func;
  struct SKsolvevars *node, *locvarlist;

  *msg = EMS_S_Success;
  stat_func = TRUE;

  /*
   * Check if the varobj already exists in the list. If so, use
   * that node, else malloc and intialize one.
   */

  node = NULL;
  if (*varlist && opts & SK_GETVR_COMPRESSED)
    {
    node = *varlist;
    while (node && node->varobj != varobj)
      node = node->next;
    }
  if (!node)
    {
    node = (struct SKsolvevars *) om$malloc (size =
            sizeof (struct SKsolvevars));
    EMerr_hndlr (!node, *msg, EMS_E_NoDynamicMemory, ret_end);
    node->props = NULL;
    node->varname = NULL;
    node->var[0] = 0.0;
    node->var[1] = 0.0;
    node->var[2] = 0.0;
    node->next = NULL;

    if (*varlist)
      {
      locvarlist = *varlist;
      while (locvarlist->next)
        locvarlist = locvarlist->next;
      locvarlist->next = node;
      }
    else
      *varlist = node;
    }

  /*
   * Move the new values into the fields of the node to be updated
   */

  node->props |= props;
  if (varname)
    {
    if ((lenstr = strlen (varname)) > VAR_STATIC_NAMESIZE)
      node->varname = om$malloc (size = (lenstr+1) * sizeof (IGRchar));
    else
      node->varname = node->varname_store;
    EMerr_hndlr (!node->varname, *msg, EMS_E_NoDynamicMemory, ret_end);
    strcpy (node->varname, varname);
    }
  node->varobj = varobj;
  node->constrid1 = constrid1;
  node->constrid2 = constrid2;

  if (var)
    {
    if ((props & VAR_PT) == VAR_PT)
      OM_BLOCK_MOVE (var, node->var, 2 * sizeof (IGRdouble));
    else if (props & VAR_FIRSTDIM)
      node->var[0] = *var;
    else if (props & VAR_SECONDDIM)
      node->var[1] = *var;
    }

ret_end:
  EMWRAPUP (*msg, stat_func, "SKaddvarlist");
  return;
}


void SKfreevarlist (varlist, numnodes)
struct SKsolvevars *varlist;
IGRint numnodes;
{
  IGRboolean flag;
  struct SKsolvevars *locvarlist;

  if (varlist)
    {
    flag = (numnodes ? TRUE : FALSE);
    while ((flag ? numnodes-- : TRUE) && varlist)
      {
      locvarlist = varlist->next;
      if (varlist->varname && varlist->varname != varlist->varname_store)
        om$dealloc (ptr = varlist->varname);
      om$dealloc (ptr = varlist);
      varlist = locvarlist;
      }
    }

  return;
}

/*
  DESCRIPTION
 
    This function is used to search a "solvevars" linked list for a particular
    variable. Each node corresponds to a single object. Since each node can
    potentially store upto two variables - X/V and Y - the varobj/varprops
    pair fully specifies the variable being searched for. Both X and Y
    of a given varobj can be searched for simultaneously. The output is
    the linked-list node(s) and the index(es). 

    The function returns TRUE if a node satisfying the varobj-varprops
    criteria is found. If X and Y are specified in varprops, then both
    props must be found in the varobj-node for a TRUE to be returned.
*/

IGRboolean SKvarlistinx (varlist, varobj, varprops, varnode, listinx)
struct SKsolvevars *varlist;
GRobjid varobj;
IGRushort varprops;
struct SKsolvevars **varnode;
IGRint *listinx;
{
  IGRushort need_varprops, chkprops;
  IGRint found;
  IGRint i, inx, inxlim, loc_varinx;
  GRobjid need_varobj;
  struct SKsolvevars *loc_varlist;

  if (varprops & VAR_FIRSTDIM && varprops & VAR_SECONDDIM)
    {
    inxlim = 2;
    if (varnode)
      varnode[FIRST] = varnode[SECOND] = NULL;
    }
  else
    {
    inxlim = 1;
    if (varnode)
      varnode[FIRST] = NULL;
    }

  found = FALSE;
  for (inx=0; inx<inxlim; inx++)
    {
    found = FALSE;
    loc_varinx = 0;

    need_varobj = varobj;
    if (inx == FIRST)
      {
      if (! (need_varprops = varprops & VAR_FIRSTDIM))
        need_varprops = varprops & VAR_SECONDDIM;
      }
    else
      need_varprops = varprops & VAR_SECONDDIM;

    loc_varlist = varlist;
    while (loc_varlist)
      {
      for (i=FIRST; i<=SECOND; i++)
        {
        chkprops = (i == FIRST ? VAR_FIRSTDIM : VAR_SECONDDIM);
        if (loc_varlist->varobj == need_varobj &&
            (loc_varlist->props & chkprops) & need_varprops)
          {
          found = TRUE;
          if (listinx)
            listinx[inx] = loc_varinx;
          if (varnode)
            varnode[inx] = loc_varlist;
          break;
          }
        if (loc_varlist->props & chkprops)
          loc_varinx++;
        }
      if (found)
        break;
  
      loc_varlist = loc_varlist->next;
      }

    if (!found)
      break;
    }

  return (found);
}

/*
  Given an index into the list, this function returns the node corresponding
  to that index
*/

IGRboolean SKvarlistnode (varlist, inx, varnode)
struct SKsolvevars *varlist;
IGRint inx;
struct SKsolvevars **varnode;
{
  IGRboolean found;
  IGRint i, curr_inx;

  found = FALSE;
  curr_inx = -1;
  while (varlist)
    {
    for (i=FIRST; i<=SECOND; i++)
      {
      if (varlist->props & (i == FIRST ? VAR_FIRSTDIM : VAR_SECONDDIM))
        curr_inx++;

      if (curr_inx == inx)
        {
        *varnode = varlist;
        found = TRUE;
        break;
        }
      }
    if (found)
      break;
    varlist = varlist->next;
    }

  return (found);
}


IGRboolean SKremovevar (varnode, varlist)
struct SKsolvevars *varnode, **varlist;
{
  IGRboolean found;
  struct SKsolvevars *curnode, *prevnode, *nextnode;

  found = FALSE;
  curnode = *varlist;
  prevnode = NULL;
  while (curnode)
    {
    if (curnode == varnode)
      {
      found = TRUE;
      nextnode = curnode->next;
      break;
      }
    prevnode = curnode;
    curnode = curnode->next;
    }

  if (found)
    {
    if (prevnode)
      prevnode->next = nextnode;
    else
      *varlist = nextnode;
    }

  return (found);
}


void SKmerge_vars (vars)
struct SKsolvevars *vars;
{
  struct SKsolvevars *temp_var, **temp_var_ptr;

  while (vars)
    {
    if (vars->props & VAR_X ^ vars->props & VAR_Y)
      {
      temp_var = vars->next;
      temp_var_ptr = &vars->next;
      while (temp_var)
        {
        if (vars->varobj == temp_var->varobj)
          {
          if (temp_var->props & VAR_X)
            vars->var[X] = temp_var->var[X];
          else
            vars->var[Y] = temp_var->var[Y];
          vars->props |= VAR_PT;

          (*temp_var_ptr) = temp_var->next;
          om$dealloc (ptr = temp_var);

          break;
          }
        temp_var_ptr = &temp_var->next;
        temp_var = temp_var->next;
        }
      }
    vars = vars->next;
    }

  return;
}

/*
void SKcompressvarlist (varlist, numvalid)
struct SKsolvevars *varlist;
IGRint *numvalid;
{
  IGRboolean found;
  IGRushort otherprops;
  IGRshort inx;
  IGRint numgood;
  struct SKsolvevars *curnode, *lastnode, *othernode;

  curnode = varlist;
  while (curnode)
    {
    curnode->props &= ~VAR_MARKER;
    curnode = curnode->next;
    }

  numgood = 0;
  curnode = varlist;
  while (curnode)
    {
    if (curnode->props & VAR_MARKER)
      {
      othernode = curnode->next;
      SKremovevar (curnode, &varlist);
      lastnode = varlist;
      while (lastnode->next)
        lastnode = lastnode->next;
      lastnode->next = curnode;
      curnode->next = NULL;
      curnode = othernode;
      while (curnode && curnode->props & VAR_MARKER)
        curnode = curnode->next;
      }
    else
      {
      if (curnode->props & VAR_PT &&
          (curnode->props & VAR_X ^ curnode->props & VAR_Y))
        {
        otherprops = curnode->props & VAR_X ? VAR_Y : VAR_X;
        othernode = curnode->next;
        found = FALSE;
        while (othernode)
          {
          if (othernode->props & otherprops &&
              !(othernode->props & VAR_MARKER))
            {
            found = TRUE;
            break;
            }
          othernode = othernode->next;
          }
        if (found)
          {
          inx = otherprops & VAR_X ? X : Y;
          OM_BLOCK_MOVE (&othernode->var[inx], &curnode->var[inx],
           sizeof (IGRdouble));
          if (inx == X)
            curnode->constrid1 = othernode->constrid1;
          else
            curnode->constrid2 = othernode->constrid2;
          curnode->props |= otherprops;
          othernode->props |= VAR_MARKER;
          }
        }
      numgood++;
      curnode = curnode->next;
      }
    }

  curnode = varlist;
  while (curnode)
    {
    curnode->props &= ~VAR_MARKER;
    curnode = curnode->next;
    }

  *numvalid = numgood;
  return;
}
*/
