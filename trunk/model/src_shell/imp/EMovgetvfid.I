/* ###################   APOGEE COMPILED   ################## */
class implementation EMSshovflow;

method EMgetvfuncident (IGRlong *msg; IGRint *vfunc_ident)
{
  *msg = EMS_S_Success;

  *vfunc_ident = ME.EMSshovflow->vfunc_identifier;
 
  return (OM_S_SUCCESS);
}

end implementation EMSshovflow;

