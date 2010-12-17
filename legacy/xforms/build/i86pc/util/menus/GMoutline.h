#ifndef	GMoutline_include
#define	GMoutline_include


/************/
/** Macros **/
/************/

#define	TRUE	1
#define	FALSE	0

#define	PARSE_BUF_LEN	512

#define	NULLCHAR	'\0'
#define	TAB		'\t'
#define	EOL		'\n'
#define	DQUOTE		'\"'
#define	COMMENT		'#'
#define	ASTERISK	'*'
#define	DELIMETER	','
#define	DOT		'.'
#define	BACKSLASH	'\\'
#define	UNDERBAR	'_'

#define	UNDEFINED_DATA	-1

#define	MAX_KEYWORDS	26
#define	UNDEF_KEYWORD	-1
#define	KEY_X		 0
#define	KEY_Y		 1
#define	KEY_NUM		 2
#define	KEY_NUM2	 3
#define	KEY_NUM3	 4
#define	KEY_NUM4	 5
#define	KEY_HT		 6
#define	KEY_HT2		 7
#define	KEY_HT3		 8
#define	KEY_HT4		 9
#define	KEY_WD		10
#define	KEY_WD2		11
#define	KEY_WD3		12
#define	KEY_WD4		13
#define	KEY_REM		14
#define	KEY_CMD		15
#define	KEY_OFF		16
#define	KEY_ON		17
#define	KEY_OFF2	18
#define	KEY_ON2		19
#define	KEY_HELP	20
#define	KEY_SYM		21
#define	KEY_FONT	22
#define	KEY_SIZE	23
#define	KEY_STYLE	24
#define	KEY_JUST	25

#define	INT_TOKEN	0
#define	DBL_TOKEN	1
#define	CHAR_TOKEN	2
#define	YESNO_TOKEN	3
#define	COLOR_TOKEN	4
#define	STYLE_TOKEN	5
#define	JUST_TOKEN	6

#define	MAX_MENU_TYPES	3

#define	MAX_LEVELS	4

#define	PANEL_XORG		998
#define	PANEL_YORG		0
#define	PANEL_PAL_WIDTH		180
#define	PANEL_PAL_HEIGHT	830
#define	PANEL_NUM_COLUMN1	4
#define	PANEL_NUM_COLUMN2	3
#define	PANEL_NUM_COLUMN3	3
#define	PANEL_NUM_COLUMN4	2
#define	PANEL_BTN_WIDTH1	45
#define	PANEL_BTN_WIDTH2	60
#define	PANEL_BTN_WIDTH3	60
#define	PANEL_BTN_WIDTH4	90
#define	PANEL_BTN_HEIGHT1	35
#define	PANEL_BTN_HEIGHT2	45
#define	PANEL_BTN_HEIGHT3	45
#define	PANEL_BTN_HEIGHT4	60

#define	BAR_XORG	152
#define	BAR_YORG	0
#define	BAR_BTN_WIDTH	42
#define	BAR_BTN_HEIGHT	40

#define	POCKET_XORG		0
#define	POCKET_YORG		0
#define	POCKET_NUM_COLUMN	6
#define	POCKET_BTN_WIDTH	45
#define	POCKET_BTN_HEIGHT	45

#define	PLAIN_STRING	0
#define	QUOTED_STRING	1
#define	STARRED_STRING	2

#define	SYM_GRAFIX	0
#define	TEXT_GRAFIX	1

#define	NUM_SYMBOLS	2

#define	NUM_COLORS	4
#define	OFF_COLOR1	0
#define	ON_COLOR1	1
#define	OFF_COLOR2	2
#define	ON_COLOR2	3


#define	BORDER_WIDTH	3


/*********************/
/** Data Structures **/
/*********************/

union	GMTokenData
{
	int	ival;
	double	dval;
	char	aval[PARSE_BUF_LEN];
};

struct	GMParseFp
{
	FILE	*in;
	int	line;
	FILE	*err;
};

struct	GMHdrData
{
	int		menuType;

	int		xOrg;
	int		yOrg;

	struct
	{
	int	numColumn;
	int	numRow;
	int	btnHeight;
	int	btnWidth;
	}		level[MAX_LEVELS];

	int		remember;

	char		*symFile;

	char		*fontName;
	float		bodySize;
	int		textStyle;
	int		textJust;

	int		color[NUM_COLORS];
};

struct	GMLineData
{
	int	nameType;
	char	*name;

	int	numBtn;

	int	numColumn;
	int	numRow;
	int	btnHeight;
	int	btnWidth;

	int	remember;

	int	cmdType;
	char	*cmdString;

	int	grafixType;

	char	*symFile;
	int	symbol[NUM_SYMBOLS];

	char	*textString;
	char	*fontName;
	float	bodySize;
	int	textStyle;
	int	textJust;

	int	color[NUM_COLORS];

	char	*helpTopic;
};

struct	GMOtlPalette
{
	struct	GMLineData	*data;
	int			level;
	struct	GMOtlButton	*buttons;
	struct	GMOtlPalette	*nextPal;
	struct	GMOtlPalette	*prevPal;
};

struct	GMOtlButton
{
	struct	GMLineData	*data;
	struct	GMOtlPalette	*palette;
	struct	GMOtlButton	*nextBtn;
	struct	GMOtlButton	*prevBtn;
};


#endif
