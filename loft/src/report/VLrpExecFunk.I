class implementation VLabstract;

/* ************************************************************************** */
/*	LOFT reporting in ASCII file exec functions used with Strudel	      */
/*	Marc Fournier (COC shipbuilding, Rungis)			      */
/*	07-JUN-1994	:	creation				      */
/*	15-MAY-2000	:	Steel Band for Avondale Shipyards.	      */
/* ************************************************************************** */

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"bsvalues.h"
#include	"grmacros.h"
#include	"cotxmacros.h"

#include        "vscmd.h"
#include        "vsdrwdef.h"
#include        "vsdrw.h"
#include        "vsdrwmacros.h"
#include        "vsdrwapi.h"

#include        "vlrptdef.h"
#include	"vlsdldef.h"
#include	"vlsdl.h"
#include	"vlsdlmacros.h"
#include	"vlalma.h"
#include	"vltemplate.h"
#include	"vlstifbend.h"
#include	"vlmiscmacros.h"
#include	"vlstrechval.h"
#include	"vlstructure.h"

#include	"vlforkmacros.h"
#include	"vlkline.h"

from	GRtext	import	GRgettxattr;

/*
#define	TRACE
*/

/* ************************************************************************** */
IGRint	VLvl_report_LoadKeyWords ()
{
	IGRchar		*K[VLSDL_MAX_IDX];
	VSdrwUsrTokType	U[VLSDL_MAX_IDX];
	VSdrwAction	A[VLSDL_MAX_IDX];
	IGRint		idx;
	IGRlong		sts;

DECLARE_ISOFTYPE ( VL, userBlock)
DECLARE_FUNCTION ( VL, getBidx)
DECLARE_FUNCTION ( VL, getBnam)
DECLARE_FUNCTION ( VL, getBxan)
DECLARE_FUNCTION ( VL, getByan)
DECLARE_FUNCTION ( VL, getBzan)
DECLARE_FUNCTION ( VL, getBnum)
DECLARE_FUNCTION ( VL, getBbalX)
DECLARE_FUNCTION ( VL, getBbalY)
DECLARE_FUNCTION ( VL, getBbalZ)
DECLARE_FUNCTION ( VL, getBshiX)
DECLARE_FUNCTION ( VL, getBshiY)
DECLARE_FUNCTION ( VL, getBshiZ)
DECLARE_ISOFTYPE ( VL, userBlock)
DECLARE_FUNCTION ( VL, getPnam)
DECLARE_FUNCTION ( VL, getPpin)
DECLARE_FUNCTION ( VL, getPcrn)
DECLARE_FUNCTION ( VL, getCnam)
DECLARE_FUNCTION ( VL, getCxpt)
DECLARE_FUNCTION ( VL, getCypt)
DECLARE_FUNCTION ( VL, getChei)
DECLARE_FUNCTION ( VL, getCpin)
DECLARE_FUNCTION ( VL, getJcol)
DECLARE_FUNCTION ( VL, getJlin)
DECLARE_FUNCTION ( VL, getJxpt)
DECLARE_FUNCTION ( VL, getJypt)
DECLARE_FUNCTION ( VL, getJzpt)
DECLARE_FUNCTION ( VL, getJhei)
DECLARE_FUNCTION ( VL, getJang)
DECLARE_FUNCTION ( VL, getJidx)
DECLARE_FUNCTION ( VL, getJnam)
DECLARE_FUNCTION ( VL, getTnam)
DECLARE_FUNCTION ( VL, getTcht)
DECLARE_FUNCTION ( VL, getTang)
DECLARE_FUNCTION ( VL, getThei)
DECLARE_FUNCTION ( VL, getTlea)
DECLARE_FUNCTION ( VL, getSnam)
DECLARE_FUNCTION ( VL, getSfra)
DECLARE_FUNCTION ( VL, getScht)
DECLARE_FUNCTION ( VL, getShei)
DECLARE_FUNCTION ( VL, setHstp)
DECLARE_FUNCTION ( VL, getHocc)
DECLARE_FUNCTION ( VL, getHsub)
DECLARE_FUNCTION ( VL, getHstp)
DECLARE_FUNCTION ( VL, getHhei)
DECLARE_FUNCTION ( VL, getU)
DECLARE_FUNCTION ( VL, getV)
DECLARE_FUNCTION ( VL, getStrVal)
DECLARE_FUNCTION ( VL, getChamf)
DECLARE_FUNCTION ( VL, getSBband)
DECLARE_FUNCTION ( VL, getSBunit)
DECLARE_FUNCTION ( VL, getSBdesc)
DECLARE_FUNCTION ( VL, getSBjobN)
DECLARE_FUNCTION ( VL, getSBnumP)
DECLARE_FUNCTION ( VL, getSBidx)
DECLARE_FUNCTION ( VL, getSBnam)
DECLARE_FUNCTION ( VL, getSBdst)
DECLARE_FUNCTION ( VL, getSBstk)
DECLARE_FUNCTION ( VL, getSBEndstk)
DECLARE_FUNCTION ( VL, getKLunit)
DECLARE_FUNCTION ( VL, getKLjobN)
DECLARE_FUNCTION ( VL, getKLpro)
DECLARE_FUNCTION ( VL, getKLlin)
DECLARE_FUNCTION ( VL, getKLnam)
DECLARE_FUNCTION ( VL, getKLdst)

	VLvl_LoadKeyWords();

        idx     = 0;    VLSDL_CHECK_IDX

	K[idx]			= VL_S_BAL_STA;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_BAL_RPT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_BAL_BAS;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_BAL_END;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_PIN_STA;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_PIN_TIT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_PIN_RPT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_CRN_TIT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_CRN_RPT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_PNL_TIT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_PNL_RPT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_PIN_END;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_CHT_TPL_STA;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_CHT_TPL_TIT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_CHT_TPL_RPT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_CHT_SPI_TIT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_CHT_SPI_RPT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_CHT_TPL_END;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_HEI_TPL_STA;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_HEI_TPL_TIT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_HEI_TPL_RPT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_HEI_TPL_END;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_HEI_BST_STA;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_HEI_BST_TIT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_HEI_BST_RPT;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_S_HEI_BST_END;
	U[idx]			= VSdrwTYPE;
	A[idx].elmQuery		= ISOFTYPE_ADDRESS ( VL, userBlock);
	idx++;			VLSDL_CHECK_IDX

        K[idx]                  = VL_STR_VAL_TIT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STR_VAL_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STR_VAL_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_TIT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_TIT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_T_H;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_T_R;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_L_H;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_L_R;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_D_H;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_D_R;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_IDX;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBidx);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_NAM;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBnam);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_XAN;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBxan);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_YAN;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getByan);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_ZAN;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBzan);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_NUM;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBnum);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_BBX;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBbalX);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_BBY;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBbalY);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_BBZ;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBbalZ);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_BSX;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBshiX);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_BSY;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBshiY);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_BAL_BSZ;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getBshiZ);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_OCC;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getPnam);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_PIN;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getPpin);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_CRN;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getPcrn);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CRN_NAM;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getCnam);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CRN_XPT;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getCxpt);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CRN_YPT;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getCypt);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CRN_HEI;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getChei);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CRN_PIN;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getCpin);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_COL;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJcol);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_LIN;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJlin);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_XPT;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJxpt);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_YPT;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJypt);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_ZPT;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJzpt);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_HEI;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJhei);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_ANG;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJang);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_IDX;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJidx);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_PIN_NAM;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getJnam);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_TPL_NAM;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getTnam);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_TPL_CHT;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getTcht);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_TPL_ANG;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getTang);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_TPL_HEI;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getThei);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_TPL_LEA;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getTlea);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_SPI_NAM;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getSnam);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_SPI_FRA;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getSfra);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_SPI_CHT;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getScht);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_CHT_SPI_HEI;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getShei);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_TPL_SET_STP;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, setHstp);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_TPL_GET_OCC;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getHocc);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_TPL_GET_SUB;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getHsub);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_TPL_GET_STP;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getHstp);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_TPL_GET_HEI;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getHhei);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_BST_SET_STP;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, setHstp);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_BST_GET_OCC;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getHocc);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_BST_GET_SUB;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getHsub);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_BST_GET_STP;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getHstp);
	idx++;			VLSDL_CHECK_IDX

	K[idx]			= VL_F_HEI_BST_GET_HEI;
	U[idx]			= VSdrwFUNCTION;
	A[idx].function 	= FUNCTION_ADDRESS ( VL, getHhei);
	idx++;			VLSDL_CHECK_IDX

        K[idx]                  = VL_STR_VAL_PlNa;
        U[idx]                  = VSdrwFUNCTION;
	A[idx].function         = FUNCTION_ADDRESS ( VL, getCnam);
	idx++;                  VLSDL_CHECK_IDX
	
	K[idx]                  = VL_STR_VAL_GetU; 
	U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getU);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STR_VAL_GetV;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getV);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STR_VAL_GetVl;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getStrVal);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VLAL_GET_CHAMFID;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getChamf);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = "vl-alma-head" ;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = "vl-alma-tail" ;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery         = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_BND;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBband);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_UNI;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBunit);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_DES;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBdesc);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_JOB;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBjobN);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_NUM;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBnumP);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_IDX;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBidx);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_NAM;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBnam);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_DST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBdst);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_STK;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBstk);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_STE_BND_ETK;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getSBEndstk);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_UNI;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getKLunit);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_JOB;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getKLjobN);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_PRO;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getKLpro);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_LIN;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getKLlin);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_NAM;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getKLnam);
        idx++;                  VLSDL_CHECK_IDX

        K[idx]                  = VL_KEY_LIN_DST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getKLdst);
        idx++;                  VLSDL_CHECK_IDX

	/* Add keywords */
	VSdrwAddFunctions (idx, K, U, A);

	sts = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexecBalanceList (		IGRint		num,
				struct	GRobj_env	List[],
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{

		IGRint		sts=MSSUCC, i, j;
		VSdrwOutputData	*outPutInit, *outPutCurr, *p;
	struct	GRid		context;
		VLsdlContext	sdlC;
	struct	VLsortTpl	*Sort;
		VLbalBasePts	Base;

	/* Initialize */
	outPutInit  = NULL;
	outPutCurr  = NULL;
	vl$sdlInit( ctx	= &sdlC );
	VLvl_report_LoadKeyWords();

	/* Fill the VLsortTpl structure */
	sts = VLfillBalanceData ( num, List, &Sort, msg);
	as$status ( sts    = sts,
		    msg    = "VLfillBalanceData()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Open output ASCII file */
	vl$sdlOpenFile(	ctx	= &sdlC,
			file	= &file );

	/* Begin report */
	vl$sdlGetCol(	ctx	= &sdlC,
			colType	= VLSDL_SYST_COL,
			colId	= &context );

	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_BAL_STA );

	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
		outPutCurr = p;

	/* Process report */
	for ( i=0; i<num; i++ ){

		vl$sdlSetState(	ctx	= &sdlC,
				state	= VL_S_BAL_RPT );
		sdlC.stateArgs	= &Sort[i];
		vs$drwExecConfig (	
				msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
	        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
				outPutCurr = p;

		sts = VLbasePoints ( msg, &List[i], &Base );
		as$status ( sts    = sts,
			    msg    = "VLfillBalanceData()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		for ( j=0; j<4; j++ ) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_S_BAL_BAS );
			sdlC.stateArgs	= &Base.corner[j];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
		        for ( p=(outPutCurr ? outPutCurr : outPutInit);
			      p;
			      p=p->next )	outPutCurr = p;

		}
	}

	/* End report */
	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_BAL_END );
	sdlC.stateArgs	= NULL;
	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
		outPutCurr = p;

wrapup:
	/* Free memory */
        if (Sort) {     om$dealloc(ptr = Sort); Sort = NULL; }

	/* Close the ASCII file */
	vl$sdlFree( ctx = &sdlC );

	/* Remove keywords */
	VSdrwRmFunctions ();

	return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexecPinjigList (		IGRint		num,
				struct	GRobj_env	List[],
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{

		IGRint		 sts=MSSUCC, i, j, npin, ncrn, npnl;
		VSdrwOutputData	*oPI1, *oPI2, *oPC1, *oPC2, *p;
	struct	GRid		context;
		VLsdlContext	sdlC;
	struct	ACrg_coll	*Data;
		VLpinCorn	*Corn, *Panl;
		IGRpoint	H1V1;

	/* Initialize */
	oPI1 = oPI2 = NULL;
	oPC1 = oPC2 = NULL;
	Data        = NULL;
	Corn        = NULL;
	Panl        = NULL;
	vl$sdlInit( ctx	= &sdlC );
	VLvl_report_LoadKeyWords();

	/* Open output ASCII file */
	vl$sdlOpenFile(	ctx	= &sdlC,
			file	= &file );

	/* Begin report */
	vl$sdlGetCol(	ctx	= &sdlC,
			colType	= VLSDL_SYST_COL,
			colId	= &context );

	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_PIN_STA );

	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;


	/* Process report */
	for ( i=0; i<num; i++ ){

		/* Get generic attributes of this <VLpinjig> */
		sts = VLfillPinjig1 ( &List[i],
				      &npin, &ncrn, &Corn, &npnl, &Panl, &Data,
				      H1V1, msg);
		as$status ( sts    = sts,
			    msg    = "VLfillPinjig1()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		vl$sdlSetState(	ctx	= &sdlC,
				state	= VL_S_PIN_TIT );
		sdlC.stateArgs	= &Data;

		vs$drwExecConfig (	msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
	        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

		for ( j=0; j<npin; j++) {

			/* Get pins attributes */
			sts = VLfillPinjig2 ( &List[i], j, H1V1, Data, msg);
			as$status ( sts    = sts,
				    msg    = "VLfillPinjig2()",
				    test   = (!(sts & 0x00000001 & (*msg))),
				    action = GOTO_VALUE,
				    value  = wrapup );

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_S_PIN_RPT );

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;
		}

		vl$sdlSetState(	ctx	= &sdlC,
				state	= VL_S_CRN_TIT );
		sdlC.stateArgs	= &Data;

		vs$drwExecConfig (	msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
	        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

		for ( j=0; j<ncrn; j++) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_S_CRN_RPT );
			sdlC.stateArgs	= &Corn[j];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;
		}

		vl$sdlSetState(	ctx	= &sdlC,
				state	= VL_S_PNL_TIT );
		sdlC.stateArgs	= &Data;

		vs$drwExecConfig (	msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
	        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

		for ( j=0; j<npnl; j++) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_S_PNL_RPT );
			sdlC.stateArgs	= &Panl[j];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;
		}
	}

	/* Free memory */
       	if (Panl) {     om$dealloc(ptr = Panl); Panl = NULL; }
       	if (Corn) {     om$dealloc(ptr = Corn); Corn = NULL; }
       	if (Data) {     om$dealloc(ptr = Data); Data = NULL; }

	/* End report */
	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_PIN_END );
	sdlC.stateArgs	= NULL;
	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = oPI1
                                                ? &oPC1->next
                                                : &oPI1 );
        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

