#ifndef NFMDEBUG_H
#define NFMDEBUG_H

#ifndef NFM_DEBUG_SUBSYSTEMS
#define NFM_DEBUG_SUBSYSTEMS 15
#endif
#ifndef NFM_DEBUG_FILE_SIZE
#define NFM_DEBUG_FILE_SIZE  80
#endif

/*  Maximum length of debug file names  */

#define NFM_DEBUG_FILE_SIZE  80

/*  Debug subsystem definitions  */

#define NFIDEBUG    1
#define NFMRDEBUG   2
#define NETCDEBUG   3
#define NETSDEBUG   4
#define NFMSDEBUG   5
#define NFMDEBUG    6
#define SQLDEBUG    7
#define MEMDEBUG    8
#define UTIDEBUG    9
#define ERRDEBUG   10
#define TLIDEBUG   11  /* PS */

/*  Debug structure definition  */

struct _NFMdebug_st
  {
    short   subsystem;
    short   NFIdebug_on;
    short   NFMRdebug_on;
    short   NETCdebug_on;
    short   NETSdebug_on;
    short   NFMSdebug_on;
    short   NFMdebug_on;
    short   SQLdebug_on;
    short   MEMdebug_on;
    short   UTIdebug_on;
    short   ERRdebug_on;
    short   TLIdebug_on;  /* PS */

    char    NFIdebug_file[NFM_DEBUG_FILE_SIZE];
    char    NFMRdebug_file[NFM_DEBUG_FILE_SIZE];
    char    NETCdebug_file[NFM_DEBUG_FILE_SIZE];
    char    NETSdebug_file[NFM_DEBUG_FILE_SIZE];
    char    NFMSdebug_file[NFM_DEBUG_FILE_SIZE];
    char    NFMdebug_file[NFM_DEBUG_FILE_SIZE];
    char    SQLdebug_file[NFM_DEBUG_FILE_SIZE];
    char    MEMdebug_file[NFM_DEBUG_FILE_SIZE];
    char    UTIdebug_file[NFM_DEBUG_FILE_SIZE];
    char    ERRdebug_file[NFM_DEBUG_FILE_SIZE];
    char    TLIdebug_file[NFM_DEBUG_FILE_SIZE]; /* PS */
  };

/*  Debug macros for all major I/NFM subsystems  */

extern struct _NFMdebug_st _NFMdebug_st;

#define _NFIdebug(s) \
if (_NFMdebug_st.NFIdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = NFIDEBUG; \
    _NFMdebug_function s; \
  }

#define _NFMRdebug(s) \
if (_NFMdebug_st.NFMRdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = NFMRDEBUG; \
    _NFMdebug_function s; \
  }

#define _NETCdebug(s) \
if (_NFMdebug_st.NETCdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = NETCDEBUG; \
    _NFMdebug_function s; \
  }

#define _NETSdebug(s) \
if (_NFMdebug_st.NETSdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = NETSDEBUG; \
    _NFMdebug_function s; \
  }

#define _NFMSdebug(s) \
if (_NFMdebug_st.NFMSdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = NFMSDEBUG; \
    _NFMdebug_function s; \
  }

#define _NFMdebug(s) \
if (_NFMdebug_st.NFMdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = NFMDEBUG; \
    _NFMdebug_function s; \
  }

#define _SQLdebug(s) \
if (_NFMdebug_st.SQLdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = SQLDEBUG; \
    _NFMdebug_function s; \
  }

#define _MEMdebug(s) \
if (_NFMdebug_st.MEMdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = MEMDEBUG; \
    _NFMdebug_function s; \
  }

#define _UTIdebug(s) \
if (_NFMdebug_st.UTIdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = UTIDEBUG; \
    _NFMdebug_function s; \
  }

#define _ERRdebug(s) \
if (_NFMdebug_st.ERRdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = ERRDEBUG; \
    _NFMdebug_function s; \
  }

#define _TLIdebug(s) \
if (_NFMdebug_st.TLIdebug_on != 0) \
  { \
    _NFMdebug_st.subsystem = TLIDEBUG; \
    _NFMdebug_function s; \
  }

#endif
