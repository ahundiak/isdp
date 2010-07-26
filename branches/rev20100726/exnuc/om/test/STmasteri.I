class implementation STmaster;

#define	OM45	1

#include  <stdio.h>
#include  <sys/param.h>
%safe
#include  <sys/types.h>
#include  <sys/times.h>
%endsafe

#include  "OMmacros.h"

#ifdef	OM45
#include  "OMCCCP.h"
#endif

extern	int times();
struct  tms tbuffer;

from  OMNamObjDir       import  add_name, translate;
from  STgene            import  init, doit, measure;
method control ()
{
  OMuword         osnum;
  int             sts, sts2, loadMode = NULL;
  OM_S_OBJID      osoid, nodoid, SToid;
  int             ii, jj;
  double          fHZ, ftime;
  
 
  fHZ = HZ;
#ifdef OM45
  if (ST_f_debug)
  {
    printf ("print initial memmap\n");
    memmap (OM_Gp_sheapBase);
  }
#endif

#ifdef OM45
  if (ST_f_noMod) loadMode |= OM_e_loados_nm;;
#endif

  if (ST_f_readOnly) loadMode |= OM_e_loados_ro;
  printf ("create fresh/stale os %s\n", ST_osname);
  if (!(1&(sts2 = om$construct_os (osname = ST_osname, osnum = &osnum,
                                   p_objid = &osoid, classname = ST_osclass,
                                   loadmode = loadMode))))
  {
    printf ("error creating os\n");
    return (sts2);
  }
  printf ("create/retrieve NOD\n");
  if (!(1&(sts = om$make_NOD (name = "STNOD", osnum = osnum, 
                              p_objid = &nodoid))))
  {
    printf ("error creating/retrieving NOD\n");
    if (!(1&sts2))
    {
      printf ("what kind of os?\n");
      om$report_error (sts = sts2);
    }
    return (sts);
  }

  if (sts2 != OM_I_READ_FROM_FILE)
  {
    printf ("create STmaster in fresh os\n");
    if (!(1&(sts = om$construct (classname = "STmaster", osnum = osnum,
                                 p_objid = &SToid))))
    {
      printf ("error constructing STmaster object\n");
      return (sts);
    }
    printf ("name the new guy\n");
    if (!(1&(sts = om$send (targetid = nodoid, targetos = osnum,
                            msg = message 
                              OMNamObjDir.add_name ("STmaster", SToid)))))
    {
      printf ("error naming STmaster object\n");
      return (sts);
    }
  }
  else
  {
    printf ("retrieve oid of stale STmaster\n");
    if (!(1&(sts = om$send (targetid = nodoid, targetos = osnum,
                            msg = message 
                              OMNamObjDir.translate("STmaster", &SToid)))))
    {
      printf ("error getting oid of STmaster object\n");
      return (sts);
    }
  }

#ifdef	OM45
  if (ST_f_debug)
  {
    printf ("memmap prior to go:\n");
    memmap (OM_Gp_sheapBase);
  }
#endif

  printf ("send a go to this guy: oid=%d, osnum=%d\n", SToid, osnum);
  if (!(1&(sts = om$send (targetid = SToid, targetos = osnum,
                          msg = message STmaster.go ()))))
  {
    printf ("error in go transmission\n");
    return (sts);
  }
  printf ("delete os\n");
  sts = om$send (targetid = osoid, targetos = osnum,
                          msg = message Root.delete (1));

#ifdef	OM45
  if (!(loadMode) && (1&sts) && ST_f_showWrStats)
  {
  printf ("\n++ Additional INswap Stats due to write of OS++\n\n");
  printf ("  ~ Total number of inswaps:           %6d     (%6d Npagd, %6d pagd)\n",
    (ii = OM_Gi_numInswaps + OM_Gi_PnumInswaps), OM_Gi_numInswaps,
    OM_Gi_PnumInswaps);
  printf ("  ~ Total bytes inswapped:             %6d     (%6d Npagd, %6d pagd)\n",
    (jj = OM_Gi_inswapBytes + OM_Gi_PinswapBytes), OM_Gi_inswapBytes,
    OM_Gi_PinswapBytes);
  ftime = (OM_Gi_inswapTicks + OM_Gi_PinswapTicks) / fHZ;
  printf ("  ~ Total time inswapping:              %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? ii/ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? jj/ftime : 0.0);
  ftime = OM_Gi_inswapTicks/fHZ;
  printf ("      NonPaged Inswapping:              %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? OM_Gi_numInswaps / ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? OM_Gi_inswapBytes/ ftime : 0.0);
  ftime = OM_Gi_PinswapTicks/fHZ; 
  printf ("      Paged Inswapping:                 %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? OM_Gi_PnumInswaps / ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? OM_Gi_PinswapBytes/ ftime : 0.0);
  }
#endif

  if (!(1&sts)) printf ("error in delete msg\n");
  return (sts);
}

#define GETHWLOCK if (OM_Gp_CCB->slotUsage > HWlocked) HWlocked = OM_Gp_CCB->slotUsage
#define GETHWSYSLOCK if (OM_Gp_CCCP->numLockedSlots > HWsysLocked) HWsysLocked = OM_Gp_CCCP->numLockedSlots
#define GETHWLOCKS {GETHWLOCK; GETHWSYSLOCK;}

method go ()
{
  int             sts, ii, jj, kk, numObjs, numEmptySlots;
  int             numConstructed =      0;
  int             aaObjs;
  int             numSTA, numSTB, numSTC, numSTD, numMsgs, numObjsToInit;
  int             STsizes[4];
  FILE            *prof;
  int             *seqProf =            0;
  MsgProf         *randomProf;
  double          fHZ, constructTime, seqTime, randomTime, passthruTime;
  double          ftime;
  int             startTime, endTime, *iptr;
  char            *tptr;
  OMuword         classids[4];
  int             beginQuota, endQuota, beginLocked, HWlocked, endLocked;
  int             begSysLocked, HWsysLocked, endSysLocked;

#ifdef	OM45  
  HWsysLocked = begSysLocked = OM_Gp_CCCP->numLockedSlots;
  beginQuota = OM_Gp_CCB->slotQuota;
  HWlocked = beginLocked = OM_Gp_CCB->slotUsage;
#endif

  printf ("STmaster.go: load profile %s & get cranked up\n", ST_profile);
  fHZ = HZ;
  om$get_classid (classname = "STa", p_classid = &classids[STAIDX]);
  om$get_classid (classname = "STb", p_classid = &classids[STBIDX]);
  om$get_classid (classname = "STc", p_classid = &classids[STCIDX]);
  om$get_classid (classname = "STd", p_classid = &classids[STDIDX]);
  
  if (NULL == (prof = fopen (ST_profile, "r")))
  {
    perror ("Error opening profile");
    return (OM_E_ERROR);
  }
  fread (&numSTA, sizeof (int), 1, prof);
  fread (&numSTB, sizeof (int), 1, prof);
  fread (&numSTC, sizeof (int), 1, prof);
  fread (&numSTD, sizeof (int), 1, prof);
  fread (&numObjsToInit, sizeof (int), 1, prof);
  fread (&(STsizes[STAIDX]), sizeof (int), 1, prof);
  fread (&(STsizes[STBIDX]), sizeof (int), 1, prof);
  fread (&(STsizes[STCIDX]), sizeof (int), 1, prof);
  fread (&(STsizes[STDIDX]), sizeof (int), 1, prof);
  fread (&numMsgs, sizeof (int), 1, prof);
  numObjs = numSTA + numSTB + numSTC + numSTD;
  aaObjs = OM_DIMENSION_OF (ME.STmaster->objects);
  if (ST_f_Verbose)
  {
    printf 
      ("*~ numSTA: %5d; numSTB: %5d; numSTC: %5d; numSTD: %5d; numObjs: %5d\n",
      numSTA, numSTB, numSTC, numSTD, numObjs);
    printf
      ("*~ sizSTA: %5d; sixSTB: %5d; sizSTC: %5d; sizSTD: %5d\n",
      STsizes[STAIDX], STsizes[STBIDX], STsizes[STCIDX], STsizes[STDIDX]);
    printf ("*~ numObjsToInit: %5d; numMsgs: %5d; oldNumObjs: %5d\n",
      numObjsToInit, numMsgs, aaObjs);
  }
  
  OM_SET_DIMENSION (ME.STmaster->objects, aaObjs+numObjs);
  OM_SET_DIMENSION (ME.STmaster->names, aaObjs+numObjs);

  if (numObjs != fread (&(ME.STmaster->names[aaObjs]), 1, numObjs, prof))
  {
    perror ("error reading class array (construction profile)\n");
    return (OM_E_ERROR);
  }
  if (ST_f_Verbose)
  {
    printf ("*~ construction sequence looks like:\n");
    for (ii=0; ii<numObjs; ii+=30)
    {
      for (jj=ii; jj<(ii+30) && jj<numObjs; jj++) 
      printf (" %c", ME.STmaster->names[aaObjs+jj]);
      printf ("\n");
    }
  }      

  if (numObjsToInit)
  {
    seqProf = om$malloc (size = sizeof (int) * numObjsToInit);
    if (numObjsToInit != fread (seqProf, sizeof (int), numObjsToInit, prof))
    {
      perror ("error reading sequential msg profile");
      return (OM_E_ERROR);
    }
    if (ST_f_Verbose)
    {
      printf ("*~ %d Sequential messages:\n", numObjsToInit);
      for (ii=0; ii<numObjsToInit; ii+=10)
      {
        for (jj=ii; jj<(ii+10) && jj<numObjsToInit; jj++) 
          printf ("  %6d", seqProf[jj]);
        printf ("\n");
      }
    }
  }
  
  randomProf = om$malloc (size = sizeof (MsgProf) * numMsgs);
  if (numMsgs != fread (randomProf, sizeof (MsgProf), numMsgs, prof))
  {
    perror ("error reading random msg profile");
    return (OM_E_ERROR);
  }
  if (!ST_f_doRandom) om$dealloc (ptr = randomProf);
  if (ST_f_Verbose && ST_f_doRandom)
  {
    printf ("*~ %d random msgs\n", numMsgs);
    for (ii = 0; ii<numMsgs; ii+=22)
    {
      for (jj = ii; jj<(ii+22) && jj<numMsgs; jj++) 
      {
        printf (" msg #%5d: ", jj);
        switch (randomProf[jj].cmd)
        {
        case DOIT:
          printf ("DOIT (objIdx: %5d, varyAmt: %6d)\n", 
            randomProf[jj].u1.m.objIdx, randomProf[jj].u1.m.varyAmt);
          break;
        case CONSTRUCT:
          printf ("CONS (class: %c)\n", randomProf[jj].u1.cls);
          break;
        case DELETE:
          printf ("DELE (objIdx: %5d)\n", randomProf[jj].u1.m.objIdx);
          break;
        default:
          printf ("UNKN (cmd = %d; ascii: \\", randomProf[jj].cmd);
          tptr = (char*) &randomProf[jj];
          for (kk = 0; kk<sizeof(MsgProf); kk++) printf ("%c", tptr[kk]);
          printf ("\\; int: ");
          iptr = (int*) &randomProf[jj];
          for (kk=0;  kk<sizeof(MsgProf)/4; kk++) printf (" %6d", iptr[kk]);
          printf (")\n");
        }
      }
    }
  }

  for (ii=0; ii<numObjs; ii++) ME.STmaster->objects[aaObjs+ii] = NULL_OBJID;
  if (numObjsToInit)
  {
    printf ("  + Begin construction phase. construct %d objects\n", 
      numObjsToInit);
    startTime = times (&tbuffer);
    for (numConstructed = 0; numConstructed < numObjsToInit; numConstructed++)
    {
      if (ST_f_verbose)
        printf ("   ~ construct %4dth obj (ST%c). Size: %5d\n", numConstructed,
          ME.STmaster->names[aaObjs+numConstructed],
          STsizes[ME.STmaster->names[aaObjs+numConstructed]-'A']);
          
      if (!(1&(sts = om$construct 
                     (classid = classids
                     [ME.STmaster->names[aaObjs+numConstructed]-'A'],
                      p_objid = &ME.STmaster->objects[aaObjs+numConstructed],
                      msg = message STgene.init 
                    (STsizes[ME.STmaster->names[aaObjs+numConstructed]-'A'])))))
      {
        printf ("error in construction of %dth object (ST%c; size: %5d)\n", 
          ME.STmaster->names[aaObjs+numConstructed], 
          STsizes[ME.STmaster->names[aaObjs+numConstructed]-'A']);
        om$report_error (sts = sts);
        break;
      }
#ifdef	OM45
      GETHWLOCKS;
#endif
    } /* for loop of construction */

    endTime = times (&tbuffer);
    constructTime = (endTime - startTime) / fHZ;
    printf ("  + construct took:            %4.3f seconds\n", constructTime);

#ifdef	OM45
    if (ST_f_debug)
    {
      printf ("  [DB] memmap prior after constructs:\n");
      memmap (OM_Gp_sheapBase);
    }
#endif

    printf ("  + Begin sequential messaging (%d msgs)\n", numMsgs);
    kk = 0;
    startTime = times (&tbuffer);
    for (ii=0; ii<numMsgs; ii++)
    {
      if (ST_f_verbose)
        printf ("   ~ transmit %4dth msg (ST%c). VaryAmt: %5d\n", ii,
          ME.STmaster->names[aaObjs+kk], seqProf[kk]);
          
      if (!(1&(sts = om$send (targetid = ME.STmaster->objects[aaObjs + kk],
                              msg = message STgene.doit (seqProf[kk])))))
      {
        printf ("error on msg #%5d (index: %5d, ST%c, varyAmt: %5d)\n",
          ii, kk, ME.STmaster->names[aaObjs+kk], seqProf[kk]);
        om$report_error (sts = sts);
        break;
      }
      if (++kk >= numObjsToInit) kk = 0;

#ifdef	OM45
      GETHWLOCKS;
#endif

    }
    endTime = times (&tbuffer);
    seqTime = (endTime - startTime) / fHZ;
    printf ("  + Sequential messaging took: %4.3f seconds\n", seqTime);

#ifdef	OM45
    if (ST_f_debug)
    {
      printf ("  [DB] memmap prior after sequential messages:\n");
      memmap (OM_Gp_sheapBase);
    }
#endif
  }

  if (ST_f_doRandom)
  {
    printf ("  + Begin random messaging     (%d msgs)\n", numMsgs);
    startTime = times (&tbuffer);
    for (ii=0; ii<numMsgs; ii++)
    {
      if (ST_f_verbose) printf ("   ~ transmit %4dth msg ", ii);
      switch (randomProf[ii].cmd)
      {
      case DOIT:
        if (ST_f_verbose) printf ("(DOIT). idx: %5d; oid: %5d; ",
          randomProf[ii].u1.m.objIdx,
          ME.STmaster->objects [aaObjs + randomProf[ii].u1.m.objIdx]);
        if (IF_NULL_OBJID 
          (ME.STmaster->objects [aaObjs + randomProf[ii].u1.m.objIdx]))
        {
          if (ST_f_verbose) printf ("(NULLOBJID! skip)\n");
          break;
        }
        if (ST_f_verbose) printf ("varyAmt: %5d; ST%c\n", 
          randomProf[ii].u1.m.varyAmt,
          ME.STmaster->names[aaObjs+randomProf[ii].u1.m.objIdx]);
        if (!(1&(sts = om$send (targetid = 
                     ME.STmaster->objects[aaObjs + randomProf[ii].u1.m.objIdx],
                     msg = message STgene.doit
  			(randomProf[ii].u1.m.varyAmt)))))
        {
          printf ("error on msg #%5d: DOIT (index: %5d, ST%c, varyAmt: %5d)\n",
            ii, randomProf[ii].u1.m.objIdx, 
            ME.STmaster->names[aaObjs+randomProf[ii].u1.m.objIdx],
            randomProf[ii].u1.m.varyAmt);
          om$report_error (sts = sts);
        }
        break;
  
      case CONSTRUCT:
        if (ST_f_verbose) printf ("(CONS). cls:   ST%c; siz: %5d\n", 
          randomProf[ii].u1.cls, STsizes[randomProf[ii].u1.cls-'A']);
        if (!(1&(sts = om$construct 
                       (classid = classids[randomProf[ii].u1.cls - 'A'],
                        p_objid = &ME.STmaster->objects[aaObjs+numConstructed],
                        msg = message STgene.init 
                      (STsizes[randomProf[ii].u1.cls-'A'])))))
        {
          printf ("error on msg #%5d: CONS (ST%c, size: %5d)\n", 
            ii, randomProf[ii].u1.cls, 
            STsizes[randomProf[ii].u1.cls-'A']);
          om$report_error (sts = sts);
          break;
        }
        numConstructed++;
        break;
  
      case DELETE:
        if (ST_f_verbose) printf ("(DELE). idx: %5d; oid: %5d; ",
          randomProf[ii].u1.m.objIdx,
          ME.STmaster->objects [aaObjs + randomProf[ii].u1.m.objIdx]);
        if (IF_NULL_OBJID 
          (ME.STmaster->objects [aaObjs + randomProf[ii].u1.m.objIdx]))
        {
          if (ST_f_verbose) printf ("(NULLOBJID! skip)\n");
          break;
        }
        if (ST_f_verbose) printf ("ST%c\n", 
          ME.STmaster->names[aaObjs+randomProf[ii].u1.m.objIdx]);
        if (!(1&(sts = om$send (targetid = 
                       ME.STmaster->objects[aaObjs + randomProf[ii].u1.m.objIdx],
                       msg = message Root.delete(1)))))
        {
          printf ("error on msg #%5d: DELE (index: %5d, ST%c)\n",
            ii, randomProf[ii].u1.m.objIdx, 
            ME.STmaster->names[aaObjs+randomProf[ii].u1.m.objIdx]);
          om$report_error (sts = sts);
        }
        ME.STmaster->objects[aaObjs + randomProf[ii].u1.m.objIdx] = NULL_OBJID;
        ME.STmaster->names[aaObjs + randomProf[ii].u1.m.objIdx] = 'n';
        break;
      }

#ifdef	OM45
      GETHWLOCKS;
#endif
  
    }

    endTime = times (&tbuffer);
    randomTime = (endTime - startTime) / fHZ;
    printf ("  + random messaging took:     %4.3f seconds\n", randomTime);

#ifdef	OM45
    if (ST_f_debug)
    {
      printf ("  [DB] memmap prior after random msgs:\n");
      memmap (OM_Gp_sheapBase);
    }
#endif

  }
  printf ("  + Begin passThru all extant objects (%d objects, varyAmt: %d)\n",
    aaObjs+numObjs, ST_i_varyAmt);
  numEmptySlots = 0;
  startTime = times (&tbuffer);
  for (ii = 0; ii<(aaObjs+numObjs); ii++)
  {
    if (ST_f_verbose) printf ("   ~ transmit %4dth msg. oid: ", ii);
    if (IF_NULL_OBJID (ME.STmaster->objects [ii])) 
    {
      if (ST_f_verbose) printf ("(NULLOBJID! skip)\n");
      numEmptySlots++;
      continue;
    }
    if (ST_f_verbose) printf ("%5d\n", ME.STmaster->objects[ii]);
    if (!1&(sts = om$send (targetid = ME.STmaster->objects[ii],
                           msg = message STgene.doit (ST_i_varyAmt))))
    {
      printf ("error on msg #%5d (ST%c, varyAmt: %5d)\n",
          ii, ME.STmaster->names[ii], ST_i_varyAmt);
      om$report_error (sts = sts);
    }

#ifdef	OM45
    GETHWLOCKS;
#endif

  }
  endTime = times (&tbuffer);
  passthruTime = (endTime - startTime) / fHZ;
  printf ("  + passthru messaging took:   %4.3f seconds ", passthruTime);
  printf ("    (encountered %d empty slots)\n", numEmptySlots);

#ifdef	OM45
  if (ST_f_debug)
  {
    printf ("  [DB] memmap prior after passthru msgs:\n");
    memmap (OM_Gp_sheapBase);
  }
#endif

  if (ST_f_measureMsg)
  {
    if (!(ii = OM_DIMENSION_OF (ME.STmaster->objects)))
      printf ("** cannot measure messages; NO objects\n");
    else
    {
      printf ("  + Begin message measurement\n");
      kk = 0;
      for (jj=0; jj<ii; jj++)
      {
        if (IF_NULL_OBJID (ME.STmaster->objects [jj])) continue;
        startTime = times (&tbuffer);
        for (; kk<100000; kk++) om$send (targetid = 
                              	       ME.STmaster->objects[jj],
                                       msg = message STgene.measure());
        endTime = times (&tbuffer);
        ftime = (endTime - startTime) / fHZ;
        printf 
        ("  + 100000 measure messages took: %3.3f seconds (%1.6f sec/msg)\n",
        ftime, ftime/100000.0);

        startTime = times (&tbuffer);
        for (kk=0; kk<100000; kk++) om$send (targetid = 
                              	       ME.STmaster->objects[jj],
                                       msg = message STgene.doit(0));
        endTime = times (&tbuffer);
        ftime = (endTime - startTime) / fHZ;
        printf 
        ("  + 100000 doit(0) messages took: %3.3f seconds (%1.6f sec/msg)\n",
        ftime, ftime/100000.0);
        break;
      }
      if (!kk) printf ("** cannot measure messages; NO objects\n");
    }
  }

  if (seqProf) om$dealloc (ptr = seqProf);
  if (ST_f_doRandom) om$dealloc (ptr = randomProf);


#ifdef	OM45
  endQuota = OM_Gp_CCB->slotQuota;
  endLocked = OM_Gp_CCB->slotUsage;
  endSysLocked = OM_Gp_CCCP->numLockedSlots;
#endif

  printf ("\n++ Summary ++\n\n");

#ifdef	OM45
  printf ("  ~ Locking is %s.\n", (OM_Gf_lockingOff) ? "OFF" : "ON");
#endif

  printf ("  ~ Total Positive Variation:          %6d\n", ST_Gi_netPos);
  printf ("  ~ Total Negative Variation:          %6d\n", ST_Gi_netNeg);
  printf ("  ~ Construction of %5d objects took: %4.3f sec (%5.1f obj/sec)\n",
    numObjsToInit, constructTime, 
    (constructTime) ? (numObjsToInit/constructTime) : 0.0);
  printf ("  ~ %5d sequential messages took:     %4.3f sec (%5.1f msg/sec)\n",
    numMsgs, seqTime, (seqTime) ? (numMsgs/seqTime) : 0.0);

  if (ST_f_doRandom)
  printf ("  ~ %5d random messages took:         %4.3f sec (%5.1f msg/sec)\n",
    numMsgs, randomTime, (randomTime) ? (numMsgs/randomTime) : 0.0);

  printf ("  ~ %5d passthru messages took:       %4.3f sec (%5.1f msg/sec)\n",
    (aaObjs+numObjs), passthruTime, 
    (passthruTime) ? ((aaObjs+numObjs)/passthruTime) : 0.0);

#ifdef	OM45
  printf ("\n++ Lock Stats ++\n\n");
  printf ("  ~ quota at start:                    %6d slots\n", beginQuota);
  printf ("  ~ quota at end:                      %6d slots\n", endQuota);
  printf ("  ~ process slots locked (start):      %6d slots\n", beginLocked);
  printf ("  ~ process slots locked (end):        %6d slots\n", endLocked);
  printf ("  ~ process highwater mark:            %6d slots\n", HWlocked);
  printf ("  ~ system slots locked (start):       %6d slots\n", begSysLocked);
  printf ("  ~ system slots locked (end):         %6d slots\n", endSysLocked);
  printf ("  ~ system highwater mark:             %6d slots\n", HWsysLocked);
  
  printf ("\n++ Paging Stats ++\n\n");
  printf ("  ~ Total number of swaps:             %6d\n",
    (ii = OM_Gi_numOutswaps + OM_Gi_numInswaps +
          OM_Gi_PnumOutswaps + OM_Gi_PnumInswaps));
  printf ("  ~ Total number of bytes swapped:     %6d\n",
    (jj = OM_Gi_outswapBytes + OM_Gi_inswapBytes +
          OM_Gi_PoutswapBytes + OM_Gi_PinswapBytes));

  ftime = (OM_Gi_outswapTicks + OM_Gi_inswapTicks + 
              OM_Gi_PoutswapTicks + OM_Gi_PinswapTicks) / fHZ;
  printf ("  ~ Total time swapping:                %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? ii/ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? jj/ftime : 0.0);

  printf ("\n");
  printf ("  ~ Total number of outswaps:          %6d     (%6d Npagd, %6d pagd)\n",
    (ii = OM_Gi_numOutswaps + OM_Gi_PnumOutswaps), OM_Gi_numOutswaps,
    OM_Gi_PnumOutswaps);
  printf ("  ~ Total bytes outswapped:            %6d     (%6d Npagd, %6d pagd)\n",
    (jj = OM_Gi_outswapBytes + OM_Gi_PoutswapBytes), OM_Gi_outswapBytes,
    OM_Gi_PoutswapBytes);
  ftime = (OM_Gi_outswapTicks + OM_Gi_PoutswapTicks) / fHZ;
  printf ("  ~ Total time outswapping:             %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? ii/ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime) ? jj/ftime : 0.0);
  ftime = OM_Gi_outswapTicks/fHZ;
  printf ("      NonPaged Outswapping:             %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? OM_Gi_numOutswaps / ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? OM_Gi_outswapBytes/ ftime : 0.0);
  ftime = OM_Gi_PoutswapTicks/fHZ;
  printf ("      Paged Outswapping:                %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? OM_Gi_PnumOutswaps / ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? OM_Gi_PoutswapBytes/ ftime : 0.0);

  printf ("\n");
  printf ("  ~ Total number of inswaps:           %6d     (%6d Npagd, %6d pagd)\n",
    (ii = OM_Gi_numInswaps + OM_Gi_PnumInswaps), OM_Gi_numInswaps,
    OM_Gi_PnumInswaps);
  printf ("  ~ Total bytes inswapped:             %6d     (%6d Npagd, %6d pagd)\n",
    (jj = OM_Gi_inswapBytes + OM_Gi_PinswapBytes), OM_Gi_inswapBytes,
    OM_Gi_PinswapBytes);
  ftime = (OM_Gi_inswapTicks + OM_Gi_PinswapTicks) / fHZ;
  printf ("  ~ Total time inswapping:              %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? ii/ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? jj/ftime : 0.0);
  ftime = OM_Gi_inswapTicks/fHZ;
  printf ("      NonPaged Inswapping:              %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? OM_Gi_numInswaps / ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? OM_Gi_inswapBytes/ ftime : 0.0);
  ftime = OM_Gi_PinswapTicks/fHZ;
  printf ("      Paged Inswapping:                 %4.3f sec (%5.1f swp/sec)\n",
    ftime, (ftime != 0.0) ? OM_Gi_PnumInswaps / ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
    (ftime != 0.0) ? OM_Gi_PinswapBytes/ ftime : 0.0);

  printf ("\n++ InFault Stats ++\n\n");
  printf ("  ~ Total number of inFaults:          %6d\n", OM_Gi_numFaults);
  printf ("  ~ Total bytes faulted in:            %6d\n", OM_Gi_faultinBytes);
  ftime = OM_Gi_faultinTicks/fHZ;
  printf ("  ~ Total time inFaulting:              %4.3f sec (%5.1f flt/sec)\n", 
  ftime, (ftime != 0.0) ? OM_Gi_numFaults/ftime : 0.0);
  printf ("                                                  (%5.1f byt/sec)\n",
  (ftime != 0.0) ? OM_Gi_faultinBytes/ftime : 0.0);
#endif

  return (OM_S_SUCCESS);
}

end implementation STmaster;

