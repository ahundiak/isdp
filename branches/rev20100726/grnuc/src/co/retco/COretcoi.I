class implementation COretco;



#define MAX_LOC_UPD	20
#define MAX_LOC_CMDS	100

#include "coimport.h"

extern int EX_file_create_list();
extern int EX_set_up_file();
extern int EX_get_file_default();
extern int EX_get_cmd_info();
extern int Wait_timer();
extern int COtool_access_file ();
extern int COtool_fi_message ();



method set_options ()
{
  int		  status = OM_S_SUCCESS;


    status = OM_S_SUCCESS;

    if (!EX_set_up_file((me->filename[0] == '\0') ? NULL : me->filename,
                        (me->seedfile[0] == '\0') ? NULL : me->seedfile,
                        (me->firstcmd[0] == '\0') ? NULL : me->firstcmd,
                        &(me->create) ) )
    {
        status = OM_E_ABORT;
    }
          
    return(status);
quit:
  return OM_S_SUCCESS;
}

method set_gadgets ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong             ok, i;
    IGRchar             *cmds[MAX_LOC_CMDS];
    IGRint              num_of_cmds=MAX_LOC_CMDS;
    struct EX_cmd       cmd;

    status = ok = OM_S_SUCCESS;

    /*
     * Get the current retrieve file options.
     */
    if ( !EX_get_file_default( me->filename,
                               me->seedfile,
                               me->firstcmd,
                               &(me->create) ) ) 
    {
        status = OM_E_ABORT;
    }
    else 
    {
        /* 
         * Get a list of the file creation commands and put them
         * in the command_field's pop up list.
         */
        if ( EX_file_create_list( cmds, &num_of_cmds ) ) 
        {
            if ( num_of_cmds )
            {
                FIfld_set_list_num_rows( me->forms[0].form_ptr,     
                                         COMMAND_FIELD, 
                                         0, 
                                         num_of_cmds );

                for (i=0; i<num_of_cmds; i++ ) 
                {
                    FIfld_set_list_text(me->forms[0].form_ptr, 
                                        COMMAND_FIELD, 
                                        i, 0, 
                                        cmds[i], 
                                        FALSE);
                }
            }
        }

        /*
         * Fill in the filename field.
         */
        FIfld_set_text( me->forms[0].form_ptr, 
                        FILE_FIELD, 
                        0, 0, 
                        me->filename, 
                        FALSE );
  
        /*
         * Fill in the seed filename field.
         */
        FIfld_set_text( me->forms[0].form_ptr, 
                        SEED_FIELD, 
                        0, 0, 
                        me->seedfile, 
                        FALSE );

        /*
         * Fill in the command name field.
         */
        FIfld_set_text( me->forms[0].form_ptr, 
                        COMMAND_FIELD, 
                        0, 0, 
                        ( EX_get_cmd_info(me->firstcmd, EX_CMD_KEY, &cmd) ) ?
                        cmd.command_name_ptr : "",
                        FALSE );


        /*
         * Set the create check.
         */
        FIg_set_state( me->forms[0].form_ptr, 
                       CREATE_CHECK,
                       me->create );
    }

    return(status);
quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

    IGRint              ok, i;
    IGRuint             perms;
    IGRint              s;
    IGRchar             path[MAX_FILENAME_LEN], *p, str[MAX_FILENAME_LEN];
    struct EX_cmd       cmd;     

    status = ok = OM_S_SUCCESS;
    switch (gadget_label) 
    {
    case FILE_FIELD:

        FIfld_get_text( form_ptr, 
                        gadget_label, 
                        0, 0, 
                        MAX_FILENAME_LEN, 
                        str,  
                        &s, &i );

        if ( str[0] ) 
        {
            /*
             * See if the file exist and if it does get it's access
             * permissions. The file is looked for in (1) current 
             * directory, (2) direct path, (3) path relative to product
             * directories.
             */
            COtool_access_file ( &perms, str, path );

            /*
             * If the file does not exist set the create flag.
             */
            if ( perms == CO_no_file ) 
            {
                COtool_fi_message( form_ptr, 
                                   MESSAGE_FIELD, 
                                   GR_E_FlNExCr, 
                                   100 );
                strncpy(me->filename,str,MAX_FILENAME_LEN);
                me->filename[MAX_FILENAME_LEN - 1] = '\0';
                FIg_set_state_on(form_ptr, CREATE_CHECK);
                me->create = TRUE;
            }
            /*
             * Else the file exists.
             */
            else 
            {
                /* 
                 * If you don't have read access to the file
                 * set the filename back to what is was before.
                 */
                if ( !(perms & CO_file_read) ) 
                {
                    COtool_fi_message( form_ptr, 
                                       MESSAGE_FIELD, 
                                       GR_E_NoRead, 
                                       100 );
                    FIfld_set_text(form_ptr, gadget_label, 0, 0, me->filename, FALSE);
                }
                /*
                 * Else if the file is a directory.
                 */
                else if ( perms & CO_file_dir ) 
                {
                    COtool_fi_message( form_ptr, 
                                       MESSAGE_FIELD, 
                                       GR_E_FlIsDir, 
                                       100 );
                    FIfld_set_text(form_ptr, gadget_label, 0, 0, me->filename, FALSE);
                }     
                else 
                {
                    strncpy(me->filename, path, MAX_FILENAME_LEN);
                    me->filename[MAX_FILENAME_LEN - 1] = '\0';
                }
            }
        }
        else me->filename[0] = NULL;

        break;

    case CREATE_CHECK:

        FIg_get_state ( form_ptr, gadget_label, &me->create );

        break;

    case SEED_FIELD:

        ok = TRUE;

        FIfld_get_text( form_ptr, 
                        gadget_label, 
                        0, 0, 
                        MAX_FILENAME_LEN, 
                        str, 
                        &s, &i );

        if ( str[0] ) 
        {
            /*
             * See if the file exist and if it does get it's access
             * permissions. The file is searched for in (1) current 
             * directory, (2) direct path, (3) path relative to product
             * directories.
             */
            COtool_access_file ( &perms, str, path );

            /* 
             * If the file is still not found, prepend the "config" directory
             * to the string and look for it in the config directories.
             */
            if ( perms == CO_no_file ) 
            {
                strcpy(path, str);
                sprintf(str,"config/%s",path);
                COtool_access_file ( &perms, str, path );
            }

            /*
             * If the file exists.
             */
            if ( perms & CO_file_exists ) 
            {
                /*
                 * If the file can't be read.
                 */
                if ( !(perms & CO_file_read) ) 
                {
                    COtool_fi_message( form_ptr, 
                                       MESSAGE_FIELD, 
                                       GR_E_NoRead, 
                                       100 );

                    FIfld_set_text( form_ptr, 
                                    gadget_label, 
                                    0, 0, 
                                    me->seedfile, 
                                    FALSE );
                    ok = FALSE;
                }
                else if ( perms & CO_file_dir ) 
                {
                    COtool_fi_message( form_ptr, 
                                       MESSAGE_FIELD, 
                                       GR_E_FlIsDir, 
                                       100 );

                    FIfld_set_text ( form_ptr, 
                                     gadget_label, 
                                     0, 0, 
                                     me->seedfile, 
                                     FALSE );

                    ok = FALSE;
                }
                else 
                {
                    /* 
                     * Set the seedfile and update field to reflect path.
                     */
                    strncpy(me->seedfile, path, MAX_FILENAME_LEN);
                    me->seedfile[MAX_FILENAME_LEN - 1] = '\0';

                    FIfld_set_text( form_ptr, 
                                    gadget_label, 
                                    0, 0, 
                                    path, 
                                    FALSE );
                }
            }
            else
            {
                COtool_fi_message( form_ptr, 
                                   MESSAGE_FIELD, 
                                   GR_E_FileNotFound, 
                                   100 );

                FIfld_set_text( form_ptr, 
                                gadget_label, 
                                0, 0, 
                                me->seedfile, 
                                FALSE );
            }
        }
        else me->seedfile[0] = '\0';

        break;

    case COMMAND_FIELD:

        FIfld_get_text( form_ptr, 
                        gadget_label, 
                        0, 0, 
                        MAX_FILENAME_LEN, 
                        str, 
                        &s, &i );
        if ( !(*str)) 
        {
            me->firstcmd[0] = '\0';
        }
        else 
        {
            if ( p = strchr(str, '=') )
            {
                *p = '\0';
                i = TRUE;
            }
            else i = FALSE;

            if ( EX_get_cmd_info(str, EX_STRING, &cmd) ) 
            {
                if ( i ) 
                {
                    *p = '=';
                    strncpy(me->firstcmd, str, MAX_COMMAND_LEN);
                    me->firstcmd[MAX_COMMAND_LEN - 1] = '\0';
                }
                else 
                {
                    strncpy(me->firstcmd, cmd.command_key,MAX_COMMAND_LEN);
                    me->firstcmd[MAX_COMMAND_LEN - 1] = '\0';
                              
                    FIfld_set_text(form_ptr, 
                                   gadget_label, 
                                   0, 0, 
                                   cmd.command_name_ptr, 
                                   FALSE);
                    }
                }
                else /* Invalid Command */
                { 
                    COtool_fi_message( form_ptr, 
                                       MESSAGE_FIELD, 
                                       EX_F_CmdNotFound, 
                                       100 );
                    if ( me->firstcmd[0] ) 
                    {
                        EX_get_cmd_info(me->firstcmd, EX_CMD_KEY, &cmd);

                        FIfld_set_text( form_ptr, 
                                        gadget_label, 
                                        0, 0, 
                                        cmd.command_name_ptr, 
                                        FALSE );
                    }
                    else 
                    {
                        FIfld_set_text( form_ptr, 
                                        gadget_label, 
                                        0, 0, 
                                        "", 
                                        FALSE );
                    }
                }
            }
            break;

        case EXIT_BUTTON:
        case QUIT_BUTTON:
            _put_response(resp = FORM_FINISHED);
            {
              int msg;

              om$send( msg = message CEO.erase_form_by_label( form_label, 0,
                                                              &msg ),
                       targetid = my_id );
            }
            break;                              
    }

    return(status);
quit:
  return OM_S_SUCCESS;
}

end implementation COretco;
