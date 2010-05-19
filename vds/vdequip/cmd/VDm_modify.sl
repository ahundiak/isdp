/* $Id: VDm_modify.sl,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/cmd / VDm_modify.sl
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_modify.sl,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.8  1998/03/02  22:13:56  pinnacle
# Replaced: vdequip/cmd/VDm_modify.sl for:  by v250_int for vds
#
# Revision 1.7  1997/12/31  14:35:50  pinnacle
# Replaced: vdequip/cmd/VDm_modify.sl for:  by kddinov for vds
#
# Revision 1.6  1997/12/30  15:44:58  pinnacle
# Replaced: vdequip/cmd/VDm_modify.sl for:  by kddinov for vds
#
# Revision 1.5  1997/12/29  18:06:42  pinnacle
# Replaced: vdequip/cmd/VDm_modify.sl for:  by kddinov for vds
#
# Revision 1.4  1997/11/26  16:51:40  pinnacle
# Replaced: vdequip/cmd/VDm_modify.sl for:  by v250_int for vds
#
# Revision 1.3  1997/11/24  20:51:10  pinnacle
# Replaced: vdequip/cmd/VDm_modify.sl for:  by kddinov for vds
#
# Revision 1.2  1997/10/30  22:15:22  pinnacle
# Warnings				ah
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/03/18  11:01:16  pinnacle
# Replaced: smsurf/cmd/SMCmdSurf.sl for:  by ksundar for vds.240
#
# Revision 1.3  1995/10/26  20:45:34  pinnacle
# Replaced: vdequip/cmd/VDm_modify.sl for:  by yzhu for vds.240
#
# Revision 1.2  1995/09/25  21:49:26  pinnacle
# Replaced: vdequip/cmd/VDm_modify.sl for:  by sundar for vds.240
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
 *    10/30/97        ah              Warnings
 *	10-17-97	kdd	Can select another Equip. to modify parameters 
 *				state select, 
 *				form VDAddParams similar to Route VRSearchParams
 *	12-97		kdd	Can Select on PID Equipment when modifying.
 *
 * -------------------------------------------------------------------*/

command_string	VDC_M_MdEq, 0, VDMdEq
synonym		"Select Equipment", 1, VDSelEq
class		VDm_modify
super_class	CEO_LOCATE
product_name	"$VDS"
command_table   "vds.cmd"
start_state     main

form            "VDMdEqui",0, 0,"-1","-1"
form            "VDAddParams",1, 0,"-1","-1"


specification

#include <stdio.h>
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "AS_status.h" 
#include "dpmacros.h" 
#include "OMmacros.h"

instance
 {
  struct	GRid		dbox;
  variable struct ACrg_coll	att[5];
  int				nb_att;
  int				before_mark;
  char				eq_name[ATTR_TXT];
  char				eq_family[ATTR_TXT];
  char				eq_partno[ATTR_TXT];
  char				eq_partrev[ATTR_TXT];
  struct GRmd_env		*EquipEnv;
  struct GRmd_env		LocatedMd_env;
  struct GRid    		LocatedEqp;
 }

implementation

/*
#define vdsDEBUG 1
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "FI.h" 
#ifdef ENV5
%safe
#include "VX_FIproto.h"
%endsafe
#endif

#include "gr.h"
#include "AS_status.h" 
#include "dpmacros.h" 
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "VDSequipdef.h"
#include "parametric.h"
#include "VDmem.h"
#include "vdparmacros.h"
#include "VDAttribMac.h"
#include "VDToolsDef.h"
#include "v_dbgmacros.h"

/* prototypes */
#include "exproto.h"
#define  AS_DEBUG


from	NDmacro		import	ACreturn_foot,ACgive_structure;
from	ACrg_collect	import	ACshow_data;
from	ACrg_collect	import	AClist_attribute, ACadd_list_attribute;
from	ACrg_collect	import	ACset_list_attribute;
from	VDequipment	import	ACgive_db_structure;
from 	ACcpx		import  ACfind_temp_obj;
from    VDSroot         import  VDGetParamsId;

extern	int	VDStorage ();


#define	 	EXIT		4
#define	 	STORE		2
#define	 	SAVE		1
#define	 	ATTRIB		24
#define	 	ADD_ATTRIB	12
#define	 	EQ_NAME		19
#define	 	EQ_FAMILY	16
#define	 	EQ_PARTNO	22
#define	 	EQ_PARTREV	15
#define	 	MSG_FIELD	10
#define		FI_SELECT_EQUIP	28

#define SEVERE_ERROR		4
#define SUCCESS			1
#define VD_CONTINUE		128


state_table

#include "exdef.h"
#include "VDmsg.h"

#define	Form		1
#define in_form		2
#define have_error	3
#define SEVERE_ERROR	4
#define SUCCESS		1
#define VD_CONTINUE		128


/*----------------------------------------------------------------------------*/
state main

   on CMD_TYPE = 0 do   message_key VD_M_MdEq        		state start
   on CMD_TYPE = 1 do   message     "Select Equipment"      	state select
   on ELSE	   do 	message     "Unknown command"           state terminate

