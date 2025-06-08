/******************************************************************************
Name: ASDAC_GeneralEnquiryEmailServiceHandler
===============================================================================
Req: 
ASDAC-6947 General email enquiries redirect to help centre general webform
===============================================================================
Purpose: Redirect to the ASDA Help Site when an email comes on 
		 General Enquiry Email Address.
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		19 Jan 2023    Initial Development
******************************************************************************/
global with sharing class ASDAC_GeneralEnquiryEmailServiceHandler implements Messaging.InboundEmailHandler {
        
	/**************************************************************************
    Purpose    : This method will process the incoming email and will send 
				 the Auto-response email back to the sender which will
				 contain the link to Help Centre site.
    Parameters : Messaging.InboundEmail email, 
				 Messaging.InboundEnvelope envelope
    Returns    : Messaging.InboundEmailResult                                              
    **************************************************************************/ 
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        result.success = true;//Success as true means we have to process this email always and 
        					  //we do not need to send anything back to customer in case of any failures.
        try {
            String linkStyle = 'style="color: #0B9B4B"';
            EmailTemplate et = [SELECT htmlValue, Subject FROM EmailTemplate WHERE DeveloperName = :Label.ASDAC_GeneralEnquiryAutoResponseEmailTemplateName WITH SECURITY_ENFORCED];
            String emailBody = et.htmlValue;
            emailBody = emailBody.replace('{Subject}', '<b>' + email.subject + '</b>');
            emailBody = emailBody.replace('{FullName}', '<b>' + email.fromName + '</b>');
            emailBody = emailBody.replace('{HelpCentreLink}', '(<a href = "' + Label.ASDAC_HelpCentreSiteURL + '"' + linkStyle + '>' + Label.ASDAC_HelpCentreSiteURL + '</a>)');
            emailBody = emailBody.replace('{PrivacyCentreLink}', '<a href = "' + Label.ASDAC_PrivacyCentreSiteURL + '"' + linkStyle + '>' + Label.ASDAC_PrivacyCentre + '</a>');
            emailBody = emailBody.replace('{HelpCentre}', '<a href = "' + Label.ASDAC_HelpCentreSiteURL + '"' + linkStyle + '>' + Label.ASDAC_HelpCentre + '</a>');
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { email.replyTo};
			message.subject = et.Subject;
            message.htmlBody = emailBody;
            message.setUseSignature(false);
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
			Messaging.sendEmail(messages);
        }
        catch(Exception ex) {
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_GeneralEnquiryEmailServiceHandler');
            ASDAC_Logger.writeLogsToDatabase();
        }
        return result;
    }
}