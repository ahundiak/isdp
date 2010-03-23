#ifndef DLOADPVT_H
#define DLOADPVT_H

/*****************************************************************************/
/*                      ARCHITECTURE DEPENDENT PARAMETERS                    */
/*									     */
/*    SLOTSIZE    - The size of a branch table slot in bytes.  This must be  */
/*                  the number of bytes consumed by whatever instruction(s)  */
/*                  would be required to jump to any virtual address.	     */
/*									     */
/*    ADDR        - An unsigned integer type appropiate for the represention */
/*                  of all possible virtual addresses.			     */
/*									     */
/*    UNRESADDR   - The address to map unresolved symbols to when the option */
/*		    enabling this feature is set.  It should be a location   */
/*		    guaranteed to cause a fault for both reads and writes.   */
/*									     */
/*    ADDRALIGN   - The machine's address alignment requirements.  This is   */
/*		    an initializer for an array of ALIGNDEF structures used  */
/*		    to sort symbols by alignment requirement.  Alignment     */
/*		    boundaries must be specified in decreasing order with    */
/*		    one (1) last.					     */
/*									     */
/*    REGIONSZ    - If defined all code loaded from a given object file must */
/*		    be contained within a virtual address range of this size */
/*		    starting on a REGIONSZ-aligned boundary; additionally    */
/*		    all branch and call destinations must lie within this    */
/*		    region.  If not defined these restrictions do not apply. */
/*									     */
/*    GRABSZ      - If defined this is the minimum amount of virtual memory  */
/*		    to obtain via memory mapping in order to make most       */
/*		    efficient use of virtual address space.  If not defined  */
/*		    a single page of memory may be mapped without loss of    */
/*		    virtual address space.				     */
/*									     */
/*    DIRECTMAP   - If defined a demand-paged object file may be directly    */
/*		    mapped into memory.  This requires that the "mmap"       */
/*		    system call allows mappings to overlay existing mappings */
/*		    in whole or in part (superceeding previous mappings).    */
/*		    If not defined all object files are loaded via the       */
/*		    standard file reading mechanisms.			     */
/*									     */
/*    NOMAPPING   - If defined the target system does not support memory     */
/*		    mapping at all.  In this case memory is obtained via     */
/*		    some other mechanism (such as malloc) and the GRABSZ     */
/*		    parameter then specifies the minimum amount to obtain    */
/*		    with each request.  If not defined memory mapping will   */
/*		    be used to allocate virtual address space for the text   */
/*		    and data segments of dynamically loaded files.  This has */
/*		    the advantage of physically separating these areas from  */
/*		    the general-use heap.				     */
/*									     */
/*    ZEROFILE    - If defined this is the name of the file to use for       */
/*		    memory mapping ("/dev/zero" on most UNIX systems).  If   */
/*		    not defined either the target system does not support    */
/*		    memory mapping (NOMAPPING defined) or a temporary file   */
/*		    will be created to support this function.		     */
/*****************************************************************************/

#if CLIX
#define  SLOTSIZE        6
#define  ADDR            unsigned int
#define  UNRESADDR       ((ADDR)0xfffffff8)
#define  ADDRALIGN       { {8,0}, {4,0}, {2,0}, {1,0} }
#define  GRABSZ          0x00400000
#elif (SunOS_4x || SunOS_5x)
#if __i386__
#define  SLOTSIZE        5
#else
#define  SLOTSIZE        12
#endif
#define  ADDR            unsigned int
#define  UNRESADDR       ((ADDR)0x0)
#define  ADDRALIGN       { {8,0}, {4,0}, {2,0}, {1,0} }
#define  ZEROFILE        "/dev/zero"
#define  DIRECTMAP
#elif IRIX_4x
#define  SLOTSIZE        16
#define  ADDR            unsigned int
#define  UNRESADDR       ((ADDR)0x0)
#define  ADDRALIGN       { {8,0}, {4,0}, {2,0}, {1,0} }
#define  REGIONSZ        0x10000000
#define  GRABSZ          0x00200000
#define  ZEROFILE        "/dev/zero"
#elif IRIX_5x
#define  SLOTSIZE        16
#define  ADDR            unsigned int
#define  UNRESADDR       ((ADDR)0x0)
#define  ADDRALIGN       { {8,0}, {4,0}, {2,0}, {1,0} }
#define  REGIONSZ        0x10000000
#define  ZEROFILE        "/dev/zero"
#define  DIRECTMAP
#else
#error  Required parameters for this machine are not defined!
#endif

/***********************/
/* TUNEABLE PARAMETERS */
/***********************/

#define  MAINHASHSZ   12500   /* size of main symbol table                 */
#define  PENDHASHSZ    2000   /* size of symbol table for pending files    */
#define  FILEHASHSZ     250   /* size of the hash table for loaded files   */
#define  TAGHASHSZ      100   /* size of hash table for reactive load tags */

#if SunOS_4x
typedef unsigned long ulong;
#endif

/********************/
/* Forward Typedefs */
/********************/

typedef struct dlsymbl SYMBOL;
typedef struct auxstuff AUXINFO;
typedef struct handle HANDLE;

/**************************/
/* memory management info */
/**************************/

#define  FRAGGRAIN   64		/* granularity of fragment index (bytes) */
#define  MEMGRAIN     4		/* granularity of avail index (pages)    */
#define  MAXMEMNDX   64		/* maximum position in avail index       */

