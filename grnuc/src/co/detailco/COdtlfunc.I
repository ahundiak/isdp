/* #######################    APOGEE COMPILED   ######################## */
class implementation COdetail;

#include <coimport.h>
#include <FI.h>
#include <msdef.h>
#include <msmacros.h>

/*
  History
    ???        mm/dd/yy            initial spec & wrote it
    elp        02/06/93            call EXwait_timer
*/

IGRint
_ds_err_msg( form,
             label,
             mess,
             key )
    Form       form;
    IGRint     label;
    IGRchar    *mess;
    IGRlong    key;
{

    IGRchar    buffer[80], *p;

    if ( mess ) p = mess;
    else 
    {
        p = buffer;
        ex$message(msgnumb = key,
                   buff = p );
    }

    FIfld_set_text(form, label, 0, 0, p, FALSE);

#ifdef X11
    sleep(1);
#else
    Wait_timer(40);
#endif

    FIfld_set_text(form, label, 0, 0, "", FALSE);

    return(1);
}

#define MAX_LOC_STDS     2

IGRint
_ds_upd_standards( form )
    Form   form;
{
    struct ds_standard  *stds, standards[MAX_LOC_STDS],std;
    IGRint              status, ok;
    IGRint              i=0, def_std, max_index;
    IGRint              num_stds;

    status = OM_S_SUCCESS;     
    ok = MSSUCC; 

    /*
     * Set the number of rows in the field gadget. 
     *
     */
    status = gr$get_num_standards( msg = &ok,
                                   num_standards = &num_stds );
    _err_ck2(status,ok);

    /*
     * Set the number of rows in the standard field.
     */
    if ( FIfld_set_num_rows(form, STANDARD_FIELD, (!num_stds)?1:num_stds) )
    {
        ok = MSFAIL;
        goto quit;
    }

    /* 
     * Update the standard field if there are any standards.
     */
    if ( num_stds ) 
    {
        
        /*
         * Get an array of form update structures.
         */
        if (num_stds > MAX_LOC_STDS) 
        {
            if ( !(stds = (struct ds_standard *)om$malloc( size = (num_stds * 
                                     sizeof(struct ds_standard))))) 
            {
                ok = MSFAIL;
                goto quit;
            }
        } 
        else /* use the stack buffers provided */
        {
            stds = standards;
        }

        /*
         * Get the standards and determine the default.
         */
        status = gr$get_standards ( msg = &ok,
                                    standards = (IGRchar *)stds );
        _err_ck2(status,ok);

        status = gr$get_default_standard ( msg = &ok,
                                           standard = &std );

        for ( def_std = 0; def_std < num_stds; def_std++ ) 
            if ( !strcmp(std.name, stds[def_std].name) ) break;

        /* 
         * Update the scroll list 
         */
        max_index = num_stds - 1;
        for ( i=0; i<num_stds; i++ ) 
        {
            FIfld_set_text(form, 
                           STANDARD_FIELD, 
                           i, 0, 
                           (stds + i)->name,
                           (i == def_std) );
        }    

        /*
         * Make the default standard appear in the field.
         */
        FIfld_set_active_row ( form, STANDARD_FIELD, def_std, 0);

        /* Trash the form update array.*/
        if (num_stds > MAX_LOC_STDS) 
        {
            om$dealloc( ptr = stds );     
        }
        _err_ck2(status,ok);

    }
    else /* There are no standards erase the field */
    {
        FIfld_set_text(form, STANDARD_FIELD, 0, 0, "", FALSE);
    }

quit:
    return(status & ok & 1);
}          

#define MAX_LOC_SHTS     10

IGRint
_ds_upd_sheets(form, sht)
    Form               form;
    struct ds_sheet    *sht;
{
    IGRint              i,max_index;
    struct ds_standard  std;
    struct ds_sheet     *shts, sheets[MAX_LOC_SHTS];
    IGRlong             status,ok;
    IGRint              num_shts, num_stds, def_sht, num_rows;

    status = OM_S_SUCCESS;
    ok = MSSUCC;

    i = 0;     
	
    status = gr$get_num_standards ( msg = &ok,
                                    num_standards = &num_stds );
    _err_ck2(status,ok);

