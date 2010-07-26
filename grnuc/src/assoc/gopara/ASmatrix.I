
/*	matrix_asso.c	
  version provisoire des operations vectorielles et matricielles en attendant 
  de savoir comment utiliser MA */


/*-----------------*/
/*VECTOR OPERATIONS*/
/*-----------------*/
/*	identity vector	 */

class implementation Root;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "madef.h"
#include "ma.h"


void v_identity(V)
IGRpoint V;
{ 
 V[0]=0.;
 V[1]=0.;
 V[2]=0.; 
} 

/*     equality of vector  */
void v_equal(v1,v2)
IGRpoint v1,v2;
{
 v2[0] = v1[0] ;
 v2[1] = v1[1] ;
 v2[2] = v1[2] ; 
}

/*	multiply vector times scalar	*/
void v_scale(v,s,V)
IGRpoint v,V;
IGRdouble s;
 {
  IGRlong ret_code;
  IGRboolean value,MAscalvc();
  value = MAscalvc(&ret_code,&s,v,V);
 }

/*	negate a vector		*/
void v_neg(v,V)
IGRpoint v,V;
 {
  IGRlong ret_code;
  IGRboolean value,MAscalvc();
  IGRdouble s = -1.;
  value = MAscalvc(&ret_code,&s,v,V);
 }

/*	add vector1 plus vector2	*/
void v_add(v1,v2,V)
IGRpoint v1,v2,V;
 {
  IGRlong ret_code;
  IGRboolean value,MAaddvc();
  value = MAaddvc(&ret_code,v1,v2,V);
 }

/*	subtract vector1 minus vector2	*/
void v_sub(v1,v2,V)
IGRpoint v1,v2,V;
 {
  IGRlong ret_code;
  IGRboolean value,MAsubvc();
  value = MAsubvc(&ret_code,v1,v2,V);
 }
  

/*	linear combination of 2 vectors		*/
void v_comb(s1,v1,s2,v2,V) 
IGRpoint v1,v2,V;
IGRdouble s1,s2;

 { 
  IGRlong ret_code;
  IGRboolean value,MAscalvc(),MAaddvc();
  IGRpoint T;
  value = MAscalvc(&ret_code,&s1,v1,V);
  value = MAscalvc(&ret_code,&s2,v2,T);
  value = MAaddvc(&ret_code,V,T,V);
 }

/*	vector cross product of vector1 and vector2	*/
void v_cross(v1,v2,V) 
IGRpoint v1,v2,V;
 {IGRlong ret_code;
  IGRpoint T;
  IGRboolean value,MAcrossvc();
  value = MAcrossvc(&ret_code,v1,v2,T);
  v_equal(T,V);
 }

/*	return scalar dot product of vector1 and vector2	*/
IGRdouble v_dot(v1,v2)
  IGRpoint v1,v2;
  {
   IGRdouble p;
   p =  v1[0]*v2[0] + v1[1]*v2[1] + v1[2]*v2[2];
   return(p);
  }

/*	return scalar length of vector	*/
IGRdouble  v_len(v)
   IGRpoint v;
   {
    IGRdouble len;
    IGRdouble sqrt();
    len =  sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
    return (len) ;
   }

/*	return TRUE if vector length = 0, else return FALSE	*/
IGRboolean v_zero(v)
   IGRpoint v;
   {
    IGRboolean test;
    test =  (v[0]==0)&&(v[1]==0)&&(v[2]==0);
    return(test);
   }

/*
 compute distance from point p1 to line passing trought p2 with unit vector v0
 Return distance and vector from point to line
*/

v_dist_line(p1,p2,v0,dist,trans)
IGRdouble *p1,    /* point */
	  *p2,    /* point on the line */
          *v0,    /* unit vector of the line*/
          *dist,  /* returned distance */
          *trans; /* returned vector from point to line */
 {
  IGRdouble scal;
  IGRdouble sqrt();

  trans[0] = p2[0]-p1[0];
  trans[1] = p2[1]-p1[1];
  trans[2] = p2[2]-p1[2];

  scal = trans[0]*v0[0] + trans[1]*v0[1] + trans[2]*v0[2];
  trans[0] = trans[0] - scal*v0[0];
  trans[1] = trans[1] - scal*v0[1];
  trans[2] = trans[2] - scal*v0[2];

  scal = trans[0]*trans[0] + trans[1]*trans[1] + trans[2]*trans[2];
  *dist = sqrt(scal);
  return(1);
 }

/*------------------------*/
/*MATRIX VECTOR OPERATIONS*/
/*------------------------*/