wrapup:
	/* Free memory */
       	if (Panl) {     om$dealloc(ptr = Panl); Panl = NULL; }
       	if (Corn) {     om$dealloc(ptr = Corn); Corn = NULL; }
       	if (Data) {     om$dealloc(ptr = Data); Data = NULL; }

	/* Close the ASCII file */
	vl$sdlFree( ctx = &sdlC );

	/* Remove keywords */
	VSdrwRmFunctions ();

	return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexecChtTemplateList (		IGRint		num,
				struct	GRobj_env	List[],
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{

		IGRint		 sts=MSSUCC, i, j, nobj=0;
		VSdrwOutputData	*oPI1, *oPI2, *oPC1, *oPC2, *p;
	struct	GRid		context;
		VLsdlContext	sdlC;
		VLpltTpl	*Reg, *Spi;

	/* Initialize */
	oPI1 = oPI2 = NULL;
	oPC1 = oPC2 = NULL;
	Reg         = NULL;
	Spi         = NULL;
	vl$sdlInit( ctx	= &sdlC );
	VLvl_report_LoadKeyWords();

	/* Open output ASCII file */
	vl$sdlOpenFile(	ctx	= &sdlC,
			file	= &file );

	/* Begin report */
	vl$sdlGetCol(	ctx	= &sdlC,
			colType	= VLSDL_SYST_COL,
			colId	= &context );

	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_CHT_TPL_STA );
	sdlC.stateArgs	= NULL;

	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

	/* Process report */
	for ( i=0; i<num; i++ ){

		/* Extract info from <VLtplMgr> */
		sts = VLfillChtTemplateData ( &List[i], &nobj, &Reg, &Spi, msg);
                as$status ( sts    = sts,
			    msg    = "VLfillChtTemplateData()",
                            test   = (!(sts & 0x00000001 & (*msg))),
                            action = GOTO_VALUE,
                            value  = wrapup );

		/* CHT template title */
		vl$sdlSetState(	ctx	= &sdlC,
				state	= VL_S_CHT_TPL_TIT );
		sdlC.stateArgs	= &Reg[0];

		vs$drwExecConfig (	msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
	        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

		/* CHT template report */
		for ( j=0; j<nobj; j++) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_S_CHT_TPL_RPT );
			sdlC.stateArgs	= &Reg[j];

			vs$drwExecConfig (	msg             = msg,
		                                elmId           = &context,
		                                elmEnv          = Env,
		                                drwPlane        = NULL,
		                                viewPlane       = NULL,
		                                viewVector      = NULL,
		                                drwEnv          = NULL,
		                                drwLbsys        = NULL,
		                                selCount        = 0,
		                                selList         = NULL,
		                                filename        = setup,
						appData		= &sdlC,
		                                output          = oPI1
	                                                        ? &oPC1->next
	                                                        : &oPI1 );
		        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next) oPC1 = p;
		}

		if (Spi) {

			/* SPINE template title */
			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_S_CHT_SPI_TIT );
			sdlC.stateArgs	= &Spi[0];

			vs$drwExecConfig (	msg             = msg,
		                                elmId           = &context,
		                                elmEnv          = Env,
		                                drwPlane        = NULL,
		                                viewPlane       = NULL,
		                                viewVector      = NULL,
		                                drwEnv          = NULL,
		                                drwLbsys        = NULL,
		                                selCount        = 0,
		                                selList         = NULL,
		                                filename        = setup,
						appData		= &sdlC,
		                                output          = oPI1
	                                                        ? &oPC1->next
	                                                        : &oPI1 );
		        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next) oPC1 = p;

			/* CHT template report */
			for ( j=0; j<nobj; j++) {

				vl$sdlSetState(	ctx	= &sdlC,
						state	= VL_S_CHT_SPI_RPT );
				sdlC.stateArgs	= &Spi[j];

			vs$drwExecConfig (	msg             = msg,
		                                elmId           = &context,
		                                elmEnv          = Env,
		                                drwPlane        = NULL,
		                                viewPlane       = NULL,
		                                viewVector      = NULL,
		                                drwEnv          = NULL,
		                                drwLbsys        = NULL,
		                                selCount        = 0,
		                                selList         = NULL,
		                                filename        = setup,
						appData		= &sdlC,
		                                output          = oPI1
	                                                        ? &oPC1->next
	                                                        : &oPI1 );
		        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next) oPC1 = p;
			}
		}
	}

	/* End report */
	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_CHT_TPL_END );
	sdlC.stateArgs	= NULL;
	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = oPI1
                                                ? &oPC1->next
                                                : &oPI1 );
        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

