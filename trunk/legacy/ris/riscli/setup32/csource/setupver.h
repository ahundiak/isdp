/* Do not alter this SPC information: $Revision: 1.11.3.1 $ */
//
// This PRODINDEX is the "product index" generated for your application
// by Software Distribution when they enter it into their databases.
//
// It will be different for every combination of:
// Product ID number
// Product Version number Major/Minor
// Language localization
// Target Platform
//

#if defined (RISAPP)
#define RISPACK 5
#define PRODINDEX "003168"
#endif


//
// This is information that will be put into the system registry
// (see the Install() function)
//
// Some of it will also be used in IngrLogInstallResult()
//


// This string is used as a PRODUCT version constant for the Registry.

#define PRODUCT_REGVERSION_STR	  "02.00"

// These strings define the registry key names 

#define INGR_REGISTRY_KEY     "SOFTWARE\\Intergraph"
#define PRODUCT_REGISTRY_KEY   INGR_REGISTRY_KEY "\\" PRODNAME
#define VERSION_REGISTRY_KEY   PRODUCT_REGISTRY_KEY "\\" PRODUCT_REGVERSION_STR
#define HKEY_LOCAL	"HKEY_LOCAL_MACHINE"
#define FULL_INGR_REGISTRY_KEY	     HKEY_LOCAL "\\" INGR_REGISTRY_KEY
#define FULL_PRODUCT_REGISTRY_KEY   HKEY_LOCAL "\\" PRODUCT_REGISTRY_KEY
#define FULL_VERSION_REGISTRY_KEY   HKEY_LOCAL "\\" VERSION_REGISTRY_KEY

// Section name used for Win32s INGR.INI file
/** MELANIA - Having problems compiling
#define INI_SECTION	PRODNAME "\\" PRODUCT_REGVERSION_STR
***/

// These strings define the registry value names

#define INSTALLDATE_VALUE      "InstallDate"
#define PATHNAME_VALUE	       "PathName"
#define SOFTWARETYPE_VALUE     "SoftwareType"
#define IDNUMBER_VALUE	       "IDNumber"
#define DESCRIPTION_VALUE      "Description"
#define VERSION_VALUE	       "Version"
#define RELDATE_VALUE	       "RelDate"
#define INSTALLMODE_VALUE      "InstallMode"

#define STANDALONE_MODE        "Standalone"
#define WORKSTATION_MODE       "Workstation"
#define SOFTWARETYPE	    "Application"

// The InstallType value is a bitmask determining what files were selected
// during installation.  This value is used during removal to select the
// proper files to remove.  (not used at present)

#define TOOLKIT 0x0001	   // basic toolkit, dlls
#define EXAMPLE 0x0002	   // example source for installation program
#define GENERIC 0x0004	   // example source for windows program, licensing
#define DOCS   0x0008	   // setupsdk documentation


//
// Defines used for FILEVERSION resource
// in product installation proecdure executable.
//

#ifdef RC_INVOKED

#include <winver.h>
#include "risver.h"

#define VER_FILEVERSION_STR    RIS_VERSION_STR
#define VER_FILEVERSION     RIS_VERSION
#define VER_FILE_DESCRIPTION_STR "RIS Share Component Setup\0"
#define VER_INTERNAL_STR "risshare.exe\0"
#define VER_COMPANYNAME_STR    "Intergraph Corporation\0"
/*** MELANIA - Already defined **
#define VER_LEGALTRADEMARKS_STR  "Windows NT (TM), Windows 95 (TM), and Windows (TM) are trademarks of Microsoft Corporation\0"
*************/
#define VER_INGR_LEGALTRADEMARKS_STR  "Intergraph\256 is a registered trademark of Intergraph Corporation. Windows(TM) is a trademark of Microsoft Corporation\0"
#define VER_INGR_LEGALCOPYRIGHT_STR	  "Copyright \251 Microsoft Corp. 1991, 1992\nCopyright \251 Intergraph Corp. " COPYRIGHTYEAR "\0"
#define VER_PRODUCTVERSION_STR	  RIS_VERSION_STR
#define VER_PRODUCTVERSION  RIS_VERSION
#if !defined (RISSRV)
#define VER_PRODUCTNAME_STR    "RIS Shared Component Setup Procedure for Windows NT and Windows 95\0"
#define VER_COMMENT_STR     "Windows NT and Windows 95 RIS Shared Component Setup\0"
#endif
#define VER_FILETYPE	 VFT_APP
#define VER_FILESUBTYPE     0
#define VER_FILEFLAGSMASK   VS_FFI_FILEFLAGSMASK
#define VER_FILEFLAGS	    VS_FF_PRERELEASE
#define VER_FILEOS	 VOS_NT_WINDOWS32


#endif // RC_INVOKED

