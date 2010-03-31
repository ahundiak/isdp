class implementation SKvalvar;

method SKgetvar (IGRlong *msg; IGRushort options;
                 IGRshort *matrix_type; IGRmatrix matrix;
                 IGRdouble *var)
{
  *msg = EMS_S_Success;
  *var = ME.expression->value;
  return (OM_S_SUCCESS);
}

end implementation SKvalvar;
