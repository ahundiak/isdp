/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include <DIprims.h>
#include <DImacros.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include "partdef.h"
#include "partmacros.h"

from GRgraphics import GRdisplay, GRdelete;
from GRpart     import GRget_attribute, GRnum_attributes;
from GRowner    import GRdrop;

void GRpart_find_catalog( msg, mod_env, number, catalog)
   int             * msg;
   struct GRmd_env * mod_env;
   char            * number;
   char           ** catalog;
{
   char regexpr    [ DI_PATH_MAX ],
        parts_dir  [ DI_PATH_MAX ],
	loc_number [ DI_PATH_MAX ],
      **p_catalog;

   int  one = 0;

   * msg = MSSUCC;

   GRpart_get_default_parts_dir( mod_env, parts_dir );
   strcpy( regexpr, parts_dir );
   strcpy( loc_number, number );

   /* 
    * srh:5/18/92
    * There are two possible number formats: local and pdu.
    * local:  regexp = "<parts_dir>:local:<number>"
    * pdu:    regexp = "<parts_dir>:*:<number>!*"
    */

   /* First try LOCAL */ 
   di$strcat( to = regexpr, from = "local" );
   di$strcat( to = regexpr, from = number );
   di$ls (regexp = regexpr, ptr = &one );
   if ( one == 1 )
   {
      /* set catalog to NULL */
      *catalog = NULL;
   }
   else /* try PDU */
   {
      strcpy( regexpr, parts_dir );
      di$strcat( to = regexpr, from = "*" ); /* wild catalog */
      strcat(loc_number, "!*"); /* wild revision */
      di$strcat( to = regexpr, from = loc_number );
      di$ls (regexp = regexpr, ptr = &one );
      if ( one == 1 )
      {
         di$ls ( regexp = regexpr, 
                 lines  = &p_catalog,
                 ptr    = &one );  

         strcpy( *catalog, *p_catalog );

         di$split ( pathname = *catalog,   /* pdu catalog directory */
                    dirname  = parts_dir );

         di$split ( pathname = parts_dir ,
                    name     = *catalog ); /* pdu catalog name */
      }
      else
      {
        *msg = CO_E_PARTSLIST_ERROR;
      }
   }
}

