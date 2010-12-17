/* MSSP - 29 Dec 93. replaced __unix__ with OS_CLIX */
#ifdef OS_CLIX
#define DELIM           "/"
#define NFMDIR          "/usr/ip32/nfm"
#define NFMSDP_COMM     "/usr/ip32/nfm/config/workflow/NFMcomm.dat"
#define NFMSDP_SDP      "/usr/ip32/nfm/config/workflow/NFMsdp.dat"
#define NFMSDP_ADMIN    "/usr/ip32/nfm/config/workflow/NFMadmin.dat"
#define NFMSDP_CATALOG  "/usr/ip32/nfm/config/workflow/NFMcatalog.dat"
#define NFMSDP_PROJECT  "/usr/ip32/nfm/config/workflow/NFMproject.dat"
#define NFMSDP_ITEM     "/usr/ip32/nfm/config/workflow/NFMitem.dat"
#define NFM_MEM_MAP_FILE     "/usr/tmp/NFMmap.config"
#endif

#ifdef vms
#define DELIM           ""
#define NFMDIR          "pro_dd_nfm:"
#define NFMSDP_COMM     "pro_dd_nfm:NFMcomm.dat"
#define NFMSDP_SDP      "pro_dd_nfm:NFMsdp.dat"
#define NFMSDP_ADMIN    "pro_dd_nfm:NFMadmin.dat"
#define NFMSDP_CATALOG  "pro_dd_nfm:NFMcatalog.dat"
#define NFMSDP_PROJECT  "pro_dd_nfm:NFMproject.dat"
#define NFMSDP_ITEM     "pro_dd_nfm:NFMitem.dat"
#define NFM_MEM_MAP_FILE "pro_dd_nfm:NFMmap.config"
#endif

/* #ifdef sparc changed to read as follows for SCO port 16 Dec 1993*/
/* MSSP - 29 Dec 93. SCO/SOLARIS Port */
/* Added for SGI port. 030394 MaC */

/* HP PORT - IGI - 10 Jun 94 */

#if (defined (__sgi) || defined OS_SUNOS || defined OS_SOLARIS || defined OS_SCO_UNIX || defined (OS_HPUX) )
#define DELIM           "/"
#define NFMDIR          "/usr/ip32/nfm"
#define NFMSDP_COMM     "/usr/ip32/nfm/config/workflow/NFMcomm.dat"
#define NFMSDP_SDP      "/usr/ip32/nfm/config/workflow/NFMsdp.dat"
#define NFMSDP_ADMIN    "/usr/ip32/nfm/config/workflow/NFMadmin.dat"
#define NFMSDP_CATALOG  "/usr/ip32/nfm/config/workflow/NFMcatalog.dat"
#define NFMSDP_PROJECT  "/usr/ip32/nfm/config/workflow/NFMproject.dat"
#define NFMSDP_ITEM     "/usr/ip32/nfm/config/workflow/NFMitem.dat"
#define NFM_MEM_MAP_FILE     "/usr/tmp/NFMmap.config"
#endif


