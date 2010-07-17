/* $Id: VRNozzOver.I,v 1.3 2002/02/13 23:29:12 louis Exp $  */
 
/*************************************************************************
 * I/ROUTE
 *
 * File:        vrnozzle/VRNozzOver.I
 *
 * Description:
 *      Contains method related to Nozzle Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRNozzOver.I,v $
 *      Revision 1.3  2002/02/13 23:29:12  louis
 *      TR5889-Corrected nozzle status being Unknown
 *
 *      Revision 1.2  2001/02/20 01:14:29  build
 *      Replaced v_dbgmacros.h with product specific dbgmacros.h
 *
 *      Revision 1.1.1.1  2001/01/04 21:13:00  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/03/12  23:02:34  pinnacle
# Replaced: vrnozzle/VRNozzOver.I for:  by lawaddel for route
#
# Revision 1.4  1998/03/11  20:07:26  pinnacle
# Replaced: vrnozzle/VRNozzOver.I for:  by azuurhou for route
#
# Revision 1.3  1998/01/13  09:30:36  pinnacle
# Replaced: vrnozzle/VRNozzOver.I for:  by apazhani for route
#
# Revision 1.2  1998/01/13  09:08:16  pinnacle
# Replaced: vrnozzle/VRNozzOver.I for:  by apazhani for route
#
 *
 * History:
 *
 * MM/DD/YY		AUTHOR		DESCRIPTION
 * 01/13/98		Alwin		Added case for Tag Number for 179702486
 * 02/12/98             law             Enhanced shape-code fetch for 179800544
 * 02/13/02		Ad Zuurhout	TR5889-Status bar was labeling nozzles
 *					as Unknown because give_structure was
 *					returning an error.
 *
 *************************************************************************/


/*
     CLASS  NAME: VRNozzle
     METHOD NAMES: 

***********************************************************************/

class implementation VRNozzle;

#include <string.h>
#include <math.h>
#include "acrepdef.h"
#include "VRparamdef.h"
#include "nddef.h"
#include "VRPid.h"
#include "VRdef.h"
#include "VDDbtbldef.h"
#include "asbox.h"
#include "VRutilmacros.h"
#include "VRutildef.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "parametric.h"
#include "vrdbgmacros.h"

#define AS_DEBUG	1

extern  GRclassid       OPP_ACpretend_class_id;
extern 	GRclassid	OPP_VRNozHold_class_id;
extern 	GRclassid	OPP_VRPiping_class_id;
extern 	GRclassid	OPP_VRHvac_class_id;

from 	VRNozHold	import	VRSetInstance;
from    ACrg_collect    import  ACget_named_attribute;


/***********************************************************************/
method NDcopy(IGRlong *msg;IGRint cp_type;
 		 struct GRmd_env *fr_env,*to_env;struct GRid *newobjid)

