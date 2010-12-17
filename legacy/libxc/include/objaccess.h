#ifndef  _OBJACCESS_H
#define  _OBJACCESS_H  1

/* typedefs for specific sized integer types (maybe want to have a special
   include for this?) */

typedef int            S4_int;
typedef short          S2_int;
typedef char           S1_int;
typedef unsigned int   U4_int;
typedef unsigned short U2_int;
typedef unsigned char  U1_int;


typedef struct objinfo OBJINFO;
typedef struct seg     SEGMENT;
typedef struct scn     SECTION;
typedef struct fildesc FILDESC;
typedef struct fcndesc FCNDESC;
typedef struct rlocent RLOCENT;
typedef struct lno     LINENUM;
typedef struct typdesc TYPDESC;
typedef struct ste     STE;
typedef struct artoc   ARTOC;
typedef struct arndx   ARNDX;
typedef struct objfd   OBJFD;


struct seg {
    U4_int   size;          /* size of the segment in bytes       */
    U4_int   faddr;         /* offset in file to start            */
    U4_int   vaddr;         /* virtual address (seg reloc'ed wrt) */
    S4_int   nscns;         /* number of sections in the segment  */
    SECTION *scnptr;        /* points to sections in this segment */
};


struct scn {
    char    *name;          /* section name                       */
    U4_int   size;          /* size of the section in bytes       */
    U4_int   faddr;         /* offset in file to start            */
    U4_int   vaddr;         /* virtual address (scn reloc'ed wrt) */
    S4_int   nrelocs;       /* number of relocs for this section  */
    RLOCENT *relocptr;      /* pointer to relocs for this section */
    STE     *auxsym;        /* symbol for section relative reloc  */
    U4_int   flags;         /* see defines below                  */
    U4_int   archflags;     /* architecture-dependent flags       */
    void    *archother;     /* other architecture-dependent data  */
};

/* values for "flags" */

#define  SCN_TEXT  0x001    /* section contains executable text    */
#define  SCN_DATA  0x002    /* section contains initialized data   */
#define  SCN_BSS   0x004    /* section describes zero-filled data  */
#define  SCN_INFO  0x008    /* section contains other information  */
#define  SCN_READ  0x010    /* in-core section with read access    */
#define  SCN_WRITE 0x020    /* in-core section with write access   */
#define  SCN_EXE   0x040    /* in-core section with execute access */
#define  SCN_ABS   0x080    /* section is non-relocatable          */
#define  SCN_NRES  0x100    /* section is not resident in core     */


struct rlocent {
    U4_int   rtype;         /* type of relocation (see below)     */
    U4_int   addr;          /* virtual address to be updated      */
    STE     *symbol;        /* symbol to relocate wrt to          */
    S4_int   addend;        /* add this value to relocation value */
};

/* clipper relocation types */

#if CLIX
#define  R_CLIP_ABSLONG   0x11  /* 32-bit absolute    */
#define  R_CLIP_PCRWORD   0x13  /* 16-bit PC-relative */
#define  R_CLIP_PCRLONG   0x14  /* 32-bit PC-relative */
#endif

/* sparc relocation types */

#if SunOS_4x
#define  R_SPARC_8          0x00
#define  R_SPARC_16         0x01
#define  R_SPARC_32         0x02
#define  R_SPARC_DISP8      0x03
#define  R_SPARC_DISP16     0x04
#define  R_SPARC_DISP32     0x05
#define  R_SPARC_WDISP30    0x06
#define  R_SPARC_WDISP22    0x07
#define  R_SPARC_HI22       0x08
#define  R_SPARC_22         0x09
#define  R_SPARC_13         0x0a
#define  R_SPARC_LO10       0x0b
#define  R_SPARC_SFA_BASE   0x0c
#define  R_SPARC_SFA_OFF13  0x0d
#define  R_SPARC_BASE10     0x0e
#define  R_SPARC_BASE13     0x0f
#define  R_SPARC_BASE22     0x10
#define  R_SPARC_PC10       0x11
#define  R_SPARC_PC22       0x12
#define  R_SPARC_JMP_TBL    0x13
#define  R_SPARC_SEGOFF16   0x14
#define  R_SPARC_GLOB_DAT   0x15
#define  R_SPARC_JMP_SLOT   0x16
#define  R_SPARC_RELATIVE   0x17
#endif

