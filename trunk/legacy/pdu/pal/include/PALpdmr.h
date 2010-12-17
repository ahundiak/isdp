#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <MEMstruct.h>
#include <MEMerrordef.h>
#include <SQLerrordef.h>
#include <PDUstr.h>
#if defined (__sgi) || defined (__Sol2__) || defined (sparc)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "PALglbs.h"
#include "PDUfile_def.h"
#include "PDUerror.h"
#include "PDMmessage.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "PALmsg.h"
