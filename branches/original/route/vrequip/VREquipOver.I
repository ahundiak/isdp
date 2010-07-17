/* $Id: VREquipOver.I,v 1.3 2001/02/20 01:13:38 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrequip / VREquipOver.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VREquipOver.I,v $
 *	Revision 1.3  2001/02/20 01:13:38  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 16:54:35  anand
 *	SP merge
 *	
# Revision 1.1  2000/12/18  17:01:08  pinnacle
# Created: route/vrequip/VREquipOver.I by lawaddel for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.6  1997/12/31  17:10:04  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by r250_int for route
#
# Revision 1.5  1997/10/24  19:35:48  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by apazhani for route
#
# Revision 1.4  1997/10/20  15:31:26  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by kddinov for route
#
# Revision 1.7  1997/09/22  14:18:30  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by kddinov for route
#
# Revision 1.6  1997/09/12  23:19:54  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by kddinov for route
#
# Revision 1.5  1997/09/11  17:18:12  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by kddinov for route
#
# Revision 1.3  1997/09/08  03:49:32  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by kddinov for route
#
# Revision 1.2  1997/09/08  00:23:02  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.4  1997/06/27  21:03:22  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by onayragu for route
#
# Revision 1.3  1997/05/28  20:56:16  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by kddinov for route
#
# Revision 1.2  1997/02/14  15:48:10  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/04  15:45:18  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  23:47:06  pinnacle
# Replaced: vrequip/VREquipOver.I for:  by r240_int for route240
#
 *
 * History:
 *	01/19/93	Karine		creation
 *	01/16/96	tlb		Add prototypes
 *	Aug/97		kdd		GRgetattr, GRputattr
 *	10/24/97        Alwin           Modified the ACgive_structure to add
 *                                      the case "NO_MTO_FLAG"
 *
 *************************************************************************/

class implementation VREquipment;

/*
#define vdsDEBUG 1
*/

#include "OMmacros.h"
#include "OMprimitives.h"

#include "nddef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "acdef.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "bserr.h"
#include "AS_status.h"

#include "VDmem.h"
#include "VRparamdef.h"
#include "vrparameters.h"
#include "VRnozzmacros.h"
#include "VRutilmacros.h"
#include "VRmacros.h"
#include "VRutildef.h"
#include "VDScheckdef.h"
#include "VRDbParamDef.h"
#include "VREquipment.h"
#include "VRPid.h"
#include "VDSutil.h"
#include "vrpdu_pto.h"
#include "VREquipForm.h"
#include "VREquipment.h"
#include "vrdbgmacros.h"

#include "godef.h"
#include "ndmacros.h"
#include "VRattr_def.h"
#include "VDDbtbldef.h"
#include "VRstructs.h"
#include "parametric.h"

extern IGRint 	NDget_channel();

from	GRgencs		import	GRgetmatrix;
from    ACcpx_defn	import  ACgive_feet_desc;
from    ACrg_collect    import  ACget_named_attribute;
from    VRNozHold	import	VRGetInstance,
				VRGiveAttributes;
from	VRNozzle	import	VRSetSoftConnection;

#define AS_DEBUG

extern GRclassid	OPP_ACpretend_class_id;

/**************************************************************************/

method  VREvaluate (	IGRlong			*msg;
			struct VRGenInfo	*Instance;
			struct GRid 		*SysParamId;
			struct GRid 		*UserParamId;
			struct GRid 		*MissParamId;
			IGRint			*NumMaxTopo;
			IGRint			*TopoType;
			IGRint			*NbMissing;
			IGRchar			***MissingNames;
			struct ret_struct	**MissingStr;
			struct GRid		*Graphics;
			struct GRmd_env		*md_env )
{

  IGRlong	retmsg, status = 1;

SetProc(VREvaluate); Begin

/*-----------
#  KDD 9/97. VRGeneric.VRSetInstance is called from VRGeneric.VREvaluate
* om$vla_set_dimension( varray = me->EquipNo,
*                       size   = strlen( Instance->Attr.Equip.EquipNumber) +1);
*
* strcpy( me->EquipNo, Instance->Attr.Equip.EquipNumber );
*
* Instance->Attr.Equip.EquipNumber[0] = 0;
------------*/

