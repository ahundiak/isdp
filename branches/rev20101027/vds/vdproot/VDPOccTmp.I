/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vdproot/imp/VDPOccTmp.I
 *
 * Description:
 *      Implementation of the following methods for VDPOccTmpl :
 *
 * Dependencies:
 *
 * History:
 *
 *      11/03/95        MSM        Creation
 *
 */

class implementation VDPRoot;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include <stdio.h>
#include "string.h"

#include "OMmacros.h"
#include "OMprimitives.h"
#include "exproto.h"
#include "exdef.h"
#include "exmacros.h"

#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "v_datamacros.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "ACcheckin.h"
#include "VDScheckdef.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "VDPdef.h"

#define PME_GLOBAL_DIR          ":IGENOD:PMEGlobal"

#define PME_EQP_TMPL		":pmEquip"
#define PME_PIP_TMPL		":pmPiping"
#define PME_HVC_TMPL		":pmHVAC"
#define PME_RWY_TMPL		":pmRway"
#define PME_SBM_TMPL		":pmBeam"
#define PME_SPL_TMPL		":pmPlate"
#define PME_CMP_TMPL		":pmCompart"

from ACrg_collect import ACset_list_attribute, AClist_attribute;

/*
   Abstract

   VDPSetTemplateData()

   This function sets the template data of the PME instantiable occurrence
   classes in the VDS design file.

   msg		long *		Output
				MSSUCC or MSFAIL

   Function returns OM_S_SUCCESS if successful else other OM_E_ errors.

*/

IGRint VDPSetTemplateData( IGRlong *msg)
{
    IGRlong		status = OM_S_SUCCESS;
    struct GRid         CollId;
    OMuword             curOs;
    IGRchar             DirName[DI_PATH_MAX];
    IGRchar             CollName[DI_PATH_MAX];
    struct ACrg_coll	*Coll=NULL;
    IGRint		nbAttr;

    SetProc( VDPSetTemplateData ); Begin

    /*  Query the DM2 server for the template information for each of	*
     *  the different Occurrence types.					*
     */
    *msg = MSSUCC;

    ex$get_cur_mod( osnum = &curOs );

    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
				pathname        = DirName );
    CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );

    /*  For each of the Occurrence types, Create an RGcollector and 	*
     *  store in the NOD.						*
     */

     /*  EQUIPMENT */

    status = VDPgetOccTemplate1( msg, "PmEquip", &nbAttr, &Coll ); 

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_EQP_TMPL );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /* store in collector */
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
                                        msg,
                                        nbAttr,
                                        Coll ) );
    CheckRC( status, *msg );

    /* PIPING */

    status = VDPgetOccTemplate1( msg, "PmPiping", &nbAttr, &Coll ); 

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_PIP_TMPL );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /* store in collector */

    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
                                        msg,
                                        nbAttr,
                                        Coll ) );
    CheckRC( status, *msg );

    /* HVAC */

    status = VDPgetOccTemplate1( msg, "PmHVAC", &nbAttr, &Coll ); 

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_HVC_TMPL );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /* store in collector */

    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
                                        msg,
                                        nbAttr,
                                        Coll ) );
    CheckRC( status, *msg );

    /* RWAY */

    status = VDPgetOccTemplate1( msg, "PmRway", &nbAttr, &Coll ); 

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_RWY_TMPL );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /* store in collector */

    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
                                        msg,
                                        nbAttr,
                                        Coll ) );
    CheckRC( status, *msg );

    /* STRUCT BEAM */

    status = VDPgetOccTemplate1( msg, "PmBeam", &nbAttr, &Coll ); 

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_SBM_TMPL );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /* store in collector */

    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
                                        msg,
                                        nbAttr,
                                        Coll ) );
    CheckRC( status, *msg );

    /* STRUCT PLATE */

    status = VDPgetOccTemplate1( msg, "PmPlate", &nbAttr, &Coll ); 

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_SPL_TMPL );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /* COMPARTMENT */

    status = VDPgetOccTemplate( msg, VDP_COMPART, &nbAttr, &Coll ); 

    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_CMP_TMPL );
    __DBGpr_str( "Collector name", CollName );

    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, TRUE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /* store in collector */

    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.ACset_list_attribute(
                                        msg,
                                        nbAttr,
                                        Coll ) );
    CheckRC( status, *msg );

