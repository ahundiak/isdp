/* #######################    APOGEE COMPILED   ######################## */

/*
 ------------------------------------------------------------------------------

  Module:  IGRlong  COprefix_to_cs_type( ReturnMsg, 
                                         Prefix,
                                         CStypeSize,
                                         CStype )

  Abstract:
  
     This function 

  Example:  status = COprefix_to_cs_type( &msg, 
                                           p_prefix,
                                           size,
                                           p_result );
                                          
                                 

  Arguments:

     *ReturnMsg(-)  IGRlong      Return message:
                                    MSSUCC - success
                                    MSFAIL - Not a prefix of a known CS type

    *Prefix(+)      IGRchar      String to be compared against known CS types

     CStypeSize(+)  IGRlong      Size of CStype buffer

    *CStype(-)      IGRchar      CStype buffer, where results are stored


  Notes:

    If the ReturnMsg is MSFAIL, then the CStype will contain the Prefix; this
    may be usefull if you with to go ahead and use this string an exact
    C S type.

 
 
  History:   srh   08/10/87   - created

 -----------------------------------------------------------------------------
 */

/* EH */

#include   "grimport.h"
#include   <ctype.h>
#include   "codebug.h"
#include   "OMminimum.h"
#include   "OMprimitives.h"
#include   "igrtypedef.h"
#include   "igetypedef.h"
#include   "msdef.h"
#include   "exdef.h"
#include   "godef.h"
#include   "gr.h"
#include   "igr.h"
#include   "igrdp.h"
#include   "ex.h"
#include   "go.h"
#include   "ex.h"
#include   "griodef.h"
#include   "grio.h"
#include   "griomacros.h"
#include   "grdpbdef.h"
#include   "grdpbmacros.h"
#include   "igrmacros.h"

#define    NUMBER_OF_CS_TYPES    ( 3 )


static IGRchar *CoordSysTypes[] = {
                                     "rectangular", 
                                     "cylindrical", 
                                     "spherical",
                                  };


IGRlong  COprefix_to_cs_type( ReturnMsg, 
                              Prefix,
                              CStypeSize,
                              CStype )
   IGRlong  *ReturnMsg;
   IGRchar  *Prefix;
   IGRlong   CStypeSize;
   IGRchar  *CStype;

{

   IGRlong
             ReturnStatus = MSSUCC;

   IGRboolean 
             HaveMatch = FALSE;

   IGRshort
             TypeIndex,
	     Index = 0; /* lower case prefix string index */

   IGRchar
	     LowerCasePrefix[MAX_CS_TYPE];



   /* EV - end of local variable declarations */


   _m_debug_str( "> COprefix_to_cs_type" );

   if ( ( strlen( CStype )) == 0 )
   {
       *ReturnMsg = MSINARG;
       goto quit;
   }

   /*
    *  convert prefix to all lower case before conversion
    */
   while ( ( Prefix[Index] != NULL ) && ( Index < MAX_CS_TYPE ) )
   {
      LowerCasePrefix[Index] = tolower( Prefix[Index] );
      Index++;
   }
   LowerCasePrefix[Index] = '\000'; /* null terminate new prefix string */



   for( TypeIndex = 0; 
        ( ! HaveMatch && TypeIndex < NUMBER_OF_CS_TYPES );
        TypeIndex++ )
   {
      if ( strncmp( LowerCasePrefix, 
		    CoordSysTypes[TypeIndex], 
		    strlen( LowerCasePrefix ) ) == 0 ) 
      {
         strncpy( CStype, CoordSysTypes[TypeIndex], CStypeSize );
         HaveMatch = TRUE;
      }
   }

   if ( ! HaveMatch )
   {
      _m_debug_str("COprefix_to_cs_type: Not a known CS type" );
      strncpy( CStype, LowerCasePrefix, CStypeSize );
      *ReturnMsg = MSFAIL;
   }


quit:
   _m_debug_str( "< COprefix_to_cs_type" );

   return( ReturnStatus );

}
