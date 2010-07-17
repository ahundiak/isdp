class implementation VLabstract;

/* ************************************************************************** */
/*	LOFT reporting in ASCII file user functions used with Strudel	      */
/*	Marc Fournier (COC shipbuilding, Rungis)			      */
/*	07-JUN-1994	:	creation				      */
/*	15-MAY-2000	:	Steel Band for Avondale Shipyards.	      */
/* ************************************************************************** */

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"ACattrib.h"

#include	"vsdrwdef.h"
#include	"vsdrw.h"
#include	"vsdrwmacros.h"
#include	"vsdrwapi.h"
#include	"vsslcdef.h"

#include	"vlfloor.h"
#include	"vlpinjig.h"
#include	"vlrptdef.h"
#include	"vlsdl.h"
#include	"vlsdldef.h"
#include	"vlsdlmacros.h"

/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, print) {

	const	VSdrwArgLst	*a;
		IGRint		col=0, jst=1, dec=0, Rlen=0, Tlen=0, i=0;
		VStktxt		txt, blk;
		VLsdlContext	*Rpt;
		VLsdlText	*Txt;

	/* Verify number of arguments */
	if ( (argc <1) || (argc > 3) )	return	xfARGCOUNT;

	/* Initialize */
	txt[0] = '\0';
	a = arglist;

	/* Get the second argument : column (if any) */
	if (argc > 1) {
		a = a->next;
		if (a->arg.type != VS_int)	return xfINVARG;
		else				col = a->arg._ival;
	}

	/* Get the third argument : format & justification (if any) */
	if (argc > 2) {
		a = a->next;
		if (a->arg.type != VS_int)	return xfINVARG;
		dec = a->arg._ival;
		if(dec < 0) {	jst = -1;	dec *= -1;	}
		if (dec > 9)	dec = 9;
	}

	/* Construct the formated result */
	switch (arglist->arg.type) {
		case VS_int :
			sprintf ( txt, "%d", arglist->arg._ival);
			break;
		case VS_double :
			sprintf ( txt, "%.*f", dec, arglist->arg._dval);
			break;
		case VS_string :
			sprintf ( txt, "%s", arglist->arg._sval);
			break;
		default   :      return xfINVARG;
	}

	/* Discard invalid inputs */
	Rpt = (VLsdlContext *) inp->appData;
	Txt = &Rpt->systTxt;
	if (col < Txt->col)	return xfINVARG;

	/* Treat the first input */
	if (!Txt->ini) {
		strcpy ( Txt->txt, txt);
		Txt->col = col;
		Txt->jst = jst;
		Txt->ini = 1;
		return	xfSUCCESS;
	}

	/* Evaluate lengths */
	Rlen = strlen (Txt->row);
	Tlen = strlen (Txt->txt);

	/* Detect overflow */
	if (Tlen > col-Txt->col) {
		for ( i=0; i<col-Txt->col; i++)
			Txt->txt[i] = '*';
		Txt->txt[col-Txt->col] = '\0';
		Tlen = strlen (Txt->txt);
	}

	/* Add leading blanks to row */
	blk[0] = '\0';
	if (Txt->jst >= 0) {
		for ( i=0; i<col-Rlen-Tlen; i++)	blk[i] = ' ';
		blk[col-Rlen-Tlen] = '\0';
	}
	else {	for ( i=0; i<Txt->col-Rlen; i++)	blk[i] = ' ';
		blk[Txt->col-Rlen] = '\0';
	}

	/* Add new text to row */
	sprintf ( Txt->row, "%s%s%s",
		  Txt->row, blk, Txt->txt );

	/* Save results */
	strcpy ( Txt->txt, txt);
	Txt->col = col;
	Txt->jst = jst;

	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, skip ) {

	IGRint		i, empty=0;
	VSxfRC		sts;
	VLsdlContext	*Rpt;
	VLsdlText	*Txt;

	/* Print last row */
	Rpt = (VLsdlContext *) inp->appData;
	sts = VLsdlSkip (Rpt);

	/* Print blank lines */
	if (argc == 1) {
                if (arglist->arg.type != VS_int)        goto wrapup;
                else    empty = arglist->arg._ival;
        }

wrapup:

	Txt = &Rpt->systTxt;
	if (Txt->out) {
                /* Print result in ASCII file */
                for ( i=0; i<empty; i++) fprintf( Txt->out, "%c", '\n');
        }
        else {  /* Write an Apfel-Strudel error */
                VSdrwPrintf ( "!!! Output file not open");
                sts = xfFAILURE;
        }

	return (sts);
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBidx) {

		VLsdlContext	*Rpt;
	struct	VLsortTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct VLsortTpl *) Rpt->stateArgs;
	if (Val)	INT_RES ( Val->idx );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBnam) {

		VLsdlContext	*Rpt;
	struct	VLsortTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct VLsortTpl *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->name );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBxan) {

		VLsdlContext	*Rpt;
	struct	VLsortTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct VLsortTpl *) Rpt->stateArgs;
	DBL_RES ( Val->x );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getByan) {

		VLsdlContext	*Rpt;
	struct	VLsortTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct VLsortTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->y );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBzan) {

		VLsdlContext	*Rpt;
	struct	VLsortTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct VLsortTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->z );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBnum) {

		VLsdlContext	*Rpt;
	struct	VLsortTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct VLsortTpl *) Rpt->stateArgs;
	if (Val)	INT_RES ( Val->num );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBbalX) {

	VLsdlContext	*Rpt;
	VLbalBasePt	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLbalBasePt *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->balance[0] );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBbalY) {

	VLsdlContext	*Rpt;
	VLbalBasePt	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLbalBasePt *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->balance[1] );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBbalZ) {

	VLsdlContext	*Rpt;
	VLbalBasePt	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLbalBasePt *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->balance[2] );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBshiX) {

	VLsdlContext	*Rpt;
	VLbalBasePt	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLbalBasePt *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->in_ship[0] );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBshiY) {

	VLsdlContext	*Rpt;
	VLbalBasePt	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLbalBasePt *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->in_ship[1] );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getBshiZ) {

	VLsdlContext	*Rpt;
	VLbalBasePt	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLbalBasePt *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->in_ship[2] );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getPnam) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	STR_RES ( (*Val)[0].desc.value.att_txt );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getPpin) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	INT_RES ( (IGRint)(*Val)[1].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getPcrn) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	INT_RES ( (IGRint)(*Val)[2].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getCnam) {

	VLsdlContext	*Rpt;
	VLpinCorn	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpinCorn *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->cp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getCxpt) {

	VLsdlContext	*Rpt;
	VLpinCorn	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpinCorn *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->dx );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getCypt) {

	VLsdlContext	*Rpt;
	VLpinCorn	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpinCorn *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->dy );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getChei) {

	VLsdlContext	*Rpt;
	VLpinCorn	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpinCorn *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->dz );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getCpin) {

	VLsdlContext	*Rpt;
	VLpinCorn	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpinCorn *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->pn );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJcol) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val) INT_RES ( (IGRint)(*Val)[3+IDX_PB_COL].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJlin) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val) INT_RES ( (IGRint)(*Val)[3+IDX_PB_LIN].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJxpt) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	DBL_RES ( (*Val)[3+IDX_PB_XPT].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJypt) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	DBL_RES ( (*Val)[3+IDX_PB_YPT].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJzpt) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	DBL_RES ( (*Val)[3+IDX_PB_ZPT].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJhei) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	DBL_RES ( (*Val)[3+IDX_PB_HEI].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJang) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	DBL_RES ( (*Val)[3+IDX_PB_ANG].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJidx) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val) INT_RES ( (IGRint)(*Val)[3+IDX_PB_IDX].desc.value.att_exp );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getJnam) {

		VLsdlContext	*Rpt;
	struct	ACrg_coll	**Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (struct ACrg_coll **) Rpt->stateArgs;
	if (*Val)	STR_RES ( (*Val)[3+IDX_PB_NAM].desc.value.att_txt );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getTnam) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->nam );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getTcht) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->cht );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getTang) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->ang );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getTlea) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->lea );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getThei) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->hei );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getSnam) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->nam );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getSfra) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->frm );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getScht) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->cht );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getShei) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->hei );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, setHstp) {

	struct	ACrg_coll	attr;
		IGRlong		sts;

	CHECK_ARGCOUNT (1);

	strcpy ( attr.name, VLRPT_HEIGHT_STEP);
	attr.desc.type = AC_ATTRIB_DOUBLE;
	attr.desc.value.att_exp = VSdrwDblVal( &arglist->arg );

	sts = vl$sdlSetAttr ( ctx     = (VLsdlContext *) inp->appData,
                              attr    = &attr,
			      colType = VLSDL_SYST_COL );
	if( ! (sts&1))  return xfFAILURE;

	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getHocc) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->nam );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getHsub) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->frm );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getHstp) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->cht );
	return	xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getHhei) {

		VLsdlContext	*Rpt;
		VLpltTpl	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLpltTpl *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->hei );
	return	xfSUCCESS;
}
/* ************************************************************************** */