    if ( num_stds ) 
    {

        status = gr$get_default_standard ( msg = &ok,
                                           standard = &std );
        _err_ck2(status,ok);

        status = gr$get_num_sheets( msg = &ok,
                                     num_sheets = &num_shts );
        _err_ck2(status,ok);

    } 
    else num_shts = 0;

   /*	*** FIX 90N0801 ****
    * unselect all the existing rows before reseting the number of rows.
    */
    FIfld_get_num_rows(form, SHEET_FIELD,&num_rows);
    for(i=0;i<num_rows;i++)
      FIfld_set_select(form, SHEET_FIELD,i,0,0);

    /*
     * set the number of rows in the field gadget. This will clear any
     * unused lines.
     */
    FIfld_set_num_rows(form, SHEET_FIELD, (!num_shts)?1:num_shts);

    /* 
     * If there are any sheets update the field.
     */
    if ( num_shts ) 
    {
        /*
         * Get an array of form update structs.
         */

        if (num_shts > MAX_LOC_SHTS) 
        {
            if ( !(shts = (struct ds_sheet *)om$malloc( size = (num_shts * 
                                            sizeof(struct ds_sheet)) ) ) )
            {
                ok = MSFAIL;
                goto quit;
            }

        } 
        else  shts = sheets; /* use the stack buffers provided */
      
        /*
         * Get all sheets defined for the current standard.
         */
        status = gr$get_sheets ( msg = &ok,
                                 sheets = (IGRchar *)shts );
        _err_ck2(status,ok);

        /*
         * Determine the default sheet. If a default has not been set 
         * make the default the first sheet on the list.
         */
        for ( def_sht = 0; def_sht < num_shts; def_sht++ ) 
            if ( !strcmp(sht->name, shts[def_sht].name) ) break;

        if ( def_sht == num_shts ) def_sht = 0;

        /*
         * Make me->sheets equal to the default sheet.
         */
        *sht = shts[def_sht];

        max_index = num_shts - 1;

        /*
         * Fill in the form update structs for all sheets.
         */
        for ( i=0; i<num_shts; i++ ) 
        {
            FIfld_set_text(form, 
                           SHEET_FIELD, 
                           i, 0, 
                           (shts + i)->name, 
                           (i == def_sht));
        }

        /*
         * Trash any malloced memory.
         */

        if (num_shts > MAX_LOC_SHTS) /* Then we malloced */
        {

             om$dealloc( ptr = shts );
        }

    }
    else 
    {
        FIfld_set_text(form, SHEET_FIELD, 0, 0, "", FALSE);
    }

quit:
     return (status & ok & 1);
}

IGRint
_ds_set_toggle(form)
    Form   form;
{
    struct ds_standard  std;
    IGRlong             status, ok;

    status = OM_S_SUCCESS;     
    ok = MSFAIL;
     
    status = gr$get_default_standard ( msg = &ok,
                                       standard = &std );
    _err_ck2(status,ok);

    FIg_set_state(form, 
                  UNITS_TOGGLE,
                  std.units);

    FIg_set_state(form, 
                  ANGLE_TOGGLE,
                  std.projection_angle);
quit:
    return (status);
}

IGRint
_ds_upd_toggle(form,
               std,
               label)
    Form                form;
    struct ds_standard  *std;
    IGRint              label;
{
    IGRint              state, t1, t2;
     
    /*
     * Determine which toggle needs updating.
     */
    switch (label) 
    {
         case UNITS_TOGGLE:
              t1 = std->imperial;
              t2 = std->metric;
              break;
         case ANGLE_TOGGLE:
              t1 = std->third;
              t2 = std->first;
              break;
         default:
              goto quit;
    }
     
    /*
     * Determine the current state of the toggle.
     */
    FIg_get_state(form, label, &state);

    /*
     * If the state of the toggle is illegal issue a warning 
     * and toggle it back the other way.
     */
    if ( (!state && !t1) ||
         ( state && !t2) ) 
    {
        IGRlong  temp1;

        temp1 = (label == UNITS_TOGGLE) ? GR_E_IllDefUnit : GR_E_IllDefProjAng;
        _ds_err_msg(form, MSG_FIELD , (char *)NULL, temp1);

        FIg_set_state(form, label, !state);
    }
    else /* update the standard */
    {
        if ( label == UNITS_TOGGLE ) 
        {
            std->units = (std->units == DS_IMPERIAL)
                          ? DS_METRIC : DS_IMPERIAL;
        }
        else 
        {
            std->projection_angle = (std->projection_angle == DS_THIRD_ANGLE)
                                           ? DS_FIRST_ANGLE : DS_THIRD_ANGLE;
        }
    }

quit:
     return (1);
}

