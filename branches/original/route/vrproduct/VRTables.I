/* $Id: VRTables.I,v 1.1.1.1 2001/01/04 21:13:06 cvs Exp $  */
/*************************************************************************
 * I/ROUTE
 *
 * File:        vrproduct/VRTables.I
 *
 * Description:
 * 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRTables.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *      Initial import to CVS
 *
# Revision 1.3  2000/01/25  18:54:32  pinnacle
# Replaced: vrproduct/VRTables.I for:  by lawaddel for route
#
# Revision 1.2  1999/10/22  15:53:26  pinnacle
# Replaced: vrproduct/VRTables.I for:  by lawaddel for route
#
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.5  1998/01/14  18:56:12  pinnacle
# Replaced: vrproduct/VRTables.I for:  by lawaddel for route
#
 *
 * History:
 *      01/08/98        law     CR179309874 Add new raceway shapes
 *      10/22/99        law     TR179900780 Cleanup raceway transitions
 *      01/25/00        law     tr179900976 - transition failures
 *
 *************************************************************************/

class implementation VRProduct;

/*
--------------------------------------------------------------------------
*
* external function for Product
*
---------------------------------------------------------------------------
*/

#include "VRcompdef.h"

#define AS_DEBUG 	1
#define	OFFSET_MAC_NAME 30

/* ========================================================================= */

IGRint VRcint_piping ( msg, item_num, AABBCCcode )

	IGRlong		*msg;
	IGRshort	item_num;
	IGRchar		*AABBCCcode;

/*.VRcint_piping */
{
 *msg = MSSUCC;

 switch ( item_num )
 {
	case VR_PIPE :strcpy ( AABBCCcode, "PIPING");
		break;

	case 2 :strcpy ( AABBCCcode, "TUBING");
		break;

	case 3 :strcpy ( AABBCCcode, "HOSE");
		break;

	case VR_REDUCER :/* concentric diameter change */
		strcpy ( AABBCCcode, "CONRED");
		break;

	case VR_FLGE_BEND :/* flange in bends */
		strcpy ( AABBCCcode, "FLANGE");
		break;

	case VR_FLGE_COMP :/* flange in other component */
		strcpy ( AABBCCcode, "FLANGE");
		break;

	case VR_TRUE_Y :/* TRUE Y */
		strcpy ( AABBCCcode, "WYE");
		break;

        case VR_EQ_CROSS :/* equal size cross */
		strcpy ( AABBCCcode, "CROSS");
		break;

	default : return ( OM_E_ABORT );
 }


	return ( OM_S_SUCCESS );

}


/*========================= H.V.A.C ========================= */

IGRint VRcint_hvac ( msg, item_num, AABBCCcode )

	IGRlong		*msg;
	IGRshort	item_num;
	IGRchar		*AABBCCcode;

/*.VRcint_hvac */
{

 *msg = MSSUCC;

 switch ( item_num )
  {
	case VR_PIPE :
		strcpy ( AABBCCcode, "DUCT");
		break;

	case VR_REDUCER :
		strcpy ( AABBCCcode, "CONRED");
		break;

	case VR_FLGE_COMP :
		strcpy ( AABBCCcode, "FLANGE");
		break;

	case VR_TWIST_R_TR :
		strcpy ( AABBCCcode, "TWIST");
		break;

	case VR_TRANS_R_O :
		strcpy ( AABBCCcode, "ROTRAN");
		break;

	case VR_TRANS_R_C :
		strcpy ( AABBCCcode, "RCTRAN");
		break;

	case VR_TRANS_O_C : /* For Avondale Db - OCTRAN was correct */
		strcpy ( AABBCCcode, "COTRAN"); /* tr179900976 */
		break;

	case VR_TRANS_R_Co :
		strcpy ( AABBCCcode, "RDTRAN");
		break;

	case VR_TRANS_O_Co :
		strcpy ( AABBCCcode, "ODTRAN");
		break;

	case VR_TRANS_C_Co :
		strcpy ( AABBCCcode, "CDTRAN");
		break;

	default : return ( OM_E_ABORT );
  }


 return ( OM_S_SUCCESS );

}

/*========================= RWAY ========================= */

IGRint VRcint_rway ( msg, item_num, AABBCCcode )

        IGRlong         *msg;
        IGRshort        item_num;
        IGRchar         *AABBCCcode;

/*.VRcint_hvac */
{

 *msg = MSSUCC;

 switch ( item_num )
  {
        case VR_PIPE :
                strcpy ( AABBCCcode, "TRAY");
                break;

        case VR_REDUCER :
                strcpy ( AABBCCcode, "CONRED");
                break;

        case VR_FLGE_COMP :
                strcpy ( AABBCCcode, "FLANGE");
                break;

        case VR_TWIST_R_TR :
                strcpy ( AABBCCcode, "TWIST");
                break;

        case VR_TRANS_R_O :
                strcpy ( AABBCCcode, "ROTRAN");
                break;

        case VR_TRANS_R_C :
                strcpy ( AABBCCcode, "RCTRAN");
                break;

        case VR_TRANS_E_C :
                strcpy ( AABBCCcode, "CETRAN");
                break;

        case VR_TRANS_R_E :
                strcpy ( AABBCCcode, "RETRAN");
                break;

        case VR_TRANS_O_C : /* For Avondale Db- OCTRAN was correct */
                strcpy ( AABBCCcode, "COTRAN"); /* tr179900976 */
                break;

        case VR_TRANS_O_E :
                strcpy ( AABBCCcode, "OETRAN");
                break;

        case VR_TRANS_R_Co :
                strcpy ( AABBCCcode, "RDTRAN");
                break;

        case VR_TRANS_O_Co : /*** transitions - tr179900976 ***/
                strcpy ( AABBCCcode, "ODTRAN");
                break;


        case VR_TRANS_E_Co :
                strcpy ( AABBCCcode, "EDTRAN");
                break;

        case VR_TRANS_C_Co :
                strcpy ( AABBCCcode, "CDTRAN");
                break;

        default : return ( OM_E_ABORT );
  }


 return ( OM_S_SUCCESS );

}

end implementation VRProduct;
