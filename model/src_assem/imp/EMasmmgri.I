class implementation EMasmmgr;

#include <OMerrordef.h>
#include <msdef.h>
#include <grimport.h>
#include <grerr.h>
#include <gocmacros.h>
#include <assemdef.h>
#include <msmacros.h>
#include <grmessage.h>
#include <grdpbdef.h>
#include <grdpb.h>
#include <grdpbmacros.h>

#include <assemdef.h>
#include <assem.h>
#include <assemmacros.h>

from EMdescribe  import EMget_display;
from EMlocalpart import EMget_layers;
from EMdescribe  import EMupdate;

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMget_item_number                                                |
 |                                                                           |
 | This method returns the next item number for a part object.               |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRchar *   item_number Item number.                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMget_item_number (IGRlong *msg; IGRchar *item_number)
{
    IGRchar buffer[40];
    
    *msg = ASM_S_SUCCESS;

    strcpy (buffer, me->item_number);
    
    while (!EMitem_string_unique(EMget_next_item_string(buffer, item_number)))
    {
        strcpy (buffer, item_number);
    }
#ifdef DEBUG
printf("get itemno: old=%s, new=%s\n",me->item_number, item_number);
#endif
    return OM_S_SUCCESS;
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  EMset_item_number                                                |
 |                                                                           |
 | This method sets the last used item number, it will be sent during the    |
 | construction of a part. The last used item number is used to determine    |
 | the format of item number (1, 2, 3, etc. or aa, bb, cc, etc.). This       |
 | message will also insure that the item number is unique within the file   |
 |                                                                           |
 | Output:  IGRlong *   msg         Return code, MSSUC or MSFAIL for now.    |
 |          IGRchar *   item_number Item number.                             |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method EMset_item_number (IGRlong *msg; IGRchar * item_number)
{
    *msg = ASM_S_SUCCESS;

    if (!EMitem_string_unique(item_number))
    {
        *msg = ASM_E_ABORT;
    }
    else
        strcpy( me->item_number, item_number);
#ifdef DEBUG
printf("set itemno=%s\n",me->item_number);
#endif
    return (OM_S_SUCCESS);
}

method super_construct ()
{
    strcpy (me->item_number, "0");
    return (OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------+
 |                                                                           |
 | Method:  wake_up                                                          |
 |                                                                           |
 | This message will update all cached parts.                                |
 |                                                                           |
 +---------------------------------------------------------------------------*/
method wake_up ()
{
    IGRlong             om_msg = OM_S_SUCCESS, msg = ASM_S_SUCCESS;
    IGRint              i, count;
    struct GRid         part_id;
    struct GRmd_env     mod_env;

    struct GRid         *prts_list = NULL;
    
    gr$get_module_env (buffer = &mod_env);
    mod_env.md_id.osnum = OM_Gw_current_OS;
    
    if(mod_env.md_id.osnum == EX_active_OS_num)
     {
       IGRlong  layers[32], on_layers[32];
       IGRlong  non_onlayers[32];
       struct GRid         filepart_id;
       IGRint   display_types;

       asm$get_file_part(msg = &msg,
                         mod_env = &mod_env,
                         part_id = &filepart_id);

       om_msg = om$send(msg = message EMdescribe.EMget_display(&msg,
                                                               &display_types,
                                                               on_layers),
                        targetid = filepart_id.objid,
                        targetos = filepart_id.osnum);

       om_msg = om$send(msg = message EMlocalpart.EMget_layers(&msg,
                                                               layers,
                                                               on_layers,
                                                               non_onlayers),
                        targetid = filepart_id.objid,
                        targetos = filepart_id.osnum);

       if(1 & msg & om_msg)
        {
           EMset_layer_display(&msg,
                               &mod_env,
                               layers,
                               display_types,
                               on_layers,
                               TRUE);
        }

     }
    om_msg = asm$part_count (msg = &msg,
                             mod_env = &mod_env,
                             count = &count);
    if (!(om_msg & msg & 1))
    {
        goto quit;
    }
    
    prts_list = (struct GRid *)malloc(count * sizeof(struct GRid));

    for (i=0; i<count; ++i)
    {
        prts_list[i].objid = NULL_OBJID;
        om_msg = asm$get_part (msg = &msg,
                               mod_env = &mod_env,
                               index = i,
                               part_id = &part_id);
        
        if (!(om_msg & msg & 1))
        {
            continue;
        }

	/* Store the partids in an array and then send update to each 
	   one. This is because, when one part is updated, the index 
           changes and so getting parts by index will not work. 27/09/94
         */
        prts_list[i] = part_id;        
    }

    for (i=0; i<count; ++i)
    {
        if (prts_list[i].objid != NULL_OBJID)
        {
            om_msg = om$send (msg = message EMdescribe.EMupdate (&msg),
                          targetid = prts_list[i].objid,
                          targetos = prts_list[i].osnum);
        }
    }

 quit:
    
    if(mod_env.md_id.osnum == EX_active_OS_num)
     {
        EMasmtree_generate();
        EMupdate_asm_display(&msg);
        EMbom_wakeup();
     }

    if (prts_list)
        free (prts_list);

    return (OM_S_SUCCESS);
}

method sleep (int type_sleep)
{
    if(OM_Gw_current_OS == EX_active_OS_num)
    EMbom_sleep();
    return (OM_S_SUCCESS);
}

end implementation EMasmmgr;

