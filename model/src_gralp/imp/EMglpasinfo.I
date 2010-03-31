/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgraloop;


method EMget_info(IGRlong *EMmsg;
                   IGRushort options;
                   IGRuint *type;
                   IGRuint *info_size;
                   IGRchar **info)
/* ************************************************************************

Description
 We just want to return success at this class since we rejected the instance
 data for EMSassoc.

History
    Jack    9/14/91     Creation

************************************************************************** */
{
 *EMmsg = EMS_S_Success;
 *info_size = 0;

 return (OM_S_SUCCESS);
}

method EMput_info (IGRlong *EMmsg; 
                   IGRushort options;
                   IGRuint type;
                   IGRuint size;
                   IGRchar *info)

{
 *EMmsg = EMS_S_Success;

  return (OM_S_SUCCESS);
}
end implementation EMSgraloop;
