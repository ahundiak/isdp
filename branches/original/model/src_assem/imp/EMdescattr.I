class implementation EMdescribe;

#include <grimport.h>
#include <DIprims.h>
#include <OMmacros.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>
#include <parametric.h>
#include <expmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"

from NDnode     import NDgive_structure;
from expression import create, give_formula;
from GRgraphics import GRdelete;

extern OMuword EX_active_OS_num;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMfill_attr_value                                               |
 |                                                                           |
 | This fills in the value portion of an attribute structure.                |
 |                                                                           |
 | Input:   EMattr      * attr        Attribute info except value info.      |
 |          struct GRid * desc_id     Describe object which owns attr.       |
 |                                                                           |
 | Output:  IGRlong     * msg         Return code                            |
 |          EMattr      * attr        Attribute with value filled in.        |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  5/7/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMfill_attr_value (IGRlong      * msg,
                           EMattr       * attr,
                           struct GRid  * desc_id)
{
    IGRlong             om_msg = OM_S_SUCCESS;
    struct ret_struct   data;
    IGRint              nret, buffersize;
    struct GRmd_env     mod_env;
    IGRchar             desc_name[DI_PATH_MAX], pwd[DI_PATH_MAX];
    IGRboolean          change_pwd = FALSE;
    
    /*
     * Get a module environment.
     */
    buffersize = sizeof(struct GRmd_env);
    om_msg = gr$get_module_env (msg = msg,
                                sizbuf = &buffersize,
                                buffer = &mod_env,
                                nret = &nret );

