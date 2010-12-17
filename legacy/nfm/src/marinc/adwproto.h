#ifdef PROTOTYPES
#define _(a) a
#else
#define _(a) ()
#endif
extern  void writedimstyle _((void));
extern  void writeentity1 _((void));
extern  void writeentity2 _((void));
extern  void writeheader _((void));
extern  void writeblockheader _((void));
extern  void writelayer _((void));
extern  void writeshapefile _((void));
extern  void writelinetype _((void));
extern  void writeregapp _((void));
extern  void writeview _((void));
extern  void writeucs _((void));
extern  void writevport _((void));
extern  void writevportenthdr _((short whichvportent));
extern  short writeextendeddata _((void));
extern  void startblockheaderwrite _((void));
extern  void startblockdefwrite _((void));
extern  void initializeblockdef _((long defno));
extern  void endblockdefwrite _((void));
extern  void startlayerwrite _((void));
extern  void startshapewrite _((void));
extern  void startlinetypewrite _((void));
extern  void startviewwrite _((void));
extern  void startentitywrite _((void));
extern  void startucswrite _((void));
extern  void startvportwrite _((void));
extern  void startextendeddatawrite _((void));
extern  void startvportenthdrwrite _((void));
extern  void startregappwrite _((void));
extern  void startdimstylewrite _((void));
extern  void terminatewrite _((void));
extern  short initializewrite _((char *fn,short buffersize));
extern  void generatehandle _((void));
extern  void inithandles _((void));
extern  void setoutputversion _((short version));
extern  void initad _((void));
extern  void emitentity _((void));
