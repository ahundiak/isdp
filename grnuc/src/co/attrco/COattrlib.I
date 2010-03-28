/* #######################    APOGEE COMPILED   ######################## */
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*\

History

	Kumar Talluri	06/15/86  Design and Implementation.
			07/01/86  added capability to keyin color and style
			          as a string, ex: green or gre; sol for
			          solid '...' for dotted style.

	Jay Wallingford	11/21/87  Added code to allow translation from just to
                                  justification string.

	JHW		08/31/88  Added fuction to retrieve font number from
			          font name and vis versa.

        JHW             02/07/89  Rewrote COattr_get_just and COattr_get_style
Notes

        These two functions should be part of the grdpb object in the form of
        several macro calls. In addition the hardcoded string representation for
        style and text justification should be changed to keys, this would allow
        these strings to be modified by the user. The translation from key to string
        could occur at initialization of the grdpb object. What is provided here is 
        a temporary fix.

\*/
class implementation COattr;

#include "coimport.h"

from GRfm           import GRvirt_search;

/**************************************************************************\
     function get_style - returns a style number for the input string, or a 0
                          if the function failed.
\**************************************************************************/
IGRint COattr_get_style(string, style)
IGRchar *string;
IGRchar unsigned *style;
{
    IGRchar unsigned   i;
    static IGRchar *   array[8] = { "sol","...","---","___",
                                    "_._","-..","_-_" };

    for ( i=0; i<8; i++) 
        if ( !strcmp(string,*(array + i)) ) {
            *style = i;
            return(1);
        }
    return(0);
}



/**************************************************************************\
     function get_just - op = 0: returns the justification which matches the 
                                 string.
                         op = 1: returns the string which matches the justification.

                         returns 0 on failure.
     NOTE: For option 1 the string buffer should be at least 13 characters long.
\**************************************************************************/
IGRint
COattr_get_just(string, just, op) 
    IGRchar *   string;
    IGRshort *  just;
    IGRshort    op;
{
    IGRchar * array1[3];
    IGRchar * array2[5];
    IGRchar * token1;
    IGRchar * token2;
    IGRchar * justs[256];
    IGRchar * seps = " ,:";
    IGRshort  i,j;

    ex$message( msgnumb = GR_I_Justs,
                buff = justs );

    /*
     * Assign justification strings to the pointer arrays.
     */
    if ( array1[0] = strtok(justs,seps) ) {
        for ( i=1; i<3; i++ )
            if ( !( array1[i] = strtok(NULL,seps) ) )
                return(0);
        for ( i=0; i<5; i++ )
            if ( !( array2[i] = strtok(NULL,seps) ) )
                return(0);
    }

    /*
     * If the string is to be returned.
     */
    if ( op == 1 ) {
        /*
         * Test for a legal justification.
         */
        if ( (*just < LO_JUST) || (*just > HI_JUST) ) return(0);

        /*
         * Get the array indexes.
         */
        i = *just / 5;
        j = *just % 5;

        /*
         * Construct the justification string.
         */
        sprintf(string, "%s, %s", *(array1 + i), *(array2 + j));
        return (1);
    }

    /*
     * Otherwise the operation is to fetch a number from the string.
     */

    /* 
     * The length must be at least 3 characters.
     */
    if (strlen(string) > 2) {
        /*
         * Get the two tokens from the input string.
         */
        if ( !( token1 = strtok(string,seps) ) ||
             !( token2 = strtok(NULL,seps) ) ) return(0);

        /*
         * Determine which just in array1 matches token1.
         */
        for ( i=0; i<3; i++ )
            if ( !strcmp(token1, *(array1 + i) ) )
                break;

        if ( i == 3 ) return(0);

        /* 
         * Determine which just in array2 matches token2.
         */
        for ( j=0; j<5; j++ )
            if ( !strcmp(token2, *(array2 + j) ) )
                break;

        if ( j == 5 ) return(0);

        *just = (i * 5) + j;
    
        return(1);
    }

    return(0);    
}

/**************************************************************************\
Abstract: This function will return a font name for a font number of vise
          versa depending on the value of op.

History:  Jay Wallingford     8/22/88   Design and implementation

Notes:    This function is a temporary fix for the lack of a macro to do
          the same. A request has been submitted for a font macro to provide
          this functionality.

\**************************************************************************/
IGRint COattr_get_font(ok, name, num, op) 
     IGRlong   *ok;
     unsigned IGRchar   *name;
     IGRshort  *num;
     IGRint    op;
{
     IGRint         status;
     OM_S_OBJID     fm_id, mod_id;
     OMuword        mod_osnum;

     status = *ok = OM_S_SUCCESS;

     status = ex$get_cur_mod( id = &mod_id, 
                              osnum = &mod_osnum );
     _err_ck(status);

     status = ex$get_objid_from_NOD(NODname = FONTMGR_NOD,
                                    objname = FONTMGR_NO_NAME,
                                    pobjid = &fm_id,
                                    modid = mod_id,
                                    mod_osnum = mod_osnum);
     _err_ck(status);

     if (op) *num = (-1);
     status = om$send ( msg = message GRfm.GRvirt_search
                              (ok, name, num),
                        targetid = fm_id,
                        targetos = mod_osnum,
                        senderid = NULL_OBJID );
     _err_ck2(status, *ok);

quit:
     return(status);
}
               
end implementation COattr;

