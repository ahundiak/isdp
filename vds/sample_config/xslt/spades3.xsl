<?xml version='1.0'?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" standalone="yes" indent="yes"/>

  <xsl:template match="/PDF_OBJ_ROOT/PDF_OBJ_TREE">
    <ROWS>
     <xsl:for-each select="//PDF_OBJ_TREE_NODE">
       <ROW>
       <xsl:value-of select="name() " />
       <xsl:text> </xsl:text>
       <xsl:value-of select="@PDF_ATR_TREE_NODE_TYPE" />
       <xsl:text> </xsl:text>
       <xsl:value-of select="@PDF_ATR_TREE_NODE_NAME" />
       </ROW>
     </xsl:for-each>
   </ROWS>
 </xsl:template>

  <xsl:template match="/PDF_OBJ_ROOT/PDF_OBJ_PLATES">
    <ROWS>
     <xsl:for-each select="PDF_OBJ_PLATE">
       <ROW>
       <xsl:value-of select="name() " />
       <xsl:text> </xsl:text>
       <xsl:value-of select="@PDF_ATR_TREE_NODE_NAME" />
       <xsl:text> PCMK </xsl:text>
       <xsl:value-of select="@PDF_ATR_TREE_NODE_PCMK" />
       </ROW>

     </xsl:for-each>
   </ROWS>
 </xsl:template>

  <xsl:template match="/PDF_OBJ_ROOT/PDF_OBJ_SETUP"></xsl:template>
  <xsl:template match="/PDF_OBJ_ROOT/PDF_OBJ_SHIP"> </xsl:template>

</xsl:stylesheet>