{
	IGRint		status,Product;
	GRclassid	MyClassId;

*msg=MSSUCC;

if ( cp_type == ND_TO_MACRO )
{
	struct GRsymbology	symb;

	/*| Copy to macro definition */

	/* -- construct VRNozHold -- */
	newobjid->osnum = to_env->md_id.osnum;
	status = om$construct( 	classid = OPP_VRNozHold_class_id,
	           		p_objid = &newobjid->objid,
	           		osnum   = newobjid->osnum );
	as$status( action = RET_STATUS );

	/* -- Set symbology -- */

	/* get my symbology */
	status = 
	om$send (msg = message GRvg.GRgetsymb
			(msg,&symb),
		targetid = my_id );
	as$status ( action = RET_STATUS );

	/* set it to the VRNozHold */
	status = 
	om$send (msg = message GRvg.GRputsymb
			(msg,&symb),
		mode = OM_e_wrt_message,
		targetid = newobjid->objid,
		targetos = newobjid->osnum );
	as$status ( action = RET_STATUS );

	/* -- Set instance -- */

	/* Get product number from class */
	om$get_classid (objid = my_id,
			osnum = OM_Gw_current_OS,
			p_classid = &MyClassId );

	if ( om$is_ancestry_valid
			( subclassid   = MyClassId,
			  superclassid = OPP_VRPiping_class_id )
	     == OM_S_SUCCESS )
	{
		/*| -- PIPING object -- */
		Product = VR_PIPING;
	}
	else
	if ( om$is_ancestry_valid
			( subclassid   = MyClassId,
			  superclassid = OPP_VRHvac_class_id )
	     == OM_S_SUCCESS )
	{
		/*| -- HVAC object -- */
		Product = VR_HVAC;
	}
	else	Product = VR_CABLING;

	status = 
	om$send (msg = message VRNozHold.VRSetInstance
			(msg, Product, me->szNumber, me->szNotes, me->dSecAngle),
		targetid = newobjid->objid,
		targetos = newobjid->osnum );
	as$status ( action = RET_STATUS );

}/* end copy to macro definition */
else
{
	/*| Generic copy */

	status = 
	om$send (msg = message VRGeneric.NDcopy
			(msg,cp_type,fr_env,to_env,newobjid),
		mode = OM_e_wrt_message,
		targetid = my_id );
	as$status ( action = RET_STATUS );


}/* end generic copy */

/*" Copy Id :<%d,%d>\n",newobjid->objid,newobjid->osnum*/

return ( OM_S_SUCCESS );

}/* end NDcopy */

/***********************************************************************/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{

        IGRchar                 string[50],txt[9];
        IGRint                  status;
        IGRlong                 retmsg;
        IGRint                  FootIndex=-1;
	GRclassid		MyClassId;
        struct ret_struct       AttrRst;

        *msg = MSSUCC;

	string[0] = '\0';

	status =
        om$send ( msg = message VRGeneric.ACgive_structure
                        ( (IGRint *) &retmsg, &FootIndex, VR_N_TAG_NUMBER_AN, &AttrRst, NULL ),
                 targetid = my_id);
//      as$status ( action = RET_STATUS ); **** TR5889 ***

	if ( (retmsg&1&status) && (AttrRst.var.text_st.text_string[0] != '\0') )
        {
                strcat(string, AttrRst.var.text_st.text_string );
                strcat(string,"-");
        }

	status =
        om$send ( msg = message VRGeneric.ACgive_structure
                        ( (IGRint *) &retmsg, &FootIndex, VR_N_SERVICE_AN, &AttrRst, NULL ),
                targetid = my_id);
//      as$status ( action = RET_STATUS ); **** TR5889 ****
	if ( retmsg&1&status )
        {
		strcat (string, AttrRst.var.text_st.text_string );
                strcat(string,"-");
        }
          /****** Modified for TR5889- Status bar labeled nozzles Unknown ***/
	/* Get product number from class */
	om$get_classid (objid = my_id,
			osnum = OM_Gw_current_OS,
			p_classid = &MyClassId );

	if ( om$is_ancestry_valid
			( subclassid   = MyClassId,
			  superclassid = OPP_VRPiping_class_id )
	     == OM_S_SUCCESS )
	{
	  status =
          om$send ( msg = message VRGeneric.ACgive_structure
                        ( (IGRint *) &retmsg, &FootIndex, VR_N_GDIAMETER_DB, &AttrRst, NULL ),
                targetid = my_id);
          /****** Modified for TR5889- Status bar labeled nozzles Unknown ***/
//        as$status ( action = RET_STATUS );

	  if ( retmsg&1&status )
          {
		sprintf( txt, "%f", AttrRst.var.root_pm_st);
                strcat (string, txt );
          }
        }
        else{
	  status =
          om$send ( msg = message VRGeneric.ACgive_structure
                        ( (IGRint *) &retmsg, &FootIndex, VR_N_WIDTH1_DB, &AttrRst, NULL ),
                targetid = my_id);
//        as$status ( action = RET_STATUS );

	  if ( retmsg&1&status )
          {
		sprintf( txt, "%.2f-", AttrRst.var.root_pm_st);
                strcat (string, txt );
	  }
	  status =
          om$send ( msg = message VRGeneric.ACgive_structure
                        ( (IGRint *) &retmsg, &FootIndex, VR_N_DEPTH1_DB, &AttrRst, NULL ),
                targetid = my_id);
//        as$status ( action = RET_STATUS );

	  if ( retmsg&1&status )
          {
		sprintf( txt, "%.2f", AttrRst.var.root_pm_st);
                strcat (string, txt );
	  }
        }

	string[31] = '\0';

        strcpy ( info->type,string );
	return OM_S_SUCCESS;	

}/* end GRgetobjinfo */

