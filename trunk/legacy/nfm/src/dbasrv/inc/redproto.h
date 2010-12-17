extern long RED_ChangeLayerColor(long w,char *fname,long newcolor);
extern long RED_CleanupSelectedElements(short flag);
extern long RED_CloseWindow(long w);
extern long RED_CopyElement(void);
extern long RED_CreateNewRedlineLayer(long w,char *fname,
  struct redfileheader *header);
extern long RED_DeleteElement(void);
extern long RED_ExecuteCreateSymbol(char *rle,long width,long height,long bytes,char *desc,char *fname);
extern long RED_GetFileParameters(long w,struct redparams *user_params);
extern long RED_GetRedlineLayerColor(long w,char *fname,long *color);
extern long RED_GetSymbolBitmap(char **bit ,long *width,long *height,
  long ShouldIScale);
extern long RED_IsAnyLayerSelected(long w);
extern long RED_IsElementSelected(long w);
extern long RED_IsLayerCreated(long w);
extern long RED_IsLayerSelected(long w,char *fname);
extern long RED_IsRedlineElementPresent(long win);
extern long RED_IsRedlineLayerLoaded(long w);
extern long RED_IsUndoAvailable(long w);
extern long RED_LoadRasterRedlineLayer(long w,char *fname,long color);
extern long RED_LoadRedlineLayer(long w,char *fname,long color);
extern long RED_LoadSymbolFromFile(char *fname,long symno);
extern long RED_MoveElement(void);
extern long RED_ReadHeaderInfo(char *fname,struct redfileheader *header);
extern long RED_ReadSymbolDescriptions(char *fname,long *numdesc,char ***desc);
extern long RED_RedrawElementSelected(void);
extern long RED_SaveRedlineLayer(long w,struct redfileheader *header,
  char *fname);
extern long RED_SetFileParameters(long w,struct redparams *user_params,
  long params_set);
extern long RED_SetSelectMode(long mode);
extern long RED_Undo(long w);
extern long RED_UnloadRedlineLayer(long w,char *fname);
