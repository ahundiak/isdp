/* #######################    APOGEE COMPILED   ######################## */
/*\
Description
   The following functions are called by macros.

History
   Gray Winn    08/27/87   Creation date.
   msm          07/09/92   ANSI-C conversion.
\*/

class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "lcmacros.h"

from GRconnector import GRflexconn;

static OM_S_CHANSELECT lc_to_go_chansel;
%safe
static int chan_inited=0;
%endsafe

static  OM_S_OBJECT_LINKAGE static_buffer[50];

/*\
Name
   lc$connect

Description
   This routine provides the connect mechanism between commands 
   and graphics objects.

   osnum                GRspacenum        The command's osnum
   objid                OM_S_OBJID        The command's objid
   p_chanselect         OM_p_CHANSELECT   The command's channel
   index                IGRint            The command's index 
   go_objid             OM_S_OBJID        The objid of the graphics object
   go_osnum             GRspacenum        The osnum of the graphics object
   go_index             IGRint            The index of the grpahics object

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
int LCconnect (osnum, objid, p_chanselect, index, go_objid, go_osnum,
               go_index)
GRspacenum        osnum;
OM_S_OBJID        objid;
OM_p_CHANSELECT   p_chanselect;
IGRint            index;
OM_S_OBJID        go_objid;
GRspacenum        go_osnum;
IGRint            go_index;
{
IGRlong           om_msg;
IGRlong           ret_msg;
IGRlong           connect_flag;
IGRlong           index2;
OM_S_CHANSELECT   lc_to_co_chansel;
struct GRid       lc_objid;

   connect_flag = 1; /* Override */
   index2 = OM_K_MAXINT;
   lc_to_co_chansel.type = OM_e_name;
   lc_to_co_chansel.u_sel.name = "LCcmd_iso.to_command";

   /*
    *  Construct the intermediate locate object in the same object
    *  space as the graphics object.
    */

   lc_objid.osnum = go_osnum;
   om_msg = om$construct (classname = "LCcmd_iso", osnum = go_osnum,
            p_objid = &lc_objid.objid);

   if (om_msg & 1)
   {
      /*
       *  Connect the intermediate object to the graphics object.
       */

      om_msg = om$send(
               msg = message GRconnector.GRflexconn (&ret_msg, 
               &connect_flag, &lc_objid, &index2, (IGRlong *)&go_index),
               senderid = NULL_OBJID, targetid = go_objid,
               targetos = go_osnum);

      if (om_msg & 1)
      {
         /*
          *  Connect the intermediate object to the command object.
          */

         om_msg = om$send(
                  msg = message Root.connect (lc_to_co_chansel, 
                  OM_K_MAXINT, objid, osnum, *p_chanselect, index),
                  senderid = NULL_OBJID, targetos = lc_objid.osnum,
                  targetid = lc_objid.objid);

      }
   }
   return (om_msg);
}

/*\
Name
   lc$wild_disconnect

Description
   This routine severs the connection between a commanbd and all 
   graphics objects on a specified command channel.

   osnum                GRspacenum        The command's osnum
   objid                OM_S_OBJID        The command's objid
   p_chanselect         OM_p_CHANSELECT   The command's channel

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
int LCwild_disconnect (osnum, objid, p_chanselect)
GRspacenum        osnum;
OM_S_OBJID        objid;
OM_p_CHANSELECT   p_chanselect;
{
IGRlong           om_msg;

   /*
    *  Delete the intermediate object so that the connect between
    *  the command and the graphics object is broken.
    */

   om_msg = om$send (
            msg = message Root.delete (FALSE),
            senderid = objid, targetos = osnum,
            p_chanselect = p_chanselect);

   return(om_msg);
}

