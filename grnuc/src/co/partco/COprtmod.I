/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>

from GRpart import GRchg_part;

method modify_part ( int label; int * msg )
{
    int  om_msg = OM_S_SUCCESS;
    int  index/*,i,count,sts*/;
    char buffer1[256], buffer2[256], * form_ptr;
/*
    char regexp[256],path[256],**entries;
*/
    char catalog[256], revision[256];
    char *p_catalog, *p_revision;
    extern void GRpart_find_catalog();

    om_msg = om$send ( msg = message CEO.get_form_ptr ( label,
                                                        &form_ptr,
                                                        &index,
                                                        msg ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        if (label != CO_review_parts)
        {
            /*
             * Get the active part's number.
             */
            index = -1;
            buffer1[0] = buffer2[0] = '\0';

            co$part_get_attr ( msg = msg,
                               mod_env = &me->ModuleInfo,
                               part = &me->part,
                               index = &index,
                               attr = NUMBER_NAME,
                               value = buffer2 );

            /*
             *  Find out which catalog the part number is found in
             *  NOTE: this function returns p_catalog == NULL if the
             *  catalog is "local".  Otherwise, p_catalog remains
             *  pointing to catalog and catalog will contain the
             *  PDU catalog name. srh 5/18/92
             */
	    p_catalog = &catalog[0];
            GRpart_find_catalog( msg, &me->ModuleInfo, buffer2, &p_catalog);

            if ( *msg == CO_E_PARTSLIST_ERROR)
            {
               /* does not exist or not unique */
               goto quit;
            }

	    if (p_catalog) /* i.e. its a PDU part */
	    {
               /*
                * Get the active part's catalog.
                */
               index = -1;
               co$part_get_attr ( msg = msg,
                                  mod_env = &me->ModuleInfo,
                                  part = &me->part,
                                  index = &index,
                                  attr = CATALOG_NAME,
                                  value = catalog );

               /*
                * Get the active part's revision.
                */
               index = -1;
               co$part_get_attr ( msg = msg,
                                  mod_env = &me->ModuleInfo,
                                  part = &me->part,
                                  index = &index,
                                  attr = REVISION_NAME,
                                  value = revision );

            }
	    else /* is a "local" part */
	    {
	      p_revision = NULL;
            }

            /*
             * If the part number has change part for all parts of this type.
	     * KLUDGE by shelley: this code is core dumping and it's 1 minute
	     * to midnight on the Nucleus Clock - pload deadline that is.
	     * For now, we will not allow the name to change.  This needs to
	     * be fixed in the VERY near future.  5/21/92
             */
            if (strcmp(buffer2, &me->value[0][0]))
            {
		/*
                om_msg = co$part_pass ( msg = msg,
                                        pass_msg = message GRpart.GRchg_part
                                                           ( msg,
                                                             p_catalog,
                                                            &me->value[0][0],
                                                             revision),
                                        mod_env = &me->ModuleInfo,
                                        number = buffer2 );
                if (!(*msg & 1))
                */

                {
                    /*
                     * Set it back to what it was.
                     */
		    /*
		     * srh: reset to old value until we allow name changes 
		     */
                    strcpy(&me->value[0][0], buffer2);

                    FIfld_set_text (form_ptr,CO_NUMBER,0,0,buffer2,0);

		    /* srh:  KLUDGE: skip BLOCK code until names can change */
		    goto skip_block;
                }


#if 0
/* This code is not reached any more thanks to srh's fix (above).
 * ANSI-C conversion found this problem by spitting out a warning
 * JSD (Jimmy Dodd) 7/15/92
 */


/************  BLOCK START
 *****  TO FIX TR 90N2893   *************
 ****/
                  /* modify entry in partslist also */
                di$give_pathname ( osnum =  me->ModuleInfo.md_id.osnum,
                                       pathname = regexp);

                di$strcat ( to = regexp, from = "partslist" );

                if (di$find(regexp = buffer2,start_dir = regexp,
                            lines = &entries,ptr = &count) == DIR_S_SUCCESS)
                {
                        strcpy(path,regexp);
                        di$strcat( to = path , from = &me->value[0][0] );

                        for ( i = 0 ; i < count ; ++i )
                        {
                                 sts = di$rename(oldname = entries[i],
                                              newname = path );

                                    if ( sts != DIR_S_SUCCESS )
                                 di$report_error(sts = sts , comment = "rename");
                           }
                    }
/**************   BLOCK END  -------  SUDHA 15/11/1990
 *******/

#endif /* End of jsd commenting out the code on 7/15/92 */

            }

skip_block:
            /*
             * Get the active part's name.
             */
            index = -1;
            buffer1[0] = '\0';
            co$part_get_attr ( msg = msg,
                               mod_env = &me->ModuleInfo,
                               part = &me->part,
                               index = &index,
                               attr = DESCRIPTION_NAME,
                               value = buffer2 );

            /*
             * If the part name has changed update it.
             */
            if (strcmp(buffer2, &me->value[1][0]))
            {
                om_msg = co$part_put_attr ( msg = msg,
                                            mod_env = &me->ModuleInfo,
                                            part = &me->part,
                                            attr = DESCRIPTION_NAME,
                                            value = &me->value[1][0],
                                            type = me->type[1] );
            }
        }

        if ((me->num_attrs >= 2) && (om_msg & *msg & 1))
        {
            om_msg = om$send ( msg = message COpart.modify_part_attributes
                                                      ( label, msg ),
                               targetid = my_id );
        }
    }
    else *msg = MSFAIL;

quit:

    if (!(om_msg & *msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

method modify_part_attributes ( int label; int * msg )
{
    int  om_msg = OM_S_SUCCESS;
    int  index, i, j, type, num;
    char buffer[256], * form_ptr;

    om_msg = om$send ( msg = message CEO.get_form_ptr ( label,
                                                        &form_ptr,
                                                        &index,
                                                        msg ),
                       targetid = my_id );

    if (om_msg & *msg & 1)
    {
        /*
         * Get the number of attributes for this part.
         */
        om_msg = co$part_get_all_attr ( msg = msg,
                                        mod_env = &me->ModuleInfo,
                                        part = &me->part,
                                        num = &num );

        if (om_msg & *msg & 1)
        {
            /*
             * Remove any attributes that have been deleted.
             */
            for (i=num-1; i>=2; --i)
            {
                buffer[0] = '\0';
                om_msg = co$part_get_attr ( msg = msg,
                                            mod_env = &me->ModuleInfo,
                                            part = &me->part,
                                            attr = buffer,
                                            index = &i,
                                            type = &type );

                if (om_msg & *msg & 1)
                {
                    if (((label == CO_review_parts) && (type & GR_COMMON_ATTR)) ||
                        (label != CO_review_parts) )
                    {
                        /*
                         * Check for this attribute ...
                         */
                        for (j=me->num_attrs-1; j>=0; --j)
                        {
                            if (!strcmp(&me->attr[j][0],buffer)) break;
                        }

                        /*
                         * If the attribute doesn't exist on the form ...
                         */
                        if (j == -1)
                        {
                            /*
                             * Add the attribute to the remove list.
                             */
                            co$part_rem_attr ( msg = msg,
                                               mod_env = &me->ModuleInfo,
                                               part = &me->part,
                                               attr = buffer );
                        }
                    }
                }
            }

            /*
             * Update/Add the attribute name/value pairs.
             */
            for (i=0; i<me->num_attrs; ++i)
            {
                co$part_put_attr ( msg = msg,
                                   mod_env = &me->ModuleInfo,
                                   part = &me->part,
                                   attr = &me->attr[i][0],
                                   value = &me->value[i][0],
                                   type = me->type[i] );
            }
        }
    }

    if (!(om_msg & *msg & 1)) *msg = MSFAIL;

    return (OM_S_SUCCESS);
}

end implementation COpart;
