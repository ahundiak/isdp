class implementation QYnpt;

#include <coimport.h>
#include <stdio.h>
#include "OMmacros.h"
#include "OMprimitives.h"
#include "FI.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

/* Sizes   */

#define QUERY_LEN   4096

/* Forms   */

#define LIST_FORM   0

/* Gadgets */

#define QUIT    4
#define EXIT    1
#define MESSAGE 10
#define QUERY   48

#define RESET_BUTTON      15
#define BACKUP_BUTTON     31

#define MACRO_LIST        12
#define MACRO_FIELD       42

#define WHERE_CHECK       17
#define WHERE_NOT_CHECK   18

#define ATTRIBUTE_LIST    43
#define ATTRIBUTE_FIELD   62

#define NE                25
#define EQ                26
#define GE                27
#define LE                29
#define GT                30
#define LT                32

#define VALUE_FIELD       51

#define AND_CHECK         73
#define AND_NOT_CHECK     74
#define OR_CHECK          75
#define OR_NOT_CHECK      76

/* Query States */

#define NO_STATE       -1
#define MACRO           0
#define WHERE           1
#define ATTRIBUTE       2
#define CONDITION       3
#define VALUE           4
#define CONJUNCTION     5

#include "expriv.h"
void KLUDGY_FUNC_TO_PUT_STRING_ON_RECALL_LIST (string)
    char * string;
{
    extern char EX_keyin_cmd[][EX_RCL_MAX_LEN];
    extern int  EX_entry;
    extern int  EX_entry_full;
    
    strncpy (EX_keyin_cmd[EX_entry], string, EX_RCL_MAX_LEN - 1);
    EX_keyin_cmd[EX_entry][EX_RCL_MAX_LEN - 1] = '\0';

    if (++EX_entry >= EX_RCL_MAX_ENTRY)
    {
        EX_entry = 0;
        EX_entry_full = 1;
    }
}

void QYclear_list (fp, label)
    Form fp;
    int  label;
{
    int num, i, sel, mode, attr;

    FIfld_get_attr (fp, label, 0, &attr);

    if (attr & FI_POPUP_ASSO_LIST)
    {
        FIfld_set_text (fp, label, 0, 0, "", FALSE);
    }
    else
    {
        FIfld_get_mode (fp, label, 0, &mode);
        FIfld_get_num_rows (fp, label, &num);
        for (i=0; i<num; ++i)
        {
            FIfld_get_select (fp, label, i, 0, &sel);
            if (sel)
            {
                FIfld_set_select (fp, label, i, 0, FALSE);
                if (mode == FI_SINGLE_SELECT) break;
            }
        }
    }
}

int QYis_string_on_list (fp, label, s)
    Form   fp;
    int    label;
    char * s;
{
    int  i, num, sel, pos;
    char text[1024];

    FIfld_get_num_rows (fp, label, &num);
    for (i=0; i<num; ++i)
    {
        FIfld_get_text (fp, label, i, 0, 1024, text, &sel, &pos);

        if (!strcmp(text, s)) return(1);
    }

    return (0);
}

/******************************************************************************

Method:
    
    switch_query_state

Description:

    This method switches the form between states.

History:

    jay wallingford     04/16/91    creation date

******************************************************************************/

#define MACRO_FIELD_BIT     0x00000001
#define MACRO_LIST_BIT      0x00000002
#define WHERE_CHECK_BIT     0x00000004
#define WHERE_NOT_CHECK_BIT 0x00000008
#define ATTRIBUTE_FIELD_BIT 0x00000010
#define ATTRIBUTE_LIST_BIT  0x00000020
#define NE_BIT              0x00000040
#define EQ_BIT              0x00000080
#define GE_BIT              0x00000100
#define LE_BIT              0x00000200
#define GT_BIT              0x00000400
#define LT_BIT              0x00000800
#define VALUE_BIT           0x00001000
#define AND_BIT             0x00002000
#define AND_NOT_BIT         0x00004000
#define OR_BIT              0x00008000
#define OR_NOT_BIT          0x00010000
#define EXIT_BIT            0x00020000

