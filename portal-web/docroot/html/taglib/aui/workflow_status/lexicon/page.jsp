<%--
/**
 * Copyright (c) 2000-present Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/taglib/aui/workflow_status/init.jsp" %>

<%
String additionalText = StringPool.BLANK;

if (Validator.isNull(statusMessage)) {
	statusMessage = WorkflowConstants.getStatusLabel(status);

	if ((status == WorkflowConstants.STATUS_PENDING) && (bean != null) && (model != null)) {
		long companyId = BeanPropertiesUtil.getLong(bean, "companyId");
		long groupId = BeanPropertiesUtil.getLong(bean, "groupId");
		long classPK = BeanPropertiesUtil.getLong(bean, "primaryKey");

		StringBundler sb = new StringBundler(4);

		try {
			String workflowStatus = WorkflowInstanceLinkLocalServiceUtil.getState(companyId, groupId, model.getName(), classPK);

			sb.append(StringPool.SPACE);
			sb.append(StringPool.OPEN_PARENTHESIS);
			sb.append(LanguageUtil.get(request, HtmlUtil.escape(workflowStatus)));
			sb.append(StringPool.CLOSE_PARENTHESIS);

			additionalText = sb.toString();
		}
		catch (NoSuchWorkflowInstanceLinkException nswile) {
		}
	}
}
%>

<div class="status">
	<liferay-ui:message key="<%= statusMessage %>" /><%= additionalText %>
</div>