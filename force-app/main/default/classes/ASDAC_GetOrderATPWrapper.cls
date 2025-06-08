public with sharing class ASDAC_GetOrderATPWrapper {
    
    public String orgId = ASDAC_OMSConstants.ASDA_STRING;
    public String sellingChannel = ASDAC_OMSConstants.GEORGECOM_STRING;
    public String transactionType = ASDAC_OMSConstants.eComm_STRING;	
    public List<Cls_availabilityByProducts> availabilityByProducts;
    
    public class Cls_availabilityByProducts {
        public String productId;	
        public String uom;
        public Cls_gtin gtin;
        public Cls_launchDateTime launchDateTime;
        public Cls_launchDate launchDate;
        public String associationType;	
        public List<Cls_availabilityByFulfillmentTypes> availabilityByFulfillmentTypes;
    }
    
    public class Cls_gtin {}
    
    public class Cls_launchDateTime {}
    
    public class Cls_launchDate {}
    
    public class Cls_availabilityByFulfillmentTypes {
        public String fulfillmentType;
        public List<Cls_availabilityDetails> availabilityDetails;
    }
    
    public class Cls_availabilityDetails {
        public String segment;
        public Decimal atp;
        public Decimal supply;
        public Decimal demand;	
        public Decimal safetyStock;
        public String atpStatus;
        public List<Cls_availabilityByLocations> availabilityByLocations;
    }
    
    public class Cls_availabilityByLocations {
        public String locationId;	
        public String locationType;	
        public Decimal atp;
        public Decimal supply;
        public Decimal demand;	
        public Decimal safetyStock;	
        public String atpStatus;
        public List<Cls_futureQtyByDates> futureQtyByDates;
    }
    
    public class Cls_futureQtyByDates {}
}