#define MACRO_BIT           0x00000003
#define WHERE_BIT           0x0000000C
#define ATTRIBUTE_BIT       0x00000030
#define CONDITION_BIT       0x00000FC0
#define CONJUNCTION_BIT     0x0001E000
#define LIST_BIT            0x00001022

method switch_query_state (int state; int reset)
{
    Form        fp;
    static char labels[18] =  { MACRO_FIELD, MACRO_LIST, WHERE_CHECK,
                                WHERE_NOT_CHECK,  ATTRIBUTE_FIELD, 
                                ATTRIBUTE_LIST, NE, EQ, GE, LE, GT, LT, 
                                VALUE_FIELD, AND_CHECK, AND_NOT_CHECK, 
                                OR_CHECK, OR_NOT_CHECK, EXIT };
    unsigned int i, j, on = 0, attr, label;
    char  prompt[MS_MAX_MSG_LENGTH];
    
    fp = me->status_display_form_ptr;

    switch (state)
    {
    case MACRO:
        on = MACRO_BIT;
        ex$message(msgnumb = GR_P_SelMacSrch, buff = prompt);
/*        prompt = "Select macro(s) to search for"; */
        break;
    case WHERE:
        on = MACRO_BIT | WHERE_BIT | EXIT_BIT;
        ex$message(msgnumb = GR_P_ExeQuery, buff = prompt);
/*        prompt = "Exectue query, select additional macro(s), or initiate condition clause";  */
        break;
    case ATTRIBUTE:
        ex$message(msgnumb = GR_P_SelAttr, buff = prompt);
/*        prompt = "Select attribute"; */
        on = ATTRIBUTE_BIT;
        break;
    case CONDITION:
        ex$message(msgnumb = GR_P_SelCondOperator, buff = prompt);
/*        prompt = "Select conditional operator"; */
        on = CONDITION_BIT;
        break;
    case VALUE:
        ex$message(msgnumb = GR_P_KeyinCompVal, buff = prompt);
/*        prompt = "Key-in comparision value"; */
        on = VALUE_BIT;
        break;
    case CONJUNCTION:
        ex$message(msgnumb = GR_P_ExeOrSel, buff = prompt);
/*        prompt = "Execute query or select conjunction operator"; */
        on = CONJUNCTION_BIT | EXIT_BIT;
        break;
    }

    for (i=0, j=1; i<18; ++i, j<<=1)
    {
        label = labels[i];

        FIg_get_attr (fp, label, &attr);

        if (on & j) 
        {
            if (attr & FI_NOT_ENABLED) 
            {
                attr &= ~FI_NOT_ENABLED;

                if (!reset && (j & MACRO_BIT))
                    FIg_set_attr (fp, label, attr);
                else if (j & LIST_BIT)
                {
                    FIg_set_attr (fp, label, attr);
                    QYclear_list (fp, label);
                }
                else
                    FIg_reset (fp, label);
                FIg_display  (fp, label);
            }
            else if (reset && (j & MACRO_BIT) && (state == MACRO))
            {
                if (j & MACRO_LIST_BIT) 
                    QYclear_list(fp, label);
                else FIg_reset (fp, label);
            }
        }
        else if (!(attr & FI_NOT_ENABLED))
        {
            attr |= FI_NOT_ENABLED;
            FIg_set_attr (fp, label, attr);
            FIg_display  (fp, label);
        }
    }

    if (state == VALUE)
        FIfld_pos_cursor (fp, VALUE_FIELD, 0, 0, 0, 0, 0, 0);

    FIfld_set_text (fp, MESSAGE, 0, 0, prompt, FALSE);

    return OM_S_SUCCESS;
}

/******************************************************************************

Method:
    
    add_to_query

Description:

    This method adds a string to the end of a query.

History:

    jay wallingford     04/16/91    creation date

******************************************************************************/

