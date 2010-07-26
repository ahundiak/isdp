//
//	Macros For Command Language
//	For Vector Manipulations
//
//	File dependency: none.


#ifndef cimath_include
#define cimath_include

//	identity vector	 
#define v_identity(V) \
	(V)[0]=0.; \
	(V)[1]=0.; \
	(V)[2]=0.; 


//     equality of vector 
#define v_equal(v1,v2) \
	(v2)[0] = (v1)[0] ; \
	(v2)[1] = (v1)[1] ; \
	(v2)[2] = (v1)[2] ;


//	multiply vector times scalar
#define v_scale(v,s,V) \
	(V)[0]=(v)[0]*(s); \
	(V)[1]=(v)[1]*(s); \
	(V)[2]=(v)[2]*(s); 

//	negate a vector	
#define v_neg(v,V) \
	(V)[0]= -(v)[0] ; \
	(V)[1]= -(v)[1] ; \
	(V)[2]= -(v)[2] ; 

//	add vector1 plus vector2
#define v_add(v1,v2,V) \
	(V)[0]=(v1)[0]+(v2)[0]; \
	(V)[1]=(v1)[1]+(v2)[1]; \
	(V)[2]=(v1)[2]+(v2)[2];

//	subtract vector1 minus vector2
#define v_sub(v1,v2,V) \
	(V)[0]= (v1)[0] - (v2)[0]; \
	(V)[1]= (v1)[1] - (v2)[1]; \
	(V)[2]= (v1)[2] - (v2)[2];

//	linear combination of 2 vectors
#define v_comb(s1,v1,s2,v2,V) \
	(V)[0]= (s1)*(v1)[0] + (s2)*(v2)[0] ; \
	(V)[1]= (s1)*(v1)[1] + (s2)*(v2)[1] ; \
	(V)[2]= (s1)*(v1)[2] + (s2)*(v2)[2] ;

//	vector cross product of vector1 and vector2
//	V must be different of v1 and v2
#define v_cross(v1,v2,V) \
	(V)[0]= (v1)[1]*(v2)[2] - (v1)[2]*(v2)[1] ; \
	(V)[1]= (v1)[2]*(v2)[0] - (v1)[0]*(v2)[2] ; \
	(V)[2]= (v1)[0]*(v2)[1] - (v1)[1]*(v2)[0] ;

//	returns scalar dot product of vector1 and vector2
#define v_dot(v1,v2) ( (v1)[0]*(v2)[0] + (v1)[1]*(v2)[1] + (v1)[2]*(v2)[2] )

//	returns scalar length of vector
#define v_len(v) sqrt( (v)[0]*(v)[0] + (v)[1]*(v)[1] + (v)[2]*(v)[2] )

//	return TRUE if vector length = 0, else return FALSE
#define v_zero(v) ( (v)[0]==0 && (v)[1]==0 && (v)[2]==0 )

#endif
