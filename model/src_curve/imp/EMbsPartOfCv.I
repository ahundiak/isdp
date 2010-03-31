/* 
  DESCRIPTION
  
   This method takes a starting and ending parameter value (and a middle
   paramter value in case of physically closed curve) and creates another
   curve out of this portion. If the object is not of free-form type,
   the object will be created in the class that it naturally 'clips to'.
   This object's id is returned.
   
  RETURN VALUES
   
      *msg         IGRlong        return code.
                                   - MSSUCC if all was well.
                                   - MSNOMEM if memory allocation
                                        failed.   
                                   - MSFAIL on any other error.
  
      *partcvid    GRobjid        Pointer to the objid that is the result
                                     of this operation. 
  
  HISTORY
  
   10/03/86 : ss  : The beginning
   01/27/87 : rlw : Modify argument list to accept start, middle, and
                    ending parameter values as opposed to just parameters.
   01/09/89 : rlw : Modified not to reset the pointer to the error return
                    code in the construct list.  This was a fatal problem
                    found by Doree.
   06/09/89 : rlw : Reworked.  This method is called by curve booleans and
                    the like.  In earlier implementations this method cons-
                    tructed new objects and as such any associated dimensions,
                    etc. were lost.  The new implementation is an attempt
                    to preserve any associated objects.
   11/28/91 : dhm : Fix a null pointer problem.
   Sudha  06/16/93     Modified for BSprototype ansification
 */

class implementation GRbspline;

#include "EMS.h"
#include <stdio.h>
#include "OMmacros.h"      /* OM_BLOCK_MOVE */
#include "gocmacros.h"     /* GRgetabsg macro  */
#include "msdef.h"
#include "bserr.h"
#include "emsdef.h"
#include "emserr.h"
#include "ndmacros.h"
#include "nddef.h"
#include "bspartofcv.h"
#include "bsfreecv.h"
#include "bsalloccv.h"

