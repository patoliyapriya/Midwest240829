/*
	myTaskList-preLoad.js Custom JavaScript for use with My Task List package (loaded at the beginning of the Visualforce page and used during build of Visualforce page)
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
			MTL_formatDate - Present a salesforce date or date time string formatted for UI
			Inputs:
				- string dateField - salesforce.com date or datetime value
				- string fieldType - salesforce.com field type of DATE or DATETIME
			Output: formatted date string
		*/
		function MTL_formatDate(dateField,fieldType) {
			// Interpret the date whether given a 13 character epoch (e.g. 1399593600000) or Salesforce time string (e.g. Wed Apr 30 14:55:22 GMT 2014)
			if (dateField.length == 13) {
				// Initialize the date object (first to 0 to set the epoch)
				var d = new Date(0);
				d.setUTCSeconds(dateField/1000);
			} else {
				// Convert Salesforce date field to JavaScript date object
				var d = new Date(dateField);
			}

			// Initialize the date string variables
			var thisDay, thisMonth, thisYear, thisHour, thisMinutes, thisAMPM;
			// Format the date strings to be MM/DD/YYYY
			thisDay = ("0" + d.getUTCDate()).slice(-2);
			thisMonth = ("0" + (d.getUTCMonth() + 1)).slice(-2);
			thisYear = d.getUTCFullYear();
			if (fieldType.toUpperCase() == 'DATETIME') {
				thisHour = ("0" + d.getHours()).slice(-2);
				thisMinutes = ("0" + d.getMinutes()).slice(-2);
				thisAMPM = 'AM';
				if (thisHour > 12) {
					thisHour -= 12;
					thisAMPM = 'PM';
				}
			}
			
			// Convert date string to MM/DD/YYY format
			// Note that the Salesforce dates are already converted to the user's timezone, so using UTC functions
			var dateString = thisMonth + "/" + thisDay + "/" + thisYear;

			// If DATETIME, add HH:MM xM
			if (fieldType.toUpperCase() == 'DATETIME') {
				dateString += " " + thisHour + ":" + thisMinutes + " " + thisAMPM;
			}

			// return the date as a string
			return dateString;
		} 

		/*
			MTL_nl2br - for a given string, replace newline characters with HTML <br /> tags
			Inputs:
				- String originalString - string with newline characters to be replaced by <br />
				- Boolean replaceExtraNL:
					- true to replace double line breaks before replacing newline characters
					- false to only replace newline characters
			Returns:
				- String newString - string with <br /> characters in place of newline characters
		*/
		function MTL_nl2br(originalString,replaceExtraNL) {
			var newString = originalString;

			if (originalString != '' && originalString != null) {
				// Replace the double linebreaks created by the Apex function JSINHTMLENCODE
				if (replaceExtraNL) {
					newString = originalString.replace(/\n\n/g,'\n');
				}
				// Replace carriage returns with HTML line breaks
				newString = newString.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2');
			}

			return newString;
		}
    	
		/*
			MTL_escape - escape a string for safe use in URLs
			Inputs:
				- String originalString - string to be cleaned
			Returns:
				- String newString - URI encoded string with apostrophes escaped
		*/
		function MTL_escape(originalString) {
			// URI encode the string
			var newString = encodeURI(originalString);
			// Remove apostrophes from the string
			if (originalString != '' && originalString != null) {
				newString = newString.replace(/'/g,"\'");
			}
			return newString;
		}	

		/*
			MTL_formatFieldLabelHTML - Format the HTML for a field's label with consideration for
				some standard API to UI name conversions (e.g. "Due Date Only" -> "Due Date",
				"Contact/Lead ID" -> "Name", "Account/Opportunity ID"-> "Related To", etc.)
			Inputs:
				- String fieldLabel - label of the field
			Returns:
				- String fieldLabelHTMLString - an HTML string to display the field's label
		*/
		function MTL_formatFieldLabelHTML(fieldLabel) {
			// By default, return the label of the string unless other modifications are needed
			var returnString = fieldLabel;

			// Return immediately if input fieldLabel is undefined/empty
			if (fieldLabel === '' || fieldLabel == 'undefined' || fieldLabel === null) {
				returnString = '';
				return returnString;
			}

			// Handle special field types appropriately
			if (fieldLabel == 'Due Date Only') {
				returnString = 'Due Date';
			} else if (fieldLabel == 'Opportunity/Account ID') {
				returnString = 'Related To';
			} else if (fieldLabel == 'Contact/Lead ID') {
				returnString = 'Name';
			} else if (fieldLabel == 'Reminder Date/Time') {
				returnString = 'Reminder';
			} else if (fieldLabel.indexOf(' ID', fieldLabel.length - 3) != -1) {
				// Remove ' ID' from fields (e.g. Account ID, Activity ID, Assigned To ID, Created By ID, Last Modified ID, Recurrence Activity ID)
				// Their field values will be updated with the record Name/Subject and will not contain an ID
				returnString = fieldLabel.substring(0,fieldLabel.indexOf(' ID'));
			} else {
				// By default, return the unmodified label of the field
				returnString = fieldLabel;
			}
			
			// Add styling
			returnString = '<b>' + returnString + ':</b>';
			
			return returnString;
		}
		
		/*
			MTL_formatFieldValueHTML - Format the HTML for a field's value with consideration for field type
			Inputs:
				- String fieldValue - value of the field (should be passed URI encoded)
				- String fieldType - Salesforce data type (Schema.DisplayType) for the field
				- String fieldAltText - alternate text for the field if it is to be different than the fieldValue
					for URL, REFERENCE, or ID fieldTypes (should be passed URI encoded) (sendnull or '' to use fieldValue as the fieldAltText)
				- String fieldName - API name of the field for which the value is being formatted (used for any follow on actions)
				- ID taskID - ID of the Task for which this field value is being updated (used for any follow on actions)
			Returns:
				- String fieldValueHTMLString - an HTML string to display the field's value
		*/
		function MTL_formatFieldValueHTML(fieldValue, fieldType, fieldAltText, fieldName, taskID) {
			// Return immediately if input fieldValue or fieldType is undefined/empty
			if (fieldValue === '' || fieldValue == 'undefined' || fieldValue === null
				|| fieldType === '' || fieldType == 'undefined' || fieldType === null) {
				returnString = '';
				return returnString;
			}

			// Initialize fieldAltText
			if (fieldAltText === '' || fieldAltText == 'undefined' || fieldAltText === null) {
				fieldAltText = decodeURI(fieldValue);
			} else {
				fieldAltText = decodeURI(fieldAltText);
			}

			// By default, return the URI decoded value of the string unless other modifications are needed
			var returnString = decodeURI(fieldValue);
			// Temp string for manipulating output
			var tempString;

			// Handle special field types appropriately
			var thisFieldType = fieldType.toUpperCase();
			if (thisFieldType == 'TEXTAREA') {
				// Convert carriage returns in TEXTAREA fields to HTML line breaks
				returnString = MTL_nl2br(returnString,true);
			} else if (thisFieldType == 'DATE' || thisFieldType == 'DATETIME') {
				// Format date strings
				returnString = MTL_formatDate(returnString,thisFieldType);
			} else if (thisFieldType == 'EMAIL') {
				// Add a mailto link to e-mail fields
		        returnString = '<a href="mailto:' + returnString + '">' + returnString + '</a>';
			} else if (thisFieldType == 'URL') {
				// Add a hyperlink to URL fields
				tempString = '<a href="javascript:void(0);"';
				tempString += ' onClick="javascript:MTL_openURL(\'' + encodeURI(returnString) + '\',\'primary\',\'\')">';
				tempString += fieldAltText;
				tempString += '</a>';
				returnString = tempString;
			} else if (thisFieldType == 'REFERENCE' || thisFieldType == 'ID') {
				// Add a hyperlink to Lookup (Reference) and ID fields
				// If friendly alt text was sent, update the field value.  If it was not, make a call to get the friendly text,
				//	which will re-call this function passing the alt text to be used for the field
				if (fieldAltText == fieldValue) {
					// Friendly alt text for this REFERENCE/ID was not sent
					// Kickoff a subsequent asynchronous call to translate the ID to a friendly alt text
					MTL_updateNameFromID(returnString,fieldName,thisFieldType,taskID);
					// To avoid the ID flashing and being replaced, temporarily fill in a field value
					tempString = '<span style="color:#888888;font-style:italic;">loading...</span>';
				} else {
					// Friendly alt text for this REFERENCE/ID was sent
					tempString = '<a href="javascript:void(0);"';
					tempString += ' onClick="javascript:MTL_openRecord(\'' + encodeURI(returnString) + '\',\'primary\',\'' + MTL_escape(fieldAltText) + '\',\'view\',\'Task\')">';
					tempString += fieldAltText;
					tempString += '</a>';
				}
				returnString = tempString;
			} else if (thisFieldType == 'PERCENT') {
				// Add a percent sign (%) to percent fields
				returnString = returnString + '%';
			} else if (thisFieldType == 'ENCRYPTEDSTRING') {
				// Intentionally skip encrypted fields to prevent data exposure
				// Encrypted strings are excluded by the controller so this is just a backup
				returnString = "<i>******</i>";
			} else if (thisFieldType == 'STRING') {
				// If the field is a formula (string) with an image, unescape enough to display the image
				//	Not generally escaping to protect against XSS vulerabilities
				if (returnString.substring(1,7) == "lt;img" && returnString != 'undefined') {
					// Unescape &quot; with "
					tempString = returnString.replace(/&quot\;/g,"\"");
					// Unescape the beginning '&lt;img' tag and trailing '&gt'
					tempString = tempString.replace(/^&lt\;img/g, "<img");
					tempString = tempString.replace(/&gt\;$/, ">");
					returnString = tempString;
				}
			}

			// Return the HTML string
			return returnString;
		}

		/*
			MTL_updateNameFromID - update a field value with a friendly name from a given ID via JavaScript Remoting
			Inputs:
				- ID id - ID of the record
				- String fieldName - name of the field for which the value is being formatted (used for any follow on actions)
				- String fieldType - field type of the REFERENCE/ID field being formatted
				- ID taskID - ID of the Task for which this field value is being updated (used for any follow on actions)
			Returns:
				- None (asynchronous)
			Action:
				- Call MTL_updateIDField to update the value of the field on the VisualForce page
			URL encode (escape) the Apex response
		*/
		function MTL_updateNameFromID(id,fieldName,fieldType,taskID) {
			// JavasScript remote call to the controller extension
			MTL_myTaskListController.getNameFromID(
				id,
				function(result, event) {;
					if(event.status) {
						// Successful update actions
						// Update the value shown on the page
						MTL_updateIDField(result,id,fieldName,fieldType,taskID);
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
			MTL_updateIDField - Update field values for ID fields to change from an ID (originally returned from Controller via refresh)
				to a human-friendly name of the record (e.g. Account.Name or Task.Subject).  Maintain hyperlinks.
			Input:
				- result - sObject returned by the updateTask() function JavaScript remoting 
				- ID fieldID - ID of the REFERENCE/ID being formatted
				- String fieldName - API name of the field for which the value is being formatted (used for any follow on actions) (should be passed URI encoded)
				- String fieldType - field type of the REFERENCE/ID field being formatted
				- ID taskID - ID of the Task for which this field value is being updated (used for any follow on actions)
		*/
		function MTL_updateIDField(result,fieldID,fieldName,fieldType,taskID) {
			if (result != '' && result != 'undefined' && result != null) {
				// Handle any reference fields (Object.Field)
				var thisFieldPrimary = '';
				var thisFieldSecondary = '';
				var thisDotLocation = fieldName.indexOf('.');
				if (thisDotLocation != -1) {
					// Handle a reference field
					thisFieldPrimary = fieldName.substring(0,thisDotLocation);
					thisFieldSecondary = fieldName.substring(thisDotLocation+1);
				}

				// Get the formatted HTML for the field value by passing the ID and the alternate text (record Name/Subject)
				var thisFieldValueStringFormatted = MTL_formatFieldValueHTML(fieldID,fieldType,encodeURI(result),fieldName,taskID);
				// Update the field value in the DOM
				if(thisDotLocation != -1) {
					// Handle any reference fields (Object.Field)
					$("#"+thisFieldPrimary+"\\."+thisFieldSecondary+"-"+taskID).html(thisFieldValueStringFormatted);
				} else {
					$("#"+fieldName+"-"+taskID).html(thisFieldValueStringFormatted);	
				}
			}
		}

