class implementation VLabstract;

/* ************************************************************************** */
/*	LOFT reporting in ASCII file tools functions.			      */
/*	Marc Fournier (COC shipbuilding, Rungis)			      */
/*	01-AUG-1994	:	creation				      */
/*	02-AUG-1994	:	enhancement				      */
/*	19-MAY-2000	:	VLsteelBand				      */
/* ************************************************************************** */

#include	<stdio.h>
#include	<string.h>
#include	"vlprototype.h"
#include	"AS_status.h"
#include	"bserr.h"
#include        "VDobj.h"
#include        "vsmiscmacros.h"
#include	"bsparameters.h"
#include        "vlsband.h"
#include	"vlstifbend.h"
#include	"vlmiscmacros.h"

#include	"bsdotp.h"
#include	"bslenvec.h"
#include	"bsmkvec.h"
#include	"bspj_pt_cv.h"
#include	"bsxtractpar.h"

extern	IGRdouble	fabs();

from	expression	import	NDgive_value;
from	VLjunction	import	VLreturn_collect;
from	ACrg_collect	import	ACget_named_attribute;

/*	#define	TRACE	*/

/* ************************************************************************** */
IGRdouble VLgetFootValue ( oObject, Footname )

        struct  GRid            *oObject;       /*I Object to be queried      */
                IGRchar         Footname[];     /*I Name of the foot          */

{
                IGRint          sts;
                IGRlong         msg;
        struct  GRid            foot;
                IGRdouble       value=0.0;

        /*c Get foot id */
#ifdef TRACE
printf( "vl$return_foot(%s) on (%d|%d)\n",
	Footname, Object->osnum, Object->objid );
#endif
	sts = vl$return_foot ( msg     = &msg,
			       name    = Footname,
                               objId   = oObject,
                               footId  = &foot );
        as$status ( sts    = sts,
                    msg    = "vl$return_foot",
                    test   = (!(sts & 0x00000001 & msg)),
                    action = GOTO_VALUE,
                    value  = wrapup );

        /*c Get foot value */
        sts = om$send ( msg = message expression.NDgive_value (&value),
                        senderid = NULL_OBJID,
                        targetid = foot.objid,
                        targetos = foot.osnum );
        as$status ( sts    = sts,
                    msg    = "expression.NDgive_value",
                    action = GOTO_VALUE,
                    value  = wrapup );

wrapup :
        return (value);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLgetHeights ( Env, Crv, spt, ept, step, dir, ort, crv, nhei, Hei, msg)

	struct	GRmd_env	*Env;	/*I	Environment info	*/
	struct	GRid		*Crv;	/*I	Curve object		*/
		IGRdouble	*spt;	/*I	Start point		*/
		IGRdouble	*ept;	/*I	End point		*/
		IGRdouble	step;	/*I	Step value		*/
		IGRdouble	*dir;	/*I	X direction		*/
		IGRdouble	*ort;	/*I	Y direction		*/
	struct	IGRbsp_curve	*crv;	/*I	Curve geometry		*/
		IGRint		*nhei;	/*O	Heights number		*/
		IGRdouble	*Hei[];	/*O	Heights array		*/
		IGRlong		*msg;	/*O	Completion code		*/
{
		IGRint		sts=OM_S_SUCCESS, i, j, idx=0;
		IGRdouble	len=0.0, cht=0.0, *par, Slen, Elen;
		IGRvector	vec, Svec, Evec;
		BSrc		rc;
		IGRpoint	Spt, Ept, *pnt, cpt;
		IGRlong		num;

	/* Initialize */
	*nhei = 0;
	*Hei  = NULL;
	if (step == 0.0) {	printf( "Step value is null !!!\n");
				*msg = MSFAIL;	goto wrapup; }
	BSxtractpar ( &rc, BSTOLCHRDHT, &cht);
        if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSxtractpar()\n");
                            goto wrapup; }
	if (cht > step / 2.0) {	printf( "Step value < 2 * cht !!!\n");
				*msg = MSFAIL;	goto wrapup; }

	/* Evaluate number of heights (max) */
	par = NULL;
	pnt = NULL;
	BSmkvec ( &rc, vec, spt, ept);
        if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSmkvec()\n");
                            goto wrapup; }
	len = BSdotp ( &rc, dir, vec);
        if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSdotp()\n");
                            goto wrapup; }
	*nhei = 3 + (IGRint) (len / step);
	*Hei = om$calloc ( num = 2 * (*nhei), structure = IGRdouble);

	/* Evaluate end vectors of curve */
	sts = VLendpts ( msg, Crv, Env, Spt, Ept);
        as$status ( sts    = sts,
                    msg    = "VLendpts()",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	BSmkvec ( &rc, Svec, spt, Spt);
        if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSmkvec()\n");
                            goto wrapup; }
	Slen = BSdotp ( &rc, dir, Svec);
        if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSdotp()\n");
                            goto wrapup; }
	BSmkvec ( &rc, Evec, spt, Ept);
        if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSmkvec()\n");
                            goto wrapup; }
	Elen = BSdotp ( &rc, dir, Evec);
        if (rc != BSSUCC) { *msg = MSFAIL;
                            printf( "Error in BSdotp()\n");
                            goto wrapup; }
	if (Elen < Slen) {
		len  = Elen;
		Elen = Slen;
		Slen = len;
		dblcpy ( vec,  Evec, 3);
		dblcpy ( Evec, Svec, 3);
		dblcpy ( Svec, vec,  3);
	}