/*	multiply matrix times point (or vector)		*/
void m_mul_v(m,v,V) 
 IGRdouble m[];
 IGRpoint v,V;
 { 
  IGRlong msg;
  IGRpoint T; 
  IGRshort i=3,j=3,k=1;

  MAmulmx(&msg,&i,&j,&k,m,v,T);
  V[0]=T[0]; V[1]=T[1]; V[2]=T[2];
 }

/*	multiply transpose of matrix1 times vector	*/
void mt_mul_v(m,v,V)
 IGRdouble m[];
 IGRpoint v,V;
 { 
  IGRlong msg;
  IGRpoint T; 
  IGRshort i=1,j=3,k=3;

  MAmulmx(&msg,&i,&j,&k,v,m,T);
  V[0]=T[0]; V[1]=T[1]; V[2]=T[2];
 }
/*
              lib_ch
   


    It is just a little stuff to do what i want.
*/


/*
      mat3_4
   Transform a (3,3) matrix to a (4,4) matrix.
*/

IGRboolean mat3_4( mat3, mat4 )
 IGRdouble *mat3;
 IGRdouble *mat4;
 {

  mat4[0]  = mat3[0]; mat4[1]  = mat3[1]; mat4[2]  = mat3[2]; mat4[3]  = 0;
  mat4[4]  = mat3[3]; mat4[5]  = mat3[4]; mat4[6]  = mat3[5]; mat4[7]  = 0;
  mat4[8]  = mat3[6]; mat4[9]  = mat3[7]; mat4[10] = mat3[8]; mat4[11] = 0;
  mat4[12] = 1      ; mat4[13] = 0      ; mat4[14] = 0      ; mat4[15] = 0;

  return(1);
 }
/*
      mat4_3

   Transform a (4,4) matrix to a (3,3) matrix.
*/

IGRboolean mat4_3( mat4, mat3 )
 IGRdouble *mat4;
 IGRdouble *mat3;
 {
  mat3[0] = mat4[0]; mat3[1] = mat4[1]; mat3[2] = mat4[2];
  mat3[3] = mat4[4]; mat3[4] = mat4[5]; mat3[5] = mat4[6];
  mat3[6] = mat4[8]; mat3[7] = mat4[9]; mat3[8] = mat4[10];

  return(1);
 }
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function AS_trans_mat                           */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

AStrans_mat(mat,trans_mat)

  /* Transpose a 4x4 homogeneous matrix of the form

        | Sx  Nx  Ax  Tx |                   | Sx  Sy  Sz  0 |
  mat = | Sy  Ny  Ay  Ty |   --> trans_mat = | Nx  Ny  Nz  0 |
        | Sz  Nz  Az  Tz |                   | Ax  Ay  Az  0 |
        |  0   0   0   1 |                   | Tx  Ty  Tz  1 |

  mat and trans_mat could be in the same array  
 */

  IGRmatrix   mat;                 /* Matrix to inverse                       */
  IGRmatrix   trans_mat;             /* Inverse of matrix mat                   */

  {
  double xx;
  trans_mat[0]=mat[0];
  trans_mat[5]=mat[5];
  trans_mat[10]=mat[10];
  trans_mat[15]=mat[15];

  xx = mat[1];
  trans_mat[1]=mat[4];
  trans_mat[4]=xx;

  xx = mat[2];
  trans_mat[2]=mat[8];
  trans_mat[8]=xx;

  xx = mat[12];
  trans_mat[12]=mat[3];
  trans_mat[3]= xx;

  xx = mat[6];
  trans_mat[6]=mat[9];
  trans_mat[9]=xx;

  xx = mat[13];
  trans_mat[13]=mat[7];
  trans_mat[7]=xx;

  xx = mat[14];
  trans_mat[14]=mat[11];
  trans_mat[11]=xx;

  return(TRUE);
}/* end function AStrans_mat */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function AS_invmat                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASinvmat(mat,inv_mat)

  /* Inverse a 4x4 homogeneous matrix of the form

        | Sx  Nx  Ax  Tx |                 | Sx  Sy  Sz  -T.S |
  mat = | Sy  Ny  Ay  Ty |   --> inv_mat = | Nx  Ny  Nz  -T.N |
        | Sz  Nz  Az  Tz |                 | Ax  Ay  Az  -T.A |
        |  0   0   0   1 |                 |  0   0   0    1  |
 */

  IGRmatrix   mat;                 /* Matrix to inverse                       */
  IGRmatrix   inv_mat;             /* Inverse of matrix mat                   */

  {
  inv_mat[0]=mat[0];
  inv_mat[1]=mat[4];
  inv_mat[2]=mat[8];
  inv_mat[3]=-(mat[0]*mat[3]+mat[4]*mat[7]+mat[8]*mat[11]);
  inv_mat[4]=mat[1];
  inv_mat[5]=mat[5];
  inv_mat[6]=mat[9];
  inv_mat[7]=-(mat[1]*mat[3]+mat[5]*mat[7]+mat[9]*mat[11]);
  inv_mat[8]=mat[2];
  inv_mat[9]=mat[6];
  inv_mat[10]=mat[10];
  inv_mat[11]=-(mat[2]*mat[3]+mat[6]*mat[7]+mat[10]*mat[11]);
  inv_mat[12]=0;
  inv_mat[13]=0;
  inv_mat[14]=0;
  inv_mat[15]=1;
  return(TRUE);
}/* end function inv_mat */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                            function ASmake_ref                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
  make a referential by 3 points :

  the computed matrix is:


  | X0  Y0  Z0  T0 |
  | X1  Y1  Z1  T1 | 
  | X2  Y2  Z2  T2 |
  |  0   0   0   1 |


  with:


  X = (p2-p1)/||p2p1||

  Z = X ^ [(p3-p1)/||p3p1||] 

  Y = Z ^ X

  T = p1

