#include <stdio.h>
#include <ctype.h>


/*
  This is a sample program which can be used for converting database
  tables form SEACOSD to STRFEM format
*/


void delete_blanks ();


#define  CS_AREA	0
#define  IZZ		1
#define  IYY		2
#define  IZY		3
#define  JXY		4
#define  TORS_CONST	5
#define  SHEAR_Y	6
#define  SHEAR_Z	7
#define  WARP_COEFF	8
#define  P_PARTTYPE	9

#ifndef TRUE
#define TRUE  1
#endif

#ifndef FALSE
#define FALSE 0
#endif

main()
{

char  output_file[81];
char  file_str[201],input_files[200][201];
char  option[81], c, overwrite, units;
char  system_str[81], tmp_str[81], input_str[81], *equal_ptr;
int   no_files, ii, jj;

double  izz, iyy;

FILE  *pif, *pof, *ptmp;

char  defined[10];




     printf("************************************************************\n");
     printf("   This program converts .p files of beams sections of\n");
     printf("   I/STRUCT product into prism_beam.p files which can be\n");
     printf("              used for  STRFEM\n");
     printf("************************************************************\n");
     printf("\n\n\n\n");

get_units:
      printf("\tEnter units\n\t  English(e)/ Metric(m) [e] ? ");
      gets( option );
      c = option[0];

      if ( c != '\0' && c != 'E' && c != 'e' && c != 'I' && c != 'i'
	   && c != 'M' && c != 'm' )  goto get_units;

      if ( c == '\0' || c == 'E' || c == 'e' || c == 'I' || c == 'i' )
	  units = 'E';
      if ( c == 'M' || c == 'm' )
	  units = 'M';


      printf("\tEnter input files : ");
      gets( file_str );
/*
      printf("input files : [%s]\n", file_str );
*/

      printf("\tEnter output file : ");
      gets( output_file );
/*
      printf("output_file : [%s]\n", output_file );
*/

get_option:
      printf("\tAppend (a)/ Overwrite (o) ? [a] : ");
      gets( option );
      c = option[0];

      if ( c != '\0' && c != 'a' && c != 'A'
	   && c != 'o' && c != 'O' )  goto get_option;

      if ( c == '\0' || c == 'a' || c == 'A' )
	   overwrite = 0;
      else
	   overwrite = 1;
/*
      printf(" overwrite = [%d]\n", overwrite );
*/     
      /* make a list of files */
      strcpy( system_str, "ls " );
      strcat( system_str, file_str );
      strcat( system_str, " > /usr/tmp/file_list" );

      system ( system_str );

      
      ptmp = (FILE *) fopen ( "/usr/tmp/file_list", "r" );

      no_files = 0;
      while ( fgets ( input_files[no_files], 200, ptmp ) != NULL )
	no_files++;
      fclose ( ptmp );
/*
      printf("No. of files = [%d]\n", no_files );
      for ( ii=0; ii < no_files; ii++ )
         printf( " file[%d] : [%s]\n", ii, input_files[ii] );
*/

      /* open output file */
      if ( overwrite )
        pof = (FILE *) fopen ( output_file, "w" );
      else
        pof = (FILE *) fopen ( output_file, "a" );


      /*   convert the files  */

      for ( ii=0; ii < no_files; ii++ )
      {

	/* open input file */
	pif = (FILE *) fopen ( input_files[ii], "r" );
        if ( pif == NULL )
        {
	   printf("Can not open file [%s] for reading\n", input_files[ii] );
	   continue;
        }

        while ( 1 )
	{
	   if ( fgets ( tmp_str, 81, pif ) == NULL ) break;

	   /* deltes all the blank chars from tmp_str */
	   delete_blanks ( tmp_str, input_str );
/*
	   printf(" tmp_str = [%s]\n", tmp_str );
	   printf(" input_str = [%s]\n", input_str );
*/
	   switch ( input_str[0] )
	   {
	     case '[' :
			fprintf( pof, "[\n");
			fprintf( pof, "n_catalogname=prism_beam\n");
			izz = iyy = -1.0;
			for ( jj=0; jj<10; jj++)
			   defined[jj] = FALSE;

			break;
	     case ']' :
			if ( izz != -1.0 && iyy != -1.0 )
			{   fprintf ( pof, "jxy=%f\n", izz+iyy );
			    defined[JXY] = TRUE;
			}

			if ( !defined[P_PARTTYPE] )
				fprintf( pof,"p_parttype='P'\n");

			if ( !defined[CS_AREA] )
				fprintf( pof,"cs_area=-1.E100\n");
			if ( !defined[IZZ] )
				fprintf( pof,"izz=-1.E100\n");
			if ( !defined[IYY] )
				fprintf( pof,"iyy=-1.E100\n");
			if ( !defined[IZY] )
				fprintf( pof,"izy=-1.E100\n");
			if ( !defined[JXY] )
				fprintf( pof,"jxy=-1.E100\n");
			if ( !defined[TORS_CONST] )
				fprintf( pof,"tors_const=-1.E100\n");
			if ( !defined[SHEAR_Y] )
				fprintf( pof,"shear_y=-1.E100\n");
			if ( !defined[SHEAR_Z] )
				fprintf( pof,"shear_z=-1.E100\n");
			if ( !defined[WARP_COEFF] )
				fprintf( pof,"warp_coeff=-1.E100\n");
			if ( units == 'E' )
				fprintf( pof,"unit='E'\n");
			else
				fprintf( pof,"unit='M'\n");

			fprintf( pof, "n_cofilename='tmp'\n");
			fprintf( pof, "]\n");
			break;
	   }


	   if ( !strncmp ( input_str, "n_catalogname", 13 ) )
	   {
		equal_ptr = (char *)strchr( input_str, '=' );
		fprintf( pof, "n_itemname='%s'\n", &equal_ptr[1] );
	   }

	   if ( !strncmp ( input_str, "n_itemname", 10 ) )
	   {
		equal_ptr = (char *)strchr( input_str, '=' );
		fprintf( pof, "n_itemrev=%s\n", &equal_ptr[1] );
		fprintf( pof, "n_itemdesc=''\n" );
		fprintf( pof, "n_creator='Seacosd'\n" );
		fprintf( pof, "n_creationdate='10/11/94'\n" );
	   }

	   if ( !strncmp ( input_str, "p_parttype", 10 ) )
	   {
		equal_ptr = (char *)strchr( input_str, '=' );
		fprintf( pof, "p_parttype=%s\n", &equal_ptr[1] );
		defined[P_PARTTYPE] = TRUE;
	   }

	   if ( !strncmp ( input_str, "A=", 2 ) )
	   {
		equal_ptr = (char *)strchr( input_str, '=' );
		fprintf( pof, "cs_area=%s\n", &equal_ptr[1] );
		defined[CS_AREA] = TRUE;
	   }

	   if ( !strncmp ( input_str, "XI=", 3 ) )
	   {
		equal_ptr = (char *)strchr( input_str, '=' );
		fprintf( pof, "izz=%s\n", &equal_ptr[1] );
		sscanf ( &equal_ptr[1], "%lf", &izz );
/*
		printf("izz = [%lf]\n", izz );
*/
		defined[IZZ] = TRUE;
	   }

	   if ( !strncmp ( input_str, "YI=", 3 ) )
	   {
		equal_ptr = (char *)strchr( input_str, '=' );
		fprintf( pof, "iyy=%s\n", &equal_ptr[1] );
		sscanf ( &equal_ptr[1], "%lf", &iyy );
/*
		printf("iyy = [%lf]\n", iyy );
*/
		defined[IYY] = TRUE;
	   }

	   if ( !strncmp ( input_str, "J=", 3 ) )
	   {
		equal_ptr = (char *)strchr( input_str, '=' );
		fprintf( pof, "tors_const=%s\n", &equal_ptr[1] );
		defined[TORS_CONST] = TRUE;
	   }
	   if ( !strncmp ( input_str, "CW=", 3 ) )
	   {
		equal_ptr = (char *)strchr( input_str, '=' );
		fprintf( pof, "warp_coeff=%s\n", &equal_ptr[1] );
		defined[WARP_COEFF] = TRUE;
	   }

	} /* while ( 1 ) */

	fclose ( pif );

    }   /*  for ( ii=0; ii < no_files; ii++ ) */


  fclose ( pof );

}


void delete_blanks ( char *tmp_str, char *input_str )
{

int  ii, jj, len;

   len = strlen ( tmp_str );

   jj=0;
   for ( ii=0; ii< len; ii++ )
   {
	if ( !isspace ( tmp_str[ii] ) )
	{ input_str[jj] = tmp_str[ii];
	  jj++;
        }
   }

   input_str[jj] = '\0';
}