/*----------------------------------------------------------------------------*/
state start
	message_key		VD_M_MdEq
	prompt_key		VD_P_IdEquip
        accept_key		VD_P_AccRej
	locate_class		"VDequipment"
        locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
        locate_owner            "  LC_RIGID_COMP
                                 | LC_RIGID_OWNER
                                 | LC_FLEX_COMP
                                 | LC_FLEX_OWNER
                                 | LC_REF_OBJECTS"

	filter			locate
	
  on EX_DATA or EX_OBJID or EX_STRING
	do firstAction	
	    on RETURN_CODE = "SEVERE_ERROR"			state have_error
								state Form

/*----------------------------------------------------------------------------*/
state Form
	display_form	0
	prompt_key	VD_P_MdEqFrm
	
        execute     	load_form
	    on RETURN_CODE = "SEVERE_ERROR"			state have_error
	    on ELSE						state in_form

/*----------------------------------------------------------------------------*/
state in_form
	prompt		"modify form/move on to select"
	filter		get_event

	on EX_RJT_MOVEON					state select 
	on EX_FORM_FINISHED					state terminate	
	on VD_CONTINUE						state .

/*----------------------------------------------------------------------------*/
state have_error
	status_key VD_E_ErrEqCmd
	    on ELSE						state terminate

/*----------------------------------------------------------------------------*/
state select
	prompt_key		VD_P_IdEquip
        accept_key              VD_P_AccRej
        locate_eligible         "VDequipment,VREquipment"
        locate_properties       "LC_DP_ONLY | LC_LC_ONLY | LC_RW"
        locate_owner            "  LC_RIGID_COMP
                                 | LC_RIGID_OWNER
                                 | LC_FLEX_COMP
                                 | LC_FLEX_OWNER
                                 | LC_REF_OBJECTS"

        filter                  locate


	on EX_DATA	do VDStoreEquip	
		on CMD_TYPE = 0		do VDDisplayParams	state in_form
		on CMD_TYPE = 1		               		state terminate
								state -

/*----------------------------------------------------------------------------*/
action VDStoreEquip
{
   struct GRid			LocatedEqp;
   struct GRmd_env		LocatedMd_env;

  *sts = SUCCESS;

__DBGpr_obj("Located Object", me->event1.located_object[0].located_obj); 

   /*----- Store located Eqip Id, for further use in other commands ----*/
   *sts = VDStorage( &me->event1.located_object[0].located_obj, 
					VDPidSelectEquip, NULL, 1); 

   *sts = VDStorage( &me->event1.located_object[0].module_info, 
					VDEqpStoreEnv, NULL, 1); 

   me->LocatedMd_env = me->event1.located_object[0].module_info;
   me->LocatedEqp    = me->event1.located_object[0].located_obj;

   dp$erase_hilite(msg = sts);

return (OM_S_SUCCESS); 
}