IGRint COpart_add_to_partslist ( msg, 
                                 mod_env,
                                 partslist,
                                 list,
                                 list_size,
                                 object,
                                 line_no )

    IGRint              * msg;
    struct GRmd_env     * mod_env;
    IGRchar             * partslist;
    struct GRpart_item  * list;
    IGRint                list_size;
    struct GRobj_env    * object;
    IGRint              * line_no;
{
    IGRint        om_msg = OM_S_SUCCESS;
    long          ok;
    IGRchar       attr_data[25 * MAX_ATTR], * attr = NULL;
    IGRchar       * attr_p[25], ** attr_pp=NULL;
    IGRchar       just_data[25 * MAX_ATTR], * just = NULL;
    IGRchar       * just_p[25], ** just_pp=NULL;
    IGRchar       value_data[25 * MAX_VALUE], * value = NULL;
    IGRchar       * value_p[25], ** value_pp=NULL;
    IGRint        num_cols = 0, line_no_buffer;
    IGRchar       part_number[MAX_VALUE];
    struct GRid   partslist_id, line_id;
    IGRchar       path[DI_PATH_MAX], base_dir[DI_PATH_MAX];
    enum GRdpmode mode;
    IGRint        i, j, size, count, index;
    OMuword       osnum;

    *msg = MSSUCC;

    if (!line_no) 
    {
        line_no = &line_no_buffer;
    }
 
    if (!partslist)
    {
        /*
         * Get the default partslist id.
         */
        ex$get_cur_mod ( osnum = &osnum );
        di$give_pathname ( osnum = osnum, pathname = base_dir );
        /* BLOCKS */
	/* di$strcat (to = base_dir, from = "partslist"); */
        di$strcat (to = base_dir, from = "blocks:partslist");

        /*
         * Get the first partslist in the partslist directory.
         */
        if ( di$index ( dirname = base_dir, 
                        index = 0, 
                        p_objid = &partslist_id.objid,
                        p_osnum = &partslist_id.osnum ) != DIR_S_SUCCESS )
        {
            *msg = CO_E_NO_PARTSLIST;
        }
    }
    /*
     * Get the specified partslist id.
     */
    else 
    {
       if ( di$translate ( objname = partslist, 
                           p_objid = &partslist_id.objid,
                           p_osnum = &partslist_id.osnum ) != DIR_S_SUCCESS )
       {
           *msg = CO_E_NO_PARTSLIST;
       }
    }

    /*
     * If the partslist was found.
     */
    if (*msg & 1)
    {
        /*
         * Determine the number of columns.
         */

        i = 2;

        om_msg = om$send ( msg = message GRpart.GRget_attribute ( (long *)msg,
                                                                  NULL,
                                                                  &i,
                                                                  attr_data,
                                                                  NULL ),
                           senderid = NULL_OBJID,
                           targetid = partslist_id.objid,
                           targetos = partslist_id.osnum );

        sscanf(attr_data, "%d", &num_cols);

        /*
         * The first 3 attributes are name, description and number of columns. 
         * The remaining attributes define the attribute and justification 
         * for each column.
         */
        if ((om_msg & *msg & 1) && (num_cols > 0))
        {
            /*
             * Get a buffer for all the attributes and justifications.
             */
            if (num_cols > 25)
            {
                attr = NULL;

                size = (2 * num_cols * MAX_ATTR * sizeof (IGRchar)) +
                       (3 * num_cols * sizeof (IGRchar *)) +
                       (num_cols * MAX_VALUE * sizeof (IGRchar));

                attr = om$malloc ( size = size );

                if (!attr)
                {
                    *msg = MSFAIL;
                }
                else
                {
                    attr_pp = (IGRchar **)(&attr[num_cols * MAX_ATTR]);
                    just = (IGRchar *)(&attr_pp[num_cols]);
                    just_pp = (IGRchar **)(&just[num_cols * MAX_ATTR]);
                    value = (IGRchar *)(&just_pp[num_cols]);
                    value_pp = (IGRchar **)(&value[num_cols * MAX_VALUE]);
                }
            }
            else
            {
                attr = attr_data;
                attr_pp = attr_p;
                just = just_data;
                just_pp = just_p;
                value = value_data;
                value_pp = value_p;
            }

            if (*msg & 1)
            {
                /*
                 * Get the attributes and justifications.
                 */
                for (i=0, j=3; i<num_cols; ++i, j+=2)
                {
                    attr_pp[i]  = &attr[i * MAX_ATTR];
                    just_pp[i]  = &just[i * MAX_ATTR];
                    value_pp[i] = &value[i * MAX_VALUE];

                    index = j;
                    om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                            ( (long *)msg,
                                                              NULL,
                                                              &index,
                                                              attr_pp[i],
                                                              NULL ),
                                       senderid = NULL_OBJID,
                                       targetid = partslist_id.objid,
                                       targetos = partslist_id.osnum );

                    if (!(om_msg & *msg & 1)) break;
                    index = j + 1;
                    om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                            ( (long *)msg,
                                                              NULL,
                                                              &index,
                                                              just_pp[i],
                                                              NULL ),
                                       senderid = NULL_OBJID,
                                       targetid = partslist_id.objid,
                                       targetos = partslist_id.osnum );

                    if (!(om_msg & *msg & 1)) break;
                }
            }

            if (om_msg & *msg & 1)
            {
                /*
                 * For all the parts in the list ...
                 */
                for (i=0; i<list_size; ++i)
                {
                    /*
                     * Get this part's number.
                     * 
#define CATALOG_NAME            "CATALOG"
#define NUMBER_NAME             "NUMBER"
#define REVISION_NAME           "REVISION"
#define DESCRIPTION_NAME        "NAME"

                     */
                    om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                                ( (long *)msg,
                                                                  NUMBER_NAME,
                                                                  NULL,
                                                                  part_number,
                                                                  NULL ),
                                       senderid = NULL_OBJID,
                                       targetid = object[list[i].part_id].obj_id.objid,
                                       targetos = object[list[i].part_id].obj_id.osnum );

                    if (om_msg & *msg & 1)
                    {
                        /*
                         * Get the name for this part's line in the partslist.
                         */
  
		        di$give_pathname ( osnum = osnum, pathname = path );
                        di$strcat(to = path, from = "partslist");
                        di$strcat(to = path, from = part_number);

                        /*
                         * If the part was not already on the partslist.
                         */
                        if ( di$translate ( objname = path,
                                            p_objid = &line_id.objid,
                                            p_osnum = &line_id.osnum )
                             != DIR_S_SUCCESS )
                        {
                            /*
                             * Make a copy of the template and add it to 
                             * the partslist.
                             */
			   if(( object[list[i].part_id].obj_id.osnum==partslist_id.osnum) &&
				(object[list[i].part_id].obj_id.objid==partslist_id.objid)) {
				 
				 *msg = CO_E_PART_IS_LIST;
				 goto wrapup;

			   }

                            om_msg =
                            COpartslist_add_line ( msg, 
                                                   mod_env,
                                                   &partslist_id, 
                                                   path,
                                                   &line_id, 
                                                   line_no );

                            if (om_msg & *msg & 1)
                            {
                                ++(*line_no);

                                for (j=0; j<num_cols; ++j)
                                {
                                    /*
                                     * If this is a global attribute.
                                     */
                                    if (*(attr_pp[j]) == '%')
                                    {
                                        if (!strcmp(attr_pp[j], "%ITEM"))
                                        {
                                            sprintf(value_pp[j], "%d", *line_no);
                                        }
                                        else if (!strcmp(attr_pp[j], "%COUNT"))
                                        {
                                            GRpart_get_count ( path,
                                                               &object[list[i].part_id].obj_id,
                                                               &count );
                                            sprintf(value_pp[j], "%d", count);
                                        }
                                        else
                                        {
                                            *(value_pp[j]) = '\0';
                                        }
                                    }
                                    else
                                    {
                                        /*
                                         * Get the value.
                                         */
                                        om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                                 ( (long *)msg,
                                                                   attr_pp[j],
                                                                   NULL,
                                                                   value_pp[j],
                                                                   NULL ),

                                                           senderid = NULL_OBJID,
                                                           targetid = object[list[i].part_id].obj_id.objid,
                                                           targetos = object[list[i].part_id].obj_id.osnum );

                                        if (!(om_msg & *msg & 1))
                                        {
                                            *(value_pp[j]) = '\0';
                                        }
                                    }
                                }

                                /*
                                 * Add the information to the list.
                                 */

                                COpartslist_add_info ( msg, 
                                                       mod_env,
                                                       &line_id, 
                                                       attr_pp, 
                                                       just_pp, 
                                                       value_pp,
                                                       num_cols );

                                if (*msg & 1)
                                {
                                    /*
                                     * Display the new line.
                                     */

                                    mode = GRbd;
                                    om$send ( msg = message GRgraphics.GRdisplay 
                                                    ( (long *)msg,
                                                      &mod_env->md_env.matrix_type,
                                                      mod_env->md_env.matrix,
                                                      &mode,
                                                      &mod_env->md_id ),
                                              senderid = NULL_OBJID,
                                              targetid = line_id.objid,
                                              targetos = line_id.osnum );
                                }
                                else
                                {
                                    /*
                                     * Delete the new line.
                                     */
                                    om$send ( msg = message GRgraphics.GRdelete ( &ok, mod_env ),
                                              senderid = NULL_OBJID,
                                              targetid = line_id.objid,
                                              targetos = line_id.osnum );
                                    break;
                                }
                            }
                        }
                        else *msg = CO_E_PART_ON_LIST;
                    }
                }
            }
        }
    }