  status =
  om$send( msg = message VRGeneric.VREvaluate (	msg,
						Instance,
						SysParamId,
						UserParamId,
						MissParamId,
						NumMaxTopo,
						TopoType,
						NbMissing,
						MissingNames,
						MissingStr,
						Graphics,
						md_env ),
	  mode 	   = OM_e_wrt_message,
	  targetid = my_id);

  if( Graphics->objid != NULL_OBJID )
  {
	status =
	om$send( msg = message GRgraphics.GRaddwrng(&retmsg,md_env),
		 targetid = Graphics->objid,
		 targetos = Graphics->osnum );
	as$status ( );

	status =
	om$send( msg = message ACncpx.ACchange_feet
					( 1, Graphics, md_env ),
		 targetid = my_id);
	as$status ( );
  }

*msg = *msg & status;
End;
return (OM_S_SUCCESS) ;

}/* end VREvaluate */

/**************************************************************************/

method VRPlaceNozzleFeet( IGRlong *ret; IGRint *NbNozzle;
			  struct GRid *NozzleIds; 
                          struct GRmd_env *md_env)
{

  IGRint			status,i,j,Index, Product;
  IGRint			NbCollections,NbAttributes[VR_NB_ATTR];
  IGRlong			retmsg;
  IGRint			NumFeet;
  IGRchar			ClassName[100];
  struct GRid			TempList[VR_NB_ATTR+1], RefId;
  struct GRid			FootId;		/* Macro's foot Id */
  struct GRid			DefId; 		/* macro definition Id */
  struct GRid			GraphicId;	/* Macro Id */
  struct VRGenInfo		NozzInstance;
  struct ACrg_coll		Attributes[200];
  struct GRsymbology		Symb;
  struct GRvg_construct		CnstList;
  struct myfeet			*FeetDesc;
  GRclassid			ClassId;
 
  extern GRclassid		OPP_VRNozHold_class_id;

  /* -- Initialize templates -- */

  for ( i=0; i<VR_NB_ATTR+1; i=i+1 )
  {
	TempList[i].objid = NULL_OBJID;
	TempList[i].osnum = md_env->md_id.osnum;
  } /*end loop on templates */

  *NbNozzle = 0;


  /*
   * Check for the terminal in the macro definition and expand if needed.
   */
  {
        IGRint  ict = 0 ;
        struct GRid     myId ;

        myId.objid      = my_id ;
        myId.osnum      = OM_Gw_current_OS ;

        status =
        VC_termexpand( ret, &ict, &myId, md_env );
  }


  status = 
  om$send( msg      = message NDnode.ASreturn_go( &GraphicId, NULL, NULL),
	   targetid = my_id,);
  as$status( action = RET_STATUS );

  if( GraphicId.objid == NULL_OBJID )	return OM_E_INVARG;

  /*| ----- Get definition of the graphic macro ----- */
  status = om$send ( 	msg 	 = message ACcpx.find_macro ( &DefId ),
			targetid = GraphicId.objid,
			targetos = GraphicId.osnum);
  /*"Def<%d,%d>\n", DefId.objid,DefId.osnum*/

  /*| ----- Get feet names from definition ----- */
  status = 
  om$send( msg 	    = message ACcpx_defn. ACgive_feet_desc
					( &NumFeet, &FeetDesc ),
	   targetid = DefId.objid,
	   targetos = DefId.osnum );

  /*^
	for (i=0; i<NumFeet; i=i+1)
	{
		printf ("Foot[%d] : Name : <%s> Type : <%d>\n",
			i, FeetDesc[i].name, FeetDesc[i].chan);

		printf ("Foot[%d] : Pos  : <%d>  Prop :  <%d>\n",
			i, FeetDesc[i].pos, FeetDesc[i].prop );

	}
  */

