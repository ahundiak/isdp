/* $Id: VSfndendinfo.I,v 1.4 2002/05/01 19:48:09 ahundiak Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsmisc/VSfndendinfo.I
 *
 * Description:
 *		The file has the function go get the Structural Selector
 *		information from the end_treatments macros. AVD has output
 *		data embedded inside the endcuts macros on beams.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSfndendinfo.I,v $
 *	Revision 1.4  2002/05/01 19:48:09  ahundiak
 *	ah
 *	
 *	Revision 1.3  2001/03/01 20:13:41  ad
 *	*** empty log message ***
 *	
 *	Revision 1.2  2001/01/16 23:31:02  ramarao
 *	*** empty log message ***
 *	
# Revision 1.2  2000/06/08  16:45:56  pinnacle
# Replaced: struct/vsmisc/VSfndendinfo.I for:  by rchennup for Service Pack
#
# Revision 1.1  2000/04/10  16:38:06  pinnacle
# initial revision
#
# Revision 1.2  1998/05/11  19:31:02  pinnacle
# TR179603965
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1998/03/26  21:32:44  pinnacle
# Replaced: vsmisc/VSfndendinfo.I for:  by azuurhou for struct
#
# Revision 1.2  1998/03/26  21:15:42  pinnacle
# Replaced: vsmisc/VSfndendinfo.I for:  by azuurhou for struct
#
# Revision 1.1  1997/05/08  14:03:58  pinnacle
# Struct 250
#
# Revision 1.1  1997/02/04  20:18:02  pinnacle
# Created: vsmisc/VSfndendinfo.I by s241_int for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/02/97  adz     creation date
 * 03/26/98  adz     Move call to PPL VSstfEndInfo.u
 *    		     which retrieve the end treatment data
 * 05/11/98  ah      TR179603965 VDppl_give_info seems to be causing intermittent
 *                   core dumps, try replaciong with smart attribute call
 *                   Problem was in memory allocation, keep SA though      
 * 03/01/00   adz    Get concatenated end_treatment information per end.
 * 05/01/02   ah     Add option to get location of end treatments
 ***************************************************************************/

class implementation VSbeam ;

#include "VDsa.h"
#include "VDobj.h"
#include "VDobj2.h"

#include "bsmkvec.h"
#include "bsnorvec.h"
#include "bsdotp.h"
#include "madef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsgeommacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsophstproto.h"
#include "vsvecmxproto.h"
#include "vsvirtualinf.h"

struct VS_s_boolOpInfo {
	GRname			slcInfo ;
	char			macName[20] ;
	struct GRid		macOcc ;
	struct GRmd_env		macEnv ;
	struct GRobj_env	boolOp ;
};

typedef struct	VS_s_boolOpInfo	boolOpInfo ;

extern OMuword OPP_ACconst_class_id ;
extern OMuword OPP_VSselector_class_id ;
		
from ACpretend	import ACfind_parent ;
from ACcpx_defn	import ACgive_name ;
from GRcurve	import GRendpts, GRmidpoint ;
from GRgencs    import GRgetmatrix;

