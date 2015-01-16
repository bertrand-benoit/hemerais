<!--
  Hemera - Intelligent System (https://sourceforge.net/projects/hemerais)
  Copyright (C) 2010-2015 Bertrand Benoit <projettwk@users.sourceforge.net>
 
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3 of the License, or
  (at your option) any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License
  along with this program; if not, see http://www.gnu.org/licenses
  or write to the Free Software Foundation,Inc., 51 Franklin Street,
  Fifth Floor, Boston, MA 02110-1301  USA   
-->

<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="s" uri="/struts-tags" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<s:url id="index_en" action="%{#request['struts.actionMapping']['name']}">
  <s:param name="request_locale">en</s:param>
</s:url>
<s:url id="index_fr" action="%{#request['struts.actionMapping']['name']}">
  <s:param name="request_locale">fr</s:param>
</s:url>

<br />
<p>
  <s:text name="language.change"/>
  
  <!-- N.B.: does not show language which is already selected. -->
  <s:if test="%{#action['locale']['language']!='en'}">
    <s:a href="%{index_en}">
      <s:text name="language.en"/>
    </s:a>&nbsp;&nbsp;
  </s:if>

  <s:if test="%{#action['locale']['language']!='fr'}">
    <s:a href="%{index_fr}">
      <s:text name="language.fr"/>
    </s:a>
  </s:if>
</p>