method add_to_query (int label)
{
    Form    fp;
    int     state;
    int  sel, pos;
    char query[QUERY_LEN], text[1024], buffer[1024];

    /* Init some variables */
    fp = me->status_display_form_ptr;
    state = me->query_state;
    text[0] = '\0';

    switch (state)
    {
    case WHERE:
        strcat(text, (label == WHERE_CHECK) ? "where " : "where ! ");
        break;

    case ATTRIBUTE:
        strcat(text, "(");
        FIfld_get_text (fp, ATTRIBUTE_FIELD, 0, 0, 1024, buffer, &sel, & pos);
        strcat(text, buffer);
        strcat(text, " ");
        break;

    case CONDITION:
        strcat(text, (label == NE) ? "!= " :
                     (label == EQ) ? "= "  :
                     (label == GE) ? ">= " :
                     (label == LE) ? "<= " :
                     (label == GT) ? "> "  :
                                     "< " );
        break;

    case VALUE:
        FIfld_get_text (fp, VALUE_FIELD, 0, 0, 1024, buffer, &sel, & pos);
        strcat (text, buffer);
        strcat (text, ") ");
        break;

    case CONJUNCTION:
        strcat(text, (label == AND_CHECK)     ? "& "  :
                     (label == AND_NOT_CHECK) ? "&! " :
                     (label == OR_CHECK)      ? "| "  :
                                                "|! " );
        break;
    }

    FIfld_get_text ( fp, QUERY, 0, 0, QUERY_LEN, query, &sel, &pos);

    if (me->num_query_offsets > om$dimension_of(varray = me->query_offsets))
    {
        om$vla_set_dimension (varray = me->query_offsets,
                              size = me->num_query_offsets + 10);
    }

    me->query_offsets[me->num_query_offsets++] = strlen(query);

    strcat (query, text);
    FIfld_set_text ( fp, QUERY, 0, 0, query, FALSE);    

    return OM_S_SUCCESS;
}
    
/******************************************************************************

Method:
    
    back_up_query

Description:

    This method backs up a query to the previous state.

History:

    jay wallingford     04/16/91    creation date

******************************************************************************/

method back_up_query ()
{
    Form    fp;
    int     state, sel, pos, num_offsets, reset = TRUE;
    char    query[QUERY_LEN];

    /* Init some variables */
    fp = me->status_display_form_ptr;
    state = me->query_state;
    num_offsets = me->num_query_offsets;

    if (state != MACRO)
    {
        if ((state == ATTRIBUTE) && (num_offsets != 1))
        {
            state = CONJUNCTION;
        }
        else --state;

        if (state == WHERE)
            reset = FALSE;
    }
    
    if (num_offsets)
    {
        FIfld_get_text ( fp, QUERY, 0, 0, QUERY_LEN, query, &sel, &pos);
        query[me->query_offsets[me->num_query_offsets = --num_offsets]] = '\0';
        FIfld_set_text ( fp, QUERY, 0, 0, query, FALSE);
    }

    if ((state == WHERE) || (state == MACRO))
    {
        if (state == MACRO)
            FIfld_set_text (fp, QUERY, 0, 0, "select ", FALSE);

        FIg_reset (fp, ATTRIBUTE_LIST);
        FIg_reset (fp, VALUE_FIELD);
    }
    
    om$send ( msg = message QYnpt.switch_query_state 
                                    (me->query_state = state, reset),
              targetid = my_id );
        
    return OM_S_SUCCESS;
}

/******************************************************************************

Method:
    
    init_query

Description:

    This method initialized the query status display form.

Override:

    from CEO form_notification

History:

    jay wallingford     04/16/91    creation date

******************************************************************************/
method init_query ()
{
    Form    form_ptr;
    int     i;

    form_ptr = me->status_display_form_ptr;

    /* Reset the form, this will turn on all gadgets */
    FIf_reset (form_ptr);

    /* Reset the query state */
    om$send ( msg = message QYnpt.switch_query_state 
                                (me->query_state = MACRO, TRUE),
              targetid = my_id );

    /* Add the select keyword to the query field */
    FIfld_set_text (form_ptr, QUERY, 0, 0, "select ", FALSE);

    /* Init the number of query offsets */
    me->num_query_offsets = 0;

    /* Fill in the macro name list */
    {
        char ** pp_macros;
        int     num_macros = 0;

        QYget_macro_names (&pp_macros, &num_macros);

        for (i=0; i<num_macros; ++i)
        {
            FIfld_set_text (form_ptr, MACRO_LIST, i, 0, pp_macros[i], FALSE);
        }
    }

    return OM_S_SUCCESS;
}