method EMpartofcv(
  IGRlong *msg; 			/* Error return code */
  IGRshort *mattyp; 			/* My matrix type */
  IGRmatrix mat;			/* My matrix */
  struct GRvg_construct *const_args; 	/* Standard construction list */
  struct GRparms *startpar;		/* Starting paramter value */
  struct GRparms *midpar;		/* Middle parm value, iff closed */
  struct GRparms *endpar;		/* Ending parameter value */
  GRobjid *partcvid)			/* Resultant object */
{
  IGRboolean	stat_func;
  IGRchar	errmsg[EMMAXERRMSG_LEN], clipto_classname[OM_K_MAXCLASS_LEN];
  IGRlong	stat_OM, msg_loc, class_change;
  struct	IGRbsp_curve *crv, *pcrv;
/*
 * Initialize
 */
 *msg = MSSUCC;
 stat_OM = OM_S_SUCCESS;
 pcrv = NULL;
 *partcvid = NULL_OBJID;
 strcpy(errmsg, "GRbspline.EMpartofcv");
/*
 * Get the abstract geometry
 * buffer.
 */
 {
  IGRlong	dumdum;

  GRgetabsg(&msg_loc, mattyp, mat, (char **) &crv, dumdum);
  EMerr_hndlr(EMis_error(msg_loc), *msg, MSFAIL, ret_end);
 }
/*
 * If the output curve is different from the input curve then
 * allocate space for the part of curve being output.
 * The total number of poles that might be output could exceed the
 * number of poles in the input curve in the case of closed curves.
 * Also call the math function to extract the part of curve.
 */
 {
  IGRdouble	u_low, u_hig;

  u_low = crv->knots[crv->order - 1];
  u_hig = crv->knots[crv->num_poles];
  if (((startpar->u == u_low) && (endpar->u == u_hig)) ||
      ((startpar->u == u_hig) && (endpar->u == u_low)))
   {}
  else
   {
    IGRdouble   parm;

    BSalloccv(
      crv->order, 
      crv->num_poles + 2 * crv->order - 1, 
      crv->rational, 
      0,			/* No boundaries */
      &pcrv, 
      &msg_loc);
     EMerr_hndlr(msg_loc != BSSUCC, *msg, MSNOMEM, ret_end);

    /*
     * Fix a null pointer problem.  dhm  11/28/91
     */

    parm = (midpar ? midpar->u : endpar->u);

    stat_func = BSpartofcv(
      &msg_loc, 
      crv, 
      startpar->u, 
      parm,
      endpar->u, 
      pcrv);
     EMerr_hndlr(! stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ret_end);
   }
 }
/*
 * Determine the class of the object to be constructed.
 */
 if (pcrv)
  {
   IGRchar	my_classname[OM_K_MAXCLASS_LEN];

   stat_OM = om$send(
     msg = message GRvg.GRclipto(
      &msg_loc, 
      clipto_classname),
     targetid = my_id);
    EMomerr_hndlr(stat_OM, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, ret_end);
   stat_OM = om$get_classname(
     object = me,
     classname = my_classname);
    EMomerr_hndlr(stat_OM, ret_end, errmsg);
   class_change = strcmp(
    clipto_classname,
    my_classname);
  } /* if (pcrv) */
 else
  class_change = FALSE;
/*
 * Copy myself to the correct object space.  Hopefully
 * anybody who depends on my will also copy.
 */
 if (! class_change)
  {
   IGRlong	mode;
   struct	GRmd_env my_md_env;

   my_md_env.md_id.objid = NULL_OBJID;		/* Should not matter */
   my_md_env.md_id.osnum = OM_Gw_current_OS;
   my_md_env.md_env.matrix_type = *mattyp;
   OM_BLOCK_MOVE(
    mat,
    my_md_env.md_env.matrix,
    sizeof(IGRmatrix));
   stat_OM = om$send(
     msg = message GRgraphics.GRcopy(
      &msg_loc,
      &my_md_env,
      const_args->env_info,
      partcvid),
     targetid = my_id);
    EMomerr_hndlr(stat_OM, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, ret_end);
   if (pcrv)
    {
     struct	GRpost_info info;

     info.construct_flag = FALSE;
     stat_OM = om$send(
       msg = message GRvg.GRpostabsg(
             &msg_loc, const_args->env_info, &info,
             (char *) pcrv, partcvid),
       targetid = *partcvid,
       targetos = const_args->env_info->md_id.osnum);
      EMomerr_hndlr(stat_OM, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, ret_end);
    } /* if (pcrv) */
/*
 * If the symbology has been passed in then take this as
 * a sign that the part of curve should use the construct
 * list symbology, i.e. this is a creation command.
 */
   if (const_args->display)
    {
     struct	GRsymbology symb;

     symb.level = const_args->level;
     symb.display_attr = *(const_args->display);
     stat_OM = om$send(
       msg = message GRvg.GRputsymb(
        &msg_loc, 
        &symb),
       targetid = *partcvid,
       targetos = const_args->env_info->md_id.osnum);
      EMomerr_hndlr(stat_OM, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, ret_end);
    } /* if (const_args->display) */
/*
 * If associative things are listening then tell them to recompute
 * now.  This is needed because several commands (booleans, trim, auto
 * fillet, etc.) drive this command repeatedly creating many copies.
 * The graph manager cannot handle when an object is copied twice.
 */
   nd$mod_batch(
    request = ND_INQ,
    p_ret_mode = &mode);
   if (mode != ND_DEFER)
    {
     nd$exec_batch(
      mode = ND_DISP_BODY);
    } /* if (mode != ND_DEFER) */
  } /* if (! class_change) */
/*
 * The new object will be of a different class than the original.  In
 * such cases I do not care if any related dimension follows because
 * the change is rather radical.
 */
 else
  {
   struct	GRvg_construct construct_list;
   struct	IGRdisplay display;

   construct_list = *const_args;
   construct_list.msg = &msg_loc;
   if (! construct_list.display)
    {
     struct	GRsymbology symb;

     construct_list.display = &display;
     stat_OM = om$send(
       msg = message GRvg.GRgetsymb(
        &msg_loc, 
        &symb),
       targetid = my_id);
      EMomerr_hndlr(stat_OM, ret_end, errmsg);
      EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, ret_end);
     construct_list.level = symb.level;
     display = symb.display_attr;
    } /* if (! construct_list.display) */
   construct_list.geometry = (IGRchar *) pcrv;
   stat_OM = om$construct(
     classname = clipto_classname,
     msg = message GRgraphics.GRconstruct(
      &construct_list),
     p_objid = partcvid,
     osnum = construct_list.env_info->md_id.osnum);
    EMomerr_hndlr(stat_OM, ret_end, errmsg);
    EMerr_hndlr(EMis_error(msg_loc), *msg, msg_loc, ret_end);
  } /* ELSE FOR if (! class_change) */
/*
 * eof
 */
ret_end: 
 if (pcrv)
  {

   stat_func = BSfreecv(
     &msg_loc, 
     pcrv);
    EMerr_hndlr_action(!stat_func || msg_loc != BSSUCC, *msg, MSFAIL, ;);
  }
 if (((! (1 & stat_OM)) || 
      (! (1 & *msg))) && 
     (*partcvid != NULL_OBJID))
  {
   IGRlong	sts;

   sts = om$send(
    msg = message GRgraphics.GRdelete(
     &msg_loc,
     const_args->env_info),
    targetid = *partcvid,
    targetos = const_args->env_info->md_id.osnum);
   *partcvid = NULL_OBJID;
  }
 return(stat_OM);
}

end implementation GRbspline;