/*----------------------------------------------------------------------------*/
action VDDisplayParams 
{
struct ACrg_coll		*Attrib = NULL;
IGRint				NumAttrib = 0;
   struct GRid			LocatedEqp, UsrParId, MisParId;
   struct GRmd_env		LocatedMd_env;
   char				classname[256];

   *sts = SUCCESS;

   if(me->forms[1].form_ptr == NULL) {*sts = SEVERE_ERROR; goto wrapup;}
   FIf_display ( me->forms[1].form_ptr );

/*-------------------
# Get User attributes from located template Equipment. Display them in form[1].
-------------------*/
   LocatedMd_env = me->LocatedMd_env;
   LocatedEqp    = me->LocatedEqp;

/*--------------------
* VDequipment and VREquipment store attributes differently.
* In VDequipment they are called UsrAttributes (vd$getUsrAttributes).
* In VREquipment those are AddAttributes = (UsrAttributes - MisAttributes).
*
* Note: VRGeneric.VRGetParams == VDSroot.VDGetParamsId
--------------------*/
   om$get_classname( osnum         = LocatedEqp.osnum,
                     objid         = LocatedEqp.objid,
                     classname     = classname);
 
   if ( !strcmp(classname,"VDequipment") ) {
	status = vd$getUsrAttributes( sts	    = sts,
					object	    = LocatedEqp,
					md_env	    = &LocatedMd_env,
		                        nbAttrs     = &NumAttrib,
		                        att         = &Attrib);
   }
   else if ( !strcmp(classname,"VREquipment") ) {
        status = om$send( msg     = message VDSroot.VDGetParamsId
                                          ( sts, NULL, &UsrParId, &MisParId),
                         targetid = LocatedEqp.objid,
                         targetos = LocatedEqp.osnum );
 
        VD$ModifyCollection( p_msg                 = sts,
                             Operation             = VD_MERGE_COLL,
                             p_InputCollectionId   = &UsrParId,
                             OutParList            = &Attrib,
                             OutNumPar             = &NumAttrib );

        VD$ModifyCollection( p_msg                 = sts,
                             Operation             = VD_SUBSTR_COLL,
                             p_InputCollectionId   = &MisParId,
                             OutParList            = &Attrib,
                             OutNumPar             = &NumAttrib );
   }

   VD$DispCollAttr2(      pForm   = me->forms[1].form_ptr,
                          Gadget  = ADD_ATTRIB,
                          pNbAttr = &NumAttrib,
                          ListAttr= Attrib );


wrapup :

   if ( Attrib) { _FREE ( Attrib ); Attrib = NULL;}

   return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/
action firstAction {

struct	GRid 			loc_obj;
long				msg;
int				rc, i, found;
struct	ret_struct		str;
struct	ACrg_coll		my_att;

*sts = SUCCESS;

if (0) goto quit; // Get rid of warning
if (status);

/* 12-97 KDD  Initialization */
me->LocatedEqp.objid = NULL_OBJID;


loc_obj= me->event1.located_object[0].located_obj;
/*"loc_obj: %d, %d\n",loc_obj.objid,loc_obj.osnum*/

/* GET STATIC INFORMATION */
status = om$send(	msg	= message VDequipment.ACgive_db_structure(
					&rc,
					NULL,
					"mac_name",
					&str,
					&me->event1.located_object[0]
							.module_info  ),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum );
if(!(rc & 1)) { printf("ERROR ACgive_db_structure for eq_name\n"); goto wrapup;}
strcpy(me->eq_name, str.var.text_st.text_string);
status = om$send(	msg	= message VDequipment.ACgive_db_structure(
					&rc,
					NULL,
					"eqp_family",
					&str,
					&me->event1.located_object[0]
							.module_info  ),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum );
if(!(rc & 1)) { printf("ERROR ACgive_db_structure for eq_family\n"); goto wrapup;}
strcpy(me->eq_family, str.var.text_st.text_string);
status = om$send(	msg	= message VDequipment.ACgive_db_structure(
					&rc,
					NULL,
					"eqp_partno",
					&str,
					&me->event1.located_object[0]
							.module_info  ),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum );
if(!(rc & 1)) { printf("ERROR ACgive_db_structure for eq_partno\n"); goto wrapup;}
strcpy(me->eq_partno, str.var.text_st.text_string);
status = om$send(	msg	= message VDequipment.ACgive_db_structure(
					&rc,
					NULL,
					"eqp_partrev",
					&str,
					&me->event1.located_object[0]
							.module_info  ),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum );
if(!(rc & 1)) { printf("ERROR ACgive_db_structure for eq_partrev\n"); goto wrapup;}
strcpy(me->eq_partrev, str.var.text_st.text_string);

dp$erase_hilite(msg = &msg);

/* MALLIK
status = om$send(	msg	= message NDmacro.ACreturn_foot(
					&msg,
					FEET_DYN_BOX,
					&me->dbox,
					NULL,
					NULL ),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum );
*/

status = om$send ( msg   = message ACcpx.ACfind_temp_obj(
					&rc,
					"userpara",
					&me->dbox ),
			targetid = loc_obj.objid,
			targetos = loc_obj.osnum );

as$status( );

#ifdef DEBUG
printf(" dbox : %d/%d\n", me->dbox.objid, me->dbox.osnum ); 
#endif

/********  GET DYNAMIC ATTRIBUTES ********/

	/* | get attr list */
	status = om$send(	msg	 = message ACrg_collect.AClist_attribute
					( &msg, 0, NULL, &me->nb_att ),
			targetid = me->dbox.objid,
			targetos = me->dbox.osnum );
	as$status( );
	/*" nb_att : %d\n", me->nb_att */
	
       if(om$dimension_of(varray = me->att) <= me->nb_att)
          {
	    if(!(om$vla_set_dimension(varray = me->att,
					size = me->nb_att + 1) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");goto wrapup;}
          }

	status = om$send(	msg	 = message ACrg_collect.AClist_attribute
					( &msg, me->nb_att, me->att, &me->nb_att ),
			targetid = me->dbox.objid,
			targetos = me->dbox.osnum );
	as$status( );

/* KLUDGE to allow add attributes */

	found = 0;
	for(i=0;i<me->nb_att; i++)
	 {
	  if(strcmp(me->att[i].name,"mark_user" ) == 0) 
	    {
		found = 1;
		me->before_mark = i ;
	    }
         }
	if(found == 0)
	 {
	   /*|add attribute mark_user */
	   strcpy( my_att.name, "mark_user" );
	   my_att.desc.type		= AC_ATTRIB_DOUBLE;
	   my_att.desc.value.att_exp	= 0.;
	   status = om$send(msg	 = message ACrg_collect.ACadd_list_attribute
					( &msg, 1, &my_att ),
			targetid = me->dbox.objid,
			targetos = me->dbox.osnum );
	   as$status( );
	   me->nb_att = me->nb_att +1;
           if(om$dimension_of(varray = me->att) <= me->nb_att)
             {
	       if(!(om$vla_set_dimension(varray = me->att,
					size = me->nb_att + 1) & 1))
		 {printf("Bad dynamic allocation of intermediate\n");goto wrapup;}
             }
	   status = om$send(	msg	 = message ACrg_collect.AClist_attribute
					( &msg, me->nb_att, me->att, &me->nb_att ),
			targetid = me->dbox.objid,
			targetos = me->dbox.osnum );
	   as$status( );
	   me->before_mark = me->nb_att - 1;

	 } 
        /*"me->before_mark: %d\n",me->before_mark*/

/*^
        for(i=0;i<me->nb_att; i++)
         {
           printf("................ attribute #%d\n",i);
           printf("att.name: <%s>\n", me->att[i].name);
           printf("att.type: <%d>\n", me->att[i].desc.type);
		switch( me->att[i].desc.type ) {
		case AC_ATTRIB_DOUBLE :
			printf("att.exp: <%lf>\n", me->att[i].desc.value.att_exp);
			break;
		case AC_ATTRIB_TEXT :
			printf("att.txt: <%s>\n", me->att[i].desc.value.att_txt);
			break;
		default :
			printf(" type unknown 1\n");
 			goto wrapup;
		}
         }
*/
return OM_S_SUCCESS;

wrapup :

	*sts = SEVERE_ERROR;
        return OM_S_SUCCESS;


}
/*----------------------------------------------------------------------------*/
action load_form
{
int	i,j;
char	text[ATTR_NAME];

if (0) goto quit; // Get rid of warning
if (status);

me->ret = SUCCESS;
if(me->forms[0].form_ptr == NULL) {me->ret = SEVERE_ERROR; return OM_S_SUCCESS;}
FIfld_set_text(me->forms[0].form_ptr, EQ_NAME, 0, 0,me->eq_name,FALSE);
FIfld_set_text(me->forms[0].form_ptr, EQ_FAMILY, 0, 0,me->eq_family,FALSE);
FIfld_set_text(me->forms[0].form_ptr, EQ_PARTNO, 0, 0,me->eq_partno,FALSE);
FIfld_set_text(me->forms[0].form_ptr, EQ_PARTREV, 0, 0,me->eq_partrev,FALSE);

/*"Fill the field before mark: %d\n",me->before_mark */

for(i=0;i<me->before_mark ;i++)
 {
   /*"index attribute: %d\n",i*/
   FIfld_set_text(me->forms[0].form_ptr, ATTRIB, i, 0,me->att[i].name,FALSE);
   switch( me->att[i].desc.type ) {
	case AC_ATTRIB_DOUBLE :
   		FIfld_set_text(me->forms[0].form_ptr, ATTRIB, i, 1,"double",FALSE);
		sprintf(text,"%lf",me->att[i].desc.value.att_exp);
   		FIfld_set_text(me->forms[0].form_ptr, ATTRIB, i, 2,text,FALSE);
		break;
	case AC_ATTRIB_TEXT :
   		FIfld_set_text(me->forms[0].form_ptr, ATTRIB, i, 1,"text",FALSE);
   		FIfld_set_text(me->forms[0].form_ptr, ATTRIB, i, 2,me->att[i].desc.value.att_txt,FALSE);
		break;
	default :
		printf(" type unknown 2\n");
 		goto wrapup;
   
   }

 }

/*"Fill the field after mark de %d a %d\n",me->before_mark+1 , me->nb_att*/

for(i=0,j=me->before_mark+1;j<me->nb_att;j++,i++)
 {
   /*"index added attribute: %d\n",j*/
   FIfld_set_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 0,me->att[j].name,FALSE);
   switch( me->att[j].desc.type ) {
	case AC_ATTRIB_DOUBLE :
   		FIfld_set_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 1,"double",FALSE);
		sprintf(text,"%lf",me->att[j].desc.value.att_exp);
   		FIfld_set_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 2,text,FALSE);
		break;
	case AC_ATTRIB_TEXT :
   		FIfld_set_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 1,"text",FALSE);
   		FIfld_set_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 2,me->att[j].desc.value.att_txt,FALSE);
		break;
	default :
		printf(" type unknown 3\n");
 		goto wrapup;
   
   }

 }
