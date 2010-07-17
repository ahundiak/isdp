#ifndef vr_assert
#define vr_assert	1

/*  VRassert: Macro definition 
*   Example
*	if ( VRassert( "John" == "John") ) ;
*	if ( VRassert( sts&1) ) {status = 2; goto wrapup;} 
*/

#define VRassert(x)  ( (x) ?  (int) 0 : (int) \
        printf("\nError in %s, line %d, Expr:(%s)\n", __FILE__, __LINE__, #x))

#endif

