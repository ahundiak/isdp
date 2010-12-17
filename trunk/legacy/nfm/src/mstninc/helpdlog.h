/*----------------------------------------------------------------------+
|									|
|   helpdlog.h  -- Resource IDs used in MicroStation Help		|
|									|
|									|
+----------------------------------------------------------------------*/
/*----------------------------------------------------------------------+
|									|
|   Current Revision:							|
|   $Header: /usr2/pinnacle/division/nfmspc/nfm/mstninc/RCS/helpdlog.h 1.1 1995/10/17 23:24:04 pinnacle Exp $
|									|
+----------------------------------------------------------------------*/
#ifndef __helpdlogH__
#define __helpdlogH__

#ifndef __basetypeH__
#include <basetype.h>
#endif

#define HELPRSC_ARTICLE   	0x48456172    /* 'HEar' */
#define HELPRSC_COMMAND	    	0x4845636d    /* 'HEcm' */
#define HELPRSC_INDEX	    	0x48456478    /* 'HEdx' */
#define HELPRSC_TOPIC	    	0x48457470    /* 'HEtp' */

#define RSCID_TASKIDLIST    	0x5441534B    /* 'TASK' */
#define RSCID_TITLELIST    	0x5449544C    /* 'TITL' */

typedef struct helpCommand
    {
    ULong    	messageListIndex;
    ULong    	articleId;
    } HelpCommand;

typedef HelpCommand    HelpTopic;

#ifdef resource
resourceclass HelpTopic	    	HELPRSC_TOPIC;
resourceclass HelpCommand    	HELPRSC_COMMAND;
#endif

#ifdef resource
typedef struct helpIndex
    {
    ULong    	type;
    ULong    	articleId;
    } HelpIndex [];
resourceclass HelpIndex	    	HELPRSC_INDEX;
#else
typedef struct helpIndex
    {
    long    	count;
    struct
	{
    	ULong  	type;
    	ULong  	articleId;
	} link[1];
    } HelpIndex;
#endif


typedef struct xReference
    {
    ULong    	type;
    ULong    	articleId;
    int	    	taskIndex;
    } XReference;

typedef struct helpArticle
    {
#ifdef resource
    XReference	    subtopic[];
    XReference	    seeAlso[];
    char    	    text[];
#else
    ULong    	    subtopicCount;
    XReference	    subtopic[1];
    ULong    	    seeAlsoCount;
    XReference	    seeAlso[1];
    long    	    textLength;
    char    	    text[1];
#endif
    } HelpArticle;

#ifdef resource
resourceclass HelpArticle    	HELPRSC_ARTICLE;
#endif

#endif
