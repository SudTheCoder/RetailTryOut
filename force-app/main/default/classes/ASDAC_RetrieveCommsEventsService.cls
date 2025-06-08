/******************************************************************************
Name: ASDAC_RetrieveCommsEvent
===============================================================================
Req: 
ASDAC-2076 See toyou email comms in SFSC
===============================================================================
Purpose: UI for Comms
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		29 Nov 2022    Initial Development
******************************************************************************/
public with sharing class ASDAC_RetrieveCommsEventsService implements ASDAC_IntegrationServices {
    
	/**************************************************************************
    Purpose    : Method to create requestBody
    Parameters : String stringifiedJSON
    Returns    : String                                               
    **************************************************************************/
    public String createRequest(String stringifiedJSON) {
        return stringifiedJSON;
    }
    
	/**************************************************************************
    Purpose    : Method to do callout
    Parameters : ASDAC_IntegrationMetadata__mdt integrationMdt, 
				 String stringifiedJSON
    Returns    : ASDAC_IntegrationUtility.ResultWrapper                                               
    **************************************************************************/
    public ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON) {
        ASDAC_IntegrationUtility.IntegrationWrapper initWrapper = prepareInputs(integrationMdt, stringifiedJSON); 
        HttpResponse resp = ASDAC_IntegrationUtility.sendRequest(initWrapper);
        ResponseWrapper respWrap = (ResponseWrapper)JSON.deserialize(resp.getBody(), ResponseWrapper.class);
        ASDAC_IntegrationUtility.ResultWrapper calloutResponse =  parseResponse(respWrap);
        if (ASDAC_ErrorHandler.checkForException(integrationMdt.DeveloperName,resp.getStatusCode())) {
            calloutResponse.statusCode = resp.getStatusCode();
            throw new ASDAC_ErrorHandler.CustomCalloutException(calloutResponse);
        }
        return calloutResponse;
    }
    
	/**************************************************************************
    Purpose    : Method to populate IntegrationWrapper
    Parameters : ASDAC_IntegrationMetadata__mdt integrationMdt, 
				 String stringifiedJSON
    Returns    : ASDAC_IntegrationUtility.ResultWrapper                                               
    **************************************************************************/
    private ASDAC_IntegrationUtility.IntegrationWrapper prepareInputs(ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON) {
        ASDAC_IntegrationUtility.IntegrationWrapper initWrapper = new ASDAC_IntegrationUtility.IntegrationWrapper();
        initWrapper.metadataRecord = integrationMdt;
        DetailsWrapper detailsWrap = (DetailsWrapper)JSON.deserialize(stringifiedJSON, DetailsWrapper.class);
        String personContactId = [SELECT Id, PersonContactId FROM Account WHERE Id = :detailsWrap.recordId] ?.PersonContactId;
        initWrapper.listOfQueryParameters = new List<String>{'\'' + personContactId + '\''};
        return initWrapper;
    }
    
	/**************************************************************************
    Purpose    : Method to parse Response
    Parameters : ResponseWrapper respWrap
    Returns    : ASDAC_IntegrationUtility.ResultWrapper                                               
    **************************************************************************/
    private ASDAC_IntegrationUtility.ResultWrapper parseResponse(ResponseWrapper respWrap) {
        ASDAC_IntegrationUtility.ResultWrapper resultWrap = new ASDAC_IntegrationUtility.ResultWrapper(false, 'No Records To Display.', null);
        if(respWrap.count != null && respWrap.count > 0 && respWrap.items != null && !respWrap.items.isEmpty()) {
            List<ValueWrapper> listOfComms = new List<ValueWrapper>();
            for(ItemsWrapper itemWrap : respWrap.items) {
                ValueWrapper wrap = new ValueWrapper();
                wrap.messagepreview = itemWrap.values.messagepreview;
                wrap.businessline = itemWrap.values.businessline;
                wrap.channel = itemWrap.values.channel; 
                wrap.subject = itemWrap.values.subject;
                wrap.recipientstatus = itemWrap.values.recipientstatus;
                wrap.failreasoncode = itemWrap.values.failreasoncode;
                wrap.sender = itemWrap.values.sender;
                wrap.timestamp = getFormattedDateTime(itemWrap.values.timestamp, itemWrap.values.channel, false);
                wrap.timestamptosort = getFormattedDateTime(itemWrap.values.timestamp, itemWrap.values.channel, true);
                wrap.opentimestamp = getFormattedDateTime(itemWrap.values.opentimestamp, itemWrap.values.channel, false);
                wrap.clicktimestamp = getFormattedDateTime(itemWrap.values.clicktimestamp, itemWrap.values.channel, false);
                wrap.bouncetimestamp = getFormattedDateTime(itemWrap.values.bouncetimestamp, itemWrap.values.channel, false);
                listOfComms.add(wrap);				                
            }
			resultWrap = new ASDAC_IntegrationUtility.ResultWrapper(true, '', JSON.serialize(listOfComms));            
        }
        return resultWrap;
    }
    
    private static String getFormattedDateTime(String reponseDateTime, String channel, Boolean formatForSorting){
        String formattedDateTime;
        String timestampFormat;
        timestampFormat = (formatForSorting == true) ? System.Label.ASDAC_DateTimeFormatForSorting : System.Label.ASDAC_OmsDateTimeFormat; 
        if(reponseDateTime == null || String.isBlank(reponseDateTime) || String.isEmpty(reponseDateTime)){
            return '';
        }
        else if(channel == 'Email'){
            formattedDateTime = Datetime.valueOfGmt(reponseDateTime.replace('T',' ').substringBefore('.')).format(timestampFormat, 'Europe/London');
        }
        else if (channel == 'SMS'){
            formattedDateTime = Datetime.valueOfGmt(reponseDateTime.replace('T',' ').substringBefore('.')).format(timestampFormat, 'GMT');
        }
        return formattedDateTime;
    }
    
    
	/**************************************************************************
    Purpose : DetailsWrapper needed to create request body
    **************************************************************************/
    public Class DetailsWrapper {
        public String recordId;
        public String token;
    }
    
	/**************************************************************************
    Purpose : ResponseWrapper to parse response
    **************************************************************************/
    //Response Wrapper
    public Class ResponseWrapper {
        public Integer count;
		public List<ItemsWrapper> items;         
    }
    
    public Class ItemsWrapper {
		public ValueWrapper values;       
    }
    
	/**************************************************************************
    Purpose : ValueWrapper to send the wrapper to Lightning web component
    **************************************************************************/
    public Class ValueWrapper {
        public String messagepreview; 
        public String businessline; 
        public String timestamp; 
        public String timestamptosort; 
        public String opentimestamp; 
        public String clicktimestamp; 
        public String bouncetimestamp; 
        public String channel; 
        public String subject; 
        public String recipientstatus; 
        public String failreasoncode; 
        public String sender; 
        public string id;
        public boolean ischannelemail;
    }
}