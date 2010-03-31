class implementation EMShorizon;


method GRgetprops(IGRlong *msg; 
                  IGRshort *props)
/*
Abstract:       
        This method returns to the caller the object's 
        properties word.

Arguments
        *msg      IGRlong       completion code message
        *props    IGRshort      object's properties word

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