  /* -- Loop on macro's feet -- */
  for ( i=0; i<NumFeet; i=i+1 )
  {
	/*" Foot[%d] = <%s>\n", i, FeetDesc[i].name*/
	/*| ----- Get the foot id ----- */
	status =
	om$send ( msg = message NDmacro.ACreturn_foot
						(&retmsg, FeetDesc[i].name,
						&FootId,NULL, NULL),
		targetid = GraphicId.objid,
		targetos = GraphicId.osnum);
	if ( !(status&1))
	{
		printf (" Foot <%s> invalid in your macro construction ?\n", FeetDesc[i].name);
		as$status ();
		continue;
	}
	
	/*| ----- Get foot class ----- */
	om$get_classid(	objid		= FootId.objid,
			osnum		= FootId.osnum,
			p_classid	= &ClassId);

	/*| ----- For each foot which is a VRNozHold : ----- */
	if ( ClassId == OPP_VRNozHold_class_id )
	{
		/*| ----- Nozzle as feet ----- */
		NozzleIds[i].objid = NULL_OBJID;
		*NbNozzle 	  +=1;

		/* -- Generate attributes collections -- */

		/*| ----- Get attributes from VRNozHold ----- */
		status = 
		om$send ( msg = message VRNozHold.VRGetInstance
							( &retmsg, &Product,
					   		NozzInstance.szNumber,
					   		NozzInstance.szNotes,
					   		&NozzInstance.Attr.Nozz.dSecAngle ),
			 targetid = FootId.objid,
			 targetos = FootId.osnum );
		if ( ! (status&1) || (retmsg != MSSUCC) )
		{
			printf ("This nozzle failed \n");
			continue;
		}

		/*| ----- get attributes Collections  ----- */
		status = 
		om$send ( msg = message VRNozHold.VRGiveAttributes
						( &retmsg, VR_NB_ATTR, 200,
						&NbCollections, NbAttributes, 
						Attributes ),
			 targetid = FootId.objid,
			 targetos = FootId.osnum );
		if ( ! (status&1) || (retmsg != MSSUCC) )
		{
			printf ("This nozzle failed \n");
			continue;
		}


		/*" %d collections\n",NbCollections*/

		/*| ----- Create collections ----- */
		Index = 0;
		for (j=0; j<NbCollections; j=j+1)
		{
			TempList[j].objid = NULL_OBJID;

			status = VR$ModifyCollection
					( p_msg 		= &retmsg,
			  		Operation		= VR_MERGE_COLL,
			  		p_ParamsListToModify	= &Attributes[Index],
			  		NbParamsToModify	= NbAttributes[j],
			  		p_OutputCollectionId	= &TempList[j] );

			Index = Index + NbAttributes[j];
			if ( ! (status&1) || (retmsg != MSSUCC) )
			{
				printf ("MERGE Collection %d failed \n", j);
				continue;
			}
		/*" Template[%d] = <%d, %d>\n", j, TempList[j].objid, TempList[j].osnum*/

		}/* end loop on collections */

		if ( bVR_IS_PID(me->xform_chan))
		{

			IGRint			Index=-1;
			struct ret_struct	AttrSt;
			struct ACrg_coll	Collection;

			/*| -- Get scale factor -- */

			status=
			om$send ( msg 	= message ACncpx.ACgive_structure 
					((IGRint *) &retmsg, &Index, VR_N_PID_SCALE_DB, 
					&AttrSt, md_env),
				targetid= my_id);
			if ( ! ( status&(retmsg)&1 ) )
			{
				retmsg = MSSUCC;
				AttrSt.var.root_pm_st.value=1;
			}

			strcpy( Collection.name, VR_N_PID_SCALE_DB);
			Collection.desc.type = AC_ATTRIB_DOUBLE;
			Collection.desc.value.att_exp = AttrSt.var.root_pm_st.value;

			status = VR$ModifyCollection
				( p_msg 		= &retmsg,
			  	Operation		= VR_MERGE_COLL,
			  	p_ParamsListToModify	= &Collection,
			  	NbParamsToModify	= 1,
			  	p_OutputCollectionId	= &TempList[0] );
		}

		/*| ----- Place a nozzle ----- */

		NozzInstance.cRep		= me->xform_chan;
		NozzInstance.nStatus		= 0;
		NozzInstance.nJustif		= VR_CENTER_JUST;
		NozzInstance.szAABBCC[0]	= 0;

		status = VR$EvaluateNozz( p_msg			= &retmsg,
	 		  		Product			= Product,
	 		  		p_Instance		= &NozzInstance,
	 		  		p_SysParamsId		= &TempList[0],
	 		  		p_UsrParamsId		= &TempList[1],
	 		  		p_MssParamsId		= &TempList[2],
			  		p_ComponentId		= &NozzleIds[i],
	 		  		p_NbMissingParams	= NULL,
	 		  		p_NbCpts		= NULL,
	 		  		p_MdEnv			= md_env );

		if ( ! (status&1) || (retmsg != MSSUCC) )
		{
			printf ("Nozzle evaluation failed \n");
			goto VRNoNozzle;
		}

		/* get symbology */

 		status = 
		om$send ( msg = message GRvg.GRgetsymb( &retmsg, &Symb ),
			  targetid = my_id);
		as$status();
		if ( ! (status&1))
		{
			printf ("This nozzle failed \n");
			goto VRNoNozzle;
		}

		CnstList.level   = Symb.level;
		CnstList.display = &Symb.display_attr;

		/*| ----- get the right object to connect to ----- */
		status =
		om$send ( msg = message ASnode.ACgive_path
				( (IGRint *) &retmsg, &GraphicId, ClassName),
			targetid = my_id);
		as$status();

		strcat (ClassName, ":");
		strcat (ClassName, FeetDesc[i].name);

		/*" Foot path = <%s>\n", ClassName*/
		status =
		om$send ( msg = message ASnode.ACconnect_pretend( 
						(IGRint *) &retmsg,
						ClassName, &RefId  ),
			targetid = my_id);

		/*"RefId = <%d,%d>\n", RefId.objid,RefId.osnum*/

		status = 
		VR$PlaceNozz (	p_msg		= &retmsg,
				p_ComponentId	= &NozzleIds[i],
				p_Instance 	= &NozzInstance,
				p_RefId		= &RefId,
				p_CnstList	= &CnstList,
				p_MdEnv 	= md_env );
		if ( ! (status&1) || (retmsg != MSSUCC) )
		{
			printf ("Nozzle placement failed \n");
			goto VRNoNozzle;
		}

		continue;
  VRNoNozzle :

		if ( NozzleIds[i].objid != NULL_OBJID )
		{
			printf ("DELETENOZZLE\n");
		}
	}/* end generate nozzle */
	else
	{
		/*| ----- No Nozzle as feet ----- */
	}

  }/* end loop on feet */

*ret = *ret & status;

