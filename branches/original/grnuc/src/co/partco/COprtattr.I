/* #######################    APOGEE COMPILED   ######################## */
class implementation COpart;

#include <coimport.h>
#include "partdef.h"
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

from ACdiowner import ACrem_attribute;
from GRpart    import GRmod_attribute;
from GRpart    import GRget_attribute, GRadd_attribute, GRnum_attributes;

int COpart_attr_func ( func_index,
                          msg,
                          mod_env,
                          parts_dir,
                          catalog,
                          part,
                          number,
                          revision,
                          attr,
                          index,
                          value,
                          type,
                          num )

    int              func_index;
    int             *   msg;
    struct GRmd_env *   mod_env;
    char            *   parts_dir;
    char            *   catalog;
    struct GRid     *   part;
    char            *   number;
    char            *   revision;
    char            *   attr;
    int             *   index;
    char            *   value;
    int             *   type;
    int             *   num;
{
    int               om_msg = OM_S_SUCCESS;
    struct GRid       part_id;
    char              partdir[DI_PATH_MAX], data[MAX_VALUE];
    char              numrev[DI_PATH_MAX];
    char            * attr_p, 
		    * value_p;
    int             * type_p, old_type, new_type;
    int               i, count, one = 1;
    int               nret, buffersize;
    struct GRmd_env   env_info;
    char           ** lines;


    *msg = MSSUCC;

    /*
     * If the module info was not supplied get the current module.
     */
    if (!mod_env)
    {
        buffersize = sizeof(struct GRmd_env);
        gr$get_module_env ( msg    = msg,
                            sizbuf = &buffersize,
                            buffer = &env_info,
                            nret   = &nret );
        mod_env = &env_info;
    }

    /*
     * If a part number was specified get the part directory.
     */
    if (number)
    {
        if (number[0] != '\0')
        {
            /*
             * If a parts directory was not supplied use the default.
             */
            if (!parts_dir)
            {
               GRpart_get_default_parts_dir (mod_env, partdir);
               /*
                * If a catalog was not supplied use the default.
                */
               if (!catalog)
               {
                  GRpart_get_default_catalog_dir (mod_env, partdir );
               }
	       else
	       {  
                  di$strcat ( to = partdir, from = catalog );
	       }

               /*
                * If a revision was supplied, use num!rev part number format.
                */
               if (revision)
               {
                  sprintf(numrev,"%s!%s",number,revision);
                  di$strcat ( to = partdir, from = numrev );
               }

	       if ( !catalog && !revision )
               {
                  di$strcat ( to = partdir, from = number );
               }

               /*
		* srh:5/18/92 - if catalog and number are specified, but
		* no revision, then we get the first revision of number.
		*/
               if ( catalog && number && !revision )
	       {
		  char loc_number [ DI_PATH_MAX ];

		  strcpy ( loc_number, number );
                  strcat ( loc_number, "!*" ); /* wild revision */
                  di$strcat ( to = partdir, from = loc_number );
                  di$dump ( ptr   = &one,
			    regexp = partdir,
			    lines = &lines );
	       }
            }

            /*
             * Get the representative part.
             */
            if (!part) part = &part_id;

            /*
	     * srh:5/18/92 - if catalog and number are specified, but
	     * no revision, then we get the first revision of number.
	     */
            if ( catalog && number && !revision )
	    {
	       if ( one > 0 )
	       {
                  if ( di$index ( dirname = *lines,
                                  index = 0,
                                  p_objid = &part->objid,
                                  p_osnum = &part->osnum ) != DIR_S_SUCCESS )
                  {
                     *msg = MSFAIL;
                  }
	       }
	       else
                  *msg = MSFAIL;
	    }
	    else
	    {
               if ( di$index ( dirname = partdir,
                               index = 0,
                               p_objid = &part->objid,
                               p_osnum = &part->osnum ) != DIR_S_SUCCESS )
               {
                  *msg = MSFAIL;
               }
	    }
        }
        else *msg = MSFAIL;
    }

    if ( !(om_msg & *msg & 1) )
    {
        *msg = MSFAIL;
        goto quit;

    }

    /*
     * Function indexes for COpart_attr_func.
     *
     *  #define CO_part_put         0
     *  #define CO_part_get         1
     *  #define CO_part_rem         2
     *  #define CO_part_all         3
     *  #define CO_part_template    4
     *
     */

    switch (func_index)
    {
        case CO_part_put:
            om_msg = om$send ( msg = message GRpart.GRget_attribute ( (long *)msg,
                                                                      attr,
                                                                      NULL,
                                                                      data,
                                                                      &old_type ),
                               senderid = NULL_OBJID,
                               targetid = part->objid,
                               targetos = part->osnum );

            /*
             * If the attribute already exists ...
             */
            if (om_msg & *msg & 1)
            {
                new_type = (int)type;

                /*
                 * And has changed ...
                 */
                if (strcmp(data, value) || (new_type != old_type))
                {
                    /*
                     * Modify it.
                     */
                    om_msg = om$send ( msg = message GRpart.GRmod_attribute
                                                               ( (long *)msg,
                                                                 attr,
                                                                 value,
                                                                 &new_type ),
                                       senderid = NULL_OBJID,
                                       targetid = part->objid,
                                       targetos = part->osnum );
                }
            }
            else /* Add it. */
            {
                new_type = (int)type;
                om_msg = om$send ( msg = message GRpart.GRadd_attribute
                                                               ( (long *)msg,
                                                                 attr,
                                                                 value,
                                                                 new_type ),
                                   senderid = NULL_OBJID,
                                   targetid = part->objid,
                                   targetos = part->osnum );
            }

            break;

        case CO_part_get:

            if (index && (*index >= 0))
            {
                if (attr) attr[0] = '\0';
            }
            else if (attr && (attr[0] != '\0'))
            {
                if (index) *index = -1;
            }
            else *msg = MSFAIL;

            if (*msg & 1)
            {
                /*
                 * Get the value for the attribute.
                 */
                om_msg = om$send ( msg = message GRpart.GRget_attribute ( (long *)msg,
                                                                          attr,
                                                                          index,
                                                                          value,
                                                                          type ),
                                   senderid = NULL_OBJID,
                                   targetid = part->objid,
                                   targetos = part->osnum );
            }
            break;

        case CO_part_rem:
            /*
             * Remove the attribute.
             */
            om_msg = om$send ( msg = message ACdiowner.ACrem_attribute ( (long *)msg,
                                                                         attr ),
                               senderid = NULL_OBJID,
                               targetid = part->objid,
                               targetos = part->osnum );
            break;

        case CO_part_all:

            count = 0;
            om_msg = om$send ( msg = message GRpart.GRnum_attributes ( (long *)msg,
                                                                       &count ),
                               senderid = NULL_OBJID,
                               targetid = part->objid,
                               targetos = part->osnum );

            if ((attr || value || type) && (om_msg & *msg & 1))
            {
                if (*num >= count)
                {
                    for (i=0; i<count; ++i)
                    {
                        attr_p  = (attr)  ? ((char **)attr) [i] : NULL;
                        value_p = (value) ? ((char **)value)[i] : NULL;
                        type_p  = (type)  ? &type[i]               : NULL;

                        if (attr_p) attr_p[0] = '\0';

                        /*
                         * Get the attribute name and value.
                         */
                        om_msg = om$send ( msg = message GRpart.GRget_attribute
                                                                    ( (long *)msg,
                                                                      attr_p,
                                                                      &i,
                                                                      value_p,
                                                                      type_p ),
                                           senderid = NULL_OBJID,
                                           targetid = part->objid,
                                           targetos = part->osnum );

                        if (!(om_msg & *msg & 1)) break;
                    }
                }
                else *msg = MSFAIL;
            }

            *num = count;

            break;

        case CO_part_template:

            break;

        default:

            *msg = MSFAIL;

            break;
    }

quit:

    return(om_msg);
}

end implementation COpart;
