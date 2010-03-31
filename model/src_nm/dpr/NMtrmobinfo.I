class implementation NMtrim;

method EMgetstatedesc (IGRlong *EMmsg; IGRchar desc[])
{
 strcpy(desc, "Surface area trim state");
 return(OM_S_SUCCESS);
}

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
 *msg = EMS_S_Success;
 strcpy(info->type, "Surface area trim state");
 return(OM_S_SUCCESS);
}

method EMgetsolidclass(IGRlong *EMmsg; IGRchar *desc)
{
  *EMmsg = EMS_E_InvalidCase;
  return(OM_S_SUCCESS);
}

end implementation NMtrim;


