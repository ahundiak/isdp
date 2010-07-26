/* #######################    APOGEE COMPILED   ######################## */
class implementation COdetail;

#include "coimport.h"

extern IGRint _ds_upd_standards();
extern IGRint _ds_upd_sheets();
extern IGRint _ds_set_toggle();
extern IGRint _ds_upd_std_subform();
extern IGRint _ds_upd_sht_subform();
extern IGRint _ds_upd_button();

method set_defaults ()
{

    me->ret = MSSUCC;

    /*
     *  Perform the necceary initialization of default values
     */
    me->name[0] = '\0'; 
    
    switch ( me->mytype ) {
    case CO_manageds:
    case CO_drawsheet:
        me->sheet.name[0] = '\0';
        me->active_form = MAIN_FORM;
        me->subform_mode = ADD_MODE;
        me->auto_fit = FALSE;
        me->auto_active = FALSE;
        break;

    default:
        me->model[0] = '\0';
        me->view[0] = '\0';
        me->desc[0] = '\0';
        me->text_scale[0] = '\0';
        me->text_name[0] = '\0';
        me->orientation = NULL;
        me->ref_info.prism_classname = NULL;
        me->ref_info.filename = NULL;
        me->ref_info.named_view = NULL;
        me->ref_info.description = NULL;
        me->ref_info.clip_poly = NULL;
        me->ref_info.ref_properties = NULL;
        me->ref_info.scale = NULL;
        break;
    }

    return(OM_S_SUCCESS);
}

method set_gadgets ()
{
    IGRlong             status,ok;
    IGRint              num;

    status = OM_S_SUCCESS;
    ok = MSSUCC;

    /*
     * If there are any standards set the toggles.
     */
    status = gr$get_num_standards( msg = &ok,
                                   num_standards = &num );
    _err_ck2(status,ok);
 
    /* 
     * Get the default standard.
     */
    if (num) 
    {
         status = gr$get_default_standard ( msg = &ok,
                                            standard = &me->tmp_std );
         _err_ck2(status,ok);
    }

    switch ( me->active_form ) 
    {
    case MAIN_FORM:
        if (num) 
        {
            status = _ds_set_toggle( me->forms[MAIN_FORM].form_ptr);
            _err_ck(status);
        }

        /*
         * Display the standards. If there aren't any standards the field 
         * will be cleared.
         */    
        status = _ds_upd_standards(me->forms[MAIN_FORM].form_ptr);
        _err_ck(status);

        /*
         * Display all the sheets for the current standard. If there isn't
         * a current standard or if there aren't any sheets the sheet field
         * will be cleared.
         */
        status = _ds_upd_sheets(me->forms[MAIN_FORM].form_ptr, &me->sheet);
        _err_ck(status);

        if ( me->mytype == CO_drawsheet ) 
        {
            status = _ds_upd_button(me->forms[MAIN_FORM].form_ptr, 
                                    me->auto_fit,
                                    me->auto_active);
            _err_ck(status);
        }
        break;

    case STANDARD_FORM:
        /*
         * If there aren't any standards set the tmp_std to NULL.
         */
        if ( !num ) 
        {
            me->tmp_std.name[0] = NULL;
            me->tmp_std.units = 0;
            me->tmp_std.metric = 0;
            me->tmp_std.imperial = 0;
            me->tmp_std.projection_angle = 0;
            me->tmp_std.first = 0;
            me->tmp_std.third = 0;
        }
        else if ( me->subform_mode == ADD_MODE ) me->tmp_std.name[0] = NULL;
              
        /*
         * Update the standard form.
         */
        status = _ds_upd_std_subform( me->forms[STANDARD_FORM].form_ptr,
                                      &me->tmp_std,
                                      me->subform_mode );
        _err_ck(status);
        break;

    case SHEET_FORM:
        status = gr$get_num_sheets ( msg = &ok,
                                     num_sheets = &num );
        _err_ck2(status,ok);

        /*
         * If there aren't any sheets set tmp_sht to NULL.
         */
        if ( !num ) 
        {
            me->tmp_sht.name[0] = NULL;
            strcpy(me->tmp_sht.standard, me->tmp_std.name);
            me->tmp_sht.file[0] = NULL;
            me->tmp_sht.view[0] = NULL;
            me->tmp_sht.units = me->tmp_std.units;
            me->tmp_sht.width = 0;
            me->tmp_sht.height = 0;
            me->tmp_sht.filetype = 0;
        }
        else if ( me->subform_mode == ADD_MODE ) me->tmp_sht.name[0] = NULL;

        /*
         * Update the sheet form.
         */
        status = _ds_upd_sht_subform( me->forms[SHEET_FORM].form_ptr,
                                      &me->tmp_sht,
                                      me->subform_mode );
        _err_ck(status);
        break;
    }     

quit:
    return (status);
}

end implementation COdetail;
