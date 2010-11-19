#ifndef NFM_SCHEMA_H
#define NFM_SCHEMA_H

/*******************************************************/
/*                                                     */
/* This include file defines the maximum sizes for all */
/* I/NFM schema attributes for 3.0 I/NFM.              */
/*                                                     */
/* KAREN TICE - July 30, 1991                          */
/* Glenn Scott - 2/26/92 Added #ifdef wrapper          */
/*                                                     */
/* Note: When using these definitions for declaring    */
/*       array sizes, use definition + 1.              */
/* Example:                                            */
/*    char storage_area_name[NFM_SANAME+1];            */
/*                                                     */
/*******************************************************/

/* define INTEGER to be 15 */
#define INTEGER  15

/* define DATE to be 20 */
#define DATE  20

/*      DEFINITION              SIZE          TABLES               */

#define NFM_ACLNAME             20         /* NFMACLS, NFMACTIVITY */
#define NFM_ACLNO               INTEGER    /* NFMACLS, NFMACLUSERS,
                                              NFMCATALOGACLMAP, NFMCATALOGS,
                                              NFMPROJECTS, NFMSIGNOFFUSERS,
                                              NFMWORKFLOW, <CATALOG> */
#define NFM_APPLICATION         3          /* NFMATTRIBUTES, NFMCOMMANDS, 
                                              NFMPROJECTS, NFMREPORTS, 
                                              NFMSYSATTRIBUTES, NFMUSERS */
#define NFM_APPTYPE             1          /* NFMREPORTS */
#define NFM_ARCHIVECOPIES       INTEGER    /* NFMARCHIVES */
#define NFM_ARCHIVEDATE         DATE       /* NFMARCHIVES */
#define NFM_ARCHIVEFLAG         1          /* NFMPROJECTCIT, NFMSETCIT */
#define NFM_ARCHIVEMETHOD       1          /* NFMARCHIVES */
#define NFM_ARCHIVENO           INTEGER    /* NFMARCHIVES, NFMCATALOGS,
                                              NFMPROJECTCIT, NFMPROJECTS,
                                              NFMSAVESETS, NFMSETCIT,
                                              F_<CATALOG> */
#define NFM_ARCHIVESIZE         INTEGER    /* NFMARCHIVES */
#define NFM_ARCHIVESTATE        1          /* NFMCATALOGS, NFMPROJECTS,
                                              <CATALOG> */
#define NFM_ATTRNO              INTEGER    /* NFMATTRIBUTES, NFMSYSATTRIBUTES,
                                              NFMVALUES */
#define NFM_CATALOGDESC         40         /* NFMCATALOGS */
#define NFM_CATALOGNAME         20         /* NFMACTIVITY, NFMCATALOGS */
#define NFM_CATALOGNO           INTEGER    /* NFMCATALOGACLMAP, NFMCATALOGS,
                                              NFMCATALOGSAMAP, NFMPROJECTCIT,
                                              NFMSAFILES, NFMSAVESETS,
                                              NFMSIGNOFF, NFMUSERS */
#define NFM_CCATALOGNO          INTEGER    /* NFMSETCIT */
#define NFM_CHECKIN             1          /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_CHECKOUT            1          /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_CIDATE              DATE       /* F_<CATALOG> */
#define NFM_CIFILENAME          128        /* F_<CATALOG> */
#define NFM_CIFILESIZE          INTEGER    /* F_<CATALOG> */
#define NFM_CISANO              INTEGER    /* NFMSAFILES, F_<CATALOG> */
#define NFM_CITEMNO             INTEGER    /* NFMSETCIT */
#define NFM_CITNO               INTEGER    /* NFMPROJECTCIT, NFMSETCIT */
#define NFM_CIUSER              14         /* F_<CATALOG> */
#define NFM_CLASSNAME           20         /* NFMCLASSES */
#define NFM_CLASSNO             INTEGER    /* NFMACCESS, NFMACLUSERS,
                                              NFMCLASSES */