/***********************************************************************/

method ACgive_structure(int *msg; int *direct_index; char *footname;
                        struct ret_struct *p_rs;
			struct GRmd_env *md_env)

{
	IGRint			status=OM_S_SUCCESS;
	IGRint			BSmkvec();
	IGRdouble		BSlenvec();

SetProc( Md ACgive_structure ); Begin 

*msg=MSSUCC;

__DBGpr_str( " Footname", footname ); 

if ( !(strcmp (footname, VR_N_AABBCC_AN)) )
{
	p_rs->type= text_type;
	sprintf (p_rs->var.text_st.text_string, "%s",
		me->szAABBCC);
}

else if ( !(strcmp (footname, VR_N_OPTION_IN)) )
{
	p_rs->type= double_type;
	p_rs->var.root_pm_st.value =  me->nOption;
}   

else
if ((!strcmp ( footname, VD_N_EQP_ID_IN ))         ||
    (!strcmp ( footname, VD_N_EQP_NUMBER_AN )))
{
         int      count;
  struct GRid     Loc_Id;
  struct GRid     Eqp_Id;
  GRclassid       Prtid;

  Loc_Id.objid = NULL_OBJID;
  Loc_Id.osnum = OM_Gw_current_OS;
  Eqp_Id.objid = NULL_OBJID;
  Eqp_Id.osnum = OM_Gw_current_OS;

  /*    get the pretend father  */
  status =
  om$get_objid_at_index ( object          = me,
                          p_chanselect    = &ND_father,
                          index           = (IGRint) me->nNbAttr,
                          objidaddr       = &Loc_Id.objid,
                          osnumaddr       = &Loc_Id.osnum);
  as$status( action = RET_STATUS );


  /*A    get the equipment    */

  om$get_classid (objid     = Loc_Id.objid,
                  osnum     = Loc_Id.osnum,
                  p_classid = &Prtid );

  if (Prtid == OPP_ACpretend_class_id)
  {  /*  if the parent is a pretend    */
    status = om$send(msg = message NDnode.NDget_objects
                               (ND_ROOT, &Eqp_Id, 1, NULL,0, 0, &count),
                targetid = Loc_Id.objid,
                targetos = Loc_Id.osnum);
    as$status( action = RET_STATUS );
  }
  else
  {  /*  or if it is the direct parent   */
    Eqp_Id.objid = Loc_Id.objid;
    Eqp_Id.osnum = Loc_Id.osnum;
  }

  if (!strcmp ( footname, VD_N_EQP_ID_IN ))
  {
        p_rs->type = double_type;
        p_rs->var.root_pm_st.value = Eqp_Id.objid;
  }
  else
  {
        status =
        om$send( msg = message ACncpx.ACgive_structure
                      (msg, direct_index, footname, p_rs, md_env),
              targetid = Eqp_Id.objid,
              targetos = Eqp_Id.osnum);
        as$status( action = RET_STATUS );
  }
}

/*KLUDGE : added for DCN benchmark	*/
/* In pre-2.5 software, the shape code was not set in HVAC nozzles   */
/* The code below uses the macro name to verify the shapecode        */
/* If the shape code is incorrect, the collection is corrected       */
/* The correct value of shapecode is returned                        */
/* If the macro name is  not rnozz,cnozz, or onozz no change is made */
/* If a new macro is created, either the "r,c, or o" protocol must be*/
/* followed OR use another first letter for the macro name.          */

else if ( !(strcmp (footname, VR_N_SHAPE_IN)) )
{
	IGRint			FootIndex = -1;
	IGRdouble		mValue ;
        IGRlong                 retmsg;
        struct GRid             SysParamId;
	struct ret_struct	ParamAttr, tmpAttr;
/*START KLUDGE*/
        /* added by alwin */
        /* From the Nozzle's Id, get the System Params Id, so that we can get 
           the SHAPE CODE. In case if SHAPE CODE is not defined in the 
           SystemParameters; then it will follow the old procedure of getting 
           the SHAPE CODE, i.e using macro name of nozzle being plaed */
        status = om$send ( msg = message VRGeneric.VRGetParams( &retmsg, 
                                 &SysParamId, NULL, NULL ),
                           targetid = my_id );
        status =
        om$send( msg = message ACncpx.ACgive_structure
                      (msg, &FootIndex, "macro_name", &tmpAttr, md_env),
              targetid = my_id );
        as$status( );
	if( !strncmp(tmpAttr.var.text_st.text_string, "r" , 1 ) )
		mValue =  (double)0;	/*RECT*/
	else if( !strncmp(tmpAttr.var.text_st.text_string, "o" , 1 ) )
		mValue =  (double)1;	/*OVAL*/
	else if( !strncmp(tmpAttr.var.text_st.text_string, "c" , 1 ) )
		mValue =  (double)2;	/*CIRCULAR*/
	else    mValue =  (double)3;    /*UNDEFINED*/

	/*
	 * corner radius shape not needed yet
	 */
        status =
        om$send( msg = message ACncpx.ACgive_structure
                 ((IGRint *)&retmsg, &FootIndex, footname, &tmpAttr, md_env),
                            senderid = my_id,
                            targetid = SysParamId.objid,
                            targetos = SysParamId.osnum );
        as$status( );

        /* status = %x and retmsg = %x \n", status, retmsg */

        /* If macro name is not recognized, keep the existing shapecode */
        if (mValue > 2.0) mValue = tmpAttr.var.root_pm_st.value;

        if( status & 1 & retmsg )
        {
           /*  NEW WAY of getting SHAPE CODE \n" */
           p_rs->type = AC_ATTRIB_DOUBLE;
           p_rs->var.root_pm_st.value = mValue;
           *msg = retmsg;
        }
        /* added by alwin */
        else {
           /* OLD WAY of getting SHAPE CODE \n" */
	   p_rs->type= double_type;
	   p_rs->var.root_pm_st.value =  mValue ;
        }

	/*
	 * Update the SHAPE CODE attribute for the component when needed.
	 */
        /* if the nozzle is in the curr_os_num */
        if(SysParamId.osnum == OM_Gw_current_OS)
        {
            struct ACrg_coll newcollect;
            /* Check if the shape code in the nozzle is OK */
            if(fabs(p_rs->var.root_pm_st.value - 
                                  tmpAttr.var.root_pm_st.value) > 0.0)
            {
               /* Shape code is incorrect so fix the return packet */
                strcpy(newcollect.name, VR_N_SHAPE_IN);
                status =
                om$send( msg = message ACrg_collect.ACget_named_attribute
                                               ( &retmsg, &newcollect ),
                        senderid = NULL_OBJID,
                        targetid = SysParamId.objid,
                        targetos = SysParamId.osnum );
                as$status( action = RET_STATUS );

                newcollect.desc.value.att_exp = mValue;
                /* Reset the nozzle shapecode collection */
                status = VR$ModifyCollection
                            ( p_msg                = &retmsg,
                              Operation            = VR_MERGE_COLL,
                              p_ParamsListToModify = &newcollect,
                              NbParamsToModify     = 1,
                              p_OutputCollectionId = &SysParamId);
            }
        }

/*corner radius shape - NOT YET NEEDED */	
/*END KLUDGE*/

}   
/* Get the Tag Number from the Collector, which will fetch you the correct 
information istead of the Instance Data. Alwin for TR179702486 & 87 */
else if( !strcmp( footname, VR_N_TAG_NUMBER_AN) )
{
        IGRint                  FootIndex = -1;
        IGRlong                 retmsg;
        struct GRid             SysParamId;
 
        status = om$send ( msg = message VRGeneric.VRGetParams( &retmsg,
                                 &SysParamId, NULL, NULL ),
                           targetid = my_id );
 
        __DBGpr_obj( " Nozzle's System Params Id ", SysParamId );
        status =
        om$send( msg = message ACncpx.ACgive_structure
                                        ((IGRint *)&retmsg, &FootIndex,
                                        footname, p_rs, md_env),
                            senderid = my_id,
                            targetid = SysParamId.objid,
                            targetos = SysParamId.osnum );
        as$status( );
        __DBGpr_str( " Tag Number ", p_rs->var.text_st.text_string );
}
else
{
	/*| Try OM_e_wrt_message */
	status=
	om$send (msg = message VRGeneric.ACgive_structure 
				(msg, direct_index, footname, p_rs, md_env),
			mode = OM_e_wrt_message,
			targetid = my_id);
	/*" status = %d, msg = %d\n", status, *msg */

} /* end try OM_e_wrt_message */

End
return ( status );

}/* end method ACgive_structure */


