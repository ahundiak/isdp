/*
Name
        GRpalmgr

Abstract
        Palette manager method implementations.

Description
        This file contains method implementations for the palette manager
        class.  This class provides a storage for palettes saved in an object
        space.
    
History:

        jay wallingford     04/10/89    creation date
        scw                 08/09/94    clarified sleep method
*/
    
class implementation GRpalmgr;

#include <stdio.h>

extern char EX_version[];
extern struct palette * GRpal_palettes;
extern struct palette * GRpal_create();
extern int GRpal_set_outline_fp();
extern int GRpal_get_header_info();
extern int GRpal_get_cmd_info();
extern int GRpal_add_cmd();
extern int GRpal_get_cmd_icon();
extern int GRpal_add_popup_icons();
extern int EX_clear_command_on_save ();

/*
Name
        GRpalmgr.wake_up

Description
        This method initializes and displays all palettes.

Notes
        The initial display of palettes upon entry into a design session used
        to take place in a startup command to ensure that the palettes would
        appear on top of all menus and graphics windows.  Because of
        journaling problems, that functionality has been moved here, with the
        exec making sure that this object is not awakened until *after* all
        other menus/windows have been displayed.

History
        mrm     03/04/93    modified to handle X journaling
        mrm     05/19/93    added stopsign call
*/

method wake_up ()
{
    OM_S_OBJID  mod_objid;
    OMuword     mod_osnum;
    
    ex$get_cur_mod(id = &mod_objid, osnum = &mod_osnum);
                     
    /*
     * Only wake up palettes in the master file.
     */

    if (mod_osnum == OM_Gw_current_OS)
    {
        if (ex$is_temp_wakeup()) /* does this wakeup follow a sleep? */
        {
            if (EX_clear_command_on_save()) /* is journaling active? */
            {
#ifdef ENV5
                /*
                 * Redisplay the palettes if journaling is active and the
                 * clear journal on save flag is set.
                 */

                struct palette * p;
                p = GRpal_palettes;
                while (p) 
                {
                    FIf_display(p->form);
                    GRpal_add_popup_icons(p);
                    p = p->next;
                }
#endif

#ifdef X11
                /*
                    Recreate the palettes - they were deleted in sleep to keep
                    the jnl X monster at bay.
                */

                om$send(msg = message GRpalmgr.wake_up_palettes(),
                        targetid = my_id);
#endif
            }

            /*
             * Dealloc the arrays.
             */

            om$vla_set_dimension ( varray = me->palettes, size = 0 );
            om$vla_set_dimension ( varray = me->commands, size = 0 );
            om$vla_set_dimension ( varray = me->strings, size = 0 );
        }
        else /* Set up the outline file pointers */
        {
            GRpal_set_outline_fp();

            /* display the palettes */

            om$send(msg = message GRpalmgr.wake_up_palettes(),
                    targetid = my_id);
        }
    }

    return (OM_S_SUCCESS);
}

/*
Name
        GRpalmgr.sleep

History
        mrm     03/04/93    modified to handle X journaling
*/

