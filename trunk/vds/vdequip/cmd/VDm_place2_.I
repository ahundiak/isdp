/* $Id: VDm_place2_.I,v 1.1.1.1 2001/01/04 21:08:43 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/cmd / VDm_place2_.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_place2_.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:43  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/12/29  18:19:38  pinnacle
# Replaced: vdequip/cmd/VDm_place2_.I for:  by kddinov for vds
#
# Revision 1.2  1997/10/30  22:15:22  pinnacle
# Warnings
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1997/02/28  10:32:50  pinnacle
# Replaced: vdequip/cmd/VDm_place2_.I for:  by ksundar for vds.241
#
# Revision 1.2  1996/10/24  21:40:16  pinnacle
# Replaced: vdequip/cmd/VDm_place2_.I for:  by msmanem for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1994/12/14  22:07:04  pinnacle
# Replaced:  vdequip/cmd/VDm_place2_.I r#
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
 *	11/14/94	adz		add attribute driven symbology.
 *	07/19/96	msm		Reconcile PME changes
 *      10/30/97        ah              warnings
 *	12-97		kdd		Place from PID equipment.
 *
 * -------------------------------------------------------------------*/

/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation VDm_place;

/*
#define vdserrDEBUG
#define vdsDEBUG    1
*/

#include "OMprimitives.h"
#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "nddef.h"
#include "acdef.h"
#include "acmacros.h"
#include "ndmacros.h"
#include "ASmessages.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "lcmacros.h"

#include "asmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "expression.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "expmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "ACcheckin.h"
#include "VDScheckdef.h"
#include "VDPdef.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "ci.h"
#include "ciexecmacros.h"
#include "vdattmacros.h"
#include "VDToolsDef.h"
#include "vdparmacros.h"
#include "VDAttribMac.h"

#define AS_DEBUG

from	ACdb_info	import	ACset_db_info;
from	NDnode		import	NDchg_state;
from	ACconst		import	ACmplace_from_def;
from	GRvg		import	GRputname,
				GRputsymb;
from	NDnode		import	ASreturn_go;
from	FIdirform	import	update;
from	ACmacro_defn	import	ACgive_upscan;
from	expression	import	NDgive_structure;
from	ci		import	is_entry_point,
				set_value;
from	VDSroot		import	VDputAttrDrivenSymb;


extern struct ACdef_param ACglobal_place;

extern	GRclassid	OPP_ACrg_collect_class_id;
extern	GRclassid	OPP_GRvg_class_id;
extern	GRclassid	OPP_expression_class_id;
extern	GRclassid	OPP_ASsource_class_id;

from ACrg_collect import ACadd_list_attribute, ACget_named_attribute,
			 AClist_attribute, ACget_attribute_at_index,
			 ACset_list_attribute, ACshow_data, ACrem_attribute;
from GRgraphics import GRdisplay;
from VDPEqBuffer import VDPrsrvEquipment;

 
/* ******************* MSG place_macro () *****************************	*/