IGRint
_ds_upd_std_subform ( form, std, mode )
    Form                form;
    struct ds_standard  *std;
    IGRint              mode;
{
    IGRchar buffer[BUFSIZ];

    ex$message(msgnumb = (mode ? GRC_M_EdtDrwStd : GRC_M_AddDrwStd),
               buff = buffer);

    FIg_erase(form, FORM_TITLE_TEXT);

    FIg_set_text(form, FORM_TITLE_TEXT, buffer);

    FIg_display(form, FORM_TITLE_TEXT);

    FIfld_set_text(form, STANDARD_FIELD, 0, 0, std->name, FALSE);

    FIg_set_state(form, IMPERIAL_CHECK, std->imperial);

    FIg_set_state(form, METRIC_CHECK, std->metric);
     
    FIg_set_state(form, UNITS_TOGGLE, std->units);

    FIg_set_state(form, FIRST_CHECK, std->first);
     
    FIg_set_state(form, THIRD_CHECK, std->third);
     
    FIg_set_state(form, ANGLE_TOGGLE, std->projection_angle);

    return (1);    
}

IGRint
_ds_upd_sht_subform ( form, sht, mode )
    Form                form;
    struct ds_sheet     *sht;
    IGRint              mode;
{
    IGRdouble           d;
    IGRchar             buffer[BUFSIZ],str[BUFSIZ];
    OM_S_OBJID          mod_oid;
    OMuword             mod_osnum;
    IGRint              status,ok;

    status = OM_S_SUCCESS;
    ok = MSSUCC;

    ex$message(msgnumb = (mode ? GRC_M_EdtDrwSht : GRC_M_AddDrwSht),
               buff = buffer);

    FIg_erase(form, FORM_TITLE_TEXT);

    FIg_set_text(form, FORM_TITLE_TEXT, buffer);

    FIg_display(form, FORM_TITLE_TEXT);

    FIfld_set_text(form, STANDARD_FIELD, 0, 0, sht->standard, FALSE);

    FIg_set_state(form, UNITS_TOGGLE, sht->units);

    FIfld_set_text(form, SHEET_FIELD, 0, 0, sht->name, FALSE);

    FIfld_set_text(form, FILENAME_FIELD, 0, 0, sht->file, FALSE);
     
    FIfld_set_text(form, VIEW_CELL_FIELD, 0, 0, sht->view, FALSE);
    
    FIg_set_state(form, FILE_TOGGLE, sht->filetype);

    status = ex$get_cur_mod( id = &mod_oid, 
                             osnum = &mod_osnum );

    strcpy(str, (sht->units ? "mm" : "in"));

    if (sht->height) 
    {
         status = co$cvt_value_to_value(
                        msg = &ok,
                        unit_type = "UOM_DISTANCE",
                        osnum = mod_osnum,
                        alias_to_cvt_from = NULL,
                        alias_to_cvt_to = str,
                        num_vals = 1,
                        values_in = &sht->height,
                        values_out = &d );

         sprintf(buffer,"%.3f %s",d,str);
    }
    else buffer[0] = NULL;

    FIfld_set_text(form, HEIGHT_FIELD, 0, 0, buffer, FALSE);

    if (sht->width) 
    {
         status = co$cvt_value_to_value(
                        msg = &ok,
                        unit_type = "UOM_DISTANCE",
                        osnum = mod_osnum,
                        alias_to_cvt_from = NULL,
                        alias_to_cvt_to = str,
                        num_vals = 1,
                        values_in = &sht->width,
                        values_out = &d );
         sprintf(buffer,"%.3f %s",d,str);
    }
    else buffer[0] = NULL;

    FIfld_set_text(form, WIDTH_FIELD, 0, 0, buffer, FALSE);

    return (status & ok & 1);
}

IGRint
_ds_upd_button ( form, auto_fit, auto_active)
    Form    form;
    IGRint  auto_fit;
    IGRint  auto_active;
{
    FIg_set_state(form,FIT_TOGGLE,auto_fit);

    FIg_set_state(form,ACTIVE_TOGGLE,auto_active);

    return(1);
}

end implementation COdetail;
