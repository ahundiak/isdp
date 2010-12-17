#ifdef PROTOTYPES
#define _(a) a
#else
#define _(a) ()
#endif
extern  void  endblockdefread _((void));
extern  short initializeread _((char *fn,unsigned short buffersize,unsigned short blkbufsize, unsigned short extbufsize));
extern  short readentity1 _((void));
extern  short readentity2 _((void));
extern  short readextendeddata _((void));
extern  short readheader _((void));
extern  short readlayer _((void));
extern  short readlinetype _((void));
extern  short readblockheader _((void));
extern  void  readdimstyle _((void));
extern  void  readregapp _((void));
extern  short readshapefile _((void));
extern  void  readucs _((void));
extern  short readview _((void));
extern  short readvport _((void));
extern  void  readvportenthdr _((void));
extern  void  startblockheaderread _((void));
extern  void  startblockdefread _((void));
extern  void  startdimstyleread _((void));
extern  void  startentityread _((void));
extern  void  startextendeddataread _((void));
extern  void  startlayerread _((void));
extern  void  startlinetyperead _((void));
extern  void  startregappread _((void));
extern  void  startshaperead _((void));
extern  void  startucsread _((void));
extern  void  startviewread _((void));
extern  void  startvportread _((void));
extern  void  startvportenthdrread _((void));
extern  void  terminateread _((void));
extern  void  initad _((void));
extern  short distancethroughentities _((void));
extern  void  saveentreadloc _((void));
extern  void  restoreentreadloc _((void));