return OM_S_SUCCESS;
wrapup :

	me->ret = SEVERE_ERROR;
        return OM_S_SUCCESS;
}
/*----------------------------------------------------------------------------*/
action form_notification {
	
int	r_pos,i,j, act_col,act_row,sel_flag, num_row;
char	text[ATTR_NAME],type[ATTR_NAME],name[ATTR_TXT],*end_ptr;
long	msg;
int	sts, index;
double	d_val;
double  strtod();
int	stat_len, dyn_len;
char	*p_str;
char	classname[256];

   struct ACrg_coll	*AddAttr = NULL, 
			*UsrAttr = NULL,
			*DynAttr = NULL,
			*Attr	 = NULL;

   int			NumAddAttr=0, NumUsrAttr = 0, NumAttr = 0, NumDynAttr=0;

   struct GRid		LocatedEqp, UsrParId;
   struct GRmd_env	LocatedMd_env;


if (0) goto quit; // Get rid of warning
if (status);

/*-------------------
# Switch between forms.
-------------------*/
	if (form_ptr == me->forms[1].form_ptr ) { goto l_VDAddParams; }

/*-------------------
# VDMdEqui form.
-------------------*/
   	FIfld_set_text(me->forms[0].form_ptr, MSG_FIELD, 0, 0,"" ,FALSE);

	switch( gadget_label ) 
 	{
	  case FI_SELECT_EQUIP:
		_put_response( resp = EX_RJT_MOVEON ) ;
		break;

	  case ADD_ATTRIB:
		/*|case ADD_ATTRIB*/

    		FIfld_get_active_row(me->forms[0].form_ptr, ADD_ATTRIB, &act_row, &r_pos);
    		FImcf_get_active_col(me->forms[0].form_ptr, ADD_ATTRIB, &act_col, &r_pos);

   		FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, act_row, 0,
                          ATTR_TXT, (unsigned char *)name, &sel_flag, &r_pos );
   		FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, act_row, 1,
                          ATTR_NAME, (unsigned char *)type, &sel_flag, &r_pos );
   		FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, act_row, 2,
                          ATTR_NAME, (unsigned char *)text, &sel_flag, &r_pos );

		if(act_col == 2 && text[0] != '\0')
		  {
		    /*| set corresponding type */
                    d_val = strtod(text, &end_ptr);
		    if( *end_ptr == '\0' )
			{
			  /*|type must be a double */
   			  FIfld_set_text(me->forms[0].form_ptr, ADD_ATTRIB, act_row, 
					      1,"double" ,FALSE);
		        }
		    else if( *end_ptr != '\0' )
			{
			  /*|type must be a text */
   			  FIfld_set_text(me->forms[0].form_ptr, ADD_ATTRIB, act_row, 
					 1,"text" ,FALSE);
			 }
                  }
		break;

	  case ATTRIB:
		/*|case ATTRIB*/

    		FIfld_get_active_row(me->forms[0].form_ptr, ATTRIB, &act_row, &r_pos);
    		FImcf_get_active_col(me->forms[0].form_ptr, ATTRIB, &act_col, &r_pos);

		if(act_row >= me->before_mark)
                   {
		     /* Modif PL Nov 94 always pos_cursor on previous row */
		     /* if delete_rows					  */
           	     FIfld_pos_cursor(me->forms[0].form_ptr,ATTRIB,act_row-1,0,0,0,0,0);
		     FIfld_delete_rows(me->forms[0].form_ptr,ATTRIB, act_row,1);
		   }
   		FIfld_get_text(me->forms[0].form_ptr, ATTRIB, act_row, 1,
                         ATTR_NAME, (unsigned char *)type, &sel_flag, &r_pos );
   		FIfld_get_text(me->forms[0].form_ptr, ATTRIB, act_row, 2,
                         ATTR_NAME, (unsigned char *)text, &sel_flag, &r_pos );

		if(strcmp(type, "double") == 0 && text[0] == '\0')
		  {
			  /*| double without value */
   			  FIfld_set_text(me->forms[0].form_ptr, MSG_FIELD, 0, 
			              	 0,"attribute must be a double" ,FALSE);
			  sprintf(text,"%lf",me->att[act_row].desc.value.att_exp);
   			  FIfld_set_text(me->forms[0].form_ptr, ATTRIB, act_row, 
					      2, text,FALSE);
			  break;
		  }
		if(strcmp(type, "text") == 0 && text[0] == '\0') break;

		if(act_col == 2 && text[0] != '\0')
		  {
		    /*| set corresponding type */
                    d_val = strtod(text, &end_ptr);
		    if( *end_ptr == '\0' )
			{
			  /*|type is a double */
/*	    modify it for TR 179423666 
         	  if(strcmp(type, "double") != 0)
			   {
   			  	FIfld_set_text(me->forms[0].form_ptr, MSG_FIELD, 0, 
			              	 0,"attribute must be a text" ,FALSE);
   			  	FIfld_set_text(me->forms[0].form_ptr, ATTRIB, act_row, 
					 2,me->att[act_row].desc.value.att_txt,FALSE);
			   }
*/		    
                         }
		    else if( *end_ptr != '\0' )
			{
			  /*|type is a text */
			  if(strcmp(type, "text") != 0)
			   {
   			  	FIfld_set_text(me->forms[0].form_ptr, MSG_FIELD, 0, 
			              	 0,"attribute must be a double" ,FALSE);
				sprintf(text,"%lf",me->att[act_row].desc.value.att_exp);
   			  	FIfld_set_text(me->forms[0].form_ptr, ATTRIB, act_row, 
					      2, text,FALSE);
			   }
			 }
                  }
		break;
	  case STORE:
		/*|case STORE*/

   		FIfld_get_num_rows(me->forms[0].form_ptr, ADD_ATTRIB, &num_row );
		/*"ADD_ATTRIB num_row: %d\n",num_row*/
           	/*"me->before_mark: %d\n",me->before_mark*/
		me->nb_att = me->before_mark + 1 + num_row ;
		/*"total num row: %d\n",me->nb_att*/
       		if(om$dimension_of(varray = me->att) <= me->nb_att)
          	 {
	    		if(!(om$vla_set_dimension(varray = me->att,
						  size = me->nb_att + 1) & 1))
		 	 {
			   printf("Bad dynamic allocation of intermediate\n");
			   me->ret = SEVERE_ERROR;
			   goto wrapup;
			 }
          	 }
   		FIfld_get_num_rows(me->forms[0].form_ptr, ATTRIB, &num_row );
		/*"ATTRIB num_row: %d\n",num_row*/
		for(i=0;i<num_row;i++)
 		 {
    		   FIfld_get_text(me->forms[0].form_ptr, ATTRIB, i, 0,
                           ATTR_TXT,(unsigned char *)name, &sel_flag, &r_pos );
   		   FIfld_get_text(me->forms[0].form_ptr, ATTRIB, i, 1,
                           ATTR_NAME,(unsigned char *)type, &sel_flag, &r_pos );
   		   FIfld_get_text(me->forms[0].form_ptr, ATTRIB, i, 2,
                           ATTR_NAME,(unsigned char *)text, &sel_flag, &r_pos );
		   /*^printf("row %d name: <%s>, type: <%s>, text: <%s>\n",i,me->att[i].name,
				type,text);*/
		   strcpy(me->att[i].name, name); 
		   if(  (strcmp(type, "double") == 0) ||
			(strcmp(type, "dbl"   ) == 0) )
			me->att[i].desc.type = AC_ATTRIB_DOUBLE;
		   else if( (strcmp(type, "text") == 0) || 
			    (strcmp(type, "txt")  == 0) )
			me->att[i].desc.type = AC_ATTRIB_TEXT;
		   else
			{
				printf(" type unknown 4: <%s>\n", type);
				me->ret = SEVERE_ERROR;
 				goto wrapup;
			}
		   switch( me->att[i].desc.type ) {
			case AC_ATTRIB_DOUBLE :
				sscanf(text,"%lf",&me->att[i].desc.value.
								att_exp);
				break;
			case AC_ATTRIB_TEXT :
				strncpy(me->att[i].desc.value.att_txt, text,
								  ATTR_NAME);
				break;
			default :
				printf(" type unknown 5\n");
				me->ret = SEVERE_ERROR;
 				goto wrapup;
                   }
                 }
		strcpy(me->att[me->before_mark].name,"mark_user" );
	   	me->att[me->before_mark].desc.type		= AC_ATTRIB_DOUBLE;
	   	me->att[me->before_mark].desc.value.att_exp	= 0.;
   		FIfld_get_num_rows(me->forms[0].form_ptr, ADD_ATTRIB, &num_row );
		/*"ADD_ATTRIB num_row: %d\n",num_row*/
		for(i=0, j=me->before_mark+1 ;i<num_row;i++)
 		 {
    		   FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 0,
                            ATTR_TXT,(unsigned char *)name, &sel_flag, &r_pos);
   		   FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 1,
                            ATTR_NAME,(unsigned char *)type, &sel_flag, &r_pos);
   		   FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 2,
                            ATTR_NAME,(unsigned char *)text, &sel_flag, &r_pos);
		   /*^printf("row %d name: <%s>, type: <%s>, text: <%s>\n",i,name,
				type,text);*/
		   if(type[0] == '\0' || (name[0] == '\0' && text[0] == '\0'))
		     {
			/*"row %d is not consistent\n",i*/
		        FIfld_delete_rows(me->forms[0].form_ptr,ADD_ATTRIB, i,1);
			me->nb_att = me->nb_att - 1;
			continue;
		     }
		   strcpy(me->att[j].name, name); 
                   if(  (strcmp(type, "double") == 0) ||
                        (strcmp(type, "dbl"   ) == 0) )
			me->att[j].desc.type = AC_ATTRIB_DOUBLE;
                   else if( (strcmp(type, "text") == 0) ||
                            (strcmp(type, "txt")  == 0) )
			me->att[j].desc.type = AC_ATTRIB_TEXT;
		   else
			{
				printf(" type unknown 6: <%s>\n", type);
				me->ret = SEVERE_ERROR;
 				goto wrapup;
			}
		   switch( me->att[j].desc.type ) {
			case AC_ATTRIB_DOUBLE :
				sscanf(text,"%lf",&me->att[j].desc.value.
								att_exp);
				break;
			case AC_ATTRIB_TEXT :
				strncpy(me->att[j].desc.value.att_txt, text,
								  ATTR_NAME);
				break;
			default :
				printf(" type unknown 7\n");
				me->ret = SEVERE_ERROR;
 				goto wrapup;
                   }
		   j = j+1;
                 }