wrapup:


    if ((num_cols > 25) && attr)
    {
        om$dealloc (ptr = attr);
    }
 
    if ((*msg == CO_E_PART_ON_LIST) && (list_size > 1)) *msg = MSSUCC;

    return (om_msg);
}


#argsused
IGRint COpart_write_to_file ( msg,
                              mod_env,
                              file,
                              list,
                              list_size,
                              object )

    IGRint              * msg;
    struct GRmd_env     * mod_env;
    FILE                * file;
    struct GRpart_item  * list;
    IGRint                list_size;
    struct GRobj_env    * object;
{
    IGRint  om_msg = OM_S_SUCCESS;
    IGRchar attr[MAX_ATTR];
    IGRchar value[MAX_VALUE];
    IGRint  qty, num_attrs;
    IGRchar path[DI_PATH_MAX];
    IGRint  i, j;
 
    *msg = MSSUCC;
 
    /*
     * For all the parts on the list.
     */
    for (i=0; i<list_size; ++i)
    {
        /*
         * Get the number of attributes for this part.
         */
        om_msg = om$send ( msg = message GRpart.GRnum_attributes ( (long *)msg, 
                                                                   &num_attrs),
                           senderid = NULL_OBJID,
                           targetid = object[list[i].part_id].obj_id.objid,
                           targetos = object[list[i].part_id].obj_id.osnum );

        if (om_msg & *msg & 1)
        {
            /*
             * Print the number of parts of this type.
             */
            qty = 0;
            GRpart_get_count ( path, 
                               &object[list[i].part_id].obj_id, 
                               &qty );

            fprintf(file, "%d\t%d", qty, num_attrs);

            for (j=0; j<num_attrs; ++j)
            {
                attr[0] = '\0';

                om_msg =
                om$send ( msg = message GRpart.GRget_attribute ( (long *)msg,
                                                                 attr,
                                                                 &j,
                                                                 value,
                                                                 NULL ),
                          senderid = NULL_OBJID,
                          targetid = object[list[i].part_id].obj_id.objid,
                          targetos = object[list[i].part_id].obj_id.osnum );

                if (!(om_msg & *msg & 1)) goto quit;

                fprintf ( file, 
                          (j == num_attrs-1) ? "\t%s=%s\n" : "\t%s=%s",
                          attr, 
                          value );
            }
        }
    }

quit:
 
