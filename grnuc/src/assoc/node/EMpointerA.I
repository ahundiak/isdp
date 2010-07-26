class implementation EMSpointerA;

method EMstore_key_from_id(IGRlong *EMmsg;
                           IGRuint options;
                           unsigned char *key)
{
 *EMmsg = 1;
 return (OM_S_SUCCESS);
}

method EMstore_id_from_key(IGRlong *EMmsg;
                           IGRuint options;
                           OM_S_OBJID *objid)
{
 *EMmsg = 1;
 return (OM_S_SUCCESS);
}

method EMstore_id(IGRlong *EMmsg;
                  IGRuint options;
                  OM_S_OBJID store_objid)
{
 *EMmsg = 1;
 return (OM_S_SUCCESS);
}

end implementation EMSpointerA;

