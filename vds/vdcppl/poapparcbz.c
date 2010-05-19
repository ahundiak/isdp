/* $Id: poapparcbz.c,v 1.1.1.1 2001/01/04 21:07:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdcppl / poapparcbz.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: poapparcbz.c,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:58  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/11/22  23:50:56  pinnacle
 * Replaced: ./vdcppl/poapparcbz.c for:  by azuurhou for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*----
%HD%
 
     MODULE NAME POXXXX
 
     Abstract:
        This function approximates an arc or circle by only one
	Bezier curve. the result are just the poles.
	the maximun number of poles is 6.
-----
%SC%

     POapparcbz( center , vn , radius , vm , ac , order , poles, &ecmax , &rc)
		 I      , I  , I      , I  , I  , I     , O    , O      , O 
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
        *center    IGRdouble	 center of arc
        *vn        IGRdouble     vector normal defining the plan
 	radius     IGRdouble     radius of arc
	*vm        IGRdouble     bissector vector of the angular sector
	ac         IGRdouble     angle of the angular sector in radian
	order	   IGRint        order of approximation

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

	*poles	   IGRdouble    poles of arc
	*ecmax     IGRdouble     maximum error
        *rc        BSrc         completion code message
                                 - always BSSUCC

-----
%MD%

     MODULES INVOKED: BSnorvec, BScrossp
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

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "ma.h"
#include "msdef.h"
#include "bserr.h"
#include "math.h"

void POapparcbz( center , vn , radius , vm , ac , order , poles, ecmax , rc)

         
IGRdouble *center;      /* center of arc				*/
IGRdouble *vn;	     	/* vector normal defining the plan		*/
IGRdouble radius;	/* radius of arc				*/
IGRdouble *vm;          /* bissector vector of the angular sector      */
IGRdouble ac;	     	/* angle of the angular sector in radian	*/
IGRint    order;        /* order of approximation			*/
IGRdouble *poles;       /* poles of arc					*/
IGRdouble *ecmax;       /* maximum error 				*/
BSrc      *rc; 	        /* if success *rc = BSSUCC			*/


{


  
static int np = 9;

static double pol[108] = {
     1.0        ,  .415603E-8,  .416666E-1,  .484659E-6,
     -.869586E-3,  .266401E-5, -.102076E-4,  .143771E-5, -.359133E-6,
             0.0, -.166666   , -.958732E-7, -.138883E-1,
     -.19466E-5 , -.112904E-3, -.367958E-5, -.156156E-6, -.720710E-6,
             0.0, -.153488E-9,  .611936E-8, -.522412E-7,
      .193841E-6, -.378646E-6,  .140007E-4, -.246038E-6,  .122443E-6,
     1.0        ,  .256133E-6, -.166594E-5,  .432688E-5,
     -.134621E-2,  .462862E-5,  .575017E-6,  .551644E-6, -.775166E-7,
             0.0, -.249997   , -.136056E-4, -.786055E-2,
     -.307143E-4,  .117064E-3, -.627057E-5,  .108590E-5, -.877133E-7,
     1.0        , -.34071E-6 ,  .416689E-1, -.571363E-5,
      .926901E-3, -.602265E-5,  .636370E-5, -.695299E-6,  .992263E-7,
             0.0, -.416175E-7,  .377892E-6, -.104538E-5,
      .133096E-5, -.888365E-6,  .315833E-6, -.539162E-7,  .224750E-7,
     1.0        , -.568063E-3, -.227428E-1, -.281696E-2,
      .716302E-3, -.537577E-3,  .104848E-3, -.907827E-5,  .332032E-6,
             0.0, -.301416   ,  .506111E-2, -.900981E-2,
      .351505E-2, -.100100E-2,  .198813E-3, -.191303E-4,  .729883E-6,
     1.0        ,  .228651E-3,  .241530E-1,  .102474E-2,
     -.379731E-3,  .189464E-3, -.356622E-4,  .312953E-5, -.119282E-6,
             0.0, -.10099    ,  .379509E-2, -.821858E-2,
      .272899E-2, -.923857E-3,  .153073E-3, -.141443E-4,  .528833E-6,
             0.0,  .627012E-4, -.167585E-3,  .194374E-3,
     -.116394E-3,  .386898E-4, -.716959E-5,  .684818E-6, -.253059E-7
};     

/*		   SELECT THE ORDER RELATED WITH THE AC ANGLE

		   ----------------------------------
                   |  AC   | <= 90 | <= 180 | <= 360 | 
		   ----------------------------------
		   | ORDER | 4,5,6 |  5,6   |    6   |
		   ----------------------------------
*/

int     i, j, jj, k, l, n1, i3, i2; 
double	vy[3], xy[12], v[5];

/*									   */
/*									   */
/*									   */
/*<---------------------->     BEGINNING OF CODE    <--------------------->*/
/*                             -----------------			   */
/*									   */
/*									   */
	if( (order < 4) || (order > 6) )
	{
		*rc = 1;
		return ;
	}
        BSnorvec(rc,vm);
        if( *rc != BSSUCC )
        {
        	*rc = 2;
        	return ;
	}
	BScrossp(rc,vn,vm,vy);
        if( *rc != BSSUCC )
        {
        	*rc = 3;
        	return ;
	}
        BSnorvec(rc,vy);
        
	*rc = BSSUCC;
	xy[0] = cos((ac/2.0))*radius;
	xy[1] = -sin((ac/2.0))*radius;
        k = ( order -1 ) / 2;
        k = k * 2 + 1;
        xy[k] = 0.0;

	k = order - 1;
	n1 = 1;
	i = order - 5;
	
	if( i > 0 ) n1 = n1 + 7;
	else if ( i == 0 ) n1 = n1 + 3;

	for(i=0; i<k; i=i+1)
	{
	      v[i] = 0.0;
	      jj   = np * n1 - 1;
	      for(j=0; j<np; j=j+1)  v[i] = v[i]*ac + pol[jj-j];
	      n1 = n1 + 1;
	}

	k = k - 1;

	for(i=0; i<k; i=i+1)  xy[i+2] = v[i] * radius;

	*ecmax = v[k] * radius;
	k = order / 2;
        l = (order - 1) * 2;
	
	for(i=0; i<2*k; i=i+2)
	{
	   xy[l] = xy[i];
	   xy[l+1] = -xy[i+1];
   	   l = l - 2;
	}

	for(i=0; i<order; i=i+1)
	{
	   i3 = i * 3;
	   i2 = i * 2;
	   for(k=0; k<3; k=k+1)
	   {
		poles[k+i3] = vm[k] * xy[i2];
		poles[k+i3] = poles[k+i3] + vy[k] * xy[i2+1];
		poles[k+i3] = center[k] + poles[k+i3];
	   }
	}
}

