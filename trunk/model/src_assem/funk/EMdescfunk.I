class implementation EMdescribe;

#include <grimport.h>
#include <stdio.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <alloca.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"

extern OMuword OPP_EMdescribe_class_id;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMconstruct_describe                                            |
 |                                                                           |
 | This method constructs the specified object.                              |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMconstruct_describe (IGRlong         * msg,
                              IGRchar         * classname,
                              struct GRmd_env * mod_env,
                              IGRchar         * class_attr,
                              struct GRid     * description_id)
{
    IGRlong     om_msg = OM_S_SUCCESS;
    
    description_id->osnum = mod_env->md_id.osnum;
    
    om_msg = om$construct (osnum = mod_env->md_id.osnum,
                           classname = classname,
                           p_objid = &description_id->objid,
                           msg = message EMdescribe.EMconstruct (msg,
                                                                 mod_env,
                                                                 class_attr));
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_feature_description                                       |
 |                                                                           |
 | This function returns the description object that's associated with a     |
 | graphic object.                                                           |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/29/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_feature_description (IGRlong         * msg,
                                   struct GRid     * feature_id,
                                   struct GRid     * description_id)
{
    IGRlong                 om_msg;
    OM_S_CHANSELECT         chansel;
    OMuint                  i, count = 0;
    OMuword                 classid;
    OM_S_OBJECT_LINKAGE   * objects;
    struct GRid             local_description_id;
    
    *msg = ASM_S_SUCCESS;

    if (!description_id)
    {
        description_id = &local_description_id;
    }
    
    om_msg = om$make_chanselect (p_chanselect = &chansel,
                                 channame = "GRnotify.notification");
    
    if (!(om_msg & 1))
    {
        *msg =  ASM_E_ABORT;
        goto quit;
    }

    om_msg = om$get_channel_count (objid = feature_id->objid,
                                   osnum = feature_id->osnum,
                                   p_chanselect = &chansel,
                                   count = &count);

    if (!(om_msg & 1) || (count == 0))
    {
        *msg = ASM_E_NODESCRIPTION;
        goto quit;
    }

    objects = (OM_S_OBJECT_LINKAGE *)alloca(count * sizeof(OM_S_OBJECT_LINKAGE));
    
    om_msg = om$get_channel_objects (objid = feature_id->objid,
                                     osnum = feature_id->osnum,
                                     p_chanselect = &chansel,
                                     list = objects,
                                     size = count,
                                     count = &count);
    