  return OM_S_SUCCESS;
}

/* ********************* MSG ACgive_structure () *******************    */

method ACgive_structure( IGRint *rc; IGRint *direct_ind; IGRchar *foot_name;
			struct ret_struct *str; struct GRmd_env *md_env )
{
  IGRint		status=OM_S_SUCCESS;

/*" Footname= %s \n", foot_name  */

/*
on June 27th 1997 : "Henk" said eqp_number is not retrieved from the instance
anymore TR#179701308.
if ( !(strcmp (foot_name, "eqp_number")) )
{
	str->type= text_type;
	strcpy( str->var.text_st.text_string, me->EquipNo);
}
else
*/

SetProc( ACgive_structure ); Begin
 
__DBGpr_str( "Footname ", foot_name );
 
if( !strcmp( foot_name, VD_N_NO_MTO_FLAG_AN ) )
{
        IGRint  i, NumSysAttr;
        IGRlong msg;
        struct ACrg_coll *SysAttr = NULL;
        struct GRid UsrParId;
 
        __DBGpr_int( "Equipment Id ", my_id );
 
        str->type= text_type;
        str->var.text_st.text_string[0] = '\0';
 
        /* Get the ParamId using the VRGetParams */
        status = om$send ( msg = message VRGeneric.VRGetParams( &msg,
                                          NULL, &UsrParId, NULL ),
                                  targetid = my_id );
 
        NumSysAttr = 1;
 
        __DBGpr_obj( "UsrParId ", UsrParId );
 
        NumSysAttr = 1;
 
        /* If it's not found in System Collection, Try if it exists in the
           User Collection */
        if( UsrParId.objid != NULL_OBJID )
        {
          status =
          VR$ModifyCollection(    p_msg                 = &msg,
                                  Operation             = VR_UPDATE,
                                  p_InputCollectionId   = &UsrParId,
                                  OutNumPar             = &NumSysAttr,
                                  OutParList            = &SysAttr );
 
          for ( i = 0; i < NumSysAttr; i++ )
          {
             __DBGpr_str( "User Attr Name ", SysAttr[ i ].name );
 
             if (!strcmp( SysAttr[ i ].name , VD_N_NO_MTO_FLAG_AN ))
             {
                strcpy( str->var.text_st.text_string,
                        SysAttr[ i ].desc.value.att_txt);
 
                __DBGpr_str( "no_mto_flag ", str->var.text_st.text_string );
 
                if ( SysAttr)
                {
                  _FREE ( SysAttr );
                  SysAttr = NULL;
                }
 
                *rc = MSSUCC;
                return (status = OM_S_SUCCESS);
             }
          }
        }
 
        str->var.text_st.text_string[0] = '\0';
        __DBGpr_str( "no_mto_flag ", str->var.text_st.text_string );
        return OM_S_SUCCESS;
}
else
{
	/*A Try generic feet management */
	status=
	om$send (msg = message VRGeneric.ACgive_structure 
			( rc, direct_ind, foot_name, str, md_env),
		mode = OM_e_wrt_message,
		targetid = my_id);
	/*" status = %d, msg = %d\n", status, *msg */

}/* end try OM_e_wrt_message */

*rc = *rc & status ; 
End ;
return ( OM_S_SUCCESS );

}/* end ACgive_structure */