method global_class.sleep (int type_sleep)
{
    int num, mask, label, max_label, row, col;
    struct palette * p;
    struct os_palette * os_p;
    struct os_palette_cmd * os_cmd_p;
    char command[256], symbol_file[256];
    OM_S_OBJID  mod_id;
    OMuword mod_osnum;
    
    ex$get_cur_mod ( id = &mod_id,
                     osnum = &mod_osnum );

    ex$file_status ( modid = mod_id,
                     modos = mod_osnum,
                     mode = &mask );

    /*
     * If the module is writable copy palettes to
     * the instance data.
     */
    if ( (mod_osnum == OM_Gw_current_OS) && !mask )
    {
        /*
         * Save the version.
         */
        om$send ( msg = message GRpalmgr.add_string ( EX_version,
                                                      &me->version ),
                  targetid = my_id );

        /*
         * Get the number of palettes.
         */
	num = 0;
        for ( p = GRpal_palettes; p != NULL; p = p->next ) ++num;

        /*
         * If there are any palettes.
         */
        if ( num )
        {
            /*
             * Set the dimension of palette array.
             */            
            if ( !(om$vla_set_dimension ( varray = me->palettes, size = num ) & 1) ) 
            {
                goto quit;
            }
                
            /*
             * Save the palette info for all palettes.
             */
            os_p = &(me->palettes[0]);
            for ( p = GRpal_palettes; p != NULL; p = p->next )
            {
                /*
                 * Save the palette header information.
                 */
                GRpal_get_header_info ( p,
                                        &os_p->xpos, &os_p->ypos,
                                        &os_p->xsize, &os_p->ysize,
                                        &os_p->rows, &os_p->cols,
                                        &os_p->btn_x, &os_p->btn_y,
                                        &os_p->color,
                                        &os_p->btn_on_color, &os_p->btn_off_color,
                                        &os_p->properties );
                /*
                 * Determine the number of commands.
                 */
                max_label = GRpal_group + (os_p->rows * os_p->cols);
                num = 0;
                for (label = GRpal_group + 1; label <= max_label; ++label) 
                {
                    FIg_get_attr (p->form, label, &mask);
                    if (!(mask & FI_NOT_DISPLAYED)) ++num;
                }

                /*
                 * Set the index into the command array.
                 */
                os_p->num_cmds = num;
                os_p->cmds = om$dimension_of(varray = me->commands);

                /*
                 * If there are any commands to save.
                 */                
                if ( num )
                { 
                    /*
                     * Set the dimension of command array.
                     */
                    if ( !(om$vla_set_dimension ( varray = me->commands, 
                                                  size = num + os_p->cmds ) & 1) )
                    {
                        os_p->num_cmds = 0;
                        goto quit;
                    }

                    /*
                     * Save each command.
                     */
                    os_cmd_p = &(me->commands[os_p->cmds]);
                    label = GRpal_group + 1;
                    for (row = 0; row < os_p->rows; ++row)
                    {
                        for (col = 0; col < os_p->cols; ++col, ++label)
                        {
                            /*
                             * If the button is displayed save it.
                             */
                            FIg_get_attr (p->form, label, &mask);

                            if (!(mask & FI_NOT_DISPLAYED))
                            {
                                /*
                                 * Save the row and column.
                                 */
                                os_cmd_p->row = row;
                                os_cmd_p->col = col;

                                /*
                                 * Save the button info.
                                 */
                                GRpal_get_cmd_info( p,
                                                    label,
                                                    command,
                                                    &os_cmd_p->command_type,
                                                    symbol_file,
                                                    &os_cmd_p->symbol );

                                /*
                                 * Add the command name and symbol file name
                                 * to the strings table.
                                 */
                                om$send(msg = message GRpalmgr.add_string 
                                                                ( command, 
                                                                  &os_cmd_p->command),
                                        targetid = my_id);

                                om$send(msg = message GRpalmgr.add_string 
                                                                ( symbol_file, 
                                                                  &os_cmd_p->symbol_file),
                                        targetid = my_id);

                                /*
                                 * Increment the os command pointer.
                                 */
                                ++os_cmd_p;
                            }
                        } 
                    } 
                } 
                ++os_p;
            } 
        } 
    } 

quit:

    /*
     * Put palettes to sleep if this is the master file.
     */
    if ( mod_osnum == OM_Gw_current_OS )
    {
        /*
         * If this file is being exited delete the palettes.
         */
        if ((type_sleep == EX_REAL_SLEEP) && GRpal_palettes)
        {
            struct palette * np;
    
            p=GRpal_palettes;

            do 
            {
                np = p->next;
                GRpal_delete (p); 
            } while (p=np);
        }
        else if (type_sleep == EX_TEMP_SLEEP) /* save, wakeup will follow */
        {
            if ( EX_clear_command_on_save()) /* is journaling active? */
            {
#ifdef ENV5
                /*
                 * Erase the palettes if journaling is active.
                 */

                p = GRpal_palettes;
                while (p) 
                {
                    FIf_erase(p->form);
                    GRpal_add_popup_icons(p);
                    p = p->next;
                }
#endif

#ifdef X11
                /*
                    Sigh.  Yet another journaling hack.  All the palettes must
                    be deleted for X journaling; erasing is not enough.  The
                    jnl X monster *must* see the window created after a save,
                    and FIf_erase behaves differently for X (just an erase)
                    and ENV5 (actually delets the window).
                */

                struct palette *np;
                
                p = GRpal_palettes;
                while (p)
                {
                    np = p->next;
                    GRpal_delete(p); 
                    p = np;
                }
#endif
            }
        }

        if (EX_clear_command_on_save())
            /* delete the popup menus */
            GRdelete_popups();
    }

    return(OM_S_SUCCESS);
}

