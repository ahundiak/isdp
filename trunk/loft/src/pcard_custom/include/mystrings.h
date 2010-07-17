/***************************************************************************
 * C
 *
 * File:        mystrings.h
 *
 * Description:	file contains additional string functions
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      12/18/97        maciek          creation date
 *
 ***************************************************************************/

// DEBUG INFO
//***********

#define DEBUG 


#ifndef mystring_include
#define mystring_include

//#include	<stdio.h>
//#include        <stdarg.h>

/* C externs */

extern calloc(), realloc(), gcvt();
extern GRdisplay_object();

/*----------------------------------------------------------------------------
 * Function gets word w with index n from string s separated by sep.
 *----------------------------------------------------------------------------*/

char * word( str, word, index, sep, blanks )
  char *str;   // Input line 
  char *word;   // Output word
  int   index;   // Word index in input line 
  int   sep; // Separator sign 
  int   blanks; // Leave blanks?
{
  char *ptr, aux_str[50];
  int   i, length;
  
  i=0;
  while( *str ) // If line not empty
  {
    // Check first character. If sep skip it.
    while( *str == sep || *str == '\t' || *str == ' ' ) 
      str = str + 1;

    if( *str ) // If still not empty
    {
      ptr = str;

      while( *str != sep && *str != '\0' && *str != '\n' ) // Look for next sep.
        str = str + 1;

      i = i + 1; // Increase word index 
      if( i == index ) // Check with input index
      {
        length = str - ptr ;
        strncpy( word, ptr, length);
        *( word + length ) = '\0';
        if( !blanks )
          rm_blanks_at_ends( word );
        return( word );
      }
    }
  }
  return( NULL );
}


/*----------------------------------------------------------------------------
 * Function removwes all white characters at both ends of string s.
 *----------------------------------------------------------------------------*/

rm_blanks_at_ends( str )
//***********************
  char * str;
{
  char *ptr;
  int   last;
  
  ptr = (char *) malloc( strlen( str )*sizeof( char ));
  strcpy( ptr, str );
  
  // Move to first not space position
  //*****************************
  while( *ptr == ' ' || *ptr == '\t' )
    ptr = ptr + 1;

  // Get last not space position
  //****************************
  last = strlen( ptr ) - 1;

  while ( ptr[last] == ' ' || ptr[last] == '\t' )
    last = last - 1;

#ifdef DEBUG
  printf("RM_BLANKS-1: l(%s):%d\n", ptr, last ) ;
#endif
  
  // And put END 
  //************
  if( ptr[last] == '\n' ) {
    ptr[last] = '\0';
#ifdef DEBUG
    printf("RM_BLANKS-2A: l(%s):%d\n", ptr, last ) ;
#endif
  }
  else {
#ifdef DEBUG
    printf("RM_BLANKS-2B: l(%s):%d\n", ptr, last ) ;
#endif
    ptr[last + 1] = '\0';
  }
  strcpy( str, ptr);
  str[last + 1] = '\0';
  
  return( 1 );
  
}

/*----------------------------------------------------------------------------
 * Function removes all white characters within string.
 *----------------------------------------------------------------------------*/

rm_blanks( str, str2 )
char * str;
char * str2;
{
  char *newstr;
  int   last, i ,j;
  
  newstr = (char *) malloc( strlen( str )*sizeof( char ));
  i = 0; j = 0;
  
  // Move to first not space position
  //**********************************
  for( i=0; i < strlen(str); i = i+1) {
  	if( str[i] != ' ' && str[i] != '\t' ) {
    		newstr[j] = str[i];
    		j = j + 1;
    	}
  }
  newstr[j] = '\0'; 
  //printf("%s converted to %s\n", str, newstr); 
  strcpy( str2, newstr);
  return( 0 );
}

/*----------------------------------------------------------------------------
 * Function fills string 'str' with character 'chr'
 *----------------------------------------------------------------------------*/

char * strset( str, chr )
  char * str;  // string to fill
  char   chr;  // character to fill with
{
  char *p ;

  p = str;
  while( *p != '\0' )
  {
    *p = chr;
    p = p + 1;
  }
  return(0);
}


#endif