    if (!(om_msg & *msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
    
    for (i=0; i<count; ++i)
    {
        om_msg = om$get_classid (objid = objects[i].S_objid,
                                 osnum = objects[i].osnum,
                                 p_classid = &classid);
        
        if (!(om_msg & 1))
        {
            *msg = ASM_E_ABORT;
            goto quit;
        }
        
        if (om$is_ancestry_valid (superclassid = OPP_EMdescribe_class_id,
                                  subclassid = classid) == OM_S_SUCCESS)
        {
            if (description_id)
            {
                description_id->objid = objects[i].S_objid;
                description_id->osnum = objects[i].osnum;
            }
            
            break;
        }
    }

    if (i == count)
    {
        *msg = ASM_E_NODESCRIPTION;
    }
      
  quit:    

    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMadd_feature_description                                       |
 |                                                                           |
 | This function creates and initializes a description object for a set of   |
 | graphic objects.                                                          |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/29/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMadd_feature_description (IGRlong         * msg,
                                   IGRchar         * directory,
                                   IGRchar         * name,
                                   IGRboolean        active,
                                   IGRchar         * feature_name,
                                   struct GRid     * feature_id,
                                   IGRint            num_attributes,
                                   EMattr          * attributes,
                                   struct GRid     * description_id)
{
    IGRlong                 om_msg;
    struct GRid             loc_description_id;
    EMdescribe_class_attr   class_attr;
    struct GRmd_env         mod_env;
    
    /*
     * Make sure the feature doesn't already have a description.
     */
    om_msg = asm$get_feature_description (msg = msg,
                                          feature_id = feature_id);

    if (om_msg & *msg & 1)
    {
        *msg = ASM_E_DESCRIPTIONEXISTS;
        goto quit;
    }
    else
    {
        om_msg = OM_S_SUCCESS;
        *msg = ASM_S_SUCCESS;
    }
    
    if (!description_id)
    {
        description_id = &loc_description_id;
    }
    
    gr$get_module_env (buffer = &mod_env);
    
    
    /*
     * Only allow features in the current module to be
     * described for now.
     */
    if (feature_id->osnum != mod_env.md_id.osnum)
    {
        *msg = ASM_E_INVARGS;
        goto quit;
    }
    
    class_attr.props = EM_DESCRIPTION | EM_DEFAULT_DISPLAY;
    class_attr.directory = directory;
    class_attr.name = name;
    class_attr.feature_id = feature_id;
    class_attr.feature_name = feature_name;
    class_attr.num_attributes = num_attributes;
    class_attr.attributes = attributes;
    
    om_msg = EMconstruct_describe (msg,
                                   "EMdescribe",
                                   &mod_env,
                                   (IGRchar *)(&class_attr),
                                   description_id);
    
    if (!(om_msg & *msg & 1))
    {
        goto quit;
    }

    if (active)
    {
        om_msg = om$send (msg = message EMdescribe.EMset_active (msg, TRUE),
                          senderid = NULL_OBJID,
                          targetid = description_id->objid,
                          targetos = description_id->osnum);
    }
    
 quit:
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMrem_feature_description                                       |
 |                                                                           |
 | This function removes a description object from a graphic object.         |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/29/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMrem_feature_description (IGRlong         * msg,
                                   struct GRid     * feature_id)
{
    IGRlong     om_msg;
    struct GRid description_id;

    om_msg = asm$get_feature_description (msg = msg,
                                          feature_id = feature_id,
                                          description_id = &description_id);
    
    if (om_msg & *msg & 1)
    {
        /*
         * Remove the directory.
         */
        om$send (msg = message EMdescribe.EMdelete (msg),
                 senderid = NULL_OBJID,
                 targetid = description_id.objid,
                 targetos = description_id.osnum);
    }

    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMreduce_syntax                                                 |
 |                                                                           |
 | This function reduces it's input to a raw formula for the syntax. For     |
 | example if the string "2 [2]" is input then the output will be "2", if    |
 | "l*w [10]" is input the output will be "l*w". This is used by the         |
 | EMmod_attr.                                                               |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/10/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMreduce_syntax (IGRchar * syntax, IGRchar * reduced_syntax)
{
    IGRlong   om_msg = OM_S_SUCCESS;
    IGRchar * loc_syntax, * p;

    if ((p = syntax) != NULL)
    {
        loc_syntax = (IGRchar *)alloca(strlen(syntax) + 1);

        if (reduced_syntax == NULL)
        {
            reduced_syntax = syntax;
        }
    
        /*
         * Strip leading white space ...
         */
        while (isspace(*p) && (*p != '\0'))
        {
            p++;
        }

        strcpy (loc_syntax, p);
        
        if (*p != '\0')
        {
            /*
             * Get a pointer to the last character of the string.
             */
            p = loc_syntax + strlen(loc_syntax) - 1;

            /*
             * Strip trailing white space ...
             */
            while (isspace(*p) && (p != loc_syntax))
            {
                p--;
            }
            
            if (isspace(*p))
            {
                *p = '\0';
            }
            else
            {
                *(p+1) = '\0';
            }
            
            /*
             * If there is a bracketed value ...
             */
            if ((p != loc_syntax) && (*p == ']'))
            {
                while ((--p) != loc_syntax)
                {
                    /*
                     * If we found the matching bracket.
                     */
                    if (*p == '[')
                    {
                        /*
                         * Strip white space between left bracket 
                         * and rest of syntax.
                         */
                        while ((p != loc_syntax) && isspace(*(--p))) 
                        {
                        }
                        
                        if (isspace(*p))
                        {
                            *p = '\0';
                        }
                        else
                        {
                            *(++p) = '\0';
                        }
                        
                        break;
                    }
                }
            }
        }

        strcpy (reduced_syntax, loc_syntax);
    }
    else
    {
        om_msg = OM_E_ABORT;
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMsyntax_changed                                                |
 |                                                                           |
 | This function determines is there is any real different between the two   |
 | input syntaxes.                                                           |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/10/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRboolean EMsyntax_different (IGRchar * syntax1,
                               IGRchar * syntax2)
{
    IGRboolean different = FALSE;
    IGRchar *  s1, * s2;

    /*
     * Do a quick check.
     */
    if (strcmp (syntax1, syntax2))
    {
        /*
         * Allocate some temporary buffers to work from.
         */
        strcpy (s1 = (IGRchar *)alloca(strlen(syntax1) + 1), syntax1);
        strcpy (s2 = (IGRchar *)alloca(strlen(syntax2) + 1), syntax2);
        
        /*
         * Reduce the syntaxes.
         */
        EMreduce_syntax (s1, NULL);
        EMreduce_syntax (s2, NULL);
        
        /*
         * Check to see if they are different now ...
         */
        if (strcmp(s1, s2))
        {
            different = TRUE;
        }
    }

    return different;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_display_props                                             |
 |                                                                           |
 | This function returns the display properties of the describe object.      |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_display_props (IGRlong     * msg,             /* OUTPUT */
                             struct GRid * id,              /* INPUT  */
                             IGRint      * props,           /* OUTPUT */
                             IGRlong     * layers)          /* OUTPUT */
{
    IGRlong om_msg;
    
    *msg = ASM_S_SUCCESS;

    /* 
     * Get the display properties. 
     */
    om_msg = om$send (msg = message EMdescribe.EMget_display (msg,
                                                              props,
                                                              layers),
                      senderid = NULL_OBJID,
                      targetid = id->objid,
                      targetos = id->osnum);
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMset_display_props                                             |
 |                                                                           |
 | This function sets the display properties of the object.                  |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMset_display_props (IGRlong          * msg,        /* OUTPUT */
                             struct GRmd_env  * mod_env,    /* INPUT  */
                             struct GRid      * id,         /* INPUT  */
                             IGRboolean         update,     /* INPUT  */
                             IGRint           * props,      /* INPUT  */
                             IGRlong          * layers)
{
    IGRlong         om_msg;
    struct GRmd_env loc_mod_env;
    
    *msg = ASM_S_SUCCESS;
    
    if (!mod_env)
    {
        gr$get_module_env (buffer = (mod_env = &loc_mod_env));
    }

    /*
     * Set the properties.
     */
    om_msg = om$send (msg = message EMdescribe.EMset_display (msg, 
                                                              mod_env,
                                                              props,
                                                              layers,
                                                              update),
                      senderid = NULL_OBJID,
                      targetid = id->objid,
                      targetos = id->osnum);

    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_behavior_props                                            |
 |                                                                           |
 | This function returns the behavior properties of the describe object.     |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_behavior_props (IGRlong     * msg,             /* OUTPUT */
                              struct GRid * id,              /* INPUT  */
                              IGRint      * props)           /* OUTPUT */
{
    IGRlong om_msg;
    
    *msg = ASM_S_SUCCESS;

    /* 
     * Get the behavior properties. 
     */
    om_msg = om$send (msg = message EMdescribe.EMget_behavior (msg, props),
                      senderid = NULL_OBJID,
                      targetid = id->objid,
                      targetos = id->osnum);
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMset_behavior_props                                            |
 |                                                                           |
 | This function sets the behavior properties of the object.                 |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMset_behavior_props (IGRlong     * msg,             /* OUTPUT */
                              struct GRid * id,              /* INPUT  */
                              IGRint        props)           /* INPUT  */
{
    IGRlong om_msg;

    *msg = ASM_S_SUCCESS;
    
    /*
     * Set the properties.
     */
    om_msg = om$send (msg = message EMdescribe.EMset_behavior (msg, props),
                      senderid = NULL_OBJID,
                      targetid = id->objid,
                      targetos = id->osnum);

    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_application_props                                         |
 |                                                                           |
 | This function returns the application properties of the describe object.  |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_application_props (IGRlong     * msg,             /* OUTPUT */
                                 struct GRid * id,              /* INPUT  */
                                 IGRuint     * props)           /* OUTPUT */
{
    IGRlong om_msg;
    
    *msg = ASM_S_SUCCESS;

    /* 
     * Get the application properties. 
     */
    om_msg = om$send (msg = message EMdescribe.EMget_application_properties
                                                            (msg, props),
                      senderid = NULL_OBJID,
                      targetid = id->objid,
                      targetos = id->osnum);
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMset_application_props                                         |
 |                                                                           |
 | This function sets the application properties of the object.              |
 |                                                                           |
 | History:  jay wallingford    3/25/93     Creation                         |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMset_application_props (IGRlong     * msg,             /* OUTPUT */
                                 struct GRid * id,              /* INPUT  */
                                 IGRuint       props)           /* INPUT  */
{
    IGRlong om_msg;

    *msg = ASM_S_SUCCESS;
    
    /*
     * Set the properties.
     */
    om_msg = om$send (msg = message EMdescribe.EMset_application_properties
                                                                 (msg, props),
                      senderid = NULL_OBJID,
                      targetid = id->objid,
                      targetos = id->osnum);

    return(om_msg);
}

%safe
static IGRboolean EMdesc_system_mode = FALSE;
%endsafe

IGRboolean EMdesc_get_system_mode ()
{
    return (EMdesc_system_mode);
}

IGRboolean EMdesc_set_system_mode (IGRboolean system_mode)
{
    IGRboolean old_mode = EMdesc_system_mode;
    
    EMdesc_system_mode = system_mode;

    return old_mode;
}

end implementation EMdescribe;
