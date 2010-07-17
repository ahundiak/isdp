class implementation VLabstract;

/* ************************************************************************** */
/*	LOFT loft book in ASCII file user functions used with Strudel	      */
/*	Marc Fournier (COC shipbuilding, Rungis)			      */
/*	18-AUG-1994	:	creation				      */
/* ************************************************************************** */

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"ACattrib.h"
#include	"bsparameters.h"

#include	"vsdrwdef.h"
#include	"vsdrw.h"
#include	"vsdrwmacros.h"
#include	"vsdrwapi.h"
#include	"vsslcdef.h"

#include	"vlbook.h"
#include	"vlbookdef.h"
#include	"vlsdl.h"
#include	"vlsdldef.h"
#include	"vlsdlmacros.h"

#define	CROSSING

/* ========================================================================== */
IGRdouble       VLgetDivisor (  VLsdlContext    *Rpt    )
{
                IGRlong         sts;
                IGRdouble       Div=1.0;
        struct  ACrg_coll       attr;

        strcpy ( attr.name, VL_BU_DIVI_NAM);
        sts = vl$sdlGetAttr ( ctx     = Rpt,
                              attr    = &attr,
                              colType = VLSDL_SYST_COL );
        if (sts&1)      Div = attr.desc.value.att_exp;

        return (Div);
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, sprintf) {

		IGRint		i, idx[100];
		VStktxt		txt, str, unf[100], val[100];
		int		Int=0;
		float		Dbl=0.0;

	/* Initialize */
        if ( (argc < 1) || (argc > 101) )	return xfARGCOUNT;
	txt[0] = '\0';
	if (arglist->arg.type != VS_string)	return xfINVARG;
	else	strcpy ( str, arglist->arg._sval);

	/* Extract format and types from format string */
	VLextractFormat ( str, (argc-1), idx, unf);

	/* Get arguments */
	for ( i=0; i<argc-1; i++) {
		arglist = arglist->next;
		val[i][0] = '\0';
		switch (arglist->arg.type) {

			case VS_int    :
				if (idx[i] == arglist->arg.type)
					sprintf ( val[i], unf[i],
						  arglist->arg._ival);
				break;

			case VS_double :
				if (idx[i] == arglist->arg.type)
					sprintf ( val[i], unf[i],
						  arglist->arg._dval);
				break;

			case VS_string :
				switch (idx[i]) {

					case VS_int    :
						sscanf ( arglist->arg._sval,
							 "%d", &Int);
						sprintf ( val[i], unf[i], Int);
						break;

					case VS_double :
						sscanf ( arglist->arg._sval,
							 "%g", &Dbl);
						sprintf ( val[i], unf[i], Dbl);
						break;

					case VS_string :
						sprintf ( val[i], unf[i],
							  arglist->arg._sval);
						break;
				}
				break;
		}
	}

	/* Execute sprintf */
	for ( i=0; i<argc-1; i++) 	strcat ( txt, val[i]);

	STR_RES (txt);
	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, repeatPattern) {

		IGRint		num=80, i;
		VStktxt		pat, txt;

	/* Initialize */
        if (argc > 2)	return xfARGCOUNT;
	strcpy ( pat, "-");
	txt[0] = '\0';

	/* Get number of characters */
	if (argc > 0) {
		if ( (arglist->arg.type != VS_int) || (arglist->arg._ival < 0) )
			return xfINVARG;
		num = arglist->arg._ival;
	}

	if (argc > 1) {
		arglist = arglist->next;
		if (arglist->arg.type != VS_string)	return xfINVARG;
		strcpy ( pat, arglist->arg._sval);
	}

	for ( i=0; i<num; i++)	strcat ( txt, pat);
	STR_RES (txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, setLdivisor) {

		VLsdlContext	*Rpt;
		IGRdouble	Div=1.0;
		IGRlong		sts;
	struct	ACrg_coll	attr;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get divisor (if any) */
	if (argc == 1) {
		switch (arglist->arg.type) {
			case VS_int:	Div = (IGRdouble) arglist->arg._ival;
					break;
			case VS_double:	Div = arglist->arg._dval;
					break;
			case VS_string:	return xfINVARG;
		}
	}
	if (Div == 0.0)		Div = 1.0;

	/* Set unit divisor */
        Rpt = (VLsdlContext *) inp->appData;
	strcpy ( attr.name, VL_BU_DIVI_NAM);
	attr.desc.type = AC_ATTRIB_DOUBLE;
	attr.desc.value.att_exp = Div;
	sts = vl$sdlSetAttr ( ctx     = Rpt,
	                      attr    = &attr,
	                      colType = VLSDL_SYST_COL );
	if (!(sts&1))	return xfFAILURE;
	else		return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLcrvNam) {

		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		VLlbElem	*Ele;
		VStktxt		txt;

	/* Initialize */
        if (argc > 0)	return xfARGCOUNT;
	txt[0] = '\0';

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;
	Ele = (VLlbElem *)     Dat->elem;

	/* Retrieve element */
	if (Ele[Dat->curA*Dat->numB].namA[0] != '\0')
		strcpy ( txt, Ele[Dat->curA*Dat->numB].namA);

	STR_RES (txt);
	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLplnNam) {

		IGRint		curB=0;
		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		VLlbElem	*Ele;
		VStktxt		txt;

	/* Initialize */
        if (argc > 0)	return xfARGCOUNT;
	txt[0] = '\0';

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;
	Ele = (VLlbElem *)     Dat->elem;

	/* Retrieve element */
	if (Dat->curB != -1)	curB = Dat->curB;
	if (Ele[curB].namB[0] != '\0')	strcpy ( txt, Ele[curB].namB);

	STR_RES (txt);
	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLoriVal) {

		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		IGRint		axis=0;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;

	DBL_RES (Dat->orig[axis] / VLgetDivisor(Rpt));
	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLothIntLst) {

		IGRint		idx=0, num=0;
		IGRlong		sts;
		VStktxt		name;
		VLsdlContext    *Rpt;
	struct	ACrg_coll	attr;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;
	strcpy ( name, VL_BC_LST0_NAM);

	/* Get index (if any) */
	if (argc == 1) {
		if (arglist->arg.type != VS_int)	return xfINVARG;
		idx = arglist->arg._ival;
		switch (idx) {
			case 0:	break;
			case 1:	strcpy ( name, VL_BC_LST1_NAM);
				break;
			case 2:	strcpy ( name, VL_BC_LST2_NAM);
				break;
			case 3:	strcpy ( name, VL_BC_LST3_NAM);
				break;
			default:	return xfINVARG;
		}
	}

	/* Get number of crossings */
        Rpt = (VLsdlContext *) inp->appData;
	strcpy ( attr.name, VL_BC_NUMB_NAM);
	attr.desc.value.att_exp = 0.0;
	sts = vl$sdlGetAttr ( ctx     = Rpt,
                              attr    = &attr,
                              colType = VLSDL_SYST_COL );
	if (!(sts&1))	return xfFAILURE;
	num = (IGRint) attr.desc.value.att_exp;

	strcpy ( attr.name, name);
	attr.desc.value.att_txt[0] = '\0';
	sts = vl$sdlGetAttr ( ctx     = Rpt,
	                      attr    = &attr,
	                      colType = VLSDL_SYST_COL );

	STR_RES (attr.desc.value.att_txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLothIntVal) {

		IGRint		idx=0, num=0;
		IGRlong		sts;
		VStktxt		name;
		VLsdlContext    *Rpt;
	struct	ACrg_coll	attr;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;
	strcpy ( name, VL_BC_VAL0_NAM);

	/* Get index (if any) */
	if (argc == 1) {
		if (arglist->arg.type != VS_int)	return xfINVARG;
		idx = arglist->arg._ival;
		switch (idx) {
			case 0:	break;
			case 1:	strcpy ( name, VL_BC_VAL1_NAM);
				break;
			case 2:	strcpy ( name, VL_BC_VAL2_NAM);
				break;
			case 3:	strcpy ( name, VL_BC_VAL3_NAM);
				break;
			default:	return xfINVARG;
		}
	}

	/* Get number of crossings */
        Rpt = (VLsdlContext *) inp->appData;
	strcpy ( attr.name, VL_BC_NUMB_NAM);
	attr.desc.value.att_exp = 0.0;
	sts = vl$sdlGetAttr ( ctx     = Rpt,
                              attr    = &attr,
                              colType = VLSDL_SYST_COL );
	if (!(sts&1))	return xfFAILURE;
	num = (IGRint) attr.desc.value.att_exp;

	/* Return value */
	if (idx >= num)	{	STR_RES ("-"); return xfSUCCESS;	}

	strcpy ( attr.name, name);
	attr.desc.value.att_exp = 0.0;
	sts = vl$sdlGetAttr ( ctx     = Rpt,
	                      attr    = &attr,
	                      colType = VLSDL_SYST_COL );

	if (!(sts&1)) {		STR_RES ("-"); return xfSUCCESS;	}

	DBL_RES (attr.desc.value.att_exp);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLabsIntVal) {

		IGRint		axis=0, curA=0, curB=0, idx=0, num=0, i;
		IGRlong		sts;
		VLsdlContext    *Rpt;
        	VLlbData        *Dat;
        	VLlbElem        *Ele;
		VLlbCross       Cross[4];
        struct  ACrg_coll       attr[VL_BC_ATTR_MAX];
		IGRdouble	Div;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;

	/* Retrieve current pointer */
	if (Dat->curA != -1)    curA = Dat->curA;
        if (Dat->curB != -1)    curB = Dat->curB;
	idx = curA * Dat->numB + curB;
	num = Ele[idx].nint;

	/* Build ACrg_collection */
        VLfillCrossAttr (attr);
	Div = VLgetDivisor(Rpt);
        attr[VL_BC_NUMB_IDX].desc.value.att_exp = (IGRdouble) num;

        /* Return result */
        switch (num) {
                case 0: STR_RES ("-");
                        break;
                case 1: attr[VL_BC_VAL0_IDX].desc.value.att_exp
			= Ele[idx].Pint[0][axis] / Div;
			DBL_RES (attr[VL_BC_VAL0_IDX].desc.value.att_exp);
                        break;
                default :
                        for ( i=0; i<num; i++) {
                                Cross[i].idx = i;
                                Cross[i].val = Ele[idx].Pint[i][axis] / Div;
                        }
                        qsort ( Cross, num, sizeof(VLlbCross), VLsortCrossing);
                        VLelimInChtTol ( &num, Cross, BSTOLCHRDHT);
                        DBL_RES (Cross[0].val);
			attr[VL_BC_NUMB_IDX].desc.value.att_exp
			= (IGRdouble) num;
			for ( i=0; i<num; i++)
				attr[VL_BC_VAL0_IDX+i].desc.value.att_exp
				=  Cross[i].val;
                        break;
        }

        /* Set value in context */
	for ( i=0; i<VL_BC_ATTR_MAX; i++) {
		sts = vl$sdlSetAttr ( ctx     = Rpt,
	                              attr    = &attr[i],
	                              colType = VLSDL_SYST_COL);
		if (!(sts&1))	return xfFAILURE;
	}

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLabsCrvVal) {

	IGRint		axis=0, curA=0, idx=0;
	VLsdlContext    *Rpt;
        VLlbData        *Dat;
        VLlbElem        *Ele;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;

	/* Retrieve current pointer */
	if (Dat->curA != -1)    curA = Dat->curA;
	idx = curA * Dat->numB;

	/* Return result */
	DBL_RES (Ele[idx].pntA[axis] / VLgetDivisor(Rpt));

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLabsPlnVal) {

	IGRint		axis=0, curB=0;
	VLsdlContext    *Rpt;
        VLlbData        *Dat;
        VLlbElem        *Ele;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;

	/* Retrieve current pointer */
        if (Dat->curB != -1)    curB = Dat->curB;

	/* Return result */
	DBL_RES (Ele[curB].pntB[axis] / VLgetDivisor(Rpt));

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLrelIntVal) {

		IGRint		axis=0, curA=0, curB=0, idx=0, num=0, i;
		IGRlong		sts;
		VLsdlContext    *Rpt;
        	VLlbData        *Dat;
        	VLlbElem        *Ele;
		VLlbCross	Cross[4];
	struct	ACrg_coll	attr[VL_BC_ATTR_MAX];
		IGRdouble	Div;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;

	/* Retrieve current pointer */
	if (Dat->curA != -1)    curA = Dat->curA;
        if (Dat->curB != -1)    curB = Dat->curB;
	idx = curA * Dat->numB + curB;
	num = Ele[idx].nint;

	/* Build ACrg_collection */
	VLfillCrossAttr (attr);
	Div = VLgetDivisor (Rpt);
	attr[VL_BC_NUMB_IDX].desc.value.att_exp = (IGRdouble) num;

	/* Return result */
	switch (num) {
		case 0:	STR_RES ("-");
			break;
		case 1: attr[VL_BC_VAL0_IDX].desc.value.att_exp
			= (Ele[idx].Pint[0][axis] - Dat->orig[axis]) / Div;
			DBL_RES (attr[VL_BC_VAL0_IDX].desc.value.att_exp);
			break;
		default :
			for ( i=0; i<num; i++) {
				Cross[i].idx = i;
				Cross[i].val = (Ele[idx].Pint[i][axis]
					     -  Dat->orig[axis]) / Div;
			}
			qsort ( Cross, num, sizeof(VLlbCross), VLsortCrossing);
			VLelimInChtTol ( &num, Cross, BSTOLCHRDHT);
			DBL_RES (Cross[0].val);
			attr[VL_BC_NUMB_IDX].desc.value.att_exp
			= (IGRdouble) num;
			for ( i=0; i<num; i++)
				attr[VL_BC_VAL0_IDX+i].desc.value.att_exp
				=  Cross[i].val;
			break;
	}

	/* Set value in context */
	for ( i=0; i<VL_BC_ATTR_MAX; i++) {
		sts = vl$sdlSetAttr ( ctx     = Rpt,
	                              attr    = &attr[i],
	                              colType = VLSDL_SYST_COL);
		if (!(sts&1))	return xfFAILURE;
	}

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLrelCrvVal) {

	IGRint		axis=0, curA=0, idx=0;
	VLsdlContext    *Rpt;
        VLlbData        *Dat;
        VLlbElem        *Ele;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;

	/* Retrieve current pointer */
	if (Dat->curA != -1)    curA = Dat->curA;
	idx = curA * Dat->numB;

	/* Return result */
	DBL_RES ((Ele[idx].pntA[axis] - Dat->orig[axis]) / VLgetDivisor(Rpt));

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLrelPlnVal) {

	IGRint		axis=0, curB=0;
	VLsdlContext    *Rpt;
        VLlbData        *Dat;
        VLlbElem        *Ele;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;

	/* Retrieve current pointer */
        if (Dat->curB != -1)    curB = Dat->curB;

	/* Return result */
	DBL_RES ((Ele[curB].pntB[axis] - Dat->orig[axis]) / VLgetDivisor(Rpt));

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLabsIntLst) {

		IGRint          curB=0, i, j, idx, nint;
		IGRint		axis=0, len=0, jst=1, dec=0;
		IGRlong		sts;
        	VStktxt         val[4], blk;
        	VLsdlContext    *Rpt;
        	VLlbData        *Dat;
		VLlbElem        *Ele;
		VLlbCross	Cross[4];
	struct	ACrg_coll	attr[VL_BC_ATTR_MAX];
		IGRdouble	Div;

	/* Initialize */
        if (argc > 3)	return xfARGCOUNT;
	blk[0] = '\0';

	/* Get axis (if any) */
	if (argc >   0) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Get element length index (if any) */
        if (argc > 1) {
                arglist = arglist->next;
                if ( (arglist->arg.type != VS_int) || (arglist->arg._ival < 0) )
                        return xfINVARG;
                len = arglist->arg._ival;
                for ( i=0; i<len; i++)  blk[i] = ' ';
                blk[len] = '\0';
        }

	/* Get format & justification index (if any) */
        if (argc > 2) {
                arglist = arglist->next;
                if (arglist->arg.type != VS_int)    return xfINVARG;
                dec = arglist->arg._ival;
                if (dec < 0) {	jst = -1;       dec *= -1;      }
                if (dec > 9)    dec = 9;
	}

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;

	/* Build ACrg_collection */
        VLfillCrossAttr (attr);
	Div = VLgetDivisor(Rpt);

	/* Retrieve current pointer */
        if (Dat->curB != -1)    curB = Dat->curB;

	/* Build output string */
	for ( i=0; i<Dat->numA; i++) {

		idx  = i * Dat->numB + curB;
		nint = Ele[idx].nint;

		val[0][0] = val[1][0] = val[2][0] = val[3][0] = '\0';
		switch (nint) {
			case 0:	strcpy ( val[0], blk);
			case 1: strcpy ( val[1], blk);
			case 2: strcpy ( val[2], blk);
			case 3:	strcpy ( val[3], blk);
				break;
		}
		
		Cross[0].val = Cross[1].val = Cross[2].val = Cross[3].val = 0.0;
		for ( j=0; j<nint; j++) {
			Cross[j].idx = j;
			Cross[j].val = Ele[idx].Pint[j][axis] / Div;
                }
                qsort ( Cross, nint, sizeof(VLlbCross), VLsortCrossing);
                VLelimInChtTol ( &nint, Cross, BSTOLCHRDHT);

		if ( nint > (IGRint) attr[VL_BC_NUMB_IDX].desc.value.att_exp )
			attr[VL_BC_NUMB_IDX].desc.value.att_exp=(IGRdouble)nint;

		switch (nint) {
			case 4:	sprintf ( val[3], "%.*f", dec, Cross[3].val );
			case 3:	sprintf ( val[2], "%.*f", dec, Cross[2].val );
			case 2:	sprintf ( val[1], "%.*f", dec, Cross[1].val );
			case 1:	sprintf ( val[0], "%.*f", dec, Cross[0].val );
				break;
		}

		sprintf ( attr[VL_BC_LST0_IDX].desc.value.att_txt, "%s%*s",
			  attr[VL_BC_LST0_IDX].desc.value.att_txt,
			  jst * len, val[0] );

		sprintf ( attr[VL_BC_LST1_IDX].desc.value.att_txt, "%s%*s",
			  attr[VL_BC_LST1_IDX].desc.value.att_txt,
			  jst * len, val[1] );

		sprintf ( attr[VL_BC_LST2_IDX].desc.value.att_txt, "%s%*s",
			  attr[VL_BC_LST2_IDX].desc.value.att_txt,
			  jst * len, val[2] );

		sprintf ( attr[VL_BC_LST3_IDX].desc.value.att_txt, "%s%*s",
			  attr[VL_BC_LST3_IDX].desc.value.att_txt,
			  jst * len, val[3] );
	}

	/* Set value in context */
        for ( i=0; i<VL_BC_ATTR_MAX; i++) {
                sts = vl$sdlSetAttr ( ctx     = Rpt,
                                      attr    = &attr[i],
                                      colType = VLSDL_SYST_COL);
                if (!(sts&1))   return xfFAILURE;
        }

	/* Return result */
	STR_RES (attr[VL_BC_LST0_IDX].desc.value.att_txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLabsCrvLst) {

	IGRint          axis=0, len=0, jst=1, dec=0, i;
        VStktxt         val, txt;
        VLsdlContext    *Rpt;
        VLlbData        *Dat;
        VLlbElem        *Ele;
	IGRdouble	Div;

	/* Initialize */
        if (argc > 3)	return xfARGCOUNT;
	txt[0] = '\0';

	/* Get axis (if any) */
	if (argc >   0) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Get element length index (if any) */
        if (argc > 1) {
                arglist = arglist->next;
                if ( (arglist->arg.type != VS_int) || (arglist->arg._ival < 0) )
                        return xfINVARG;
                len = arglist->arg._ival;
        }

	/* Get format & justification index (if any) */
        if (argc > 2) {
                arglist = arglist->next;
                if (arglist->arg.type != VS_int)    return xfINVARG;
                dec = arglist->arg._ival;
                if (dec < 0) {  jst = -1;       dec *= -1;      }
                if (dec > 9)    dec = 9;
        }

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;
	Div = VLgetDivisor(Rpt);

	/* Build output string */
	for ( i=0; i<Dat->numA; i++) {
		sprintf ( val, "%.*f", dec, Ele[i*Dat->numB].pntA[axis] / Div );
		sprintf ( txt, "%s%*s", txt, jst * len, val);
	}

	/* Return result */
	STR_RES (txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLabsPlnLst) {

	IGRint          axis=0, len=0, jst=1, dec=0, i;
        VStktxt         val, txt;
        VLsdlContext    *Rpt;
        VLlbData        *Dat;
        VLlbElem        *Ele;
	IGRdouble	Div;

	/* Initialize */
        if (argc > 3)	return xfARGCOUNT;
	txt[0] = '\0';

	/* Get axis (if any) */
	if (argc >   0) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Get element length index (if any) */
        if (argc > 1) {
                arglist = arglist->next;
                if ( (arglist->arg.type != VS_int) || (arglist->arg._ival < 0) )
                        return xfINVARG;
                len = arglist->arg._ival;
        }

	/* Get format & justification index (if any) */
        if (argc > 2) {
                arglist = arglist->next;
                if (arglist->arg.type != VS_int)    return xfINVARG;
                dec = arglist->arg._ival;
                if (dec < 0) {  jst = -1;       dec *= -1;      }
                if (dec > 9)    dec = 9;
        }

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;
	Div = VLgetDivisor(Rpt);

	/* Build output string */
	for ( i=0; i<Dat->numB; i++) {
		sprintf ( val, "%.*f", dec, Ele[i].pntB[axis] / Div );
		sprintf ( txt, "%s%*s", txt, jst * len, val);
	}

	/* Return result */
	STR_RES (txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLrelIntLst) {

		IGRint          curB=0, i, j, idx, nint;
                IGRint          axis=0, len=0, jst=1, dec=0;
		IGRlong		sts;
                VStktxt         val[4], blk;
                VLsdlContext    *Rpt;
                VLlbData        *Dat;
                VLlbElem        *Ele;
                VLlbCross       Cross[4];
        struct  ACrg_coll       attr[VL_BC_ATTR_MAX];
		IGRdouble	Div;

	/* Initialize */
        if (argc > 3)	return xfARGCOUNT;
	blk[0] = '\0';

	/* Get axis (if any) */
	if (argc >   0) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Get element length index (if any) */
        if (argc > 1) {
                arglist = arglist->next;
                if ( (arglist->arg.type != VS_int) || (arglist->arg._ival < 0) )
                        return xfINVARG;
                len = arglist->arg._ival;
                for ( i=0; i<len; i++)  blk[i] = ' ';
                blk[len] = '\0';
        }

	/* Get format & justification index (if any) */
        if (argc > 2) {
                arglist = arglist->next;
                if (arglist->arg.type != VS_int)    return xfINVARG;
                dec = arglist->arg._ival;
                if (dec < 0) {  jst = -1;       dec *= -1;      }
                if (dec > 9)    dec = 9;
        }

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;

	/* Build ACrg_collection */
        VLfillCrossAttr (attr);
	Div = VLgetDivisor (Rpt);

	/* Retrieve current pointer */
        if (Dat->curB != -1)    curB = Dat->curB;

	/* Build output string */
        for ( i=0; i<Dat->numA; i++) {

                idx  = i * Dat->numB + curB;
                nint = Ele[idx].nint;

                val[0][0] = val[1][0] = val[2][0] = val[3][0] = '\0';
                switch (nint) {
                        case 0: strcpy ( val[0], blk);
                        case 1: strcpy ( val[1], blk);
                        case 2: strcpy ( val[2], blk);
                        case 3: strcpy ( val[3], blk);
                                break;
                }

                Cross[0].val = Cross[1].val = Cross[2].val = Cross[3].val = 0.0;
                for ( j=0; j<nint; j++) {
                        Cross[j].idx = j;
                        Cross[j].val = (Ele[idx].Pint[j][axis]
				     -  Dat->orig[axis]) / Div;
                }
                qsort ( Cross, nint, sizeof(VLlbCross), VLsortCrossing);
                VLelimInChtTol ( &nint, Cross, BSTOLCHRDHT);

                if ( nint > (IGRint) attr[VL_BC_NUMB_IDX].desc.value.att_exp )
                        attr[VL_BC_NUMB_IDX].desc.value.att_exp=(IGRdouble)nint;

                switch (nint) {
                        case 4: sprintf ( val[3], "%.*f", dec, Cross[3].val );
                        case 3: sprintf ( val[2], "%.*f", dec, Cross[2].val );
                        case 2: sprintf ( val[1], "%.*f", dec, Cross[1].val );
                        case 1: sprintf ( val[0], "%.*f", dec, Cross[0].val );
                                break;
                }

                sprintf ( attr[VL_BC_LST0_IDX].desc.value.att_txt, "%s%*s",
                          attr[VL_BC_LST0_IDX].desc.value.att_txt,
                          jst * len, val[0] );

                sprintf ( attr[VL_BC_LST1_IDX].desc.value.att_txt, "%s%*s",
                          attr[VL_BC_LST1_IDX].desc.value.att_txt,
                          jst * len, val[1] );

                sprintf ( attr[VL_BC_LST2_IDX].desc.value.att_txt, "%s%*s",
                          attr[VL_BC_LST2_IDX].desc.value.att_txt,
                          jst * len, val[2] );

                sprintf ( attr[VL_BC_LST3_IDX].desc.value.att_txt, "%s%*s",
                          attr[VL_BC_LST3_IDX].desc.value.att_txt,
                          jst * len, val[3] );
        }

        /* Set value in context */
        for ( i=0; i<VL_BC_ATTR_MAX; i++) {
                sts = vl$sdlSetAttr ( ctx     = Rpt,
                                      attr    = &attr[i],
                                      colType = VLSDL_SYST_COL);
                if (!(sts&1))   return xfFAILURE;
        }

        /* Return result */
        STR_RES (attr[VL_BC_LST0_IDX].desc.value.att_txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLrelCrvLst) {

	IGRint          axis=0, len=0, jst=1, dec=0, i;
        VStktxt         val, txt;
        VLsdlContext    *Rpt;
        VLlbData        *Dat;
        VLlbElem        *Ele;
	IGRdouble	Div;

	/* Initialize */
        if (argc > 3)	return xfARGCOUNT;
	txt[0] = '\0';

	/* Get axis (if any) */
	if (argc >   0) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Get element length index (if any) */
        if (argc > 1) {
                arglist = arglist->next;
                if ( (arglist->arg.type != VS_int) || (arglist->arg._ival < 0) )
                        return xfINVARG;
                len = arglist->arg._ival;
        }

	/* Get format & justification index (if any) */
        if (argc > 2) {
                arglist = arglist->next;
                if (arglist->arg.type != VS_int)    return xfINVARG;
                dec = arglist->arg._ival;
                if (dec < 0) {  jst = -1;       dec *= -1;      }
                if (dec > 9)    dec = 9;
        }

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;
	Div = VLgetDivisor (Rpt);

	/* Build output string */
	for ( i=0; i<Dat->numA; i++) {
		sprintf ( val, "%.*f", dec,
			  (Ele[i * Dat->numB].pntA[axis]
			  - Dat->orig[axis]) / Div );
		sprintf ( txt, "%s%*s", txt, jst * len, val);
	}

	/* Return result */
	STR_RES (txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLrelPlnLst) {

	IGRint          axis=0, len=0, jst=1, dec=0, i;
        VStktxt         val, txt;
        VLsdlContext    *Rpt;
        VLlbData        *Dat;
        VLlbElem        *Ele;
	IGRdouble	Div;

	/* Initialize */
        if (argc > 3)	return xfARGCOUNT;
	txt[0] = '\0';

	/* Get axis (if any) */
	if (argc >   0) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Get element length index (if any) */
        if (argc > 1) {
                arglist = arglist->next;
                if ( (arglist->arg.type != VS_int) || (arglist->arg._ival < 0) )
                        return xfINVARG;
                len = arglist->arg._ival;
        }

	/* Get format & justification index (if any) */
        if (argc > 2) {
                arglist = arglist->next;
                if (arglist->arg.type != VS_int)    return xfINVARG;
                dec = arglist->arg._ival;
                if (dec < 0) {  jst = -1;       dec *= -1;      }
                if (dec > 9)    dec = 9;
        }

	/* Retrieve context and data */
        Rpt = (VLsdlContext *) inp->appData;
        Dat = (VLlbData *)     Rpt->stateArgs;
        Ele = (VLlbElem *)     Dat->elem;
	Div = VLgetDivisor (Rpt);

	/* Build output string */
	for ( i=0; i<Dat->numB; i++) {
		sprintf ( val, "%.*f", dec,
			  (Ele[i].pntB[axis] - Dat->orig[axis]) / Div );
		sprintf ( txt, "%s%*s", txt, jst * len, val);
	}

	/* Return result */
	STR_RES (txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLabsStaVal) {

		IGRint		axis=0, curA=0, curB=0, idx=0;
		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		IGRboolean	flag=FALSE;
		IGRdouble	value=0.0;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;

	/* Retrieve current pointer */
	if (Dat->curA != -1)    curA = Dat->curA;
        if (Dat->curB != -1)    curB = Dat->curB;
	idx = curA * Dat->numB + curB;
	if (  (Dat->elem[idx].Pext[0][0] != 0.0)
	   || (Dat->elem[idx].Pext[0][1] != 0.0)
	   || (Dat->elem[idx].Pext[0][2] != 0.0) )	flag = TRUE;
	value = Dat->elem[idx].Pext[0][axis] / VLgetDivisor(Rpt);

	/* Ouput value */
	switch (Dat->elem[idx].next) {
		case 0:	STR_RES ("-");
			break;
		case 1: switch (flag) {
				case TRUE:	DBL_RES (value);
						break;
				case FALSE:	STR_RES ("-");
						break;
			}
		case 2:	DBL_RES (value);
			break;
	}

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLrelStaVal) {

		IGRint		axis=0, curA=0, curB=0, idx=0;
		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		IGRboolean	flag=FALSE;
		IGRdouble	value=0.0;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;

	/* Retrieve current pointer */
	if (Dat->curA != -1)    curA = Dat->curA;
        if (Dat->curB != -1)    curB = Dat->curB;
	idx = curA * Dat->numB + curB;
	if (  (Dat->elem[idx].Pext[0][0] != 0.0)
           || (Dat->elem[idx].Pext[0][1] != 0.0)
           || (Dat->elem[idx].Pext[0][2] != 0.0) )      flag = TRUE;
        value = ( Dat->elem[idx].Pext[0][axis] - Dat->orig[axis] );
	value /= VLgetDivisor(Rpt);

        /* Ouput value */
        switch (Dat->elem[idx].next) {
                case 0: STR_RES ("-");
                        break;
                case 1: switch (flag) {
                                case TRUE:      DBL_RES (value);
                                                break;
                                case FALSE:     STR_RES ("-");
                                                break;
                        }
                case 2: DBL_RES (value);
                        break;
        }

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLabsEndVal) {

		IGRint		axis=0, curA=0, curB=0, idx=0;
		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		IGRboolean	flag=FALSE;
		IGRdouble	value=0.0;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;

	/* Retrieve current pointer */
	if (Dat->curA != -1)    curA = Dat->curA;
        if (Dat->curB != -1)    curB = Dat->curB;
	idx = curA * Dat->numB + curB;
	if (  (Dat->elem[idx].Pext[1][0] != 0.0)
           || (Dat->elem[idx].Pext[1][1] != 0.0)
           || (Dat->elem[idx].Pext[1][2] != 0.0) )      flag = TRUE;
        value = Dat->elem[idx].Pext[1][axis] / VLgetDivisor(Rpt);

        /* Ouput value */
        switch (Dat->elem[idx].next) {
                case 0: STR_RES ("-");
                        break;
                case 1: switch (flag) {
                                case TRUE:      DBL_RES (value);
                                                break;
                                case FALSE:     STR_RES ("-");
                                                break;
                        }
                case 2: DBL_RES (value);
                        break;
        }

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLrelEndVal) {

		IGRint		axis=0, curA=0, curB=0, idx=0;
		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		IGRboolean	flag=FALSE;
		IGRdouble	value=0.0;

	/* Verify number of arguments */
        if (argc > 1)	return xfARGCOUNT;

	/* Get axis (if any) */
	if (argc ==  1) axis = VLdecodeAxis (arglist);
	if (axis == -1)	return xfINVARG;

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;

	/* Retrieve current pointer */
	if (Dat->curA != -1)    curA = Dat->curA;
        if (Dat->curB != -1)    curB = Dat->curB;
	idx = curA * Dat->numB + curB;
	if (  (Dat->elem[idx].Pext[1][0] != 0.0)
           || (Dat->elem[idx].Pext[1][1] != 0.0)
           || (Dat->elem[idx].Pext[1][2] != 0.0) )      flag = TRUE;
	value = ( Dat->elem[idx].Pext[1][axis] - Dat->orig[axis] );
        value /= VLgetDivisor(Rpt);

        /* Ouput value */
        switch (Dat->elem[idx].next) {
                case 0: STR_RES ("-");
                        break;
                case 1: switch (flag) {
                                case TRUE:      DBL_RES (value);
                                                break;
                                case FALSE:     STR_RES ("-");
                                                break;
                        }
                case 2: DBL_RES (value);
                        break;
        }

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLneaStaNam) {

		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		VStktxt		txt;
		IGRdouble	val;

	/* Initialize */
        if (argc > 0)	return xfARGCOUNT;

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;

	/* Get nearest displacement station */
	VLnearestDispStation ( Dat, txt, &val);

	STR_RES (txt);

	return xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getLneaStaDst) {

		VLsdlContext	*Rpt;
		VLlbData	*Dat;
		VStktxt		txt;
		IGRdouble	val;

	/* Initialize */
        if (argc > 0)	return xfARGCOUNT;

	/* Retrieve context and data */
	Rpt = (VLsdlContext *) inp->appData;
	Dat = (VLlbData *)     Rpt->stateArgs;

	/* Get nearest displacement station */
	VLnearestDispStation ( Dat, txt, &val);

	if (val >= 0.0)	{ DBL_RES (val / VLgetDivisor(Rpt)); return xfSUCCESS; }
	else		{ STR_RES ("-"); return xfSUCCESS; }
}
/* ************************************************************************** */

end implementation VLabstract;
