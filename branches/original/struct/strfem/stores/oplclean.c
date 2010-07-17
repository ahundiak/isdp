#include <stdio.h>
#include <string.h>
char *substr( s1, s2 )
  char *s1, *s2;
{
  int i, l1, l2;
  l1 = strlen( s1 );
  l2 = strlen( s2 );
  if( l2 < l1 ) return( 0 );
  else {
    for( i = 0; i <= ( l2 - l1 ); i++ ) {
      if( ! strncmp( s1, &s2[i], l1 ) ) return( &s2[i] );
    }
  }
  return( 0 );
}

main (argc, argv)
  int   argc;
  char *argv[];
{
  FILE *infp, *outfp;
  char line[2000], **product;
  int  first_fun = 1, first_fun_p = 1, first_uword = 1;
  int nbProds = argc - 3 ; int i ;

  if (argc < 3) {
      fprintf(stderr,
      	"usage %s <Product1> <Product2> ... <ProductN> <input file> <output file>\n",argv[0]);
      exit(0);
    }
  product = argv + 1 ;
  infp = fopen (argv[argc-2], "r");
  if (! infp) {
    fprintf (stderr, "%s: cannot read file %s\n", argv[0], argv[2]);
    exit (1);
    }
  outfp = fopen (argv[argc-1], "w");
  if (! outfp) {
    fprintf (stderr, "%s: cannot write file %s\n", argv[0], argv[3]);
    exit (1);
    }


  fprintf(stderr," %d Product(s)= >", nbProds ) ;

  for(i=0;i<nbProds;i++) fprintf(stderr, "%s ", product[i] ) ;
 
  fprintf(stderr, "< input file = >%s< output file = >%s<\n",
          argv[argc-2],argv[argc-1]);

  while ( fgets( line, 1025, infp)) {
     line[strlen(line)-1] = 0;
     if ( substr ( "int ", line ) ) {
     	for(i=0;i<nbProds;i++) {
	       if ( substr( product[i], line )) {
        		 fprintf(outfp, "%s\n", line );
		         first_fun = 0;
		         break ;
	       }
	}
     }
     else if ( substr ( "OM_p_FUNCPTR", line ) ) {
         fprintf(outfp, "%s\n", line );
         if ( first_fun_p )
           fprintf(outfp, " {\n" );
         first_fun_p = 0;
         }
     else if ( substr ( "OMuword", line ) ) {
       		if ( first_uword ) {
         		fprintf(outfp,"\n 0\n };\n");
         		first_uword = 0;
         	}
         	for(i=0;i<nbProds;i++) {
	       		if ( substr( product[i], line )) {
	        		 fprintf(outfp, "%s\n", line );
	        		 break ;
			}
		}
     }
     else if ( !first_fun_p ) {
     	for(i=0;i<nbProds;i++) {
     		if ( substr( product[i], line )) {
        		 fprintf(outfp, "%s\n", line );
        		 break ;
        	}
	}
     }
     else if ( first_fun )
         fprintf(outfp, "%s\n", line );
  }
}
