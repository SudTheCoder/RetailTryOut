/************************************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-05-22
* @description                  : Paymnet Aithorization request payload wrapper class
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                22-May-2023      Created the class
***************************************************************************************************/
public class ASDAC_PaymentPayloadWrapper{
    public Order order {get; Set;}
	public CardPaymentMethodSpecificInput cardPaymentMethodSpecificInput;
    
	public class Order {
		public AmountOfMoney amountOfMoney;
		public References references;
	}
    
	public class AmountOfMoney {
		public String currencyCode ;	
		public Integer amount ;	
	}
    
	public class References {
		public String merchantReference ;	
	}
    public class ThreeDSecure {
        public boolean skipAuthentication; 
    }
    public class Recurring {
        public String recurringPaymentSequenceIndicator;
    }
    
	public class CardPaymentMethodSpecificInput {
        public String token;
        public String authorizationMode ;	
		public String transactionChannel;
        public String schemeReferenceData;
        public Recurring recurring;
        public Integer paymentProductId;
        public ThreeDSecure threeDSecure;
        public boolean isRecurring;
	}
    
	
}