#define ERROR_CHK if(!(sts & 0x00000001))				       \
	{ printf("\n\nRAP: error at line %d in \"%s\"\n",__LINE__,__FILE__);   \
	  om$report_error(sts=sts);					       \
	  return(OM_S_SUCCESS); }

#define RAP_EOF		-1
#define CREATE           1

#define DEFAULT_FILE	"rap.u"

#define NOD_NAME	"RAPnod"
#define LISTENER_NAME	"RAPlistener"

/*
#define RAP_DEBUG
*/
