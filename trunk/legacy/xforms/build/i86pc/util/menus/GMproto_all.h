
/* GMHdrData.c */
extern int GMGetHdrData(struct GMHdrData *hdrData, struct GMParseFp *fp);
extern int GMInitHdrData(struct GMHdrData *hdrData);
extern int GMParseMenuType(char *token);
extern int GMParseVersion(char *token);
extern int GMParseMenuOption(struct GMHdrData *hdrData, char *token, struct GMParseFp *fp);
extern int GMFinishHdrData(struct GMHdrData *hdrData);
extern int GMFreeHdrData(struct GMHdrData *hdrData);

/* GMLineData.c */
extern int GMGetLineData(int *level, struct GMLineData **lineData, struct GMHdrData *hdrData, struct GMParseFp *fp);
extern int GMInitLineData(struct GMLineData **lineData);
extern int GMParseLineToken1(struct GMLineData *lineData, char *token, struct GMParseFp *fp);
extern int GMParseLineToken2(struct GMLineData *lineData, struct GMHdrData *hdrData, char *token, struct GMParseFp *fp);
extern int GMParseNewLines(char *textString);
extern int GMParseLineToken3(struct GMLineData *lineData, struct GMHdrData *hdrData, char *token, struct GMParseFp *fp);
extern int GMParseLineToken4(struct GMLineData *lineData, struct GMHdrData *hdrData, char *token, struct GMParseFp *fp);
extern int GMParseLineOption(struct GMLineData *lineData, char *token);
extern int GMFreeLineData(struct GMLineData *lineData, struct GMHdrData *hdrData);

/* GMMenu.c */
extern int GMWriteMenu(char *mnuFile, int menuType, struct GMPalette *palList, FILE *errFp);
extern int GMParseMenuName(char *mnuDir, char *palName, char *mnuFile);
extern int GMCreateMenuPal(Form *palPtr, int menuType, struct GMPalette *pal, FILE *errFp);
extern int GMWriteMenuPal(Form palPtr, char *tmpDir, char *palName, FILE *errFp);
extern int GMFreeMenuPal(struct GMPalette *palList);
extern int GMFreeMenuBtn(struct GMButton *btn);

/* GMMenuData.c */
extern int GMGetMenuData(int *menuType, struct GMPalette **palList, char *palPrefix, FILE *otlFp, FILE *errFp);
extern int GMGenMenuData(struct GMPalette **palList, char *palPrefix, struct GMHdrData *hdrData, struct GMOtlPalette *otlPalList);
extern struct GMPalette *GMGenPalette(struct GMOtlPalette *otlPal, char *palPrefix, int palOrg[][2 ]);
extern struct GMButton *GMGenButton(struct GMOtlPalette *otlPal, int numBtn, struct GMOtlButton *otlBtn, char *palPrefix);
extern int GMGenPalName(char *palName, char *otlPalName, char *palPrefix);

/* GMMergePanel.c */
extern int GMMergePanels(struct GMPalette **palList, char *menuList[], int numMenu, FILE *errFp);
extern void GMGenBtnList(Form pnlPtr, int label, struct GMButtonList *btnList);
extern struct GMButton *GMCopyButton(Form *pnlPtr, int label);

/* GMOtlData.c */
extern int GMGetOtlData(struct GMOtlPalette **otlPalList, struct GMHdrData *hdrData, struct GMParseFp *fp);
extern struct GMOtlPalette *GMAddOtlPal(struct GMOtlPalette *palHdr, struct GMLineData *lineData, int level, struct GMHdrData *hdrData);
extern int GMFinishOtlPal(struct GMOtlPalette *otlPal);
extern struct GMOtlButton *GMAddOtlBtn(struct GMOtlPalette *curPal, struct GMLineData *lineData, struct GMHdrData *hdrData);
extern int GMFreeOtlData(int dummyFlag, struct GMOtlPalette *otlPalList, struct GMHdrData *hdrData);

/* GMParser.c */
extern int GMGetLine(struct GMParseFp *fp, char *buf, int bufLen);
extern int GMParseToken(char *token, char *line);
extern int GMParseKeyword(union GMTokenData *data, char *token);
extern int GMParseYesNo(char *token);
extern int GMParseColor(char *token);
extern int GMParseStyle(char *token);
extern int GMParseJust(char *token);
extern int GMParseLevel(char *line);

/* GMPrintDesc.c */
extern int GMPrintDesc(char *mnuFile, int menuType, struct GMPalette *palList);

/* genmenu.c */
extern int GMParseCmdLine(char *otlFile, char *mnuFile, char *palPrefix, int cmdOpts[], int argc, char *argv[]);

/* mrgpanel.c */
extern int main(int argc, char *argv[]);
extern int GMPParseCmdLine(int *mnuIdx, int cmdOpts[], int argc, char *argv[]);
