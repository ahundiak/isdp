
/*	matrix_asso.h	
  Type definition of the matrix_assoc function
*/


IGRdouble sqrt();

void v_identity();		/* initialize a vector to 0	 	*/
void v_equal();			/* equality of vector  			*/
void v_scale();			/* multiply vector times scalar		*/
void v_neg();			/* negate a vector			*/
void v_add();			/* add vector1 plus vector2		*/
void v_sub();			/* subtract vector1 minus vector2	*/
void v_comb();			/* linear combination of 2 vectors	*/
void v_cross();			/* vector cross product			*/
IGRdouble v_dot();		/* return scalar dot 			*/
IGRdouble  v_len();		/* return scalar length of vector	*/
IGRboolean v_zero();		/* return TRUE if vector length = 0	*/
void m_mul_v();		/* multiply matrix times point (or vector)	*/
void mt_mul_v();	/* multiply transpose of matrix1 times vector	*/

/****************************************************************/
/* change coordinate system using a 4x4 matrix  		*/
/* call is ASmatv(flag,matrix,in,out)           		*/
/* flag int : binary composition of following flags 		*/
/* matrix *double : matrix definition				*/
/* in     *double : in vector or point				*/
/* out    *double : out vector or point 			*/
/****************************************************************/


#define ASMV_DIRECT 0     /* use this matrix */
#define ASMV_INVERT 1     /* use the inverse matrix */

#define ASMV_VECTOR 2     /* vector transformation  */
#define ASMV_POINT  4     /* point  transformation  */
void ASmatv();          
