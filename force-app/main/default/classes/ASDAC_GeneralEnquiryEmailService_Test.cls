/******************************************************************************
Name: ASDAC_GeneralEnquiryEmailServiceHandler_Test
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
@isTest
public class ASDAC_GeneralEnquiryEmailService_Test {
    
	/**************************************************************************
    Purpose    : This method will test handleInboundEmail positive result.
    Parameters : Messaging.InboundEmail email, 
				 Messaging.InboundEnvelope envelope
    Returns    : Messaging.InboundEmailResult                                              
    **************************************************************************/    
    static testMethod void testHandleInboundEmailPositive() {  
        User adminUser = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        adminUser.email = System.Label.ASDAC_DefaultEmailForFeed;
        adminUser.userName = adminUser.userName + '.systemAdmin';
        insert adminUser;
        System.runAs(adminUser) {
            // Create a new email and envelope object.
            Messaging.InboundEmail email  = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            // Test with the subject that matches the unsubscribe statement.
            email.subject = 'test unsubscribe test';
       	    email.replyTo = 'abc@asdatest.co.uk'; 
            env.fromAddress = 'user@acme.com';
            // Call the class and test it with the data in the testMethod.
            ASDAC_GeneralEnquiryEmailServiceHandler emailServiceObj = new ASDAC_GeneralEnquiryEmailServiceHandler();
            emailServiceObj.handleInboundEmail(email, env);
            System.assertEquals(1, Limits.getEmailInvocations(), 'Email Sent');
        }
    }
    
	/**************************************************************************
    Purpose    : This method will test handleInboundEmail negative.
    Parameters : Messaging.InboundEmail email, 
				 Messaging.InboundEnvelope envelope
    Returns    : Messaging.InboundEmailResult                                              
    **************************************************************************/    
    static testMethod void testHandleInboundEmailNegative() {  
        User adminUser = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        adminUser.email = System.Label.ASDAC_DefaultEmailForFeed;
        adminUser.userName = adminUser.userName + '.systemAdmin';
        insert adminUser;
        System.runAs(adminUser) {
            // Create a new email and envelope object.
            Messaging.InboundEmail email  = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            // Test with the subject that matches the unsubscribe statement.
            email.subject = 'test unsubscribe test';
            env.fromAddress = 'user@acme.com';
            // Call the class and test it with the data in the testMethod.
            ASDAC_GeneralEnquiryEmailServiceHandler emailServiceObj = new ASDAC_GeneralEnquiryEmailServiceHandler();
            emailServiceObj.handleInboundEmail(email, env);
            System.assertEquals(0, Limits.getEmailInvocations(), 'Execption test. No email is sent');
        }
    }
}