/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include <exmacros.h>
#include <grmessage.h>
#include <expression.h>
#include <ASmsg.h>

/*
  History
     ???        mm/dd/yy           initial spec & wrote it
     elp        02/06/93           use EXwait_timer instead of sleep &
                                   Wait_timer
*/

method update_active_row (IGRint label; IGRint * msg)
{
    IGRint om_msg = OM_S_SUCCESS;
    IGRint index, i, rows, sel, pos;
    IGRchar attr[MAX_ATTR], value[MAX_VALUE], buffer[256];
    IGRchar * form_ptr;

    *msg = MSSUCC;

    om_msg = om$send ( msg = message CEO.get_form_ptr ( label,
                                                        &form_ptr,
                                                        &index,
                                                        msg ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        /*
         * Get the name for the active part.
         */
        attr[0] = '\0'; index = -1;
        om_msg = co$part_get_attr ( msg = msg,
                                    mod_env = &me->ModuleInfo,
                                    part = &me->part,
                                    attr = NUMBER_NAME,
                                    index = &index,
                                    value = value );

        if (om_msg & *msg & 1)
        {
            /*
             * Set the active row in the parts field.
             */
            FIfld_get_num_rows (form_ptr,CO_PARTS,&rows);

            for (i=0; i<rows; ++i)
            {
                FIfld_get_text(form_ptr,CO_PARTS,i,1,256,buffer,&sel,&pos);

                if (!strcmp(value, buffer))
                {
                    FImcf_set_select (form_ptr,CO_PARTS,i,1);
                    break;
                }
            }
        }
    }

    if(!(om_msg & *msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method display_form_by_label (IGRint label; IGRint * msg; )
{
    IGRint      om_msg = OM_S_SUCCESS;
    IGRint      index, displayed;
    IGRchar *   form_ptr;

    *msg = MSSUCC;

    om_msg = om$send ( msg = message CEO.get_form_ptr ( label,
                                                        &form_ptr,
                                                        &index,
                                                        msg ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        if (label == CO_edit_part)
        {
            /* temporary kludge until problem in which editing a part name or
               number causes corruption is fixed -- tr92n4819 */

            FIfld_set_mode(form_ptr, CO_NUMBER, 0, FI_REVIEW);
            FIfld_set_mode(form_ptr, CO_NAME, 0, FI_REVIEW);
        }

        FIf_is_displayed (form_ptr, &displayed);

        if (!displayed)
        {
            om_msg = om$send ( msg = message CEO.display_form_by_label ( label,
                                                                         msg ),
                               mode = OM_e_wrt_message,
                               targetid  = my_id );
        }
    }

    if (!(om_msg & *msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method reset_form_by_label (IGRint label; IGRint * msg; )
{
    IGRint      om_msg = OM_S_SUCCESS;
    IGRint      index, mask;
    IGRchar *   form_ptr;

    *msg = MSSUCC;


    om_msg = om$send ( msg = message CEO.get_form_ptr ( label,
                                                        &form_ptr,
                                                        &index,
                                                        msg ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        FIf_reset (form_ptr);

        if (label == CO_create_part)
        {
            FIfld_set_mode (form_ptr, CO_NUMBER, 0, FI_INSERT);
            FIfld_set_mode (form_ptr, CO_NAME,   0, FI_INSERT);
            FIfld_set_mode (form_ptr, CO_STATIC, 0, FI_INSERT);
            FIfld_set_mode (form_ptr, CO_STATIC, 1, FI_INSERT);
        }
        else if (label == CO_review_parts)
        {
            FImcf_get_attr (form_ptr, CO_PARTS, &mask);
            FImcf_set_attr (form_ptr, CO_PARTS, mask | FI_ROW_SELECT);
        }

    }

    if (!(om_msg & *msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method update_form_by_label (IGRint label; IGRint * msg)
{
    IGRint  om_msg = OM_S_SUCCESS, count, i;
    IGRchar * form_ptr;
    IGRint  index, num, row, sel, num_rows;
    IGRchar * number_p[50], number_data[50 * MAX_VALUE];
    IGRchar * number = NULL, ** number_pp = NULL;
    IGRchar * name_p[50], name_data[50 * MAX_VALUE];
    IGRchar * name = NULL, ** name_pp = NULL;
    IGRint  * quantity = NULL, quantity_data[50];
    IGRchar   buffer[256];

    *msg = MSSUCC;

    om_msg = om$send ( msg = message CEO.get_form_ptr ( label,
                                                        &form_ptr,
                                                        &index,
                                                        msg ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        switch ( label )
        {
            case CO_create_part:
            case CO_review_parts:

                /*
                 * Find the number of part types that exist in this
                 * file.
                 */
                co$part_get_parts ( msg = msg,
                                    mod_env = &me->ModuleInfo,
                                    num = &num );

                /*
                 * If the number is greater than the stack buffersize
                 * allocate some more memory.
                 */
                if ( num > 50 )
                {
                    number = om$malloc (size = num * MAX_VALUE);
                    number_pp = (IGRchar **)om$malloc(size = num * sizeof(IGRchar *));

                    if (label == CO_review_parts)
                    {
                        name = om$malloc (size = num * MAX_VALUE);
                        name_pp = (IGRchar **)om$malloc (size = num * sizeof(IGRchar *));
                        quantity = (IGRint *)om$malloc (size = num * sizeof(IGRint));
                    }
                }
                else
                {
                    number = number_data;
                    number_pp = number_p;

                    if (label == CO_review_parts)
                    {
                        name = name_data;
                        name_pp = name_p;
                        quantity = quantity_data;
                    }
                }

                /*
                 * If the space could be allocated ...
                 */
                if (((label != CO_review_parts) && number) ||
                    ((label == CO_review_parts) && number && name && quantity))
                {
                    /*
                     * Set the pointers to the character strings.
                     */
                    for (i=0; i<num; ++i)
                    {
                        number_pp[i] = &number[i * MAX_VALUE];

                        if (label == CO_review_parts)
                        {
                            name_pp[i] = &name[i * MAX_VALUE];
                        }
                    }

                    /*
                     * Get the list of part types.
                     */
                    co$part_get_parts ( msg = msg,
                                        mod_env = &me->ModuleInfo,
                                        number = number_pp,
                                        name = name_pp,
                                        quantity = quantity,
                                        num = &count );
                    if (label == CO_create_part)
                    {
                        /*
                         * Place all part types on the associated list.
                         */
                        for (i=0; i<num; ++i)
                        {
                            FIfld_set_list_default_text ( form_ptr,
                                                          CO_NUMBER,
                                                          i,0,
                                                          number_pp[i],
                                                          0 );
                        }
                    }
                    else if (label == CO_review_parts)
                    {
                        row = 0;

                        for (i=0; i<num; i=i+1)
                        {
                            FImcf_get_select (form_ptr, CO_PARTS, i, &sel);

                            if (sel == 1)
                            {
                                row = i;
                                break;
                            }
                        }

                        FIfld_get_num_rows (form_ptr, CO_PARTS, &num_rows);

                        for (i=0; i<num; i=i+1)
                        {
                            if (row == i)
                            {
                                co$part_get_template( msg = msg,
                                                      mod_env = &me->ModuleInfo,
                                                      number = number_pp[i],
                                                      part = &me->part );

                                sel = 1;
                            }
                            else sel = 0;

                            sprintf(buffer, "%d", quantity[i]);
                            FIfld_set_text (form_ptr,CO_PARTS,i,0,buffer, sel);
                            FIfld_set_text (form_ptr,CO_PARTS,i,1,number_pp[i],sel);
                            FIfld_set_text (form_ptr,CO_PARTS,i,2,name_pp[i],sel);

                            if (sel == 1)
                            {
                                om_msg = om$send ( msg = message COpart.update_form_attributes_by_label
                                                                ( label,
                                                                  msg,
                                                                  NULL,
                                                                  NULL,
                                                                  CO_STATIC,
                                                                  NULL ),
                                                   targetid = my_id );
                            }
                        }

                        if (num_rows > num)
                        {
                            for (i=num; i<num_rows; i=i+1)
                            {
                                FIfld_set_text (form_ptr,CO_PARTS,i,0,"",0);
                                FIfld_set_text (form_ptr,CO_PARTS,i,1,"",0);
                                FIfld_set_text (form_ptr,CO_PARTS,i,2,"",0);
                            }
                        }

                        FIfld_set_num_rows (form_ptr,CO_PARTS,num);
                    }

                    /*
                     * If space had to be allocated for the part types,
                     * deallocate it now.
                     */
                    if ( num > 50 )
                    {
                        om$dealloc (ptr = number);
                        om$dealloc (ptr = number_pp);

                        if (label == CO_review_parts)
                        {
                            om$dealloc (ptr = name);
                            om$dealloc (ptr = name_pp);
                            om$dealloc (ptr = quantity);
                        }
                    }
                }

                break;
        }
    }
    else *msg = MSFAIL;

    if (!(om_msg & *msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method update_form_attributes_by_label ( IGRint        label;
                                         IGRint      * msg;
                                         IGRint        number_label;
                                         IGRint        name_label;
                                         IGRint        static_label;
                                         IGRint        dynamic_label )
{
    IGRint      om_msg = OM_S_SUCCESS;
    IGRchar     * form_ptr;
    IGRint      index, i;
    IGRint      num_static, num_dynamic;
    IGRint      num_static_rows, num_dynamic_rows;

    om_msg = om$send ( msg = message CEO.get_form_ptr ( label,
                                                        &form_ptr,
                                                        &index,
                                                        msg ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        /*
         * Get the attributes for the active part.
         */
        om_msg = om$send ( msg = message COpart.get_attributes
                                                ( msg,
                                                  1,
                                                  (label != CO_review_parts) ),
                           targetid = my_id );

        if (om_msg & *msg & 1)
        {
            /*
             * Fill in the part number.
             */
            if (number_label)
            {
               FIfld_set_text (form_ptr,number_label,0,0,&me->value[0][0],0);
            }

            /*
             * Fill in the part name.
             */
            if (name_label)
            {
                FIfld_set_text (form_ptr,name_label,0,0,&me->value[1][0],0);
            }

            if (static_label || dynamic_label)
            {
                num_static  = num_static_rows  = 0;
                num_dynamic = num_dynamic_rows = 0 ;

                if (static_label)
                {
                   FIfld_get_num_rows (form_ptr,static_label,&num_static_rows);
                }

                if (dynamic_label)
                {
                   FIfld_get_num_rows (form_ptr,dynamic_label,&num_dynamic_rows);
                }

                /*
                 * Fill in the rest of the attributes.
                 */
                for (i=2; i<me->num_attrs; i=i+1)
                {
                    if ((me->type[i] & GR_COMMON_ATTR) && static_label)
                    {
                        /*
                         * Update the attribute name.
                         */
                        FIfld_set_text (form_ptr,static_label,num_static,0,&me->attr[i][0],0);

                        /*
                         * Update the attribute value.
                         */
                        FIfld_set_text (form_ptr,static_label,num_static++,1,&me->value[i][0],0);
                    }
                    else if ( dynamic_label )
                    {
                        /*
                         * Update the attribute name.
                         */
                        FIfld_set_text (form_ptr,dynamic_label,num_dynamic,0,&me->attr[i][0],0);

                        /*
                         * Update the attribute value.
                         */
                        FIfld_set_text (form_ptr,dynamic_label,num_dynamic++,1,&me->value[i][0],0);
                    }
                }

                /*
                 * Clear out any unused rows.
                 */
                for (i=num_static; i<num_static_rows; ++i)
                {
                    FIfld_set_text (form_ptr,static_label,i,0,"",0);
                    FIfld_set_text (form_ptr,static_label,i,1,"",0);
                }
                FIfld_set_num_rows (form_ptr,static_label,num_static);

                for (i=num_dynamic; i<num_dynamic_rows; ++i)
                {
                   FIfld_set_text (form_ptr,dynamic_label,i,0,"",0);
                   FIfld_set_text (form_ptr,dynamic_label,i,1,"",0);
                }
                FIfld_set_num_rows (form_ptr,dynamic_label,num_dynamic);
            }
        }
    }

    if (!(om_msg & *msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method query_form_by_label  ( IGRint label; IGRint * msg )
{
    IGRint      om_msg = OM_S_SUCCESS;
    IGRint      index, i;
    IGRchar     * form_ptr;
    IGRchar     buffer1[256], buffer2[256], msgbuff[200];
    IGRint      sel, pos;
    IGRint      num = 0, num_static, num_dynamic;

    *msg = MSSUCC;

    om_msg = om$send ( msg = message CEO.get_form_ptr ( label,
                                                        &form_ptr,
                                                        &index,
                                                        msg ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        if (label == CO_review_parts)
        {
            num = 2;
        }
        else
        {
            /*
             * Get the part number and name.
             */
            FIfld_get_text(form_ptr,CO_NUMBER,0,0,256,buffer1,&sel,&pos);
            FIfld_get_text(form_ptr,CO_NAME,0,0,256,buffer2,&sel,&pos);

            if ( (buffer1[0]=='\0') || (buffer2[0]=='\0') )
            {
                ex$message(msgnumb = GR_I_EnterPrtNumNam,
                           buff = msgbuff);

                FIfld_set_text(form_ptr,CO_MESSAGE,0,0,msgbuff,0);
                num = 0;
            }
            else
            {
                num = 2;
            }
        }

        if (num >= 2)
        {
            num_static = num_dynamic = 0;

            FIfld_get_num_rows ( form_ptr, CO_STATIC, &num_static );

            if (label != CO_review_parts)
            {
                FIfld_get_num_rows ( form_ptr, CO_DYNAMIC, &num_dynamic );
            }

            num += num_static + num_dynamic;

            if (num > om$dimension_of(varray = me->attr))
            {
                om$vla_set_dimension(varray = me->attr,  size = num + 5);
                om$vla_set_dimension(varray = me->value, size = num + 5);
                om$vla_set_dimension(varray = me->type,  size = num + 5);
            }

            if (label != CO_review_parts)
            {
                strcpy(&me->attr[0][0],NUMBER_NAME);
                strcpy(&me->value[0][0],buffer1);
                me->type[0] = GR_STATIC_ATTR;

                strcpy(&me->attr[1][0],DESCRIPTION_NAME);
                strcpy(&me->value[1][0],buffer2);
                me->type[1] = GR_STATIC_ATTR;

                num = 2;
            }
            else num = 0;

            for (i=0; i<num_static; ++i)
            {
                FIfld_get_text (form_ptr,CO_STATIC,i,0,256,buffer1,&sel,&pos);
                FIfld_get_text (form_ptr,CO_STATIC,i,1,256,buffer2,&sel,&pos);

                if (buffer1[0] != '\0')
                {
                    strncpy(&me->attr[num][0], buffer1, MAX_ATTR);
                    me->attr[num][MAX_ATTR - 1] = '\0';

                    strncpy(&me->value[num][0], buffer2, MAX_VALUE);
                    me->value[num][MAX_VALUE - 1] = '\0';

                    me->type[num++] = GR_STATIC_ATTR;
                }
            }

            for (i=0; i<num_dynamic; ++i)
            {
                FIfld_get_text (form_ptr,CO_DYNAMIC,i,0,256,buffer1,&sel,&pos);
                FIfld_get_text (form_ptr,CO_DYNAMIC,i,1,256,buffer2,&sel,&pos);

                if (buffer1[0] != '\0')
                {
                    strncpy(&me->attr[num][0], buffer1, MAX_ATTR);
                    me->attr[num][MAX_ATTR - 1] = '\0';

                    strncpy(&me->value[num][0], buffer2, MAX_VALUE);
                    me->value[num][MAX_VALUE - 1] = '\0';

                    me->type[num++] = GR_DYNAMIC_ATTR;
                }
            }
        }
    }

    if (!(om_msg & *msg & 1) || ((label != CO_review_parts) && (num < 2)) )
    {
        me->num_attrs = 0;
        *msg = MSFAIL;
    }
    else
    {
        me->num_attrs = num;
    }

    if (!(om_msg & *msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method form_notification ( IGRint       form_label;
                           IGRint       gadget_label;
                           IGRdouble    value;
                           IGRchar    * form_ptr )
{
    IGRint      om_msg = OM_S_SUCCESS, msg = MSSUCC;
    IGRchar     buffer[256], number[256], msgbuff[200];
    IGRint      sel, pos, mode, row, delete;
    IGRint      num, index, i;
    IGRint      response;
    IGRshort    is_valid_name;

    FIfld_set_text (form_ptr,CO_MESSAGE,0,0,"",0);

    switch ( gadget_label )
    {
        case CO_NUMBER:
            /*
             * Get the new part number.
             */
            FIfld_get_text(form_ptr,CO_NUMBER,0,0,256,buffer,&sel,&pos);
	
	    i = 0;
	    is_valid_name = TRUE;

	    while ( buffer[i] != '\0' ){
	      if ( ((buffer[i] >= '0') && (buffer[i] <= '9')) ||
		   ((buffer[i] >= 'a') && (buffer[i] <= 'z')) ||
                   ((buffer[i] >= 'A') && (buffer[i] <= 'Z')) ||
                   (buffer[i] == '-') || (buffer[i] == '_') ||
		   (buffer[i] == '.') ){
		      i = i + 1;
	       } else {
		      is_valid_name = FALSE;        /* invalid model name */
		      break;
	       };
	    }

	    if ( !is_valid_name )
	    {
                ex$message(msgnumb = GR_I_InvNumEntAgain,
                           buff = msgbuff);

                FIfld_set_text(form_ptr,CO_MESSAGE,0,0,msgbuff,0);
                FIfld_set_text (form_ptr,CO_NUMBER,0,0,"",0);
		break;
	    }

            /*
             * Get the current part number.
             */
            index = -1;
            co$part_get_attr ( msg = &msg,
                               mod_env = &me->ModuleInfo,
                               part = &me->part,
                               attr = NUMBER_NAME,
                               index = &index,
                               value = number );

            if (!strchr(buffer, ':'))
            {
                /*
                 * Get the number of attributes.
                 */
                om_msg = co$part_get_all_attr ( msg = &msg,
                                                mod_env = &me->ModuleInfo,
                                                number = buffer,
                                                num = &num );

                if (om_msg & msg & 1)
                {
                    if (form_label == CO_create_part)
                    {
                        /*
                         * Get a template id for this part number, this
                         * will be used by update_form_attributes_by_label.
                         */
                        co$part_get_template ( msg = &msg,
                                               mod_env = &me->ModuleInfo,
                                               number = buffer,
                                               part = &me->part );

                        /*
                         * Set the mode to review only.
                         */
                        FIfld_get_mode (form_ptr,CO_NAME,0,&mode);

                        if (mode != FI_REVIEW)
                        {
                            mode = FI_REVIEW;
                            FIfld_set_mode(form_ptr,CO_NAME,0,mode);
                            FIfld_set_mode(form_ptr,CO_STATIC,0,mode);
                            FIfld_set_mode(form_ptr,CO_STATIC,1,mode);
                            FIg_display(form_ptr,CO_NAME);
                            FIg_display(form_ptr,CO_STATIC);
                        }

                        /*
                         * Update the form based on the attributes from this part.
                         */
                        om_msg = om$send ( msg = message COpart.update_form_attributes_by_label
                                                                ( CO_create_part,
                                                                  &msg,
                                                                  NULL,
                                                                  CO_NAME,
                                                                  CO_STATIC,
                                                                  CO_DYNAMIC ),
                                               targetid = my_id );
                    }
                    else if (form_label == CO_edit_part)
                    {
                        if (strcmp (number, buffer))
                        {
                            /*
                             * Issue a warning and set the name back to
                             * what it was.
                             */
                            ex$message(msgnumb = GR_I_NumAlreadyUsed,
                                       buff = msgbuff);

                            FIfld_set_text (form_ptr,CO_MESSAGE,0,0,msgbuff,0);

#ifdef X11
                            sleep(1);
#endif
#ifdef ENV5
                            Wait_timer(40);
#endif

                            FIfld_set_text (form_ptr,CO_MESSAGE,0,0,"",0);
                            FIfld_set_text (form_ptr,CO_NUMBER,0,0,number,0);
                        }
                    }
                }
                else if (form_label == CO_create_part)
                {
                    /*
                     * Set the mode to edit.
                     */
                    FIfld_get_mode (form_ptr, CO_NAME, 0, &mode);

                    if (mode == FI_REVIEW)
                    {
                        mode = FI_INSERT;
                        FIfld_set_mode(form_ptr,CO_NAME,0,mode);
                        FIfld_set_mode(form_ptr,CO_STATIC,0,mode);
                        FIfld_set_mode(form_ptr,CO_STATIC,1,mode);
                        FIg_display(form_ptr,CO_NAME);
                        FIg_display(form_ptr,CO_STATIC);
                    }
                }
            }
            else
            {
                /*
                 * Issue a warning and set the name back to
                 * what it was.
                 */
                ex$message(msgnumb = GR_I_BadPartNum,
                           buff = msgbuff);
                FIfld_set_text (form_ptr,CO_MESSAGE,0,0,msgbuff,0);

#ifdef X11
                sleep(1);
#endif
#ifdef ENV5
                Wait_timer(40);
#endif

                FIfld_set_text (form_ptr,CO_MESSAGE,0,0,"",0);
                FIfld_set_text (form_ptr,CO_NUMBER,0,0,number,0);
            }
            break;

        case CO_STATIC:
        case CO_DYNAMIC:

            FIg_get_state (form_ptr,CO_DELETE,&delete);

            if ((value == -1) && (delete == 1))
            {
                row = -1;

                FIfld_get_active_row (form_ptr,gadget_label,&row,&pos);

                if (row >= 0)
                {
                    FIfld_get_num_rows (form_ptr,gadget_label,&num);

                    for (i=row; i<num-1; i=i+1)
                    {
                        FIfld_get_text (form_ptr,gadget_label,i+1,0,256,buffer,&sel,&pos);
                        FIfld_set_text (form_ptr,gadget_label,i,0,buffer,&sel);
                        FIfld_get_text (form_ptr,gadget_label,i+1,1,256,buffer,&sel,&pos);
                        FIfld_set_text (form_ptr,gadget_label,i,1,buffer,&sel);
                    }

                    FIfld_set_text (form_ptr,gadget_label,num-1,0,"",&sel);
                    FIfld_set_text (form_ptr,gadget_label,num-1,1,"",&sel);
                }
            }
            else
            {
                IGRint row;
                
                FIfld_get_active_row (form_ptr,gadget_label,&row,&pos);
                
                FIfld_get_text (form_ptr,gadget_label,row,1,256,buffer,&sel,&pos);
                
                if (strlen(buffer) >= EXP_MAX_LEN)
                {
                    ex$message(msgnumb = AS_S_Syntax_long,
                               buff = buffer);
                    FIfld_set_text (form_ptr,CO_MESSAGE,0,0,buffer,0);

#ifdef X11
                    sleep(1);
#endif
#ifdef ENV5
                    Wait_timer(40);
#endif
                    FIfld_set_text(form_ptr,CO_MESSAGE,0,0,"",0);
                    FIfld_set_text(form_ptr,gadget_label,row,1,"",0);
                }
            }
            break;

        case CO_PARTS:
            /*
             * Get the name of the active part.
             */
            FIfld_get_num_rows (form_ptr, CO_PARTS, &num);

            for (i=0; i<num; ++i)
            {
                FImcf_get_select (form_ptr, CO_PARTS, i, &sel);

                if (sel == 1)
                {
                    FIfld_get_text ( form_ptr,
                                     CO_PARTS,
                                     i, 1,
                                     256,
                                     buffer,
                                     &sel,
                                     &pos );

                    co$part_get_template ( msg = &msg,
                                           mod_env = &me->ModuleInfo,
                                           number = buffer,
                                           part = &me->part );
                    break;
                }
            }

            om_msg = om$send ( msg = message COpart.update_form_attributes_by_label
                                                        ( form_label,
                                                          &msg,
                                                          NULL,
                                                          NULL,
                                                          CO_STATIC,
                                                          NULL ),
                               targetid = my_id );

            break;

        case CO_ACCEPT:
        case CO_CANCEL:
        case CO_MODIFY:
        {
            long byte;

            response = gadget_label + CO_RESPONSE_MASK;
            byte = sizeof(struct EX_button);

            ex$putque ( msg = (long *)&msg,
                        response = &response,
                        byte = &byte,
                        buffer = me->response_data );

            if ( gadget_label != CO_MODIFY ) {
              om$send( msg = message CEO.erase_form_by_label( form_label, 0,
                                                              &msg ),
                       targetid = my_id );
            }
        }
            break;

    }

    return (OM_S_SUCCESS);
}

end implementation COpart;
