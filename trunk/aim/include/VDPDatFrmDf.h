/* I/VDS
 *
 * File:        vdpinclude/VDPDatFormDf.h
 *
 * Description:  Default data selection form
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *       9/95            MSM             Creation
 *      08/13/98         SSR             Added constants for form Gadet nos for SIR 
 *      08/20/98         SSR             Changed form  ( made on Clix )
 *      Nov25 98	SSR		New form, gadget for CR # 179801371
 *      Aug27/99	SSR		New gadgets for prefix based query.
 */


#ifndef VDPDatFormDf_include
#define VDPDatFormDf_include

#ifndef igrtypedef_include
#include <igrtypedef.h>
#endif

#ifndef VDPdef_include
#include "VDPdef.h"
#endif

/* Field definitions for Required PME Data Form */

#define VD_FP		me^^CEO.forms[0].form_ptr

#define G_EDIT_GROUP_LBL	33
#define G_REV_GROUP_LBL		41

#define	G_CTX_MSG		10
#define G_BWTCTX_E		14
#define	G_CTX_TYPE_E		15
#define G_BWTCTX_DESC		16
#define	G_CTX_SUBTYPE_E		17
#define	G_CTX_NAME_E		18
#define	G_CTX_DESC		19
#define G_ESWBS_E		28
#define G_ESWBS_DESC_E		30
#define G_SHIPNAME_E		44
#define G_SHIP_DESC_E		48

#define G_ESWBS_R		36
#define G_BWTCTX_R		37
#define	G_CTX_TYPE_R		38
#define	G_CTX_SUBTYPE_R		39
#define	G_CTX_NAME_R		40
#define G_ESWBS_DESC_R		42
#define	G_SHIPNAME_R		45

#define VDPREQ_DATA_FORM	"VDPreqPMdat"

/* Gadget label definitions for SHow enabled Items form */

#define VDPSHOW_ENAB_ITMS_FORM	"VDPshEnab"

#define	G_FIT_ITEM_CHK		12
#define	G_ITEMLIST		18
#define	G_HILITE_OPTION		19

#define G_ITEMLIST_STATUS	14
#define G_ITEMLIST_ERROR	16
#define G_ITEMLIST_SUCCESS	20
#define G_TOG_ERROR		21
#define G_TOG_SUCC		22
/* Definitions for form VDPEqPreload */

#define VDPEQP_PRELOAD_FORM	"VDPEqPreload"

#define  G_EQUIPMENT            32
#define  G_PLACEMENT_CTX        15

/* gadgets for SIR form   */

#define	G_SEL_GRP		30
#define	G_VEW_GRP		31

/*  #define G_SEL_CFG_ITM       26   
 #define G_SEL_HULL		27 */  
/*  #define G_SEL_CTX		29 */  
#define G_SEL_CTX_TYP		28


/* #define G_VEW_CFG_ITM	13   
   #define G_VEW_CFG_DESC	15   
  #define G_VEW_HULL_NAM	17   
  #define G_VEW_HULL_DESC	19    */

 /* #define G_VEW_CTX		23  */
/* #define G_VEW_CTX_DESC		25  */
 #define G_VEW_CTX_TYP		21 
#define G_TG_FILE_TYP		33 // CR # 179801371
#define G_TIT_SYS	        26 	
#define G_TIT_ZONE		18
#define G_TIT_UNIT              19
#define G_BTN_QRY_CTX           37
#define G_FLD_PREFX		27

#define G_TEXT_CONTEXTS         22
#define G_TEXT_HSC              25
#define G_TEXT_ZONE             29
#define G_TEXT_ZONESYS          43
#define G_TEXT_UNIT             34
#define G_TEXT_REV              35
#define G_TEXT_CONTDESC         24 
#define G_TEXT_CONTAPP          36
#define G_FLD_CONTAPP           42
#define G_FLD_MULTICOL          23



/* added Pullabhotla 05/06/2000 */

#define G_SERV_NAME	        13
#define G_AIM_ENVI		15
#define G_HULL_APP		17

/* TLS 01/23/02 - AMDC Enhancements */
#define G_TG_ASSEM_FILE	        45

#endif
