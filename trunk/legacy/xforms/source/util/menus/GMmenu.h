#ifndef GMmenu_include
#define	GMmenu_include


/************/
/** Macros **/
/************/

#define	GM_FILENAME_LEN	128


/*********************/
/** Data Structures **/
/*********************/

struct	GMPalette
{
	char			name[16];

	int			xPos;
	int			yPos;
	int			xSize;
	int			ySize;

	int			remember;

	struct	GMButton	*buttons;

	struct	GMPalette	*nextPal;
};

struct	GMButton
{
	struct	standard_st	std;

	int			textStyle;
	int			textJust;

	char			palName[16];

	struct	GMButton	*nextBtn;
};

struct  GMButtonList
{
  int    numBtn;
  int    numAlloc;
  int   *btnLabel;
};

#endif
