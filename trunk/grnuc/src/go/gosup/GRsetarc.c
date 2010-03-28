/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRsetarc
 
     Abstract: This routine fills in the data for an IGRarc. The input
	      data may be from a two or three dimensional object.

-----
%SC%

     VALUE = GRsetarc(msg, dim, prim, sec, st_ang, sw_ang, rot, org, 
		      org_z, arc)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     dim	  IGRshort	 dimension of the input data
     prim	  IGRdouble 	 primary axis length
     sec	  IGRdouble	 secondary axis length
     st_ang	  IGRdouble 	 start angle of the arc
     sw_ang	  IGRdouble	 sweep angle of the arc
     rot	  IGRdouble	 rotation angle if dim = 2, matrix if
				 dim = 3
     org	  IGRpoint	 x and y values of the origin of the arc
     org_z	  IGRdouble	 z value of the origin of the arc 
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - severe failure, 
				 sine and cosine of rot undetermined

     arc	  IGRarc	 arc data structure

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - arc structure is complete
                        FALSE- arc structure is incomplete

-----
%MD%

     MODULES INVOKED:
		 	MAsincos
-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  06/25/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine simply loads the arc data structure with the given 
information. In addition, if the dimension is two the rotation
matrix is calculated using the rotation angle.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"

IGRboolean GRsetarc(msg, dim, prim, sec, st_ang, sw_ang, rot, org, 
		      org_z, arc)

	   IGRlong       *msg;			/* return code		*/
	   IGRshort	 *dim;			/* dimension of data	*/
	   IGRdouble	 *prim;			/* primary axis length	*/
	   IGRdouble	 *sec;			/* secondary axis length*/
	   IGRdouble	 *st_ang;		/* start angle		*/
	   IGRdouble	 *sw_ang;		/* sweep angle		*/
	   IGRdouble	 *rot;			/* rotation angle/matrix*/
	   IGRdouble	 *org;			/* x and y of origin	*/
	   IGRdouble	 *org_z;		/* z of origin		*/
	   struct IGRarc *arc;			/* arc data structure	*/

{
  IGRdouble sin, cos;				/*sine and cosine of rot*/


  *msg = MSSUCC;

  arc->prim_axis = *prim;
  arc->sec_axis  = *sec;

  arc->origin[0] = org[0];
  arc->origin[1] = org[1];
  arc->origin[2] = *org_z;

  if( *dim == 3 )
    {
      arc->rot_matrix[0] = rot[0];
      arc->rot_matrix[1] = rot[1];
      arc->rot_matrix[2] = rot[2];
      arc->rot_matrix[3] = 0.0;
      arc->rot_matrix[4] = rot[3];
      arc->rot_matrix[5] = rot[4];
      arc->rot_matrix[6] = rot[5];
      arc->rot_matrix[7] = 0.0;
      arc->rot_matrix[8] = rot[6];
      arc->rot_matrix[9] = rot[7];
      arc->rot_matrix[10] = rot[8];
      arc->rot_matrix[11] = 0.0;
      arc->rot_matrix[12] = 0.0;
      arc->rot_matrix[13] = 0.0;
      arc->rot_matrix[14] = 0.0;
      arc->rot_matrix[15] = 1.0;
    }
  else
    {
      if( MAsincos(msg, rot, &sin, &cos) )
	{
          arc->rot_matrix[0] = cos;
          arc->rot_matrix[1] = -sin;
          arc->rot_matrix[2] = 0.0;
          arc->rot_matrix[3] = 0.0;
          arc->rot_matrix[4] = sin;
          arc->rot_matrix[5] = cos;
          arc->rot_matrix[6] = 0.0;
          arc->rot_matrix[7] = 0.0;
          arc->rot_matrix[8] = 0.0;
          arc->rot_matrix[9] = 0.0;
          arc->rot_matrix[10] = 1.0;
          arc->rot_matrix[11] = 0.0;
          arc->rot_matrix[12] = 0.0;
          arc->rot_matrix[13] = 0.0;
          arc->rot_matrix[14] = 0.0;
	  arc->rot_matrix[15] = 1.0;
	}
    }

  arc->start_angle = *st_ang;
  arc->sweep_angle = *sw_ang;

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */	  
