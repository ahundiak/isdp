#ifdef DEBUG
#define MF_EMerr_hndlr( a, b, c, e ) \
        { \
        if( a ) \
        fprintf(stderr, "%d %s\n", __LINE__, __FILE__); \
        EMerr_hndlr( a, b, c, e ) \
        }
#else
#define MF_EMerr_hndlr( a, b, c, e ) \
        EMerr_hndlr( a, b, c, e )
#endif
