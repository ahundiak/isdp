#if (SVR4 || SunOS)
#define  EXT  "so"
#else
#define  EXT  "o"
#endif

#if SVR4
#define  PFX  ""
#else
#define  PFX  "_"
#endif
