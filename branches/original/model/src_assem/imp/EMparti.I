class implementation EMpart;

#include <grimport.h>
#include <DIprims.h>
#include <OMmacros.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

#include "assemdef.h"
#include "assem.h"
#include "assempriv.h"
#include "assemmacros.h"

extern OMuword OPP_expression_class_id;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method: EMget_instancename                                                |
 |                                                                           |
 | This method returns a unique name for an instance object.                 |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRchar *   name        Name for the instance.                   |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  3/25/93     creation                                     |
 | dkk              4/20/94     modified method name to avoid clash with     |
 |                              function name                                |
 +---------------------------------------------------------------------------*/
method EMget_instancename (IGRlong * msg; 
                            IGRchar * dirname; 
                            IGRchar * name)
{
    IGRlong om_msg = OM_S_SUCCESS;
    IGRchar path[DI_PATH_MAX];
    
    *msg = ASM_S_SUCCESS;
    
    /*
     * Get my name.
     */
    if (di$untranslate (objid = my_id,
                        osnum = OM_Gw_current_OS,
                        objname = path) == DIR_S_SUCCESS)
    {
        IGRchar loc_dirname[DI_PATH_MAX], basename[DI_PATH_MAX];

        /*
         * Use local dirname buffer if one is not provided.
         */
        if (!dirname)
        {
            dirname = loc_dirname;
        }

        /*
         * Get the base name for the instance which is my basename.
         */
        di$split (pathname = path, 
                  dirname = dirname,
                  name = basename);

        strcat (basename, "#");
        
        /*
         * Make it a unique name.
         */
        om_msg = om$send (msg = message EMdescribe.EMget_unique_name 
                                               (msg, basename, name),
                          targetid = my_id);

        /*
         * Store the directory name if requested.
         */
        if (dirname != loc_dirname)
        {
            strcpy (dirname, path);
        }
    }
    else
    {
        *msg = ASM_E_ABORT;
    }

    return (om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMdefault_memb_type                                             |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/18/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMdefault_memb_type (IGRlong     * msg; 
                            struct GRid * memb_id; 
                            IGRint      * type)
{
    IGRlong om_msg;
    
    om_msg = om$send (msg = message EMdescribe.EMdefault_memb_type (msg,
                                                                    memb_id,
                                                                    type),
                      mode = OM_e_wrt_message,
                      targetid = my_id);

    if ((om_msg & *msg & 1) && (*type == EM_ATTRIBUTE))
    {
        *type = EM_PART_ATTR;
    }
    
    return om_msg;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMget_memb_type                                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/18/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_memb_type (IGRlong *msg; IGRint * type)
{
    *msg = ASM_S_SUCCESS;
    *type = EM_PART;
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMlegal_memb_op                                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  6/18/93     creation                                     |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMlegal_memb_op (IGRlong *msg; IGRint operation; EMmemb * memb)
{
    *msg = ASM_S_SUCCESS;

    if (!EMdesc_get_system_mode())
    {
        if (!strncmp(memb->name, "asm_", 4))
        {
            *msg = ASM_E_ILLEGALOP;
            goto quit;
        }

        switch (operation)
        {
        case EM_ADD:
            if (!strcmp(memb->name, "number")        ||
                !strcmp(memb->name, "revision")      ||
                !strcmp(memb->name, "name")          ||
                !strcmp(memb->name, "filename")      ||
                !strcmp(memb->name, "database")      ||
                !strcmp(memb->name, "catalog")       ||
                !strcmp(memb->name, "entry")         ||
                !strcmp(memb->name, "itemno")        ||
                !strcmp(memb->name, "count")         ||
                !strcmp(memb->name, "origin")        ||
                !strcmp(memb->name, "view"))
            {
                *msg = ASM_E_ILLEGALOP;
            }
            else if ((!strcmp(memb->name, "weight")      ||
                      !strcmp(memb->name, "cost")        ||
                      !strcmp(memb->name, "mass"))       ||
                      !strcmp(memb->name, "material")    &&
                     memb->type != EM_PART_ATTR)
            {
                *msg = ASM_E_ILLEGALOP;
            }
            else if (!strcmp(memb->name, "quantity")     &&
                     memb->type != EM_INSTANCE_ATTR)
            {
                *msg = ASM_E_ILLEGALOP;
            }
            break;
            
        case EM_MOD:
            if (!strcmp(memb->name, "name")          ||
                !strcmp(memb->name, "filename")      ||
                !strcmp(memb->name, "database")      ||
                !strcmp(memb->name, "catalog")       ||
                !strcmp(memb->name, "entry")         ||
                !strcmp(memb->name, "count")         ||
                !strcmp(memb->name, "origin"))
            { 
                *msg = ASM_E_ILLEGALOP;
            }
            else if ((!strcmp(memb->name, "number")       ||
                      !strcmp(memb->name, "revision")     ||
                      !strcmp(memb->name, "weight")       ||
                      !strcmp(memb->name, "cost")         ||
                      !strcmp(memb->name, "mass")         ||
                      !strcmp(memb->name, "material"))    &&
                     memb->type != EM_PART_ATTR)
            {
                *msg = ASM_E_ILLEGALOP;
            }
            else if (!strcmp(memb->name, "itemno") &&
                     (memb->type != EM_COMMON_ATTR))
            {
                *msg = ASM_E_ILLEGALOP;
            }
            else if (!strcmp(memb->name, "view") &&
                     memb->type != EM_INSTANCE_ATTR)
            {
                *msg = ASM_E_ILLEGALOP;
            }
            break;
            
        case EM_REM:
        case EM_RNM:
            if (!strcmp(memb->name, "name")          ||
                !strcmp(memb->name, "number")        ||
                !strcmp(memb->name, "revision")      ||
                !strcmp(memb->name, "filename")      ||
                !strcmp(memb->name, "database")      ||
                !strcmp(memb->name, "catalog")       ||
                !strcmp(memb->name, "entry")         ||
                !strcmp(memb->name, "itemno")        ||
                !strcmp(memb->name, "count")         ||
                !strcmp(memb->name, "origin")        ||
                !strcmp(memb->name, "view"))
            { 
                *msg = ASM_E_ILLEGALOP;
            }
            break;
        }
    }

 quit:
    
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Override: EMlegal_attr_op                                                 |
 |                                                                           |
 | History:                                                                  |
 |                                                                           |
 | jay wallingford  8/6/93     creation                                      |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMlegal_attr_op (IGRlong *msg; IGRint operation; EMattr * attr)
{
struct GRid mygrid;
IGRint type, om_msg;

    *msg = ASM_S_SUCCESS;

    switch (operation)
    {
    case EM_ADD:
    case EM_MOD:
        /*
         * Insure that the itemno attribute is unique and is a string.
	 * Do this only for REFERENCE and LOCAL parts and not for
	 * FILE_PART - 20/04/94
         */
        if (!strcmp(attr->info.name, "itemno"))
	{
	    mygrid.objid = my_id;
    	    mygrid.osnum = OM_Gw_current_OS;

    	    om_msg = asm$get_part_type( msg = msg,
				   part_id = &mygrid,
				   type = &type );
            if( !(om_msg & *msg & 1) )
	        goto quit;		

            if( type == EM_FILE_PART )
            {
                if( attr->value.type != EM_STRING )
                    *msg = ASM_E_ILLEGALOP;
                goto quit;
            }

            if ((attr->value.type != EM_STRING) ||
                (!EMitem_string_unique (attr->value.syntax)))
                
            {
                *msg = ASM_E_ILLEGALOP;
            }
        }
        
        break;
    }
    
quit:
    return OM_S_SUCCESS;
}

end implementation EMpart;