method place_macro()
{
IGRlong			msg,
			sts,
			status;
int			i,
			j,
			suc,
			my_nb_temp,
			temp_name_len;
struct	GRid		go,
			def_id,
			*my_temp;
IGRchar			template_name[PATH_MAX],
			dir_name[PATH_MAX];
GRclassid		obj_class;
short			active_level;
struct	IGRdisplay	active_display;
struct	ACrg_coll	my_att;
struct	ret_struct	txt_str;

enum	GRdpmode	dpmode = GRbd;

// struct	GRsymbology	symbology;

    SetProc( place_macro : VDm_place2_.I); Begin

// Get rid of warning
if (SCI_fileid);

my_temp	= NULL;


  /* get active symbology and directory */

     status = om$send(msg = message COm_place.get_active_symb
				(&active_level,&active_display,dir_name),
		      targetid = my_id);
     as$status(action = RET_STATUS);


	def_id.objid	= NULL_OBJID;
	sts = ac$find_macro_defn(	action		= ACfind_load,
					macro_name	= "VDequidef",
					p_macro_defn_id	= &def_id );
	as$status( sts = sts );

	/*| create a new dyn */
	me->dyn_box.osnum = me->stat_box.osnum;
	sts = om$construct(	classid	= OPP_ACrg_collect_class_id,
				osnum	= me->dyn_box.osnum,
				p_objid = &me->dyn_box.objid );
	as$status( sts = sts );
	
	/* | set value in dyn box */
	my_nb_temp	= 2;
	for( i=0; i<me->Nb_Max_Temp; i++ ){

		if( ! strcmp( me->dup[i].prompt, "~rep") ){
			/*" rep pos : %d\n", i */
			continue;
		}

		if( me->dup[i].type & parameter_generic ){

			strcpy( my_att.name, me->dup[i].prompt );

			if( me->Temp_List[i].objid != NULL_OBJID ){

				/*| use new val */

				sts = om$send(	msg	 = message 
					expression.NDgive_structure
						( &msg, &txt_str, &me->ModuleInfo ),
					targetid = me->Temp_List[i].objid,
					targetos = me->Temp_List[i].osnum );
				as$status( sts = sts );

				if( txt_str.type == text_type ){

					my_att.desc.type = AC_ATTRIB_TEXT;
					strcpy( my_att.desc.value.att_txt, 
						txt_str.var.text_st.text_string );
					
				} else if( txt_str.type == double_type ){

					my_att.desc.type = AC_ATTRIB_DOUBLE;
					my_att.desc.value.att_exp = 
						txt_str.var.root_pm_st.value;

				  } else {

					printf(" obj is not a text \n");
					my_att.desc.type = AC_ATTRIB_TEXT;
					my_att.desc.value.att_txt[0] = '\0';
				    }

			} else {

				/*| use default value */

				if( me->dup[i].type == double_type ){

					my_att.desc.type = AC_ATTRIB_DOUBLE;
					my_att.desc.value.att_exp = 
						me->Temp_Value[i].var.root_pm_st.value;

				} else {

					my_att.desc.type = AC_ATTRIB_TEXT;
					strcpy( my_att.desc.value.att_txt, 
						me->Temp_Value[i].var.text_st.text_string );
				  }
			  }/*end use def*/

			sts = om$send(	msg	 = message ACrg_collect.ACadd_list_attribute
							( &msg, 1, &my_att ),
					targetid = me->dyn_box.objid,
					targetos = me->dyn_box.osnum );
			as$status( sts = sts );
			as$status( sts = msg );

		} else my_nb_temp++;

	}/*end for dyn*/

	/*| set new template */
	my_temp = (struct GRid *) om$malloc( size=sizeof( struct GRid ) * my_nb_temp );
	if( my_temp == NULL ){

		printf(" Error not enougth memory to allocate my_temp \n");
		status	= 0;
		goto	wrapup;
	}

	my_temp[0]	= me->stat_box;
	my_temp[1]	= me->dyn_box;

	for( i=0, j=2; i<me->Nb_Max_Temp; i++ )
		if( ! (me->dup[i].type & parameter_generic) )
			my_temp[j++] = me->Temp_List[i];

    status =   om$construct(	classname	= "VDequipment",
				osnum		= me->hdr.osnum, 
				p_objid		= &me->hdr.objid );
    as$status( action = RET_STATUS );

/* jla use macro name to place equipment as symbol or as regular macro */
/* May 93 */
{  
 char equip_type[20];
 if(me->hdr_type == HDR_CONS) strcpy(equip_type,"VDequicon");
 else			      strcpy(equip_type,"VDequidef");
    status = om$send( msg = message ACconst.ACmplace_from_def(
					&suc,
					AChdr_nodisplay,
					me->rep,
					equip_type,
					my_nb_temp, 
					my_temp,
					&me->def_hdr, 
					&me->ModuleInfo ),
		      targetid = me->hdr.objid,
 		      targetos = me->hdr.osnum );
    as$status();
}

/* display */
      if(me->hdr_symb) COmchg_var_symb(me->hdr_symb,&me->hdr,
				       active_level,&active_display,
				       &me->ModuleInfo);

/* call a potential ppl to perform additional manipulations */

      status = om$send(msg = message VDm_place.VDppl_post_placement(),
		       targetid = my_id);

    /*
     * take the symbology from the ascii file
     */

/*
    status =
    vd$get_attr_symbology(        msg = &msg,
                                  path = "config/attribute",
                                  file_name = "equip.att",
                                  obj = &me->hdr,
                                  obj_env = &me->ModuleInfo,
                                  symbology = &symbology);

     if( status & msg & 1 ){

	status =
	om$send( msg = message GRvg.GRputsymb(
                                        &msg,
                                        &symbology),
                   targetid = me->hdr.objid,
                   targetos = me->hdr.osnum);
        as$status();
     }
*/
	/* Called this method for CR: 179700254  */
 
        status =
        om$send( msg = message VDSroot.VDputAttrDrivenSymb(
                                        &msg,
                                        &me->ModuleInfo,
                                        "equip.att"),
                   targetid = me->hdr.objid,
                   targetos = me->hdr.osnum );
        /* as$status(); Do not check return status */

       status = om$send( msg = message GRgraphics.GRdisplay
				(&msg,
			         &me->ModuleInfo.md_env.matrix_type,
			          me->ModuleInfo.md_env.matrix,
				 &dpmode,
				 &me->ModuleInfo.md_id),
                       targetid = me->hdr.objid,
                       targetos = me->hdr.osnum);
       as$status();

        /* 12-97 KDD Update Add (VREquipment) or Usr (VDequipment) */
	/* attributes, with those of the located PID template. */ 

	if ( (me->LocatedPID.objid != NULL_OBJID) &&
	     (me->PIDAddAttr       != NULL      )   ){ 

__DBGpr_obj("LocatedPID   ", me->LocatedPID); 
__DBGpr_int("PIDNumAddAttr 4", me->PIDNumAddAttr);
__DBGpr_int("PIDNumUsrAttr 4", me->PIDNumUsrAttr);
           vd$modUsrAttributes( sts        = &msg,
                                object     = me->hdr,
                                md_env     = &me->ModuleInfo,
                                nbAttrs    = me->PIDNumAddAttr,
                                att        = me->PIDAddAttr);
	}

/*
{
extern 	int		VDStorage();
int	response;
long	len;
char	response_data[256];
 
        status = VDStorage( &me->hdr, VDPlacedEquipment, NULL, 1);

	response = CMD_STRING;
	strcpy(response_data, "ci = ci_VDMdEq" );
	len = strlen(response_data)+1;

        ex$putque( msg          = &status,
                   response     = &response,
                   byte         = &len,
		   pos	        = BACK,
                   buffer       = response_data);
}
*/

	


 /* Give it a name */

   if(me->hdr_type!=HDR_GRAPHIC && me->hdr_name[0]!='\0' && dir_name[0]!='\0');
    {
     char tmp_name[DI_PATH_MAX];
     sprintf(tmp_name,"%s:%s",dir_name,me->hdr_name);

     status=om$send(msg = message  GRvg.GRputname(&msg,tmp_name),
                    targetid = me->hdr.objid,
                    targetos = me->hdr.osnum);

/* Give a name to the template */

   if( me->temp_name[0] == '\0' )
    {
     /*| Does not name template */
    }
   else
    {
      
     di$pwd(dirname = template_name); /* di$add_name does not work with  */
				      /* relative name if diff os !!!!!! */
     if(me->temp_name[0] != '.')
      {
       strcat(template_name,":temp_");
       strcat(template_name,me->hdr_name);
       status = di$mkdir(dirname =template_name);
      }
     else
      {
       /* name in current directory */
       status = 1;
      }

     strcat(template_name,":");
     temp_name_len = strlen(template_name);
     if(status&1)
       {
        for(i = 0; i<me->Nb_Max_Temp; i++)
        {
	 strcpy(template_name+temp_name_len,me->dup[i].prompt);

	 /*"adding name %s\n",template_name */
	 go = me->Temp_List[i];
         om$get_classid(objid = go.objid,
                        osnum = go.osnum,
                        p_classid = &obj_class);

	 if(om$is_ancestry_valid(superclassid = OPP_ASsource_class_id,
				      subclassid = obj_class) == OM_S_SUCCESS)
	  {
	   status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
			    targetid = me->Temp_List[i].objid,
			    targetos = me->Temp_List[i].osnum);
 	   if(go.osnum != me->Temp_List[i].osnum) continue;
           om$get_classid(objid = go.objid,
                          osnum = go.osnum,
                          p_classid = &obj_class);
	  }

	 if(om$is_ancestry_valid(superclassid = OPP_GRvg_class_id,
				 subclassid = obj_class) == OM_S_SUCCESS) 
	  {
	   /*"to go %d %d\n",go.objid,go.osnum */
           status = om$send(msg = message GRvg.GRputname(&msg, template_name),
                          targetid = go.objid,
                          targetos = go.osnum);
	   as$status();
	   if(!(msg&1)) di$report_error(sts = msg);

	  }
	 
	 else if(om$is_ancestry_valid(superclassid = OPP_expression_class_id,
				      subclassid = obj_class) == OM_S_SUCCESS)
	  {
	   /*" to expression %d %d\n",go.objid,go.osnum */
           status = di$add_name(objname = template_name,
                              objid = go.objid,
                              osnum = go.osnum);
	   if(!(status&1)) di$report_error(sts = status);

	  }
	 else 
          { printf("Cant not name %d %d\n",me->Temp_List[i].objid,
					   me->Temp_List[i].osnum);
          }
	}
       }
      }
     }

 /* add the db info to the macro */

 me->db_info.quantity	= EQUIPMENT_OBJ;
 status = om$send(msg = message ACdb_info.ACset_db_info(&msg,&me->db_info),
		 targetid = me->hdr.objid,
		 targetos = me->hdr.osnum);

 as$status( action = RET_STATUS );
    /* If PME is enabled */

    if( IsPmeEnabled() == TRUE )
    {
      /* MALLIK */

      /* Enable Only Objects from Placement List */
      if ( me->PMobid[0] != '\0' )
      {
	struct GRid	Buf;
	OMuword		curOs;
	IGRchar		ListName[DI_PATH_MAX];
	IGRchar		PlCtx[VDPNAME_LEN], 
			PlCtxId[VDPOBID_LEN], 
			FileId[VDPOBID_LEN];


	__DBGpr_str("PME Obid ", me->PMobid );
	status = VDPPmeEnable ( &msg, me->hdr, me->PMobid );

	/* Reserve the item for further Placement first in the local buffer */
	/* then in the Database */
	ex$get_cur_mod( osnum = &curOs );
	status = di$give_pathname(  osnum           = curOs,
				pathname        = ListName );

	__CheckRC( status, 1, "di$give_pathname", wrapup );
	__DBGpr_str( "Path name", ListName );
	strcat (ListName, PME_GLOBAL_DIR );
	strcat (ListName, PME_EQP_LIST );

	status =
	di$translate  ( objname = ListName,
		    p_objid = &Buf.objid,
		    p_osnum = &Buf.osnum ) ;

	__DBGpr_obj( "Equipment Buffer Id", Buf );

	if( status == DIR_S_SUCCESS )
	{
	   /* Reserve in the equipment Buffer */
	    status =
	    _VD_SEND_OBJN ( Buf, VDPEqBuffer.VDPrsrvEquipment (
							&msg,
							me->PMobid ));
	    __CheckRC ( status, msg, "VDPrsrvEquipment", wrapup );
	}

	/* Reserve it in the Database */
	status = VDPGetPlacementContext( &msg, PlCtx, PlCtxId );
	CheckRC ( status, msg );
	status = VDPGetFileId( &msg, curOs, FileId );
	CheckRC ( status, msg );
	status = VDPreserveOccurrence ( &msg, PlCtxId, FileId, me->PMobid, me->hdr.objid );
	CheckRC (status, msg );

	/* Clear the PMobid from the command's instance data */
	me->PMobid[0] = '\0';
      }
    }

