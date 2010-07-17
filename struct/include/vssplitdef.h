/*
	I/STRUCT
	Options for macros which split curves with a surface.
*/


#ifndef vssplitdef_include
#	define vssplitdef_include


#define 	VS_K_CONSASANINFPLANE	0x001	/* Spliting plane surface is  */
						/* considering as an infinite */
						/* plane ( default option ).  */

#define 	VS_K_CONSNORMALSURF	0x002	/* No considerations for      */
						/* spliting surfaces.	      */

#define 	VS_K_SETCURVORIENT	0X004	/* Set good orientation for   */
						/* result curve ( default     */
						/* option ).		      */

#define 	VS_K_COPYCURVEORIENT	0x008	/* Set orientation for result */
						/* curve same as original     */
						/* curve.		      */


/*
	Examples :

		Macro vs$delimit_curve_by_two_surfaces :

		Result curve is the curve between surf[0] and surf[1].

			| Orientation of result curve with option
			| VS_K_COPYCURVEORIENT
			|
			|    | Orientation of result curve with option
			|    | VS_K_SETCURVEORIENT according with the surface
			|    | position
			v    v
		-->--|-->----<----|-----      <-- Original curve

		     ^		  ^
		     |		  |
		    surf[1]      surf[0]


		__________________________ Result curve with option
		|		  |	   VS_K_CONSNORMALSURF
		v		  v
		     _____________________  Result curve with option
		     |		  |	    VS_K_CONSASANINFPLANE
		     v		  v
		-->---------------|---	    <-- Original curve

		     |

		     ^		  ^
		     |		  |
		    surf[0]      surf[1]

*/


#endif
