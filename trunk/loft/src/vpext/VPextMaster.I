
class implementation VDbtBase;

#include "VDtypedef.h"
#include "VDobj.h"
#include "VDchn.h"
#include "VDmem.h"
#include "VDmac.h"
#include "VDgeom.h"

#include "VPpdf.h"
#include "VPpdfAttrs.h"
#include "VPextInfo.h"

#include "bsdistptpt.h"
#include "bststcvcarc.h"

static TVPextMasterInfo info;

/* --------------------------------------------
 * Static file pointers for various trace files
 */
TVPextMasterInfo *VPextGetMasterInfo()
{
  return &info;
}

IGRstar VPextInitMasterInfo()
{
  memset(&info,0,sizeof(info));

  info.file.plates  = fopen("plates.txt", "wt");
  info.file.bevels  = fopen("bevels.txt", "wt");
  info.file.labels  = fopen("labels.txt", "wt");
  info.file.beams   = fopen("beams.txt",  "wt");
  info.file.ets     = fopen("ets.txt",    "wt");
  info.file.holes   = fopen("holes.txt",  "wt");
  info.file.cutouts = fopen("cutouts.txt","wt");

  return 1;
}

IGRstat VPextDeleteMasterInfo() 
{
  if (info.file.data)    fclose(info.file.data);
  if (info.file.plates)  fclose(info.file.plates);
  if (info.file.bevels)  fclose(info.file.bevels);
  if (info.file.labels)  fclose(info.file.labels);
  if (info.file.beams)   fclose(info.file.beams);
  if (info.file.ets)     fclose(info.file.ets);
  if (info.file.holes)   fclose(info.file.ets);
  if (info.file.cutouts) fclose(info.file.cutouts);

  memset(&info,0,sizeof(info));

  return 1;
}

/* -------------------------------------------------
 * Returns file pointers for various trace files
 */
FILE *VPextGetBevelTraceFile()  { return info.file.bevels; }
FILE *VPextGetPlateTraceFile()  { return info.file.plates; }
FILE *VPextGetLabelTraceFile()  { return info.file.labels; }
FILE *VPextGetBeamTraceFile()   { return info.file.beams;  }
FILE *VPextGetEtTraceFile()     { return info.file.ets;    }
FILE *VPextGetHoleTraceFile()   { return info.file.holes;   }
FILE *VPextGetCutoutTraceFile() { return info.file.cutouts; }

/* --------------------------------------------------------
 * Opens and inits spades data file
 */
IGRstat VPextOpenDataFile(IGRchar *fileName)
{
  IGRstat retFlag = 0;
  
  FILE *file;
  
  // Arg check
  if (fileName == NULL) goto wrapup;

  // Open file
  file = fopen(fileName,"wb");
  if (file == NULL) goto wrapup;
  
  VPpdfSetBinFile(file);
  
  // Master root object
  VPpdfWriteObjBeg (PDF_OBJ_ROOT);

  retFlag = 1;
  
wrapup:
  return retFlag;
}

/* --------------------------------------------------------
 * Close spades data file
 */
IGRstat VPextCloseDataFile(IGRchar *fileName)
{
  IGRstat retFlag = 0;
  
  FILE *file;

  // Last object
  VPpdfWriteObjEnd(PDF_OBJ_ROOT);

  // Close
  file = VPpdfGetBinFile();
  if (file) fclose(file);
  VPpdfSetBinFile(NULL);

  // Now verify the binary file just written
  if (fileName == NULL) goto wrapup;
  VPpdfVerifyFile(fileName);

  retFlag = 1;
  
wrapup:
  return retFlag;
}

end implementation VDbtBase;



