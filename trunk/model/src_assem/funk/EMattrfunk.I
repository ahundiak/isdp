class implementation EMdescribe;

#include <grimport.h>
#include <DIprims.h>
#include <grownerdef.h>
#include <grerr.h>
#include <gocmacros.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpbmacros.h>
#include <exdef.h>
#include <ex.h>
#include <exmacros.h>
#include "assemdef.h"
#include "assem.h"
#include "assemmacros.h"
#include "asmfilemac.h"

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMattribute_count                                               |
 |                                                                           |
 | This function returns the number of attributes on a part or an instance.  | 
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMattribute_count (IGRlong       * msg,
                           struct GRid   * id,
                           IGRint          type,
                           IGRint        * count)
{
    IGRlong          om_msg = OM_S_SUCCESS;
    IGRint           num_attrs;
 
    *msg = ASM_S_SUCCESS;
    *count = 0;

    /*
     * Get total number of attributes of specified type.
     */ 
    om_msg = om$send (msg = message EMdescribe.EMnum_attrs(msg,
                                                           type,
                                                           &num_attrs),
                      senderid = NULL_OBJID,
                      targetos = id->osnum,
                      targetid = id->objid);

    if ( om_msg & *msg & 1 )
    {
        *count = num_attrs; 
    }
    
    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMget_attribute                                                 |
 |                                                                           |
 | This function returns an attribute by name or index.                      | 
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMget_attribute (IGRlong         * msg,
                         struct GRid     * id,
                         IGRchar         * name,
                         IGRint            type,
                         IGRint            index,
                         EMattr          * attribute)
{
    IGRlong om_msg = OM_S_SUCCESS;
    EMattr  loc_attribute;
    
    *msg = ASM_S_SUCCESS;
    
    if (!attribute)
    {
        attribute = &loc_attribute;
    }
    
    /*
     * Get attribute specified by name or index.
     */
    om_msg = om$send (msg = message EMdescribe.EMget_attr(msg,
                                                          name,
                                                          type,
                                                          index,
                                                          attribute),
                      senderid = NULL_OBJID,
                      targetos = id->osnum,
                      targetid = id->objid);

    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMadd_attribute                                                 |
 |                                                                           |
 | This function adds an attribute to a part or an instance.                 |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMadd_attribute (IGRlong         * msg,
                         struct GRid     * id,
                         EMattr          * attribute)
{
    IGRlong om_msg = OM_S_SUCCESS;

    *msg = ASM_S_SUCCESS;

    /* 
     * Add attribute to part or instance.
     */
    om_msg = om$send (msg = message EMdescribe.EMadd_attr(msg,
                                                          attribute),
                      senderid = NULL_OBJID,
                      targetos = id->osnum,
                      targetid = id->objid);
    
    return(om_msg);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMmod_attribute                                                 |
 |                                                                           |
 | This function modifies an attribute on a part or an instance.             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMmod_attribute (IGRlong         * msg,
                         struct GRid     * id,
                         IGRchar         * name,
                         IGRint            type,
                         IGRint            index,
                         EMattr          * attribute)
{
    IGRlong om_msg = OM_S_SUCCESS;

    *msg = ASM_S_SUCCESS;

    /*
     * Modify attribute on part or instance.
     */
    om_msg = om$send (msg = message EMdescribe.EMmod_attr(msg,
                                                          name,
                                                          type,
                                                          index,
                                                          attribute),
                      senderid = NULL_OBJID,
                      targetos = id->osnum,
                      targetid = id->objid);

    return(om_msg);
}


/*---------------------------------------------------------------------------+
 |                                                                           |
 | Function: EMrem_attribute                                                 |
 |                                                                           |
 | This function removes an attribute from a part or an instance.            |
 |                                                                           |
 +---------------------------------------------------------------------------*/
IGRlong EMrem_attribute (IGRlong         * msg,
                         struct GRid     * id,
                         IGRchar         * name,
                         IGRint            type,
                         IGRint            index)
{
    IGRlong om_msg = OM_S_SUCCESS;

    *msg = ASM_S_SUCCESS;

    /*
     * Removes an attribute from a part or an instance.
     */
    om_msg = om$send (msg = message EMdescribe.EMrem_attr(msg,
                                                          name,
                                                          type,
                                                          index),
                      senderid = NULL_OBJID,
                      targetos = id->osnum,
                      targetid = id->objid);

    return(om_msg);
}

/*----------------------------------------------------------------------------+
 | Fuction used by GRNUC place balloon command object and others              |
 +----------------------------------------------------------------------------*/

IGRlong EMget_attr_valstr( IGRlong *msg, 
			   IGRchar * name, 
                           struct GRid * inst_id,
                           IGRchar * value )
{
IGRlong om_msg = OM_S_SUCCESS;
EMattr  attr;
struct  GRid part_id;

    *msg = MSSUCC;

    /*
     * First try to get the attribute from the instance ( OCCURANCE )
     */

    om_msg = om$send (msg = message EMdescribe.EMget_attr( msg,
                                                          name,
                                                          0,
                                                          -1,
                                                          &attr),
                      senderid = NULL_OBJID,
                      targetos = inst_id->osnum,
                      targetid = inst_id->objid);

    if( om_msg & *msg & 1 )
    {
	if( attr.value.type != EM_STRING )
	{
            sprintf( value, "%g", attr.value.data.d );
        }
        else
            strcpy( value, attr.value.syntax );
    }
    else
    {
        /*
         * Attribute not on instance, Get the part id given the inst_id and try
         * it from the part
         */
        om_msg = EMget_instance_part ( msg, inst_id, &part_id );

	if( !(om_msg & *msg & 1 ))
	    goto quit;

        om_msg = om$send (msg = message EMdescribe.EMget_attr( msg,
                                                          name,
                                                          0,
                                                          -1,
                                                          &attr),
                      senderid = NULL_OBJID,
                      targetos = part_id.osnum,
                      targetid = part_id.objid);

        if( om_msg & *msg & 1 )
        {
            strcpy( value, attr.value.syntax );        
        }
        else
            value[0] = 0;
    }

quit:
    return( om_msg );
}

/*
 * This function needs to be stubbed in GRNUC, used by TRsavimp.I for
 * save and rename.
 */
EMsave_newprt( filename, number, revision, description )
IGRchar * filename, * number, * revision, * description;
{
IGRlong msg;
IGRint  om_msg = OM_S_SUCCESS, old_system_mode = -1;
struct  GRid id;
EMattr  attr[3], numb, rev, desc;

    /* Get the file_part and its identity */
    om_msg = asm$get_file_part( msg = &msg,
                                part_id = &id );
    if( om_msg & msg & 1 )
    {
        om_msg = asm$get_part_identity( msg = &msg,
                                        part_id = &id,
                                        number = &numb,
                                        revision = &rev,
                                        description = &desc );
        if( !(om_msg & msg & 1) )
            goto quit;

        /* Go to system mode */
        old_system_mode = EMdesc_set_system_mode(TRUE);

        /* Modify the file_part identity to the new id */
        if( number[0] )
        {
            attr[0].info.type = EM_PART_ATTR;
            strcpy(attr[0].value.syntax, number);
	        strcpy(attr[0].info.name,"number");
	        strcpy(attr[0].info.desc,"Part Number");
            om_msg = asm$mod_attribute( msg = &msg,
                                        id = &id,
                                        name = "number",
                                        attribute = &attr[0] );
        }
        if( revision[0] )
        {
            attr[1].info.type = EM_PART_ATTR;
            strcpy(attr[1].value.syntax, revision);
	    strcpy(attr[1].info.name,"revision");
            om_msg = asm$mod_attribute( msg = &msg,
                                        id = &id,
                                        name = "revision",
                                        attribute = &attr[1] );
        }
        if( description[0] )
        {
            attr[2].info.type = EM_PART_ATTR;
            strcpy(attr[2].value.syntax, description);
	    strcpy(attr[2].info.name,"description");
            om_msg = asm$mod_attribute( msg = &msg,
                                        id = &id,
                                        name = "description",
                                        attribute = &attr[2] );
        }
    }

    /* Save the current file with new name */
    EX_saveas1(filename);

    if( old_system_mode != -1 )
    {
	IGRchar *ptr = NULL, *dir = NULL;
        IGRchar path[DI_PATH_MAX], name[DI_PATH_MAX];

	/* split the path and name of file */
	ptr = strrchr(filename, '/');
	if( ptr )
        {
            dir = path;
            strncpy(dir, filename, ptr - filename );
	    strcpy( name, ptr+1 );
        }
        else
            strcpy( name, filename );

        /* if any of the three is not given, use the original */
        if( !number[0] )
            attr[0] = numb;
        if( !revision[0] )
            attr[1] = rev;
        if( !description[0] )
            attr[2] = desc;

	/* Add the new part to the ascii file */
	om_msg = asm$add_directory_part( msg = &msg,
                                         dir = dir,
                                         filename = name,
                                         numb = attr[0].value.syntax,
                                         rev = attr[1].value.syntax,
                                         desc = attr[2].value.syntax );
 
        /* Reset the identity of the current file_part using stored identity */
        om_msg = asm$mod_attribute( msg = &msg,
                                    id = &id,
                                    name = "number",
                                    attribute = &numb );
        om_msg = asm$mod_attribute( msg = &msg,
                                    id = &id,
                                    name = "revision",
                                    attribute = &rev );
        om_msg = asm$mod_attribute( msg = &msg,
                                    id = &id,
                                    name = "description",
                                    attribute = &desc );

        /* Get out of system mode */
        EMdesc_set_system_mode(old_system_mode);
    }

quit:
    return( om_msg );
}

end implementation EMdescribe;