wrapup:
	/* Free memory */
	if (Reg) {     om$dealloc (ptr = Reg);        Reg = NULL;    }
        if (Spi) {     om$dealloc (ptr = Spi);        Spi = NULL;    }

	/* Close the ASCII file */
	vl$sdlFree( ctx = &sdlC );

	/* Remove keywords */
	VSdrwRmFunctions ();

	return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexecHeiTemplateList (		IGRint		num,
				struct	GRobj_env	List[],
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{
		IGRint		sts=MSSUCC, i, j, k;
		IGRint		ntpl=0, nval=0;
		VSdrwOutputData	*outPutInit, *outPutCurr, *p;
	struct	GRid		context;
		VLsdlContext	sdlC;
	struct	ACrg_coll	attr;
		IGRdouble	step, *Val;
		VLpltTpl	*Tpl;

	/* Initialize */
	outPutInit = NULL;
	outPutCurr = NULL;
	Tpl	   = NULL;
	Val        = NULL;
	vl$sdlInit( ctx	= &sdlC );
	VLvl_report_LoadKeyWords();

	/* Open output ASCII file */
	vl$sdlOpenFile(	ctx	= &sdlC,
			file	= &file );

	/* Begin report */
	vl$sdlGetCol(	ctx	= &sdlC,
			colType	= VLSDL_SYST_COL,
			colId	= &context );

	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_HEI_TPL_STA );

	sdlC.stateArgs	= NULL;

	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
		outPutCurr = p;

	/* Get step value setted by user */
	strcpy ( attr.name, VLRPT_HEIGHT_STEP);
	attr.desc.value.att_exp = 0.0;
	vl$sdlGetAttr ( ctx = &sdlC, attr = &attr, colType = VLSDL_SYST_COL);
	step = attr.desc.value.att_exp;
	if (step == 0.0)	step = 100.0;

	/* Process report */
	for ( i=0; i<num; i++) {

	/* Get <VLtplMgr> and <VLtplObj>s names */
	if (Tpl) {	om$dealloc (ptr = Tpl);	Tpl = NULL;	}
	sts = VLfillHeiTemplateData1 ( &List[i], &ntpl, &Tpl, msg);
	as$status ( sts    = sts,
	            msg    = "VLfillHeiTemplateData1()",
	            test   = (!(sts & 0x00000001 & (*msg))),
	            action = GOTO_VALUE,
	            value  = wrapup );

	for ( j=0; j<ntpl; j++) {
	sts = VLfillHeiTemplateData2 ( &List[i], step, &Tpl[j],
				       &nval, &Val, msg );
	as$status ( sts    = sts,
	            msg    = "VLfillHeiTemplateData2()",
	            test   = (!(sts & 0x00000001 & (*msg))),
	            action = GOTO_VALUE,
	            value  = wrapup );

	/* Title report */
	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_HEI_TPL_TIT );

	sdlC.stateArgs	= &Tpl[j];

	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
		outPutCurr = p;

	for ( k=0; k<nval; k++) {

                vl$sdlSetState( ctx     = &sdlC,
				state	= VL_S_HEI_TPL_RPT );

		Tpl[j].idx = k;
		Tpl[j].cht = Val[2*k];
		Tpl[j].hei = Val[2*k+1];
#ifdef TRACE
printf("\t\tidx=%d, stp=%g, hei=%g\n", Tpl[j].idx, Tpl[j].cht, Tpl[j].hei);
#endif
		sdlC.stateArgs	= &Tpl[j];

                vs$drwExecConfig (
                                msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
                for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
                                outPutCurr = p;
        }
        }
        }

	/* End report */
	vl$sdlGetCol(	ctx	= &sdlC,
			colType	= VLSDL_SYST_COL,
			colId	= &context );

	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_S_HEI_TPL_END );

	sdlC.stateArgs	= NULL;

	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
		outPutCurr = p;

