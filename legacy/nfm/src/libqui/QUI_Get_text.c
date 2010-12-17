#include "machine.h"
#include "QUI.h"

QUI_Get_text ( fp, g_label )
/* this routine gets the text from a single select field */
       Form    fp;            /* I - Pointer to the form     */
       long     g_label;       /* I - The label of the gadget */
{
    long text_len;
    long field_type;
    long row = 0;
    long col = 0;
    long pos;
    long           row_position;
    long           select_flag;

    FIg_get_type ( fp, g_label, (int) &field_type );

    if ( field_type == FI_MULTI_COL )
    {

        /* Get the row and col for the MCF */

        FImcf_get_active_col ( fp, g_label, &col, &pos );

        FIfld_get_active_row ( fp, g_label, &row, &pos );
    }

    FIfld_get_text_length ( fp, g_label, row, col, &text_len );

    /* Increment text_len because of NULL */

    text_len++;

    if ( QUIglobal.text_size < text_len )
    {
        if ( QUIglobal.text_size > 0 )
        {
           /* Realloc space for larger string */
           QUIglobal.text = (char *) realloc ( QUIglobal.text, text_len );
        }
        else
        {
           /* Calloc space for string */
           QUIglobal.text = (char *) calloc ( 1, text_len );
        }
        QUIglobal.text_size = text_len;
    }

    FIfld_get_text ( fp, g_label, row, col, QUIglobal.text_size,
                     QUIglobal.text, &select_flag, &row_position );
}
