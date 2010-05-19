/*----
%HD%
 
     MODULE NAME FAev
 
     Abstract:
        This function evaluate the current point and the two first derivates
        on a facette giving the u and v parameters.


		P00             P01
		+---------------+
		|### u       	|
		|#		|
		|#		|
		|v		|
		|		|
		+---------------+
		P10             P11


-----
%SC%

     FAev1( idim, p00, p01, p10, p11, u, v, eval, rc )
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
	idim	   IGRshort	 2d or 3d facette
        *p00       IGRdouble     first pole 
        *p01       IGRdouble     secnd pole
        *p10       IGRdouble     third pole
        *p11       IGRdouble     fourth pole

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	*eval	   IGRdouble	according to opt the point and derivates 
        *rc        BSrc         completion code message
                                 - always BSSUCC

--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/

#include "bstypes.h"
#include "bserr.h"


void FAev1( idim, p00, p01, p10, p11, u, v, eval, rc )

IGRshort	idim;
IGRdouble	*p00;
IGRdouble	*p01;
IGRdouble	*p10;
IGRdouble	*p11;
IGRdouble	u;
IGRdouble	v;
IGRdouble	*eval;
IGRlong		*rc;

{

IGRint			i, j, k, m;
IGRdouble 		un_u, un_v, uv, un_uMun_v, uMun_v, vMun_u;
IGRdouble		*du, *dv;

/*
extern IGRboolean	BScrossp();
extern IGRboolean	BSnorvec();
*/

*rc = BSSUCC;

un_u      = 1.0 - u;
un_v      = 1.0 - v;
un_uMun_v = un_u * un_v;
uMun_v    = u * un_v;
vMun_u    = v * un_u;
uv        = u * v;
du        = eval + idim;
dv        = du + idim;

for(i=0;i<idim;i++){
	eval[i] = un_uMun_v * p00[i] +
		  uMun_v    * p01[i] +
	          vMun_u    * p10[i] +
		  uv	    * p11[i];
				    
	du[i]   =  un_v * ( p01[i] - p00[i] ) +
	 	   v    * ( p11[i] - p10[i] );

        dv[i]   =  un_u * ( p10[i] - p00[i] ) +
		   u    * ( p11[i] - p01[i] );
}


}