#define NFM_CO                  1          /* NFMSAFILES */
#define NFM_COCOMMENT           40         /* F_<CATALOG> */
#define NFM_CODATE              DATE       /* F_<CATALOG> */
#define NFM_COFILENAME          128        /* F_<CATALOG> */
#define NFM_COLEVEL             INTEGER    /* <CATALOG> */
#define NFM_COMMANDNAME         100        /* NFMACTIVITY, NFMCOMMANDS */
#define NFM_COMMANDNO           INTEGER    /* NFMCOMMANDS, NFMTRANSITIONS */
#define NFM_COMPLETE            1          /* NFMACLS */
#define NFM_COMPRESS            1          /* NFMSTORAGEAREA */
#define NFM_CONVERTIND          1          /* F_<CATALOG> */
#define NFM_COPY                1          /* NFMSAFILES */
#define NFM_COSANO              INTEGER    /* F_<CATALOG> */
#define NFM_COUSER              14         /* F_<CATALOG> */
#define NFM_CREATIONDATE        DATE       /* NFMCATALOGS, NFMPROJECTS,
                                              <CATALOG> */
#define NFM_CREATOR             14         /* NFMCATALOGS, <CATALOG> */
#define NFM_DATATYPE            15         /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_DATE                DATE       /* NFMACTIVITY, NFMUSERS */
#define NFM_DECNET              1          /* NFMNODES */
#define NFM_DEFAULTNO           INTEGER    /* NFMVALUES */
#define NFM_DEFAULTVALUE        40         /* NFMVALUES */
#define NFM_DELETE              1          /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_DESCRIPTION         40         /* NFMSYSCAT */
#define NFM_DEVICETYPE          2          /* NFMSTORAGEAREA */
#define NFM_EMAILADDR           60         /* NFMUSERS */
#define NFM_ENTITY              1          /* NFMCOMMANDS */
#define NFM_EXPIRATIONDATE      DATE       /* NFMARCHIVES */
#define NFM_FAILREASON          80         /* NFMACTIVITY */
#define NFM_FILECLASS           1          /* F_<CATALOG> */
#define NFM_FILECO              1          /* F_<CATALOG> */
#define NFM_FILENAME            512        /* NFMSAFILES */
#define NFM_FILENO              INTEGER    /* NFMSAVESETS, F_<CATALOG> */
#define NFM_FILENUM             INTEGER    /* NFMSAFILES, F_<CATALOG> */
#define NFM_FILETYPE            5          /* F_<CATALOG> */
#define NFM_FILEVERSION         INTEGER    /* F_<CATALOG> */
#define NFM_FROMSTATE           INTEGER    /* NFMTRANSITIONS */
#define NFM_GROUP               20         /* NFMUSERS */
#define NFM_HISTORY             1          /* NFMSIGNOFF */
#define NFM_ICONNAME            40         /* <CATALOG> */
#define NFM_IDENTIFIER          20         /* NFMCATALOGS, NFMTABLES */
#define NFM_INDEXSLOT           INTEGER    /* NFMINDEX */
#define NFM_INFOTYPE            20         /* NFMSYSCAT */
#define NFM_ITEMDESC            240         /* <CATALOG> */
#define NFM_ITEMLOCK            1          /* <CATALOG> */
#define NFM_ITEMNAME            60         /* NFMACTIVITY, <CATALOG> */
#define NFM_ITEMNO              INTEGER    /* NFMPROJECTCIT, NFMSAFILES,
                                              NFMSAVESETS, NFMSIGNOFF,
                                              NFMUSERS, <CATALOG> */
#define NFM_ITEMNUM             INTEGER    /* F_<CATALOG> */
#define NFM_ITEMREV             60         /* NFMACTIVITY, <CATALOG> */
#define NFM_ITEMSTATE           1          /* NFMSAVESETS */
#define NFM_JOINATTRNO          INTEGER    /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_JOINTABLE           1          /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_LABEL               10         /* NFMARCHIVES */
#define NFM_LATTRNO             INTEGER    /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_LGFILETYPE          40         /* <CATALOG> */
#define NFM_LISTNAME            20         /* NFMLISTS */
#define NFM_LISTNO              INTEGER    /* NFMLISTS, NFMVALUES */
#define NFM_LOGONFAILURE        1          /* NFMTRANSITIONS */
#define NFM_LOGONSUCCESS        1          /* NFMTRANSITIONS */
#define NFM_MACHID              10         /* NFMNODES */
#define NFM_MAJORITY            2          /* NFMSTATES */
#define NFM_MAPNO               INTEGER    /* NFMCATALOGACLMAP, NFMCATALOGSAMAP,
                                              NFMPROJECTACLMAP, NFMPROJECTSAMAP */
