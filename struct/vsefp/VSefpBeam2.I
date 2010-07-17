/* -------------------------------------------------
 * Misc beam routines
 */
class implementation VSbeam;

#include "VDtypedef.h"
#include "VDobj.h"

#include "VDefp.h"
#include "VSefp.h"

// For the beam clone
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
#include "vsbeamproto.h"
#include "vsvecmxproto.h"

// Back to normal
#include "vsdpb.h"
#include "vsevalbeamcs.h"

#include "bscrossp.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "mamulmx.h"

static int traceFlag;

/* -----------------------------------------------------------------
 * Cloned from VSmxprodpt, 
 * Even though it uses MAmulmx we know it works
 * for translating points from a beam profile to 3d space
 * because of VSevalBeamCS
 */
void VSefpMxPt( IGRmatrix mat, IGRpoint pt1, IGRpoint pt2)
{

  IGRshort s4 = 4;
  IGRshort s1 = 1;
  
  IGRlong msg;
  
  IGRdouble PT1[4],PT2[4];
  IGRint    i;
  
  // Init
  PT1[3] = PT2[3] = 1.0;
  for(i = 0; i < 3; i++) PT1[i] = pt1[i];
  
  // Do It
  MAmulmx(&msg,&s4,&s4,&s1,mat,PT1,PT2);
  
  // Xfer
  for(i = 0; i < 3; i++) pt2[i] = PT2[i];

  // Trace
  // printf("PT1 %12.4f %12.4f %12.4f\n",pt1[0],pt1[1],pt1[2]);
  printf("PT2 %12.4f %12.4f %12.4f\n",pt2[0],pt2[1],pt2[2]);
  
}

/*----------------------------------------------------------------------------
 * Direct clone of the offical routine but 
 * Always get the web aligned origin point
 *
 * Hack this down later to use beam info as input to speed things up
 */
long VSefpEvalBeamCS( msg, beam, endno, cardPt, CS )