/*^
	printf("me->nb_att: %d\n",me->nb_att);
        for(i=0;i<me->nb_att; i++)
         {
           printf("................ attribute #%d\n",i);
           printf("att.name: <%s>\n", me->att[i].name);
           printf("att.type: <%d>\n", me->att[i].desc.type);
		switch( me->att[i].desc.type ) {
		case AC_ATTRIB_DOUBLE :
			printf("att.exp: <%lf>\n", me->att[i].desc.value.att_exp);
			break;
		case AC_ATTRIB_TEXT :
			printf("att.txt: <%s>\n", me->att[i].desc.value.att_txt);
			break;
		default :
			printf(" type unknown 8\n");
			me->ret = SEVERE_ERROR;
 			goto wrapup;
		}
         }
*/		sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute
						( &msg, me->nb_att, me->att ),
				targetid = me->dbox.objid,
				targetos = me->dbox.osnum );
		as$status( sts = sts );

		nd$wait_batch(	type		= GR_GEOM_POSTED,
				/*p_fr_info	= &me->event1.located_object[0]
							.module_info, */
				nb_obj		= 1,
				l_object	= &me->dbox );

		nd$exec_batch();

		break;
	  case EXIT :
		_put_response( resp = EX_FORM_FINISHED ) ;
		break ;
	  case SAVE :
		/*|case SAVE*/


   		FIfld_get_num_rows(me->forms[0].form_ptr, ADD_ATTRIB, &num_row );
		/*"ADD_ATTRIB num_row: %d\n",num_row*/
           	/*"me->before_mark: %d\n",me->before_mark*/
		me->nb_att = me->before_mark + 1 + num_row ;
		/*"total num row: %d\n",me->nb_att*/
       		if(om$dimension_of(varray = me->att) <= me->nb_att)
          	 {
	    		if(!(om$vla_set_dimension(varray = me->att,
						  size = me->nb_att + 1) & 1))
		 	 {
			   printf("Bad dynamic allocation of intermediate\n");
			   me->ret = SEVERE_ERROR;
			   goto wrapup;
			 }
          	 }
   		FIfld_get_num_rows(me->forms[0].form_ptr, ATTRIB, &num_row );
		/*"ATTRIB num_row: %d\n",num_row*/
		for(i=0;i<num_row;i++)
 		 {
    		   FIfld_get_text(me->forms[0].form_ptr, ATTRIB, i, 0,
                            ATTR_TXT,(unsigned char *)name, &sel_flag, &r_pos);
   		   FIfld_get_text(me->forms[0].form_ptr, ATTRIB, i, 1,
                            ATTR_NAME,(unsigned char *)type, &sel_flag, &r_pos);
   		   FIfld_get_text(me->forms[0].form_ptr, ATTRIB, i, 2,
                            ATTR_NAME,(unsigned char *)text, &sel_flag, &r_pos);
		   /*^printf("row %d name: <%s>, type: <%s>, text: <%s>\n",i,me->att[i].name,
				type,text);*/
		   strcpy(me->att[i].name, name); 
                   if(  (strcmp(type, "double") == 0) ||
                        (strcmp(type, "dbl"   ) == 0) )
			me->att[i].desc.type = AC_ATTRIB_DOUBLE;
                   else if( (strcmp(type, "text") == 0) ||
                            (strcmp(type, "txt")  == 0) )
			me->att[i].desc.type = AC_ATTRIB_TEXT;
		   else
			{
				printf(" type unknown 9: <%s>\n", type);
				me->ret = SEVERE_ERROR;
 				goto wrapup;
			}
		   switch( me->att[i].desc.type ) {
			case AC_ATTRIB_DOUBLE :
				sscanf(text,"%lf",&me->att[i].desc.value.
								att_exp);
				break;
			case AC_ATTRIB_TEXT :
				strncpy(me->att[i].desc.value.att_txt, text,
								  ATTR_NAME);
				break;
			default :
				printf(" type unknown 10\n");
				me->ret = SEVERE_ERROR;
 				goto wrapup;
                   }
                 }
		strcpy(me->att[me->before_mark].name,"mark_user" );
	   	me->att[me->before_mark].desc.type		= AC_ATTRIB_DOUBLE;
	   	me->att[me->before_mark].desc.value.att_exp	= 0.;
   		FIfld_get_num_rows(me->forms[0].form_ptr, ADD_ATTRIB, &num_row );
		/*"ADD_ATTRIB num_row: %d\n",num_row*/
		for(i=0, j=me->before_mark+1 ;i<num_row;i++, j++)
 		 {
    		   FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 0,
                           ATTR_TXT,(unsigned char *)name, &sel_flag, &r_pos );
   		   FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 1,
                           ATTR_NAME,(unsigned char *)type, &sel_flag, &r_pos );
   		   FIfld_get_text(me->forms[0].form_ptr, ADD_ATTRIB, i, 2,
                           ATTR_NAME,(unsigned char *)text, &sel_flag, &r_pos );
		   /*^printf("row %d name: <%s>, type: <%s>, text: <%s>\n",i,name,
				type,text);*/
		   if(type[0] == '\0' || (name[0] == '\0' && text[0] == '\0'))
		     {
			/*"row %d is not consistent\n",i*/
			me->nb_att = me->nb_att - 1;
			continue;
		     }
		   strcpy(me->att[j].name, name); 
                   if(  (strcmp(type, "double") == 0) ||
                        (strcmp(type, "dbl"   ) == 0) )
			me->att[j].desc.type = AC_ATTRIB_DOUBLE;
                   else if( (strcmp(type, "text") == 0) ||
                            (strcmp(type, "txt")  == 0) )
			me->att[j].desc.type = AC_ATTRIB_TEXT;
		   else
			{
				printf(" type unknown 11: <%s>\n", type);
				me->ret = SEVERE_ERROR;
 				goto wrapup;
			}
		   switch( me->att[j].desc.type ) {
			case AC_ATTRIB_DOUBLE :
				sscanf(text,"%lf",&me->att[j].desc.value.
								att_exp);
				break;
			case AC_ATTRIB_TEXT :
				strncpy(me->att[j].desc.value.att_txt, text,
								  ATTR_NAME);
				break;
			default :
				printf(" type unknown 12\n");
				me->ret = SEVERE_ERROR;
 				goto wrapup;
                   }
                 }