#if SunOS_5x
#if __i386__
#define  R_I386_32          0x01
#define  R_I386_PC32        0x02
#define  R_I386_GOT32       0x03
#define  R_I386_PLT32       0x04
#define  R_I386_COPY        0x05
#define  R_I386_GLOB_DAT    0x06
#define  R_I386_JMP_SLOT    0x07
#define  R_I386_RELATIVE    0x08
#define  R_I386_GOTOFF      0x09
#define  R_I386_GOTPC       0x0a
#else
#define  R_SPARC_8          0x01
#define  R_SPARC_16         0x02
#define  R_SPARC_32         0x03
#define  R_SPARC_DISP8      0x04
#define  R_SPARC_DISP16     0x05
#define  R_SPARC_DISP32     0x06
#define  R_SPARC_WDISP30    0x07
#define  R_SPARC_WDISP22    0x08
#define  R_SPARC_HI22       0x09
#define  R_SPARC_22         0x0a
#define  R_SPARC_13         0x0b
#define  R_SPARC_LO10       0x0c
#define  R_SPARC_GOT10      0x0d
#define  R_SPARC_GOT13      0x0e
#define  R_SPARC_GOT22      0x0f
#define  R_SPARC_PC10       0x10
#define  R_SPARC_PC22       0x11
#define  R_SPARC_WPLT30     0x12
#define  R_SPARC_COPY       0x13
#define  R_SPARC_GLOB_DAT   0x14
#define  R_SPARC_JMP_SLOT   0x15
#define  R_SPARC_RELATIVE   0x16
#define  R_SPARC_UA32       0x17
#endif
#endif

/* mips relocation types */

#if IRIX_4x
#define  R_MIPS_REFHALF     0x01  /* 16-bit reference            */
#define  R_MIPS_REFWORD     0x02  /* 32-bit reference            */
#define  R_MIPS_JMPADDR     0x03  /* 26-bit jump reference       */
#define  R_MIPS_REFHI       0x04  /* 16-bit high-order reference */
#define  R_MIPS_REFLO       0x05  /* 16-bit low-order reference  */
#define  R_MIPS_GPREL       0x06  /* global pointer relative     */
#endif

#if IRIX_5x
#define  R_MIPS_16          0x01
#define  R_MIPS_32          0x02
#define  R_MIPS_REL32       0x03
#define  R_MIPS_26          0x04
#define  R_MIPS_HI16        0x05
#define  R_MIPS_LO16        0x06
#define  R_MIPS_GPREL16     0x07
#define  R_MIPS_LITERAL     0x08
#define  R_MIPS_GOT16       0x09
#define  R_MIPS_PC16        0x0a
#define  R_MIPS_CALL16      0x0b
#define  R_MIPS_GPREL32     0x0c
#define  R_MIPS_EXTGOT      0x0d
#endif


struct fildesc {
    char    *name;          /* name of source file                */
    char    *dir;           /* directory containing source file   */
    U4_int   vaddr;         /* virtual address of start of file   */
    S4_int   nlsyms;        /* number of local symbols            */
    S4_int   nfcns;         /* number of function entries         */
    S4_int   nlines;        /* number of line numbers             */
    STE     *lsyms;         /* points to local symbols            */
    FCNDESC *fcns;          /* points to function entries         */
    LINENUM *lines;         /* points to line numbers             */
};


struct fcndesc {
    U4_int   vaddr1;        /* virtual address start of function  */
    U4_int   vaddr2;        /* virtual address after prologue     */
    S4_int   nlsyms;        /* number of local symbols            */
    S4_int   nlines;        /* number of line numbers             */
    STE     *lsyms;         /* points to local symbols            */
    LINENUM *lines;         /* points to line numbers             */
    FILDESC *file;          /* points to file that defined me     */
};


struct typdesc {
    char    *desc;          /* type constructor (see below)       */
    STE     *tag;           /* struct/union/enum tag symbol       */
    U4_int   size;          /* size of an object of this type     */
    S4_int   dim[2];        /* array def:  pairs (start ndx, dim) */
};

/* fundamental types - always first element of constructor */

#define  TYP_VOID    'v'
#define  TYP_CHAR    'c'
#define  TYP_SHORT   's'
#define  TYP_INT     'i'
#define  TYP_LONG    'l'
#define  TYP_FLOAT   'f'
#define  TYP_DOUBLE  'd'
#define  TYP_QUAD    'q'    /* long double                        */
#define  TYP_BFIELD  'b'    /* bit field                          */
#define  TYP_UNSIGN  'u'    /* unsigned (ie. "ui" = unsigned int) */
#define  TYP_STRUCT  'S'    /* struct: "tag" points to tag STE    */
#define  TYP_UNION   'U'    /* union:  "tag" points to tag STE    */
#define  TYP_ENUM    'E'    /* enum:   "tag" points to tag STE    */
#define  TYP_TYPDEF  'T'    /* typdef: "tag" points to typdef STE */

