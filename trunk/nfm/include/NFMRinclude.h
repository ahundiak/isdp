#ifndef NFMR_INCLUDE_H
#define NFMR_INCLUDE_H

#include <stdio.h>
#include "MEMstruct.h"
#include "NETstruct.h"
#include "NETdef.h"
#include "NFMtypes.h"
#include "NFMerrordef.h"
#include "MSGstruct.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "ERR.h"
#include "NFMcombine.h"

extern MSGptr NFMRmsg_ptr;
extern MSGptr NFMmsg_ptr;
extern MSGptr MEMmsg_ptr;

#ifndef NFM_DEBUG_SUBSYSTEMS
#define NFM_DEBUG_SUBSYSTEMS 15
#endif
#ifndef NFM_DEBUG_FILE_SIZE
#define NFM_DEBUG_FILE_SIZE  80
#endif

#endif