#ifdef TRACE
printf( "Start length = %g, End length = %g\n", Slen, Elen);
#endif
	/* Evaluate Heights */
	for ( i=0; i<(*nhei) - 2; i++) {

		/* Start point of curve case */
		if ( (Slen > i*step + cht) && (Slen < (i+1)*step - cht) ) {
			(*Hei)[2*idx]   = Slen;
			(*Hei)[2*idx+1] = BSdotp ( &rc, ort, Svec);;
        		if (rc != BSSUCC) { *msg = MSFAIL;
                            		    printf( "Error in BSdotp()\n");
                            		    goto wrapup; }
			idx++;
		}

		/* Middle point of curve case */
		for ( j=0; j<3; j++)    cpt[j] = spt[j] + i * step * dir[j];
                if (pnt) {      om$dealloc (ptr = pnt); pnt = NULL;     }
                if (par) {      om$dealloc (ptr = par); par = NULL;     }
                BSpj_pt_cv ( crv, cpt, ort, &num, &pnt, &par, &rc);
                if (rc != BSSUCC) { *msg = MSFAIL;
                                    printf( "Error in BSpj_pt_cv()\n");
                                    goto wrapup; }
                if (num > 0) {
                        BSmkvec ( &rc, vec, cpt, pnt[0]);
                        if (rc != BSSUCC) { *msg = MSFAIL;
                                            printf( "Error in BSmkvec()\n");
                                            goto wrapup; }
			(*Hei)[2*idx]   = i * step;
                        (*Hei)[2*idx+1] = BSlenvec ( &rc, vec);
                        if (rc != BSSUCC) { *msg = MSFAIL;
                                            printf( "Error in BSlenvec()\n");
                                            goto wrapup; }
			idx++;
                }

		/* End point of curve case */
		if ( (Elen > i*step + cht) && (Elen < (i+1)*step - cht) ) {
			(*Hei)[2*idx]   = Elen;
			(*Hei)[2*idx+1] = BSdotp ( &rc, ort, Evec);;
        		if (rc != BSSUCC) { *msg = MSFAIL;
                            		    printf( "Error in BSdotp()\n");
                            		    goto wrapup; }
			idx++;
		}
	}

	*nhei = idx;

