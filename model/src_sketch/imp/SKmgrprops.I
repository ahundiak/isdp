/* ###################   APOGEE COMPILED   ################## */
class implementation SKmgr;

method SKmgrprops (IGRlong *msg; IGRshort actdef;
                   IGRushort inprops;
                   IGRushort *outprops)
{
  extern void EFtoggle();

  *msg = EMS_S_Success;

  switch (actdef)
    {
    case SK_CHGPROPS_OFF:
      ME.SKmgr->props &= ~inprops;
      break;

    case SK_CHGPROPS_ON:
      ME.SKmgr->props |= inprops;
      break;
    
    case SK_CHGPROPS_TOGGLE:
      EFtoggle (inprops, &ME.SKmgr->props);
      break;

    case SK_CHGPROPS_SET:
      ME.SKmgr->props = inprops;
      break;
    
    case SK_CHGPROPS_GET:
      *outprops = ME.SKmgr->props;
      break;

    default:
      *msg = EMS_E_InvalidArg;
    }

  if (outprops)
    *outprops = ME.SKmgr->props;

  return (OM_S_SUCCESS);
}

end implementation SKmgr;