/*\
Name
   lc$range_disconnect

Description
   This routine provides the mechanism for commands to disconnect 
   the graphics objects within a certain range on the command object's
   channel.

   osnum                GRspacenum        The command's osnum
   objid                OM_S_OBJID        The command's objid
   p_chanselect         OM_p_CHANSELECT   The command's channel
   low_index            IGRint            The low index of the disconnect
                                          range
   high_index           IGRint            The high index of the disconnect
                                          range

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
int LCrange_disconnect (osnum, objid, p_chanselect, low_index, 
                        high_index)
GRspacenum        osnum;
OM_S_OBJID        objid;
OM_p_CHANSELECT   p_chanselect;
IGRint            low_index;
IGRint            high_index;
{
IGRlong           om_msg;

   /*
    *  Delete the intermediate object so that the connect between
    *  the command and the graphics object is broken.
    */

   om_msg = om$send (
            msg = message Root.delete (FALSE),
            senderid = objid, targetos = osnum,
            p_chanselect = p_chanselect, from = low_index, 
            to = high_index);

   return(om_msg);
}

/*\
Name
   lc$disconnect

Description
   This routine provides the mechanism for commands to disconnect 
   a graphics object from its channel.

   osnum                GRspacenum        The command's osnum
   objid                OM_S_OBJID        The command's objid
   p_chanselect         OM_p_CHANSELECT   The command's channel
   go_objid             OM_S_OBJID        The objid of the graphics object
   go_osnum             GRspacenum        The osnum of the graphics object

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
int LCdisconnect (osnum, objid, p_chanselect, go_objid, go_osnum)
GRspacenum        osnum;
OM_S_OBJID        objid;
OM_p_CHANSELECT   p_chanselect;
OM_S_OBJID        go_objid;
GRspacenum        go_osnum;
{
IGRlong           om_msg;
IGRint            index;

   om_msg = lc$get_index ( osnum = osnum, objid = objid,
            p_chanselect = p_chanselect, go_objid = go_objid,
            go_osnum = go_osnum, index = &index);

   /*
    *  Delete the intermediate object so that the connect between
    *  the command and the graphics object is broken.
    */

   om_msg = om$send (
            msg = message Root.delete (FALSE),
            senderid = objid, targetos = osnum,
            p_chanselect = p_chanselect, from = index, to = index);

   return(om_msg);
}

/*\
Name
   lc$delete

Description
   This routine provides the mechanism for commands to delete the
   command ISO object.  This routine should be called if a message
   was sent to delete the graphics object.

   osnum                GRspacenum        The command's osnum
   objid                OM_S_OBJID        The command's objid
   p_chanselect         OM_p_CHANSELECT   The command's channel

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
int LCdelete (osnum, objid, p_chanselect)
GRspacenum        osnum;
OM_S_OBJID        objid;
OM_p_CHANSELECT   p_chanselect;
{
IGRlong           om_msg;

   /*
    *  Delete the intermediate object so that the connect between
    *  the command and the graphics object is broken.
    */

   om_msg = om$send (
            msg = message Root.delete (FALSE),
            senderid = objid, targetos = osnum,
            p_chanselect = p_chanselect);

   return(om_msg);
}

