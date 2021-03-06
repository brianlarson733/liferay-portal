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

<%@ include file="/init.jsp" %>

<%
String redirect = ParamUtil.getString(request, "redirect");

long mbThreadId = ParamUtil.getLong(request, "mbThreadId");

String subject = StringPool.BLANK;
String to = StringPool.BLANK;

if (mbThreadId != 0) {
	List<MBMessage> mbMessages = MBMessageLocalServiceUtil.getThreadMessages(mbThreadId, WorkflowConstants.STATUS_ANY);

	MBMessage firstMessage = mbMessages.get(0);

	subject = firstMessage.getSubject();

	List<UserThread> userThreads = UserThreadLocalServiceUtil.getMBThreadUserThreads(mbThreadId);

	to = ListUtil.toString(userThreads, "userId", ", ");
}

long[] userIds = StringUtil.split(ParamUtil.getString(request, "userIds"), 0L);

StringBundler sb = new StringBundler(userIds.length * 6);

for (long userId : userIds) {
	try {
		User user2 = UserLocalServiceUtil.getUser(userId);

		sb.append(user2.getFullName());
		sb.append(CharPool.SPACE);
		sb.append(CharPool.LESS_THAN);
		sb.append(user2.getScreenName());
		sb.append(CharPool.GREATER_THAN);
		sb.append(StringPool.COMMA_AND_SPACE);
	}
	catch (Exception e) {
	}
}

to = sb.toString() + to;
%>

<div class="portlet-configuration-body-content">
	<div class="container-fluid-1280">
		<div class="message-container" id="<portlet:namespace />messageContainer"></div>

		<div class="message-body-container">
			<aui:form enctype="multipart/form-data" method="post" name="fm" onSubmit="event.preventDefault();">
				<aui:input name="mbThreadId" type="hidden" value="<%= mbThreadId %>" />

				<div id="<portlet:namespace />autoCompleteContainer">
					<aui:input name="to" required="<%= true %>" value="<%= to %>" />
				</div>

				<aui:input name="subject" required="<%= true %>" value="<%= subject %>" />

				<aui:input cssClass="message-body" label="message" name="body" required="<%= true %>" type="textarea" />

				<label class="field-label">
					<liferay-ui:message key="attachments" />
				</label>

				<%
				long fileMaxSize = DLValidatorUtil.getMaxAllowableSize() / 1024;
				%>

				<aui:field-wrapper>
					<c:if test="<%= fileMaxSize != 0 %>">
						<div class="alert alert-info">
							<%= LanguageUtil.format(request, "upload-documents-no-larger-than-x-k", String.valueOf(fileMaxSize), false) %>
						</div>
					</c:if>
				</aui:field-wrapper>

				<aui:input label="" name="msgFile1" type="file" />

				<aui:input label="" name="msgFile2" type="file" />

				<aui:input label="" name="msgFile3" type="file" />

				<aui:button-row>
					<aui:button type="submit" value="send" />
				</aui:button-row>
			</aui:form>
		</div>
	</div>
</div>

<aui:script use="aui-io-deprecated,aui-loading-mask-deprecated,autocomplete">
	var form = A.one('#<portlet:namespace />fm');

	form.on(
		'submit',
		function(event) {
			var messageBody = form.one('#<portlet:namespace />body').val();
			var messageSubject = form.one('#<portlet:namespace />subject').val();
			var messageTo = form.one('#<portlet:namespace />to').val();

			if (!messageTo || !messageSubject || !messageBody) {
				event.preventDefault();
			}
			else {
				var loadingMask = new A.LoadingMask(
					{
						'strings.loading': '<%= UnicodeLanguageUtil.get(request, "sending-message") %>',
						target: A.one('.private-messaging-portlet .message-body-container')
					}
				);

				loadingMask.show();

				A.io.request(
					'<liferay-portlet:actionURL name="sendMessage"></liferay-portlet:actionURL>',
					{
						dataType: 'JSON',
						form: {
							id: form,
							upload: true
						},
						on: {
							complete: function(event, id, obj) {
								var responseText = obj.responseText;

								var responseData = JSON.parse(responseText);

								if (responseData.success) {
									Liferay.Util.getWindow('<portlet:namespace />Dialog').hide();
								}
								else {
									var messageContainer = A.one('#<portlet:namespace />messageContainer');

									if (messageContainer) {
										messageContainer.html('<div class="alert alert-danger">' + responseData.message + '</div>');
									}

									loadingMask.hide();
								}
							}
						}
					}
				);
			}
		}
	);

	var to = A.one('#<portlet:namespace />to');

	to.plug(
		A.Plugin.AutoComplete,
		{
			queryDelimiter: ',',
			requestTemplate: '&<portlet:namespace />keywords={query}',
			resultListLocator: 'results.users',
			resultTextLocator: 'name',
			source: '<liferay-portlet:resourceURL id="getUsers" />'
		}
	);

	to.on(
		'focus',
		function() {
			to.ac.sendRequest('');
		}
	);
</aui:script>