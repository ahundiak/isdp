/* #######################    APOGEE COMPILED   ######################## */
class implementation COdetail;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"

extern IGRint COtool_fi_message();
extern IGRint _ds_upd_standards();
extern IGRint _ds_upd_sheets();
extern IGRint _ds_set_toggle();
extern IGRint _ds_upd_toggle();
extern IGRint _ds_upd_std_subform();
extern IGRint _ds_upd_sht_subform();

/*
  History
    ???             mm/dd/yy           initial spec & wrote it
    elp             01/14/93           make sure all gadgets are initialized
                                       before displaying subform.  erase main
                                       form when "dismiss" button poked.
    Satya           08/09/94           increased the size of buffer from
				       80 to BUFSIZ and also intitialized
	                               buffer and text to NULL;
				       TR# 119418338

*/
method form_notification(int form_label; int gadget_label; double value; char * form_ptr)
{
    IGRint              num_shts, num_stds, index;
    struct ds_standard  std, new_std;
    struct ds_sheet     new_sht;
    IGRlong             status;
    IGRlong             ok;
    IGRint              resp;
    IGRlong             siz;
    IGRboolean          subform, flag, update;
    IGRchar             buffer[BUFSIZ], *name, text[BUFSIZ];
    IGRdouble           d, *dp = NULL;
    IGRint              sel_flag;
    IGRint              r_pos;
    OM_S_OBJID          mod_oid;
    OMuword             mod_osnum;

    status = OM_S_SUCCESS;
    ok = MSSUCC;
    index = value;
    update = flag = subform = FALSE;
    text[0] = buffer[0] = NULL;

    if ( (me->mytype == CO_revref) || (me->mytype == CO_revdv) )
    {
        status = om$send ( msg = message COdetail.review_notify ( form_label, 
                                                                  gadget_label, 
                                                                  value, 
                                                                  form_ptr ),
                           targetid = my_id );

        goto quit;
    }
    else if ( (me->mytype == CO_drawview) || (me->mytype == CO_attachmd))
    {
        status = om$send ( msg = message COdetail.options_notify ( form_label,
                                                                  gadget_label,
                                                                  value,
                                                                  form_ptr ),
                           targetid = my_id );

        goto quit;
    }

    /*
     * Get the number of standards and sheets.
     */
    status = gr$get_num_standards ( msg = &ok,
                                    num_standards = &num_stds );
    _err_ck2(status,ok);

    if ( num_stds ) 
    {
        status = gr$get_default_standard ( msg = &ok,
                                           standard = &std );
        _err_ck2(status,ok);
     
        status = gr$get_num_sheets ( msg = &ok,
                                     num_sheets = &num_shts );
        _err_ck2(status,ok);
    } 
    else 
    {
        num_shts = 0;
        std.name[0] = NULL;
    }

    /* 
     * Switch on current form.
     */
    switch ( form_label ) 
    {
    case MAIN_FORM:

        if ( gadget_label == STANDARD_FIELD ) 
        {

            FIfld_get_text ( form_ptr, 
                             STANDARD_FIELD, 
                             index, 
                             0, 
                             BUFSIZ, 
                             text, 
                             &sel_flag, 
                             &r_pos );
 
            /*
             * If a user clicks in a standard field on the edit standards form
             * and there are no standards defined, assume the user wants to add
             * a sheet and bring up the add standard subform.
             */
            if ( !num_stds && (me->mytype == CO_manageds) ) 
            {
                /* Bring up the add standard subform */
                gadget_label = STD_ADD_BUTTON;
            }
            else /* There are standards defined */
            {
                /*
                 * If the standard has changed.
                 */
                if ( strcmp(text, std.name ) )  
                {
                    /*
                     * Update the default standard. The default standard
                     * will always be the last one selected.
                     */
     
                    /* 
                     * Get the standard 
                     */
                    strcpy(new_std.name,text);
                    status = gr$get_standard( msg = &ok,    
                                              standard = &new_std );
                    _err_ck2(status,ok);

                    /*
                     * Make the standard the default.
                     */
                    status = gr$set_default_standard( msg = &ok,
                                                      standard = &new_std );
                    _err_ck2(status,ok);

                    /*
                     * Set all toggles according to the current standard.
                     */
                    status = _ds_set_toggle(form_ptr);
                    _err_ck(status);

                    /*
                     * Display all the sheets for the current standard.
                     */
                    status = _ds_upd_sheets(form_ptr, &me->sheet);
                    _err_ck(status);
                }
            }
        }
        else if ( gadget_label == SHEET_FIELD ) 
        {
            FIfld_get_text ( form_ptr,
                             SHEET_FIELD, 
                             index, 
                             0, 
                             BUFSIZ, 
                             text, 
                             &sel_flag, 
                             &r_pos );

            /*
             * If there user clicks in a empty sheet field when there are standards defined and 
             * the command is edit drawing sheet standards, assume the user wants to add a sheet
             * and bring up the add sheet subform.
             */ 
            if ( !num_shts && num_stds && (me->mytype == CO_manageds)) 
            {
                /* Bring up the add sheet subform */
                gadget_label = SHT_ADD_BUTTON;
            }
            else 
            /* 
             * If there are standards set the new sheet. 
             */
            if ( num_stds ) 
            {
                strcpy(new_sht.name, text);
                strcpy(new_sht.standard, std.name);
                new_sht.units = std.units;
                status = gr$get_sheet ( msg = &ok,
                                        sheet = &new_sht );
                _err_ck(status);

                if ( ok & 1 ) me->sheet = new_sht;
            }
        }

        /* 
         * Switch on appropriate label. 
         */
        switch ( gadget_label ) 
        {
        case ANGLE_TOGGLE:
            status = _ds_upd_toggle(form_ptr,
                                    &std,
                                    ANGLE_TOGGLE);
            _err_ck(status);

            /*
             * Modify the standards in the drawing sheet manager. Since the
             * default projection angle may have changed.
             */
            status = gr$mod_standard( msg = &ok, 
                                      standard = &std );
            _err_ck2(status,ok);
            break;
  
        case UNITS_TOGGLE:
            status = _ds_upd_toggle(form_ptr,
                                    &std,
                                    UNITS_TOGGLE);
            _err_ck(status);

            /*
             * Modify the standards in the drawing sheet manager. Since the
             * default units may have changed.
             */
            status = gr$mod_standard( msg = &ok, 
                                      standard = &std );
            _err_ck2(status,ok);
     
            /*
             * Display the new sheets.
             */
            status = _ds_upd_sheets(form_ptr, &me->sheet);
            _err_ck(status);
            break;

        case FIT_TOGGLE:
            /*
             * Set the auto fit switch.
             */
            me->auto_fit = value;
            break;

        case ACTIVE_TOGGLE:
            /*
             * Set the auto fit switch.
             */
            me->auto_active = value;
            break;

        case EXIT_BUTTON:
            resp = FORM_FINISHED;
            if ( me->mytype == CO_drawsheet ) 
            {
                if ( !num_shts || !num_stds ) 
                {
                    COtool_fi_message(form_ptr, MSG_FIELD, GR_E_NoShtDfn, 100);
                    break;
                }
                else resp = MOVE_ON;
            }

            /*
             * Push the response on the queue.
             */
            siz = sizeof(struct EX_button);
            ex$putque( msg = &ok,
                       response = &resp,
                       byte = &siz,
                       buffer = me->response_data );
#if 1
            status = om$send ( msg = message CEO.erase_form_by_label( 0, 1, 
                                                            (IGRint *) &ok),
                               targetid = my_id );
#endif
            break;

        case QUIT_BUTTON:
            /*
             * Push the response on the queue.
             */
            resp = FORM_FINISHED;
            siz = sizeof(struct EX_button);
            ex$putque( msg = &ok,
                       response = &resp,
                       byte = &siz,
                       buffer = me->response_data );
#if 1
            status = om$send ( msg = message CEO.erase_form_by_label( 0, 1, 
                                                            (IGRint *) &ok),
                               targetid = my_id );
#endif
            break;
     
        case STD_DEL_BUTTON:
            /*
             * If there are no standards defined issue
             * an error message.
             */
            if ( ! num_stds ) 
            {
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_NoStdDfn, 
                                   100 );
            }
            else 
            {
                /* 
                 * Delete the standard from the the drawing
                 * sheet manager. 
                 * NOTE: This will also delete all sheets associated 
                 *       with the standard. Also if the standard 
                 *       deleted was the default standard the default
                 *       is set to the top standard in the list.
                 */
                status = gr$del_standard(msg = &ok,
                                         standard = &std);
                /*
                 * Set defaults according to the modified drawing sheet manager.
                 * This is done to reflect any changes the drawing sheet manager
                 * made in response to the deletion of the standard.
                 */
                update = TRUE;
            }
            break;

        case STD_MOD_BUTTON:
            FIg_set_state_off(form_ptr, gadget_label);

            /*
             * If no standards to modify pop button backup and 
             * issue error message.
             */
            if ( !num_stds ) 
            {
                /* Issue and error message. */
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_NoStdDfn, 
                                   100 );
            }    

            /*
             * Setup request for modify standard subform.
             */                
            me->active_form = STANDARD_FORM;
            me->subform_mode = MOD_MODE;
            subform = TRUE;
            break;

        case STD_ADD_BUTTON:
            FIg_set_state_off(form_ptr, gadget_label);

            /*
             * Setup request for add standard subform.
             */                
            me->active_form = STANDARD_FORM;
            me->subform_mode = ADD_MODE;
            subform = TRUE;
            break;

        case SHT_DEL_BUTTON:
            /*
             * If there are no sheets defined issue
             * an error message.
             */
            if ( !num_shts ) 
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_NoShtDfn, 
                                   100 );
            else 
            {
                /* 
                 * Delete the sheet from the drawing sheet
                 * manager.
                 */
                status = gr$del_sheet( msg = &ok,
                                       sheet = &me->sheet );
                _err_ck2(status,ok);

                update = TRUE;
            }
            break;
 
        case SHT_MOD_BUTTON:
            FIg_set_state_off(form_ptr, gadget_label);

            /*
             * If no sheets to modify.
             */
            if ( !num_shts ) 
            {
                /* Issue and error message. */
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_NoShtDfn, 
                                   100 );
                break;
            }

            /*
             * Set up request form modify sheet subform.
             */
            me->active_form = SHEET_FORM;
            me->subform_mode = MOD_MODE;
            me->tmp_sht = me->sheet;
            subform = TRUE;
            break;

        case SHT_ADD_BUTTON:
            FIg_set_state_off(form_ptr, gadget_label);

            if (!num_stds)
            {
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_NoStdDfn, 
                                   100 );
                break;
            }

            /*
             * Set up request for add sheet subform.
             */
            me->active_form = SHEET_FORM;
            me->subform_mode = ADD_MODE;
            me->tmp_sht = me->sheet;
            me->tmp_sht.name[0] = NULL;
            subform = TRUE;
            break;
        }
        break;

    case STANDARD_FORM:
        /* 
         * Switch on appropriate label.
         */
        switch ( gadget_label ) 
        {
        case STANDARD_FIELD:

            FIfld_get_text(form_ptr, STANDARD_FIELD, index, 0, BUFSIZ, text, &sel_flag, &r_pos);
 
            /*
             * If the standard name has changed.
             */
            if (strcmp(me->tmp_std.name, text)) 
            {
                /*
                 * See if the standard exists.
                 */
                strcpy(new_std.name, text);
                status = gr$get_standard( msg = &ok, 
                                          standard = &new_std );
                _err_ck(status);

                /*
                 * If the standard is defined.
                 */
                if ( ok & 1 ) 
                {
                    me->tmp_std = new_std;

                    status = gr$set_default_standard( msg = &ok,
                                                      standard = &new_std );
                    _err_ck2(status,ok);

                    /*
                     * If we are adding a standard.
                     */
                    if ( me->subform_mode == ADD_MODE ) 
                    { 
                        me->tmp_std.name[0] = NULL; 
                        COtool_fi_message( form_ptr,
                                           MSG_FIELD, 
                                           GR_P_EntNwNm,
                                           100 );
                    }

                    status = _ds_upd_std_subform( form_ptr,
                                                  &me->tmp_std,
                                                  me->subform_mode );
                    _err_ck(status);
                }
                else 
                {
                    strcpy(me->tmp_std.name, text);
                }
            }
            break;
     
        case ANGLE_TOGGLE:
            if ( (!(me->tmp_std.projection_angle) && !(me->tmp_std.first)) ||
                 (me->tmp_std.projection_angle && !(me->tmp_std.third)) ) 
            {
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_EnProjAng,
                                   100 );
                FIg_set_state(form_ptr,gadget_label,me->tmp_std.projection_angle);
            }
            else me->tmp_std.projection_angle = !(me->tmp_std.projection_angle);
            break;

        case THIRD_CHECK:
            if ( ( value && me->tmp_std.projection_angle && !(me->tmp_std.first) ) ||
                 ( !(value) && !(me->tmp_std.projection_angle) && me->tmp_std.first ) )
            {
                FIg_set_state(form_ptr,ANGLE_TOGGLE,!value);
                me->tmp_std.projection_angle = !value;
            }
            me->tmp_std.third = !(me->tmp_std.third);
            break;

        case FIRST_CHECK:
            if ( ( value && !(me->tmp_std.projection_angle) && !(me->tmp_std.third) ) ||
                 ( !(value) && me->tmp_std.projection_angle && me->tmp_std.third) )
            {
                FIg_set_state(form_ptr,ANGLE_TOGGLE,value);
                me->tmp_std.projection_angle = value;
            }
            me->tmp_std.first = !(me->tmp_std.first);
            break;

        case UNITS_TOGGLE:
            if ( (value && !(me->tmp_std.metric)) ||
                 (!value && !(me->tmp_std.imperial)) ) 
            {
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_EnUnit,
                                   100 );
                FIg_set_state(form_ptr,gadget_label,me->tmp_std.units);
            }
            else me->tmp_std.units = !(me->tmp_std.units);
            break;

        case IMPERIAL_CHECK:
            if ( ( value && me->tmp_std.units && !(me->tmp_std.metric) ) ||
                 ( !(value) && !(me->tmp_std.units) && me->tmp_std.metric) )
            {
                FIg_set_state(form_ptr,UNITS_TOGGLE,!value);
                me->tmp_std.units = !value;
            }
            me->tmp_std.imperial= !(me->tmp_std.imperial);
            break;

        case METRIC_CHECK:
            if ( ( value && !(me->tmp_std.units) && !(me->tmp_std.imperial) ) ||
                 ( !(value) && me->tmp_std.units && me->tmp_std.imperial) )
            {
                FIg_set_state(form_ptr,UNITS_TOGGLE,value);
                me->tmp_std.units = value;
            }
            me->tmp_std.metric = !(me->tmp_std.metric);
            break;

        case EXIT_RETURN_BUTTON:
        case EXIT_BUTTON:
            /*
             * Check for a legal standard.
             */
            name = NULL;
  
            if ( !me->tmp_std.name[0] ) 
            {
                FIg_set_state_off(form_ptr, gadget_label);
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_P_EntNwNm,
                                   100 );
                break;   /* don't dismiss form until user corrects error */
            }
            else if( ((me->tmp_std.units) && (!me->tmp_std.metric)) ||
                     ((!me->tmp_std.units) && (!me->tmp_std.imperial)) ) 
            {
                FIg_set_state_off(form_ptr, gadget_label);
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_IllDefUnit,
                                   100 );
                break;   /* don't dismiss form until user corrects error */
            }
            else if( ((me->tmp_std.projection_angle) && (!me->tmp_std.first)) ||
                    ((!me->tmp_std.projection_angle) && (!me->tmp_std.third)) ) 
            {
                FIg_set_state_off(form_ptr, gadget_label);
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_IllDefProjAng,
                                   100 );
                break;   /* don't dismiss form until user corrects error */
            }
            else 
            {
                if ( me->subform_mode == MOD_MODE ) 
                {
                    /*
                     * If the standard name has changed.
                     */
                    if ( strcmp(std.name, me->tmp_std.name) ) 
                    {
                        /*
                         * Save the new name for the standard and reset
                         * the old standard name. This is needed to locate
                         * the sheet in the drawing sheet manager.
                         */
                        name = (IGRchar *)buffer;
                        strcpy(name, me->tmp_std.name);
                        strcpy(me->tmp_std.name, std.name);
                    }
                    else name = NULL;
                    
                    /*
                     * Modify the standard.
                     */
                    status = gr$mod_standard( msg = &ok,
                                              standard = &me->tmp_std,
                                              new_name = name);
                    _err_ck2(status,ok);

                    /*
                     * Reset the standard's name.
                     */
                    if (name) strcpy(me->tmp_std.name, name);
                }
                else 
                {
                    status = gr$add_standard( msg = &ok,
                                              standard = &me->tmp_std );
                    _err_ck2(status,ok);
                }

                status = gr$set_default_standard( msg = &ok,
                                                  standard = &me->tmp_std );
                _err_ck2(status,ok);
            }

        case QUIT_BUTTON:
            if ( gadget_label == EXIT_RETURN_BUTTON ) 
            {
                if (me->subform_mode == ADD_MODE) 
                {
                    COtool_fi_message( form_ptr,
                                       MSG_FIELD, 
                                       GR_I_StdAdd,
                                       100 );
                    me->tmp_std.name[0] = NULL;
                    FIfld_set_text(form_ptr, STANDARD_FIELD, 0, 0, "", &sel_flag);
                }
            }
            else subform = TRUE;
            break;
        }
        break;

    case SHEET_FORM:

        FIfld_get_text(form_ptr, gadget_label, index, 0, BUFSIZ, text, &sel_flag, &r_pos);

        /* 
         * Switch on appropriate label.
         */
        switch ( gadget_label ) 
        {
        case SHEET_FIELD:
            /*
             * If the sheet name has changed.
             */
            if ( strcmp(me->tmp_sht.name, text) ) 
            {
                /* 
                 * See if the sheet exists.
                 */
                strcpy(new_sht.name, text);
                strcpy(new_sht.standard, std.name);
                new_sht.units = me->tmp_sht.units;
                status = gr$get_sheet( msg = &ok,
                                       sheet = &new_sht );
                _err_ck(status);
                
                /* 
                 * If the sheet is defined.
                 */
                if ( ok & 1 ) 
                {
                    me->sheet = new_sht;
                    me->tmp_sht = new_sht;

                    /*
                     * If the standard name is different.
                     */
                    if (strcmp(std.name, new_sht.standard) ) 
                    {
                        strcpy(new_std.name,new_sht.name);
                        status = gr$get_standard( msg = &ok,
                                                  standard = &new_std );
                        _err_ck2(status,ok);

                        status = gr$set_default_standard ( msg = &ok,
                                                           standard = &new_std );
                        _err_ck2(status,ok);
                    }

                    status = _ds_upd_sht_subform( form_ptr,
                                                  &me->tmp_sht,
                                                  me->subform_mode );
                    _err_ck(status);

                    /*
                     * If we are adding a sheet.
                     */
                    if ( me->subform_mode == ADD_MODE ) 
                    {
                        me->tmp_sht.name[0] = NULL;
                        COtool_fi_message( form_ptr,
                                           MSG_FIELD, 
                                           GR_P_EntNwNm,
                                           100 );
                    }
                }
                else strcpy(me->tmp_sht.name, text);
            }
            break;
                         
        case UNITS_TOGGLE:
            /*
             * See if the new units are compatable with the standard.
             */
            if ( (value && !std.metric) ||
                 (!value && !std.imperial) )
            {
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_IllDefUnit,
                                   100 );
                FIg_set_state(form_ptr,gadget_label,me->tmp_sht.units);
            }
            else 
            {
                me->tmp_sht.units = value;
                if ( me->subform_mode == MOD_MODE ) 
                {
                    status = _ds_upd_sht_subform( form_ptr,
                                                  &me->tmp_sht,
                                                  me->subform_mode );
                }
                _err_ck(status);
            }
            break; 

        case FILE_TOGGLE:
            me->tmp_sht.filetype = value;
               
            ex$message(msgnumb = (me->tmp_sht.filetype ? GR_I_SavVw : GRC_M_CellNme),
                       buff = text);

            FIg_set_text(form_ptr,VIEW_CELL_TEXT,text);

            break;

        case FILENAME_FIELD:
            strcpy(me->tmp_sht.file, text);
            break;

        case VIEW_CELL_FIELD:
            strcpy(me->tmp_sht.view, text);
            break;
 
        case HEIGHT_FIELD:
            dp = &(me->tmp_sht.height);
            flag = TRUE;

        case WIDTH_FIELD:
            if (!flag) dp = &(me->tmp_sht.width);

            /*
             * Convert the string to working units.
             */
            co$epp( msg = &ok,
                    string = text,
                    sizebuf = BUFSIZ,
                    buffer = buffer );

            if ( ok == MSSUCC ) 
            {
                co$expreval( msg = &ok,
                             expression = buffer,
                             unit_type = "UOM_DISTANCE",
                             result = dp );
            }

            if (*dp > 0) 
            {
                /*
                 * Update to reflect the output units.
                 */
                status = ex$get_cur_mod( id = &mod_oid, 
                                         osnum = &mod_osnum );

                strcpy(buffer, ((me->tmp_sht.units) ? "mm" : "in"));
                status = co$cvt_value_to_value(
                                   msg = &ok,
                                   unit_type = "UOM_DISTANCE",
                                   osnum = mod_osnum,
                                   alias_to_cvt_from = NULL,
                                   alias_to_cvt_to = buffer,
                                   num_vals = 1,
                                   values_in = dp,
                                   values_out = &d );
                sprintf(text,"%.3f %s",d,buffer);
            }
            else 
            {
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_IllDim,
                                   100 );
                text[0] = NULL;
                *dp = 0;
            }

            FIfld_set_text(form_ptr,gadget_label,0,0,text,&sel_flag);
            break;

        case EXIT_RETURN_BUTTON:
        case EXIT_BUTTON:
            /*
             * Check for a legal sheet.
             */
            if ( !me->tmp_sht.name[0] ) 
            {
                FIg_set_state_off(form_ptr, gadget_label);
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_P_EntNwNm,
                                   100 );
                break;   /* don't dismiss form until user corrects error */
            }
            else if ( !me->tmp_sht.height || !me->tmp_sht.width ) 
            {
                FIg_set_state_off(form_ptr, gadget_label);
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   GR_E_IllDim,
                                   100 );
                break;   /* don't dismiss form until user corrects error */
            }
            else if ( me->tmp_sht.file[0] && !me->tmp_sht.view[0] ) 
            {
                FIg_set_state_off(form_ptr, gadget_label);
                COtool_fi_message( form_ptr,
                                   MSG_FIELD, 
                                   me->tmp_sht.filetype ? 
                                   GR_P_KySavVwNme : GR_P_KyCelNme,
                                   100 );
                break;   /* don't dismiss form until user corrects error */
            }
            else 
            {
                /* 
                 * If the sheet is being modified.
                 */
                if ( me->subform_mode == MOD_MODE ) 
                {
                    if ( strcmp(me->tmp_sht.name, me->sheet.name))
                    {
                        /*
                         * Save the new name for the sheet and reset
                         * the old sheet name. This is needed to locate
                         * the sheet in the drawing sheet manager.
                         */
                        name = (IGRchar *)buffer;
                        strcpy(name,me->tmp_sht.name);
                        strcpy(me->tmp_sht.name, me->sheet.name);
                    }
                    else name = NULL;

                    /*
                     * Modify the sheet.
                     */
                    status = gr$mod_sheet( msg = &ok,
                                           sheet = &me->tmp_sht,
                                           new_name = name );
                    _err_ck2(status,ok);

                    /*
                     * Reset the sheets name.
                     */
                    if (name) strcpy(me->tmp_sht.name, name);
                }
                else /* Adding a sheet */
                {
                    status = gr$add_sheet( msg = &ok, 
                                           sheet = &me->tmp_sht );
                    _err_ck2(status,ok);
                }
                me->sheet = me->tmp_sht;
            }

        case QUIT_BUTTON:
            if ( gadget_label == EXIT_RETURN_BUTTON ) 
            {
                if (me->subform_mode == ADD_MODE) 
                {
                    COtool_fi_message( form_ptr,
                                       MSG_FIELD, 
                                       GRC_M_ShtAdded,
                                       100 );
                    me->tmp_sht.name[0] = NULL;

              /*    FIfld_set_text(form_ptr,gadget_label,0,0,"",&sel_flag); */

                    FIfld_set_text(form_ptr,SHEET_FIELD,0,0,"",&sel_flag); 
			/** FIX_90N1449 **/

                }
            }
            else subform = TRUE;
            break;

        }
        break;
    }

    /*
     * If a subform is becoming the active form or the main form is 
     * becoming active.
     */
    if ( subform ) 
    {
        /* 
         * If a subform is being taken down.
         */
        if ( (gadget_label == EXIT_BUTTON) || 
             (gadget_label == QUIT_BUTTON) ) 
        {
            /*
             * Request an erasure of the subform.
             */
/*---------------------------------------------------------------------------
    Begin TR: 90N2178 - Replaced FIf_erase with CEO.erase_form_by_label
                        since cob was not being notified of the erasure
                        of the form.

            FIf_erase(form_ptr);
  --------------------------------------------------------------------------*/
            status = om$send ( msg = message CEO.erase_form_by_label(
                                                            me->active_form, 
                                                            1, 
                                                            (IGRint *)&ok),
                               targetid = my_id );
/*---------------------------------------------------------------------------
    End   TR: 90N2178
  --------------------------------------------------------------------------*/

            /*
             * Make the main form the active form.
             */
            me->active_form = MAIN_FORM;
            
            /*
             * Request an update of the main form.
             */
            update = TRUE;

        }
        else /* Bringing up a subform */
        {
#if 1
            /*
             * Set the gadgets on the subform.
             */
             status = om$send( msg = message COdetail.set_gadgets(),
                               targetid = my_id);
             _err_ck(status);
#endif
            /*
             * Request a display for the subform.
             */
/*---------------------------------------------------------------------------
    Begin TR: 90N2178 - Replaced FIf_display with CEO.display_form_by_label
                        since cob was not being notified of the display/erasure
                        of the form.

            FIf_display(me->forms[me->active_form].form_ptr);
  --------------------------------------------------------------------------*/
            status = om$send ( msg = message CEO.display_form_by_label(
                                                            me->active_form, 
                                                            (IGRint *)&ok),
                               targetid = my_id );
/*---------------------------------------------------------------------------
    End   TR: 90N2178
  --------------------------------------------------------------------------*/

            /*
             * If we are adding a sheet or standard start the sequence.
             */    
            if (me->subform_mode == ADD_MODE) {
                form_label = me->active_form;
                gadget_label = (form_label == SHEET_FORM) ?
                                              SHEET_FIELD :
                                           STANDARD_FIELD ;
                FIf_set_seq_on(me->forms[form_label].form_ptr);
                FIg_start_seq(me->forms[form_label].form_ptr, gadget_label);
            }
            else {
                FIf_set_seq_off(me->forms[form_label].form_ptr);
            }

#if 0
            /*
             * Set the gadgets on the subform.
             */
            update = TRUE;
#endif
        }
    }

    if ( update ) 
    {
        /*
         * Update the active form.
         */
        status = om$send( msg = message COdetail.set_gadgets(),
                          targetid = my_id);
        _err_ck(status);
    }   

quit:

    return (status);
}

end implementation COdetail;