/* type constructors */

#define  TYP_PTR     '*'
#define  TYP_ARY     'A'
#define  TYP_FCN     'F'


struct ste {
    char    *name;          /* symbol name                        */
    U4_int   whatis;        /* what kind of symbol (see below)    */
    U4_int   value;         /* value of the symbol                */
    TYPDESC *type;          /* description of symbol's type       */
};

/* values for "whatis" (non-debug symbols) */

#define  SYM_NIL    0x0000  /* meaningless symbol                 */
#define  SYM_EXT    0x0001  /* reference to external name         */
#define  SYM_GLOB   0x0002  /* global definition                  */
#define  SYM_COMM   0x0004  /* uninitialized global (common)      */
#define  SYM_WEAK   0x0008  /* weak global definition             */
#define  SYM_STAT   0x0010  /* static definition                  */
#define  SYM_TEXT   0x0020  /* symbol in text segment             */
#define  SYM_DATA   0x0040  /* symbol in data segment             */
#define  SYM_BSS    0x0080  /* symbol in bss segment              */
#define  SYM_ABS    0x0100  /* absolute (non-relocatable) symbol  */
#define  SYM_FUNC   0x0200  /* function                           */
#define  SYM_VAR    0x0400  /* variable (data item)               */
#define  SYM_LAB    0x0800  /* label                              */
#define  SYM_FILE   0x1000  /* object file name (scopes statics)  */

/* values for "whatis" (debugging symbols) */
/* THESE NEED TO BE REVISED!!!!!           */

#define  SYM_REG    0x0020  /* register symbol                    */
#define  SYM_AUTO   0x0040  /* automatic (stack) symbol           */
#define  SYM_SNAME  0x0100  /* source file name                   */
#define  SYM_SDIR   0x0200  /* source directory (if known)        */
#define  SYM_BINCL  0x0300  /* start of included file             */
#define  SYM_EINCL  0x0400  /* end of included file               */
#define  SYM_BSCOP  0x0500  /* start of local scope (ie '{' in C) */
#define  SYM_ESCOP  0x0600  /* end of local scope                 */
#define  SYM_BCOMM  0x0700  /* begin common block                 */
#define  SYM_ECOMM  0x0800  /* end common block                   */
#define  SYM_FCN    0x1000  /* function                           */
#define  SYM_RPARM  0x2020  /* function parameter in a register   */
#define  SYM_PARM   0x2000  /* function parameter                 */
#define  SYM_SMEM   0x3000  /* member of structure                */
#define  SYM_UMEM   0x4000  /* member of union                    */
#define  SYM_ENUM   0x5000  /* member of enumeration              */
#define  SYM_STAG   0x6000  /* structure tag                      */
#define  SYM_UTAG   0x7000  /* union tag                          */
#define  SYM_ETAG   0x8000  /* enumeration tag                    */
#define  SYM_TDEF   0x9000  /* type definition                    */


struct lno {
    U4_int   addr;          /* address (file name if line == 0)   */
    U4_int   line;          /* source line number                 */
};


struct objinfo {
    S4_int    nlibs;        /* number of referenced libraries      */
    S4_int    nsects;       /* number of sections                  */
    S4_int    nsyms;        /* number of symbols                   */
    S4_int    ndbgs;        /* number of debug symbols             */
    S4_int    naux;         /* number of aux symbols               */
    S4_int    nfiles;       /* number of file descriptors          */
    S4_int    nfcns;        /* number of function descriptors      */
    S4_int    nrelocs;      /* number of relocation entries        */
    S4_int    nlines;       /* number of line numbers              */
    SEGMENT  *text;         /* quick pointer to text segment       */
    SEGMENT  *data;         /* quick pointer to data segment       */
    SEGMENT  *bss;          /* quick pointer to bss segment        */
    char    **libs;         /* array of referenced library names   */
    SECTION  *scnptr;       /* pointer to array of SECTIONs        */
    STE      *symptr;       /* global and static symbols           */
    STE      *dbgptr;       /* debug symbol table                  */
    STE      *auxsym;       /* auxiliarly symbols for relocs       */
    char     *nametbl;      /* cache for symbol names              */
    FILDESC  *files;        /* points to file descriptor table     */
    FCNDESC  *fcns;         /* points to function descriptor table */
    RLOCENT  *relocptr;     /* relocation entries                  */
    LINENUM  *lineptr;      /* line number entries                 */
    U4_int    timestamp;    /* seconds since 00:00:00 GMT 1/1/70   */
    U4_int    entry;        /* entry point address                 */
    U4_int    base;         /* base address for shared library     */
    U4_int    init;         /* initialization function address     */
    U4_int    fini;         /* termination function address        */
    U4_int    flags;        /* see defines below                   */
    U4_int    archflags;    /* architecture-dependent flags        */
    void     *archother;    /* other architecture-dependent data   */
};

