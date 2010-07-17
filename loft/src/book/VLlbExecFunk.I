class implementation VLabstract;

/* ************************************************************************** */
/*	LOFT loft book in ASCII file exec functions used with Strudel	      */
/*	Marc Fournier (COC shipbuilding, Rungis)			      */
/*	16-AUG-1994	:	creation				      */
/* ************************************************************************** */

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"bsvalues.h"
#include	"grmacros.h"
#include	"msdef.h"
#include	"msmacros.h"

#include        "vscmd.h"
#include        "vsdrwdef.h"
#include        "vsdrw.h"
#include        "vsdrwmacros.h"
#include        "vsdrwapi.h"

#include	"vlsdldef.h"
#include	"vlsdl.h"
#include	"vlsdlmacros.h"
#include	"vlbookdef.h"
#include	"vlbook.h"

/*	#define	TRACE	*/

/* ************************************************************************** */
IGRint	VLvl_book_LoadKeyWords ()
{
	IGRchar		*K[VLSDL_MAX_IDX];
	VSdrwUsrTokType	U[VLSDL_MAX_IDX];
	VSdrwAction	A[VLSDL_MAX_IDX];
	IGRint		idx;
	IGRlong		sts;

DECLARE_ISOFTYPE ( VL, userBlock)
DECLARE_FUNCTION ( VL, getLcrvNam)
DECLARE_FUNCTION ( VL, getLplnNam)
DECLARE_FUNCTION ( VL, getLoriVal)
DECLARE_FUNCTION ( VL, getLabsIntVal)
DECLARE_FUNCTION ( VL, getLabsCrvVal)
DECLARE_FUNCTION ( VL, getLabsPlnVal)
DECLARE_FUNCTION ( VL, getLrelIntVal)
DECLARE_FUNCTION ( VL, getLrelCrvVal)
DECLARE_FUNCTION ( VL, getLrelPlnVal)
DECLARE_FUNCTION ( VL, getLabsIntLst)
DECLARE_FUNCTION ( VL, getLabsCrvLst)
DECLARE_FUNCTION ( VL, getLabsPlnLst)
DECLARE_FUNCTION ( VL, getLrelIntLst)
DECLARE_FUNCTION ( VL, getLrelCrvLst)
DECLARE_FUNCTION ( VL, getLrelPlnLst)
DECLARE_FUNCTION ( VL, getLothIntVal)
DECLARE_FUNCTION ( VL, getLothIntLst)
DECLARE_FUNCTION ( VL, getLabsStaVal)
DECLARE_FUNCTION ( VL, getLrelStaVal)
DECLARE_FUNCTION ( VL, getLabsEndVal)
DECLARE_FUNCTION ( VL, getLrelEndVal)
DECLARE_FUNCTION ( VL, setLdivisor)
DECLARE_FUNCTION ( VL, getLneaStaNam)
DECLARE_FUNCTION ( VL, getLneaStaDst)

	VLvl_LoadKeyWords();

        idx     = 0;    VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_A_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_A_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_A_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_B_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_B_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_B_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_C_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_C_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_C_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_D_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_D_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_D_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_E_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_E_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_E_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_F_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_F_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_F_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_G_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_G_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_G_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_H_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_H_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_H_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_I_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_I_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_I_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_J_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_J_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_J_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_K_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_K_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_K_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_L_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_L_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_L_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_M_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_M_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_M_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_N_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_N_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_N_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_O_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_O_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_O_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_P_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_P_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_P_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_Q_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_Q_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_Q_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_R_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_R_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_R_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_S_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_S_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_S_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_T_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_T_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_T_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_U_STA;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_U_RPT;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_S_BOOK_U_END;
        U[idx]                  = VSdrwTYPE;
        A[idx].elmQuery	       = ISOFTYPE_ADDRESS ( VL, userBlock);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_CRV_NAM;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLcrvNam);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_PLN_NAM;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLplnNam);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ORI_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLoriVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ABS_INT_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLabsIntVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ABS_CRV_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLabsCrvVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ABS_PLN_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLabsPlnVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_REL_INT_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLrelIntVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_REL_CRV_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLrelCrvVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_REL_PLN_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLrelPlnVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ABS_INT_LST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLabsIntLst);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ABS_CRV_LST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLabsCrvLst);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ABS_PLN_LST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLabsPlnLst);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_REL_INT_LST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLrelIntLst);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_REL_CRV_LST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLrelCrvLst);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_REL_PLN_LST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLrelPlnLst);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_OTH_INT_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLothIntVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_OTH_INT_LST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLothIntLst);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ABS_STA_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLabsStaVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_REL_STA_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLrelStaVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_ABS_END_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLabsEndVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_REL_END_VAL;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLrelEndVal);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_SET_DIVISOR;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, setLdivisor);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_NEA_STA_NAM;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLneaStaNam);
        idx++;                  VLSDL_CHECK_IDX

	K[idx]                  = VL_F_LB_NEA_STA_DST;
        U[idx]                  = VSdrwFUNCTION;
        A[idx].function         = FUNCTION_ADDRESS ( VL, getLneaStaDst);
        idx++;                  VLSDL_CHECK_IDX

	/* Add keywords */
	VSdrwAddFunctions (idx, K, U, A);

	sts = MSSUCC;

