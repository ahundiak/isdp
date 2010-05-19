/* $Id: SMCmddrwtxt.sl,v 1.3 2001/01/21 16:12:16 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwtxt/cmd / SMCmddrwtxt.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCmddrwtxt.sl,v $
 *	Revision 1.3  2001/01/21 16:12:16  ramarao
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/19 23:05:11  jayadev
 *	*** empty log message ***
 *	
# Revision 1.1  2000/05/16  22:24:18  pinnacle
# Created: vds/smdrwtxt/cmd/SMCmddrwtxt.sl by rchennup for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/03/21  23:16:14  pinnacle
# Replaced: smdrwtxt/cmd/SMCmddrwtxt.sl for:  by kddinov for vds.240
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
 *	05/16/00	Rama Rao	Added Rotate Option.
 * -------------------------------------------------------------------*/

/*  File             SMCmddrwtxt.sl
    Creation Date    AUGUST 93
    Auteur           Pascale Lacroix (ISDC)
    
     Command Object for copied and consumed drawing text

    History  
*/


command_string       SMC_M_MdDrwTxt,0,SMCpCsmTxt
class                SMCmddrwtxt
command_table        "sman.cmd"
super_class          VDS_LOCATE
product_name        "$VDS"


specification

#include <stdio.h>
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "growner.h"
#include "asmacros.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "SMdef.h"
#include "SMmsg.h"
#include "FI.h"

#define SM_MAX_CPCSM_ATTR	80

instance
{
  struct GRevent	mnevents[2];
  struct GRobj_env 	text;
  struct GRid		macro_id;
  IGRdouble		delta_x;
  IGRdouble		delta_y;
  IGRdouble		delta_z;
  
}

/******************************************************************/

implementation

#include "AS_status.h"
#include "comnmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "grmsg.h"
#include "grdpbmacros.h"
#include "griomacros.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define my_dyn		202
#define LOC_TXT		519
#define	SM_DRW_ERROR	0
#define	SM_DRW_SUCCESS	1


from SMmgr 	import 	SMGetAttDbl;
from SMCpTxt 	import 	SMcreate, SMModify;
from NDnode	import	NDget_objects;

extern	GRclassid	OPP_SMCpTxt_class_id;
extern	GRclassid	OPP_VDdrwGm_class_id;
extern	GRclassid	OPP_VDgeom_class_id;

/********************************************************************/
state_table


#include "VDSFilter.h"
#include "comnindex.h"
#include "comndef.h"
#include "SMmsg.h"

#define TRUE  1
#define FALSE 0

#define	SM_DRW_ERROR	0
#define	SM_DRW_SUCCESS	1

#define my_dyn	202
#define LOC_TXT		519


state start

message_key	SM_M_MdDrwTxt
prompt_key	SM_P_LocTxt
locate_class 	"GRtext"
locate_owner  	"LC_RIGID_COMP | LC_RIGID_OWNER |
               	 LC_FLEX_COMP  | LC_FLEX_OWNER  | LC_REF_OBJECTS"
filter		vds_locate

 
	on EX_DATA or EX_STRING or EX_OBJID
	  do locate_text( &me->ret )
                on RETURN_CODE = SM_DRW_SUCCESS		state move_object 
							state .

	on EX_BACK_UP or EX_RJT_MOVEON or EX_RESTART	state terminate


state move_object

message_key	SM_M_MdDrwTxt
prompt_key	SM_P_MvTxt
dynamics	my_dyn
filter		vds_get_event

	on EX_DATA
	  do store_pos		
	  do copy_text					state start

	on EX_RJT_MOVEON or EX_RESTART			state start

	on EX_BACK_UP					state -


at init do init_all

/******************************************************************/

action init_all
{
  IGRshort            num_alias = 3;  /* number of aliases */
  OMuword	      cur_os;
  IGRint              size;           /* of IGRdisplay structure */
  IGRdouble           aa;             /* active angle */
  GRIOalias_name      def_units[3];   /* default units */
  IGRshort            field_size;

  me->text.obj_id.objid = NULL_OBJID;
  me->macro_id.objid = NULL_OBJID;

  me->delta_x = 0.0; 
  me->delta_y = 0.0; 
  me->delta_z = 0.0; 

  ex$get_cur_mod( osnum = &cur_os );
  size = sizeof (aa);

  gr$get_active_angle (msg = &me->ret,
                       sizbuf = &size,
                       buffer = &aa,
                       nret = &size);

  field_size = sizeof(GRIOalias_name) * 3;

  co$cvt_imp_to_alias (msg = &me->ret,
                       unit_type = "UOM_ANGLE",
                       osnum = cur_os,
                       working_units = &aa,
                       num_alias = &num_alias,
                       field_size = &field_size,
                       cvt_list = def_units);

  ex$message (msgnumb = GR_I_ActAng,
              type = "%s",
              var = `def_units`);

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  goto quit;
}