/* defines for flags (some may have machine-specific interpretations) */

#define  OBJ_REL     0x0001   /* this is a relocatable object       */
#define  OBJ_SLIB    0x0002   /* this is a dynamic/shared library   */
#define  OBJ_EXE     0x0004   /* this is an executable image        */
#define  OBJ_CORE    0x0008   /* this is a core image               */
#define  OBJ_DYN     0x0010   /* references dynamic/shared library  */
#define  OBJ_DBG     0x0020   /* contains debugging information     */
#define  OBJ_NSYM    0x0040   /* symbol table has been stripped     */
#define  OBJ_NRELOC  0x0080   /* relocation information is stripped */
#define  OBJ_DEMAND  0x0100   /* demand paged  (ZMAGIC)             */
#define  OBJ_IMPURE  0x0200   /* impure format (OMAGIC)             */
#define  OBJ_SHARED  0x0400   /* shared text   (NMAGIC)             */
#define  OBJ_ADJSEG  0x0800   /* text & data must be contiguous     */
#define  OBJ_PIC     0x1000   /* contains position-independent code */

/* defines for architecture-dependent flags */

#if IRIX
#define  O_MIPS_GPREL  0x001  /* file uses global pointer addressing */
#endif


struct artoc {
    char   *name;           /* archive member name                */
    U4_int  offset;         /* archive member offset              */
};


struct arndx {
    char   *symbol;         /* symbol name                        */
    U4_int  offset;         /* offset of defining member          */
};


struct objfd {
    U1_int  arch;           /* non-zero if file is an ar-archive  */
    U1_int  mode;           /* mode file opened with              */
    S2_int  fileno;         /* open file descriptor number        */
    char   *name;           /* name of file (plus archive member) */
    long    tstamp;         /* last-modified timestamp            */
    U4_int  base;           /* base offset to archive member      */
};


/* values for "whence" argument of OBJopen */

#define  OBJ_ARCH   1       /* open only ar-archive file          */
#define  OBJ_OBJ    2       /* open only simple object file       */
#define  OBJ_ALL    3       /* open either archive or object file */

/* use this value as "name" with OBJopen to access main program file */

#define  OBJ_MAIN   (char *)0

/* values for "cmd" argument of OBJread */

#define  OBJ_LIBS   0x001   /* return referenced library names    */
#define  OBJ_SCN    0x002   /* return section headers             */
#define  OBJ_FILE   0x004   /* return file descriptors            */
#define  OBJ_FCN    0x008   /* return function descriptors        */
#define  OBJ_RELOC  0x010   /* return relocation information      */
#define  OBJ_LINE   0x020   /* return line number information     */
#define  OBJ_GSYM   0x040   /* return global symbol table         */
#define  OBJ_LSYM   0x080   /* return local symbol table          */
#define  OBJ_DEBUG  0x100   /* return symbolic debugging info     */
#define  OBJ_MACH   0x200   /* return architecture-specific data  */
#define  OBJ_CMDS   0x2ff   /* mask of all command flags          */


#if defined(__cplusplus)
extern "C" {
#endif
#if defined(__STDC__) || defined(__cplusplus)
extern OBJFD   *OBJopen     (char *name, int whence);
extern OBJFD   *OBJnew      (char *name, int mode);
extern OBJFD   *OBJseek_ar  (OBJFD *fd, U4_int offset);
extern ARNDX   *OBJread_ndx (OBJFD *fd, U4_int *cnt);
extern ARTOC   *OBJread_toc (OBJFD *fd, U4_int *cnt);
extern OBJINFO *OBJread     (OBJFD *fd, int cmd);
extern int      OBJwrite    (OBJFD *fd, OBJINFO *info, void **scnlist);
extern int      OBJclose    (OBJFD *fd, int keep);
#else  /* K&R "C" */
extern OBJFD   *OBJopen ();
extern OBJFD   *OBJnew ();
extern OBJFD   *OBJseek_ar ();
extern ARNDX   *OBJread_ndx ();
extern ARTOC   *OBJread_toc ();
extern OBJINFO *OBJread ();
extern int      OBJwrite ();
extern int      OBJclose ();
#endif
#if defined(__cplusplus)
}
#endif

#endif
