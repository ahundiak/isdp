/*----
%HD%
 
     MODULE NAME FAintDrFa
 
     Abstract:
        This function finds the intersection between a line and a facet.
-----
%SC%

     FAintDrFa( p00, p01, p10, p11, ptdr, vecdr, ptsol, &parSol, &rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
       *P00	  IGRdouble	 first Pole
       *P01	  IGRdouble	 second Pole
       *P10	  IGRdouble	 third Pole
       *P11	  IGRdouble	 forth Pole
       *ptDr      IGRdouble	 point on the line
       *vecDr     IGRdouble      vector director
      
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	*ptSol	   IGRdouble	point solution
	*uv
        *rc        BSrc         completion code message
                                 - always BSSUCC
        result     IGRdouble     dotproduct of two vectors
  
-----
%MD%

     MODULES INVOKED: none
-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:
        
        JLL    : Creation date.
      
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/
#include <stdio.h>
#include "bstypes.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdef.h"
#include "madef.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"

void FAintDrFa( p00, p01, p10, p11, ptDr, vecDr, ptSol, parSol, rc )
IGRdouble	*p00;
IGRdouble	*p01;
IGRdouble	*p10;
IGRdouble	*p11;
IGRdouble	*ptDr;
IGRdouble	*vecDr;
IGRdouble	*ptSol;
IGRdouble	*parSol;
BSrc		*rc;

{

extern IGRdouble	fabs();
extern void		FAev2();
extern IGRdouble	sqrt();

IGRint		i, k;
IGRdouble	ev[12], pq[3], u[3], dd, pd[3];
IGRdouble	ahMde, doMas, esMho, eta, dze;
IGRdouble	*du, *dv, *dudv;
IGRdouble	uSave, vSave;


uSave = parSol[0];
vSave = parSol[1];
du   = &ev[3];
dv   = &ev[6];
dudv = &ev[9];

eta = vecDr[0]*vecDr[0] + vecDr[1]*vecDr[1] + vecDr[2]*vecDr[2];
eta = sqrt(eta);
for(k=0;k<3;k++) u[k] = -1.0 * vecDr[k] / eta ;

for( i=0; i<10; i++ ){

	FAev2(  (IGRshort)3,p00,p01,p10,p11,parSol[0],parSol[1], ev, rc );
	eta = 0.0;
	for(k=0;k<3;k++){
		pd[k] = ptDr[k] + parSol[2]*vecDr[k];
		pq[k] = pd[k]  - ev[k];
		eta  += pq[k] * pq[k];
	}

	if( eta < 1.0E-6 ) goto sucsuc;

	dd = u[0]*ev[4]*ev[8] + ev[3]*ev[7]*u[2] + u[1]*ev[5]*ev[6] -
	     ev[6]*ev[4]*u[2] - u[0]*ev[7]*ev[5] - ev[3]*u[1]*ev[8];

	if( fabs(dd) < 1.0E-30 ) goto wrapup;

	ahMde = u[0]*pq[1] - pq[0]*u[1];
	doMas = pq[0]*u[2] - u[0]*pq[2];
	esMho = u[1]*pq[2] - pq[1]*u[2];
	eta =  ( dv[2]*ahMde + dv[1]*doMas + dv[0]*esMho ) / dd; 
	dze = -( du[2]*ahMde + du[1]*doMas + du[0]*esMho ) / dd;

	for( k=0; k<3; k++ ){
		du[k] = du[k] + 0.5 * dze * dudv[k];
		dv[k] = dv[k] + 0.5 * eta * dudv[k]; 
	}

	dd = u[0]*ev[4]*ev[8] + ev[3]*ev[7]*u[2] + u[1]*ev[5]*ev[6] -
	     ev[6]*ev[4]*u[2] - u[0]*ev[7]*ev[5] - ev[3]*u[1]*ev[8];
	if( fabs(dd) < 1.0E-30 ) goto wrapup;

	parSol[0] +=  ( dv[2]*ahMde + dv[1]*doMas + dv[0]*esMho ) / dd; 
	parSol[1] += -( du[2]*ahMde + du[1]*doMas + du[0]*esMho ) / dd;
	parSol[2] += (  pq[0]*du[1]*dv[2] + du[0]*dv[1]*pq[2] +
		        dv[0]*du[2]*pq[1] - pq[2]*du[1]*dv[0] -
		        du[0]*pq[1]*dv[2] - pq[0]*dv[1]*du[2] ) / dd;
}
	

wrapup:
	/*d
	printf("Erreur dans FAintDrFa\n");
	d*/
	parSol[0] = uSave;
	parSol[1] = vSave;
	*rc = BSFAIL;
	return;

sucsuc:
	/*d
	printf("in FAintDrFa i = %d, parSol = %f, %f\n",i,parSol[0],parSol[1]);
	d*/

	for(k=0;k<3;k++) ptSol[k] = ( ev[k] + pd[k] ) * 0.5;
	*rc = BSSUCC;
	return;
}
