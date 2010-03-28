#ifndef accondit_include
#define accondit_include 1

/* Structure to define matching between the condit template and the occurence
   template
*/


#define ACCOND_STRING   0x1
#define ACCOND_NUM        0x2
#define ACCOND_EQUAL      0x6  
#define ACCOND_LESS       0xa
#define ACCOND_LESS_OR_EQ 0xe

#define ACTEMP_STRING   0x1
#define ACTEMP_NUM      0x2

struct ACcond_val
     {
      union {
	     double dbl;
	     char str[macro_MAX_CHAR]; 
            } value;
      char type; 
     };

struct ACcond_temp
     {
      union {
	     double dbl;
	     char str[macro_MAX_CHAR]; 
            } value;
      short index;
      char type;
     };


/*
   structure to describe the differents construction possible for the 
   conditional
*/

struct ACcond_descrip
       { char konst[macro_MAX_CHAR];           /* construction name         */ 
         struct ACcond_val cond;	       /* condition value           */
 	 int temp_first_def;                  /* template description      */
	 int temp_nb_def;		
 	 int *feet_desc;		       /* feet matching description */
       };

#endif /* accondit_include */
