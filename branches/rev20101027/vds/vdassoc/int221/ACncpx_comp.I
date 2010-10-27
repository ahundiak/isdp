/* $Id: ACncpx_comp.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / ACncpx_comp.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ACncpx_comp.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation ACncpx;

#define AS_DEBUG

extern char *regcmp();
extern char *regex();
extern char *strpbrk();

#include <alloca.h>

#include "ASmacroi.h"
#include "grerr.h"
#include "macro.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "godef.h"
#include "grownerdef.h"
#include "grownmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "gocmacros.h"
#include "EMSkey.h"
#include "ASmsg.h"
#include "msmacros.h"


from ACcpx_defn import 	ACgive_name, ACgive_temp_desc, ACgive_feet_desc;
from ACcpx_defn import 	ACintpt_foot;
from ACmacro_defn import 	ACgive_upscan;
from ACpretend  import 	ACfind_parent;
from ACpretend  import 	ACrebind;
from ACconst  import 	ACget_foot_in_mac;
from EMSpointerA import EMstore_key_from_id, EMstore_id_from_key;

extern IGRboolean ASbroadcast_in_progress;

method ACcontext_compute ( IGRlong *msg; IGRint cn_type;
			IGRint count; struct GRid root []; 
			struct GRid *context;
                        struct GRmd_env *md_env)
{
  int 			status,i;
  long			msg_loc;
  struct GRid		mygrid;
  int 			feet_num;
  struct myfeet 	*feet;
  struct GRid		*new_root,*feet_list,*temp_list;
  IGRboolean 		save_br;
  struct GRid mac_def,my_grid;
  int rep,STATE;
  GRclassid target_cl;

  *msg = 0;
  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;

/* find macro definition */

  status = om$send( msg = message ACcpx.find_macro(&mac_def),
                    targetid = my_id);
  as$status(action = RET_STATUS);


/* if element in error, does nothing */

  if(me->state & ND_DEGRADED)
    {as$status(sts = 0,
	       string =("element %d not updated because degraded\n",my_id));
    return(OM_W_ABORT);}
  
/* transfer context if any */

  if(context->objid != NULL_OBJID)
   {
    status = om$get_classid(objid = context->objid,
		 osnum = context->osnum,
		    p_classid = &target_cl);
     if(   (status&1)
	&& !(me->STATE &ncpx_root)
	&& (om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ACncpx_class_id) == OM_S_SUCCESS))
      {
	 status = om$send(msg =  message ACncpx.ACget_STATE (&STATE),
		   targetid =context->objid,
		   targetos =context->osnum ); 
      as$status( );
      STATE =(ncpx_consumed|ncpx_missing) & STATE;
      me->STATE = (~(ncpx_consumed|ncpx_missing)) &  me->STATE;
      me->STATE= STATE|me->STATE;
      }
     else
      {
/* not correct to transfert symbology of nested components : all of them
/* takes the same symbology than the first 
/* ACtrans_symb(*context,my_grid);
/* jla march 93
/*******/
	int count = 0;
	status = om$get_channel_count(objid = my_id,
				     p_chanselect = &AC_mto_graf_chns,
				     count = (OMuint *) &count);
	if(count)
	 {
	  feet_list = (struct GRid *) alloca(count*sizeof(struct GRid));
	  if(!feet_list) return OM_W_ABORT;
	  ACread(my_grid,&AC_mto_graf_chns,feet_list,count);
       	  status = om$send(msg = message ACncpx.ACcontext_compute_feet(count,
					*context,feet_list,md_env),
			targetid = my_id);
          as$status();
	 }
      }
    }

/* if root element --> done */

  if(me->STATE  & ncpx_root)
    {
     *msg = ND_COMP_SUCC;
     return OM_S_SUCCESS;
    }

/* control representation consistency of parents and do I
   Do I need to generate an extra template for representation */

  status = om$send(msg = message ACncpx.ACget_rep(&rep),
		   targetid = my_id);
  if((status&1) && rep&(AC_FREE_REP|AC_DEP_REP))
    {
     rep = rep & ~AC_ERROR_REP;
     status = ac$compute_rep_value(initial_rep = rep,
				   p_root = root,
				     nb_root = count,
				     resulting_rep = &rep);
     if(rep&AC_ERROR_REP)
      {
	 char dummy_rep;
	 struct GRsymbology symb; 

	 /* Turn to error because parents have inconsistent representation */
	 ac$get_def_rep(prep = &dummy_rep,
			esymb = &symb);
	 status = om$send(msg = message GRvg.GRputsymb(msg,&symb),
			  targetid = my_id);
	 as$status();
         status = om$send(msg = message ACncpx.ACput_rep
					(AC_ERROR_REP,AC_ERROR_REP),
			  targetid = my_id);
	 *msg = 0;
	 return OM_S_SUCCESS;
      }

     /* update my internal representation and generate an additional parent */

     status = om$send(msg = message ACncpx.ACput_rep
					(rep,~(AC_DEP_REP|AC_FREE_REP)),
		      targetid = my_id);

     new_root = (struct GRid *) alloca((count+1)*sizeof(struct GRid));
     if(!(new_root)) return OM_W_ABORT;

     OM_BLOCK_MOVE(root,new_root+1,count*sizeof(struct GRid));
	
     rep  = rep&AC_VDS_REP;
     status = ACgenerate_rep(rep,OM_Gw_current_OS,new_root);
     root = new_root;
     count += 1;
    }


/*
 * Send a store_key_from_id message to all the children and ignore any
 * error messages. This is necessary for an optimised storage of keys
 * for model space counterparts and pointers.
 */

  om$send (msg = message EMSpointerA.EMstore_key_from_id(&msg_loc,
                         EMS_OPT_STORE_ID, NULL),
                   p_chanselect = &ND_children);


  mygrid.osnum = OM_Gw_current_OS;  mygrid.objid = my_id;
  feet_list = NULL; 
  temp_list = NULL; 
  save_br=ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;

/* update the feet */
    
    status = om$send( msg = message ACmacro_defn.ACgive_feet_desc(
			&feet_num, &feet),
		      targetid=mac_def.objid,targetos=mac_def.osnum );
     as$status( action = GOTO_VALUE, value = wrapup );

    if(feet_num) feet_list=(struct GRid *) alloca(feet_num*sizeof(struct GRid));
    for(i=0;i<feet_num;i++) feet_list[i].objid=NULL_OBJID;
 
    status = om$send(msg = message ACncpx.ACconstruct_feet(
				msg,cn_type,count,root,md_env, 
				&feet_num,feet_list),
		  targetid = my_id);
    as$status();
    if(!(*msg&status&1)) goto wrapup;

    status = om$send( msg = message ACncpx.ACcontext_compute_feet(
			feet_num,*context,feet_list, md_env),
	     	      targetid = my_id);
    as$status(action = GOTO_VALUE,value = wrapup);

    ASbroadcast_in_progress = 1;
    status = om$send( msg = message ACncpx.ACchange_feet(
			feet_num,feet_list, md_env),
	     	      targetid = my_id);
    as$status();

/* For top most macro --> without context notify listeners */

    if(context->objid == NULL_OBJID)
    GR_NOTIFY_LISTENERS(msg,&status,GR_GEOM_MODIFIED);

/* Reset key in pointer (should not be necessary) */

wrapup :
  
    om$send (msg = message EMSpointerA.EMstore_id_from_key (&msg_loc,
                          NULL, NULL),
                    p_chanselect = &ND_children);

/* end pp */

  ASbroadcast_in_progress =save_br;
  return ( status );
}
end implementation ACncpx;