#define NFM_MAXVALUE            40         /* NFMVALUES */
#define NFM_MINVALUE            40         /* NFMVALUES */
#define NFM_MOUNTPOINT          80         /* NFMSAFILES */
#define NFM_NAME                20         /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_NETWARE             1          /* NFMNODES */
#define NFM_NEWSTATENAME        40         /* NFMACTIVITY */
#define NFM_NFMCOMMANDNO        INTEGER    /* NFMCOMMANDS */
#define NFM_NFS                 1          /* NFMNODES, NFMSAFILES, 
                                              NFMSTORAGEAREA */
#define NFM_NODEDESC            40         /* NFMNODES */
#define NFM_NODENAME            30         /* NFMNODES */
#define NFM_NODENO              INTEGER    /* NFMNODES, NFMSTORAGEAREA */
#define NFM_NOTIFY              1          /* NFMTRANSITIONS */
#define NFM_NOVOL               INTEGER    /* NFMARCHIVES */
#define NFM_NULL                1          /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_OLDSTATENAME        40         /* NFMACTIVITY */
#define NFM_OPSYS               10         /* NFMNODES */
#define NFM_OVERRIDE            1          /* NFMSIGNOFFUSERS */
#define NFM_OWNER               INTEGER    /* NFMREPORTS, NFMSTORAGEAREA */
#define NFM_PARTITION           3          /* NFMSTORAGEAREA */
#define NFM_PASSWD              50         /* NFMSTORAGEAREA, NFMUSERS */
#define NFM_PATHNAME            80         /* NFMSTORAGEAREA */
#define NFM_PCATALOGNO          INTEGER    /* NFMSETCIT */
#define NFM_PENDINGFLAG         2          /* NFMCATALOGS, NFMPROJECTS,
                                              <CATALOG> */
#define NFM_PITEMNO             INTEGER    /* NFMSETCIT */
#define NFM_PLATTERNAME         16         /* NFMSTORAGEAREA */
#define NFM_PREPOST             1          /* NFMPROCESSES */
#define NFM_PREVSTATENO         INTEGER    /* <CATALOG> */
#define NFM_PROGRAMFILE         14         /* NFMPROGRAMS */
#define NFM_PROGRAMDESC         40         /* NFMPROGRAMS */
#define NFM_PROGRAMNAME         20         /* NFMPROGRAMS */
#define NFM_PROGRAMNO           INTEGER    /* NFMPROCESSES, NFMPROGRAMS,
                                              NFMVALUES */
#define NFM_PROJECTDESC         40         /* NFMPROJECTS */
#define NFM_PROJECTMGR          14         /* NFMPROJECTS */
#define NFM_PROJECTNAME         20         /* NFMACTIVITY, NFMPROJECTS */
#define NFM_PROJECTNO           INTEGER    /* NFMACLS, NFMPROJECTACLMAP, 
                                              NFMPROJECTCIT, NFMPROJECTS, 
                                              NFMPROJECTSAMAP, NFMUSERS */
#define NFM_PROJECTNUM          20         /* NFMPROJECTS */
#define NFM_READ                1          /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_REASON              40         /* NFMSIGNOFF */
#define NFM_REF                 INTEGER    /* NFMSAFILES */
#define NFM_REPORTDESC          40         /* NFMREPORTS */
#define NFM_REPORTFILE          14         /* NFMREPORTS */
#define NFM_REPORTNAME          20         /* NFMREPORTS */
#define NFM_REPORTNO            INTEGER    /* NFMREPORTS */
#define NFM_RESTOREDATE         DATE       /* NFMSAVESETS */
#define NFM_RESTOREFLAG         2          /* F_<CATALOG> */
#define NFM_RESTORENO           INTEGER    /* NFMSAVESETS */
#define NFM_ROWNO               INTEGER    /* NFMSYSCAT */
#define NFM_SANAME              30         /* NFMSTORAGEAREA */
#define NFM_SANO                INTEGER    /* NFMARCHIVES, NFMCATALOGSAMAP,
                                              NFMSAFILES, NFMSTORAGEAREA,
                                              NFMUSERS */
