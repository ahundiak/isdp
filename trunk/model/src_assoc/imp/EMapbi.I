/* ###################   APOGEE COMPILED   ################## */
/*
  DESCRIPTION

   This file contains the overrides (towards the end of the file) and the
   definition of all the messages declared at EMSapb.

  HISTORY

    SS  :  03/16/91  :  Creation
*/

class implementation EMSapb;

method EMgetrunindex (IGRint type; IGRint *index)
{
  IGRint typeinx;

  if (type == EMSdistance || type == EMSscalar || type == EMSangle)
    typeinx = 0;
  else if (type == EMSpoint)
    typeinx = 1;
  else if (type == EMSvector)
    typeinx = 2;
  else if (type == EMSinfplane)
    typeinx = 3;
  else
    typeinx = 4;

  *index = ME.EMSapb->running_index[typeinx]++;

  return (OM_S_SUCCESS);
}


method super_construct ()
{
  IGRint i;

  for (i=0; i<5; i++)
    ME.EMSapb->running_index[i] = 0;

  return (OM_S_SUCCESS);
}


method delete (IGRint defer_flag)
{
  return(OM_S_SUCCESS);
}

end implementation EMSapb;
