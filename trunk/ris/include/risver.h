/* =======================================================
 * SOL10 24 Nov 2010
 *
 * The PDUimage has RIS_app_version = 5.2.2.20
 * Which actually matches what dates shows
 *
 * /etc/risconfig shows 5.4.0.26 13 Feb 1998
 *
 * Wonder if the version is getting set from the ingrconfig file?
 *
 * Move it to 5.4.0.30 just for grins
 */
#define RIS_VERSION 05,04,00,26
#define RIS_VERSION_STR "05.04.00.30\0"
#define RIS_MAJ_MIN_STR "05.04"
#define RIS_VERSION_FIX 05,04,00,30
#define RIS_VERSION_CUI "Version 05.04.00.30"
#define RIS_VERSION_MAJ 05
#define RIS_VERSION_MIN 04
#define RIS_VERSION_REL 00
#define RIS_VERSION_SEQ 30

#define RIS_MAJOR_MINOR "05.04"

#define RELDATE      "24-Nov-2010"
#define PATHNAME     "\\win32app\\ingr\\share\\ris05.04"
#define RISCOMPONENT "RIS05.04"
#define RISPROGGROUP "RIS 05.04"
#define REGISTRY     "Software\\Intergraph\\RIS\\05.04"

#define RIS_PROGMAN_STR   "RISDP 05.04"
#define RIS_LIST_STR      "RISDP\\05.04"
#define RISDP_PROGMAN_STR "RISDP 05.04"
#define RISDP_LIST_STR    "RISDP\\05.04"
#define DB2DS_PROGMAN_STR "RISDB2DS 05.04"
#define DB2DS_LIST_STR    "RISDB2DS\\05.04"
#define ORADS_PROGMAN_STR "RISORADS 05.04"
#define ORADS_LIST_STR    "RISORADS\\05.04"
#define ORANS_PROGMAN_STR "RISORANS 05.04"
#define ORANS_LIST_STR    "RISORANS\\05.04"
#define IGSDS_PROGMAN_STR "RISIGSDS 05.04"
#define IGSDS_LIST_STR    "RISIGSDS\\05.04"
#define INFDS_PROGMAN_STR "RISINFDS 05.04"
#define INFDS_LIST_STR    "RISINFDS\\05.04"
#define INFNS_PROGMAN_STR "RISINFNS 05.04"
#define INFNS_LIST_STR    "RISINFNS\\05.04"
#define MSFDS_PROGMAN_STR "RISMSFDS 05.04"
#define MSFDS_LIST_STR    "RISMSFDS\\05.04"
#define SYBDS_PROGMAN_STR "RISSYBDS 05.04"
#define SYBDS_LIST_STR    "RISSYBDS\\05.04"
#define RIS_CR "Copyright 1995, Intergraph Corporation. All Rights Reserved\0"
#define RIS_CO "Intergraph Corporation\0"
#define RIS_TM "Intergraph\256 is a registered trademark of Intergraph Corporation.\0"

static char *RIS_version = "05.04.00.30";
static int   RIS_version_maj = 5;
static int   RIS_version_min = 3;
static int   RIS_version_rel = 0;
static int   RIS_version_seq = 6;