IGRlong VSgetCsStiff(   IGRlong                 *msg,
			struct GRid		*bmId,
			struct GRmd_env		*bmEnv,
                        IGRdouble               *SecMat )
{
BSrc            	rc;
IGRlong         	sts;
IGRint          	i, j;
IGRdouble       	o0[3], X0[3], Y0[3], Z0[3], v[3], o1[3], X1[3], Y1[3], 
                	Z1[3], SecMat0[16], SecMat1[16], dotp;
struct GRobj_env	stiff;

   sts = *msg = MSSUCC;

   stiff.obj_id  = *bmId;
   stiff.mod_env = *bmEnv;

   // get Section Cs at parameter 0
   sts = VSevalBeamCS( msg, &stiff, 0, VS_e_BOT_LEFT , SecMat0 );
   __CheckRC( sts, *msg, "VSevalBeamCS: End 1", wrapup );
   for( i=0; i<3; i++ )
   {
        j     = i*4;
        X0[i] = SecMat0[j];
        Y0[i] = SecMat0[j+1];
        o0[i] = SecMat0[j+3];
   }
   BScrossp( &rc, X0, Y0, Z0 );

   // get Section Cs at parameter 1
   sts = VSevalBeamCS( msg, &stiff, 1, VS_e_BOT_LEFT , SecMat1 );
   __CheckRC( sts, *msg, "VSevalBeamCS: End 2", wrapup );
   for( i=0; i<3; i++ )
   {
        j     = i*4;
        X1[i] = SecMat1[j];
        Y1[i] = SecMat1[j+1];
        o1[i] = SecMat1[j+3];
   }
   BScrossp( &rc, X1, Y1, Z1 );

   // create vector
   BSmkvec( &rc, v, o0, o1 );

   // compare vector direction
   dotp = BSdotp( &rc, v, Z0 );

   if( dotp > 0 )
   {
        // sect mat is SecMat0  Z0
        for( i=0; i<16; i++ ) SecMat[i] = SecMat0[i];
        SecMat[2]       = Z0[0];
        SecMat[6]       = Z0[1];
        SecMat[10]      = Z0[2];
   }
   else
   {
        // sect mat is SecMat1  Z1
        for( i=0; i<16; i++ ) SecMat[i] = SecMat1[i];
        SecMat[2]       = Z1[0];
        SecMat[6]       = Z1[1];
        SecMat[10]      = Z1[2];
   }
   sts = *msg = MSSUCC;

wrapup:
   return sts;
}

/*----------------------------------------------------------------------------*/
/* TR179603965 Use smart attributes to execute ppl                            */
/* 
 * If both == 3 then return 3d coords as well
 */
int VSslcEndInfo( long      	*msg, 
		  IGRboolean   	both,
		  char      	*etMacro,
		  char      	*etNear, 
		  TGRid    	*macID, 
		  TGRmd_env 	*macENV )
  
{
  
  long	      sts ;
  long        msgx;
  Tret_struct attrData ;
 
  TGRobj_env etOE;
  TGRobj_env csOE;
  IGRmatrix  mat;
  IGRchar   *p;
 
  SetProc( VSslcEndInfo ); Begin

  sts = 0;  
  *msg = MSSUCC ;
  etNear[0] = '\0' ;

  if( macID->objid == NULL_OBJID) goto wrapup ;
  
  sts = vdsa$GetStruct(objID  = macID,
		       objENV = macENV,
		       name   = "SA_PPL:VSstfEndInfo:GetEndInfo",
		       rs     = &attrData);
  if (!(sts & 1)) goto wrapup;
  
  if(attrData.type != text_type ) goto wrapup;

  if( both ) sprintf( etNear, ":%s:", etMacro );
  strcat( etNear, attrData.var.text_st.text_string );
  sts = OM_S_SUCCESS ;


  if (both != 3) goto wrapup;

  // Need coords
  etOE.obj_id = *macID;
  etOE.mod_env = *macENV;
  VDobjGetFoot(&etOE,NULL,"cs",&csOE);
  if (csOE.obj_id.objid == NULL_OBJID) goto wrapup;

  om$send(msg = message GRgencs.GRgetmatrix(&msgx,mat),
          senderid = NULL_OBJID,
          targetid = csOE.obj_id.objid,
          targetos = csOE.obj_id.osnum);

  p = etNear + strlen(etNear);
  sprintf(p,":%.1f,%.1f,%.1f",mat[3],mat[7],mat[11]);

wrapup :

  __DBGpr_str(" Result ", etNear );

  End ;
  return sts ;
}


/*----------------------------------------------------------------------------*/
/* TR179603965 Save for future reference */
#if 0
int VSOLDslcEndInfo( msg, etNear, macOcc, macEnv )