wrapup:
	if (pnt) {      om$dealloc (ptr = pnt); pnt = NULL;     }
        if (par) {      om$dealloc (ptr = par); par = NULL;     }
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLextractBendedLines (	Occ, nlin, Lin, msg)

	struct	GRobj_env	*Occ;	/*I	Occurence of VLstifBend	*/
		IGRint		*nlin;	/*O	Bended lines number	*/
	struct	GRobj_env	*Lin[];	/*O	Bended lines array	*/
		IGRlong		*msg;	/*O	Completion code		*/
{
		IGRint		sts=OM_S_SUCCESS, num=0, i;
		IGRchar		name[DI_PATH_MAX];

	/* Initialize */
	*nlin = 0;
	*Lin  = NULL;

	/* Find number of bended lines */
	sts = om$send ( msg = message GRowner.GRget_number_components
                                                ( msg, &num ),
			senderid = NULL_OBJID,
			targetid = Occ->obj_id.objid,
			targetos = Occ->obj_id.osnum );
	as$status ( sts    = sts,
		    msg    = "GRowner.GRget_number_components",
		    test   = (!(sts & 0x00000001 & (*msg))),
		    action = GOTO_VALUE,
		    value  = wrapup );
	*nlin = (num - MACRO_SB_FFEET) / 2;
	if ( (*nlin) < 1 ) {	*nlin = 0;	goto wrapup;	}
	else	*Lin = om$calloc ( num	     = *nlin,
				   structure = struct GRobj_env );

	/* Get the bended lines */
	for ( i=0; i<*nlin; i++) {
		name[0] = '\0';
		sprintf ( name, "%s%d", NAM_SBF_VARF, (*nlin)+i+1);
		sts = vl$return_foot ( msg     = msg,
				       name    = name,
	                               objId   = &Occ->obj_id,
				       objEnv  = &Occ->mod_env,
	                               footId  = &(*Lin)[i].obj_id,
				       footEnv = &(*Lin)[i].mod_env );
		as$status ( sts    = sts,
			    msg    = "vl$return_foot",
			    test   = (!(sts & 0x00000001 & (*msg))),
			    action = GOTO_VALUE,
			    value  = wrapup );
	}

wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLgetSteelBandInformation ( Occ, band, unit, 
				    desc, jobN, stock, endstock, msg )

struct	GRobj_env	*Occ;		/*I	Occurence of VLsteelBand      */
	IGRchar		*band;		/*O	Band number		      */
	IGRchar		*unit;		/*O	Unit number		      */
	IGRchar		*desc;		/*O	Description		      */
	IGRchar		*jobN;		/*O	Job number		      */
	IGRdouble	*stock;		/*O	Stock		              */
	IGRdouble	*endstock;      /*O     End Stock                     */
	IGRlong		*msg;		/*O	Completion code		      */
{
	IGRint			sts=OM_S_SUCCESS;
	struct GRobj_env	boxOE;
	struct	ACrg_coll	test;

	/* Initialize */
	band[0]	= '\0';
	unit[0]	= '\0';
	desc[0]	= '\0';
	jobN[0]	= '\0';

        vdobj$GetTemplate( objID      = &Occ->obj_id,
                           nth        = 1,
                           templateOE = &boxOE );

	/* Get ACrg_coll sub-foot data */
	strcpy ( test.name, NAM_SB_BANDNO );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, &test ),
			senderid = NULL_OBJID,
			targetid = boxOE._objid,
			targetos = boxOE._osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(BandNumber)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	strcpy ( band, test.desc.value.att_txt );

	strcpy ( test.name, NAM_SB_UNITNO );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, &test ),
			senderid = NULL_OBJID,
			targetid = boxOE._objid,
			targetos = boxOE._osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(UnitNumber)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	strcpy ( unit, test.desc.value.att_txt );

	strcpy ( test.name, NAM_SB_JOBDESC );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, &test ),
			senderid = NULL_OBJID,
			targetid = boxOE._objid,
			targetos = boxOE._osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(JobDescription)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	strcpy ( desc, test.desc.value.att_txt );

	strcpy ( test.name, NAM_SB_JOBNO );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, &test ),
			senderid = NULL_OBJID,
			targetid = boxOE._objid,
			targetos = boxOE._osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(JobNumber)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	strcpy ( jobN, test.desc.value.att_txt );

        strcpy ( test.name, NAM_SB_STOCK );
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        ( msg, &test ),
                        senderid = NULL_OBJID,
                        targetid = boxOE._objid,
                        targetos = boxOE._osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(Stock)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*stock = test.desc.value.att_exp;

        strcpy ( test.name, NAM_SB_ENDSTOCK );
        sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
                                        ( msg, &test ),
                        senderid = NULL_OBJID,
                        targetid = boxOE._objid,
                        targetos = boxOE._osnum );
        as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(EndStock)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
        *endstock = test.desc.value.att_exp;