/*^
	printf("me->nb_att: %d\n",me->nb_att);
        for(i=0;i<me->nb_att; i++)
         {
           printf("................ attribute #%d\n",i);
           printf("att.name: <%s>\n", me->att[i].name);
           printf("att.type: <%d>\n", me->att[i].desc.type);
		switch( me->att[i].desc.type ) {
		case AC_ATTRIB_DOUBLE :
			printf("att.exp: <%lf>\n", me->att[i].desc.value.att_exp);
			break;
		case AC_ATTRIB_TEXT :
			printf("att.txt: <%s>\n", me->att[i].desc.value.att_txt);
			break;
		default :
			printf(" type unknown 13\n");
			me->ret = SEVERE_ERROR;
 			goto wrapup;
		}
         }
*/		sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute
						( &msg, me->nb_att, me->att ),
				targetid = me->dbox.objid,
				targetos = me->dbox.osnum );
		as$status( sts = sts );

		nd$wait_batch(	type		= GR_GEOM_POSTED,
				/*p_fr_info	= &me->event1.located_object[0]
							.module_info, */
				nb_obj		= 1,
				l_object	= &me->dbox );

		nd$exec_batch();

		_put_response( resp = EX_FORM_FINISHED ) ;
		break ;
	}

return OM_S_SUCCESS;