    return (om_msg);
}


/*
 * Function types for COpart_list_func 
 *
 *  #define CO_part_write_to_file       0
 *  #define CO_part_add_to_partslist    1
 *  #define CO_part_update_partslist    2
 */

IGRint COpart_list_func ( type,
                          msg, 
                          mod_env,
                          partslist,
                          file,
                          object,
                          num_objects,
                          line_no )

    IGRint                type;
    IGRint              * msg;
    struct GRmd_env     * mod_env;
    IGRchar             * partslist;
    FILE                * file;
    struct GRobj_env    * object;
    IGRint                num_objects;
    IGRint              * line_no;

{
    IGRint              om_msg = OM_S_SUCCESS;
    IGRint              size, index;
    struct GRpart_item  list[25], * list_p;
    IGRint              list_size;
    IGRchar             * part_p, part[25 * MAX_VALUE];
    IGRint              i, j;

    *msg = MSSUCC;

    list_p = NULL;
    part_p = NULL;
 
    if (num_objects > 25)
    {
        size = num_objects * sizeof (struct GRpart_item);

        list_p = (struct GRpart_item *) om$malloc ( size = size );
  
        if (!list_p)
        {
            *msg = MSFAIL;
        }
        else
        {
            size = num_objects * sizeof (IGRchar) * MAX_VALUE;

            part_p = om$malloc ( size = size );
   
            if (!part_p)
            {
                *msg = MSFAIL;
            }
        }
    }
    else
    {
        list_p = list;
        part_p = part;
    }
  
    if ( *msg & 1 )
    {
        index = -1;
        list_size = 0;
 
        for (i=0; i<num_objects; ++i)
        {
            list_p[list_size].part = &part_p[list_size * MAX_VALUE];

            /*
             * Get the part number.
             */
            om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                  ( (long *)msg,
                                                    NUMBER_NAME,
                                                    &index,
                                                    list_p[list_size].part,
                                                    NULL ),
                               senderid = NULL_OBJID,
                               targetid = object[i].obj_id.objid,
                               targetos = object[i].obj_id.osnum );

            if (om_msg & *msg & 1)
            {
                /*
                 * Make sure this part type is not already on the list.
                 */
                for (j=0; j<list_size; ++j)
                {
                    if ( !strcmp(list_p[j].part, list_p[list_size].part ) )
                    {
                        break;
                    }
                }

                /*
                 * If the part wasn't already on the list add it.
                 */
                if (j == list_size)
                {
                    list_p[list_size++].part_id = i;
                }
            }
        }

        if (list_size)
        {
            if (type == CO_part_add_to_partslist)
            {
                om_msg =
                COpart_add_to_partslist ( msg,
                                          mod_env,
                                          partslist,
                                          list_p,
                                          list_size,
                                          object,
                                          line_no );
            }
            else if (type == CO_part_write_to_file)
            {
                om_msg =
                COpart_write_to_file ( msg,
                                       mod_env,
                                       (file) ? (FILE *)file : (FILE *)stdout,
                                       list_p,
                                       list_size,
                                       object );
            }
        }
    }

    if (num_objects > 25)
    {
        if (list_p) om$dealloc ( ptr = list_p );
        if (part_p) om$dealloc ( ptr = part_p );
    }
 
    return (om_msg);
}