wrapup:
	return (sts);
}
/* ************************************************************************** */

/* ************************************************************************** */
IGRlong	VLgetSteelBandAttributes ( Occ, idx, index, name, distance, msg )

struct	GRobj_env	*Occ;		/*I	Occurence of VLsteelBand      */
	IGRint		idx;		/*I	0-based index in loop	      */
	IGRint		*index;		/*O	point index		      */
	IGRchar		*name;		/*O	molded curve name	      */
	IGRdouble	*distance;	/*O	distance from start	      */
	IGRlong		*msg;		/*O	Completion code		      */
{
	IGRint			sts=OM_S_SUCCESS;
	IGRchar			*p, txt[DI_PATH_MAX];
	struct	GRid		foot[2];
	struct	ACrg_coll	attr[3];
	struct	ACrg_coll	test;

	/* Initialize */
	*index		= 0;
	name[0]		= '\0';
	*distance	= 0.0;

	/* Get VLjunction at index */
	foot[0].objid = NULL_OBJID;
	sprintf ( txt, "Point%d", idx );
        sts = vl$return_foot ( msg = msg,
                               name = txt,
                               objId = &(Occ->obj_id),
                               objEnv = &(Occ->mod_env),
                               footId = &foot[0] );
	as$status ( sts    = sts,
                    msg    = "vl$return_foot",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get ACrg_coll sub-foot object */
	sts = om$send ( msg = message VLjunction.VLreturn_collect
					( msg, &foot[1] ),
			senderid = NULL_OBJID,
			targetid = foot[0].objid,
			targetos = foot[0].osnum );
	as$status ( sts    = sts,
                    msg    = "VLjunction.VLreturn_collect",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	/* Get ACrg_coll sub-foot data */
	strcpy ( test.name, "Index" );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, &test ),
			senderid = NULL_OBJID,
			targetid = foot[1].objid,
			targetos = foot[1].osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(Index)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*index	  = test.desc.value.att_exp;
	
	strcpy ( test.name, "Length" );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, &test ),
			senderid = NULL_OBJID,
			targetid = foot[1].objid,
			targetos = foot[1].osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(Length)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );
	*distance  = test.desc.value.att_exp;
	
	strcpy ( test.name, "RefLineName" );
	sts = om$send ( msg = message ACrg_collect.ACget_named_attribute
					( msg, &test ),
			senderid = NULL_OBJID,
			targetid = foot[1].objid,
			targetos = foot[1].osnum );
	as$status ( sts    = sts,
                    msg    = "ACrg_collect.AClist_attribute(MoldLineName)",
                    test   = (!(sts & 0x00000001 & (*msg))),
                    action = GOTO_VALUE,
                    value  = wrapup );

	p = strrchr(test.desc.value.att_txt, ':');

	if( p )
	    strcpy ( name, p+1 );
	else
	    strcpy ( name, test.desc.value.att_txt );

wrapup:
	return (sts);
}
/* ************************************************************************** */

end implementation VLabstract;
