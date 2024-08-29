/**
 * @description       : 
 * @author            : Nilesh Badrakiya
 * @group             : 
 * @last modified on  : 03-13-2024
 * @last modified by  : Nilesh Badrakiya
**/
public with sharing class ManagedObject {
    
    public static final String FIELD_NAME_ID = 'Id';
	public static final String FIELD_NAME_NAME = 'Name';
	public static final String FIELD_NAME_CURRENCY = 'CurrencyIsoCode';
	public static final String FIELD_NAME_OWNER = 'OwnerId';
	public static final String FIELD_NAME_OWNER_NAME = 'Owner.Name';
	public static final String FIELD_NAME_CREATEDBY = 'CreatedById';
	public static final String FIELD_NAME_CREATEDBY_NAME = 'CreatedBy.Name';
	public static final String FIELD_NAME_LASTMODIFIEDBY = 'LastModifiedById';
	public static final String FIELD_NAME_LASTMODIFIEDBY_NAME = 'LastModifiedBy.Name';
	public static final String FIELD_NAME_RECORDTYPE = 'RecordTypeId';
	public static final String FIELD_NAME_RECORDTYPE_NAME = 'RecordType.Name';
	public static final String FIELD_NAME_SYSTEMMODSTAMP = 'SystemModstamp';
	public static final String FIELD_NAME_LASTMODIFIEDDATE = 'LastModifiedDate';
	public static final String FIELD_NAME_LASTACTIVITYDATE = 'LastActivityDate';
	public static final String FIELD_NAME_CREATEDDATE = 'CreatedDate';
}