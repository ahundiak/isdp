class implementation EMSdpb;

/*
  File History:  (for method histories see below)

   06/14/93 : scw : Removed references to the X11 directory for include files.
   08/13/94 : scw : Solaris Intel port
   08/14/94 : scw : Clarified sleep method
*/


#include "EMS.h"
#include "exmacros.h" /* For ex$is_invis */
#if defined( NT )
#if 0  /* because opp can not handle it */
#  include <windows.h>
#endif
#endif

#ifdef X11
#  include <X11/Xlib.h>
#  include <X11/Xutil.h>
#endif

#if defined(__STDC__) || defined(__cplusplus)
#if 0  /* because opp can not handle it */
#  if defined( X11 )
#    include <XFIproto_pub.h>
#  elif defined( ENV5 )
#    include <FIproto_pub.h>
#  elif defined( NT )
#    include <shampub.h>
#  endif
#  endif
#else
#  include <FI.h>
#  endif

#include "nddef.h"
#include "ndmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h" /* For gr$get_associative_flag */
#include "DIdef.h"
#include "DItypedef.h"
#include "DIprims.h"
#include "expression.h"
#include "expmacros.h"
#include "exdef.h"
#include "exmacros.h"

#define FORM_LABEL 0

#define VARIATIONAL_GEOMETRY

#ifdef VARIATIONAL_GEOMETRY
#include <stdio.h>
#include <string.h>
#include "exdef.h"
#include "exmacros.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsdef.h"

#define MAXSIZE_PRODPATHNAME	200
#define MAXNUM_PRODPATHS	20
#define TEST_EXISTS  0
#define TEST_EXECUTE 1
#define TEST_SUCCESS 0

extern IGRint _debug_graph_decompose;
#endif

#define PATHWAY
#ifdef PATHWAY
#include "PWapi/clock.h"
#endif

#define FORM1  1

extern void EFswap_bar_menu_callback();

method super_construct ()
{
 /* *********************************************************************

    Description
        This method sets up the default parameters which are 
        predetermined. As an enhancement, I think this method should
        read the parameters from an ascii file thus letting the user
        customizing the default parameters to his taste.

        For now, I am hardcoding the defaults.

    Notes
      Always has a return status of OM_S_SUCCESS;

    History
        PP  : 10/19/87                Creation.
        rlw : 12/28/87                Changed default orders to cubic.
        RC  : 11/30/88                Added EMDPB_UPDATE_XSECTION to
                                      default props.
        scw : 08/08/91                Converted to use gr$dpb associative
                                      flag
        Kumar N: 01/21/93             Port to windows NT
    ******************************************************************** */

 me^^EMSdpb.u_order = 4;
 me^^EMSdpb.v_order = 4;
 me^^EMSdpb.u_rules = 0;
 me^^EMSdpb.v_rules = 0;
 me^^EMSdpb.props = EMDPB_UPDATE_XSECTION | EMDPB_REF_LOCK_ON;

 {
   char       ExpressionName [DI_PATH_MAX];
   OM_S_OBJID ExpressionId;

   DIstmocpy ( ExpressionName, "IGENOD", ".PerVcnstr_Validated", 0,
     OM_Gw_current_OS );
   exp$create ( exp_name = ExpressionName, exp_syntax = "0.0", 
     p_exp_id = &ExpressionId );
 }

 return (OM_S_SUCCESS);
 
}


