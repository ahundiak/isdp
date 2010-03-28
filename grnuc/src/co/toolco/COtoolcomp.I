/* #######################    APOGEE COMPILED   ######################## */
/******************************************************************************

Methods:

    compare
    inrange

Description:    

    The compare method compares one data type to another. The types
    that may be defined are found in toolco.h.

    The inrange method determines whether a value is with a particular
    range.

History:    

    jay wallingford     04/10/89    creation date
    jhw                 09/15/89    added inrange method
    jhw                 09/22/89    added support for CO_msg_to_str

Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COtools;

#include <coimport.h>
#include <msdef.h>
#include <msmacros.h>

extern int COtool_ci_strcmp ();

method compare ( IGRint * relation;
                 IGRchar * first_value;
                 IGRchar * second_value;
                 IGRint type )
{
    IGRint      i;
    IGRdouble   val1,val2;

    if ( type == CO_str_to_str ) 
    {
        i = strcmp(first_value,second_value);
        *relation = (i == 0) ? CO_eq :
                    (i < 0)  ? CO_lt :
                               CO_gt;
    }
    else if ( type == CO_msg_to_str )
    {
        IGRchar buffer[132];

        ex$message ( msgnumb = (IGRint)first_value,
                     buff = buffer );

        i = COtool_ci_strcmp ( buffer, second_value );

        *relation = (i == 0) ? CO_eq :
                    (i < 0)  ? CO_lt :
                               CO_gt;
    }
    else if ( type == CO_btn_to_btn ) 

    {
/*
        *relation = ( *(struct EX_button *)first_value ==
                      *(struct EX_button *)second_value ) ?
                       CO_eq : CO_ne ;
*/
        *relation = ( !( memcmp((char *)first_value, 
				(char *)second_value,
				sizeof( struct EX_button )) ) ) ?
                       CO_eq : CO_ne ;

    }
    else if ( type == CO_btn_to_pnt ) 
    {
        *relation = CO_ne;

        if ( ((struct EX_button *)first_value)->x == 
             ((double *)second_value)[0] )
        if ( ((struct EX_button *)first_value)->y == 
             ((double *)second_value)[1] )
        if ( ((struct EX_button *)first_value)->z == 
             ((double *)second_value)[2] )
        {
            *relation = CO_eq;
        }
    }
    else if ( type == CO_mtx_to_mtx ) 
    {
        *relation = CO_eq;
        for ( i=0; i<16; i++ )
        {
            if ( ((double *)first_value)[i] !=
                 ((double *)second_value)[i] )
            {
                *relation = CO_ne;
                break;
            }
        }
    }
    else 
    {
        switch ( type ) 
        {
        case CO_int_to_int:
            val1 = *(int *)first_value;
            val2 = *(int *)second_value;
            break;
        case CO_cin_to_int:
            val1 = (int)first_value;
            val2 = *(int *)second_value;
            break;
        case CO_cin_to_dbl:
            val1 = (int)first_value;
            val2 = *(double *)second_value;
            break;
        case CO_dbl_to_dbl:
            val1 = *(double *)first_value;
            val2 = *(double *)second_value;
            break;
        case CO_dbl_to_int:
            val1 = *(double *)first_value;
            val2 = *(int *)second_value;
            break;
        default:
            goto quit;
        }

        *relation = (val1 >  val2) ? CO_gt :
                    (val1 == val2) ? CO_eq :
                                     CO_lt;
    }

quit:

    return OM_S_SUCCESS;
}

method inrange ( IGRint * result;
                 IGRchar * value;
                 IGRchar * low_value;
                 IGRchar * high_value;
                 IGRint type )
{
    IGRdouble   val,low,high;

    low = (IGRint)low_value;
    high = (IGRint)high_value;

    if ( type == CO_str_to_str ) 
    {
        *result = (strcmp(value,low_value) >= 0) &&
                  (strcmp(value,high_value) <= 0);
    }
    else if (type == CO_int_to_int ) 
    {
        val = *((IGRint *)value);
        *result = ((val >= low) && (val <= high));
    }
    else if ( type == CO_dbl_to_int )
    {
        val = *((IGRdouble *)value);
        *result = (val >= low) && (val <= high);
    }
    else
    {
        *result = 0;
    }

    *result = (*result) ? MSSUCC : MSFAIL;

    return (OM_S_SUCCESS);
}

end implementation COtools;

