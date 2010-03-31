class implementation NMinters;


method EMput_info  (IGRlong *EMmsg; IGRushort options;
                    unsigned int type; unsigned int info_size;
                     IGRchar *info)
{
 *EMmsg = EMS_I_InvalidSend;
 return(OM_S_SUCCESS);
}


method EMget_info(IGRlong *EMmsg; IGRushort options;
                  unsigned int *type; unsigned int *info_size;
                  IGRchar **info)
{
 *EMmsg = EMS_I_InvalidSend;
 return(OM_S_SUCCESS);
}

end implementation NMinters;