/******************************************************************************/

method GRdelete( IGRlong *msg; struct GRmd_env *md_env )
{
	IGRlong	status=OM_S_SUCCESS;

	if( me->Status & VR_OUT_MACRO )
	{
		/*| I am out of macro */
		status = om$send( msg      = message ASnode.GRdelete
								( msg, md_env ),
				  mode     = OM_e_wrt_message,
				  targetid = my_id );
		as$status();
	}

	return OM_S_SUCCESS;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*              override     method GRxform                            
/*
/*  DESCRIPTION: A component is allowed to move if is not attached to any topology.
/*
/*	Bruno : override implemented the 19 of July 1993 in order to make nozzles
/*		behave like any other components.
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


method GRxform(IGRlong *msg; struct GRmd_env *md_env;
	IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid )
{
	struct GRid	RefId;

	*newobjid = my_id;

	RefId.objid = NULL_OBJID;

	om$send ( msg = message VRNozzle.VRGetRefId
			( msg, &RefId ),
		targetid = my_id);

	if ( RefId.objid == NULL_OBJID )
	{
		return
		om$send ( msg = message VRGeneric.GRxform
				( msg, md_env, matrix_type, matrix, newobjid ),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	}
	else return OM_S_SUCCESS;


}/* end GRxform */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/*              override     method ACconstruct_feet                          
/*
/*  DESCRIPTION: A component is allowed to move if is not attached to any topology.
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method ACconstruct_feet( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *fcount; struct GRid  *feet_list)
{
	IGRuchar 		rep;
	IGRlong			status=OM_S_SUCCESS;
	struct		GRid	RefId, MacroId;

	if( ! ( me->Status & VR_OUT_MACRO ) )
	{
		status = om$send( msg      = message VRNozzle.VRGetRefId( msg, &RefId ),
				  targetid = my_id );
		as$status( action = RET_STATUS );

		/*"RefId = %d %d\n", RefId.objid,  RefId.osnum */ 

		status = om$send( msg      = message NDnode.NDget_objects
						( ND_ROOT, &MacroId, 1, NULL, 0,
					  	  OM_K_MAXINT, &count ),
				  targetid = RefId.objid,
				  targetos = RefId.osnum );
		as$status( action = RET_STATUS );

		/*"MacroId = %d %d\n", MacroId.objid,  MacroId.osnum */ 

    		status = om$send( msg      = message ACncpx.ACget_NV_rep(&rep),
                      		  targetid = MacroId.objid, 
                      		  targetos = MacroId.osnum );
    		as$status( action = RET_STATUS );

		if( rep )
		{
	  		status = om$send( msg      = message ACncpx.ACset_NV_rep( rep, md_env ),
			    		  targetid = my_id );
  			as$status( action = RET_STATUS );
		}
	}

	status = om$send( mode     = OM_e_wrt_message,
			  msg      = message VRGeneric.ACconstruct_feet
					( msg, cn_type, count, list, md_env,
			   		  fcount, feet_list ),
			  targetid = my_id );
	as$status( action = RET_STATUS );

	return OM_S_SUCCESS;
}

end implementation VRNozzle;
