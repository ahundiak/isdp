/******************************************************************************

Functions:

    COdpb_get_style
    COdpb_get_just
    COdpb_get_font

Description:    

    These function fetch the name for an attribute value or an attribute
    value for a name.

History:    

    jay wallingford     04/10/89    creation date
    dhm                 07/09/92    ANSI conversion.

Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COdpb;

from GRfm           import GRvirt_search, GRfm_retdata;

#include <coimport.h>

/**************************************************************************
     function get_style - op = 1 - returns a style number for the input 
                                   string, or a 0 if the function failed.
                          op = 0 - returns a style string for the input
                                   number, or a 0 if the function failed.
 **************************************************************************/
extern IGRint COdpb_get_style(string, style, op)
IGRchar *string;
IGRuchar *style;
IGRint  op;
{
    IGRuchar   i;
    IGRint             msg;
    static IGRchar *   array[7] = { "sol","...","---","___",
                                    "_._","-..","_-_" };
    if (op) 
    {
        msg = MSFAIL;
        for ( i=0; i<7; i++) 
        {
            if ( !strncmp(string,array[i],3) ) {
                *style = i;
                msg = MSSUCC;
                break;
            }
        }
    }
    else
    {
        if ( (IGRint) *style >= CO_lo_style && (IGRint) *style <= CO_hi_style )
        {
            strcpy(string, array[*style]);
            msg = MSSUCC;
        }
        else msg = MSFAIL;
        
    }

    return ( msg );
}

/**************************************************************************
    function COdpb_get_just - op = 1: returns the justification which matches 
                                      the string.
                              op = 0: returns the string which matches the 
                                      justification.
                        returns 0 on failure.
    
    NOTE: For option 0 the string buffer should be at least 13 characters long.
 **************************************************************************/
extern IGRint COdpb_get_just(string, just, op) 
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
    IGRint    msg;

    ex$message( msgnumb = GR_I_Justs,
                buff = (IGRchar *) justs );

    msg = MSFAIL;

    /*
     * Assign justification strings to the pointer arrays.
     */
    if ( (array1[0] = (char *)strtok((IGRchar *) justs,seps)) ) {
        for ( i=1; i<3; i++ )
            if ( !( array1[i] = (char *)strtok(NULL,seps) ) ) 
                goto quit;

        for ( i=0; i<5; i++ )
            if ( !( array2[i] = (char *)strtok(NULL,seps) ) ) 
                goto quit;
    }

    /*
     * If the string is to be returned.
     */
    if ( op == 0 ) {
        /*
         * Test for a legal justification.
         */
        if ( (*just < CO_lo_just) || (*just > CO_hi_just) ) 
            goto quit;

        /*
         * Get the array indexes.
         */
        i = *just / 5;
        j = *just % 5;

        /*
         * Construct the justification string.
         */
        sprintf(string, "%s, %s", array1[i], array2[j]);
        msg = MSSUCC;
    }
    /*
     * Otherwise the operation is to fetch a number from the string.
     */
    else 
    {
        /* 
         * The length must be at least 3 characters.
         */
        if (strlen(string) > 2) 
        {
            /*
             * Get the two tokens from the input string.
             */
            if ( !( token1 = (char *)strtok(string,seps) ) ||
                 !( token2 = (char *)strtok(NULL,seps) ) ) 
                goto quit;

            /*
             * Determine which just in array1 matches token1.
             */
            for ( i=0; i<3; i++ )
                if ( !strcmp(token1, array1[i] ) )
                    break;

            if ( i == 3 ) goto quit;

            /* 
             * Determine which just in array2 matches token2.
             */
            for ( j=0; j<5; j++ )
                if ( !strcmp(token2, array2[j] ) )
                    break;

            if ( j == 5 ) goto quit;

            *just = (i * 5) + j;
    
            msg = MSSUCC;
        }
    }

quit:
    return(msg);    
}
               
/**************************************************************************
Abstract: This function will return a font name for a font number of vise
          versa depending on the value of op.

          op = 0 - get name for number
          op = 1 - get number for name

History:  Jay Wallingford     8/22/88   Design and implementation
          jhw                 2/20/89   Modified to check for font type

Notes:    This function is a temporary fix for the lack of a macro to do
          the same. A request has been submitted for a font macro to provide
          this functionality.

 **************************************************************************/
extern IGRint COdpb_get_font(name, num, type, op) 
     IGRchar   *name;
     IGRshort  *num;
     IGRlong   type;
     IGRint    op;
{
     IGRint             status,msg;
     IGRshort           s;
     OM_S_OBJID         fm_id, mod_id;
     OMuword            mod_osnum;
     struct vfont_entry vfnt;

     status = msg = MSSUCC;

     msg = ex$get_cur_mod( id = &mod_id, 
                           osnum = &mod_osnum );
     _err_ck(msg);

     msg = ex$get_objid_from_NOD(NODname = FONTMGR_NOD,
                                 objname = FONTMGR_NO_NAME,
                                 pobjid = &fm_id,
                                 modid = mod_id,
                                 mod_osnum = mod_osnum);
     _err_ck(msg);

     if (op) *num = (-1);
     status = om$send ( msg = message GRfm.GRvirt_search
                              ((IGRlong *) &msg, (IGRuchar *) name, num),
                        targetid = fm_id,
                        targetos = mod_osnum,
                        senderid = NULL_OBJID );
     _err_ck2(status, msg);

     status = om$send( msg = message GRfm.GRfm_retdata((IGRlong *) &msg,
                                                       num,
                                                       &vfnt),
                       targetid = fm_id,
                       targetos = mod_osnum,
                       senderid = NULL_OBJID );
     _err_ck2(status, msg);

     switch (type)
     {
     case CO_font:
     case CO_ascii:
        /* NOTE: a check for a 7 bit font must be done also */
        /*       to insure a ascii font. This is done later */
        s = 0x01; /* 0th bit indicates char font */
        break;
     case CO_frac:
        s = 0x02; /* 1st bit indicates fraction font */
        break;
     case CO_symb:
        s = 0x04; /* 2nd bit indicates symbol font */
        break;
     default:
        msg = MSFAIL;
        goto quit;
     }

     /*
      * Check for legal font type.
      */
     if ( !(vfnt.flags & s) ) msg = MSFAIL;
     /*
      * A legal ascii font must be a 7 bit font in
      * addition to being a character font.
      */
     else if ( (type == CO_ascii) && (vfnt.flags & 0x04) )
         msg = MSFAIL;

quit:

     return((status & msg & 1) ? MSSUCC : MSFAIL);
}

end implementation COdpb;


