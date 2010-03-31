class implementation EMShorizon;

method GRchgprops(IGRlong *msg; 
                  IGRshort *action; 
                  IGRshort *props)
/*
Abstract        
        Given a properties mask (props), this method adjusts 
        the object's properties word by clearing, setting the specified
        bits using the input props, or by the properties word with 
        the indicated mask.  The action taken depends on the 
        action indicated by the input "action" parameter.

Arguments
     *action      IGRshort       indictor of whether to set, clear 
                                 or replace the properties word
                                    1 - set with mask
                                    0 - clear using mask
                                    -1 - replace with input props
     *props       IGRshort       mask used to set, clear or
                                 replace the properties word
     *msg         IGRlong        completion code message

Return Values
        MSSUCC if successful

History
    Jack   11/18/91   Created, just return success.

*/

{
 IGRlong sts;

 *msg = EMS_S_Success;
  sts = OM_S_SUCCESS;

 return (sts);
}

end implementation EMShorizon;
