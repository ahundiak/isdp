/* Copyright (C) 1996, 1997, Intergraph Corporation. All rights reserved. */

#ifndef maerr_include
#define maerr_include

/*
 * errors
 */
#define	MAOVF	  	0X8018322    	/* overflow or underflow	*/
#define MANEGSRT  	0X801832A	/* negative input to square root*/
#define MAZDIV	  	0X8018332	/* divide by zero		*/
#define MADGENRAT 	0X801833A	/* degenerate case- error       */
#define MANONPLANAR	0X8018372	/* non planar			*/
#define MAEINFSOLUTION  0X8018382	/* infinite solution		*/
#define MANOPROJECT	0X801839A	/* projection failed		*/
#define MANOTCOMPLETE	0X80103A2	/* processing not complete	*/
/*
 * severe errors
 */
#define MASDGENRAT 	0X8018344	/* degenerate case- severe error*/
#define MADDNE	  	0X801834C	/* derivative does not exist	*/
#define MAKNTI	 	0X801835C 	/* knot index could not be found*/
#define MANOSOLUTION 	0X801837C  	/* no solution could be determined*/
#define MANOMEMORY	0X8018394	/* no memory could be allocated */
/* 
 * information
 */
#define MAINFSOLUTION 	0X8018363	/* infinite number of solutions */
#define MAIDGENRAT      0X801836B	/* degenerate case 		*/
#define MAINOTUNIQUE	0X801838B	/* more solutions exist than the
					 * one located.			*/
#endif /* maerr_include */
