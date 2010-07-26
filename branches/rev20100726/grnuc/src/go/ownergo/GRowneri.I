/* #######################    APOGEE COMPILED   ######################## */

/*\
Description
    The following messages are passed to the unknown message handler 
    which will pass them to the components.

History
    Gray Winn       10/15/87    Design and Coding date.
    jay wallingford 04/27/89    Optimized the making of the chanselect
    scott walters   06/23/92    Added static ANSI C prototypes
\*/
   
class implementation GRowner;

#include "OMmacros.h"
#include "grimport.h"
#include "gocmacros.h"
#include "msdef.h"

extern int   GRget_to_comp_chansel();

%safe
static IGRboolean elig_chk ();
%endsafe



method GRchghprops(long *msg; short *action; int *mask)
{
    long           om_msg;
    OM_S_CHANSELECT   chansel;

    if ( om_msg = GRget_to_comp_chansel ( &chansel ) ) 
    {
        om_msg = om$send (msg = message GRvg.GRchghprops (msg, action, mask),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);

    }

    return (om_msg);
}

method GRchgcolor(long *msg; 
                  int unsigned *rgb_value; 
                  short unsigned *color)
{
    long           om_msg;
    OM_S_CHANSELECT   chansel;

    if ( om_msg = GRget_to_comp_chansel ( & chansel ) ) 
    {

        om_msg = om$send (msg = message GRvg.GRchgcolor (msg, rgb_value, color),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
    }

   return (om_msg);
}

method GRchgdp(long *msg; struct IGRdisplay *dp_info)
{
    long           om_msg;
    OM_S_CHANSELECT   chansel;

    if ( om_msg = GRget_to_comp_chansel ( & chansel ) ) 
    {
        om_msg = om$send ( msg = message GRvg.GRchgdp (msg, dp_info),
                           p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
    }

    return (om_msg);
}

method GRchglevel(long *msg; short *level)
{
    long           om_msg;
    OM_S_CHANSELECT   chansel;
    
    if ( om_msg = GRget_to_comp_chansel ( &chansel ) ) 
    {
        om_msg = om$send (msg = message GRvg.GRchglevel (msg, level),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
    }

    return (om_msg);
}


method GRchgstyle(long *msg; char unsigned *style)
{
    long         om_msg;
    OM_S_CHANSELECT chansel;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        om_msg = om$send (msg = message GRvg.GRchgstyle (msg, style),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
    }
    return (om_msg);
}

method GRchgweight(long *msg; char unsigned *weight)
{
    long         om_msg;
    OM_S_CHANSELECT chansel;

    if ( om_msg = GRget_to_comp_chansel( &chansel ) ) 
    {
        om_msg = om$send (msg = message GRvg.GRchgweight (msg, weight),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
    }

    return (om_msg);
}

method GRputsymb(long *msg; struct GRsymbology *symb)
{
    long         om_msg;
    OM_S_CHANSELECT chansel;

    if ( GRget_to_comp_chansel( &chansel ) ) 
    {
        om_msg = om$send (msg = message GRvg.GRputsymb (msg, symb),
                          p_chanselect = &chansel);

        GR_NOTIFY_LISTENERS(msg, &om_msg, GR_ATTR_MODIFIED);
    }

    return (om_msg);
}

method GRget_siblings (long *msg; unsigned short opts;
                       int *num_siblings; struct GRid **siblings;
                       int num_buff; struct GRid *buff)
{
  *msg = MSSUCC;
  *num_siblings = 0;
  *siblings = NULL;
  return (OM_S_SUCCESS);
}

method GRpass_messg (long *msg; unsigned short opts;
                     OM_E_WRT_FLAG wrt_flag;
                     OM_p_MESSAGE messg;
                     struct GRmdenv_info *my_mdenv_info;
                     OM_p_CLASSLIST yes_classes, no_classes;
                     IGRboolean (*eligfunc)(); char *eligfunc_args;
                     int depth)
{
  IGRboolean eligible;
  int i, local_depth;
  OMuint inxlim;
  long msg_loc, stat_OM;
  GRclassid compclass;
  GRobjid compobj;
  GRspacenum compos;
  struct GRmdenv_info save_mdenv_info, loc_mdenv_info;
  OM_S_CHANSELECT chan_to_components;
  IGRboolean elig_chk();

  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;

  OM_BLOCK_MOVE (my_mdenv_info, &save_mdenv_info,
   sizeof (struct GRmdenv_info));

  /*
   * Resolve the transformation matrix problem. Obtain this nodes, 
   * transformation matrix and plug it in as the matrix to pass on down.
   * But the incoming one is saved away and restored on return.
   */

  OM_BLOCK_MOVE (my_mdenv_info, &loc_mdenv_info, 
   sizeof (struct GRmdenv_info));
  om$send (msg = message GRowner.GRget_matrix (&msg_loc, 
   &my_mdenv_info->matrix_type, my_mdenv_info->matrix, 
   &loc_mdenv_info.matrix_type, loc_mdenv_info.matrix), 
   targetid = my_id);
  OM_BLOCK_MOVE (&loc_mdenv_info, my_mdenv_info,
   sizeof (struct GRmdenv_info));

  /*
   * Check eligibility of this object usign the criteria supplied
   * by the caller
   */

  eligible = elig_chk (my_id, OM_Gw_current_OS, yes_classes, no_classes,
                       eligfunc, eligfunc_args);
  if (!eligible)
    goto Send_Down;

  /*
   * All eligibility criteria having been passed, send the input message to
   * myself. Once sent, terminate this invocation. Later, this must be
   * driven by an option.
   */

  stat_OM = om$send (mode = wrt_flag, msg = messg, targetid = my_id);
  if (stat_OM != OM_I_STOP_SENDING)
    stat_OM = OM_S_SUCCESS;
  goto wrapup;

  /*
   * If the depth allows, send on down if the component is of type GRowner.
   * If not, then the component object must be screened for eligibility
   * and on passing the test, the target message issued to it.
   */

  Send_Down:

  if (depth <= 0)
    goto wrapup;

  GRget_to_comp_chansel (&chan_to_components);
  om$get_channel_count (object = me, p_chanselect = &chan_to_components,
   count = &inxlim);
  
  local_depth = depth - 1;

  for (i=0; i<inxlim; i++)
    {
    om$get_objid_at_index (object = me, p_chanselect = &chan_to_components,
     index = i, objidaddr = &compobj, osnumaddr = &compos);

    om$get_classid (objid = compobj, osnum = compos, p_classid = &compclass);

    if (om$is_ancestry_valid (subclassid = compclass,
         superclassid = OPP_GRowner_class_id) == OM_S_SUCCESS)
      stat_OM = om$send (msg = message GRowner.GRpass_messg (msg, opts,
                 wrt_flag, messg, my_mdenv_info, yes_classes, no_classes,
                 eligfunc, eligfunc_args, local_depth),
                 targetid = compobj, targetos = compos);
    else if (elig_chk (compobj, compos, yes_classes, no_classes, 
              eligfunc, eligfunc_args))
      stat_OM = om$send (mode = wrt_flag, msg = messg,
                 targetid = compobj, targetos = compos);

    if (stat_OM == OM_I_STOP_SENDING)
      goto wrapup;
    stat_OM = OM_S_SUCCESS;
    }

wrapup:
  OM_BLOCK_MOVE (&save_mdenv_info, my_mdenv_info,
   sizeof (struct GRmdenv_info));
  return (stat_OM);
}

/*
 * Locally used function
 */

static IGRboolean elig_chk (my_id, my_os, yes_classes, no_classes,
                            eligfunc,  eligfunc_args)
GRobjid my_id;
GRspacenum my_os;
OM_p_CLASSLIST yes_classes, no_classes;
IGRboolean (*eligfunc)();
char *eligfunc_args;
{
  IGRboolean eligible = FALSE;
  GRclassid myclass;
  struct GRid my_grid;
  IGRboolean GRclass_eligible();

  /*
   * Check for eligibility by classes
   */

  om$get_classid (objid = my_id, osnum = my_os, p_classid = &myclass);

  if (yes_classes)
    eligible = GRclass_eligible (myclass, yes_classes);
  if (!eligible)
    goto wrapup;

  if (no_classes)
    eligible = !GRclass_eligible (myclass, no_classes);
  if (!eligible)
    goto wrapup;

  /*
   * If a user supplied eligibility function has been supplied. Invoke
   * that to check for eligibility.
   */

  if (eligfunc)
    {
    my_grid.objid = my_id;
    my_grid.osnum = my_os;
    eligible = (*eligfunc)(&my_grid, eligfunc_args);
    }
  if (!eligible)
    goto wrapup;

wrapup:
  return (eligible);
}


IGRboolean GRclass_eligible (classid, classlist)
GRclassid classid;
OM_p_CLASSLIST classlist;
{
 IGRboolean	eligible;

 if ((! classlist) ||
     (classlist->w_flags & OM_CLST_negation) ||
     (classlist->w_count == 0) ||
     (classlist->p_classes == NULL))
  eligible = TRUE;
 else
  {
   int	numclasses, i;
   long	stat_OM;
   GRclassid	*classes;

   eligible = FALSE;
   numclasses = classlist->w_count;
   classes = classlist->p_classes;
   for (i = 0; (i < numclasses) && (! eligible); i++)
    {
     stat_OM = om$is_ancestry_valid(
      subclassid = classes[i],
      superclassid = classid);
     if (stat_OM == OM_S_SUCCESS)
      eligible = TRUE;
     else
      {
       stat_OM = om$is_ancestry_valid(
        subclassid = classid,
        superclassid = classes[i]);
       if (stat_OM == OM_S_SUCCESS)
        eligible = TRUE;
      }
    } /*  for (i = 0; (i < numclasses) && (! eligible); i++) */
  }

 return(eligible);
}

end implementation GRowner;