/******************************************************************/

action store_pos
{
  me->mnevents[1] = me->event1;
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}
/******************************************************************/


action locate_text
{
	OMuint			count;
	OM_S_CHANSELECT		owner_chansel;
	OM_S_OBJECT_LINKAGE	list_ids[50];
	struct	GRid		tmpObj ;
	IGRint			i,
				owner_count ;
	IGRlong			msg ;

  *sts = OM_S_SUCCESS;
  me->mnevents[0] = me->event1;
  me->text.obj_id = me->event1.located_object[0].located_obj;
  me->text.mod_env = me->event1.located_object[0].module_info;

  owner_count = 0;

  GRget_to_owner_info(	&owner_chansel,
                        me->text.obj_id.osnum,
                        me->text.obj_id.objid,
                        &owner_count );
  if( ! owner_count ) goto quit ;
  if( owner_count > 50 ) owner_count = 50 ;

  msg = om$get_channel_objects(	osnum		= me->text.obj_id.osnum,
				objid		= me->text.obj_id.objid,
                                p_chanselect	= & owner_chansel,
                                list		= list_ids,
                                size		= owner_count,
                                count		= &count);
  *sts = SM_DRW_ERROR ;

  for( i=0 ; i<count ; i++ ){

	tmpObj.osnum = list_ids[i].osnum ;
	tmpObj.objid = list_ids[i].S_objid ;

	if( vd_$is_ancestry_valid(
		object = &tmpObj, classid = OPP_VDdrwGm_class_id ) ||
	    vd_$is_ancestry_valid(
		object = &tmpObj, classid = OPP_SMCpTxt_class_id ) ||
	    vd_$is_ancestry_valid(
		object = &tmpObj, classid = OPP_VDgeom_class_id )){

		*sts = SM_DRW_SUCCESS;
		break ;
	}
  }

  if( *sts != SM_DRW_SUCCESS ){
    UI_status(" Invalid text type located " );
  }
}

/******************************************************************/

