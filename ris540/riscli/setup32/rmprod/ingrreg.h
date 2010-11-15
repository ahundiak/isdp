// 1996.02.06:Alan Barksdale:Modified from csource\ingrreg.h of Setup SDK
//	2.3.0.0.

// Compile time constants

// #define PRODUCTNAME              "<Applic Name>"
#if defined(RISCLI)
#define	PRODUCTNAME	"RISCLI"
#elif defined(RISINTOP)
// 1996:03.01:Alan Barksdale:PRODUCTNAME not used for RISINTOP
#elif defined(risorads)
#define	PRODUCTNAME	"RISORADS"
#elif defined(risorans)
#define	PRODUCTNAME	"RISORANS"
#elif defined(risinfds)
#define	PRODUCTNAME	"RISINFDS"
#elif defined(risinfns)
#define	PRODUCTNAME	"RISINFNS"
#elif defined(rismsfds)
#define	PRODUCTNAME	"RISMSFDS"
#elif defined(rissybds)
#define	PRODUCTNAME	"RISSYBDS"
#elif defined(risingds)
#define	PRODUCTNAME	"RISIGSDS"
#elif defined(risdb2ds)
#define	PRODUCTNAME	"RISDB2DS"
#elif defined(RISAPP)
#define	PRODUCTNAME	"RISDP"
#elif defined(RISSHARE)
#define	PRODUCTNAME	"RIS"
#endif
// #define VERSIONSTRING            "<Applic RegVersion>"
#define VERSIONSTRING            RIS_MAJ_MIN_STR

// 1996.03.14:Alan Barksdale:to help make remove work with other versions
#define VERSIONSTRING_MACRO( \
    version_string_vm) \
\
    ((version_string_vm) ? (version_string_vm) : VERSIONSTRING)
// VERSIONSTRING_MACRO

// These strings define the registry key names

#define INTERGRAPH               "Intergraph"

#define SOFTWARE_KEY             "SOFTWARE"
#define INTERGRAPH_KEY            SOFTWARE_KEY "\\" INTERGRAPH
#define PRODUCTNAME_KEY           INTERGRAPH_KEY "\\" PRODUCTNAME
#define VERSIONSTRING_KEY         PRODUCTNAME_KEY "\\" VERSIONSTRING

#define HKEY_LOCAL               "HKEY_LOCAL_MACHINE"
#define FULL_INTERGRAPH_KEY       HKEY_LOCAL "\\" INTERGRAPH_KEY
#define FULL_PRODUCTNAME_KEY      HKEY_LOCAL "\\" PRODUCTNAME_KEY
#define FULL_VERSIONSTRING_KEY    HKEY_LOCAL "\\" VERSIONSTRING_KEY

// These strings define the registry value names

#define INSTALLDATE_VALUE        "InstallDate"
#define PATHNAME_VALUE           "PathName"
#define SOFTWARETYPE_VALUE       "SoftwareType"
#define IDNUMBER_VALUE           "IDNumber"
#define DESCRIPTION_VALUE        "Description"
#define VERSION_VALUE            "Version"
#define RELDATE_VALUE            "RelDate"
#define INSTALLMODE_VALUE        "InstallMode"
#define REFLIST_VALUE            "RefList"
#define LOCALPATHNAME_VALUE      "LocalPathName"
#define TEMPDELIVERYDIR_VALUE    "TempDeliveryDir"

#define ADMINISTRATOR_MODE       "Administrator"
#define STANDALONE_MODE          "Standalone"
#define WORKSTATION_MODE         "Workstation"

#define APPLICATION_TYPE         "Application"
#define SYSTEM_SHAREDCOMP        "System Shared Component"
#define APPLICATION_SHAREDCOMP   "Application Shared Component"

// These strings define registry environment keys and values

#define CURRENTCONTROLSET_KEY    "SYSTEM\\CurrentControlSet"
#define CONTROL_KEY               CURRENTCONTROLSET_KEY "\\Control"
#define SESSIONMANAGER_KEY        CONTROL_KEY "\\Session Manager"
#define ENVIRONMENT_KEY           SESSIONMANAGER_KEY "\\Environment"

// Dont confuse WINDOWS_KEY (W95) with WINDOWSNT_KEY (NT)

#define MICROSOFT_REGISTRY_KEY   "SOFTWARE\\Microsoft"
#define WINDOWS_KEY               MICROSOFT_REGISTRY_KEY "\\Windows"
#define CURRENTVERSION_KEY        WINDOWS_KEY "\\CurrentVersion"
#define APPPATHS_KEY              CURRENTVERSION_KEY "\\App Paths"

#define COMMONFILESDIR_VALUE     "CommonFilesDir"
#define PROGRAMFILESDIR_VALUE    "ProgramFilesDir"
#define PATH_VALUE               "Path"
#define DEFAULT_VALUE            ""

// These strings define Windows95 Uninstall keys and values

#define UNINSTALL                "Uninstall"
#define UNINSTALL_KEY             CURRENTVERSION_KEY "\\" UNINSTALL
#define PROD_UNINSTALL_KEY        UNINSTALL_KEY "\\" PRODUCTNAME

#define DISPLAYNAME_VALUE        "DisplayName"
#define UNINSTALLSTRING_VALUE    "UninstallString"

// These values define Win32s registry equivalents

#define INI_FILE                 "INGR.INI"
#define INI_SECTION               PRODUCTNAME "\\" VERSIONSTRING

// This defines some product directories (format must be slash terminated)

#define PH2_W95_PROD_DIR         "\\Program Files"
#define PH2_W32S_PROD_DIR        "\\Progra~1"

#define PH2_INGR_ADMIN_DIR_FMT   "%c:\\%s\\"
#define PH2_INGR_PROD_DIR_FMT    "%c:"PH2_W95_PROD_DIR"\\%s\\"
#define PH2_W32S_PROD_DIR_FMT    "%c:"PH2_W32S_PROD_DIR"\\%s\\"

// This defines some shared component directories stuff

#define INGR_SHARE_DIR           "\\win32app\\ingr\\share"
#define PH2_INGR_SHARE_DIR        PH2_W95_PROD_DIR"\\Common Files\\" INTERGRAPH
#define PH2_SYS_SHARE_DIR         PH2_W95_PROD_DIR"\\Common Files\\System"
#define PH2_W32S_SHARE_DIR        PH2_W32S_PROD_DIR"\\Common~1\\Interg~1"

#define INGR_SHARE_DIR_FMT       "%c:"INGR_SHARE_DIR"\\"
#define PH2_INGR_SHARE_DIR_FMT   "%c:"PH2_INGR_SHARE_DIR"\\"
#define PH2_SYS_SHARE_DIR_FMT    "%c:"PH2_SYS_SHARE_DIR"\\"
#define PH2_W32S_SHARE_DIR_FMT   "%c:"PH2_W32S_SHARE_DIR"\\"

#define COMMON_VALUE             "Common"   // registry key and ini value
#define COMMON_SECTION           "Common"   // ini section within ini file