wrapup:
	/* Free memory */
	if (Val)  {	om$dealloc (ptr = Val);		Val  = NULL;	}
	if (Tpl)  {	om$dealloc (ptr = Tpl);		Tpl  = NULL;	}

	/* Close the ASCII file */
	vl$sdlFree( ctx = &sdlC );

	/* Remove keywords */
	VSdrwRmFunctions ();

	return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexecHeiBendStfnrList (	IGRint		num,
				struct	GRobj_env	List[],
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{
		IGRint          sts=MSSUCC, i, j, k;
                IGRint          nlin=0, nval=0;
                VSdrwOutputData *outPutInit, *outPutCurr, *p;
        struct  GRid            context, foot_id;
                VLsdlContext    sdlC;
        struct  ACrg_coll       attr;
                IGRdouble       step, *Val;
	struct	GRobj_env	*Lin;
		VLpltTpl	inBeLi;
		IGRshort	text_length=0;
		IGRuchar	*text_string;

	/* Initialize */
        outPutInit = NULL;
        outPutCurr = NULL;
        Val        = NULL;
        Lin        = NULL;
        vl$sdlInit( ctx = &sdlC );
        VLvl_report_LoadKeyWords();
	text_string = NULL;

	/* Open output ASCII file */
        vl$sdlOpenFile( ctx     = &sdlC,
                        file    = &file );

        /* Begin report */
        vl$sdlGetCol(   ctx     = &sdlC,
                        colType = VLSDL_SYST_COL,
                        colId   = &context );

        vl$sdlSetState( ctx     = &sdlC,
                        state   = VL_S_HEI_BST_STA );

        sdlC.stateArgs  = NULL;

	vs$drwExecConfig (      msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
                outPutCurr = p;

	/* Get step value setted by user */
        strcpy ( attr.name, VLRPT_HEIGHT_STEP);
        attr.desc.value.att_exp = 0.0;
	vl$sdlGetAttr ( ctx = &sdlC, attr = &attr, colType = VLSDL_SYST_COL);
        step = attr.desc.value.att_exp;
        if (step == 0.0)        step = 100.0;

	/* Process report */
        for ( i=0; i<num; i++) {

        /* Get foot "Name" of <VLstifBend> */
	sts = vl$return_foot ( msg	= msg,
			       name	= NAM_SBF_NAME,
			       objId	= &List[i].obj_id,
			       footId	= &foot_id, );
	as$status ( sts    = sts,
		    msg    = "vl$return_foot(NAM_SBF_NAME)",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Retrieve text attributes */
	sts = om$send ( msg = message GRtext.GRgettxattr
				( msg, NULL, &text_length, &text_string ),
			senderid = NULL_OBJID,
			targetid = foot_id.objid,
			targetos = foot_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRtext.GRgettxattr",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	/* Remove escape sequences */
	co$rm_esc_seqs ( msg         = msg,
                         font_num    = (IGRshort)0,
                         font_flags  = (IGRint)0,
                         text_string = text_string,
                         text_length = &text_length );

	/* Copy text in string */
        strncpy ( inBeLi.nam, (IGRchar *)text_string, text_length);
        inBeLi.nam[text_length] = '\0';
	
	/* Extract bended lines from <VLstifBend> */
	sts = VLextractBendedLines ( &List[i], &nlin, &Lin, msg);
	as$status ( sts    = sts,
		    msg    = "VLextractBendedLines()",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );

	for ( j=0; j<nlin; j++) {

	if (Val) {      om$dealloc (ptr = Val); Val = NULL;     }
        sts = VLcomputeBendLineHeights ( &Lin[j], &List[i], step,
					 &nval, &Val, msg);
        as$status ( sts    = sts,
                    msg    = "VLcomputeBendLineHeights()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	inBeLi.frm[0] = '\0';
	sprintf ( inBeLi.frm, "%s%d", NAM_SBF_VARF, nlin+j+1);
#ifdef TRACE
printf( "Title is <%s>\n", inBeLi.frm );
#endif
	/* Title report */
        vl$sdlSetState( ctx     = &sdlC,
                        state   = VL_S_HEI_BST_TIT );

        sdlC.stateArgs  = &inBeLi; 

        vs$drwExecConfig (      msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
                outPutCurr = p;

	for ( k=0; k<nval; k++) {

                vl$sdlSetState( ctx     = &sdlC,
                                state   = VL_S_HEI_BST_RPT );

		inBeLi.cht = Val[2*k];
		inBeLi.hei = Val[2*k+1];
#ifdef TRACE
printf("\t\t stp=%g, hei=%g\n", inBeLi.cht, inBeLi.hei );
#endif
                sdlC.stateArgs  = &inBeLi;

                vs$drwExecConfig (
                                msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
                for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
                                outPutCurr = p;
	}
	}
	}

	/* End report */
        vl$sdlGetCol(   ctx     = &sdlC,
                        colType = VLSDL_SYST_COL,
                        colId   = &context );

        vl$sdlSetState( ctx     = &sdlC,
                        state   = VL_S_HEI_BST_END );

        sdlC.stateArgs  = NULL;

        vs$drwExecConfig (      msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
                outPutCurr = p;

wrapup:
        /* Free memory */
        if (Lin)  {     om$dealloc (ptr = Lin);         Lin  = NULL;    }
        if (Val)  {     om$dealloc (ptr = Val);         Val  = NULL;    }
	if (text_string) {	om$dealloc(ptr = text_string);
				text_string = NULL;	}

	/* Close the ASCII file */
        vl$sdlFree( ctx = &sdlC );

        /* Remove keywords */
        VSdrwRmFunctions ();

        return sts;
}
/* ************************************************************************** */

IGRlong	VLexecStrechValList (	IGRint		num,
				struct	GRobj_env	List[],
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{
		IGRint          sts=MSSUCC, i, j, k;
                IGRint		tmp,l;
                IGRint		loc_sts;
                IGRlong         loc_msg;
                VSdrwOutputData *outPutInit, *outPutCurr, *p;
        struct  GRid            context;
                VLsdlContext    sdlC;
                VStktxt         name;
       
        struct VLStrechVal      StrVal;
        struct GRid		unw,plate;
	VLpinCorn		titl;
        struct ret_struct       expr;
        int			nb_step_in_u,nb_step_in_v;
        struct GRobj_env	obj;
        OMuword			obj_cl,acpretend_cl;

	/* Initialize */
        outPutInit = NULL;
        outPutCurr = NULL;
        om$get_classid(  classname = "ACpretendin",  p_classid = &acpretend_cl);
        vl$sdlInit( ctx = &sdlC );
        VLvl_report_LoadKeyWords();

	/* Open output ASCII file */
        vl$sdlOpenFile( ctx     = &sdlC,
                        file    = &file );

        /* Begin report */
        vl$sdlGetCol(   ctx     = &sdlC,
                        colType = VLSDL_SYST_COL,
                        colId   = &context );


	/* Process report */
        for ( i=0; i<num; i++) {

        // Get the unwrapped plate

        sts = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                               &loc_sts,IDX_UNW,&unw),
              senderid = NULL_OBJID,
              targetid = List[i].obj_id.objid,
              targetos = List[i].obj_id.osnum );

        if (!(sts&loc_sts&1)) goto wrapup;
      
        om$get_classid(osnum      = unw.osnum,
                       objid      = unw.objid,
                       p_classid  = &obj_cl) ;
        if( om$is_ancestry_valid( superclassid  = acpretend_cl,
                                subclassid    = obj_cl ) == OM_S_SUCCESS ) {
          sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        &loc_msg ,
                                        "",
                                        &(obj.obj_id),
                                        &(obj.mod_env.md_env.matrix_type),
                                        obj.mod_env.md_env.matrix ),
                 senderid = NULL_OBJID,
                 targetid = unw.objid,
                 targetos = unw.osnum );
         }
         else obj.obj_id = unw;


        // Get the plate
        sts = om$send(msg=message ACcpx.ACfind_exp_temp_obj(
                                               &loc_sts,1,&plate),
              senderid = NULL_OBJID,
              targetid = obj.obj_id.objid,
              targetos = obj.obj_id.osnum );

        if (!(sts&loc_sts&1)) goto wrapup;

        om$get_classid(osnum      = plate.osnum,
                       objid      = plate.objid,
                       p_classid  = &obj_cl) ;
        if( om$is_ancestry_valid( superclassid  = acpretend_cl,
                                subclassid    = obj_cl ) == OM_S_SUCCESS ) {
          sts = om$send( msg      = message NDmacro.ACreturn_foot(
                                        &loc_msg ,
                                        "",
                                        &(obj.obj_id),
                                        &(obj.mod_env.md_env.matrix_type),
                                        obj.mod_env.md_env.matrix ),
                 senderid = NULL_OBJID,
                 targetid = plate.objid,
                 targetos = plate.osnum );
         }
         else obj.obj_id = plate;

        /* Get the Plate's name */
        sts = om$send ( msg = message GRgraphics.GRgetname ( msg, name),
                        senderid = NULL_OBJID,
                        targetid = obj.obj_id.objid,
                        targetos = obj.obj_id.osnum );
        if (!(sts & 0x00000001 & (*msg)))
                strcpy( titl.cp, "Unamed Plate");
        else    strcpy( titl.cp, &strrchr(name,':')[1]);


	/* Title report */
        vl$sdlSetState( ctx     = &sdlC,
                        state   = VL_STR_VAL_TIT );

        sdlC.stateArgs  = &titl;

        vs$drwExecConfig (      msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
                outPutCurr = p;

        sts = om$send( msg = message ACcpx.ACfind_exp_temp_struct(
                                                        &loc_sts,
                                                        IDX_STEPU,
                                                        &expr,
                                                        Env),
                        senderid = NULL_OBJID,
                        targetid = List[i].obj_id.objid,
                        targetos = List[i].obj_id.osnum );

        if (!(sts&loc_sts&1)) goto wrapup;

        nb_step_in_u =  expr.var.root_pm_st.value;

        sts = om$send( msg = message ACcpx.ACfind_exp_temp_struct(
                                                        &loc_sts,
                                                        IDX_STEPV,
                                                        &expr,
                                                        Env),
                        senderid = NULL_OBJID,
                        targetid = List[i].obj_id.objid,
                        targetos = List[i].obj_id.osnum );

        if (!(sts&loc_sts&1)) goto wrapup;

        nb_step_in_v =  expr.var.root_pm_st.value;

        tmp = (nb_step_in_v-1)*nb_step_in_u;
        l = nb_step_in_v + nb_step_in_u;
        StrVal.num_val = 0;
        for (k=0;k<nb_step_in_u-1;k++)
        {               
          for (j=0;j<nb_step_in_v-1;j++)
          {
            StrVal.u = k;
            StrVal.v = j;
            sts = VLget_strech_val(&List[i],
				    l+ k*(nb_step_in_v-1) +j,
				    &(StrVal.val[0]));
            if (!(sts&1)) goto wrapup;
            sts = VLget_strech_val(&List[i],
				   l+ j*(nb_step_in_u-1) +k +tmp,
				   &(StrVal.val[1]));
            if (!(sts&1)) goto wrapup;
            sts = VLget_strech_val(&List[i],
				    l+ (k+1)*(nb_step_in_v-1) +j,
				    &(StrVal.val[2]));
            if (!(sts&1)) goto wrapup;
            sts = VLget_strech_val(&List[i],
				    l+ (j+1)*(nb_step_in_u-1) +k +tmp,
				    &(StrVal.val[3]));
            if (!(sts&1)) goto wrapup;
            vl$sdlSetState( ctx     = &sdlC,
                            state   = VL_STR_VAL_RPT );
            sdlC.stateArgs  = &StrVal;

            vs$drwExecConfig (
                                msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
            for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
                                outPutCurr = p;
            StrVal.num_val = 0;
	  }
	}
      }

	/* End report */
        vl$sdlGetCol(   ctx     = &sdlC,
                        colType = VLSDL_SYST_COL,
                        colId   = &context );

        vl$sdlSetState( ctx     = &sdlC,
                        state   = VL_STR_VAL_END );

        sdlC.stateArgs  = NULL;

        vs$drwExecConfig (      msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
                                appData         = &sdlC,
                                output          = outPutInit
                                                        ? &outPutCurr->next
                                                        : &outPutInit );
        for ( p=(outPutCurr ? outPutCurr : outPutInit); p; p=p->next)
                outPutCurr = p;

wrapup:
        /* Free memory */
	/* Close the ASCII file */
        vl$sdlFree( ctx = &sdlC );

        /* Remove keywords */
        VSdrwRmFunctions ();

        return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexecSteelBandList (		IGRint		num,
				struct	GRobj_env	List[],
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{

		IGRint		 sts=MSSUCC, i, j, npts;
		VSdrwOutputData	*oPI1, *oPI2, *oPC1, *oPC2, *p;
	struct	GRid		context;
		VLsdlContext	sdlC;
		VLsteelBandInfo	Info;
		VLsteelBandData	*Data;

	/* Initialize */
	oPI1 = oPI2 = NULL;
	oPC1 = oPC2 = NULL;
	Data        = NULL;
	vl$sdlInit( ctx	= &sdlC );
	VLvl_report_LoadKeyWords();

	/* Open output ASCII file */
	vl$sdlOpenFile(	ctx	= &sdlC,
			file	= &file );

	/* Begin report */
	vl$sdlGetCol(	ctx	= &sdlC,
			colType	= VLSDL_SYST_COL,
			colId	= &context );

	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_STE_BND_STA );

	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;


	/* Process report */
	for ( i=0; i<num; i++ ){

		/* Get generic attributes of this steel_band ci_macro */
		sts = VLfillSteelBand ( &List[i], &Info, &Data, msg);
		as$status ( sts    = sts,
			    msg    = "VLfillSteelBand()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );

		vl$sdlSetState(	ctx	= &sdlC,
				state	= VL_STE_BND_TIT );
		sdlC.stateArgs	= &Info;

		vs$drwExecConfig (	msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
	        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

		for ( j=0; j<Info.numP; j++) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_STE_BND_RPT );
			sdlC.stateArgs	= &Data[j];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;
		}

		/* Free memory */
       		if (Data) {     om$dealloc(ptr = Data); Data = NULL; }

	}

	/* End report */
	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_STE_BND_END );
	sdlC.stateArgs	= NULL;
	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = oPI1
                                                ? &oPC1->next
                                                : &oPI1 );
        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

wrapup:
	/* Free memory */
       	if (Data) {     om$dealloc(ptr = Data); Data = NULL; }

	/* Close the ASCII file */
	vl$sdlFree( ctx = &sdlC );

	/* Remove keywords */
	VSdrwRmFunctions ();

	return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexecKeyLineList (		IGRint		num,
				struct	GRobj_env	List[],
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{

		IGRint		 sts=MSSUCC, i, j, npts;
		VSdrwOutputData	*oPI1, *oPI2, *oPC1, *oPC2, *p;
	struct	GRid		context;
		VLsdlContext	sdlC;
		VLkeyLineInfo	Info;
		VLkeyLineData	*Tran, *Long, *Diag;
#ifdef TRACE
printf ( ">> VLexecKeyLineList() on %d %s objects\n", num, NAM_KL_MACR );
#endif
	/* Initialize */
	oPI1 = oPI2 = NULL;
	oPC1 = oPC2 = NULL;
	Tran        = NULL;
	Long        = NULL;
	Diag        = NULL;
	vl$sdlInit( ctx	= &sdlC );
	VLvl_report_LoadKeyWords();

	/* Open output ASCII file */
	vl$sdlOpenFile(	ctx	= &sdlC,
			file	= &file );

	/* Begin report */
	vl$sdlGetCol(	ctx	= &sdlC,
			colType	= VLSDL_SYST_COL,
			colId	= &context );

	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_KEY_LIN_STA );

	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

	/* Process report */
	for ( i=0; i<num; i++ ){

		/* Get generic attributes of this plate_key ci_macro */
#ifdef TRACE
printf ( "VLexecKeyLineList() >> VLfillKeyLine() on object %d\n", i );
#endif
		sts = VLfillKeyLine ( &List[i],
				      &Info, &Tran, &Long, &Diag, msg);
		as$status ( sts    = sts,
			    msg    = "VLfillKeyLine()",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
#ifdef TRACE
printf ( "VLexecKeyLineList() << VLfillKeyLine() on object %d\n", i );
#endif
		vl$sdlSetState(	ctx	= &sdlC,
				state	= VL_KEY_LIN_TIT );
		sdlC.stateArgs	= &Info;

		vs$drwExecConfig (	msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI1
                                                        ? &oPC1->next
                                                        : &oPI1 );
	        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

		if (Info.numT > 0) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_KEY_LIN_T_H );
			sdlC.stateArgs	= &Tran[0];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;
		}

		for ( j=0; j<Info.numT; j++) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_KEY_LIN_T_R );
			sdlC.stateArgs	= &Tran[j];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;

		}

		if (Info.numL > 0) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_KEY_LIN_L_H );
			sdlC.stateArgs	= &Long[0];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;
		}

		for ( j=0; j<Info.numL; j++) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_KEY_LIN_L_R );
			sdlC.stateArgs	= &Long[j];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;

		}

		if (Info.numD > 0) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_KEY_LIN_D_H );
			sdlC.stateArgs	= &Diag[0];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;
		}

		for ( j=0; j<Info.numD; j++) {

			vl$sdlSetState(	ctx	= &sdlC,
					state	= VL_KEY_LIN_D_R );
			sdlC.stateArgs	= &Diag[j];

			vs$drwExecConfig (	
					msg             = msg,
	                                elmId           = &context,
	                                elmEnv          = Env,
	                                drwPlane        = NULL,
	                                viewPlane       = NULL,
	                                viewVector      = NULL,
	                                drwEnv          = NULL,
	                                drwLbsys        = NULL,
	                                selCount        = 0,
	                                selList         = NULL,
	                                filename        = setup,
					appData		= &sdlC,
	                                output          = oPI2
                                                        ? &oPC2->next
                                                        : &oPI2 );
			for ( p=(oPC2 ? oPC2 : oPI2); p; p=p->next)
				oPC2 = p;
		}

		/* Free memory */
       		if (Tran) {     om$dealloc(ptr = Tran); Tran = NULL; }
       		if (Long) {     om$dealloc(ptr = Long); Long = NULL; }
       		if (Diag) {     om$dealloc(ptr = Diag); Diag = NULL; }

	}

	/* End report */
	vl$sdlSetState(	ctx	= &sdlC,
			state	= VL_KEY_LIN_END );
	sdlC.stateArgs	= NULL;
	vs$drwExecConfig (	msg             = msg,
                                elmId           = &context,
                                elmEnv          = Env,
                                drwPlane        = NULL,
                                viewPlane       = NULL,
                                viewVector      = NULL,
                                drwEnv          = NULL,
                                drwLbsys        = NULL,
                                selCount        = 0,
                                selList         = NULL,
                                filename        = setup,
				appData		= &sdlC,
                                output          = oPI1
                                                ? &oPC1->next
                                                : &oPI1 );
        for ( p=(oPC1 ? oPC1 : oPI1); p; p=p->next)	oPC1 = p;