/***********************************************************************/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{

        IGRchar                 string[50];

        *msg = MSSUCC;

	strcpy( string, "EQ");

/* if( me->EquipNo[0] ) { */
	if ( om$dimension_of(varray = me->EquipNo) > 1 ) { 
		strcat( string, "-" );
		strcat( string, me->EquipNo );
	}

	strcpy ( info->type, string );

	return OM_S_SUCCESS;	

}/* end GRgetobjinfo */

/***********************************************************************/

method VRGetDefName ( IGRlong   *msg; IGRchar *sMacroName )

{
  *msg = MSSUCC;

  strcpy ( sMacroName, "VDequidef" );

  return ( OM_S_SUCCESS );

}
/* oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo */

method ACset_NV_rep( unsigned char rep;struct GRmd_env *md_env)
{
  IGRlong		msg, status;
  IGRint		i,j;
  IGRchar		macro_lib[100];
  IGRint		NbChildren, NbFoot;
  struct  VRdbEquipPart	Part;
  struct  ACrg_coll	Collection[4],
			Attr;
  struct  GRid		SysParamId, ModelId;
  struct  GRid		*ChildId, *SaveId=NULL;
  GRclassid		ClassId;

/*** KDD May-97.  
* To deal with legacy data, if DB table name not found in my system collection,
* by default go to PID_EQUIP_LIST_TBL.
****/
  char			TableName[41]={ PID_EQUIP_LIST_TBL },
			MacroName[41]={""};

  
  extern GRclassid		OPP_VRPNozz_class_id;
  extern GRclassid		OPP_VRHNozz_class_id;

SetProc(ACset_NV_rep); Begin

  ModelId.objid = NULL_OBJID;
  ModelId.osnum = md_env->md_id.osnum;

        /*| Get Equipment System Collection */
  status = om$send( msg      = message VRGeneric.VRGetParams(
                                        &msg, &SysParamId, NULL, NULL),
                    targetid = my_id);

  strcpy ( Attr.name, VR_N_TABLE_NAME_DB );
  status = om$send( msg      = message ACrg_collect.ACget_named_attribute(
                                                        &msg, &Attr ),
                    senderid = NULL_OBJID,
                    targetid = SysParamId.objid,
                    targetos = SysParamId.osnum );
  if ( status&1 ) 
     if ( Attr.desc.type == AC_ATTRIB_TEXT ) 
        strcpy( TableName, Attr.desc.value.att_txt);
     
  status = VRdbGetEqOccur( &msg, TableName, me->EquipNo, MacroName, NULL, NULL);
  as$status(); 


  if(  bVR_IS_PID(me->xform_chan) && !bVR_IS_PID(rep))
  {
	/*| from PID to 3D representation */

	status = VRdbGetEqOccur( &msg, TableName, me->EquipNo,NULL, &Part,NULL);
	as$status( action = RET_VALUE, value = OM_E_ABORT); 

	VDSget_eqp_library ( Part.Familly, macro_lib );

        status =
	ac$construct_path( mode    = AC_ADD_PATH | AC_INQ,
			   name    = macro_lib);

	strcpy( Collection[0].name, VR_N_MACRO_NAME_AN);
	Collection[0].desc.type = AC_ATTRIB_TEXT;
	strcpy( Collection[0].desc.value.att_txt, MacroName);

	strcpy( Collection[1].name,"eqp_family" );
	Collection[1].desc.type = AC_ATTRIB_TEXT;
	strcpy( Collection[1].desc.value.att_txt, Part.Familly);

	strcpy( Collection[2].name, "eqp_partno");
	Collection[2].desc.type = AC_ATTRIB_TEXT;
	strcpy( Collection[2].desc.value.att_txt, Part.PartNb);

	strcpy( Collection[3].name, "eqp_partrev");
	Collection[3].desc.type = AC_ATTRIB_TEXT;
	strcpy( Collection[3].desc.value.att_txt, Part.PartRev);

	status =
  	VR$ModifyCollection(p_msg 		 = &msg,
			    Operation 		 = VR_MERGE_COLL,
			    p_ParamsListToModify = Collection,
			    NbParamsToModify 	 = 4,
			    p_OutputCollectionId = &SysParamId );

	/*| get all needed attributes */
	status = 
	om$send ( msg = message VRGeneric.VRGetModel( &msg, &ModelId, md_env ),
		  targetid = my_id);

	/*| Update Dynamic collection */
	status = 
  	om$send ( msg 	    = message VREquipment.VRUpdateDynAttr( &msg, 
							   	   md_env),
	    	  targetid = my_id);
  	as$status();
  }

  if(  bVR_IS_PID(rep) && !bVR_IS_PID(me->xform_chan) )
  {
        IGRint                  Index=-1;
        struct ret_struct       AttrSt;

	/*| from 3D to PID representation */

	strcpy( Collection[0].name, VR_N_MACRO_NAME_AN);
	Collection[0].desc.type = AC_ATTRIB_TEXT;
	strcpy( Collection[0].desc.value.att_txt, MacroName);

        status=
        om$send ( msg = message ACncpx.ACgive_structure
                            ((IGRint *) &msg, &Index, VR_N_PID_SCALE_DB,
                                        &AttrSt, md_env),
             targetid = my_id);

        if ( ! ( status&(msg)&1 ) )
        {
           msg = MSSUCC;
           AttrSt.var.root_pm_st.value=1;
        }

	strcpy( Collection[1].name, VR_N_PID_SCALE_DB);
	Collection[1].desc.type = AC_ATTRIB_DOUBLE;
	Collection[1].desc.value.att_exp = AttrSt.var.root_pm_st.value;

  	status =
  	VR$ModifyCollection(	p_msg 			= &msg,
				Operation 		= VR_MERGE_COLL,
				p_ParamsListToModify 	= Collection,
				NbParamsToModify 	= 2,
				p_OutputCollectionId 	= &SysParamId );
	as$status();
  }

  /*| --- Get all children connected to equipment */
  status =
  om$send( msg      = message NDnode.NDget_objects(	ND_CHILDREN | ND_IN_BUF,
							NULL,
							0,
							&ChildId,
							0,
							OM_K_MAXINT,
							&NbChildren ),
	   targetid = my_id);
  as$status( action = RET_STATUS );

  /*"NbChildren = %d \n",NbChildren*/


  if( NbChildren )
    SaveId = _MALLOC( NbChildren ,  struct GRid ); 

  for ( i=0; i<NbChildren; i++ )
  {
	SaveId[i].objid = ChildId[i].objid;
	SaveId[i].osnum = ChildId[i].osnum;
  }

  /*| -- Loop on children -- */
  for ( i=0; i<NbChildren; i++ )
  {
	/*| ----- Get equipment foot classid ----- */
	status =
	om$get_classid(	objid		= SaveId[i].objid,
			osnum		= SaveId[i].osnum,
			p_classid	= &ClassId);

	if ( ClassId == OPP_ACpretend_class_id )
	{
		
		/*| ----- Get ACpretend childs ----- */
		status =
  		om$send( msg      = message NDnode.NDget_objects (
						ND_CHILDREN | ND_IN_BUF,
						NULL,
						0,
						&ChildId,
						0,
						OM_K_MAXINT,
						&NbFoot ),
	  		targetid = SaveId[i].objid,
			targetos = SaveId[i].osnum);
  		as$status( action = RET_STATUS );

		for( j=0; j<NbFoot; j++ )
		{
			/*| ----- Get ACpretend child classid ----- */
			status =
			om$get_classid(	objid		= ChildId[j].objid,
					osnum		= ChildId[j].osnum,
					p_classid	= &ClassId);

			if (	ClassId == OPP_VRPNozz_class_id ||
				ClassId == OPP_VRHNozz_class_id )
			{
				/*| Set State Disconnect */
				status = 
  				om$send( msg	  = message VRNozzle.VRSetSoftConnection
								( &msg),
					 targetid = ChildId[j].objid,
					 targetos = ChildId[j].osnum);
				as$status();
			}
		}
	}

  }/* end loop on feet */

  _FREE (SaveId);

  /*| Send ACset_NV_rep wrt message */
  status = 
  om$send ( msg		= message ACncpx.ACset_NV_rep( rep, md_env),
	    targetid	= my_id,
	    mode 	= OM_e_wrt_message);
  as$status();
 
End;
return (OM_S_SUCCESS);
}/* end of ACset_NV_rep */


