/* $Id: VRsimplex.C,v 1.4 2001/03/10 16:06:52 ad Exp $ pinnacle */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconstrain / VRsimplex.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRsimplex.C,v $
 *	Revision 1.4  2001/03/10 16:06:52  ad
 *	Add some tuning inside the VRsimplex routine.
 *	
 *	Revision 1.3  2001/02/20 01:13:06  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.2  2001/01/12 16:03:06  anand
 *	SP merge
 *	
 * Revision 1.2  2000/07/10  19:37:52  pinnacle
 * Replaced: route/vrconstrain/VRsimplex.C for:  by apazhani for Service Pack
 *
 * Revision 1.1  2000/07/10  19:34:26  pinnacle
 * Created: route/vrconstrain/VRsimplex.C by apazhani for Service Pack
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.2  1998/01/16  20:42:02  pinnacle
 * Replaced: vrconstrain/VRsimplex.C for:  by kddinov for route
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.1  1996/07/25  18:25:44  pinnacle
 * Creation of Route 241 project
 *
 * Revision 1.3  1996/04/05  17:54:00  pinnacle
 * Replaced: vrconstrain/VRsimplex.C for:  by msmanem for route240
 *
 * Revision 1.2  1996/01/16  22:12:34  pinnacle
 * Replaced: vrconstrain/VRsimplex.C for:  by r240_int for route240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	01/16/96	tlb	Add prototypes
 *	Jan-98		kdd	added OMminimum.h for compilation problems.
 *	Jul-10		alwin	Check to prevent infinite looping. TR179901743
 *	03/10/01	adz	Adjust solver processing MP4829. Add stop sign
 *
 *************************************************************************/
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "OMminimum.h"
#include "OMerrordef.h"
#include "AS_status.h"

//#include "v_miscmacros.h"
#include "VDmem.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"

#include "vrconstr_pto.h"

extern	IGRboolean	IGEstop();

/*===========================================================================*/
/*									     */
/*                          Macro definition                                 */
/*---------------------------------------------------------------------------*/
/*									     */
/*									     */

#define test_tolerance 1.e-6      /* to limit the space of the solutions     */
#define test_b_bar     1.e-10     /*  to approximate the zero                */

#define AS_DEBUG

/*===========================================================================*/


/*===========================================================================*/
/*                                                                           */
/*		    internal function determination_an                       */
/*                                                                           */
/*	  Cette fonction  permet de calculer la sous matrice                 */
/*	des vecteurs de A qui n'appartiennent pas a la base realisable       */
/*                                                                           */
/*===========================================================================*/

VRsimplex_determination_an ( a, cn, n_base, an, m, n )

 double   a[];		/* IN   array of the matrix of the canonical system   */
 double   *cn;		/* IN   pointer to the non_base coefficient of the    */
			/*      function to optimise  Z		              */
 double   *an;		/* OUT  pointer to the matrix of the non_base         */
 int      *n_base;	/* IN   pointer to n_base 			      */
 int      m;		/* IN   number of the n_base's elements               */
 int      n;		/* IN   number of constrains  			      */

	{

	 int i, k;
	
		for( k = 0; k< m; k++)
		 {
			for ( i = 0; i< n; i++)
			 {
				an[i * m + k] = a[i * ( m + n ) + n_base[k]];
			}
		}
	}

/*===========================================================================*/

/*---------------------------------------------------------------------------*/
/*                                                                           */
/*		       internal function cout_reduit                         */
/*                                                                           */
/*	cette fonction calcule les differents couts reduits { cn_bar}        */
/*	et selectionne le plus negatif                                       */
/*	  Le vecteur correspondant entre alors dans la base realisable       */
/*                                                                           */
/*---------------------------------------------------------------------------*/


