class implementation EMSnatedge;

method EMpostgeom
(
  IGRchar *edgeom
)
{
  IGRuchar *location=NULL;

  ME.EMSedge->ed_props = 0;
  ME.EMSedge->curve_type = 0;

  location = (IGRuchar *) edgeom;
  ME.EMSnatedge->location = *location;
  
  return (OM_S_SUCCESS);
}

end implementation EMSnatedge;

