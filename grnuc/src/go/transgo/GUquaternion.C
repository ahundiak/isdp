/* #######################    APOGEE COMPILED   ######################## */
#include "grimport.h"
#include "igrtypedef.h"
#include "madef.h"


/*
 *  This function will take the quaternions of an IGDS 8.8
 *  element and form the rotation matrix for that element.
 */

GUquat_to_rotmx ( quat, rotmx )						

IGRdouble quat[];
IGRdouble rotmx[];	
{
	quat[0] = quat[0] / 2147483647.0;				
	quat[1] = quat[1] / 2147483647.0;				
	quat[2] = quat[2] / 2147483647.0;				
	quat[3] = quat[3] / 2147483647.0;				
									
	rotmx[0] = (quat[0] * quat[0]) + (quat[1] * quat[1])		
		 - (quat[2] * quat[2]) - (quat[3] * quat[3]);		
	rotmx[1] = 2 * ((quat[3] * quat[0]) + (quat[1] * quat[2]));	
	rotmx[2] = 2 * ((quat[1] * quat[3]) - (quat[2] * quat[0]));	
	rotmx[3] = 0.0;						
	rotmx[4] = 2 * ((quat[1] * quat[2]) - (quat[3] * quat[0]));	
	rotmx[5] = (quat[0] * quat[0]) - (quat[1] * quat[1])		
		 + (quat[2] * quat[2]) - (quat[3] * quat[3]);		
	rotmx[6] = 2 * ((quat[1] * quat[0]) + (quat[2] * quat[3]));	
	rotmx[7] = 0.0;							
	rotmx[8] = 2 * ((quat[1] * quat[3]) + (quat[2] * quat[0]));	
	rotmx[9] = 2 * ((quat[2] * quat[3]) - (quat[1] * quat[0]));	
	rotmx[10] = (quat[0] * quat[0]) - (quat[1] * quat[1])		
		 - (quat[2] * quat[2]) + (quat[3] * quat[3]);		
	rotmx[11] = 0.0;						
	rotmx[12] = 0.0;						
	rotmx[13] = 0.0;						
	rotmx[14] = 0.0;						
	rotmx[15] = 1.0;

}





/* 
 *  This function will convert a rotation matrix to
 *  IGDS quaternions.  The algorithm used is found 
 *  in the IGDS interface document.
 */

GUrotmx_to_quat ( rotmx, quat )

IGRdouble rotmx[];
IGRdouble quat[];

{
    IGRlong  		msg;
    IGRdouble 		temp = 0;
    IGRdouble 		temp2 = 0;
    extern IGRdouble	MAsqrt();  
    static IGRdouble 	sqrtol = 2.3283064365386963e-10 ;



	temp = 1.0 + rotmx[0] + rotmx[5] + rotmx[10];

/*
 *  check Q1, Q2, Q3, Q4 against quaternion tolerance
 *  and adjust if necessary
 */

	if ( temp < .000000001 )
	{
	    temp = 0.0;
	}
	quat[0] = MAsqrt ( &msg, &temp ); 
	quat[0] /= 2.0;
	temp2 = quat[0] * quat[0];

	temp = temp2 - (( rotmx[5] + rotmx[10] ) / 2.0 );
	if ( temp < sqrtol )
	{
	    temp = 0.0;
	}
	quat[1] = MAsqrt ( &msg, &temp );


	temp = temp2 - (( rotmx[0] + rotmx[10] ) / 2.0 );
	if ( temp < sqrtol )
	{
	     temp = 0.0;
	}
	quat[2] = MAsqrt ( &msg, &temp );



	temp = temp2 - (( rotmx[0] + rotmx[5] ) / 2.0 );
	if ( temp < sqrtol )
	{
	    temp = 0.0;
	}
	quat[3] = MAsqrt ( &msg, &temp );

/*
 *  determine signs of each quaternion
 */

	if (( quat[0] == 0.0 ) && ( quat[1] != 0.0 ))
	{
	    quat[1] = MAabsolute ( quat[1] );  /*  sign (q1) = positive   */

	    if ( rotmx[1] < 0.0 )    /*  sign (q2) = sign (r12)  */
	    {
		if ( quat[2] >= 0.0 )
		{
		    quat[2] = 0.0 - quat[2];
		}
	    }
	    else
	    {
		quat[2] = MAabsolute ( quat[2] );
	    }

	    if ( rotmx[2] < 0.0 )   /*  sign (q3) = sign (r13)  */
	    {
		if ( quat[3] >= 0.0 )
		{
		    quat[3] = 0.0 - quat[3];
		}
	    }
	    else
	    {
		quat[3] = MAabsolute ( quat[3] );
	    }
	}

	else if (( quat[0] == 0.0 ) && ( quat[1] == 0.0 ))
	{
	    quat[2] = MAabsolute ( quat[2] );   /*  sign (q2) = positive    */

	    if ( rotmx[6] < 0.0 )     /*  sign (q3) = sign (r23)  */
	    {
		if ( quat[3] >= 0.0 )
		{
		    quat[3] = 0.0 - quat[3];
		}
	    }
	    else
	    {
		quat[3] = MAabsolute ( quat[3] );
	    }
	}
	else
	{
	    if (( rotmx[6] - rotmx[9] ) < 0.0 )  /* sign(q1) = sign(r23-r32) */
	    {
	        if ( quat[1] >= 0.0 )
	        {
		    quat[1] = 0.0 - quat[1];
	        }
	    }
	    else
	    {
	        quat[1] = MAabsolute ( quat[1] );
	    }

	    if (( rotmx[8] - rotmx[2] ) < 0.0 )  /* sign(q2) = sign(r31-r13) */
	    {
	        if ( quat[2] >= 0.0 )
	        {
		    quat[2] = 0.0 - quat[2];
	        }
	    }
	    else
	    {
	        quat[2] = MAabsolute ( quat[2] );
	    }

	    if (( rotmx[1] - rotmx[4] ) < 0.0 )  /* sign(q3) = sign(r12-r21) */
	    {
	        if ( quat[3] >= 0.0 )
	        {	 
	            quat[3] = 0.0 - quat[3];
	        }
	    }
	    else
	    {
	        quat[3] = MAabsolute ( quat[3] );
	    }
	}
	    	
/*
 *  perform final calculations to
 *  determine quaternion values
 */

	temp = ( quat[0] * quat[0] ) + ( quat[1] * quat[1] ) +
	       ( quat[2] * quat[2] ) + ( quat[3] * quat[3] );

	temp2 = MAsqrt ( &msg, &temp );


	quat[0] /= temp2;
	quat[1] /= temp2;
	quat[2] /= temp2;
	quat[3] /= temp2;

	quat[0] *= 2147483647.0;
	quat[1] *= 2147483647.0;
	quat[2] *= 2147483647.0;
	quat[3] *= 2147483647.0;
}