/*\
Name
   lc$get_channel_count

Description
   This routine provides the mechanism for commands to inquire the 
   number of graphics objects on its channel.

   osnum                GRspacenum        The command's osnum
   objid                OM_S_OBJID        The command's objid
   p_chanselect         OM_p_CHANSELECT   The command's channel
   *count               IGRint            The number of graphics objects
                                          on the channel

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
int LCget_channel_count (osnum, objid, p_chanselect, count)
GRspacenum           osnum;
OM_S_OBJID           objid;
OM_p_CHANSELECT      p_chanselect;
IGRint               *count;
{
    IGRboolean		 malloced;
    IGRlong              om_msg;
    IGRint               i;
    unsigned int         temp;
    IGRint		 cmd_count;
    OM_p_OBJECT_LINKAGE  buffer;

    *count = 0;
    om_msg = LCget_buffer(objid,osnum,p_chanselect,&buffer,&cmd_count,
		&malloced);

    for (i=0; i < cmd_count; ++i)
    {
       	om_msg = om$get_channel_count (osnum = buffer[i].osnum,
                     objid = buffer[i].S_objid, 
                     p_chanselect = &lc_to_go_chansel,
                     count = &temp);

         *count = *count + temp;
    }
    if ( malloced)
    {
    	om$dealloc (ptr = buffer);
    }

    return(om_msg);
}


/*\
Name
   lc$get_channel_objects

Description
   This routine provides the mechanism for commands to get the 
   graphics objects on its channel.

   osnum                GRspacenum           The command's osnum
   objid                OM_S_OBJID           The command's objid
   p_chanselect         OM_p_CHANSELECT      The command's channel
   list[]               OM_S_OBJECT_LINKAGE  An array of object linkages
   size                 IGRint               The number of elements in the
                                             list.
   *count               IGRint               The number of graphics objects
                                             on the channel

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/

int LCget_channel_objects (osnum, objid, p_chanselect, list, size, count)
GRspacenum           osnum;
OM_S_OBJID           objid;
OM_p_CHANSELECT      p_chanselect;
OM_S_OBJECT_LINKAGE  list[];
IGRint               size;
IGRint               *count;
{
    IGRlong              om_msg;
    IGRint               i;
    unsigned int         temp;
    IGRint		 cmd_count;
    OM_p_OBJECT_LINKAGE  buffer;
    IGRboolean		 malloced;

    *count = 0;
    om_msg = LCget_buffer(objid,osnum,p_chanselect,&buffer,&cmd_count,
		&malloced);

    if ( 1 & om_msg)
    {
         for (i=0; (i < cmd_count) && (size - *count > 0); ++i)
         {
               om_msg = om$get_channel_objects (osnum = buffer[i].osnum,
                        objid = buffer[i].S_objid,
                        p_chanselect = &lc_to_go_chansel,
                        list = &list[*count],
                        size = size - *count,
                        count = &temp);

               *count = *count + temp;
         }
    }
    if ( malloced)
    {
    	om$dealloc (ptr = buffer);
    }

    return(om_msg);
}


/*\
Name
   lc$is_objid_on_channel

Description
   This routine checks if a fiven objid is on the specified channel.

   osnum                GRspacenum           The command's osnum
   objid                OM_S_OBJID           The command's objid
   p_chanselect         OM_p_CHANSELECT      The command's channel
   go_objid             OM_S_OBJID           The graphics object id
   go_osnum             GRspacenum           The graphics object osnum

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
int LCis_objid_on_channel (osnum, objid, p_chanselect, go_objid, go_osnum)
GRspacenum           osnum;
OM_S_OBJID           objid;
OM_p_CHANSELECT      p_chanselect;
OM_S_OBJID           go_objid;
GRspacenum           go_osnum;
{
    IGRboolean		 malloced;
    IGRlong              om_msg;
    IGRint               i;
    IGRint		 cmd_count;
    OM_p_OBJECT_LINKAGE  buffer;

    om_msg = LCget_buffer(objid,osnum,p_chanselect,&buffer,&cmd_count,
		&malloced);

    if (1 & om_msg)
    {
    	om_msg = OM_W_NOTONCHAN;

	for (i=0; i < cmd_count; ++i)
    	{
 	    om_msg = om$is_objid_on_channel (osnum_c = buffer[i].osnum,
                     objid_c = buffer[i].S_objid,
                     p_chanselect = &lc_to_go_chansel,
                     objid = go_objid, osnum2 = go_osnum);
                   
  	    if (om_msg & 1) break;
        }
    }
    if ( malloced)
    {
    	om$dealloc (ptr = buffer);
    }

    return(om_msg);
}

/*\
Name
   lc$get_objid_at_index

Description
   This routine returns the objid and osnum of the object at the
   specified index in an ordered channel.

   osnum                GRspacenum           The command's osnum
   objid                OM_S_OBJID           The command's objid
   p_chanselect         OM_p_CHANSELECT      The command's channel
   index                IGRint               The command's index
   *go_objid            OM_S_OBJID           The graphics object id
   *go_osnum            GRspacenum           The graphics object osnum

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/
IGRint LCget_objid_at_index(osnum, objid, p_chanselect, index, go_objid,
                            go_osnum)
GRspacenum           osnum;
OM_S_OBJID           objid;
OM_p_CHANSELECT      p_chanselect;
IGRint               index;
OM_S_OBJID           *go_objid;
GRspacenum           *go_osnum;
{
IGRlong              om_msg;
unsigned int         count;
OM_S_OBJECT_LINKAGE  lc_list;
struct GRid          lc_objid;

if (! chan_inited)
{
   lc_to_go_chansel.type = OM_e_name;
   lc_to_go_chansel.u_sel.name = "GRcmpowner.to_components";
   chan_inited=1;
}

   /*
    *  Get the intermediate object at the index.
    */

   om_msg = om$get_objid_at_index (osnum = osnum, objid = objid,
            p_chanselect = p_chanselect, index = index,
            objidaddr = &lc_objid.objid, osnumaddr = &lc_objid.osnum);

   if (om_msg & 1)
   {
      om_msg = om$get_channel_objects (osnum = lc_objid.osnum, 
               objid = lc_objid.objid, p_chanselect = &lc_to_go_chansel,
               list = &lc_list, size = 1, count = &count);

      *go_objid = lc_list.S_objid;
      *go_osnum = lc_list.osnum;
   }
   return (om_msg);
}

