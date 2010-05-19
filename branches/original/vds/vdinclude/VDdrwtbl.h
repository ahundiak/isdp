/* $Id: VDdrwtbl.h,v 1.2 2001/01/10 16:46:25 art Exp $  */

/* I/VDS
 *
 * File:        $VDS/vdinclude/VDdrwtbl.h
 *
 * Description:
 *      This include file provides constants used for table creation
 *	
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDdrwtbl.h,v $
 *	Revision 1.2  2001/01/10 16:46:25  art
 *	sp merge
 *	
 *
 * History:
 *
 *      04/14/95  	R. Manem 	Creation 
 *      06/19/95  	R. Manem 	Row flags : lineout, delete etc
 *      06/26/95  	R. Manem 	Data structures for summarization
 *					- generalized list info structure
 *      09/13/95  	R. Manem 	Added VD_ROW_USER_DEFINED to support
 *					removal of line outs.
 *      09/22/95  	R. Manem 	Added qty field in sort structures
 *      01/10/01        ah              sp merge
 */

#ifndef vd_VDdrwtbl_include
#       define vd_VDdrwtbl_include

/* type to construct */

#define VD_DRW_CNST_BOTH		0
#define VD_DRW_CNST_HDR			1
#define VD_DRW_CNST_TRLR		2

/* location of coordinate system, for placing table header */

#define	VD_DRW_CS_LOC_LEFT		1
#define	VD_DRW_CS_LOC_RIGHT		2

/* rowInfo bits */

#define VD_ROW_DELETE				0x0001
#define VD_ROW_LINEOUT				0x0002
#define VD_ROW_QTY_EXPRESSION		0x0004
#define VD_ROW_USER_DEFINED		0x0008

/* hdrInfo bits */

#define VD_HDR_DELETE				0x0001

/* used for type match */
#define	NULL_DBL                        -9999 
#define	MAX_BUF_CHARS1                  100 

/* for sort of table */
struct VDrowinfo{
        IGRint          	start_rindex;         
        IGRint          	nbsumobjs;           
	struct VDdrwlo_qtyExp	qty;
};

struct VDsortElementM
{
     struct GRobj_env     	obj;
     IGRchar              	*refStr;
     IGRchar              	compStr[MAX_BUF_CHARS1];
     IGRchar              	(*attrVal)[MAX_BUF_CHARS1];
     IGRint               	sum;
     struct VDdrwlo_qtyExp	qty;
     IGRint			rowNb;
};

/*
 * general structure giving the info for a list
 */
 
struct VDdrw_listInfo
{
    IGRint		startIndex;	/* starting index */
    IGRint		count;		/* no of elements */
};

#endif /* vd_VDdrwtbl_include */