wrapup:
	return (sts);
}
/* ************************************************************************** */
IGRlong	VLexecLoftBookList (		IGRint		*chapter,
					IGRchar		*userpath,
				struct	GRmd_env	*Env,
					VSfileFormInfo	file,
					IGRchar		*setup,
					IGRlong		*msg )
{

		IGRint		sts=MSSUCC, i, numA, numB;
		VSdrwOutputData	*outPutInit, *outPutCurr, *p;
	struct	GRid		context;
		VLsdlContext	sdlC;
		VLlbData	data;

	/* Initialize */
	outPutInit  = NULL;
	outPutCurr  = NULL;
	data.elem   = NULL;
	vl$sdlInit( ctx	= &sdlC );
	VLvl_book_LoadKeyWords();

	/* Open output ASCII file */
	vl$sdlOpenFile(	ctx	= &sdlC,
			file	= &file );

	/* Begin report */
        vl$sdlGetCol(   ctx     = &sdlC,
                        colType = VLSDL_SYST_COL,
                        colId   = &context );

	/* Loop on loftbook's chapters */
	for ( i=0; i<VL_EXEC_BOOK_ROW; i++) {

	if (chapter[i]) {

	/* Display chapter title in key-in field */
	ex$message ( field = KEYIN_FIELD, in_buff = VLindexToChapterName (i) );

	/* Get state keywords & directory indices */
	data.head.chap = i;
	VLgetLoftBookHeader (&data.head);

	/* Get chapter data */
	if (data.elem) { om$dealloc (ptr = data.elem);	data.elem = NULL; }
	sts = VLgetLoftBookData ( userpath, Env, &data, msg);
	as$status ( sts    = sts,
                    msg    = "VLgetLoftBookData()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
#ifdef TRACE
printf( "\tnumA=%d, idxA=%d, plnA=%d, looA=%d\n",
	data.numA, data.head.idxA, data.head.plnA, data.head.looA );
printf( "\tnumB=%d, idxB=%d, plnB=%d, looB=%d\n",
	data.numB, data.head.idxB, data.head.plnB, data.head.looB );
printf( "\tXorigin=%g\tYorigin=%g\tZorigin=%g\n",
	data.orig[0], data.orig[1], data.orig[2] );
#endif
	/* Begin chapter */
	if (data.head.looA)	numA = data.numA;
	else			numA = 1;
	for ( data.curA=0; data.curA<numA; data.curA++) {
	vl$sdlSetState ( ctx = &sdlC, state = data.head.staS );
	data.curB = -1;
	sdlC.stateArgs  = &data;
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

	/* Report chapter */
	if (data.head.looB)	numB = data.numB;
	else			numB = 1;
	for ( data.curB=0; data.curB<numB; data.curB++) {
if ((!data.head.looA) || (data.elem[data.curA*data.numB+data.curB].nint)) {
#ifdef TRACE
printf( "Axis(%d,%d) :\t[ %g, %g, %g]\n", data.curA, data.curB,
	data.elem[data.curA*data.numB+data.curB].Pint[0][0],
	data.elem[data.curA*data.numB+data.curB].Pint[0][1],
	data.elem[data.curA*data.numB+data.curB].Pint[0][2] );
#endif
	vl$sdlSetState ( ctx = &sdlC, state = data.head.rptS );
	sdlC.stateArgs  = &data;
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
}
	}

	/* End chapter */
	vl$sdlSetState ( ctx = &sdlC, state = data.head.endS );
	data.curB = -1;
	sdlC.stateArgs  = &data;
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
	}
	}
	}

wrapup:
	/* Clear key-in field */
	ex$message ( field = KEYIN_FIELD, in_buff = " " );

	/* Free memory */
	if (data.elem) { om$dealloc (ptr = data.elem);	data.elem = NULL; }

	/* Close the ASCII file */
	vl$sdlFree( ctx = &sdlC );

	/* Remove keywords */
	VSdrwRmFunctions ();

	return (sts);
}
/* ************************************************************************** */

end implementation VLabstract;
