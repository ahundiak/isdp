/* $Id: VREquipInfo.I,v 1.2 2001/01/12 16:54:33 anand Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrequip / VREquipInfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VREquipInfo.I,v $
 *	Revision 1.2  2001/01/12 16:54:33  anand
 *	SP merge
 *	
# Revision 1.1  2000/08/05  14:51:34  pinnacle
# Created: route/vrequip/VREquipInfo.I by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1997/09/08  00:20:56  pinnacle
# Replaced: vrequip/VREquipInfo.I for:  by kddinov for route
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.2  1997/02/14  22:06:54  pinnacle
# Replaced: vrequip/VREquipInfo.I for:  by hverstee for route
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1996/04/04  15:45:56  pinnacle
# Replaced: vrequip/VREquipInfo.I for:  by hverstee for route240
#
# Revision 1.2  1996/01/16  23:47:00  pinnacle
# Replaced: vrequip/VREquipInfo.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb		Add prototypes
 *
 *************************************************************************/

class implementation VREquipment;

#include <math.h>

#include "OMprimitives.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "bserr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "VRcompdef.h"
#include "bserr.h"
#include "VRparamdef.h"
#include "VRattr_def.h"
#include "VRstructs.h"
#include "VRDbParamDef.h"
#include "VRutildef.h"
#include "VRutilmacros.h"
#include "VDSutil.h"
#include "VDmem.h"

#include "vrtools_pto.h"

#define AS_DEBUG	1
#define VRMAXCRIT      10

from	ACrg_collect	import	ACrem_attribute;
from	ACrg_collect	import	ACadd_list_attribute;

/***********************************************************************/

method VRGetSearch ( 	IGRlong *msg;
			struct GRid *PbId;
			IGRint ListSize;
			IGRint *NbParams;
			struct VRSelectAttr *ParamList;
			IGRchar *szSearch;
			struct GRmd_env *md_env)

{
	IGRint			retmsg, status, FootIndex=-1;
	struct ret_struct	AttrRst;


if ( !szSearch )
{
	/*| ERROR : Null pointer given as argument */
	*msg = MSFAIL;
	return ( OM_E_INVARG );
}

  *msg = MSSUCC;

  strcpy (szSearch, VR_EQUIP_DIR);
  strcat (szSearch, ":");

  /* -- build selection name -- */

  /* Family */
  status = 
  om$send ( msg = message ACncpx.ACgive_structure
			 ( 	&retmsg, &FootIndex, "eqp_family",
				&AttrRst, md_env ),
	    targetid = my_id);
  as$status ( action = RET_STATUS );

  if ( retmsg&1 )
  {
	strcat ( szSearch, AttrRst.var.text_st.text_string );
	strcat ( szSearch, "-");
  }

  /* Partno */
  status = 
  om$send ( msg = message ACncpx.ACgive_structure
			( &retmsg, &FootIndex, "eqp_partno",
			  &AttrRst, md_env ),
	    targetid = my_id);
  as$status ( action = RET_STATUS );

  if ( retmsg&1 )
  {
	strcat ( szSearch, AttrRst.var.text_st.text_string );
	strcat ( szSearch, "-");
  }

  /* Part rev */
  status = 
  om$send ( msg = message ACncpx.ACgive_structure
			( &retmsg, &FootIndex, "eqp_partrev",
			  &AttrRst, md_env ),
	    targetid = my_id);
  as$status ( action = RET_STATUS );

  if (retmsg&1)	strcat ( szSearch, AttrRst.var.text_st.text_string );

  /*" Search string = %s\n",szSearch*/

  return ( OM_S_SUCCESS );

}/* end VRGetSearch */

/***********************************************************************/

method VRGetRefId ( IGRlong *msg; struct GRid *RefId )

{
  IGRint		status;
  OM_S_CHANSELECT	father;

  if (me->nNbTopo < me->nNbCpts) 	*msg = MSSUCC;
  else					*msg = MSFAIL;

  father.type = OM_e_name;
  father.u_sel.name = "father";

  /* -- The referential is just after the attributes templates -- */
  status =
  om$get_objid_at_index (	object		= me,
				p_chanselect	= &father,
				index 		= (IGRint) me->nNbAttr,
				objidaddr	= &RefId->objid,
				osnumaddr	= &RefId->osnum);

  /*" Coordinate System : <%d,%d>\n",RefId->objid,RefId->osnum */

return ( status );

}
/***********************************************************************/
method VRGetSysType ( IGRlong *msg; IGRshort *nSysType )
{
*msg = MSSUCC;

	*nSysType = VR_EQUIPMENT;

return ( OM_S_SUCCESS );

}/* end VRGetSysType */