/******************************************************************************

Method:
    
    form_notification

Description:

    This method supports the query status display form.

Override:

    from CEO form_notification

History:

    jay wallingford     04/16/91    creation date

******************************************************************************/

method form_notification ( int    form_label; 
                           int    gadget_label; 
                           double value; 
                           Form   form_ptr )
{
    long msg = MSSUCC;
    int  sel, pos, num, len;
    int  i, j;
    char query[QUERY_LEN], buffer[QUERY_LEN], text[1024],
         msgbuff[MS_MAX_MSG_LENGTH];
    int  switch_state = TRUE, concatenate = TRUE, back_up = FALSE;

    switch (gadget_label)
    {
    case MACRO_LIST:
        text[0] = '\0';
        FIfld_get_num_rows (form_ptr, MACRO_LIST, &num);
        for (i=0, j=0; i<num; ++i)
        {
            FIfld_get_select (form_ptr, MACRO_LIST, i, 0, &sel);
            if (sel)
            {
                if (j>0) strcat(text, ",");
                FIfld_get_text (form_ptr, MACRO_LIST, i, 0, 1024, buffer, &sel, & pos);
                strcat(text, buffer);
                ++j;
            }
        }
        FIfld_set_text (form_ptr, MACRO_FIELD, 0, 0, text, FALSE);

    case MACRO_FIELD:

        FIfld_get_text (form_ptr, MACRO_FIELD, 0, 0, 1024, text, &sel, &pos);

        strcpy(buffer, "select ");
        strcat(buffer, text);
        strcat(buffer, " ");
        FIfld_set_text (form_ptr, QUERY, 0, 0, buffer, FALSE);

        if (text[0] == '\0') 
        { 
            back_up = TRUE; 
            switch_state = FALSE; 
        }
        else if (me->query_state == WHERE)
        {
            switch_state = FALSE;
        }
        concatenate = FALSE;
        break;

    case WHERE_CHECK:
    case WHERE_NOT_CHECK:
    {
        char ** pp_feet;
        int     num_feet = 0;
        char *  pp_macros[1024];
        int     num_macros = 0;
        char *  sep = ", ";
        
        FIfld_get_text (form_ptr, MACRO_FIELD, 0, 0, 1024, text, &sel, &pos);

        if (pp_macros[num_macros] = strtok(text, sep))
        {
            if (QYis_string_on_list(form_ptr, MACRO_LIST, pp_macros[num_macros]))
            {
                ++num_macros;

                while ((pp_macros[num_macros] = strtok(NULL, sep)) &&
                       (num_macros < 1024))
                {
                    if (QYis_string_on_list(form_ptr, MACRO_LIST, pp_macros[num_macros]))
                    {
                        ++num_macros;
                    }
                    else 
                    {
                        num_macros = 0; 
                        break;
                    }
                }
            }
        }

        if (num_macros)
        {
            QYget_feet (&pp_feet, &num_feet, pp_macros, num_macros);

            for (i=0; i<num_feet; ++i)
            {
                FIfld_set_text(form_ptr, ATTRIBUTE_LIST, i, 0, pp_feet[i], FALSE);
                FIfld_set_list_text(form_ptr, VALUE_FIELD, i, 0, pp_feet[i], FALSE);
            }
        }
        else
        {
            ex$message(msgnumb = GR_E_InvMacName, buff = msgbuff);
            FIfld_set_text (form_ptr, MESSAGE, 0, 0, msgbuff, FALSE);
            switch_state = concatenate = FALSE;
            back_up = TRUE;
        }
    }
        break;

    case ATTRIBUTE_LIST:
        text[0] = '\0';
        FIfld_get_num_rows (form_ptr, ATTRIBUTE_LIST, &num);
        for (i=0; i<num; ++i)
        {
            FIfld_get_select (form_ptr, ATTRIBUTE_LIST, i, 0, &sel);
            if (sel)
            {
                FIfld_get_text (form_ptr, ATTRIBUTE_LIST, i, 0, 1024, text, &sel, & pos);
                break;
            }
        }
        FIfld_set_text (form_ptr, ATTRIBUTE_FIELD, 0, 0, text, FALSE);

    case ATTRIBUTE_FIELD:
        FIfld_get_text (form_ptr, ATTRIBUTE_FIELD, 0, 0, 1024, text, &sel, & pos);
        if (!QYis_string_on_list ( form_ptr, ATTRIBUTE_LIST, text ))
        {
          ex$message(msgnumb = GR_E_InvFtAttrName, buff = msgbuff);
          FIfld_set_text ( form_ptr, MESSAGE, 0, 0, msgbuff, FALSE);
          switch_state = concatenate = FALSE;
        }
        else
          switch_state = concatenate = (text[0] != '\0');
        break;

    case NE:
    case EQ:
    case GE:
    case LE:
    case GT:
    case LT:
    break;

    case VALUE_FIELD:
        FIfld_get_text_length ( form_ptr, VALUE_FIELD, 0, 0, &len );
        if (len < 2)
        {
            concatenate = switch_state = FALSE;
            FIfld_pos_cursor (form_ptr, VALUE_FIELD, 0, 0, 0, 0, 0, 0);
        }
        else
        {
          int i;
          
          FIfld_get_text ( form_ptr, VALUE_FIELD, 0, 0, 1024, text, &sel, &pos );
          for (i = 0; text [i]; i++)
            if (!(text [i] >= '0' && text [i] <= '9'))
            {
              /* a name was keyed in, it must be a valid attribute */
              if (!QYis_string_on_list ( form_ptr, ATTRIBUTE_LIST, text ))
              {
                ex$message(msgnumb = GR_E_InvFtAttrName, buff = msgbuff);
                FIfld_set_text (form_ptr, MESSAGE, 0, 0, msgbuff, FALSE);
                switch_state = concatenate = FALSE;
                FIfld_pos_cursor ( form_ptr, VALUE_FIELD, 0, 0, 0, 0, 0, 0 );
                break;
              }
            }
        }
        break;

    case AND_CHECK:
    case AND_NOT_CHECK:
    case OR_CHECK:
    case OR_NOT_CHECK:
    break;

    case RESET_BUTTON:
        om$send ( msg = message QYnpt.init_query (),
                  targetid = my_id );
        switch_state = FALSE;
        concatenate = FALSE;
        break;

    case BACKUP_BUTTON:
        om$send ( msg = message QYnpt.back_up_query(),
                  targetid = my_id );
        switch_state = FALSE;
        concatenate = FALSE;
        break;

    case EXIT: /* Quit and push query */
        {
        int  response;
        long ok, buffersize;

        FIfld_get_text ( form_ptr, QUERY, 0, 0, QUERY_LEN, query, &sel, &pos);

        /*
         * Push the query on the queue.
         */
        buffersize = strlen(query) + 1;
        response = EX_STRING;

        ex$putque ( msg = &ok,
                    response = &response,
                    byte = &buffersize,
                    buffer = query );
/*
        KLUDGY_FUNC_TO_PUT_STRING_ON_RECALL_LIST (query);
*/
        }
        
    case QUIT: /* Erase and reset the form, this will also reset query state */
        {
          int sts;
          
          om$send( msg = message CEO.erase_form_by_label ( form_label, 0, &sts ),
                   targetid = my_id );
          msg = sts;
        }
        om$send( msg = message QYnpt.init_query (),
                 targetid = my_id );
        switch_state = FALSE;
        concatenate = FALSE;
        break;

    case QUERY:
        switch_state = FALSE;
        concatenate = FALSE;
        break;
    }

    if (concatenate)
    {
        om$send ( msg = message QYnpt.add_to_query (gadget_label),
                  targetid = my_id );
    }
        
    if (switch_state)
    {
        me->query_state = (me->query_state == 5) ? 2 : me->query_state + 1;

        om$send ( msg = message QYnpt.switch_query_state 
                                            (me->query_state, TRUE),
                  targetid = my_id );
    }
    else if (back_up)
    {
        om$send ( msg = message QYnpt.back_up_query (),
                  targetid = my_id );
    }
        
    return (OM_S_SUCCESS);
}

end implementation QYnpt;