long			*msg ;
char			*etNear ;
struct	GRid		*macOcc ;
struct	GRmd_env	*macEnv ; {

	long			sts ;
	struct  ret_struct      retStr ;

	SetProc( VSOLDslcEndInfo ); Begin

	*msg = MSSUCC ;
	etNear[0] = '\0' ;

	if( IF_NULL_OBJID( macOcc->objid ) ) goto wrapup ;
	strcpy( retStr.var.text_st.text_string , "");

	sts = 
	VDppl_give_info(	"VSstfEndInfo", "main",
				macOcc, macEnv,
				NULL, NULL, 	/* No Input Arguments */
				&retStr ) ;
	__CheckRC( sts, 1, "VDppl_give_info", wrapup ) ;

	if( retStr.type == text_type ){
		strcpy( etNear, retStr.var.text_st.text_string );
	}

	sts = OM_S_SUCCESS ;

wrapup :

	__DBGpr_str(" Result ", etNear );

	End ;

	return sts ;
}
#endif

/*----------------------------------------------------------------------------*/
int VSorderEndTreatmentInfo( msg, bmId, bmEnv, nbBop, bopList,
				etNear0, etNear1, both )
long		*msg ;
struct GRid	*bmId ;
struct GRmd_env	*bmEnv ;
int		nbBop ;
boolOpInfo	*bopList;
char		*etNear0 ;
char		*etNear1 ;
IGRboolean	both ; {

	long		sts, rc ;
	double 		tNear0 = 1.,
			tNear1 = 0. ;
	int		i,
			iNear0 = -1, 
			iNear1 = -1 ;
	struct GRobj_env
			suppAxis ;
	GRrange		range ;
	IGRboolean	world = FALSE, is_reverse = FALSE ;
	struct GRparms	prjParms ;
	IGRpoint	mid,
			prjPt ;
	IGRdouble	SecMat[16], z_axis[3], spt[3], ept[3], vec[3];

	SetProc( VSorderEndTreatmentInfo ); Begin 

	etNear0[0] = '\0' ;
	etNear1[0] = '\0' ;
	
	sts = om$send(	msg	= message VSbeam.VSgetSupportAxis(
						msg, bmEnv, &suppAxis ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetSupportAxis", wrapup ) ;

	/*
	 * Have geometric entities evaluated in beam's coordinate system.
	 */
	if( bmEnv->_MATRIX_TYPE != MAIDMX ) {
		VSmulmx(	bmEnv->_MATRIX,
				suppAxis._matrix,
				suppAxis._matrix,
				&suppAxis._matrix_type ) ;
	}

	sts = VSgetCsStiff( msg, bmId, bmEnv, SecMat );
        __CheckRC( sts, *msg, "VSgetCsStiff", wrapup ) ;

	z_axis[0] = SecMat[2];
	z_axis[1] = SecMat[6];
	z_axis[2] = SecMat[10];
        __DBGpr_vec("Stiffener Z axis ", z_axis );

	is_reverse = FALSE;
        sts = om$send ( msg      = message GRcurve.GRendpts (
                                                msg,
                                                &suppAxis._matrix_type,
                                                suppAxis._matrix,
                                                spt,
                                                ept ),
                        senderid = NULL_OBJID,
                        targetid = suppAxis._objid,
                        targetos = suppAxis._osnum );
	__CheckRC( sts, *msg, "GRcurve.GRendpts", wrapup ) ;
	BSmkvec( &rc, vec, spt, ept );
	BSnorvec ( &rc,  vec ); 

	if( BSdotp ( &rc, z_axis, vec ) < 0.0 )  is_reverse = TRUE;

	for( i = 0 ; i < nbBop ; i++ ) {
		sts = om$send(	msg	= message GRgraphics.GRgetrang(
						msg,
						&bopList[i].boolOp._matrix_type,
						bopList[i].boolOp._matrix,
						&world,
						range ),
				senderid= bmId->objid,
				targetid= bopList[i].boolOp._objid,
				targetos= bopList[i].boolOp._osnum ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		VSmidpoint( range + 0, range + 3, mid ) ;

		sts = om$send(	msg	= message GRgraphics.GRptproject(
						msg,
						&suppAxis._matrix_type,
						suppAxis._matrix,
						mid,
						prjPt,
						&prjParms ),
				senderid= bmId->objid,
				targetid= suppAxis._objid,
				targetos= suppAxis._osnum ) ;
		if( !( sts & 1 & *msg ) ) continue ;

		if( is_reverse ) prjParms.u = 1.0 - prjParms.u ;

		if( prjParms.u < tNear0 ) {
			tNear0 = prjParms.u ; iNear0 = i ;
		}
		if( prjParms.u > tNear1 ) {
			tNear1 = prjParms.u ; iNear1 = i ;
		}
	}

	if( iNear0 != iNear1 ) { 
		if( iNear0 != -1 ) VSslcEndInfo(msg ,
						both, 
						bopList[iNear0].macName,
						etNear0 ,
						& bopList[iNear0].macOcc ,
						& bopList[iNear0].macEnv ) ;
		if( iNear1 != -1 ) VSslcEndInfo(msg ,
						both, 
						bopList[iNear1].macName,
						etNear1 ,
						& bopList[iNear1].macOcc ,
						& bopList[iNear1].macEnv ) ;
	} else {
		om$send(msg	= message GRcurve.GRmidpoint(
						msg,
						&suppAxis._matrix_type,
						suppAxis._matrix,
						&prjParms,
						mid ),
			senderid= bmId->objid,
			targetid= suppAxis._objid,
			targetos= suppAxis._osnum ) ;
			
		om$send(msg	= message GRgraphics.GRptproject(
						msg,
						&suppAxis._matrix_type,
						suppAxis._matrix,
						mid,
						prjPt,
						&prjParms ),
			senderid= bmId->objid,
			targetid= suppAxis._objid,
			targetos= suppAxis._osnum ) ;

		if( is_reverse ) prjParms.u = 1.0 - prjParms.u ;

		if( tNear0 <= prjParms.u ) {
		  if( iNear0 != -1 )
			VSslcEndInfo(	msg ,
					both, 
					bopList[iNear0].macName,
					etNear0 ,
					& bopList[iNear0].macOcc ,
					& bopList[iNear0].macEnv ) ;
		} else {
		  if( iNear1 != -1 )
			VSslcEndInfo(	msg ,
					both, 
					bopList[iNear1].macName,
					etNear1 ,
					& bopList[iNear1].macOcc ,
					& bopList[iNear1].macEnv ) ;
		}
	}

	wrapup:

		__DBGpr_str(" etNear0 ", etNear0 );
		__DBGpr_str(" etNear1 ", etNear1 );

		End
		return sts ;

} /* VSorderEndTreatment */
/*----------------------------------------------------------------------------*/
long VSfindEndTreatmentsInfo( msg, bmId, bmEnv, et1, et2, both )

long		*msg ;
struct GRid	*bmId ;
struct GRmd_env	*bmEnv ;
char		*et1 ;
char		*et2 ;
IGRboolean	both ; {

	/*
	 * Given a beam finds the end-treatments performed on it: actually
	 * returns the definition names of the last two macros whose solid
	 * members were used to perform boolean differences on that beam.
	 *
	 * When both is TRUE, we will return macro name and attribute info.
	 */

	long		sts ;
	VSopHistory	*history = NULL,
			*h ;
	int		o,
			nbop ;
	struct GRid	operator,
			macroOcc,
			macroDef ;
	char		*macName ;
	boolOpInfo	*bop = NULL ;

	SetProc( VSfindEndTreatmentsInfo ); Begin
	
	et1[0] = '\0' ;
	et2[0] = '\0' ;

	sts = om$send(	msg	= message VSfeature.VSgetOperationHistory(
							msg, bmEnv, &history ),
			senderid= bmId->objid,
			targetid= bmId->objid,
			targetos= bmId->osnum ) ;
	__CheckRC( sts, *msg, "VSfeature.VSgetOperationHistory", wrapup ) ;

	/*
	 * Find a max. for allocation of list of boolean operators.
	 */
	for( nbop = 0, h = history ; h ; h = h->next ) nbop++ ;
	if( ! nbop ) goto wrapup ;

	/* TR179603965 Used to just allocate nbop items
	 * Caused intermittent core dumps
	 * Think need room for multiple end treatment cutting curves
	 */
	if( !( bop = _MALLOC( nbop * VS_K_bbMAX_NOTCHES, struct VS_s_boolOpInfo ) ) ) vs$mem_fail() ;
	for( o = 0 ; o < (nbop * VS_K_bbMAX_NOTCHES) ; o++ ){
		bop[o].slcInfo[0] = '\0' ;
		bop[o].macName[0] = '\0' ;
	}

	__DBGpr_int(" Number Oper ", nbop );

	for( nbop = 0, h = history ; h  ; h = h->next ) {
		if( !( h->resultType & VS_m_DPR_generic ) ) continue ;

		for( o = 0 ; o < h->opCount ; o++ ) {
			operator.objid = h->opList[o].id ;
			operator.osnum = h->opList[o].os ;

			/*
			 * Operator is a pretend: find macro occurrence which is
			 * its parent.
			 */
			sts = om$send(
				msg	= message ACpretend. ACfind_parent(
							&macroOcc, NULL, NULL ),
				senderid= operator.objid,
				targetid= operator.objid,
				targetos= operator.osnum ) ;
			if( !( sts & 1 ) ) continue ;

			if( IF_NULL_OBJID( macroOcc.objid ) ) continue ;

			if( !vs$is_ancestry_valid(
					object = &macroOcc,
					classid = OPP_ACconst_class_id ) ) 
				continue ;
			/*
			 * This send will fail if it is not a macro occurrence
			 * but an ASsource and this failure is fine with us.
			 */
			sts = om$send(	msg	= message ACcpx.find_macro(
								&macroDef ),
					senderid= macroOcc.objid,
					targetid= macroOcc.objid,
					targetos= macroOcc.osnum ) ;
			if( !( sts & 1 ) ) continue ;

			sts = om$send(	msg	= message ACcpx_defn.ACgive_name(
								&macName ),
					senderid= macroDef.objid,
					targetid= macroDef.objid,
					targetos= macroDef.osnum ) ;
			if( !( sts & 1 ) ) continue ;

			sts = VSgetVirtualInfo(	msg,
						&operator ,
						&bop[nbop].boolOp.mod_env ,
						&bop[nbop].boolOp._grid ) ;
			if( !( sts & 1 & *msg ) ) continue ; 

			/*
			 * Have geomtries evaluated in the beam's coordinate
			 * system.
			 */
			if(  bmEnv->_MATRIX_TYPE != MAIDMX ) {
				VSmulmx( bmEnv->_MATRIX,
					 bop[nbop].boolOp._matrix,
					 bop[nbop].boolOp._matrix,
					 &bop[nbop].boolOp._matrix_type ) ;
			}
			bop[nbop].macOcc = macroOcc ;
			bop[nbop].macEnv = *bmEnv ; 
			strcpy( bop[nbop++].macName, macName );
		}
	}

	if( nbop ) {
		sts = VSorderEndTreatmentInfo(	msg, 
						bmId, 
						bmEnv, 
						nbop, 
						bop, 
						et1, 
						et2,
						both ) ;
	}

	wrapup :
		_FREE( bop );
		VSfreeOpHistory( history ) ;

		End
	
		return sts ;

} /* VSfindEndTreatments */
/*----------------------------------------------------------------------------*/

end implementation VSbeam ;
