class implementation SKptvar;

#define MIN 0
#define MAX 1

#define X 0
#define Y 1

method SKupdaterange (IGRlong *msg; IGRdouble xyrange[2][2])
{
  IGRdouble *pt;
 
  *msg = EMS_S_Success;
  
  pt = ME.SKptvar->pt;
  if (pt[X] < xyrange[MIN][X])
    xyrange[MIN][X] = pt[X];
  if (pt[Y] < xyrange[MIN][Y])
    xyrange[MIN][Y] = pt[Y];
  if (pt[X] > xyrange[MAX][X])
    xyrange[MAX][X] = pt[X];
  if (pt[Y] > xyrange[MAX][Y])
    xyrange[MAX][Y] = pt[Y];

  return (OM_S_SUCCESS);
}

end implementation SKptvar;
