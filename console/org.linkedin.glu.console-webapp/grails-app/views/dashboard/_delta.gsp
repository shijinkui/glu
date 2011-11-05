%{--
  - Copyright (c) 2010-2010 LinkedIn, Inc
  - Portions Copyright (c) 2011 Yan Pujante
  -
  - Licensed under the Apache License, Version 2.0 (the "License"); you may not
  - use this file except in compliance with the License. You may obtain a copy of
  - the License at
  -
  - http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
  - WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
  - License for the specific language governing permissions and limitations under
  - the License.
  --}%

<%@ page import="org.linkedin.glu.console.filters.UserPreferencesFilters; org.linkedin.glu.grails.utils.ConsoleConfig; org.linkedin.glu.agent.tracker.AgentsTracker.AccuracyLevel" %>
<table class="bordered-table condensed-table">
  <tr>
    <th>System</th>
    <td class="systemId"><g:link controller="model" action="view" id="${system.id}">${system.id}</g:link></td>
    <th>Filter</th>
    <td><g:if test="${request.system.filters}">${request.system.filters.toString().encodeAsHTML()}</g:if><g:else>-</g:else></td>
  </tr>
</table>
<h1>${request.userSession?.customDeltaDefinition?.name?.encodeAsHTML()}<g:if test="${request?.userSession?.customDeltaDefinitionDirty}"> | <g:link controller="dashboard" action="delta" params="['session.reset': true]">Reset</g:link></g:if><g:if test="${request.userSession?.customFilter}"> | ${request.userSession.customFilter.toDSL().encodeAsHTML()} [<g:link controller="dashboard" action="delta" params="['session.systemFilter': '-']">Clear Filter</g:link>]</g:if></h1>
<div id="__delta">
  <div id="__delta_content">
    <table class="bordered-table tight-table">
      <thead>
      <tr>
        <th>${delta.firstColumn.name?.encodeAsHTML()}</th>
        <th><g:link controller="dashboard" action="delta" params="['session.summary': !request.userSession.customDeltaDefinition.summary]">I:${delta.counts['instances']}</g:link></th>
        <th><g:link controller="dashboard" action="delta" params="['session.errorsOnly': !request.userSession.customDeltaDefinition.errorsOnly]">E:${delta.counts['errors']}</g:link></th>
        <g:each in="${delta.tailColumns.name}" var="column" status="columnIdx">
          <th><g:link controller="dashboard" action="delta" params="['session.groupBy': column]">
            <g:if test="${delta.counts[column] == null}">${column.encodeAsHTML()}</g:if>
            <g:else>${column.encodeAsHTML()}:${delta.counts[column]}</g:else>
          </g:link></th>
        </g:each>
      </tr>
      </thead>
      <g:if test="${delta.accuracy == AccuracyLevel.INACCURATE}">
        <tr id="__delta_inaccurate">
          <td colspan="${3 + delta.tailColumns.size()}">
            <div class="warning">Warning!!! Warning!!! Warning!!!</div>
            The data you are seeing is not accurate as the console is in the process of loading it from ZooKeeper
            <div class="warning">Warning!!! Warning!!! Warning!!!</div>
          </td>
        </tr>
      </g:if>
      <% /* Column 0 is (already) sorted according to definition and we do the grouping on (span multiple rows) */ %>
      <g:each in="${delta.groupByDelta.keySet()}" var="column0Value" status="line">
        <tbody id="${column0Value}">
        <% /* Entries (grouped by column0) are sorted by column 1 */ %>
        <g:set var="row" value="${delta.groupByDelta[column0Value]}"/>
        <g:set var="entries" value="${row.entries}"/>
        <g:set var="rowState" value="${row.state + ' ' + row.na}"/>
        <g:each in="${entries}" var="entry" status="rowIdx">
          <tr class="${rowState}">
            <g:each in="${delta.deltaDefinition.visibleColumns}" var="column" status="columnIdx">
              <g:if test="${columnIdx == 0}">
                <g:if test="${rowIdx == 0}">
                  <td rowspan="${entries.size()}" class="${rowState} column0">
                    <cl:formatDeltaValue column="${column}" values="${entry}"/>
                  </td>
                  <td rowspan="${entries.size()}" class="${rowState} totalCount">
                    ${row.instancesCount}
                  </td>
                  <td rowspan="${entries.size()}" class="${rowState} errorsCount">
                    ${row.errorsCount}
                  </td>
                </g:if>
              </g:if>
              <g:else>
                <td class="${entry.status == 'delta' ? 'DELTA' : entry.state} detail">
                  <cl:formatDeltaValue column="${column}" values="${entry}" row="d-${line}-${rowIdx}"/>
                </td>
              </g:else>
            </g:each>
          </tr>
        </g:each>
        </tbody>
      </g:each>
    </table>
  </div>
</div>