IGRint COpart_delete_partslist_entries_func ( msg, mod_env, partslist )
    IGRint          * msg;
    struct GRmd_env * mod_env;
    IGRchar         * partslist;
{
    IGRint            om_msg = OM_S_SUCCESS, count, i;
    IGRchar           regexp[DI_PATH_MAX], path[DI_PATH_MAX];
    DIgrid          * entries;
    enum GRdpmode     mode;

    if (!partslist)
    {
        partslist = path;
        di$give_pathname ( osnum = mod_env->md_id.osnum, pathname = regexp );
        di$strcat ( to = regexp, from = "partslist" );
    }
    else
    {
        strcpy (regexp, partslist);
    }
 
    di$strcat ( to = regexp, from = "*" );
 
    /*
     * Get all the part ids that are on the current partslist.
     */
    di$dump ( regexp = regexp, grids = &entries, ptr = &count, options = NULL );
 
    mode = GRbe;
 
    for (i=count-1; i>=0; --i)
    {
        om_msg = om$send ( msg = message GRgraphics.GRdisplay ( 
					    (long *)msg,
                                           &mod_env->md_env.matrix_type,
                                            mod_env->md_env.matrix,
                                           &mode,
                                           &mod_env->md_id ),
                           senderid = NULL_OBJID,
                           targetid = entries[i].objid,
                           targetos = entries[i].osnum );

        om_msg = om$send ( msg = message GRgraphics.GRdelete ( (long *)msg, mod_env ),
                           senderid = NULL_OBJID,
                           targetid = entries[i].objid,
                           targetos = entries[i].osnum );
    }

    free (entries);  
 
    return (om_msg);
}

/*
 * srh:5/18/92 - now ALL catalogs are searched, not just local
 */
IGRint COpart_update_partslist_func ( msg, mod_env, partslist )
    IGRint            * msg;
    struct GRmd_env   * mod_env;
    IGRchar           * partslist;
{
    IGRint             om_msg = OM_S_SUCCESS;
    IGRchar         ** parts, number[MAX_VALUE];
    IGRint             count, i;
    struct GRobj_env   part_info;
    IGRchar            regexp[DI_PATH_MAX], path[DI_PATH_MAX];
    struct GRid        dir_id;
  
    *msg = MSSUCC;
 
    if (!partslist)
    {
        partslist = path;
        di$give_pathname ( osnum = mod_env->md_id.osnum, pathname = regexp );
        di$strcat ( to = regexp, from = "partslist" );
        strcpy (partslist, regexp);
    }
    else strcpy (regexp, partslist);

    if ( di$translate ( objname = partslist,
                        p_objid = &dir_id.objid,
                        p_osnum = &dir_id.osnum ) == DIR_S_SUCCESS )
    {
        di$strcat ( to = regexp, from = "*" );

        /*
         * Get all the parts that are on the current partslist.
         */
        count = 0;
        di$dump (regexp = regexp, lines = &parts, ptr = &count, options = NULL);

        /*
         * If there where any parts on the list ...
         */
        if (count)
        {
            /*
             * Delete all the entries in the partslist.
             */
            co$part_delete_partslist_entries ( msg = msg, 
                                               mod_env = mod_env, 
                                               partslist = partslist );

            /*
             * Add the parts back to the list.
             */
            for (i=0; i<count; ++i)
            {
               char  catalog [ DI_PATH_MAX ],
		    *p_catalog;

               p_catalog = &catalog[0];
               di$split ( pathname = parts[i],
                           name = number );
               /*
                *  find out which catalog the part number is found in
		*  NOTE: this function returns p_catalog == NULL if the
		*  catalog is "local".  Otherwise, p_catalog remains 
		*  pointing to catalog and catalog will contain the 
		*  PDU catalog name. KLUDGE! srh 5/18/92
                */
	       GRpart_find_catalog( msg, mod_env, number, &p_catalog);
               if ( *msg == CO_E_PARTSLIST_ERROR)
	       {
		 /* does not exist or not unique */
	         goto quit;
	       }
 
               om_msg = co$part_get_template ( msg = msg,
                                               mod_env = mod_env,
                                               catalog = p_catalog,
                                               number = number,
                                               part = &part_info.obj_id );

               /*
                * If there is still parts of this type.
                */
               if (om_msg & *msg & 1)
               {
                  part_info.mod_env = *mod_env;

                  om_msg = co$part_add_to_partslist ( 
                                               msg = msg, 
                                               mod_env = mod_env,
                                               partslist = (IGRchar *)NULL,
                                               object = &part_info,
                                               num_objects = 1,
                                               line_no = (IGRint *)NULL );

                    if ( (*msg == CO_E_PARTSLIST_ERROR) ||
                         (*msg == MSFAIL)              ||
                         (!(om_msg & 1)) ) break;
                }
            }

            if (count) di$free ( lines = parts, count = count );
        }
    }
quit:
    return (om_msg);
}


end implementation COpart;