VRsimplex_cout_reduit( d, an, cb, cn, m, n, probleme,s, pi, pi_bar, cn_bar )

 double     *d;		/* IN  pointer to the matrix of the base	     */
 double	   *cb;		/* IN  pointer to the base's cofficient of Z	     */
 double	   *cn;		/* IN  pointer to the n_base's coifficient of Z      */
 double    *an; 	/* IN  pointer to the matrix of the n_base           */
 double	   *pi;		/* Internal pointer to variable used to calculate    */
			/* cn_bar                                            */
 double     *pi_bar;	/* Internal pointer to variable used to calculate    */
			/* cn_bar                                            */
 double     *cn_bar;	/* Internal pointer to find *s			     */
 int        *probleme;	/* OUT  used to stop the execution of this fonction  */ 
			/*      if there is some problems                    */
 int	   *s;		/* OUT  returns the element of the n_base chosen to  */
			/*      to become in the base                        */ 
 int        m;		/* IN  number of the n_base's elements		     */
 int	   n;		/* IN  number of constraints			     */

  {
	int i, k;
	double cs;      /* varible to find the greater value of *s	     */
	
	cs = 0;

/*----------------------------------------------------------------------------*/
/*--------------- 	calcul des cn_bar        ---------------------------- */

	*s = m + 1;
	for ( i = 0 ; i < n ; i++ )
	{
		*(pi+i) = 0;
		for ( k = 0 ; k< n ; k++ ) {
			*(pi + i ) += cb[k] * d[(k * n) + i];
		}
	}

	for ( i = 0 ; i < m ; i++ )
	{
		*(pi_bar + i ) = 0;

		for ( k = 0; k < n ; k++)
		{
			*(pi_bar + i ) += *(pi + k ) * an[(k* m)+ i];
		}

		*(cn_bar + i) = cn[i] - *(pi_bar + i);


/*--------------------------------------------------------------------------*/
/* ---------------  la recherche de l'element le plus negatif   ------------*/   
	
	
		if ( *(cn_bar + i) < cs)
		{
			cs = *(cn_bar + i);
			*s = i;
		}
	}
	if ( cs == 0 )
	{
		*s = m + 1;
		return 0 ;
	}	

}


/*===========================================================================*/


/*---------------------------------------------------------------------------*/
/*                                                                           */
/*			internal function rentre                             */
/*                                                                           */
/*	Cette fonction calcule les differentes valeurs de as_bar             */
/*	et b_bar puis selectionne le vecteur qui rentre dans la              */
/*	base en cherchant le minimum positif de b_bar[i]\as_bar[i]           */
/*                                                                           */
/*---------------------------------------------------------------------------*/


VRsimplex_rentre (a, d, b_bar, as_bar, s, m, n, r, n_base)

 double     a[];	/* IN  array of the matrix of the canonical system   */ 
 double     *d;		/* IN  pointer to the matrix of the base	     */
 double     *b_bar;	/* IN/OUT pointer to vector solution in this step    */
 double     *as_bar;	/* OUT pointer to a d * as vector where as is the    */
			/*    column s of the matrix a			     */	
 int        *s;		/* IN shows the element to get in base		     */
 int        *r;		/* OUT shows the element that quit the base	     */
 int        *n_base;	/* IN  pointer to the n_base			     */
 int        m;		/* IN  the number of the n_base's elements	     */
 int	   n;		/* IN  the number of constrains			     */

{

	double xr;
	int i, k, optimum_borne, mn;

	mn = m + n;
	xr = 0;	 
	*r = n + 1;
	optimum_borne = 0;

	for (i = 0; i< n; i++)
	{
		as_bar[i] = 0;

		for ( k= 0; k< n; k++)
		{
			if ( a[(k * mn) + n_base[*s]] != 0 )
			{
    				as_bar[i] += d[(i* n) + k] * a[(k * mn) +  n_base[*s]];
			}
		}

		if ( *(as_bar + i) > test_tolerance )
		{
			optimum_borne = 1;
			xr = b_bar[i] / *(as_bar + i);
			*r = i;	
		}
	}

	if (optimum_borne == 0)
	{ 
		*r = n + 1;
		return 0 ;
	}

	for ( i = 0; i< n ; i++ )
	{
		if ( as_bar[i] > test_tolerance )
		{
			if ( b_bar[i] / *(as_bar + i) <= xr)
			{
				xr = b_bar[i] / *(as_bar + i);
				*r = i;
			}
		}
	}
}

		
/*===========================================================================*/