method wake_up()
{
/* *************************************************************
 
Description
   This method initialises the form and updates the values of the form
   should the form be displayed.
  
History
	SS  : 02/01/92		      Added initialization of control 
                                      tolerances for variational geometry
        SS  : 10/15/90                Added the call to initialize symbolic
                                      objects (vide variational geometry)
        PP  : 06/13/89                Fixed a bug which was causing the
                                      form to talk to the wrong DPB object
                                      whenver there existed reference files.
        rlw : 03/10/89                Added conditional compilation for I/DRAW
        PP  : 02/12/89                Made changes to initialise the
                                      locate control information
        PP  : 10/19/87                Creation.
   ************************************************************ */

 IGRlong EMmsg,status;
 IGRint displayed;
 OM_S_OBJID set_id;
 struct GRid active_dpbid;
 int ret;
 extern EMSdpb_process_form ();
 extern void GRdisplay_associative_symbol();

 EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 active_dpbid.objid = NULL_OBJID;

 set_id = NULL_OBJID;

/*
 * Initialise the locate control information in the wakeup method
 * instead of super_construct method so that IGE can handle
 * context switching and turn of those types which do not make
 * sense for the  application which becomes active.
 */

 EFinit_locate_control(&EMmsg);

#ifndef IDRAW
/*
 * The form should only talk to the dpb of the master file.
 */

 if (!(ex$is_invis(mod_osnum = OM_Gw_current_OS))) 
 {
  ret = FIf_new(FORM1, "MDModelPar", EMSdpb_process_form, &me->form1);
  if(ret)
    return(OM_E_ABORT);
  ret = FIf_set_cmd_oid_os(me->form1, my_id, OM_Gw_current_OS);
  if(ret)
    return(OM_E_ABORT);

  ret = FIf_is_displayed(me->form1, &displayed);
  if (ret)
    return(OM_E_ABORT);
  
  if (displayed)
  {
   status = om$send (msg = message EMSdpb.EMupdate_form (&EMmsg),
                     targetid = my_id);
   if (!(1&status&EMmsg)) return (OM_E_ABORT);
  }
/*
  gr$get_associative_flag( buffer = &state );
  if (state)
   GRdisplay_associative_symbol(1);
  else
   GRdisplay_associative_symbol(0);
*/
  if (me->props & EMDPB_REF_LOCK_ON)
   GRdisplay_refpln_symbol(1);
  else
   GRdisplay_refpln_symbol(0);

  /* arrange to be notified whenever the bar menu is swapped, so that the */
  /* reference plane lock may be updated */
  GRregister_swap_menu_callback(EFswap_bar_menu_callback);
 }
#endif

  {
    char ExpressionName [DI_PATH_MAX];
    OM_S_OBJID ExpressionId;
    struct GRmd_env  mod_env;
    IGRlong msg_loc;
    struct GRid cur_mod;

    ExpressionId = NULL_OBJID;
    DIstmocpy ( ExpressionName, "IGENOD", ".PerVcnstr_Validated", 0, 
                OM_Gw_current_OS );
    di$translate ( objname = ExpressionName,  p_objid = &ExpressionId );
    if(ExpressionId == NULL_OBJID)
     {
      (void)EMidmatrix(&msg_loc, &mod_env.md_env.matrix_type,
                        mod_env.md_env.matrix);
      ex$get_modid(mod_osnum = OM_Gw_current_OS, 
                     mod_id = &mod_env.md_id.objid);
      mod_env.md_id.osnum = OM_Gw_current_OS;
      (void) EMvalidate_direction(&msg_loc, &mod_env);

      /* Create an expression to indicate that we have validated the
         perpendicular constraints in this object space once. This will prevent
         the processing from occuring again. I am doing this only for master
         files. Creation of new expressions in a ref. file is disallowed
         through the public interface and I do not wish to complicate matters
         by trying to use the backdoor mechanism. The downside of this being
         that untill a ref. file is brought up as a master file, the validation
         processing will always occur.
         SM 03-Mar-1993.
      */
      ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
      if(cur_mod.osnum == OM_Gw_current_OS)
       {
        DIstmocpy ( ExpressionName, "IGENOD", ".PerVcnstr_Validated", 0,
                  OM_Gw_current_OS );
        exp$create ( exp_name = ExpressionName, exp_syntax = "0.0", 
                    p_exp_id = &ExpressionId );
       }
     }
  }    

  {
    char ExpressionName [DI_PATH_MAX];
    OM_S_OBJID ExpressionId;
    struct GRmd_env  mod_env;
    IGRlong msg_loc;
    struct GRid cur_mod;

    ExpressionId = NULL_OBJID;
    DIstmocpy ( ExpressionName, "IGENOD", ".ParVcnstr_Validated", 0, 
                OM_Gw_current_OS );
    di$translate ( objname = ExpressionName,  p_objid = &ExpressionId );
    if(ExpressionId == NULL_OBJID)
     {
      (void)EMidmatrix(&msg_loc, &mod_env.md_env.matrix_type,
                        mod_env.md_env.matrix);
      ex$get_modid(mod_osnum = OM_Gw_current_OS, 
                     mod_id = &mod_env.md_id.objid);
      mod_env.md_id.osnum = OM_Gw_current_OS;
      (void) EMvalidate_direction1(&msg_loc, &mod_env);

      /* Create an expression to indicate that we have validated the
         perpendicular constraints in this object space once. This will prevent
         the processing from occuring again. I am doing this only for master
         files. Creation of new expressions in a ref. file is disallowed
         through the public interface and I do not wish to complicate matters
         by trying to use the backdoor mechanism. The downside of this being
         that untill a ref. file is brought up as a master file, the validation
         processing will always occur.
         PP 16 March 1993
      */
      ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
      if(cur_mod.osnum == OM_Gw_current_OS)
       {
        DIstmocpy ( ExpressionName, "IGENOD", ".ParVcnstr_Validated", 0,
                  OM_Gw_current_OS );
        exp$create ( exp_name = ExpressionName, exp_syntax = "0.0", 
                    p_exp_id = &ExpressionId );
       }
     }
  }    
    

#ifdef VARIATIONAL_GEOMETRY
 /*
  * Initialization for control parameter/tolerances used during
  * computation.
  */
 {
 IGRlong msg_loc;
 IGRdouble lentol, angtol;
 extern void SKsettol(), SKsetiterpar();

 BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, lentol);
 angtol = EMS_ZEROANGLE_DEG;
 SKsetiterpar (NULL, &lentol);
 SKsettol (&lentol, &angtol);

 _debug_graph_decompose = 0;
 }

