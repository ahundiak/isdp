class implementation STc;
#define	OM45	1

method init (int size)
{
  int           sts = OM_S_SUCCESS;

#ifdef	OM45
  if (ST_f_debug)
  {
    DBME ("init", 'C', &(ME.STc->Varray[0]));
    fverify (OM_Gp_sheapBase);
    pverify (OM_Gp_sheapBase);
  }
#endif

  ME.STgene->size = (size > 0) ? size : (-size);
  if (ME.STgene->size != STCSIZE)
  {
    if (ST_f_verbose) 
      printf ("    <STC vla dimension change in init: %d for %d>\n",
                              size, STCSIZE);
    sts = om$vla_set_dimension (varray=ME.STc->Varray, 
                                  size = (ME.STgene->size));
    if (1&sts) ME.STgene->size = size;
  }
#ifdef	OM45
  if (ST_f_debug)
  {
    fverify (OM_Gp_sheapBase);
    pverify (OM_Gp_sheapBase);
  }
#endif

  return (sts);
};

method doit (int varyAmount)
{
  int           newSize, sts = OM_S_SUCCESS;

#ifdef	OM45
  if (ST_f_debug)
  {
    DBME ("doit", 'C', &(ME.STc->Varray[0]));
    fverify (OM_Gp_sheapBase);
    pverify (OM_Gp_sheapBase);
    chkBlkAdr (me, OM_Gp_sheapBase);
    chkBlkAdr (&(ME.STc->Varray[0]), OM_Gp_sheapBase);
  }
#endif

  newSize = ME.STgene->size + varyAmount;
  if (newSize < 0) 
  {
    newSize = 0;
    varyAmount = -(ME.STgene->size);
  }
  ME.STgene->size = newSize;
  if (varyAmount < 0) ST_Gi_netNeg += varyAmount;
  if (varyAmount > 0) ST_Gi_netPos += varyAmount;

  if (varyAmount) 
  {
    if (ST_f_verbose && !newSize) 
      printf ("   * oid: %d vla is GOING TO ZERO\n", my_id);
    sts = om$vla_set_dimension (varray=ME.STc->Varray, size = newSize);
    if (1&sts) ME.STgene->size = newSize;
  }
#ifdef	OM45
  if (ST_f_debug)
  {
    DBME ("doit", 'C', &(ME.STc->Varray[0]));
    fverify (OM_Gp_sheapBase);
    pverify (OM_Gp_sheapBase);
    chkBlkAdr (me, OM_Gp_sheapBase);
    chkBlkAdr (&(ME.STc->Varray[0]), OM_Gp_sheapBase);
  }
#endif

  return (sts);
}

end implementation STc;

