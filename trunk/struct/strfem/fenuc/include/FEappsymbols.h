#ifndef FEappsymbols_included
#define FEappsymbols_included

/* Doc:  FEappsymbols.h

   Abstract: This file defines data types used for the common symbols
   	such as arrows.
	
   History:

	Date		Who		Why
	---------	------		----------------------------------
	06-08-89	ahs		Creation
*/
/* *****************************H H H H H******************************* */

/*	Size of symbol is defined by the following relationship:
		f : magnitude;	s : size;

			^
			|
		     s2	|        _______
			|       /
			|      /
			|     /
			|    /
		     s1	|---/
			| 
			------------------->
			    f1   f2
*/

struct	arrowparms {
	double		f1,f2,s1,s2;	/* defined above		*/
	double		hwid_to_len;	/* half width of arrow-head to
						head-length ratio 	*/
	};

#endif