/******************************************************************************/
method GRgetattr( IGRlong       *msg;
                  IGRchar       *attr)
{
  struct VREquipment_common *equipment;
 
SetProc( VREquipOver.GRgetattr );Begin
 
  *msg = OM_S_SUCCESS;
 
  equipment = (struct VREquipment_common *) attr;
 
  switch ( equipment->Iwant ) {
 
  case VREquipment_EquipNo :
 
        strcpy( equipment->EquipNo , me->EquipNo );
        break;
  }
 
End

return (OM_S_SUCCESS);
}


/******************************************************************************/
method GRputattr( IGRlong       *msg;
                  IGRchar       *attr)
{
  struct VREquipment_common *equipment;
 
SetProc( VREquipOver.GRputattr );Begin
 
  *msg = OM_S_SUCCESS;
 
  equipment = (struct VREquipment_common *) attr;
 
  switch ( equipment->Iwant ) {
 
    case VREquipment_EquipNo :

    	om$vla_set_dimension( varray = me->EquipNo,
                              size   = strlen( equipment->EquipNo) +1);
 
	strcpy( me->EquipNo, equipment->EquipNo ); 

        break;
  }
 
End;
return (OM_S_SUCCESS);
}

/******************************************************************************/
/* Overwritten to free memory allocated for VREquipment Instance data */
/******************************************************************************/