/*\
Name
   lc$get_index

Description
   This routine returns the relative or absolute index of a go_objid
   and go_osnum on a channel.

   osnum                GRspacenum           The command's osnum
   objid                OM_S_OBJID           The command's objid
   p_chanselect         OM_p_CHANSELECT      The command's channel
   go_objid             OM_S_OBJID           The graphics object id
   go_osnum             GRspacenum           The graphics object osnum
   *index               IGRint               The command's index at which
                                             the grpahics object resides

Return Values
   OM_S_SUCCESS
   OM_E_ABORT
\*/

IGRint LCget_index(osnum, objid, p_chanselect, go_objid, go_osnum, index)
GRspacenum           osnum;
OM_S_OBJID           objid;
OM_p_CHANSELECT      p_chanselect;
OM_S_OBJID           go_objid;
GRspacenum           go_osnum;
IGRint               *index;
{
    IGRboolean		 malloced;
    IGRlong              om_msg;
    IGRint               i;
    IGRint		 cmd_count;
    OM_p_OBJECT_LINKAGE  buffer;

   *index = 0;
    om_msg = LCget_buffer(objid,osnum,p_chanselect,&buffer,&cmd_count,
		&malloced);

    for (i=0; i < cmd_count; ++i)
    {
        om_msg = om$is_objid_on_channel (osnum_c = buffer[i].osnum,
                     objid_c = buffer[i].S_objid,
                     p_chanselect = &lc_to_go_chansel,
                     objid = go_objid, osnum2 = go_osnum);
                   
        if (om_msg & 1)
        {
           *index = i;
            break;
        }
    }
    if ( malloced)
    {
    	om$dealloc (ptr = buffer);
    }
 
    return(om_msg);
}

IGRint LCget_buffer(objid,osnum,p_chanselect,buffer,cmd_count,malloced)

GRobjid	objid;
GRspacenum osnum;
OM_p_CHANSELECT p_chanselect;
OM_S_OBJECT_LINKAGE **buffer;
unsigned int	*cmd_count;
IGRboolean *malloced;

{
    IGRint om_msg;

    *malloced = FALSE;
    if (! chan_inited)
    {
   	lc_to_go_chansel.type = OM_e_name;
   	lc_to_go_chansel.u_sel.name = "GRcmpowner.to_components";
   	chan_inited=1;
    }

    /* 
     *  Get the number of intermediate locate objects on the commands
     *  channel.
     */

    om_msg = om$get_channel_count (osnum = osnum, objid = objid, 
            p_chanselect = p_chanselect, count = cmd_count);

    if ((om_msg & 1) && (*cmd_count))
    {
        if (*cmd_count > 50)
        {
            /*
             *  Malloc memory for the objects and get them from the 
       	     *  commands channel.
       	     */

            if (*buffer = (OM_p_OBJECT_LINKAGE)
               om$malloc (size = sizeof(OM_S_OBJECT_LINKAGE) * *cmd_count))
	    {
		*malloced =  TRUE;
	    }	    
        }
        else
        {
	    *buffer = static_buffer;
        }

        /*
         *  Loop for each intermediate object and accumulate
         *  the total number of graphics objects.
         */

        if ( *buffer)
        {
	    unsigned int total_count;

            om_msg = om$get_channel_objects (osnum = osnum,
                  objid = objid, p_chanselect = p_chanselect, 
                  list = *buffer, size = *cmd_count, count = &total_count);
        }
    }

    return(om_msg);
}
end implementation Root;