/*---------------------------------------------------------------------------*/
/*                                                                           */
/*			internal function change                             */ 
/*                                                                           */
/*	cette fonction fait le changement de base et calcule la              */
/*	nouvelle matrice de passage et la nouvelle base                      */
/*                                                                           */ 
/*---------------------------------------------------------------------------*/



VRsimplex_change( d, b_bar, as_bar, r, s, n, base, n_base, cb, cn, probleme, db )

 double     *d;		/* IN/OUT pointer to the invers of the matrix of    */
			/*        the base				    */
 double	   *b_bar;	/* IN  pointer to the current solution of this step */
 double     *as_bar;	/* IN  pointer to the vector used to change d	    */
 double	   *cb;		/* IN/OUT pointer to the base's coefficient of Z    */
 double     *cn;	/* IN/OUT pointer to the n_base's coefficient of Z  */
 double     *db;	/* Internal pointer used to change d		    */
 int        *r;		/* IN pointer to integer that swos wich variable    */
			/*    quit the base    				    */ 
 int        *s;		/* IN pointer to integer that shows wich variable   */
			/*    get in to the base			    */
 int        *base;	/* IN/OUT pointer to the different elements of base */
 int        *n_base;	/* IN/OUT pointer to the elements of the n_base     */
 int        *probleme ;	/* OUT  used to stop the execution of this function */
			/*      if ther is some problems		    */
 int        n ;		/* IN   the number of constrains		    */

{

	int i, k, sw;
	double  aw;
	

	for ( i = 0; i < n ; i++)
	{
		if ( i != *r ){
			  b_bar[i] =  b_bar[i] - ( as_bar[i] / as_bar[*r] ) * b_bar[*r] ;
		}
		if ( b_bar[i] < - test_b_bar )
		{
			 /*" PROBLEME : b_bar[%d] est negatif et vaut %f \n", i, b_bar[i] */
			  *probleme = 1;
			  return ( *probleme );
		}
			 	
		for ( k= 0; k< n; k++) 
		{
			if ( i != *r)
			{	
			
				db[i * n + k] = d[i * n + k] - (*(as_bar + i ) / *(as_bar + *r )) * d[ *r * n + k];


			}
				db[ *r * n + k] = d[ *r * n + k] / *(as_bar + *r);

		}
	}

	b_bar[ *r ] =  b_bar[ *r ] / as_bar[ *r ];

	for ( i = 0; i < n * n ; i++) 
	{
		d[i] = db[i];
	}
	
	sw = *(base + *r );
	*(base + *r) = *(n_base + *s );
	*(n_base + *s) = sw;

	aw = *(cb + *r);
	*(cb + *r) = *(cn + *s);
	*(cn + *s) = aw;
}


/*===========================================================================*/

/*---------------------------------------------------------------------------*/
/*                                                                           */
/*                        function simplex revised                           */
/*                                                                           */
/*---------------------------------------------------------------------------*/


VRsimplex( nb_unkn, nb_constr, Matrix, vector)

double    *Matrix, *vector;
int       nb_unkn, nb_constr;

/*  nb_unkn    : number of inital variables                                 */

/*  nb_constr  : number of constrain                                        */

/*  matrix     :If the base matrix is a N*M matrix, Matrix will be (N+1)*M  */
/*              in the last row, we have the elements of the function to    */
/*              maximise.                                                   */
/*              The result will be the first M values of Matrix.            */

