
class specification ASlinear (0:1) of GRlinear,ASbspline;

override GRvg;

/*
 * override GRlinear methods just to send back the
 * message to the graphic object via complex channel
 */

  override  GRaddpts,GRmoveseg,GRsegfind,GRvtadjseg,GRgetpolyline;

end specification ASlinear;
