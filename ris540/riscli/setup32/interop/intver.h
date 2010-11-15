/* Do not alter this SPC information: $Revision: 1.6.3.1 $ */
#ifdef WIN32
#ifdef RC_INVOKED

#include <winver.h>
#include <risver.h>

#define VER_FILEVERSION_STR      RIS_VERSION_STR
#define VER_FILEVERSION          RIS_VERSION

#define VER_PRODUCTNAME_STR      "Configure RIS Version for Windows NT and Windows 95\0"
#define VER_COMPANYNAME_STR      "Intergraph Corporation\0"
#define VER_LEGALTRADEMARKS_STR  "Windows NT (TM), Windows 95 (TM), and Windows (TM) are trademarks of Microsoft Corporation\0"
#define VER_LEGALCOPYRIGHT_STR   "Copyright \251 Intergraph Corp. " COPYRIGHTYEAR "\0"
#define VER_PRODUCTVERSION_STR   RIS_VERSION_STR
#define VER_PRODUCTVERSION       RIS_VERSION
#define VER_COMMENT_STR          "Windows NT and Windows 95 Configure RIS Version \0"
#define VER_FILETYPE             VFT_APP
#define VER_FILESUBTYPE          0
#define VER_FILEFLAGSMASK        VS_FFI_FILEFLAGSMASK
#define VER_FILEFLAGS            VS_FF_PRERELEASE
#define VER_FILEOS               VOS_NT_WINDOWS32

#endif // RC_INVOKED

#endif // WIN32

