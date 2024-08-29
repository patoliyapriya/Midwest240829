/*
	myTaskList-postLoad.js Custom JavaScript for use with My Task List package (loaded at the end of the Visualforce page)
	Author: Mike Hineline

	Copyright (c) 2013, salesforce.com, Inc.
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without modification, 
	are permitted provided that the following conditions are met:
	
	    * Redistributions of source code must retain the above copyright notice, 
	    this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright notice, 
	    this list of conditions and the following disclaimer in the documentation 
	    and/or other materials provided with the distribution.
	    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
	    may be used to endorse or promote products derived from this software 
	    without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
	IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
	DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
	LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
	OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
	OF THE POSSIBILITY OF SUCH DAMAGE.

*/
		/*
			MTL_updateTask - update the record in the Salesforce database via JavaScript Remoting
			Inputs:
				- ID id - ID of the record to update
				- String targetField - API name of the field to update (null if just getting the updated task from the DB)
				- String newValue - new value to store in targetField (null if just getting the updated task from the DB)
			Returns:
				- None (asynchronous)
			Action:
				- Turn on the refresh graphic (MTL_refreshTask will turn it off)
				- Call MTL_refreshTask to refresh the task on the VisualForce page
			URL encode (escape) the Apex response
		*/
		function MTL_updateTask(id, targetField, newValue) {
			// Turn on the refresh graphic
			$("#refreshIndicator"+id).removeClass("hidden");
			// JavasScript remote call to the controller extension
			MTL_myTaskListController.updateTask(
				id,
				targetField,
				newValue,
				function(result, event) {;
					if(event.status) {
						// Successful update actions
						// Refresh the task on the page
						MTL_refreshTask(result);
					} else if (event.type === 'exception') {
						// Update fail actions
						console.log('Error: ' + result);
					} else {
						// Unknown exception actions
						console.log('An unknown error has occurred');
					}
			},{escape: true});
		}

		/*
			MTL_refreshTask - Refresh task on page by updating values and formatting appropriately
			Input:
				- result - sObject returned by the updateTask() function JavaScript remoting 
		*/
		function MTL_refreshTask(result) {
			// Ensure the refresh graphic is on
			$("#refreshIndicator"+result.Id).removeClass("hidden");

			/*
				Update required task field values
			*/
			// Update task header field values
			$("#taskSubject"+result.Id).html(result.Subject);
			if (result.ActivityDate != null) {
				var textDate = MTL_formatDate(result.ActivityDate,'DATE');
				$("#taskActivityDate"+result.Id).text(textDate);
				// Check if ActivityDate is <= today and format text accordingly
				var targetDate = Date.parse(textDate);
				var d = new Date();
				var nowDate = d.getTime();
				if (targetDate <= nowDate) {
					// Due date past due or due, highlight red
					$("#taskActivityDate"+result.Id).addClass("text-danger");
				} else {
					// Due in the future, remove red highlight
					$("#taskActivityDate"+result.Id).removeClass("text-danger");
				}
			} else {
				$("#taskActivityDate"+result.Id).text("");
			}
			if (result.What != null) {
				// Replace the WhatId text
				$("#taskWhat"+result.Id).html(result.What.Name);
				// Replace the WhatId URL
				var pageFormat = MTL_getPageFormat();
				$("#taskWhatURL"+result.Id).attr('onclick','javascript:MTL_openRecord(\'' + encodeURI(result.WhatId) + '\',\'primary\',\'' + MTL_escape(result.What.Name) + '\',\'view\',\'Task\')');
			} else {
				$("#taskWhat"+result.Id).text("");
				$("#taskWhatURL"+result.Id).attr('onclick','javascript:void(0);');
			}
			// Update task detail field values
			$("#taskStatus"+result.Id).html(result.Status);
			$("#taskPriority"+result.Id).html(result.Priority);
			if (result.Who != null) {
				// Replace the WhoId text
				$("#taskWho"+result.Id).html(result.Who.Name);
				// Replace the WhoId URL
				var pageFormat = MTL_getPageFormat();
				$("#taskWhoURL"+result.Id).attr('onclick','javascript:MTL_openRecord(\'' + encodeURI(result.WhoId) + '\',\'primary\',\'' + MTL_escape(result.Who.Name) + '\',\'view\',\'Task\')');
			} else {
				$("#taskWho"+result.Id).text("");
				$("#taskWhoURL"+result.Id).attr('onclick','javascript:void(0);');
			}

			/*
				Update the task Priority formatting
			*/
			if (result.IsHighPriority == true) {
				$("#taskCard"+result.Id).removeClass("panel-default");
				$("#taskCard"+result.Id).addClass("panel-danger");
				$("#taskPriorityHeader"+result.Id).removeClass("hidden");
				$("#taskPriorityDetails"+result.Id).removeClass("hidden");
			} else { 
				$("#taskCard"+result.Id).removeClass("panel-danger");
				$("#taskCard"+result.Id).addClass("panel-default");
				$("#taskPriorityHeader"+result.Id).addClass("hidden");
				$("#taskPriorityDetails"+result.Id).addClass("hidden");
			}
            
			/*
				Update the Task Closed/Deleted status formatting
			*/
			if (result.IsDeleted) {
				// Remove the Task hyperlink
				$("#taskSubjectURL"+result.Id)[0].onclick = null;
				
				// Strike through the header text
				$("#taskSubject"+result.Id).addClass("strikeThrough");
				$("#taskActivityDate"+result.Id).addClass("strikeThrough");
				$("#taskWhat"+result.Id).addClass("strikeThrough");
				
				// Hide the task quick actions, which are not applicable on a deleted task
				$("#taskActionButtons"+result.Id).addClass("hidden");
				
				// Turn off high priority formatting
				$("#taskCard"+result.Id).removeClass("panel-danger");
				$("#taskCard"+result.Id).addClass("panel-default");
				$("#taskPriorityHeader"+result.Id).addClass("hidden");
				$("#taskPriorityDetails"+result.Id).addClass("hidden");
			} else if (result.IsClosed) {
				// Strike through the header text
				$("#taskSubject"+result.Id).addClass("strikeThrough");
				$("#taskActivityDate"+result.Id).addClass("strikeThrough");
				$("#taskWhat"+result.Id).addClass("strikeThrough");
				
				// Make the quick close button green
				$("#taskQuickCloseButton"+result.Id).removeClass("btn-danger");
				$("#taskQuickCloseButton"+result.Id).addClass("btn-success");
				
				// Replace the quick close button onClick function so that it will re-open the task if clicked again
				// Note that we do not update the value of the statusPriorValue<Id> hidden field to Closed
				var statusPriorValue = $("#statusPriorValue"+result.Id).val();
				$("#taskQuickCloseLink"+result.Id)[0].onclick = null;
				$("#taskQuickCloseLink"+result.Id).click(function() { MTL_updateTask(result.Id,'Status',statusPriorValue) });
				
				// Turn off high priority formatting
				$("#taskCard"+result.Id).removeClass("panel-danger");
				$("#taskCard"+result.Id).addClass("panel-default");
				$("#taskPriorityHeader"+result.Id).addClass("hidden");
				$("#taskPriorityDetails"+result.Id).addClass("hidden");
			} else {
				// Remove strike through on header text
				$("#taskSubject"+result.Id).removeClass("strikeThrough");
				$("#taskActivityDate"+result.Id).removeClass("strikeThrough");
				$("#taskWhat"+result.Id).removeClass("strikeThrough");
				
				// Make the quick close button red again
				$("#taskQuickCloseButton"+result.Id).removeClass("btn-success");
				$("#taskQuickCloseButton"+result.Id).addClass("btn-danger");
				
				// Replace the quick close button onClick function so that it will close the task if clicked again
				var statusCompletedValue = 'Completed';
				$("#taskQuickCloseLink"+result.Id)[0].onclick = null;
				$("#taskQuickCloseLink"+result.Id).click(function() { MTL_updateTask(result.Id,'Status',statusCompletedValue) });
				// Update the value of the statusPriorValue<Id> hidden field
				$("#statusPriorValue"+result.Id).val(result.Status);
			}

			/*
				Update the field values for all admin selected (field set) fields
			*/
			var thisFieldValueString = '';
			var thisFieldValueStringFormatted = '';
			for (var i = 0; i < MTL_taskCardOtherFieldNames.length; i++) {
				// Handle any reference fields (Object.Field)
				var thisFieldPrimary = '';
				var thisFieldSecondary = '';
				var thisDotLocation = MTL_taskCardOtherFieldNames[i].indexOf('.');
				var thisFieldValueString = '';
				if (thisDotLocation != -1) {
					// Handle a reference field
					thisFieldPrimary = MTL_taskCardOtherFieldNames[i].substring(0,thisDotLocation);
					thisFieldSecondary = MTL_taskCardOtherFieldNames[i].substring(thisDotLocation+1);
					if (result[thisFieldPrimary] != null) {
						thisFieldValueString = result[thisFieldPrimary][thisFieldSecondary];
					}
				} else {
					thisFieldValueString = result[MTL_taskCardOtherFieldNames[i]];
				}

				// Format the field value HTML
				if (thisFieldValueString === '' || thisFieldValueString == 'undefined' || thisFieldValueString == null) {
					thisFieldValueStringFormatted = '';
				} else {
					thisFieldValueStringFormatted = MTL_formatFieldValueHTML(thisFieldValueString,MTL_taskCardOtherFieldTypes[i],null,MTL_taskCardOtherFieldNames[i],result.Id);
				}

				// Update the field value in the DOM
				if(thisDotLocation != -1) {
					// Handle any reference fields (Object.Field)
					$("#"+thisFieldPrimary+"\\."+thisFieldSecondary+"-"+result.Id).html(thisFieldValueStringFormatted);
				} else {
					$("#"+MTL_taskCardOtherFieldNames[i]+"-"+result.Id).html(thisFieldValueStringFormatted);
				}
			}
			
			// Turn off the refresh graphic
			$("#refreshIndicator"+result.Id).addClass("hidden");
		}

		/*
			MTL_togglePriority - toggle the priority (high or not) of a record
			Input: ID id - ID of the record to update
			Requires: hidden field priorityOriginalValue<id>
			Outputs: none
			Actions: asyncrhonous update of task due date and refresh of task card
		*/
		function MTL_togglePriority(id) {
			// Determine current (at time of last page load) Task Priority value from the hidden field priorityOriginalValue<id>
			var originalPriority = $("#priorityOriginalValue"+id).val();
			// Determine current Task Priority from the text in taskPriority<id>
			var currentPriority = $("#taskPriority"+id).text();
			
			// If the priority is already high, change it to normal.  Otherwise, change it to high.
			var newPriority;
			if (originalPriority == "High" && currentPriority == "High") {
				newPriority = "Normal";
			} else if (originalPriority == "High" && currentPriority != "High") {
				newPriority = "High";
			} else if (originalPriority != "High" && currentPriority == "High") {
				newPriority = originalPriority;
			} else {
				// original priority not high and current priority not high, set to high
				newPriority = "High";
			}
			// Update the task
			MTL_updateTask(id,'Priority',newPriority);
		}
        
		/*
			MTL_emailTask - email the task to the current logged in user
			Input: ID id - ID of the record to email
			Returns:
				- None (asynchronous)
			Action:
				- Javascript remote call to send copy of task to user
				- Notify user of success/failure
		*/
		function MTL_emailTask(id) {
			// Turn the refresh graphic on
			$("#refreshIndicator"+id).removeClass("hidden");

			// JavasScript remote call to the controller extension
			MTL_myTaskListController.emailTask(
				id,
				function(result, event) {;
					if(event.status) {
						// Successful update actions
						if (result == true) {
							// The controller returned success, make the email button green
							$("#taskEmailButton"+id).removeClass("btn-default");
							$("#taskEmailButton"+id).addClass("btn-success");
						} else {
							// The controller returned false, make the email button red
							$("#taskEmailButton"+id).removeClass("btn-default");
							$("#taskEmailButton"+id).addClass("btn-danger");
						}
					} else if (event.type === 'exception') {
						// Update fail actions
						console.log('Error: ' + result);
                			// Make the email button red
                			$("#taskEmailButton"+id).removeClass("btn-default");
                			$("#taskEmailButton"+id).addClass("btn-danger");
					} else {
						// Unknown exception actions
						console.log('An unknown error has occurred');
                			// Make the email button red
                			$("#taskEmailButton"+id).removeClass("btn-default");
                			$("#taskEmailButton"+id).addClass("btn-danger");
					}
					// Turn the refresh graphic off
					$("#refreshIndicator"+id).addClass("hidden");
			});
		}

		/*
			MTL_getObjectId - Return the focused subtab's object ID
			Inputs: none
			Returns: ID objectID
		*/
		function MTL_getObjectId() {
			var  thisObjectId;
			
			// Handle the result of sforce.console.getEnclosingTabId()
			var setObjectId = function setObjectId(result) {
				thisObjectId = result.id;
			};

			// Use the console function to get the enclosing tab Id
			sforce.console.getFocusedSubtabObjectId(setObjectId);

			// Return the object Id
			return thisObjectId;
		}

		/*
			MTL_openSubtab - open a new subtab in the Salesforce console as a subtab of the enclosing primary tab
				This is only valid for pages which are in sidebar components of a record.  Web-tabs, for example, aren't enclosed by a primary tab
			Inputs:
				- String url - URL to open in the subtab
				- String tabTitle - title of the console subtab
			Returns: none
		*/
		function MTL_openSubtab(url,tabTitle) {
			var MTL_openSubtabFunction = function MTL_openSubtabFunction(result) {
				// Open a new subtab with primaryTabId=result.id, url=url,active=true,tabLabel=tabTitle,id=null (create new subtab),callback=N/A,name=N/A
				sforce.console.openSubtab(result.id,url,true,tabTitle,null);
			}
			sforce.console.getEnclosingPrimaryTabId(MTL_openSubtabFunction);
		}

		/*
			MTL_openRecord - open a Salesforce record page specific to the UI:
				- Salesforce console: a new tab is opened containing the record
				- Salesforce1 mobile app: the record is navigated to
				- Aloha UI: the record is opened in a new window (/browser tab)
			Inputs:
				- ID recordID - ID of the record to which to navigate
				- String tabType:
					- primary - open a new primary tab
					- sub - open a new subtab (only valid if this page is a sidebar component of a record)
				- String targetLabel - title of the console tab [should be passed URI encoded] (input null or empty string ('') to accept default label) 
				- String targetAction:
					- view - open the record for viewing
					- edit - open the record for editing
					- close - open the URL with delete rendering where available (console, aloha, NOT Salesforce1)
					- new - create a new record
				- String entityName - name of the object (e.g. Task)
			Returns: none
		*/
		function MTL_openRecord(recordID, tabType, targetLabel, targetAction, entityName) {
			// Initial recordID cleanup
			if (recordID != null) {
				recordID = decodeURI(recordID);

				// Set the default 'URL' to be the recordID
				var thisURL = '/' + recordID;

				// Detect Content which will be displayed instead of Files in the Salesforce console & Aloha UI
				// 	Note: Content & Files both use 069 IDs.  If entityName = 'Files' (or anything other than 'Content')
				//		the record will be opened as a File in Aloha and the Console  
				if (recordID.substring(0,3) == '069') {
					thisURL = encodeURI('/sfc/#version/' + recordID);
				}
			}

			// Initial targetLabel cleanup
			targetLabel = decodeURI(targetLabel);

			// Append appropriate modifier based on targetAction
			if (targetAction == 'close') {
				// close/edit modifier
				thisURL += '/e?close=1&cancelURL=%2F' + recordID;
			} else if (targetAction == 'edit') {
				// edit modifier
				thisURL += '/e';
			} else if (targetAction == 'new') {
				// new URL (overwrites initialized default)
				if (entityName == 'Task') {
					thisURL = '/00T/e';
				}
			}
			
			// Determine the UI
			var pageFormat = MTL_getPageFormat();
	
			// Form the appropriate javascript function based on the UI the user is using
			if (pageFormat == 'console') {
				// Open the targetURL in a new console tab
				if (tabType == 'sub') {
					if(targetLabel == null || targetLabel == '') targetLabel = '';
					// Open a new sub tab of the enclosing tab
					MTL_openSubtab(thisURL, targetLabel);
				} else {
					// Open a new primary tab
					// Paramters: id=null (new tab), url=thisURL, active=true, tabLabel=targetLabel, callback=N/A
					if(targetLabel == null || targetLabel == '') {
						sforce.console.openPrimaryTab(null, thisURL, true);
					} else {
						sforce.console.openPrimaryTab(null, thisURL, true, targetLabel);
					}
				}
			} else if (pageFormat == 'mobile') {
				if (targetAction == 'edit') {
					// Open the record for editing in Salesforce1
					sforce.one.editRecord(recordID);
				} else if (targetAction == 'new') {
					// Open the record for editing in Salesforce1
					sforce.one.createRecord(entityName);
				} else {
					// Default (including targetAction == 'view'): open the recordID for viewing in Salesforce1
					sforce.one.navigateToSObject(recordID);
				}
			} else {
				// Open record using normal browser window.open commands (for the Aloha UI)
				window.open(thisURL,recordID);
			}
		}

		/*
			MTL_openURL - open a URL specific to the UI:
				- Salesforce console: a new tab is opened containing the URL
				- Salesforce1 mobile app: the URL is navigated to
				- Aloha UI: the URL is opened in a new window (/browser tab)
			Inputs:
				- targetURL URL - URL to which to navigate [should be passed URI encoded]
				- String tabType:
					- primary - open a new primary tab
					- sub - open a new subtab (only valid if this page is a sidebar component of a record)
				- String targetLabel - title of the console tab [should be passed URI encoded] (input null or empty string ('') to accept default label)
			Returns: none
		*/
		function MTL_openURL(targetURL, tabType, targetLabel) {
			// Initial URL cleanup
			if (targetURL != null) {
				// URI decode the URL
				targetURL = decodeURI(targetURL);

				// Ensure targetURL has a URI scheme
				//	Add 'http://' if the targetURL has no URI scheme
				var hasURIscheme = targetURL.indexOf('://');
				if (hasURIscheme == -1) {
					targetURL = 'http://'+targetURL;
				}
			}

			// Initial targetLabel cleanup
			targetLabel = decodeURI(targetLabel);

			// Determine the UI
			var pageFormat = MTL_getPageFormat();
	
			// Form the appropriate javascript function based on the UI the user is using
			//	Note: due to browser same-origin policy and console app security issues, currently defaulting to window.open for console URLs
			//		just as a URL field in the console does	
			if (pageFormat == 'UNUSED-console-UNUSED') {
				// Open the targetURL in a new console tab
				if (tabType == 'sub') {
					if(targetLabel == null || targetLabel == '') targetLabel = '';
					// Open a new sub tab
					MTL_openSubtab(targetURL, targetLabel);
				} else {
					// Open a new primary tab
					// Paramters: id=null (new tab), url=targetURL, active=true, tabLabel=targetLabel, callback=N/A
					if(targetLabel == null || targetLabel == '') {
						sforce.console.openPrimaryTab(null, targetURL, true);
					} else {
						sforce.console.openPrimaryTab(null, targetURL, true, targetLabel);
					}
				}
			} else if (pageFormat == 'mobile') {
				// Open the URL in Salesforce1
				sforce.one.navigateToURL(targetURL);
			} else {
				// Open record using normal browser window.open commands (for the Aloha UI)
				window.open(targetURL);
			}
		}