action copy_text
{
 IGRlong 	   	msg;
 int     	   	count, nb_att, size;
 IGRdouble		dx1, dy1, dz1, dx2, dy2, dz2, aa, aa1, aa2;
 IGRshort		type, att_type[SM_MAX_CPCSM_ATTR];
 struct ACrg_coll	ACrg[SM_MAX_CPCSM_ATTR];
 struct GRid		mac, text;
 OMuword		classid;
 IGRboolean		is_modify;

 nb_att = 0;
 is_modify = FALSE;
 text.objid = NULL_OBJID;
 mac.objid = NULL_OBJID;

 if(me->text.obj_id.objid == NULL_OBJID){
	ex$message(msgnumb = SM_S_NoTxtLoc);
	goto quit;
 }

 size = sizeof (aa1);
 gr$get_active_angle ( 	msg 	= &msg,
			sizbuf  = &size,	
			buffer  = &aa1,
			nret 	= &size);

 as$make_source(	go_grid = me->text.obj_id,
			mod_env = &me->text.mod_env,
			as_os = me->ModuleInfo.md_id.osnum,
			as_grid = &text);

 status = om$send(msg = message NDnode.NDget_objects
		  (ND_ROOT , &mac, 1 ,NULL, 0, 1,&count),
		      targetid = text.objid,
		      targetos = text.osnum);
 if(status != OM_S_SUCCESS)
		mac = me->text.obj_id;

 om$get_classid(	objid = mac.objid,
			osnum = mac.osnum,
			p_classid = &classid);

 if(om$is_ancestry_valid(superclassid = OPP_SMCpTxt_class_id,
			 subclassid = classid) == OM_S_SUCCESS){

	/* the text has already been copied and consume, it is a
	   a modify */

	is_modify = TRUE;
     	status = om$send( msg = message SMmgr.SMGetAttDbl
		      				(&msg,
		       				 "delta_x",
						 &dx2,
						 &type),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     	if (!(status & msg & 1))
      			{ printf("erreur retrieving delta_x\n"); goto wrapup; }
	

     	status = om$send( msg = message SMmgr.SMGetAttDbl
		      				(&msg,
		       				 "delta_y",
						 &dy2,
						 &type),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     	if (!(status & msg & 1))
      			{ printf("erreur retrieving delta_y\n"); goto wrapup; }
	
     	status = om$send( msg = message SMmgr.SMGetAttDbl
		      				(&msg,
		       				 "delta_z",
						 &dz2,
						 &type),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     	if (!(status & msg & 1))
      			{ printf("erreur retrieving delta_z\n"); goto wrapup; }

	status = om$send( msg = message SMmgr.SMGetAttDbl
                                                (&msg,
                                                 "aa",
                                                 &aa2,
                                                 &type),
                      targetid = mac.objid,
                      targetos = mac.osnum);
        if (!(status & msg & 1))	aa2 = 0.0 ;

	

 	dx1 = me->mnevents[1].event.button.x - me->mnevents[0].event.button.x;
 	dy1 = me->mnevents[1].event.button.y - me->mnevents[0].event.button.y;
 	dz1 = me->mnevents[1].event.button.z - me->mnevents[0].event.button.z;

	me->delta_x = dx1 + dx2;
	me->delta_y = dy1 + dy2;
	me->delta_z = dz1 + dz2;
	aa	    = aa1 + aa2;
 }
 else{


 	/* compute dx, dy, dz */

 	me->delta_x = me->mnevents[1].event.button.x - me->mnevents[0].event.button.x;
 	me->delta_y = me->mnevents[1].event.button.y - me->mnevents[0].event.button.y;
 	me->delta_z = me->mnevents[1].event.button.z - me->mnevents[0].event.button.z;	
	aa	    = aa1;

 }

 SMSetAttr("delta_x",ACrg, att_type,&nb_att, AC_ATTRIB_DOUBLE, 
		me->delta_x, (char *)NULL, SM_DYNAMIC_ATT | SM_SYST_ATT,
		SM_MAX_CPCSM_ATTR );
 
 SMSetAttr("delta_y",ACrg,att_type,&nb_att, AC_ATTRIB_DOUBLE, 
		me->delta_y, (char *)NULL, SM_DYNAMIC_ATT | SM_SYST_ATT,
		SM_MAX_CPCSM_ATTR );

 SMSetAttr("delta_z",ACrg, att_type,&nb_att, AC_ATTRIB_DOUBLE, 
		me->delta_z, (char *)NULL, SM_DYNAMIC_ATT | SM_SYST_ATT,
		SM_MAX_CPCSM_ATTR );

 SMSetAttr("aa",ACrg, att_type,&nb_att, AC_ATTRIB_DOUBLE,
                aa, (char *)NULL, SM_DYNAMIC_ATT | SM_SYST_ATT,
                SM_MAX_CPCSM_ATTR );

	
 if(is_modify){
	me->macro_id = mac;
                status = om$send( msg = message SMCpTxt.SMModify
                                                (&msg,
                                                 nb_att,
                                                 ACrg,
                                                 att_type,
                                                 &text),
                      targetid = me->macro_id.objid,
                      targetos = me->macro_id.osnum);

     	if (!(status & msg & 1))
      			{ printf("erreur modifying SMCpTxt\n"); goto wrapup; }
 }
 else{
 	/* copy and consume the text */

	me->macro_id.objid = NULL_OBJID;
     	me->macro_id.osnum = me->ModuleInfo.md_id.osnum;
     	status = om$construct(classid = OPP_SMCpTxt_class_id,
			   osnum   = me->macro_id.osnum,
			   p_objid = &me->macro_id.objid );
     	if(!(status & 1))
      			{printf("erreur creating macro\n"); goto wrapup; }

     	status = om$send( msg = message SMCpTxt.SMcreate
		      				(&msg,
		       				 nb_att,
						 ACrg,
						 att_type,
		       				 &text),
		      targetid = me->macro_id.objid,
		      targetos = me->macro_id.osnum);
     	if (!(status & msg & 1))
      			{ printf("erreur creating SMCpTxt\n"); goto wrapup; }
 }

 *sts = OM_S_SUCCESS;
 return OM_S_SUCCESS;

wrapup:
 *sts = OM_E_ABORT;
 return OM_S_SUCCESS;


} 

/******************************************************************/

action dynamics
{
    switch (dynamics)
    {
        case my_dyn:
            co$dymove (msg = &me->ret,
                       from_point = &me->mnevents[0].event.button,
                       module = &me->ModuleInfo,
                       event = &me->event1);
            break;

        default:
            om$send (mode = OM_e_wrt_message,
                     msg = message CEO_LOCATE.dynamics
                          (dynamics, (int *)&me->ret),
                     targetid = my_id);
    }

   *sts = OM_S_SUCCESS;
   goto quit ;
}
 