#define NFM_SAVESET             20         /* NFMARCHIVES */
#define NFM_SEARCHNO            INTEGER    /* NFMUSERS */
#define NFM_SEQNO               INTEGER    /* NFMATTRIBUTES, NFMPROCESSES,
                                              NFMSTATES, NFMSYSATTRIBUTES */
#define NFM_SETCATNO            INTEGER    /* NFMUSERS */
#define NFM_SETINDICATOR        1          /* <CATALOG> */
#define NFM_SETITEMNO           INTEGER    /* NFMUSERS */
#define NFM_SIGNOFF             1          /* NFMSIGNOFF */
#define NFM_SIGNOFFS            INTEGER    /* NFMSTATES */
#define NFM_SORTNO              INTEGER    /* NFMUSERS */
#define NFM_STATEDESC           40         /* NFMSTATES */
#define NFM_STATENAME           40         /* NFMSTATES */
#define NFM_STATENO             INTEGER    /* NFMCATALOGS, NFMPROJECTS,
                                              NFMSIGNOFF, NFMSIGNOFFUSERS,
                                              NFMSTATES, NFMWORKFLOW,
                                              <CATALOG> */
#define NFM_STATUS              2          /* <CATALOG> */
#define NFM_SUCCESSFAIL         INTEGER    /* NFMACTIVITY */
#define NFM_SYNONYM             40         /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_TABLENAME           20         /* NFMINDEX, NFMTABLES */
#define NFM_TABLENO             INTEGER    /* NFMATTRIBUTES, NFMSYSATTRIBUTES,
                                              NFMTABLES */
#define NFM_TABLETYPE           20         /* NFMREPORTS, NFMTABLES */
#define NFM_TCPIP               1          /* NFMNODES */
#define NFM_TOSTATE             INTEGER    /* NFMTRANSITIONS */
#define NFM_TRANSCOMMAND        1          /* NFMCOMMANDS */
#define NFM_TRANSFROM           1          /* NFMSTATES */
#define NFM_TRANSITIONNAME      80         /* NFMACTIVITY, NFMTRANSITIONS */
#define NFM_TRANSITIONNO        INTEGER    /* NFMACCESS, NFMPROCESSES,
                                              NFMTRANSITIONS */
#define NFM_TRANSTO             1          /* NFMSTATES */
#define NFM_TYPE                3          /* NFMCATALOGS, NFMPROJECTCIT,
                                              NFMREPORTS, NFMSETCIT,
                                              NFMSTORAGEAREA, NFMVALUES */
#define NFM_UPDATE              1          /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_UPDATEDATE          DATE       /* NFMCATALOGS, <CATALOG> */
#define NFM_UPDATER             14         /* NFMCATALOGS, <CATALOG> */
#define NFM_USERDESC            40         /* NFMUSERS */
#define NFM_USERNAME            14         /* NFMACTIVITY, NFMSTORAGEAREA,
                                              NFMUSERS */
#define NFM_USERNO              INTEGER    /* NFMACLUSERS, NFMSIGNOFF,
                                              NFMSIGNOFFUSERS‚, NFMUSERS */
#define NFM_VALUE               40         /* NFMLISTS */
#define NFM_VALUE2              40         /* NFMLISTS */
#define NFM_VERSIONLIMIT        INTEGER    /* <CATALOG> */
#define NFM_WORKFLOWDESC        40         /* NFMWORKFLOW */
#define NFM_WORKFLOWNAME        20         /* NFMACTIVITY, NFMWORKFLOW */
#define NFM_WORKFLOWNO          INTEGER    /* NFMACLS, NFMCLASSES,
                                              NFMSTATES, NFMTRANSITIONS,
                                              NFMWORKFLOW */
#define NFM_WORKFLOWTYPE        1          /* NFMWORKFLOW */
#define NFM_WRITE               1          /* NFMATTRIBUTES, NFMSYSATTRIBUTES */
#define NFM_XNS                 1          /* NFMNODES */

#endif
