<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:acl="xalan://org.mycore.access.MCRAccessManager" xmlns:mcr="http://www.mycore.org/"
  xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:encoder="xalan://java.net.URLEncoder"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="xalan xlink mcr i18n acl mods mcrxsl encoder" version="1.0">
  <xsl:param name="MCR.Users.Superuser.UserName" />
  <xsl:include href="mods-utils.xsl" />
  <xsl:include href="mods2html.xsl" />
  <xsl:include href="modsmetadata.xsl" />
  <xsl:include href="mods-highwire.xsl" />

  <xsl:include href="basket.xsl" />

  <xsl:include href="modshitlist-external.xsl" />  <!-- for external usage in application module -->
  <xsl:include href="modsdetails-external.xsl" />  <!-- for external usage in application module -->

  <xsl:variable name="head.additional">
    <xsl:if test="contains(/mycoreobject/@ID,'_mods_')">
      <!-- ==================== Highwire Press tags ==================== -->
      <xsl:apply-templates select="/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" mode="highwire" />
    </xsl:if>
  </xsl:variable>

  <xsl:template match="/mycoreobject[contains(@ID,'_mods_')]" mode="basketContent">
    <xsl:call-template name="objectLink">
      <xsl:with-param select="." name="mcrobj" />
    </xsl:call-template>
    <div class="description">
      <xsl:for-each select="./metadata/def.modsContainer/modsContainer/*">
<!-- Link to presentation, ?pt -->
        <xsl:for-each select="mods:identifier[@type='uri']">
          <a href="{.}">
            <xsl:value-of select="." />
          </a>
          <br />
        </xsl:for-each>
<!-- Place, ?pt -->
        <xsl:for-each select="mods:originInfo[not(@eventType) or @eventType='publication']/mods:place/mods:placeTerm[@type='text']">
          <xsl:value-of select="." />
        </xsl:for-each>
<!-- Author -->
        <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
          <xsl:if test="position()!=1">
            <xsl:value-of select="'; '" />
          </xsl:if>
          <xsl:apply-templates select="." mode="printName" />
          <xsl:if test="position()=last()">
            <br />
          </xsl:if>
        </xsl:for-each>
<!-- Shelfmark -->
        <xsl:for-each select="mods:location/mods:shelfLocator">
          <xsl:value-of select="." />
          <br />
        </xsl:for-each>
<!-- URN -->
        <xsl:for-each select="mods:identifier[@type='urn']">
          <xsl:value-of select="." />
          <br />
        </xsl:for-each>
      </xsl:for-each>
    </div>
  </xsl:template>

  <!--Template for title in metadata view: see mycoreobject.xsl -->
  <xsl:template priority="1" mode="title" match="/mycoreobject[contains(@ID,'_mods_')]">
    <xsl:variable name="mods-type">
      <xsl:apply-templates select="." mode="mods-type" />
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$mods-type='confpro'">
        <xsl:apply-templates select="./metadata/def.modsContainer/modsContainer/mods:mods" mode="mods.title.confpro" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title">
            <xsl:variable name="text">
              <xsl:choose>
                <xsl:when test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@transliteration]/mods:title">
                  <!-- TODO: if editor bug fixed -->
                  <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo[@transliteration]/mods:title" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:titleInfo/mods:title[1]" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="$text" disable-output-escaping="yes" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@ID" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mods.getObjectEditURL">
    <xsl:param name="id" />
    <xsl:param name="layout" select="'$'" />
    <xsl:param name="collection" select="''" />
    <xsl:choose>
      <xsl:when test="mcrxsl:resourceAvailable('actionmappings.xml')">
        <!-- URL mapping enabled -->
        <xsl:variable name="url">
          <xsl:choose>
            <xsl:when test="string-length($collection) &gt; 0">
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="actionmapping:getURLforCollection('update-xml',$collection,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="actionmapping:getURLforCollection('update',$collection,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$layout = 'all'">
                  <xsl:value-of select="actionmapping:getURLforID('update-xml',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="actionmapping:getURLforID('update',$id,true())" xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="string-length($url)=0" />
          <xsl:otherwise>
            <xsl:call-template name="UrlSetParam">
              <xsl:with-param name="url" select="$url"/>
              <xsl:with-param name="par" select="'id'"/>
              <xsl:with-param name="value" select="$id" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
      <!-- URL mapping disabled -->
        <xsl:variable name="layoutSuffix">
          <xsl:if test="$layout != '$'">
            <xsl:value-of select="concat('-',$layout)" />
          </xsl:if>
        </xsl:variable>
        <xsl:variable name="form" select="concat('editor_form_commit-mods',$layoutSuffix,'.xml')" />
        <xsl:value-of select="concat($WebApplicationBaseURL,$form,'?id=',$id)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
