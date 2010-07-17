class implementation Root;

#include "VDtypedef.h"

#include "VPpdf.h"

#include "vldbgmacros.h"
#include "v_miscmacros.h"
#include "vdprdmacros.h"

typedef struct 
{
  IGRint  type;
  IGRchar desc[64];
} TVPdesc;

static IGRint   recTypeDescCnt;

static TVPdesc *recTypeDesc;

/* --------------------------------------------------------------------
 * Return record description for a given type
 * Try cheating here and use the include file for the text strings
 */
IGRstat VPpdfReadRecTypeDesc(IGRchar *buf)
{
  IGRstat retFlag = 0;
  
  IGRchar *p,*q;

  // Looking for objects or attributes
  p = strstr(buf,"PDF_OBJ");
  if (p == NULL) p = strstr(buf,"PDF_ATR");
  if (p == NULL) goto wrapup;

  // Get the hex type
  q = strchr(p,' ');
  if (q == NULL) goto wrapup;

  recTypeDesc[recTypeDescCnt].type = atol(q);
  
  // Pull out the string
  *q = 0;
  strcpy(recTypeDesc[recTypeDescCnt].desc,p);

#if 0
  printf("%3d %4d %s\n",
	 recTypeDescCnt, 
	 recTypeDesc[recTypeDescCnt].type,
	 recTypeDesc[recTypeDescCnt].desc);
#endif

  // Onto next
  recTypeDescCnt++;
  retFlag = 1;
  
  
wrapup:
  return retFlag;
  
}

/* --------------------------------------------------------
 * Look through config directories for record file
 */
FILE *VPpdfOpenRecordFile()
{
  IGRint i;
  IGRchar buf[DI_PATH_MAX];
  FILE *file;
  
  for(i = 0; 1; i++) {
    
    // Product specific loading
    *buf = 0;
    ex$get_path( index = i,
		 path  = buf,
		 len   = sizeof(buf),
		 type  = EX_CONFIG_PATH );
    if (*buf == 0) {
      file = NULL;
      return file;
    }
    
    strcat(buf,"config/EfpAttrs.txt");
        
    file = fopen(buf,"rt");
    if (file != NULL) return file;
  }
}

IGRstar VPpdfGetRecTypeDesc(IGRint recType, IGRchar *desc)
{
  IGRstat retFlag = 0;

  FILE   *file = NULL;
  IGRchar buf[256];

  IGRint  i;
  
  // Arg Check
  if (desc == NULL) goto wrapup;
  *desc = 0;
  
  recType &= 0x3FFF;
  
  // Load in type desc if this is the first time 
  if (recTypeDesc == NULL) {
    
    recTypeDesc = _CALLOC(256,TVPdesc);

    if (recTypeDesc == NULL) goto wrapup;
    recTypeDescCnt = 0;

    *buf = 0;
    
    // Product specific loading
    file = VPpdfOpenRecordFile();
    if (file == NULL) goto wrapup;

    // Cycle through
    while(fgets(buf,sizeof(buf),file)) {

      VPpdfReadRecTypeDesc(buf);
    }
    fclose(file);
  }

  retFlag = 0;
  
  for(i = 0; (i < recTypeDescCnt) && (recType != recTypeDesc[i].type); i++);

  if (i == recTypeDescCnt) goto wrapup;
  
  strcpy(desc,recTypeDesc[i].desc);
  //printf("%4d %s\n",recType,desc);
  retFlag = 1;
  
wrapup:
  return retFlag;
  
}

end implementation Root;