typedef struct memhdr MEMHDR;
struct memhdr {
   MEMHDR *next;		/* pointer to next free chunk  */
   uint    size;		/* size in bytes of this chunk */
};

typedef struct mregion REGION;
struct mregion {
   ADDR      addr;		/* starting address of this region    */
   REGION   *next;		/* pointer to the next defined region */
   MEMHDR  **avail;		/* available memory index             */
   MEMHDR  **tfrags;		/* text fragment index                */
   MEMHDR  **dfrags;            /* data fragment index                */
};

typedef struct slottbl SLOTTBL;
struct slottbl {
   ADDR     addr;		/* address of table               */
   ushort   alloced;		/* number of slots allocated      */
   char     prot;		/* set when write-protected       */
   SLOTTBL *next;		/* points to the next slot table  */
};


struct dlsymbl {
   char   *name;     /* symbol name                                     */
   int     whatis;   /* what kind of symbol (defines in objaccess.h)    */
   uint    value;    /* value of the symbol                             */
union {
   SYMBOL *alias;    /* points to alias symbol if SYM_ALIAS set         */
   HANDLE *owner;    /* points to defining file (SYM_EXT & SYM_COMM)    */
   ADDR    slot;     /* points to the branch table slot for functions   */
} u;
};

/* additional defines for "whatis" used only by the dynamic loader */

#define  SYM_MAIN   0x0100000   /* main program definition  */
#define  SYM_PEND   0x0200000   /* pending definition       */
#define  SYM_HIDE   0x0400000   /* hidden symbol            */
#define  SYM_ALIAS  0x0800000   /* alias for another symbol */
#define  SYM_IGNORE 0x1000000   /* ignore redefinitions     */


/*****************************************************************************/
/*****************************************************************************/

typedef struct savreloc SRE;
struct savreloc {
   SRE    *next;         /* points to next saved relocation          */
   SYMBOL *sym;          /* symbol being referenced                  */
   long   *where;        /* address to be updated                    */
   long    rvalue;       /* value extracted from original relocation */
   uint    rtype;        /* relocation type                          */
   int     addend;       /* relocation addend                        */
};


/*****************************************************************************/
/* "Auxstuff" is information needed to process the dynamic load of this file */
/* which is purged after the load completes.				     */
/*****************************************************************************/

struct auxstuff {
   char    *fpath;       /* path name of file as given to dload            */
   uint     bssneed;     /* bytes needed to allocate commons               */
   int      textmod;     /* text segment relocation factor                 */
   int      datamod;     /* data segment relocation factor                 */
   int      unres;       /* number of unresolved symbols                   */
   OBJFD   *objfd;       /* object file descriptor for objaccess routines  */
   OBJINFO *objinfo;     /* object info structure returned by OBJread      */
};


/*****************************************************************************/
/*****************************************************************************/

#define  DLMAGIC  1755801566   /* unlikely quantity for validity test */
struct handle {
   int      magic;       /* equals DLMAGIC for valid handle                */
   char    *name;        /* name of the associated file (NULL if multiple) */
   int      options;     /* options the file was loaded with               */
   HANDLE  *next;        /* next file in the loaded list                   */
   HANDLE  *prev;        /* prev file in the loaded list                   */
   ADDR     text;        /* address of the text segment                    */
   ADDR     data;        /* address of the data segment                    */
   uint     tsize;       /* size of the text segment                       */
   uint     dsize;       /* size of the data segment                       */
   ushort   nfiles;      /* number of files in composite handle            */
   char     prot;        /* set when text segment is write-protected       */
   char     dbgknows;    /* set if a debugger knows about this file        */
   int      nsyms;       /* number of symbols                              */
   SYMBOL  *symtab;      /* symbol table for this file                     */
   char    *names;       /* name cache for this file                       */
   void    *dbginfo;     /* information for symbolic debuggers             */
   AUXINFO *auxinfo;     /* auxiliary information not needed after load    */
};

/*****************************************************************************/
/* "Alignment Definition" is a machine independent method of handling the    */
/* alignment requirements of 'common' (unitialized global) symbols that must */
/* be allocated space and assigned addresses by the dynamic loader.  One     */
/* such structure is allocated for each alignment requirement.  Symbols are  */
/* sorted by their alignments and assigned addresses largest alignments      */
/* first.  This technique makes for best memory utilization.		     */
/*****************************************************************************/

typedef struct algndef ALIGNDEF;
struct algndef {
   int     bound;
   SYMBOL *symlist;
};


/*****************************************************************************/
/*****************************************************************************/

typedef struct tagdef RLTAG;
struct tagdef {
   char  *tagname;
   char  *dirname;
   void (*recover)();
};

/**********/
/* MACROS */
/**********/

/* Space allocation given number of elements and type. */

#define  Space(n,t)    (t *)Malloc ((n) * sizeof (t))
#define  Resize(p,n,t) (t *)Realloc ((p), (n) * sizeof (t))

/* Minimum of two values. */

#define  MIN(x,y)  ((x) < (y) ? (x) : (y))

/* Determine symbol type:  1=pure external; 2=common; 3=global. */

#define  SYMTYPE(s)  ((s)->whatis & SYM_COMM ? 2 : \
                                               ((s)->whatis & SYM_EXT ? 1 : 3))

#define  TRUNC(v,b)  ((v) / (b) * (b))

#define  ALIGN(v,b)  (TRUNC ((v) - 1, b) + (b))
#endif