#argsused
IMPLEMENT_FUNCTION ( VL, getU) {
VLsdlContext    *Rpt;
struct  VLStrechVal       *Val;

  Rpt = (VLsdlContext *) inp->appData;
  Val = (struct VLStrechVal *) Rpt->stateArgs;
  if (Val)        INT_RES ( Val->u );
  return  xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getV) {
VLsdlContext    *Rpt;
struct  VLStrechVal       *Val;

  Rpt = (VLsdlContext *) inp->appData;
  Val = (struct VLStrechVal *) Rpt->stateArgs;
  if (Val)        INT_RES ( Val->v );
  return  xfSUCCESS;
}
/* ************************************************************************** */
#argsused
IMPLEMENT_FUNCTION ( VL, getStrVal) {
VLsdlContext    *Rpt;
struct  VLStrechVal       *Val;

  Rpt = (VLsdlContext *) inp->appData;
  Val = (struct VLStrechVal *) Rpt->stateArgs;
  if (Val)        DBL_RES ( Val->val[Val->num_val] );
  (Val->num_val)++;
  return  xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getChamf) {

	IGRint	i;

	VLgetChamfId ( DRW_elmId, &i);

	INT_RES(i);

	return  xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBband) {

	VLsdlContext	*Rpt;
	VLsteelBandInfo	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLsteelBandInfo *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->band );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBunit) {

	VLsdlContext	*Rpt;
	VLsteelBandInfo	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLsteelBandInfo *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->unit );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBdesc) {

	VLsdlContext	*Rpt;
	VLsteelBandInfo	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLsteelBandInfo *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->desc );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBjobN) {

	VLsdlContext	*Rpt;
	VLsteelBandInfo	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLsteelBandInfo *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->jobN );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBnumP) {

	VLsdlContext	*Rpt;
	VLsteelBandInfo	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLsteelBandInfo *) Rpt->stateArgs;
	if (Val)	INT_RES ( Val->numP );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBidx) {

	VLsdlContext	*Rpt;
	VLsteelBandData	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLsteelBandData *) Rpt->stateArgs;
	if (Val)	INT_RES ( Val->idx );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBnam) {

	VLsdlContext	*Rpt;
	VLsteelBandData	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLsteelBandData *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->nam );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBdst) {

	VLsdlContext	*Rpt;
	VLsteelBandData	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLsteelBandData *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->dst );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBstk) {

        VLsdlContext    *Rpt;
        VLsteelBandInfo *Val;

        Rpt = (VLsdlContext *) inp->appData;
        Val = (VLsteelBandInfo *) Rpt->stateArgs;
        if (Val)        DBL_RES ( Val->stock );
        return  xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getSBEndstk) {

        VLsdlContext    *Rpt;
        VLsteelBandInfo *Val;

        Rpt = (VLsdlContext *) inp->appData;
        Val = (VLsteelBandInfo *) Rpt->stateArgs;
        if (Val)        DBL_RES ( Val->endstock );
        return  xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getKLunit) {

	VLsdlContext	*Rpt;
	VLkeyLineInfo	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLkeyLineInfo *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->unit );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getKLjobN) {

	VLsdlContext	*Rpt;
	VLkeyLineInfo	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLkeyLineInfo *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->jobN );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getKLpro) {

	VLsdlContext	*Rpt;
	VLkeyLineData	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLkeyLineData *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->pro );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getKLlin) {

	VLsdlContext	*Rpt;
	VLkeyLineData	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLkeyLineData *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->lin );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getKLnam) {

	VLsdlContext	*Rpt;
	VLkeyLineData	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLkeyLineData *) Rpt->stateArgs;
	if (Val)	STR_RES ( Val->nam );
	return	xfSUCCESS;
}
/* ************************************************************************** */
IMPLEMENT_FUNCTION ( VL, getKLdst) {

	VLsdlContext	*Rpt;
	VLkeyLineData	*Val;

	Rpt = (VLsdlContext *) inp->appData;
	Val = (VLkeyLineData *) Rpt->stateArgs;
	if (Val)	DBL_RES ( Val->dst );
	return	xfSUCCESS;
}
/* ************************************************************************** */

end implementation VLabstract;
