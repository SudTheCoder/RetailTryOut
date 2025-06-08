public with sharing class ASDAC_ReceiveRequest {        

        public String updateUser = ASDAC_OMSConstants.SFSC_USER;
        public String orgId;
        public String sellingChannel;	
        public String orderId;
        public String orderType;
        public List<Cls_orderLines> orderLines;
        public class Cls_orderLines {
            	
            public Integer orderLineId;	
            public Decimal quantity;
            public Boolean receivedInSFSC;
            public String updateUser;

        }


            
}