*/

ASmake_ref(p1,p2,p3,tmat)

  IGRpoint   p1;                     /* origin point                          */
  IGRpoint   p2;                     /* point along the X axis                */
  IGRpoint   p3;                     /* point in the direction of Y           */
  IGRdouble *tmat;                   /* Matrix of the coordonate system       */

{
  MAvector   x,y,z;
  IGRint     index;                  /* Index for a loop                      */
  IGRint     ret_code;               /* Code returned by the function         */
  IGRlong    mess;                   /* Code return by the MA_functions       */
  IGRdouble  length;                 /* Length of the vectors                 */
  IGRdouble  EPSILON = 0;            /* Length of the null vector             */
  IGRdouble  v_len();
  IGRboolean MAscalvc();
  IGRboolean MAsubvc();
  IGRboolean MAcrossvc();
  IGRboolean MAunitvc();


  /*| Compute the X vector */

  MAsubvc(&mess,p2,p1,x);
  length=v_len(x);
  if(length > EPSILON)
    {
    /*| after first test */
    length = 1/length;
    MAscalvc(&mess,&length,x,x);

    /*| Compute the Z vector */

    MAsubvc(&mess,p3,p1,y);
    MAunitvc(&mess,y,y);
    MAcrossvc(&mess,x,y,z);
    length=v_len(z);
    if(length > EPSILON)
      {
       /*| after second test */
      length = 1/length;
      MAscalvc(&mess,&length,z,z);
 
      /*| Compute the Y vector */

      MAcrossvc(&mess,z,x,y);

      /*| Load the matrix */

      for(index=0; index<3; ++index)
        {
        tmat[index*4]   = x[index];
        tmat[1+index*4] = y[index];
        tmat[2+index*4] = z[index];
        tmat[3+index*4] = p1[index];
        tmat[12+index]  = 0.0;
      }/* end for(index=0; index<3; ++index) */ 
      tmat[15] = 1.0;
      ret_code =1;
      }
    else
      ret_code = 0;
    /* end if(length Z > EPSILON) */
    }
  else
    ret_code = 0;
  /*| end if( length X > EPSILON) */
  return(ret_code);
}/* end ASmake_ref(p1,p2,p3,tmat) */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


/***************************************/
/* Perform the operation out = matrix * in
/* depending upon flag value
/*      - point or vector operation
/*      - uses matrix or inverts it before use
/* in and out could be the same vector
/***************************************/

#define DIRECT 0
#define INVERT 1

#define VECTOR 2
#define POINT  4

void ASmatv(flag,matrix,in,out)
IGRint flag;
IGRdouble *matrix,*in,*out;
{
 IGRdouble prov[3];
 IGRdouble xx;
 IGRint i,j,k,s;

 for(i=0;i<3;i++) prov[i]=in[i];


 if(flag&INVERT) s=4;
	   else  s=1;

 for(i=0,k=0;i<3;i++,k+=s)  
    {
     xx=0;k = k%15;
     for(j=0 ; j<3 ; j++,k+=s) xx += prov[j]*matrix[k]; 
     out[i] = xx;
    }

/* Do I have to had translation */
if(flag&POINT)
  {
   if(flag&INVERT)
     { 
      out[0] -= (matrix[0]*matrix[3]+matrix[4]*matrix[7]+matrix[8]*matrix[11]);
      out[1] -= (matrix[1]*matrix[3]+matrix[5]*matrix[7]+matrix[9]*matrix[11]);
      out[2] -= (matrix[2]*matrix[3]+matrix[6]*matrix[7]+matrix[10]*matrix[11]);
     }
   else
     {
      for(i=0;i<3;i++) out[i] += matrix[4*i+3];
     }
  }
}

 
end implementation Root;
