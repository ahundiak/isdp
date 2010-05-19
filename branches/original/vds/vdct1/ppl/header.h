/* $Id: header.h,v 1.2 2001/01/12 14:47:06 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/header.h
 *
 * Description: Collector Tree Object
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: header.h,v $
 *      Revision 1.2  2001/01/12 14:47:06  art
 *      sp merge
 *
 * Revision 1.2  2000/05/15  15:13:00  pinnacle
 * Replaced: vds/vdct1/ppl/header.h for:  by pnoel for Service Pack
 *
 * Revision 1.1  2000/04/20  18:49:02  pinnacle
 * Created: vds/vdct1/ppl/header.h by pnoel for Service Pack
 *
 * Revision 1.7  2000/03/30  18:41:10  pinnacle
 * pn.
 *
 * Revision 1.5  2000/03/24  20:35:06  pinnacle
 * ah
 *
 * Revision 1.4  2000/03/13  15:43:10  pinnacle
 * ah
 *
 * Revision 1.0  2000/03/10  16:10:30  pinnacle
 * pn
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/10/00  pn      Provide Global Variables for PPL/.I file communication of data
 ***************************************************************************/

/* ------------------------------------------------
 * Trick to allow sharing global header information 
 */
#include "VDppl.h"
#include "VDobj.h"
#include "VDsa.h"
#include "VDct1.h"
#include "time.h"
#include "VDct1Post.h"

TGRid             MGR_ID;
TGRid             SET_ID;

TVDctSetName      SET_NAME;
TVDctSetType      SET_TYPE;
TVDctSetTypeRev   SET_TYPE_REV;

TVDctSetTypeInfo  SET_TYPE_INFO;

IGRint            NODE_INDEX;
IGRint            NODE_CNT;
IGRint            ATTR_OFFSET;
IGRstat           ACTION_OK;
IGRchar           LOCATION[128];
IGRchar           TABLE_NAME[128];

TVDctBaseInfo     BASE_INFO;
TVDctBaseInfo     BASE_INFO_PARENT;
TVDctNodeName     NODE_NAME;
TVDctNodeType     NODE_TYPE;
TVDctNodeTypeInfo NODE_TYPE_INFO;

TGRid   NODE_ID;
TGRid   NODE_PARENT_ID;

IGRchar NODE_PATH[128];
IGRchar NODE_MSG [128];
IGRchar OP[16];

OM_S_CLASSLIST    CLASS_LIST;

IGRint  LIST_IND;
IGRchar LIST_TEXT[64];

TGRobj_env PIECE_OE;

TVDfld  FLD;
TVDatFld FLDS[VDAT_FLD_MAX];


IGRint RET_FLAG;

extern isdigit();