    if (!(om_msg & *msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
    
    mod_env.md_id.osnum = desc_id->osnum;
    
    /*
     * Get the value from the expression object.
     */ 
    om_msg = om$send (msg = message NDnode.NDgive_structure
                                          (msg, &data, &mod_env),
                      senderid = NULL_OBJID,
                      targetid = attr->info.id.objid,
                      targetos = attr->info.id.osnum);
 
    if (!(om_msg & *msg & 1))
    {
        *msg = ASM_E_ABORT;
        goto quit;
    }
    
    /*
     * Get the attribute in the context of the describe object. This
     * is done so the expression like "area=length*width" where
     * length and width are stored on this object does not
     * come back with the full path on it.
     */
    di$untranslate (objid = desc_id->objid,
                    osnum = desc_id->osnum,
                    objname = desc_name);
    di$pwd (dirname = pwd);

    /* Added to set the ems directory to usr of working assembly file, 
     * instead of ems root TR#119603578 - bbkr */

    if (strlen(pwd) == 1 && pwd[0] == ':')
    {
      GRspacenum osnum = EX_active_OS_num;
      di$give_pathname ( osnum =  osnum,
                         pathname = pwd);
      strcat(pwd,":usr");
    }

    di$cd (dirname = desc_name);
    change_pwd = TRUE;
    
    switch ( data.type )
    {
    case text_type:
        attr->value.type = EM_STRING;
        strcpy(attr->value.data.s, data.var.text_st.text_string);
            
        /*
         * Store the syntax.
         */
        strcpy (attr->value.syntax, data.var.text_st.text_string);
        break;
 
    case double_type:
        /*
         * Set this up as a double first.
         */
        attr->value.type = EM_DOUBLE;
        attr->value.data.d = data.var.root_pm_st.value;

        /*
         * If this isn't an double.
         */
        if ((attr->value.data.d / 1.0) == 0.0)
        {
            attr->value.type = EM_INTEGER;
            attr->value.data.i = data.var.root_pm_st.value;
        }
        
        /*
         * Store the syntax.
         */
        om_msg = om$send (msg = message expression.give_formula 
                                          (attr->value.syntax),
                          senderid = NULL_OBJID,
                          targetid = attr->info.id.objid,
                          targetos = attr->info.id.osnum);

        if (!(om_msg & 1))
        {
            if (attr->value.type == EM_DOUBLE)
            {
                sprintf (attr->value.syntax, "%f", attr->value.data.d);
            }
            else
            {
                sprintf (attr->value.syntax, "%d", attr->value.data.i);
            }
            
            om_msg = OM_S_SUCCESS;
        }
        break;
 
    default:
        *msg = ASM_E_ABORT;
        break;
    }
        
 quit:
    
    /*
     * Make sure we change back the default working directory.
     */
    if (change_pwd) 
    {
        di$cd (dirname = pwd);
    }

    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMnum_attrs                                                       |
 |                                                                           |
 | This method returns the total number of attributes.                       |
 | The type determines which types of attributes should be considered.       |
 |                                                                           |
 | Input:   IGRint      type        Attribute types to consider.             |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |          IGRint  *   num_attrs   Number of attribute of that type.        |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMnum_attrs    ( IGRlong *  msg;
                        IGRint     type;
                        IGRint  *  num_attrs )
{
    IGRlong om_msg = OM_S_SUCCESS;

    *msg = ASM_S_SUCCESS;

    type &= EM_ATTRIBUTE_MEMBERS;

    om_msg = om$send (msg = message EMdescribe.EMnum_membs (msg, 
                                                            type,
                                                            num_attrs),
                      targetid = my_id);

    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_attr                                                        |
 |                                                                           |
 | This method gets an attribute by index or name.                           |
 | The type determines which types of attributes should be considered.       |
 |                                                                           |
 | Input:   IGRchar * name            Name of attribute, NULL if by index.   |
 |          IGRint    type            Types to consider, not used with name. |
 |          IGRint    index           Index of the attribute.                |
 |                                                                           |
 | Output:  IGRlong * msg             Return code                            |
 |          EMattr  * attr            Attribute.                             |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_attr     ( IGRlong *  msg;
                        IGRchar *  name;
                        IGRint     type;
                        IGRint     index;
                        EMattr  *  attr )
{
    IGRint              om_msg = OM_S_SUCCESS;
    EMattr              loc_attr;

    *msg = ASM_S_SUCCESS;

    type &= EM_ATTRIBUTE_MEMBERS;

    if (attr == NULL)
    {
        attr = &loc_attr;
    }
          
    /*
     * Get the member info ...
     */
    om_msg = om$send ( msg = message EMdescribe.EMget_memb (msg,
                                                            name,
                                                            type,
                                                            index,
                                                            &attr->info ),
                       targetid = my_id );

    /*
     * If we found the attribute, get the attribute's value ...
     */
    if (om_msg & *msg & 1)
    {
        struct GRid desc_id;
        
        desc_id.objid = my_id;
        desc_id.osnum = OM_Gw_current_OS;
        
        om_msg = EMfill_attr_value (msg, attr, &desc_id);
    }

    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_attrs                                                       |
 |                                                                           |
 | This method gets attributes of the specified type.                        |
 | The type determines which types of attributes should be considered.       |
 |                                                                           |
 | Input:   IGRint    type        Attribute types to consider.               |
 |          IGRint    num_attrs   Size of attrs buffer.                      |
 |                                                                           |
 | Output:  IGRlong * msg         Return code                                |
 |          IGRint    num_attrs   Number of attributes returned.             |
 |          EMattr  * attrs       Attributes.                                |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_attrs    ( IGRlong *  msg;
                        IGRint     type;
                        IGRint     num_attrs;
                        EMattr  *  attrs )
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRint  i, num;

    om_msg = om$send (msg = message EMdescribe.EMnum_attrs ( msg, 
                                                             type, 
                                                             &num ),
                      targetid = my_id );

    if (om_msg & *msg & 1)
    {
        if (num_attrs < num)
        {
            *msg = ASM_E_BUFFTOOSMALL;    
        }
        else
        {
            for (i=0; i < num; ++i)
            {
                om_msg = om$send ( msg = message EMdescribe.EMget_attr 
                                                                ( msg,
                                                                  NULL,
                                                                  type,
                                                                  i,
                                                                  &attrs[i] ),
                                   targetid = my_id );

                if (!(om_msg & *msg & 1))
                {
                    break;
                }
            }
        }
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMadd_attr                                                        |
 |                                                                           |
 | This method adds an attribute.                                            |
 |                                                                           |
 | Input:   EMattr  *   attr    Attribute to add, expr_id = NULL_OBJID       |
 |                                                                           |
 | Output:  IGRlong *   msg     Return code                                  |
 |          EMattr  *   attr    New attribute, expr_id filled in.            |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMadd_attr     ( IGRlong     *  msg;
                        EMattr      *  attr )
{
    IGRlong     om_msg = OM_S_SUCCESS, ok;
    OM_S_OBJID  objid;
    IGRchar     my_name[DI_PATH_MAX], pwd[DI_PATH_MAX];
    IGRshort    short_msg;
    IGRboolean  change_pwd = FALSE;
    IGRchar     reduced_syntax[DI_PATH_MAX];
    IGRint      index;

    /*
     * See if a member with that name already exists.
     */
    om_msg = om$send(msg = message EMdescribe.EMget_memb (msg, 
                                                          attr->info.name, 
                                                          EM_MEMBER_TYPES,
                                                          0,
                                                          NULL),
                     targetid = my_id);

    if (om_msg & *msg & 1)
    {
        *msg = ASM_E_MEMBEXISTS;
    }
    else
    {
        IGRshort state;
        
        om_msg = OM_S_SUCCESS;
        *msg = ASM_S_SUCCESS;
        
        om_msg = om$send (msg = message EMdescribe.EMlegal_attr_op (msg,
                                                                    EM_ADD,
                                                                    attr),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * Construct the expression object with me as the 
         * current working directory.
         */
        di$untranslate(objid = my_id, objname = my_name);
        di$pwd (dirname = pwd);
        di$cd  (dirname = my_name);
        change_pwd = TRUE;
        
        /*
         * Turn off the message display while creating expression 
         * objects. We should talk with someone about getting rid 
         * of this work around! Expression objects ouput error 
         * messages if the expression cannot be added as a double.
         */
        ms$onoff (msg = &ok, prevstate = &state, type = MS_OFF);
        
        /*
         * If this isn't a string expression ...
         */
        if (attr->value.type != EM_STRING)
        {
            /*
             * Reduce the syntax to what's necessary. This is done to make
             * sure that an expression like "2 [2] is reduced to "2".
             */
            EMreduce_syntax (attr->value.syntax, reduced_syntax);
            
            /*
             * Try to add the attribute to myself as a double.
             */
            om_msg = om$construct (classname = "expression",
                                   osnum = OM_Gw_current_OS,
                                   p_objid = &objid);
        
            if (om_msg & 1)
            {
                /*
                 * Save the index of the new object.
                 */
                index = om$dimension_of (varray = me->info);
                
                /*
                 * Create the expression, this will add it to this object.
                 */
                om_msg = om$send (msg = message expression.create 
                                                          (attr->info.name, 
                                                           reduced_syntax,
                                                           &short_msg),
                                  targetid = objid);
                
                *msg = short_msg;
                
                if (!(om_msg & *msg & 1))
                {
                    om$send (msg = message Root.delete (1),
                             targetid = objid);
                }
                else
                {
                    attr->info.index = index;
                    
                    /*
                     * Update the member info for this attribute.
                     */
                    om_msg = om$send (msg = message EMdescribe.EMmod_memb_info
                                                         (msg, &attr->info),
                                      targetid = my_id);

                    if (!(om_msg & *msg & 1))
                    {
                        goto quit;
                    }
                }
            }
        }
        else
        {
            strcpy (reduced_syntax, attr->value.syntax);
        }

        if (!(om_msg & *msg & 1) || (attr->value.type == EM_STRING))
        {
            *msg = ASM_S_SUCCESS;
            
            /*
             * Try to add the attribute to myself as a string.
             */
            om_msg = om$construct (classname = "text_exp",
                                   osnum = OM_Gw_current_OS,
                                   p_objid = &objid);
        
            if (om_msg & 1)
            {
                /*
                 * Save the index.
                 */
                index = om$dimension_of (varray = me->info);
                
                /*
                 * Create the string expression, this will add it to this
                 * object.
                 */
                om_msg = om$send (msg = message expression.create 
                                                          (attr->info.name, 
                                                           reduced_syntax,
                                                           &short_msg),
                              targetid = objid);

                *msg = short_msg;

                if (!(om_msg & *msg & 1))
                {
                    om$send (msg = message Root.delete(1),
                             targetid = objid);

                    *msg = ASM_E_INVSYNTAX;
                }
                else
                {
                    attr->info.index = index;
                    
                    /*
                     * Update the member info for this attribute.
                     */
                    om_msg = om$send (msg = message EMdescribe.EMmod_memb_info
                                                         (msg, &attr->info),
                                      targetid = my_id);

                    if (!(om_msg & *msg & 1))
                    {
                        goto quit;
                    }
                }
            }
            else
            {
                *msg = ASM_E_ABORT;
            }
        }

        /*
         * Set message display to previous state.
         */
        ms$onoff (msg = &ok, 
                  prevstate = &state, 
                  setstate = state, 
                  type = MS_SET);

        /*
         * If everything is ok ...
         */
        if (om_msg & *msg & 1)
        {
            IGRlong ok;
            
            struct GRid desc_id;

            /*
             * Return the expression id.
             */
            attr->info.id.objid = objid,
            attr->info.id.osnum = OM_Gw_current_OS;
            
            desc_id.objid = my_id;
            desc_id.osnum = OM_Gw_current_OS;
                
            /*
             * Now backfill the attribute structure so
             * the complete syntax and data values are
             * returned.
             */
            EMfill_attr_value (&ok, attr, &desc_id);
        }
    }
    
quit:

    /*
     * Change directory back to the original pwd.
     */
    if (change_pwd)
    {
        di$cd  (dirname = pwd);
    }

    return om_msg;
}
    
/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMmod_attr                                                        |
 |                                                                           |
 | This method modifies an attribute.                                        |
 |                                                                           |
 | Input:   IGRchar  *   name       Name of attribute to modify.             |
 |          IGRint   *   type       Type of attribute to modify.             |
 |          IGRint   *   index      Index of attribute to modify.            |
 |          EMattr   *   attr       Attribute info to modify.                |
 |                                                                           |
 | Output:  IGRlong  *   msg     Return code                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMmod_attr     ( IGRlong *  msg;
                        IGRchar *  name;
                        IGRint     type;
                        IGRint     index;
                        EMattr  *  attr )
{
    IGRint om_msg = OM_S_SUCCESS;
    EMattr loc_attr;

    /*
     * Get the attribute ...
     */
    om_msg = om$send ( msg = message EMdescribe.EMget_attr
                                                ( msg,
                                                  name,
                                                  type,
                                                  index,
                                                  &loc_attr ),
                       targetid = my_id );

    /*
     * If we found the attribute ...
     */
    if ((om_msg & *msg & 1) && (attr != NULL))
    {
        /*
         * Make sure it's ok to modify this attribute.
         */
        om_msg = om$send (msg = message EMdescribe.EMlegal_attr_op (msg,
                                                                    EM_MOD,
                                                                    attr),
                          targetid = my_id);
        
        if (!(om_msg & *msg & 1))
        {
            goto quit;
        }
        
        /*
         * Set the expression id.
         */
        attr->info.id.objid = loc_attr.info.id.objid;
        attr->info.id.osnum = loc_attr.info.id.osnum;
        
        /*
         * If the syntax has changed update it ...
         */
        if (EMsyntax_different(attr->value.syntax, loc_attr.value.syntax))
        {
            IGRchar   my_name[DI_PATH_MAX], pwd[DI_PATH_MAX];
            IGRchar * syntax = attr->value.syntax;
            
            /*
             * If this isn't a string expression ...
             */
            if (loc_attr.value.type != EM_STRING)
            {
                /*
                 * Reduce the syntax to what's necessary. This is done to make
                 * sure that an expression like "2 [2] is reduced to "2".
                 */
                EMreduce_syntax (attr->value.syntax, loc_attr.value.syntax);
                syntax = loc_attr.value.syntax;
            }
            
            /*
             * Modify the expression object within the context of 
             * this object.
             */
            di$untranslate(objid = my_id, objname = my_name);
            di$pwd (dirname = pwd);
            di$cd (dirname = my_name);
            
            *msg = exp$modify(exp_id = loc_attr.info.id.objid,
                              osnum = loc_attr.info.id.osnum,
                              exp_syntax = syntax);

            if (!(*msg & 1))
            {
                *msg = ASM_E_INVSYNTAX;
            }
            
            /*
             * Change back to the default directory.
             */
            di$cd (dirname = pwd);
        }
        else /* The value will be the same. */
        {
            attr->value = loc_attr.value;
        }

        if (om_msg & *msg & 1)
        {
            /*
             * If any of the member info has changed ..
             */
            if ((attr->info.type != loc_attr.info.type) ||
                (strcmp (attr->info.name, loc_attr.info.name)) ||
                (strcmp (attr->info.desc, loc_attr.info.desc)))
            {
                /*
                 * Update it.
                 */
                om_msg = om$send (msg = message EMdescribe.EMmod_memb
                                                     (msg, 
                                                      name,
                                                      type,
                                                      index,
                                                      &(attr->info)),
                                  targetid = my_id);
            }

            if (om_msg & *msg & 1)
            {
                struct GRid desc_id;
                
                desc_id.objid = my_id;
                desc_id.osnum = OM_Gw_current_OS;
                
                /*
                 * Now backfill the attribute structure so
                 * the complete syntax and data values are
                 * returned.
                 */
                om_msg = EMfill_attr_value (msg, attr, &desc_id);

                if (!(om_msg & *msg & 1))
                {
                    goto quit;
                }
            }
        }
    }
    else
    {
        *msg = ASM_E_MEMBNOTFOUND;
    }

 quit:
    
    return (om_msg);    
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMrem_attr                                                        |
 |                                                                           |
 | This method removes an attribute from the part by name or index.          |
 |                                                                           |
 | Input:   IGRchar     * name        Name of attribute, NULL if by index.   |
 |          IGRint        type        Types to consider, not used with name. |
 |          IGRint        index       Index of the attribute.                |
 |                                                                           |
 | Output:  IGRlong *     msg         Return code                            |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 |                                                                           | 
 +---------------------------------------------------------------------------*/
method EMrem_attr     ( IGRlong *  msg;
                        IGRchar *  name;
                        IGRint     type;
                        IGRint     index )
{
    IGRlong om_msg = OM_S_SUCCESS;

    type &= EM_ATTRIBUTE_MEMBERS;

    om_msg = om$send ( msg = message EMdescribe.EMrem_memb (msg,
                                                            name,
                                                            type,
                                                            index),
                           targetid = my_id );
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMlegal_attr_op                                                  |
 |                                                                           |
 | This method determines whether it's legal to perform the specified        |
 | operation on the attribute.                                               |
 |                                                                           |
 | Input:   IGRint      operation   EM_ADD, EM_MOD, or EM_REM.               |
 |          EMattr      attr        Attribute.                               |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code                              |
 |                                                                           |
 | Return:  ASM_S_SUCCESS       Successful.                                  |
 |          ASM_E_ILLEGALOP     Illegal operation on reserved attribute.     |
 |          ASM_E_ABORT         Catostrophic error.                          |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMlegal_attr_op (IGRlong *msg; IGRint operation; EMattr * attr)
{
    *msg = ASM_S_SUCCESS;
    return OM_S_SUCCESS;
}

end implementation EMdescribe;