wrapup :

	if( my_temp != NULL )	om$dealloc( ptr=my_temp );

End;
 return status;
}

method VDppl_post_placement()
{
    long status,loc_msg;
    int ci_entry;
    OM_S_OBJID file_id;

SetProc( VDppl_post_placement); Begin;

__DBGpr_str("me->post_placement", me->post_placement); 

    if(me->post_placement[0] == '\0') return OM_S_SUCCESS;

    ci_entry = 0;
    file_id = NULL_OBJID;

    status = ci$load(file_name = me->post_placement,
		 file_id   = &file_id,
		 load = LOAD);

    if(status&1) status = om$send(msg = message ci.is_entry_point
						   (&ci_entry,"post_placement"),
                    		  targetid = file_id ,
                    		  targetos = OM_Gw_TransOSnum_0);
    as$status ( );

    if(ci_entry&1) 
     {
      status = om$send(msg = message ci.set_value ((int *)&loc_msg, "MACRO_ID",
				(char *)&me->hdr , sizeof(struct GRid)),
                       targetid = file_id,
                       targetos = OM_Gw_TransOSnum_0);
      as$status ( );

      status = om$send(msg = message ci.set_value ((int *)&loc_msg, "MOD_ENV",
			      (char *)&me->ModuleInfo ,sizeof(struct GRmd_env)),
                       targetid = file_id,
                       targetos = OM_Gw_TransOSnum_0);
      as$status ( );

      if(status&1) status = ci$run( file_id = &file_id,
				    entry = "post_placement");
      as$status ( );
     }

   if(file_id != NULL_OBJID) ci$delete(file_id = file_id);
End;
 return OM_S_SUCCESS;
}
end implementation VDm_place;