/*  vector     :The dimension of the vector is 2*N :                        */
/*              the first N values are the b[i], terms of Ax = b            */
/*              the other values correspond to the inequalities . The       */
/*		 convention is :                                            */           
/*              <= , -1             = , 0               => , 1              */

{

	double    *sim_buff1 = NULL; /* array containing all the doubles    */
	int 	  *sim_buff2 = NULL; /* array containing all the integers   */
	int	  max_size1 ;
	int 	  max_size2 ;


	int       m, n, s, r, probleme;
	int       q;           /* number of the artificial variables       */
	int       i, k, j, l;
	double    mu;          /* the artificial variable's coefficient of */
			       /* the fonction to optimise. it must be     */
			       /* very bigger than the others cefficient   */
			       /* to obtain zero us a result of the	   */
			       /* artificial variable ( mu >> 0 )          */
 	
	double    *as_bar, *b_bar, *d, *an, *cn, *cb, *a, *db, *pi, *pi_bar, *cn_bar;
	int       *base, *n_base ;
	int		nCounterToAbort;
	char		infoBuf[1000];
 
	SetProc( Fn VRsimplex ); Begin 

	n = nb_constr;         /* for each constrain we have one row !!    */


	q = 0;

	for ( i = 0; i< nb_constr; i++ )
	{
		if ( vector[i] < 0 )
		{
			vector[i] = - vector[i];
			vector[ i + n] = - vector[ i + n];
			for ( k = 0; k < nb_unkn; k++ )
			{
				Matrix[ i*nb_unkn + k] = - Matrix[ i*nb_unkn + k ];
			}
		}
	}

	for ( i= 0; i< n; i++ )
	{
		if ( vector[ n + i ] == 1 )
		{
			q = q + 1;
		}
	}

	s = 0;
	r = 0;
	probleme = 0;	
	m = nb_unkn + q;      /* number of the elements of the non_base    */

	max_size1 =  3*n*n + 2*n*m + 3*m + 4*n ;
	max_size2 =  n + m ;

	/* sim_buff1 = ( double *) malloc( max_size1 * sizeof ( double)) ;
	 * sim_buff2 = ( int * ) malloc( max_size2 * sizeof ( int ));
	 */

	__DBGpr_com( " Allocating Memory for sim_buff's " );
	sim_buff1 = _MALLOC ( max_size1, double );
	sim_buff2 = _MALLOC ( max_size2, int );

	if ( sim_buff1 == NULL  ||  sim_buff2 == NULL )
	{
		__DBGpr_com( " malloc failed " );
		End
		return ( s = m + 2 );
	}


/*-------------------------------------------------------------------------*/
/* ---------------------    initialisation of a    ------------------------*/

	a = sim_buff1;


	for ( i= 0; i< (n + m ) * n; i++ )
	{
		a[i] = 0;
	}
	

	l = 0;
	for ( i= 0; i< n; i++ )
	{
		for ( k = 0; k < nb_unkn; k++ )
		{
			a[ i * ( n + m ) + k ] = Matrix[ i * nb_unkn + k ];
		}
	
		a[ i * ( n + m ) + m + i ] = 1;
		if ( vector[ i + n ] == 1 )
		{
			a[ i * ( n + m ) + nb_unkn + l ] = -1;
			l += 1;
		}
	}

/*-------------------------------------------------------------------------*/
/*----------------------   initialisation of cn   -------------------------*/
	
	cn = sim_buff1 + ( n*n + 2*n*m );
	mu = 1;
	for ( i= 0; i< nb_unkn; i++ )
	{
		cn[i] = - Matrix[ ( n * nb_unkn ) + i ];
		mu    = mu + fabs( cn[i] );
	}
	
	mu = 100 * mu;

	for ( i= 0; i< q; i++ )
	{
		cn[ nb_unkn + i ] = 0;
	}


/*---------------------------------------------------------------------------*/
/*----------------------  initialisation of cb   ----------------------------*/


	cb = sim_buff1 + ( n*n + 2*n*m + m );
	for ( i= 0; i< n; i++ )
	{
		cb[i] = 0;
		if ( vector[ n + i] != -1 )
		{
			cb[i] = mu;
		}
	}

/*---------------------------------------------------------------------------*/
	


	d = sim_buff1 + ( n*n + 2*n*m + m + n );
	b_bar = sim_buff1 + ( 3*n*n + 2*m*n + 3*m + 2*n );
	base  = sim_buff2;

	for ( i= 0; i< n * n; i++) { d[i] = 0;} 
	for ( i = 0; i < n; i++) 
	{
		d[i * n + i] = 1;
		b_bar[i] = vector[i];
		base[i] = m + i;
	}

	n_base = sim_buff2 + n ;
	for ( i= 0; i< m; i++ )
	{
		n_base[i] = i;
	}

	an = sim_buff1 + ( n*n + n*m );
	db = sim_buff1 + ( 2*n*n + 2*n*m + m + n );
	pi = sim_buff1 + ( 3*n*n + 2*n*m + m + n );
	pi_bar = sim_buff1 + ( 3*n*n + 2*n*m + m + 2*n );
	cn_bar = sim_buff1 + ( 3*n*n + 2*n*m + 2*m + 2*n );
	as_bar = sim_buff1 + ( 3*n*n + 2*n*m + 3*m +3*n );
	


/*----------------------      SOLVING     -----------------------------------*/

/*                      ------------------                                   */


	__DBGpr_com( " Solving the Equations ... " );
	nCounterToAbort = 0;

	UI_status( "Processing .. .. ..");

	while ( s <= m  &&  r <= n) 
	{
		sprintf( infoBuf, " Process[s<=m && r<=n]: %d, %d, %d, %d, %d ", 
			s, m, r, n, nCounterToAbort );

		__DBGpr_str( " process", infoBuf );

		nCounterToAbort++;

		if( IGEstop() )
		{
		    End
		    return OM_E_INVARG;
		}

		if( nCounterToAbort > 10000 )
		{
		    End
		    return OM_E_INVARG;
		}

		VRsimplex_determination_an ( a, cn, n_base, an, m, n ); 
		__DBGpr_dbl( " Determinant ", *an );
	
		VRsimplex_cout_reduit( d, an, cb, cn, m, n, &probleme, &s, pi, pi_bar, cn_bar ) ;
		__DBGpr_int( " prombleme value ", probleme );
		__DBGpr_int( " s value ", s );
	
		if ( s < m+1 ) 
		{
			VRsimplex_rentre (a, d, b_bar, as_bar, &s, m, n, &r, n_base);
			if ( r < n + 1 )
			{	
				VRsimplex_change( d, b_bar, as_bar, &r, &s, n, base, n_base, cb, cn, &probleme, db);
				if ( probleme == 1) 
				{
					s = m + 2;
				} /* end of if probleme == 1 */
			}  /* end of if r < n + 1 */
		}  /* end of if s < m + 1 */

	}  /* end of while */

	UI_status( "");

/* end of the resolution of the system by the revised simplex method         */



/*----------------------     load the result    -----------------------------*/

/*                      ------------------------                             */

	
/*   the result is loaded in the nb_constr first elements of Matrix           */

/*---------------------------------------------------------------------------*/

	if ( probleme != 1 )
	{

		for ( i = 0; i< nb_unkn ; i++)
		{
			Matrix[i] = 0;
		}
	

		for ( i = 0; i < n; i++) 
		{
			if ( base[i] < nb_unkn )
			{
				Matrix[ base[i] ] = b_bar[i];
			}
	
		}
	}
	
	/*free ( sim_buff1 );
	 *free ( sim_buff2 );		
 	 */
	_FREE ( sim_buff1 );
	_FREE ( sim_buff2 );

	End
	return OM_S_SUCCESS;		

}  /* end of the function VRsimplex */


/*===========================================================================*/
/*---------------------------------------------------------------------------*/
/*===========================================================================*/