method GRdelete(  IGRlong       	*msg;
                  struct GRmd_env       *md_env)
{
IGRlong		status, retcode;

SetProc( VREquipOver.GRdelete );Begin

  om$vla_set_dimension( varray = me->EquipNo,
                        size   = 1);

  me->EquipNo[0] = 0;

  status = om$send ( msg      = message VRGeneric.GRdelete( &retcode, md_env),
	             mode     = OM_e_wrt_message,
                     targetid = my_id); 
  as$status();

*msg = retcode;
End;
return (OM_S_SUCCESS);
}


/******************************************************************************/
method VRSetInstance  (IGRlong      *msg;
                struct VRGenInfo    *Instance)
{

  IGRlong status;

SetProc( VREquipOver.GRputattr );Begin
 
  *msg = OM_S_SUCCESS;


	/* Set Instance data of VREquipment class */
  om$vla_set_dimension( varray = me->EquipNo,
                        size   = strlen( Instance->Attr.Equip.EquipNumber) +1);

  strcpy( me->EquipNo, Instance->Attr.Equip.EquipNumber );


	/* Call Parent Class VRSetInstance method */ 
  status = om$send ( msg      = message VRGeneric.VRSetInstance (msg, Instance),
                     mode     = OM_e_wrt_message,
                     targetid = my_id );


*msg = *msg & status;
End;
return (OM_S_SUCCESS);

}


end implementation VREquipment;