method add_string ( IGRchar * string; IGRint * index )
{
    IGRint size, status = OM_S_SUCCESS, len;

    size = om$dimension_of(varray = me->strings);
    *index = 0;

    /*
     * Search for the string in the strings table.
     */
    while(*index < size)
    {
        if (!strcmp(string, &(me->strings[*index]))) return (status);
        else *index += strlen(&(me->strings[*index])) + 1;
    }

    /*
     * String is not found, allocate space for the new string and
     * copy it.
     */
    *index = size;
    size += (len = strlen(string) + 1);
    status = om$vla_set_dimension ( varray = me->strings,
                                    size = size );
    if ( status & 1 )
    {
	OM_BLOCK_MOVE ( string, &(me->strings[*index]), len );
    }

    return(status);
}

method wake_up_palettes ()
{
    int    msg, version_changed;
    struct palette * p;
    struct os_palette * os_p;
    struct os_palette_cmd * os_cmd_p;
    char   symbol_file[256], * symbol_file_p;
    int    symbol;
    int    i, j, n;

    if ( !(n = om$dimension_of(varray=me->palettes) ) ) goto quit;
    
    /*
     * See if the version has changed.
     */
    version_changed = strcmp(&(me->strings[me->version]), EX_version);

    /*
     * Recreate all the palettes.
     */ 
    os_p = &me->palettes[0];
    for (i=0; i<n; ++os_p, ++i) 
    { 
        /*
             Create a blank palette.  Make sure it has been adjusted to
             account for the message strip (TR91n0711).
         */
        if (p = GRpal_create(&msg, 
                             os_p->properties, 
                             os_p->rows, os_p->cols, 
                             os_p->color, 
                             os_p->xpos, 
                             (os_p->properties & PAL_YADJUSTED) ?
                             os_p->ypos : os_p->ypos + 55,
                             os_p->xsize, os_p->ysize,
                             os_p->btn_x, os_p->btn_y, 
                             os_p->btn_on_color, os_p->btn_off_color)) 
        {
            os_cmd_p = &me->commands[os_p->cmds];
            for (j=0; j<os_p->num_cmds; ++j, ++os_cmd_p)
            {
                /*
                 * If the command type is a command key check for
                 * a version change.
                 */
                if ((os_cmd_p->command_type == FI_CMD_KEY) && 
                    (os_cmd_p->symbol != -1))
                {
                    /*
                     * If the version has changed update the symbol file
                     * and number.
                     */
                    if (version_changed)
                    {
                        if (!GRpal_get_cmd_icon
                            (&me->strings[os_cmd_p->command],
                             symbol_file,
                             &symbol))
                        {
                            strncpy(symbol_file, 
                                    &me->strings[os_cmd_p->command],
                                    PAL_MAX_LABEL);
                            symbol_file[PAL_MAX_LABEL] = '\0';
                            symbol = -1;
                        }

                        symbol_file_p = symbol_file;
                    }
                    else /* use the symbol file and symbol as is */
                    {
                        symbol_file_p = &(me->strings[os_cmd_p->symbol_file]);
                        symbol = os_cmd_p->symbol;
                    }
                }
                else /* use the symbol file and symbol as is */
                {
                    symbol_file_p = &(me->strings[os_cmd_p->symbol_file]);
                    symbol = os_cmd_p->symbol;
                }

                GRpal_add_cmd ( p,
                                os_cmd_p->row, os_cmd_p->col,
                                os_cmd_p->command_type,
                                &(me->strings[os_cmd_p->command]),
                                symbol_file_p,
                                symbol );
            }
        }
    }

quit:

    /*
     * Dealloc the arrays.
     */
    om$vla_set_dimension ( varray = me->palettes, size = 0 );
    om$vla_set_dimension ( varray = me->commands, size = 0 );
    om$vla_set_dimension ( varray = me->strings, size = 0 );

    return (OM_S_SUCCESS);
}

end implementation GRpalmgr;