l_VDAddParams:
/*-------------------
* 12-97 KDD. You may be here only if a template equipment has been selected.  
# VDAddParams form. Update info in VDMdEqui form, with the one in VDAddParams.
* Dynamic Collection is Updated, 
* Additional Collection is Merged, 
* Then Union both to form User collection.
-------------------*/

   switch ( gadget_label ) {
   case FI_RESET:
	FIfld_set_num_rows ( form_ptr, ADD_ATTRIB, 0); 
	break;

   case FI_ACCEPT:
	/* Merge old Additional attributes with the new ones */

        VD$CreCollFromForm(     form                    = form_ptr,
                                gadget                  = ADD_ATTRIB,
                                NumParLst               = &NumAttr,
                                ParLst                  = &Attr);

        VD$CreCollFromForm(     form                    = me->forms[0].form_ptr,
                                gadget                  = ADD_ATTRIB,
                                NumParLst               = &NumAddAttr,
                                ParLst                  = &AddAttr);

        VD$ModifyCollection( p_msg                 = &msg,
                             Operation             = VD_MERGE_COLL,
                             p_ParamsListToModify  = Attr,
                             NbParamsToModify      = NumAttr,
                             OutParList            = &AddAttr,
                             OutNumPar             = &NumAddAttr );

	VD$DispCollAttr2(    pForm   = me->forms[0].form_ptr,
                             Gadget  = ADD_ATTRIB,
                             pNbAttr = &NumAddAttr,
                             ListAttr= AddAttr );


	/* Update the Dynamic Attributes using those of the located equipment */

        VD$CreCollFromForm(     form                    = me->forms[0].form_ptr,
                                gadget                  = ATTRIB,
                                NumParLst               = &NumUsrAttr,
                                ParLst                  = &UsrAttr);

        LocatedMd_env = me->LocatedMd_env;
        LocatedEqp    = me->LocatedEqp;

/*-------------
* VDequipment and VREquipment store dynamic attributes differently 
-------------*/

	om$get_classname( osnum		= LocatedEqp.osnum,
			  objid		= LocatedEqp.objid,
			  classname 	= classname); 

	if ( !strcmp(classname,"VDequipment") ) { 
	   vd$get_params(  sts		= &msg,
                           object	= &LocatedEqp,
                           md_env	= &LocatedMd_env,
                           count	= &NumDynAttr,
                           plist 	= &DynAttr)

	   /* remove "stat_attr:" & "dyn_attr:" from attribute names*/
	   stat_len = strlen("stat_attr:");
	   dyn_len  = strlen("dyn_attr:");

	   index = NumDynAttr;
	   for ( i = 0; i < index; i++){
	       if ( (p_str = strstr(DynAttr[i].name, "stat_attr:")) != NULL ) 
			   DynAttr[i].name[0] = '\0'; 

	       if ( (p_str = strstr(DynAttr[i].name, "dyn_attr:")) != NULL )
			   strcpy( p_str, p_str + dyn_len);
	   }

           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_UPDATE_COLL,
                                p_ParamsListToModify  = DynAttr,
                                NbParamsToModify      = NumDynAttr,
                                OutParList            = &UsrAttr,
                                OutNumPar             = &NumUsrAttr );
	}
	else if ( !strcmp(classname,"VREquipment") ) {
	   status = om$send( msg     = message VDSroot.VDGetParamsId
						( &msg, NULL, &UsrParId, NULL),
                        targetid = LocatedEqp.objid,
                        targetos = LocatedEqp.osnum );

           VD$ModifyCollection( p_msg                 = &msg,
                                Operation             = VD_UPDATE_COLL,
                                p_InputCollectionId   = &UsrParId,
                                OutParList            = &UsrAttr,
                                OutNumPar             = &NumUsrAttr );
	}

        VD$DispCollAttr2(    pForm   = me->forms[0].form_ptr,
                             Gadget  = ATTRIB,
                             pNbAttr = &NumUsrAttr,
                             ListAttr= UsrAttr );


	FIf_erase( form_ptr); 
	_put_response( resp = VD_CONTINUE);
	break;

   case FI_CANCEL:
	FIf_erase( form_ptr); 
	_put_response( resp = VD_CONTINUE);
	break;

   default: 
	break;
   }

wrapup :
   if (AddAttr) {_FREE( AddAttr ); AddAttr = NULL; } 
   if (UsrAttr) {_FREE( UsrAttr ); UsrAttr = NULL; } 
   if (DynAttr) {_FREE( DynAttr ); DynAttr = NULL; } 
   if (Attr   ) {_FREE( Attr    ); Attr    = NULL; } 

   return OM_S_SUCCESS;
}
/*----------------------------------------------------------------------------*/
 
