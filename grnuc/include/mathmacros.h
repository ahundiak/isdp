#ifndef mathmacros_include
#define mathmacros_include

IGRdouble mat1[16],mat2[16],mat3[16],mat4[16];

IGRshort dim;



extern    IGRboolean    MAmulmx();
extern    IGRboolean    MArotmx();
extern    IGRboolean    MA3protmx();

/*
Abstract
   This macro will build a 4x4 matrix.  There is an option of
sending 3 points to build the rotation matrix, or sending view
matrix and 3 angles.

Arguments
   *msg		IGRlong		O 	Return Code
				 	    MSSUCC - successful
					    MSFAIL - error

   *points      IGRdouble	I	Array of 3 points 
					   points[0:2] - origin point
					   points[3:5] - x axis direction
					   points[6:8] - y axis direction 

   *angles	IGRdouble	I 	 angles  (in radians)
					   angle[0] - x angle
					   angle[1] - y angle
					   angle[2] - z angle
					   if rotation in only one
					   direction is desired, 
					   send 0 for the other angles.

   *view_matrix	IGRdouble	I	 view matrix representing
					 world to view transformation

   matrix	IGRmatrix	O	 output rotation matrix

*/

#omdef gr$get_matrix
		  (msg,
		   points=NULL ^
		   angles=NULL ,
		   view_matrix=NULL,
		   matrix)

#if ( om$specified(points)) 
  {
	MA3protmx(msg,&points[0],&points[3],&points[6],matrix);
  }
#elif ( om$specified(angles) && om$specified(view_matrix))
  {
   	  			/* get each rotation 	      */
      if( MArotmx(msg,&view_matrix[0],&angles[0],mat1) )
      {
          if( MArotmx(msg,&view_matrix[4],&angles[1],mat2) )
	  {
	      if( MArotmx(msg,&view_matrix[8],&angles[2],mat3) )
	      {
	          dim = 4;
					/* multiply to get final mat */
	          MAmulmx(msg,&dim,&dim,&dim,mat3,mat2,mat4);

	          MAmulmx(msg,&dim,&dim,&dim,mat4,mat1,matrix);
	       }
	   }
       }
  }
#else
  {
#    omerror "must specify points or angles and view_matrix"
  }  
    
#endif

#endomdef

#endif
