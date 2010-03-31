/* ###################   APOGEE COMPILED   ################## */
class specification GRbcsubbc (1:0) of GRsubbc;
/*
Abstract

	The class GRbcsubbc is a subclass of GRsubbc and is a 
	3-D double precision B-spline curve representation of a
	subcurve.

	No methods should ideally be declared at this class and the
	only methods which should override are those which require
	instance data access.

History

	SDG	03/24/86 : Initial creation
	rlw	03/30/87 : Totally redone -
                           1) Instance data is much different
                           2) Parentage has changed - removed GRgenbc
	rlw	12/16/87 : Removed override to EMputbcdef().
*/
instance GRbcsubbc
 {
  IGRuchar	dp_props;		/* Display properties.	*/
  IGRuchar	bc_props;		/* Bspline properties.	*/
  IGRuchar	order;			/* order of the curve */
  IGRuchar	reserved;		/* For later, padded anyway */
  IGRushort	num_poles;		/* number of poles */
  variable IGRdouble	packed_doubles[];	/* poles, weight, knots */
 };

/*

Further explanation of instance data. 
Note that keywords can be found in go/include/godef.h.

                Bit fields for dp_props
 
 bit     meaning                                keyword
 ---     -------                                -------
 0       is the polygon displayed?              GRIS_POLYDIS
 1       is the curve displayed?              	GRIS_CURVEDIS
 
                Bit fields for bc_props
 
 bit     meaning                                keyword
 ---     -------                                -------
 0       not used
 1       is the curve periodic?          	GRIS_PERIODIC
 2       is the knot vector non-uniform?	GRIS_NON_UNIFORM
 3       is the curve rational?               	GRIS_RATIONAL
 4       is the curve phy closed?		GRIS_PHY_CLOSED

*/
override

GRgenabsg; 
/*
  Motivation

  Fill in a message declaration.

  Files	
	GRbcscgenabs.I 
*/
#ifndef BASE_EMS
override
GRpostabsg, 
/*
  Motivation

  Fill in a message declaration.

  Files	
	GRbcscpostab.I 
*/
GRclipto, 
/*
  Motivation

  Fill in a message declaration.

  Files	
	GRbcscclipto.I
*/
GRputattr,
/*
  Motivation

  Fill in a message declaration.

  Files	
	GRbcscputat.I
*/
GRgetattr;
/*
  Motivation

  Fill in a message declaration.

  Files	
	GRbcscgetatt.I
*/

#endif
end specification GRbcsubbc;


