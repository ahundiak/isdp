/* $Id: VRRNinfo.I,v 1.3 2001/02/20 01:16:51 build Exp $  */

/***************************************************************************
 * I/ROUTE
 *
 * File:	vrprdcmp/VRRNinfo.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRRNinfo.I,v $
 *	Revision 1.3  2001/02/20 01:16:51  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/16 17:43:17  anand
 *	SP merge (removed #ifdef PLOAD262 - #endif)
 *	
 *	Revision 1.1.1.1  2001/01/04 21:13:05  cvs
 *	Initial import to CVS
 *
 *
# Revision 1.1  2000/07/10  19:09:08  pinnacle
# Created: route/vrprdcmp/VRRNinfo.I by apazhani for Service Pack
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.3  1995/12/17  18:09:10  pinnacle
# Replaced: ./vrprdcmp/VRRNinfo.I for:  by azuurhou for route240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	12/17/95	adz		VDObjDef structure error.
 *	07/10/00	Alwin		Implemented the VRGetSearch and 
 *					VRGetSpecComp for Raceway Nozzle, but
 *					would be available only for PLOAD
 *					02.06.02.00 CR179901003
 *
 ***************************************************************************/

class implementation VRRNozz;

#include "VRparamdef.h"
#include "VRattr_def.h"
#include "VRDbParamDef.h"
#include "VRDbStruct.h"
#include "VRmsg.h"
#include "vrdbgmacros.h"
#include "vrpdu_pto.h"

/***********************************************************************/

method VRGetDefName ( IGRlong	*msg; IGRchar *sMacroName )

{

  *msg = MSSUCC;

  strcpy ( sMacroName, "RWcndef" );

  return ( OM_S_SUCCESS );

}/* end method VRGetDefName */

/***********************************************************************/

method VDgetObjDef( long *msg; VDobjDef *myDef )
{
  long	sts;

  myDef->info	= VR_I_ObjRwayNozz ;
  myDef->type	= 0 ;

  sts		= OM_S_SUCCESS ;
  *msg		= MSSUCC ;

  return sts ;
}
/***********************************************************************/

method VRGetSearch ( 	IGRlong *msg;
                        struct GRid *PbId;
			IGRint ListSize;
			IGRint *NbParams;
			struct VRSelectAttr *ParamList;
			IGRchar *szSearch;
			struct GRmd_env *md_env)
{
    IGRint		intmsg, status;
    IGRint		FootIndex=-1;
    IGRshort		nShape;
    IGRlong		retmsg;
    IGRchar		tmp[20];
    struct ret_struct	AttrRst;

    SetProc( Md VRGetSearch ); Begin 

    if ( !szSearch )
    {
	/*| ERROR : Null pointer given as argument */
	*msg = MSFAIL;
	End
	return ( OM_E_INVARG );
    }

    *msg = MSSUCC;

    strcpy (szSearch, VR_RWAY_DIR);
    strcat (szSearch, ":");

    // Get the Vendor Name
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                           ( &intmsg, &FootIndex, VR_N_CLASS_AN,
                              &AttrRst, md_env ),
         targetid = my_id);

    if( intmsg & 1) 
      strcat( szSearch, AttrRst.var.text_st.text_string );

    __DBGpr_str( " Vendor Name ", AttrRst.var.text_st.text_string );

    // Get the Shape Code
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                              ( &intmsg, &FootIndex, VR_N_SHAPE_IN,
                                 &AttrRst, md_env ),
         targetid = my_id);

    tmp[0] = '\0';
    if( intmsg & 1 ) 
    {
      nShape = (IGRshort)AttrRst.var.root_pm_st.value;
      sprintf( tmp, "-%d", nShape );
      strcat( szSearch, tmp );
      tmp[0] = '\0';
    }

    // Get the Width
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_WIDTH1_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if( intmsg & 1 ) 
    {
      sprintf( tmp, "-%.3lf", AttrRst.var.root_pm_st.value );
      strcat( szSearch, tmp );
      tmp[0] = '\0';
    }

    // Get the Depth
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_DEPTH1_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if( intmsg & 1 ) 
    {
      sprintf( tmp, "-%.3lf", AttrRst.var.root_pm_st.value );
      strcat( szSearch, tmp );
      tmp[0] = '\0';
    }

    End
    return ( OM_S_SUCCESS );
}/* end VRGetSearch */
/***********************************************************************/

method VRGetSpecComp ( 	IGRlong *msg;
			IGRint NbParams ;
			struct VRSelectAttr *ParamList;
			struct GRid *PbId;
			struct GRmd_env *md_env )
{
    IGRint		status, intmsg, FootIndex=-1;
    IGRshort		nShape;
    IGRlong		retmsg;
    IGRchar		szVendorName[9];
    IGRdouble		dWidth, dDepth;
    struct ret_struct	AttrRst;

    SetProc( Md VRGetSpecComp ); Begin 

    *msg = MSSUCC;

    // Get the Vendor Name
    szVendorName[0] = '\0';
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                           ( &intmsg, &FootIndex, VR_N_CLASS_AN,
                              &AttrRst, md_env ),
         targetid = my_id);

    if( intmsg & 1)
      strcpy( szVendorName, AttrRst.var.text_st.text_string );

    __DBGpr_str( " Vendor Name ", szVendorName );

    // Get the Shape Code
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                              ( &intmsg, &FootIndex, VR_N_SHAPE_IN,
                                 &AttrRst, md_env ),
         targetid = my_id);

    if( intmsg & 1 )
      nShape = (IGRshort)AttrRst.var.root_pm_st.value;

    __DBGpr_int( " Shape Code ", nShape );

    // Get the Width
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_WIDTH1_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if( intmsg & 1 )
      dWidth = AttrRst.var.root_pm_st.value;

    __DBGpr_dbl( " Width Value ", dWidth );

    // Get the Depth
    status =
    om$send ( msg = message ACncpx.ACgive_structure
                            ( &intmsg, &FootIndex, VR_N_DEPTH1_DB,
                               &AttrRst, md_env ),
         targetid = my_id);

    if( intmsg & 1 )
      dDepth = AttrRst.var.root_pm_st.value;

    __DBGpr_dbl( " Depth Value ", dDepth );

    PbId->osnum = md_env->md_id.osnum;

    // Construct/fetch the Model : after confirming with Database
    status = VRaccess_rway_noz_db( &retmsg, szVendorName, nShape,
				dWidth, dDepth, PbId );

    if( ! status & retmsg & 1 )
    {
       __DBGpr_com( " Failed accessing rway_nozzle table " );
       *msg = MSFAIL;
    }

    __DBGpr_obj( " Model Id ", *PbId );

    End
    return ( OM_S_SUCCESS );
}/* end VRGetSpecComp */
/***********************************************************************/

end implementation VRRNozz;