wrapup:
	/* Free memory */
       	if (Tran) {     om$dealloc(ptr = Tran); Tran = NULL; }
       	if (Long) {     om$dealloc(ptr = Long); Long = NULL; }
       	if (Diag) {     om$dealloc(ptr = Diag); Diag = NULL; }

	/* Close the ASCII file */
	vl$sdlFree( ctx = &sdlC );

	/* Remove keywords */
	VSdrwRmFunctions ();
#ifdef TRACE
printf ( "<< VLexecKeyLineList()\n" );
#endif
	return sts;
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLexecKeyLineMatrix (		IGRint		num,
				struct	GRobj_env	Lst[],
					IGRlong		*msg )
{

		IGRint		 sts=MSSUCC, i, j, cnt, nRow, nCol;
		VLkeyLineInfo	Info;
	struct	GRid		foot;
		IGRchar		name[80];
		IGRchar		**Matrix;

	/* Initialise */
	Matrix = NULL;

	/* Process report */
	for ( i=0; i<num; i++ ){

		/* Get info */
		sts = VLgetKLinfo ( &Lst[i], &Info, msg );
	        as$status ( sts    = sts,
	                    msg    = "VLgetKLinfo()",
	                    test   = (!(sts & 0x00000001 & (*msg))),
	                    action = GOTO_VALUE,
	                    value  = wrapup );

		/* Get RowNumber & ColumnNumber */
		nRow = nCol = 0;
		for ( j=0; j<Info.numT; j++ ) {

			IGRdouble	val;

			/* Get Point# feet */
			sprintf ( name, "%s%d", NAM_KL_PNT, j+1 );
			foot.objid = NULL_OBJID;
			sts = vl$return_foot ( msg      = msg,
		                               name     = name,
		                               objId    = &(Lst[i].obj_id),
		                               objEnv   = &(Lst[i].mod_env),
		                               footId   = &foot );
		        as$status ( sts    = sts,
		                    msg    = "vl$return_foot",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			/* Get Row attribute value */
			val = KLgetDistance ( &foot, "Row" );
			if (nRow < val)	nRow = val;

			/* Get Column attribute value */
			val = KLgetDistance ( &foot, "Column" );
			if (nCol < val)	nCol = val;
		}

		/* add 1 row & 1 column for headers */
		nRow++;
		nCol++;

		/* Allocate memory */
		Matrix = om$calloc ( num = nRow * nCol, structure = IGRchar * );
		for ( j=0; j < nRow * nCol; j++ ) {
			Matrix[j] = om$calloc ( num = 80, structure = IGRchar );
			strcpy ( Matrix[j], "X" );
		}

		/* Fill Transverse matrix */
		Matrix[0][0] = '\0';
		for ( j=0; j<Info.numT; j++ ) {

			IGRint		iRow, iCol;

			/* Get Point# feet */
			sprintf ( name, "%s%d", NAM_KL_PNT, j+1 );
			foot.objid = NULL_OBJID;
			sts = vl$return_foot ( msg      = msg,
		                               name     = name,
		                               objId    = &(Lst[i].obj_id),
		                               objEnv   = &(Lst[i].mod_env),
		                               footId   = &foot );
		        as$status ( sts    = sts,
		                    msg    = "vl$return_foot",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			iRow = KLgetDistance ( &foot, "Row" );
			iCol = KLgetDistance ( &foot, "Column" );

			strcpy ( Matrix[iRow*nCol],
				 KLgetName(&foot,NAM_KPJ_LNAM) );
			strcpy ( Matrix[iCol],
				 KLgetName(&foot,NAM_KPJ_TNAM) );
			sprintf ( Matrix[iCol+iRow*nCol], "%.0f",
				  KLgetDistance(&foot,NAM_KPJ_TDIST) );
		}

		/* Print Transverse matrix in file */
		VLsprintfKLmatrix ( &Info, Matrix, nRow, nCol,
				    "TRANS_", i+1, "TRANSVERSE" );

		/* Initialise matrix */
		for ( j=0; j < nRow * nCol; j++ )
			strcpy ( Matrix[j], "X" );

		/* Fill Longitudinal matrix */
		Matrix[0][0] = '\0';
		for ( j=0; j<Info.numL; j++ ) {

			IGRint		iRow, iCol;

			/* Get Point# feet */
			sprintf ( name, "%s%d", NAM_KL_PNT, j+1 );
			foot.objid = NULL_OBJID;
			sts = vl$return_foot ( msg      = msg,
		                               name     = name,
		                               objId    = &(Lst[i].obj_id),
		                               objEnv   = &(Lst[i].mod_env),
		                               footId   = &foot );
		        as$status ( sts    = sts,
		                    msg    = "vl$return_foot",
		                    test   = (!(sts & 0x00000001 & (*msg))),
		                    action = GOTO_VALUE,
		                    value  = wrapup );

			iRow = KLgetDistance ( &foot, "Row" );
			iCol = KLgetDistance ( &foot, "Column" );

			strcpy ( Matrix[iRow*nCol],
				 KLgetName(&foot,NAM_KPJ_LNAM) );
			strcpy ( Matrix[iCol],
				 KLgetName(&foot,NAM_KPJ_TNAM) );
			sprintf ( Matrix[iCol+iRow*nCol], "%.0f",
				  KLgetDistance(&foot,NAM_KPJ_LDIST) );
		}

		/* Print Longitudinal matrix in file */
		VLsprintfKLmatrix ( &Info, Matrix, nRow, nCol,
				    "LONGI_", i+1, "LONGITUDINAL" );

		/* Free memory */
		if (Matrix) {
			for ( j=0; j < nRow * nCol; j++ ) {
				om$dealloc ( ptr = Matrix[j] );
				Matrix[j] = NULL;
			}
			om$dealloc ( ptr = Matrix );
			Matrix = NULL;
		}
	}

wrapup:
	/* Free memory */
	if (Matrix) {
		for ( j=0; j < nRow * nCol; j++ ) {
			om$dealloc ( ptr = Matrix[j] );
			Matrix[j] = NULL;
		}
		om$dealloc ( ptr = Matrix );
		Matrix = NULL;
	}
	return sts;
}
/* ************************************************************************** */

end implementation VLabstract;