long			*msg ;
struct GRobj_env	*beam ;
int			endno ;
enum VScardinal_point	cardPt ;
IGRmatrix		CS ; {

	long		sts ;		/* OM return code		*/
	struct GRid	profDef ;	/* Profile definition		*/
	VSsuppList	supports ;	/* Beam's supports		*/
	int		count ;		/* ... of supports		*/
	int		invx,		/* Must inverse x-axis ?	*/
			invy ;		/* Must inverse y-axis ?	*/
	IGRvector	origin ;

	sts = om$send(	msg	= message VSbeam.VSgetProfileDef( msg, &profDef ),
			targetid= beam->_objid,
			targetos= beam->_osnum,
			senderid= beam->_objid ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetProfileDef", wrapup ) ;

	sts = om$send(	msg	= message VSpart.VSgetSupports(
					msg, &beam->mod_env, &count, supports ),
			targetid= beam->_objid,
			targetos= beam->_osnum,
			senderid= beam->_objid ) ;
	__CheckRC( sts, *msg, "VSpart.VSgetSupports", wrapup ) ;

	sts = om$send(	msg	= message VSbeam.VSgetCrossSectionCS(
							msg,
							&beam->mod_env,
							supports + 0,
							supports + 1,
							(double) endno,
							&profDef,
							CS ),
			targetid= beam->_objid,
			targetos= beam->_osnum,
			senderid= beam->_objid ) ;
	__CheckRC( sts, *msg, "VSbeam.VSgetCrossSectionCS", wrapup ) ;

/* TR179700969 */
/* TR179702512 */
  {	
    IGRboolean cardOpt = FALSE ;
    int        state ;

    VSbeamGetState(&beam->obj_id,&state);

    if( state & VS_m_NdState ) cardOpt = TRUE ;

    // Just for the efp code
    cardOpt = TRUE;
    
    VScardpt_to_point( &beam->mod_env, profDef, &cardOpt, cardPt, origin ) ;
    // printf("Origin %f %f %f\n",origin[0],origin[1],origin[2]);
    
  }


	VSmxprodpt( CS, origin, origin ) ;

	for( count = 0 ; count < 3 ; count++ ) {
		CS[count*4+3] = origin[count] ;
	}

	switch( cardPt ) {
		case VS_e_BOT_LEFT : invx = FALSE  ; invy = FALSE  ; break ;
		case VS_e_BOT_RGHT : invx = TRUE   ; invy = FALSE  ; break ;
		case VS_e_UPP_LEFT : invx = FALSE  ; invy = TRUE   ; break ;
		case VS_e_UPP_RGHT : invx = TRUE   ; invy = TRUE   ; break ;
		default		   : *msg = MSINARG ; sts = OM_E_INVARG ;
				     goto wrapup ;
	}

	if( invx ) {
		int i ;

		for( i = 0 ; i < 3 ; i++ ) {
			CS[i*4+0] *= -1. ;
		}
	}
	if( invy ) {
		int i ;

		for( i = 0 ; i < 3 ; i++ ) {
			CS[i*4+1] *= -1. ;
		}
	}
	if( ( invx || invy ) && !( invx && invy ) ) {
		int i ;

		for( i = 0 ; i < 3 ; i++ ) {
			CS[i*4+2] *= -1. ;
		}
	}

	*msg	= MSSUCC ;
	sts	= OM_S_SUCCESS ;

	wrapup :
		return sts ;

} /* VSevalBeamCS */
/*----------------------------------------------------------------------------*/

/* --------------------------------------------------------
 * Determines the "production base end" of a beam
 *
 * Problem with this rotine is that if the beam was not placed web
 * aligned then you get the left profile point and not the left web
 * so I-T beams will be wrong
 *
 * Not a problem for now since ET origin is used but later need to
 * swap out the call to VSevalBeamCS with a call to VSefpGetLowerLeftWebCS
 *
 * The cloned VSefpEvalBeamCS seems to have solved the above problem
 */
IGRstat VSefpGetBeamBaseEnd(TGRobj_env *beamOE, TVDmatInfo *matInfo)
{
  IGRstat retFlag = 0;
  IGRstat sts,msg;
  BSrc    rc;
  
  IGRint  i,j;

  TVDmatInfo end0,end1;
 
  IGRdouble V[3];
  IGRdouble dotp;
  
  // Say hi
  // traceFlag = 1;
  if (traceFlag) printf(">>> VSefpGetBeamBaseEnd\n");
  
  // Arg check
  if (matInfo == NULL) goto wrapup;
  memset(matInfo,0,sizeof(TVDmatInfo));
  if ((beamOE == NULL) || (beamOE->obj_id.objid == NULL_OBJID)) goto wrapup;

  // Get the end information
  end0.par = 0.0;
  sts = VSefpEvalBeamCS( &msg, beamOE, 0, VS_e_BOT_LEFT , end0.mat);
  if (!(sts & msg & 1)) {
    printf("Problem getting VSevalBeamCS for \n");
    vdobj$Print(objOE = beamOE);
    goto wrapup;
  }
  end1.par = 1.0;
  sts = VSefpEvalBeamCS( &msg, beamOE, 1, VS_e_BOT_LEFT , end1.mat);
  if (!(sts & msg & 1)) {
    printf("Problem getting VSevalBeamCS for \n");
    vdobj$Print(objOE = beamOE);
    goto wrapup;
  }

  // Xfer vector information
  for(i = 0; i < 3; i++) {
    j = i * 4;
    end0.X [i] = end0.mat[j+0];  // X Vector
    end0.Y [i] = end0.mat[j+1];  // Y Vector
    end0.Z [i] = end0.mat[j+2];  // Just to document
    end0.S [i] = end0.mat[i+12]; // Scale???
    end0.O0[i] = end0.mat[j+3];  // Base   Origin
    end0.O1[i] = end1.mat[j+3];  // Offset Origin
    
    end1.X [i] = end1.mat[j+0];
    end1.Y [i] = end1.mat[j+1];
    end1.Z [i] = end1.mat[j+2];
    end1.S [i] = end1.mat[i+12];
    end1.O0[i] = end1.mat[j+3];
    end1.O1[i] = end0.mat[j+3];
  }

#if 0
  printf("Matrix 0\n");
  for(i = 0; i < 4; i++) {
    for(j = 0; j < 4; j++) {
      printf("%-12.4f ",end0.mat[(i*4)+j]);
    }
    printf("\n");
  }
  printf("Matrix 1\n");
  for(i = 0; i < 4; i++) {
    for(j = 0; j < 4; j++) {
      printf("%-12.4f ",end1.mat[(i*4)+j]);
    }
    printf("\n");
  }
#endif

  // Force Z to be orthogonal
  BScrossp( &rc, end0.X, end0.Y, end0.Z);
  BScrossp( &rc, end1.X, end1.Y, end1.Z);

#if 0
  printf("Matrix 0\n");
  for(i = 0; i < 4; i++) {
    for(j = 0; j < 4; j++) {
      printf("%-12.4f ",end0.mat[(i*4)+j]);
    }
    printf("\n");
  }
  printf("Matrix 1\n");
  for(i = 0; i < 4; i++) {
    for(j = 0; j < 4; j++) {
      printf("%-12.4f ",end1.mat[(i*4)+j]);
    }
    printf("\n");
  }
#endif

  // Make a vector from 1 end to another
  BSmkvec( &rc, V, end0.O0, end1.O0);

  // Compare directions
  dotp = BSdotp(&rc,V,end0.Z);
 
  if (traceFlag) {
    printf("Dot Product is %f\n",dotp);
  }
  
  if (dotp > 0.0) {

    *matInfo = end1;

    // Need to invert Z axis (stiffener direction)
#if 1
    for(i = 0; i < 3; i++) {
      matInfo->Z[i] = -1.0  * matInfo->Z[i];
      matInfo->mat[(i*4)+2] = matInfo->Z[i];
    }
#endif
    if (traceFlag) printf("Base End 1\n");
  }
  else {

    *matInfo = end0;
#if 0
    for(i = 0; i < 3; i++) {
      matInfo->Z[i] = -1.0  * matInfo->Z[i];
      matInfo->mat[(i*4)+2] = matInfo->Z[i];
    }
#endif

    if (traceFlag) printf("Base End 0\n");
  }
  
  if (traceFlag) {
    for(i = 0; i < 4; i++) {
      for(j = 0; j < 4; j++) {
	printf("%-12.4f ",matInfo->mat[(i*4)+j]);
      }
      printf("\n");
    }
  }
  
  // Done
  retFlag = 1;
  
wrapup:
  if (traceFlag) printf("<<< VSefpGetBeamBaseEnd %d\n",retFlag);
  return retFlag;
}
#if 0
/*----------------------------------------------------------------------------*/
/*
 * The left or right end is hilighted.  
 * Left and right are consistent with left and right of a Loft Profile Card.
 */
method  VShiliteBeamEndAsLoft( 
	struct GRobj_env support;   	/* I: stiffener or beam  	*/
	IGRchar 	 *bmEnd )       /* I: "left" or "right" 	*/
{
	long		sts, msg;
	double		o0[3], X0[3], Y0[3], Z0[3], v[3];
	double		o1[3], X1[3], Y1[3], Z1[3];
	double		SecMat[16],SecMat0[16], SecMat1[16];
	BSrc		rc;
	int		i,k;
	double		dotp;
	int             hiliteParam = -1;

	///SetProc(VShiliteBeamEndAsLoft); Begin

	/*
	 * get Section Cs at parameter 0
	 */
	__DBGpr_obj("support 1",support.obj_id);
	sts = VSevalBeamCS( &msg, &support, 0, VS_e_BOT_LEFT , SecMat0 ); 

	if( ! (sts&msg&1)){ 
		__DBGpr_com("Evaluation failed 1");
		sts = MSFAIL; goto wrapup; 
	}

	for( i=0; i<3; i++ ){
		k=i*4;
		X0[i]	= SecMat0[k];
		Y0[i]	= SecMat0[k+1];
		o0[i]	= SecMat0[k+3];
	}

	BScrossp( &rc, X0, Y0, Z0 );

	/*
	 * get Section Cs at parameter 1
	 */
	sts = VSevalBeamCS( &msg, &support, 1, VS_e_BOT_LEFT, SecMat1 ); 
	if( ! (sts&msg&1)){ 
		__DBGpr_com("Evaluation failed 2");
		sts = MSFAIL; goto wrapup; 
	}
	for( i=0; i<3; i++ ){
		k=i*4;
		X1[i]	= SecMat1[k];
		Y1[i]	= SecMat1[k+1];
		o1[i]	= SecMat1[k+3];
	}
	BScrossp( &rc, X1, Y1, Z1 );

	BSmkvec( &rc, v, o0, o1 );

	/* 
	 * compare vector direction
	 */
	dotp = BSdotp( &rc, v, Z0 );

	if( dotp > 0 ){
		__DBGpr_com("dotp > 0");
		/* sect mat is SecMat0	Z0

		for( i=0; i<16; i++ ) SecMat[i] = SecMat0[i];
		SecMat[2]	= Z0[0];
		SecMat[6]	= Z0[1];
		SecMat[10]	= Z0[2];
		*/
		if(!strcmp(bmEnd,"left")){
			hiliteParam= 0;
		}
		else if(!strcmp(bmEnd,"right")){
			hiliteParam = 1;
		} else {
			printf(" Error! ");
		}
	} else {
		if(!strcmp(bmEnd,"left")){
			hiliteParam= 1;
		}
		else if(!strcmp(bmEnd,"right")){
			hiliteParam = 0;
		} else {
			printf(" Error! ");
		}
	}
	if( hiliteParam == 1 || hiliteParam == 0 ){
		sts = MSSUCC;
	} else { 
		sts = MSFAIL ;
		goto wrapup ;
	}

	sts = om$send( msg = 	message VSovrlngCmd.displayCrossSection(
					support,
					hiliteParam ),
			targetid = my_id );
wrapup :
	//End 
	return sts;
}
#endif

end implementation VSbeam;