#endif

#ifdef PATHWAY
  {
    pwInitClocks();
  }
#endif

 return(OM_S_SUCCESS);
}

#ifndef IDRAW
method global_class.sleep(IGRint type)
{
 IGRlong EMmsg,status,loc_msg;
 struct GRid active_dpbid;
 IGRint displayed;
 int ret;

 EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 active_dpbid.objid = NULL_OBJID;

/*
 * Process the redo list and the key list.
 */
 loc_msg = 1; 
 EFprocess_key_list(&loc_msg,NULL);

 if (!(ex$is_invis(mod_osnum = OM_Gw_current_OS))) 
 {
   ret = FIf_is_displayed(me->form1, &displayed);
   if (ret)
     return (OM_E_ABORT);

  if (displayed)
  {
   ret = FIf_erase (me->form1);
   if (ret)
     return (OM_E_ABORT);

  }

  if (me->form1)
   FIf_delete(me->form1);

  me->form1 = NULL;

 }

 return(OM_S_SUCCESS);
}
#endif

method delete (IGRint defer_flag)
{
/*
 * This object cannot be deleted
 */

 return(OM_S_SUCCESS);
}

method EMget_dpb_parameter (IGRlong *EMmsg; 
                            IGRlong parameter;
                            IGRchar *buff)
/* ************************************************************************

Description
    This method gets the dpb parameter requested. 

 Input
      parameter : 	parameter whose value is desired

 Output
      EMmsg     :       Completion code
      buff      : 	a character buffer containing the value of the parameter
               		desired
Notes
    Upon exit the completion code will be one of the following:
      EMS_S_Success : if all goes well
      EMS_E_InvalidArg:if the parameter whose value is requested is not
                       defined


Files
    EMSdpb.h : for declarations pertaining to the valid parameters whose
               value may be asked
History
    PP : 10/19/87            Creation

*************************************************************************** */

{
  *EMmsg = EMS_S_Success;

  switch (parameter)
  {
   case EMSdpb_u_order:
    *(IGRuchar *)buff = me^^EMSdpb.u_order;
   break;

   case EMSdpb_v_order:
    *(IGRuchar *)buff = me^^EMSdpb.v_order;
   break;

   case EMSdpb_u_rules:
    *(IGRuchar *)buff = me^^EMSdpb.u_rules;
   break;

   case EMSdpb_v_rules:
    *(IGRuchar *)buff = me^^EMSdpb.v_rules;
   break;

   case EMSdpb_props:
    *(IGRuchar *)buff = me^^EMSdpb.props;
   break;

   default:
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
/*   break;    - COMMENTED OUT - Ashok */
  }

wrapup:
 return (OM_S_SUCCESS);
 };


method EMput_dpbinfo (IGRlong *EMmsg;
                      struct EMdpbinfo *dpbinfo)

/* ************************************************************************

Description
  This method puts all the dpb information in one shot. 

Notes
  Upon exit the completion code will be one of the following:
  EMS_S_Success : Always successful

History
  Creation : PP : 06/26/88

   *********************************************************************** */
{

 *EMmsg = EMS_S_Success;

  me->u_order = dpbinfo->u_order;
  me->v_order = dpbinfo->v_order;
  me->u_rules = dpbinfo->u_rules;
  me->v_rules = dpbinfo->v_rules;
  me->props   = dpbinfo->props;

 return (OM_S_SUCCESS);
}

method EMput_dpb_parameter (IGRlong *EMmsg;
                            IGRlong parameter;
                            IGRchar *buff)
/* ************************************************************************

Description
    This method stores the parameter requested in the instance data of
    the dpb.

 Input
      parameter : 	parameter whose value is to be stored in the
                        instance data.
      buff      :       the value of the parameter to be stored

 Output
      EMmsg     :       Completion code
Notes
    Upon exit the completion code will be one of the following:
      EMS_S_Success : if all goes well
      EMS_E_InvalidArg:    Invalid arguments  

Files
    EMSdpb.h : for declarations pertaining to the valid parameters whose
               value may be asked
History
    PP : 10/19/87            Creation

*************************************************************************** */
{
 *EMmsg = EMS_S_Success;

 switch (parameter)
 { 
   case EMSdpb_u_order:
    me^^EMSdpb.u_order = *(IGRuchar *) buff;
   break;

   case EMSdpb_v_order:
    me^^EMSdpb.v_order = *(IGRuchar *) buff;
   break;

   case EMSdpb_u_rules:
    me^^EMSdpb.u_rules = *(IGRuchar *) buff;
   break;

   case EMSdpb_v_rules:
    me^^EMSdpb.v_rules = *(IGRuchar *) buff;
   break;

   case EMSdpb_props:
    me^^EMSdpb.props = *(IGRuchar *) buff;
   break;

   default:
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
/*   break; - COMMENTED OUT - Ashok */
 }

wrapup:
  return (OM_S_SUCCESS);
}

end implementation EMSdpb;
