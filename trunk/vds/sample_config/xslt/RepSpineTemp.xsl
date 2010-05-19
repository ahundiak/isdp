<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
      <table name="Spine Template Report"
             description="Spine Template Report" >
	<layout>
	  <column title="Frame Name"    column_no="1"/>
	  <column title="Chord Height"  column_no="2"/>
        </layout>
        <xsl:for-each select="SMS_PRS/SMS_PRS_UNIT/SMS_TEMPLATES/SMS_TEMPLATE">
	  <row>
	     <cell column_no="1" value="Name: {SMS_SPI_TEMP/@NAME}"/>
	     <cell column_no="2" value=""/>
          </row>
          <row>
	     <cell column_no="1" value="Frame Name" />
	     <cell column_no="2" value="Chord Height" />
          </row>
          <xsl:for-each select="SMS_SPI_TEMP/CHT_INFO">
	     <row>
                <cell column_no="1" value="{@FRM_NAME}" />
                <cell column_no="2" value="{@CHT_HEIGHT}" />
             </row>
          </xsl:for-each>
	</xsl:for-each>
     </table>
  </xsl:template>
</xsl:stylesheet>