/***********************************************************************/

method VRGetInstance ( IGRlong	*msg; struct VRGenInfo *Instance )

{
	IGRint	length;
	IGRint	status;

	*msg = MSSUCC;

	/* -- Get super class instance -- */
	status =
	om$send ( msg = message VRGeneric.VRGetInstance
			(msg, Instance),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	as$status ();

	length = strlen( me->EquipNo);

/* ---------------------------------------------------------------------
      This code makes no sense, I assume the caller wants a pointer to
      the equipment number.......

	Instance->Attr.Equip.EquipNumber = ( IGRchar * )malloc (length +1);

	strcpy( Instance->Attr.Equip.EquipNumber, me->EquipNo);

    	free (Instance->Attr.Equip.EquipNumber);
   ---------------------------------------------------------------------- */

        Instance->Attr.Equip.EquipNumber = me->EquipNo;

	return ( OM_S_SUCCESS );

}/* end VRGetInstance */

/****************************************************************************/
method VRGetMatrix ( 	IGRlong *msg; IGRint NbTemp; struct GRid *TempList;
			IGRdouble *dRefMatrix;  struct GRmd_env *md_env)

{
	IGRlong			retmsg;
        IGRint          	i, status;
	struct	GRid		RefId;
	struct	ret_struct	RefInfo;

*msg = MSSUCC;

  if( me->nNbTopo )
  {
	/* -- Get Referencial  -- */
	status =
        om$send( msg      = message VREquipment.VRGetRefId( &retmsg, &RefId ),
                 targetid = my_id );
	as$status();

	/*"Coordinate System : <%d,%d>\n",RefId.objid,RefId.osnum */

	status=
	om$send( msg	  = message NDnode.NDgive_structure(&retmsg,&RefInfo,md_env),
		 targetid = RefId.objid,
		 targetos = RefId.osnum);
	as$status();

	for( i=0; i<16; i++ )
		dRefMatrix[i] = RefInfo.var.ref_st.t[i];

  }
  else
  {
	status =
        om$send( msg      = message VRGeneric.VRGetMatrix( &retmsg,
							   NbTemp,
							   TempList, 
							   dRefMatrix,
							   md_env ),
                 targetid = my_id,
		 mode 	  = OM_e_wrt_message);
  }

  return OM_S_SUCCESS;

}/* end VRGetMatrix */



/***********************************************************************/

method VRGetSpecComp ( 	IGRlong *msg;
			IGRint NbParams ;
			struct VRSelectAttr *ParamList;
			struct GRid *PbId;
			struct GRmd_env *md_env )

{
  IGRint		retmsg;
  IGRint		status;
  IGRint		NbDyn, NbStat, i;
  IGRchar		Family[21],PartNo [21], PartRev[21];
  IGRchar		szPathName[100];
  IGRint		FootIndex=-1;
  struct ret_struct	AttrRst;
  struct VDSatt_family	*StatAttr, *DynAttr;
  struct ACrg_coll	StatColl[VR_MAX_ATTR], DynColl[VR_MAX_ATTR];
  struct GRid		UserParamId;

  *msg = MSSUCC;

  /* -- Initialize search parameters -- */

  /* Family  */
  status = 
  om$send ( msg = message ACncpx.ACgive_structure( &retmsg, &FootIndex, 
						   "eqp_family",&AttrRst,
						   md_env ),
	    targetid = my_id);
  as$status ( action = RET_STATUS );

  if ( retmsg&1 )
  strcpy( Family, AttrRst.var.text_st.text_string );
  /*"Family = <%s> \n",Family*/

  /* Part Number */
  status = 
  om$send ( msg = message ACncpx.ACgive_structure( &retmsg, &FootIndex,
						   "eqp_partno", &AttrRst,
						   md_env ),
	    targetid = my_id);
  as$status ( action = RET_STATUS );

  if ( retmsg&1 )
  strcpy ( PartNo, AttrRst.var.text_st.text_string );
  /*"PartNo = <%s> \n",PartNo*/

  /* Part Rev */
  status = 
  om$send ( msg = message ACncpx.ACgive_structure( &retmsg, &FootIndex,
						   "eqp_partrev", &AttrRst,
						   md_env ),
	    targetid = my_id);
  as$status ( action = RET_STATUS );

  if ( retmsg&1 )
  strcpy ( PartRev, AttrRst.var.text_st.text_string );
  /*"PartRev = <%s> \n",PartRev*/

  status = VDSget_attr( Family, PartNo, PartRev, "EQUIP",
			&NbStat, &StatAttr, &NbDyn, &DynAttr);

  /*"NbStat = %d \n",NbStat */
  /*"NbDyn  = %d \n",NbDyn */
	
  if ( !( status & 1 ))
  {
	/*| ERROR -> SPEC ACCESS FAILED */
	*msg=MSFAIL;
	return ( status );
  }

  /*| --- Put dynamic attributes in user coll --- */
  for( i=0; i<NbStat; i++ )	StatColl[i]	= StatAttr[i].attr;
  for( i=0; i<NbDyn; i++ )	DynColl[i]	= DynAttr[i].attr;

  /*| free memory */
  if( StatAttr ) om$dealloc( ptr= StatAttr);
  if( DynAttr  ) om$dealloc( ptr= DynAttr);

  PbId->objid = NULL_OBJID;
  PbId->osnum = md_env->md_id.osnum;

  UserParamId.objid =  NULL_OBJID;
  UserParamId.osnum =  md_env->md_id.osnum;

  status =
  VR$ModifyCollection(	p_msg			= msg,
			Operation		= VR_MERGE_COLL,
			p_ParamsListToModify	= StatColl,
			NbParamsToModify	= NbStat,
			p_OutputCollectionId	= PbId );
  status =
  VR$ModifyCollection(	p_msg			= msg,
			Operation		= VR_MERGE_COLL,
			p_ParamsListToModify	= DynColl,
			NbParamsToModify	= NbDyn,
			p_OutputCollectionId	= &UserParamId);


  di$give_pathname ( osnum = OM_Gw_current_OS, pathname = szPathName );
  strcat ( szPathName, ":" );
  strcat ( szPathName, VR_EQUIP_DIR);
  strcat ( szPathName, ":");
  strcat ( szPathName, Family );
  strcat ( szPathName, "-");
  strcat ( szPathName, PartNo );
  strcat ( szPathName, "-");
  strcat ( szPathName, PartRev );
  strcat ( szPathName, "-");
  strcat ( szPathName, "dyn");

  status=
  om$send(msg      = message ACncpx.GRputname( msg, szPathName),
	  targetid = UserParamId.objid,
	  targetos = UserParamId.osnum );
  as$status ();

  return ( OM_S_SUCCESS );

}/* end VRGetSpecComp */

/***********************************************************************/

method VRUpdateDynAttr ( IGRlong *msg; struct GRmd_env *md_env )

{
  IGRint	status;
  IGRboolean 	bResult=FALSE;
  IGRchar	szSearch[30], szPathName[100];
  struct GRid	CacheId, UserParamId;

  *msg = MSSUCC;
 

  /*| get the quipment dyn collection */
  status =
  om$send( msg = message VRGeneric.VRGetParams(	msg, NULL, &UserParamId, NULL ),
	   targetid = my_id);
  as$status ( );	
  /*"UserParamId = %d %d \n",UserParamId.objid, UserParamId.osnum*/

  /*| Get the directory name of the cache */
  di$give_pathname ( osnum = OM_Gw_current_OS, pathname = szPathName );

  status =
  om$send( msg = message VRProduct.VRGetSearch(	msg, NULL, 0, NULL, NULL, 
						szSearch, md_env ),
	   targetid = my_id);
  as$status ( );	
	
  strcat ( szPathName, ":" );
  strcat ( szPathName, szSearch );
  strcat ( szPathName, "-" );
  strcat ( szPathName, "dyn" );

  CacheId.objid = NULL_OBJID;
  CacheId.osnum = md_env->md_id.osnum;

  status = di$translate(	objname = szPathName,
		  		p_objid = &CacheId.objid,
		  		p_osnum = &CacheId.osnum );
 
  /*"CacheId = %d %d \n",CacheId.objid, CacheId.osnum*/

  if( CacheId.objid == NULL_OBJID )
  {
	*msg = MSFAIL;
	return status;
  }
  else
  {
	/*| Test if component dyn coll is equal to cache one */
	status = VRTestColl( msg, &CacheId, &UserParamId, &bResult );
	
	if( !bResult )
	{
		/*| Update Component coll by cache one */

		/* delete additionnal parameters */
		status =
  		VR$ModifyCollection(	p_msg			= msg,
					Operation		= VR_INTER_COLL,
					p_InputCollectionId	= &CacheId,
					p_OutputCollectionId	= &UserParamId );
		as$status();

		/* add new parameters */
		status =
  		VR$ModifyCollection(	p_msg			= msg,
					Operation		= VR_UNION_COLL,
					p_InputCollectionId	= &CacheId,
					p_OutputCollectionId	= &UserParamId );
		as$status();
	}

	/*| Remove eqp_number parameter as it is treated as an instance */
	status =
	om$send( msg      = message ACrg_collect.ACrem_attribute
                                      ( msg, "eqp_number" ),
		 senderid = NULL_OBJID,
		 targetid = UserParamId.objid,
		 targetos = UserParamId.osnum );
	as$status();
  }

  return ( OM_S_SUCCESS );

}/* end VRUpdateDynAttr */

/**************************************************************************/

IGRint  VREQ_set_att (IGRchar   *fam,
                      IGRchar   *part,
                      IGRchar   *rev,
              struct  GRid      *sbox,
              struct  GRid      *dbox)

{
  IGRlong                 sts, msg;
  IGRint                  nb_stat;
  IGRint                  nb_dyn;
  IGRint                  i;

  struct  VDSatt_family   *stat_attr;
  struct  VDSatt_family   *dyn_attr;

  nb_stat   = 0;
  nb_dyn    = 0;
  stat_attr = NULL;
  dyn_attr  = NULL;

  sts = VDSget_attr( fam, part, rev, "EQUIP", &nb_stat, &stat_attr,
                      &nb_dyn, &dyn_attr);

  if (!(sts & OM_S_SUCCESS)) goto wrapup;

  if ( sbox ) { 
     for( i=0; i<nb_stat; i++ ) {
        sts =
        om$send (msg = message ACrg_collect.ACadd_list_attribute
                                                ( &msg, 1, &stat_attr[i].attr ),
            senderid = NULL_OBJID,
            targetid = sbox->objid,
            targetos = sbox->osnum );
        as$status( sts = sts );
     }
  }

  if ( dbox ) { 
     for( i=0; i<nb_dyn; i++ ) {
        sts =
        om$send (msg = message ACrg_collect.ACadd_list_attribute
                                                ( &msg, 1, &dyn_attr[i].attr ),
            senderid = NULL_OBJID,
            targetid = dbox->objid,
            targetos = dbox->osnum );
        as$status( sts = sts );
     }
  }

wrapup:

  if ( stat_attr) _FREE( stat_attr );
  if ( dyn_attr ) _FREE( dyn_attr );
  return  sts;
}

/*******************************************************************************
* KDD July 97. 
*
*  Get the System and User Attributes, predefined for that piece of equipment. 
*  We allocate memory, the caller must free it. 
*******************************************************************************/
IGRint  VREQ_set_att_list (	IGRchar   	*fam,
                      		IGRchar   	*part,
                      		IGRchar   	*rev,
              		struct  ACrg_coll       **SysAttr,
              		struct  ACrg_coll       **UsrAttr, 
				IGRint		*NumSysAttr,
				IGRint		*NumUsrAttr)

{
  IGRlong                 sts;
  IGRint                  nb_stat=0;
  IGRint                  nb_dyn=0;
  IGRint                  i;

  struct  VDSatt_family   *stat_attr;
  struct  VDSatt_family   *dyn_attr;

  nb_stat   = 0;
  nb_dyn    = 0;
  stat_attr = NULL;
  dyn_attr  = NULL;

  sts = VDSget_attr( fam, part, rev, "EQUIP", &nb_stat, &stat_attr,
                      &nb_dyn, &dyn_attr);

  if (!(sts & OM_S_SUCCESS)) goto wrapup;

/*----------------------
*  Does the caller want System attributes?
*-----------------------*/
  if ( SysAttr && nb_stat ) { 
  	(*SysAttr) = _MALLOC( nb_stat , struct ACrg_coll ) ; 

  	for( i=0; i<nb_stat; i++ ) {
		(*SysAttr) [ i ] = stat_attr[i].attr;
 	 }
  }
  if ( NumSysAttr ) *NumSysAttr = nb_stat;

/*----------------------
*  Does the caller want User attributes?
*-----------------------*/
  if ( UsrAttr && nb_dyn ) { 
  	(*UsrAttr) = _MALLOC( nb_dyn, struct ACrg_coll ) ; 

  	for( i=0; i<nb_dyn; i++ ) {
		(*UsrAttr) [ i ] =  dyn_attr[i].attr;
  	}
  }
  if ( NumUsrAttr ) *NumUsrAttr = nb_dyn;

wrapup:

  _FREE( stat_attr );
  _FREE( dyn_attr );
  return  sts;
}

end implementation VREquipment;