wrapup:
    _FREE( Coll );
    End
    return OM_S_SUCCESS;
}

/* 

  Abstract
  
  VDPgetTemplateData

  This function returns a collector filled with the attribute names of the 
  occurrence template.

  msg		long *			Output
  TempType	int			Input	* Possible values PIPING_OBJ
								  HVAC_OBJ ...
  nbAttr	int *			Output	* number of attributes in
						  the collector *
  Coll		struct ACrg_coll **	Output  * Collector with attributes *

*/

IGRint VDPgetTemplateData ( 	IGRlong *msg,
				IGRint TempType, 
				IGRint *nbAttr,
				struct ACrg_coll    **Coll )
{
    IGRlong		status = OM_S_SUCCESS;
    struct GRid         CollId;
    OMuword             curOs;
    IGRchar             DirName[DI_PATH_MAX];
    IGRchar             CollName[DI_PATH_MAX];

    SetProc( VDPgetTemplateData ); Begin
    *msg = MSSUCC;

    *nbAttr = 0;
    *Coll = NULL;

    ex$get_cur_mod( osnum = &curOs );

    /* get directory path name */
    status = di$give_pathname(  osnum           = curOs,
				pathname        = DirName );
    CheckRC( status, 1 );
    __DBGpr_str( "Path name", DirName );
    switch ( TempType )
    {
	case PIPING_OBJ:
    	    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_PIP_TMPL );
    	    __DBGpr_str( "Collector name", CollName );
	    break;

	case HVAC_OBJ:
    	    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_HVC_TMPL );
    	    __DBGpr_str( "Collector name", CollName );
	    break;

	case RWAY_OBJ:
    	    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_RWY_TMPL );
    	    __DBGpr_str( "Collector name", CollName );
	    break;

	case EQUIPMENT_OBJ:
    	    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_EQP_TMPL );
    	    __DBGpr_str( "Collector name", CollName );
	    break;

	case STRUCT_BEAM_OBJ:
    	    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_SBM_TMPL );
    	    __DBGpr_str( "Collector name", CollName );
	    break;

	case STRUCT_PLATE_OBJ:
    	    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_SPL_TMPL );
    	    __DBGpr_str( "Collector name", CollName );
	    break;

	case COMPARTMENT_OBJ:
    	    sprintf( CollName,"%s%s%s", DirName, PME_GLOBAL_DIR, PME_CMP_TMPL );
    	    __DBGpr_str( "Collector name", CollName );
    }
    CollId.objid = NULL_OBJID;

    status = VDgetVdCollId( msg, CollName, TRUE, FALSE, &CollId );
    __DBGpr_obj ( "Coll Id", CollId );

    /*  get the RGcollector */
    status =
    _VD_SEND_OBJN( CollId, ACrg_collect.AClist_attribute(
						msg,
						0,
						NULL,
						nbAttr ) );
    CheckRC( status, *msg );

    if( *nbAttr )
        *Coll = _MALLOC ( *nbAttr, struct ACrg_coll );

    if( *Coll )
    {
	status =
	_VD_SEND_OBJN( CollId, ACrg_collect.AClist_attribute(
							msg,
							*nbAttr,
							*Coll,
							nbAttr ) );
	__CheckRC( status, *msg, "AClist_attribute", wrapup );
    }

wrapup:
    End
    return OM_S_SUCCESS;
}

/*

IGRint	VDPgetOccTemplate( IGRlong *msg, IGRint code, IGRint *nbAttr, struct ACrg_coll **Coll )
{
    SetProc ( VDPgetOccTemplate ); Begin

    *msg = MSSUCC;
    *nbAttr = 3;

    *Coll = _MALLOC( *nbAttr, struct ACrg_coll );

    strcpy((*Coll)[0].name, "descript" );
    (*Coll)[0].desc.type = AC_ATTRIB_TEXT;
    (*Coll)[0].desc.value.att_txt[0] = '\0';

    strcpy((*Coll)[1].name, "cog_x" );
    (*Coll)[1].desc.type = AC_ATTRIB_DOUBLE;
    (*Coll)[1].desc.value.att_exp = 0;

    strcpy((*Coll)[2].name, "tag_number" );
    (*Coll)[2].desc.type = AC_ATTRIB_TEXT;
    (*Coll)[2].desc.value.att_txt[0] = '\0';

    End
    return OM_S_SUCCESS;

}

*/

end implementation VDPRoot;
