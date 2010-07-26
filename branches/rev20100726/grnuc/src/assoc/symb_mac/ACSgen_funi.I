/*
/*  History :
/*	LLC :- 15_9_90	 + creation date
/*
/* */

class implementation ACheader;

#define EXP_MAX_LEN 100

/*----------------------------------------------------------------------------*/
short int ACSlocate_pattern( Pattern, Source )

char *Pattern, *Source ;

/*----------------------------------------------------------------------------*\
 | Searches  "Source"  for  "Pattern" and returns the position in the  string |
 | where "Pattern"  begins  if found else -1. The algorithm is that of Knuth, |
 | Morris & Pratt.                                                            |
 |                                                                            |
 | INPUT: Pattern, pointer to pattern string                                  |
 |        Source , pointer to source string where "Pattern" is looked for     |
\*----------------------------------------------------------------------------*/

{ char          P_S[EXP_MAX_LEN+1]          ;
  short    int lP, m, Found, q[EXP_MAX_LEN] ;
  register int i, j                         ;

  lP = strlen( Pattern )                  ;
  m  = lP +  strlen( Source ) + 2         ;
  P_S[0] = '\0'                           ;
  strcat( P_S, " " )      ; strcat( P_S, Pattern ) ;
  strcat( P_S, "`" )      ; strcat( P_S, Source  ) ;
  Found = 0 ; q[1] = 0 ; q[2] = 1 ; j = 1 ; i = 2 ;
  while( i <= m && !Found )
                           { register char c ;
                             c = P_S[i]    ; P_S[0] = c    ;
                             while( c != P_S[j] ) j = q[j] ;
                             Found  =   j == lP            ;
                             q[++i] = ++j                  ;
                           } /* while */

quit:

  return( ( Found ) ? i - 2*lP - 2 : -1 ) ;

} /* locate */


/* ******************** get_dir () ***********************************	*/

get_dir( tot_path, beg_ind, end_ind, next_beg, dir )

IGRchar		*tot_path;
IGRint		beg_ind;
IGRint		end_ind;
IGRint		*next_beg;
IGRchar		*dir;
{
IGRint	tmp_ind;
IGRint	i;

	*next_beg = beg_ind;
	dir[0] = '\0';

	if( end_ind <beg_ind ){
		printf(" find delimiter pb \n");
		return	FALSE;
	}

	while( tot_path[beg_ind] != ':' && beg_ind < end_ind ) 
		beg_ind = beg_ind + 1;

	if( end_ind <= beg_ind ){ 
		printf(" no directory \n");
		return	FALSE;
	}	
	tmp_ind = beg_ind;

	// find second :
	beg_ind = beg_ind + 1;
	while( tot_path[beg_ind] != ':' && beg_ind < end_ind ) 
		beg_ind = beg_ind + 1;

	if( end_ind <= beg_ind ){ 
		/*| no more directory */
		return	TRUE;
	}	

	*next_beg = beg_ind;
	for( i=0; i<beg_ind; i=i+1 )	dir[i] = tot_path[i];

	dir[i] = '\0';

	/*" dir : %s\n", dir */

return	TRUE;
}

end implementation ACheader;

